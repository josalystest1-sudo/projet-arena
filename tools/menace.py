"""Mesure la menace réelle de chaque monstre de la Tour, et règle leur puissance si on le demande.

Usage : python3 tools/menace.py etages_1.csv [etages_2.csv ...] [--ecrire]
(les fichiers viennent de tools/simulate_tour.gd, avec son troisième argument)

Sur les étages ordinaires, les PV perdus par le duo sont rapportés à la moyenne de leur étage, puis multipliés par le
budget de l'étage : c'est la « menace effective » du groupe, en unités de budget. Une régression (moindres carrés,
sans constante) répartit cette menace entre les monstres du groupe. Avec --ecrire, la menace de chaque monstre (son
coût dans le budget de l'étage) va à mi-chemin de sa mesure (0,5 au moins) : deux petits monstres agissent deux fois par
tour, un soigneur frappe peu, un Meute frappe plus fort en groupe ; leurs stats restent celles de leur rang. Les
Gardiens se règlent entre eux par leur puissance : chacun vers la moyenne des PV que le duo perd contre eux.
"""
import csv
import json
import os
import sys
from collections import defaultdict

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
BESTIARY = os.path.join(ROOT, "data", "v1", "bestiaire.json")
TOWER = os.path.join(ROOT, "data", "v1", "tower.json")


def solve(matrix, vector):
    """Résout matrix · x = vector (élimination de Gauss avec pivot partiel)."""
    n = len(vector)
    a = [row[:] + [vector[i]] for i, row in enumerate(matrix)]
    for col in range(n):
        pivot = max(range(col, n), key=lambda r: abs(a[r][col]))
        a[col], a[pivot] = a[pivot], a[col]
        if abs(a[col][col]) < 1e-12:
            continue
        for r in range(n):
            if r != col:
                factor = a[r][col] / a[col][col]
                for c in range(col, n + 1):
                    a[r][c] -= factor * a[col][c]
    return [a[i][n] / a[i][i] if abs(a[i][i]) > 1e-12 else 0.0 for i in range(n)]


def write_bestiary(bestiary):
    """Réécrit le bestiaire en gardant sa forme lisible : une ligne par famille, rang, passif, compétence, monstre."""
    sections = []
    for section, values in bestiary.items():
        lines = [f'    {json.dumps(k, ensure_ascii=False)}: {json.dumps(v, ensure_ascii=False)}' for k, v in values.items()]
        sections.append(f'  {json.dumps(section)}: {{\n' + ",\n".join(lines) + "\n  }")
    with open(BESTIARY, "w", encoding="utf-8") as f:
        f.write("{\n" + ",\n".join(sections) + "\n}\n")


def main():
    files = [p for p in sys.argv[1:] if not p.startswith("--")]
    write = "--ecrire" in sys.argv
    tower = json.load(open(TOWER, encoding="utf-8"))
    budgets = {i + 1: f.get("budget") for i, f in enumerate(tower["floors"])}
    rows = []
    for path in files:
        rows += list(csv.DictReader(open(path, encoding="utf-8")))
    normal = [r for r in rows if not r["famille"].startswith("gardien")]
    by_floor = defaultdict(list)
    for r in normal:
        by_floor[int(r["etage"])].append(float(r["pv_perdus"]))
    floor_mean = {k: sum(v) / len(v) for k, v in by_floor.items()}
    monsters = sorted({m for r in normal for m in r["monstres"].split("+")})
    index = {m: i for i, m in enumerate(monsters)}
    n = len(monsters)
    ata = [[0.0] * n for _ in range(n)]
    aty = [0.0] * n
    for r in normal:
        floor = int(r["etage"])
        y = float(r["pv_perdus"]) / max(floor_mean[floor], 1e-6) * float(budgets[floor])
        counts = defaultdict(int)
        for m in r["monstres"].split("+"):
            counts[index[m]] += 1
        for i, ci in counts.items():
            aty[i] += ci * y
            for j, cj in counts.items():
                ata[i][j] += ci * cj
    measured = dict(zip(monsters, solve(ata, aty)))
    bestiary = json.load(open(BESTIARY, encoding="utf-8"))
    print(f"{len(normal)} étages ordinaires mesurés")
    print("monstre            menace  mesurée")
    for m in monsters:
        print(f"  {m:16} {float(bestiary['monsters'][m]['menace']):6.2f}  {measured[m]:6.2f}")
    families = defaultdict(lambda: [0, 0, 0.0])
    for r in rows:
        families[r["famille"]][0] += 1
        families[r["famille"]][1] += 1 - int(r["gagne"])
        families[r["famille"]][2] += float(r["pv_perdus"])
    print("famille                étages  chute  PV perdus")
    for f, (g, lost, hp) in sorted(families.items()):
        print(f"  {f:20} {g:6d}  {100 * lost / g:4.1f} %  {100 * hp / g:4.1f} %")
    if write:
        for m in monsters:
            monster = bestiary["monsters"][m]
            old_menace = float(monster["menace"])
            monster["menace"] = round(max(0.5, old_menace + 0.5 * (measured[m] - old_menace)), 2)
            print(f"  {m} : menace {old_menace} -> {monster['menace']}")
        guardians = {f.split(" ")[1]: hp / g for f, (g, lost, hp) in families.items() if f.startswith("gardien")}
        if guardians:
            target = sum(guardians.values()) / len(guardians)
            for m, lost in guardians.items():
                monster = bestiary["monsters"][m]
                factor = min(1.2, max(0.8, (target / max(lost, 0.01)) ** 0.5))
                old = int(monster["stats"]["power"])
                monster["stats"]["power"] = max(20, int(round(old * factor)))
                print(f"  {m} (Gardien) : puissance {old} -> {monster['stats']['power']}")
        write_bestiary(bestiary)
        print("puissances mises à jour dans data/bestiaire.json")


if __name__ == "__main__":
    main()
