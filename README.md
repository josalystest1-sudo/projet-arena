# Projet Arena

RPG mobile en duo (ton perso + un acolyte piloté par l'IA), tour par tour simultané, pixel art. Godot 4, iOS + Android.

- `docs/GDD.md` : le game design document complet (source de vérité).
- `CLAUDE.md` : le résumé lu par Claude Code à chaque session, avec les choix faits en cours de route.

Le projet est entièrement développé avec Claude Code.

## Organisation du code

| Dossier | Contenu |
| --- | --- |
| `engine/` | Le moteur de règles du combat : module pur, sans affichage, réutilisé par le client, le serveur, l'IA et le simulateur. |
| `data/` | Les données de jeu en JSON : classes, compétences, passifs, états, Synergies. |
| `scenes/app/` | L'application : profil, duo, navigation entre les écrans (scène de démarrage). |
| `scenes/screens/` | Les écrans : création, rencontre de l'acolyte, Vitrine, Acolyte, Compétences, La Tour, Profil, Paramètres, face-à-face. |
| `scenes/ui/` | Les briques communes de l'interface : thème, boutons, cartes, portraits animés. |
| `scenes/combat/` | L'écran de combat (affichage uniquement, aucune règle). |
| `tests/` | Les tests automatiques du moteur, lancés en CI à chaque PR. |
| `tools/` | Les simulateurs (duo contre duo, montées de la Tour), l'équilibrage (mesure et régleur automatique) et le générateur de bruitages provisoires. |
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
