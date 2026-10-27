"""Régleur automatique de l'équilibrage (avant-goût de l'étape 4).

Usage : python3 tools/regleur.py <tours de réglage> <combats par tour>
(Godot doit être lancé par la commande indiquée dans la variable GODOT, par défaut ~/godot/godot.)

À chaque tour de réglage :
1. tools/equilibrage.gd fait jouer les combats (4 processus en parallèle), l'IA aux commandes des deux duos ;
2. on mesure le taux de victoire de chaque classe, compétence, passif et Synergie ;
3. on corrige le chiffre principal de chacun, proportionnellement à son écart :
   - une classe : ses PV max (écart à 50 %) ;
   - une compétence ou un passif : son chiffre (écart au taux de sa classe, pour ne pas corriger deux fois) ;
   - une Synergie : son chiffre (écart à la moyenne de ses deux classes).
   - une paire d'éléments d'un même kit (deux compétences, ou une compétence et le passif) : son ajustement de PV et
     de puissance dans data/destins.json (écart entre le taux des kits qui ont la paire et ce qu'on attendrait de
     chacun des deux éléments seul). C'est le budget de puissance du Destin : aucun kit ne doit dominer.
Les fichiers de data/ sont réécrits ; on relit le résultat avec tools/equilibrage.py.
"""
import json
import math
import os
import re
import subprocess
import sys
from collections import defaultdict

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DATA = os.path.join(ROOT, "data")
GODOT = os.environ.get("GODOT", os.path.expanduser("~/godot/godot"))
OUT = os.environ.get("EQUILIBRAGE_DIR", "/tmp/equilibrage")
GAIN = 1.0
# Un passif ou une Synergie bouge moins le taux de victoire qu'une compétence : on les corrige plus fort.
PASSIVE_GAIN = 2.5
SYNERGY_GAIN = 1.2
CLASS_GAIN = 0.6
MAX_STEP = 0.15

# Le chiffre principal de chaque compétence : (type d'effet, clé). Rempart n'a pas de chiffre : il n'est pas réglé.
SKILL_LEVERS = {
    "taillade": [("damage", "power")], "coup_de_bouclier": [("damage", "power")],
    "provocation": [("damage", "power")], "fendoir": [("damage", "power"), ("status", "value")],
    "cri_de_guerre": [("damage", "power")],
    "boule_de_feu": [("damage", "power")], "etincelle": [("damage", "power")],
    "trait_de_givre": [("damage", "power")], "arc_de_foudre": [("damage", "power")],
    "nova": [("damage", "power")], "bouclier_de_mana": [("barrier", "power")],
    "chatiment": [("damage", "power")], "priere": [("heal", "power")],
    "restauration": [("heal", "power")], "purification": [("heal", "power")],
    "egide": [("barrier", "power")], "resurrection": [("revive", "percent")],
}
# Le chiffre principal de chaque passif (plus il est haut, plus le passif est fort). Résonance et Météorologue
# (une recharge en moins) n'ont pas de chiffre fin : ils ne sont pas réglés automatiquement.
PASSIVE_LEVERS = {
    "peau_de_fer": "reduction", "second_souffle": "heal", "veteran": "damage", "colere": "per_quarter",
    "focalisation": "bonus", "brasier": "value", "foi": "bonus", "martyr": "share",
    "lumiere_interieure": "heal", "sanctuaire": "bonus",
}
SYNERGY_LEVERS = {
    "provocation_nova": "bonus", "trait_de_givre_chatiment": "damage",
    "provocation_chatiment": "mult", "arc_de_foudre_priere": "mult",
    "fendoir_boule_de_feu": "bonus", "cri_de_guerre_bouclier_de_mana": "share",
}
PAIR_GAIN = 0.5
PAIR_LIMIT = 0.15
# Une compétence ou un passif sans chiffre à régler (Rempart, Résonance, Météorologue) se règle par le budget du
# Destin : un ajustement de PV et de puissance du perso qui l'a (data/destins.json, « kit_items »).
ITEM_GAIN = 0.5
# En duo, un élément n'a pas la même force selon la classe du partenaire (un Bouclier de mana protège mieux un Guerrier
# qui encaisse) : réglé par « duo_items ». La composition du duo, qui touche les deux membres : « duo_classes ».
COMPO_GAIN = 0.25
# Bornes des chiffres de Synergie : au-delà, une Synergie change de nature (ou ne se joue pas assez pour être réglée
# par sa force : il faut alors revoir son effet).
SYNERGY_LIMITS = {"mult": (0.5, 1.5), "share": (0.3, 1.0), "bonus": (0.05, 1.0)}


