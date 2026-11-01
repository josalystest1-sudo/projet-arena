# -*- coding: utf-8 -*-
"""Les scénarios d'économie : une simulation à comptes individuels (des milliers de joueurs de plusieurs sortes, des cohortes
qui arrivent et qui partent, la Tour, les donjons, l'hôtel des ventes avec des prix qui montent et descendent selon l'offre
et la demande, l'amélioration +1 à +10, les cosmétiques, une ferme de bots et des clients qui lui achètent de l'Or), jouée
jour par jour sur six mois, pour six façons de faire la monnaie. Mesure l'inflation, l'écart vétérans / débutants, ce qu'un
débutant peut s'acheter, la liquidité du Marché et ce qu'un revendeur d'Or peut livrer. Relit les chiffres du jeu (`data/`).
Écrit `docs/ECONOMIE-SCENARIOS.md` (les tableaux) et `docs/economie_scenarios.json` (les courbes).

Usage : python tools/scenarios_economie.py [--joueurs 3000] [--jours 180] [--bots 300] [--graines 1,2,3] [--scenarios A,B,C,D,E,F,G,H]
(les mesures sont la moyenne des graines)
"""
import argparse
import io
import json
import math
import os
import random
import statistics
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
RARETES = ["commun", "peu_commun", "rare", "epique", "legendaire"]
TRANCHES = [(1, 10), (11, 20), (21, 30), (31, 60)]
EMPLACEMENTS = 8
NIVEAU_MAX = 60
# Les sortes de joueurs : (chance de jouer un jour donné, combats par jour de jeu, part de l'Or qu'il accepte de mettre dans
# un objet, marge demandée avant de tenter une amélioration (Or possédé / coût), descentes de donjon par jour au plus,
# chance de partir chaque jour).
SORTES = {
    "occasionnel": dict(joue=0.40, combats=3, part=0.5, marge=3.0, donjons=1, depart=0.012),
    "regulier": dict(joue=0.75, combats=8, part=0.6, marge=2.0, donjons=2, depart=0.005),
    "assidu": dict(joue=0.95, combats=18, part=0.8, marge=1.2, donjons=3, depart=0.002),
}
POIDS_SORTES = [("occasionnel", 50), ("regulier", 38), ("assidu", 12)]
COMBATS_PAR_NIVEAU = 0.22  # combats cumulés pour atteindre un niveau L : 0,22 × L² (le niveau 30 en ~200 combats : un à deux mois)
COMBATS_PAR_NIVEAU_EVOLUE = 40  # au-delà du niveau 30, quarante combats par niveau (le niveau 60 en huit mois pour un régulier)
CHANCE_BOSS = 0.03  # un légendaire échangeable par descente, une fois sur trente environ
CHANCE_EPIQUE_ECHANGEABLE = 0.25  # l'épique de l'élite est échangeable une fois sur quatre (le premier passage d'une route)
HABILETE_BOT = 0.6  # un bot joue moins bien que l'IA : il progresse à 60 % de la vitesse
COMBATS_BOT = 60
COUT_BOT_PAR_JOUR = 0.05  # euros par compte bot et par jour (électricité, compte, proxy) : fixe le prix de revient de l'Or
PART_CLIENTS = 0.02  # part des joueurs réguliers et assidus qui achèteraient de l'Or
SCENARIOS = {
    "A": dict(nom="RPG classique", texte="l'Or tombe des monstres à chaque combat, tout objet se vend au marchand, prix libres à l'hôtel des ventes, taxe fixe de 5 %, aucun plafond",
              or_pve=True, tout_echangeable=True, fourchette=False, taxe_variable=False, taxe=0.05, comptoir_flottant=False, cosmetiques=False,
              mail=False, plafond=False, monnaie="or"),
    "B": dict(nom="Le jeu d'aujourd'hui (PR #83 et #92)", texte="l'Or ne naît qu'au Comptoir (objets de premier passage), fourchettes de prix, taxe de 15 % qui monte jusqu'à 40 %, amélioration en Or",
              or_pve=False, tout_echangeable=False, fourchette=True, taxe_variable=True, taxe=0.15, comptoir_flottant=False, cosmetiques=False,
              mail=False, plafond=False, monnaie="or"),
    "C": dict(nom="La proposition § 8", texte="B + le Comptoir paie moins quand l'Or abonde (et plus quand il manque), des cosmétiques en Or, l'adresse mail confirmée pour vendre (cinq fois moins de bots)",
              or_pve=False, tout_echangeable=False, fourchette=True, taxe_variable=True, taxe=0.15, comptoir_flottant=True, cosmetiques=True,
              mail=True, plafond=False, monnaie="or"),
    "D": dict(nom="§ 8 + l'Or plafonné", texte="C + un compte ne peut pas détenir plus de 20 Or par niveau (l'excédent devient des Éclats)",
              or_pve=False, tout_echangeable=False, fourchette=True, taxe_variable=True, taxe=0.15, comptoir_flottant=True, cosmetiques=True,
              mail=True, plafond=True, monnaie="or"),
    "E": dict(nom="Les Éclats comme monnaie du Marché", texte="pas d'Or : le Marché se paie en Éclats (ceux du PvE, imprimés à chaque combat), avec les fourchettes et la taxe ; l'acheteur détruit, le vendeur reçoit ; le revendeur vend donc des Éclats",
              or_pve=True, tout_echangeable=False, fourchette=True, taxe_variable=True, taxe=0.15, comptoir_flottant=False, cosmetiques=True,
              mail=True, plafond=False, monnaie="eclats"),
    "F": dict(nom="L'Or lent (recommandé)", texte="D, plus : ce que tout le monde veut est vendu par le jeu, jamais entre joueurs ; la fourchette des légendaires serrée (× 50 au lieu de × 500) ; la taxe lue sur trois semaines",
              or_pve=False, tout_echangeable=False, fourchette=True, taxe_variable=True, taxe=0.15, comptoir_flottant=True, cosmetiques=True,
              mail=True, plafond=True, monnaie="or", legendaire_serre=True, taxe_lissee=True, thermostat="source", cible_or=6.0,
              universel="jeu", prime_jour=0),
    "G": dict(nom="F + une source d'Or quotidienne", texte="F, plus un objet lié racheté chaque jour par le Comptoir (une petite source d'Or bornée par jour et par compte, pour voir ce que les bots en font)",
              or_pve=False, tout_echangeable=False, fourchette=True, taxe_variable=True, taxe=0.15, comptoir_flottant=True, cosmetiques=True,
              mail=True, plafond=True, monnaie="or", legendaire_serre=True, taxe_lissee=True, thermostat="source", cible_or=6.0,
              universel="jeu", prime_jour=1),
    "H": dict(nom="F, l'amélioration en Éclats", texte="F mais l'amélioration +1 à +10 se paie en Éclats (liés) : l'Or n'achète plus que des objets et des tenues",
              or_pve=False, tout_echangeable=False, fourchette=True, taxe_variable=True, taxe=0.15, comptoir_flottant=True, cosmetiques=True,
              mail=True, plafond=True, monnaie="or", legendaire_serre=True, taxe_lissee=True, thermostat="source", cible_or=6.0,
              universel="jeu", prime_jour=0, amelioration_eclats=True),
}
PLAFOND_OR_PAR_NIVEAU = 20  # l'Or qu'un compte peut détenir, par niveau (D et suivants)
PLANCHER_UNIVERSEL = 20  # l'objet que tout le monde veut (une tenue rare, un objet de remise à zéro) : prix plancher en Or
CHANCE_UNIVERSEL = 1 / 400.0  # il tombe une fois tous les quatre cents combats
ENVIE_UNIVERSEL = 7  # chacun en veut un par semaine


