# Les scénarios d'économie

Généré par `tools/scenarios_economie.py` (la moyenne des graines 1, 2, 3) : 3000 comptes au départ, 15 nouveaux par jour, 180 jours ; une ferme de 300 comptes bots ; les chiffres du jeu relus dans `data/` (prix plancher du Comptoir, fourchettes du Marché, taxe, amélioration, butin de la Tour, donjons, potions). Ne pas modifier à la main : changer le modèle ou les données, puis relancer l'outil. Le sens et la recommandation sont dans `docs/VISION.md` § 8.

## Le modèle

- **Les comptes** : trois sortes de joueurs (occasionnel : joue 4 jours sur 10, 3 combats ; régulier : 3 jours sur 4, 8 combats ; assidu : presque chaque jour, 18 combats), qui partent un jour (1,2 %, 0,5 %, 0,2 % de chance par jour) ; des nouveaux chaque jour. Le niveau monte avec les combats (le niveau 30 vers 200 combats : un à deux mois pour un régulier ; puis quarante combats par niveau). 2 % des réguliers et des assidus sont prêts à acheter de l'Or à un revendeur.
- **La Tour** : jusqu'à trois étages neufs par jour (premier passage : un objet échangeable sept fois sur dix, du commun ou du peu commun ; peu commun au Gardien, rare possible au grand Gardien), puis des étages rejoués (des objets liés, recyclés en Éclats). **Les donjons** : quatre combats par descente, l'entrée en Éclats, un épique à l'élite (échangeable une fois sur quatre, lié sinon), un légendaire échangeable au boss (une descente sur trente).
- **L'équipement** : huit emplacements ; un joueur porte ce qui vaut mieux que son pire emplacement (l'objet est alors lié) et vend le reste ; il n'achète que mieux que son pire emplacement. Quand il change de tranche de niveau, tout est à refaire.
- **L'hôtel des ventes** : les communs et les peu communs vont au Comptoir (le prix plancher du jeu : c'est là que l'Or naît) ; les rares, les épiques et les légendaires sont mis en vente. Pour chaque tranche de niveau et chaque rareté, un prix courant : il monte de 10 % au plus par jour quand les acheteurs sont plus nombreux que les annonces, baisse sinon, dans la fourchette du jeu quand elle existe. Un joueur achète au plus un objet par jour, le meilleur de sa tranche qu'il peut se payer (un occasionnel y met la moitié de son Or, un assidu les quatre cinquièmes). L'invendu de plus de sept jours part au Comptoir. Quand un joueur change de tranche, ses objets ne lui servent plus et il rachète.
- **L'objet que tout le monde veut** (une tenue rare, un objet de remise à zéro du Destin) : il tombe une fois tous les cent cinquante combats, à tout niveau ; chacun en veut un par semaine. Vendu entre joueurs (A à E) ou par le jeu (F, G : la trouvaille vaut des Éclats). C'est lui que les vétérans rendent inabordable dans les RPG classiques.
- **Les puits** : l'amélioration +1 à +10 (les chiffres de `items.json` ; un échec fait perdre un cran ; tentée dès que l'Or dépasse une marge sur le coût), les potions d'énergie des assidus, des cosmétiques en Or (une tenue quand on a quatre fois son prix, tous les quinze jours au plus), la taxe du Marché.
- **La ferme de bots** : des comptes qui jouent 60 combats par jour, moins bien que l'IA (ils montent à 60 % de la vitesse), vendent tout ce qu'ils peuvent, et sont remplacés au niveau 30 quand il n'y a plus de premier passage à vendre. Leur monnaie (de l'Or, ou des Éclats en E) est livrée chaque semaine aux clients : par échange direct en RPG classique ; sinon par une annonce du client au plus haut de sa fourchette, achetée par la ferme (la taxe est détruite ; un client ne peut pas recevoir plus que ses annonces ne permettent, ni dépasser son plafond). Un compte bot coûte 0,05 € par jour au revendeur : son prix de revient se lit sur ce que ses comptes produisent (ce qu'il livre est borné par ce que les clients veulent).

## Les scénarios

- **A. RPG classique** : l'Or tombe des monstres à chaque combat, tout objet se vend au marchand, prix libres à l'hôtel des ventes, taxe fixe de 5 %, aucun plafond.
- **B. Le jeu d'aujourd'hui (PR #83 et #92)** : l'Or ne naît qu'au Comptoir (objets de premier passage), fourchettes de prix, taxe de 15 % qui monte jusqu'à 40 %, amélioration en Or.
- **C. La proposition § 8** : B + le Comptoir paie moins quand l'Or abonde (et plus quand il manque), des cosmétiques en Or, l'adresse mail confirmée pour vendre (cinq fois moins de bots).
- **D. § 8 + l'Or plafonné** : C + un compte ne peut pas détenir plus de 20 Or par niveau (l'excédent devient des Éclats).
- **E. Les Éclats comme monnaie du Marché** : pas d'Or : le Marché se paie en Éclats (ceux du PvE, imprimés à chaque combat), avec les fourchettes et la taxe ; l'acheteur détruit, le vendeur reçoit ; le revendeur vend donc des Éclats.
- **F. L'Or lent (recommandé)** : D, plus : ce que tout le monde veut est vendu par le jeu, jamais entre joueurs ; la fourchette des légendaires serrée (× 50 au lieu de × 500) ; la taxe lue sur trois semaines.
- **G. F + une source d'Or quotidienne** : F, plus un objet lié racheté chaque jour par le Comptoir (une petite source d'Or bornée par jour et par compte, pour voir ce que les bots en font).
- **H. F, l'amélioration en Éclats** : F mais l'amélioration +1 à +10 se paie en Éclats (liés) : l'Or n'achète plus que des objets et des tenues.

