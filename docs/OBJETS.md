# Les objets du jeu

Généré par `tools/catalogue_objets.py` depuis `data/items.json` (et les données du butin) : ne pas modifier à la main, modifier les données puis relancer l'outil. Les noms sont de fantasy classique en attendant l'univers (décision de Gautier du 29 octobre).

## Comment un objet est fait

Un objet, c'est **une base** (ce qu'il est : une Épée, une Robe…), **un palier de niveau** (son matériau), **une rareté** et **ses lignes** : des bonus en %, tirés à la trouvaille dans la réserve de sa base. Il n'a de valeur que pour un Destin : ses lignes s'ajoutent aux éclats de la roue. Cinq emplacements, un objet porté par emplacement.

- **Les raretés** : commun (1 ligne, fourchettes × 1) ; rare (2 lignes, fourchettes × 1,1) ; épique (3 lignes, fourchettes × 1,3) ; légendaire (4 lignes, fourchettes × 1,5).
- **Le niveau** : les fourchettes valent 50 % de leur pleine valeur au niveau 1, 100 % au niveau 30 et au-delà.
- **La qualité** (0 à 100 %) dit où les chiffres sont tombés dans leurs fourchettes.
- **Lié ou échangeable** : échangeable seulement s'il vient d'un premier passage (Tour) ou d'un boss de donjon ; lié dès qu'on l'équipe, et pour toujours.
- **La reforge** : une ligne retirée contre 20 Éclats, +100 % par reforge déjà faite. **Le recyclage** rend 5 (commun) / 15 (rare) / 40 (épique) / 100 (légendaire) Éclats.

## Les huit lignes

| Ligne | Ce qu'elle fait | Fourchette (commun, niveau 30) | Plafond sur le total porté |
| --- | --- | --- | --- |
| PV max | +X % de PV max | 3 – 6 % | 25 % |
| Force | +X % de force (toutes les valeurs) | 2 – 4 % | 15 % |
| Dégâts | +X % de dégâts directs | 3 – 6 % | 25 % |
| Soins | +X % de soins et de Gardiens | 3 – 6 % | 25 % |
| Barrières | +X % de barrières | 4 – 8 % | 30 % |
| Poisons et brûlures | +X % de dégâts sur la durée | 4 – 8 % | 30 % |
| Clés | +X % sur les Clés | 4 – 8 % | 30 % |
| Ouvertures | +X % sur le moyeu et les ouvertures | 4 – 8 % | 30 % |

## Les paliers de niveau (le matériau du nom)

| Dès le niveau | Suffixe | Exemple |
| --- | --- | --- |
| 1 | de fer | Épée de fer rare |
| 10 | d'acier | Épée d'acier rare |
| 20 | d'argent | Épée d'argent rare |
| 30 | de mithril | Épée de mithril rare |
| 40 | runique | Épée runique rare |
| 50 | de dragon | Épée de dragon rare |

## Les trente bases, par emplacement

Chaque base a une réserve de quatre lignes possibles ; un objet tire ses lignes dedans (autant que sa rareté en donne, toutes différentes). Chaque ligne est dans quinze réserves : aucune n'est plus rare qu'une autre.

### Arme

| Base | Lignes possibles | Description |
| --- | --- | --- |
| **Épée** | Dégâts, Force, Clés, Ouvertures | La lame droite du soldat : des coups francs, et la main sûre pour ouvrir le combat. |
| **Bâton** | Soins, Force, Poisons et brûlures, Clés | Un bois noueux qui porte les soins et le feu lent ; il garde la Clé au chaud. |
| **Arc** | Dégâts, Poisons et brûlures, Ouvertures, Clés | Le trait part de loin, revient souvent, et finit sa proie. |
| **Dague** | Dégâts, Poisons et brûlures, Ouvertures, Force | Courte et vicieuse : le poison, le premier coup, la main vive. |
| **Hache** | Dégâts, Force, Poisons et brûlures, Barrières | Large et lourde : elle tranche, elle saigne, et le bras tient le choc. |
| **Marteau** | PV max, Dégâts, Barrières, Clés | Le poids d'une enclume : encaisser, écraser, et finir par la Clé. |

