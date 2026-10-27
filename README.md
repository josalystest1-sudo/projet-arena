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
| `scenes/combat/` | L'écran de combat du prototype (affichage uniquement, aucune règle). |
| `tests/` | Les tests automatiques du moteur, lancés en CI à chaque PR. |
| `tools/` | Le mini-simulateur IA contre IA (duo contre duo) et le générateur de bruitages provisoires. |
| `.github/workflows/` | Tests à chaque PR, export web publié sur GitHub Pages à chaque fusion sur `main`. |

## Lancer en local (pour les développeurs)

```
godot --headless --path . --import
godot --headless --path . --script res://tests/run_tests.gd
godot --headless --path . --script res://tools/simulate.gd -- 1000
```
