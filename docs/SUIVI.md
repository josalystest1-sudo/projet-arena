# Suivi du projet

Mis à jour le **28 octobre 2026** (fin de matinée). Ce fichier dit où en est le projet, ce qui attend Gautier et ce qui vient ensuite. Il est lu au début de chaque session (avec `CLAUDE.md`) et mis à jour à la fin de chaque PR. Les règles du jeu sont dans `docs/GDD.md`, les choix techniques et les chiffres dans `CLAUDE.md` (« Choix faits par Claude Code »).

## Où on en est

Les prototypes des étapes 1 à 3 sont jouables sur téléphone : le **combat en duo** (ton perso et ton acolyte contre un duo IA, **10 classes**, le Destin et le mini-Destin) et **la Tour** (10 étages de monstres). Les 10 classes et la Tour sont **équilibrées au simulateur** (PR #23 : classes entre 48 et 52 %, vérifié sur 48 000 combats neufs). L'étape 4 (le simulateur complet) est entamée : il tourne sur le PC de Gautier, 3,4 fois plus vite qu'avant.

**À tester :** https://josalystest1-sudo.github.io/projet-arena/ (mis à jour à chaque fusion sur `main`, une à deux minutes après).

## Feuille de route : avancement

| Étape | État | Détail |
| --- | --- | --- |
| 1. Prototype de combat en duo | **Fait, à valider** | PR #5 à #8, #10, #12, #14. Critère de sortie (« on a envie de relancer un combat ») pas encore confirmé par Gautier. |
| 2. La Tour en prototype | **Fait, à valider** | PR #9, #13 (monstres et bestiaire). Critère (« on veut battre son record ») pas encore confirmé. |
| 3. 10 classes, Destin, mini-Destin, Synergies | **Fait, à valider** | PR #17 à #23. Équilibrage des 10 classes et de la Tour vérifié sur des combats neufs (PR #23). |
| 4. Simulateur d'équilibrage | **En cours** | Duels et Tour : `tools/equilibrage.gd`, `tools/regleur.py`, `tools/simulate_tour.gd`, `tools/menace.py`, `tools/regleur_tour.py`, `tools/profil.gd`. Fait : les nœuds du Destin mesurés et réglés (PR #24). La Tour suit le niveau (PR #25). La durée des combats est dans la cible du GDD (PR #26). Les nœuds du Destin ont leur valeur par côté (PR #27). Reste : les Synergies hors fourchette (c'est leur effet à revoir), la durée des combats aux niveaux élevés. |
| 5. Serveur, comptes, PvP réel, Échos | À faire | Pas avant l'étape 4. |
| 6. Art PixelLab et les 13 écrans | À faire | Sprites provisoires d'ici là. Les écrans existent déjà en version simple (création, rencontre, Vitrine, Acolyte, Compétences, La Tour, Bestiaire, Profil, Paramètres). |
| 7 à 10. Évolutions, boutique, bêta, lancement | À faire | |

## En attente de Gautier

