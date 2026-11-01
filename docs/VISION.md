# La vision du jeu — l'interview de Gautier du 1er novembre 2026

Ce document dit **ce que Gautier attend du jeu**, dans ses mots, et **ce que Claude en déduit pour le développer**. Il fait foi sur les intentions : quand un choix de game design, de graphisme ou d'équilibrage se pose et que le GDD ne tranche pas, on revient ici. Les règles précises restent dans `docs/GDD_V2.md` ; l'ordre du travail dans `docs/PLAN.md`.

## 1. Les réponses de Gautier

| Question | Réponse |
| --- | --- |
| Le jeu existant dont le fini se rapproche le plus (le feeling) | « Combat à la **Octopath Traveler**, et la navigation dans les menus à la **Shakes & Fidget**. » |
| Ce qui doit rendre le jeu unique | « Avoir un **personnage unique qui ne ressemble à aucun autre** dans le jeu, **guerre de guilde poussée**, **évolution d'un perso**. » |
| Une bonne journée de joueur | **Une vraie session le soir** (30 à 60 minutes d'affilée : la Tour, un donjon, la guilde). |
| Pour qui | **Des joueurs comme lui** : des gens qui ont connu Dofus ou les RPG, qui aiment optimiser et comprendre un système profond. |
| Unique en quoi | **Sa façon de jouer** (sa roue tirée à la création, ses formes, ses choix de nœuds, son évolution), renforcée par « **énormément de classes différentes** ». |
| Ce qu'il veut retrouver d'Octopath | **Les effets des combats**, « **des petites cinématiques pour chaque coup ultime** », **la mise en scène** (sprites en pixel art sur un décor en profondeur, animations des coups, chiffres qui jaillissent), **le rythme et la lisibilité**. |
| Le temps pour atteindre le niveau 30 et l'évolution | **Un à deux mois** pour un joueur assidu (une session chaque soir) : l'évolution est un vrai cap, qu'on prépare et qu'on attend. |
| Ce qui retient un joueur au niveau max | « **Looter des items toujours plus rares en donjon** pour avoir l'équipement parfait, **ou le vendre et devenir riche** », les guerres de guilde, le classement de l'Arène, la Tour sans fin. |
| Ce qui manque aux guerres de guilde | « **Chaque guilde, même petite, peut être une menace** », des **enjeux plus gros** (des bonus qui comptent vraiment, une capitale de région, un classement des guildes avec des titres), des **batailles plus riches** (sortes d'attaques différentes, murs à abattre, boss de territoire à vaincre ensemble). |
| Comment une petite guilde menace une grosse | **Des limites pour les grosses** (une grosse guilde ne tient qu'un nombre limité de territoires, et plus elle en tient plus ils sont faciles à prendre) et **les alliances** (plusieurs petites guildes s'allient contre une grosse le temps d'une guerre). |
| Le social indispensable | **Le chat de guilde**, **les amis et les Échos choisis** (prendre le perso d'un ami comme Écho), **du jeu ensemble en direct** (combats à 3 contre 3 avec de vrais joueurs connectés, donjons de guilde en groupe). |
| La descente idéale en donjon | « En gardant la **mécanique de chemin** et **un seul mène vraiment au boss**, qui possède **une ou plusieurs astuces** pour le vaincre. » |
| Le cœur du jeu | **Le combat** : chaque combat doit être un plaisir, lisible, beau, tendu ; tout le reste n'est qu'une raison de combattre. |
| L'univers | **Fantasy classique**. |
| Les graphismes | **Pixel art détaillé et animé** (des sprites de la taille d'Octopath, des animations de coups, des décors en profondeur, des cinématiques d'ultime). |
| Qui les produit | **Gautier avec des outils d'IA**, « j'ai peur de ne pas avoir les compétences, j'aurai dans tous les cas besoin de l'aide d'une IA » ; Claude intègre et aide. |
| L'argent | **Cosmétiques**, et « **des items de réinitialisation de classe, ou autres de confort** ». Jamais de puissance vendue. |
| Combien de classes | **Ce qui est prévu suffit** : 10 classes, 30 évolutions, puis 90 de rang 2 et les classes de grimoire, débloquées au fil des mises à jour. |
| Ses inquiétudes | « **Que je n'arrive pas à rendre réels les graphismes que j'ai imaginés** pour le jeu et **que ça coûte trop cher** », les tricheurs et les bots, que ce soit trop gros. |

## 2. La vision en dix lignes

1. Un RPG de téléphone, en portrait, qu'on joue **le soir, une vraie session**, avec des joueurs qui aiment les systèmes profonds.
2. **Le combat est le cœur** : tour par tour simultané, sans hasard, lisible, et **mis en scène comme Octopath Traveler** (effets, animations, une cinématique par Clé).
3. **Ton personnage ne ressemble à aucun autre** : sa roue est tirée une fois, ses choix sont définitifs, et il y a beaucoup de classes et d'évolutions.
4. **L'évolution est le grand cap** d'un personnage : un à deux mois de jeu assidu pour l'atteindre.
5. **La fin de jeu, c'est le butin** : les donjons à chemins, un seul mène au boss, et le boss a ses astuces ; l'objet parfait se loote, se garde ou se vend.
6. **Les guerres de guilde font vivre le serveur** : chaque guilde, même petite, est une menace ; les enjeux comptent ; les batailles ont des formes.
7. **Le social est dans le jeu** : chat de guilde, amis, Échos choisis, et du jeu ensemble en direct.
8. **Fantasy classique**, lisible tout de suite.
9. **Pixel art détaillé et animé**, produit avec des outils d'IA ; c'est le plus gros risque du projet.
10. **Gratuit, financé par les cosmétiques et le confort**, jamais par la puissance.

## 3. Ce que ça change dans le jeu (décisions de design qui découlent de l'interview)

Tout ce qui suit est **[Décidé]** par Gautier le 1er novembre, par ses réponses ; le détail des règles reste à écrire dans le GDD au moment de le faire.

- **Les menus à la Shakes & Fidget** : la ville à bâtiments reste l'accueil ; chaque écran doit se lire d'un coup d'œil, avec peu de texte, de grandes cases et des chiffres bien visibles. Pas de menus profonds.
- **Le combat d'abord, dans la mise en scène** : la phase des graphismes commence par l'écran de combat (sprites, animations d'attaque, de coup reçu et de KO, effets des états, chiffres qui jaillissent, décor en profondeur), et **chaque Clé a sa cinématique** (un « cut-in » court : le personnage en grand, le nom de la Clé, un effet propre). Avec 10 classes × 5 Clés (puis 30 évolutions), les cinématiques sont construites à partir d'un gabarit par type d'effet, personnalisé par la classe (couleur, pictogramme, effet), pas dessinées une à une.
- **Un à deux mois jusqu'au niveau 30** : la courbe d'XP se règle à l'équilibrage pour qu'un joueur assidu (une session par soir) atteigne le niveau 30 en 30 à 60 sessions. Aujourd'hui, le jeu publié monte beaucoup plus vite : c'est voulu pour tester.
- **Les guerres de guilde « poussées »** (à faire avant les graphismes, dans le game design) :
  - **des limites pour les grosses guildes** : un nombre maximal de territoires par guilde, et une défense qui faiblit avec le nombre de territoires tenus ;
  - **les alliances** : deux guildes ou plus s'allient le temps d'une guerre contre une cible commune (leurs combats comptent ensemble ; un territoire pris va à l'allié qui a déclaré) ;
  - **des enjeux plus gros** : une capitale par région (un territoire qui vaut davantage et qui donne un titre), un classement des guildes de la saison, des bonus de territoire qui se sentent (butin, XP, accès réservé au donjon de la semaine) ;
  - **des batailles plus riches** : des sortes d'attaques (siège, raid, embuscade) aux règles différentes, des murs (un Bastion à abattre avant la prise), un boss de territoire à vaincre ensemble.
- **Les donjons** : la mécanique actuelle (trois portes par profondeur, une seule route vers le boss, le boss à paliers avec sa solution) est la bonne ; il faut **plus d'astuces par boss** et des **objets rares propres aux donjons** (la fin de jeu).
- **Le social** demande le vrai serveur (Supabase) : le **chat de guilde**, la **liste d'amis** (prendre le perso d'un ami comme Écho), puis **le jeu en direct** (3 contre 3 avec de vrais joueurs, donjons de guilde). Le jeu en direct vient **après la version 1**.
- **L'univers est la fantasy classique** : les noms des objets, des monstres et des territoires restent dans ce ton. Le nom du jeu est à choisir.
- **L'argent** : une boutique de **cosmétiques** (tenues, couleurs, animations d'ultime, bannières, titres) et de **confort** (un objet qui remet la roue à zéro ou change de classe, un sac plus grand, plus d'annonces au Marché). La remise à zéro du Destin, interdite dans le jeu, devient donc un **objet de confort payant** : à écrire au GDD avec ses limites.
- **Le nombre de classes** : les 10 + 30 + 90 + grimoires prévus suffisent ; pas de nouvelles classes de départ.

## 4. Comment Claude va développer le jeu (le plan révisé)

L'ordre de Gautier reste : **tout le game design, puis les graphismes, puis l'équilibrage**. L'interview le précise et fixe ce que la **version 1** contient.

### 4.1 Finir le game design de la version 1 (en cours)

1. **Les classes de grimoire** (prévu) : rares, épiques, légendaires, lâchées par les boss de donjon, ligue Ascendants, sans évolution.
2. **Les guerres de guilde poussées** : limites des grosses guildes, alliances, capitale et classement des guildes, sortes d'attaques, boss de territoire. Une PR par brique.
3. **Les donjons de fin de jeu** : plus d'astuces par boss, des objets rares propres à chaque donjon, les routes secrètes.
4. **La boutique** (le bâtiment grisé) : son catalogue (cosmétiques, confort) sans paiement réel pour l'instant ; l'objet de remise à zéro du Destin.
5. **Le chat de guilde et les amis** : le design et l'écran, branchés sur le serveur simulé, prêts pour Supabase.

Ce qui attend **après la version 1** : le rang 2 (dans les données, caché), le jeu en direct (3 contre 3 synchrone, donjons de guilde), le paiement réel.

### 4.2 Les graphismes (phase 10), le plus gros risque

Gautier a peur de ne pas savoir produire les graphismes qu'il imagine et que cela coûte trop cher. La réponse est une **chaîne de production gratuite, par étapes validées**, où personne ne dessine à la main :

1. **La bible graphique** (un document avec des images) : le style exact (taille des sprites, palette, épaisseur du trait, lumière), des exemples de référence, les règles d'animation. Claude l'écrit, Gautier la valide.
2. **Un personnage complet comme preuve** : un Guerrier avec toutes ses poses (repos, attaque, coup reçu, KO, victoire), un décor de combat, les effets d'une voie et la cinématique d'une Clé. Produit avec des outils d'IA de génération d'images (depuis l'app Claude ou des outils gratuits), nettoyé par du code (mise à la palette, taille exacte, feuilles de sprites). **Si cette étape ne convainc pas, on change d'approche avant d'avoir tout produit** (packs d'assets, ou un artiste payé plus tard avec une liste exacte et un budget).
3. **La production en série** : les 10 classes, les 14 monstres, les décors (Tour, donjons, carte, ville), les effets des 16 états, les pictogrammes, les cinématiques des Clés par gabarit. Toujours par lots validés par Gautier.
4. **L'intégration** : des sprites animés à la place des grilles de caractères, un écran de combat mis en scène (profondeur, caméra, chiffres), la ville et les écrans habillés.

Gautier produit lui-même des images quand il le souhaite (outils d'IA, pixel art) ; Claude les intègre de la même façon.

### 4.3 Le serveur réel et le social

Dès que Gautier a créé le projet Supabase (`docs/serveur/GUIDE-SUPABASE.md`) : brancher les comptes, les fiches, l'Arène, le Marché, les guildes, les territoires, les guerres, puis le chat de guilde et les amis (Supabase Realtime, palier gratuit). Les garde-fous contre les bots et l'Or farmé (`docs/ECONOMIE.md`) sont déjà dans le jeu ; côté serveur, ils seront des règles de la base (limites par jour, taxe), à écrire dans le SQL.

### 4.4 L'équilibrage (en dernier)

Avec les outils déjà faits (`tools/regleur.py`, `tools/regleur_tour.py`, `tools/economie.py`) : la courbe d'XP (niveau 30 en un à deux mois), les classes, la Tour (un Gardien moindre tous les trois niveaux environ), l'économie, les guerres (une petite guilde doit pouvoir gagner).

### 4.5 La sortie de la version 1

Une petite communauté d'abord (des joueurs comme Gautier), le jeu gratuit, sans paiement ; on regarde ce qui est joué et ce qui retient, puis le rang 2, le jeu en direct et la boutique réelle.

## 5. Ce que Claude s'engage à faire en pratique

- Revenir à ce document avant tout choix de design ; quand il ne tranche pas, demander à Gautier avec une proposition.
- Garder la version 1 **petite** (ce qui est écrit ici, rien de plus) pour répondre à l'inquiétude « trop gros ».
- Faire la preuve graphique (un personnage complet) **avant** de produire en série, pour répondre à l'inquiétude « je n'y arriverai pas » et « trop cher ».
- Mettre le combat en premier dans chaque phase : design, graphismes, équilibrage.
