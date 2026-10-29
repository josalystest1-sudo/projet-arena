# Projet Arena — GDD V2 : le trio, les Échos, la Tour fixe, les donjons et les guildes

Rédigé le 29 octobre 2026 à partir des décisions prises avec Gautier ce jour-là. **Ce document remplace le GDD V1 (`docs/GDD.md`) sur tout ce qu'il traite** ; le V1 reste la référence pour ce qu'il ne traite pas (les tableaux de compétences des 10 classes, les trois pistes d'univers, les écrans de création et de combat, les évolutions). En cas de contradiction, le V2 l'emporte. `CLAUDE.md` résume l'état du prototype ; `docs/MECANIQUES.md` liste toutes les mécaniques de combat.

Chaque règle porte une étiquette : **[Décidé]** (validé par Gautier), **[Proposé]** (choix de Claude Code, à confirmer ou corriger par Gautier ; en attendant, c'est ce qu'on construit), **[Ouvert]** (question posée à la fin, rien à construire avant la réponse).

---

## 1. Le jeu en dix lignes

- RPG mobile en pixel art, tour par tour **simultané** (12 s pour choisir, résolution par ordre de vitesse), **sans aucun hasard en combat**.
- **Un seul personnage par compte**, d'une des 10 classes, avec un **Destin** unique (arbre de 45 nœuds, 30 points, un point par niveau) qui fixe ses 3 compétences, son passif et ses bonus. Le joueur ne joue jamais que lui. **[Décidé]**
- **On joue toujours en trio** Front + Dégâts + Soutien : le joueur occupe la case de son rôle principal, les deux autres sont des **Échos**, des personnages de vrais joueurs pilotés par l'IA. Le joueur ne leur donne jamais d'ordre. **[Décidé]** (Remplace le duo joueur + acolyte du V1.)
- **La Tour** (solo en trio, fixe, sans remise à zéro), **le PvP** (trio contre trio, 5 combats classés par jour), **les donjons** (3 joueurs humains, routes secrètes, boss unique au serveur), **les guildes** (combats du soir, territoires) : voir les sections 4 à 8.
- Les **Soutiens** n'ont pas besoin de faire des dégâts : chacune de leurs compétences est utile même quand personne n'est blessé. **[Décidé]**
- **L'équipement** crée les écarts de puissance ; la base (classe, Destin) est équilibrée au maximum ; ni l'un ni l'autre ne crée de méta. **[Décidé]**
- **Évolution** au niveau 30 : choix parmi 3, puissance ×2,5, nouveau Destin. Deux ligues : Aspirants et Élus.
- Financement par **cosmétiques uniquement**. Jamais de puissance vendue. **[Décidé]**
- La Tour doit être **difficile par moments** : on y est bloqué, on revient plus fort. **[Décidé]**
- L'IA est **prévisible plutôt que brillante**, mais jamais bête : des règles fixes, mesurées au simulateur.

## 2. Décisions verrouillées (ne pas rouvrir sans Gautier)

Inchangées : duo… remplacé par le trio (voir ci-dessous) ; pas de Garde/Brèche, pas de Tempo, pas de mana, pas de timing en temps réel, pas de pierre-feuille-ciseaux, pas de hasard en combat, Destin non modifiable, un seul personnage par compte, jamais de puissance vendue, moteur de règles pur et testé, données en fichiers.

Modifiées le 29 octobre :
- **Le duo joueur + acolyte est remplacé par le trio joueur + 2 Échos.** Plus d'acolyte fixe, plus d'écran de rencontre. **[Décidé]**
- **« Aucune limite de parties »** devient : **5 combats PvP classés par jour** (valeur modulable), les combats amicaux restent illimités. Le PvE n'a aucune limite. **[Décidé pour le PvP ; amicaux illimités : Proposé]**
- **La classe est fixe hors Évolution** : maintenue. La récompense « grimoire de changement de classe » évoquée pour les boss est donc à remplacer (voir § 7.6). **[Ouvert]**

## 3. Le combat

### 3.1 Règles (inchangées, rappel)

- 12 s pour choisir, puis résolution par vitesse. 3 compétences à recharge : basique (sans recharge), moyenne (revient 2 tours après), forte (4 tours, jouable dès le tour 3). 1 passif. Les chiffres sont dans `data/`.
- **PvP** : mort subite au tour 8 (soins ÷ 2, dégâts +50 % par tour), fin forcée à la fin du tour 13 (plus de PV totaux, puis plus de dégâts, puis le camp prioritaire). Jamais de match nul.
- **PvE : aucune limite de tours.** Un combat peut durer 100 tours ; le joueur peut abandonner quand il veut. Les règles « les monstres s'épuisent au tour 12 » et « ils abandonnent au tour 24 » sont retirées. **[Décidé]** Pour que tout étage reste gagnable en un temps fini : un seul soigneur par étage, et **les soins et régénérations des monstres s'affaiblissent à chaque usage** (100, 75, 56…). Le simulateur garde un plafond technique (300 tours, compté comme un abandon) que le joueur ne voit jamais. **[Proposé]**

### 3.2 Ce que le joueur voit de l'adversaire : rien, ou presque

- **En combat, l'adversaire est opaque** : ni ses compétences, ni son Destin, ni ses recharges, ni son équipement. On le découvre en le regardant jouer, comme dans tous les RPG. Le joueur ne lit pas de fiche pendant un tour de 12 s. **[Décidé]**
- Deux exceptions, parce que ce sont des signaux et non des informations à lire : **les icônes d'état** sur tous les personnages (poison, brûlure, marque, étourdi… avec le nombre de tours) ; **une lueur « forte prête »** sur un ennemi dont la grosse attaque est disponible (une lueur, pas un chiffre). **[Décidé]**
- Après le combat, l'écran de fin peut résumer le Destin et le kit de l'adversaire. **[Proposé]**
- Côté joueur, tout reste visible : ses recharges, celles de ses Échos (pastilles M et F), leurs annonces, les Synergies possibles.
- À retirer du prototype : les pastilles de recharge sur les ennemis, le kit complet quand on les touche, le bandeau des sorts adverses.

### 3.3 Le trio et les annonces

- Au début des 12 s, **le premier Écho annonce** son action (et sa raison, en une ligne), puis **le second** en connaissant la première, puis **le joueur choisit** en connaissant les deux. Le joueur décide toujours en dernier et n'est jamais pris de court. **[Décidé]**
- Les **Synergies** (un couple de compétences jouées le même tour, un effet unique par couple) valent entre le joueur et chacun de ses deux Échos. Les 63 Synergies existantes couvrent déjà toutes les paires de classes de rôles différents.
- La règle d'attente de l'IA (garder sa forte un tour pour une Synergie au tour suivant, jamais deux) est conservée.

### 3.4 Les Soutiens

- **Un Soutien n'a pas besoin de faire des dégâts.** Dans le trio il y a toujours un Dégâts et un Front : sa valeur, c'est les PV du trio (rendus, non perdus, ou coups ennemis en moins). **[Décidé]**
- **Chaque compétence de Soutien a un effet utile même quand personne n'est blessé.** Celles qui ne l'ont pas reçoivent un repli : Résurrection → si personne n'est KO, elle bénit (le prochain coup mortel sur l'allié le laisse à 1 PV, une fois) ; Purification → s'il n'y a rien à retirer, elle immunise contre le prochain état négatif ; Catalyseur → si l'allié n'a aucune recharge en cours, il le rend Vif. **[Proposé]**
- **Quatre façons d'être Soutien, qui se valent par des chemins différents** : le Prêtre **répare** (soigne, relève), l'Alchimiste **dure** (régénération, états qui durent, affaiblissements), le Barde **accélère** (le trio agit avant, recharges plus courtes, dégâts qui montent), le Diplomate **interdit** (trêve, chantage, détournement). Le simulateur règle leurs chiffres jusqu'à ce que tout trio, quel que soit son Soutien, aille aussi loin à la Tour et gagne autant en PvP. **[Décidé]**
- Les Soutiens gardent **au plus une** compétence qui frappe dans leur réserve de six ; un Destin de Soutien peut n'en avoir aucune sans être un handicap. **[Proposé]**
- L'IA du rôle Soutien : soigner si besoin, sinon renforcer le Dégâts ou affaiblir l'ennemi, jamais « sinon frapper ». Le Front suit la même logique : sa valeur, c'est les coups qu'il prend à la place des autres.

