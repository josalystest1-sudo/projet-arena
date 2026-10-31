"""Les passes de réglage du combat V2 : mesurer, puis toucher les boutons (docs/SPEC-COMBAT-V2.md, section 11.3), dans
l'ordre, avec les décisions de Gautier du 28 octobre (docs/JOURNAL-COMBAT-V2.md) :
  - la durée : on vise une médiane de 20 tours (décision du 29 octobre, qui remplace « 10 tours » du 28) ; les PV de
    toutes les classes montent ou baissent ensemble, la mort subite reste au tour fixé dans data/rules.json ; chaque
    classe garde ensuite son propre bouton de PV à ±10 % ;
  - la route Éventail doit seulement ne pas dépasser 55 % ;
  - la Tour n'est plus réglée ici (phase 9 : elle est absolue, sa courbe se règle avec tools/regleur_tour.py).
Depuis la phase 9, les passes se font en trio (tools/regleur.py --format) : le k d'une classe change le trio qu'elle
mène et ceux où elle est l'Écho d'une autre, comme l'acolyte du duo ; le Jacobien s'en charge.
Chaque passe ajoute son rapport à docs/EQUILIBRAGE-V2.md. Lancé par tools/regleur.py passes <nombre>.
"""
import json
import math
import os

import regleur

DATA = regleur.DATA
ETAT = os.path.join(DATA, "..", "tools", "regleur_etat.json")

# Les chiffres de la spécification (sections 7.2, 7.3, 7.5), pour les bornes des boutons.
PV_SPEC = {"guerrier": 1400, "pugiliste": 1200, "voleur": 1000, "diplomate": 1000, "pretre": 950, "alchimiste": 950,
           "barde": 950, "mage": 900, "archer": 900, "invocateur": 900}
BUDGETS = {1: 70, 2: 100, 3: 140, 4: 230}
COUTS_ETATS = {"etourdi": 120, "gele": 80, "aveugle": 70, "desarme": 60, "egare": 60, "silencie": 45, "provoque": 40, "enracine": 35}
K_MIN, K_MAX = 0.75, 1.20
## Les PV de toutes les classes (en part des PV de la spécification), pour une médiane de 20 tours (consigne de
## Gautier du 29 octobre : « on peut viser 20 tours ») : entre ces bornes, la fourchette de la médiane étant celle de
## tools/equilibrage_lib.gd (18 à 22 tours).
PV_GLOBAL_MIN = 0.30
PV_GLOBAL_MAX = 1.50
MEDIANE_CIBLE = 20
PV_CLASSE = 0.10
BUDGET_ECART = 0.10
VALEURS = {"degats": "valeur", "soin": "valeur", "barriere": "valeur", "dot": "par_tour", "gardien": "par_tour",
           "renfort": "pourcent", "affaiblissement": "pourcent"}


def dump(v, ind=0):
    """Le format des fichiers de classes : un effet par ligne."""
    pad = "  " * ind
    if isinstance(v, dict):
        if all(not isinstance(x, (dict, list)) for x in v.values()):
            return json.dumps(v, ensure_ascii=False)
        items = [pad + "  " + json.dumps(k, ensure_ascii=False) + ": " + dump(x, ind + 1) for k, x in v.items()]
        return "{\n" + ",\n".join(items) + "\n" + pad + "}"
    if isinstance(v, list):
        if all(not isinstance(x, (dict, list)) for x in v):
            return json.dumps(v, ensure_ascii=False)
        items = [pad + "  " + dump(x, ind + 1) for x in v]
        return "[\n" + ",\n".join(items) + "\n" + pad + "]"
    return json.dumps(v, ensure_ascii=False)


def lire_classe(c):
    return regleur.lire(os.path.join(DATA, "classes", c + ".json"))


def ecrire_classe(c, d):
    with open(os.path.join(DATA, "classes", c + ".json"), "w", encoding="utf-8", newline="\n") as f:
        f.write(dump(d) + "\n")


def ecrire_json(nom, d, compact=False):
    with open(os.path.join(DATA, nom), "w", encoding="utf-8", newline="\n") as f:
        f.write((dump(d) if compact else json.dumps(d, ensure_ascii=False, indent=2)) + "\n")


