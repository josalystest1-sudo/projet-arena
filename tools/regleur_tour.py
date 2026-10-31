"""Le régleur de la Tour (phase 9, PR 9.3 ; docs/PLAN.md) : la courbe « niveau → étage atteint ».

La Tour est absolue (un étage a la même force pour tout le monde) et à murs (décision de Gautier du 31 octobre : un grand
Gardien tous les 10 étages, un Gardien moindre tous les 5, chaque étage plus dur que le précédent, un Gardien plus fort
que les cinq étages qui le suivent ; engine/tour.gd). Ce régleur mesure, pour des trios générés à plusieurs niveaux, sans
équipement ni Faveur, l'étage où ils tombent (la médiane des montées de toutes les classes), et touche deux boutons de
data/tour.json pour suivre la cible :
  - niveau_par_etage : le niveau que les monstres gagnent à chaque étage (la pente), jusqu'à etage_coude ;
  - niveau_par_etage_haut : la pente au-delà du coude (les étages des évolués, ×2,5 : la Tour garde le même rythme) ;
  - niveau_depart : le niveau des monstres de l'étage 1.
La cible (proposition de Claude, à valider par Gautier) : un Gardien moindre tous les 3 niveaux environ. Un trio de niveau
L bat les Gardiens jusqu'à g(L) = 5 × ⌊(L − 1) ÷ 3⌋ et tombe au suivant : l'étage atteint visé est T(L) = g(L) + 5 (le
niveau 1 tombe au Gardien 5, le niveau 4 au grand Gardien 10, le niveau 30 à l'étage 50, le niveau 60 à l'étage 100). La
première pente se règle sur le plus haut niveau d'une classe de base (30), la seconde sur le plus haut niveau mesuré (60),
le départ sur le niveau 1.

Usage :
  python tools/regleur_tour.py mesure [--montees 12] [--niveaux 1,4,7,10,13,16,19,22,25,30,40,50,60] [--graine 1] [--titre "…"] [--rapport]
  python tools/regleur_tour.py passes <nombre> [mêmes options]
Variables : GODOT (le programme Godot), PROCESSUS (24 par défaut).
"""
import argparse
import json
import os
import shutil
import sys
import tempfile
import time
from concurrent.futures import ThreadPoolExecutor

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import regleur  # noqa: E402

DATA = regleur.DATA
TOUR = os.path.join(DATA, "tour.json")
NIVEAUX = [1, 4, 7, 10, 13, 16, 19, 22, 25, 30, 40, 50, 60]
## La cible : un Gardien moindre tous les NIVEAUX_PAR_GARDIEN niveaux (à valider par Gautier).
NIVEAUX_PAR_GARDIEN = 3
## Les bornes des boutons.
PENTE_MIN, PENTE_MAX = 0.2, 5.0
DEPART_MIN, DEPART_MAX = 1.0, 60.0