1. **Les critères de sortie** (le GDD dit de ne pas passer à l'étape suivante sans avoir testé la précédente sur téléphone) : après quelques combats, as-tu envie d'en relancer un ? À la Tour, as-tu envie de battre ton record ?

Dernier retour : feu vert pour rééquilibrer les Destins puis attaquer l'étape 3 (28 octobre).

## Prochaines tâches (dans l'ordre)

1. ~~Équilibrer les Destins séparément côté joueur et côté acolyte.~~ Fait (PR #16) : côté joueur 45,5–52,9 % (77 kits sur 96 dans 48–52), côté acolyte 45,9–53,8 % (83 sur 96), Tour reréglée.
2. **Étape 3**, en plusieurs PR :
   - ~~le moteur rendu générique~~ fait (PR #17) ;
   - les 7 classes manquantes, par groupes : ~~Voleur, Archer, Pugiliste~~ (PR #19) ; ~~Alchimiste, Barde, Diplomate~~ (PR #20) ; ~~l'Invocateur et sa créature~~ (PR #21) ; 6 actives et 4 passifs chacune, leurs Synergies (au moins une entre chaque classe et chaque classe qui peut lui servir d'acolyte, et chaque kit a une Synergie possible), avec tests ;
   - ~~le générateur de Destin (arbre de 45 nœuds, 30 points, budget de puissance), le mini-Destin de l'acolyte (15 nœuds, auto-attribué) et l'écran de l'arbre~~ (PR #22) ;
   - ~~un nouveau passage du régleur (duel et Tour) sur les 10 classes~~ (PR #23).
3. **Étape 4**, en plusieurs PR : ~~le simulateur avec Destin et le régleur des valeurs des nœuds~~ (PR #24) ; ~~la Tour qui suit le niveau du duo~~ (PR #25) ; ~~la durée des combats~~ (PR #26) ; ~~les valeurs du Destin propres à l'acolyte~~ (PR #27) ; les Synergies encore hors fourchette (revoir leur effet, voir « Limites connues ») ; la durée des combats aux niveaux élevés.

## Limites connues

- **Après l'équilibrage des 10 classes (PR #23, puis PR #26, 48 000 combats neufs)** : classes 49,3–50,7 %, compositions 48,6–53,5 %, passifs et compétences dans la fourchette ; mais 10 Synergies sur 63 restent en dehors (de 30 à 63 %), la plupart à la borne de leur levier : c'est leur effet qu'il faut revoir, pas leur chiffre. Kits : de 31 à 62 % selon le côté, 287 sur 625 dans 48–52 ; les plus bas sont des kits qui ne frappent presque pas (Diplomate Encouragement + Trêve + Discours, Alchimiste Élixir + Fumigène + Catalyseur). L'ajustement d'un kit est plafonné à ±25 % : au-delà, c'est la conception.
- **Le réglage automatique a trois pièges connus** (tous corrigés dans PR #23, voir `CLAUDE.md`) : des ajustements qui s'additionnent sur un même kit, un levier où un chiffre plus grand affaiblit (Charisme, Esquive), un chiffre à virgule arrondi en entier (la part de puissance des créatures). Toujours vérifier sur des combats neufs avant de fusionner.
- **Cycle entre compositions** (mesuré à 3 classes) : Guerrier + Mage bat Mage + Prêtre 55 %, Mage + Prêtre bat Guerrier + Prêtre 56 %, Guerrier + Prêtre bat Guerrier + Mage 55 %. La force d'un duo ne peut pas le corriger. Le Guerrier + Prêtre gagne surtout au décompte des PV : piste de la mort subite (étape 4). À remesurer à 10 classes (les affrontements vont de 43 à 55 %).
- **Le pilier « le duo gagne »** n'est pas encore démontré au simulateur : un joueur IA qui lit l'annonce de son acolyte gagne 52,9 % contre un qui l'ignore. Il faudra une IA qui prépare ses coups sur plusieurs tours (étape 4), et surtout le ressenti de Gautier.
- **La Tour selon la classe** : étage moyen atteint, de 5,7 (Barde) à 9,2 (Prêtre) ; les Soutiens qui frappent peu montent moins haut. Le record étant par classe, ce n'est pas bloquant, mais l'écart a grandi avec les 10 classes.
- **Durée des combats** : 90,5 % entre les tours 8 et 15 depuis la PR #26 (+15 % de PV). Mais avec le Destin aux niveaux élevés, les combats raccourcissent (35 % finis avant le tour 8 aux niveaux 1 à 30, mesuré avant la PR #26) : les nœuds de puissance pèsent plus que ceux de PV. À remesurer, puis corriger du côté des nœuds.
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
| 28 oct | « Pas de crédits cloud : la solution la plus rapide, performante et gratuite » | Un seul Claude à la fois (plus d'agents en parallèle) ; les simulations longues sur les machines de GitHub, gratuites pour un dépôt public (PR #18). |
| 28 oct | « Il me reste 22 $ de crédit, ça continue de baisser » | Les machines de GitHub sont gratuites, mais chaque échange avec Claude coûte, d'autant plus que la conversation est longue. Session arrêtée ; reprise le lendemain sur le PC de Gautier. |
| 28 oct | « Tu as la journée jusqu'à 17 h pour avancer le plus possible » ; « est-ce qu'il n'y a pas moyen d'aller plus vite tout en restant local ? » ; « ne sacrifie pas la performance au profit de la rapidité » | Les simulations tournent sur son PC (24 processus) ; le simulateur rendu 3,4 fois plus rapide sans changer un résultat (PR #23) ; les passes de réglage gardent leurs 400 000 combats. |
| 28 oct | Fermeture de League of Legends et d'Overwolf pendant les calculs | Gain d'environ 10 % : la simulation occupait déjà 22 cœurs sur 28. |

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
| #23 | 28 oct | Équilibrage des 10 classes et de la Tour (sur le PC de Gautier) ; régleur simplifié et trois pièges corrigés ; plafond ±25 % ; Encouragement frappe aussi ; simulateur 3,4 fois plus rapide. |
| #24 | 28 oct | Le simulateur avec Destin (niveau, points placés au hasard, nœuds pris dans le CSV), le régleur des valeurs des nœuds, les valeurs réglées, bouton « Réglage du Destin » sur GitHub. |
| #25 | 28 oct | La Tour suit le niveau du duo : monstres renforcés de 2,2 % par niveau, calibré au simulateur (même part au sommet du niveau 0 au niveau 30). |
| #26 | 28 oct | Durée des combats : +15 % de PV pour toutes les classes (90,5 % des combats entre les tours 8 et 15, cible du GDD), reréglage des classes et de la Tour. |
| #27 | 28 oct | Le Destin par côté : un facteur par modèle de nœud pour le mini-Destin de l'acolyte (`mini_values`), régleur qui mesure joueur et acolyte séparément, valeurs reréglées. |

## Reprendre le travail (pour Claude Code)

- **Branche de travail** : celle indiquée par la session. Le force-push est refusé : pour se mettre à jour, `git merge origin/main` (pas de rebase). Les PR se fusionnent en « squash » avec le SHA complet (40 caractères) de leur dernier commit.
- **Sur le PC de Gautier (Windows, 28 cœurs)** : le dépôt est dans `C:/Users/Gautier/Documents/projet-arena`, Godot 4.5 dans `C:/Users/Gautier/godot/godot_console.exe` (la version console écrit dans le terminal ; `godot.exe` à côté). Les simulations longues tournent là, gratuitement, plus vite que sur GitHub : 24 processus Godot en parallèle (une passe de 400 000 combats en 6 minutes, une passe de 20 000 montées en 2 minutes). **GitHub CLI** est dans `C:/Users/Gautier/gh/gh.exe` (version portable, connecté au compte josalystest1-sudo avec les droits `repo` et `workflow` ; si la connexion est perdue : `gh auth login --web`, le code s'entre depuis n'importe quel appareil sur github.com/login/device). Les PR se créent avec `gh pr create --body-file`, se fusionnent avec `gh pr merge <n> --squash --match-head-commit <sha complet>` ; après un squash sur `main`, une branche qui contenait les commits d'origine a des conflits de forme : `git merge main`, puis garder la version de la branche (`git checkout --ours`) pour les fichiers en conflit si la branche est un sur-ensemble. Une **copie de travail** (`git worktree`) est dans `C:/Users/Gautier/Documents/projet-arena-wt` pour développer pendant qu'une simulation tourne dans le dépôt principal (ne jamais changer de branche dans un dossier où Godot simule). Les scripts de simulation de la journée du 28 octobre (réglage des duels sur 24 processus, Tour, Destin, Tour par niveau, durée des combats) étaient dans le brouillon de la session ; les commandes équivalentes sont dans le `README.md`. Toujours **un seul Claude** (pas d'agents en parallèle, pas de session cloud).
- **Godot 4.5** : s'il manque dans le conteneur, l'installer comme la CI (`.github/workflows/tests.yml`, dans `~/godot/godot`) ; pour l'export web, les modèles d'export comme dans `.github/workflows/web.yml`.
- **Tests** (169 au 28 octobre) : `~/godot/godot --headless --path . --script res://tests/run_tests.gd`. Trois tests comparent des dégâts à l'arrondi près : les chiffres réglés par le simulateur changent les arrondis.
- **Voir le jeu comme Gautier** : exporter (`~/godot/godot --headless --path . --export-release "Web" build/web/index.html`), servir `build/web` (`python3 -m http.server 8765`), puis piloter et capturer avec `node tools/navigateur.js` (souris ou doigt, hauteur de téléphone réglable ; mode d'emploi en tête du fichier). Ajouter `?graine=7` à l'adresse rejoue toujours les mêmes tirages.
- **Équilibrage** : sur le PC de Gautier (voir ci-dessus) ou sur GitHub (onglet Actions → « Réglage de l'équilibrage », choisir la branche de départ ; à la fin, une branche `reglage-<numéro>` porte les données réglées et le résumé du run donne le rapport ; même chose pour la Tour avec « Réglage de la Tour », branche `reglage-tour-<numéro>`). **Vérifier toujours le résultat sur des combats neufs avant de fusionner** : le run 2 de GitHub (6 passes, 10 classes) avait divergé (kits de 6 à 94 %) sans que rien ne le dise. En local, commandes dans le `README.md` ; faire tourner le régleur dans une copie (`git worktree`), puis recopier `data/`. Pour arrêter un processus, éviter `pkill -f` (il se tue lui-même) : passer par `ps aux | grep "[n]om"` (sous Windows : `Get-Process Godot* | Stop-Process`).
- **Chaque retour de Gautier** : l'ajouter au tableau « Retours » ci-dessus ; chaque choix fait sans le GDD : une ligne dans `CLAUDE.md`.