def cout_effet(regles, ef):
    couts = regles["couts"]
    t = ef["type"]
    if t in ("degats", "soin", "barriere"):
        base = ef["valeur"] * couts[t]
    elif t in ("dot", "gardien"):
        base = ef["par_tour"] * ef["tours"] * couts[t]
    elif t in ("renfort", "affaiblissement"):
        base = ef["pourcent"] * couts[t]
    elif t == "etat":
        base = couts[ef["nom"]] * ef["tours"]
    else:
        base = couts[t]
    if ef["cible"] in ("tous_les_ennemis", "duo"):
        return regles.get("couts_multi", {}).get(t, base * regles["multi_cible"])
    return base


def recaler(regles, noeud, budget):
    """Remet les valeurs du nœud à l'échelle pour que son coût tombe sur ce budget (les états ne bougent pas)."""
    fixe = sum(cout_effet(regles, ef) for ef in noeud["effets"] if ef["type"] not in VALEURS)
    variable = sum(cout_effet(regles, ef) for ef in noeud["effets"] if ef["type"] in VALEURS)
    if variable <= 0 or budget - fixe <= 0:
        return False
    f = (budget - fixe) / variable
    for ef in noeud["effets"]:
        if ef["type"] in VALEURS:
            k = VALEURS[ef["type"]]
            ef[k] = round(ef[k] * f, 2)
    return True


def changer_budget(regles, noeud, facteur):
    """Le bouton 2 : le budget d'un nœud, ×facteur, dans ±10 % du budget de son rang. Rend le nouveau budget, ou None."""
    rang = noeud["rang"]
    actuel = noeud.get("budget_override", BUDGETS[rang])
    nouveau = round(min(max(actuel * facteur, BUDGETS[rang] * (1 - BUDGET_ECART)), BUDGETS[rang] * (1 + BUDGET_ECART)), 1)
    if abs(nouveau - actuel) < 0.05:
        return None
    sauve = json.loads(json.dumps(noeud))
    if not recaler(regles, noeud, nouveau):
        noeud.clear()
        noeud.update(sauve)
        return None
    if abs(nouveau - BUDGETS[rang]) < 0.05:
        noeud.pop("budget_override", None)
    else:
        noeud["budget_override"] = nouveau
    return nouveau


def part_cout(regles, voie, types):
    total = 0.0
    part = 0.0
    for n in voie["noeuds"]:
        for ef in n["effets"]:
            c = cout_effet(regles, ef)
            total += c
            if ef["type"] in types:
                part += c
    return part / total if total > 0 else 0.0


DEFENSE = ("soin", "barriere", "gardien", "purge")
ATTAQUE = ("degats", "dot")


def resserrer_duels(resume, classes, regles, ordre):
    """Bouton 2, pour les cases de la matrice hors de 40 – 60 % : une classe qui perd trop contre des classes qui frappent
    fort et gagne trop contre des classes qui durent reçoit un peu plus dans ses voies défensives et un peu moins dans
    ses voies offensives (et l'inverse), ±3 % par passe, dans ±10 % du budget de chaque rang."""
    boutons = []
    attaque = {c: sum(part_cout(regles, v, ATTAQUE) for v in classes[c]["voies"]) / 5.0 for c in ordre}
    taux = {(x["a"], x["b"]): x["taux"] for x in resume["cases"]}
    for a in ordre:
        bas = [b for b in ordre if taux.get((a, b), 0.5) < 0.42]
        haut = [b for b in ordre if taux.get((a, b), 0.5) > 0.58]
        # Seulement un vrai écart entre duels (trop bas contre les uns ET trop haut contre les autres) : une classe
        # simplement trop forte ou trop faible partout, c'est le travail de son multiplicateur (bouton 1).
        if not bas or not haut:
            continue
        m_bas = sum(attaque[b] for b in bas) / len(bas)
        m_haut = sum(attaque[b] for b in haut) / len(haut)
        if abs(m_bas - m_haut) < 0.06:
            continue
        # Perd contre ceux qui frappent : plus de défense ; perd contre ceux qui durent : plus d'attaque.
        plus, moins = (DEFENSE, ATTAQUE) if m_bas > m_haut else (ATTAQUE, DEFENSE)
        touchees = []
        for voie in classes[a]["voies"]:
            if part_cout(regles, voie, plus) >= 0.5:
                if any(changer_budget(regles, n, 1.03) is not None for n in voie["noeuds"]):
                    touchees.append(voie["nom"] + " +3 %")
            elif part_cout(regles, voie, moins) >= 0.5:
                if any(changer_budget(regles, n, 0.97) is not None for n in voie["noeuds"]):
                    touchees.append(voie["nom"] + " -3 %")
        if touchees:
            boutons.append("duels de %s (trop bas contre %s ; trop haut contre %s) : %s" % (
                classes[a]["nom"], ", ".join(classes[b]["nom"] for b in bas) or "personne", ", ".join(classes[b]["nom"] for b in haut) or "personne", ", ".join(touchees)))
    return boutons


