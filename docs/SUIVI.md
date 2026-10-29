# Suivi du projet

Mis à jour le **29 octobre 2026** (nuit : combat V2, étape 6). Ce fichier dit où en est le projet, ce qui attend Gautier et ce qui vient ensuite. Il est lu au début de chaque session (avec `CLAUDE.md`) et mis à jour à la fin de chaque PR. Les règles du jeu sont dans `docs/GDD.md`, les choix techniques et les chiffres dans `CLAUDE.md` (« Choix faits par Claude Code »).

## Où on en est

**Le combat V2, « l'Arbre vivant » (`docs/SPEC-COMBAT-V2.md`, validée par Gautier le 28 octobre) remplace tout le combat.** Le Destin devient une roue : un moyeu (l'action de base) et 5 voies de 4 nœuds, dont une Clé ; jouer, c'est avancer d'un nœud sur une voie ; les jalons, les nœuds éteints et les menaces se voient des deux côtés. La spécification répond aux questions 4 (stratégie du combat : on voit venir les Clés de l'adversaire et on peut y répondre) et 5 (l'Invocateur devient une classe de Dégâts). Le travail suit son plan en 8 étapes, une PR chacune. **Étapes 1 à 6 faites** (données des 10 classes et outil de budget ; le moteur de règles, qui joue un tour phase par phase ; le générateur de Destin et la roue à l'écran ; l'IA à score, le bestiaire transposé et la Tour sur le nouveau moteur ; le simulateur et le réglage : 5 des 6 critères d'équilibrage tenus sur des combats jamais vus, le sixième manqué d'une case, voir `docs/EQUILIBRAGE-V2.md` ; l'écran de combat de la section 12 : une seule arène, les six cases, la bande de la voie, les menaces, les fiches sur appui long, la fiche d'un perso). **Aperçu du combat V2** : https://josalystest1-sudo.github.io/projet-arena/v2/ (la roue du Destin, le combat en duel et la Tour ; la résolution animée et l'écran de fin arrivent à l'étape 7). Pendant les étapes 2 à 7, les PR vont sur la branche `combat-v2` : l'adresse de test garde l'ancien combat, jouable, jusqu'à l'étape 8.

