# Suivi du projet

Mis à jour le **28 octobre 2026**. Ce fichier dit où en est le projet, ce qui attend Gautier et ce qui vient ensuite. Il est lu au début de chaque session (avec `CLAUDE.md`) et mis à jour à la fin de chaque PR. Les règles du jeu sont dans `docs/GDD.md`, les choix techniques et les chiffres dans `CLAUDE.md` (« Choix faits par Claude Code »).

## Où on en est

Les prototypes des étapes 1 et 2 de la feuille de route sont jouables sur téléphone : le **combat en duo** (ton perso et ton acolyte contre un duo IA, 3 classes) et **la Tour** (10 étages de monstres). Ils ont des menus, un équilibrage mesuré au simulateur et un combat guidé. Le 28 octobre, Gautier a donné le feu vert pour la suite : d'abord les Destins réglés par côté (fait, PR #16), puis l'étape 3 (les 10 classes, le Destin, le mini-Destin, les Synergies), en plusieurs PR.

**À tester :** https://josalystest1-sudo.github.io/projet-arena/ (mis à jour à chaque fusion sur `main`, une à deux minutes après).

## Feuille de route : avancement

| Étape | État | Détail |
| --- | --- | --- |
| 1. Prototype de combat en duo | **Fait, à valider** | PR #5 à #8, #10, #12, #14. Critère de sortie (« on a envie de relancer un combat ») pas encore confirmé par Gautier. |
| 2. La Tour en prototype | **Fait, à valider** | PR #9, #13 (monstres et bestiaire). Critère (« on veut battre son record ») pas encore confirmé. |
| 3. 10 classes, Destin, mini-Destin, Synergies | **Fait, à équilibrer** | PR #17 à #22. Reste le passage du régleur sur les 10 classes (PR d'équilibrage). |
| 4. Simulateur d'équilibrage | **En partie** | Déjà là pour 3 classes : `tools/equilibrage.gd`, `tools/regleur.py`, `tools/simulate_tour.gd`, `tools/menace.py`, `tools/regleur_tour.py`. À étendre aux 10 classes, aux nœuds de Destin et à la mort subite. |
| 5. Serveur, comptes, PvP réel, Échos | À faire | Pas avant l'étape 4. |
| 6. Art PixelLab et les 13 écrans | À faire | Sprites provisoires d'ici là. Les écrans existent déjà en version simple (création, rencontre, Vitrine, Acolyte, Compétences, La Tour, Bestiaire, Profil, Paramètres). |
| 7 à 10. Évolutions, boutique, bêta, lancement | À faire | |

## En attente de Gautier

1. **Les critères de sortie** (le GDD dit de ne pas passer à l'étape suivante sans avoir testé la précédente sur téléphone) : après quelques combats, as-tu envie d'en relancer un ? À la Tour, as-tu envie de battre ton record ?

Dernier retour : feu vert pour rééquilibrer les Destins puis attaquer l'étape 3 (28 octobre).

## Prochaines tâches (dans l'ordre)

**Depuis le 29 octobre, la suite est l'ordre de construction du § 12 de `docs/GDD_V2.md`** (d'abord le trio avec Échos générés), après la PR d'équilibrage des 10 classes ci-dessous. Lire le GDD V2 avant de commencer ; les réponses de Gautier aux questions du § 13 sont à ajouter au tableau des retours.