### 3.5 Le geste de classe

- Chaque classe a un **geste constant, quel que soit son Destin** : ses deux basiques partagent un élément propre (lumière pour le Prêtre, perforant pour l'Archer, contondant pour le Pugiliste, feu/givre/foudre pour le Mage…), et une forte est toujours une forte. Deux ou trois compétences des données sont à ajuster pour que ce soit vrai partout. **[Décidé]**
- Les conditions des boss (§ 7.5) ne parlent que de gestes (« une basique de lumière »), de paliers (« deux fortes le même tour ») ou de rôles (« la forte d'un Front »), jamais d'une compétence précise d'un Destin.

### 3.6 L'IA (une seule, pour tout : Échos, adversaires, monstres, simulateur)

- Des règles fixes par rôle, essayées dans le même ordre, la première qui s'applique décide (voir `CLAUDE.md`, « L'acolyte sans postures » : les règles de rôle sont celles-là, étendues au trio).
- **Des règles de bon sens placées avant les règles de rôle** **[Proposé]** :
  - *Achever* : si un ennemi peut tomber ce tour avec ce que les alliés ont annoncé plus mon coup, je le frappe, avec la compétence la moins chère qui suffit (la moyenne si elle tue, pas la forte).
  - *Ne pas gaspiller la forte* : une protection forte seulement si un allié a perdu des PV ou si un ennemi a sa forte prête ; une attaque forte seulement si elle tue, touche deux ennemis ou frappe une cible marquée ou étourdie. À la Tour, les recharges passent d'un étage à l'autre : une forte lâchée pour rien manque au Gardien.
  - *Lire la menace* : si tous les ennemis sont étourdis ou en trêve, pas de protection ce tour.
- **La frustration se mesure** : le simulateur tient un tableau des erreurs par rôle (actions perdues sur un ennemi déjà mort, soins en trop, protections jamais touchées, fortes gaspillées, achèvements ratés) et l'IA se règle jusqu'à ce qu'elles soient rares. **[Proposé]**
- Le joueur ne donne jamais d'ordre, ne pointe pas de cible, ne change pas de posture. **[Décidé]**
- Plus tard (étape 5) : **chacun règle son propre Écho** (deux ou trois choix : « soigne dès 60 % », « garde la forte pour les Gardiens », « suit la cible du joueur »), visibles sur sa fiche quand on l'emprunte. C'est le propriétaire qui dit comment joue son personnage quand il n'est pas là, pas l'emprunteur. **[Proposé]**

## 4. Les Échos

- Un Écho est **le personnage d'un vrai joueur** (classe, Destin, équipement) piloté par l'IA. Avant le serveur (étape 5), des Échos générés en tiennent lieu.
- **Composition** : toujours un Front, un Dégâts, un Soutien, par rôle principal. Fronts : Guerrier, Pugiliste, Invocateur. Dégâts : Mage, Voleur, Archer. Soutiens : Prêtre, Alchimiste, Barde, Diplomate. Le joueur occupe sa case ; les deux autres sont complétées. **[Décidé]**
- **Trois sources** : des amis, des membres de la guilde, ou des profils aléatoires. **[Décidé]**
  - Amis et guilde : **à leur vrai niveau**, donc ils peuvent porter ; c'est voulu, pour qu'un nouveau rattrape les anciens sans frustration. **Limite : 3 aides par jour.** Le classement par classe tient : celui qui monte seul avec des Échos aléatoires va plus haut que celui qui ne monte que de trois étages par jour avec de l'aide. **[Décidé]**
  - Aléatoires : **ramenés au niveau du joueur** (leur Destin avec autant de points, même mini-arbre), sans limite. **[Décidé]**
- **Récompense de sélection** : chaque fois qu'un personnage est choisi pour compléter un trio, son propriétaire gagne un peu d'XP et de la monnaie de cosmétiques, **sans jouer**. Plafonnée par jour (5 sélections payées) ; un personnage n'est proposé en aléatoire que si son joueur a joué dans la semaine. Jamais de puissance directe. Comme le trio a besoin d'un Front et d'un Soutien, ce sont les classes rares qui sont choisies le plus : la rareté se paie toute seule. **[Décidé ; plafonds : Proposé]**
- **En PvP classé**, le joueur complète son trio avec deux Échos aléatoires à son niveau, jamais des amis (équité). **[Proposé]**

## 5. La Tour (solo, en trio)

- **Fixe, sans remise à zéro.** Tu atteins l'étage 10, demain tu reprends à l'étage 10. C'est de là que vient le blocage. **[Décidé]**
- **Paliers tous les 5 étages** (les Gardiens) : on reprend au dernier palier avec tous ses PV ; entre deux paliers, l'usure joue : 20 % des PV max rendus entre deux étages, un membre KO revient avec 20 %, recharges conservées. **[Proposé]**
- **Étages** : des monstres du bestiaire (1 à 4 par étage, budget de menace, un seul soigneur), Gardiens aux étages 5 et 10 ; à rééquilibrer pour un trio (plus de monstres).
- **La Tour est absolue, le joueur est relatif** : un étage a toujours la même force ; le simulateur règle « à quel niveau on passe tel étage » (par exemple : étage 3 dès le niveau 1, Gardien de l'étage 5 vers le niveau 8–10, sommet Aspirant vers le niveau 25–30). **[Proposé]**
- **Étages des Élus** : 10 étages de plus, ouverts par l'Évolution. **[Proposé]**
- **Faveurs de la Tour** : chaque Gardien vaincu pour la première fois donne une Faveur permanente, à choisir parmi trois (+10 % de PV dans la Tour, +15 % contre une famille, forte prête au départ, 30 % de PV rendus entre étages…). **Valables seulement dans la Tour** : une progression de puissance en PvE qui ne touche pas au PvP. **[Proposé]**
- **Revenu passif selon la hauteur** : monnaie de cosmétiques et un peu d'XP par jour, plafonnés (l'équivalent d'un duel), jamais d'objets de puissance. À mesurer contre l'économie. **[Décidé dans le principe, à mesurer]**
- **Record** = étage atteint, par classe. La Tour **grandit à chaque saison** (10 étages de plus), la course est au sommet du moment. **[Proposé]**
- **Comment on devient plus fort quand on est bloqué** : par les duels (XP la plus rapide), par les étages déjà passés (chaque étage franchi donne son XP), par la sélection comme Écho, par les donjons, par un ami qui porte (3 par jour), par les Faveurs, par l'équipement, et au niveau 30 par l'Évolution. **[Décidé]**

## 6. Le PvP (trio contre trio)

- **Asynchrone** : ton trio contre le trio d'un autre joueur, piloté par l'IA (ce sont les Échos du V1). **5 combats classés par jour**, valeur modulable, pour que personne ne se lasse à force de spammer. **[Décidé]**
- Amicaux illimités, sans XP ni classement. **[Proposé]**
- **Synchrone** : plutôt que 6 humains (introuvables), **2 humains en direct, chacun avec ses 2 Échos** ; 5 par jour aussi. **[Proposé]**
- Matchmaking par ligue, niveau et score d'équipement (§ 9). Deux ligues : Aspirants, Élus.
- Classement par saison. **[Ouvert : forme des ligues et divisions.]**

## 7. Les donjons (3 joueurs humains)

### 7.1 Principe

- Plusieurs donjons ouverts en même temps, **un par tranche de niveau**, communs à tout le serveur (on y joue avec sa guilde, ses amis ou des inconnus). **[Décidé]**
- Un donjon est un arbre de routes : à chaque embranchement, **trois portes** ; une route fait X combats ; au bout, **un combat d'élite**, sauf sur **une seule route : le boss**. Après chaque vague vaincue, le trio **vote** la porte suivante (majorité ; si les trois votent différemment, celui qui a le plus de routes explorées tranche). **[Décidé ; départage : Proposé]**
- Le groupe a le droit d'abandonner quand il veut ; pas de limite de tours.

### 7.2 Les portes sans nom (contre le partage sur Internet)

- Les trois portes d'un embranchement sont **identiques** et **leur ordre est propre à chaque joueur** (calculé à partir du joueur et de la porte ; aucun hasard en jeu). La porte que Léa voit à gauche, Tom la voit peut-être au milieu. Le jeu connaît la vraie identité de chaque porte ; personne ne la voit.
- **Les trois portes mènent à la même vague** (les monstres dépendent de la profondeur, pas de la porte) : on ne peut pas décrire une porte par ce qu'il y a derrière.
- Conséquence : **une route ne peut pas s'écrire**. « Gauche, milieu, gauche » ne veut rien dire pour un autre joueur ; une capture d'écran de carte est dans l'ordre de celui qui l'a prise ; un streamer montre ses portes à lui. **Seule la carte en jeu sait** : le jeu traduit pour chacun (« la porte de gauche est explorée », « Léa a voté pour la porte de droite »). **[Décidé]**

### 7.3 Les cartes

- **Carte personnelle** : les routes que le joueur a lui-même parcourues.
- **Carte de guilde** : l'union des cartes de ses membres. Rejoindre une guilde active réduit les chemins ; un explorateur qui rejoint apporte sa carte. Quitter la guilde n'emporte que sa carte personnelle. **[Décidé]**
- **Fragments de carte** : les combats d'élite (et certaines vagues) donnent un fragment qui révèle une porte à un embranchement, rendu dans l'ordre de chacun. La chasse n'est pas qu'un tâtonnement. **[Proposé]**
- Les routes explorées rapportent par elles-mêmes (points de guilde, monnaie) : la carte est une progression (« 38 % du donjon connu »). **[Proposé]**

### 7.4 Le boss, unique au serveur

- **Un seul boss par donjon et par serveur.** Il ne bouge pas tant qu'il n'est pas mort : la chasse peut durer des semaines. **[Décidé]**
- **Sa mort est un événement** : annonce à tout le serveur, titre, récompenses uniques pour la guilde qui l'a tué en premier. Puis **une nouvelle chasse** : nouveau boss, nouvelles routes, cartes remises à zéro pour tout le monde. **[Décidé]**
- Option : une **semaine de curée** après le premier, où les autres guildes peuvent le tuer pour des récompenses moindres. **[Proposé]**

### 7.5 Le combat de boss

- **La porte du boss est ouverte à tous**, guilde ou non. **[Décidé]**
- Le boss a des **paliers de vie** (80 %, 50 %, 20 %…). À chaque palier, un blocage : il brille et prépare un coup qui tue tout le monde, ou devient immortel, ou s'enfuit. **La solution est secrète** et se trouve en essayant : toujours un geste de classe, un palier ou un rôle (« une basique de lumière pendant qu'il brille », « deux fortes le même tour », « la forte d'un Front pendant qu'il charge »). Sans hasard : il brille au tour 4, chaque fois. Le jeu dit après coup ce qui a manqué, en termes vagues (« il fallait de la lumière »). **[Décidé]**
- Sans la bonne classe dans le trio, on ne passe pas : c'est voulu. Le groupe revient avec la classe qu'il faut.
- **Le coup final ne porte que s'il vient de trois membres d'une même guilde.** Dit clairement à l'entrée du donjon et expliqué par l'histoire (le boss ne se laisse abattre que sous une bannière). Un groupe d'inconnus va jusqu'au bout, apprend tous les paliers, rentre avec la récompense d'élite et sait qu'il lui faut une guilde. **[Décidé]**
- Les mécaniques des blocages viennent de `docs/MECANIQUES.md` (immortalité = barrière infinie jusqu'au geste, fuite = fin du combat sans récompense, coup mortel = dégâts > PV max).

### 7.6 Les récompenses

- Élite : équipement épique, fragments, monnaie. Boss : **extraordinaires**, selon le niveau du donjon : équipement légendaire, skins de lignée uniques, titres, Faveur rare. **[Décidé dans le principe]**
- **[Ouvert]** Gautier a évoqué « un grimoire de changement de classe ». Ça contredit « un seul personnage, classe fixe hors Évolution ». Propositions de remplacement : le choix de l'Évolution parmi **cinq** au lieu de trois, ou un **second Destin** proposé au moment d'évoluer. À trancher.
- Aucune récompense de boss ne donne de puissance qui ne soit pas de l'équipement (soumis aux mêmes plafonds que le reste, § 9).

## 8. Les guildes et les territoires

- **Le cœur du jeu à terme** : les combats de guilde chaque soir. Conditions : qu'un joueur sans guilde s'amuse déjà (Tour, duels, donjons avec des inconnus) ; qu'une guilde inactive se dissolve doucement et que le jeu propose des guildes actives ; des soirées par fuseau horaire. **[Décidé dans le principe]**
- **Les guerres se jouent en asynchrone** : chaque membre fait ses combats de trio dans la soirée, on somme. Personne n'a besoin d'être connecté à la même heure. **[Proposé]**
- **Territoires** : la carte du monde est découpée ; une guilde qui tient un territoire où apparaît un donjon a un avantage : une part des routes révélées par les joueurs des autres guildes dans ce donjon, une part de la monnaie dépensée pour y entrer. **[Décidé dans le principe]** Garde-fous : avantages plafonnés (au plus 10 % des routes), nombre de territoires limité par guilde, carte remise à zéro chaque saison, bonus de rattrapage pour les petites guildes (contre la boule de neige). **[Proposé]**
- **L'appel** : « on est au boss, il manque un Prêtre » notifie les membres de la classe voulue ; alliances entre deux guildes pour les boss (le coup final reste à une guilde). **[Proposé]**
- **[Ouvert]** Taille (100 ?), création, rôles (chef, officiers), chat en jeu (et sa modération) ou non.

## 9. L'équipement

- **La base (classe, Destin) est équilibrée au maximum ; l'équipement crée les écarts de puissance ; aucun des deux ne crée de méta.** **[Décidé]**
- **Même langue que le Destin** : un objet est un paquet de modificateurs (+PV, +puissance, +feu, brûlure plus longue, forte qui revient plus tôt, ta moyenne +X %…), ceux que le moteur applique déjà aux nœuds du Destin. Un objet n'a pas de valeur en soi, il en a pour un Destin : « brûlure +2 tours » vaut de l'or avec Boule de feu et rien avec Trait de givre. Deux joueurs d'une même classe n'ont pas le même meilleur objet, et c'est voulu. **[Décidé]**
- **À la Diablo** : **5 emplacements** (Arme, Armure, Anneau, Amulette, Talisman : le Talisman parle d'une compétence) ; **4 raretés** (Commun 1 ligne, Rare 2, Épique 3, Légendaire 3 + un trait unique) ; **des noms fixes dont les lignes et les fourchettes sont connues et affichées** (« Anneau de braise : +feu [4–10], +PV [10–30], brûlure [+1–2 tours] »), **les chiffres tirés à la trouvaille**, avec une qualité en % ; **le niveau de l'objet** fait grandir les fourchettes. **[Décidé]**
- **Contre la méta** : un **budget par objet** (les lignes se partagent un budget selon rareté et niveau) ; des **plafonds par statistique** tous objets confondus (par exemple +30 % de puissance, −2 tours de recharge au plus) ; et **la mesure** : le simulateur règle les fourchettes avec la règle « en moyenne sur tous les Destins, aucune ligne ne gagne plus qu'une autre ; pour un Destin donné, elles diffèrent beaucoup ». **[Proposé]**
- **Traits légendaires** : un seul par objet, pris dans les mécaniques ◇ de `docs/MECANIQUES.md`, jamais de hasard en combat. **[Proposé]**
- **Sources** : Tour (étages, Gardiens), donjons (élites : épiques ; boss : légendaires), coffre hebdomadaire du PvP, territoires. **Jamais la boutique.** **[Décidé]**
- **Reforge** : refaire le tirage d'une seule ligne contre de la monnaie du jeu, coût croissant sur le même objet. Objets **liés au personnage**, pas d'échange ; les objets en trop se recyclent. **[Proposé]**
- **PvP** : matchmaking classé par niveau et **score d'équipement** ; à score égal, aucun choix n'est meilleur pour tout le monde. **[Proposé]**
- Dans le moteur, l'équipement s'ajoute aux modificateurs du Destin (`CombatUnit.mods`, `skill_mods`) ; le simulateur tire des équipements au hasard pour mesurer.

## 10. Progression et économie

- **XP** : duels (toujours la plus rapide), étages de la Tour (chaque étage franchi, même si on tombe ensuite), sélection comme Écho (plafonnée), donjons, revenu passif de la Tour (plafonné). Le GDD vise 20 à 60 minutes par niveau au début ; la courbe du prototype est plus rapide pour tester et sera rallongée. **[Décidé]**
- **Trois objectifs du jour** (« gagne 2 duels », « franchis 3 étages », « déclenche 2 Synergies ») avec un bonus d'XP : ils disent au joueur bloqué quoi faire. **[Proposé]**
- **Niveau 30 → Évolution** (×2,5, nouveau Destin, ligue des Élus, étages des Élus).
- **Monnaie** : une monnaie de cosmétiques gagnée en jouant (Tour, Échos, routes, donjons, territoires), dépensée en skins et en reforge. **[Ouvert : une seule monnaie, ou une seconde réservée à la reforge ?]**
- **Boutique** : skins de lignée (personnage), animations, poses, titres. Rien d'autre. **[Décidé]**
- **Saisons** : classements PvP, Tour qui grandit, carte des territoires remise à zéro, donjons renouvelés. **[Ouvert : durée (3 mois ?).]**

## 11. Les écrans et la navigation **[Proposé, jamais discuté]**

Barre du bas, cinq onglets : **Accueil**, **Personnage**, **Guilde**, **Jouer**, **Profil**.

- **Accueil** : ton personnage en grand, le mot du jour (objectifs du jour, appel de guilde, boss tué sur le serveur), trois gros boutons : La Tour (« Étage 7, palier 5 »), Duel (« 3 combats classés restants »), Donjon (« niveaux 10–20 ouvert »).
- **Personnage** : Compétences (3 actives, passif, Synergies possibles par classe d'Écho), Destin (l'arbre, vue en lignes : une ligne par chemin depuis la racine, nœuds pris allumés), Équipement (5 emplacements, inventaire, comparaison « avec cet objet, Boule de feu fait 54 au lieu de 48 »), Mon Écho (comment mon personnage joue quand il est prêté, et ce qu'il m'a rapporté).
- **Guilde** : membres, carte des donjons (38 % connu, fragments), territoires, guerre du soir (mes combats à faire, le score), appel, alliances.
- **Jouer** : choisir le mode, puis **composer le trio** (toujours le même écran : ma case, deux cases à compléter : amis, guilde, aléatoire ; les aides restantes du jour ; la fiche de chaque Écho : classe, niveau, comment il joue, nos Synergies).
- **Profil** : niveau, records (Tour par classe, duels, donjons), titres, skins, paramètres.
- **Combat** : l'écran actuel (carte du milieu, consigne en gros, Synergies en doré), avec trois personnages côté joueur, l'adversaire opaque, les icônes d'état, la lueur « forte prête » ; au donjon, l'écran de vote des portes entre deux vagues.
- **Premier lancement** : création (classe, Destin dévoilé), premier combat guidé contre des monstres, puis l'Accueil. Plus d'écran de rencontre de l'acolyte.

## 12. Ce qui existe déjà et l'ordre de construction

**Existe (prototype web, 28 octobre)** : moteur pur et testé (168 tests), 10 classes, 63 Synergies, Destin (45 nœuds, mini-Destin), niveaux et XP, Tour à monstres (10 étages, bestiaire), duel en duo contre une IA, simulateur et régleur (en local et sur GitHub Actions), écrans de création, accueil, compétences, Destin, Tour, bestiaire, profil, paramètres.

**Ordre** (chaque bloc doit être amusant seul avant le suivant) :
1. **Le trio avec Échos générés** (le moteur sait déjà faire du 3 contre N) : composition par rôle, annonces en chaîne, Synergies avec les deux, IA de bon sens et tableau des erreurs, adversaire opaque, écran de composition du trio. Retirer l'acolyte fixe et la rencontre. Les Soutiens « toujours utiles » et le geste de classe (données). Rééquilibrer (duel 3v3, Tour en trio).
2. **La Tour fixe à paliers**, sans limite de tours, soins des monstres qui s'affaiblissent, Faveurs, étages des Élus (après l'Évolution), revenu passif. Réglage « à quel niveau on passe tel étage ».
3. **L'équipement** : données, inventaire, fiche et comparaison, butin de la Tour, reforge, passe de simulateur sur les lignes.
4. **Serveur et comptes** (étape 5 du V1) : vrais Échos (amis, guilde, aléatoires), récompenses de sélection, PvP asynchrone classé à 5 par jour, PvP synchrone à 2 humains, classements.
5. **Guildes et donjons à routes** : portes sans nom, cartes, fragments, élites, boss unique au serveur et ses paliers, coup final de guilde, appel.
6. **Territoires et guerres du soir** : quand les donjons ont prouvé qu'ils font revenir les gens.
7. Art (PixelLab), évolutions, boutique, bêta, lancement (comme le V1).

## 13. Questions ouvertes pour Gautier

1. **L'univers** (La Veille, Le Tissage, La Foire des Dieux oubliés) : il faut maintenant une raison d'histoire pour la bannière de guilde, les Échos et les boss. Laquelle ?
2. **Le nom du jeu.**
3. **La récompense « changement de classe » des boss** : garder (et rouvrir « classe fixe ») ou remplacer (Évolution parmi cinq, second Destin) ?
4. **Les saisons** : durée, et ce qui se remet à zéro (Tour qui grandit, territoires, donjons, classements).
5. **La guilde** : taille, création, rôles, chat en jeu (avec modération) ou pas de chat.
6. **La monnaie** : une seule, ou une seconde pour la reforge ?
7. **Les Faveurs de la Tour, les paliers tous les 5 étages, la Tour qui grandit** : d'accord tels quels ?
8. **Le PvP synchrone à 2 humains + 4 Échos** et **les amicaux illimités** : d'accord ?
9. **La navigation du § 11** : d'accord dans les grandes lignes ?
