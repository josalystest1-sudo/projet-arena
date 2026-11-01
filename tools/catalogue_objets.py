# -*- coding: utf-8 -*-
"""Le catalogue des objets, en français, pour Gautier : docs/OBJETS.md, généré depuis data/items.json (les emplacements,
les bases et leurs lignes possibles, les paliers de niveau, les raretés et leurs fourchettes), data/donjons.json,
data/arene.json, data/comptoir.json et data/tour.json (d'où tombe quoi, lié ou échangeable).

Usage : python tools/catalogue_objets.py   (écrit docs/OBJETS.md)
"""
import io
import json
import os

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


def lire(nom):
    return json.load(io.open(os.path.join(ROOT, "data", nom), encoding="utf-8"))


def f(x):
    t = "%.1f" % x
    if t.endswith(".0"):
        t = t[:-2]
    return t.replace(".", ",")


def echelle_niveau(niveau, objets):
    plancher = objets["niveau"]["plancher"]
    plein = objets["niveau"]["plein"]
    return plancher + (1 - plancher) * (min(max(1, niveau), plein) - 1) / (plein - 1)


def fourchette(stat, rarete, niveau, objets):
    a, b = objets["lignes"][stat]["fourchette"]
    e = objets["raretes"][rarete]["echelle"] * echelle_niveau(niveau, objets)
    return round(a * e, 1), round(b * e, 1)


