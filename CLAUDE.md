# Projet Arena — mémoire du projet

Ce fichier est lu au début de chaque session. Il résume ce qu'il faut savoir pour travailler sur le jeu sans relire tout le GDD. La source de vérité complète est `docs/GDD.md` : en cas de doute sur une règle, c'est lui qui tranche.

## Qui est le propriétaire du projet et comment travailler avec lui

- Gautier ne lit pas de code et n'utilise jamais de terminal. Il travaille uniquement depuis l'interface de l'app Claude.
- Chaque fin de session : explique ce qui a été fait en langage courant, sans jargon, et donne-lui quelque chose à tester (une adresse web à ouvrir sur son téléphone, un comportement à vérifier).
- Jamais de commande à lui faire taper. Si une action manuelle est indispensable (créer un compte, cliquer dans une interface web), décris-la bouton par bouton.
- Avance par petites PR lisibles, une par étape. Titre et description en français.
- Quand le GDD ne dit rien, choisis, et note le choix dans la section « Choix faits par Claude Code » ci-dessous.

## Le jeu en dix lignes

- RPG mobile PvP **3 contre 3**, tour par tour **simultané** : 12 s pour choisir, puis résolution par ordre de vitesse.
- Un seul personnage par compte. Son **Destin** (arbre de 45 nœuds, 30 points, généré aléatoirement, unique au monde, non modifiable) détermine ses 3 compétences actives, son passif et ses bonus.
- **10 classes de base** : Guerrier, Mage, Voleur, Archer, Prêtre, Alchimiste, Invocateur, Barde, Diplomate, Pugiliste. Trois rôles : Front, Dégâts, Soutien ; chaque classe a un rôle principal et un secondaire.
- Chaque classe : pool de **6 actives** (2 basiques, 2 moyennes, 2 fortes) et **4 passifs** ; un personnage tire **une active de chaque palier + 1 passif**.
- **Recharges** : basique sans recharge ; moyenne 2 tours ; forte 4 tours, disponible à partir du tour 3. Pas de mana, pas de ressource partagée. Le Tempo et la Brèche ont été abandonnés : ne pas les réintroduire.
- **Intentions** : pendant les 12 s, chaque joueur voit en transparence ce que ses alliés choisissent. L'adversaire ne voit rien.
- **Synergies** : couples de compétences de deux alliés jouées le même tour → effet bonus unique par couple. Au moins une Synergie entre chaque paire de classes.
- **Évolution** au niveau 30 : choix parmi 3, saut de puissance ×2,5, nouveau Destin à zéro. Deux ligues séparées : Aspirants (classes de base) et Élus (évolutions). V1 = 10 classes + 30 évolutions.
- **Échos** : les joueurs absents sont remplacés par leur propre personnage piloté par l'IA. Matchmaking par rôle (un Front, un Dégâts, un Soutien par équipe) et par ligue.
- Financement par **cosmétiques uniquement** (skins de lignée, animations, poses). Aucune limite de parties. Jamais de puissance vendue.

## Stack et architecture

- **Godot 4, GDScript**, un seul projet pour iOS, Android et web.
- **Règle d'architecture n°1** : le moteur de règles du combat (recharges, Synergies, résolution d'un tour, ordre de vitesse, mort subite, KO et relève) est un **module pur, sans affichage, sans dépendance aux nœuds de scène**, couvert par des tests automatiques. Il sera réutilisé tel quel par le serveur (version qui fait foi), par le client (affichage et prévision), par l'IA des Échos et par le simulateur d'équilibrage.
- Données de jeu (classes, compétences, passifs, Synergies, nœuds de Destin) dans des fichiers de données lisibles (JSON ou .tres), jamais codées en dur dans la logique.
- Serveur prévu : Nakama + PostgreSQL (étape 4 de la feuille de route). Pas avant.
- Art : PixelLab via MCP (étape 5). Sprites provisoires d'ici là.
- Builds : GitHub Actions. Export **web publié sur GitHub Pages à chaque fusion sur `main`** pour que Gautier teste sur son téléphone. Android puis iOS (runner macOS + Fastlane) plus tard.
- Tests : `godot --headless` lance la suite de tests du moteur de règles en CI ; une PR ne fusionne pas si les tests échouent.

