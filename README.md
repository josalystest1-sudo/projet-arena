# Projet Arena

RPG mobile en duo (ton perso + un acolyte piloté par l'IA), tour par tour simultané, pixel art. Godot 4, iOS + Android.

- `docs/GDD.md` : le game design document complet (source de vérité).
- `CLAUDE.md` : le résumé lu par Claude Code à chaque session, avec les choix faits en cours de route.
- `docs/SUIVI.md` : où en est le projet, ce qui attend une décision, les prochaines tâches, l'historique des PR.

Le projet est entièrement développé avec Claude Code.

## Organisation du code

| Dossier | Contenu |
| --- | --- |
| `engine/` | Le moteur de règles du combat V2 (`docs/SPEC-COMBAT-V2.md`) : données (`donnees.gd`), budget (`budget.gd`), Destin (`destin.gd`) et son générateur (`generateur.gd`), état d'un combat (`etat_combat.gd`), règles du tour (`regles.gd`), IA (`ia.gd`), textes générés (`texte.gd`), la Tour (`tour.gd`). Module pur, sans affichage, réutilisé par le client, le serveur, l'IA et le simulateur. |
| `data/` | Les données de jeu en JSON : règles (`rules.json`), états (`etats.json`), textes (`textes.json`), les 10 classes et leurs roues (`classes/`), le bestiaire de la Tour (`bestiaire.json`) et ses règles (`tour.json`). |
| `scenes/app/` | L'application : profil, duo, navigation entre les écrans (scène de démarrage). |
| `scenes/screens/` | Les écrans : création, rencontre de l'acolyte, Vitrine, Acolyte, Compétences, La Tour, Bestiaire, Profil, Paramètres, face-à-face. |
| `scenes/ui/` | Les briques communes de l'interface : thème, boutons, cartes, portraits animés. |
| `scenes/combat/` | L'écran de combat (affichage uniquement, aucune règle). |
| `tests/` | Les tests automatiques du moteur, lancés en CI à chaque PR. |
| `tools/` | Les simulateurs (duo contre duo, montées de la Tour), l'équilibrage (mesure et régleur automatique), le générateur de bruitages provisoires et le pilote de navigateur pour les captures. |
| `.github/workflows/` | Tests à chaque PR, export web publié sur GitHub Pages à chaque fusion sur `main`. |

## Lancer en local (pour les développeurs)

```
godot --headless --path . --import
godot --headless --path . --script res://tests/run_tests.gd
godot --headless --path . --script res://tools/budget.gd          # chaque nœud dans ±6 % de son budget (aussi en CI)
```

Équilibrage du combat V2 (`docs/SPEC-COMBAT-V2.md`, section 11) : des combats IA contre IA au niveau 30, la matrice des classes, les trois routes, l'usage des voies, la longueur des combats et la Tour, puis les six critères ; chaque passe ajoute son rapport en français à `docs/EQUILIBRAGE-V2.md`.

```
GODOT=chemin/vers/godot PROCESSUS=24 python tools/regleur.py mesure --matrice 1000 --routes 1000 --tour 1000   # une mesure
GODOT=chemin/vers/godot PROCESSUS=24 python tools/regleur.py passes 6 --matrice 1500 --routes 40 --tour 1000   # des passes de réglage
```

`tools/equilibrage_lib.gd` contient la simulation, les critères et le rapport ; `tools/equilibrage.gd` les lance en ligne de commande (un travailleur, ou le rapport) ; `tools/regleur.py` lance les travailleurs en parallèle ; `tools/regleur_boutons.py` touche les boutons de la section 11.3 et garde son état dans `tools/regleur_etat.json`.

Le simulateur fait aussi jouer des **trios** (le joueur et ses deux Échos générés, `docs/GDD_V2.md`, `docs/PLAN.md` PR 1.1) : dernier argument `trio` d'un travailleur, par exemple `godot --headless --path . --script res://tools/equilibrage.gd -- simuler matrice 0 1 100 1 sortie.json trio` (sans lui : le duo, le jeu publié). Le régleur passera au trio avec la PR 1.5.

Voir un écran sans téléphone : `godot --path . --script res://tools/capture.gd -- <dossier> '<étapes JSON>'` (mode d'emploi en tête du fichier : créer un perso, monter de niveau, allumer un nœud, lancer un duel ou une montée, toucher, appui long, captures).
