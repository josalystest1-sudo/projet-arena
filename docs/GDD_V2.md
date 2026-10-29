# Projet Arena — GDD V2 : le trio, les Échos, la Tour infinie, les donjons et les guildes

Rédigé le 29 octobre 2026 à partir des décisions prises avec Gautier ce jour-là (version 2.2 : économie et risques de guilde validés au soir ; le plan de développement est dans `docs/PLAN.md`). **Ce document remplace le GDD V1 (`docs/GDD.md`) sur tout ce qu'il traite** ; le V1 reste la référence pour ce qu'il ne traite pas (les tableaux de compétences des 10 classes, les trois pistes d'univers, l'écran de création, les évolutions de base). En cas de contradiction, le V2 l'emporte. `CLAUDE.md` résume l'état du prototype ; `docs/MECANIQUES.md` liste toutes les mécaniques de combat.

Chaque règle porte une étiquette : **[Décidé]** (validé par Gautier), **[Proposé]** (choix de Claude Code là où Gautier a demandé de décider ou n'a rien dit ; on construit ça tel quel sauf correction), **[Ouvert]** (rien à construire avant la réponse).

**Raccord avec le combat V2 (29 octobre au soir)** : ce document a été écrit sans connaître le combat V2 (`docs/SPEC-COMBAT-V2.md`), qui reste la référence pour les règles d'un combat (roue, voies, jalons, menaces, 4 Synergies universelles, 20 tours). Ce qui est caduc ici, et les deux points à trancher par Gautier (l'adversaire opaque, le rôle de l'Invocateur) : `docs/PLAN.md`, « Raccord avec le combat V2 ».

---

## 1. Le jeu en douze lignes

- RPG mobile en pixel art, **tout en mode portrait**, tour par tour **simultané** (12 s pour choisir, résolution par ordre de vitesse), **sans aucun hasard en combat**. **[Décidé]**
- **Un seul personnage par compte**, avec un **Destin** unique (arbre de 45 nœuds, 30 points, un point par niveau). Le joueur ne joue jamais que lui. **[Décidé]**
- **10 classes de base**, chacune avec **3 évolutions**, chacune avec **3 évolutions de second rang** (10 + 30 + 90), plus des **classes de grimoire** (rares, épiques, légendaires) obtenues sur les boss de donjon. **[Décidé]**
- **On joue toujours en trio** Front + Dégâts + Soutien : le joueur occupe la case de son rôle principal, les deux autres sont des **Échos**, des personnages de vrais joueurs pilotés par l'IA. Le joueur ne leur donne jamais d'ordre. **[Décidé]** (Remplace le duo joueur + acolyte du V1.)
- **La Tour** est **infinie**, fixe, sans remise à zéro : le concours est à qui monte le plus haut. **[Décidé]**
- **Le PvP** : trio contre trio, asynchrone (5 classés par jour) et synchrone à 6 humains. **[Décidé]**
- **Les donjons** : 3 joueurs humains, routes secrètes impossibles à écrire, boss unique au serveur. **[Décidé]**
- **Les guildes** : jusqu'à 100 membres, guerres du soir, territoires sur la carte du monde, ressource de guilde, classement. **[Décidé]**
- Les **Soutiens** n'ont pas besoin de faire des dégâts. **[Décidé]**
- **L'équipement** crée les écarts de puissance ; la base est équilibrée au maximum ; ni l'un ni l'autre ne crée de méta. **[Décidé]**
- Financement par **cosmétiques uniquement**. Jamais de puissance vendue. **[Décidé]**
- L'IA est **prévisible plutôt que brillante**, mais jamais bête.

## 2. Décisions verrouillées (ne pas rouvrir sans Gautier)

Inchangées : pas de Garde/Brèche, pas de Tempo, pas de mana, pas de timing en temps réel, pas de pierre-feuille-ciseaux, pas de hasard en combat, Destin non modifiable (on ne retire jamais un point), un seul personnage par compte, jamais de puissance vendue, moteur de règles pur et testé, données en fichiers.

Modifiées le 29 octobre :
- **Le duo joueur + acolyte est remplacé par le trio joueur + 2 Échos.** Plus d'acolyte fixe, plus d'écran de rencontre. **[Décidé]**
- **« Aucune limite de parties »** devient : **5 combats PvP classés par jour** (asynchrone) et le synchrone classé limité aussi ; le PvE n'a aucune limite. **[Décidé]**
- **« La classe est fixe hors Évolution »** devient : **la classe change par Évolution (deux rangs) ou par grimoire de classe** ; changer de classe garde le niveau et donne un tout nouveau Destin. **[Décidé]**
- **Pas d'inflation, pas de bots vendeurs d'or** : l'or ne vient que de la vente d'objets de chance ; les joueurs fixent leurs prix dans une fourchette ; aucun canal de transfert hors Marché (voir § 10.2). **[Décidé]**

## 3. Les classes

- **10 classes de base** (Guerrier, Mage, Voleur, Archer, Prêtre, Alchimiste, Invocateur, Barde, Diplomate, Pugiliste ; rôles Front / Dégâts / Soutien). Kits : 6 actives (2 par palier) + 4 passifs ; un Destin tire une active par palier + 1 passif.
- **Évolution de rang 1** au niveau 30 : choix parmi 3 (30 classes), puissance ×2,5, nouveau Destin. **Évolution de rang 2** : choix parmi 3 pour chaque classe de rang 1 (90 classes), même saut. **[Décidé ; le niveau de la seconde Évolution : Proposé, 60]**
- **Classes de grimoire** : rares, épiques, légendaires. **Sans évolution, uniques.** Obtenues seulement par un **grimoire de classe** lâché par un boss de donjon : très forte chance pour un rare, très faible pour un épique, quasi nulle pour un légendaire. Un seul grimoire par boss, donné à **un seul** membre du trio vainqueur, en plus des récompenses communes. **[Décidé]** Le membre qui le reçoit est tiré au sort devant les trois (un tirage visible, pas en combat). **[Proposé]**
- **Puissance, sans méta** : une classe rare vaut une classe évoluée de rang 2 ; une épique est légèrement plus forte ; une légendaire légèrement plus forte qu'une épique. **[Décidé]** Pour que ça ne fasse pas de méta : chaque classe de grimoire a sa propre réserve de compétences et de Synergies, est réglée au simulateur comme les autres, et **joue dans la ligue de sa puissance** (voir § 6). **[Proposé]**
- **Changer de classe** (Évolution ou grimoire) **garde le niveau et donne un tout nouveau Destin** de la nouvelle classe. **[Décidé]** Le nouveau Destin reçoit aussitôt autant de points à placer que le niveau le permet (30 au plus), pour que le joueur reconstruise son arbre ; les points suivants viennent des niveaux suivants. **[Proposé]**
- **Le niveau continue** au-delà de 30 : 1–30 pour la classe de base, 31–60 pour le rang 1, 61–90 pour le rang 2 ; un grimoire se joue au niveau où on l'a reçu. **[Proposé]**
- **Le geste de classe** : chaque classe a un geste constant quel que soit son Destin (ses deux basiques partagent un élément propre ; une forte est toujours une forte). Les conditions de boss ne parlent que de gestes, de paliers ou de rôles. **[Décidé]** Les classes évoluées et de grimoire ont aussi leur geste.

## 4. Le combat

### 4.1 Règles (rappel)

- 12 s pour choisir, résolution par vitesse. Basique (sans recharge), moyenne (revient 2 tours après), forte (4 tours, dès le tour 3), 1 passif. Chiffres dans `data/`.
- **PvP** : mort subite au tour 8 (soins ÷ 2, dégâts +50 % par tour), fin forcée au tour 13 (PV totaux, puis dégâts, puis camp prioritaire). Jamais de match nul.
- **PvE : aucune limite de tours.** Un combat peut durer 100 tours ; le joueur abandonne quand il veut. Les règles « les monstres s'épuisent au tour 12 » et « ils abandonnent au tour 24 » sont retirées. **[Décidé]** Pour que tout combat reste gagnable : un seul soigneur par groupe de monstres, et **leurs soins et régénérations s'affaiblissent à chaque usage** (100, 75, 56…). Plafond technique du simulateur : 300 tours, compté comme un abandon, invisible au joueur. **[Proposé]**

### 4.2 L'adversaire est opaque

- En combat, on ne voit de l'adversaire ni ses compétences, ni son Destin, ni ses recharges, ni son équipement : on le découvre en le regardant jouer. **[Décidé]**
- Deux exceptions, des signaux et non des informations à lire : **les icônes d'état** sur tous les personnages (avec le nombre de tours) et **une lueur « forte prête »** sur un ennemi dont la grosse attaque est disponible. **[Décidé]**
- Après le combat, l'écran de fin peut résumer le Destin et le kit de l'adversaire. **[Proposé]**
- Côté joueur, tout reste visible : ses recharges, celles de ses Échos, leurs annonces, les Synergies possibles.
- À retirer du prototype : pastilles de recharge des ennemis, kit complet au toucher, bandeau des sorts adverses.

### 4.3 Le trio et les annonces

- Au début des 12 s, **le premier Écho annonce** (action et raison), **puis le second** en connaissant la première, **puis le joueur choisit** en connaissant les deux. **[Décidé]**
- Les **Synergies** valent entre le joueur et chacun de ses Échos (les 63 existantes couvrent toutes les paires de classes de rôles différents). La règle d'attente (garder sa forte un tour pour une Synergie, jamais deux) est conservée.

### 4.4 Les Soutiens

- **Un Soutien n'a pas besoin de faire des dégâts** : sa valeur, c'est les PV du trio (rendus, non perdus, ou coups ennemis en moins). **[Décidé]**
- **Chaque compétence de Soutien a un effet utile même quand personne n'est blessé.** Replis pour celles qui ne l'ont pas : Résurrection → si personne n'est KO, le prochain coup mortel sur l'allié le laisse à 1 PV (une fois) ; Purification → s'il n'y a rien à retirer, immunité contre le prochain état négatif ; Catalyseur → sans recharge en cours chez l'allié, il le rend Vif. **[Proposé]**
- **Quatre façons d'être Soutien, qui se valent** : le Prêtre répare, l'Alchimiste dure, le Barde accélère, le Diplomate interdit. Le simulateur règle leurs chiffres jusqu'à ce que tout trio, quel que soit son Soutien, aille aussi loin et gagne autant. **[Décidé]**
- Au plus une compétence qui frappe dans la réserve de six d'un Soutien ; un Destin sans aucune n'est pas un handicap. **[Proposé]** L'IA du Soutien : soigner si besoin, sinon renforcer ou affaiblir, jamais « sinon frapper ».

### 4.5 L'IA (une seule : Échos, adversaires, monstres, simulateur)

- Règles fixes par rôle, dans un ordre fixe (celles de `CLAUDE.md`, étendues au trio).
- **Règles de bon sens avant les règles de rôle** **[Proposé]** : *achever* (si un ennemi peut tomber ce tour avec ce que les alliés ont annoncé plus mon coup, je le frappe avec la compétence la moins chère qui suffit) ; *ne pas gaspiller la forte* (protection forte seulement si un allié a perdu des PV ou si un ennemi a sa forte prête ; attaque forte seulement si elle tue, touche deux ennemis ou frappe une cible marquée ou étourdie ; les recharges passent d'un étage à l'autre) ; *lire la menace* (si tous les ennemis sont étourdis ou en trêve, pas de protection).
- **La frustration se mesure** : tableau des erreurs par rôle au simulateur (actions perdues, soins en trop, protections jamais touchées, fortes gaspillées, achèvements ratés), IA réglée jusqu'à ce qu'elles soient rares. **[Proposé]**
- Le joueur ne donne jamais d'ordre. **[Décidé]** Plus tard : chacun règle son propre Écho (deux ou trois choix visibles sur sa fiche). **[Proposé]**

## 5. Les Échos

- Un Écho est **le personnage d'un vrai joueur** (classe, Destin, équipement) piloté par l'IA. Avant le serveur, des Échos générés en tiennent lieu.
- **Composition** : toujours un Front, un Dégâts, un Soutien, par rôle principal (Fronts : Guerrier, Pugiliste, Invocateur ; Dégâts : Mage, Voleur, Archer ; Soutiens : Prêtre, Alchimiste, Barde, Diplomate ; les classes évoluées et de grimoire ont chacune leur rôle). Le joueur occupe sa case. **[Décidé]**
- **Trois sources** : amis, membres de la guilde, profils proposés par le jeu. **[Décidé]**
  - Amis et guilde : **à leur vrai niveau** (ils peuvent porter : un nouveau rattrape les anciens sans frustration). **3 aides par jour.** **[Décidé]**
  - Proposés par le jeu : **au niveau du joueur**, sans limite. **[Décidé]**
- **Récompense de sélection** : chaque fois qu'un personnage complète un trio, son propriétaire gagne un peu d'XP et de monnaie, sans jouer. Les classes rares dans le trio (Front, Soutien) sont choisies le plus : la rareté se paie toute seule. **[Décidé]** Plafond : 5 sélections payées par jour ; proposé en aléatoire seulement si son joueur a joué dans la semaine. **[Proposé]**
- Mêmes règles de composition en Tour, en PvP et en donjon (au donjon, les trois sont humains).

## 6. La Tour (solo, en trio)

- **Infinie, fixe, sans remise à zéro.** Tu atteins l'étage 40, demain tu reprends à l'étage 40. Le concours est à qui est le plus haut. **[Décidé]**
- **Assez d'étages pour que personne n'atteigne jamais le plafond**, en tenant compte des sauts de puissance (Évolutions, grimoires, équipement) : les étages sont **générés** (famille, budget de menace, PV et puissance qui montent par une courbe réglée au simulateur), Gardien tous les 5 étages avec des variantes qui montent en gamme. **[Décidé ; génération : Proposé]**
- **Paliers tous les 5 étages** (optionnels selon Gautier, gardés) : on reprend au dernier palier avec tous ses PV ; entre deux paliers, l'usure joue (20 % des PV rendus entre étages, un KO revient à 20 %, recharges conservées). **[Proposé]**
- **Rejouer depuis un palier** est toujours possible : les étages déjà franchis redonnent de l'XP et du butin (moins qu'une première fois). C'est la boucle de ferme en solo : bloqué à l'étage 23, on refait 20 à 22 pour l'XP et l'équipement. **[Proposé]**
- **La Tour est absolue, le joueur est relatif** : un étage a toujours la même force ; le simulateur règle « à quel niveau et avec quel équipement on passe tel étage ». **[Proposé]**
- **Faveurs de la Tour** : chaque Gardien vaincu pour la première fois donne une Faveur permanente, à choisir parmi trois, **valable seulement dans la Tour**. **[Proposé]**
- **Revenu passif selon la hauteur** : monnaie et un peu d'XP par jour, plafonnés, jamais d'objets de puissance. **[Décidé dans le principe, à mesurer contre l'économie]**
- **Classement** = étage atteint, par classe. Pas de saison pour la Tour (elle ne se remet pas). **[Décidé]**

## 7. Le PvP (trio contre trio)

- **Asynchrone classé** : ton personnage + 2 Échos choisis parmi amis, guilde ou profils proposés (de ton niveau), contre le trio d'un autre joueur piloté par l'IA. **5 combats par jour** (modulable). **[Décidé]** Les amis et guildés comptent dans les 3 aides du jour ; le matchmaking se fait sur la puissance totale du trio (niveau, classe, équipement), pas seulement sur le joueur, pour que porter ne soit pas tricher. **[Proposé]**
- **Synchrone classé** : **3 contre 3 à 6 humains**, limité par jour aussi (5). **[Décidé]** Il faut une file par rôle pour former deux trios Front + Dégâts + Soutien ; en attendant 6 joueurs, le jeu propose de lancer la partie à 2 humains + 4 Échos. **[Proposé]**
- Amicaux illimités, sans XP ni classement. **[Proposé]**
- **Ligues par puissance** : Aspirants (classes de base), Élus (rang 1), Ascendants (rang 2 et classes de grimoire). **[Proposé]**
- **Saisons** : le classement PvP se remet à zéro à chaque saison. **[Décidé]** Durée : 3 mois. **[Proposé]**

## 8. Les donjons (3 joueurs humains)

### 8.1 Principe

- Plusieurs donjons ouverts en même temps, **un par tranche de niveau**, communs au serveur ; on y va avec sa guilde, ses amis ou des inconnus. **[Décidé]** Ils sont placés sur la carte du monde, avec leur niveau. **[Décidé]**
- Un donjon est un arbre de routes : **trois portes** à chaque embranchement ; une route fait X combats ; au bout, **un élite**, sauf sur une seule route : **le boss**. Après chaque vague, le trio **vote** la porte suivante (majorité ; trois votes différents : celui qui a le plus de routes explorées tranche). **[Décidé ; départage : Proposé]**
- Entrer coûte des Éclats (une part va à la guilde qui tient le territoire, § 9). Pas de limite de tours, abandon libre.

### 8.2 Les portes sans nom

- Trois portes **identiques** dont **l'ordre est propre à chaque joueur** (calculé à partir du joueur et de la porte) ; le jeu connaît la vraie identité de chaque porte, personne ne la voit ; **les trois mènent à la même vague** (les monstres dépendent de la profondeur). **Une route ne peut donc pas s'écrire** : « gauche, milieu » ne veut rien dire pour un autre ; une capture d'écran est dans l'ordre de son auteur ; un streamer montre ses portes à lui. Seule la carte en jeu sait, et le jeu traduit pour chacun (« la porte de gauche est explorée », « Léa a voté pour la porte de droite »). **[Décidé]**

### 8.3 Les cartes

- **Carte personnelle** (les routes qu'on a parcourues soi-même) ; **carte de guilde** (l'union des cartes de ses membres : rejoindre une guilde active réduit les chemins ; quitter n'emporte que sa carte personnelle). **[Décidé]**
- **Fragments de carte** sur les élites : révèlent une porte, dans l'ordre de chacun. Les routes explorées rapportent par elles-mêmes (ressource de guilde, monnaie). **[Proposé]**

### 8.4 Le boss, unique au serveur

- Un seul boss par donjon et par serveur ; **il ne bouge pas** tant qu'il n'est pas mort (la chasse peut durer des semaines). **Sa mort est un événement** (annonce, titre, récompenses uniques), puis **nouvelle chasse** : nouveau boss, nouvelles routes, cartes remises à zéro. **[Décidé]** À la mort d'un boss, un donjon peut apparaître sur un territoire de guilde (§ 9). **[Décidé]**
- Option : une semaine de curée pour les autres guildes, à récompenses moindres. **[Proposé]**

### 8.5 Le combat de boss

- **La porte est ouverte à tous.** Le boss a des **paliers de vie** avec un blocage (coup mortel, immortalité, fuite) dont **la solution est secrète** et se trouve en essayant : toujours un geste de classe, un palier ou un rôle, jamais un sort précis d'un Destin ; sans hasard. Le jeu dit après coup ce qui a manqué, en termes vagues. Sans la bonne classe, on ne passe pas : voulu. **[Décidé]**
- **Le coup final ne porte que s'il vient de trois membres d'une même guilde**, dit à l'entrée et expliqué par l'histoire. Un groupe d'inconnus va jusqu'au bout, apprend tout, repart avec la récompense d'élite. **[Décidé]**

### 8.6 Les récompenses

- **Communes aux trois** : équipement (les plus puissants du jeu), ressources, titres. **Un grimoire de classe** à un seul membre (§ 3). Élites : équipement épique, fragments, monnaie. **[Décidé]**

## 9. Les guildes, la carte du monde et les territoires

### 9.1 La guilde

- **Taille qui grossit avec le niveau de guilde, 100 au plus. Rôles** (chef, officiers, membres). **Chat de guilde. Bannière** composée avec des modèles du jeu (pas d'image importée). **[Décidé]**
- **Ressource de guilde** (nom provisoire : **l'Influence**), gagnée par l'activité des membres (duels, étages, routes explorées, sélections comme Écho), par les territoires (revenu quotidien) et par les boss ; dépensée pour **monter des effets** : taille de la guilde, XP des membres en plus, butin en plus (PvE seulement), aides par jour en plus, reforge moins chère, coffre de guilde. Jamais de puissance en PvP. **[Décidé dans le principe ; liste : Proposé]**
- **Classement de guilde** par saison : points de territoires tenus (par jour), guerres gagnées, boss tués, routes explorées. **[Décidé]** Ligues de guilde par taille (petites, moyennes, grandes) pour que les petites se comparent entre elles. **[Proposé]**
- **Les petites guildes doivent s'amuser** **[Décidé]** : récompenses de territoire **par membre** (un territoire rapporte plus à chacun dans une petite guilde) ; régions de la carte à petits territoires et donjons de niveau modeste, où les grandes guildes n'ont rien à gagner ; chaque guilde a un **foyer** imprenable ; un territoire ne peut être attaqué que par une guilde d'au plus le double de sa taille. **[Proposé]**

### 9.2 La carte du monde

- **Une seule carte** : celle où l'on choisit son donjon est celle des territoires. On y voit les donjons (position, niveau), quelle guilde tient quel territoire, et donc quel donjon. **[Décidé]**
- **Tenir un territoire avec un donjon** rapporte : une part de la monnaie payée pour entrer dans ce donjon ; chaque jour, **une route qui ne mène pas au boss** signalée sur la carte de la guilde (la guilde élimine des chemins sans jouer) ; et le prestige. **[Décidé dans le principe ; parts : Proposé, 10 % de l'entrée, 1 route par jour]**
- **Tenir un territoire sans donjon** doit valoir quelque chose **[Décidé]** : chaque territoire a un **type** **[Proposé]** : *Mine* (Influence chaque jour), *Sanctuaire* (un peu d'XP par membre chaque jour), *Marché* (reforge et taxes moins chères pour les membres), *Relais* (une aide d'Écho de plus par jour), *Bastion* (défense plus solide des territoires voisins). Et surtout : **on ne peut attaquer qu'un territoire voisin d'un des siens** : les territoires sans donjon sont le chemin vers ceux qui en ont. Un donjon qui apparaît sur un territoire tenu le fait prospérer d'un coup.
- **Saison** : à chaque saison, la carte redevient vierge (territoires neutres) et le classement de guilde repart. **[Décidé]**

### 9.3 La guerre de guilde **[Proposé, Gautier a demandé de décider]**

- **Chaque soir**, une fenêtre de guerre (trois heures, par fuseau horaire). Une guilde déclare au plus **N attaques** (1 + sa taille ÷ 20) sur des territoires **voisins** de ses territoires, neutres ou tenus.
- **Une bataille se joue en asynchrone** : chaque membre dispose de **3 combats de guerre** par soir, à faire quand il veut dans la fenêtre, contre les trios des défenseurs (leurs personnages pilotés par l'IA, comme des Échos). Les défenseurs font de même contre les attaquants. Le score d'un camp = ses victoires, pondérées par la force de l'adversaire battu.
- **Territoire neutre** : la guilde qui a le meilleur score à la fin de la fenêtre le prend (égalité : la première déclarée).
- **Territoire tenu** : l'attaquant le prend si son score dépasse celui du défenseur multiplié par la défense du territoire (1,2 ; 1,5 avec un Bastion voisin). Un territoire pris est **protégé deux jours**.
- Les membres ne peuvent pas être partout : 3 combats chacun, répartis entre les batailles du soir par les officiers. Une grande guilde attaque large mais défend mince ; une petite se concentre. C'est le frein à la boule de neige.
- Le **foyer** d'une guilde est imprenable. Une guilde sans territoire garde son foyer et peut toujours attaquer un voisin neutre.

### 9.4 Les risques du système de guilde et leurs réponses **[Décidé le 29 octobre au soir]**

- **Personne ne se connecte pendant la guerre** → **la défense est automatique** : les défenseurs sont les personnages de la guilde pilotés par l'IA ; les membres qui jouent *ajoutent* au score. Les attaques sont optionnelles (3 combats par soir, dix minutes).
- **Trop de territoires pour trop peu de guildes** → la carte **grandit et rétrécit avec la population** : des régions s'ouvrent quand des guildes se créent, se ferment quand elles meurent. Jamais de carte fixe.
- **Fuseaux horaires** → un serveur par grande région ; la fenêtre du soir est celle du serveur.
- **Guildes mortes** → un territoire sans aucun combat de guerre pendant 7 jours redevient neutre.
- **Boule de neige, grosses alliances** → attaques limitées par la taille, 3 combats par membre, un même personnage ne défend pas plus de 3 fois par bataille, récompenses par membre, ligues de guilde par taille, remise à zéro chaque saison ; les alliances sont officielles et limitées à deux guildes (pour les boss).
- **Guildes-miroirs** (une grosse guilde divisée pour tripler ses attaques) → pas de parade parfaite ; une guilde de moins de 10 membres actifs ne peut pas attaquer un territoire tenu, et le foyer ne se déplace pas.
- **Échange de victoires** → impossible : les combats de guerre sont contre des IA, on ne peut pas « se laisser battre ».
- **Ceux qui n'aiment pas la guerre** → les donjons, la carte, les Échos de guilde, le chat et les bonus de territoire ne demandent aucun combat de guerre. La guerre est une couche, pas une obligation.
- **Faisabilité** → le combat de guerre est le combat de trio asynchrone ; ce qui coûte, c'est la carte et ses règles. Construit en dernier, testé avec une petite communauté avant d'en faire le cœur du jeu.

## 10. L'équipement et l'économie

### 10.1 L'équipement

- **Même langue que le Destin** : un objet est un paquet de modificateurs ; il n'a de valeur que pour un Destin. **5 emplacements** (Arme, Armure, Anneau, Amulette, Talisman), **4 raretés**, **noms fixes aux lignes et fourchettes connues et affichées**, chiffres tirés à la trouvaille, qualité en %, fourchettes qui grandissent avec le niveau de l'objet. **[Décidé]**
- **Contre la méta** : budget par objet, plafonds par statistique, et la règle du simulateur « en moyenne sur tous les Destins, aucune ligne ne gagne plus qu'une autre ; pour un Destin donné, elles diffèrent beaucoup ». Traits légendaires : un seul par objet, pris dans `docs/MECANIQUES.md`. **[Proposé]**
- **D'où il vient** **[Décidé dans le principe ; détail : Proposé]** :
  - **Les donjons** : le plus puissant (élites : épiques ; boss : légendaires).
  - **La Tour, en solo** : chaque étage lâche un objet de son niveau (commun à rare ; épique aux Gardiens) ; les étages rejoués depuis un palier en lâchent encore, moins souvent. Comme la Tour est infinie, l'équipement de la Tour n'a pas de plafond : un joueur bloqué refait ses étages et s'équipe. **Personne n'est bloqué en équipement parce qu'il ne trouve pas de groupe.**
  - **Le coffre hebdomadaire du PvP**, **les territoires**, **le Marché** (§ 10.2).
- **Lié ou échangeable** : un objet est **échangeable** seulement s'il vient d'un **premier passage** (un étage de la Tour franchi pour la première fois, un Gardien la première fois) ou d'un **donjon** (élite, boss). Tout objet d'un étage rejoué, du coffre PvP ou d'un territoire est **lié** au personnage. Un objet échangeable devient lié dès qu'on l'équipe. **[Décidé]**
- **Reforge** d'une ligne contre des Éclats, coût croissant. **[Décidé]**

### 10.2 L'économie : prix libres, or impossible à fabriquer **[Décidé le 29 octobre au soir]**

Trois volontés de Gautier, compatibles : celui qui a eu la chance d'un grand objet peut le vendre au prix qu'il veut et devenir riche ; aucun bot vendeur d'or, aucun farm automatique pour transférer de l'or à un tricheur ; aucune inflation (pas de monnaie distribuée à tour de bras qui rend tout exorbitant).

- **Deux monnaies.** Les **Éclats**, **liés** (jamais échangeables) : c'est ce que donnent la Tour, les monstres, les duels, les sélections d'Écho, les routes, le revenu passif ; ils paient la reforge, les entrées de donjon, les améliorations de guilde. L'**Or**, **échangeable** : **il ne tombe jamais du contenu**. La seule façon d'avoir de l'or, c'est de **vendre un objet échangeable** (au Marché, à un autre joueur ; ou au Comptoir, au prix plancher fixé par le jeu). Un bot qui farm en boucle gagne des Éclats qu'il ne peut donner à personne, et des objets liés.
- **L'or naît de la chance et meurt à la vente.** Les objets échangeables sont bornés par compte (premiers passages, donjons à trois humains avec entrée en Éclats et vote) ; chaque vente détruit **15 % de taxe** ; les cosmétiques et certains services s'achètent en or. L'or entre lentement, sort à chaque échange : pas de robinet à farmer, donc pas d'inflation. Les objets rares seront chers parce qu'ils sont rares, pas parce que tout le monde est riche.
- **Le Marché** (l'hôtel des ventes) : le vendeur fixe **le prix qu'il veut**, dans une **fourchette autorisée** calculée par le jeu d'après la rareté, le niveau et la qualité du tirage : très large pour un bon légendaire (de 1 à 500 fois son prix plancher), étroite pour un objet quelconque. **Un objet de rien ne peut pas être mis à un prix exorbitant** : c'est ce qui tue le transfert d'or vers un tricheur. Les annonces sont **anonymes** et vont au **premier acheteur** : impossible de réserver une vente à un complice.
- **Aucun autre canal** : pas d'échange direct, pas de don, pas d'envoi d'or, pas de retrait d'or de la banque de guilde (la guilde dépense, les membres ne retirent pas). Le Marché s'ouvre au **niveau 15 et après 7 jours** de compte. Un réseau de bots devrait faire des premiers passages avec des comptes mûrs, dont chaque objet vendu perd 15 % et reste dans sa fourchette : ça ne vaut plus le coup.
- **Le Comptoir** achète tout objet échangeable au prix plancher (c'est le seul « robinet » d'or, borné par la chance) et vend du commun et du rare liés contre des Éclats.
- Le jeu mesure chaque semaine l'or qui entre et qui sort ; si les réserves gonflent, la taxe monte, jamais les fourchettes.

### 10.3 Progression

- **XP** : duels (toujours la plus rapide), étages de la Tour (y compris rejoués), sélection comme Écho, donjons, revenu passif, trois objectifs du jour (bonus). Courbe : 20 à 60 min par niveau au début. **[Décidé ; objectifs du jour : Proposé]**
- **Boutique** : skins de lignée, animations, poses, titres, modèles de bannière. Rien d'autre. **[Décidé]**

## 11. Les écrans et la navigation **[Décidé dans le principe ; détail : Proposé]**

- **Tout en portrait**, toutes les options accessibles en deux touchers au plus. **[Décidé]**
- **La ville** (écran d'accueil) : une carte à la *Shakes & Fidget* avec des **bâtiments**, chacun un lieu du jeu : **la Tour**, **l'Arène** (PvP), **le Donjon** (ouvre la carte du monde), **la Guilde**, **le Comptoir**, **la Forge** (équipement, reforge), **la Maison** (personnage, Destin), **la Boutique** (cosmétiques), **le Tableau** (objectifs du jour, événements du serveur : « le boss des Catacombes est tombé »). La carte est un fichier de données (bâtiments, positions, écran ouvert) pour ajouter un lieu sans toucher au code. **[Décidé]**
- **La carte du monde** : les territoires (couleur de la guilde qui les tient), les donjons (position, niveau, qui le tient), son foyer, les attaques du soir. On y choisit son donjon. **[Décidé]**
- **Le chat** : **général**, **guilde**, **groupe**, dans un volet accessible de partout (une poignée en bas de l'écran). Modération : filtre de mots, signalement, silence par un officier dans la guilde. **[Décidé ; modération : Proposé]**
- **Composer le trio** : un seul écran pour tous les modes : ma case, deux cases à compléter (amis, guilde, proposés), les aides restantes du jour, la fiche de chaque Écho (classe, niveau, comment il joue, nos Synergies). **[Proposé]**
- **Combat** : l'écran actuel (carte du milieu, consigne en gros, Synergies en doré), trois personnages côté joueur, adversaire opaque, icônes d'état, lueur « forte prête » ; au donjon, l'écran de vote des portes entre deux vagues.
- **Premier lancement** : création (classe, Destin dévoilé), premier combat guidé contre des monstres, la ville. Plus d'écran de rencontre.

## 12. Ce qui existe déjà et l'ordre de construction

**Existe (prototype web, 28 octobre)** : moteur pur et testé (168 tests), 10 classes, 63 Synergies, Destin (45 nœuds, mini-Destin), niveaux et XP, Tour à monstres (10 étages, bestiaire), duel en duo contre une IA, simulateur et régleur (en local et sur GitHub Actions), écrans de création, accueil, compétences, Destin, Tour, bestiaire, profil, paramètres.

**Ordre** (chaque bloc doit être amusant seul avant le suivant) :
1. **Le trio avec Échos générés** : composition par rôle, annonces en chaîne, Synergies avec les deux, IA de bon sens et tableau des erreurs, adversaire opaque, écran de composition du trio ; retrait de l'acolyte fixe et de la rencontre ; Soutiens « toujours utiles » et geste de classe ; rééquilibrage (duel 3v3, Tour en trio).
2. **La Tour infinie** : étages générés, paliers, rejouer depuis un palier, sans limite de tours, soins des monstres qui s'affaiblissent, Faveurs, revenu passif ; réglage « à quel niveau on passe tel étage ».
3. **L'équipement** : données, Forge (inventaire, fiche, comparaison, reforge), butin de la Tour (lié / échangeable), Éclats, passe de simulateur sur les lignes.
4. **La ville** et la navigation en portrait, les objectifs du jour.
5. **Serveur et comptes** : vrais Échos, récompenses de sélection, PvP asynchrone classé, chat, Marché et Comptoir (or, fourchettes, taxe, anonymat, seuils de compte), classements, saisons.
6. **Guildes et donjons à routes** : Influence, rôles, bannière, carte du monde, portes sans nom, cartes, fragments, élites, boss unique et ses paliers, coup final de guilde, grimoires, appel.
7. **Territoires et guerres du soir**, classement de guilde, ligues de guilde.
8. **Évolutions de rang 1 et 2, classes de grimoire** (30 + 90 + les grimoires : le plus gros chantier de contenu), PvP synchrone à 6, art, boutique, bêta, lancement.

## 13. Questions encore ouvertes

1. **L'univers et le nom** : à décider ensemble, plus tard (nécessaires pour l'histoire des bannières, des Échos et des boss, et pour les noms des 120 classes).
2. **La guerre de guilde (§ 9.3), les types de territoire (§ 9.2), les ligues par puissance (§ 7)** : décidés par Claude Code à la demande de Gautier, validés dans le principe le 29 octobre au soir (« on adaptera en conséquence »).
3. **Le niveau de la seconde Évolution** (60 ?) et ce qu'il advient du niveau au-delà de 90.
4. **Qui reçoit le grimoire** dans le trio vainqueur : tirage visible, ou une règle (celui qui a exploré le plus, celui qui n'en a pas) ?
