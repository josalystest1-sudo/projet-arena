# -*- coding: utf-8 -*-
"""La simulation de l'économie (docs/GDD_V2.md, § 10.2 ; engine/economie.gd) : des joueurs honnêtes et une ferme de bots
pendant des semaines, pour mesurer l'Or qui entre (le Comptoir), qui sort (la taxe), ce qui circule, et ce qu'un
revendeur d'Or peut livrer à un client. Écrit docs/ECONOMIE.md (les règles, puis les chiffres). Modèle simple, en Python,
qui relit les données du jeu (prix plancher, raretés du butin par étage, fourchettes du Marché, taxe, limites) ; les
combats ne sont pas joués : on suppose qu'un joueur franchit ses étages au rythme de la Tour à murs (1,7 étage par niveau).

Usage : python tools/economie.py [--joueurs 1000] [--semaines 12] [--bots 50] [--graine 1]
"""
import argparse
import io
import json
import math
import os
import random

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ETAGES_PAR_NIVEAU = 1.7


def lire(nom):
    return json.load(io.open(os.path.join(ROOT, "data", nom), encoding="utf-8"))


def f(x):
    t = "%.1f" % x
    if t.endswith(".0"):
        t = t[:-2]
    return t.replace(".", ",")


class Modele:
    def __init__(self, graine):
        self.objets = lire("items.json")
        self.comptoir = lire("comptoir.json")
        self.marche = lire("marche.json")
        self.tour = lire("tour.json")
        self.rng = random.Random(graine)

    def rarete(self, source):
        poids = self.objets["butin"][source]
        total = sum(poids.values())
        t = self.rng.uniform(0, total)
        for r, p in poids.items():
            t -= p
            if t < 0:
                return r
        return list(poids)[-1]

    def prix_plancher(self, rarete, niveau, qualite):
        c = self.comptoir
        base = c["plancher"][rarete]
        nv = c["niveau_pente"] * niveau / 30.0
        q = c["qualite_base"] + (1 - c["qualite_base"]) * qualite / 100.0
        return max(1, round(base * (1 + nv) * q))

    def prix_max_marche(self, rarete, niveau, qualite):
        return self.prix_plancher(rarete, niveau, qualite) * self.comptoir["marche"][rarete]

    def butin_etage(self, etage):
        """L'objet d'un premier passage : (rareté, niveau, qualité)."""
        g = self.tour["gardien_tous_les"]
        gg = self.tour["grand_gardien_tous_les"]
        source = "grand_gardien" if etage % gg == 0 else ("gardien" if etage % g == 0 else "etage")
        niveau = max(1, int(self.tour["niveau_depart"] + self.tour["niveau_par_etage"] * (etage - 1)))
        return self.rarete(source), niveau, self.rng.randint(0, 100)

    def taux_taxe(self, entre, detruit):
        base = self.marche["taxe"]
        inf = self.marche["inflation"]
        if entre < inf["minimum"]:
            return base
        ratio = entre / max(1, detruit)
        if ratio <= inf["seuil"]:
            return base
        crans = int((ratio - inf["seuil"]) / inf["par"] + 1e-9) + 1
        return min(self.marche["taxe_max"], base + inf["pas"] * crans)


def or_d_un_bot(m, niveau_max=30):
    """Tout l'Or qu'un compte peut créer au Comptoir en montant jusqu'à ce niveau : ses premiers passages (1,7 étage par
    niveau), tout vendu au plancher. Rien d'autre ne crée de l'Or."""
    total = 0
    for etage in range(1, int(ETAGES_PAR_NIVEAU * niveau_max) + 1):
        rarete, niveau, qualite = m.butin_etage(etage)
        total += m.prix_plancher(rarete, niveau, qualite)
    return total


