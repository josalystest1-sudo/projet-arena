"""Analyse des combats du simulateur d'équilibrage (tools/equilibrage.gd).

Usage : python3 tools/equilibrage.py fichier1.csv [fichier2.csv ...]

Pour chaque élément du jeu (classe, compétence, passif, composition de duo, Synergie, kit complet, et avec le Destin
les modèles de nœuds pris), affiche son taux de victoire et marque ceux qui sortent de la fourchette du GDD (48 à 52 %).
Un élément n'est déclaré hors fourchette que si l'écart dépasse aussi le bruit de mesure.
"""
import csv
import math
import sys
from collections import defaultdict

LOW, HIGH = 48.0, 52.0


def read(paths):
    rows = []
    for path in paths:
        with open(path, encoding="utf-8") as f:
            rows.extend(csv.DictReader(f))
    return rows


def table(title, stats, min_games=200, show_all=True):
    print(f"\n{title}")
    flagged = 0
    for key, (wins, games) in sorted(stats.items(), key=lambda kv: -kv[1][0] / max(kv[1][1], 1)):
        if games < min_games:
            continue
        rate = 100.0 * wins / games
        margin = 196.0 * math.sqrt(max(rate / 100.0 * (1 - rate / 100.0), 1e-9) / games)
        out = (rate - margin > HIGH) or (rate + margin < LOW)
        flagged += out
        if show_all or out:
            mark = "  <-- hors fourchette" if out else ""
            print(f"  {key:<44} {rate:5.1f} % ± {margin:3.1f}  ({games}){mark}")
    return flagged


def main():
    rows = read(sys.argv[1:])
    combats = len(rows) // 2
    turns = [int(r["tours"]) for r in rows[::2]]
    ko = sum(1 for r in rows[::2] if r["fin"] == "ko")
    in_window = sum(1 for t in turns if 8 <= t <= 15)
    print(f"{combats} combats · {sum(turns) / combats:.1f} tours en moyenne · {100 * ko / combats:.0f} % finis par KO · {100 * in_window / combats:.0f} % entre les tours 8 et 15")

    groups = defaultdict(lambda: defaultdict(lambda: [0, 0]))
    for r in rows:
        won = int(r["gagne"])

        def add(group, key):
            entry = groups[group][key]
            entry[0] += won
            entry[1] += 1

        for side, prefix in (("joueur", "j_"), ("acolyte", "a_")):
            cls = r[side]
            add("Classes (dans le duo)", cls)
            add("Classes (en tant que " + side + ")", cls)
            for tier in ("basique", "moyenne", "forte"):
                add("Compétences", r[prefix + tier])
            add("Passifs", r[prefix + "passif"])
        add("Duos (joueur + acolyte)", r["joueur"] + " + " + r["acolyte"])
        add("Compositions", " + ".join(sorted([r["joueur"], r["acolyte"]])))
        for synergy in filter(None, r["synergies_possibles"].split("+")):
            add("Synergies possibles dans le duo", synergy)
        add("Kits du joueur (Destins)", " ".join([r["joueur"], r["j_basique"], r["j_moyenne"], r["j_forte"], r["j_passif"]]))
        add("Kits de l'acolyte (Destins)", " ".join([r["acolyte"], r["a_basique"], r["a_moyenne"], r["a_forte"], r["a_passif"]]))
        add("Affrontements", " + ".join(sorted([r["joueur"], r["acolyte"]])) + "  contre  " + " + ".join(sorted(r["adverse"].split("+"))))
        # Avec le Destin (tools/equilibrage.gd lancé avec un niveau) : les nœuds pris, par modèle et par type, et le
        # niveau (les deux duos jouent au même niveau : chaque ligne doit rester à 50 %).
        if r.get("niveau", "0") not in ("", "0"):
            add("Niveaux (les deux duos au même niveau)", f"niveau {int(r['niveau']):2d}")
            for side, column in (("joueur", "j_destin"), ("acolyte", "a_destin")):
                seen = set()
                for label in filter(None, r.get(column, "").split("+")):
                    if label in seen:
                        continue
                    seen.add(label)
                    add("Nœuds du Destin pris (" + side + ")", label)
                    add("Types de nœud pris (" + side + ")", label.split(":")[0])

    flagged = 0
    for group in ["Classes (dans le duo)", "Classes (en tant que joueur)", "Classes (en tant que acolyte)", "Compositions",
                  "Duos (joueur + acolyte)", "Compétences", "Passifs", "Synergies possibles dans le duo", "Affrontements"]:
        flagged += table(group, groups[group])
    for group in ["Niveaux (les deux duos au même niveau)", "Types de nœud pris (joueur)", "Types de nœud pris (acolyte)",
                  "Nœuds du Destin pris (joueur)", "Nœuds du Destin pris (acolyte)"]:
        if group in groups:
            flagged += table(group, groups[group])
    flagged_kits = 0
    for group in ("Kits du joueur (Destins)", "Kits de l'acolyte (Destins)"):
        kits = groups[group]
        flagged_kits += table(group + " hors fourchette", kits, min_games=150, show_all=False)
        rates = [100.0 * w / g for w, g in kits.values() if g >= 150]
        if rates:
            inside = sum(1 for v in rates if LOW <= v <= HIGH)
            print(f"  {len(rates)} kits mesurés : de {min(rates):.1f} % à {max(rates):.1f} %, {inside} dans 48-52")
    print(f"\nHors fourchette (hors kits) : {flagged}   kits hors fourchette : {flagged_kits}")


if __name__ == "__main__":
    main()