def load(name):
    with open(os.path.join(DATA, name), encoding="utf-8") as f:
        return json.load(f)


def write_skills(skills):
    lines = ["{"]
    items = list(skills.items())
    previous = None
    for i, (key, skill) in enumerate(items):
        if previous is not None and skill["class"] != previous:
            lines.append("")
        previous = skill["class"]
        head = ", ".join(f'"{k}": {json.dumps(v, ensure_ascii=False)}' for k, v in skill.items() if k not in ("effects", "description"))
        effects = ", ".join(json.dumps(e, ensure_ascii=False) for e in skill["effects"])
        lines += [f'  "{key}": {{', f"    {head},", f'    "effects": [{effects}],',
                  f'    "description": {json.dumps(skill["description"], ensure_ascii=False)}',
                  "  }" + ("," if i < len(items) - 1 else "")]
    lines.append("}")
    with open(os.path.join(DATA, "skills.json"), "w", encoding="utf-8") as f:
        f.write("\n".join(lines) + "\n")


def write_passives(passives):
    lines = ["{"]
    items = list(passives.items())
    previous = None
    for i, (key, passive) in enumerate(items):
        if previous is not None and passive["class"] != previous:
            lines.append("")
        previous = passive["class"]
        lines.append(f'  "{key}": ' + json.dumps(passive, ensure_ascii=False) + ("," if i < len(items) - 1 else ""))
    lines.append("}")
    with open(os.path.join(DATA, "passives.json"), "w", encoding="utf-8") as f:
        f.write("\n".join(lines) + "\n")


def write_destins(destins):
    lines = ["{"]
    sections = ("kit_items", "kit_pairs", "kit_triples", "duo_classes", "acolyte_classes", "duo_items")
    for n, section in enumerate(sections):
        values = destins.get(section, {})
        lines.append(f'  "{section}": {{')
        if section == "duo_items":
            partners = sorted(values)
            for p_index, partner in enumerate(partners):
                inner = values[partner]
                keys = sorted(k for k, v in inner.items() if v != 0)
                body = ", ".join(f'"{k}": {inner[k]}' for k in keys)
                lines.append(f'    "{partner}": {{{body}}}' + ("," if p_index < len(partners) - 1 else ""))
        else:
            keys = sorted(k for k, v in values.items() if v != 0)
            lines += [f'    "{k}": {values[k]}' + ("," if i < len(keys) - 1 else "") for i, k in enumerate(keys)]
        lines.append("  }" + ("," if n < len(sections) - 1 else ""))
    lines.append("}")
    with open(os.path.join(DATA, "destins.json"), "w", encoding="utf-8") as f:
        f.write("\n".join(lines) + "\n")


def write_synergies(synergies):
    with open(os.path.join(DATA, "synergies.json"), "w", encoding="utf-8") as f:
        f.write(json.dumps(synergies, ensure_ascii=False, indent=2) + "\n")


def set_class_stats(class_id, hp, power):
    path = os.path.join(DATA, "classes", class_id + ".json")
    with open(path, encoding="utf-8") as f:
        text = f.read()
    text = re.sub(r'"max_hp": \d+', f'"max_hp": {hp}', text)
    text = re.sub(r'"power": \d+', f'"power": {power}', text)
    with open(path, "w", encoding="utf-8") as f:
        f.write(text)