def lire(nom):
    return json.load(io.open(os.path.join(ROOT, "data", nom), encoding="utf-8"))


def f(x, d=1):
    t = ("%%.%df" % d) % x
    if "." in t:
        t = t.rstrip("0").rstrip(".")
    return t.replace(".", ",")


def tranche(niveau):
    for i, (a, b) in enumerate(TRANCHES):
        if a <= niveau <= b:
            return i
    return len(TRANCHES) - 1


def gini(valeurs):
    v = sorted(valeurs)
    n = len(v)
    if n == 0 or sum(v) == 0:
        return 0.0
    cumul = 0
    total = sum(v)
    aire = 0.0
    for i, x in enumerate(v):
        cumul += x
        aire += cumul
    return 1 - 2 * aire / (n * total) + 1.0 / n


class Compte(object):
    __slots__ = ("sorte", "bot", "client", "combats", "niveau", "record", "or_", "eclats", "age", "actif", "parti", "objets", "slots", "gear_tranche",
                 "cran", "objets_finis", "dernier_cosmetique", "dernier_universel", "revenu", "achats_jour", "ventes_jour", "rmt_recu", "jour_arrive")

    def __init__(self, sorte, jour, bot=False, client=False):
        self.sorte = sorte
        self.bot = bot
        self.client = client
        self.combats = 0.0
        self.niveau = 1
        self.record = 0
        self.or_ = 0
        self.eclats = 0
        self.age = 0
        self.actif = True
        self.parti = False
        self.objets = []  # les objets échangeables en main : (rareté, niveau, qualité)
        self.slots = [0] * EMPLACEMENTS  # le rang de rareté de l'objet porté à chaque emplacement (0 : rien), pour la tranche courante
        self.gear_tranche = 0
        self.cran = 0
        self.objets_finis = 0
        self.dernier_cosmetique = -99
        self.dernier_universel = -99
        self.revenu = [0] * 7  # l'Or gagné chaque jour de la semaine passée
        self.achats_jour = 0
        self.ventes_jour = 0
        self.rmt_recu = 0
        self.jour_arrive = jour


