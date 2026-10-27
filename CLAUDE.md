# Projet Arena — mémoire du projet

Ce fichier est lu au début de chaque session. Il résume ce qu'il faut savoir pour travailler sur le jeu sans relire tout le GDD. La source de vérité complète est `docs/GDD.md` : en cas de doute sur une règle, c'est lui qui tranche.

**Changement majeur du 27 octobre 2026 :** le jeu passe du 3v3 entre humains au **duo** (joueur + acolyte IA). Le prototype 3v3 de l'étape 1 reste la base technique ; son format doit être remplacé. Tout ce qui parle de « 3 alliés », d'Intentions visibles entre humains ou de file par rôle est caduc.

## Qui est le propriétaire du projet et comment travailler avec lui

- Gautier ne lit pas de code et n'utilise jamais de terminal. Il travaille uniquement depuis l'interface de l'app Claude.
- Chaque fin de session : explique ce qui a été fait en langage courant, sans jargon, et donne-lui quelque chose à tester (une adresse web à ouvrir sur son téléphone, un comportement à vérifier).
- Jamais de commande à lui faire taper. Si une action manuelle est indispensable (créer un compte, cliquer dans une interface web), décris-la bouton par bouton.
- Avance par petites PR lisibles, une par étape. Titre et description en français.
- Quand le GDD ne dit rien, choisis, et note le choix dans la section « Choix faits par Claude Code » ci-dessous.

## Le jeu en douze lignes

- RPG mobile en pixel art. Deux modes en V1 : **PvP en duo** (joueur + acolyte contre joueur + acolyte) et **la Tour** (PvE solo : le duo grimpe des étages générés, classement par classe). Le 3v3 entre humains est en V2.
- Combat tour par tour **simultané** : 12 s pour choisir, puis résolution par ordre de vitesse. Système classique : 3 compétences à **recharge** (basique sans recharge ; moyenne 2 tours ; forte 4 tours, disponible à partir du tour 3). Pas de mana en V1, pas de Tempo, pas de Garde/Brèche, pas de timing en temps réel : ne pas les réintroduire.
- Un seul personnage par compte. Son **Destin** (arbre de 45 nœuds, 30 points, généré aléatoirement, unique au monde, non modifiable) détermine ses 3 compétences actives, son passif et ses bonus.
- **L'acolyte** : un second personnage fixe, piloté par l'IA, attribué au premier combat, de classe complémentaire (un Soutien reçoit un Front ou un Dégâts, etc.). Même niveau que le joueur, mini-Destin de 15 nœuds auto-attribué, 3 actives + 1 passif. Le joueur ne contrôle jamais ses sorts.
- L'acolyte **annonce son action en premier** au début des 12 s ; le joueur choisit en le sachant. **Plus de postures (décision du 27 octobre, 14 h) :** le joueur ne lui donne aucun ordre, il joue seul comme un second joueur, selon des règles fixes par rôle (celles de l'ancienne posture « Libre »). Une seule règle pour les Synergies : s'il existe une Synergie entre sa forte et une compétence que le joueur aura au tour suivant, il attend un tour, jamais plus. L'IA de l'acolyte doit être **prévisible plutôt que brillante**.
- **10 classes de base** : Guerrier, Mage, Voleur, Archer, Prêtre, Alchimiste, Invocateur, Barde, Diplomate, Pugiliste. Trois rôles : Front, Dégâts, Soutien ; chaque classe a un rôle principal et un secondaire.
- Chaque classe : pool de **6 actives** (2 basiques, 2 moyennes, 2 fortes) et **4 passifs** ; un personnage tire **une active de chaque palier + 1 passif**.
- **Synergies** : couples de compétences joueur + acolyte jouées le même tour → effet bonus unique par couple. Au moins une Synergie entre chaque classe et chaque classe qui peut lui servir d'acolyte.
- **Évolution** au niveau 30 : choix parmi 3, saut de puissance ×2,5, nouveau Destin à zéro. L'acolyte évolue en même temps (choix parmi 3, dont une qui déplace son rôle) ; c'est le seul moment où sa fonction peut changer. Deux ligues séparées : Aspirants (classes de base) et Élus (évolutions). V1 = 10 classes + 30 évolutions.
- **Échos** : les joueurs absents sont remplacés par leur propre duo piloté par l'IA. Matchmaking par ligue, classement et niveau ; pas de file par rôle (chaque duo est équilibré par construction).
- **La Tour** : même moteur ; 2 à 3 ennemis par étage construits avec les classes du jeu ; 20 % de PV rendus et recharges conservées entre étages ; pas de mort subite ; record par classe et par saison. L'XP de PvP reste toujours la plus rapide.
- Financement par **cosmétiques uniquement** (skins de lignée pour le perso et pour l'acolyte, animations, poses). Aucune limite de parties. Jamais de puissance vendue.

## Stack et architecture

- **Godot 4, GDScript**, un seul projet pour iOS, Android et web.
- **Règle d'architecture n°1** : le moteur de règles du combat (recharges, Synergies, résolution d'un tour, ordre de vitesse, mort subite, KO et relève) est un **module pur, sans affichage, sans dépendance aux nœuds de scène**, couvert par des tests automatiques. Il sert au serveur (version qui fait foi), au client (affichage et prévision), à l'IA (acolyte, Échos, ennemis de la Tour) et au simulateur d'équilibrage. Le moteur doit accepter des camps de taille variable (2 contre 2 en PvP, 2 contre 2 ou 3 à la Tour).
- **Une seule IA** pour l'acolyte, les Échos, les ennemis de la Tour et le simulateur, avec des règles fixes par rôle (plus de postures).
- Données de jeu (classes, compétences, passifs, Synergies, nœuds de Destin, étages de la Tour) dans des fichiers de données lisibles (JSON ou .tres), jamais codées en dur dans la logique.
- Serveur prévu : Nakama + PostgreSQL (étape 5 de la feuille de route). Pas avant.
- Art : PixelLab via MCP (étape 6). Sprites provisoires d'ici là.
- Builds : GitHub Actions. Export **web publié sur GitHub Pages à chaque fusion sur `main`** pour que Gautier teste sur son téléphone. Android puis iOS (runner macOS + Fastlane) plus tard.
- Tests : `godot --headless` lance la suite de tests du moteur de règles en CI ; une PR ne fusionne pas si les tests échouent.

