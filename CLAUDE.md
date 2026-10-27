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
- L'acolyte **annonce son action en premier** au début des 12 s ; le joueur choisit en le sachant. Le joueur lui donne une **posture** qui dure jusqu'à nouvel ordre : Libre, Protège-moi, Fonce, Garde ta forte. L'IA de l'acolyte doit être **prévisible plutôt que brillante**.
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
- **Une seule IA** pour l'acolyte, les Échos, les ennemis de la Tour et le simulateur, paramétrée par les postures.
- Données de jeu (classes, compétences, passifs, Synergies, nœuds de Destin, étages de la Tour) dans des fichiers de données lisibles (JSON ou .tres), jamais codées en dur dans la logique.
- Serveur prévu : Nakama + PostgreSQL (étape 5 de la feuille de route). Pas avant.
- Art : PixelLab via MCP (étape 6). Sprites provisoires d'ici là.
- Builds : GitHub Actions. Export **web publié sur GitHub Pages à chaque fusion sur `main`** pour que Gautier teste sur son téléphone. Android puis iOS (runner macOS + Fastlane) plus tard.
- Tests : `godot --headless` lance la suite de tests du moteur de règles en CI ; une PR ne fusionne pas si les tests échouent.

## Feuille de route (ordre impératif)

1. **Prototype de combat en duo (web).** Reprendre le moteur de l'étape 1 (3v3) et le passer en duo : l'acolyte avec ses 4 postures et son annonce, le duo du joueur contre un duo IA, 3 classes. **Critère de sortie : on a envie de relancer un combat.**
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
- Un perso mis KO avant d'agir perd son action. Un KO perd ses états. Un perso relevé revient à 30 % de ses PV, recharges remises à zéro, et n'agit qu'au tour suivant. On ne peut être relevé qu'une fois par combat, et la Résurrection ne sert qu'une fois par combat.
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