class Monde(object):
    def __init__(self, sc, joueurs, jours, bots, graine):
        self.sc = sc
        self.rng = random.Random(graine)
        self.objets_d = lire("items.json")
        self.comptoir = lire("comptoir.json")
        self.marche = lire("marche.json")
        self.tour = lire("tour.json")
        self.donjons = lire("donjons.json")
        self.fatigue = lire("fatigue.json")
        self.jours = jours
        self.nouveaux_par_jour = max(1, joueurs // 200)
        self.comptes = [self.nouveau(0) for _ in range(joueurs)]
        nb_bots = bots // 5 if sc["mail"] else bots
        self.bots = [self.nouveau(0, bot=True) for _ in range(nb_bots)]
        self.nb_bots_payes = bots  # la ferme paie toujours autant de comptes ; le mail en fait perdre les quatre cinquièmes
        self.ferme_or = 0
        self.ferme_produit = 0
        self.ferme_livre_semaine = 0
        self.ferme_livre_total = 0
        self.ferme_jours_bot = 0
        # L'hôtel des ventes : par (tranche, rareté) un prix courant et des annonces [(compte, jour, rareté, niveau, qualité)].
        self.prix = {}
        self.annonces = {}
        for t in range(len(TRANCHES)):
            for r in RARETES[2:]:
                self.prix[(t, r)] = self.plancher_tranche(t, r) * 2.0
                self.annonces[(t, r)] = []
        self.prix["U"] = PLANCHER_UNIVERSEL * 2.0
        self.annonces["U"] = []
        self.taux = sc["taxe"]
        self.facteur_comptoir = 1.0
        self.facteur_puits = 1.0
        self.bilans = []  # par semaine : entre, detruit, echange
        self.semaine = dict(entre=0, detruit=0, echange=0, ventes=0, annonces=0, invendu=0, achats_rmt=0, achats=0)
        self.courbes = []
        self.instantanes = []
        self.ventes_7 = []
        self.jour = 0

    # --- les chiffres du jeu ---
    def nouveau(self, jour, bot=False):
        if bot:
            return Compte("assidu", jour, bot=True)
        t = self.rng.uniform(0, sum(p for _, p in POIDS_SORTES))
        for s, p in POIDS_SORTES:
            t -= p
            if t < 0:
                break
        client = s != "occasionnel" and self.rng.random() < PART_CLIENTS
        return Compte(s, jour, client=client)

    def echelle(self, niveau):
        n = self.objets_d["niveau"]
        return n["plancher"] + (1 - n["plancher"]) * min(niveau, n["plein"]) / float(n["plein"])

    def prix_plancher(self, rarete, niveau, qualite):
        c = self.comptoir
        base = c["plancher"][rarete]
        q = c["qualite_base"] + (1 - c["qualite_base"]) * qualite / 100.0
        return max(1, base * (1 + c["niveau_pente"] * niveau / 30.0) * q)

    def plancher_tranche(self, t, rarete):
        if t == "U":
            return PLANCHER_UNIVERSEL
        a, b = TRANCHES[t]
        return self.prix_plancher(rarete, (a + b) / 2.0, 50)

    def plafond_tranche(self, t, rarete):
        if t == "U":
            return PLANCHER_UNIVERSEL * 50
        m = self.comptoir["marche"][rarete]
        if self.sc.get("legendaire_serre") and rarete == "legendaire":
            m = 50
        return self.plancher_tranche(t, rarete) * m

    def niveau_de(self, combats):
        seuil30 = COMBATS_PAR_NIVEAU * 30 * 30
        if combats < seuil30:
            return max(1, int(math.sqrt(combats / COMBATS_PAR_NIVEAU)))
        return min(NIVEAU_MAX, 30 + int((combats - seuil30) / COMBATS_PAR_NIVEAU_EVOLUE))

    def record_max(self, niveau):
        return int(4 + 1.5 * niveau)

    def tirer(self, poids):
        total = sum(poids.values())
        t = self.rng.uniform(0, total)
        for r, p in poids.items():
            t -= p
            if t < 0:
                return r
        return list(poids)[-1]

    def butin_premier_passage(self, etage):
        b = self.objets_d["butin"]
        g, gg = self.tour["gardien_tous_les"], self.tour["grand_gardien_tous_les"]
        if etage % gg == 0:
            source = "grand_gardien"
        elif etage % g == 0:
            source = "gardien"
        else:
            if self.rng.random() > b["chance_etage"]:
                return None
            source = "etage"
        niveau = max(1, int(self.tour["niveau_depart"] + self.tour["niveau_par_etage"] * (etage - 1)))
        return (self.tirer(b[source]), min(niveau, NIVEAU_MAX), self.rng.randint(0, 100))

    def cout_amelioration(self, rarete, niveau, cran):
        a = self.objets_d["amelioration"]
        return max(1, round(a["cout"] / self.sc.get("amelioration_div", 1.0) * self.objets_d["raretes"][rarete]["rang"] * self.echelle(niveau) * a["pente"] ** cran))

    def unite(self, x):
        """En scénario E, la monnaie est l'Éclat : les prix en Or du jeu valent cinq Éclats."""
        return x * 5 if self.sc["monnaie"] == "eclats" else x

    def plafond_or(self, c):
        return PLAFOND_OR_PAR_NIVEAU * c.niveau

    def equiper(self, c, rarete):
        """Porte l'objet s'il vaut mieux que le pire emplacement (il devient lié) ; dit si c'est fait."""
        rang = RARETES.index(rarete) + 1
        pire = min(c.slots)
        if rang > pire:
            c.slots[c.slots.index(pire)] = rang
            return True
        return False

    # --- une journée ---
    def jouer(self, c):
        sc = self.sc
        s = SORTES[c.sorte]
        gagne = 0
        if c.bot:
            n = COMBATS_BOT
        else:
            n = max(1, int(round(s["combats"] * self.rng.uniform(0.6, 1.4))))
        # La Tour : des étages neufs d'abord (premier passage), au plus trois par jour.
        neufs = min(3, self.record_max(c.niveau) - c.record, n)
        for _ in range(max(0, neufs)):
            c.record += 1
            c.eclats += min(50, 10 + 2 * c.record)
            o = self.butin_premier_passage(c.record)
            if o:
                c.objets.append(o)
            if sc["or_pve"] and sc["monnaie"] == "or":
                gagne += self.or_monstres(c)
            elif sc["monnaie"] == "eclats":
                pass
        reste = n - max(0, neufs)
        # Les donjons : quatre combats par descente, l'entrée en Éclats ; l'élite donne un épique lié, le boss (une route sur
        # douze environ) un légendaire échangeable.
        dj = self.donjon_de(c.niveau)
        descentes = 0
        if dj and not c.bot:
            descentes = min(s["donjons"], reste // 4)
            for _ in range(descentes):
                if c.eclats < dj["entree"]:
                    break
                c.eclats -= dj["entree"]
                reste -= 4
                c.eclats += self.donjons["recompenses"]["elite"]["eclats"]
                if self.rng.random() < CHANCE_EPIQUE_ECHANGEABLE:
                    c.objets.append(("epique", c.niveau, self.rng.randint(0, 100)))
                elif not self.equiper(c, "epique"):
                    c.eclats += self.objets_d["recyclage"]["epique"]
                if sc["or_pve"] and sc["monnaie"] == "or":
                    gagne += 4 * self.or_monstres(c)
                if self.rng.random() < CHANCE_BOSS:
                    c.eclats += self.donjons["recompenses"]["boss"]["eclats"]
                    c.objets.append(("legendaire", c.niveau, self.rng.randint(0, 100)))
        # Le farm : des étages rejoués, des objets liés recyclés en Éclats ; en RPG classique tout se revend.
        b = self.objets_d["butin"]
        for _ in range(max(0, reste)):
            c.eclats += 5
            if self.rng.random() < b["rejoue"]:
                r = self.tirer(b["etage"])
                if sc["tout_echangeable"]:
                    c.objets.append((r, c.niveau, self.rng.randint(0, 100)))
                else:
                    c.eclats += self.objets_d["recyclage"][r]
            if sc["or_pve"] and sc["monnaie"] == "or":
                gagne += self.or_monstres(c)
        for _ in range(n):
            if self.rng.random() < CHANCE_UNIVERSEL:
                if sc.get("universel", "marche") == "marche":
                    c.objets.append(("universel", c.niveau, 50))
                else:
                    c.eclats += 50  # le jeu le vend lui-même : la trouvaille vaut des Éclats
        if sc.get("prime_jour", 0) and reste > 0:
            c.objets.append(("prime", c.niveau, self.rng.randint(0, 100)))
        c.combats += n * (HABILETE_BOT if c.bot else 1.0)
        c.niveau = self.niveau_de(c.combats)
        t = tranche(c.niveau)
        if t != c.gear_tranche:  # les objets de la tranche d'avant ne servent plus : la demande renaît
            c.gear_tranche = t
            c.slots = [0] * EMPLACEMENTS
            c.cran = 0
            c.objets_finis = 0
        # Les Éclats se dépensent (reforge, étal, potions) : on garde un matelas.
        if c.eclats > 300 and not c.bot:
            c.eclats -= 40
        return gagne

    def or_monstres(self, c):
        return 1.5 * c.niveau

    def donjon_de(self, niveau):
        for d in self.donjons["donjons"]:
            if d["niveau_min"] <= niveau <= d["niveau_max"]:
                return d
        return None

    def marche_ouvert(self, c):
        m = self.marche
        return c.niveau >= m["niveau_min"] and c.age >= m["jours_min"]

    def vendre(self, c):
        """Les objets échangeables en main : les communs et les peu communs au Comptoir (de la monnaie créée), les rares et
        au-dessus à l'hôtel des ventes si le compte peut y vendre, sinon au Comptoir."""
        sc = self.sc
        gagne = 0
        garde = []
        for o in c.objets:
            r, niveau, q = o
            if r == "prime":
                if c.ventes_jour < self.comptoir["ventes_par_jour"]:
                    c.ventes_jour += 1
                    gagne += self.unite(self.prix_plancher("peu_commun", niveau, q)) * self.facteur_comptoir
                continue
            peut_vendre = self.marche_ouvert(c) and not (c.bot and sc["mail"])
            if r == "universel":
                if peut_vendre:
                    self.annonces["U"].append((c, self.jour, r, niveau, q))
                    self.semaine["annonces"] += 1
                else:
                    garde.append(o)
                continue
            if not c.bot and tranche(niveau) == tranche(c.niveau) and self.equiper(c, r):
                continue
            au_marche = RARETES.index(r) >= 2 and peut_vendre
            if au_marche and len(self.annonces[(tranche(niveau), r)]) < 5000:
                self.annonces[(tranche(niveau), r)].append((c, self.jour, r, niveau, q))
                self.semaine["annonces"] += 1
            elif c.ventes_jour < self.comptoir["ventes_par_jour"] or sc["tout_echangeable"]:
                c.ventes_jour += 1
                gagne += self.unite(self.prix_plancher(r, niveau, q)) * self.facteur_comptoir
            else:
                garde.append(o)
        c.objets = garde
        self.semaine["entre"] += gagne
        return gagne

    def acheter(self, c):
        """Le compte cherche, dans sa tranche, le meilleur objet qu'il peut se payer, du légendaire au rare ; un achat par jour."""
        if c.bot or not self.marche_ouvert(c) or c.achats_jour >= self.marche["achats_par_jour"]:
            return None
        part = SORTES[c.sorte]["part"] * (1.15 if c.client else 1.0)
        if self.sc.get("universel", "marche") == "marche" and self.jour - c.dernier_universel >= ENVIE_UNIVERSEL and self.prix["U"] <= self.solde(c) * part:
            return "U"
        t = tranche(c.niveau)
        pire = min(c.slots)
        for r in ("legendaire", "epique", "rare"):
            if RARETES.index(r) + 1 <= pire:
                continue
            p = self.prix[(t, r)]
            if p <= self.solde(c) * part:
                return (t, r)
            if self.rng.random() < 0.5:
                return None  # une fois sur deux, il garde son Or pour mieux
        return None

    def solde(self, c):
        return c.eclats if self.sc["monnaie"] == "eclats" else c.or_

    def payer(self, c, montant):
        if self.sc["monnaie"] == "eclats":
            c.eclats -= montant
        else:
            c.or_ -= montant

    def recevoir(self, c, montant):
        if self.sc["monnaie"] == "eclats":
            c.eclats += montant
        else:
            c.or_ += montant
            c.revenu[self.jour % 7] += montant

    def clore_marche(self, acheteurs):
        """Pour chaque (tranche, rareté) : les acheteurs du jour contre les annonces ; le prix monte quand les acheteurs sont
        plus nombreux que les annonces, baisse sinon, dans la fourchette ; l'invendu de plus de sept jours part au Comptoir."""
        sc = self.sc
        for cle, liste in self.annonces.items():
            if cle == "U":
                t, r = "U", "universel"
            else:
                t, r = cle
            demandeurs = acheteurs.get(cle, [])
            p = self.prix[cle]
            nb = min(len(demandeurs), len(liste))
            self.rng.shuffle(demandeurs)
            vendues = 0
            for k in range(nb):
                acheteur = demandeurs[k]
                vendeur, jour0, rr, niveau, q = liste[k]
                prix = int(round(p))
                if self.solde(acheteur) < prix:
                    continue
                self.payer(acheteur, prix)
                taxe = int(math.ceil(prix * self.taux))
                self.recevoir(vendeur, prix - taxe)
                vendues += 1
                acheteur.achats_jour += 1
                if cle == "U":
                    acheteur.dernier_universel = self.jour
                else:
                    self.equiper(acheteur, r)
                self.semaine["detruit"] += taxe
                self.semaine["echange"] += prix - taxe
                self.semaine["ventes"] += 1
                self.semaine["achats"] += 1
                if acheteur.client and acheteur.rmt_recu > 0:
                    self.semaine["achats_rmt"] += 1
            del liste[:vendues]
            # Le prix bouge avec l'excès de demande.
            d, o = len(demandeurs), len(liste) + vendues
            if d + o > 0:
                p *= 1 + 0.10 * (d - o) / float(max(d, o, 1))
            bas = self.unite(self.plancher_tranche(t, r))
            if sc["fourchette"]:
                p = min(self.unite(self.plafond_tranche(t, r)), max(bas, p))
            else:
                p = max(bas, p)
            self.prix[cle] = p
            # L'invendu de plus de sept jours part au Comptoir, au plancher.
            vieux = [a for a in liste if self.jour - a[1] > 7]
            if vieux:
                self.semaine["invendu"] += len(vieux)
                for vendeur, jour0, rr, niveau, q in vieux:
                    m = self.unite(PLANCHER_UNIVERSEL if rr == "universel" else self.prix_plancher(rr, niveau, q)) * self.facteur_comptoir
                    self.recevoir(vendeur, m)
                    self.semaine["entre"] += m
                liste[:] = [a for a in liste if self.jour - a[1] <= 7]

    def depenser(self, c):
        """Les puits : l'amélioration +1 à +10 (un échec fait perdre un cran), les potions, les cosmétiques."""
        sc = self.sc
        s = SORTES[c.sorte]
        if c.bot:
            return
        detruit = 0
        # L'amélioration : sur le meilleur objet porté.
        meilleure = RARETES[max(c.slots) - 1] if max(c.slots) > 0 else None
        en_eclats = sc.get("amelioration_eclats", False)
        if meilleure and c.objets_finis < EMPLACEMENTS:
            a = self.objets_d["amelioration"]
            for _ in range(3):
                if c.cran >= a["max"]:
                    c.objets_finis += 1
                    c.cran = 0
                    break
                cout = max(1, int(round(self.unite(self.cout_amelioration(meilleure, c.niveau, c.cran)) * self.facteur_puits)))
                if en_eclats:
                    cout *= 5
                    if c.eclats < cout * s["marge"]:
                        break
                    c.eclats -= cout
                else:
                    if self.solde(c) < cout * s["marge"]:
                        break
                    self.payer(c, cout)
                    detruit += cout
                if self.rng.random() < a["reussite"][c.cran]:
                    c.cran += 1
                else:
                    c.cran = max(0, c.cran - 1)
        # Les potions d'énergie en Or chez l'Alchimiste (les assidus).
        if c.sorte == "assidu" and sc["monnaie"] == "or" and not sc["or_pve"] and c.or_ >= 100:
            c.or_ -= self.fatigue["potion"]["prix_or"]
            detruit += self.fatigue["potion"]["prix_or"]
        # Les cosmétiques en Or : une tenue quand on est riche, une tous les quinze jours au plus.
        if sc["cosmetiques"]:
            prix = self.unite(300 * self.echelle(c.niveau)) * self.facteur_puits
            if self.solde(c) >= 4 * prix and self.jour - c.dernier_cosmetique >= 14:
                self.payer(c, prix)
                detruit += prix
                c.dernier_cosmetique = self.jour
        self.semaine["detruit"] += detruit

    def plafonner(self, c):
        if self.sc["plafond"] and self.sc["monnaie"] == "or":
            cap = self.plafond_or(c)
            if c.or_ > cap:
                c.eclats += int((c.or_ - cap) * 5)
                self.semaine["detruit"] += c.or_ - cap
                c.or_ = cap

    def ferme(self):
        """La ferme de bots : ses comptes jouent, vendent au Comptoir (et à l'hôtel des ventes, sauf si le mail est exigé),
        et leur Or est mis de côté pour les clients ; un bot au niveau 30 n'a plus de premier passage à vendre : on le
        remplace par un compte neuf."""
        sc = self.sc
        for b in self.bots:
            b.age += 1
            b.ventes_jour = 0
            self.ferme_jours_bot += 1
            eclats0 = b.eclats
            b.or_ += self.jouer(b)
            b.or_ += self.vendre(b)
            if sc["monnaie"] == "eclats":
                b.or_ = max(0, b.eclats - eclats0)  # les Éclats gagnés ce jour sont la marchandise
                b.eclats = eclats0
            self.ferme_or += b.or_
            self.ferme_produit += b.or_
            b.or_ = 0
            if b.niveau >= 30 and not sc["tout_echangeable"]:
                b.__init__("assidu", self.jour, bot=True)

    def livrer_rmt(self):
        """Chaque semaine, la ferme livre son Or aux clients : en RPG classique par échange direct (tout passe) ; sinon par
        une annonce du client au prix le plus haut de sa fourchette, achetée par un compte de la ferme : la taxe est détruite,
        le client ne peut pas recevoir plus que ce que ses annonces permettent, ni dépasser son plafond d'Or."""
        sc = self.sc
        clients = [c for c in self.comptes if c.client and c.actif and not c.parti and self.marche_ouvert(c)]
        self.rng.shuffle(clients)
        livre = 0
        for c in clients:
            if self.ferme_or <= 0:
                break
            t = tranche(c.niveau)
            voulu = max(0, self.prix[(t, "legendaire")] * 2 - self.solde(c))  # de quoi acheter deux légendaires
            if sc["tout_echangeable"]:
                canal = voulu
            else:
                # Cinq annonces par jour pendant sept jours, d'objets qu'il possède (on suppose un épique par semaine) :
                # un épique au plafond de sa fourchette, puis des communs.
                canal = self.unite(self.plafond_tranche(t, "epique") + 34 * self.plafond_tranche(t, "commun"))
            montant = min(voulu, canal / (1 - self.taux), self.ferme_or)
            if sc["plafond"] and sc["monnaie"] == "or":
                montant = min(montant, max(0, self.plafond_or(c) - c.or_) / (1 - self.taux))
            if montant <= 0:
                continue
            taxe = montant * self.taux if not sc["tout_echangeable"] else 0
            self.recevoir(c, montant - taxe)
            c.rmt_recu += montant - taxe
            livre += montant - taxe
            self.ferme_or -= montant
            self.semaine["detruit"] += taxe
        self.ferme_livre_semaine = livre
        self.ferme_livre_total += livre

    def taux_taxe(self, entre, detruit):
        m = self.marche
        base = m["taxe"]
        inf = m["inflation"]
        if entre < inf["minimum"]:
            return base
        ratio = entre / max(1.0, detruit)
        if ratio <= inf["seuil"]:
            return base
        crans = int((ratio - inf["seuil"]) / inf["par"] + 1e-9) + 1
        return min(m["taxe_max"], base + inf["pas"] * crans)

    def fin_de_semaine(self):
        sc = self.sc
        s = self.semaine
        self.bilans.append(dict(s))
        if sc["taxe_variable"]:
            if sc.get("taxe_lissee"):
                derniers = self.bilans[-3:]
                self.taux = self.taux_taxe(sum(b["entre"] for b in derniers), sum(b["detruit"] for b in derniers))
            else:
                self.taux = self.taux_taxe(s["entre"], s["detruit"])
        actifs = self.actifs()
        if sc["comptoir_flottant"] and actifs:
            g = sum(c.or_ for c in actifs) / float(len(actifs))
            med = statistics.median(c.niveau for c in actifs)
            cible = sc.get("cible_or", 6.0) * med
            if sc.get("thermostat", "source") == "baisse":
                voulu = min(1.0, max(0.5, cible / max(1.0, g)))
                self.facteur_comptoir = 0.5 * self.facteur_comptoir + 0.5 * voulu
            elif sc.get("thermostat", "source") == "puits":
                # Le Comptoir ne paie jamais plus que le plancher ; les puits se renchérissent avec l'Or qui abonde.
                voulu = min(1.0, max(0.5, cible / max(1.0, g)))
                self.facteur_comptoir = 0.5 * self.facteur_comptoir + 0.5 * voulu
                voulu_puits = min(5.0, max(0.2, g / max(1.0, cible)))
                self.facteur_puits = 0.5 * self.facteur_puits + 0.5 * voulu_puits
            else:
                fmax = sc.get("facteur_max", 1.5)
                voulu = min(fmax, max(1.0 / fmax, cible / max(1.0, g)))
                self.facteur_comptoir = 0.5 * self.facteur_comptoir + 0.5 * voulu
        self.livrer_rmt()
        self.semaine = dict(entre=0, detruit=0, echange=0, ventes=0, annonces=0, invendu=0, achats_rmt=0, achats=0)

    def actifs(self):
        return [c for c in self.comptes if not c.parti and c.actif]

    def journee(self):
        sc = self.sc
        self.jour += 1
        for _ in range(self.nouveaux_par_jour):
            self.comptes.append(self.nouveau(self.jour))
        acheteurs = {}
        for c in self.comptes:
            if c.parti:
                continue
            c.age += 1
            c.achats_jour = 0
            c.ventes_jour = 0
            c.revenu[self.jour % 7] = 0
            s = SORTES[c.sorte]
            if self.rng.random() < s["depart"]:
                c.parti = True
                continue
            if self.rng.random() > s["joue"]:
                c.actif = False
                continue
            c.actif = True
            eclats0 = c.eclats
            gagne = self.jouer(c)
            if sc["monnaie"] == "or":
                c.or_ += gagne
                c.revenu[self.jour % 7] += gagne
                self.semaine["entre"] += gagne
            gagne = self.vendre(c)
            if sc["monnaie"] == "or":
                c.or_ += gagne
                c.revenu[self.jour % 7] += gagne
            else:
                c.eclats += gagne
                c.revenu[self.jour % 7] += c.eclats - eclats0
            envie = self.acheter(c)
            if envie:
                acheteurs.setdefault(envie, []).append(c)
            self.depenser(c)
            self.plafonner(c)
        self.ferme()
        self.clore_marche(acheteurs)
        if self.jour % 7 == 0:
            self.fin_de_semaine()
            self.courbe()
        if self.jour % 30 == 0:
            self.instantane()

    # --- les mesures ---
    def revenu_jour(self, c):
        return sum(c.revenu) / 7.0

    def courbe(self):
        actifs = self.actifs()
        ors = [self.solde(c) for c in actifs]
        b = self.bilans[-1]
        self.courbes.append(dict(
            semaine=len(self.bilans), actifs=len(actifs), or_par_actif=(sum(ors) / len(ors)) if ors else 0,
            rare_11_20=self.prix[(1, "rare")], epique_21_30=self.prix[(2, "epique")], legendaire_21_30=self.prix[(2, "legendaire")],
            taux=self.taux, facteur=self.facteur_comptoir, puits=self.facteur_puits, entre=b["entre"], detruit=b["detruit"], ventes=b["ventes"], annonces=b["annonces"],
            invendu=b["invendu"], rmt=self.ferme_livre_semaine, achats_rmt=b["achats_rmt"], achats=b["achats"]))

    def instantane(self):
        actifs = self.actifs()
        ors = [self.solde(c) for c in actifs]
        vets = [self.solde(c) for c in actifs if c.age >= 90]
        debs = [self.solde(c) for c in actifs if c.age <= 14]
        # Ce qu'un joueur régulier gagne par jour dans chaque tranche (la semaine passée), pour lire les prix en jours de jeu.
        revenus = {}
        for t in range(len(TRANCHES)):
            rs = [self.revenu_jour(c) for c in actifs if tranche(c.niveau) == t and c.sorte == "regulier" and c.age >= 7]
            revenus[t] = (sum(rs) / len(rs)) if rs else 0.0
        def jours(t, r):
            rev = revenus[t]
            return self.prix[(t, r)] / rev if rev > 0 else float("inf")
        debutants = [c for c in actifs if c.age <= 14 and c.age >= 7]
        or_deb = statistics.median([self.solde(c) for c in debutants]) if debutants else 0
        semaines = self.bilans[-4:]
        ventes = sum(b["ventes"] for b in semaines)
        annonces = sum(b["annonces"] for b in semaines)
        invendu = sum(b["invendu"] for b in semaines)
        achats = sum(b["achats"] for b in semaines)
        achats_rmt = sum(b["achats_rmt"] for b in semaines)
        jours_bot = max(1, self.ferme_jours_bot)
        or_par_bot_jour = self.ferme_produit / float(jours_bot)
        prix_1000 = (1000.0 / or_par_bot_jour * COUT_BOT_PAR_JOUR * (self.nb_bots_payes / float(len(self.bots)))) if or_par_bot_jour > 0 else float("inf")
        or_5e = (5.0 / prix_1000 * 1000.0) if prix_1000 not in (0, float("inf")) else 0.0
        jours_5e = (or_5e / revenus[2]) if revenus[2] > 0 else float("inf")
        clients = [self.solde(c) for c in actifs if c.client and c.age >= 30]
        honnetes = [self.solde(c) for c in actifs if not c.client and c.sorte != "occasionnel" and c.age >= 30]
        avantage = (statistics.median(clients) / statistics.median(honnetes)) if clients and honnetes and statistics.median(honnetes) > 0 else 0.0
        crans_c = [c.objets_finis * 10 + c.cran for c in actifs if c.client and c.age >= 30]
        crans_h = [c.objets_finis * 10 + c.cran for c in actifs if not c.client and c.sorte != "occasionnel" and c.age >= 30]
        crans_clients = statistics.median(crans_c) if crans_c else 0
        crans_honnetes = statistics.median(crans_h) if crans_h else 0
        dernier = self.bilans[-1] if self.bilans else dict(entre=0, detruit=0)
        universel = self.prix["U"] if self.sc.get("universel", "marche") == "marche" else 0.0
        jours_universel = (universel / revenus[1]) if revenus[1] > 0 else float("inf")
        avant = [i for i in self.instantanes if i["jour"] == self.jour - 90]
        hausse_prix = ((self.prix[(2, "legendaire")] / avant[0]["prix"]["2_legendaire"]) - 1) if avant else 0.0
        hausse_or = (((sum(ors) / len(ors)) / avant[0]["or_par_actif"]) - 1) if avant and ors and avant[0]["or_par_actif"] > 0 else 0.0
        self.instantanes.append(dict(
            jour=self.jour, comptes=len(self.comptes), actifs=len(actifs), niveau_median=statistics.median(c.niveau for c in actifs) if actifs else 0,
            or_total=sum(ors), or_par_actif=(sum(ors) / len(ors)) if ors else 0, or_median=statistics.median(ors) if ors else 0,
            or_vets=statistics.median(vets) if vets else 0, or_debs=statistics.median(debs) if debs else 0, gini=gini(ors),
            prix={"%d_%s" % (t, r): self.prix[(t, r)] for t in range(len(TRANCHES)) for r in RARETES[2:]},
            jours={"%d_%s" % (t, r): jours(t, r) for t in range(len(TRANCHES)) for r in RARETES[2:]},
            revenus=revenus, or_debutant=or_deb, taux=self.taux, facteur=self.facteur_comptoir, puits=self.facteur_puits,
            ventes=ventes, annonces=annonces, invendu=invendu, part_vendue=(ventes / float(annonces)) if annonces else 0,
            achats_rmt=achats_rmt, achats=achats, rmt_semaine=self.ferme_livre_semaine, rmt_total=self.ferme_livre_total,
            or_par_bot_jour=or_par_bot_jour, prix_1000=prix_1000, bots=len(self.bots), jours_5e=jours_5e, avantage=avantage,
            universel=universel, jours_universel=jours_universel, hausse_prix=hausse_prix, hausse_or=hausse_or,
            crans_clients=crans_clients, crans_honnetes=crans_honnetes, entre=dernier["entre"], detruit=dernier["detruit"]))


def simuler(code, joueurs, jours, bots, graine):
    sc = SCENARIOS[code]
    m = Monde(sc, joueurs, jours, bots, graine)
    for _ in range(jours):
        m.journee()
    return m


def moyenne(valeurs):
    """La moyenne de dictionnaires de même forme (nombres, et dictionnaires de nombres) ; l'infini reste l'infini."""
    base = valeurs[0]
    if isinstance(base, dict):
        return {k: moyenne([v[k] for v in valeurs]) for k in base}
    if isinstance(base, bool) or isinstance(base, str):
        return base
    if any(v == float("inf") for v in valeurs):
        return float("inf")
    return sum(valeurs) / float(len(valeurs))


class Moyen(object):
    """Un monde moyen : les instantanés et les courbes moyennés sur plusieurs graines."""

    def __init__(self, mondes):
        self.sc = mondes[0].sc
        self.instantanes = [moyenne([m.instantanes[i] for m in mondes]) for i in range(len(mondes[0].instantanes))]
        self.courbes = [moyenne([m.courbes[i] for m in mondes]) for i in range(len(mondes[0].courbes))]


# --- le rapport ---
def nom_tranche(t):
    a, b = TRANCHES[t]
    return "%d–%d" % (a, b)


def j(x):
    if x == float("inf"):
        return "jamais"
    if x >= 365:
        return "%s ans" % f(x / 365.0)
    if x >= 60:
        return "%s mois" % f(x / 30.0)
    return "%s j" % f(x)


def rapport(mondes, joueurs, jours, bots, graines):
    L = ["# Les scénarios d'économie", "",
         "Généré par `tools/scenarios_economie.py` (la moyenne des graines %s) : %d comptes au départ, %d nouveaux par jour, %d jours ; une ferme de %d comptes bots ; "
         "les chiffres du jeu relus dans `data/` (prix plancher du Comptoir, fourchettes du Marché, taxe, amélioration, butin de la Tour, donjons, potions). "
         "Ne pas modifier à la main : changer le modèle ou les données, puis relancer l'outil. Le sens et la recommandation sont dans `docs/VISION.md` § 8." % (
             ", ".join(str(g) for g in graines), joueurs, max(1, joueurs // 200), jours, bots), "",
         "## Le modèle", "",
         "- **Les comptes** : trois sortes de joueurs (occasionnel : joue 4 jours sur 10, 3 combats ; régulier : 3 jours sur 4, 8 combats ; assidu : presque chaque jour, 18 combats), "
         "qui partent un jour (1,2 %, 0,5 %, 0,2 % de chance par jour) ; des nouveaux chaque jour. Le niveau monte avec les combats (le niveau 30 vers 200 combats : un à deux mois pour un régulier ; puis quarante combats par niveau). "
         "2 % des réguliers et des assidus sont prêts à acheter de l'Or à un revendeur.",
         "- **La Tour** : jusqu'à trois étages neufs par jour (premier passage : un objet échangeable sept fois sur dix, du commun ou du peu commun ; peu commun au Gardien, rare possible au grand Gardien), "
         "puis des étages rejoués (des objets liés, recyclés en Éclats). **Les donjons** : quatre combats par descente, l'entrée en Éclats, un épique à l'élite (échangeable une fois sur quatre, lié sinon), un légendaire échangeable au boss (une descente sur trente).",
         "- **L'équipement** : huit emplacements ; un joueur porte ce qui vaut mieux que son pire emplacement (l'objet est alors lié) et vend le reste ; il n'achète que mieux que son pire emplacement. Quand il change de tranche de niveau, tout est à refaire.",
         "- **L'hôtel des ventes** : les communs et les peu communs vont au Comptoir (le prix plancher du jeu : c'est là que l'Or naît) ; les rares, les épiques et les légendaires sont mis en vente. "
         "Pour chaque tranche de niveau et chaque rareté, un prix courant : il monte de 10 % au plus par jour quand les acheteurs sont plus nombreux que les annonces, baisse sinon, dans la fourchette du jeu quand elle existe. "
         "Un joueur achète au plus un objet par jour, le meilleur de sa tranche qu'il peut se payer (un occasionnel y met la moitié de son Or, un assidu les quatre cinquièmes). "
         "L'invendu de plus de sept jours part au Comptoir. Quand un joueur change de tranche, ses objets ne lui servent plus et il rachète.",
         "- **L'objet que tout le monde veut** (une tenue rare, un objet de remise à zéro du Destin) : il tombe une fois tous les cent cinquante combats, à tout niveau ; chacun en veut un par semaine. Vendu entre joueurs (A à E) ou par le jeu (F, G : la trouvaille vaut des Éclats). C'est lui que les vétérans rendent inabordable dans les RPG classiques.",
         "- **Les puits** : l'amélioration +1 à +10 (les chiffres de `items.json` ; un échec fait perdre un cran ; tentée dès que l'Or dépasse une marge sur le coût), les potions d'énergie des assidus, "
         "des cosmétiques en Or (une tenue quand on a quatre fois son prix, tous les quinze jours au plus), la taxe du Marché.",
         "- **La ferme de bots** : des comptes qui jouent 60 combats par jour, moins bien que l'IA (ils montent à 60 %% de la vitesse), vendent tout ce qu'ils peuvent, "
         "et sont remplacés au niveau 30 quand il n'y a plus de premier passage à vendre. Leur monnaie (de l'Or, ou des Éclats en E) est livrée chaque semaine aux clients : par échange direct en RPG classique ; "
         "sinon par une annonce du client au plus haut de sa fourchette, achetée par la ferme (la taxe est détruite ; un client ne peut pas recevoir plus que ses annonces ne permettent, ni dépasser son plafond). "
         "Un compte bot coûte %s € par jour au revendeur : son prix de revient se lit sur ce que ses comptes produisent (ce qu'il livre est borné par ce que les clients veulent)." % f(COUT_BOT_PAR_JOUR, 2),
         ""]
    L.append("## Les scénarios")
    L.append("")
    for code, m in mondes:
        L.append("- **%s. %s** : %s." % (code, m.sc["nom"], m.sc["texte"]))
    L.append("")
    L.append("## Le tableau comparé (au jour %d)" % jours)
    L.append("")
    L.append("| Mesure | " + " | ".join("%s" % code for code, m in mondes) + " |")
    L.append("| --- | " + " | ".join("---" for _ in mondes) + " |")
    def ligne(nom, fn):
        L.append("| %s | " % nom + " | ".join(fn(m.instantanes[-1], m) for code, m in mondes) + " |")
    u = lambda m: "Éclats" if m.sc["monnaie"] == "eclats" else "Or"
    ligne("Comptes actifs (niveau médian)", lambda i, m: "%d (%s)" % (i["actifs"], f(i["niveau_median"])))
    ligne("Monnaie par joueur actif", lambda i, m: "%s %s" % (f(i["or_par_actif"], 0), u(m)))
    ligne("Monnaie médiane : vétérans (90 j et plus) / débutants (14 j au plus)", lambda i, m: "%s / %s" % (f(i["or_vets"], 0), f(i["or_debs"], 0)))
    ligne("Indice de Gini de la monnaie (0 = égal, 1 = un seul riche)", lambda i, m: f(i["gini"], 2))
    ligne("Prix d'un rare de niveau 11–20", lambda i, m: "%s %s" % (f(i["prix"]["1_rare"], 0), u(m)))
    ligne("… en jours de jeu d'un régulier de ce niveau", lambda i, m: j(i["jours"]["1_rare"]))
    ligne("Prix d'un épique de niveau 21–30", lambda i, m: "%s %s" % (f(i["prix"]["2_epique"], 0), u(m)))
    ligne("… en jours de jeu d'un régulier de ce niveau", lambda i, m: j(i["jours"]["2_epique"]))
    ligne("Prix d'un légendaire de niveau 21–30", lambda i, m: "%s %s" % (f(i["prix"]["2_legendaire"], 0), u(m)))
    ligne("… en jours de jeu d'un régulier de ce niveau", lambda i, m: j(i["jours"]["2_legendaire"]))
    ligne("Prix de l'objet que tout le monde veut (tenue rare)", lambda i, m: ("%s %s" % (f(i["universel"], 0), u(m))) if i["universel"] else "vendu par le jeu")
    ligne("… en jours de jeu d'un régulier de niveau 11–20", lambda i, m: j(i["jours_universel"]) if i["universel"] else "sans objet")
    ligne("Hausse des prix sur les trois derniers mois (légendaire 21–30)", lambda i, m: ("+" if i["hausse_prix"] >= 0 else "") + f(i["hausse_prix"] * 100, 0) + " %")
    ligne("Hausse de la monnaie par joueur actif sur trois mois", lambda i, m: ("+" if i["hausse_or"] >= 0 else "") + f(i["hausse_or"] * 100, 0) + " %")
    ligne("Part des annonces vendues (quatre dernières semaines)", lambda i, m: f(i["part_vendue"] * 100, 0) + " %")
    ligne("Taxe de la semaine / facteur du Comptoir / facteur des puits", lambda i, m: "%s %% / × %s / × %s" % (f(i["taux"] * 100, 0), f(i["facteur"], 2), f(i["puits"], 2)))
    ligne("Monnaie créée / détruite la dernière semaine", lambda i, m: "%s / %s" % (f(i["entre"], 0), f(i["detruit"], 0)))
    ligne("Monnaie livrée par le revendeur la dernière semaine", lambda i, m: "%s %s" % (f(i["rmt_semaine"], 0), u(m)))
    ligne("Monnaie produite par compte bot et par jour", lambda i, m: "%s %s" % (f(i["or_par_bot_jour"], 1), u(m)))
    ligne("Prix de revient de 1 000 unités pour le revendeur", lambda i, m: ("%s €" % f(i["prix_1000"], 2)) if i["prix_1000"] != float("inf") else "jamais")
    ligne("Ce que 5 € achetés au revendeur valent, en jours de jeu d'un régulier de niveau 21–30", lambda i, m: j(i["jours_5e"]))
    ligne("Monnaie médiane des clients du revendeur / des honnêtes (réguliers et assidus)", lambda i, m: "× " + f(i["avantage"], 1))
    ligne("Part des achats du Marché faits par des clients du revendeur", lambda i, m: (f(100.0 * i["achats_rmt"] / i["achats"], 1) + " %") if i["achats"] else "0 %")
    ligne("Crans d'amélioration (médiane) : clients du revendeur / honnêtes", lambda i, m: "%s / %s" % (f(i["crans_clients"], 0), f(i["crans_honnetes"], 0)))
    L.append("")
    for code, m in mondes:
        L.append("## %s. %s" % (code, m.sc["nom"]))
        L.append("")
        L.append("| Jour | Actifs | Niveau médian | %s par actif | Vétérans / débutants | Gini | Rare 11–20 | Légendaire 21–30 | Tenue rare | Annonces vendues | Taxe | Comptoir × | Puits × | Or livré / sem. |" % u(m))
        L.append("| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |")
        for i in m.instantanes:
            L.append("| %d | %d | %s | %s | %s / %s | %s | %s (%s) | %s (%s) | %s | %s | %s | %s | %s | %s |" % (
                i["jour"], i["actifs"], f(i["niveau_median"]), f(i["or_par_actif"], 0), f(i["or_vets"], 0), f(i["or_debs"], 0), f(i["gini"], 2),
                f(i["prix"]["1_rare"], 0), j(i["jours"]["1_rare"]),
                f(i["prix"]["2_legendaire"], 0), j(i["jours"]["2_legendaire"]), ("%s (%s)" % (f(i["universel"], 0), j(i["jours_universel"]))) if i["universel"] else "par le jeu",
                f(i["part_vendue"] * 100, 0) + " %", f(i["taux"] * 100, 0) + " %", f(i["facteur"], 2), f(i["puits"], 2), f(i["rmt_semaine"], 0)))
        L.append("")
    return "\n".join(L) + "\n"


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--joueurs", type=int, default=3000)
    parser.add_argument("--jours", type=int, default=180)
    parser.add_argument("--bots", type=int, default=300)
    parser.add_argument("--graines", default="1,2,3")
    parser.add_argument("--scenarios", default=",".join(SCENARIOS))
    parser.add_argument("--sortie", default=os.path.join(ROOT, "docs"))
    args = parser.parse_args()
    mondes = []
    graines = [int(g) for g in args.graines.split(",")]
    for code in args.scenarios.split(","):
        m = Moyen([simuler(code, args.joueurs, args.jours, args.bots, g) for g in graines])
        mondes.append((code, m))
        i = m.instantanes[-1]
        print("%s %-40s actifs %5d  or/actif %8.0f  vets/debs %6.0f/%5.0f  gini %.2f  rare11-20 %6.0f  leg21-30 %8.0f  vendu %3.0f%%  taxe %2.0f%%  rmt/sem %7.0f" % (
            code, m.sc["nom"], i["actifs"], i["or_par_actif"], i["or_vets"], i["or_debs"], i["gini"], i["prix"]["1_rare"], i["prix"]["2_legendaire"],
            i["part_vendue"] * 100, i["taux"] * 100, i["rmt_semaine"]))
    texte = rapport(mondes, args.joueurs, args.jours, args.bots, graines)
    io.open(os.path.join(args.sortie, "ECONOMIE-SCENARIOS.md"), "w", encoding="utf-8", newline="\n").write(texte)
    donnees = {code: dict(nom=m.sc["nom"], texte=m.sc["texte"], monnaie=m.sc["monnaie"], courbes=m.courbes, instantanes=m.instantanes) for code, m in mondes}
    io.open(os.path.join(args.sortie, "economie_scenarios.json"), "w", encoding="utf-8", newline="\n").write(json.dumps(donnees, ensure_ascii=False, indent=None))


if __name__ == "__main__":
    sys.stdout.reconfigure(encoding="utf-8")
    main()
