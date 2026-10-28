"""Régleur des valeurs des nœuds du Destin (étape 4).

Usage : python3 tools/regleur_destin.py <passes> <combats par passe>            (simule en local, GODOT, 4 processus)
        python3 tools/regleur_destin.py regler <étiquette> fichier1.csv [...]    (règle seulement : GitHub Actions)
        python3 tools/regleur_destin.py mesurer fichier1.csv [...]               (mesure sans rien écrire)

Les combats viennent de tools/equilibrage.gd lancé avec le niveau « alea » : les deux duos au même niveau, les points
de Destin placés au hasard. Pour chaque modèle de nœud (« stat:pv », « evolution:power », « pivot:solide »,
« cle:zone »…), on mesure le taux de victoire des personnages qui l'ont pris, côté joueur et côté acolyte séparément.
Un modèle au-dessus de 50 % est plus fort que sa valeur ne le dit : côté joueur, sa valeur monte (et inversement) ;
côté acolyte, c'est son facteur du mini-Destin (« mini_values » : un même modèle n'a pas la même force chez
l'acolyte, de la classe complémentaire, dont les points vont sur un petit arbre). D'au plus 15 % par passe, avec
amortissement. Comme tous les arbres sont ramenés à la même valeur totale, un nœud qui vaut
plus laisse moins de place aux autres bonus de son arbre : c'est ainsi que la valeur rejoint la force réelle.
Les valeurs sont ensuite remises à l'échelle pour que la valeur nominale d'un arbre (22 Stats, 14 Évolutions,
7 Pivots, 2 Clés) ne bouge pas, puis la cible « meilleure valeur avec 30 points » est recalibrée sur des arbres neufs
(tools/calibrer_destin.gd, si Godot est là).
"""
import csv
import json
import os
import re
import subprocess
import sys
from collections import defaultdict

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
NODES = os.path.join(ROOT, "data", "destin_nodes.json")
GODOT = os.environ.get("GODOT", os.path.expanduser("~/godot/godot"))
OUT = os.environ.get("DESTIN_DIR", "/tmp/regleur_destin")
# Un nœud n'est qu'un des 30 points d'un personnage : son effet sur le taux de victoire est dilué, d'où un gain fort.
GAIN = 3.0
MAX_STEP = 0.15
MIN_GAMES = 300
MIN_VALUE = 0.3
MIN_FACTOR, MAX_FACTOR = 0.4, 2.5
# Un nœud de Stat est petit ou grand (une ou deux unités, 65 / 35 %) : sa valeur nominale moyenne.
STAT_UNITS = 1.35
DAMPING = {}


def load_nodes():
    with open(NODES, encoding="utf-8") as f:
        return json.load(f)


def save_nodes(config):
    with open(NODES, "w", encoding="utf-8") as f:
        f.write(json.dumps(config, ensure_ascii=False, indent=2) + "\n")


def templates(config):
    """Chaque modèle, avec son étiquette (celle de Destin.template_of) et le dictionnaire qui porte sa valeur."""
    result = []
    for template in config.get("stats", []):
        result.append(("stat:" + template["id"], "stat", template))
    for kind, template in config.get("evolutions", {}).items():
        result.append(("evolution:" + kind, "evolution", template))
    for role, group in config.get("pivots", {}).items():
        for template in group:
            result.append(("pivot:" + template["id"], "pivot", template))
    for template in config.get("cles", []):
        result.append(("cle:" + template["id"], "cle", template))
    return result


def nominal_value(config):
    """La valeur d'un arbre « moyen » : les nœuds de chaque type à leur valeur moyenne."""
    by_type = defaultdict(list)
    for _, kind, template in templates(config):
        by_type[kind].append(float(template["value"]))
    total = 0.0
    for kind, values in by_type.items():
        count = int(config["counts"].get(kind, 0))
        mean = sum(values) / len(values)
        total += count * mean * (STAT_UNITS if kind == "stat" else 1.0)
    return total


def measure(files):
    """Taux par modèle, côté joueur (« j ») et côté acolyte (« a »), et par niveau."""
    rates = {"j": defaultdict(lambda: [0, 0]), "a": defaultdict(lambda: [0, 0])}
    levels = defaultdict(lambda: [0, 0])
    for path in files:
        with open(path, encoding="utf-8") as f:
            for row in csv.DictReader(f):
                if row.get("niveau", "0") in ("", "0"):
                    continue
                won = int(row["gagne"])
                levels[int(row["niveau"])][0] += won
                levels[int(row["niveau"])][1] += 1
                for side, column in (("j", "j_destin"), ("a", "a_destin")):
                    for label in set(filter(None, row.get(column, "").split("+"))):
                        rates[side][label][0] += won
                        rates[side][label][1] += 1
    return rates, levels


def damp(key, deviation):
    state = DAMPING.get(key)
    mult = 1.0
    if state is not None:
        mult = state["mult"] * 0.5 if state["dev"] * deviation < 0 else min(1.0, state["mult"] * 1.25)
    DAMPING[key] = {"dev": deviation, "mult": mult}
    return mult