def simulate(round_index, count):
    os.makedirs(OUT, exist_ok=True)
    per_process = max(1, count // 4)
    procs = []
    files = []
    for k in range(4):
        path = os.path.join(OUT, f"r{round_index}_{k}.csv")
        files.append(path)
        procs.append(subprocess.Popen([GODOT, "--headless", "--path", ROOT, "--script", "res://tools/equilibrage.gd", "--",
                                       str(per_process), str(1000 * round_index + k + 1), path],
                                      stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL))
    for proc in procs:
        proc.wait()
    return files


GAMES = {}


def measure(files):
    import csv
    rates = defaultdict(lambda: [0, 0])
    for path in files:
        with open(path, encoding="utf-8") as f:
            for row in csv.DictReader(f):
                won = int(row["gagne"])
                keys = []
                for side, prefix, partner in (("joueur", "j_", "acolyte"), ("acolyte", "a_", "joueur")):
                    cls = row[side]
                    keys += ["classe:" + cls, "passif:" + row[prefix + "passif"]]
                    keys += ["comp:" + row[prefix + t] for t in ("basique", "moyenne", "forte")]
                    keys += [f"duo:{row[partner]}:{row[prefix + t]}" for t in ("basique", "moyenne", "forte", "passif")]
                    keys.append(f"duoclasse:{row[partner]}:{cls}")
                    if side == "acolyte":
                        keys.append("acolyte:" + cls)
                    keys.append("trio:" + "+".join(sorted(row[prefix + t] for t in ("basique", "moyenne", "forte"))))
                keys += ["syn:" + s for s in filter(None, row["synergies_possibles"].split("+"))]
                keys.append("compo:" + "+".join(sorted([row["joueur"], row["acolyte"]])))
                for key in keys:
                    rates[key][0] += won
                    rates[key][1] += 1
    GAMES.clear()
    GAMES.update({k: g for k, (w, g) in rates.items()})
    return {k: 100.0 * w / g for k, (w, g) in rates.items() if g > 0}


def pair_key(a, b):
    return f"{a}+{b}" if a < b else f"{b}+{a}"


def measure_pairs(files):
    """Pour chaque paire d'un même kit : (taux observé, taux attendu des deux éléments pris seuls, marge, parties)."""
    import csv
    import itertools
    single = defaultdict(lambda: [0, 0])
    pair = defaultdict(lambda: [0, 0])
    classes = defaultdict(lambda: [0, 0])
    owner = {}
    for path in files:
        with open(path, encoding="utf-8") as f:
            for row in csv.DictReader(f):
                won = int(row["gagne"])
                for side, prefix in (("joueur", "j_"), ("acolyte", "a_")):
                    items = [row[prefix + t] for t in ("basique", "moyenne", "forte", "passif")]
                    for entry in [classes[row[side]]] + [single[i] for i in items]:
                        entry[0] += won
                        entry[1] += 1
                    for a, b in itertools.combinations(items, 2):
                        key = pair_key(a, b)
                        owner[key] = row[side]
                        pair[key][0] += won
                        pair[key][1] += 1
    rate = lambda e: 100.0 * e[0] / e[1]
    result = {}
    for key, entry in pair.items():
        a, b = key.split("+")
        expected = rate(single[a]) + rate(single[b]) - rate(classes[owner[key]])
        result[key] = (rate(entry), expected, 196.0 * math.sqrt(0.25 / entry[1]), entry[1])
    return result


def tune_pairs(pairs):
    destins = load("destins.json")
    values = destins.setdefault("kit_pairs", {})
    report = []
    for key, (observed, expected, margin, games) in sorted(pairs.items()):
        deviation = observed - expected
        if abs(deviation) < max(1.5, margin):
            continue
        old = values.get(key, 0.0)
        values[key] = round(min(PAIR_LIMIT, max(-PAIR_LIMIT, old - PAIR_GAIN * deviation / 100.0)), 3)
        report.append(f"paire {key} ({deviation:+.1f}) : {old:+.3f} -> {values[key]:+.3f}")
    write_destins(destins)
    return report


def step(value, deviation, gain=GAIN):
    factor = 1.0 - gain * deviation / 100.0
    factor = min(1.0 + MAX_STEP, max(1.0 - MAX_STEP, factor))
    return value * factor


def step_int(value, deviation, gain=GAIN):
    """Un petit nombre entier (puissance 24, brûlure 9) ne bougerait jamais à l'arrondi : on le bouge d'au moins 1
    quand l'écart est net."""
    new = max(1, int(round(step(value, deviation, gain))))
    if new == value and abs(deviation) >= 1.5:
        new = max(1, value - 1 if deviation > 0 else value + 1)
    return new


def tune(rates):
    skills = load("skills.json")
    passives = load("passives.json")
    synergies = load("synergies.json")
    report = []
    for class_id in load("classes.json"):
        deviation = rates["classe:" + class_id] - 50.0
        if abs(deviation) < 0.8:
            continue
        cls = load(os.path.join("classes", class_id + ".json"))
        hp = cls["stats"]["max_hp"]
        power = cls["stats"]["power"]
        # Une classe se règle par ses PV et sa puissance (qui porte aussi les soins et les barrières).
        new_hp = int(round(step(hp, deviation, CLASS_GAIN) / 5.0) * 5)
        new_power = int(round(step(power, deviation, CLASS_GAIN)))
        set_class_stats(class_id, new_hp, new_power)
        report.append(f"classe {class_id} {rates['classe:' + class_id]:.1f} % : PV {hp} -> {new_hp}, puissance {power} -> {new_power}")
    for skill_id, levers in SKILL_LEVERS.items():
        skill = skills[skill_id]
        deviation = rates["comp:" + skill_id] - rates["classe:" + skill["class"]]
        if abs(deviation) < 1.0:
            continue
        for effect_type, key in levers:
            for effect in skill["effects"]:
                if effect["type"] == effect_type and key in effect:
                    old = effect[key]
                    effect[key] = step_int(old, deviation)
                    report.append(f"{skill_id} ({deviation:+.1f}) : {key} {old} -> {effect[key]}")
                    break
    destins = load("destins.json")
    items = destins.setdefault("kit_items", {})
    unleveled = [(sid, "comp:", s["class"]) for sid, s in skills.items() if sid not in SKILL_LEVERS]
    unleveled += [(pid, "passif:", p["class"]) for pid, p in passives.items() if pid not in PASSIVE_LEVERS]
    for item_id, prefix, class_id in unleveled:
        deviation = rates[prefix + item_id] - rates["classe:" + class_id]
        if abs(deviation) < 1.0:
            continue
        old = items.get(item_id, 0.0)
        items[item_id] = round(min(PAIR_LIMIT, max(-PAIR_LIMIT, old - ITEM_GAIN * deviation / 100.0)), 3)
        report.append(f"budget {item_id} ({deviation:+.1f}) : {old:+.3f} -> {items[item_id]:+.3f}")
    duo_items = destins.setdefault("duo_items", {})
    for key, rate in sorted(rates.items()):
        if not key.startswith("duo:"):
            continue
        _, partner, item_id = key.split(":")
        own_class = skills[item_id]["class"] if item_id in skills else passives[item_id]["class"]
        overall = rates.get("comp:" + item_id, rates.get("passif:" + item_id))
        # L'écart propre au partenaire : l'élément comparé à sa classe dans ce duo, moins son écart à sa classe en
        # général (déjà réglé par son chiffre). Ainsi un duo entier qui gagne trop ne déplace pas tous ses éléments.
        deviation = (rate - rates[f"duoclasse:{partner}:{own_class}"]) - (overall - rates["classe:" + own_class])
        margin = 196.0 * math.sqrt(0.25 / GAMES[key])
        if abs(deviation) < max(1.5, margin):
            continue
        inner = duo_items.setdefault(partner, {})
        old = inner.get(item_id, 0.0)
        inner[item_id] = round(min(PAIR_LIMIT, max(-PAIR_LIMIT, old - ITEM_GAIN * deviation / 100.0)), 3)
        report.append(f"budget {item_id} avec un {partner} ({deviation:+.1f}) : {old:+.3f} -> {inner[item_id]:+.3f}")
    # Les trois compétences d'un kit ensemble (un trio qui va trop bien ou trop mal ensemble, au-delà de ses paires).
    triples = destins.setdefault("kit_triples", {})
    for key, rate in sorted(rates.items()):
        if not key.startswith("trio:"):
            continue
        trio = key.split(":")[1]
        deviation = rate - rates["classe:" + skills[trio.split("+")[0]]["class"]]
        margin = 196.0 * math.sqrt(0.25 / GAMES[key])
        if abs(deviation) < max(1.5, margin):
            continue
        old = triples.get(trio, 0.0)
        triples[trio] = round(min(PAIR_LIMIT, max(-PAIR_LIMIT, old - ITEM_GAIN * deviation / 100.0)), 3)
        report.append(f"budget du trio {trio} ({deviation:+.1f}) : {old:+.3f} -> {triples[trio]:+.3f}")
    # Une classe jouée en acolyte (toujours par l'IA) comparée à la même classe en général.
    acolytes = destins.setdefault("acolyte_classes", {})
    for key, rate in sorted(rates.items()):
        if not key.startswith("acolyte:"):
            continue
        class_id = key.split(":")[1]
        deviation = rate - rates["classe:" + class_id]
        if abs(deviation) < 0.8:
            continue
        old = acolytes.get(class_id, 0.0)
        acolytes[class_id] = round(min(PAIR_LIMIT, max(-PAIR_LIMIT, old - ITEM_GAIN * deviation / 100.0)), 3)
        report.append(f"budget de l'acolyte {class_id} ({deviation:+.1f}) : {old:+.3f} -> {acolytes[class_id]:+.3f}")
    compos = destins.setdefault("duo_classes", {})
    for key, rate in sorted(rates.items()):
        if not key.startswith("compo:"):
            continue
        deviation = rate - 50.0
        if abs(deviation) < 0.8:
            continue
        compo = key.split(":")[1]
        old = compos.get(compo, 0.0)
        compos[compo] = round(min(PAIR_LIMIT, max(-PAIR_LIMIT, old - COMPO_GAIN * deviation / 100.0)), 3)
        report.append(f"budget du duo {compo} ({deviation:+.1f}) : {old:+.3f} -> {compos[compo]:+.3f}")
    write_destins(destins)
    for passive_id, key in PASSIVE_LEVERS.items():
        passive = passives[passive_id]
        deviation = rates["passif:" + passive_id] - rates["classe:" + passive["class"]]
        if abs(deviation) < 1.0:
            continue
        old = passive["params"][key]
        passive["params"][key] = step_int(old, deviation, PASSIVE_GAIN) if isinstance(old, int) else round(step(old, deviation, PASSIVE_GAIN), 3)
        report.append(f"passif {passive_id} ({deviation:+.1f}) : {key} {old} -> {passive['params'][key]}")
    for synergy in synergies:
        key = SYNERGY_LEVERS.get(synergy["id"])
        if key is None:
            continue
        a, b = synergy["skills"]
        # Une Synergie se compare aux duos de la même composition (une Synergie Guerrier-Mage aux duos Guerrier + Mage).
        base = rates["compo:" + "+".join(sorted([skills[a]["class"], skills[b]["class"]]))]
        deviation = rates.get("syn:" + synergy["id"], base) - base
        if abs(deviation) < 1.5:
            continue
        old = synergy["params"][key]
        if isinstance(old, int):
            synergy["params"][key] = step_int(old, deviation, SYNERGY_GAIN)
        else:
            low, high = SYNERGY_LIMITS.get(key, (0.0, 10.0))
            synergy["params"][key] = round(min(high, max(low, step(old, deviation, SYNERGY_GAIN))), 3)
        report.append(f"synergie {synergy['id']} ({deviation:+.1f}) : {key} {old} -> {synergy['params'][key]}")
    write_skills(skills)
    write_passives(passives)
    write_synergies(synergies)
    return report


def main():
    rounds = int(sys.argv[1]) if len(sys.argv) > 1 else 5
    count = int(sys.argv[2]) if len(sys.argv) > 2 else 12000
    for r in range(1, rounds + 1):
        files = simulate(r, count)
        rates = measure(files)
        pairs = measure_pairs(files)
        spread = [v for k, v in rates.items() if k.startswith(("comp:", "passif:", "classe:"))]
        worst_pair = max(abs(o - e) for o, e, _, _ in pairs.values())
        print(f"\n== Réglage {r} : écart max à 50 % = {max(abs(v - 50) for v in spread):.1f} points ; pire paire : {worst_pair:.1f} points")
        for line in tune(rates) + tune_pairs(pairs):
            print("  " + line)
        sys.stdout.flush()


if __name__ == "__main__":
    main()