## La classe d'un acolyte est fixe (section 3.2) : le k d'une classe change le duo qu'elle mène et celui dont elle est
## l'acolyte (baisser le Mage, acolyte du Prêtre, affaiblissait surtout le duo du Prêtre, et le régleur montait le
## Prêtre, acolyte du Guerrier…). Le Jacobien (le taux de chaque classe selon le k de chaque classe) est mesuré à
## graines égales, k par k, puis les pas de toutes les classes sont résolus ensemble.
JACOBIEN_PERTURBATION = 0.06
JACOBIEN_AGE = 4
JACOBIEN_MATRICE = 300
JACOBIEN_AMORTI = 0.5
JACOBIEN_PAS_MAX = 0.06
JACOBIEN_RIDGE = 0.1
## Le poids d'un duel au-delà de 58 % face à celui de la moyenne d'une classe (qui a de la marge entre 47 et 53 %).
JACOBIEN_POIDS_DUEL = 1.5


def mesurer_jacobien(etat, graine):
    ordre = regleur.lire(os.path.join(DATA, "classes.json"))
    base, _ = regleur.mesurer(JACOBIEN_MATRICE, 0, 0, graine, "jacobien")
    colonnes = []
    paires = []
    for c in ordre:
        d = lire_classe(c)
        ancien = d["k"]
        d["k"] = round(ancien * (1 + JACOBIEN_PERTURBATION), 4)
        ecrire_classe(c, d)
        try:
            r, _ = regleur.mesurer(JACOBIEN_MATRICE, 0, 0, graine, "jacobien " + c)
        finally:
            d["k"] = ancien
            ecrire_classe(c, d)
        dlog = math.log(round(ancien * (1 + JACOBIEN_PERTURBATION), 4) / ancien)
        colonnes.append([(r["classes"][i]["taux"] - base["classes"][i]["taux"]) / dlog for i in ordre])
        paires.append({"%s|%s" % (a, b): (_duel(r, a, b) - _duel(base, a, b)) / dlog for a in ordre for b in ordre if a < b})
    # J[i][j] : la variation du taux de la classe i quand le log du k de la classe j monte de 1 ; P[paire][j] : celle
    # du duel de la paire (la première classe contre la seconde, ses deux cases moyennées).
    etat["jacobien"] = {"ordre": ordre, "passe": etat.get("passes", 0),
                        "J": [[round(colonnes[j][i], 4) for j in range(len(ordre))] for i in range(len(ordre))],
                        "P": {cle: [round(paires[j][cle], 4) for j in range(len(ordre))] for cle in paires[0]}}
    for i, c in enumerate(ordre):
        print("jacobien %-10s %s" % (c, " ".join("%+5.2f" % x for x in etat["jacobien"]["J"][i])))