- Une seule IA (`engine/combat_ai.gd`) pour l'acolyte, le joueur IA d'en face et le simulateur. Pas de score caché : une liste de règles courtes essayées toujours dans le même ordre, la première qui s'applique décide. Textes et seuils dans `data/postures.json`.
- Règle commune à toutes les postures : un allié KO est relevé dès que possible (le joueur d'abord).
- **Libre** (selon le rôle principal de l'acolyte) : un Front pose sa protection sur le joueur dès qu'elle est prête (Provocation, Rempart), sinon sa forte, sinon sa basique ; un Dégâts joue forte, puis moyenne, puis basique, et ne secourt (soin, bouclier) que si quelqu'un passe sous 50 % ; un Soutien soigne le plus blessé sous 50 % (son plus gros soin prêt), sinon retire un état négatif, sinon joue sa forte, sinon sa basique.
- **Protège-moi** : protections sur le joueur dès qu'elles sont prêtes, soins sur lui dès qu'il a perdu 25 % de ses PV, état négatif retiré ; sinon il frappe **celui qui a frappé le joueur en dernier** (forte comprise). Une première version gardait la forte offensive : en simulation, la posture perdait 61 % des combats.
- **Fonce** : forte, puis moyenne, puis basique de dégâts, sur **la cible du joueur** (celle de son Intention, sinon celle du tour précédent, sinon l'ennemi le plus bas). Plus de soins ni de protections ; un Soutien sans attaque retombe sur Libre.
- **Garde ta forte** : comme Libre sans la forte ; elle part le tour où le joueur joue sa forte **ou une compétence qui fait Synergie avec elle**, sur la cible du joueur. Ajout au GDD pour qu'une Synergie moyenne + forte (Provocation + Nova) se construise aussi.
- « L'ennemi le plus bas » = le plus bas en % de PV ; à égalité, celui qui a le moins de PV (au tour 1, le plus fragile). Une protection ou un soin inutile (Rempart déjà posé, barrière déjà aussi grosse, allié à fond) est sauté, sauf pour la basique.
- En Libre et en Protège-moi, l'annonce de l'acolyte ne dépend jamais du choix du joueur (un test le vérifie sur des centaines de situations). En Fonce et en Garde ta forte, il réagit : il suit la cible ou lance sa forte avec celle du joueur.
- Le joueur IA d'en face connaît l'annonce de son acolyte, comme un humain : il relève et soigne l'urgence, puis cherche la Synergie avec l'annonce (jamais au prix d'un tour gâché), puis joue son rôle sur la même cible. Il change la posture de son acolyte : Protège-moi sous 40 % de PV, Fonce si un adversaire est sous 35 %, Garde ta forte quand sa propre forte revient au tour suivant, sinon Libre.
- Réglages pour le duo : en 2 contre 2 il n'y a plus que deux attaquants par camp, alors que les soins et les protections d'un Prêtre ou d'un Guerrier restent entiers. Mesuré : 41 dégâts par camp et par tour, premier KO au tour 8, un combat sur trois au décompte des PV (les duos Guerrier + Prêtre se neutralisaient). Changements : dégâts de toutes les compétences ×1,35 environ, Prière 44, Restauration 80, Cri de guerre +50 %, Fendoir 73, Boule de feu 40, Châtiment 43, Arc de foudre 38, Mage puissance 105, Prêtre 220 PV, mort subite +50 % par tour, Jugement et Courant de vie à ×1,5.
- Résultat en simulation (3 000 combats) : 8,8 tours en moyenne, premier KO au tour 6,3, 89 % des combats finis par KO, 68 % entre les tours 8 et 15 (le GDD vise 90 % : en duo, le combat se termine vite après le premier KO ; à revoir à l'étape 4). Classes : Guerrier 46 %, Mage 54 %, Prêtre 50 %. Écarts restants pour l'étape 4 : Prière (sans attaque) et Cri de guerre en dessous, Fendoir au-dessus.
- Postures gardées tout le combat contre Libre : Protège-moi 46 %, Fonce 51 %, Garde ta forte 48 %. Aucune ne domine : c'est un choix de situation.
- Limite connue : le simulateur ne démontre pas encore le pilier « le duo gagne ». Un joueur IA qui lit l'annonce et cherche les Synergies gagne 51 % contre un qui l'ignore, parce que les deux en déclenchent presque autant (1,6 contre 1,5 par combat) : quand chacun joue son rôle, les couples tombent d'eux-mêmes. Il faudra une IA qui prépare ses coups sur plusieurs tours (étape 4), et surtout le ressenti de Gautier.

**Écran et IA (2026-10-26, prototype)**

- Le joueur choisit sa classe au lancement et peut retirer son kit (« Autre tirage, prototype seulement ») : c'est volontairement contraire au Destin non modifiable, pour tester les 3 classes et tous les kits. À retirer quand les comptes arrivent (étape 4).
- Chaque équipe contient toujours un Guerrier, un Mage et un Prêtre (un Front, un Dégâts, un Soutien), kits tirés au hasard.
- Bouton « Prêt » : la phase d'Intention se termine dès que le joueur est prêt et que ses alliés ont décidé, sans attendre les 12 s.
- Les alliés IA décident entre 1 et 4,5 s après le début du tour, puis réajustent leur Intention quand le joueur change la sienne. Les ennemis décident entre eux sans voir nos Intentions.
- Si le joueur est KO, ses alliés continuent ; la phase d'Intention est raccourcie.
- Le joueur peut toucher n'importe quel perso pour voir son kit et ses recharges ; un badge « FORTE PRÊTE » s'affiche sur les ennemis dont la forte est disponible. On voit ce qu'un ennemi *peut* faire, jamais ce qu'il a choisi : ses Intentions restent cachées (GDD). (2026-10-27, pour que « maintenant ou au tour suivant » soit un vrai choix.)
- Prévision sur la cible visée : dégâts, soin, « KO ! » ou « Bloqué », calculée par le moteur (`Combat.preview`) sans tenir compte de ce que les autres feront avant. Sous chaque bouton, une ligne dorée nomme la Synergie possible avec un allié, et s'allume quand il la prépare.
- Ressenti (2026-10-27) : bruitages synthétiques provisoires (`tools/generate_sfx.py`, bouton pour couper le son), secousses d'écran, flash, annonce en grand des fortes et des Synergies, persos qui respirent, tremblent et tombent au KO. Toucher l'écran pendant la résolution l'accélère.
- Série de victoires, record et bilan V/D gardés sur l'appareil (`user://profil.cfg`) en attendant les comptes ; l'écran de fin montre ta part du combat et le meilleur des 6.
- (Remplacé le 2026-10-27 par l'IA à postures : voir « Duo : IA et réglages ».)
