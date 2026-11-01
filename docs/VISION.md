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


---

# Deuxième interview (1er novembre, même jour) : les coins d'ombre

Gautier a demandé d'aller plus loin : « il doit te rester plein d'éléments non pensés, pose toutes les questions qui vont t'éclairer ». Dix tours de quatre questions. Ses réponses, puis ce qui change, puis la proposition d'économie qu'il a demandée, puis le nouvel ordre de travail.

## 6. Les réponses de Gautier (deuxième interview)

### Le combat

| Question | Réponse |
| --- | --- |
| Les Échos annoncent avant le joueur | **Oui, on garde** : le joueur joue en dernier, chef d'orchestre. |
| Le chrono en PvP | **30 secondes par tour** (au lieu de 20). La mort subite au tour 18 n'a pas été contestée. |
| Un allié KO | **On peut le relever** : un Soutien a un nœud ou une Clé de résurrection (rare, coûteux) ; les retournements sont possibles. |
| La durée d'un tour animé | **Rapide, 3 à 5 secondes** ; seules les Clés ont une vraie cinématique (2 secondes). |

### La création, le compte, les plateformes

| Question | Réponse |
| --- | --- |
| À la création | **Classe, nom et apparence** (genre, peau, cheveux, couleurs : un éditeur simple, visible sur le sprite). |
| Un seul personnage par compte | **Oui, un seul** : le compte, c'est le perso. |
| L'objet qui remet le Destin à zéro ou change de classe | **Gagnable aussi en jeu** (un par saison : classement, Tour), ou achetable. |
| Les plateformes | **Le web d'abord**, comme aujourd'hui. |

### Le rythme, la fatigue, la Tour, les donjons, l'histoire

| Question | Réponse |
| --- | --- |
| Les limites par jour | « Classé limité à 5 par jour. Les donjons sont illimités si on peut payer l'entrée ; cependant **si on enchaîne trop, le personnage devient de plus en plus fatigué, et plus il est fatigué, moins il est performant. Pour être en forme, il faut faire des pauses ou prendre une potion d'énergie.** » |
| La Tour | « **La Tour ne se monte qu'une fois** ; le joueur peut refaire d'anciens étages quand il veut, mais **moins l'étage est haut, moins la récompense est forte**. Refaire un étage coûte de l'énergie ; quand l'énergie est faible, le personnage devient moins fort, et s'il continue, **il s'écroule de fatigue et doit attendre** avant de relancer. **Le butin de la Tour, c'est de l'équipement commun ou peu commun**, dont le niveau monte avec les étages. **Butin non assuré** : des fois, on gagne juste de l'XP et de la monnaie. » |
| Ce qui fatigue | **Seulement le « farm »** : rejouer un étage déjà battu et enchaîner les donjons. Le record de la Tour, les classés, les guerres, l'amical : jamais. |
| Le rythme de la fatigue | **Court** : fatigué après 8 à 10 combats de farm, repos en 2 ou 3 heures ; on fait des pauses dans la soirée. |
| La potion d'énergie | **L'Alchimiste du Comptoir** : achetable contre des Éclats ou de l'Or, en nombre limité par jour. |
| Les donjons | **Illimités**, sous réserve de payer l'entrée et de ne pas être fatigué. |
| Une histoire | **Juste de l'ambiance** : descriptions, noms, bestiaire ; pas de quêtes ni de dialogues. |

### L'équipement

| Question | Réponse |
| --- | --- |
| Les raretés | **Cinq** : commun, peu commun, rare, épique, légendaire. La Tour lâche les deux premières, les donjons les trois dernières. |
| Les emplacements | **Huit, à la Dofus** : arme, casque, armure, cape, bottes, ceinture, anneau, amulette. |
| L'équipement visible sur le sprite | **Non** : les cosmétiques font l'apparence ; l'équipement n'est que des chiffres. |
| Faire progresser un objet | **Un niveau d'amélioration de +1 à +10, payé en monnaie ; si ça échoue, on perd un cran** (« si je veux passer de +3 à +4 et que ça rate, je passe à +2 »). |
| L'échange entre joueurs | **Seulement par le Marché** (annonces anonymes, taxe) : pas de don, pas d'échange direct. |