## Le tableau comparé (au jour 180)

| Mesure | A | B | C | D | E | F | G | H |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Comptes actifs (niveau médian) | 1623 (47,3) | 1654 (46,7) | 1658 (46,7) | 1626 (46,7) | 1632 (46,7) | 1633 (47,7) | 1620 (47,7) | 1649 (46) |
| Monnaie par joueur actif | 16381 Or | 193 Or | 230 Or | 223 Or | 1088 Éclats | 237 Or | 272 Or | 395 Or |
| Monnaie médiane : vétérans (90 j et plus) / débutants (14 j au plus) | 1812 / 169 | 240 / 7 | 281 / 9 | 278 / 9 | 1221 / 235 | 263 / 8 | 297 / 17 | 340 / 6 |
| Indice de Gini de la monnaie (0 = égal, 1 = un seul riche) | 0,82 | 0,45 | 0,45 | 0,45 | 0,43 | 0,53 | 0,49 | 0,56 |
| Prix d'un rare de niveau 11–20 | 363 Or | 23 Or | 26 Or | 30 Or | 171 Éclats | 20 Or | 34 Or | 19 Or |
| … en jours de jeu d'un régulier de ce niveau | 2,4 j | 2,8 j | 2,5 j | 3,3 j | 1,9 j | 5,2 j | 6 j | 8,7 j |
| Prix d'un épique de niveau 21–30 | 28 Or | 28 Or | 28 Or | 28 Or | 139 Éclats | 28 Or | 28 Or | 28 Or |
| … en jours de jeu d'un régulier de ce niveau | 0,1 j | 2,1 j | 2,1 j | 3,2 j | 4 j | 5,7 j | 3,2 j | 8,8 j |
| Prix d'un légendaire de niveau 21–30 | 3109 Or | 236 Or | 324 Or | 249 Or | 1259 Éclats | 111 Or | 126 Or | 111 Or |
| … en jours de jeu d'un régulier de ce niveau | 10,5 j | 17,3 j | 24,6 j | 27,2 j | 35,4 j | 22,9 j | 14,6 j | 35,3 j |
| Prix de l'objet que tout le monde veut (tenue rare) | 1944 Or | 305 Or | 371 Or | 358 Or | 1714 Éclats | vendu par le jeu | vendu par le jeu | vendu par le jeu |
| … en jours de jeu d'un régulier de niveau 11–20 | 12,9 j | 37,6 j | 35,5 j | 39,7 j | 19,3 j | sans objet | sans objet | sans objet |
| Hausse des prix sur les trois derniers mois (légendaire 21–30) | +1 % | +52 % | +71 % | +11 % | +35 % | +0 % | -2 % | +0 % |
| Hausse de la monnaie par joueur actif sur trois mois | +131 % | +44 % | +35 % | +32 % | +35 % | +34 % | +31 % | +7 % |
| Part des annonces vendues (quatre dernières semaines) | 23 % | 14 % | 15 % | 15 % | 17 % | 9 % | 11 % | 9 % |
| Taxe de la semaine / facteur du Comptoir / facteur des puits | 5 % / × 1 / × 1 | 15 % / × 1 / × 1 | 15 % / × 1,25 / × 1 | 15 % / × 1,26 / × 1 | 15 % / × 1 / × 1 | 15 % / × 1,2 / × 1 | 15 % / × 1,07 / × 1 | 15 % / × 0,7 / × 1 |
| Monnaie créée / détruite la dernière semaine | 8847366 / 6155515 | 200935 / 175225 | 237501 / 214017 | 234261 / 214862 | 920915 / 988456 | 231946 / 211386 | 284981 / 252788 | 135658 / 107529 |
| Monnaie livrée par le revendeur la dernière semaine | 34289 Or | 3470 Or | 2713 Or | 2725 Or | 15578 Éclats | 2625 Or | 3124 Or | 1517 Or |
| Monnaie produite par compte bot et par jour | 5386,6 Or | 6,4 Or | 8,6 Or | 8,6 Or | 557,3 Éclats | 8,4 Or | 13,5 Or | 5,5 Or |
| Prix de revient de 1 000 unités pour le revendeur | 0,01 € | 7,81 € | 29,13 € | 29,01 € | 0,45 € | 29,69 € | 18,51 € | 45,48 € |
| Ce que 5 € achetés au revendeur valent, en jours de jeu d'un régulier de niveau 21–30 | 5 ans | 47,3 j | 13,2 j | 19,7 j | 10,6 mois | 34,7 j | 31,3 j | 34,9 j |
| Monnaie médiane des clients du revendeur / des honnêtes (réguliers et assidus) | × 1,2 | × 1,2 | × 1 | × 0,9 | × 1,5 | × 1,2 | × 1,9 | × 1,4 |
| Part des achats du Marché faits par des clients du revendeur | 2,2 % | 3,2 % | 2,6 % | 2,8 % | 3,3 % | 2 % | 2 % | 3 % |
| Crans d'amélioration (médiane) : clients du revendeur / honnêtes | 10 / 9 | 6 / 5 | 6 / 5 | 6 / 5 | 6 / 5 | 5 / 5 | 6 / 5 | 3 / 2 |

