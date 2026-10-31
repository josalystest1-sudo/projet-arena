"""Le régleur d'équilibrage du combat V2 (docs/SPEC-COMBAT-V2.md, section 11.3).

Une mesure : des travailleurs Godot en parallèle (tools/equilibrage.gd simuler), puis le rapport (tools/equilibrage.gd
rapport) : la matrice des classes, les trois routes, l'usage des voies, la longueur des combats, la Tour, et les six
critères de la section 11.2.

Une passe : une mesure, puis les boutons de la section 11.3, dans cet ordre et seulement ceux-là :
  1. k_classe (0,75 à 1,20) ;
  2. le budget d'un nœud précis, ±10 % autour de celui de son rang (budget_override dans la donnée du nœud ; les
     valeurs du nœud suivent, pour que son coût reste dans ±6 % de ce budget) ;
  3. le coût d'un état dans la grille, ±20 % (les nœuds qui posent cet état voient leurs autres valeurs suivre) ;
  4. les PV de base d'une classe, ±10 % ;
  5. les règles globales (mort subite, extinction, refroidissement), seulement si les quatre premiers ne suffisent pas.
Chaque passe ajoute son rapport en français à docs/EQUILIBRAGE-V2.md.

Depuis la phase 9 (docs/PLAN.md), le format est le trio (le joueur et ses deux Échos générés, le jeu publié) ; « --format duo »
garde l'ancien format. La Tour n'est plus réglée ici (elle est absolue depuis la PR #57 : sa courbe « niveau → étage » se règle
avec tools/regleur_tour.py) ; « --tour n » mesure seulement les montées (étage atteint, jusqu'à --etage-max).

Usage :
  python tools/regleur.py mesure [--matrice 1000] [--routes 1000] [--tour 1000] [--graine 1] [--titre "…"] [--format trio] [--niveau 30] [--etage-max 21]
  python tools/regleur.py passes <nombre> [--matrice 300] [--routes 200] [--tour 0]
Variables : GODOT (le programme Godot), PROCESSUS (24 par défaut).
"""
import argparse
import json
import os
import shutil
import subprocess
import sys
import tempfile
import time
from concurrent.futures import ThreadPoolExecutor

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DATA = os.path.join(ROOT, "data")
GODOT = os.environ.get("GODOT", next((p for p in [os.path.expanduser("~/godot/godot_console.exe"), os.path.expanduser("~/godot/godot")] if os.path.exists(p)),
                                     os.path.expanduser("~/godot/godot")))
## Le format et les réglages des travailleurs (tools/equilibrage.gd) : posés par main() depuis la ligne de commande.
FORMAT = "trio"
REGLAGES = []
PROCESSUS = int(os.environ.get("PROCESSUS", "24"))
RAPPORT = os.path.join(ROOT, "docs", "EQUILIBRAGE-V2.md")


def lire(chemin):
    with open(chemin, encoding="utf-8") as f:
        return json.load(f)


def godot(*args):
    return subprocess.run([GODOT, "--headless", "--path", ROOT, "--script", "res://tools/equilibrage.gd", "--"] + list(args),
                          capture_output=True, text=True, encoding="utf-8", errors="replace")


def mesurer(n_matrice, n_routes, n_tour, graine0, titre, boutons=None, dossier=None):
    """Une mesure complète ; rend le résumé (et écrit le rapport de la mesure dans le dossier)."""
    dossier = dossier or tempfile.mkdtemp(prefix="equilibrage-")
    parts = os.path.join(dossier, "parts")
    shutil.rmtree(parts, ignore_errors=True)
    os.makedirs(parts)
    travaux = []
    for mesure, n in [("matrice", n_matrice), ("routes", n_routes), ("tour", n_tour)]:
        if n <= 0:
            continue
        for p in range(PROCESSUS):
            travaux.append((mesure, p, n))
    debut = time.time()

    def lancer(travail):
        mesure, p, n = travail
        sortie = os.path.join(parts, "%s-%02d.json" % (mesure, p))
        r = godot("simuler", mesure, str(p), str(PROCESSUS), str(n), str(graine0), sortie, FORMAT, "bon_sens", *REGLAGES)
        if r.returncode != 0 or not os.path.exists(sortie):
            raise RuntimeError("travailleur %s %d : %s" % (mesure, p, r.stdout + r.stderr))
        return sortie

    with ThreadPoolExecutor(max_workers=PROCESSUS) as pool:
        list(pool.map(lancer, travaux))
    fichier_boutons = os.path.join(dossier, "boutons.json")
    with open(fichier_boutons, "w", encoding="utf-8") as f:
        json.dump(boutons or [], f, ensure_ascii=False)
    md = os.path.join(dossier, "rapport.md")
    resume = os.path.join(dossier, "resume.json")
    r = godot("rapport", parts, md, resume, titre, fichier_boutons)
    if r.returncode != 0:
        raise RuntimeError(r.stdout + r.stderr)
    print("mesure en %d s : %s (%s)" % (time.time() - debut, r.stdout.strip().splitlines()[-1], dossier))
    return lire(resume), open(md, encoding="utf-8").read()


def ajouter_au_rapport(texte):
    entete = ("# Équilibrage du combat V2\n\nUn rapport par passe de réglage (docs/SPEC-COMBAT-V2.md, section 11.3) : la matrice des "
              "classes, les trois routes, l'usage des voies, la longueur des combats, la Tour, et les boutons touchés. Le plus "
              "récent est en bas.\n\n")
    ancien = open(RAPPORT, encoding="utf-8").read() if os.path.exists(RAPPORT) else entete
    with open(RAPPORT, "w", encoding="utf-8", newline="\n") as f:
        f.write(ancien.rstrip("\n") + "\n\n" + texte.rstrip("\n") + "\n")


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("action", choices=["mesure", "passes"])
    parser.add_argument("nombre", nargs="?", type=int, default=1)
    parser.add_argument("--matrice", type=int, default=1000)
    parser.add_argument("--routes", type=int, default=1000)
    parser.add_argument("--tour", type=int, default=1000)
    parser.add_argument("--graine", type=int, default=1)
    parser.add_argument("--titre", default="Mesure")
    parser.add_argument("--rapport", action="store_true", help="ajouter le rapport à docs/EQUILIBRAGE-V2.md")
    parser.add_argument("--format", choices=["duo", "trio"], default="trio")
    parser.add_argument("--niveau", type=int, default=30, help="le niveau des Destins simulés")
    parser.add_argument("--etage-max", type=int, default=21, help="l'étage où les montées s'arrêtent")
    args = parser.parse_args()
    global FORMAT, REGLAGES
    FORMAT = args.format
    REGLAGES = ["niveau=%d" % args.niveau, "etage_max=%d" % args.etage_max]
    if args.action == "mesure":
        resume, texte = mesurer(args.matrice, args.routes, args.tour, args.graine, args.titre)
        print(texte)
        if args.rapport:
            ajouter_au_rapport(texte)
    else:
        import regleur_boutons
        regleur_boutons.passes(args.nombre, args)


if __name__ == "__main__":
    sys.stdout.reconfigure(encoding="utf-8")
    sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
    main()