## Feuille de route (ordre impératif)

1. **Prototype de combat en duo (web).** Reprendre le moteur de l'étape 1 (3v3) et le passer en duo : l'acolyte (sans postures) et son annonce, le duo du joueur contre un duo IA, 3 classes. **Critère de sortie : on a envie de relancer un combat.**
2. **La Tour en prototype** : 10 étages générés, gestion des PV et recharges entre étages. Critère : on veut battre son record.
3. Les 10 classes complètes, le générateur de Destin (budget de puissance), le mini-Destin de l'acolyte, les Synergies joueur-acolyte.
4. Le simulateur d'équilibrage (moteur sans interface, centaines de milliers de combats en duo, taux de victoire par classe / compétence / nœud, réglage de la mort subite).
5. Serveur, comptes, matchmaking, PvP réel, Échos, classements PvP et Tour.
6. Art PixelLab et les 13 écrans (dont la rencontre de l'acolyte et l'écran Acolyte).
7. Les 30 évolutions, l'évolution partagée avec l'acolyte, la Ligue des Élus.
8. Boutique et paiements (skins perso et acolyte).
9. Bêta fermée Android puis TestFlight.
10. Lancement.

## Décisions verrouillées (ne pas rouvrir sans l'accord de Gautier)

Voir `docs/GDD.md`, section « Décisions prises et questions ouvertes ». En particulier : duo joueur + acolyte en V1, pas de Garde/Brèche, pas de Tempo, pas de mana, pas de mécanique de timing, pas de pierre-feuille-ciseaux, pas d'énergie ni de limite de parties, Destin non modifiable, un seul personnage et un seul acolyte par compte, classe de l'acolyte fixe hors évolution.

## Questions encore ouvertes (à poser à Gautier au bon moment, pas avant)

- Univers : trois pistes dans le GDD (La Veille, Le Tissage, La Foire des Dieux oubliés). Nécessaire à partir de l'écran de création (étape 6). L'acolyte doit y trouver sa place.
- Nom définitif du jeu.
- Équipement et économie : orientation retenue dans les grandes lignes (voir GDD, « Encore ouvert ») mais **mis de côté** ; rien à implémenter avant que Gautier ne le remette à l'ordre du jour.
- Chiffres (PV, dégâts, vitesses, tours de mort subite) : valeurs de départ libres au prototype, puis simulateur.