## A. RPG classique

| Jour | Actifs | Niveau médian | Or par actif | Vétérans / débutants | Gini | Rare 11–20 | Légendaire 21–30 | Tenue rare | Annonces vendues | Taxe | Comptoir × | Puits × | Or livré / sem. |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 30 | 1721 | 27,7 | 1548 | 0 / 125 | 0,7 | 7 (0,1 j) | 1835 (7,1 j) | 281 (2,3 j) | 33 % | 5 % | 1 | 1 | 43872 |
| 60 | 1673 | 33 | 3085 | 0 / 134 | 0,73 | 19 (0,1 j) | 2142 (8 j) | 1277 (10,1 j) | 25 % | 5 % | 1 | 1 | 590836 |
| 90 | 1659 | 37 | 7103 | 1112 / 172 | 0,82 | 308 (2,1 j) | 3193 (10,6 j) | 1688 (11,7 j) | 20 % | 5 % | 1 | 1 | 552297 |
| 120 | 1652 | 41,7 | 9767 | 1222 / 122 | 0,86 | 370 (2,6 j) | 4150 (12,5 j) | 1808 (13 j) | 21 % | 5 % | 1 | 1 | 76444 |
| 150 | 1636 | 45 | 12905 | 1552 / 137 | 0,84 | 339 (2,3 j) | 3020 (10,5 j) | 1954 (12,9 j) | 23 % | 5 % | 1 | 1 | 22311 |
| 180 | 1623 | 47,3 | 16381 | 1812 / 169 | 0,82 | 363 (2,4 j) | 3109 (10,5 j) | 1944 (12,9 j) | 23 % | 5 % | 1 | 1 | 34289 |

