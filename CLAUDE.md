# Projet Arena — référence pour Claude Code

Ce fichier et `PROGRESS.md` suffisent pour reprendre le projet. `CLAUDE.md` dit **ce qu'est le jeu, comment le code est fait, ce qui a été décidé et les pièges à éviter**. `PROGRESS.md` dit **où on en est** : ce qui est fait, ce qui est en cours, ce qui reste à faire et les bugs connus. Les documents de `docs/` donnent le détail ; quand ils se contredisent, l'ordre d'autorité est indiqué au § 4.

État au **29 octobre 2026, soir** : `main` = `5dafe1b` (PR #57). Jeu publié : https://josalystest1-sudo.github.io/projet-arena/

---

## 1. Le propriétaire et la façon de travailler

- **Gautier** est le propriétaire. Il ne lit pas de code et n'utilise jamais de terminal. Il travaille depuis l'app Claude, souvent sur son téléphone (Remote Control). On lui parle **en français**, sans jargon.
- **Fin de chaque session** : expliquer ce qui a été fait en langage courant, et lui donner quelque chose à tester sur son téléphone (l'adresse ci-dessus, se met à jour 1 à 2 minutes après chaque fusion sur `main`). Ne jamais lui demander de taper une commande. Si une action manuelle est indispensable, la décrire bouton par bouton.
- **Une PR par étape**, petite, titre et description en français, fusionnée en « squash » sur `main` quand les tests passent. Claude fusionne lui-même ; Gautier a approuvé ce mode de travail.
- **Décision de Gautier du 29 octobre (soir) : construire tout le jeu d'abord, sans équilibrage en route ; l'équilibrage global vient ensuite (phase 9), puis les graphismes (phase 10).** Pas de passes de réglage ni de critère de taux de victoire pour finir une PR. Seuls garde-fous : les tests passent, aucun combat ne s'éternise, la Tour n'est ni impossible ni triviale. Le jeu publié peut être déséquilibré : le lui dire.
- **Quand le GDD V2 ne dit rien** : demander l'avis de Gautier (outil AskUserQuestion), avec une proposition argumentée et l'option recommandée en premier. Si la question ne bloque pas, avancer avec la proposition. Noter le choix dans `docs/JOURNAL-COMBAT-V2.md` et, s'il change le GDD, dans `docs/GDD_V2.md` (étiquette **[Décidé]** + date quand Gautier a tranché).
- À chaque PR, mettre à jour `PROGRESS.md` (et `docs/SUIVI.md`, l'historique des retours et des PR), et noter tout choix fait hors des documents dans `docs/JOURNAL-COMBAT-V2.md`.
- Commits : terminer par `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`. Descriptions de PR : terminer par `🤖 Generated with [Claude Code](https://claude.com/claude-code)`. Identité git par variables d'environnement : `GIT_AUTHOR_NAME=Claude GIT_AUTHOR_EMAIL=noreply@anthropic.com GIT_COMMITTER_NAME=Claude GIT_COMMITTER_EMAIL=noreply@anthropic.com`.
- **Un seul Claude à la fois** : pas de session cloud (Gautier ne veut pas de crédits cloud).

## 2. Le jeu

RPG mobile en pixel art, **tout en mode portrait**, tour par tour **simultané**, **sans aucun hasard en combat**. Nom provisoire « Projet Arena » ; l'univers et le nom ne sont pas choisis.

- **Un seul personnage par compte**, d'une des **10 classes** : Guerrier, Pugiliste (Front) ; Mage, Voleur, Archer, Invocateur (Dégâts) ; Prêtre, Alchimiste, Barde, Diplomate (Soutien). Plus tard, 3 évolutions par classe (30), puis 3 par évolution (90), et des classes de grimoire (boss de donjon). Une évolution peut changer le rôle de sa classe.
- **Le trio** : on joue toujours à 3 (Front + Dégâts + Soutien). Le joueur occupe la case de son rôle ; les deux autres sont des **Échos**, des personnages pilotés par l'IA (plus tard ceux de vrais joueurs ; pour l'instant proposés par le jeu). Le joueur ne leur donne jamais d'ordre. **Tous les combats sont en 3 contre X** : 3 en face en PvP, de 1 à 6 monstres en PvE. L'ancien duo joueur + acolyte n'existe plus à l'écran ; le moteur sait encore jouer des camps de 2 (tests, simulateur).
- **Le Destin** (combat V2, « l'Arbre vivant », `docs/SPEC-COMBAT-V2.md`) : chaque perso a une roue. Au centre, le **moyeu** (action de base, toujours jouable : c'est aussi le **geste de la classe**). Autour, **5 voies** de 4 nœuds : N1 (ouverture), N2, N3, **Clé** (le gros coup). Chaque voie a 5 **éclats** (petits bonus passifs). Les voies sont fixes par classe ; chaque nœud a une **forme** tirée une fois à la création, avec la graine (Base, Diffuse, Concentrée, Persistante, Vive) : c'est le seul hasard du jeu. À la création, le moyeu et les 5 N1 sont allumés ; ensuite un point par niveau (30 niveaux), à placer sur un nœud ou un éclat, sans retour possible.
- **Un tour** : chacun joue une action (le moyeu, ou le nœud suivant d'une voie). Le nœud joué s'**éteint** pendant 3 tours. Chaque voie garde un **jalon** (le dernier rang joué) ; une voie non jouée pendant 2 tours **refroidit** (le jalon recule) ; jouer la Clé remet la voie à zéro. Les Échos **annoncent leur action en premier** (le second connaît le premier), puis le joueur choisit (20 s en PvP, sans limite à la Tour). Tout se résout ensuite en même temps (phases 2a à 2i) ; **les KO sont constatés en fin de tour**, après les soins.
- **16 états** (Étourdi, Gelé, Silencié, Enraciné, Aveuglé, Désarmé, Provoqué, Égaré, Saignement, Brûlure, Poison, Familier, Gardien, Barrière, Renfort, Affaiblissement), qui agissent à partir du tour suivant (sauf Égaré, immédiat).
- **4 Synergies universelles**, entre deux membres d'un même camp qui jouent le même tour : Brisure (contrôle + dégâts sur la même cible : dégâts ×1,25), Embrasement (deux DoT sur la même cible : +1 tour), Bastion (barrière + soin sur le même allié : barrière ×1,3), Harmonie (Renfort + dégâts : Renfort +1 tour).
- **L'adversaire est caché** : on ne voit de lui que son nom, sa classe, ses PV et ses états. Seul signal : une lueur et l'étiquette « CLÉ PRÊTE » quand une de ses Clés est jouable. On découvre ses sorts en le regardant jouer ; sa fiche liste ce qu'on l'a vu jouer.
- **Durée** : environ 20 tours par duel. En PvP, la mort subite commence au tour 18 (+20 % de dégâts par tour). En PvE, pas de limite de tours.
- **La Tour** : infinie, de force fixe (un étage a la même force pour tout le monde ; c'est le niveau du joueur qui le fait monter plus haut). Un Gardien tous les 5 étages ; une fois franchi, on reprend après lui (palier). Record par classe.
- **Prévu** (GDD V2) : Faveurs de la Tour, équipement « à la Diablo » sans méta (Forge, butin lié ou échangeable), deux monnaies (Éclats liés, Or échangeable), ville à bâtiments en portrait, serveur (comptes, vrais Échos, PvP asynchrone classé 5 par jour, Marché), guildes, donjons à routes secrètes et boss unique au serveur, territoires et guerres du soir, PvP synchrone à 6, cosmétiques seulement (jamais de puissance vendue).

## 3. Stack, environnement et commandes

- **Godot 4.5 stable**, GDScript, rendu Compatibility, export web **sans threads** (GitHub Pages n'accepte pas les en-têtes requis par les threads). Fenêtre de référence 540 × 960, `stretch canvas_items / expand`. Scène de départ : `scenes/app/app.tscn`.
- **Le PC de Gautier** (Windows 11, 28 cœurs) : dépôt `C:/Users/Gautier/Documents/projet-arena` ; Godot `C:/Users/Gautier/godot/godot_console.exe` (sortie dans le terminal ; `godot.exe` à côté pour les fenêtres) ; GitHub CLI portable `C:/Users/Gautier/gh/gh.exe` (connecté au compte josalystest1-sudo, droits `repo` et `workflow`). Outil Bash = Git Bash (chemins `/c/Users/...`) ; outil PowerShell = Windows PowerShell 5.1.
- **Commandes** (depuis la racine d'une copie de travail) :
  - importer (obligatoire dans une copie neuve, et après avoir ajouté un script à `class_name`) : `godot_console.exe --headless --path . --import`
  - tests (79 au 29 octobre) : `godot_console.exe --headless --path . --script res://tests/run_tests.gd`
  - budget des nœuds (210 nœuds dans ±6 %) : `godot_console.exe --headless --path . --script res://tools/budget.gd`
  - simulateur, un travailleur : `godot_console.exe --headless --path . --script res://tools/equilibrage.gd -- simuler <matrice|routes|tour|bon_sens> <part> <parts> <n> <graine0> <sortie.json> [duo|trio] [section10]`, puis le rapport : `-- rapport <dossier> <rapport.md> <resume.json> "<titre>"`. En parallèle : 24 processus en arrière-plan (`&` puis `wait`).
  - captures au format téléphone : `godot.exe --path . --script res://tools/capture.gd -- <dossier> '<étapes JSON>'` (étapes : `{"creer":"mage"}`, `{"niveau":12}`, `{"ecran":"trio"}`, `{"duel":1}`, `{"montee":1}`, `{"fin":1}`, `{"clic":[x,y]}`, `{"appui":[x,y,s]}`, `{"tenir":[x,y,s,"nom"]}`, `{"attendre":0.5}`, `{"capture":"nom"}` ; en 540 × 960 : la case du moyeu est en (95, 855), on la touche deux fois pour la jouer).
- **PR et fusion** : `gh.exe pr create --base main --head <branche> --title "…" --body-file <fichier>`, puis `gh.exe pr checks <n> --watch`, puis `gh.exe pr merge <n> --squash --match-head-commit <sha complet>`. L'outil de l'app `bind_pr` échoue (le gh de l'app n'est pas connecté) : passer par le gh portable.
- **CI** : `.github/workflows/tests.yml` (sur chaque PR et chaque push sur `main` : import, tests, budget) ; `.github/workflows/web.yml` (sur push sur `main` : tests, budget, export web, publication GitHub Pages ; il publie aussi un aperçu de la branche `combat-v2` sous `/v2/` si elle existe, ce qui est un reste de la migration du combat V2).
- **Copies de travail** : une par PR (`git worktree add -b <branche> ../arena-<nom> main`). Ne jamais changer de branche dans le dossier principal pendant qu'une simulation y tourne.
- **Vérifier le jeu publié** : navigateur intégré (outils `mcp__Claude_Browser__*`), format `mobile` (375 × 812), adresse terminée par `?graine=7` (tirages reproductibles). Remettre le format `desktop` ensuite.

## 4. Les documents et leur autorité

| Fichier | Contenu | Autorité |
| --- | --- | --- |
| `CLAUDE.md` | Ce fichier : jeu, code, décisions, pièges. | Référence de travail. |
| `PROGRESS.md` | Fait / en cours / à faire / bugs. | État du projet. |
| `docs/GDD_V2.md` | Le jeu (trio, Échos, Tour infinie, PvP, donjons, guildes, équipement, économie, ville). Règles étiquetées [Décidé] / [Proposé] / [Ouvert]. | **Fait foi sur le format du jeu.** Son § 4.1 (recharges, mort subite au tour 8), ses « 63 Synergies » et « 6 actives + 4 passifs » décrivent l'ancien combat : **caducs**. |
| `docs/SPEC-COMBAT-V2.md` | Les règles d'un combat : roue, voies, jalons, états, résolution phase par phase, budget, IA à score, simulateur. | **Fait foi sur les règles d'un combat**, sauf ce que Gautier a décidé depuis (journal) : 20 tours, mort subite au tour 18, adversaire caché, trio, Soutiens presque sans dégâts, Tour absolue. |
| `docs/PLAN.md` | Le plan de développement, PR par PR, phases 1 à 10. En tête : la décision « construire puis équilibrer » et le raccord avec le combat V2 (les fichiers cités par les PR d'origine sont ceux de l'ancien moteur, supprimé). | Ordre du travail. |
| `docs/JOURNAL-COMBAT-V2.md` | Une ligne par choix fait hors des documents (date, point, choix, pourquoi), dont toutes les décisions de Gautier depuis le 28 octobre. | À compléter à chaque choix. |
| `docs/SUIVI.md` | Historique : retours de Gautier et ce qu'on en a fait, tableau de toutes les PR (#1 à #57). | Historique. |
| `docs/EQUILIBRAGE-V2.md` | Rapports de toutes les passes de réglage et mesures (duo à 20 tours, premier trio, IA de bon sens). | Mesures. |
| `docs/MECANIQUES.md` | Inventaire des mécaniques de l'ancien combat et idées. | Inspiration (ancien combat). |
| `docs/GDD.md`, `docs/RAPPORT-COMBAT-V2.md` | Le GDD V1 (référence pour l'univers et l'écran de création) ; le bilan de la migration au combat V2. | Historique. |

## 5. L'architecture du code

**Règle n°1** : le moteur (`engine/`) est **pur** : classes `RefCounted`, aucun nœud de scène, aucun `randi()`, `randf()` ni `randomize()` (seuls des `RandomNumberGenerator` à graine fournie, dans le générateur, la Tour et la composition du trio). `tests/test_architecture.gd` le vérifie. **Mêmes entrées, même résultat.** Les données sont en JSON dans `data/`, jamais codées en dur dans la logique.

### `engine/` (le moteur, module pur)

| Fichier | Rôle | API principale |
| --- | --- | --- |
| `donnees.gd` (`Donnees`) | Charge et valide `data/` (clés connues : `CLES_*`, une clé inconnue est une erreur). | `Donnees.defaut()`, `.regles`, `.etats`, `.textes`, `.classes`, `.ordre_classes`, `.bestiaire`, `.tour`, `.erreurs` |
| `budget.gd` (`Budget`) | Coût d'un nœud selon la grille (`rules.json` : `couts`, `couts_multi`, `multi_cible` 1,3) et budget de son rang (moyeu 55, N1 70, N2 100, N3 140, Clé 230 ; `budget_override` à ±10 % au plus). | `cout`, `budget`, `faute`, `fautes` |
| `destin.gd` (`Destin`) | Une roue : classe, nom, sprite, rôle, graine, `acolyte` (3 voies), `echo` (Écho d'un trio), PV de base, `pv_mult`, `k`, moyeu, voies (nœuds avec forme et `allume`, éclats). | `de_base`, `bonus_valeurs`, `bonus_pv`, `vers_dict`, `depuis_dict` |
| `generateur.gd` (`Generateur`) | Le seul hasard : formes des nœuds tirées avec la graine, valeurs recalculées pour garder le budget ; allumage (par défaut ou liste du joueur, ex. `"v2.n3"`, `"v1.e1"`). | `generer(classe, graine, niveau, allumage, donnees)`, `acolyte`, `echo`, `monstre`, `allumage_defaut`, `peut_allumer`, `allumer` |
| `trio.gd` (`Trio`) | La composition : un Front, un Dégâts, un Soutien (rôle = celui des données de la classe). Un Écho par rôle manquant, classe tirée avec sa graine. | `classes_du_role`, `roles_des_echos`, `graine_echo`, `echos`, `echo(role, graine, niveau)`, `camp(joueur, niveau)` |
| `etat_combat.gd` (`EtatCombat`) | L'état d'un combat : `statique` (fiches fixes), `persos` (PV, états, barrière, jalons, extinctions, cibles, `soins`), `ordre`, `journal` d'événements, `actions_jouees`. Sérialisable. | `copie`, `vers_dict`, `depuis_dict`, `perso`, `fiche`, `camp`, `vivant`, `vivants`, `allies_vivants`, `ennemis_vivants`, `a_etat`, `valeur_etat`, `tours_restants`, `pv_pourcent`, `noeud`, `nb_voies` |
| `regles.gd` (`Regles`) | Les règles : création d'un combat (places « joueur », « acolyte », « echo », « ennemi »), actions légales, cibles, menaces, Synergies (entre chaque paire d'un camp), résolution d'un tour (phases 2a à 2i), mort subite, usure des soins des monstres à la Tour. | `nouveau_combat(camp_a, camp_b, niveau, mode, donnees)` (mode `"pvp"` ou `"tour"`), `resoudre_tour(etat, declarations)`, `actions_legales`, `action`, `cibles`, `menaces`, `echeance`, `synergies`, `synergies_possibles`, `valeur`, `multiplicateur_niveau`, `mort_subite`, `usure_soins`, `noeud_de`, `plancher` |
| `ia.gd` (`IA`) | Une seule IA déterministe (Échos, acolytes, adversaires, monstres, simulateur) : un score par action (section 10 de la spécification) + les règles de bon sens (`IA.bon_sens`, vrai par défaut) : achever, pas de coup sur un ennemi qui tombe déjà, pas de Clé gaspillée, barrière seulement sur un allié que les ennemis viseront. Annonces en chaîne. | `declarer(e, humains)`, `choisir(e, id, connues)`, `score`, `cible_ennemie`, `cible_alliee`, `degats_prevus`, `degats_annonces`, `reste`, `ticks_a_venir`, `ennemis_a_portee`, `annonces_connues`, `degats_sur` |
| `texte.gd` (`Texte`) | Les textes générés depuis les données : nom avec suffixe de forme, ligne, phrase, fiche d'un nœud ou d'un état, pictogrammes, Synergies. | `nom`, `ligne`, `ligne_en_combat`, `fiche`, `fiche_etat`, `pictos`, `picto`, `synergie` |
| `tour.gd` (`Tour`) | La Tour infinie : monstres au niveau de l'étage (`niveau_par_etage`), somme de leurs `pv_mult` qui monte jusqu'à `somme_max`, Gardien tous les 5 étages, 1 à 6 monstres, paliers, PV gardés entre étages (+20 %, Écho KO revient à 20 %). | `commencer_camp(membres, niveau, graine, donnees, depart)`, `combat()`, `terminer(e)`, `arreter()`, `tirer_etage(n)`, `monstres(n)`, `niveau_etage(n)`, `fourchette(n)`, `palier_apres(franchi, 5)`, `paliers(franchi, 5)` |

### `data/` (données de jeu, JSON)

- `rules.json` : extinction 3, refroidissement 2, mort subite au tour 18 (+0,2 par tour), chrono 20 s, `niveau_pente` 0,05 (valeurs × 1 + 0,05 × (niveau − 1)), multi-cible ×1,3, tolérance du budget 6 %, budgets par rang, coûts des effets et des états (réglés par le simulateur : Aveuglé coûte 80, pas 70), `tour_soins_usure` 0,75.
- `classes.json` (ordre des 10 classes) et `classes/<id>.json` : nom, genre, rôle, PV, `k` (multiplicateur de classe), `acolyte` (ancienne classe d'acolyte, plus utilisée à l'écran), moyeu, 5 voies (id, nom, `acolyte`, 4 nœuds : rang, nom, genre, effets, `budget_override` éventuel). Mise en forme : objets sur plusieurs lignes, **chaque effet sur une seule ligne** ; la conserver.
- `etats.json` (16 états : nom, type, texte, pictogramme, couleur, négatif, dissipable, purgeable), `textes.json` (formes, gabarits des lignes et fiches, pictogrammes, Synergies), `bestiaire.json` (4 familles, 14 monstres : classe, voies, `pv_mult`, rang, description), `tour.json` (`pv_entre_etages`, `monstres_max` 6, `somme_depart`, `somme_pente`, `somme_largeur`, `somme_max` 3, `niveau_par_etage` 2,5, `tirages`, `gardien_tous_les` 5).

### `scenes/` (affichage, Godot ; toute la règle vient du moteur)

- `app/app.gd` (`ArenaApp`) : le profil, le perso (classe, graine, nœuds allumés) et ses deux Échos (`echos_choisis` : par rôle, une graine et un nom), un écran à la fois, la barre du bas (Accueil, Trio, Destin, La Tour, Profil). Fonctions : `create_character`, `charger_perso`, `sauver_perso`, `changer_echo(role)`, `trio()`, `noms_trio()`, `allumer`, `gain_xp`, `duel_contre_ia`, `commencer_tour(depart)`, `palier()`, `xp_etage`, `fin_duel`, `fin_tour`.
- `combat/combat_screen.gd` : l'arène à 3 contre X (places `PLACES`, `PLACES_MONSTRES` pour 1 à 6 monstres), les annonces des Échos (pastille + trait), le bandeau des Synergies, la bande de la voie, les six cases (moyeu + 5 voies), la ligne d'aide, les fiches (toucher une pastille, appui long sur un perso), la résolution, la part de chacun. `unit_view.gd` (un perso : sprite, PV, pastilles de menaces pour les alliés et d'états pour tous, halo et étiquette « CLÉ PRÊTE »), `case_noeud.gd`, `bande_voie.gd`, `bandeau_synergie.gd`, `resolution_view.gd` (cut-ins du journal), `pixel_sprites.gd` (sprites provisoires en grilles de caractères), `sfx.gd`, `player_profile.gd` (`PlayerProfile`, `user://profil.cfg` : statistiques, son, `duo` = le perso (version 3 : classe, graine, allumage, echos), records et paliers de la Tour, monstres vus, niveau, XP).
- `screens/` : `creation_screen` (classe, révélation du Destin, puis « Ton premier combat » = l'étage 1 de la Tour), `home_screen` (le trio, Combattre, La Tour), `trio_screen` (« Ton trio » : fiches des Échos, « Un autre Écho », lance le duel ou la montée), `versus_screen` (face-à-face des trios), `tower_screen` (règles, record, palier, Reprendre, Rejouer depuis un palier, bestiaire), `fin_screen`, `destin_screen` (la roue, allumer un nœud), `bestiary_screen`, `profile_screen`, `settings_screen` (son, outils du prototype : autre Destin, gagner un niveau, nouveau perso, tout effacer).
- `ui/` : `ui_kit.gd` (`UiKit` : thème, couleurs, constructeurs, `rangee_trio`, `echo_rules_card`), `picto.gd` (pictogrammes dessinés), `portrait_view.gd`.

### `tools/`, `tests/`

- `tools/budget.gd` (le budget de chaque nœud, en CI), `tools/equilibrage.gd` + `tools/equilibrage_lib.gd` (le simulateur : matrice des classes, routes, Tour, mesure `bon_sens`, erreurs de l'IA par rôle, rapport et six critères ; formats `duo` et `trio`), `tools/regleur.py` + `tools/regleur_boutons.py` (les passes de réglage du combat V2, encore pensées pour le duo et l'ancienne Tour), `tools/capture.gd` (captures), `tools/navigateur.js` (Playwright, piloter le web), `tools/generate_sfx.py`.
- `tests/run_tests.gd` (lanceur maison : toutes les méthodes `test_*` de `tests/test_*.gd`), `test_case.gd` (aides : `essai(...)` construit un Destin d'essai, `duel_essai`, `combat`, `jouer`, `moyeu`, `tour`, `poser`, `evenements`, assertions), et un fichier par sujet : règles, données, générateur, IA, fiches, simulateur, Tour, trio, bon sens, Soutiens, architecture.

## 6. Décisions importantes (toutes prises ou validées par Gautier ; détail daté dans `docs/JOURNAL-COMBAT-V2.md`)

1. **Combat V2 « l'Arbre vivant »** (28 oct) remplace tout l'ancien combat (recharges, vitesse, 3 actives + 1 passif, 63 Synergies, règle d'attente) : ne pas les réintroduire. Pas de mana, de Tempo, de Garde/Brèche, de timing, de pierre-feuille-ciseaux, de hasard en combat.
2. **20 tours par duel** (29 oct, matin) : PV ×0,8 de ceux de la spécification ; **mort subite au tour 18** (la spécification disait 10 à 14).
3. **GDD V2** (29 oct) : trio + Échos, Tour infinie, PvP 5 classés par jour, donjons, guildes, équipement, économie sans inflation.
4. **L'adversaire est caché** (29 oct, soir). Signal « Clé prête » seulement. L'IA, elle, voit tout.
5. **L'Invocateur reste Dégâts** ; les évolutions pourront changer le rôle de n'importe quelle classe.
6. **3 contre X partout**, PvE compris.
7. **Construire tout le jeu, puis équilibrer, puis les graphismes** ; demander l'avis de Gautier sur ce que le GDD ne dit pas.
8. **Soutiens presque sans dégâts** : une seule voie de dégâts par Soutien (Prêtre Châtiment, Alchimiste Acide, Barde Solo, Diplomate Duel) ; la Nitro de l'Alchimiste est devenue la Corrosion. **Le soin en trop est perdu**, mais chaque Soutien a toujours au moins deux actions utiles quand toute l'équipe a ses PV (test).
9. **La Tour est absolue** : monstres au niveau de l'étage (1 + 2,5 par étage). Paliers après chaque Gardien. Pas de limite de tours en PvE ; soins des monstres × 0,75 à chaque usage.
10. **Faveurs de la Tour = petits bonus cumulables** ; **revenu passif avec la Forge** (phase 3). Voir `PROGRESS.md`, « En cours ».
11. Les Échos proposés par le jeu sont gardés d'un combat à l'autre (« Un autre Écho » pour en changer). Le premier combat après la création est l'étage 1 de la Tour.

## 7. Pièges et erreurs à ne pas refaire

1. **Vérifier sur quelle base un document a été écrit.** Le GDD V2 et le plan ont été écrits sur une branche partie d'avant le combat V2 (`claude/duo-combat-prototype-5n3gqc`) : ils citaient des fichiers et des règles disparus. Toujours partir de `main` à jour (`git fetch` puis `git log origin/main`), et raccorder ce qui vient d'ailleurs.
2. **Ne jamais modifier les fichiers d'une copie de travail pendant qu'une simulation y tourne** : les processus Godot lancés ensuite chargent le code modifié et la mesure mélange deux versions. Simuler dans une copie à part, ou attendre la fin.
3. **Arrêter une simulation** : `TaskStop` arrête le script bash, pas les processus Godot qu'il a lancés. Les tuer avec PowerShell, seulement ceux lancés récemment : `Get-Process godot* | Where-Object { $_.StartTime -gt (Get-Date).AddMinutes(-30) } | Stop-Process -Force`. Jamais `pkill -f` (il se tue lui-même).
4. **Les petits échantillons trompent** : chaque graine fixe les Destins de toutes les classes, donc les duels d'une même graine se ressemblent. Une comparaison A/B de deux IA a donné 56,5 % sur 20 graines et 51,7 % sur 200. Pour une A/B, au moins 200 graines (20 000 duels).
5. **Bash et les heredocs** : l'outil Bash retire les antislashs d'un heredoc. Pour écrire un script Python ou GDScript qui en contient (continuation de ligne `\`, `\"`), utiliser l'outil Write, puis exécuter le fichier. Écrire les scripts temporaires dans le dossier brouillon de la session, pas dans le dépôt.
6. **Une copie de travail neuve doit être importée** (`--import`) avant les tests, sinon les `class_name` ne sont pas connus. Committer les fichiers `.uid` créés pour chaque nouveau script.
7. **GDScript** : une variable de boucle sur un tableau littéral n'a pas de type inféré (`for c in ["a", "b"]` puis `var x := c + "2"` échoue) : écrire `for c: String in [...]`. Un `Array[Dictionary]` attendu en paramètre ne reçoit pas un `Array` non typé : déclarer `var x: Array[Dictionary] = [...]`.
8. **Le budget** : tout changement d'un nœud doit rester dans ±6 % du budget de son rang, calculé avec les coûts de `data/rules.json` (pas ceux de la spécification, que le simulateur a modifiés). Lancer `tools/budget.gd`. Pour remplacer un effet, reporter son coût sur un autre effet (l'Affaiblissement se dose au pour cent près).
9. **Les morts sont constatées en fin de tour, après les soins** : un ennemi « déjà abattu » par les coups annoncés peut être sauvé par un soin de son camp. Ne pas supposer qu'un coup en trop est forcément perdu.
10. **Les Clés n'existent qu'à partir d'un certain niveau** : un adversaire à allumage par défaut n'a sa première Clé allumée qu'au niveau 11 (un acolyte au niveau 7). À bas niveau, le signal « CLÉ PRÊTE » n'apparaît donc jamais : pour le tester, monter un perso de 12 niveaux ou plus.
11. **Toute donnée lue dans `depuis_dict`** doit être reconstruite clé par clé (`EtatCombat.depuis_dict` liste les clés de `persos`) : une nouvelle clé d'état de combat doit y être ajoutée (exemple : `soins`).
12. **Prouver qu'une refonte ne change rien** : simulation à graine fixe avant et après (`simuler matrice 0 1 4 777 a.json`, puis comparer les fichiers). Les nouveaux comportements de l'IA se désactivent avec `IA.bon_sens = false` (argument `section10` du simulateur).
13. **L'outil « Gagner un niveau »** (Paramètres) ouvre l'écran du Destin à chaque niveau : monter de 10 niveaux sur le web demande 10 allers-retours. En capture, utiliser l'étape `{"niveau": N}`.
14. **Ne pas réintroduire ce qui a été décidé contre** : postures, règle d'attente de l'acolyte, adversaire visible, Soutiens qui frappent partout, limite de tours en PvE, équilibrage en cours de construction.