1. ~~Équilibrer les Destins séparément côté joueur et côté acolyte.~~ Fait (PR #16) : côté joueur 45,5–52,9 % (77 kits sur 96 dans 48–52), côté acolyte 45,9–53,8 % (83 sur 96), Tour reréglée.
2. **Étape 3**, en plusieurs PR :
   - ~~le moteur rendu générique~~ fait (PR #17) ;
   - les 7 classes manquantes, par groupes : ~~Voleur, Archer, Pugiliste~~ (PR #19) ; ~~Alchimiste, Barde, Diplomate~~ (PR #20) ; ~~l'Invocateur et sa créature~~ (PR #21) ; 6 actives et 4 passifs chacune, leurs Synergies (au moins une entre chaque classe et chaque classe qui peut lui servir d'acolyte, et chaque kit a une Synergie possible), avec tests ;
   - ~~le générateur de Destin (arbre de 45 nœuds, 30 points, budget de puissance), le mini-Destin de l'acolyte (15 nœuds, auto-attribué) et l'écran de l'arbre~~ (PR #22) ;
   - un nouveau passage du régleur (duel et Tour) sur les 10 classes.

## Limites connues

- **Cycle entre compositions** : Guerrier + Mage bat Mage + Prêtre 55 %, Mage + Prêtre bat Guerrier + Prêtre 56 %, Guerrier + Prêtre bat Guerrier + Mage 55 %. La force d'un duo ne peut pas le corriger. Le Guerrier + Prêtre gagne surtout au décompte des PV : piste de la mort subite (étape 4). À revoir avec les 10 classes.
- **Le pilier « le duo gagne »** n'est pas encore démontré au simulateur : un joueur IA qui lit l'annonce de son acolyte gagne 52,9 % contre un qui l'ignore. Il faudra une IA qui prépare ses coups sur plusieurs tours (étape 4), et surtout le ressenti de Gautier.
- **La Tour selon la classe** : étage moyen atteint, Mage 6,2, Guerrier 6,3, Prêtre 8,1. Le record étant par classe, ce n'est pas bloquant.
- **La règle d'attente de l'acolyte** (garder sa forte un tour pour une Synergie) ne sert que dans environ 2 combats sur 100 avec 3 classes ; elle prendra de l'importance avec les 10 classes.
- **Ce qui est provisoire** : sprites en pixels dessinés en code (PixelLab à l'étape 6), bruitages synthétiques, noms des monstres et de l'acolyte (en attente de l'univers), données gardées sur l'appareil (comptes à l'étape 5), courbe d'XP rapide et bouton « Gagner un niveau » (pour tester l'arbre du Destin).
- **Les valeurs des nœuds du Destin** sont fixées à la main (`data/destin_nodes.json`) : le simulateur de l'étape 4 doit mesurer le taux de victoire par type de nœud et corriger.
- **Ce qui est contraire au GDD, pour le prototype seulement** (à retirer à l'étape 5) : refaire le tirage de son perso ou de son acolyte, recréer un personnage (Paramètres).

## Retours de Gautier et ce qu'on en a fait

| Date | Retour | Réponse |
| --- | --- | --- |
| 27 oct | « C'est un peu fade » | PV baissés de 25 %, combat plus vif (secousses, sons, annonces). |
| 27 oct | Le jeu passe du 3v3 au duo (joueur + acolyte IA) | PR #5 à #7 : moteur, IA de l'acolyte, écran en duo. |
| 27 oct | « Aucune méta » tant qu'il n'y a pas d'équipement | Équilibrage au simulateur (PR #10). |
| 27 oct | Postures selon le rôle (« pas de Protège-moi pour un Mage ») | PR #10, puis remplacées le même jour. |
| 27 oct, 14 h | Plus de postures : l'acolyte joue seul | PR #12, avec la règle d'attente pour les Synergies. |
| 27 oct | À la Tour, des monstres (1 à 4), et un bestiaire | PR #13 : 14 monstres en 4 familles, 2 Gardiens. |
| 28 oct | « Les Synergies ne sont pas mises en avant », « on ne sait pas ce qu'on doit faire » | PR #14 : une carte au milieu, une consigne en gros, les Synergies en doré, un premier combat guidé. |
| 28 oct | « On ne peut pas faire défiler un écran vers le bas » | PR #14 : défilement au doigt partout, écran de combat qui tient sur un téléphone peu haut. |
| 28 oct | « C'est beaucoup plus clair » | Prochaines étapes proposées. |
| 28 oct | Feu vert : Destins par côté, puis l'étape 3 ; « avance au maximum » | PR #16 (Destins par côté), puis l'étape 3 en plusieurs PR. |
| 29 oct | Réponses aux questions du GDD V2 : 10 classes → 30 → 90 évolutions + classes de grimoire (rare, épique, légendaire) sur les boss ; Tour infinie ; saisons pour le PvP et les territoires ; guildes à 100 avec rôles, chat, bannière, ressource ; pas d'inflation ; ville à bâtiments en portrait ; équipement aussi en solo | `docs/GDD_V2.md` version 2.1 : guerre de guilde, types de territoire, Comptoir à prix fixes et ligues par puissance proposés par Claude Code (à confirmer). |
| 29 oct | Grande session de conception : trio avec Échos à la place de l'acolyte, adversaire opaque, Soutiens sans dégâts, Tour fixe sans limite de tours, PvP à 5 par jour, donjons à routes et boss unique au serveur, guildes, territoires, équipement | `docs/GDD_V2.md` (décisions étiquetées Décidé / Proposé / Ouvert, 9 questions en attente) et `docs/MECANIQUES.md`. |
| 28 oct | « Il me reste 22 $ de crédit, ça continue de baisser » | Les machines de GitHub sont gratuites, mais chaque échange avec Claude coûte, d'autant plus que la conversation est longue. Session arrêtée ; la suite est écrite ci-dessous pour une conversation courte. |
| 28 oct | « Pas de crédits cloud : la solution la plus rapide, performante et gratuite » | Un seul Claude à la fois (plus d'agents en parallèle) ; les simulations longues sur les machines de GitHub, gratuites pour un dépôt public (PR #18). |

## Historique des PR

| PR | Date | Contenu |
| --- | --- | --- |
| #1 | 26 oct | Moteur de règles du combat (3v3), données des 3 classes, tests en CI. |
| #2 | 26 oct | Écran de combat minimal jouable contre 5 IA. |
| #3 | 26 oct | Export web publié sur GitHub Pages à chaque fusion sur `main`. |
| #4 | 27 oct | Combat plus vif, plus lisible et plus vivant (repris dans #5). |
| #5 | 27 oct | Duo (1/3) : le moteur passe en 2 contre 2. |
| #6 | 27 oct | Duo (2/3) : l'IA de l'acolyte (alors à 4 postures). |
| #7 | 27 oct | Duo (3/3) : l'écran de combat avec l'acolyte. |
| #8 | 27 oct | Un acolyte Guerrier ne protège plus un joueur qui a tous ses PV. |
| #9 | 27 oct | Étape 2 : la Tour (10 étages, PV et recharges gardés). |
| #10 | 27 oct | Postures selon le rôle, équilibrage « aucune méta », menus et navigation. |
| #11 | 27 oct | Notes de CLAUDE.md sur les postures. |
| #12 | 27 oct | L'acolyte sans postures, règle d'attente pour une Synergie. |
| #13 | 27 oct | La Tour contre des monstres : bestiaire, 1 à 4 monstres par étage. |
| #14 | 28 oct | Combat plus clair, écrans qui défilent au doigt. |
| #15 | 28 oct | Documents de suivi (ce fichier), outil de captures dans le navigateur. |
| #16 | 28 oct | Destins réglés séparément côté joueur et côté acolyte ; Tour reréglée. |
| #17 | 28 oct | Moteur générique (passifs par paramètres, états par drapeaux, Synergies en données) ; aucune règle ne change. |
| #18 | 28 oct | Réglage de l'équilibrage sur les machines de GitHub, en parallèle (bouton dans l'onglet Actions). |
| #19 | 28 oct | Voleur, Archer, Pugiliste : 3 classes, 16 Synergies, réglage sur GitHub. |
| #20 | 28 oct | Alchimiste, Barde, Diplomate : 3 Soutiens, 26 Synergies. |
| #21 | 28 oct | L'Invocateur et sa créature (Golem, Spectre) : la 10e classe, 14 Synergies ; bouton de réglage de la Tour sur GitHub. |
| #22 | 28 oct | Le Destin : arbre de 45 nœuds et 30 points, mini-Destin de l'acolyte (15 nœuds), niveaux et XP, écran de l'arbre. |

## Reprendre le travail (pour Claude Code)

**À faire en premier (reste de l'étape 3, environ 15 minutes, PR #23)** : le réglage des 10 classes a tourné sur GitHub (Actions → « Réglage de l'équilibrage », run 2, 6 passes de 400 000 combats) et a publié la branche `reglage-2` (données réglées + rapport dans le résumé du run). Étapes : (1) `git merge origin/reglage-2` dans la branche de travail (seul `data/` change) ; (2) lancer Actions → « Réglage de la Tour » sur cette branche (4 passes, 20 000 montées, 12 machines ; environ 10 minutes) puis fusionner la branche `reglage-tour-<numéro>` qu'il publie ; (3) copier les chiffres du rapport (classes, compositions, kits par côté, durée des combats, Tour : part au sommet, étage moyen par classe) dans `CLAUDE.md` (section « Équilibrage ») et ici (« Limites connues », tableau des PR), tests, PR, fusion. Faire peu d'échanges : ne pas surveiller GitHub en boucle (chaque vérification coûte), lancer puis revenir plus tard.

- **Branche de travail** : celle indiquée par la session. Le force-push est refusé : pour se mettre à jour, `git merge origin/main` (pas de rebase). Les PR se fusionnent en « squash » avec le SHA complet (40 caractères) de leur dernier commit.
- **Godot 4.5** : s'il manque dans le conteneur, l'installer comme la CI (`.github/workflows/tests.yml`, dans `~/godot/godot`) ; pour l'export web, les modèles d'export comme dans `.github/workflows/web.yml`.
- **Tests** (168 au 28 octobre) : `~/godot/godot --headless --path . --script res://tests/run_tests.gd`.
- **Voir le jeu comme Gautier** : exporter (`~/godot/godot --headless --path . --export-release "Web" build/web/index.html`), servir `build/web` (`python3 -m http.server 8765`), puis piloter et capturer avec `node tools/navigateur.js` (souris ou doigt, hauteur de téléphone réglable ; mode d'emploi en tête du fichier). Ajouter `?graine=7` à l'adresse rejoue toujours les mêmes tirages.
- **Équilibrage** : de préférence sur GitHub (onglet Actions → « Réglage de l'équilibrage », choisir la branche de départ ; à la fin, une branche `reglage-<numéro>` porte les données réglées et le résumé du run donne le rapport ; même chose pour la Tour avec « Réglage de la Tour », branche `reglage-tour-<numéro>`). En local, commandes dans le `README.md` ; faire tourner le régleur dans une copie (`git worktree`), puis recopier `data/`. Pour arrêter un processus, éviter `pkill -f` (il se tue lui-même) : passer par `ps aux | grep "[n]om"`.
- **Chaque retour de Gautier** : l'ajouter au tableau « Retours » ci-dessus ; chaque choix fait sans le GDD : une ligne dans `CLAUDE.md`.