## B. Le jeu d'aujourd'hui (PR #83 et #92)

| Jour | Actifs | Niveau médian | Or par actif | Vétérans / débutants | Gini | Rare 11–20 | Légendaire 21–30 | Tenue rare | Annonces vendues | Taxe | Comptoir × | Puits × | Or livré / sem. |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 30 | 1702 | 27,3 | 46 | 0 / 10 | 0,44 | 15 (3,1 j) | 125 (23,2 j) | 68 (14,1 j) | 25 % | 15 % | 1 | 1 | 5722 |
| 60 | 1664 | 33 | 87 | 0 / 9 | 0,45 | 33 (5,8 j) | 111 (18,5 j) | 144 (24,9 j) | 18 % | 15 % | 1 | 1 | 10826 |
| 90 | 1657 | 37 | 134 | 162 / 10 | 0,44 | 22 (3,3 j) | 156 (24,3 j) | 213 (32,3 j) | 11 % | 15 % | 1 | 1 | 7390 |
| 120 | 1630 | 41 | 163 | 209 / 8 | 0,45 | 22 (2,7 j) | 199 (22,8 j) | 245 (29,7 j) | 12 % | 15 % | 1 | 1 | 4191 |
| 150 | 1614 | 45,3 | 184 | 231 / 9 | 0,44 | 23 (3,5 j) | 230 (27,1 j) | 277 (43,1 j) | 14 % | 15 % | 1 | 1 | 3828 |
| 180 | 1654 | 46,7 | 193 | 240 / 7 | 0,45 | 23 (2,8 j) | 236 (17,3 j) | 305 (37,6 j) | 14 % | 15 % | 1 | 1 | 3470 |

## C. La proposition § 8

| Jour | Actifs | Niveau médian | Or par actif | Vétérans / débutants | Gini | Rare 11–20 | Légendaire 21–30 | Tenue rare | Annonces vendues | Taxe | Comptoir × | Puits × | Or livré / sem. |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 30 | 1730 | 27,7 | 55 | 0 / 10 | 0,44 | 18 (3 j) | 125 (17,6 j) | 78 (12,8 j) | 27 % | 15 % | 1,47 | 1 | 3203 |
| 60 | 1682 | 33 | 109 | 0 / 12 | 0,45 | 34 (4,2 j) | 119 (12,2 j) | 175 (21,4 j) | 20 % | 15 % | 1,5 | 1 | 3409 |
| 90 | 1659 | 37,3 | 170 | 206 / 10 | 0,45 | 34 (6,2 j) | 191 (18,6 j) | 271 (50 j) | 12 % | 15 % | 1,41 | 1 | 3315 |
| 120 | 1657 | 41,7 | 197 | 253 / 10 | 0,45 | 24 (2,5 j) | 200 (22,3 j) | 302 (30,6 j) | 13 % | 15 % | 1,27 | 1 | 2990 |
| 150 | 1659 | 45 | 218 | 276 / 11 | 0,45 | 23 (2,7 j) | 225 (20,5 j) | 331 (39,1 j) | 14 % | 15 % | 1,25 | 1 | 2756 |
| 180 | 1658 | 46,7 | 230 | 281 / 9 | 0,45 | 26 (2,5 j) | 324 (24,6 j) | 371 (35,5 j) | 15 % | 15 % | 1,25 | 1 | 2713 |

## D. § 8 + l'Or plafonné