### Armure

| Base | Lignes possibles | Description |
| --- | --- | --- |
| **Cotte de mailles** | PV max, Barrières, Force, Ouvertures | Des anneaux de métal tissés : on encaisse, on tient, on repart. |
| **Robe** | PV max, Soins, Barrières, Clés | Du tissu brodé de signes : les soins et les barrières y sont plus grands. |
| **Armure de cuir** | PV max, Dégâts, Poisons et brûlures, Ouvertures | Souple et silencieuse : pour frapper fort sans peser. |
| **Armure de plates** | PV max, Barrières, Soins, Ouvertures | Des plaques d'acier : rien ne passe, et le porteur dure. |
| **Tunique** | Soins, Poisons et brûlures, Ouvertures, Force | Légère, propre aux soigneurs qui bougent : soins, venins, ouverture vive. |
| **Cape** | Poisons et brûlures, Dégâts, Barrières, Clés | Un pan d'ombre sur les épaules : les poisons, la frappe, la barrière. |

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

### Talisman

| Base | Lignes possibles | Description |
| --- | --- | --- |
| **Talisman** | Clés, Ouvertures, Force, Poisons et brûlures | Un signe qui ouvre et qui ferme : les Clés et les Ouvertures. |
| **Relique** | Soins, Barrières, Clés, PV max | Un os de saint, dit-on : les soins, les barrières, la Clé et la vie. |
| **Idole** | Dégâts, Poisons et brûlures, Ouvertures, Soins | Une petite figure de bois : le poison, la frappe, l'élan. |
| **Grigri** | Ouvertures, PV max, Soins, Poisons et brûlures | Un petit sac cousu : l'ouverture, la vie, les soins, le venin. |
| **Rune** | Clés, Force, Barrières, Dégâts | Un galet gravé : la Clé, la force, la barrière, le coup. |
| **Charme** | Barrières, Soins, Force, Poisons et brûlures | Un ruban noué : barrières, soins, force, venin. |

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
| PV max | commun | 1,5 – 3 | 2 – 3,9 | 2,5 – 5 | 3 – 6 |
| PV max | rare | 1,7 – 3,4 | 2,3 – 4,5 | 2,9 – 5,7 | 3,4 – 6,9 |
| PV max | épique | 2 – 3,9 | 2,6 – 5,1 | 3,2 – 6,5 | 3,9 – 7,8 |
| PV max | légendaire | 2,2 – 4,5 | 2,9 – 5,9 | 3,7 – 7,4 | 4,5 – 9 |
| Force | commun | 1 – 2 | 1,3 – 2,6 | 1,7 – 3,3 | 2 – 4 |
| Force | rare | 1,1 – 2,3 | 1,5 – 3 | 1,9 – 3,8 | 2,3 – 4,6 |
| Force | épique | 1,3 – 2,6 | 1,7 – 3,4 | 2,2 – 4,3 | 2,6 – 5,2 |
| Force | légendaire | 1,5 – 3 | 2 – 3,9 | 2,5 – 5 | 3 – 6 |
| Dégâts | commun | 1,5 – 3 | 2 – 3,9 | 2,5 – 5 | 3 – 6 |
| Dégâts | rare | 1,7 – 3,4 | 2,3 – 4,5 | 2,9 – 5,7 | 3,4 – 6,9 |
| Dégâts | épique | 2 – 3,9 | 2,6 – 5,1 | 3,2 – 6,5 | 3,9 – 7,8 |
| Dégâts | légendaire | 2,2 – 4,5 | 2,9 – 5,9 | 3,7 – 7,4 | 4,5 – 9 |
| Soins | commun | 1,5 – 3 | 2 – 3,9 | 2,5 – 5 | 3 – 6 |
| Soins | rare | 1,7 – 3,4 | 2,3 – 4,5 | 2,9 – 5,7 | 3,4 – 6,9 |
| Soins | épique | 2 – 3,9 | 2,6 – 5,1 | 3,2 – 6,5 | 3,9 – 7,8 |
| Soins | légendaire | 2,2 – 4,5 | 2,9 – 5,9 | 3,7 – 7,4 | 4,5 – 9 |
| Barrières | commun | 2 – 4 | 2,6 – 5,2 | 3,3 – 6,6 | 4 – 8 |
| Barrières | rare | 2,3 – 4,6 | 3 – 6 | 3,8 – 7,6 | 4,6 – 9,2 |
| Barrières | épique | 2,6 – 5,2 | 3,4 – 6,8 | 4,3 – 8,6 | 5,2 – 10,4 |
| Barrières | légendaire | 3 – 6 | 3,9 – 7,9 | 5 – 9,9 | 6 – 12 |
| Poisons et brûlures | commun | 2 – 4 | 2,6 – 5,2 | 3,3 – 6,6 | 4 – 8 |
| Poisons et brûlures | rare | 2,3 – 4,6 | 3 – 6 | 3,8 – 7,6 | 4,6 – 9,2 |
| Poisons et brûlures | épique | 2,6 – 5,2 | 3,4 – 6,8 | 4,3 – 8,6 | 5,2 – 10,4 |
| Poisons et brûlures | légendaire | 3 – 6 | 3,9 – 7,9 | 5 – 9,9 | 6 – 12 |
| Clés | commun | 2 – 4 | 2,6 – 5,2 | 3,3 – 6,6 | 4 – 8 |
| Clés | rare | 2,3 – 4,6 | 3 – 6 | 3,8 – 7,6 | 4,6 – 9,2 |
| Clés | épique | 2,6 – 5,2 | 3,4 – 6,8 | 4,3 – 8,6 | 5,2 – 10,4 |
| Clés | légendaire | 3 – 6 | 3,9 – 7,9 | 5 – 9,9 | 6 – 12 |
| Ouvertures | commun | 2 – 4 | 2,6 – 5,2 | 3,3 – 6,6 | 4 – 8 |
| Ouvertures | rare | 2,3 – 4,6 | 3 – 6 | 3,8 – 7,6 | 4,6 – 9,2 |
| Ouvertures | épique | 2,6 – 5,2 | 3,4 – 6,8 | 4,3 – 8,6 | 5,2 – 10,4 |
| Ouvertures | légendaire | 3 – 6 | 3,9 – 7,9 | 5 – 9,9 | 6 – 12 |

