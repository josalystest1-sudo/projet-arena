# Projet Arena — Game Design Document (V1)

Oct 26, 2026 · @Gautier

## Vision et piliers

Un RPG mobile de combat PvP en 3 contre 3, tour par tour simultané, en pixel art, où chaque joueur possède un seul personnage au Destin unique au monde.

Six piliers, non négociables, qui tranchent toutes les décisions de ce document :

1. **Un perso, une identité.** Un seul personnage par compte. Son Destin n'existe nulle part ailleurs. Le joueur ne choisit pas son Destin, il apprend à le jouer.
2. **Le joueur agit à chaque tour.** Pas de combat automatique. Chaque tour demande un vrai choix : quelle compétence, quelle cible, maintenant ou au tour suivant.
3. **La cohésion gagne.** Une équipe qui coordonne ses actions bat trois bons joueurs qui jouent seuls. Les mécaniques (Intentions, Synergies, recharges) sont construites pour ça.
4. **Zéro méta.** Toutes les classes se valent, tous les Destins se valent. L'écart vient du jeu, jamais du tirage ni du choix de classe.
5. **Aucune limite de jeu.** Pas d'énergie, pas de nombre de parties par jour. Le joueur joue tant qu'il veut.
6. **Le beau se voit.** Le jeu vit des skins. Un skin acheté est visible par tout le monde, partout : vitrine, combat, écran de fin, profil.

## Périmètre de la V1

La V1 est un jeu PvP complet mais resserré : 40 classes, un mode de jeu, une boutique de skins. Tout ce qui ne sert pas à prouver que le combat est addictif attend la V2.