| Jour | Actifs | Niveau médian | Or par actif | Vétérans / débutants | Gini | Rare 11–20 | Légendaire 21–30 | Tenue rare | Annonces vendues | Taxe | Comptoir × | Puits × | Or livré / sem. |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 30 | 1727 | 28 | 55 | 0 / 11 | 0,44 | 19 (2,9 j) | 122 (17 j) | 78 (12,5 j) | 27 % | 15 % | 1,47 | 1 | 3193 |
| 60 | 1681 | 33 | 108 | 0 / 9 | 0,44 | 34 (4,7 j) | 130 (14,8 j) | 177 (25 j) | 20 % | 15 % | 1,5 | 1 | 3365 |
| 90 | 1632 | 37 | 168 | 205 / 11 | 0,45 | 28 (2,6 j) | 223 (20,7 j) | 265 (25,2 j) | 12 % | 15 % | 1,43 | 1 | 3367 |
| 120 | 1621 | 41 | 201 | 258 / 11 | 0,46 | 26 (2,4 j) | 242 (23,3 j) | 307 (28,6 j) | 13 % | 15 % | 1,25 | 1 | 2987 |
| 150 | 1615 | 44,7 | 218 | 275 / 11 | 0,45 | 22 (2 j) | 194 (19,1 j) | 311 (27 j) | 14 % | 15 % | 1,25 | 1 | 2829 |
| 180 | 1626 | 46,7 | 223 | 278 / 9 | 0,45 | 30 (3,3 j) | 249 (27,2 j) | 358 (39,7 j) | 15 % | 15 % | 1,26 | 1 | 2725 |

## E. Les Éclats comme monnaie du Marché

| Jour | Actifs | Niveau médian | Éclats par actif | Vétérans / débutants | Gini | Rare 11–20 | Légendaire 21–30 | Tenue rare | Annonces vendues | Taxe | Comptoir × | Puits × | Or livré / sem. |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 30 | 1716 | 27,7 | 452 | 0 / 197 | 0,3 | 34 (0,4 j) | 716 (19,8 j) | 627 (6,6 j) | 40 % | 15 % | 1 | 1 | 21803 |
| 60 | 1670 | 33 | 597 | 0 / 216 | 0,35 | 171 (1,9 j) | 828 (22 j) | 841 (9,2 j) | 21 % | 15 % | 1 | 1 | 88280 |
| 90 | 1657 | 37 | 809 | 874 / 225 | 0,38 | 171 (1,9 j) | 943 (23,3 j) | 1219 (13,5 j) | 15 % | 15 % | 1 | 1 | 52587 |
| 120 | 1638 | 41 | 955 | 1104 / 207 | 0,4 | 171 (1,8 j) | 1146 (31 j) | 1420 (14,9 j) | 16 % | 15 % | 1 | 1 | 27114 |
| 150 | 1610 | 44,7 | 1041 | 1192 / 215 | 0,41 | 171 (1,9 j) | 1367 (36,3 j) | 1542 (16,9 j) | 17 % | 15 % | 1 | 1 | 24228 |
| 180 | 1632 | 46,7 | 1088 | 1221 / 235 | 0,43 | 171 (1,9 j) | 1259 (35,4 j) | 1714 (19,3 j) | 17 % | 15 % | 1 | 1 | 15578 |

## F. L'Or lent (recommandé)

