# Les objets du jeu

Généré par `tools/catalogue_objets.py` depuis `data/items.json` (et les données du butin) : ne pas modifier à la main, modifier les données puis relancer l'outil. Les noms sont de fantasy classique en attendant l'univers (décision de Gautier du 29 octobre).

## Comment un objet est fait

Un objet, c'est **une base** (ce qu'il est : une Épée, une Robe…), **un palier de niveau** (son matériau), **une rareté** et **ses lignes** : des bonus en %, tirés à la trouvaille dans la réserve de sa base. Il n'a de valeur que pour un Destin : ses lignes s'ajoutent aux éclats de la roue. Huit emplacements, un objet porté par emplacement.

- **Les raretés** : commun (1 ligne, fourchettes × 1) ; peu commun (2 lignes, fourchettes × 1) ; rare (2 lignes, fourchettes × 1,2) ; épique (3 lignes, fourchettes × 1,4) ; légendaire (4 lignes, fourchettes × 1,5).
- **Le niveau** : les fourchettes valent 50 % de leur pleine valeur au niveau 1, 100 % au niveau 30 et au-delà.
- **La qualité** (0 à 100 %) dit où les chiffres sont tombés dans leurs fourchettes.
- **Lié ou échangeable** : échangeable seulement s'il vient d'un premier passage (Tour) ou d'un boss de donjon ; lié dès qu'on l'équipe, et pour toujours.
- **La reforge** : une ligne retirée contre 20 Éclats, +100 % par reforge déjà faite. **Le recyclage** rend 5 (commun) / 10 (peu commun) / 15 (rare) / 40 (épique) / 100 (légendaire) Éclats.
- **L'amélioration +1 à +10** (décision de Gautier du 1er novembre) : payée en Or, et cet Or est détruit (réussite ou échec). Chaque cran ajoute 5 % aux lignes de l'objet (+50 % à +10). Le cran suivant coûte 5 Or × le rang de la rareté (1 commun / 2 peu commun / 3 rare / 4 épique / 5 légendaire) × l'échelle du niveau, puis × 1,6 par cran déjà pris. Les chances de réussite, cran par cran : 100 %, 90 %, 80 %, 70 %, 60 %, 50 %, 40 %, 35 %, 30 %, 25 %. **Un échec fait perdre un cran** (de +3, on retombe à +2). La reforge et l'équipement gardent le cran ; le nom le porte (« Épée d'acier épique +4 »). C'est le seul hasard du jeu hors combat avec la création.

Le coût de chaque cran pour un objet du niveau 30 (en Or) :

| Cran | commun | peu commun | rare | épique | légendaire |
| --- | --- | --- | --- | --- | --- |
| +1 | 5 | 10 | 15 | 20 | 25 |
| +2 | 8 | 16 | 24 | 32 | 40 |
| +3 | 13 | 26 | 38 | 51 | 64 |
| +4 | 20 | 41 | 61 | 82 | 102 |
| +5 | 33 | 66 | 98 | 131 | 164 |
| +6 | 52 | 105 | 157 | 210 | 262 |
| +7 | 84 | 168 | 252 | 336 | 419 |
| +8 | 134 | 268 | 403 | 537 | 671 |
| +9 | 215 | 429 | 644 | 859 | 1074 |
| +10 | 344 | 687 | 1031 | 1374 | 1718 |
| total | 908 | 1816 | 2723 | 3632 | 4539 |

## Les huit lignes

| Ligne | Ce qu'elle fait | Fourchette (commun, niveau 30) | Plafond sur le total porté |
| --- | --- | --- | --- |
| PV max | +X % de PV max | 2 – 4 % | 25 % |
| Force | +X % de force (toutes les valeurs) | 1,2 – 2,5 % | 15 % |
| Dégâts | +X % de dégâts directs | 2 – 4 % | 25 % |
| Soins | +X % de soins et de Gardiens | 2 – 4 % | 25 % |
| Barrières | +X % de barrières | 2,5 – 5 % | 30 % |
| Poisons et brûlures | +X % de dégâts sur la durée | 2,5 – 5 % | 30 % |
| Clés | +X % sur les Clés | 2,5 – 5 % | 30 % |
| Ouvertures | +X % sur le moyeu et les ouvertures | 2,5 – 5 % | 30 % |

## Les paliers de niveau (le matériau du nom)

| Dès le niveau | Suffixe | Exemple |
| --- | --- | --- |
| 1 | de fer | Épée de fer rare |
| 10 | d'acier | Épée d'acier rare |
| 20 | d'argent | Épée d'argent rare |
| 30 | de mithril | Épée de mithril rare |
| 40 | runique | Épée runique rare |
| 50 | de dragon | Épée de dragon rare |

## Les quarante-huit bases, par emplacement

Chaque base a une réserve de quatre lignes possibles ; un objet tire ses lignes dedans (autant que sa rareté en donne, toutes différentes). Chaque ligne est dans vingt-quatre réserves : aucune n'est plus rare qu'une autre.

### Arme

| Base | Lignes possibles | Description |
| --- | --- | --- |
| **Épée** | Dégâts, Force, Clés, Ouvertures | La lame droite du soldat : des coups francs, et la main sûre pour ouvrir le combat. |
| **Bâton** | Soins, Force, Poisons et brûlures, Clés | Un bois noueux qui porte les soins et le feu lent ; il garde la Clé au chaud. |
| **Arc** | Dégâts, Poisons et brûlures, Ouvertures, Clés | Le trait part de loin, revient souvent, et finit sa proie. |
| **Dague** | Dégâts, Poisons et brûlures, Ouvertures, Force | Courte et vicieuse : le poison, le premier coup, la main vive. |
| **Hache** | Dégâts, Force, Poisons et brûlures, Barrières | Large et lourde : elle tranche, elle saigne, et le bras tient le choc. |
| **Marteau** | PV max, Dégâts, Barrières, Clés | Le poids d'une enclume : encaisser, écraser, et finir par la Clé. |

### Casque

| Base | Lignes possibles | Description |
| --- | --- | --- |
| **Casque** | PV max, Barrières, Force, Ouvertures | Un bol de fer sur la tête : la vie, la garde, la force, l'ouverture. |
| **Heaume** | PV max, Barrières, Dégâts, Clés | Fermé, lourd, sans visage : on encaisse, on garde, on frappe, on finit. |
| **Capuche** | Poisons et brûlures, Ouvertures, Dégâts, Soins | De l'ombre sur les yeux : le venin, le premier coup, la frappe, un peu de soin. |
| **Couronne** | Clés, Force, Soins, PV max | Un cercle d'or qui commande : la Clé, la force, les soins, la vie. |
| **Diadème** | Soins, Barrières, Clés, Ouvertures | Un fin bandeau serti : les soins, les barrières, la Clé, l'ouverture. |
| **Bandeau** | Ouvertures, Poisons et brûlures, Force, Dégâts | Une bande de toile nouée : l'ouverture vive, le venin, la force, le coup. |

### Armure

| Base | Lignes possibles | Description |
| --- | --- | --- |
| **Cotte de mailles** | PV max, Barrières, Force, Ouvertures | Des anneaux de métal tissés : on encaisse, on tient, on repart. |
| **Robe** | PV max, Soins, Barrières, Clés | Du tissu brodé de signes : les soins et les barrières y sont plus grands. |
| **Armure de cuir** | PV max, Dégâts, Poisons et brûlures, Ouvertures | Souple et silencieuse : pour frapper fort sans peser. |
| **Armure de plates** | PV max, Barrières, Soins, Ouvertures | Des plaques d'acier : rien ne passe, et le porteur dure. |
| **Tunique** | Soins, Poisons et brûlures, Ouvertures, Force | Légère, propre aux soigneurs qui bougent : soins, venins, ouverture vive. |
| **Brigandine** | PV max, Dégâts, Force, Clés | Des plaques cousues sous le cuir : solide, et faite pour frapper. |

### Cape

| Base | Lignes possibles | Description |
| --- | --- | --- |
| **Cape** | Poisons et brûlures, Dégâts, Barrières, Clés | Un pan d'ombre sur les épaules : les poisons, la frappe, la barrière. |
| **Manteau** | PV max, Soins, Barrières, Force | Long et lourd, doublé de laine : la vie, les soins, la barrière, la force. |
| **Pèlerine** | Soins, Ouvertures, Poisons et brûlures, PV max | Courte, pour la route : les soins, l'ouverture, le venin, la vie. |
| **Houppelande** | Clés, Barrières, Soins, Dégâts | Ample, aux manches immenses : la Clé, la barrière, les soins, la frappe. |
| **Mantelet** | Dégâts, Ouvertures, Force, Poisons et brûlures | Un pan court sur une épaule : la frappe, l'ouverture, la force, le venin. |
| **Voile** | Poisons et brûlures, Soins, Clés, Barrières | Léger comme un souffle : le venin, les soins, la Clé, la barrière. |

### Bottes

| Base | Lignes possibles | Description |
| --- | --- | --- |
| **Bottes** | Ouvertures, PV max, Force, Dégâts | Du cuir jusqu'au genou : l'ouverture, la vie, la force, le coup. |
| **Sandales** | Soins, Ouvertures, Poisons et brûlures, Barrières | Des lanières et une semelle : les soins, l'ouverture, le venin, la barrière. |
| **Sabots** | PV max, Barrières, Force, Poisons et brûlures | Du bois plein : la vie, la garde, la force, et le venin qu'on écrase. |
| **Brodequins** | Dégâts, Clés, Ouvertures, Poisons et brûlures | Lacés serré, pour courir : la frappe, la Clé, l'ouverture, le venin. |
| **Souliers** | Soins, Clés, Poisons et brûlures, Ouvertures | Fins et souples : les soins, la Clé, le venin, l'ouverture. |
| **Cuissardes** | PV max, Dégâts, Barrières, Clés | Hautes et épaisses : la vie, la frappe, la barrière, la Clé. |

### Ceinture

| Base | Lignes possibles | Description |
| --- | --- | --- |
| **Ceinture** | Force, PV max, Dégâts, Soins | Du cuir et une boucle : la force, la vie, le coup, un peu de soin. |
| **Ceinturon** | Soins, Force, Barrières, Clés | Large, à poches : les soins, la force, la barrière, la Clé. |
| **Baudrier** | Dégâts, Clés, Poisons et brûlures, Force | En travers de la poitrine, pour l'arme : la frappe, la Clé, le venin, la force. |
| **Écharpe** | Soins, Poisons et brûlures, Barrières, Ouvertures | De la soie nouée à la taille : les soins, le venin, la barrière, l'ouverture. |
| **Cordelière** | Soins, Clés, Ouvertures, Poisons et brûlures | Une corde à nœuds : les soins, la Clé, l'ouverture, le venin. |
| **Chaîne** | Barrières, Force, PV max, Poisons et brûlures | Des maillons lourds : la barrière, la force, la vie, le venin. |

### Anneau

| Base | Lignes possibles | Description |
| --- | --- | --- |
| **Anneau** | Force, Clés, PV max, Dégâts | Un cercle simple ; sa force va partout. |
| **Sceau** | Soins, Barrières, PV max, Ouvertures | Une bague gravée d'un serment : protéger et soigner. |
| **Chevalière** | PV max, Ouvertures, Barrières, Dégâts | Le blason d'une maison : la vie, l'ouverture, la garde, le coup. |
| **Alliance** | Soins, Barrières, Ouvertures, Force | Un cercle d'or uni : soins et barrières pour les siens. |
| **Bague** | Poisons et brûlures, Clés, Dégâts, Soins | Une pierre sombre : venins, Clé, coups, et un peu de soin. |
| **Boucle** | Ouvertures, Clés, PV max, Force | Un anneau de cuir et de bronze : l'ouverture, la Clé, la vie, la force. |

### Amulette

| Base | Lignes possibles | Description |
| --- | --- | --- |
| **Amulette** | PV max, Soins, Force, Poisons et brûlures | Une pierre contre le cœur : la vie, les soins, un peu de venin. |
| **Pendentif** | PV max, Clés, Barrières, Dégâts | Un éclat suspendu : la Clé frappe plus fort derrière une barrière. |
| **Collier** | Force, Ouvertures, PV max, Soins | Des perles enfilées : la force, l'ouverture, la vie, les soins. |
| **Médaillon** | Barrières, Clés, Soins, Dégâts | Un portrait sous verre : barrières, Clé, soins, frappe. |
| **Camée** | Poisons et brûlures, PV max, Barrières, Soins | Un profil taillé dans la pierre : venins, vie, barrière, soin. |
| **Fétiche** | Clés, Force, Dégâts, Poisons et brûlures | Des plumes et des dents : la Clé, la force, la frappe, le venin. |

## Les traits légendaires

Un objet légendaire porte un trait, tiré à la trouvaille parmi ceux-ci : un passif de combat de son porteur. Un même trait porté deux fois ne compte qu'une fois.

| Trait | Ce qu'il fait |
| --- | --- |
| **Ténacité** | la première fois que ses PV tomberaient à zéro, il reste à 1 PV (une fois par combat) |
| **Soif** | chaque dégât direct qu'il inflige le soigne de 10 % de ce dégât |
| **Épines** | quand il subit un dégât direct, l'attaquant en reprend 10 % |
| **Ancrage** | ses voies refroidissent un tour plus tard |
| **Fulgurance** | ses Clés s'éteignent un tour de moins |
| **Endurance** | les états négatifs qu'il subit durent un tour de moins (jamais moins d'un tour) |
| **Férocité** | +20 % de dégâts directs sur un ennemi sous 30 % de ses PV |
| **Grâce** | les soins qu'il reçoit sont +15 % |
| **Carapace** | au début du combat, une barrière de 15 % de ses PV max |
| **Persistance** | les poisons, brûlures et saignements qu'il pose durent un tour de plus |