def simuler(joueurs, semaines, bots, graine):
    m = Modele(graine)
    rng = m.rng
    # Les joueurs honnêtes : le niveau monte d'un par jour les deux premières semaines, puis d'un tous les trois jours,
    # jusqu'à 60 ; chaque niveau ouvre 1,7 étage en premier passage (un objet échangeable chacun) ; les communs et les
    # rares vont au Comptoir (de l'Or créé), les épiques et les légendaires au Marché (une offre au prix médian de la
    # fourchette) ; ce que les acheteurs peuvent payer est borné par l'Or qu'ils ont (la moitié de l'Or en circulation
    # par semaine au plus) ; l'invendu finit au Comptoir. L'Or échangé change de main, la taxe est détruite.
    etat = [{"niveau": 1, "etage": 0, "age": rng.randint(0, 60)} for _ in range(joueurs)]
    taux = m.marche["taxe"]
    circulation = 0
    bilans = []
    for semaine in range(1, semaines + 1):
        entre = 0
        offre = 0
        for j in etat:
            for jour in range(7):
                j["age"] += 1
                if (j["age"] <= 14 or jour % 3 == 0) and j["niveau"] < 60:
                    j["niveau"] += 1
                    cible = int(ETAGES_PAR_NIVEAU * j["niveau"])
                    while j["etage"] < cible:
                        j["etage"] += 1
                        rarete, niveau, qualite = m.butin_etage(j["etage"])
                        plancher = m.prix_plancher(rarete, niveau, qualite)
                        if rarete in ("commun", "rare"):
                            entre += plancher
                        else:
                            offre += (plancher + m.prix_max_marche(rarete, niveau, qualite)) // 2
        echange = min(offre, circulation // 2)
        # L'offre invendue va au Comptoir, au plancher (environ un dixième du prix médian demandé).
        entre += (offre - echange) // 10
        detruit = math.ceil(echange * taux)
        circulation += entre - detruit
        bilans.append({"semaine": semaine, "entre": entre, "detruit": detruit, "echange": echange, "taux": taux, "circulation": circulation,
                       "niveau_moyen": sum(j["niveau"] for j in etat) / len(etat)})
        taux = m.taux_taxe(entre, detruit)
    # La ferme de bots : un compte monte de deux niveaux par jour jusqu'au niveau 30 (15 jours), vend tous ses premiers
    # passages au Comptoir, puis n'a plus rien à créer : la ferme doit faire tourner des comptes neufs. Pour livrer de
    # l'Or à un client, le client met un de ses objets en vente au prix le plus haut de sa fourchette, et un compte de la
    # ferme (niveau 15, 7 jours) l'achète : l'Or passe, moins la taxe.
    or_bot = sum(or_d_un_bot(m) for _ in range(20)) / 20.0
    ferme_semaine = bots * or_bot / (15 / 7.0)
    return bilans, m, or_bot, ferme_semaine


def rapport(bilans, m, or_bot, ferme_semaine, joueurs, semaines, bots):
    dernier = bilans[-1]
    taux = dernier["taux"]
    legendaire = m.prix_max_marche("legendaire", 30, 100)
    epique = m.prix_max_marche("epique", 30, 100)
    commun = m.prix_max_marche("commun", 30, 100)
    L = ["# L'économie du jeu", "",
         "Généré par `tools/economie.py` : les règles (depuis `data/marche.json`, `data/comptoir.json`, `data/items.json`, `data/tour.json`) puis une "
         "simulation simple de %d joueurs honnêtes pendant %d semaines, et le calcul de ce qu'une ferme de %d bots peut faire. Ne pas modifier à la "
         "main : changer les données ou le modèle, puis relancer l'outil." % (joueurs, semaines, bots), "",
         "## Les règles (GDD V2, § 10.2)", "",
         "- **Deux monnaies.** Les Éclats, liés, viennent de tout le contenu (Tour, duels, revenu du jour, objectifs) et paient la reforge, l'étal "
         "du Comptoir et les entrées de donjon. **L'Or, échangeable, ne tombe jamais du contenu** : il naît seulement au Comptoir, quand on y vend un "
         "objet échangeable (un premier passage de la Tour, le boss d'un donjon), au prix plancher fixé par le jeu. Comme les premiers passages "
         "sont comptés (1,7 étage par niveau), **l'Or qu'un compte peut créer dans sa vie est borné** : environ %d Or jusqu'au niveau 30." % round(or_bot),
         "- **Le Marché** (l'hôtel des ventes) : le vendeur fixe son prix entre le plancher et le plancher × %s selon la rareté ; les annonces sont "
         "anonymes et vont au premier acheteur ; **chaque vente détruit une taxe** de %s (jusqu'à %s quand trop d'Or est créé). L'Or qui change de "
         "main ne se crée pas : l'acheteur doit l'avoir." % (
             " / ".join("%d (%s)" % (v, m.objets["raretes"][k]["nom"]["m"]) for k, v in m.comptoir["marche"].items()),
             f(m.marche["taxe"] * 100) + " %", f(m.marche["taxe_max"] * 100) + " %"),
         "- **La taxe qui monte** : chaque semaine, le jeu lit l'Or créé au Comptoir et l'Or détruit par la taxe la semaine d'avant (tous les "
         "joueurs). Si l'Or créé dépasse %s fois l'Or détruit (et au moins %d Or), la taxe de la semaine monte de %s par cran de %s dans ce rapport, "
         "jusqu'à %s. Les fourchettes de prix, elles, ne bougent jamais." % (
             f(m.marche["inflation"]["seuil"]), m.marche["inflation"]["minimum"], f(m.marche["inflation"]["pas"] * 100) + " points",
             f(m.marche["inflation"]["par"]), f(m.marche["taxe_max"] * 100) + " %"),
         "- **Les garde-fous contre les bots et les revendeurs d'Or** : le Marché s'ouvre au niveau %d et après %d jours de compte ; %d annonces "
         "en cours au plus ; par jour et par compte, **%d ventes au Comptoir, %d mises en vente, %d achats** ; un objet de rien ne peut pas être "
         "mis à un prix exorbitant (un commun : %d Or au plus) ; aucun autre canal : pas de don, pas d'échange direct, pas d'envoi d'Or." % (
             m.marche["niveau_min"], m.marche["jours_min"], m.marche["annonces_max"], m.comptoir["ventes_par_jour"], m.marche["depots_par_jour"],
             m.marche["achats_par_jour"], commun),
         "", "## La simulation des joueurs honnêtes", "",
         "Un joueur monte d'un niveau par jour ses deux premières semaines, puis d'un tous les trois jours ; chaque niveau ouvre 1,7 étage en premier "
         "passage (un objet échangeable chacun) ; les communs et les rares vont au Comptoir, les épiques et les légendaires au Marché (au prix médian "
         "de leur fourchette) ; les acheteurs ne peuvent dépenser que l'Or qu'ils ont (la moitié de l'Or en circulation par semaine au plus) ; "
         "l'invendu finit au Comptoir. La taxe de chaque semaine se décide sur la semaine d'avant.",
         "", "| Semaine | Taxe | Or créé (Comptoir) | Or détruit (taxe) | Or échangé entre joueurs | Or en circulation | Niveau moyen |",
         "| --- | --- | --- | --- | --- | --- | --- |"]
    for b in bilans:
        L.append("| %d | %s | %d | %d | %d | %d | %s |" % (b["semaine"], f(b["taux"] * 100) + " %", b["entre"], b["detruit"], b["echange"], b["circulation"], f(b["niveau_moyen"])))
    L.append("")
    L.append("## La ferme de bots et le revendeur d'Or")
    L.append("")
    L.append("- Un compte bot monte de deux niveaux par jour jusqu'au niveau 30 (15 jours) et vend tous ses premiers passages au Comptoir : "
             "**%d Or dans sa vie**, puis plus rien (il n'a plus de premier passage ; les étages rejoués ne donnent que des objets liés). "
             "Une ferme de %d bots qui fait tourner ses comptes crée donc environ **%d Or par semaine**." % (round(or_bot), bots, round(ferme_semaine)))
    L.append("- Pour livrer cet Or à un client, le client met un objet à lui en vente au prix le plus haut de sa fourchette et un compte de la ferme "
             "l'achète (il faut à ce compte le niveau %d et %d jours) : la taxe de %s est détruite au passage. Un commun livre %d Or au plus, un "
             "épique %d, un légendaire %d : **pour livrer 10 000 Or, il faut %s comptes bots amenés au niveau 30, et le client doit posséder "
             "un légendaire ou cinq épiques échangeables** ; %d Or partent en taxe." % (
                 m.marche["niveau_min"], m.marche["jours_min"], f(taux * 100) + " %", commun - math.ceil(commun * taux), epique - math.ceil(epique * taux),
                 legendaire - math.ceil(legendaire * taux), f(10000 / max(1, or_bot * (1 - taux))), math.ceil(10000 * taux / (1 - taux))))
    L.append("- L'Or en circulation après %d semaines : %d pour %d joueurs (%s par joueur) ; la taxe de la dernière semaine : %s (elle monte quand "
             "les joueurs créent beaucoup plus d'Or qu'ils n'en échangent)." % (semaines, dernier["circulation"], joueurs, f(dernier["circulation"] / joueurs), f(taux * 100) + " %"))
    L.append("- Dans ce modèle, la taxe oscille d'une semaine à l'autre (les joueurs montent de niveau par à-coups, et l'Or créé avec eux) : "
             "la règle lit une seule semaine ; si le vrai jeu fait pareil, lisser sur deux ou trois semaines (à régler à la fin).")
    L.append("- Ces chiffres sont ceux du modèle, pas du jeu joué : ils disent l'ordre de grandeur et le sens des garde-fous. Le réglage fin vient à la fin, "
             "avec le vrai serveur et de vrais joueurs.")
    L.append("")
    return "\n".join(L) + "\n"


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--joueurs", type=int, default=1000)
    parser.add_argument("--semaines", type=int, default=12)
    parser.add_argument("--bots", type=int, default=50)
    parser.add_argument("--graine", type=int, default=1)
    args = parser.parse_args()
    bilans, m, or_bot, ferme = simuler(args.joueurs, args.semaines, args.bots, args.graine)
    texte = rapport(bilans, m, or_bot, ferme, args.joueurs, args.semaines, args.bots)
    io.open(os.path.join(ROOT, "docs", "ECONOMIE.md"), "w", encoding="utf-8", newline="\n").write(texte)
    print(texte)


if __name__ == "__main__":
    import sys
    sys.stdout.reconfigure(encoding="utf-8")
    main()