def pas_jacobien(jac, resume, ordre, ks=None):
    """Les pas relatifs de k qui ramènent toutes les classes à 50 % ensemble (moindres carrés, un peu de ridge pour la
    direction sans effet où tous les k montent ensemble), amortis et bornés. Un duel au-delà de 58 % (ses deux cases
    moyennées) compte aussi, ramené vers 57 % : aucune voie n'a d'effet propre sur un duel (essais des passes 55 et
    56), mais il dépend des k des quatre persos en jeu, acolytes compris, autrement que les moyennes des classes."""
    import numpy as np
    stats = resume["classes"]
    lignes = [list(x) for x in jac["J"]]
    r = [0.5 - stats[c]["taux"] for c in ordre]
    # Les duels ne comptent qu'une fois toutes les classes entre 47 et 53 % : leurs effets, mesurés sur 300 combats par
    # case, sont bruités, et ils retenaient le pas d'une classe très en dessous (passe 86 : le Diplomate, à 44,7 %,
    # n'aurait gagné qu'un point et demi).
    duels = jac.get("P", {}) if max(abs(stats[c]["taux"] - 0.5) for c in ordre) <= 0.03 else {}
    for cle, ligne in duels.items():
        a, b = cle.split("|")
        t = _duel(resume, a, b)
        if abs(t - 0.5) > DUEL_SEUIL - 0.02:
            lignes.append([JACOBIEN_POIDS_DUEL * x for x in ligne])
            r.append(JACOBIEN_POIDS_DUEL * (0.5 + math.copysign(DUEL_CIBLE, t - 0.5) - t))
    J = np.array(lignes)
    r = np.array(r)
    dx = np.linalg.solve(J.T @ J + JACOBIEN_RIDGE * np.eye(len(ordre)), J.T @ r) * JACOBIEN_AMORTI
    # Monter tous les k ensemble ne change aucun taux (seulement la durée et la Tour) : la moyenne des pas reste nulle.
    dx = dx - dx.mean()
    dx = np.clip(dx, -JACOBIEN_PAS_MAX, JACOBIEN_PAS_MAX)
    # Une classe à sa borne de k ne peut pas suivre son pas : comme monter tous les k ensemble ne change aucun taux, ce
    # qu'elle ne peut pas faire, toutes les classes le font dans l'autre sens (passes 71 à 86 : le Diplomate, à 1,20,
    # restait à 45 %, les autres ne baissant que de sa part de la moyenne).
    if ks:
        lk = np.array([math.log(ks[c]) for c in ordre])
        haut = max(0.0, float(np.max(lk + dx - math.log(K_MAX))))
        bas = max(0.0, float(np.max(math.log(K_MIN) - (lk + dx))))
        dx = dx - haut + bas
    return {c: float(math.exp(dx[i]) - 1) for i, c in enumerate(ordre)}


## Le bouton 2 pour un duel de la matrice qui reste hors de 40 – 60 % deux passes de suite : chaque voie des deux
## classes, à son tour, est affaiblie (celle qui gagne trop) ou renforcée (celle qui perd), et le duel remesuré à graines
## égales. On garde la voie dont l'effet sur ce duel est le plus propre (ce qui reste une fois les moyennes des deux
## classes ramenées par leur k), et on la change d'autant qu'il faut pour revenir à 57 %, dans les ±10 % du budget.
DUEL_PERTURBATION = 0.08
DUEL_MATRICE = 300
DUEL_CIBLE = 0.07
DUEL_SEUIL = 0.10
DUEL_MOYENNE_MAX = 0.03


def paires_hors(resume, seuil=DUEL_SEUIL):
    """Les duels hors de 50 ± seuil, une fois par paire de classes (les deux cases de la paire moyennées) : {"a>b": taux}."""
    cases = {(x["a"], x["b"]): x["taux"] for x in resume["cases"]}
    hors = {}
    for (a, b), t in cases.items():
        if a >= b or (b, a) not in cases:
            continue
        m = (t + 1.0 - cases[(b, a)]) / 2.0
        if abs(m - 0.5) > seuil:
            hors["%s>%s" % (a, b) if m > 0.5 else "%s>%s" % (b, a)] = m if m > 0.5 else 1.0 - m
    return hors


def _duel(r, a, b):
    cases = {(x["a"], x["b"]): x["taux"] for x in r["cases"]}
    return (cases[(a, b)] + 1.0 - cases[(b, a)]) / 2.0