### L'économie

| Question | Réponse |
| --- | --- |
| À quoi sert l'Or | « **Il va falloir se reposer les questions sur l'économie.** Je passe cette question, et **il faudra que tu me trouves une solution anti-bots et anti-inflation.** » (→ § 8) |
| L'Or contre de l'argent réel | **Jamais**, d'aucune façon. |
| Le Marché | **Annonces anonymes, 7 jours.** |
| Contre les bots | **L'âge et le niveau** du compte (ce qui existe) et **un compte vérifié pour vendre** (une adresse mail confirmée ; pas de carte, pas de téléphone). |

### Les guildes

| Question | Réponse |
| --- | --- |
| Un trésor de guilde | **Oui, en Or et en Influence** : les membres donnent de l'Or ; le trésor paie les effets, la bannière, les guerres ; le chef et les rôles autorisés dépensent. |
| Des activités en plus des guerres | **Un boss de guilde** (chaque semaine, tous le frappent chacun de son côté, récompenses selon la part) et **un donjon de guilde** (réservé aux membres, ses salles s'ouvrent avec les fragments trouvés par tous). |
| La taille | **Plus petites : 50 au plus** (plus de guildes, plus de guerres, chaque membre compte). |
| Changer de guilde | **Libre, avec un délai** : on part quand on veut, on ne rejoint une autre guilde qu'après 3 jours, et on ne combat pas en guerre la première semaine. |

### Les territoires et les guerres

| Question | Réponse |
| --- | --- |
| Le rythme des guerres | « **Il faut mettre au clair avec toi le fonctionnement des guerres de guilde avant de répondre.** » |
| La forme d'une guerre | « **Je n'ai pas encore d'idée en tête pour les combats de guilde. Il faut qu'on voie ça tous les deux**, qu'on réfléchisse à quelque chose. Mais dans tous les cas, **je ne veux pas que ce soit juste des combats faits à la suite. Je veux que les officiers de chaque guilde aient une importance sur le placement. Je veux que ce soit du 3 contre 3 comme tous les formats de combat, mais avec 3 joueurs, pas de PNJ.** Est-ce que les joueurs doivent être connectés ? On ne peut pas leur demander d'être tout le temps connectés. Ce qu'on peut faire, c'est **leur donner un avantage s'ils sont connectés, et sinon laisser l'IA jouer leur perso** : les gens se connectent pour avoir plus de chances de gagner. **Il faudrait qu'on décide vraiment du gameplay.** » |
| La durée | « Vu qu'il y a un aspect officier et préparation, on ne peut pas faire une guerre par jour. Ce que je propose : **2 jours de préparation, 1 jour de guerre**. Hypothétique ; **ne pas le prendre au pied de la lettre.** » |
| Qui fait quoi | **Les officiers planifient, les défenseurs présents jouent, les alliés renforcent**, et autre chose à définir ensemble. |
| La fin de saison | **Tout redevient neutre** ; la guilde qui tenait le plus reçoit un titre et un coffre. |
| Ce que gagne un joueur | **Des bonus de jeu, un revenu (Or ou Éclats chaque jour selon les territoires), des cosmétiques et des titres.** |

### L'Arène et les Échos

| Question | Réponse |
| --- | --- |
| L'adversaire classé | « **En classé, seul le nombre de points du joueur sert à trouver un adversaire.** Comme ça, un bon joueur peut monter, et un mauvais joueur finit forcément par monter parce qu'il commence à avoir du bon stuff. » (Plus de niveau à ±2.) |
| Les récompenses de saison | **Un titre et une aura, un coffre selon la ligue, un cosmétique exclusif.** |
| Être pris comme Écho | **Oui, un petit revenu** (des Éclats à chaque fois que ton perso est choisi). |
| Les replays | **Non.** |

### Le social

| Question | Réponse |
| --- | --- |
| Les canaux | **Le chat de guilde**, et « si possible, **un moyen rapide pour que les guildes mettent leur lien Discord** dans une interface, et que les gens aient juste à cliquer dessus ». Pas de canal général. |
| Les amis | **Prendre un ami comme Écho, le duel amical, voir ses progrès.** |
| La modération | **Un filtre de mots.** |
| Les langues | **Français seulement.** |

### L'univers, le son, l'argent, la sortie

| Question | Réponse |
| --- | --- |
| Le nom et l'univers | **Plus tard, avec les graphismes.** |
| La musique | **Orchestral pixel, à la Octopath** (des thèmes riches, produits avec des outils d'IA). |
| La boutique | **Des tenues (2 à 5 €)** et **un passe de saison (5 à 10 €)** de cosmétiques. |
| La première sortie | **Ouverte à tous dès que c'est joli** (Discord, Reddit, etc.). |

## 7. Ce qui change (décisions du 1er novembre, deuxième interview)

Tout ce qui suit est **[Décidé]** par Gautier, sauf mention.

- **Le combat** : chrono PvP à **30 s** ; **la résurrection** entre dans le jeu (un nœud ou une Clé de Soutien, rare et coûteux : à placer dans les roues des Soutiens, avec son coût dans la grille du budget) ; la résolution d'un tour vise 3 à 5 s, cinématique de Clé 2 s.
- **La fatigue** (nouveau système) : une jauge d'énergie par personnage. **Seul le farm fatigue** : rejouer un étage déjà battu, enchaîner les donjons. Le record de la Tour, les classés, les guerres, l'amical ne fatiguent jamais. Fatigué après 8 à 10 combats de farm : les valeurs du personnage baissent avec la fatigue ; au bout, **il s'écroule** et doit attendre. Repos en 2 ou 3 heures. **La potion d'énergie** s'achète au Comptoir (chez l'Alchimiste), en nombre limité par jour, contre des Éclats ou de l'Or. Chiffres exacts à l'équilibrage.
- **La Tour** : une seule montée (le record) ; les étages passés se rejouent à volonté, en fatiguant, avec une récompense qui baisse avec la hauteur de l'étage ; **butin commun ou peu commun**, au niveau de l'étage, **pas toujours** (parfois XP et monnaie seulement). Les objets épiques et légendaires ne viennent plus de la Tour mais **des donjons** (et des grands Gardiens, à confirmer).
- **L'équipement, refondu** : **cinq raretés** (commun, peu commun, rare, épique, légendaire), **huit emplacements** (arme, casque, armure, cape, bottes, ceinture, anneau, amulette ; le catalogue des bases passe de 30 à environ 48), **l'amélioration +1 à +10** (payée en Or, un échec fait perdre un cran ; c'est **le seul hasard du jeu hors combat avec la création** : il ne touche jamais un combat), la reforge reste. **Rien ne se voit sur le sprite** : l'apparence vient de l'éditeur de création et des cosmétiques. Échange **seulement par le Marché**.
- **La création** : classe, **nom et apparence** (un éditeur simple : genre, peau, cheveux, couleurs). **Un seul personnage par compte.** L'objet de remise à zéro du Destin : un par saison gagnable en jeu, ou achetable.
- **Les donjons** : illimités, payés en Éclats, soumis à la fatigue.
- **Pas d'histoire** : de l'ambiance (descriptions, noms, bestiaire). **Français seulement.** Le nom du jeu attend les graphismes.
- **Les guildes** : **50 membres au plus** (à retailler : 20 au départ, +5 par niveau par exemple) ; **un trésor** en Or et en Influence (dons des membres ; le trésor paie les effets, la bannière, les guerres ; les rôles autorisés dépensent) ; **un boss de guilde** par semaine ; **un donjon de guilde** ouvert par les fragments de tous ; **un lien Discord** cliquable sur la fiche de la guilde ; **changer de guilde** : libre, 3 jours avant d'en rejoindre une autre, pas de guerre la première semaine.
- **Les guerres de guilde : à concevoir ensemble**, dans une séance à part, avant de les coder. Les contraintes de Gautier : pas une suite de combats ; les officiers comptent par **le placement** ; des **trios de trois vrais joueurs** (pas de PNJ, pas d'Échos générés) ; un **avantage aux connectés**, l'IA joue les absents ; **deux jours de préparation puis un jour de guerre** (hypothèse). Ce qui existe (PR #87) reste comme base technique. En fin de saison, **tout redevient neutre** (titre et coffre à la meilleure guilde). Tenir des territoires donne **des bonus de jeu, un revenu quotidien à chaque membre, des cosmétiques et des titres**.
- **L'Arène** : l'adversaire classé est choisi **par les points seulement** (plus de contrainte de niveau) ; récompenses de saison : **titre et aura, coffre selon la ligue, cosmétique exclusif** ; pas de replays.
- **Les Échos** : être choisi comme Écho **rapporte des Éclats** à son propriétaire.
- **Le social** : chat de guilde, lien Discord, amis (Écho, duel amical, progrès), filtre de mots ; pas de canal général.
- **Le son** : orchestral pixel, à la Octopath, produit avec des outils d'IA.
- **La boutique** : des tenues (2 à 5 €) et un passe de saison (5 à 10 €) ; **l'Or ne s'achète jamais**, d'aucune façon.
- **La sortie** : sur le web, ouverte à tous dès que c'est joli.

## 8. L'économie : la proposition de Claude (à valider par Gautier)

Gautier demande « une solution anti-bots et anti-inflation ». Voici une proposition complète, à discuter ; elle part de ce qui existe (PR #83 : l'Or mesuré, la taxe qui monte, les garde-fous) et de ses réponses (jamais d'Or contre de l'argent réel, Marché seulement, compte vérifié pour vendre, amélioration +1 à +10, fatigue).

### Le principe : deux monnaies, deux rôles

- **Les Éclats** (liés, jamais échangeables) : la monnaie **du joueur seul**. Gagnés en jouant (étages, duels, objectifs, revenu du jour, recyclage, être pris comme Écho). Ils paient **ce qui ne concerne que toi** : la reforge, l'entrée des donjons, les potions d'énergie, l'étal du Comptoir. Un bot qui farme des Éclats ne gagne rien de transmissible : **les Éclats ne valent rien pour un revendeur.**
- **L'Or** (échangeable) : la monnaie **entre joueurs**. Il n'a qu'une source : **le Comptoir, qui achète les objets échangeables** (ceux du premier passage d'un étage ou d'un donjon). Il n'a qu'un circuit : **le Marché**. Il a des puits : **la taxe** (détruite), **l'amélioration +1 à +10** (payée en Or, détruite), le trésor de guilde (immobilisé), des cosmétiques achetables en Or (détruits).

### Anti-bots : rendre le farm d'Or inutile plutôt que l'interdire

1. **L'Or ne naît que d'objets de premier passage.** Un étage ou un donjon rejoué lâche des objets **liés** (invendables au Comptoir, recyclables en Éclats). Un compte a donc une quantité d'Or finie à créer sur toute sa vie, qui croît seulement en progressant (nouveaux étages, nouveaux donjons). Un bot ne peut pas « farmer » : il doit **progresser**, ce qu'un bot fait mal (le combat sans hasard contre l'IA demande de jouer).
2. **La fatigue** borne le farm d'objets liés par jour ; elle ne touche pas la création d'Or (qui est déjà bornée par le premier passage).
3. **Vendre au Marché demande** : niveau 15, 7 jours de compte, **une adresse mail confirmée** (décision de Gautier), et au plus 5 annonces et 10 ventes au Comptoir par jour.
4. **La fourchette de prix** (du plancher à un multiple selon la rareté) empêche le transfert d'Or déguisé (un objet commun vendu 10 000 Or à un complice) : c'est la faille classique des revendeurs d'Or. Elle existe déjà.
5. **La taxe est détruite** (15 %, jusqu'à 40 %) : chaque transfert entre comptes perd de la valeur ; une chaîne de comptes mules fond.
6. **Pas de don, pas d'échange direct, jamais d'Or contre de l'argent réel** (décisions de Gautier) : il n'y a rien à vendre pour un revendeur, et rien à acheter pour un tricheur.
7. **Le serveur tient les comptes** : le solde d'Or et chaque mouvement vivent sur le serveur (table `mouvements`, déjà prévue), jamais dans le téléphone ; un client modifié ne peut pas s'inventer de l'Or. Plus tard : une détection des rythmes anormaux (combats 24 h sur 24) qui gèle le Marché pour le compte, revue à la main.

### Anti-inflation : mesurer, puis freiner là où ça entre et aspirer là où ça sort

1. **La mesure existe** (`Economie.bilan`) : chaque semaine, l'Or créé (Comptoir) contre l'Or détruit (taxe, et désormais amélioration et cosmétiques en Or).
2. **La taxe monte** quand l'Or créé dépasse 4 fois l'Or détruit (jusqu'à 40 %) : déjà en place.
3. **Nouveau : le Comptoir paie moins quand l'Or abonde.** Le prix plancher d'achat du Comptoir baisse (jusqu'à −50 %) quand l'Or en circulation par joueur actif dépasse un seuil, et remonte quand il baisse. L'Or devient plus rare à créer précisément quand il y en a trop.
4. **Nouveau : des puits qui grandissent avec la richesse.** L'amélioration +1 à +10 coûte de plus en plus cher à chaque cran (par exemple ×1,6 par cran : +10 vaut des centaines de fois +1) et **un échec détruit l'Or payé** ; les riches y versent leur fortune pour l'objet parfait, ce qui est exactement ce que Gautier veut (« avoir l'équipement parfait ou le vendre et devenir riche »). Des cosmétiques en Or (une partie des tenues, des titres) donnent une raison d'être riche sans toucher à la puissance.
5. **Les prix du Marché restent ancrés** : la fourchette est calculée sur le plancher du Comptoir (qui bouge avec l'inflation) : si l'Or abonde, les plafonds de prix ne s'envolent pas.
6. **Les objets sont périssables en valeur** : un objet porté est lié ; un objet acheté reste échangeable seulement tant qu'on ne le porte pas ; le niveau monte et les objets d'un niveau deviennent vite inutiles aux joueurs qui progressent : l'offre se renouvelle, personne ne thésaurise des objets.

### Ce qui reste à décider avec Gautier (§ 6 : « il va falloir se reposer les questions sur l'économie »)

- Les cosmétiques en Or : oui ou non (Claude recommande oui, une petite partie).
- Le revenu quotidien des territoires : en Éclats (sûr) ou en Or (crée de l'Or hors Comptoir ; à borner).
- Les dons au trésor de guilde : en Or (immobilisé, pas détruit) ; le trésor peut-il reverser aux membres (non : sinon c'est un transfert déguisé).
- Les chiffres (seuils, pentes) : à l'équilibrage, avec `tools/economie.py`.

## 9. Le plan de travail, réordonné (deuxième interview)

Le game design de la version 1 s'allonge ; dans l'ordre proposé par Claude (à corriger par Gautier) :

1. **L'équipement refondu** : cinq raretés, huit emplacements et leurs bases, l'amélioration +1 à +10 en Or avec échec, la Tour qui lâche du commun et du peu commun au niveau de l'étage (pas toujours), les donjons qui lâchent le reste ; les écrans de la Forge et du Comptoir qui suivent.
2. **La fatigue et les potions** : la jauge, ce qui fatigue, l'affaiblissement, l'écroulement, le repos, l'Alchimiste du Comptoir.
3. **L'économie** : les décisions du § 8 une fois validées (Comptoir qui paie moins, puits), le compte vérifié pour vendre (avec Supabase), les annonces à 7 jours.
4. **L'Arène et les Échos** : l'adversaire par les points, les récompenses de saison, le revenu de l'Écho choisi.
5. **Les guildes** : 50 membres, le trésor, le délai de changement, le boss de guilde, le donjon de guilde, le lien Discord.
6. **Les amis** : la liste, l'ami comme Écho, le duel amical, ses progrès (serveur simulé, prêt pour Supabase).
7. **La création** : nom et apparence (l'éditeur simple ; le sprite suit avec les graphismes).
8. **La résurrection** : un nœud ou une Clé par Soutien (budget), la règle des KO relevés.
9. **Les classes de grimoire.**
10. **Les guerres de guilde** : **une séance de conception avec Gautier** (sur la base des contraintes du § 7), puis les PR.
11. **La boutique** : le catalogue (tenues, passe de saison), sans paiement réel.

Puis, inchangé : les graphismes par preuve (avec l'éditeur d'apparence et la musique orchestrale), le serveur réel et le social, l'équilibrage en dernier (avec la fatigue, l'amélioration, l'économie et la courbe d'XP).
