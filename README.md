# Projet Arena

RPG mobile en duo (ton perso + un acolyte piloté par l'IA), tour par tour simultané, pixel art. Godot 4, iOS + Android.

- `docs/GDD.md` : le game design document complet (source de vérité).
- `CLAUDE.md` : le résumé lu par Claude Code à chaque session, avec les choix faits en cours de route.
- `docs/SUIVI.md` : où en est le projet, ce qui attend une décision, les prochaines tâches, l'historique des PR.

Le projet est entièrement développé avec Claude Code.

## Organisation du code

| Dossier | Contenu |
| --- | --- |
| `engine/` | Le moteur de règles du combat : module pur, sans affichage, réutilisé par le client, le serveur, l'IA et le simulateur. |
| `data/` | Les données de jeu en JSON : classes, compétences, passifs, états, Synergies, IA, la Tour et son bestiaire de monstres. |
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
godot --headless --path . --script res://tools/simulate.gd -- 1000
godot --headless --path . --script res://tools/simulate_tour.gd -- 500
```

Équilibrage (taux de victoire de chaque classe, compétence, passif, Synergie, composition et kit, fourchette 48–52 %) :

```
godot --headless --path . --script res://tools/equilibrage.gd -- 20000 1 /tmp/equilibrage.csv
python3 tools/equilibrage.py /tmp/equilibrage.csv
python3 tools/regleur.py 8 16000   # règle les chiffres de data/ par passes successives (4 processus Godot)
```

Pour tester une Synergie précise (un duo donné contre des duos au hasard, avec puis sans elle) : `godot --headless --path . --script res://tools/essai_synergie.gd -- 1500 golem_priere invocateur 0 0 0 0 pretre 1 0 0 0` (classe puis index de la basique, de la moyenne, de la forte et du passif, pour le joueur puis l'acolyte).

Pour savoir où va le temps du simulateur (tirage des duos, IA, résolution) : `godot --headless --path . --script res://tools/profil.gd -- 200`.

Le même réglage sur les machines de GitHub, en parallèle et gratuitement : onglet Actions → « Réglage de l'équilibrage (simulation sur GitHub) » → « Run workflow » (passes, combats par passe, machines, branche de départ). À la fin, la branche `reglage-<numéro>` porte les données réglées et le résumé du run donne le rapport. La Tour a son propre bouton, « Réglage de la Tour (simulation sur GitHub) » (passes, montées par passe, machines, branche) : il règle la menace des monstres et la difficulté des étages, et publie la branche `reglage-tour-<numéro>`.

Le Destin (valeurs des nœuds, étape 4) : les mêmes combats avec un niveau (`alea` : les deux duos au même niveau tiré entre 1 et 30, points de Destin placés au hasard ; ou un niveau fixe), puis le régleur des valeurs de `data/destin_nodes.json` :

```
godot --headless --path . --script res://tools/equilibrage.gd -- 20000 1 /tmp/destin.csv alea
python3 tools/equilibrage.py /tmp/destin.csv        # sections « Nœuds du Destin pris »
python3 tools/regleur_destin.py 4 8000               # 4 passes (4 processus Godot) : valeurs côté joueur, force dans le mini-Destin côté acolyte, puis recalibrage de best_value
godot --headless --path . --script res://tools/calibrer_destin.gd -- 120   # la valeur naturelle des arbres neufs
```

La Tour (menace de chaque monstre, puis difficulté de chaque étage) :

```
godot --headless --path . --script res://tools/simulate_tour.gd -- 1000 1 /tmp/etages.csv
python3 tools/menace.py /tmp/etages.csv [--ecrire]   # menace réelle des monstres (--ecrire : la règle dans data/bestiaire.json)
python3 tools/regleur_tour.py 3 2000                 # chaque étage vers son taux de chute cible (data/tower.json)
```

Voir le jeu au format téléphone et prendre des captures (Node et Playwright, après l'export web) :

```
godot --headless --path . --export-release "Web" build/web/index.html
(cd build/web && python3 -m http.server 8765) &
OUT=/tmp/captures Q="?graine=7" node tools/navigateur.js '[{"wait":1000},{"shot":"accueil"},{"tap":[270,700]},{"swipe":[270,800,300]},{"shot":"apres"}]'
```