## Feuille de route (ordre impératif)

1. Prototype de combat web : moteur de règles + 3 classes (Guerrier, Mage, Prêtre) + IA simple + écran de combat minimal + publication GitHub Pages. **Critère de sortie : on a envie de relancer un combat.**
2. Les 10 classes complètes et le générateur de Destin (budget de puissance).
3. Le simulateur d'équilibrage (moteur sans interface, centaines de milliers de combats, taux de victoire par classe / compétence / nœud).
4. Serveur, comptes, matchmaking, PvP réel, Échos, classement.
5. Art PixelLab et les 11 écrans.
6. Les 30 évolutions et la Ligue des Élus.
7. Boutique et paiements.
8. Bêta fermée Android puis TestFlight.
9. Lancement.

## Décisions verrouillées (ne pas rouvrir sans l'accord de Gautier)

Voir `docs/GDD.md`, section « Décisions prises et questions ouvertes ». En particulier : pas de Garde/Brèche, pas de Tempo, pas de pierre-feuille-ciseaux, pas d'énergie ni de limite de parties, Destin non modifiable, un seul personnage par compte.

## Questions encore ouvertes (à poser à Gautier au bon moment, pas avant)

- Univers : trois pistes dans le GDD (La Veille, Le Tissage, La Foire des Dieux oubliés). Nécessaire à partir de l'écran de création (étape 5).
- Nom définitif du jeu.
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

- Chiffres : Guerrier 330 PV, vitesse 9, puissance 100 ; Mage 230 PV, vitesse 8, puissance 110 ; Prêtre 270 PV, vitesse 7, puissance 100. Dégâts = puissance de la compétence × puissance du perso / 100.
- Recharges : une moyenne jouée au tour N revient au tour N+3, une forte au tour N+5 ; forte jouable à partir du tour 3.
- Ordre du tour : la file est calculée au début de la résolution (vitesse + bonus de la compétence + passifs). À vitesse égale, la priorité est **tirée à pile ou face à chaque combat puis alterne à chaque tour** (sans ça, l'équipe prioritaire gagnait 56 % des combats miroirs en simulation).
- Coup de bouclier : la cible échange sa place avec celle qui la suit dans la file. Trait de givre : la cible passe en fin de file ; si elle a déjà agi, elle agira en dernier au tour suivant.
- Provocation : la cible choisie et le prochain ennemi à agir sont provoqués ; ne détourne que les compétences offensives (un soin reste un soin).
- Rempart : protège jusqu'à la fin du tour suivant ou jusqu'au premier coup (les dégâts sur la durée ne le consomment pas). Les barrières ne se cumulent pas : la plus grosse reste.
- Un perso mis KO avant d'agir perd son action. Un KO perd ses états. Un perso relevé revient à 30 % de ses PV, recharges remises à zéro, et n'agit qu'au tour suivant. On ne peut être relevé qu'une fois par combat, et la Résurrection ne sert qu'une fois par combat.
- Mort subite au tour 10 (soins ÷2, dégâts +25 % par tour cumulés), fin forcée à la fin du tour 15 : plus de PV totaux, puis plus de dégâts infligés, puis l'équipe prioritaire. Jamais de match nul. En simulation, 100 % des combats finissent entre les tours 8 et 15.
- 4e passif inventé pour chaque classe (le GDD n'en donne que 3) : Colère (Guerrier, +10 % de dégâts par quart de PV manquant), Météorologue (Mage, forte revient 1 tour plus tôt), Sanctuaire (Prêtre, barrières +25 %).
- Synergies du prototype : Provocation + Nova (celle du GDD) et trois nouvelles pour couvrir chaque paire de classes : Bastion (Rempart + Prière, le Rempart se reforme), Éclat (Trait de givre + Châtiment sur la même cible, +40 dégâts de lumière), Plaie brûlante (Fendoir + Boule de feu sur la même cible, saignement +2 tours). Une Synergie se déclenche quand la seconde compétence du couple se résout, même si la première est passée avant.