## Choix faits par Claude Code

(À compléter au fil des sessions : une ligne par choix, avec la date et la raison.)

**Technique (2026-10-26, étape 1)**

- Godot **4.5 stable**, rendu « Compatibility » (le seul qui tourne partout sur le web mobile). Export web **sans threads** : GitHub Pages ne permet pas les en-têtes de sécurité qu'exigent les threads.
- Moteur de règles dans `engine/` (classes `RefCounted`, aucune scène, aucun hasard interne : mêmes entrées, même résultat). Un test (`tests/test_architecture.gd`) fait échouer la CI si le moteur dépend un jour de l'affichage.
- Tests maison dans `tests/` (pas de bibliothèque externe type GUT) : `godot --headless --path . --script res://tests/run_tests.gd`. Mini-simulateur IA contre IA dans `tools/simulate.gd` (avant-goût de l'étape 3).
- Données de jeu dans `data/` en JSON : classes, compétences, passifs, états, Synergies.
- Sprites provisoires dessinés en pixels à partir de grilles de caractères (`scenes/combat/pixel_sprites.gd`), en attendant PixelLab.

**Règles de combat (2026-10-26, prototype : valeurs de départ, à ajuster par le simulateur)**

- Chiffres : Guerrier 250 PV, vitesse 9, puissance 100 ; Mage 175 PV, vitesse 8, puissance 105 ; Prêtre 220 PV, vitesse 7, puissance 100. Dégâts = puissance de la compétence × puissance du perso / 100. (2026-10-27 : PV baissés de 25 % après le retour de Gautier « c'est un peu fade » : le premier KO arrivait au tour 7 et un combat sur quatre finissait au décompte des PV. Puis réglages du duo, voir « Duo : IA et réglages ».)
- Recharges : une moyenne jouée au tour N revient au tour N+3, une forte au tour N+5 ; forte jouable à partir du tour 3.
- Ordre du tour : la file est calculée au début de la résolution (vitesse + bonus de la compétence + passifs). À vitesse égale, la priorité est **tirée à pile ou face à chaque combat puis alterne à chaque tour** (sans ça, l'équipe prioritaire gagnait 56 % des combats miroirs en simulation).
- Coup de bouclier : la cible échange sa place avec celle qui la suit dans la file. Trait de givre : la cible passe en fin de file ; si elle a déjà agi, elle agira en dernier au tour suivant.
- Provocation : la cible choisie et le prochain ennemi à agir sont provoqués ; ne détourne que les compétences offensives (un soin reste un soin).
- Rempart : protège jusqu'à la fin du tour suivant ou jusqu'au premier coup (les dégâts sur la durée ne le consomment pas). Les barrières ne se cumulent pas : la plus grosse reste.
- Un perso mis KO avant d'agir perd son action. Un KO perd ses états. Un perso relevé revient avec le pourcentage de PV de la Résurrection (dans les données), recharges remises à zéro, et n'agit qu'au tour suivant. On ne peut être relevé qu'une fois par combat, et la Résurrection ne sert qu'une fois par combat.
- Mort subite au tour 8 (soins ÷2, dégâts +50 % par tour cumulés depuis le passage au duo), fin forcée à la fin du tour 13 : plus de PV totaux, puis plus de dégâts infligés, puis le camp prioritaire. Jamais de match nul. Ces réglages sont dans `data/rules.json`.
- 4e passif inventé pour chaque classe (le GDD n'en donne que 3) : Colère (Guerrier, +10 % de dégâts par quart de PV manquant), Météorologue (Mage, forte revient 1 tour plus tôt), Sanctuaire (Prêtre, barrières +25 %).
- Synergies du prototype : Provocation + Nova (celle du GDD) et trois nouvelles pour couvrir chaque paire de classes : Bastion (Rempart + Prière, le Rempart se reforme), Éclat (Trait de givre + Châtiment sur la même cible, +75 dégâts de lumière), Plaie brûlante (Fendoir + Boule de feu sur la même cible, saignement ×1,5 et +2 tours). Une Synergie se déclenche quand la seconde compétence du couple se résout, même si la première est passée avant. (Éclat et Plaie brûlante renforcées le 2026-10-27 pour que construire une Synergie vaille un tour.)

**Duo : moteur (2026-10-27, étape 1 du duo)**

- Le moteur accepte des camps de toute taille. En PvP, chaque camp est un duo : le personnage principal (`a1`, `b1`) puis son acolyte (`a2`, `b2`, marqué `is_acolyte`). `engine/duo.gd` compose les duos.
- Classe de l'acolyte : tirée au hasard parmi les classes dont le rôle principal diffère de celui du joueur (avec 3 classes : les deux autres).
- Kit de l'acolyte (3 actives + 1 passif, comme un joueur) : tiré au hasard **parmi les kits qui ont au moins une Synergie avec celui du joueur**. Sans cette règle, 69 % des duos n'avaient aucune Synergie possible avec les 4 Synergies de départ, alors que le GDD veut « aucun duo sans Synergie ».
- 3 Synergies ajoutées pour que tout kit de joueur ait une Synergie possible avec chaque classe d'acolyte (un test le vérifie) : **Forteresse** (Cri de guerre + Bouclier de mana : le bouclier se pose aussi sur l'autre membre du duo), **Jugement** (Provocation + Châtiment : le Châtiment frappe aussi l'autre ennemi provoqué), **Courant de vie** (Arc de foudre + Prière : la Prière soigne aussi l'autre membre du duo).
- Provocation en duo : la cible et le prochain ennemi à agir, donc tout le duo adverse. Gardé tel quel (c'est le métier du Front) ; à la Tour, face à 3 ennemis, le troisième garde sa cible.
- L'acolyte a exactement les stats d'un personnage de sa classe (même niveau que le joueur ; pas encore de niveaux au prototype). Pas de mini-Destin avant l'étape 3, ni de nom modifiable avant les comptes.

**Duo : IA et réglages (2026-10-27, étape 1 du duo)**

- Une seule IA (`engine/combat_ai.gd`) pour l'acolyte, le joueur IA d'en face et le simulateur. Pas de score caché : une liste de règles courtes essayées toujours dans le même ordre, la première qui s'applique décide. Textes, seuils et phrases d'annonce dans `data/ia.json`.
- « L'ennemi le plus bas » = le plus bas en % de PV ; à égalité, celui qui a le moins de PV (au tour 1, le plus fragile). Une protection ou un soin inutile (Rempart déjà posé, barrière déjà aussi grosse, allié à fond) est sauté, sauf pour la basique.
- Le joueur IA d'en face connaît l'annonce de son acolyte, comme un humain : il relève et soigne l'urgence, puis cherche la Synergie avec l'annonce (jamais au prix d'un tour gâché), puis joue son rôle sur la même cible. Il ne donne aucun ordre à son acolyte (il n'y en a plus).
- Réglages pour le duo : en 2 contre 2 il n'y a plus que deux attaquants par camp, alors que les soins et les protections d'un Prêtre ou d'un Guerrier restent entiers. Mesuré : 41 dégâts par camp et par tour, premier KO au tour 8, un combat sur trois au décompte des PV (les duos Guerrier + Prêtre se neutralisaient). Changements : dégâts de toutes les compétences ×1,35 environ, Prière 44, Restauration 80, Cri de guerre +50 %, Fendoir 73, Boule de feu 40, Châtiment 43, Arc de foudre 38, Mage puissance 105, Prêtre 220 PV, mort subite +50 % par tour, Jugement et Courant de vie à ×1,5.
- (Historique, avant l'équilibrage du 2026-10-27 après-midi.) Résultat en simulation (3 000 combats) : 8,8 tours en moyenne, premier KO au tour 6,3, 89 % des combats finis par KO, 68 % entre les tours 8 et 15 (le GDD vise 90 % : en duo, le combat se termine vite après le premier KO ; à revoir à l'étape 4). Classes : Guerrier 46 %, Mage 54 %, Prêtre 50 %. Écarts restants pour l'étape 4 : Prière (sans attaque) et Cri de guerre en dessous, Fendoir au-dessus.
- Limite connue : le simulateur ne démontre pas encore le pilier « le duo gagne ». Un joueur IA qui lit l'annonce et cherche les Synergies gagne 51 % contre un qui l'ignore, parce que les deux en déclenchent presque autant (1,6 contre 1,5 par combat) : quand chacun joue son rôle, les couples tombent d'eux-mêmes. Il faudra une IA qui prépare ses coups sur plusieurs tours (étape 4), et surtout le ressenti de Gautier.

**L'acolyte sans postures (2026-10-27, décision de Gautier : remplace les postures par rôle)**

- L'acolyte joue seul, comme un second joueur : aucune posture, aucun ordre. Ses règles sont celles de l'ancienne posture « Libre », fixes par rôle (`engine/combat_ai.gd`, textes dans `data/ia.json`, affichées sur la fiche Acolyte et à la rencontre sous « Comment il joue ») :
  - commune : un allié KO est relevé dès que possible (le joueur d'abord) ;
  - Front : il protège le joueur (sa protection prête) dès que celui-ci a perdu des PV, sinon sa forte, sinon il frappe l'ennemi le plus bas ;
  - Dégâts : il frappe l'ennemi le plus bas (forte, moyenne, basique) et ne secourt qu'un allié sous 50 % ;
  - Soutien : il soigne le plus blessé sous 50 % (son plus gros soin prêt), sinon retire un état négatif, sinon joue sa forte, sinon frappe.
- **Règle d'attente** (la seule pour les Synergies) : si sa forte est prête et fait Synergie avec une compétence du joueur qui n'est pas jouable ce tour-ci mais le sera au tour suivant (il lui reste exactement 1 tour de recharge), il garde sa forte et joue ses autres règles. Jamais deux tours de suite : l'action porte `waits_for_synergy`, et le combat retient le tour de l'attente (`flags.waited_for_synergy`). Pas d'attente pour une relève, ni pour une compétence du joueur déjà prête (la Synergie est possible tout de suite), ni pour une qui revient dans 2 tours ou plus.
- **Le tour d'après l'attente**, il joue la forte gardée (règle « avec_toi », juste après la relève), dès que la compétence du joueur est revenue. Choix de Claude Code : le GDD dit seulement « il attend un tour » ; sans cette règle, une forte qui protège (Bouclier de mana d'un Mage, joué seulement en secours) était gardée pour rien, et l'écran promettait une Synergie qui ne venait pas.
- Il annonce toujours en premier ; son annonce ne dépend jamais du choix du joueur (un test le vérifie), et l'écran envoie exactement l'annonce affichée.
- Le joueur IA d'en face ne change plus rien chez son acolyte ; il lit son annonce et cherche la Synergie (il joue donc sa compétence avec la forte gardée, le tour d'après).
- `tools/postures.gd` supprimé. `tools/simulate.gd` mesure les attentes (combien, et si la Synergie suit) et compare l'acolyte avec et sans la règle d'attente.
- RÉSULTATS_A_COMPLETER

**Équilibrage (2026-10-27, demandé par Gautier : « aucune méta » tant qu'il n'y a pas d'équipement)**

- Outils : `tools/equilibrage.gd` fait jouer des milliers de combats IA contre IA (duos tirés au hasard) et écrit un CSV ; `tools/equilibrage.py` donne le taux de victoire de chaque classe, compétence, passif, Synergie, composition, affrontement et kit complet, et marque ce qui sort de 48–52 % au-delà du bruit de mesure ; `tools/regleur.py` corrige les chiffres de `data/` par passes successives (mesure, puis correction proportionnelle à l'écart, 4 processus Godot en parallèle). Les chiffres cités plus haut dans ces notes sont ceux du moment où ils ont été écrits : les valeurs actuelles sont dans `data/`.
- Tous les chiffres des passifs et des Synergies sont dans les données (`params`), et toutes les descriptions se remplissent avec (`{bonus%}`, `{turns}`…) : le régleur peut tout toucher sans que les textes mentent.
- Ce que le régleur règle : une classe par sa **puissance seulement** (ses PV disent son rôle et ne bougent pas : Guerrier 250, Prêtre 220, Mage 175 ; un premier réglage par les PV avait fini par donner moins de PV au Guerrier qu'au Prêtre) ; une compétence, un passif ou une Synergie par son chiffre principal (comparé à sa classe, ou à sa composition pour une Synergie) ; les chiffres de Synergie restent dans des bornes (au-delà, c'est l'effet qu'il faut revoir).
- Changements de conception, parce qu'aucun chiffre ne suffisait : **Prière** (ce qui dépasse les PV max devient une barrière : un Prêtre tiré avec Prière gagnait 38 %), **Cri de guerre** (frappe une cible en plus de renforcer le duo : 33 %), **Provocation** (frappe aussi sa cible), **Vétéran** (bonus de dégâts permanent, multiplié et + vitesse quand l'allié est KO : sinon il ne servait presque jamais), **Courant de vie** (le soin en trop devient aussi une barrière : sinon le régleur montait sa force sans effet), **Prière** (seule une part du soin en trop devient une barrière, 50 % au départ : avec un Prêtre plus puissant, Prière et Courant de vie devenaient une machine à barrières, et les duos Mage + Prêtre qui l'avaient gagnaient 75 %), **Forteresse** (le second bouclier a une taille réglable), **Plaie brûlante** (le saignement est aussi renforcé), **Éclat** (dégâts fixes réglables : il gagnait 85 %).
- **Budget du Destin** (`data/destins.json`, avant-goût du budget de puissance du générateur de Destin de l'étape 3) : un ajustement de quelques % des PV et de la puissance d'un perso selon son kit. Par élément, pour ce qui n'a pas de chiffre à régler (Rempart, Résonance, Météorologue : sans ça, le régleur affaiblissait les autres passifs du Mage pour compenser). Par paire d'un même kit qui va trop bien ou trop mal ensemble (ex. Prière + Résurrection : aucun dégât ; Prière + Égide : très solide). Par trio de compétences (Étincelle + Arc de foudre + Nova : +3,9 points après tout le reste). En duo, le partenaire compte aussi : un élément selon la classe de l'autre membre du duo (Cri de guerre gagnait 6,5 points de plus à côté d'un Mage, qui frappe fort, et 7 de moins à côté d'un Prêtre), et la composition du duo elle-même. Le duo étant fixe (un seul acolyte par compte), l'ajustement l'est aussi. Affiché au joueur sur les écrans Compétences et Acolyte (« Équilibre du Destin : +3 % de PV et de puissance, parce que ce kit et ce duo vont moins bien ensemble que d'autres »). Hors duo (ennemis de la Tour à 3), seuls les éléments et les paires comptent. Les tests du moteur le neutralisent (ils vérifient les règles avec les chiffres des classes), sauf deux tests dédiés.
- **Amortissement** : un levier dont l'écart change de sens d'une passe à l'autre voit son pas divisé par deux (état gardé dans le dossier de sortie). Sans ça, plusieurs leviers qui corrigent le même écart (une Synergie, les deux membres d'un duo, leurs compétences) le faisaient osciller de ±20 points : certains duos sont très sensibles (4 % de PV et de puissance faisaient passer un groupe de duos Mage + Prêtre de 75 % à 26 % contre Guerrier + Mage). Faire tourner le régleur dans une copie (`git worktree`) pour ne pas laisser `data/` modifié pendant des heures, puis recopier les fichiers.
- Résultat après réglage (96 000 combats, tirages neufs) : 10,2 tours en moyenne, 82 % des combats finis par KO, 87 % entre les tours 8 et 15. Classes 49,8–50,3 % (en joueur 49,6–50,5, en acolyte 49,7–50,2) ; compositions 49,5–50,3 % ; toutes les compétences et tous les passifs entre 48 et 52 % ; Synergies 47,8–52,0 % ; kits complets (joueur et acolyte confondus) 46,0–54,3 %, 74 sur 96 dans 48–52 %, dispersion réelle ±1,4 point (avant le budget du Destin : 38,7–67,9 %).
- Limites connues : (1) un léger cycle entre compositions (Guerrier + Mage bat Mage + Prêtre 53 %, Mage + Prêtre bat Guerrier + Prêtre 51 %, Guerrier + Prêtre bat Guerrier + Mage 52 %) : la force d'un duo ne peut pas le corriger (c'est du pierre-feuille-ciseaux entre compositions), à surveiller à l'étape 4 avec les 10 classes ; (2) un kit côté joueur est mesuré avec le joueur IA, qui n'est qu'une approximation d'un humain ; (3) chaque changement de l'IA déplace l'équilibre : relancer le régleur après (fait après les postures par rôle, puis après leur suppression).

**La Tour (2026-10-27, étape 2, fusionnée le même jour : les nouveaux menus sont construits dessus)**

- `engine/tower.gd` (module pur) et `data/tower.json` : 10 étages. Pour chaque étage, le fichier donne le nombre d'ennemis (2 ou 3) et leur force (PV et puissance en multiplicateurs) ; classes et kits des ennemis sont tirés au hasard. Étages 5 et 10 : un Gardien (+60 % de PV). Noms : Sentinelle (Guerrier), Arcaniste (Mage), Oracle (Prêtre).
- Entre deux étages : 20 % des PV max rendus, **un membre KO revient avec 20 %** (le GDD ne dit rien ; sans ça, le duo se réduisait à un seul perso pour toute la suite), recharges conservées. Une forte prête l'est dès le tour 1 de l'étage suivant (la règle « forte au tour 3 » ne vaut qu'au premier étage). Ce qui sert « une fois par combat » (Résurrection, relève, Second souffle) revient à chaque étage.
- Pas de mort subite (GDD). Mais sans rien, 15 % des montées se bloquaient dans des combats sans fin (un duo qui frappe peu contre des Prêtres ennemis). D'où trois règles, qui ne pénalisent jamais le joueur : les soins des ennemis de la Tour sont moitié moins forts ; **à partir du tour 12 d'un étage, les ennemis s'épuisent** (plus de soins ni de barrières) ; au tour 24, ils abandonnent et l'étage est franchi (le GDD dit qu'un étage se perd quand le duo tombe, donc un duo debout ne perd pas).
- Record = étage atteint (celui où le duo tombe, ou 10), gardé par classe sur l'appareil. On peut abandonner la montée entre deux étages.
- Après l'équilibrage du 2026-10-27 (classes, budget du Destin, postures par rôle, depuis supprimées), la Tour était devenue trop facile (21 % des montées au sommet) : puissance des ennemis de tous les étages ×1,25 et PV ×0,9 (ils frappent plus fort et tombent plus vite, ce qui limite les combats qui s'éternisent). Résultat (600 montées) : 4,8 % au sommet, 73 % des montées s'arrêtent entre les étages 4 et 8, 9 tours par étage, environ 4 % des étages gagnés par abandon ; étage moyen selon la classe du joueur : Mage 5,8, Guerrier 6,3, Prêtre 7,5 (record par classe : pas bloquant).
- (Historique, étape 2.) Réglage au simulateur (`tools/simulate_tour.gd`, l'IA joue les deux camps) : la plupart des montées s'arrêtent entre les étages 4 et 8, 6 % atteignent le sommet, 8,5 tours par étage, 1,5 % des étages finissent par abandon. Étage moyen selon la classe du joueur : Guerrier 6,4, Mage 6,3, Prêtre 7,8 (le Prêtre gère mieux l'usure ; le record étant par classe, ce n'est pas bloquant).

**Interface générale (2026-10-27, demandée par Gautier)**

- `scenes/app/app.gd` (scène de démarrage `scenes/app/app.tscn`) garde le profil et le duo, affiche un écran à la fois et la barre de navigation du bas (Accueil, Acolyte, Compétences, La Tour, Profil). Les écrans sont dans `scenes/screens/`, les briques communes (thème, boutons, cartes, portraits animés) dans `scenes/ui/`. Tout est construit en code, comme l'écran de combat.
- Premier lancement : **Création** (choix de la classe, puis le Destin se dévoile compétence après compétence) → **Rencontre de l'acolyte** (il arrive, se présente, vos Synergies) → **Vitrine**. Ensuite, on arrive directement sur la Vitrine : le duo en grand, deux gros boutons Combattre et La Tour, la série et le record.
- **Combattre** passe par un **face-à-face** (« Recherche d'un adversaire… », puis les deux duos ; le duo d'en face est marqué « Duo IA », pour ne jamais mentir au joueur, comme le veut le GDD pour les Échos).
- **Acolyte** : sa fiche, ses compétences, et « Comment il joue » (ses règles de rôle et la règle d'attente, mêmes textes qu'à la rencontre). Plus de posture de départ ni de sélecteur (décision du 27 octobre).
- Écrans Compétences et Acolyte : quand le budget du Destin ajuste le kit, une ligne le dit (« Équilibre du Destin : +3 % de PV et de puissance, parce que ce kit et ce duo vont moins bien ensemble que d'autres »).
- **Compétences** : tes 3 actives et ton passif, leurs recharges, tes Synergies avec l'acolyte. **La Tour** : règles, ton record, records par classe, bouton pour monter. **Profil** : duels (victoires, série) et records de la Tour. **Paramètres** (depuis la Vitrine) : son, et les outils du prototype (autre tirage, autre acolyte, nouveau personnage, effacer ses données avec confirmation).
- En combat, un bouton **Quitter** (deux appuis) : en duel, ça compte comme une défaite ; à la Tour, la montée s'arrête. Pas pendant l'animation d'un tour.
- Les descriptions des compétences, passifs et Synergies se remplissent avec les chiffres des données (`{percent}`, `{bonus%}`…) : elles restent justes quand l'équilibrage change un chiffre.

**Écran (2026-10-26, prototype ; passé en duo le 2026-10-27)**

- Le joueur choisit sa classe au lancement et peut retirer son kit ou son acolyte (« Autre tirage pour toi », « Autre acolyte », prototype seulement) : c'est volontairement contraire au Destin non modifiable, pour tester les 3 classes et tous les kits. À retirer quand les comptes arrivent (étape 5). Un nouveau tirage du joueur garde l'acolyte s'il fait toujours Synergie avec lui.
- Le duo (perso, acolyte, nom de l'acolyte) est gardé sur l'appareil (`user://profil.cfg`) : « Rejouer » et « Continuer avec ton duo » gardent le même acolyte, comme dans le vrai jeu. Il est présenté avant le combat avec ses compétences et vos Synergies possibles (avant-goût de l'écran « Rencontre de l'acolyte »). Nom de l'acolyte tiré dans une liste, pas encore modifiable.
- Disposition (portrait) : le duo adverse en haut, le tien au milieu, chaque fois l'acolyte à gauche et le joueur à droite. Colonne de gauche : en haut « Duo adverse — Duo IA », en bas un encadré sur ton acolyte (« Joue seul selon son rôle (Dégâts) », « Garde sa forte pour la Synergie X au prochain tour », « Joue la forte qu'il gardait : à toi de jouer la Synergie », ou « X est KO »). Les zones de texte ont une hauteur fixe pour que les boutons ne bougent jamais sous le doigt.
- L'acolyte annonce son coup dès le début du tour (bulle au-dessus de lui, trait vers sa cible, petit effet et son). Sous les persos, une phrase dit pourquoi : « Saule : Restauration sur toi — soigne le plus blessé ». Son annonce ne change jamais pendant le tour. Une étoile dans sa bulle : il garde sa forte pour une Synergie au tour suivant (phrase : « garde sa forte un tour : Synergie X avec Y au prochain tour »), et la ligne sous ta compétence concernée dit « Au prochain tour : Synergie X avec Saule ».
- Synergies : dès qu'un couple est possible avec l'annonce de l'acolyte, un arc doré avec une étoile relie le joueur et l'acolyte, la bannière dit quoi jouer (« Synergie possible : Éclat — joue Châtiment sur Brume »), la ligne sous le bouton concerné s'allume et la bonne cible est marquée d'une étoile. Quand ton Intention la déclenche : « Synergie prête », traits dorés qui clignotent. Calculé par `CombatAI.synergy_options` (moteur).
- Recharges visibles sur chaque perso (pastilles M et F : vert = prête, chiffre = tours restants, × = déjà utilisée) : on voit quand la forte de son acolyte ou de l'adversaire revient. Le badge « FORTE PRÊTE » reste sur les ennemis.
- Bouton « Prêt » : l'acolyte a déjà annoncé, le tour part dès que tu es prêt. Sans choix à la fin des 12 s : ta basique sur la même cible (et l'acolyte réagit à cette basique).
- Si tu es KO, ton acolyte continue seul : le tour part après 3 secondes (ou « Prêt »). Si l'acolyte est KO, l'encadré le dit.
- Le joueur peut toucher n'importe quel perso pour voir son kit et ses recharges (et ses règles pour l'acolyte). On voit ce qu'un ennemi *peut* faire, jamais ce qu'il a choisi.
- Prévision sur la cible visée : dégâts, soin, « KO ! » ou « Bloqué », calculée par le moteur (`Combat.preview`) sans tenir compte de ce que les autres feront avant.
- Ressenti (2026-10-27) : bruitages synthétiques provisoires (`tools/generate_sfx.py`, bouton pour couper le son), secousses d'écran, flash, annonce en grand des fortes et des Synergies, persos qui respirent, tremblent et tombent au KO. Toucher l'écran pendant la résolution l'accélère.
- Série de victoires, record et bilan V/D gardés sur l'appareil ; l'écran de fin montre ta part du combat, celle de ton acolyte et le meilleur des 4.
- Test : une adresse terminée par `?graine=7` rejoue toujours les mêmes tirages (pour piloter le jeu automatiquement dans un navigateur au format téléphone).