def cible(niveau, regles):
    """L'étage atteint visé (celui où le trio tombe) : le Gardien qui suit le dernier qu'un trio de ce niveau doit battre."""
    g = int(regles["gardien_tous_les"])
    return g * ((niveau - 1) // NIVEAUX_PAR_GARDIEN) + g


def lire_tour():
    return regleur.lire(TOUR)


def ecrire_tour(t):
    """Le format de data/tour.json : une clé par ligne, les objets (revenu) sur une ligne."""
    with open(TOUR, "w", encoding="utf-8", newline="\n") as f:
        f.write("{\n" + ",\n".join('  "%s": %s' % (k, json.dumps(v, ensure_ascii=False)) for k, v in t.items()) + "\n}\n")


def mesurer(niveaux, montees, graine0, titre):
    """Les montées à chaque niveau : rend {niveau: {"mediane": étage médian, "moyenne": …, "classes": {classe: médiane}}}."""
    regles = lire_tour()
    dossier = tempfile.mkdtemp(prefix="tour-")
    ordre = regleur.lire(os.path.join(DATA, "classes.json"))
    debut = time.time()
    out = {}
    for niveau in niveaux:
        etage_max = cible(niveau, regles) + 3 * int(regles["gardien_tous_les"])
        parts = os.path.join(dossier, "n%d" % niveau)
        os.makedirs(parts, exist_ok=True)

        def lancer(p, niveau=niveau, parts=parts, etage_max=etage_max):
            sortie = os.path.join(parts, "tour-%02d.json" % p)
            r = regleur.godot("simuler", "tour", str(p), str(regleur.PROCESSUS), str(montees), str(graine0), sortie, "trio", "bon_sens",
                              "niveau=%d" % niveau, "etage_max=%d" % etage_max)
            if r.returncode != 0 or not os.path.exists(sortie):
                raise RuntimeError("travailleur niveau %d part %d : %s" % (niveau, p, r.stdout + r.stderr))
            return sortie

        with ThreadPoolExecutor(max_workers=regleur.PROCESSUS) as pool:
            fichiers = list(pool.map(lancer, range(regleur.PROCESSUS)))
        comptes = {}
        for f in fichiers:
            for cle, n in regleur.lire(f)["tour"].items():
                i, etage = cle.split("|")
                comptes.setdefault(ordre[int(i)], {})
                comptes[ordre[int(i)]][int(etage)] = comptes[ordre[int(i)]].get(int(etage), 0) + int(n)
        par_classe = {c: _mediane(comptes.get(c, {})) for c in ordre}
        tous = {}
        total = 0
        for c in comptes.values():
            for etage, n in c.items():
                tous[etage] = tous.get(etage, 0) + n
                total += etage * n
        out[niveau] = {"mediane": _mediane(tous), "moyenne": total / max(1, sum(tous.values())), "classes": par_classe,
                       "montees": sum(tous.values()), "etage_max": etage_max, "cible": cible(niveau, regles)}
        print("niveau %2d : étage médian %3d (cible %3d, moyenne %.1f, plafond %d) en %d s" % (
            niveau, out[niveau]["mediane"], out[niveau]["cible"], out[niveau]["moyenne"], etage_max, time.time() - debut), flush=True)
    shutil.rmtree(dossier, ignore_errors=True)
    return out


def _mediane(comptes):
    total = sum(comptes.values())
    cumul = 0
    for etage in sorted(comptes):
        cumul += comptes[etage]
        if cumul * 2 >= total:
            return etage
    return 0


def rapport(mesure, titre, boutons):
    regles = lire_tour()
    ordre = regleur.lire(os.path.join(DATA, "classes.json"))
    noms = [regleur.lire(os.path.join(DATA, "classes", c + ".json"))["nom"] for c in ordre]
    lignes = ["## " + titre, "",
              "Trios générés, allumage par défaut, sans équipement ni Faveur, IA de bon sens ; l'étage atteint est celui où le trio est tombé "
              "(médiane des montées de toutes les classes). La cible : un Gardien moindre tous les %d niveaux (`tools/regleur_tour.py`). "
              "Réglage : niveau des monstres de l'étage 1 %s, +%s par étage jusqu'à l'étage %d puis +%s ; un Gardien a la force de l'étage +%d, un grand Gardien de l'étage +%d ; somme des multiplicateurs de PV de %s + %s par étage (largeur %s, plafond %s)."
              % (NIVEAUX_PAR_GARDIEN, _f(regles["niveau_depart"]), _f(regles["niveau_par_etage"]), int(regles["etage_coude"]), _f(regles["niveau_par_etage_haut"]), int(regles["avance_gardien"]), int(regles["avance_grand_gardien"]),
                 _f(regles["somme_depart"]), _f(regles["somme_pente"]), _f(regles["somme_largeur"]), _f(regles["somme_max"])),
              "", "| Niveau du trio | Étage atteint (médiane) | Cible | Moyenne | Par classe (%s) |" % " / ".join(noms),
              "| --- | --- | --- | --- | --- |"]
    ecart = 0
    for niveau in sorted(mesure):
        m = mesure[niveau]
        ecart += abs(m["mediane"] - m["cible"])
        lignes.append("| %d | %d | %d | %s | %s |" % (niveau, m["mediane"], m["cible"], _f(m["moyenne"]), " / ".join(str(m["classes"][c]) for c in ordre)))
    lignes.append("")
    lignes.append("Écart total à la cible : %d étages sur %d niveaux mesurés." % (ecart, len(mesure)))
    lignes.append("")
    lignes.append("### Boutons touchés, et pourquoi")
    lignes.append("")
    lignes.extend(("- " + b) for b in boutons) if boutons else lignes.append("Aucun (mesure seule).")
    lignes.append("")
    return "\n".join(lignes), ecart


def _f(x):
    return ("%.2f" % float(x)).rstrip("0").rstrip(".").replace(".", ",")


def appliquer(mesure):
    """Les deux boutons. La pente, d'après le niveau le plus haut mesuré : l'étage atteint y est à peu près proportionnel à
    1 ÷ pente (les monstres d'un étage ont le niveau depart + pente × (étage − 1)) ; puis le départ, d'après le niveau le
    plus bas : un étage de trop vaut pente niveaux de monstres. Pas amortis de moitié, bornés."""
    t = lire_tour()
    boutons = []
    niveaux = sorted(mesure)
    # La première pente se règle sur le plus haut niveau avant l'évolution (30), la seconde (au-delà du coude) sur le
    # plus haut niveau mesuré, le départ sur le plus bas.
    plafond = int(regleur.lire(os.path.join(DATA, "rules.json"))["evolution"]["niveau"])
    haut, bas = max([n for n in niveaux if n <= plafond] or niveaux), niveaux[0]
    m_haut, m_bas = mesure[haut], mesure[bas]
    coude = int(t["etage_coude"])
    if niveaux[-1] > plafond:
        m_evo = mesure[niveaux[-1]]
        p2 = float(t["niveau_par_etage_haut"])
        if abs(m_evo["mediane"] - m_evo["cible"]) > 2 and m_evo["cible"] > coude:
            facteur = max(1.0, m_evo["mediane"] - coude) / max(1.0, m_evo["cible"] - coude)
            facteur = 1 + (facteur - 1) * 0.5
            nouvelle = round(min(PENTE_MAX, max(PENTE_MIN, p2 * facteur)), 3)
            if nouvelle != p2:
                boutons.append("niveau par étage au-delà du coude (étage %d) : %s → %s (au niveau %d, l'étage %d atteint pour une cible à %d)" % (coude, _f(p2), _f(nouvelle), niveaux[-1], m_evo["mediane"], m_evo["cible"]))
                t["niveau_par_etage_haut"] = nouvelle
    pente = float(t["niveau_par_etage"])
    if abs(m_haut["mediane"] - m_haut["cible"]) > 2:
        facteur = (m_haut["mediane"] - 1) / max(1.0, m_haut["cible"] - 1.0)
        facteur = 1 + (facteur - 1) * 0.5
        nouvelle = round(min(PENTE_MAX, max(PENTE_MIN, pente * facteur)), 3)
        if nouvelle != pente:
            boutons.append("niveau par étage : %s → %s (au niveau %d, l'étage %d atteint pour une cible à %d)" % (_f(pente), _f(nouvelle), haut, m_haut["mediane"], m_haut["cible"]))
            t["niveau_par_etage"] = nouvelle
            pente = nouvelle
    depart = float(t["niveau_depart"])
    if abs(m_bas["mediane"] - m_bas["cible"]) > 1:
        nouveau = round(min(DEPART_MAX, max(DEPART_MIN, depart + 0.5 * pente * (m_bas["mediane"] - m_bas["cible"]))), 2)
        if nouveau != depart:
            boutons.append("niveau des monstres de l'étage 1 : %s → %s (au niveau %d, l'étage %d atteint pour une cible à %d)" % (_f(depart), _f(nouveau), bas, m_bas["mediane"], m_bas["cible"]))
            t["niveau_depart"] = nouveau
    ecrire_tour(t)
    return boutons


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("action", choices=["mesure", "passes"])
    parser.add_argument("nombre", nargs="?", type=int, default=1)
    parser.add_argument("--montees", type=int, default=12, help="montées par classe et par niveau")
    parser.add_argument("--niveaux", default=",".join(str(n) for n in NIVEAUX))
    parser.add_argument("--graine", type=int, default=1)
    parser.add_argument("--titre", default="La Tour à murs : mesure")
    parser.add_argument("--rapport", action="store_true", help="ajouter le rapport à docs/EQUILIBRAGE-V2.md")
    args = parser.parse_args()
    niveaux = [int(x) for x in args.niveaux.split(",")]
    if args.action == "mesure":
        m = mesurer(niveaux, args.montees, args.graine, args.titre)
        texte, ecart = rapport(m, args.titre, [])
        print(texte)
        if args.rapport:
            regleur.ajouter_au_rapport(texte)
        return
    for p in range(args.nombre):
        graine = args.graine + 7919 * p
        titre = "%s, passe %d (graines à partir de %d)" % (args.titre, p + 1, graine)
        m = mesurer(niveaux, args.montees, graine, titre)
        _, ecart = rapport(m, titre, [])
        boutons = appliquer(m) if ecart > len(niveaux) else []
        texte, _ = rapport(m, titre, boutons)
        print(texte)
        if args.rapport:
            regleur.ajouter_au_rapport(texte)
        if not boutons:
            print("la cible est tenue (écart %d)" % ecart)
            break


if __name__ == "__main__":
    sys.stdout.reconfigure(encoding="utf-8")
    main()
