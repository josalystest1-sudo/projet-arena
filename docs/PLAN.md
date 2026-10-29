# Plan de développement du GDD V2 (pour Claude Code)

Écrit le 29 octobre 2026. Ce plan traduit `docs/GDD_V2.md` en PR, dans l'ordre. Il s'adresse à la conversation Claude Code (Opus) qui reprend le projet **depuis l'ordinateur de Gautier** (jamais dans le cloud : il ne veut pas consommer de crédits cloud).

## Raccord avec le combat V2 (ajouté par Claude Code le 29 octobre au soir)

Ce plan et le GDD V2 ont été écrits le 29 octobre à midi dans une conversation partie d'une copie du projet du 28 octobre au matin : ils ne connaissaient pas **le combat V2, « l'Arbre vivant »** (`docs/SPEC-COMBAT-V2.md`, validé par Gautier le 28 au soir, publié le 29 au matin, PR #34 à #47). Le raccord :

- **Le GDD V2 décide du format du jeu** : le trio et les Échos, la Tour infinie, le PvP, les donjons, les guildes, l'équipement, l'économie, la ville. **La spécification du combat V2 reste la référence pour les règles d'un combat** : la roue (moyeu, 5 voies de 4 nœuds dont une Clé), les jalons, les menaces, les 16 états, le budget, les 4 Synergies universelles, l'IA à score, la mort subite. Avec les décisions de Gautier depuis : des combats de 20 tours, la mort subite au tour 18 (PR #47).
- **Caducs dans le GDD V2** (ils décrivent l'ancien combat) : le « rappel » des règles du § 4.1 (basique, moyenne, forte, recharges, vitesse, mort subite au tour 8, fin forcée au tour 13) ; « les 63 Synergies » et la règle d'attente (§ 4.3 : il y a 4 Synergies universelles, sans règle d'attente, section 8 de la spécification) ; « 6 actives + 4 passifs » (§ 3 : chaque classe a sa roue de 5 voies). Le Destin reste de 45 nœuds et 30 points.
- **Tranchés par Gautier le 29 octobre au soir** : (1) **l'adversaire est caché** (« On cache les sorts adverses ») : dans le combat V2, ni ses voies, ni ses jalons, ni ses menaces, ni l'annonce de son acolyte ; la lueur « forte prête » devient une lueur et une pastille « Clé » quand une de ses Clés est jouable. Fait tout de suite, sur l'écran en duo (PR #50) ; la PR 1.4 le reprendra pour le trio. (2) **L'Invocateur reste Dégâts** ; une ou plusieurs de ses évolutions pourront le faire passer Front, et toute classe pourra avoir des évolutions de plusieurs rôles (GDD V2, § 3). Deux Fronts (Guerrier, Pugiliste), quatre Dégâts, quatre Soutiens.
- **Les PR du plan, traduites dans le moteur V2** (les fichiers cités plus bas sont ceux de l'ancien moteur, supprimés par la PR #35) :
  - `engine/duo.gd` → la composition du trio dans `engine/trio.gd`, les Échos générés par `engine/generateur.gd` (une roue entière de 5 voies, allumage par défaut au niveau du joueur, section 3.1 de la spécification) ;
  - `engine/combat_ai.gd` → `engine/ia.gd` : les annonces en chaîne (Écho 1, puis Écho 2 qui connaît l'Écho 1, puis le joueur IA qui connaît les deux), le bonus de Synergie compté avec chaque action déjà annoncée ; pas de règle d'attente (interdite par la spécification) ;
  - `engine/combat.gd` → `engine/regles.gd` : des camps de 3 (le joueur, puis ses Échos), les Synergies entre chaque paire d'un même camp ; la cible `duo` des données vise tout le camp. Provocation, Hymne, Trêve et Charisme n'existent plus ;
  - la simulation « à graine fixe comparée au bit près » : `tools/equilibrage.gd` (le mode duo doit rester identique tant que l'écran ne passe pas au trio) ;
  - PR 1.2 : l'IA V2 n'a pas de règles en liste mais un score (section 10) : *achever*, *ne pas gaspiller la Clé* et *lire la menace* deviendront des termes de ce score ;
  - PR 1.3 : Résurrection, Purification, Catalyseur n'existent plus ; « toujours utile » se vérifiera sur les voies des Soutiens ;
  - PR 1.5 : les boutons de réglage de la section 11.3 de la spécification et `tools/regleur_boutons.py`, sur le PC de Gautier (les workflows « Réglage » de GitHub datent de l'ancien combat et ont été retirés).
- **« Ce qui existe » (§ 1 ci-dessous) et « Reprendre le travail » du suivi** parlaient de la PR d'équilibrage des 10 classes : elle est faite depuis le 28 octobre (PR #23), et tout le combat a été refait depuis. On passe directement à la phase 1.

## 0. Règles de travail (à relire à chaque session)

1. **Lire dans l'ordre** : `CLAUDE.md` (état du prototype, choix faits), `docs/SUIVI.md` (avancement, retours de Gautier), `docs/GDD_V2.md` (les règles, étiquetées Décidé / Proposé / Ouvert), `docs/MECANIQUES.md` (l'inventaire des mécaniques), puis ce plan. Le V2 l'emporte sur `docs/GDD.md` ; le V1 reste la référence pour les tableaux de compétences, l'univers et l'écran de création.
2. **Gautier ne lit pas de code et n'utilise pas de terminal.** Chaque fin de session : ce qui a été fait en langage courant, et quelque chose à tester sur son téléphone (https://josalystest1-sudo.github.io/projet-arena/, mis à jour à chaque fusion sur `main`). Jamais de commande à lui faire taper.
3. **Une PR par étape**, petite et lisible, titre et description en français, fusionnée en « squash » quand les tests passent. Mettre à jour `docs/SUIVI.md` (tableau des PR, retours, prochaines tâches) et `CLAUDE.md` (« Choix faits par Claude Code ») à chaque PR.
4. **Le moteur reste pur** (`engine/`, aucune scène, aucun hasard : `tests/test_architecture.gd` le vérifie), **les données en JSON** (`data/`), **tout se mesure au simulateur** avant d'être déclaré équilibré. Les simulations longues tournent **sur GitHub Actions** (gratuit : boutons « Réglage de l'équilibrage » et « Réglage de la Tour », branches `reglage-<n>` et `reglage-tour-<n>`), jamais en boucle d'attente : lancer, revenir plus tard.
5. **Un seul Claude à la fois** : pas d'agents en parallèle, pas de session cloud.
6. **Vérifier les écrans comme Gautier les verra** : export web, puis `tools/navigateur.js` (format téléphone, portrait, souris ou doigt, captures). Un écran n'est fini que s'il tient en portrait sur un téléphone peu haut.
7. **Quand le GDD V2 ne dit rien**, choisir, le noter dans `CLAUDE.md`, et ajouter la question au § 13 du V2 si elle mérite l'avis de Gautier.
8. Tests : `~/godot/godot --headless --path . --script res://tests/run_tests.gd` (168 au 28 octobre). Après une refonte du moteur, prouver que rien n'a changé par une simulation à graine fixe comparée au bit près (`tools/equilibrage.gd -- 3000 1 a.csv` puis `md5sum`).

## 1. Ce qui existe (28 octobre 2026)

Moteur pur et testé ; 10 classes, 63 Synergies, passifs et états génériques ; Destin (45 nœuds, mini-Destin, niveaux et XP) ; Tour à monstres (10 étages, bestiaire, Gardiens) ; duel en **duo** (joueur + acolyte) contre un duo IA ; une seule IA ; simulateur, régleur, budget du Destin ; écrans de création, accueil, acolyte, compétences, Destin, Tour, bestiaire, profil, paramètres, combat (carte du milieu, consigne, Synergies en doré, premier combat guidé). Reste à finir avant tout : **la PR d'équilibrage des 10 classes** (`docs/SUIVI.md`, « Reprendre le travail » : branche `reglage-2`, puis réglage de la Tour).

## 2. Les phases et leurs PR

Chaque PR a : son contenu, ses fichiers principaux, son critère de sortie, et ce que Gautier teste. Les numéros de PR sont indicatifs.

### Phase 1 — Le trio avec Échos générés (remplace le duo)

**PR 1.1 — Moteur : le trio et les annonces en chaîne**
- `engine/trio.gd` (remplace `engine/duo.gd`) : composition Front + Dégâts + Soutien par rôle principal (`data/classes.json` porte le rôle principal de chaque classe), le joueur dans sa case, deux Échos générés (classe du rôle manquant, kit tiré, Destin au niveau du joueur avec points placés seuls comme `app.random_enemy_duo` le fait déjà). Un Écho est marqué `is_echo`.
- `engine/combat_ai.gd` : les annonces en chaîne (Écho 1 annonce, Écho 2 annonce en connaissant Écho 1, le joueur IA d'en face joue en connaissant les deux) ; `synergy_options` pour deux partenaires ; la règle d'attente conservée.
- `engine/combat.gd` : rien à changer aux règles (camps de taille variable déjà) ; vérifier Provocation (« le prochain ennemi à agir » : en 3v3, deux provoqués sur trois, à conserver), Hymne, Trêve, Charisme avec trois alliés.
- Tests : composition (toujours les trois rôles), Échos au niveau du joueur, ordre des annonces, Synergies avec chacun, un Écho n'est jamais contrôlé par le joueur.
- **Critère** : le simulateur fait jouer des trios contre des trios ; aucun test rouge ; la simulation à graine fixe du mode duo n'est plus attendue (le format change, c'est voulu).
- **Gautier teste** : rien encore (pas d'écran), on enchaîne.

**PR 1.2 — L'IA de bon sens et le tableau des erreurs**
- `engine/combat_ai.gd` : règles *achever*, *ne pas gaspiller la forte*, *lire la menace* placées avant les règles de rôle (GDD V2 § 4.5), en utilisant `Combat.preview` et les annonces déjà connues. Textes des raisons dans `data/ia.json`.
- `tools/equilibrage.gd` et `tools/equilibrage.py` : colonnes d'erreurs par rôle (actions perdues sur un ennemi déjà mort, soins en trop, protections jamais touchées, fortes gaspillées, achèvements ratés) ; rapport « erreurs pour 100 tours » par rôle et par classe.
- Tests : chaque règle sur une situation construite (un ennemi à 30 PV et une moyenne qui tue → la moyenne, pas la forte ; tous les ennemis étourdis → pas de protection).
- **Critère** : erreurs rares (objectif de départ : moins de 3 pour 100 tours et par rôle, à affiner), et le taux de victoire des trios ne baisse pas.

**PR 1.3 — Les Soutiens toujours utiles, le geste de classe**
- `data/skills.json` : replis (Résurrection → bénédiction, Purification → immunité, Catalyseur → Vif), au plus une compétence qui frappe par Soutien (revoir Châtiment, Acide, Trait d'ombre, Hymne : lesquelles restent offensives), basiques d'une même classe sur un même élément (le geste), `data/classes.json` : le geste de chaque classe.
- `engine/combat_ai.gd` : le rôle Soutien ne « frappe sinon » plus : renforcer le Dégâts, affaiblir l'ennemi. Le Front suit la même logique.
- Tests : chaque compétence de Soutien a un effet quand personne n'est blessé ; chaque classe a un geste ; l'IA Soutien ne frappe jamais quand un renfort ou un affaiblissement est jouable.
- **Critère** : un test générique le vérifie pour toutes les compétences de Soutien ; simulation : les quatre Soutiens à 48–52 % (classes) et des trios qui vont aussi loin quel que soit leur Soutien (± 0,5 étage).

**PR 1.4 — Écrans : le trio en combat, l'adversaire opaque, la composition**
- `scenes/combat/combat_screen.gd` : trois personnages côté joueur (format compact existant), deux cartes d'annonce enchaînées (ou une carte qui résume les deux : « Nima tire sur Bise · Saule te protège »), Synergies possibles avec chacun ; **adversaire opaque** : retirer les pastilles M/F des ennemis, le kit au toucher (garder le nom, la classe, la barre), ajouter **les icônes d'état** (pictogramme + tours, sur tous) et **la lueur « forte prête »** sur un ennemi.
- `scenes/screens/trio_screen.gd` : composer le trio (ma case, deux cases « proposés par le jeu » ; amis et guilde grisés « à l'étape serveur ») avec la fiche de chaque Écho (classe, niveau, « comment il joue », nos Synergies) ; ce même écran sert à la Tour et au duel.
- Retirer la rencontre de l'acolyte, l'onglet Acolyte, `acolyte_name` ; l'écran de création enchaîne sur un premier combat guidé puis l'accueil. Bulles d'aide du premier combat mises à jour (les deux annonces).
- Écran de fin : résumé de l'adversaire (Proposé), part de chacun des trois.
- `tools/navigateur.js` : captures du combat en trio, portrait, hauteur 664 et 844.
- **Critère** : un duel et un étage de Tour se jouent en trio de bout en bout dans le navigateur, sans erreur, sans débordement.
- **Gautier teste** : un duel et un étage en trio ; est-ce qu'il sait toujours quoi faire ; est-ce que l'adversaire opaque lui manque.

**PR 1.5 — Rééquilibrage en trio**
- `.github/workflows/reglage.yml` : simulation de trios (adapter `tools/equilibrage.gd` et `tools/regleur.py` : kits mesurés côté joueur et côté Écho, par rôle), 6 passes de 400 000 combats ; puis `reglage_tour.yml` avec des trios (budgets de menace et multiplicateurs à remonter : plus de monstres par étage).
- Notes dans `CLAUDE.md` (chiffres avant / après), `docs/SUIVI.md`.
- **Critère** : classes 48–52 % des deux côtés, Soutiens à égalité, Tour : taux de chute par étage conforme à la courbe.

### Phase 2 — La Tour infinie

**PR 2.1 — Étages générés, paliers, reprise, sans limite de tours**
- `engine/tower.gd` et `data/tower.json` : les étages ne sont plus une liste de 10 mais une **courbe** (budget de menace, PV et puissance des monstres par étage ; Gardien tous les 5, variantes qui montent en gamme ; familles qui tournent). `plan_floor(n)` pour tout n. Paliers tous les 5 étages : reprise au dernier palier avec tous ses PV ; entre deux paliers, l'usure (20 %, KO à 20 %, recharges conservées). Rejouer depuis un palier (étages déjà franchis : XP et butin réduits).
- Retirer « épuisés au tour 12 » et « abandonnent au tour 24 » ; **les soins et régénérations des monstres s'affaiblissent à chaque usage** (`data/rules.json` : facteur 0,75) ; plafond technique de 300 tours dans `tools/simulate_tour.gd` (compté comme abandon).
- Profil : étage courant, palier, par classe ; record = étage atteint.
- Écran Tour : « Étage 23 · palier 20 », « Reprendre », « Rejouer depuis le palier », records.
- Tests : reprise au palier, usure entre paliers, soins qui s'affaiblissent, étage 200 généré sans erreur, aucune limite de tours.
- **Gautier teste** : monter, tomber, revenir le lendemain au même endroit ; un combat long qui ne s'arrête pas tout seul.

**PR 2.2 — Faveurs, revenu passif, réglage « niveau → étage »**
- `data/faveurs.json` (modificateurs PvE seulement, trois au choix par Gardien), `engine/combat_unit.gd` : les Faveurs s'ajoutent aux `mods` seulement en mode Tour. Revenu passif quotidien (Éclats, un peu d'XP, plafonné) calculé à l'ouverture du jeu selon l'étage.
- Simulateur : `tools/simulate_tour.gd` fait monter des trios **de niveau donné** (Destin avec autant de points, Faveurs acquises) ; `tools/regleur_tour.py` règle la courbe pour que l'étage moyen atteint suive la cible par niveau (étage 3 au niveau 1, Gardien 5 vers 8–10, étage 10 vers 25–30, puis la courbe continue). Lancer sur GitHub.
- **Critère** : courbe « niveau → étage » mesurée et notée ; personne n'atteint un plafond (l'étage 1 000 se génère).

### Phase 3 — L'équipement

**PR 3.1 — Données et moteur**
- `data/items.json` : bases (nom, emplacement, niveau min, réserve de lignes, fourchettes par ligne, traits légendaires possibles), raretés (nombre de lignes, budget), plafonds par statistique, table de butin par source (étage, Gardien, premier passage ou non).
- `engine/equipment.gd` (module pur, graine fournie) : tirage d'un objet (lignes, chiffres dans les fourchettes sous budget, qualité en %), `mods_for(items)` (mêmes clés que le Destin), plafonds, lié / échangeable, reforge d'une ligne (graine).
- `engine/combat_unit.gd` : `apply_mods` additionne Destin + équipement (+ Faveurs en Tour).
- Tests : un objet respecte ses fourchettes et son budget ; les plafonds tiennent ; un objet lié le reste ; la reforge ne touche qu'une ligne ; la simulation à graine fixe sans équipement est identique à avant.
- **Critère** : `tools/equilibrage.gd` sait tirer des équipements au hasard par niveau et les appliquer.

**PR 3.2 — La Forge et le butin**
- `scenes/screens/forge_screen.gd` : inventaire (5 emplacements, sac), fiche d'objet (lignes, fourchettes entre crochets, qualité, lié / échangeable), **comparaison** par `Combat.preview` (« Boule de feu : 54 au lieu de 48 »), équiper, recycler (Éclats), reforger (Éclats, coût croissant). Éclats dans le profil.
- Butin : à la fin d'un étage (objet du niveau de l'étage ; épique aux Gardiens ; échangeable seulement au premier passage), coffre de fin de montée.
- **Gautier teste** : trouver un objet, comparer, équiper, reforger ; sentir l'écart de puissance à la Tour.

**PR 3.3 — Passe de simulateur sur les lignes**
- `tools/regleur.py` : leviers = fourchettes des lignes ; règle « en moyenne sur tous les Destins aucune ligne ne gagne plus ; pour un Destin donné elles diffèrent » (mesurer la moyenne et l'écart-type par ligne) ; plafonds ajustés. Sur GitHub.
- **Critère** : aucune ligne hors 48–52 % en moyenne ; écart-type par Destin noté (c'est lui qui prouve « un meilleur objet pour moi »).

### Phase 4 — La ville et la navigation en portrait

**PR 4.1 — La ville**
- `data/ville.json` (bâtiments : nom, position, image provisoire, écran ouvert, condition d'ouverture), `scenes/screens/ville_screen.gd` : la carte à bâtiments en portrait (Tour, Arène, Donjon (grisé jusqu'au serveur), Guilde (grisé), Comptoir / Marché (grisé), Forge, Maison, Boutique (grisée), Tableau). Barre du bas réduite à : Ville, Chat (grisé), Profil. Tout accessible en deux touchers.
- Tableau : trois objectifs du jour (`data/objectifs.json`), événements (en local : records battus).
- **Gautier teste** : tout le jeu en portrait depuis la ville ; ajouter un bâtiment ne demande qu'une ligne de données (il le vérifie en demandant un bâtiment « Test »).

### Phase 5 — Serveur, comptes, vrais Échos, PvP classé, Marché

(Étape 5 du V1 : Nakama + PostgreSQL. Le moteur de règles tourne côté serveur, version qui fait foi.)

**PR 5.1** Comptes et profils en ligne (le profil local migre). **PR 5.2** Les vrais Échos : amis, guilde (grisé jusqu'à la phase 6), proposés par le jeu (au niveau), 3 aides par jour, récompenses de sélection (plafond 5, actif dans la semaine). **PR 5.3** PvP asynchrone classé : 5 par jour, matchmaking par puissance du trio, ligues Aspirants / Élus (Ascendants plus tard), saison de 3 mois, coffre hebdomadaire (objets liés), amicaux illimités. **PR 5.4** Chat (général, groupe ; guilde plus tard), filtre de mots, signalement. **PR 5.5** Marché et Comptoir : or, objets échangeables, fourchettes de prix (rareté, niveau, qualité), annonces anonymes au premier acheteur, taxe de 15 % détruite, seuils (niveau 15, 7 jours), aucun autre canal ; Comptoir au prix plancher ; mesure hebdomadaire de l'or qui entre et sort. **PR 5.6** Classements (Tour par classe, PvP, puis guildes).

### Phase 6 — Guildes et donjons à routes

**PR 6.1** Guildes : création, niveau, taille (jusqu'à 100), rôles, chat de guilde, bannière par modèles (`data/bannieres.json`), Influence (sources, améliorations : `data/guilde.json`), coffre (sans retrait d'or). **PR 6.2** Carte du monde (`data/monde.json` : régions, territoires, types, voisinages, donjons), affichage portrait. **PR 6.3** Donjons : `engine/donjon.gd` (arbre de routes, portes sans nom : ordre par joueur calculé à partir du joueur et de la porte, même vague par profondeur, vote, élites, fragments), cartes personnelle et de guilde, écran de vote. **PR 6.4** Le boss unique au serveur : paliers de vie et solutions secrètes exprimées en gestes / paliers / rôles (`data/boss.json`), coup final de guilde, événement serveur, nouvelle chasse, grimoires (tirage visible), récompenses. **PR 6.5** L'appel, les alliances à deux guildes.

### Phase 7 — Territoires et guerres du soir

**PR 7.1** Territoires : types et bonus, revenus, donjons sur territoire (part d'entrée, une route éliminée par jour), carte qui grandit avec la population, territoires neutres après 7 jours sans guerre. **PR 7.2** La guerre : fenêtre du soir par serveur, déclarations (1 + taille ÷ 20, voisins seulement), 3 combats par membre, défense automatique par Échos, rotation des défenseurs (3 fois au plus), scores, capture (neutre : meilleur score ; tenu : score × 1,2 ou 1,5), protection de deux jours, foyer imprenable, guildes de moins de 10 actifs limitées. **PR 7.3** Classement et ligues de guilde, remise à zéro de saison.

### Phase 8 — Le reste

Évolutions de rang 1 (30 classes) et de rang 2 (90), classes de grimoire (rares, épiques, légendaires : réserves de compétences et Synergies, réglées au simulateur, ligue Ascendants) ; PvP synchrone à 6 humains (file par rôle, repli à 2 humains + 4 Échos) ; art PixelLab ; boutique de cosmétiques ; bêta fermée Android puis TestFlight ; lancement.

## 3. Ce qu'il faut mesurer à chaque phase (le simulateur dit si c'est fini)

- Phase 1 : classes et kits dans 48–52 % des deux côtés ; Soutiens à égalité en étages atteints ; erreurs de l'IA rares ; Synergies par combat (viser au moins 1,5 par trio).
- Phase 2 : courbe niveau → étage ; part d'étages gagnés après 50 tours (viser < 2 %) ; aucun combat au plafond technique.
- Phase 3 : lignes d'équipement à 48–52 % en moyenne, écart-type par Destin élevé ; écart de puissance entre un joueur sans équipement et un joueur équipé à son niveau (viser +30 à +50 %, à confirmer par Gautier).
- Phase 5 : or entré / or détruit par semaine ; nombre d'objets échangeables par compte et par jour.

## 4. Questions à poser à Gautier au bon moment (pas avant)

- Phase 1, PR 1.4 : l'adversaire opaque lui manque-t-il ? Le résumé de l'adversaire en fin de combat lui plaît-il ?
- Phase 2 : la courbe niveau → étage (à quel niveau le Gardien 5, le 10) ; les Faveurs proposées.
- Phase 3 : l'écart de puissance voulu entre équipé et non équipé ; les noms des objets (univers).
- Phase 5 : la durée de saison (3 mois), les plafonds d'or et d'Éclats.
- Phase 6 : qui reçoit le grimoire ; les premiers boss et leurs conditions ; le nombre d'embranchements par donjon.
- Toujours : l'univers et le nom du jeu, dès que l'art (phase 8) approche.