## Les fourchettes par rareté et par niveau

Pour chaque ligne, les bornes d'un objet (en %) selon sa rareté, aux niveaux 1, 10, 20 et 30 (au-delà de 30, comme à 30).

| Ligne | Rareté | Niveau 1 | Niveau 10 | Niveau 20 | Niveau 30 |
| --- | --- | --- | --- | --- | --- |
| PV max | commun | 1 – 2 | 1,3 – 2,6 | 1,7 – 3,3 | 2 – 4 |
| PV max | peu commun | 1 – 2 | 1,3 – 2,6 | 1,7 – 3,3 | 2 – 4 |
| PV max | rare | 1,2 – 2,4 | 1,6 – 3,1 | 2 – 4 | 2,4 – 4,8 |
| PV max | épique | 1,4 – 2,7 | 1,8 – 3,5 | 2,2 – 4,5 | 2,7 – 5,4 |
| PV max | légendaire | 1,5 – 3 | 2 – 3,9 | 2,5 – 5 | 3 – 6 |
| Force | commun | 0,6 – 1,2 | 0,8 – 1,6 | 1 – 2,1 | 1,2 – 2,5 |
| Force | peu commun | 0,6 – 1,2 | 0,8 – 1,6 | 1 – 2,1 | 1,2 – 2,5 |
| Force | rare | 0,7 – 1,5 | 0,9 – 2 | 1,2 – 2,5 | 1,4 – 3 |
| Force | épique | 0,8 – 1,7 | 1,1 – 2,2 | 1,3 – 2,8 | 1,6 – 3,4 |
| Force | légendaire | 0,9 – 1,9 | 1,2 – 2,5 | 1,5 – 3,1 | 1,8 – 3,8 |
| Dégâts | commun | 1 – 2 | 1,3 – 2,6 | 1,7 – 3,3 | 2 – 4 |
| Dégâts | peu commun | 1 – 2 | 1,3 – 2,6 | 1,7 – 3,3 | 2 – 4 |
| Dégâts | rare | 1,2 – 2,4 | 1,6 – 3,1 | 2 – 4 | 2,4 – 4,8 |
| Dégâts | épique | 1,4 – 2,7 | 1,8 – 3,5 | 2,2 – 4,5 | 2,7 – 5,4 |
| Dégâts | légendaire | 1,5 – 3 | 2 – 3,9 | 2,5 – 5 | 3 – 6 |
| Soins | commun | 1 – 2 | 1,3 – 2,6 | 1,7 – 3,3 | 2 – 4 |
| Soins | peu commun | 1 – 2 | 1,3 – 2,6 | 1,7 – 3,3 | 2 – 4 |
| Soins | rare | 1,2 – 2,4 | 1,6 – 3,1 | 2 – 4 | 2,4 – 4,8 |
| Soins | épique | 1,4 – 2,7 | 1,8 – 3,5 | 2,2 – 4,5 | 2,7 – 5,4 |
| Soins | légendaire | 1,5 – 3 | 2 – 3,9 | 2,5 – 5 | 3 – 6 |
| Barrières | commun | 1,2 – 2,5 | 1,6 – 3,3 | 2,1 – 4,1 | 2,5 – 5 |
| Barrières | peu commun | 1,2 – 2,5 | 1,6 – 3,3 | 2,1 – 4,1 | 2,5 – 5 |
| Barrières | rare | 1,5 – 3 | 2 – 3,9 | 2,5 – 5 | 3 – 6 |
| Barrières | épique | 1,7 – 3,4 | 2,2 – 4,4 | 2,8 – 5,6 | 3,4 – 6,8 |
| Barrières | légendaire | 1,9 – 3,8 | 2,5 – 4,9 | 3,1 – 6,2 | 3,8 – 7,5 |
| Poisons et brûlures | commun | 1,2 – 2,5 | 1,6 – 3,3 | 2,1 – 4,1 | 2,5 – 5 |
| Poisons et brûlures | peu commun | 1,2 – 2,5 | 1,6 – 3,3 | 2,1 – 4,1 | 2,5 – 5 |
| Poisons et brûlures | rare | 1,5 – 3 | 2 – 3,9 | 2,5 – 5 | 3 – 6 |
| Poisons et brûlures | épique | 1,7 – 3,4 | 2,2 – 4,4 | 2,8 – 5,6 | 3,4 – 6,8 |
| Poisons et brûlures | légendaire | 1,9 – 3,8 | 2,5 – 4,9 | 3,1 – 6,2 | 3,8 – 7,5 |
| Clés | commun | 1,2 – 2,5 | 1,6 – 3,3 | 2,1 – 4,1 | 2,5 – 5 |
| Clés | peu commun | 1,2 – 2,5 | 1,6 – 3,3 | 2,1 – 4,1 | 2,5 – 5 |
| Clés | rare | 1,5 – 3 | 2 – 3,9 | 2,5 – 5 | 3 – 6 |
| Clés | épique | 1,7 – 3,4 | 2,2 – 4,4 | 2,8 – 5,6 | 3,4 – 6,8 |
| Clés | légendaire | 1,9 – 3,8 | 2,5 – 4,9 | 3,1 – 6,2 | 3,8 – 7,5 |
| Ouvertures | commun | 1,2 – 2,5 | 1,6 – 3,3 | 2,1 – 4,1 | 2,5 – 5 |
| Ouvertures | peu commun | 1,2 – 2,5 | 1,6 – 3,3 | 2,1 – 4,1 | 2,5 – 5 |
| Ouvertures | rare | 1,5 – 3 | 2 – 3,9 | 2,5 – 5 | 3 – 6 |
| Ouvertures | épique | 1,7 – 3,4 | 2,2 – 4,4 | 2,8 – 5,6 | 3,4 – 6,8 |
| Ouvertures | légendaire | 1,9 – 3,8 | 2,5 – 4,9 | 3,1 – 6,2 | 3,8 – 7,5 |

