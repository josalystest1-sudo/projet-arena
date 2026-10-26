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