| Jour | Actifs | Niveau médian | Or par actif | Vétérans / débutants | Gini | Rare 11–20 | Légendaire 21–30 | Tenue rare | Annonces vendues | Taxe | Comptoir × | Puits × | Or livré / sem. |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 30 | 1728 | 28 | 56 | 0 / 10 | 0,45 | 18 (4,1 j) | 161 (24,2 j) | par le jeu | 18 % | 15 % | 1,47 | 1 | 3417 |
| 60 | 1651 | 33 | 113 | 0 / 14 | 0,48 | 25 (5,7 j) | 111 (20,3 j) | par le jeu | 14 % | 15 % | 1,5 | 1 | 3438 |
| 90 | 1639 | 37,2 | 178 | 212 / 12 | 0,48 | 24 (5 j) | 111 (20,8 j) | par le jeu | 5 % | 15 % | 1,38 | 1 | 3271 |
| 120 | 1639 | 41 | 204 | 253 / 9 | 0,5 | 20 (4,9 j) | 115 (21,9 j) | par le jeu | 6 % | 15 % | 1,21 | 1 | 2970 |
| 150 | 1636 | 44,7 | 226 | 279 / 8 | 0,5 | 19 (4,9 j) | 111 (23 j) | par le jeu | 8 % | 15 % | 1,2 | 1 | 2665 |
| 180 | 1633 | 47,7 | 237 | 263 / 8 | 0,53 | 20 (5,2 j) | 111 (22,9 j) | par le jeu | 9 % | 15 % | 1,2 | 1 | 2625 |

## G. F + une source d'Or quotidienne

| Jour | Actifs | Niveau médian | Or par actif | Vétérans / débutants | Gini | Rare 11–20 | Légendaire 21–30 | Tenue rare | Annonces vendues | Taxe | Comptoir × | Puits × | Or livré / sem. |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 30 | 1713 | 27,3 | 78 | 0 / 18 | 0,38 | 23 (2,7 j) | 182 (17,2 j) | par le jeu | 32 % | 15 % | 1,47 | 1 | 6035 |
| 60 | 1682 | 33 | 153 | 0 / 20 | 0,4 | 34 (4,8 j) | 151 (12,9 j) | par le jeu | 17 % | 15 % | 1,46 | 1 | 5898 |
| 90 | 1640 | 37 | 208 | 241 / 18 | 0,45 | 34 (4,8 j) | 130 (11,5 j) | par le jeu | 9 % | 15 % | 1,14 | 1 | 4747 |
| 120 | 1648 | 41,3 | 236 | 297 / 18 | 0,47 | 34 (6,3 j) | 126 (11,8 j) | par le jeu | 10 % | 15 % | 1,06 | 1 | 4309 |
| 150 | 1648 | 45,3 | 249 | 299 / 13 | 0,48 | 34 (5,7 j) | 115 (14,9 j) | par le jeu | 11 % | 15 % | 1,07 | 1 | 4051 |
| 180 | 1620 | 47,7 | 272 | 297 / 17 | 0,49 | 34 (6 j) | 126 (14,6 j) | par le jeu | 11 % | 15 % | 1,07 | 1 | 3124 |

## H. F, l'amélioration en Éclats

| Jour | Actifs | Niveau médian | Or par actif | Vétérans / débutants | Gini | Rare 11–20 | Légendaire 21–30 | Tenue rare | Annonces vendues | Taxe | Comptoir × | Puits × | Or livré / sem. |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 30 | 1722 | 27,3 | 118 | 0 / 13 | 0,58 | 19 (4,1 j) | 196 (32,9 j) | par le jeu | 30 % | 20 % | 1,47 | 1 | 3248 |
| 60 | 1682 | 33 | 299 | 0 / 8 | 0,58 | 25 (8,8 j) | 119 (32,6 j) | par le jeu | 18 % | 15 % | 0,82 | 1 | 2152 |
| 90 | 1651 | 37 | 369 | 441 / 6 | 0,53 | 21 (10,4 j) | 111 (37,7 j) | par le jeu | 6 % | 15 % | 0,68 | 1 | 1554 |
| 120 | 1640 | 41 | 389 | 522 / 6 | 0,51 | 18 (7,5 j) | 111 (35,7 j) | par le jeu | 6 % | 15 % | 0,67 | 1 | 1586 |
| 150 | 1647 | 45 | 393 | 429 / 8 | 0,53 | 17 (8,8 j) | 113 (37 j) | par le jeu | 7 % | 15 % | 0,68 | 1 | 1470 |
| 180 | 1649 | 46 | 395 | 340 / 6 | 0,56 | 19 (8,7 j) | 111 (35,3 j) | par le jeu | 9 % | 15 % | 0,7 | 1 | 1517 |