def main():
    objets = lire("items.json")
    donjons = lire("donjons.json")
    arene = lire("arene.json")
    comptoir = lire("comptoir.json")
    tour = lire("tour.json")
    L = []
    L.append("# Les objets du jeu")
    L.append("")
    L.append("Généré par `tools/catalogue_objets.py` depuis `data/items.json` (et les données du butin) : ne pas modifier à la main, "
             "modifier les données puis relancer l'outil. Les noms sont de fantasy classique en attendant l'univers (décision de Gautier du 29 octobre).")
    L.append("")
    L.append("## Comment un objet est fait")
    L.append("")
    L.append("Un objet, c'est **une base** (ce qu'il est : une Épée, une Robe…), **un palier de niveau** (son matériau), **une rareté** et "
             "**ses lignes** : des bonus en %, tirés à la trouvaille dans la réserve de sa base. Il n'a de valeur que pour un Destin : "
             "ses lignes s'ajoutent aux éclats de la roue. Huit emplacements, un objet porté par emplacement.")
    L.append("")
    L.append("- **Les raretés** : " + " ; ".join("%s (%d ligne%s, fourchettes × %s)" % (r["nom"]["m"], r["lignes"], "s" if r["lignes"] > 1 else "", f(r["echelle"]))
                                             for r in objets["raretes"].values()) + ".")
    L.append("- **Le niveau** : les fourchettes valent %s %% de leur pleine valeur au niveau 1, 100 %% au niveau %d et au-delà." % (f(objets["niveau"]["plancher"] * 100), objets["niveau"]["plein"]))
    L.append("- **La qualité** (0 à 100 %) dit où les chiffres sont tombés dans leurs fourchettes.")
    L.append("- **Lié ou échangeable** : échangeable seulement s'il vient d'un premier passage (Tour) ou d'un boss de donjon ; lié dès qu'on l'équipe, et pour toujours.")
    L.append("- **La reforge** : une ligne retirée contre %d Éclats, +%d %% par reforge déjà faite. **Le recyclage** rend %s Éclats." % (
        objets["reforge"]["cout"], round(objets["reforge"]["pente"] * 100), " / ".join("%d (%s)" % (v, objets["raretes"][k]["nom"]["m"]) for k, v in objets["recyclage"].items())))
    a = objets["amelioration"]
    L.append("- **L'amélioration +1 à +%d** (décision de Gautier du 1er novembre) : payée en Or, et cet Or est détruit (réussite ou échec). "
             "Chaque cran ajoute %s %% aux lignes de l'objet (+%s %% à +%d). Le cran suivant coûte %s Or × le rang de la rareté (%s) × l'échelle du "
             "niveau, puis × %s par cran déjà pris. Les chances de réussite, cran par cran : %s. **Un échec fait perdre un cran** (de +3, on retombe à +2). "
             "La reforge et l'équipement gardent le cran ; le nom le porte (« Épée d'acier épique +4 »). C'est le seul hasard du jeu hors combat avec la "
             "création." % (a["max"], f(a["bonus_par_cran"] * 100), f(a["bonus_par_cran"] * 100 * a["max"]), a["max"], f(a["cout"]),
                            " / ".join("%d %s" % (r["rang"], r["nom"]["m"]) for r in objets["raretes"].values()), f(a["pente"]),
                            ", ".join("%s %%" % f(c * 100) for c in a["reussite"])))
    L.append("")
    L.append("Le coût de chaque cran pour un objet du niveau %d (en Or) :" % objets["niveau"]["plein"])
    L.append("")
    L.append("| Cran | " + " | ".join(r["nom"]["m"] for r in objets["raretes"].values()) + " |")
    L.append("| --- |" + " --- |" * len(objets["raretes"]))
    for c in range(a["max"]):
        L.append("| +%d | " % (c + 1) + " | ".join(str(max(1, round(a["cout"] * r["rang"] * a["pente"] ** c))) for r in objets["raretes"].values()) + " |")
    L.append("| total | " + " | ".join(str(sum(max(1, round(a["cout"] * r["rang"] * a["pente"] ** c)) for c in range(a["max"]))) for r in objets["raretes"].values()) + " |")
    L.append("")
    L.append("## Les huit lignes")
    L.append("")
    L.append("| Ligne | Ce qu'elle fait | Fourchette (commun, niveau 30) | Plafond sur le total porté |")
    L.append("| --- | --- | --- | --- |")
    for sid, l in objets["lignes"].items():
        L.append("| %s | %s | %s – %s %% | %s %% |" % (l["nom"], l["texte"].replace("{v}", "X"), f(l["fourchette"][0]), f(l["fourchette"][1]), f(l["plafond"])))
    L.append("")
    L.append("## Les paliers de niveau (le matériau du nom)")
    L.append("")
    L.append("| Dès le niveau | Suffixe | Exemple |")
    L.append("| --- | --- | --- |")
    for p in objets["paliers"]:
        L.append("| %d | %s | Épée %s rare |" % (p["niveau_min"], p["suffixe"], p["suffixe"]))
    L.append("")
    L.append("## Les quarante-huit bases, par emplacement")
    L.append("")
    L.append("Chaque base a une réserve de quatre lignes possibles ; un objet tire ses lignes dedans (autant que sa rareté en donne, toutes différentes). "
             "Chaque ligne est dans vingt-quatre réserves : aucune n'est plus rare qu'une autre.")
    L.append("")
    for eid, e in objets["emplacements"].items():
        L.append("### %s" % e["nom"])
        L.append("")
        L.append("| Base | Lignes possibles | Description |")
        L.append("| --- | --- | --- |")
        for bid, b in objets["bases"].items():
            if b["emplacement"] != eid:
                continue
            L.append("| **%s** | %s | %s |" % (b["nom"], ", ".join(objets["lignes"][s]["nom"] for s in b["lignes"]), b.get("description", "")))
        L.append("")
    L.append("## Les traits légendaires")
    L.append("")
    L.append("Un objet légendaire porte un trait, tiré à la trouvaille parmi ceux-ci : un passif de combat de son porteur. Un même trait porté deux fois ne compte qu'une fois.")
    L.append("")
    L.append("| Trait | Ce qu'il fait |")
    L.append("| --- | --- |")
    for tid, t in objets.get("traits", {}).items():
        L.append("| **%s** | %s |" % (t["nom"], t["texte"].replace("{v}", f(t["valeur"] * 100))))
    L.append("")
    L.append("## Les fourchettes par rareté et par niveau")
    L.append("")
    L.append("Pour chaque ligne, les bornes d'un objet (en %) selon sa rareté, aux niveaux 1, 10, 20 et 30 (au-delà de 30, comme à 30).")
    L.append("")
    L.append("| Ligne | Rareté | Niveau 1 | Niveau 10 | Niveau 20 | Niveau 30 |")
    L.append("| --- | --- | --- | --- | --- | --- |")
    for sid, l in objets["lignes"].items():
        for rid, r in objets["raretes"].items():
            cases = []
            for nv in (1, 10, 20, 30):
                a, b = fourchette(sid, rid, nv, objets)
                cases.append("%s – %s" % (f(a), f(b)))
            L.append("| %s | %s | %s |" % (l["nom"], r["nom"]["m"], " | ".join(cases)))
    L.append("")
    L.append("## D'où tombe quoi")
    L.append("")
    L.append("| Source | Rareté | Niveau de l'objet | Lié ou échangeable |")
    L.append("| --- | --- | --- | --- |")
    L.append("| Un étage de la Tour, franchi pour la première fois | %s, %d fois sur 10 (sinon rien) | celui de l'étage | échangeable |" % (_poids(objets["butin"]["etage"], objets), round(objets["butin"]["chance_etage"] * 10)))
    L.append("| Un étage de la Tour, rejoué | %s, une fois sur %s | celui de l'étage | lié |" % (_poids(objets["butin"]["etage"], objets), f(1 / objets["butin"]["rejoue"])))
    L.append("| Un Gardien de la Tour (tous les %d étages), la première fois | %s | celui de l'étage | échangeable |" % (
        tour["gardien_tous_les"], _poids(objets["butin"]["gardien"], objets)))
    L.append("| Un grand Gardien de la Tour (tous les %d étages), la première fois | %s | celui de l'étage | échangeable |" % (
        tour["grand_gardien_tous_les"], _poids(objets["butin"]["grand_gardien"], objets)))
    L.append("| Un Gardien ou un grand Gardien rejoué | les mêmes raretés, toujours un objet | celui de l'étage | lié |")
    L.append("| L'élite d'un donjon | %s (+ %d fragment, %d Éclats) | celui du donjon | lié |" % (
        objets["raretes"][donjons["recompenses"]["elite"]["rarete"]]["nom"]["m"], donjons["recompenses"]["elite"]["fragments"], donjons["recompenses"]["elite"]["eclats"]))
    L.append("| Le boss d'un donjon | %s (+ %d Éclats) | celui du donjon | échangeable |" % (
        objets["raretes"][donjons["recompenses"]["boss"]["rarete"]]["nom"]["m"], donjons["recompenses"]["boss"]["eclats"]))
    L.append("| Le coffre de la semaine à l'Arène | %s | le tien | lié |" % " ; ".join("%s dès %d victoires" % (objets["raretes"][r]["nom"]["m"], n) for r, n in arene["coffre"].items()))
    L.append("| L'étal du Comptoir (contre des Éclats) | %s | le tien | lié |" % " ; ".join("%s à %d Éclats" % (objets["raretes"][r]["nom"]["m"], comptoir["etal"]["prix"][r]) for r in comptoir["etal"]["raretes"]))
    L.append("")
    L.append("## Les prix (Comptoir et Marché)")
    L.append("")
    L.append("Le Comptoir achète un objet échangeable à son **prix plancher** : %s Or selon la rareté, × le niveau (pente %s), × la qualité (de %s à 1). "
             "Au Marché, le vendeur fixe son prix entre le plancher et le plancher × %s." % (
                 " / ".join("%d (%s)" % (v, objets["raretes"][k]["nom"]["m"]) for k, v in comptoir["plancher"].items()), f(comptoir["niveau_pente"]), f(comptoir["qualite_base"]),
                 " / ".join("%d (%s)" % (v, objets["raretes"][k]["nom"]["m"]) for k, v in comptoir["marche"].items())))
    L.append("")
    chemin = os.path.join(ROOT, "docs", "OBJETS.md")
    io.open(chemin, "w", encoding="utf-8", newline="\n").write("\n".join(L) + "\n")
    print("écrit : docs/OBJETS.md (%d bases)" % len(objets["bases"]))


def _poids(poids, objets):
    total = sum(poids.values())
    return ", ".join("%s %d %%" % (objets["raretes"][r]["nom"]["m"], round(100 * v / total)) for r, v in poids.items())


if __name__ == "__main__":
    import sys
    sys.stdout.reconfigure(encoding="utf-8")
    main()