Avant la V2 : les prototypes des étapes 1 à 3 de la feuille de route (combat en duo à 10 classes, Destin, Tour de 10 étages) étaient jouables et équilibrés au simulateur (PR #23 à #31).

**À tester :** https://josalystest1-sudo.github.io/projet-arena/ (mis à jour à chaque fusion sur `main`, une à deux minutes après).

## Feuille de route : avancement

| Étape | État | Détail |
| --- | --- | --- |
| 1. Prototype de combat en duo | **Fait, à valider** | PR #5 à #8, #10, #12, #14. Critère de sortie (« on a envie de relancer un combat ») pas encore confirmé par Gautier. |
| 2. La Tour en prototype | **Fait, à valider** | PR #9, #13 (monstres et bestiaire). Critère (« on veut battre son record ») pas encore confirmé. |
| 3. 10 classes, Destin, mini-Destin, Synergies | **Fait, à valider** | PR #17 à #23. Équilibrage des 10 classes et de la Tour vérifié sur des combats neufs (PR #23). |
| 4. Simulateur d'équilibrage | **Fait pour l'essentiel** | Duels et Tour : `tools/equilibrage.gd`, `tools/regleur.py`, `tools/simulate_tour.gd`, `tools/menace.py`, `tools/regleur_tour.py`, `tools/profil.gd`. Fait : les nœuds du Destin mesurés et réglés (PR #24). La Tour suit le niveau (PR #25). La durée des combats est dans la cible du GDD (PR #26). Les nœuds du Destin ont leur valeur par côté (PR #27). Reste : les Synergies hors fourchette (c'est leur effet à revoir), la durée des combats aux niveaux élevés. |
| **Combat V2** (avant l'étape 5) | **En cours** | Plan de `docs/SPEC-COMBAT-V2.md`, section 15 : 1. données et budget (**fait**, PR #34) ; 2. moteur de règles (**fait**, PR #35, sur `combat-v2`) ; 3. générateur et roue (**fait**, PR #37) ; 4. IA, bestiaire, Tour (**fait**, PR #38) ; 5. simulateur et équilibrage (**fait**, 5 critères sur 6, PR #39) ; 6. écran de combat (**fait**, PR #40) ; 7. résolution et fin ; 8. export web et test sur téléphone. |
| 5. Serveur, comptes, PvP réel, Échos | À faire | Pas avant l'étape 4. |
| 6. Art PixelLab et les 13 écrans | À faire | Sprites provisoires d'ici là. Les écrans existent déjà en version simple (création, rencontre, Vitrine, Acolyte, Compétences, La Tour, Bestiaire, Profil, Paramètres). |
| 7 à 10. Évolutions, boutique, bêta, lancement | À faire | |

## En attente de Gautier

1. **Les choix de la nuit du 28 au 29 octobre** (`docs/JOURNAL-COMBAT-V2.md`, lignes « à valider ») : les PV de toutes les classes à −60 % de la spécification pour tenir la médiane de 10 tours (la décision parlait de −40 %) ; l'étape 5 fusionnée avec 5 critères sur 6.
2. **Les critères de sortie** (le GDD dit de ne pas passer à l'étape suivante sans avoir testé la précédente sur téléphone) : ils seront à vérifier sur le combat V2, à l'étape 8 de son plan.
3. ~~Les kits qui ne frappent presque pas~~, ~~la Tour selon la classe~~, ~~la stratégie du combat~~, ~~l'Invocateur~~ : tranchés par la spécification du combat V2 (chaque Soutien a une voie de dégâts ; la Tour doit être aussi dure pour chaque classe, à 5 points près ; menaces visibles ; l'Invocateur est Dégâts).

Dernier retour : la spécification du combat V2, validée, avec la consigne de suivre son plan dans l'ordre et de ne pas s'arrêter après l'étape 5 avant que les six critères d'équilibrage soient tenus (28 octobre, soir).

## Prochaines tâches (dans l'ordre)

0. **Combat V2**, dans l'ordre de la section 15 de la spécification : ~~1. données et budget~~ (PR #34) ; ~~2. moteur de règles~~ (PR #35 : l'ancien moteur et ses tests supprimés) ; ~~3. générateur de Destin, écran de la roue~~ (PR #37, aperçu sur `/v2/` grâce à la PR #36) ; ~~4. IA, bestiaire, Tour~~ (PR #38) ; ~~5. simulateur, régleur et réglage~~ (PR #39 : 5 critères sur 6 ; le dernier, une case de la matrice à 61,1 %, est encore travaillé) ; ~~6. écran de combat~~ (PR #40) ; 7. résolution et fin de combat ; 8. export web et test sur téléphone. Ce qui suit (anciennes tâches) date du combat V1.
1. ~~Équilibrer les Destins séparément côté joueur et côté acolyte.~~ Fait (PR #16) : côté joueur 45,5–52,9 % (77 kits sur 96 dans 48–52), côté acolyte 45,9–53,8 % (83 sur 96), Tour reréglée.
2. **Étape 3**, en plusieurs PR :
   - ~~le moteur rendu générique~~ fait (PR #17) ;
   - les 7 classes manquantes, par groupes : ~~Voleur, Archer, Pugiliste~~ (PR #19) ; ~~Alchimiste, Barde, Diplomate~~ (PR #20) ; ~~l'Invocateur et sa créature~~ (PR #21) ; 6 actives et 4 passifs chacune, leurs Synergies (au moins une entre chaque classe et chaque classe qui peut lui servir d'acolyte, et chaque kit a une Synergie possible), avec tests ;
   - ~~le générateur de Destin (arbre de 45 nœuds, 30 points, budget de puissance), le mini-Destin de l'acolyte (15 nœuds, auto-attribué) et l'écran de l'arbre~~ (PR #22) ;
   - ~~un nouveau passage du régleur (duel et Tour) sur les 10 classes~~ (PR #23).
3. **Étape 4**, en plusieurs PR : ~~le simulateur avec Destin et le régleur des valeurs des nœuds~~ (PR #24) ; ~~la Tour qui suit le niveau du duo~~ (PR #25) ; ~~la durée des combats~~ (PR #26) ; ~~les valeurs du Destin propres à l'acolyte~~ (PR #27) ; ~~la durée des combats aux niveaux élevés~~ (PR #28, 83 %) ; ~~les Synergies mesurées par rapport aux kits, Golem + Prière~~ (PR #29) ; ~~les paires de kits~~ (PR #30 : toutes les Synergies dans la fourchette). Reste : les kits (31 à 65 % selon le côté), la Tour selon la classe (étage moyen de 5,5 à 9,3).
4. **Étape 5** (serveur, comptes, PvP réel, Échos) quand Gautier aura validé les critères de sortie des étapes 1 à 3 sur son téléphone.

## Limites connues

- **Après l'équilibrage des 10 classes (PR #23, puis PR #26, 48 000 combats neufs)** : classes 49,3–50,7 %, compositions 48,6–53,5 %, passifs et compétences dans la fourchette ; et depuis la PR #30 les 63 Synergies sont dans la fourchette par rapport aux kits (46,6–53,5 %) grâce à un ajustement par paire de kits plafonné à ±10 %. Kits : de 31 à 62 % selon le côté, 287 sur 625 dans 48–52 ; les plus bas sont des kits qui ne frappent presque pas (Diplomate Encouragement + Trêve + Discours, Alchimiste Élixir + Fumigène + Catalyseur). L'ajustement d'un kit est plafonné à ±25 % : au-delà, c'est la conception.
- **Le réglage automatique a trois pièges connus** (tous corrigés dans PR #23, voir `CLAUDE.md`) : des ajustements qui s'additionnent sur un même kit, un levier où un chiffre plus grand affaiblit (Charisme, Esquive), un chiffre à virgule arrondi en entier (la part de puissance des créatures). Toujours vérifier sur des combats neufs avant de fusionner.
- **Cycle entre compositions** (mesuré à 3 classes) : Guerrier + Mage bat Mage + Prêtre 55 %, Mage + Prêtre bat Guerrier + Prêtre 56 %, Guerrier + Prêtre bat Guerrier + Mage 55 %. La force d'un duo ne peut pas le corriger. Le Guerrier + Prêtre gagne surtout au décompte des PV : piste de la mort subite (étape 4). À remesurer à 10 classes (les affrontements vont de 43 à 55 %).
- **Le pilier « le duo gagne »** n'est pas encore démontré au simulateur : un joueur IA qui lit l'annonce de son acolyte gagne 52,9 % contre un qui l'ignore. Il faudra une IA qui prépare ses coups sur plusieurs tours (étape 4), et surtout le ressenti de Gautier.
- **La Tour selon la classe** : étage moyen atteint, de 5,4 (Barde) à 9,2 (Prêtre) ; les Soutiens qui frappent peu montent moins haut. Le record étant par classe, ce n'est pas bloquant, mais l'écart a grandi avec les 10 classes.
- **Durée des combats** : 90,5 % entre les tours 8 et 15 sans Destin (PR #26, +15 % de PV) ; avec le Destin aux niveaux 1 à 30, 83 % (PR #28 : nœuds défensifs renforcés, nœuds d'attaque adoucis ; 76 % avant). Le reste viendra d'un plafonnement global des bonus d'attaque de l'arbre, à voir avec les évolutions (étape 7).
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
| 28 oct, après-midi | « Le jeu est pas mal » ; « pour l'Invocateur on ne voit pas ses invocations » | La créature n'a qu'une barre de PV et des textes : un sprite à côté de son maître est prévu, à vérifier à l'écran avec Gautier. |
| 28 oct, après-midi | « Pourquoi l'Invocateur se retrouve avec un Archer en acolyte ? » | Le GDD classe l'Invocateur en Front (sa créature encaisse) : un Front reçoit un Dégâts ou un Soutien. Question posée : le rebasculer en Dégâts ? |
| 28 oct, après-midi | « Pas très stratégique : on fait son attaque la plus puissante quand elle est dispo, si on est assez fort ça passe, sinon jamais ; il manque la sensation "il faut que je réfléchisse pour ce combat" » | Diagnostic : rien à anticiper, puisqu'on ne voit jamais ce que l'ennemi a choisi. Deux pistes proposées : (1) les fortes se chargent et s'annoncent un tour à l'avance (pour tous, PvP compris) ; (2) les ennemis de l'IA annoncent leur coup comme l'acolyte (Tour et duos IA). En attente de son choix. |
| 28 oct, soir | Spécification du combat V2 « l'Arbre vivant », validée : « applique son plan dans l'ordre, une PR par étape, n'invente rien, note les choix dans le journal » | Étape 1 (PR #34) : données des 10 classes recopiées de la spécification, tous les nœuds dans leur budget. |
| 28 oct, soir | Trois critères d'équilibrage impossibles avec les seuls boutons de la spécification (durée, route Éventail, Tour) : « On vise 10 » (tours) ; Éventail « seulement pas plus de 55 % » ; « Difficulté propre à la Tour » | PV de toutes les classes jusqu'à −40 % ; plus de plancher pour Éventail ; la force des monstres monte avec les étages, avec un facteur par classe, réglée au simulateur (étape 5). |
| 28 oct, soir | Ruée et Éventail : « Repères, plus critères » | Les deux routes sont mesurées et affichées sans seuil ; le critère 3 porte sur la route Réactive. |
| 28 oct, nuit | « Je vais me coucher, travaille le plus possible et prends les décisions par toi-même, compte rendu demain matin » | Étape 5 finie (le k de chaque classe réglé en tenant compte de son acolyte ; mesures plus grosses ; 5 critères sur 6 sur des combats jamais vus), puis les étapes 6 et 7. Choix notés dans le journal, marqués « à valider ». |

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
| #27 | 28 oct | Le Destin par côté : un facteur par modèle de nœud pour le mini-Destin de l'acolyte (`mini_strength`), régleur qui mesure joueur et acolyte séparément et par rapport à la classe, valeurs reréglées. |
| #28 | 28 oct | Les nœuds de PV, de réduction et de régénération du Destin pèsent plus, pour que les combats restent dans la cible aux niveaux élevés ; valeurs reréglées. |
| #29 | 28 oct | Les Synergies mesurées par rapport aux deux kits du duo ; le joueur IA ne joue plus une protection ou un soin pour une Synergie sans besoin (Golem + Prière nuisait) ; outil de diagnostic d'une Synergie ; reréglage. |
| #30 | 28 oct | Un ajustement par paire de kits qui a une Synergie possible (`synergy_pairs`, plafonné à ±10 %), réglé sur l'écart de la Synergie aux kits ; reréglage. |
| #31 | 28 oct | La Tour revérifiée et reréglée après les réglages de la journée (6,0 % au sommet). |
| #32 | 28 oct | Suivi de fin de journée : questions à poser à Gautier (kits qui ne frappent pas, Tour selon la classe). |
| #33 | 28 oct | Retours de Gautier après ses tests sur téléphone (stratégie du combat, Invocateur, invocations invisibles) et les pistes proposées. |
| — | 28 oct | Spécification du combat V2 (`docs/SPEC-COMBAT-V2.md`) et journal des choix. |
| #34 | 28 oct | Combat V2, étape 1 : données (règles, 16 états, textes, 10 classes en roues de 5 voies), budget de chaque nœud vérifié en CI (`tools/budget.gd`), tests 1 à 4. Anciennes données dans `data/v1/`. |
| #35 | 28 oct | Combat V2, étape 2 (sur `combat-v2`) : le moteur de règles (`engine/regles.gd`, `engine/etat_combat.gd`, `engine/destin.gd`) : actions légales, menaces, Synergies, phases 2a à 2i, journal d'événements ; tests 11 à 36. L'ancien moteur, ses tests et ses données supprimés. |
| #36 | 28 oct | Publication : un aperçu de la branche `combat-v2` sous `/v2/`, à chaque fusion sur elle (le jeu actuel reste à la racine). |
| #37 | 28 oct | Combat V2, étape 3 (sur `combat-v2`) : le générateur de Destin (formes Base, Diffuse, Concentrée, Persistante, Vive, neutres en budget ; allumage ; acolyte), les textes générés (`engine/texte.gd`), la roue du Destin à l'écran, l'application rebranchée sur le Destin V2 ; tests 5 à 10 et 45 ; outil de captures `tools/capture.gd`. |
| #38 | 28 oct | Combat V2, étape 4 (sur `combat-v2`) : l'IA à score (`engine/ia.gd`), le bestiaire transposé (14 monstres : une classe, des voies, un multiplicateur de PV), la Tour sur le nouveau moteur (`engine/tour.gd`, `data/tour.json`) ; tests 37 à 40 et 46 à 48. |

## Reprendre le travail (pour Claude Code)

- **Branche de travail** : celle indiquée par la session. Le force-push est refusé : pour se mettre à jour, `git merge origin/main` (pas de rebase). Les PR se fusionnent en « squash » avec le SHA complet (40 caractères) de leur dernier commit.
- **Sur le PC de Gautier (Windows, 28 cœurs)** : le dépôt est dans `C:/Users/Gautier/Documents/projet-arena`, Godot 4.5 dans `C:/Users/Gautier/godot/godot_console.exe` (la version console écrit dans le terminal ; `godot.exe` à côté). Les simulations longues tournent là, gratuitement, plus vite que sur GitHub : 24 processus Godot en parallèle (une passe de 400 000 combats en 6 minutes, une passe de 20 000 montées en 2 minutes). **GitHub CLI** est dans `C:/Users/Gautier/gh/gh.exe` (version portable, connecté au compte josalystest1-sudo avec les droits `repo` et `workflow` ; si la connexion est perdue : `gh auth login --web`, le code s'entre depuis n'importe quel appareil sur github.com/login/device). Les PR se créent avec `gh pr create --body-file`, se fusionnent avec `gh pr merge <n> --squash --match-head-commit <sha complet>` ; après un squash sur `main`, une branche qui contenait les commits d'origine a des conflits de forme : `git merge main`, puis garder la version de la branche (`git checkout --ours`) pour les fichiers en conflit si la branche est un sur-ensemble. Une **copie de travail** (`git worktree`) est dans `C:/Users/Gautier/Documents/projet-arena-wt` pour développer pendant qu'une simulation tourne dans le dépôt principal (ne jamais changer de branche dans un dossier où Godot simule). Les scripts de simulation de la journée du 28 octobre (réglage des duels sur 24 processus, Tour, Destin, Tour par niveau, durée des combats) étaient dans le brouillon de la session ; les commandes équivalentes sont dans le `README.md`. Toujours **un seul Claude** (pas d'agents en parallèle, pas de session cloud).
- **Godot 4.5** : s'il manque dans le conteneur, l'installer comme la CI (`.github/workflows/tests.yml`, dans `~/godot/godot`) ; pour l'export web, les modèles d'export comme dans `.github/workflows/web.yml`.
- **Combat V2** : les étapes 2 à 7 se font sur des branches tirées de `combat-v2` et fusionnées dans `combat-v2` (`gh pr create --base combat-v2`) ; l'étape 8 fusionne `combat-v2` sur `main`. Sur `combat-v2`, les anciens écrans et les anciens outils de simulation ne marchent plus (ils seront refaits aux étapes 3 à 7) ; l'import du projet affiche leurs erreurs sans échouer.
- **Voir un écran sans téléphone** : `godot --path . --script res://tools/capture.gd -- <dossier> '<étapes JSON>'` ouvre l'application dans une fenêtre 540 × 960, joue des étapes (créer un perso, monter de niveau, allumer, changer d'écran, toucher, appui long) et prend des captures, avec un profil à part (mode d'emploi en tête du fichier).
- **Tests** (49 au 28 octobre au soir, combat V2) : `~/godot/godot --headless --path . --script res://tests/run_tests.gd`. Trois tests comparent des dégâts à l'arrondi près : les chiffres réglés par le simulateur changent les arrondis.
- **Voir le jeu comme Gautier** : exporter (`~/godot/godot --headless --path . --export-release "Web" build/web/index.html`), servir `build/web` (`python3 -m http.server 8765`), puis piloter et capturer avec `node tools/navigateur.js` (souris ou doigt, hauteur de téléphone réglable ; mode d'emploi en tête du fichier). Ajouter `?graine=7` à l'adresse rejoue toujours les mêmes tirages.
- **Équilibrage** : sur le PC de Gautier (voir ci-dessus) ou sur GitHub (onglet Actions → « Réglage de l'équilibrage », choisir la branche de départ ; à la fin, une branche `reglage-<numéro>` porte les données réglées et le résumé du run donne le rapport ; même chose pour la Tour avec « Réglage de la Tour », branche `reglage-tour-<numéro>`). **Vérifier toujours le résultat sur des combats neufs avant de fusionner** : le run 2 de GitHub (6 passes, 10 classes) avait divergé (kits de 6 à 94 %) sans que rien ne le dise. En local, commandes dans le `README.md` ; faire tourner le régleur dans une copie (`git worktree`), puis recopier `data/`. Pour arrêter un processus, éviter `pkill -f` (il se tue lui-même) : passer par `ps aux | grep "[n]om"` (sous Windows : `Get-Process Godot* | Stop-Process`).
- **Chaque retour de Gautier** : l'ajouter au tableau « Retours » ci-dessus ; chaque choix fait sans le GDD : une ligne dans `CLAUDE.md`.