| Dans la V1 | Repoussé (V2 et plus) |
| --- | --- |
| 10 classes de base + 30 évolutions de palier 1 | Les 90 évolutions de palier 2 |
| Combat PvP 3v3 classé, tour par tour simultané | Mode JcE, campagne, donjons |
| Destin unique par personnage | Équipement (stuff) |
| Matchmaking par rôle et par ligue, IA de remplacement | Guildes, tournois organisés |
| Progression : niveaux, points de Destin, classement saisonnier | Mode spectateur, replays |
| Boutique de skins et d'animations | Chat vocal, système d'amis avancé (une liste d'amis simple reste en V1) |
| iOS et Android, même code | Version PC |

## Le personnage

Un compte = un personnage, créé une fois, jamais supprimé ni recréé gratuitement. C'est ce qui donne de la valeur au Destin et au skin.

**Création.** Le joueur choisit un nom et une classe parmi les 10. Le jeu génère ensuite son Destin et le lui révèle dans une mise en scène (l'arbre s'illumine, les 3 compétences actives et le passif tirés apparaissent un à un). Ce moment doit être mémorable : c'est la naissance du perso.

**Ce qui définit un personnage :**

- sa classe (puis son évolution) ;
- son Destin : l'arbre unique, ses 3 compétences actives et son passif, tirés dans les pools de la classe ;
- son niveau et les points de Destin dépensés ;
- son skin équipé et ses cosmétiques (animations, pose de victoire, bordure) ;
- son rang dans la saison en cours et son historique de saisons.

**Visibilité du skin.** Le personnage est affiché en grand, animé, dans la Vitrine (écran d'accueil), dans l'arbre de Destin, en combat (les 6 persos sont visibles en permanence avec leur skin), sur l'écran de fin de combat (pose de victoire) et sur le profil que n'importe quel adversaire peut ouvrir en tapant sur son nom.

**Recréer un personnage.** Possible, mais le joueur perd tout (niveau, rang, Destin). Les cosmétiques achetés restent sur le compte.

## Rôles et les 10 classes de base

Trois rôles, et chaque classe en porte deux : un principal (qui sert au matchmaking) et un secondaire (que le Destin peut renforcer). Aucune classe n'est un pur soigneur ni un pur sac à PV : chacune a toujours quelque chose à faire à chaque tour.

**Les trois rôles**

- **Front** : encaisse, protège, contrôle. Il décide qui l'ennemi peut frapper.
- **Dégâts** : concentre et achève. Il décide qui meurt.
- **Soutien** : soigne, renforce les alliés, affaiblit les ennemis. Il décide qui tient debout et qui frappe à moitié.

**Les types de dégâts** (ils servent aux résistances et aux Synergies) : tranchant, contondant, perforant, feu, givre, foudre, ombre, lumière.

**Ce qu'un personnage possède.** Chaque classe a un pool de 6 compétences actives, réparties en trois paliers (2 basiques, 2 moyennes, 2 fortes), et un pool de 4 passifs. Un personnage tire à la création, via son Destin, **une active de chaque palier et 1 passif**. Deux Mages n'ont donc ni les mêmes sorts ni le même passif, mais tous les deux ont une basique, une moyenne et une forte. Les paliers et leurs recharges sont décrits dans Combat.

| Classe | Principal / secondaire | Identité en une phrase | Types de dégâts | Basiques (2) | Moyennes (2) | Fortes (2) | Passifs (4, extraits) |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | Front / Dégâts | Le mur qui frappe : il tient la ligne et choisit qui on attaque | Tranchant, contondant | Taillade · Coup de bouclier (faible, repousse l'Intention de la cible d'un cran de vitesse) | Provocation (2 ennemis doivent le cibler ce tour) · Rempart (absorbe le prochain coup porté à un allié) | Fendoir (gros dégâts + saignement 3 tours) · Cri de guerre (alliés +20 % dégâts 2 tours) | Peau de fer (-15 % dégâts subis) · Second souffle (soigne 10 % en passant sous 30 % de PV) · Vétéran (+1 vitesse par allié KO) |
| Mage | Dégâts / Soutien | Les éléments en zone | Feu, givre, foudre | Boule de feu · Étincelle (foudre, agit tôt) | Trait de givre (la cible agit en dernier) · Arc de foudre (2 cibles) | Nova (3 ennemis) · Bouclier de mana (grosse barrière sur un allié) | Résonance (toucher 2 cibles réduit la recharge de la forte d'un tour) · Focalisation (+20 % sur cible unique) · Brasier (chaque coup de feu brûle 1 tour) |
| Voleur | Dégâts / Soutien | Burst, poison et disparition | Ombre, perforant | Dague · Lancer (ombre, à distance) | Voile (intouchable ce tour, agit en premier au suivant) · Poison (dégâts 3 tours) | Coup bas (double si la cible n'a pas encore agi) · Sabotage (la forte de la cible repart en recharge) | Opportuniste (+30 % sur une cible déjà touchée ce tour) · Fuite (esquive la première attaque du combat) · Doigts agiles (recharge de la moyenne -1) |
| Archer | Dégâts / Soutien | Il marque et il saigne ses proies à distance | Perforant | Tir · Tir rapide (faible, agit en premier) | Marque (+25 % de tous les dégâts sur la cible, 2 tours) · Piège (le prochain ennemi qui agit sur un allié est immobilisé) | Flèche barbelée (lourd saignement 3 tours) · Pluie de flèches (3 ennemis) | Œil de faucon (+15 % sur cibles marquées) · Calme (agit en dernier, +25 % dégâts) · Sang-froid (immunisé aux ralentissements) |
| Prêtre | Soutien / Front | Il répare, il relève, il tient | Lumière | Châtiment (lumière) · Prière (petit soin) | Restauration (gros soin) · Purification (retire un état négatif, petit soin) | Égide (barrière sur toute l'équipe) · Résurrection (relève un KO à 30 %, une fois par combat) | Foi (soins +20 % sur un allié sous 40 % de PV) · Martyr (encaisse 20 % des dégâts d'un allié) · Lumière intérieure (se soigne 5 % par tour) |
| Alchimiste | Soutien / Dégâts | Potions et acides : il change les règles du tour | Feu, givre | Fiole (feu) · Élixir (petit soin + vitesse) | Acide (-30 % dégâts de la cible, 2 tours) · Fumigène (l'allié choisi ne peut pas être ciblé ce tour) | Bombe (feu, 3 ennemis) · Catalyseur (remet à zéro toutes les recharges d'un allié) | Distillation (ses soins durent 1 tour de plus) · Peau de mercure (-20 % dégâts élémentaires) · Sang acide (les attaquants au contact subissent des dégâts) |
| Invocateur | Front / Dégâts | Il ne combat pas seul : sa créature encaisse à sa place | Contondant, ombre | Fouet d'ombre · Ordre (la créature attaque) | Golem (créature qui prend les coups destinés à l'équipe) · Spectre (créature qui frappe seule) ; une créature à la fois | Sacrifice (la créature explose, zone) · Lien (les dégâts d'un allié vont à la créature, 2 tours) | Symbiose (la créature hérite 30 % des stats du Destin) · Essaim (la créature agit deux fois un tour sur deux) · Pacte (quand la créature meurt, la moyenne est immédiatement rechargée) |
| Barde | Soutien / Dégâts | Le métronome de l'équipe | Foudre | Note (foudre) · Refrain (un allié +1 vitesse) | Hymne (les alliés agissent avant les ennemis ce tour) · Dissonance (ennemi -20 % dégâts 2 tours) | Crescendo (foudre sur 3 ennemis, plus fort à chaque tour écoulé) · Berceuse (la cible passe son prochain tour) | Rythme (recharge de la moyenne -1) · Inspiration (chaque Synergie alliée donne +10 % dégâts à l'équipe 1 tour) · Virtuose (ses chansons durent un tour de plus) |
| Diplomate | Soutien / Front | Il gagne sans frapper : il négocie, impose, retourne | Lumière, contondant | Argument (coup de canne) · Encouragement (un allié +10 % dégâts 1 tour) | Ultimatum (la cible doit l'attaquer lui ce tour, et le paie) · Trêve (un ennemi et un allié ne peuvent pas se cibler ce tour) | Discours (alliés +20 % dégâts 2 tours) · Chantage (la cible ne peut pas utiliser sa forte au tour suivant) | Charisme (20 % des attaques visant un allié le visent lui) · Impassible (immunisé aux contrôles) · Réseau (+5 % vitesse par ennemi sous un de ses effets) |
| Pugiliste | Front / Dégâts | Combos et contres : chaque coup prépare le suivant | Contondant | Jab (agit en premier) · Direct | Garde haute (défend et contre-attaque) · Crochet (double si Jab a touché au tour précédent) | Uppercut (gros dégâts, la cible agit en dernier au tour suivant) · Enchaînement (3 coups sur la même cible) | Cardio (+1 vitesse par tour, remis à zéro quand touché) · Mâchoire d'acier (-25 % dégâts physiques) · Esquive (annule la première attaque reçue du combat) |

Répartition : 3 Front (Guerrier, Invocateur, Pugiliste), 3 Dégâts (Mage, Voleur, Archer), 4 Soutien (Prêtre, Alchimiste, Barde, Diplomate). Les kits complets (6 actives et 4 passifs par classe) et tous les chiffres seront fixés dans le prototype, où ils pourront être testés.

## Évolution de classe

Au niveau 30, le personnage choisit une des 3 évolutions de sa classe. Il gagne un saut de puissance massif, repart niveau 1 avec un nouveau Destin, et change de ligue.

**Le déroulé**

1. Niveau 30 atteint (Destin de base complet) : l'écran d'évolution se débloque. Le joueur peut rester en classe de base aussi longtemps qu'il veut.
2. Il choisit 1 évolution parmi 3. Le choix est définitif.
3. Le personnage repart niveau 1. Un nouveau Destin, propre à l'évolution, est généré et révélé (même mise en scène qu'à la création). 3 compétences actives et 1 passif sont tirés dans les pools de l'évolution : des versions améliorées des compétences de base plus des compétences inédites.
4. Ses stats de base sont multipliées par environ 2,5 : une évolution niveau 1 bat une classe de base niveau 30 à Destin complet.

**Conséquence : deux ligues séparées.** Puisqu'une évolution écrase toute classe de base, les deux ne doivent jamais se croiser en matchmaking. La V1 a donc deux ligues : la **Ligue des Aspirants** (classes de base) et la **Ligue des Élus** (évolutions). Évoluer, c'est quitter le sommet d'une ligue pour entrer en bas de la suivante, comme un boxeur qui change de catégorie. Le classement et les récompenses de saison sont propres à chaque ligue.

**Les 30 évolutions.** Elles ne sont pas encore nommées ; on les définira une fois les 10 classes de base testées dans le prototype. Le principe, lui, est fixé : chaque classe en a 3, l'évolution A renforce le rôle principal, la B le rôle secondaire, la C ouvre une troisième voie. Une évolution reprend les 6 actives de la classe en version modifiée et en ajoute 2 inédites (8 actives, 3 tirées), avec un pool de passifs qui lui est propre. Ça divise par trois le volume de design par rapport à des kits entièrement nouveaux.

## Le Destin

Le Destin est un arbre de 45 nœuds généré à la création, unique au monde, impossible à modifier ou à retirer. Le joueur y place 1 point par niveau, donc 30 points sur 45 nœuds : il ne pourra jamais tout prendre, et c'est là que se joue sa stratégie.

**Ce que le Destin contient**

- **Les 3 compétences actives** du personnage, tirées dans le pool de 6 de sa classe, et **son passif**, tiré dans le pool de 4 de sa classe. Connus dès la création, ils ne changent jamais.
- **45 nœuds** reliés en arbre, de 4 types :

| Type de nœud | Ce qu'il fait | Exemple (Mage avec Boule de feu) | Part de l'arbre |
| --- | --- | --- | --- |
| Stat | Bonus passif permanent | +6 % de dégâts de feu, +40 PV, +1 vitesse | 50 % |
| Évolution de compétence | Modifie une des 3 actives ou le passif | Boule de feu rebondit sur un deuxième ennemi · Boule de feu brûle 2 tours · Nova revient 1 tour plus tôt | 30 % |
| Pivot | Renforce le rôle secondaire | Le Bouclier de mana du Mage soigne aussi 10 % des PV | 15 % |
| Clé | Nœud puissant, débloqué seulement après 3 nœuds précis | Boule de feu devient une zone sur toute l'équipe ennemie, une fois par combat | 5 % (2 à 3 par arbre) |
|  |  |  |  |

**Génération et unicité**

1. Le serveur tire une graine aléatoire, vérifie qu'elle n'a jamais été utilisée, et la stocke avec le personnage.
2. La graine choisit les 4 compétences, la forme de l'arbre et le contenu de chaque nœud dans les pools de la classe.
3. Le Destin est inchangeable : pas de relance, pas de respec payant, pas de réinitialisation. Seule l'évolution en crée un nouveau.

**Le budget de puissance, garantie du « tous les Destins se valent ».** Chaque nœud a une valeur en points de puissance, fixée par le simulateur d'équilibrage (voir Équilibrage). Le générateur impose trois contraintes à chaque arbre :

- la valeur totale des 45 nœuds est la même pour tous (à 2 % près) ;
- la valeur maximale atteignable avec 30 points est la même pour tous (à 2 % près) ;
- chaque arbre contient au moins une évolution pour chacune des 3 actives et une pour le passif et au moins un chemin cohérent vers chaque Clé.

La différence entre deux Destins est donc une différence de **forme et de combinaisons**, jamais de puissance brute. Un Destin « en or » ne peut pas exister par construction. Un arbre tiré qui viole une contrainte est rejeté et retiré, le joueur ne le voit jamais.

**Lecture pour le joueur.** L'arbre est affiché en entier dès la création, y compris les nœuds lointains. Le joueur voit où il va et planifie ses 30 points. Les nœuds pris sont allumés, le chemin choisi dessine une silhouette propre à ce perso.

## Système de combat

Un combat 3v3 vise 8 à 15 tours, soit 3 à 5 minutes. Chaque tour, les 6 joueurs choisissent leur action en même temps pendant 12 secondes, puis le tour se résout dans l'ordre de vitesse. Présentation à la Octopath : les deux équipes face à face, sprites en pied, compte-tour en haut.

**Un tour, pas à pas**

1. **Phase d'Intention (12 s).** Chaque joueur choisit une de ses 3 compétences disponibles et une cible. Ses coéquipiers voient son choix en transparence au-dessus de sa tête, en direct, et peuvent ajuster le leur. L'équipe adverse ne voit rien. Pas de choix à la fin du timer = le perso utilise sa basique sur la même cible qu'au tour précédent.
2. **Révélation.** Les 6 actions s'affichent.
3. **Résolution.** Les actions s'exécutent par ordre de vitesse (stat + modificateurs du tour). Les Synergies se déclenchent au moment où la seconde compétence du couple se résout.
4. **Fin de tour.** Effets sur la durée (saignement, poison, brûlure), les recharges avancent d'un tour.

**Les trois paliers de compétences et leurs recharges.** Chaque personnage a exactement une compétence de chaque palier. Pas de mana, pas de ressource partagée : le seul coût d'une compétence est le temps avant de pouvoir la rejouer.

| Palier | Rôle dans le kit | Disponible | Recharge après usage |
| --- | --- | --- | --- |
| Basique | Le coup de tous les jours, l'action par défaut | Tous les tours | Aucune |
| Moyenne | L'outil tactique : contrôle, soin, buff, débuff, dégâts corrects | Dès le tour 1 | 2 tours (jouable un tour sur trois) |
| Forte | Le coup qui renverse un combat | À partir du tour 3 | 4 tours (jouable deux à trois fois par combat) |

La forte n'est pas disponible au tour 1, pour deux raisons : éviter que les six joueurs ouvrent par leur plus gros coup, et laisser deux tours pour lire l'équipe adverse avant de la placer. Les chiffres de recharge sont des valeurs de départ, le simulateur les ajustera.

**Ce que chaque tour demande au joueur.** Avec trois compétences dont deux à recharge, la question de chaque tour n'est pas « quoi jouer » mais « maintenant ou au tour suivant » : garder sa moyenne pour contrer la forte adverse qui arrive au tour 3, aligner sa forte avec celle d'un allié pour une Synergie, ou frapper tout de suite la cible que les deux autres visent déjà. Les Intentions visibles rendent ce calcul collectif.

**Les Synergies.** Certains couples de compétences, joués le même tour par deux coéquipiers, déclenchent un effet bonus. Elles sont affichées en phase d'Intention dès qu'un couple est possible (une icône relie les deux persos). Une Synergie est un effet unique par couple, pas une version amplifiée de chaque compétence : le volume de design reste contenu. Exemples :

| Couple | Effet de la Synergie |
| --- | --- |
| Provocation (Guerrier) + Nova (Mage) | Les ennemis provoqués subissent la Nova à +50 % |
| Trait de givre (Mage) + Crochet (Pugiliste) | La cible gelée est étourdie : elle perd son action du tour suivant |
| Marque (Archer) + Coup bas (Voleur) | Le Coup bas est doublé même si la cible a déjà agi |
| Hymne (Barde) + n'importe quelle forte alliée | La forte revient 1 tour plus tôt |
| Ultimatum (Diplomate) + Garde haute (Pugiliste) | L'ennemi forcé d'attaquer subit les deux contre-attaques |
| Acide (Alchimiste) + Sacrifice (Invocateur) | L'explosion applique l'Acide aux 3 ennemis |
| Égide (Prêtre) + Lien (Invocateur) | La créature récupère tous les dégâts qu'elle a absorbés ce tour |

Chaque classe a au moins une Synergie avec chaque autre classe (45 couples minimum), pour qu'aucune composition d'équipe ne soit sans Synergie.

**L'utilité des Soutiens.** Elle est classique et c'est voulu : un Prêtre soigne, un Barde renforce, un Alchimiste affaiblit. Ce qui les rend décisifs ici, c'est le tour par tour simultané : un soin placé le tour où la forte adverse tombe vaut dix fois le même soin placé au hasard, et les Intentions alliées permettent de le savoir. Leur puissance se règle avec les mêmes chiffres que les autres (montants, durées, recharges), sans mécanique à part.

**Conditions de fin**

- Victoire : les 3 adversaires sont KO.
- Un KO peut être relevé par un Soutien (une fois par perso et par combat).
- **Mort subite** : à partir d'un tour donné, les soins sont divisés par deux et tous les dégâts augmentent de 25 % par tour. Quelques tours plus tard, fin forcée : l'équipe avec le plus de PV totaux gagne. Jamais de match nul. Le tour de déclenchement et le tour de fin forcée seront fixés par le simulateur, avec une cible claire : 90 % des combats finis entre le tour 8 et le tour 15.

## Matchmaking, équipes et IA de remplacement

Chaque équipe a toujours un Front, un Dégâts et un Soutien (rôle principal). Si la file ne se remplit pas en 20 secondes, les places vides sont prises par des **Échos** : les personnages réels d'autres joueurs, pilotés par l'IA.

**L'ordre de priorité du matchmaking**

1. Même ligue (Aspirants ou Élus). Jamais de croisement.
2. Un rôle principal de chaque par équipe. Le joueur voit le temps d'attente estimé pour son rôle.
3. Classement proche (écart de rang qui s'élargit avec le temps d'attente).
4. Niveau proche (écart max de 8 niveaux au départ, élargi après 20 s).

**Les Échos : les joueurs absents jouent quand même.** Un Écho est la copie exacte d'un vrai personnage (classe, Destin, niveau, skin), joué par l'IA. Le joueur dont l'Écho a combattu reçoit une notification à son retour : « Ton Écho a gagné 2 combats pendant ton absence », avec une petite récompense. Trois effets :

- les files sont toujours pleines, même le jour du lancement avec 50 joueurs ;
- les skins des absents restent visibles, donc utiles ;
- le joueur a une raison de revenir voir ce qu'a fait son Écho.

Un combat avec des Échos compte pour le classement avec un poids réduit (50 % des points). Le joueur voit clairement quels adversaires sont des Échos (icône discrète), pour ne jamais lui mentir.

**L'IA des Échos.** Elle joue les mêmes règles que les joueurs : elle lit les Intentions alliées, cherche les Synergies et concentre les attaques. Elle est volontairement un cran en dessous d'un bon joueur humain (elle place ses compétences fortes moins bien), pour que jouer avec de vrais coéquipiers reste visiblement plus fort. C'est la même IA qui sert au simulateur d'équilibrage.

**Équipes préfaites.** En V1, un joueur peut inviter 1 ou 2 amis pour former son équipe avant la file. Les équipes de 3 préfaites n'affrontent que des équipes de 3 préfaites ou, après 30 s, des équipes mixtes avec un malus de classement compensé.

## Progression, classement et rétention

Aucune limite de parties. La progression tient sur trois boucles : le niveau (points de Destin), le rang de saison (classement) et les cosmétiques (boutique et récompenses).

| Boucle | Durée | Ce que le joueur gagne |
| --- | --- | --- |
| Un combat | 3 à 5 min | XP (victoire ou défaite, bonus de victoire), points de rang |
| Un niveau | 20 à 60 min au début, plus long ensuite | 1 point de Destin à placer tout de suite |
| Une session | 20 à 40 min | 3 quêtes du jour (cosmétiques uniquement, jamais de puissance) |
| Une saison | 1 mois | Rang final, bordure de profil et pose de victoire exclusives à la saison, jamais revendues |
| La classe de base | 30 niveaux, environ 40 à 60 h | Le choix d'évolution |

**Classement.** Deux échelles séparées (Aspirants, Élus), chacune en paliers nommés (Bronze à Légende) avec un classement mondial pour le dernier palier. Un reset partiel à chaque saison : on redescend d'un palier, pas à zéro.

**Pourquoi le joueur revient**

- Le point de Destin : chaque niveau est une décision immédiate et visible sur son arbre.
- L'Écho : « qu'est-ce que mon perso a fait pendant que je n'étais pas là ? »
- La saison : le rang se perd si on ne joue pas.
- Les coéquipiers : une fin de combat propose d'ajouter en ami un coéquipier avec qui on a déclenché une Synergie.

**Ce qu'on ne fait jamais.** Pas d'énergie, pas de coffre à attendre, pas de bonus d'XP payant, pas de récompense de connexion quotidienne qui punit l'absence. La rétention vient du jeu, pas de la culpabilité.

## Équilibrage anti-méta

L'objectif chiffré : chaque classe, chaque compétence et chaque type de nœud de Destin gagne entre 48 % et 52 % de ses combats, en ligue comme en simulation. Dès qu'une valeur sort de la fourchette, elle est corrigée dans les deux semaines.

**Pourquoi une méta apparaît, et ce qui la bloque ici**

| Source de méta classique | Ce qui la bloque dans ce jeu |
| --- | --- |
| Une classe plus forte que les autres | Simulateur + patch bi-mensuel, cible 48–52 % |
| Une composition d'équipe dominante | Matchmaking par rôle : toute équipe a un Front, un Dégâts, un Soutien |
| Un build optimal que tout le monde copie | Le Destin est unique et non modifiable : aucun build n'est copiable |
| Le counter-pick (choisir sa classe contre l'adversaire) | La classe est fixée au compte, les équipes ne se voient pas avant le combat |
| Les objets qui cassent l'équilibre | Pas de stuff en V1, les skins n'ont aucune stat |

**Le simulateur.** Avant chaque patch, l'IA des Échos joue des centaines de milliers de combats 3v3 entre personnages générés aléatoirement (classe, Destin, répartition de points). Le simulateur sort un taux de victoire par classe, par compétence, par nœud et par Synergie. C'est lui qui fixe la valeur en points de puissance de chaque nœud, donc c'est lui qui garantit que les Destins se valent. Il tourne en quelques minutes sur un serveur, sans joueur.

**Les données réelles.** Chaque combat en ligue remonte au serveur les mêmes statistiques. Un tableau de bord interne compare simulation et réalité ; l'écart entre les deux est le premier signal qu'un build a été trouvé par les joueurs avant la simulation.

**La règle de correction.** On ajuste des chiffres (dégâts, recharges, durées), jamais le Destin d'un joueur. Un nœud trop fort est affaibli pour tout le monde ; il reste dans les arbres existants, personne ne perd son point.

**Honnêteté sur la limite.** Aucun jeu n'a jamais atteint le zéro méta parfait avec 40 classes. Ce qu'on peut garantir, c'est un écart de puissance assez faible pour que la coordination d'équipe pèse plus lourd que le choix de classe. C'est le vrai critère de succès.

## Monétisation

Le jeu est gratuit et vend uniquement ce qui se voit. Rien de ce qui est vendu ne change un chiffre de combat.

**Ce qui est vendu**

| Article | Ce que c'est | Où on le voit | Prix indicatif |
| --- | --- | --- | --- |
| Skin de lignée | Une apparence complète du perso, déclinée sur la classe de base et ses 3 évolutions (achetée une fois, valable toute la lignée) | Vitrine, combat, fin de combat, profil | 5 à 15 € selon la richesse |
| Animation de compétence | Un effet visuel différent pour une compétence (la Boule de feu devient bleue et spirale) | Combat | 2 à 4 € |
| Pose de victoire | L'animation de fin de combat | Fin de combat, profil | 2 à 3 € |
| Bordure et effet de profil | Cadre animé autour du nom | Profil, file d'attente, écran de combat | 1 à 3 € |
| Pass de saison (cosmétique) | Une piste de récompenses cosmétiques liée aux combats joués | Partout | 5 à 8 € par saison |

**Ce qui n'est jamais vendu** : des stats, de l'XP, des points de Destin, une relance de Destin, une relance d'évolution, un passe-droit de file d'attente. Cette liste est publique dans le jeu, c'est un argument de confiance.

**Pourquoi le skin de lignée.** Un skin acheté en classe de base suit le joueur à l'évolution, donc il ne se sent pas volé quand il évolue, et le prix peut être plus élevé. Le coût : 4 sprites animés par skin au lieu d'un. PixelLab rend ce volume tenable.

**Ce que le modèle exige du jeu.** Le perso doit être vu par d'autres humains, souvent, en grand. D'où : les 6 sprites toujours à l'écran en combat, la pose de victoire en fin de combat que les 5 autres joueurs regardent, le profil ouvrable en un tap sur n'importe quel nom, et l'Écho qui continue d'exhiber le skin quand le joueur est absent.

**Paiement.** Achats intégrés natifs (Google Play Billing, Apple StoreKit), monnaie interne achetée par paliers pour simplifier les prix. Les deux stores prennent 15 % (jusqu'à 1 M€ de revenus annuels) puis 30 %.

## Écrans et interface

Onze écrans en V1, tous en portrait, pensés pour une main. Le combat est le seul écran complexe ; tous les autres servent à montrer le perso ou à y revenir vite.

| Écran | Rôle | Ce qu'on y voit en premier |
| --- | --- | --- |
| Création | Nom, choix de classe, révélation du Destin | Les 10 classes animées, puis la mise en scène du Destin |
| Vitrine (accueil) | Le hub | Le perso en grand, animé, avec son skin ; bouton Combattre dominant |
| Destin | L'arbre complet, placement des points | L'arbre entier, les nœuds pris allumés |
| Compétences | Les 3 actives et le passif, leurs évolutions acquises, les Synergies connues | Les 4 icônes (3 actives, 1 passif) et leur description |
| File d'attente | Recherche d'équipe | Temps estimé pour son rôle, les coéquipiers trouvés arrivent un par un |
| Combat | Le jeu | Les 6 persos, le timer de 12 s, les recharges, les Intentions alliées |
| Fin de combat | Résultat | Poses de victoire des 3 gagnants, XP, points de rang, Synergies déclenchées, bouton « ajouter en ami » |
| Classement | Les deux ligues | Son rang, les 50 premiers mondiaux |
| Boutique | Cosmétiques | Les skins essayés en direct sur son propre perso |
| Profil (le sien ou celui d'un autre) | Carte d'identité | Le perso en pied avec son skin, classe, niveau, rang, saisons passées |
| Paramètres | Compte, son, langue | — |

**Le combat sur un téléphone.** Les deux équipes en haut (ennemis) et au milieu (alliés), sprites en pied. En bas, les 3 compétences en grandes touches, leur recharge affichée dessus, puis les cibles. Deux taps par tour maximum. Les Intentions alliées sont des icônes translucides au-dessus de chaque allié, reliées par un trait à leur cible ; une Synergie possible fait clignoter le trait.

## Stack technique et pipeline

Un seul projet Godot 4 pour iOS et Android, un serveur Nakama qui arbitre les combats, PixelLab pour tous les sprites, et des builds compilés dans le cloud par GitHub Actions : pas de Mac, pas de terminal, tout piloté depuis Claude Code.

| Brique | Choix | Pourquoi | Coût |
| --- | --- | --- | --- |
| Moteur | [Godot 4](https://godotengine.org) (GDScript) | 2D pixel art natif, export iOS + Android + web depuis le même code, gratuit, tout en fichiers texte que Claude Code écrit | 0 € |
| Pixel art | [PixelLab](https://www.pixellab.ai) via son serveur MCP | Génère personnages, rotations et animations directement depuis Claude Code | Abonnement, de l'ordre de 10 à 40 €/mois selon le volume |
| Serveur de jeu | [Nakama](https://heroiclabs.com) (open source) | Comptes, matchmaking, classements, logique de combat arbitrée côté serveur (anti-triche) | VPS 10 à 20 €/mois au début, ou Heroic Cloud (hébergement géré) |
| Base de données | PostgreSQL (fournie avec Nakama) | Personnages, Destins, achats, statistiques | Inclus |
| Code source | GitHub (dépôt privé) | Historique, et c'est lui qui déclenche les builds | 0 € |
| Builds | GitHub Actions | Compile Android (Linux) et iOS (runner macOS) à chaque version | Gratuit jusqu'à un quota mensuel, puis quelques euros |
| Paiements | Google Play Billing + Apple StoreKit (plugins Godot) | Obligatoires sur les stores | Commission des stores |
| Simulateur d'équilibrage | Le même code de combat, lancé sans interface sur le serveur | Un seul moteur de règles pour le jeu, les Échos et la simulation | Inclus |

**La règle d'architecture qui compte.** Le moteur de règles du combat (recharges, Synergies, résolution d'un tour) est un module pur, sans affichage. Il tourne à trois endroits : sur le serveur (la seule version qui fait foi), sur le téléphone (pour afficher et prévoir), et dans le simulateur. Un bug corrigé l'est partout.

**Sortir sur iOS sans Mac.** Godot exige officiellement un Mac avec Xcode pour exporter vers iOS, mais la compilation peut se faire sur un Mac loué à la minute par GitHub Actions. Un pipeline GitHub Actions avec runners macOS et Fastlane permet de livrer un jeu Godot sur iOS sans posséder de Mac, de la signature du code à la distribution TestFlight ([conférence GodotCon 2026](https://talks.godotengine.org/godotcon-ams-2026/talk/VGASKF/)). Claude Code écrit ce pipeline une fois ; ensuite, chaque version se compile seule.

**Tester sans rien installer.** Godot exporte aussi en version web : le prototype de combat se testera directement dans le navigateur du téléphone, avant même la première build Android.

**Les comptes à ouvrir**

- [ ] Compte GitHub (gratuit)
- [ ] Compte PixelLab (payant)
- [ ] Google Play Console : 25 € une fois
- [ ] Apple Developer Program : 99 € par an
- [ ] Un VPS ou Heroic Cloud pour le serveur, au moment du premier test en ligne

## Feuille de route

Le prototype de combat passe en premier, avant tout art et tout serveur : c'est lui qui prouve ou non que le jeu est addictif. Tout le reste s'empile dessus.

1. **Prototype de combat (web, local).** Le moteur de règles complet (recharges, Synergies, tour simultané), 3 classes, sprites provisoires, le joueur contre 5 IA. Jouable dans un navigateur de téléphone. Critère de sortie : tu veux relancer un combat quand il se termine.
2. **Les 10 classes et le Destin.** Les 10 kits complets (6 actives et 4 passifs chacun), le générateur de Destin avec son budget de puissance, l'écran de l'arbre, les 45 Synergies minimum.
3. **Le simulateur.** Le moteur lancé sans interface, des centaines de milliers de combats, le tableau des taux de victoire. Première passe d'équilibrage avant qu'un seul joueur n'arrive.
4. **Serveur et PvP réel.** Nakama : comptes, personnages persistants, matchmaking par rôle et par ligue, combat arbitré côté serveur, Échos, classement.
5. **Art et écrans.** Les 10 sprites de base via PixelLab (idle, 2 attaques, incantation, touché, KO, victoire), les 11 écrans, la Vitrine, la création avec sa mise en scène.
6. **Les 30 évolutions.** Kits, Destins, sprites, la Ligue des Élus.
7. **Boutique et paiements.** Première série de skins de lignée, Google Play Billing, StoreKit, pass de saison.
8. **Bêta fermée.** Android d'abord (plus simple à distribuer), puis TestFlight sur iOS. Saison 0 avec de vrais joueurs, deuxième passe d'équilibrage sur données réelles.
9. **Lancement.** Les deux stores le même jour, saison 1.

Chaque étape produit quelque chose de jouable ou de mesurable. On ne passe pas à la suivante sans avoir testé la précédente sur un téléphone.

## Univers : trois pistes

L'univers doit répondre à trois questions que le jeu pose dès l'écran de création : pourquoi personne ne choisit son Destin, pourquoi on se bat dans une arène, et pourquoi mon personnage continue de combattre quand je ne suis pas là (les Échos). Les trois pistes ci-dessous y répondent chacune à leur façon ; la première est celle que je recommande.

| Piste | Le monde en trois phrases | Ce qui explique le Destin | Ce qui explique les Échos | Ce qui explique les skins et l'évolution | Ton |
| --- | --- | --- | --- | --- | --- |
| **La Veille** (recommandée) | Depuis la Grande Nuit, une cité entière dort d'un sommeil dont nul ne se réveille. Les dormeurs se retrouvent dans un rêve partagé, l'Arène, le seul endroit où ils peuvent encore agir. Gagner, c'est rester éveillé dans le rêve un peu plus longtemps. | Le Destin est ce que l'esprit du dormeur a produit la première nuit. On ne choisit pas ses rêves. | On rêve même quand on ne s'en souvient pas : ton dormeur se bat sans toi. | Le skin est la forme qu'on décide de prendre dans le rêve, donc tout est possible. Évoluer, c'est s'enfoncer d'un niveau de sommeil : la Ligue des Élus est le sommeil profond. | Onirique, coloré, un peu mélancolique |
| **Le Tissage** | Trois Fileuses aveugles tissent le fil de chaque nouveau-né, une seule fois. L'Arène est le métier à tisser où les fils se croisent ; les Synergies sont des fils qui se nouent. | Le fil est tissé à la naissance et jamais retissé. | Un fil tendu vibre même quand personne ne le touche. | Le skin est la teinture du fil. Évoluer, c'est devenir corde. | Mythologique, textures de tissu dans l'interface |
| **La Foire des Dieux oubliés** | Des dieux que plus personne ne prie se disputent les derniers croyants. Chaque combattant est le champion d'un dieu oublié ; chaque combat est une prière. | Le dieu grave le Destin dans la peau de son champion, sans lui demander son avis. | Le dieu fait combattre son champion même quand celui-ci dort. | Le skin est une offrande du dieu. Évoluer, c'est le dieu qui grandit et refaçonne son champion. | Épique et burlesque, mélange de mythologies |

**Pourquoi La Veille.** C'est la seule des trois où les Échos ne sont pas une excuse mais une évidence, et la seule qui autorise n'importe quel skin sans justification (dans un rêve, un Guerrier peut être un ours ou une armure vide). Elle donne aussi une raison simple de revenir chaque jour : le joueur ne se réveille jamais vraiment, il retourne dormir. Le risque est que « monde onirique » soit un décor vu ailleurs ; la parade est de le rendre très concret : une seule cité, nommée, avec ses quartiers, et une Arène qui est la place centrale de cette cité telle qu'elle était la veille de la Grande Nuit.

## Décisions prises et questions ouvertes

**Décidé le 26 octobre 2026**

- Nom de travail : **Projet Arena**.
- Combat PvP 3v3, tour par tour simultané, Intentions visibles entre alliés.
- Un seul personnage par compte.
- Destin généré aléatoirement à la création, unique, non modifiable, non choisi. 45 nœuds, 30 points.
- Chaque classe : pool de 6 actives (2 basiques, 2 moyennes, 2 fortes) et pool de 4 passifs ; chaque personnage tire une active de chaque palier et 1 passif via son Destin.
- Pas de système de Garde ni de Brèche. La coordination repose sur les Intentions, les Synergies et le choix de cible.
- Pas de ressource partagée (le Tempo est abandonné) : système classique de recharges, la basique sans recharge, la moyenne à recharge courte, la forte à recharge longue.
- Évolution au niveau 30, choix parmi 3, saut de puissance majeur, nouveau Destin à zéro.
- Deux ligues séparées (Aspirants / Élus) : les évolutions ne croisent jamais les classes de base.
- V1 à 40 classes (10 de base + 30 évolutions), palier 2 en V2. Les 10 classes : Guerrier, Mage, Voleur, Archer, Prêtre, Alchimiste, Invocateur, Barde, Diplomate, Pugiliste.
- Échos (IA de remplacement) qui rapportent une petite récompense à leur propriétaire absent.
- Skins de lignée (valables sur la base et ses 3 évolutions).
- Mort subite : tour de déclenchement fixé par le simulateur, cible 8 à 15 tours par combat.
- Pas de limite de parties, pas de pierre-feuille-ciseaux, financement par cosmétiques uniquement.
- Pixel art façon Octopath Traveler, iOS et Android depuis un seul code, builds iOS dans le cloud (pas de Mac).

**Encore ouvert**

- [ ] L'univers : choisir une des trois pistes ci-dessus, puis nommer la cité
- [ ] Le nom définitif du jeu
- [ ] Les noms et les kits des 30 évolutions (après le prototype)
- [ ] Les kits complets des 10 classes : 6 actives et 4 passifs chacune (fixés dans le prototype)
- [ ] Les chiffres : PV, dégâts, vitesses, courbe d'XP, tours de mort subite (prototype puis simulateur)
- [ ] Le style exact du pixel art : taille des sprites, palette, profondeur de champ façon HD-2D ou 2D plate
- [ ] Les prix définitifs des cosmétiques
