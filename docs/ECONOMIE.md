# L'économie du jeu

Généré par `tools/economie.py` : les règles (depuis `data/marche.json`, `data/comptoir.json`, `data/items.json`, `data/tour.json`) puis une simulation simple de 1000 joueurs honnêtes pendant 12 semaines, et le calcul de ce qu'une ferme de 50 bots peut faire. Ne pas modifier à la main : changer les données ou le modèle, puis relancer l'outil.

## Les règles (GDD V2, § 10.2)

- **Deux monnaies.** Les Éclats, liés, viennent de tout le contenu (Tour, duels, revenu du jour, objectifs) et paient la reforge, l'étal du Comptoir et les entrées de donjon. **L'Or, échangeable, ne tombe jamais du contenu** : il naît seulement au Comptoir, quand on y vend un objet échangeable (un premier passage de la Tour, le boss d'un donjon), au prix plancher fixé par le jeu. Comme les premiers passages sont comptés (1,7 étage par niveau), **l'Or qu'un compte peut créer dans sa vie est borné** : environ 553 Or jusqu'au niveau 30.
- **Le Marché** (l'hôtel des ventes) : le vendeur fixe son prix entre le plancher et le plancher × 2 (commun) / 5 (rare) / 50 (épique) / 500 (légendaire) selon la rareté ; les annonces sont anonymes et vont au premier acheteur ; **chaque vente détruit une taxe** de 15 % (jusqu'à 40 % quand trop d'Or est créé). L'Or qui change de main ne se crée pas : l'acheteur doit l'avoir.
- **La taxe qui monte** : chaque semaine, le jeu lit l'Or créé au Comptoir et l'Or détruit par la taxe la semaine d'avant (tous les joueurs). Si l'Or créé dépasse 4 fois l'Or détruit (et au moins 500 Or), la taxe de la semaine monte de 5 points par cran de 1 dans ce rapport, jusqu'à 40 %. Les fourchettes de prix, elles, ne bougent jamais.
- **Les garde-fous contre les bots et les revendeurs d'Or** : le Marché s'ouvre au niveau 15 et après 7 jours de compte ; 5 annonces en cours au plus ; par jour et par compte, **10 ventes au Comptoir, 5 mises en vente, 10 achats** ; un objet de rien ne peut pas être mis à un prix exorbitant (un commun : 8 Or au plus) ; aucun autre canal : pas de don, pas d'échange direct, pas d'envoi d'Or.

## La simulation des joueurs honnêtes

Un joueur monte d'un niveau par jour ses deux premières semaines, puis d'un tous les trois jours ; chaque niveau ouvre 1,7 étage en premier passage (un objet échangeable chacun) ; les communs et les rares vont au Comptoir, les épiques et les légendaires au Marché (au prix médian de leur fourchette) ; les acheteurs ne peuvent dépenser que l'Or qu'ils ont (la moitié de l'Or en circulation par semaine au plus) ; l'invendu finit au Comptoir. La taxe de chaque semaine se décide sur la semaine d'avant.

| Semaine | Taxe | Or créé (Comptoir) | Or détruit (taxe) | Or échangé entre joueurs | Or en circulation | Niveau moyen |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | 15 % | 166570 | 0 | 0 | 166570 | 4,7 |
| 2 | 40 % | 578503 | 33314 | 83285 | 711759 | 7,9 |
| 3 | 40 % | 135912 | 142352 | 355879 | 705319 | 10,9 |
| 4 | 15 % | 648953 | 52899 | 352659 | 1301373 | 13,9 |
| 5 | 40 % | 120419 | 260275 | 650686 | 1161517 | 16,9 |
| 6 | 15 % | 712388 | 87114 | 580758 | 1786791 | 19,9 |
| 7 | 40 % | 103537 | 357358 | 893395 | 1532970 | 22,9 |
| 8 | 15 % | 820212 | 114973 | 766485 | 2238209 | 25,9 |
| 9 | 35 % | 150496 | 391687 | 1119104 | 1997018 | 28,9 |
| 10 | 15 % | 895311 | 149777 | 998509 | 2742552 | 31,9 |
| 11 | 25 % | 140714 | 342819 | 1371276 | 2540447 | 34,9 |
| 12 | 15 % | 982372 | 190534 | 1270223 | 3332285 | 37,9 |

## La ferme de bots et le revendeur d'Or

- Un compte bot monte de deux niveaux par jour jusqu'au niveau 30 (15 jours) et vend tous ses premiers passages au Comptoir : **553 Or dans sa vie**, puis plus rien (il n'a plus de premier passage ; les étages rejoués ne donnent que des objets liés). Une ferme de 50 bots qui fait tourner ses comptes crée donc environ **12899 Or par semaine**.
- Pour livrer cet Or à un client, le client met un objet à lui en vente au prix le plus haut de sa fourchette et un compte de la ferme l'achète (il faut à ce compte le niveau 15 et 7 jours) : la taxe de 15 % est détruite au passage. Un commun livre 6 Or au plus, un épique 1700, un légendaire 68000 : **pour livrer 10 000 Or, il faut 21,3 comptes bots amenés au niveau 30, et le client doit posséder un légendaire ou cinq épiques échangeables** ; 1765 Or partent en taxe.
- L'Or en circulation après 12 semaines : 3332285 pour 1000 joueurs (3332,3 par joueur) ; la taxe de la dernière semaine : 15 % (elle monte quand les joueurs créent beaucoup plus d'Or qu'ils n'en échangent).
- Dans ce modèle, la taxe oscille d'une semaine à l'autre (les joueurs montent de niveau par à-coups, et l'Or créé avec eux) : la règle lit une seule semaine ; si le vrai jeu fait pareil, lisser sur deux ou trois semaines (à régler à la fin).
- Ces chiffres sont ceux du modèle, pas du jeu joué : ils disent l'ordre de grandeur et le sens des garde-fous. Le réglage fin vient à la fin, avec le vrai serveur et de vrais joueurs.

