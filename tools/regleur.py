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
}


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


def measure(files):
    import csv
    rates = defaultdict(lambda: [0, 0])
    for path in files:
        with open(path, encoding="utf-8") as f:
            for row in csv.DictReader(f):
                won = int(row["gagne"])
                keys = []
                for side, prefix in (("joueur", "j_"), ("acolyte", "a_")):
                    cls = row[side]
                    keys += ["classe:" + cls, "passif:" + row[prefix + "passif"]]
                    keys += ["comp:" + row[prefix + t] for t in ("basique", "moyenne", "forte")]
                keys += ["syn:" + s for s in filter(None, row["synergies_possibles"].split("+"))]
                keys.append("compo:" + "+".join(sorted([row["joueur"], row["acolyte"]])))
                for key in keys:
                    rates[key][0] += won
                    rates[key][1] += 1
    return {k: 100.0 * w / g for k, (w, g) in rates.items() if g > 0}


def step(value, deviation, gain=GAIN):
    factor = 1.0 - gain * deviation / 100.0
    factor = min(1.0 + MAX_STEP, max(1.0 - MAX_STEP, factor))
    return value * factor


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
                    effect[key] = max(1, int(round(step(old, deviation))))
                    report.append(f"{skill_id} ({deviation:+.1f}) : {key} {old} -> {effect[key]}")
                    break
    for passive_id, key in PASSIVE_LEVERS.items():
        passive = passives[passive_id]
        deviation = rates["passif:" + passive_id] - rates["classe:" + passive["class"]]
        if abs(deviation) < 1.0:
            continue
        old = passive["params"][key]
        new = step(old, deviation, PASSIVE_GAIN)
        passive["params"][key] = int(round(new)) if isinstance(old, int) else round(new, 3)
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
        new = step(old, deviation, SYNERGY_GAIN)
        synergy["params"][key] = int(round(new)) if isinstance(old, int) else round(new, 3)
        report.append(f"synergie {synergy['id']} ({deviation:+.1f}) : {key} {old} -> {synergy['params'][key]}")
    write_skills(skills)
    write_passives(passives)
    write_synergies(synergies)
    return report


def main():
    rounds = int(sys.argv[1]) if len(sys.argv) > 1 else 5
    count = int(sys.argv[2]) if len(sys.argv) > 2 else 12000
    for r in range(1, rounds + 1):
        rates = measure(simulate(r, count))
        spread = [v for k, v in rates.items() if k.startswith(("comp:", "passif:", "classe:"))]
        print(f"\n== Réglage {r} : écart max à 50 % = {max(abs(v - 50) for v in spread):.1f} points")
        for line in tune(rates):
            print("  " + line)
        sys.stdout.flush()


if __name__ == "__main__":
    main()
