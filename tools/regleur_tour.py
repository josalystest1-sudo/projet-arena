"""Régleur de la difficulté de la Tour : chaque étage vers un taux de chute qui monte doucement.

Usage : python3 tools/regleur_tour.py <passes> <montées par passe>
(Godot doit être lancé par la commande indiquée dans la variable GODOT, par défaut ~/godot/godot.)

À chaque passe, tools/simulate_tour.gd fait monter des duos tirés au hasard (4 processus en parallèle) et écrit une
ligne par étage joué. Pour chaque étage, on compare la part des duos qui y tombent (parmi ceux qui l'atteignent) à
la cible, puis on corrige ses multiplicateurs de PV et de puissance (data/tower.json), d'au plus 8 % par passe.
La force de chaque monstre se règle à part (tools/menace.py).
"""
import csv
import json
import os
import subprocess
import sys
from collections import defaultdict

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
TOWER = os.path.join(ROOT, "data", "tower.json")
GODOT = os.environ.get("GODOT", os.path.expanduser("~/godot/godot"))
OUT = os.environ.get("TOUR_DIR", "/tmp/regleur_tour")
# Part des duos qui tombent à chaque étage, parmi ceux qui l'atteignent (les étages 5 et 10 sont des Gardiens).
TARGET = [0.02, 0.04, 0.06, 0.10, 0.18, 0.22, 0.27, 0.32, 0.38, 0.60]
STEP = 0.08


def simulate(count, seed):
    os.makedirs(OUT, exist_ok=True)
    procs, files = [], []
    for i in range(4):
        path = os.path.join(OUT, f"etages_{seed}_{i}.csv")
        files.append(path)
        procs.append(subprocess.Popen([GODOT, "--headless", "--path", ROOT, "--script", "res://tools/simulate_tour.gd", "--",
                                       str(count // 4), str(seed * 10 + i), path],
                                      stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL))
    for proc in procs:
        proc.wait()
    rows = []
    for path in files:
        with open(path, encoding="utf-8") as f:
            rows += list(csv.DictReader(f))
    return rows


def read_rows(files):
    rows = []
    for path in files:
        with open(path, encoding="utf-8") as f:
            rows += list(csv.DictReader(f))
    return rows


def main():
    if len(sys.argv) > 1 and sys.argv[1] == "regler":
        # Sur GitHub Actions : les montées ont été simulées par d'autres machines, on ne fait que régler.
        # python3 tools/regleur_tour.py regler <étiquette> fichier1.csv [fichier2.csv ...]
        one_pass(sys.argv[2], read_rows(sys.argv[3:]))
        return
    passes = int(sys.argv[1]) if len(sys.argv) > 1 else 4
    count = int(sys.argv[2]) if len(sys.argv) > 2 else 2000
    for n in range(1, passes + 1):
        one_pass(str(n), simulate(count, 100 + n))


def one_pass(label, rows):
    if True:
        count = sum(1 for r in rows if int(r["etage"]) == 1)
        played, lost = defaultdict(int), defaultdict(int)
        for r in rows:
            played[int(r["etage"])] += 1
            lost[int(r["etage"])] += 1 - int(r["gagne"])
        tower = json.load(open(TOWER, encoding="utf-8"))
        summit = played[len(tower["floors"])] - lost[len(tower["floors"])]
        print(f"== Passe {label} : {count} montées, sommet {100 * summit / max(count, 1):.1f} %", flush=True)
        for i, floor in enumerate(tower["floors"]):
            number = i + 1
            rate = lost[number] / max(played[number], 1)
            gap = TARGET[i] - rate
            # Plus de chutes que la cible : l'étage s'adoucit (et inversement), proportionnellement à l'écart.
            factor = 1.0 + max(-STEP, min(STEP, 0.6 * gap))
            floor["hp"] = round(floor["hp"] * factor, 3)
            floor["power"] = round(floor["power"] * factor, 3)
            print(f"  étage {number:2d} : {played[number]:5d} duos, chute {100 * rate:4.1f} % (cible {100 * TARGET[i]:.0f} %)"
                  f" -> PV x{floor['hp']}, puissance x{floor['power']}", flush=True)
        with open(TOWER, "w", encoding="utf-8") as f:
            f.write(json.dumps(tower, ensure_ascii=False, indent=2) + "\n")


if __name__ == "__main__":
    main()
