"""Régleur automatique de l'équilibrage (avant-goût de l'étape 4).

Usage : python3 tools/regleur.py <tours de réglage> <combats par tour>
(Godot doit être lancé par la commande indiquée dans la variable GODOT, par défaut ~/godot/godot.)

À chaque tour de réglage :
1. tools/equilibrage.gd fait jouer les combats (4 processus en parallèle), l'IA aux commandes des deux duos ;
2. on mesure le taux de victoire de chaque classe, compétence, passif et Synergie ;
3. on corrige le chiffre principal de chacun, proportionnellement à son écart :
   - une classe : sa puissance (écart à 50 %) ; ses PV restent ceux de son rôle (le Front le plus solide, le Dégâts
     le plus fragile), sinon le réglage finit par casser l'identité des classes ;
   - une compétence ou un passif : son chiffre (écart au taux de sa classe, pour ne pas corriger deux fois) ;
   - une Synergie : son chiffre (écart à la moyenne de ses deux classes) ;
   - le budget de puissance du Destin (data/destins.json, ajustements de PV et de puissance) : un élément sans chiffre
     (« kit_items »), la composition du duo (« duo_classes »), qui en est le joueur (« duo_orders »), une classe jouée
     en acolyte (« acolyte_classes »), et chaque kit complet, côté joueur et côté acolyte séparément (« kits » : un
     Destin de joueur n'est jamais joué en acolyte, et un même kit n'a pas la même force selon qui le joue).
   Les leviers par paire, par trio et par élément-selon-le-partenaire (« kit_pairs », « kit_triples », « duo_items »)
   ne sont plus réglés : à 10 classes, ces ajustements qui s'additionnent sur un même kit avec celui du kit entier
   avaient divergé (jusqu'à +60 % sur un kit, 6 % à 94 % de victoires). Le kit entier, mesuré directement, suffit
   avec 400 000 combats par passe ; et le moteur plafonne le total à ±25 %.
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
SYNERGY_GAIN = 0.8
CLASS_GAIN = 0.6
# Pas maximal d'un chiffre par passe. À 10 %, une compétence à 18 points de sa classe (Encouragement, Argument après le
# run 2) mettait cinq passes à revenir ; à 15 %, trois. L'amortissement divise le pas par deux dès qu'un écart change de sens.
MAX_STEP = 0.15

# Les chiffres que le régleur fait bouger viennent des données : pour une compétence, tous ses chiffres de force
# (« power », « value », « percent » de ses effets, scalés ensemble) ; pour un passif ou une Synergie, le chiffre
# nommé par « lever ». Sans chiffre (Rempart, Résonance, Météorologue), l'élément se règle par le budget du Destin.
SKILL_LEVER_KEYS = ("power", "value", "percent")
# Leviers dont un chiffre plus grand AFFAIBLIT le passif (« un coup sur N est détourné », « seconde esquive à partir du
# tour N ») : le régleur les bouge dans l'autre sens. Sans ça, il avait ramené Charisme de 4 à 1 (tous les coups
# détournés) et Esquive de 5 à 2 en croyant les affaiblir, et tout le Diplomate s'était déformé pour compenser.
INVERTED_LEVERS = ("redirect_every", "dodge_again_from_turn")


def skill_levers(skill):
    return [(effect["type"], key) for effect in skill["effects"] for key in SKILL_LEVER_KEYS if key in effect]


PAIR_LIMIT = 0.15
# Une compétence ou un passif sans chiffre à régler (Rempart, Résonance, Météorologue) se règle par le budget du
# Destin : un ajustement de PV et de puissance du perso qui l'a (data/destins.json, « kit_items »).
ITEM_GAIN = 0.4
# La composition du duo, qui touche les deux membres : « duo_classes » ; et qui en est le joueur et qui l'acolyte
# (« mage>guerrier » : un Mage avec son acolyte Guerrier) : « duo_orders ».
COMPO_GAIN = 0.25
# Le reste d'un kit complet, par côté (joueur ou acolyte) : comparé à sa classe jouée du même côté (chaque kit est
# mesuré directement, environ 1 250 parties par kit et par côté avec 400 000 combats).
KIT_GAIN = 0.5
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
    sections = ("kit_items", "kit_pairs", "kit_triples", "duo_classes", "duo_orders", "acolyte_classes", "duo_items", "kits")
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
        elif section == "kits":
            # Un kit par ligne, rangé par côté puis par classe (ils sont nombreux : 32 par classe et par côté).
            for s_index, side in enumerate(("joueur", "acolyte")):
                inner = values.get(side, {})
                keys = sorted(k for k, v in inner.items() if v != 0)
                lines.append(f'    "{side}": {{')
                lines += [f'      "{k}": {inner[k]}' + ("," if i < len(keys) - 1 else "") for i, k in enumerate(keys)]
                lines.append("    }" + ("," if s_index == 0 else ""))
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
                    # Le kit complet, du côté où il est joué (un Destin de joueur n'est jamais joué en acolyte).
                    keys.append(f"cote:{side}:{cls}")
                    keys.append(f"kit:{side}:{cls}:" + "+".join(row[prefix + t] for t in ("basique", "moyenne", "forte", "passif")))
                keys += ["syn:" + s for s in filter(None, row["synergies_possibles"].split("+"))]
                keys.append("compo:" + "+".join(sorted([row["joueur"], row["acolyte"]])))
                keys.append(f"ordre:{row['joueur']}>{row['acolyte']}")
                for key in keys:
                    rates[key][0] += won
                    rates[key][1] += 1
    GAMES.clear()
    GAMES.update({k: g for k, (w, g) in rates.items()})
    return {k: 100.0 * w / g for k, (w, g) in rates.items() if g > 0}


# Amortissement : un levier dont l'écart change de sens d'une passe à l'autre a dépassé sa cible ; son pas est divisé
# par deux (et remonte peu à peu tant que l'écart garde le même sens). Sans ça, plusieurs leviers qui corrigent le même
# écart (une Synergie, les deux membres d'un duo, leurs compétences) le faisaient osciller de ±20 points.
DAMPING = {}


def damp(key, deviation):
    state = DAMPING.get(key)
    mult = 1.0
    if state is not None:
        mult = state["mult"] * 0.5 if state["dev"] * deviation < 0 else min(1.0, state["mult"] * 1.25)
    DAMPING[key] = {"dev": deviation, "mult": mult}
    return mult


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
        # Une classe se règle par sa puissance (qui porte aussi les soins et les barrières). Ses PV ne bougent pas : ils
        # disent son rôle (un réglage par les PV avait fini par donner moins de PV au Guerrier qu'au Prêtre).
        new_hp = hp
        new_power = int(round(step(power, deviation, CLASS_GAIN * damp("classe:" + class_id, deviation))))
        set_class_stats(class_id, new_hp, new_power)
        report.append(f"classe {class_id} {rates['classe:' + class_id]:.1f} % : PV {hp} -> {new_hp}, puissance {power} -> {new_power}")
    for skill_id, skill in skills.items():
        if skill.get("monster") or not skill_levers(skill) or ("comp:" + skill_id) not in rates:
            continue
        deviation = rates["comp:" + skill_id] - rates["classe:" + skill["class"]]
        if abs(deviation) < 1.0:
            continue
        for effect in skill["effects"]:
            for key in SKILL_LEVER_KEYS:
                if key in effect:
                    old = effect[key]
                    gain = GAIN * damp("comp:" + skill_id, deviation)
                    # Un chiffre à virgule (la part de puissance d'une créature : 0,7) reste à virgule : arrondi en entier,
                    # le Golem était passé à 4 fois la puissance de l'Invocateur et oscillait entre 3 et 4.
                    effect[key] = step_int(old, deviation, gain) if isinstance(old, int) else round(step(old, deviation, gain), 3)
                    report.append(f"{skill_id} ({deviation:+.1f}) : {key} {old} -> {effect[key]}")
    destins = load("destins.json")
    items = destins.setdefault("kit_items", {})
    unleveled = [(sid, "comp:", s["class"]) for sid, s in skills.items() if not skill_levers(s)]
    unleveled += [(pid, "passif:", p["class"]) for pid, p in passives.items() if not p.get("lever")]
    for item_id, prefix, class_id in unleveled:
        deviation = rates[prefix + item_id] - rates["classe:" + class_id]
        if abs(deviation) < 1.0:
            continue
        old = items.get(item_id, 0.0)
        items[item_id] = round(min(PAIR_LIMIT, max(-PAIR_LIMIT, old - ITEM_GAIN * damp("budget:" + item_id, deviation) * deviation / 100.0)), 3)
        report.append(f"budget {item_id} ({deviation:+.1f}) : {old:+.3f} -> {items[item_id]:+.3f}")
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
        acolytes[class_id] = round(min(PAIR_LIMIT, max(-PAIR_LIMIT, old - ITEM_GAIN * damp(key, deviation) * deviation / 100.0)), 3)
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
        compos[compo] = round(min(PAIR_LIMIT, max(-PAIR_LIMIT, old - COMPO_GAIN * damp(key, deviation) * deviation / 100.0)), 3)
        report.append(f"budget du duo {compo} ({deviation:+.1f}) : {old:+.3f} -> {compos[compo]:+.3f}")
    # Qui est le joueur et qui est l'acolyte, dans une même composition (un Mage avec son acolyte Guerrier, contre un
    # Guerrier avec son acolyte Mage) : comparé à la composition.
    orders = destins.setdefault("duo_orders", {})
    for key, rate in sorted(rates.items()):
        if not key.startswith("ordre:"):
            continue
        order = key.split(":")[1]
        deviation = rate - rates["compo:" + "+".join(sorted(order.split(">")))]
        if abs(deviation) < 0.8:
            continue
        old = orders.get(order, 0.0)
        orders[order] = round(min(PAIR_LIMIT, max(-PAIR_LIMIT, old - COMPO_GAIN * damp(key, deviation) * deviation / 100.0)), 3)
        report.append(f"budget du duo {order} ({deviation:+.1f}) : {old:+.3f} -> {orders[order]:+.3f}")
    # Chaque kit complet, côté joueur et côté acolyte : ce que les éléments et la composition n'expliquent pas
    # (comparé à sa classe jouée du même côté, pour ne rien corriger deux fois).
    kits = destins.setdefault("kits", {"joueur": {}, "acolyte": {}})
    for key, rate in sorted(rates.items()):
        if not key.startswith("kit:"):
            continue
        _, side, kit = key.split(":", 2)
        deviation = rate - rates[f"cote:{side}:{kit.split(':')[0]}"]
        margin = 196.0 * math.sqrt(0.25 / GAMES[key])
        if abs(deviation) < max(1.5, margin):
            continue
        inner = kits.setdefault(side, {})
        old = inner.get(kit, 0.0)
        inner[kit] = round(min(PAIR_LIMIT, max(-PAIR_LIMIT, old - KIT_GAIN * damp(key, deviation) * deviation / 100.0)), 3)
        report.append(f"budget du kit {kit} en {side} ({deviation:+.1f}) : {old:+.3f} -> {inner[kit]:+.3f}")
    write_destins(destins)
    for passive_id, passive in passives.items():
        key = passive.get("lever")
        if not key or ("passif:" + passive_id) not in rates:
            continue
        deviation = rates["passif:" + passive_id] - rates["classe:" + passive["class"]]
        if abs(deviation) < 1.0:
            continue
        if key in INVERTED_LEVERS:
            deviation = -deviation
        old = passive["params"][key]
        gain = PASSIVE_GAIN * damp("passif:" + passive_id, deviation)
        passive["params"][key] = step_int(old, deviation, gain) if isinstance(old, int) else round(step(old, deviation, gain), 3)
        report.append(f"passif {passive_id} ({deviation:+.1f}) : {key} {old} -> {passive['params'][key]}")
    for synergy in synergies:
        key = synergy.get("lever")
        if key is None or any(skill.startswith("*") for skill in synergy["skills"]):
            continue
        a, b = synergy["skills"]
        # Une Synergie se compare aux duos de la même composition (une Synergie Guerrier-Mage aux duos Guerrier + Mage).
        base = rates["compo:" + "+".join(sorted([skills[a]["class"], skills[b]["class"]]))]
        deviation = rates.get("syn:" + synergy["id"], base) - base
        if abs(deviation) < 1.5:
            continue
        old = synergy["params"][key]
        gain = SYNERGY_GAIN * damp("syn:" + synergy["id"], deviation)
        if isinstance(old, int):
            synergy["params"][key] = step_int(old, deviation, gain)
        else:
            low, high = SYNERGY_LIMITS.get(key, (0.0, 10.0))
            synergy["params"][key] = round(min(high, max(low, step(old, deviation, gain))), 3)
        report.append(f"synergie {synergy['id']} ({deviation:+.1f}) : {key} {old} -> {synergy['params'][key]}")
    write_skills(skills)
    write_passives(passives)
    write_synergies(synergies)
    return report


def load_damping():
    state_path = os.path.join(OUT, "amortissement.json")
    if os.path.exists(state_path):
        with open(state_path, encoding="utf-8") as f:
            DAMPING.update(json.load(f))


def save_damping():
    os.makedirs(OUT, exist_ok=True)
    with open(os.path.join(OUT, "amortissement.json"), "w", encoding="utf-8") as f:
        json.dump(DAMPING, f)


def one_round(label, files):
    """Une passe de réglage à partir de fichiers CSV déjà simulés : mesure, puis correction des chiffres de data/."""
    rates = measure(files)
    spread = [v for k, v in rates.items() if k.startswith(("comp:", "passif:", "classe:"))]
    kits = [v for k, v in rates.items() if k.startswith("kit:")]
    print(f"\n== Réglage {label} : écart max à 50 % = {max(abs(v - 50) for v in spread):.1f} points"
          f" ; kits (par côté) de {min(kits):.1f} à {max(kits):.1f} %, {sum(1 for v in kits if 48 <= v <= 52)} sur {len(kits)} dans 48-52", flush=True)
    for line in tune(rates):
        print("  " + line, flush=True)
    save_damping()


def main():
    load_damping()
    if len(sys.argv) > 1 and sys.argv[1] == "regler":
        # Sur GitHub Actions : les combats ont été simulés par d'autres machines, on ne fait que régler.
        # python3 tools/regleur.py regler <étiquette> fichier1.csv [fichier2.csv ...]
        one_round(sys.argv[2], sys.argv[3:])
        return
    rounds = int(sys.argv[1]) if len(sys.argv) > 1 else 5
    count = int(sys.argv[2]) if len(sys.argv) > 2 else 12000
    for r in range(1, rounds + 1):
        one_round(str(r), simulate(r, count))


if __name__ == "__main__":
    main()