def tune(config, rates):
    report = []
    before = nominal_value(config)
    minis = config.setdefault("mini_values", {})
    for label, kind, template in templates(config):
        # Côté joueur : la valeur du modèle.
        wins, games = rates["j"].get(label, (0, 0))
        if games < MIN_GAMES:
            report.append(f"{label:<22} joueur : pas assez de parties ({games})")
        else:
            rate = 100.0 * wins / games
            deviation = rate - 50.0
            if abs(deviation) >= 0.5:
                # Plus fort que sa valeur : la valeur monte (le contraire du régleur des compétences, qui baisse leur chiffre).
                factor = 1.0 + GAIN * damp("j:" + label, deviation) * deviation / 100.0
                factor = min(1.0 + MAX_STEP, max(1.0 - MAX_STEP, factor))
                old = float(template["value"])
                template["value"] = round(max(MIN_VALUE, old * factor), 2)
                report.append(f"{label:<22} joueur {rate:5.1f} % ({games}) : valeur {old} -> {template['value']}")
        # Côté acolyte : le facteur du mini-Destin (les Clés n'y existent pas).
        wins, games = rates["a"].get(label, (0, 0))
        if kind == "cle" or games < MIN_GAMES:
            continue
        rate = 100.0 * wins / games
        deviation = rate - 50.0
        if abs(deviation) < 0.5:
            continue
        factor = 1.0 + GAIN * damp("a:" + label, deviation) * deviation / 100.0
        factor = min(1.0 + MAX_STEP, max(1.0 - MAX_STEP, factor))
        old_factor = float(minis.get(label, 1.0))
        new_factor = round(min(MAX_FACTOR, max(MIN_FACTOR, old_factor * factor)), 3)
        if new_factor == 1.0:
            minis.pop(label, None)
        else:
            minis[label] = new_factor
        report.append(f"{label:<22} acolyte {rate:5.1f} % ({games}) : facteur du mini-Destin {old_factor} -> {new_factor}")
    # Remise à l'échelle : la valeur nominale d'un arbre ne bouge pas, pour que total_value reste atteignable.
    after = nominal_value(config)
    scale = before / after if after > 0 else 1.0
    if abs(scale - 1.0) > 1e-6:
        for _, _, template in templates(config):
            template["value"] = round(max(MIN_VALUE, float(template["value"]) * scale), 2)
        report.append(f"remise à l'échelle x{scale:.3f} (valeur nominale d'un arbre : {before:.1f})")
    return report


def calibrate(config):
    """Recalibre « best_value » sur la médiane de la meilleure valeur d'arbres neufs (Godot requis)."""
    godot = GODOT if os.path.exists(GODOT) else None
    if godot is None:
        return "calibrage sauté : Godot introuvable (" + GODOT + ") ; lancer tools/calibrer_destin.gd à la main"
    out = subprocess.run([godot, "--headless", "--path", ROOT, "--script", "res://tools/calibrer_destin.gd", "--", "120"],
                         capture_output=True, text=True, timeout=600).stdout
    found = re.search(r"best_median=([\d.]+) total_median=([\d.]+)", out)
    if not found:
        return "calibrage impossible : " + out.strip()[-200:]
    old = float(config["best_value"])
    config["best_value"] = round(float(found.group(1)), 1)
    return f"best_value {old} -> {config['best_value']} (médiane sur 120 arbres neufs ; valeur totale médiane {float(found.group(2)):.1f})"


def load_damping():
    path = os.path.join(OUT, "amortissement_destin.json")
    if os.path.exists(path):
        with open(path, encoding="utf-8") as f:
            DAMPING.update(json.load(f))


def save_damping():
    os.makedirs(OUT, exist_ok=True)
    with open(os.path.join(OUT, "amortissement_destin.json"), "w", encoding="utf-8") as f:
        json.dump(DAMPING, f)


def show(rates, levels):
    print("  niveau : " + ", ".join(f"{level} {100.0 * w / g:.1f} %" for level, (w, g) in sorted(levels.items()) if g))
    for side, name in (("j", "joueur"), ("a", "acolyte")):
        print(f"  --- {name}")
        for label, (wins, games) in sorted(rates[side].items(), key=lambda kv: -kv[1][0] / max(kv[1][1], 1)):
            print(f"  {label:<22} {100.0 * wins / games:5.1f} %  ({games})")


def one_pass(label, files):
    rates, levels = measure(files)
    config = load_nodes()
    measured = [100.0 * w / g for side in ("j", "a") for w, g in rates[side].values() if g >= MIN_GAMES]
    combats = sum(g for _, g in levels.values()) // 2
    if measured:
        print(f"== Réglage du Destin {label} : {combats} combats, {len(measured)} modèles mesurés (les deux côtés), de {min(measured):.1f} à {max(measured):.1f} %", flush=True)
    else:
        print(f"== Réglage du Destin {label} : rien à mesurer", flush=True)
    show(rates, levels)
    for line in tune(config, rates):
        print("  " + line, flush=True)
    save_nodes(config)
    print("  " + calibrate(config), flush=True)
    save_nodes(config)
    save_damping()


def simulate(round_index, count):
    os.makedirs(OUT, exist_ok=True)
    procs, files = [], []
    for k in range(4):
        path = os.path.join(OUT, f"d{round_index}_{k}.csv")
        files.append(path)
        procs.append(subprocess.Popen([GODOT, "--headless", "--path", ROOT, "--script", "res://tools/equilibrage.gd", "--",
                                       str(max(1, count // 4)), str(7000 * round_index + k + 1), path, "alea"],
                                      stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL))
    for proc in procs:
        proc.wait()
    return files


def main():
    load_damping()
    if len(sys.argv) > 1 and sys.argv[1] == "regler":
        one_pass(sys.argv[2], sys.argv[3:])
        return
    if len(sys.argv) > 1 and sys.argv[1] == "mesurer":
        rates, levels = measure(sys.argv[2:])
        show(rates, levels)
        return
    passes = int(sys.argv[1]) if len(sys.argv) > 1 else 4
    count = int(sys.argv[2]) if len(sys.argv) > 2 else 8000
    for r in range(1, passes + 1):
        one_pass(str(r), simulate(r, count))


if __name__ == "__main__":
    main()