def duel_mesure(etat, regles, fort, faible, taux, graine):
    """fort gagne trop contre faible ; rend le texte du bouton touché, ou None."""
    base, _ = regleur.mesurer(DUEL_MATRICE, 0, 0, graine, "duel")
    t0 = _duel(base, fort, faible)
    meilleur = None
    for c, facteur in ((fort, 1 - DUEL_PERTURBATION), (faible, 1 + DUEL_PERTURBATION)):
        for v in range(5):
            p = os.path.join(DATA, "classes", c + ".json")
            sauve = open(p, encoding="utf-8").read()
            d = lire_classe(c)
            if all(changer_budget(regles, n, facteur) is None for n in d["voies"][v]["noeuds"]):
                continue
            ecrire_classe(c, d)
            try:
                r, _ = regleur.mesurer(DUEL_MATRICE, 0, 0, graine, "duel %s %d" % (c, v))
            finally:
                with open(p, "w", encoding="utf-8", newline="\n") as f:
                    f.write(sauve)
            dt = _duel(r, fort, faible) - t0
            dfort = r["classes"][fort]["taux"] - base["classes"][fort]["taux"]
            dfaible = r["classes"][faible]["taux"] - base["classes"][faible]["taux"]
            propre = -(dt - dfort + dfaible)
            print("duel %s>%s : %s voie %d : duel %+.3f, moyennes %+.3f %+.3f, propre %+.3f" % (fort, faible, c, v + 1, dt, dfort, dfaible, propre), flush=True)
            # Une voie qui aggrave directement le duel, ou qui déplace beaucoup la moyenne d'une des deux classes (l'IA la
            # joue alors bien plus ou bien moins), n'est pas retenue : son effet « propre » ne viendrait que des k.
            if dt > 0.005 or abs(dfort) > DUEL_MOYENNE_MAX or abs(dfaible) > DUEL_MOYENNE_MAX:
                continue
            if meilleur is None or propre > meilleur[0]:
                meilleur = (propre, c, v, facteur)
    if meilleur is None or meilleur[0] < 0.01:
        return "duel %s contre %s (%s) : aucune voie n'y change rien à elle seule (le plus propre : %s)" % (
            lire_classe(fort)["nom"], lire_classe(faible)["nom"], pc(taux), pc(meilleur[0]) if meilleur else "rien")
    propre, c, v, facteur = meilleur
    besoin = (taux - 0.5 - DUEL_CIBLE) / propre
    f = 1 + (facteur - 1) * min(2.0, max(0.5, besoin))
    d = lire_classe(c)
    faits = [changer_budget(regles, n, f) for n in d["voies"][v]["noeuds"]]
    ecrire_classe(c, d)
    if all(x is None for x in faits):
        return None
    return "duel %s contre %s (%s) : budgets de la %s (%s) %+d %% (effet propre mesuré : %s pour %d %%)" % (
        lire_classe(fort)["nom"], lire_classe(faible)["nom"], pc(taux), d["voies"][v]["nom"], d["nom"], round(100 * (f - 1)), pc(propre), round(100 * DUEL_PERTURBATION))


def lire_etat():
    if os.path.exists(ETAT):
        return regleur.lire(ETAT)
    return {"pv_global": 1.0, "pv_classe": {}, "gains": {}, "signes": {}}


def ecrire_etat(etat):
    with open(ETAT, "w", encoding="utf-8", newline="\n") as f:
        json.dump(etat, f, ensure_ascii=False, indent=2)


def amorti(etat, cle, ecart, gain):
    """Un pas proportionnel à l'écart ; divisé par deux chaque fois que l'écart change de sens (sinon il oscille)."""
    g = etat["gains"].get(cle, gain)
    signe = 1 if ecart > 0 else -1
    if etat["signes"].get(cle, signe) != signe:
        g *= 0.5
    etat["gains"][cle] = max(g, gain * 0.125)
    etat["signes"][cle] = signe
    return g * ecart


def pc(x):
    return ("%.1f %%" % (100 * x)).replace(".", ",")