## D'où tombe quoi

| Source | Rareté | Niveau de l'objet | Lié ou échangeable |
| --- | --- | --- | --- |
| Un étage de la Tour, franchi pour la première fois | commun 70 %, rare 30 % | celui de l'étage | échangeable |
| Un étage de la Tour, rejoué | commun 70 %, rare 30 %, une fois sur 2 | celui de l'étage | lié |
| Un Gardien de la Tour (tous les 5 étages ; un grand tous les 10), la première fois | épique 100 % | celui de l'étage | échangeable |
| Un Gardien rejoué | épique 100 %, toujours | celui de l'étage | lié |
| L'élite d'un donjon | épique (+ 1 fragment, 30 Éclats) | celui du donjon | lié |
| Le boss d'un donjon | légendaire (+ 100 Éclats) | celui du donjon | échangeable |
| Le coffre de la semaine à l'Arène | commun dès 3 victoires ; rare dès 5 victoires ; épique dès 7 victoires | le tien | lié |
| L'étal du Comptoir (contre des Éclats) | commun à 40 Éclats ; rare à 120 Éclats | le tien | lié |

## Les prix (Comptoir et Marché)

Le Comptoir achète un objet échangeable à son **prix plancher** : 2 (commun) / 6 (rare) / 20 (épique) / 80 (légendaire) Or selon la rareté, × le niveau (pente 1), × la qualité (de 0,5 à 1). Au Marché, le vendeur fixe son prix entre le plancher et le plancher × 2 (commun) / 5 (rare) / 50 (épique) / 500 (légendaire).