## D'où tombe quoi

| Source | Rareté | Niveau de l'objet | Lié ou échangeable |
| --- | --- | --- | --- |
| Un étage de la Tour, franchi pour la première fois | commun 70 %, peu commun 30 %, 7 fois sur 10 (sinon rien) | celui de l'étage | échangeable |
| Un étage de la Tour, rejoué | commun 70 %, peu commun 30 %, une fois sur 2 | celui de l'étage | lié |
| Un Gardien de la Tour (tous les 5 étages), la première fois | peu commun 100 % | celui de l'étage | échangeable |
| Un grand Gardien de la Tour (tous les 10 étages), la première fois | peu commun 60 %, rare 40 % | celui de l'étage | échangeable |
| Un Gardien ou un grand Gardien rejoué | les mêmes raretés, toujours un objet | celui de l'étage | lié |
| L'élite d'un donjon | épique (+ 1 fragment, 30 Éclats) | celui du donjon | lié |
| Le boss d'un donjon | légendaire (+ 100 Éclats) | celui du donjon | échangeable |
| Le coffre de la semaine à l'Arène | commun dès 3 victoires ; rare dès 5 victoires ; épique dès 7 victoires | le tien | lié |
| L'étal du Comptoir (contre des Éclats) | commun à 40 Éclats ; peu commun à 80 Éclats ; rare à 120 Éclats | le tien | lié |

## Les prix (Comptoir et Marché)

Le Comptoir achète un objet échangeable à son **prix plancher** : 2 (commun) / 4 (peu commun) / 6 (rare) / 20 (épique) / 80 (légendaire) Or selon la rareté, × le niveau (pente 1), × la qualité (de 0,5 à 1). Au Marché, le vendeur fixe son prix entre le plancher et le plancher × 2 (commun) / 3 (peu commun) / 5 (rare) / 50 (épique) / 500 (légendaire).