def appliquer(resume, etat):
    """Les boutons, dans l'ordre ; rend la liste des changements, en clair."""
    boutons = []
    regles = regleur.lire(os.path.join(DATA, "rules.json"))
    ordre = regleur.lire(os.path.join(DATA, "classes.json"))
    stats = resume["classes"]
    classes = {c: lire_classe(c) for c in ordre}

    # La durée (décision de Gautier du 29 octobre : on vise 20 tours) : les PV de toutes les classes ensemble.
    med = resume["mediane"]
    if med > MEDIANE_CIBLE + 1 or resume["avant_limite"] < 0.95:
        facteur = max(0.92, min(0.97, MEDIANE_CIBLE / max(med, 1)))
    elif med < MEDIANE_CIBLE - 1:
        facteur = max(1.03, min(1.08, MEDIANE_CIBLE / max(med, 1)))
    else:
        facteur = 1.0
    if facteur != 1.0:
        ancien = etat["pv_global"]
        etat["pv_global"] = round(min(PV_GLOBAL_MAX, max(PV_GLOBAL_MIN, ancien * facteur)), 4)
        if etat["pv_global"] != ancien:
            boutons.append("PV de toutes les classes : ×%s → ×%s des PV de la spécification (médiane %d tours, %s finis avant le tour 30 ; on vise 20 tours)"
                           % (("%.3f" % ancien).replace(".", ","), ("%.3f" % etat["pv_global"]).replace(".", ","), med, pc(resume["avant_limite"])))

    # Bouton 1 : k_classe, selon le taux de victoire de la classe ; avec le Jacobien, tous les pas ensemble.
    jac = etat.get("jacobien")
    pas_k = pas_jacobien(jac, resume, ordre, {c: classes[c]["k"] for c in ordre}) if jac and jac["ordre"] == ordre else None
    if pas_k is not None:
        boutons.append("pas des k calculés ensemble : le k d'une classe change aussi le duo dont elle est l'acolyte ; les duels au-delà de 58 %% comptent aussi (effets mesurés à graines égales avant la passe %d)" % (jac["passe"] + 1))
    for c in ordre:
        wr = stats[c]["taux"]
        if pas_k is not None:
            # Tous les pas ensemble : une classe déjà à 50 % bouge aussi si les autres en ont besoin.
            pas = pas_k[c]
        elif abs(wr - 0.5) < 0.008:
            continue
        else:
            pas = amorti(etat, "k:" + c, 0.5 - wr, 0.35)
            pas = max(-0.03, min(0.03, pas))
        ancien = classes[c]["k"]
        nouveau = round(min(K_MAX, max(K_MIN, ancien * (1 + pas))), 4)
        if abs(nouveau - ancien) >= 0.0005:
            classes[c]["k"] = nouveau
            boutons.append("k_classe %s : %s → %s (%s de victoires)" % (classes[c]["nom"], ("%.3f" % ancien).replace(".", ","), ("%.3f" % nouveau).replace(".", ","), pc(wr)))

    # Bouton 2 : le budget de nœuds précis (voies trop peu jouées, routes hors de leur fourchette, Clés trop rares).
    for c in ordre:
        s = stats[c]
        for v in range(5):
            if s["voies"][v] < 0.17:
                faits = [changer_budget(regles, n, 1.03) for n in classes[c]["voies"][v]["noeuds"]]
                if any(x is not None for x in faits):
                    boutons.append("budgets de la %s (%s) : +3 %% (jouée dans %s des combats)" % (classes[c]["voies"][v]["nom"], classes[c]["nom"], pc(s["voies"][v])))
                if faits[0] is None:
                    # Son premier nœud ne fait que poser un état : son budget ne peut pas monter. Ce sont les premiers
                    # nœuds des autres voies de la classe qui baissent un peu, pour qu'il soit choisi plus souvent.
                    autres = [changer_budget(regles, classes[c]["voies"][w]["noeuds"][0], 0.97) for w in range(5) if w != v and s["voies"][w] >= 0.17]
                    if any(x is not None for x in autres):
                        boutons.append("budgets des premiers nœuds des autres voies (%s) : -3 %% (la %s, jouée dans %s des combats, commence par un état seul)" % (classes[c]["nom"], classes[c]["voies"][v]["nom"], pc(s["voies"][v])))
        if s["cle"] < 0.62:
            faits = [changer_budget(regles, voie["noeuds"][3], 1.03) for voie in classes[c]["voies"]]
            if any(x is not None for x in faits):
                boutons.append("budgets des Clés (%s) : +3 %% (une Clé jouée dans %s des combats)" % (classes[c]["nom"], pc(s["cle"])))
    if etat.get("duels", False):
        boutons.extend(resserrer_duels(resume, classes, regles, ordre))

    # Bouton 4 : les PV de chaque classe, ±10 % autour de ceux de toutes les classes, quand son k est déjà à sa borne.
    for c in ordre:
        wr = stats[c]["taux"]
        k = classes[c]["k"]
        if (k >= K_MAX - 0.001 and wr < 0.485) or (k <= K_MIN + 0.001 and wr > 0.515):
            ancien = etat["pv_classe"].get(c, 1.0)
            nouveau = round(min(1 + PV_CLASSE, max(1 - PV_CLASSE, ancien * (1.03 if wr < 0.5 else 0.97))), 4)
            if nouveau != ancien:
                etat["pv_classe"][c] = nouveau
                boutons.append("PV du %s : ×%s → ×%s (k déjà à sa borne, %s de victoires)" % (classes[c]["nom"], ("%.2f" % ancien).replace(".", ","), ("%.2f" % nouveau).replace(".", ","), pc(wr)))
    for c in ordre:
        propre = etat["pv_classe"].get(c, 1.0)
        classes[c]["pv"] = int(round(PV_SPEC[c] * etat["pv_global"] * propre))
        ecrire_classe(c, classes[c])
    return boutons


def score(resume):
    """Plus c'est bas, mieux c'est : les critères manqués, puis la somme des écarts aux fourchettes."""
    ecart = 0.0
    for c in resume["classes"].values():
        ecart += max(0.0, abs(c["taux"] - 0.5) - 0.03) * 4
    for x in resume["cases"]:
        ecart += max(0.0, abs(x["taux"] - 0.5) - 0.10)
    ecart += max(0, abs(resume["mediane"] - MEDIANE_CIBLE) - 2) * 0.5
    # Le critère 6 (la Tour) ne compte pas : la Tour est absolue et se règle à part (tools/regleur_tour.py).
    return sum(1 for c in resume["criteres"] if not c["ok"] and not c["titre"].startswith("6.")) + ecart


def sauver_donnees(dossier):
    regleur.shutil.rmtree(dossier, ignore_errors=True)
    regleur.shutil.copytree(DATA, dossier)


def passes(nombre, args):
    etat = lire_etat()
    copies = os.path.join(regleur.tempfile.gettempdir(), "reglage-v2")
    os.makedirs(copies, exist_ok=True)
    for p in range(nombre):
        graine = args.graine + 100003 * (etat.get("passes", 0) + 1)
        jac = etat.get("jacobien")
        if jac is None or etat.get("passes", 0) - jac["passe"] >= JACOBIEN_AGE:
            mesurer_jacobien(etat, graine + 50021)
            ecrire_etat(etat)
        titre = "Passe %d (graines à partir de %d)" % (etat.get("passes", 0) + 1, graine)
        resume, texte = regleur.mesurer(args.matrice, args.routes, args.tour, graine, titre)
        # Le critère 6 (la Tour) ne compte pas dans les passes des classes (voir score).
        tenus = sum(1 for c in resume["criteres"] if c["ok"] or c["titre"].startswith("6."))
        # Une copie des données mesurées à chaque passe, et de la meilleure, pour pouvoir y revenir.
        sauver_donnees(os.path.join(copies, "passe-%d" % (etat.get("passes", 0) + 1)))
        s = score(resume)
        if s < etat.get("meilleur_score", 1e9):
            etat["meilleur_score"] = s
            etat["meilleure_passe"] = etat.get("passes", 0) + 1
            sauver_donnees(os.path.join(copies, "meilleure"))
        boutons = appliquer(resume, etat) if tenus < 6 else []
        hors = paires_hors(resume)
        if tenus < 6 and etat.get("duels_mesures", False):
            # Le pire des duels hors fourchette, s'il était déjà au-delà de 58 % à la passe d'avant ; un par passe.
            persistants = [k for k in hors if k in etat.get("paires_hors", {})]
            if persistants:
                cle = max(persistants, key=lambda k: hors[k])
                fort, faible = cle.split(">")
                regles = regleur.lire(os.path.join(DATA, "rules.json"))
                b = duel_mesure(etat, regles, fort, faible, hors[cle], graine + 70001)
                if b:
                    boutons.append(b)
        etat["paires_hors"] = paires_hors(resume, DUEL_SEUIL - 0.02)
        etat["passes"] = etat.get("passes", 0) + 1
        ecrire_etat(etat)
        texte = texte.replace("Aucun (mesure seule).", "\n".join("- " + b for b in boutons) if boutons else "Aucun : les six critères sont tenus.")
        texte = texte.replace("\n- - ", "\n- ")
        regleur.ajouter_au_rapport(texte)
        print("passe %d : %d critères tenus, %d boutons touchés" % (etat["passes"], tenus, len(boutons)))
        if tenus == 6:
            break
        r = regleur.subprocess.run([regleur.GODOT, "--headless", "--path", regleur.ROOT, "--script", "res://tools/budget.gd"], capture_output=True, text=True, encoding="utf-8", errors="replace")
        if r.returncode != 0:
            print(r.stdout[-2000:])
            raise SystemExit("le budget n'est plus tenu après la passe")
