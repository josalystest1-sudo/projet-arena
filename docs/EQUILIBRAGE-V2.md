# Équilibrage du combat V2

Un rapport par passe de réglage (docs/SPEC-COMBAT-V2.md, section 11.3) : la matrice des classes, les trois routes, l'usage des voies, la longueur des combats, la Tour, et les boutons touchés. Le plus récent est en bas.

## Passe 1 (graines à partir de 100004)

**1 critères tenus sur 6.** 15000 combats de duel (médiane 17 tours), 0 combats non finis.

### Les six critères (section 11.2)

- ❌ **1. Chaque classe entre 47 % et 53 % de victoires** : guerrier 46,5 %, archer 56,1 %, pretre 67,7 %, alchimiste 64,7 %, invocateur 41,0 %, diplomate 35,5 %, pugiliste 23,1 %
- ❌ **2. Aucune case de la matrice hors de 40 % – 60 %** : guerrier contre pretre 21,3 %, guerrier contre alchimiste 23,3 %, guerrier contre diplomate 62,0 %, guerrier contre pugiliste 70,0 %, mage contre pretre 25,3 %, mage contre alchimiste 30,7 %, mage contre diplomate 63,3 %, mage contre pugiliste 84,0 %, voleur contre pretre 34,7 %, voleur contre alchimiste 38,7 %, voleur contre diplomate 66,0 %, voleur contre pugiliste 79,3 %, archer contre voleur 65,3 %, archer contre pretre 30,7 %, archer contre alchimiste 35,3 %, archer contre diplomate 68,0 %, archer contre pugiliste 86,0 %, pretre contre guerrier 76,0 %, pretre contre mage 66,0 %, pretre contre archer 69,3 %, pretre contre invocateur 71,3 %, pretre contre barde 63,3 %, pretre contre diplomate 86,0 %, pretre contre pugiliste 90,0 %, alchimiste contre guerrier 74,0 %, alchimiste contre mage 65,3 %, alchimiste contre invocateur 70,0 %, alchimiste contre barde 64,0 %, alchimiste contre diplomate 86,0 %, alchimiste contre pugiliste 90,0 %, invocateur contre archer 30,0 %, invocateur contre pretre 20,0 %, invocateur contre alchimiste 27,3 %, invocateur contre barde 36,0 %, invocateur contre pugiliste 68,7 %, barde contre pretre 36,7 %, barde contre alchimiste 39,3 %, barde contre diplomate 68,7 %, barde contre pugiliste 84,0 %, diplomate contre mage 33,3 %, diplomate contre voleur 29,3 %, diplomate contre archer 30,7 %, diplomate contre pretre 12,0 %, diplomate contre alchimiste 16,7 %, diplomate contre barde 28,7 %, diplomate contre pugiliste 71,3 %, pugiliste contre guerrier 24,7 %, pugiliste contre mage 14,7 %, pugiliste contre voleur 17,3 %, pugiliste contre archer 14,7 %, pugiliste contre pretre 9,3 %, pugiliste contre alchimiste 14,0 %, pugiliste contre invocateur 23,3 %, pugiliste contre barde 18,7 %
- ❌ **3. Aucune route au-dessus de 55 % ni sous 40 % (Éventail : seulement pas au-dessus de 55 %)** : mage Ruée 56,5 %, archer Réactive 56,1 %, pretre Réactive 67,7 %, alchimiste Réactive 64,7 %, invocateur Ruée 29,6 %, diplomate Ruée 18,8 %, diplomate Réactive 35,5 %, pugiliste Ruée 36,6 %, pugiliste Réactive 23,1 %
- ✅ **4. Chaque voie jouée dans 15 % des combats au moins, une Clé dans 60 %**
- ❌ **5. Longueur : médiane de 6 à 10 tours, 95 % finis avant le tour 20** : médiane 17 tours, 72,3 % des combats finis avant le tour 20
- ❌ **6. Tour : étage 10 dans 40 à 60 % des montées, étage 20 dans 5 à 10 %, à 5 points près entre classes** : guerrier étage 20 0,0 %, mage étage 10 0,0 %, mage étage 20 0,0 %, voleur étage 10 0,0 %, voleur étage 20 0,0 %, archer étage 10 0,0 %, archer étage 20 0,0 %, pretre étage 10 14,0 %, pretre étage 20 0,0 %, alchimiste étage 10 9,0 %, alchimiste étage 20 0,0 %, invocateur étage 10 5,0 %, invocateur étage 20 0,0 %, barde étage 10 3,0 %, barde étage 20 0,0 %, diplomate étage 10 3,0 %, diplomate étage 20 0,0 %, pugiliste étage 10 0,0 %, pugiliste étage 20 0,0 %, écart entre classes : étage 10 de 0,0 % à 44,0 %, étage 20 de 0,0 % à 0,0 %

### La matrice des classes (taux de victoire de la ligne contre la colonne)

| | Guer | Mage | Vole | Arch | Prêt | Alch | Invo | Bard | Dipl | Pugi | **Moyenne** |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 51 | 46 | 42 | 54 | 21 | 23 | 49 | 46 | 62 | 70 | **46,5 %** |
| Mage | 58 | 43 | 49 | 47 | 25 | 31 | 59 | 47 | 63 | 84 | **50,7 %** |
| Voleur | 44 | 49 | 43 | 42 | 35 | 39 | 50 | 53 | 66 | 79 | **49,9 %** |
| Archer | 55 | 51 | 65 | 53 | 31 | 35 | 59 | 58 | 68 | 86 | **56,1 %** |
| Prêtre | 76 | 66 | 59 | 69 | 51 | 45 | 71 | 63 | 86 | 90 | **67,7 %** |
| Alchimiste | 74 | 65 | 55 | 57 | 43 | 42 | 70 | 64 | 86 | 90 | **64,7 %** |
| Invocateur | 44 | 40 | 41 | 30 | 20 | 27 | 47 | 36 | 56 | 69 | **41,0 %** |
| Barde | 56 | 40 | 45 | 49 | 37 | 39 | 55 | 49 | 69 | 84 | **52,4 %** |
| Diplomate | 41 | 33 | 29 | 31 | 12 | 17 | 44 | 29 | 48 | 71 | **35,5 %** |
| Pugiliste | 25 | 15 | 17 | 15 | 9 | 14 | 23 | 19 | 42 | 52 | **23,1 %** |

### Les trois routes, l'usage des voies et la Tour, par classe

| Classe | Ruée | Éventail | Réactive | Voie 1 | Voie 2 | Voie 3 | Voie 4 | Voie 5 | Clé | Tour : étage 10 | étage 20 | étage moyen |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 51,2 % | 8,1 % | 46,5 % | 49,8 % | 71,7 % | 48,0 % | 88,1 % | 66,3 % | 99,6 % | 44,0 % | 0,0 % | 9,2 |
| Mage | 56,5 % | 13,1 % | 50,7 % | 50,8 % | 63,1 % | 38,1 % | 43,3 % | 38,2 % | 97,7 % | 0,0 % | 0,0 % | 4,3 |
| Voleur | 43,9 % | 13,3 % | 49,9 % | 39,2 % | 29,3 % | 29,0 % | 45,8 % | 83,8 % | 96,9 % | 0,0 % | 0,0 % | 4,9 |
| Archer | 46,0 % | 14,8 % | 56,1 % | 27,6 % | 74,8 % | 57,2 % | 33,7 % | 34,7 % | 97,3 % | 0,0 % | 0,0 % | 4,6 |
| Prêtre | 41,4 % | 13,1 % | 67,7 % | 54,7 % | 82,1 % | 45,5 % | 75,1 % | 73,7 % | 99,5 % | 14,0 % | 0,0 % | 7,3 |
| Alchimiste | 45,0 % | 17,0 % | 64,7 % | 57,2 % | 58,7 % | 22,8 % | 53,3 % | 72,3 % | 98,0 % | 9,0 % | 0,0 % | 6,6 |
| Invocateur | 29,6 % | 6,4 % | 41,0 % | 41,6 % | 47,1 % | 51,3 % | 71,0 % | 45,2 % | 96,7 % | 5,0 % | 0,0 % | 5,7 |
| Barde | 45,8 % | 10,8 % | 52,4 % | 48,0 % | 49,8 % | 59,1 % | 51,1 % | 60,5 % | 98,5 % | 3,0 % | 0,0 % | 5,4 |
| Diplomate | 18,8 % | 3,6 % | 35,5 % | 21,2 % | 56,1 % | 94,7 % | 69,4 % | 76,3 % | 98,4 % | 3,0 % | 0,0 % | 6,0 |
| Pugiliste | 36,6 % | 2,0 % | 23,1 % | 34,2 % | 38,3 % | 83,9 % | 86,8 % | 28,1 % | 99,7 % | 0,0 % | 0,0 % | 4,3 |

### Boutons touchés, et pourquoi

- PV de toutes les classes : ×1,000 → ×0,850 des PV de la spécification (médiane 17 tours, 72,3 % finis avant le tour 20 ; on vise 10 tours)
- k_classe Guerrier : 0,850 → 0,877 (46,5 % de victoires)
- k_classe Archer : 1,000 → 0,945 (56,1 % de victoires)
- k_classe Prêtre : 1,000 → 0,940 (67,7 % de victoires)
- k_classe Alchimiste : 1,000 → 0,940 (64,7 % de victoires)
- k_classe Invocateur : 1,000 → 1,060 (41,0 % de victoires)
- k_classe Barde : 1,000 → 0,978 (52,4 % de victoires)
- k_classe Diplomate : 1,000 → 1,060 (35,5 % de victoires)
- k_classe Pugiliste : 0,900 → 0,954 (23,1 % de victoires)
- budgets des Clés (Mage) : -3 % (Ruée 56,5 %, une Clé jouée dans 97,7 % des combats)
- budgets des Clés (Invocateur) : +3 % (Ruée 29,6 %, une Clé jouée dans 96,7 % des combats)
- budgets des Clés (Diplomate) : +3 % (Ruée 18,8 %, une Clé jouée dans 98,4 % des combats)
- budgets des Clés (Pugiliste) : +3 % (Ruée 36,6 %, une Clé jouée dans 99,7 % des combats)
- Tour : force des monstres au départ 0,600 → 0,450, en plus par étage 0,120 → 0,093 (étage 10 atteint dans 7,8 % des montées, étage 20 dans 0,0 %)
- Tour, Guerrier : facteur des monstres 1,000 → 1,150 (étage 10 dans 44,0 % des montées)
- Tour, Mage : facteur des monstres 1,000 → 0,938 (étage 10 dans 0,0 % des montées)
- Tour, Voleur : facteur des monstres 1,000 → 0,938 (étage 10 dans 0,0 % des montées)
- Tour, Archer : facteur des monstres 1,000 → 0,938 (étage 10 dans 0,0 % des montées)
- Tour, Prêtre : facteur des monstres 1,000 → 1,050 (étage 10 dans 14,0 % des montées)
- Tour, Invocateur : facteur des monstres 1,000 → 0,978 (étage 10 dans 5,0 % des montées)
- Tour, Barde : facteur des monstres 1,000 → 0,962 (étage 10 dans 3,0 % des montées)
- Tour, Diplomate : facteur des monstres 1,000 → 0,962 (étage 10 dans 3,0 % des montées)
- Tour, Pugiliste : facteur des monstres 1,000 → 0,938 (étage 10 dans 0,0 % des montées)

## Passe 2 (graines à partir de 200007)

**1 critères tenus sur 6.** 15000 combats de duel (médiane 16 tours), 0 combats non finis.

### Les six critères (section 11.2)

- ❌ **1. Chaque classe entre 47 % et 53 % de victoires** : guerrier 46,7 %, voleur 61,6 %, pretre 64,1 %, alchimiste 57,0 %, invocateur 59,0 %, barde 41,7 %, diplomate 44,7 %, pugiliste 32,9 %
- ❌ **2. Aucune case de la matrice hors de 40 % – 60 %** : guerrier contre voleur 38,7 %, guerrier contre archer 60,7 %, guerrier contre pretre 34,0 %, guerrier contre alchimiste 32,7 %, guerrier contre invocateur 38,7 %, mage contre voleur 38,7 %, mage contre pretre 35,3 %, mage contre barde 66,0 %, mage contre pugiliste 70,7 %, voleur contre guerrier 61,3 %, voleur contre alchimiste 62,7 %, voleur contre barde 80,0 %, voleur contre diplomate 66,0 %, voleur contre pugiliste 72,7 %, archer contre pretre 30,0 %, archer contre invocateur 36,0 %, archer contre barde 64,7 %, archer contre pugiliste 67,3 %, pretre contre guerrier 64,0 %, pretre contre mage 65,3 %, pretre contre archer 68,7 %, pretre contre barde 74,0 %, pretre contre diplomate 76,0 %, pretre contre pugiliste 80,0 %, alchimiste contre guerrier 63,3 %, alchimiste contre barde 69,3 %, alchimiste contre diplomate 68,7 %, alchimiste contre pugiliste 69,3 %, invocateur contre guerrier 68,7 %, invocateur contre barde 71,3 %, invocateur contre pugiliste 70,7 %, barde contre mage 34,7 %, barde contre voleur 28,7 %, barde contre pretre 32,7 %, barde contre invocateur 32,7 %, diplomate contre voleur 36,0 %, diplomate contre pretre 18,0 %, diplomate contre alchimiste 33,3 %, diplomate contre invocateur 38,7 %, diplomate contre pugiliste 62,0 %, pugiliste contre guerrier 34,7 %, pugiliste contre mage 22,7 %, pugiliste contre voleur 20,7 %, pugiliste contre archer 30,7 %, pugiliste contre pretre 30,0 %, pugiliste contre alchimiste 31,3 %, pugiliste contre invocateur 24,0 %, pugiliste contre diplomate 36,0 %
- ❌ **3. Aucune route au-dessus de 55 % ni sous 40 % (Éventail : seulement pas au-dessus de 55 %)** : mage Ruée 56,1 %, voleur Réactive 61,6 %, pretre Ruée 38,6 %, pretre Réactive 64,1 %, alchimiste Ruée 34,5 %, alchimiste Réactive 57,0 %, invocateur Réactive 59,0 %, barde Ruée 35,8 %, diplomate Ruée 31,5 %, pugiliste Réactive 32,9 %
- ✅ **4. Chaque voie jouée dans 15 % des combats au moins, une Clé dans 60 %**
- ❌ **5. Longueur : médiane de 6 à 10 tours, 95 % finis avant le tour 20** : médiane 16 tours, 80,7 % des combats finis avant le tour 20
- ❌ **6. Tour : étage 10 dans 40 à 60 % des montées, étage 20 dans 5 à 10 %, à 5 points près entre classes** : guerrier étage 20 1,0 %, mage étage 10 4,0 %, mage étage 20 0,0 %, voleur étage 10 11,0 %, voleur étage 20 0,0 %, archer étage 10 4,0 %, archer étage 20 0,0 %, pretre étage 10 32,0 %, pretre étage 20 0,0 %, alchimiste étage 10 28,0 %, alchimiste étage 20 0,0 %, invocateur étage 10 28,0 %, invocateur étage 20 0,0 %, barde étage 10 12,0 %, barde étage 20 0,0 %, diplomate étage 20 0,0 %, pugiliste étage 10 16,0 %, pugiliste étage 20 0,0 %, écart entre classes : étage 10 de 4,0 % à 45,0 %, étage 20 de 0,0 % à 1,0 %

### La matrice des classes (taux de victoire de la ligne contre la colonne)

| | Guer | Mage | Vole | Arch | Prêt | Alch | Invo | Bard | Dipl | Pugi | **Moyenne** |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 49 | 48 | 39 | 61 | 34 | 33 | 39 | 59 | 50 | 57 | **46,7 %** |
| Mage | 49 | 47 | 39 | 54 | 35 | 48 | 45 | 66 | 50 | 71 | **50,3 %** |
| Voleur | 61 | 51 | 53 | 57 | 56 | 63 | 56 | 80 | 66 | 73 | **61,6 %** |
| Archer | 41 | 51 | 45 | 59 | 30 | 49 | 36 | 65 | 53 | 67 | **49,5 %** |
| Prêtre | 64 | 65 | 55 | 69 | 49 | 56 | 54 | 74 | 76 | 80 | **64,1 %** |
| Alchimiste | 63 | 58 | 41 | 51 | 49 | 49 | 52 | 69 | 69 | 69 | **57,0 %** |
| Invocateur | 69 | 54 | 54 | 57 | 48 | 51 | 55 | 71 | 60 | 71 | **59,0 %** |
| Barde | 41 | 35 | 29 | 42 | 33 | 43 | 33 | 56 | 47 | 59 | **41,7 %** |
| Diplomate | 56 | 46 | 36 | 49 | 18 | 33 | 39 | 55 | 53 | 62 | **44,7 %** |
| Pugiliste | 35 | 23 | 21 | 31 | 30 | 31 | 24 | 47 | 36 | 52 | **32,9 %** |

### Les trois routes, l'usage des voies et la Tour, par classe

| Classe | Ruée | Éventail | Réactive | Voie 1 | Voie 2 | Voie 3 | Voie 4 | Voie 5 | Clé | Tour : étage 10 | étage 20 | étage moyen |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 47,1 % | 6,3 % | 46,7 % | 46,3 % | 64,4 % | 46,4 % | 86,9 % | 66,5 % | 99,5 % | 45,0 % | 1,0 % | 9,7 |
| Mage | 56,1 % | 13,5 % | 50,3 % | 43,7 % | 61,8 % | 41,8 % | 38,1 % | 37,2 % | 95,1 % | 4,0 % | 0,0 % | 6,1 |
| Voleur | 51,4 % | 15,9 % | 61,6 % | 37,5 % | 27,6 % | 27,2 % | 49,8 % | 78,6 % | 96,7 % | 11,0 % | 0,0 % | 6,6 |
| Archer | 40,4 % | 11,5 % | 49,5 % | 29,2 % | 65,1 % | 57,1 % | 31,0 % | 27,7 % | 94,3 % | 4,0 % | 0,0 % | 5,8 |
| Prêtre | 38,6 % | 8,0 % | 64,1 % | 52,6 % | 76,2 % | 32,1 % | 74,8 % | 75,5 % | 98,9 % | 32,0 % | 0,0 % | 8,5 |
| Alchimiste | 34,5 % | 11,3 % | 57,0 % | 49,9 % | 56,3 % | 29,5 % | 53,6 % | 66,3 % | 98,0 % | 28,0 % | 0,0 % | 8,0 |
| Invocateur | 40,6 % | 9,3 % | 59,0 % | 44,6 % | 50,9 % | 42,7 % | 74,7 % | 42,3 % | 96,5 % | 28,0 % | 0,0 % | 7,8 |
| Barde | 35,8 % | 6,8 % | 41,7 % | 41,0 % | 61,0 % | 57,1 % | 49,1 % | 51,6 % | 97,9 % | 12,0 % | 0,0 % | 6,5 |
| Diplomate | 31,5 % | 5,4 % | 44,7 % | 22,1 % | 60,1 % | 93,1 % | 66,2 % | 79,3 % | 97,3 % | 40,0 % | 0,0 % | 8,8 |
| Pugiliste | 41,1 % | 1,8 % | 32,9 % | 37,1 % | 49,7 % | 70,7 % | 88,9 % | 23,7 % | 99,5 % | 16,0 % | 0,0 % | 7,1 |

### Boutons touchés, et pourquoi

- PV de toutes les classes : ×0,850 → ×0,723 des PV de la spécification (médiane 16 tours, 80,7 % finis avant le tour 20 ; on vise 10 tours)
- k_classe Guerrier : 0,877 → 0,903 (46,7 % de victoires)
- k_classe Voleur : 1,000 → 0,940 (61,6 % de victoires)
- k_classe Prêtre : 0,940 → 0,884 (64,1 % de victoires)
- k_classe Alchimiste : 0,940 → 0,884 (57,0 % de victoires)
- k_classe Invocateur : 1,060 → 1,017 (59,0 % de victoires)
- k_classe Barde : 0,978 → 1,015 (41,7 % de victoires)
- k_classe Diplomate : 1,060 → 1,111 (44,7 % de victoires)
- k_classe Pugiliste : 0,954 → 1,011 (32,9 % de victoires)
- budgets des Clés (Mage) : -3 % (Ruée 56,1 %, une Clé jouée dans 95,1 % des combats)
- budgets des Clés (Archer) : +3 % (Ruée 40,4 %, une Clé jouée dans 94,3 % des combats)
- budgets des Clés (Prêtre) : +3 % (Ruée 38,6 %, une Clé jouée dans 98,9 % des combats)
- budgets des Clés (Alchimiste) : +3 % (Ruée 34,5 %, une Clé jouée dans 98,0 % des combats)
- budgets des Clés (Invocateur) : +3 % (Ruée 40,6 %, une Clé jouée dans 96,5 % des combats)
- budgets des Clés (Barde) : +3 % (Ruée 35,8 %, une Clé jouée dans 97,9 % des combats)
- budgets des Clés (Diplomate) : +3 % (Ruée 31,5 %, une Clé jouée dans 97,3 % des combats)
- Tour : force des monstres au départ 0,450 → 0,338, en plus par étage 0,093 → 0,072 (étage 10 atteint dans 22,0 % des montées, étage 20 dans 0,1 %)
- Tour, Guerrier : facteur des monstres 1,150 → 1,323 (étage 10 dans 45,0 % des montées)
- Tour, Mage : facteur des monstres 0,938 → 0,803 (étage 10 dans 4,0 % des montées)
- Tour, Voleur : facteur des monstres 0,938 → 0,855 (étage 10 dans 11,0 % des montées)
- Tour, Archer : facteur des monstres 0,938 → 0,803 (étage 10 dans 4,0 % des montées)
- Tour, Prêtre : facteur des monstres 1,050 → 1,134 (étage 10 dans 32,0 % des montées)
- Tour, Alchimiste : facteur des monstres 1,000 → 1,048 (étage 10 dans 28,0 % des montées)
- Tour, Invocateur : facteur des monstres 0,978 → 1,001 (étage 10 dans 28,0 % des montées)
- Tour, Barde : facteur des monstres 0,962 → 0,885 (étage 10 dans 12,0 % des montées)
- Tour, Diplomate : facteur des monstres 0,962 → 1,031 (étage 10 dans 40,0 % des montées)
- Tour, Pugiliste : facteur des monstres 0,938 → 0,893 (étage 10 dans 16,0 % des montées)

## Passe 3 (graines à partir de 300010)

**0 critères tenus sur 6.** 15000 combats de duel (médiane 15 tours), 0 combats non finis.

### Les six critères (section 11.2)

- ❌ **1. Chaque classe entre 47 % et 53 % de victoires** : voleur 57,8 %, archer 55,1 %, pretre 46,3 %, alchimiste 45,1 %, invocateur 59,4 %, barde 42,7 %, diplomate 43,4 %
- ❌ **2. Aucune case de la matrice hors de 40 % – 60 %** : guerrier contre archer 62,0 %, guerrier contre invocateur 36,7 %, guerrier contre diplomate 62,0 %, voleur contre alchimiste 72,0 %, voleur contre barde 62,7 %, voleur contre pugiliste 66,7 %, archer contre alchimiste 60,7 %, archer contre diplomate 62,0 %, archer contre pugiliste 64,0 %, pretre contre voleur 39,3 %, pretre contre invocateur 36,0 %, alchimiste contre mage 34,0 %, alchimiste contre voleur 32,7 %, alchimiste contre invocateur 32,7 %, invocateur contre guerrier 62,0 %, invocateur contre alchimiste 70,0 %, invocateur contre barde 70,7 %, invocateur contre diplomate 62,7 %, invocateur contre pugiliste 68,0 %, barde contre mage 37,3 %, barde contre voleur 36,0 %, barde contre archer 38,7 %, barde contre invocateur 32,0 %, diplomate contre pretre 34,0 %, pugiliste contre mage 38,7 %, pugiliste contre alchimiste 64,0 %
- ❌ **3. Aucune route au-dessus de 55 % ni sous 40 % (Éventail : seulement pas au-dessus de 55 %)** : mage Ruée 62,1 %, voleur Réactive 57,8 %, archer Réactive 55,1 %, pretre Ruée 28,6 %, alchimiste Ruée 26,0 %, invocateur Réactive 59,4 %, barde Ruée 33,9 %, diplomate Ruée 24,5 %
- ❌ **4. Chaque voie jouée dans 15 % des combats au moins, une Clé dans 60 %** : diplomate voie 1 14,6 %
- ❌ **5. Longueur : médiane de 6 à 10 tours, 95 % finis avant le tour 20** : médiane 15 tours, 87,7 % des combats finis avant le tour 20
- ❌ **6. Tour : étage 10 dans 40 à 60 % des montées, étage 20 dans 5 à 10 %, à 5 points près entre classes** : guerrier étage 10 67,0 %, guerrier étage 20 0,0 %, mage étage 10 31,0 %, mage étage 20 0,0 %, voleur étage 20 0,0 %, archer étage 10 36,0 %, archer étage 20 0,0 %, pretre étage 10 30,0 %, pretre étage 20 0,0 %, alchimiste étage 10 30,0 %, alchimiste étage 20 0,0 %, invocateur étage 20 0,0 %, barde étage 20 0,0 %, diplomate étage 20 1,0 %, pugiliste étage 20 1,0 %, écart entre classes : étage 10 de 30,0 % à 67,0 %, étage 20 de 0,0 % à 1,0 %

### La matrice des classes (taux de victoire de la ligne contre la colonne)

| | Guer | Mage | Vole | Arch | Prêt | Alch | Invo | Bard | Dipl | Pugi | **Moyenne** |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 54 | 51 | 53 | 62 | 45 | 53 | 37 | 52 | 62 | 55 | **52,4 %** |
| Mage | 47 | 51 | 43 | 50 | 53 | 60 | 47 | 57 | 56 | 60 | **52,3 %** |
| Voleur | 57 | 53 | 50 | 55 | 53 | 72 | 55 | 63 | 55 | 67 | **57,8 %** |
| Archer | 45 | 53 | 47 | 53 | 58 | 61 | 49 | 59 | 62 | 64 | **55,1 %** |
| Prêtre | 53 | 46 | 39 | 48 | 41 | 50 | 36 | 46 | 55 | 49 | **46,3 %** |
| Alchimiste | 55 | 34 | 33 | 43 | 49 | 55 | 33 | 47 | 57 | 45 | **45,1 %** |
| Invocateur | 62 | 59 | 42 | 53 | 56 | 70 | 51 | 71 | 63 | 68 | **59,4 %** |
| Barde | 41 | 37 | 36 | 39 | 47 | 50 | 32 | 49 | 45 | 53 | **42,7 %** |
| Diplomate | 42 | 44 | 47 | 45 | 34 | 49 | 41 | 45 | 45 | 43 | **43,4 %** |
| Pugiliste | 45 | 39 | 42 | 51 | 47 | 64 | 40 | 50 | 51 | 50 | **47,7 %** |

### Les trois routes, l'usage des voies et la Tour, par classe

| Classe | Ruée | Éventail | Réactive | Voie 1 | Voie 2 | Voie 3 | Voie 4 | Voie 5 | Clé | Tour : étage 10 | étage 20 | étage moyen |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 50,4 % | 8,0 % | 52,4 % | 47,3 % | 63,7 % | 52,1 % | 84,7 % | 63,8 % | 99,5 % | 67,0 % | 0,0 % | 11,2 |
| Mage | 62,1 % | 15,4 % | 52,3 % | 47,0 % | 54,7 % | 37,2 % | 41,7 % | 29,4 % | 93,8 % | 31,0 % | 0,0 % | 8,6 |
| Voleur | 50,6 % | 20,1 % | 57,8 % | 32,8 % | 39,2 % | 21,8 % | 49,0 % | 73,2 % | 95,2 % | 56,0 % | 0,0 % | 10,2 |
| Archer | 46,4 % | 13,0 % | 55,1 % | 28,5 % | 65,9 % | 51,7 % | 30,8 % | 33,9 % | 92,7 % | 36,0 % | 0,0 % | 8,8 |
| Prêtre | 28,6 % | 5,6 % | 46,3 % | 45,7 % | 69,7 % | 44,5 % | 77,5 % | 78,9 % | 97,8 % | 30,0 % | 0,0 % | 8,5 |
| Alchimiste | 26,0 % | 7,6 % | 45,1 % | 48,9 % | 45,6 % | 52,2 % | 54,3 % | 50,5 % | 97,1 % | 30,0 % | 0,0 % | 8,5 |
| Invocateur | 47,0 % | 11,0 % | 59,4 % | 45,0 % | 42,3 % | 36,1 % | 68,7 % | 36,1 % | 95,4 % | 45,0 % | 0,0 % | 9,9 |
| Barde | 33,9 % | 5,8 % | 42,7 % | 43,5 % | 39,4 % | 54,4 % | 50,1 % | 64,5 % | 96,9 % | 40,0 % | 0,0 % | 9,2 |
| Diplomate | 24,5 % | 3,3 % | 43,4 % | 14,6 % | 55,5 % | 90,5 % | 61,0 % | 81,8 % | 97,4 % | 59,0 % | 1,0 % | 11,2 |
| Pugiliste | 48,3 % | 2,3 % | 47,7 % | 35,7 % | 53,5 % | 60,6 % | 92,8 % | 15,9 % | 99,0 % | 57,0 % | 1,0 % | 10,4 |

### Boutons touchés, et pourquoi

- PV de toutes les classes : ×0,723 → ×0,614 des PV de la spécification (médiane 15 tours, 87,7 % finis avant le tour 20 ; on vise 10 tours)
- k_classe Guerrier : 0,903 → 0,893 (52,4 % de victoires)
- k_classe Mage : 1,000 → 0,980 (52,3 % de victoires)
- k_classe Voleur : 0,940 → 0,884 (57,8 % de victoires)
- k_classe Archer : 0,945 → 0,901 (55,1 % de victoires)
- k_classe Prêtre : 0,884 → 0,898 (46,3 % de victoires)
- k_classe Alchimiste : 0,884 → 0,903 (45,1 % de victoires)
- k_classe Invocateur : 1,017 → 0,974 (59,4 % de victoires)
- k_classe Barde : 1,015 → 1,048 (42,7 % de victoires)
- k_classe Diplomate : 1,111 → 1,177 (43,4 % de victoires)
- k_classe Pugiliste : 1,011 → 1,032 (47,7 % de victoires)
- budgets des Clés (Mage) : -3 % (Ruée 62,1 %, une Clé jouée dans 93,8 % des combats)
- budgets des Clés (Prêtre) : +3 % (Ruée 28,6 %, une Clé jouée dans 97,8 % des combats)
- budgets des Clés (Alchimiste) : +3 % (Ruée 26,0 %, une Clé jouée dans 97,1 % des combats)
- budgets des Clés (Barde) : +3 % (Ruée 33,9 %, une Clé jouée dans 96,9 % des combats)
- budgets de la Voie de l'Intimidation (Diplomate) : +3 % (jouée dans 14,6 % des combats)
- budgets des Clés (Diplomate) : +3 % (Ruée 24,5 %, une Clé jouée dans 97,4 % des combats)
- budgets de la Voie du Défi (Pugiliste) : +3 % (jouée dans 15,9 % des combats)
- Tour : force des monstres au départ 0,338 → 0,318, en plus par étage 0,072 → 0,057 (étage 10 atteint dans 45,1 % des montées, étage 20 dans 0,2 %)
- Tour, Guerrier : facteur des monstres 1,323 → 1,521 (étage 10 dans 67,0 % des montées)
- Tour, Mage : facteur des monstres 0,803 → 0,712 (étage 10 dans 31,0 % des montées)
- Tour, Voleur : facteur des monstres 0,855 → 0,892 (étage 10 dans 56,0 % des montées)
- Tour, Archer : facteur des monstres 0,803 → 0,744 (étage 10 dans 36,0 % des montées)
- Tour, Prêtre : facteur des monstres 1,134 → 1,065 (étage 10 dans 30,0 % des montées)
- Tour, Alchimiste : facteur des monstres 1,048 → 0,985 (étage 10 dans 30,0 % des montées)
- Tour, Barde : facteur des monstres 0,885 → 0,849 (étage 10 dans 40,0 % des montées)
- Tour, Diplomate : facteur des monstres 1,031 → 1,088 (étage 10 dans 59,0 % des montées)
- Tour, Pugiliste : facteur des monstres 0,893 → 0,935 (étage 10 dans 57,0 % des montées)

## Passe 4 (graines à partir de 400013)

**0 critères tenus sur 6.** 15000 combats de duel (médiane 14 tours), 0 combats non finis.

### Les six critères (section 11.2)

- ❌ **1. Chaque classe entre 47 % et 53 % de victoires** : voleur 56,3 %, archer 46,5 %, alchimiste 42,9 %, invocateur 56,4 %, barde 39,6 %, pugiliste 55,0 %
- ❌ **2. Aucune case de la matrice hors de 40 % – 60 %** : guerrier contre mage 64,0 %, guerrier contre archer 66,7 %, mage contre voleur 38,7 %, mage contre alchimiste 63,3 %, voleur contre mage 63,3 %, voleur contre alchimiste 74,0 %, voleur contre barde 64,7 %, archer contre guerrier 32,7 %, pretre contre pugiliste 39,3 %, alchimiste contre mage 34,7 %, alchimiste contre voleur 26,7 %, alchimiste contre archer 36,0 %, alchimiste contre invocateur 37,3 %, alchimiste contre barde 60,7 %, alchimiste contre pugiliste 30,0 %, invocateur contre guerrier 61,3 %, invocateur contre alchimiste 68,0 %, invocateur contre barde 69,3 %, barde contre guerrier 35,3 %, barde contre voleur 36,0 %, barde contre archer 38,0 %, barde contre pretre 30,0 %, barde contre invocateur 32,7 %, diplomate contre archer 60,7 %, diplomate contre barde 61,3 %, pugiliste contre alchimiste 65,3 %, pugiliste contre barde 64,7 %
- ❌ **3. Aucune route au-dessus de 55 % ni sous 40 % (Éventail : seulement pas au-dessus de 55 %)** : mage Ruée 61,9 %, voleur Réactive 56,3 %, pretre Ruée 35,3 %, alchimiste Ruée 30,8 %, invocateur Réactive 56,4 %, barde Ruée 37,8 %, barde Réactive 39,6 %, diplomate Ruée 29,1 %, pugiliste Ruée 15,0 %
- ❌ **4. Chaque voie jouée dans 15 % des combats au moins, une Clé dans 60 %** : archer voie 1 14,4 %
- ❌ **5. Longueur : médiane de 6 à 10 tours, 95 % finis avant le tour 20** : médiane 14 tours, 91,8 % des combats finis avant le tour 20
- ❌ **6. Tour : étage 10 dans 40 à 60 % des montées, étage 20 dans 5 à 10 %, à 5 points près entre classes** : guerrier étage 10 70,0 %, guerrier étage 20 0,0 %, mage étage 20 2,0 %, voleur étage 20 2,0 %, archer étage 20 0,0 %, pretre étage 20 3,0 %, alchimiste étage 20 1,0 %, invocateur étage 20 0,0 %, pugiliste étage 10 63,0 %, pugiliste étage 20 2,0 %, écart entre classes : étage 10 de 45,0 % à 70,0 %, étage 20 de 0,0 % à 5,0 %

### La matrice des classes (taux de victoire de la ligne contre la colonne)

| | Guer | Mage | Vole | Arch | Prêt | Alch | Invo | Bard | Dipl | Pugi | **Moyenne** |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 51 | 64 | 50 | 67 | 47 | 57 | 47 | 55 | 49 | 44 | **53,0 %** |
| Mage | 46 | 45 | 39 | 49 | 44 | 63 | 43 | 59 | 51 | 52 | **49,1 %** |
| Voleur | 58 | 63 | 44 | 55 | 53 | 74 | 49 | 65 | 51 | 50 | **56,3 %** |
| Archer | 33 | 49 | 43 | 48 | 41 | 59 | 45 | 59 | 46 | 43 | **46,5 %** |
| Prêtre | 57 | 57 | 40 | 53 | 43 | 51 | 45 | 47 | 57 | 39 | **49,1 %** |
| Alchimiste | 51 | 35 | 27 | 36 | 51 | 52 | 37 | 61 | 50 | 30 | **42,9 %** |
| Invocateur | 61 | 55 | 50 | 50 | 53 | 68 | 53 | 69 | 55 | 48 | **56,4 %** |
| Barde | 35 | 45 | 36 | 38 | 30 | 45 | 33 | 49 | 41 | 44 | **39,6 %** |
| Diplomate | 50 | 49 | 46 | 61 | 42 | 57 | 47 | 61 | 50 | 52 | **51,5 %** |
| Pugiliste | 52 | 54 | 44 | 59 | 57 | 65 | 49 | 65 | 55 | 49 | **55,0 %** |

### Les trois routes, l'usage des voies et la Tour, par classe

| Classe | Ruée | Éventail | Réactive | Voie 1 | Voie 2 | Voie 3 | Voie 4 | Voie 5 | Clé | Tour : étage 10 | étage 20 | étage moyen |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 54,3 % | 13,1 % | 53,0 % | 42,5 % | 70,9 % | 44,0 % | 81,5 % | 64,5 % | 97,5 % | 70,0 % | 0,0 % | 11,3 |
| Mage | 61,9 % | 18,3 % | 49,1 % | 32,5 % | 58,9 % | 34,3 % | 56,5 % | 29,1 % | 90,3 % | 45,0 % | 2,0 % | 10,1 |
| Voleur | 51,9 % | 29,5 % | 56,3 % | 22,8 % | 27,9 % | 54,7 % | 47,2 % | 57,8 % | 91,2 % | 55,0 % | 2,0 % | 10,1 |
| Archer | 46,0 % | 16,8 % | 46,5 % | 14,4 % | 63,2 % | 66,7 % | 22,9 % | 23,5 % | 87,8 % | 46,0 % | 0,0 % | 9,7 |
| Prêtre | 35,3 % | 9,0 % | 49,1 % | 41,9 % | 71,0 % | 44,5 % | 72,1 % | 77,1 % | 95,3 % | 57,0 % | 3,0 % | 10,5 |
| Alchimiste | 30,8 % | 8,4 % | 42,9 % | 52,1 % | 43,5 % | 37,3 % | 55,3 % | 55,9 % | 95,2 % | 45,0 % | 1,0 % | 9,6 |
| Invocateur | 49,4 % | 19,4 % | 56,4 % | 33,6 % | 39,1 % | 43,2 % | 74,7 % | 26,7 % | 87,9 % | 45,0 % | 0,0 % | 9,8 |
| Barde | 37,8 % | 9,8 % | 39,6 % | 43,1 % | 37,5 % | 49,7 % | 46,2 % | 60,9 % | 90,5 % | 59,0 % | 5,0 % | 11,2 |
| Diplomate | 29,1 % | 8,6 % | 51,5 % | 20,8 % | 60,4 % | 87,1 % | 55,2 % | 76,6 % | 91,7 % | 57,0 % | 5,0 % | 11,1 |
| Pugiliste | 15,0 % | 4,6 % | 55,0 % | 37,3 % | 49,7 % | 59,2 % | 89,5 % | 17,1 % | 95,6 % | 63,0 % | 2,0 % | 10,9 |

### Boutons touchés, et pourquoi

- PV de toutes les classes : ×0,614 → ×0,600 des PV de la spécification (médiane 14 tours, 91,8 % finis avant le tour 20 ; on vise 10 tours)
- k_classe Guerrier : 0,893 → 0,881 (53,0 % de victoires)
- k_classe Mage : 0,980 → 0,983 (49,1 % de victoires)
- k_classe Voleur : 0,884 → 0,834 (56,3 % de victoires)
- k_classe Archer : 0,901 → 0,915 (46,5 % de victoires)
- k_classe Prêtre : 0,898 → 0,902 (49,1 % de victoires)
- k_classe Alchimiste : 0,903 → 0,932 (42,9 % de victoires)
- k_classe Invocateur : 0,974 → 0,946 (56,4 % de victoires)
- k_classe Barde : 1,048 → 1,097 (39,6 % de victoires)
- k_classe Diplomate : 1,177 → 1,169 (51,5 % de victoires)
- k_classe Pugiliste : 1,032 → 1,009 (55,0 % de victoires)
- budgets des Clés (Guerrier) : -3 % (Ruée 54,2 %, une Clé jouée dans 97,5 % des combats)
- budgets des Clés (Mage) : -3 % (Ruée 61,9 %, une Clé jouée dans 90,3 % des combats)
- budgets de la Voie de la Précision (Archer) : +3 % (jouée dans 14,4 % des combats)
- budgets des Clés (Prêtre) : +3 % (Ruée 35,2 %, une Clé jouée dans 95,3 % des combats)
- budgets des Clés (Alchimiste) : +3 % (Ruée 30,8 %, une Clé jouée dans 95,2 % des combats)
- budgets des Clés (Barde) : +3 % (Ruée 37,8 %, une Clé jouée dans 90,5 % des combats)
- budgets des Clés (Diplomate) : +3 % (Ruée 29,1 %, une Clé jouée dans 91,7 % des combats)
- budgets des Clés (Pugiliste) : +3 % (Ruée 15,0 %, une Clé jouée dans 95,6 % des combats)
- Tour : force des monstres au départ 0,318 → 0,326, en plus par étage 0,057 → 0,047 (étage 10 atteint dans 54,2 % des montées, étage 20 dans 2,0 %)
- Tour, Guerrier : facteur des monstres 1,521 → 1,713 (étage 10 dans 70,0 % des montées)
- Tour, Mage : facteur des monstres 0,712 → 0,660 (étage 10 dans 45,0 % des montées)
- Tour, Archer : facteur des monstres 0,744 → 0,695 (étage 10 dans 46,0 % des montées)
- Tour, Prêtre : facteur des monstres 1,065 → 1,071 (étage 10 dans 57,0 % des montées)
- Tour, Alchimiste : facteur des monstres 0,985 → 0,949 (étage 10 dans 45,0 % des montées)
- Tour, Invocateur : facteur des monstres 1,001 → 0,983 (étage 10 dans 45,0 % des montées)
- Tour, Barde : facteur des monstres 0,849 → 0,865 (étage 10 dans 59,0 % des montées)
- Tour, Diplomate : facteur des monstres 1,088 → 1,100 (étage 10 dans 57,0 % des montées)
- Tour, Pugiliste : facteur des monstres 0,935 → 0,968 (étage 10 dans 63,0 % des montées)

## Passe 5 (graines à partir de 500016)

**1 critères tenus sur 6.** 15000 combats de duel (médiane 14 tours), 0 combats non finis.

### Les six critères (section 11.2)

- ❌ **1. Chaque classe entre 47 % et 53 % de victoires** : mage 45,0 %, pretre 59,3 %, invocateur 54,7 %, barde 53,7 %
- ❌ **2. Aucune case de la matrice hors de 40 % – 60 %** : guerrier contre mage 62,0 %, guerrier contre archer 71,3 %, guerrier contre pretre 38,7 %, guerrier contre diplomate 61,3 %, mage contre guerrier 36,0 %, mage contre pretre 39,3 %, voleur contre alchimiste 66,7 %, archer contre guerrier 37,3 %, archer contre pugiliste 38,0 %, pretre contre guerrier 66,0 %, pretre contre mage 66,7 %, pretre contre archer 62,0 %, pretre contre diplomate 64,0 %, alchimiste contre pugiliste 36,0 %, invocateur contre alchimiste 64,0 %, barde contre archer 61,3 %, barde contre diplomate 61,3 %, diplomate contre pretre 35,3 %, pugiliste contre alchimiste 65,3 %
- ❌ **3. Aucune route au-dessus de 55 % ni sous 40 % (Éventail : seulement pas au-dessus de 55 %)** : mage Ruée 60,8 %, pretre Ruée 34,4 %, pretre Réactive 59,3 %, alchimiste Ruée 30,1 %, diplomate Ruée 23,5 %, pugiliste Ruée 20,1 %
- ✅ **4. Chaque voie jouée dans 15 % des combats au moins, une Clé dans 60 %**
- ❌ **5. Longueur : médiane de 6 à 10 tours, 95 % finis avant le tour 20** : médiane 14 tours, 91,8 % des combats finis avant le tour 20
- ❌ **6. Tour : étage 10 dans 40 à 60 % des montées, étage 20 dans 5 à 10 %, à 5 points près entre classes** : guerrier étage 20 0,0 %, mage étage 10 64,0 %, voleur étage 20 3,0 %, archer étage 10 63,0 %, archer étage 20 3,0 %, pretre étage 10 68,0 %, alchimiste étage 10 65,0 %, invocateur étage 20 2,0 %, barde étage 10 66,0 %, barde étage 20 13,0 %, diplomate étage 10 64,0 %, pugiliste étage 10 64,0 %, écart entre classes : étage 10 de 52,0 % à 68,0 %, étage 20 de 0,0 % à 13,0 %

### La matrice des classes (taux de victoire de la ligne contre la colonne)

| | Guer | Mage | Vole | Arch | Prêt | Alch | Invo | Bard | Dipl | Pugi | **Moyenne** |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 50 | 62 | 55 | 71 | 39 | 47 | 51 | 43 | 61 | 48 | **52,8 %** |
| Mage | 36 | 50 | 44 | 51 | 39 | 57 | 45 | 44 | 40 | 44 | **45,0 %** |
| Voleur | 55 | 46 | 53 | 57 | 50 | 67 | 47 | 53 | 51 | 43 | **52,4 %** |
| Archer | 37 | 51 | 54 | 59 | 51 | 57 | 50 | 46 | 45 | 38 | **48,9 %** |
| Prêtre | 66 | 67 | 55 | 62 | 57 | 59 | 57 | 59 | 64 | 47 | **59,3 %** |
| Alchimiste | 54 | 45 | 42 | 45 | 46 | 53 | 47 | 47 | 55 | 36 | **47,0 %** |
| Invocateur | 54 | 59 | 54 | 55 | 52 | 64 | 44 | 59 | 55 | 50 | **54,7 %** |
| Barde | 55 | 52 | 50 | 61 | 51 | 59 | 54 | 50 | 61 | 43 | **53,7 %** |
| Diplomate | 43 | 53 | 53 | 49 | 35 | 50 | 50 | 45 | 51 | 43 | **47,3 %** |
| Pugiliste | 52 | 55 | 51 | 54 | 48 | 65 | 53 | 49 | 58 | 43 | **52,8 %** |

### Les trois routes, l'usage des voies et la Tour, par classe

| Classe | Ruée | Éventail | Réactive | Voie 1 | Voie 2 | Voie 3 | Voie 4 | Voie 5 | Clé | Tour : étage 10 | étage 20 | étage moyen |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 50,6 % | 12,0 % | 52,8 % | 41,3 % | 62,5 % | 44,3 % | 84,3 % | 70,9 % | 97,7 % | 56,0 % | 0,0 % | 10,6 |
| Mage | 60,8 % | 20,1 % | 45,0 % | 33,5 % | 57,7 % | 29,4 % | 51,9 % | 32,3 % | 88,8 % | 64,0 % | 8,0 % | 12,0 |
| Voleur | 51,6 % | 25,0 % | 52,4 % | 23,1 % | 29,1 % | 57,6 % | 43,7 % | 53,6 % | 90,9 % | 52,0 % | 3,0 % | 10,3 |
| Archer | 49,9 % | 15,5 % | 48,9 % | 53,2 % | 39,7 % | 59,1 % | 24,1 % | 25,9 % | 85,6 % | 63,0 % | 3,0 % | 11,2 |
| Prêtre | 34,4 % | 10,9 % | 59,3 % | 47,3 % | 67,3 % | 42,8 % | 71,6 % | 77,5 % | 95,3 % | 68,0 % | 8,0 % | 12,5 |
| Alchimiste | 30,1 % | 6,0 % | 47,0 % | 54,4 % | 51,1 % | 15,7 % | 50,5 % | 67,8 % | 93,1 % | 65,0 % | 5,0 % | 12,4 |
| Invocateur | 50,2 % | 19,0 % | 54,7 % | 44,3 % | 34,5 % | 40,5 % | 65,9 % | 29,6 % | 87,9 % | 52,0 % | 2,0 % | 10,2 |
| Barde | 43,4 % | 12,4 % | 53,7 % | 39,3 % | 35,0 % | 48,7 % | 51,0 % | 69,4 % | 90,7 % | 66,0 % | 13,0 % | 12,4 |
| Diplomate | 23,5 % | 6,4 % | 47,3 % | 17,1 % | 62,7 % | 87,6 % | 55,9 % | 74,9 % | 90,6 % | 64,0 % | 5,0 % | 11,8 |
| Pugiliste | 20,1 % | 5,9 % | 52,8 % | 47,8 % | 54,5 % | 63,7 % | 80,5 % | 20,1 % | 97,2 % | 64,0 % | 8,0 % | 11,8 |

### Boutons touchés, et pourquoi

- Règles globales (bouton 5, les PV de toutes les classes étant déjà à -40 %) : mort subite au tour 12 → 11, pas 0,15 → 0,175 (médiane 14 tours)
- k_classe Guerrier : 0,881 → 0,870 (52,8 % de victoires)
- k_classe Mage : 0,983 → 1,006 (45,0 % de victoires)
- k_classe Voleur : 0,834 → 0,816 (52,4 % de victoires)
- k_classe Archer : 0,915 → 0,920 (48,9 % de victoires)
- k_classe Prêtre : 0,902 → 0,883 (59,3 % de victoires)
- k_classe Alchimiste : 0,932 → 0,945 (47,0 % de victoires)
- k_classe Invocateur : 0,946 → 0,926 (54,7 % de victoires)
- k_classe Barde : 1,097 → 1,088 (53,7 % de victoires)
- k_classe Diplomate : 1,169 → 1,176 (47,3 % de victoires)
- k_classe Pugiliste : 1,009 → 0,996 (52,8 % de victoires)
- budgets des Clés (Prêtre) : +3 % (Ruée 34,4 %, une Clé jouée dans 95,3 % des combats)
- budgets de la Voie des Fumées (Alchimiste) : +3 % (jouée dans 15,7 % des combats)
- budgets des Clés (Alchimiste) : +3 % (Ruée 30,1 %, une Clé jouée dans 93,1 % des combats)
- budgets des Clés (Pugiliste) : +3 % (Ruée 20,1 %, une Clé jouée dans 97,2 % des combats)
- Tour : force des monstres au départ 0,326 → 0,348, en plus par étage 0,047 → 0,044 (étage 10 atteint dans 61,4 % des montées, étage 20 dans 5,5 %)
- Tour, Guerrier : facteur des monstres 1,713 → 1,676 (étage 10 dans 56,0 % des montées)
- Tour, Mage : facteur des monstres 0,660 → 0,667 (étage 10 dans 64,0 % des montées)
- Tour, Voleur : facteur des monstres 0,892 → 0,876 (étage 10 dans 52,0 % des montées)
- Tour, Prêtre : facteur des monstres 1,071 → 1,085 (étage 10 dans 68,0 % des montées)
- Tour, Alchimiste : facteur des monstres 0,949 → 0,955 (étage 10 dans 65,0 % des montées)
- Tour, Invocateur : facteur des monstres 0,983 → 0,964 (étage 10 dans 52,0 % des montées)
- Tour, Barde : facteur des monstres 0,865 → 0,881 (étage 10 dans 66,0 % des montées)
- Tour, Diplomate : facteur des monstres 1,100 → 1,112 (étage 10 dans 64,0 % des montées)
- Tour, Pugiliste : facteur des monstres 0,968 → 0,978 (étage 10 dans 64,0 % des montées)

## Passe 6 (graines à partir de 600019)

**0 critères tenus sur 6.** 15000 combats de duel (médiane 14 tours), 0 combats non finis.

### Les six critères (section 11.2)

- ❌ **1. Chaque classe entre 47 % et 53 % de victoires** : diplomate 46,5 %, pugiliste 57,5 %
- ❌ **2. Aucune case de la matrice hors de 40 % – 60 %** : guerrier contre mage 64,0 %, guerrier contre archer 67,3 %, guerrier contre pretre 39,3 %, voleur contre alchimiste 62,7 %, archer contre guerrier 36,0 %, archer contre pretre 39,3 %, pretre contre guerrier 60,7 %, alchimiste contre voleur 38,0 %, pugiliste contre mage 64,0 %, pugiliste contre voleur 60,7 %, pugiliste contre archer 60,7 %, pugiliste contre alchimiste 64,0 %, pugiliste contre diplomate 63,3 %
- ❌ **3. Aucune route au-dessus de 55 % ni sous 40 % (Éventail : seulement pas au-dessus de 55 %)** : mage Ruée 58,6 %, pretre Ruée 37,5 %, alchimiste Ruée 30,6 %, diplomate Ruée 23,3 %, pugiliste Ruée 14,6 %, pugiliste Réactive 57,5 %
- ❌ **4. Chaque voie jouée dans 15 % des combats au moins, une Clé dans 60 %** : alchimiste voie 3 13,5 %
- ❌ **5. Longueur : médiane de 6 à 10 tours, 95 % finis avant le tour 20** : médiane 14 tours
- ❌ **6. Tour : étage 10 dans 40 à 60 % des montées, étage 20 dans 5 à 10 %, à 5 points près entre classes** : guerrier étage 10 66,0 %, guerrier étage 20 2,0 %, mage étage 10 66,0 %, voleur étage 10 69,0 %, voleur étage 20 1,0 %, archer étage 10 61,0 %, archer étage 20 4,0 %, pretre étage 10 68,0 %, pretre étage 20 13,0 %, alchimiste étage 10 74,0 %, barde étage 10 65,0 %, barde étage 20 14,0 %, diplomate étage 10 63,0 %, pugiliste étage 20 4,0 %, écart entre classes : étage 10 de 55,0 % à 74,0 %, étage 20 de 1,0 % à 14,0 %

### La matrice des classes (taux de victoire de la ligne contre la colonne)

| | Guer | Mage | Vole | Arch | Prêt | Alch | Invo | Bard | Dipl | Pugi | **Moyenne** |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 47 | 64 | 53 | 67 | 39 | 43 | 59 | 45 | 52 | 49 | **51,9 %** |
| Mage | 48 | 55 | 47 | 53 | 45 | 57 | 48 | 41 | 59 | 49 | **50,1 %** |
| Voleur | 45 | 48 | 52 | 55 | 43 | 63 | 51 | 55 | 53 | 53 | **51,7 %** |
| Archer | 36 | 52 | 54 | 52 | 39 | 59 | 45 | 42 | 56 | 41 | **47,7 %** |
| Prêtre | 61 | 56 | 51 | 55 | 44 | 59 | 58 | 45 | 57 | 43 | **52,9 %** |
| Alchimiste | 56 | 50 | 38 | 43 | 48 | 56 | 48 | 47 | 59 | 41 | **48,6 %** |
| Invocateur | 48 | 52 | 51 | 51 | 43 | 59 | 53 | 56 | 51 | 56 | **52,0 %** |
| Barde | 53 | 53 | 53 | 60 | 47 | 51 | 50 | 47 | 50 | 47 | **51,2 %** |
| Diplomate | 47 | 49 | 50 | 47 | 44 | 43 | 51 | 43 | 47 | 43 | **46,5 %** |
| Pugiliste | 57 | 64 | 61 | 61 | 47 | 64 | 57 | 51 | 63 | 51 | **57,5 %** |

### Les trois routes, l'usage des voies et la Tour, par classe

| Classe | Ruée | Éventail | Réactive | Voie 1 | Voie 2 | Voie 3 | Voie 4 | Voie 5 | Clé | Tour : étage 10 | étage 20 | étage moyen |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 49,3 % | 12,3 % | 51,9 % | 39,9 % | 56,9 % | 46,6 % | 87,6 % | 61,5 % | 97,1 % | 66,0 % | 2,0 % | 11,1 |
| Mage | 58,6 % | 16,0 % | 50,1 % | 37,2 % | 52,5 % | 40,8 % | 45,3 % | 32,8 % | 87,1 % | 66,0 % | 8,0 % | 12,2 |
| Voleur | 51,9 % | 26,0 % | 51,7 % | 26,7 % | 25,9 % | 55,3 % | 45,7 % | 49,7 % | 90,2 % | 69,0 % | 1,0 % | 10,9 |
| Archer | 47,0 % | 15,8 % | 47,7 % | 47,4 % | 47,0 % | 54,8 % | 24,4 % | 22,9 % | 85,3 % | 61,0 % | 4,0 % | 11,1 |
| Prêtre | 37,5 % | 11,1 % | 52,9 % | 44,8 % | 71,7 % | 36,9 % | 68,7 % | 73,9 % | 93,5 % | 68,0 % | 13,0 % | 12,6 |
| Alchimiste | 30,6 % | 7,2 % | 48,6 % | 50,8 % | 49,7 % | 13,5 % | 49,1 % | 68,6 % | 93,2 % | 74,0 % | 8,0 % | 12,5 |
| Invocateur | 48,6 % | 18,8 % | 52,0 % | 36,9 % | 29,9 % | 43,7 % | 62,0 % | 28,5 % | 85,5 % | 55,0 % | 8,0 % | 10,8 |
| Barde | 40,3 % | 12,6 % | 51,2 % | 42,7 % | 40,8 % | 46,7 % | 50,6 % | 60,9 % | 90,5 % | 65,0 % | 14,0 % | 12,1 |
| Diplomate | 23,3 % | 7,5 % | 46,5 % | 17,3 % | 55,1 % | 86,7 % | 56,1 % | 76,9 % | 91,9 % | 63,0 % | 5,0 % | 11,4 |
| Pugiliste | 14,6 % | 5,0 % | 57,5 % | 36,2 % | 49,2 % | 58,7 % | 90,9 % | 17,5 % | 95,1 % | 60,0 % | 4,0 % | 10,9 |

### Boutons touchés, et pourquoi

- Règles globales (bouton 5, les PV de toutes les classes étant déjà à -40 %) : mort subite au tour 11 → 10, pas 0,175 → 0,2 (médiane 14 tours)
- k_classe Guerrier : 0,870 → 0,863 (51,9 % de victoires)
- k_classe Voleur : 0,816 → 0,803 (51,7 % de victoires)
- k_classe Archer : 0,920 → 0,929 (47,7 % de victoires)
- k_classe Prêtre : 0,883 → 0,877 (52,9 % de victoires)
- k_classe Alchimiste : 0,945 → 0,951 (48,6 % de victoires)
- k_classe Invocateur : 0,926 → 0,918 (52,0 % de victoires)
- k_classe Barde : 1,088 → 1,085 (51,2 % de victoires)
- k_classe Diplomate : 1,176 → 1,186 (46,5 % de victoires)
- k_classe Pugiliste : 0,996 → 0,962 (57,5 % de victoires)
- budgets de la Voie des Fumées (Alchimiste) : +3 % (jouée dans 13,5 % des combats)
- budgets des Clés (Barde) : +3 % (Ruée 40,2 %, une Clé jouée dans 90,5 % des combats)
- budgets des Clés (Pugiliste) : +3 % (Ruée 14,6 %, une Clé jouée dans 95,1 % des combats)
- Tour : force des monstres au départ 0,348 → 0,379, en plus par étage 0,044 → 0,044 (étage 10 atteint dans 64,7 % des montées, étage 20 dans 6,7 %)
- Tour, Voleur : facteur des monstres 0,876 → 0,879 (étage 10 dans 69,0 % des montées)
- Tour, Archer : facteur des monstres 0,695 → 0,675 (étage 10 dans 61,0 % des montées)
- Tour, Prêtre : facteur des monstres 1,085 → 1,092 (étage 10 dans 68,0 % des montées)
- Tour, Alchimiste : facteur des monstres 0,955 → 0,973 (étage 10 dans 74,0 % des montées)
- Tour, Invocateur : facteur des monstres 0,964 → 0,946 (étage 10 dans 55,0 % des montées)
- Tour, Pugiliste : facteur des monstres 0,978 → 0,969 (étage 10 dans 60,0 % des montées)

## Passe 7 (graines à partir de 700022)

**0 critères tenus sur 6.** 15000 combats de duel (médiane 13 tours), 0 combats non finis.

### Les six critères (section 11.2)

- ❌ **1. Chaque classe entre 47 % et 53 % de victoires** : voleur 47,0 %, pretre 60,6 %, alchimiste 46,7 %, invocateur 46,9 %, barde 54,7 %, diplomate 45,7 %, pugiliste 54,3 %
- ❌ **2. Aucune case de la matrice hors de 40 % – 60 %** : guerrier contre mage 61,3 %, guerrier contre pretre 32,0 %, voleur contre pretre 38,0 %, archer contre guerrier 39,3 %, archer contre alchimiste 64,0 %, pretre contre mage 64,0 %, pretre contre voleur 63,3 %, pretre contre archer 64,7 %, pretre contre invocateur 70,0 %, pretre contre diplomate 68,7 %, alchimiste contre guerrier 60,7 %, invocateur contre pretre 38,0 %, barde contre voleur 60,7 %, diplomate contre pretre 34,0 %, pugiliste contre alchimiste 61,3 %
- ❌ **3. Aucune route au-dessus de 55 % ni sous 40 % (Éventail : seulement pas au-dessus de 55 %)** : mage Ruée 63,6 %, pretre Ruée 34,8 %, pretre Réactive 60,6 %, alchimiste Ruée 32,9 %, diplomate Ruée 17,0 %, pugiliste Ruée 55,3 %
- ❌ **4. Chaque voie jouée dans 15 % des combats au moins, une Clé dans 60 %** : alchimiste voie 3 11,5 %
- ❌ **5. Longueur : médiane de 6 à 10 tours, 95 % finis avant le tour 20** : médiane 13 tours
- ❌ **6. Tour : étage 10 dans 40 à 60 % des montées, étage 20 dans 5 à 10 %, à 5 points près entre classes** : guerrier étage 20 2,0 %, voleur étage 20 1,0 %, archer étage 10 61,0 %, pretre étage 10 69,0 %, alchimiste étage 10 67,0 %, invocateur étage 20 2,0 %, barde étage 20 14,0 %, diplomate étage 20 3,0 %, pugiliste étage 10 66,0 %, pugiliste étage 20 2,0 %, écart entre classes : étage 10 de 47,0 % à 69,0 %, étage 20 de 1,0 % à 14,0 %

### La matrice des classes (taux de victoire de la ligne contre la colonne)

| | Guer | Mage | Vole | Arch | Prêt | Alch | Invo | Bard | Dipl | Pugi | **Moyenne** |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 47 | 61 | 48 | 60 | 32 | 47 | 45 | 47 | 45 | 47 | **48,0 %** |
| Mage | 43 | 54 | 48 | 49 | 42 | 55 | 49 | 45 | 55 | 51 | **49,1 %** |
| Voleur | 48 | 52 | 49 | 45 | 38 | 54 | 49 | 49 | 45 | 41 | **47,0 %** |
| Archer | 39 | 51 | 48 | 51 | 43 | 64 | 51 | 48 | 55 | 44 | **49,5 %** |
| Prêtre | 59 | 64 | 63 | 65 | 49 | 57 | 70 | 51 | 69 | 59 | **60,6 %** |
| Alchimiste | 61 | 42 | 41 | 43 | 40 | 43 | 49 | 48 | 52 | 48 | **46,7 %** |
| Invocateur | 47 | 47 | 49 | 43 | 38 | 55 | 51 | 48 | 47 | 44 | **46,9 %** |
| Barde | 55 | 55 | 61 | 58 | 56 | 55 | 55 | 45 | 57 | 51 | **54,7 %** |
| Diplomate | 47 | 45 | 51 | 43 | 34 | 52 | 49 | 47 | 49 | 41 | **45,7 %** |
| Pugiliste | 55 | 51 | 55 | 55 | 49 | 61 | 52 | 59 | 55 | 50 | **54,3 %** |

### Les trois routes, l'usage des voies et la Tour, par classe

| Classe | Ruée | Éventail | Réactive | Voie 1 | Voie 2 | Voie 3 | Voie 4 | Voie 5 | Clé | Tour : étage 10 | étage 20 | étage moyen |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 46,9 % | 10,0 % | 48,0 % | 39,1 % | 54,3 % | 42,5 % | 84,3 % | 58,7 % | 97,1 % | 51,0 % | 2,0 % | 10,4 |
| Mage | 63,6 % | 19,6 % | 49,1 % | 37,7 % | 54,4 % | 36,0 % | 44,9 % | 27,3 % | 87,1 % | 60,0 % | 10,0 % | 11,6 |
| Voleur | 42,8 % | 19,0 % | 47,0 % | 24,1 % | 36,5 % | 54,7 % | 37,5 % | 48,4 % | 88,4 % | 47,0 % | 1,0 % | 9,6 |
| Archer | 50,6 % | 19,1 % | 49,5 % | 47,0 % | 42,1 % | 50,5 % | 30,2 % | 21,7 % | 84,2 % | 61,0 % | 8,0 % | 11,4 |
| Prêtre | 34,8 % | 13,4 % | 60,6 % | 42,2 % | 74,0 % | 25,6 % | 72,7 % | 70,1 % | 93,9 % | 69,0 % | 5,0 % | 12,0 |
| Alchimiste | 32,9 % | 7,4 % | 46,7 % | 56,3 % | 50,0 % | 11,5 % | 44,5 % | 69,3 % | 93,6 % | 67,0 % | 8,0 % | 11,9 |
| Invocateur | 40,4 % | 14,0 % | 46,9 % | 42,5 % | 26,8 % | 45,8 % | 57,9 % | 29,3 % | 84,8 % | 50,0 % | 2,0 % | 10,2 |
| Barde | 45,9 % | 14,5 % | 54,7 % | 39,4 % | 38,0 % | 40,0 % | 52,7 % | 68,0 % | 89,2 % | 59,0 % | 14,0 % | 12,1 |
| Diplomate | 17,0 % | 4,9 % | 45,7 % | 17,3 % | 42,8 % | 86,3 % | 47,3 % | 82,5 % | 92,1 % | 60,0 % | 3,0 % | 11,3 |
| Pugiliste | 55,3 % | 5,1 % | 54,3 % | 40,1 % | 44,6 % | 57,5 % | 86,4 % | 20,6 % | 95,7 % | 66,0 % | 2,0 % | 11,1 |

### Boutons touchés, et pourquoi

- PV de toutes les classes : ×0,600 → ×0,510 des PV de la spécification (médiane 13 tours, 98,3 % finis avant le tour 20 ; on vise 10 tours)
- k_classe Guerrier : 0,863 → 0,866 (48,0 % de victoires)
- k_classe Mage : 1,006 → 1,010 (49,1 % de victoires)
- k_classe Voleur : 0,803 → 0,814 (47,0 % de victoires)
- k_classe Prêtre : 0,877 → 0,857 (60,6 % de victoires)
- k_classe Alchimiste : 0,951 → 0,965 (46,7 % de victoires)
- k_classe Invocateur : 0,918 → 0,924 (46,9 % de victoires)
- k_classe Barde : 1,085 → 1,074 (54,7 % de victoires)
- k_classe Diplomate : 1,186 → 1,197 (45,7 % de victoires)
- k_classe Pugiliste : 0,962 → 0,944 (54,3 % de victoires)
- budgets de la Voie des Fumées (Alchimiste) : +3 % (jouée dans 11,5 % des combats)
- budgets des Clés (Invocateur) : +3 % (Ruée 40,4 %, une Clé jouée dans 84,8 % des combats)
- budgets des Clés (Pugiliste) : -3 % (Ruée 55,2 %, une Clé jouée dans 95,7 % des combats)
- Tour : force des monstres au départ 0,379 → 0,399, en plus par étage 0,044 → 0,042 (étage 10 atteint dans 59,0 % des montées, étage 20 dans 5,5 %)
- Tour, Guerrier : facteur des monstres 1,676 → 1,623 (étage 10 dans 51,0 % des montées)
- Tour, Voleur : facteur des monstres 0,879 → 0,874 (étage 10 dans 47,0 % des montées)
- Tour, Prêtre : facteur des monstres 1,092 → 1,114 (étage 10 dans 69,0 % des montées)
- Tour, Alchimiste : facteur des monstres 0,973 → 0,989 (étage 10 dans 67,0 % des montées)
- Tour, Invocateur : facteur des monstres 0,946 → 0,928 (étage 10 dans 50,0 % des montées)
- Tour, Pugiliste : facteur des monstres 0,969 → 0,976 (étage 10 dans 66,0 % des montées)

## Passe 8 (graines à partir de 800025)

**0 critères tenus sur 6.** 15000 combats de duel (médiane 12 tours), 0 combats non finis.

### Les six critères (section 11.2)

- ❌ **1. Chaque classe entre 47 % et 53 % de victoires** : archer 54,4 %, pretre 57,1 %, alchimiste 54,5 %, invocateur 44,7 %, barde 56,2 %
- ❌ **2. Aucune case de la matrice hors de 40 % – 60 %** : guerrier contre pretre 38,0 %, guerrier contre alchimiste 37,3 %, guerrier contre pugiliste 62,0 %, mage contre pretre 36,7 %, archer contre voleur 62,0 %, archer contre invocateur 70,7 %, pretre contre guerrier 64,0 %, pretre contre voleur 60,7 %, pretre contre invocateur 64,7 %, pretre contre diplomate 60,7 %, alchimiste contre guerrier 66,7 %, alchimiste contre invocateur 60,7 %, invocateur contre archer 37,3 %, invocateur contre pretre 36,7 %, barde contre guerrier 64,7 %, barde contre mage 62,0 %, barde contre invocateur 62,0 %, pugiliste contre invocateur 62,0 %
- ❌ **3. Aucune route au-dessus de 55 % ni sous 40 % (Éventail : seulement pas au-dessus de 55 %)** : mage Ruée 67,8 %, voleur Ruée 39,4 %, archer Ruée 56,3 %, pretre Réactive 57,1 %, alchimiste Ruée 31,8 %, barde Réactive 56,2 %, diplomate Ruée 20,1 %
- ❌ **4. Chaque voie jouée dans 15 % des combats au moins, une Clé dans 60 %** : alchimiste voie 3 12,3 %
- ❌ **5. Longueur : médiane de 6 à 10 tours, 95 % finis avant le tour 20** : médiane 12 tours
- ❌ **6. Tour : étage 10 dans 40 à 60 % des montées, étage 20 dans 5 à 10 %, à 5 points près entre classes** : guerrier étage 10 37,0 %, guerrier étage 20 0,0 %, mage étage 10 63,0 %, mage étage 20 15,0 %, voleur étage 20 0,0 %, archer étage 10 61,0 %, archer étage 20 12,0 %, alchimiste étage 20 3,0 %, invocateur étage 10 35,0 %, invocateur étage 20 1,0 %, barde étage 20 4,0 %, diplomate étage 20 4,0 %, pugiliste étage 20 3,0 %, écart entre classes : étage 10 de 35,0 % à 63,0 %, étage 20 de 0,0 % à 15,0 %

### La matrice des classes (taux de victoire de la ligne contre la colonne)

| | Guer | Mage | Vole | Arch | Prêt | Alch | Invo | Bard | Dipl | Pugi | **Moyenne** |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 52 | 51 | 53 | 57 | 38 | 37 | 54 | 41 | 50 | 62 | **49,6 %** |
| Mage | 45 | 47 | 56 | 53 | 37 | 57 | 60 | 60 | 51 | 51 | **51,5 %** |
| Voleur | 49 | 46 | 47 | 41 | 42 | 55 | 54 | 45 | 44 | 47 | **47,1 %** |
| Archer | 40 | 49 | 62 | 52 | 49 | 59 | 71 | 58 | 53 | 51 | **54,4 %** |
| Prêtre | 64 | 56 | 61 | 57 | 54 | 51 | 65 | 57 | 61 | 47 | **57,1 %** |
| Alchimiste | 67 | 48 | 53 | 41 | 54 | 52 | 61 | 60 | 60 | 50 | **54,5 %** |
| Invocateur | 49 | 41 | 51 | 37 | 37 | 45 | 51 | 41 | 47 | 48 | **44,7 %** |
| Barde | 65 | 62 | 48 | 55 | 58 | 47 | 62 | 56 | 58 | 51 | **56,2 %** |
| Diplomate | 55 | 45 | 55 | 46 | 41 | 43 | 49 | 45 | 53 | 51 | **48,3 %** |
| Pugiliste | 45 | 45 | 53 | 51 | 45 | 53 | 62 | 44 | 56 | 47 | **50,2 %** |

### Les trois routes, l'usage des voies et la Tour, par classe

| Classe | Ruée | Éventail | Réactive | Voie 1 | Voie 2 | Voie 3 | Voie 4 | Voie 5 | Clé | Tour : étage 10 | étage 20 | étage moyen |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 46,6 % | 9,0 % | 49,6 % | 41,9 % | 53,1 % | 36,6 % | 82,7 % | 59,1 % | 95,4 % | 37,0 % | 0,0 % | 8,8 |
| Mage | 67,8 % | 25,3 % | 51,5 % | 41,9 % | 52,3 % | 26,9 % | 41,9 % | 24,9 % | 82,2 % | 63,0 % | 15,0 % | 12,1 |
| Voleur | 39,4 % | 21,1 % | 47,1 % | 23,4 % | 26,7 % | 50,6 % | 30,5 % | 54,7 % | 83,9 % | 46,0 % | 0,0 % | 9,4 |
| Archer | 56,3 % | 22,8 % | 54,4 % | 45,1 % | 41,7 % | 49,1 % | 26,7 % | 24,3 % | 80,5 % | 61,0 % | 12,0 % | 11,6 |
| Prêtre | 40,4 % | 16,4 % | 57,1 % | 38,3 % | 66,5 % | 32,7 % | 67,1 % | 69,7 % | 90,5 % | 55,0 % | 8,0 % | 11,5 |
| Alchimiste | 31,8 % | 10,1 % | 54,5 % | 48,5 % | 44,8 % | 12,3 % | 44,2 % | 74,1 % | 90,7 % | 42,0 % | 3,0 % | 9,8 |
| Invocateur | 44,0 % | 17,8 % | 44,7 % | 39,9 % | 23,8 % | 43,3 % | 53,9 % | 22,1 % | 78,2 % | 35,0 % | 1,0 % | 8,9 |
| Barde | 45,0 % | 18,4 % | 56,2 % | 42,7 % | 35,5 % | 41,5 % | 45,3 % | 60,5 % | 84,6 % | 44,0 % | 4,0 % | 10,4 |
| Diplomate | 20,1 % | 7,0 % | 48,3 % | 17,6 % | 60,5 % | 87,5 % | 49,3 % | 75,0 % | 89,5 % | 54,0 % | 4,0 % | 10,5 |
| Pugiliste | 53,5 % | 5,1 % | 50,2 % | 40,3 % | 43,3 % | 58,3 % | 85,3 % | 22,1 % | 94,1 % | 48,0 % | 3,0 % | 10,1 |

### Boutons touchés, et pourquoi

- PV de toutes les classes : ×0,510 → ×0,450 des PV de la spécification (médiane 12 tours, 98,9 % finis avant le tour 20 ; on vise 10 tours)
- k_classe Mage : 1,010 → 1,006 (51,5 % de victoires)
- k_classe Voleur : 0,814 → 0,825 (47,1 % de victoires)
- k_classe Archer : 0,929 → 0,920 (54,4 % de victoires)
- k_classe Prêtre : 0,857 → 0,843 (57,1 % de victoires)
- k_classe Alchimiste : 0,965 → 0,955 (54,5 % de victoires)
- k_classe Invocateur : 0,924 → 0,935 (44,7 % de victoires)
- k_classe Barde : 1,074 → 1,059 (56,2 % de victoires)
- k_classe Diplomate : 1,197 → 1,200 (48,3 % de victoires)
- budgets des Clés (Voleur) : +3 % (Ruée 39,4 %, une Clé jouée dans 83,9 % des combats)
- budgets des Clés (Archer) : -3 % (Ruée 56,2 %, une Clé jouée dans 80,5 % des combats)
- budgets de la Voie des Fumées (Alchimiste) : +3 % (jouée dans 12,3 % des combats)
- Tour : force des monstres au départ 0,399 → 0,399, en plus par étage 0,042 → 0,039 (étage 10 atteint dans 48,5 % des montées, étage 20 dans 5,0 %)
- Tour, Guerrier : facteur des monstres 1,623 → 1,548 (étage 10 dans 37,0 % des montées)
- Tour, Mage : facteur des monstres 0,667 → 0,705 (étage 10 dans 63,0 % des montées)
- Tour, Voleur : facteur des monstres 0,874 → 0,872 (étage 10 dans 46,0 % des montées)
- Tour, Archer : facteur des monstres 0,675 → 0,709 (étage 10 dans 61,0 % des montées)
- Tour, Prêtre : facteur des monstres 1,114 → 1,129 (étage 10 dans 55,0 % des montées)
- Tour, Alchimiste : facteur des monstres 0,989 → 0,982 (étage 10 dans 42,0 % des montées)
- Tour, Invocateur : facteur des monstres 0,928 → 0,903 (étage 10 dans 35,0 % des montées)
- Tour, Barde : facteur des monstres 0,881 → 0,873 (étage 10 dans 44,0 % des montées)
- Tour, Diplomate : facteur des monstres 1,112 → 1,136 (étage 10 dans 54,0 % des montées)

## Passe 9 (graines à partir de 900028)

**0 critères tenus sur 6.** 15000 combats de duel (médiane 11 tours), 0 combats non finis.

### Les six critères (section 11.2)

- ❌ **1. Chaque classe entre 47 % et 53 % de victoires** : mage 54,7 %, pretre 54,4 %, alchimiste 42,9 %, barde 44,7 %
- ❌ **2. Aucune case de la matrice hors de 40 % – 60 %** : guerrier contre archer 62,7 %, guerrier contre pretre 39,3 %, guerrier contre alchimiste 38,7 %, mage contre invocateur 62,7 %, voleur contre mage 38,7 %, archer contre alchimiste 66,7 %, archer contre invocateur 60,7 %, pretre contre guerrier 61,3 %, alchimiste contre mage 39,3 %, alchimiste contre voleur 38,0 %, alchimiste contre archer 38,0 %, alchimiste contre diplomate 37,3 %, barde contre mage 35,3 %, barde contre diplomate 38,7 %
- ❌ **3. Aucune route au-dessus de 55 % ni sous 40 % (Éventail : seulement pas au-dessus de 55 %)** : mage Ruée 66,0 %, pretre Ruée 35,0 %, alchimiste Ruée 27,1 %, barde Ruée 35,1 %, diplomate Ruée 21,4 %
- ❌ **4. Chaque voie jouée dans 15 % des combats au moins, une Clé dans 60 %** : alchimiste voie 3 11,6 %
- ❌ **5. Longueur : médiane de 6 à 10 tours, 95 % finis avant le tour 20** : médiane 11 tours
- ❌ **6. Tour : étage 10 dans 40 à 60 % des montées, étage 20 dans 5 à 10 %, à 5 points près entre classes** : guerrier étage 20 0,0 %, voleur étage 20 1,0 %, pretre étage 20 4,0 %, alchimiste étage 20 3,0 %, invocateur étage 20 3,0 %, barde étage 10 39,0 %, barde étage 20 2,0 %, diplomate étage 10 39,0 %, diplomate étage 20 0,0 %, pugiliste étage 20 1,0 %, écart entre classes : étage 10 de 39,0 % à 57,0 %, étage 20 de 0,0 % à 8,0 %

### La matrice des classes (taux de victoire de la ligne contre la colonne)

| | Guer | Mage | Vole | Arch | Prêt | Alch | Invo | Bard | Dipl | Pugi | **Moyenne** |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 55 | 55 | 53 | 63 | 39 | 39 | 42 | 45 | 51 | 54 | **49,5 %** |
| Mage | 50 | 51 | 57 | 49 | 48 | 57 | 63 | 59 | 57 | 55 | **54,7 %** |
| Voleur | 51 | 39 | 47 | 56 | 53 | 53 | 52 | 52 | 51 | 49 | **50,2 %** |
| Archer | 40 | 46 | 51 | 51 | 44 | 67 | 61 | 49 | 50 | 55 | **51,3 %** |
| Prêtre | 61 | 50 | 52 | 51 | 53 | 59 | 53 | 50 | 56 | 57 | **54,4 %** |
| Alchimiste | 54 | 39 | 38 | 38 | 43 | 44 | 41 | 51 | 37 | 44 | **42,9 %** |
| Invocateur | 55 | 40 | 43 | 54 | 46 | 54 | 49 | 59 | 47 | 49 | **49,6 %** |
| Barde | 51 | 35 | 45 | 43 | 55 | 41 | 43 | 46 | 39 | 49 | **44,7 %** |
| Diplomate | 47 | 44 | 48 | 53 | 47 | 52 | 52 | 56 | 56 | 53 | **50,8 %** |
| Pugiliste | 47 | 51 | 53 | 55 | 50 | 53 | 53 | 53 | 52 | 51 | **51,9 %** |

### Les trois routes, l'usage des voies et la Tour, par classe

| Classe | Ruée | Éventail | Réactive | Voie 1 | Voie 2 | Voie 3 | Voie 4 | Voie 5 | Clé | Tour : étage 10 | étage 20 | étage moyen |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 48,1 % | 11,8 % | 49,5 % | 38,5 % | 50,2 % | 34,0 % | 85,9 % | 53,5 % | 96,3 % | 53,0 % | 0,0 % | 10,2 |
| Mage | 66,0 % | 20,1 % | 54,7 % | 40,4 % | 45,6 % | 39,1 % | 38,3 % | 23,2 % | 82,0 % | 57,0 % | 6,0 % | 11,2 |
| Voleur | 42,8 % | 18,0 % | 50,2 % | 16,7 % | 23,8 % | 47,7 % | 30,6 % | 57,7 % | 86,8 % | 49,0 % | 1,0 % | 9,6 |
| Archer | 53,3 % | 17,9 % | 51,3 % | 40,8 % | 45,4 % | 48,1 % | 23,0 % | 21,2 % | 75,2 % | 56,0 % | 8,0 % | 11,0 |
| Prêtre | 35,0 % | 10,9 % | 54,4 % | 34,5 % | 67,4 % | 27,4 % | 60,9 % | 68,5 % | 90,5 % | 44,0 % | 4,0 % | 9,8 |
| Alchimiste | 27,1 % | 7,4 % | 42,9 % | 53,5 % | 43,5 % | 11,6 % | 40,1 % | 64,4 % | 90,7 % | 52,0 % | 3,0 % | 10,4 |
| Invocateur | 42,4 % | 13,1 % | 49,6 % | 38,8 % | 20,5 % | 37,4 % | 58,9 % | 17,8 % | 76,9 % | 46,0 % | 3,0 % | 9,9 |
| Barde | 35,1 % | 12,5 % | 44,7 % | 39,9 % | 30,9 % | 41,4 % | 39,0 % | 61,7 % | 86,1 % | 39,0 % | 2,0 % | 9,4 |
| Diplomate | 21,4 % | 7,1 % | 50,8 % | 16,9 % | 50,2 % | 81,1 % | 47,1 % | 72,9 % | 86,9 % | 39,0 % | 0,0 % | 9,2 |
| Pugiliste | 49,1 % | 4,6 % | 51,9 % | 35,3 % | 42,5 % | 53,5 % | 84,1 % | 17,0 % | 93,7 % | 42,0 % | 1,0 % | 9,3 |

### Boutons touchés, et pourquoi

- k_classe Mage : 1,006 → 0,996 (54,7 % de victoires)
- k_classe Archer : 0,920 → 0,917 (51,3 % de victoires)
- k_classe Prêtre : 0,843 → 0,835 (54,4 % de victoires)
- k_classe Alchimiste : 0,955 → 0,963 (42,9 % de victoires)
- k_classe Barde : 1,059 → 1,065 (44,7 % de victoires)
- k_classe Diplomate : 1,200 → 1,199 (50,8 % de victoires)
- k_classe Pugiliste : 0,944 → 0,936 (51,9 % de victoires)
- budgets de la Voie des Ombres (Voleur) : +3 % (jouée dans 16,7 % des combats)
- budgets de la Voie de l'Intimidation (Diplomate) : +3 % (jouée dans 16,9 % des combats)
- Tour : force des monstres au départ 0,399 → 0,399, en plus par étage 0,039 → 0,033 (étage 10 atteint dans 47,7 % des montées, étage 20 dans 2,8 %)
- Tour, Guerrier : facteur des monstres 1,548 → 1,564 (étage 10 dans 53,0 % des montées)
- Tour, Mage : facteur des monstres 0,705 → 0,732 (étage 10 dans 57,0 % des montées)
- Tour, Archer : facteur des monstres 0,709 → 0,732 (étage 10 dans 56,0 % des montées)
- Tour, Prêtre : facteur des monstres 1,129 → 1,125 (étage 10 dans 44,0 % des montées)
- Tour, Alchimiste : facteur des monstres 0,982 → 0,984 (étage 10 dans 52,0 % des montées)
- Tour, Barde : facteur des monstres 0,873 → 0,858 (étage 10 dans 39,0 % des montées)
- Tour, Diplomate : facteur des monstres 1,136 → 1,116 (étage 10 dans 39,0 % des montées)
- Tour, Pugiliste : facteur des monstres 0,976 → 0,973 (étage 10 dans 42,0 % des montées)

## Passe 10 (graines à partir de 1000031)

**0 critères tenus sur 6.** 15000 combats de duel (médiane 11 tours), 0 combats non finis.

### Les six critères (section 11.2)

- ❌ **1. Chaque classe entre 47 % et 53 % de victoires** : invocateur 46,4 %, diplomate 54,1 %, pugiliste 47,0 %
- ❌ **2. Aucune case de la matrice hors de 40 % – 60 %** : guerrier contre archer 61,3 %, voleur contre mage 36,7 %, voleur contre archer 38,7 %, alchimiste contre guerrier 62,7 %, alchimiste contre archer 36,0 %, invocateur contre archer 35,3 %, diplomate contre voleur 67,3 %
- ❌ **3. Aucune route au-dessus de 55 % ni sous 40 % (Éventail : seulement pas au-dessus de 55 %)** : mage Ruée 68,1 %, archer Ruée 55,8 %, pretre Ruée 37,1 %, alchimiste Ruée 34,8 %, barde Ruée 39,5 %, diplomate Ruée 26,5 %, pugiliste Ruée 55,5 %
- ❌ **4. Chaque voie jouée dans 15 % des combats au moins, une Clé dans 60 %** : alchimiste voie 3 7,5 %
- ❌ **5. Longueur : médiane de 6 à 10 tours, 95 % finis avant le tour 20** : médiane 11 tours
- ❌ **6. Tour : étage 10 dans 40 à 60 % des montées, étage 20 dans 5 à 10 %, à 5 points près entre classes** : guerrier étage 20 1,0 %, voleur étage 10 37,0 %, voleur étage 20 2,0 %, archer étage 20 4,0 %, pugiliste étage 20 2,0 %, écart entre classes : étage 10 de 37,0 % à 57,0 %, étage 20 de 1,0 % à 8,0 %

### La matrice des classes (taux de victoire de la ligne contre la colonne)

| | Guer | Mage | Vole | Arch | Prêt | Alch | Invo | Bard | Dipl | Pugi | **Moyenne** |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 49 | 57 | 56 | 61 | 47 | 45 | 55 | 45 | 43 | 57 | **51,5 %** |
| Mage | 47 | 52 | 56 | 45 | 43 | 54 | 57 | 47 | 43 | 57 | **50,1 %** |
| Voleur | 43 | 37 | 56 | 39 | 43 | 60 | 47 | 54 | 43 | 49 | **47,0 %** |
| Archer | 40 | 53 | 54 | 51 | 44 | 53 | 56 | 48 | 42 | 47 | **48,9 %** |
| Prêtre | 57 | 54 | 58 | 48 | 41 | 47 | 51 | 44 | 55 | 46 | **50,1 %** |
| Alchimiste | 63 | 40 | 49 | 36 | 49 | 51 | 55 | 54 | 44 | 53 | **49,3 %** |
| Invocateur | 49 | 47 | 47 | 35 | 49 | 47 | 49 | 54 | 41 | 46 | **46,4 %** |
| Barde | 57 | 43 | 54 | 41 | 47 | 48 | 47 | 50 | 47 | 51 | **48,6 %** |
| Diplomate | 48 | 55 | 67 | 55 | 41 | 58 | 54 | 53 | 52 | 57 | **54,1 %** |
| Pugiliste | 43 | 43 | 55 | 51 | 47 | 43 | 44 | 47 | 48 | 49 | **47,0 %** |

### Les trois routes, l'usage des voies et la Tour, par classe

| Classe | Ruée | Éventail | Réactive | Voie 1 | Voie 2 | Voie 3 | Voie 4 | Voie 5 | Clé | Tour : étage 10 | étage 20 | étage moyen |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 48,8 % | 11,1 % | 51,5 % | 43,6 % | 48,4 % | 30,9 % | 80,1 % | 62,3 % | 94,8 % | 49,0 % | 1,0 % | 10,1 |
| Mage | 68,1 % | 22,4 % | 50,1 % | 33,2 % | 47,6 % | 37,3 % | 46,0 % | 24,0 % | 79,5 % | 52,0 % | 8,0 % | 10,5 |
| Voleur | 44,3 % | 18,0 % | 47,0 % | 32,9 % | 31,1 % | 47,2 % | 25,3 % | 41,8 % | 81,7 % | 37,0 % | 2,0 % | 8,9 |
| Archer | 55,8 % | 20,8 % | 48,9 % | 47,9 % | 36,6 % | 51,7 % | 17,7 % | 20,8 % | 75,3 % | 55,0 % | 4,0 % | 10,6 |
| Prêtre | 37,1 % | 12,8 % | 50,1 % | 32,7 % | 65,4 % | 26,3 % | 59,1 % | 69,8 % | 88,0 % | 47,0 % | 5,0 % | 10,2 |
| Alchimiste | 34,8 % | 9,9 % | 49,3 % | 52,7 % | 40,4 % | 7,5 % | 41,5 % | 65,3 % | 88,9 % | 50,0 % | 6,0 % | 10,6 |
| Invocateur | 44,5 % | 15,3 % | 46,4 % | 38,3 % | 22,5 % | 34,8 % | 60,7 % | 17,2 % | 72,7 % | 57,0 % | 6,0 % | 10,9 |
| Barde | 39,5 % | 15,0 % | 48,6 % | 35,7 % | 32,5 % | 37,8 % | 33,1 % | 64,7 % | 81,5 % | 46,0 % | 8,0 % | 10,6 |
| Diplomate | 26,5 % | 9,3 % | 54,1 % | 17,0 % | 52,1 % | 78,2 % | 46,6 % | 74,7 % | 82,7 % | 50,0 % | 6,0 % | 10,1 |
| Pugiliste | 55,5 % | 5,3 % | 47,0 % | 41,4 % | 39,0 % | 56,5 % | 81,9 % | 15,6 % | 91,9 % | 45,0 % | 2,0 % | 9,9 |

### Boutons touchés, et pourquoi

- k_classe Guerrier : 0,866 → 0,865 (51,5 % de victoires)
- k_classe Voleur : 0,825 → 0,836 (47,0 % de victoires)
- k_classe Archer : 0,917 → 0,919 (48,9 % de victoires)
- k_classe Invocateur : 0,935 → 0,943 (46,4 % de victoires)
- k_classe Barde : 1,065 → 1,067 (48,6 % de victoires)
- k_classe Diplomate : 1,199 → 1,193 (54,1 % de victoires)
- k_classe Pugiliste : 0,936 → 0,942 (47,0 % de victoires)
- budgets des Clés (Archer) : -3 % (Ruée 55,8 %, une Clé jouée dans 75,3 % des combats)
- budgets de la Voie du Défi (Pugiliste) : +3 % (jouée dans 15,6 % des combats)
- budgets des Clés (Pugiliste) : -3 % (Ruée 55,5 %, une Clé jouée dans 91,9 % des combats)
- Tour : force des monstres au départ 0,399 → 0,399, en plus par étage 0,033 → 0,030 (étage 10 atteint dans 48,8 % des montées, étage 20 dans 4,8 %)
- Tour, Mage : facteur des monstres 0,732 → 0,741 (étage 10 dans 52,0 % des montées)
- Tour, Voleur : facteur des monstres 0,872 → 0,862 (étage 10 dans 37,0 % des montées)
- Tour, Archer : facteur des monstres 0,732 → 0,750 (étage 10 dans 55,0 % des montées)
- Tour, Invocateur : facteur des monstres 0,903 → 0,911 (étage 10 dans 57,0 % des montées)
- Tour, Barde : facteur des monstres 0,858 → 0,853 (étage 10 dans 46,0 % des montées)
- Tour, Pugiliste : facteur des monstres 0,973 → 0,969 (étage 10 dans 45,0 % des montées)

## Passe 11 (graines à partir de 1100034)

**0 critères tenus sur 6.** 30000 combats de duel (médiane 11 tours), 0 combats non finis.

### Les six critères (section 11.2)

- ❌ **1. Chaque classe entre 47 % et 53 % de victoires** : pretre 55,1 %, invocateur 46,0 %, diplomate 53,3 %
- ❌ **2. Aucune case de la matrice hors de 40 % – 60 %** : voleur contre archer 38,7 %, archer contre invocateur 61,0 %, pretre contre guerrier 68,3 %, pretre contre mage 60,3 %, alchimiste contre archer 39,7 %, invocateur contre archer 39,3 %, invocateur contre diplomate 38,7 %
- ❌ **3. Aucune route au-dessus de 55 % ni sous 40 % (Éventail : seulement pas au-dessus de 55 %)** : guerrier Ruée 39,9 %, mage Ruée 64,9 %, pretre Ruée 36,8 %, pretre Réactive 55,1 %, diplomate Ruée 31,7 %, pugiliste Ruée 14,4 %
- ❌ **4. Chaque voie jouée dans 15 % des combats au moins, une Clé dans 60 %** : alchimiste voie 3 11,7 %
- ❌ **5. Longueur : médiane de 6 à 10 tours, 95 % finis avant le tour 20** : médiane 11 tours
- ❌ **6. Tour : étage 10 dans 40 à 60 % des montées, étage 20 dans 5 à 10 %, à 5 points près entre classes** : mage étage 20 12,7 %, voleur étage 20 0,7 %, alchimiste étage 20 2,0 %, invocateur étage 20 3,3 %, pugiliste étage 20 3,3 %, écart entre classes : étage 10 de 44,0 % à 54,7 %, étage 20 de 0,7 % à 12,7 %

### La matrice des classes (taux de victoire de la ligne contre la colonne)

| | Guer | Mage | Vole | Arch | Prêt | Alch | Invo | Bard | Dipl | Pugi | **Moyenne** |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 47 | 54 | 53 | 58 | 44 | 43 | 48 | 45 | 47 | 54 | **49,3 %** |
| Mage | 44 | 47 | 53 | 51 | 45 | 59 | 55 | 51 | 45 | 53 | **50,3 %** |
| Voleur | 49 | 44 | 51 | 39 | 51 | 55 | 51 | 54 | 44 | 41 | **48,0 %** |
| Archer | 40 | 52 | 59 | 47 | 51 | 57 | 61 | 53 | 46 | 45 | **51,2 %** |
| Prêtre | 68 | 60 | 57 | 55 | 55 | 51 | 51 | 49 | 54 | 51 | **55,1 %** |
| Alchimiste | 59 | 51 | 48 | 40 | 56 | 51 | 54 | 60 | 51 | 45 | **51,5 %** |
| Invocateur | 45 | 44 | 49 | 39 | 50 | 47 | 49 | 52 | 39 | 45 | **46,0 %** |
| Barde | 53 | 51 | 53 | 50 | 54 | 46 | 49 | 51 | 43 | 49 | **49,9 %** |
| Diplomate | 52 | 57 | 57 | 52 | 47 | 52 | 56 | 55 | 49 | 56 | **53,3 %** |
| Pugiliste | 40 | 48 | 57 | 47 | 49 | 53 | 49 | 55 | 46 | 49 | **49,3 %** |

### Les trois routes, l'usage des voies et la Tour, par classe

| Classe | Ruée | Éventail | Réactive | Voie 1 | Voie 2 | Voie 3 | Voie 4 | Voie 5 | Clé | Tour : étage 10 | étage 20 | étage moyen |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 39,9 % | 11,7 % | 49,3 % | 38,5 % | 64,1 % | 38,3 % | 72,0 % | 65,6 % | 95,2 % | 54,7 % | 7,3 % | 10,5 |
| Mage | 64,9 % | 24,6 % | 50,3 % | 38,4 % | 50,2 % | 28,5 % | 51,2 % | 25,0 % | 79,2 % | 50,0 % | 12,7 % | 11,3 |
| Voleur | 43,6 % | 21,8 % | 48,0 % | 38,7 % | 27,9 % | 50,5 % | 32,3 % | 29,4 % | 82,3 % | 46,0 % | 0,7 % | 9,6 |
| Archer | 54,4 % | 23,5 % | 51,2 % | 48,0 % | 36,9 % | 54,3 % | 22,6 % | 22,2 % | 73,4 % | 48,0 % | 8,0 % | 10,6 |
| Prêtre | 36,8 % | 13,1 % | 55,1 % | 33,0 % | 64,7 % | 29,6 % | 59,2 % | 73,7 % | 88,3 % | 54,7 % | 6,7 % | 11,2 |
| Alchimiste | 41,3 % | 10,9 % | 51,5 % | 44,7 % | 41,0 % | 11,7 % | 41,9 % | 74,5 % | 88,9 % | 47,3 % | 2,0 % | 10,2 |
| Invocateur | 43,1 % | 15,0 % | 46,0 % | 35,6 % | 21,4 % | 35,7 % | 62,3 % | 19,8 % | 72,4 % | 44,0 % | 3,3 % | 9,8 |
| Barde | 40,2 % | 16,3 % | 49,9 % | 34,6 % | 32,4 % | 38,7 % | 36,8 % | 67,0 % | 81,9 % | 49,3 % | 10,0 % | 10,6 |
| Diplomate | 31,7 % | 10,4 % | 53,3 % | 16,4 % | 42,3 % | 78,2 % | 44,6 % | 75,0 % | 83,3 % | 54,0 % | 10,0 % | 11,2 |
| Pugiliste | 14,4 % | 5,3 % | 49,3 % | 36,3 % | 45,0 % | 54,9 % | 83,9 % | 19,2 % | 92,3 % | 47,3 % | 3,3 % | 10,0 |

### Boutons touchés, et pourquoi

- PV de toutes les classes : ×0,450 → ×0,409 des PV de la spécification (médiane 11 tours, 99,3 % finis avant le tour 20 ; on vise 10 tours)
- k_classe Voleur : 0,836 → 0,843 (48,0 % de victoires)
- k_classe Archer : 0,919 → 0,918 (51,2 % de victoires)
- k_classe Prêtre : 0,835 → 0,825 (55,1 % de victoires)
- k_classe Alchimiste : 0,963 → 0,962 (51,5 % de victoires)
- k_classe Invocateur : 0,943 → 0,951 (46,0 % de victoires)
- k_classe Diplomate : 1,193 → 1,189 (53,3 % de victoires)
- budgets des Clés (Guerrier) : +3 % (Ruée 39,9 %, une Clé jouée dans 95,2 % des combats)
- budgets des Clés (Archer) : -3 % (Ruée 54,4 %, une Clé jouée dans 73,4 % des combats)
- budgets des premiers nœuds des autres voies (Alchimiste) : -3 % (la Voie des Fumées, jouée dans 11,7 % des combats, commence par un état seul)
- budgets de la Voie de l'Intimidation (Diplomate) : +3 % (jouée dans 16,4 % des combats)
- budgets des Clés (Pugiliste) : +3 % (Ruée 14,4 %, une Clé jouée dans 92,3 % des combats)
- Tour, Guerrier : facteur des monstres 1,564 → 1,580 (étage 10 dans 54,7 % des montées)
- Tour, Voleur : facteur des monstres 0,862 → 0,859 (étage 10 dans 46,0 % des montées)
- Tour, Prêtre : facteur des monstres 1,125 → 1,127 (étage 10 dans 54,7 % des montées)
- Tour, Alchimiste : facteur des monstres 0,984 → 0,983 (étage 10 dans 47,3 % des montées)
- Tour, Invocateur : facteur des monstres 0,911 → 0,908 (étage 10 dans 44,0 % des montées)
- Tour, Diplomate : facteur des monstres 1,116 → 1,121 (étage 10 dans 54,0 % des montées)
- Tour, Pugiliste : facteur des monstres 0,969 → 0,967 (étage 10 dans 47,3 % des montées)

## Passe 12 (graines à partir de 1200037)

**1 critères tenus sur 6.** 30000 combats de duel (médiane 10 tours), 0 combats non finis.

### Les six critères (section 11.2)

- ❌ **1. Chaque classe entre 47 % et 53 % de victoires** : guerrier 43,7 %, alchimiste 46,3 %, diplomate 54,6 %
- ❌ **2. Aucune case de la matrice hors de 40 % – 60 %** : guerrier contre pretre 37,0 %, guerrier contre alchimiste 31,0 %, guerrier contre invocateur 34,3 %, guerrier contre barde 38,0 %, voleur contre guerrier 65,0 %, voleur contre pugiliste 39,0 %, archer contre alchimiste 62,0 %, alchimiste contre guerrier 64,3 %, alchimiste contre mage 39,0 %, alchimiste contre voleur 37,7 %, alchimiste contre archer 36,0 %, invocateur contre guerrier 62,3 %, barde contre guerrier 64,7 %, barde contre voleur 39,3 %, diplomate contre guerrier 61,7 %, diplomate contre invocateur 61,0 %
- ❌ **3. Aucune route au-dessus de 55 % ni sous 40 % (Éventail : seulement pas au-dessus de 55 %)** : mage Ruée 65,8 %, archer Ruée 56,5 %, pretre Ruée 36,3 %, alchimiste Ruée 39,5 %, barde Ruée 37,3 %, diplomate Ruée 31,8 %, pugiliste Ruée 15,3 %
- ❌ **4. Chaque voie jouée dans 15 % des combats au moins, une Clé dans 60 %** : alchimiste voie 3 10,9 %
- ✅ **5. Longueur : médiane de 6 à 10 tours, 95 % finis avant le tour 20**
- ❌ **6. Tour : étage 10 dans 40 à 60 % des montées, étage 20 dans 5 à 10 %, à 5 points près entre classes** : guerrier étage 20 0,0 %, mage étage 20 4,0 %, voleur étage 20 2,0 %, archer étage 20 3,3 %, pretre étage 20 2,7 %, alchimiste étage 20 4,0 %, invocateur étage 10 38,0 %, pugiliste étage 10 31,3 %, écart entre classes : étage 10 de 31,3 % à 50,0 %, étage 20 de 0,0 % à 8,0 %

### La matrice des classes (taux de victoire de la ligne contre la colonne)

| | Guer | Mage | Vole | Arch | Prêt | Alch | Invo | Bard | Dipl | Pugi | **Moyenne** |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 53 | 51 | 41 | 59 | 37 | 31 | 34 | 38 | 45 | 47 | **43,7 %** |
| Mage | 49 | 49 | 52 | 49 | 48 | 58 | 47 | 54 | 44 | 55 | **50,4 %** |
| Voleur | 65 | 48 | 46 | 42 | 48 | 57 | 49 | 54 | 47 | 39 | **49,6 %** |
| Archer | 49 | 52 | 58 | 52 | 44 | 62 | 51 | 54 | 49 | 49 | **52,0 %** |
| Prêtre | 58 | 48 | 48 | 42 | 44 | 54 | 49 | 45 | 55 | 46 | **48,9 %** |
| Alchimiste | 64 | 39 | 38 | 36 | 42 | 52 | 46 | 52 | 47 | 45 | **46,3 %** |
| Invocateur | 62 | 49 | 48 | 40 | 52 | 56 | 49 | 56 | 42 | 47 | **50,1 %** |
| Barde | 65 | 42 | 39 | 43 | 52 | 54 | 43 | 44 | 45 | 45 | **47,1 %** |
| Diplomate | 62 | 51 | 55 | 53 | 50 | 56 | 61 | 55 | 51 | 52 | **54,6 %** |
| Pugiliste | 51 | 51 | 53 | 53 | 49 | 57 | 49 | 51 | 51 | 49 | **51,5 %** |

### Les trois routes, l'usage des voies et la Tour, par classe

| Classe | Ruée | Éventail | Réactive | Voie 1 | Voie 2 | Voie 3 | Voie 4 | Voie 5 | Clé | Tour : étage 10 | étage 20 | étage moyen |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 40,4 % | 10,1 % | 43,7 % | 37,1 % | 68,6 % | 40,3 % | 71,9 % | 56,7 % | 94,2 % | 41,3 % | 0,0 % | 9,3 |
| Mage | 65,8 % | 22,3 % | 50,4 % | 36,0 % | 46,8 % | 32,7 % | 51,4 % | 21,4 % | 76,6 % | 42,0 % | 4,0 % | 9,9 |
| Voleur | 48,5 % | 24,0 % | 49,6 % | 35,5 % | 25,0 % | 45,4 % | 23,3 % | 43,0 % | 76,9 % | 47,3 % | 2,0 % | 9,8 |
| Archer | 56,5 % | 22,8 % | 52,0 % | 45,0 % | 42,1 % | 47,5 % | 20,5 % | 23,3 % | 69,7 % | 42,0 % | 3,3 % | 9,7 |
| Prêtre | 36,3 % | 12,8 % | 48,9 % | 30,6 % | 60,1 % | 38,1 % | 57,8 % | 74,9 % | 84,4 % | 45,3 % | 2,7 % | 9,7 |
| Alchimiste | 39,5 % | 11,0 % | 46,3 % | 52,9 % | 35,3 % | 10,9 % | 40,8 % | 62,8 % | 85,8 % | 47,3 % | 4,0 % | 10,2 |
| Invocateur | 49,2 % | 17,8 % | 50,1 % | 33,3 % | 21,0 % | 32,3 % | 66,6 % | 17,1 % | 66,2 % | 38,0 % | 5,3 % | 9,8 |
| Barde | 37,3 % | 15,0 % | 47,1 % | 38,6 % | 32,3 % | 36,9 % | 32,6 % | 60,3 % | 79,5 % | 50,0 % | 8,0 % | 10,6 |
| Diplomate | 31,8 % | 11,8 % | 54,6 % | 19,6 % | 56,1 % | 76,3 % | 46,9 % | 68,5 % | 80,5 % | 50,0 % | 7,3 % | 10,7 |
| Pugiliste | 15,3 % | 4,1 % | 51,5 % | 35,9 % | 38,0 % | 49,3 % | 85,7 % | 16,4 % | 91,9 % | 31,3 % | 5,3 % | 8,9 |

### Boutons touchés, et pourquoi

- k_classe Guerrier : 0,865 → 0,868 (43,7 % de victoires)
- k_classe Archer : 0,918 → 0,916 (52,0 % de victoires)
- k_classe Prêtre : 0,825 → 0,826 (48,9 % de victoires)
- k_classe Alchimiste : 0,962 → 0,964 (46,3 % de victoires)
- k_classe Barde : 1,067 → 1,070 (47,1 % de victoires)
- k_classe Diplomate : 1,189 → 1,183 (54,6 % de victoires)
- k_classe Pugiliste : 0,942 → 0,940 (51,5 % de victoires)
- budgets des Clés (Guerrier) : +3 % (Ruée 40,4 %, une Clé jouée dans 94,2 % des combats)
- budgets des Clés (Archer) : -3 % (Ruée 56,5 %, une Clé jouée dans 69,7 % des combats)
- budgets des premiers nœuds des autres voies (Alchimiste) : -3 % (la Voie des Fumées, jouée dans 10,9 % des combats, commence par un état seul)
- budgets de la Voie du Défi (Pugiliste) : +3 % (jouée dans 16,4 % des combats)
- budgets des Clés (Pugiliste) : +3 % (Ruée 15,2 %, une Clé jouée dans 91,9 % des combats)
- Tour : force des monstres au départ 0,399 → 0,391, en plus par étage 0,030 → 0,028 (étage 10 atteint dans 43,5 % des montées, étage 20 dans 4,2 %)
- Tour, Guerrier : facteur des monstres 1,580 → 1,577 (étage 10 dans 41,3 % des montées)
- Tour, Voleur : facteur des monstres 0,859 → 0,860 (étage 10 dans 47,3 % des montées)
- Tour, Alchimiste : facteur des monstres 0,983 → 0,985 (étage 10 dans 47,3 % des montées)
- Tour, Invocateur : facteur des monstres 0,908 → 0,903 (étage 10 dans 38,0 % des montées)
- Tour, Barde : facteur des monstres 0,853 → 0,859 (étage 10 dans 50,0 % des montées)
- Tour, Diplomate : facteur des monstres 1,121 → 1,129 (étage 10 dans 50,0 % des montées)
- Tour, Pugiliste : facteur des monstres 0,967 → 0,955 (étage 10 dans 31,3 % des montées)

## Passe 13 (graines à partir de 1300040)

**2 critères tenus sur 6.** 30000 combats de duel (médiane 10 tours), 0 combats non finis.

### Les six critères (section 11.2)

- ❌ **1. Chaque classe entre 47 % et 53 % de victoires** : alchimiste 42,5 %, barde 43,8 %
- ❌ **2. Aucune case de la matrice hors de 40 % – 60 %** : guerrier contre archer 61,7 %, guerrier contre pretre 38,3 %, guerrier contre invocateur 38,0 %, mage contre alchimiste 66,7 %, voleur contre alchimiste 62,7 %, voleur contre pugiliste 39,3 %, archer contre guerrier 33,7 %, archer contre alchimiste 64,0 %, alchimiste contre mage 36,3 %, alchimiste contre voleur 32,0 %, alchimiste contre archer 33,3 %, alchimiste contre pugiliste 35,7 %, invocateur contre archer 38,7 %, barde contre voleur 37,0 %, barde contre archer 37,0 %, pugiliste contre alchimiste 62,7 %
- ❌ **3. Aucune route au-dessus de 55 % ni sous 40 % (Éventail : seulement pas au-dessus de 55 %)** : guerrier Ruée 38,4 %, mage Ruée 65,6 %, archer Ruée 55,1 %, pretre Ruée 38,9 %, barde Ruée 37,7 %, diplomate Ruée 33,3 %, pugiliste Ruée 14,4 %
- ✅ **4. Chaque voie jouée dans 15 % des combats au moins, une Clé dans 60 %**
- ✅ **5. Longueur : médiane de 6 à 10 tours, 95 % finis avant le tour 20**
- ❌ **6. Tour : étage 10 dans 40 à 60 % des montées, étage 20 dans 5 à 10 %, à 5 points près entre classes** : guerrier étage 20 4,7 %, mage étage 20 14,7 %, voleur étage 20 2,7 %, pretre étage 10 34,7 %, pretre étage 20 4,0 %, alchimiste étage 10 38,7 %, alchimiste étage 20 2,7 %, pugiliste étage 10 38,7 %, écart entre classes : étage 10 de 34,7 % à 52,0 %, étage 20 de 2,7 % à 14,7 %

### La matrice des classes (taux de victoire de la ligne contre la colonne)

| | Guer | Mage | Vole | Arch | Prêt | Alch | Invo | Bard | Dipl | Pugi | **Moyenne** |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 51 | 60 | 46 | 62 | 38 | 45 | 38 | 49 | 52 | 59 | **50,0 %** |
| Mage | 47 | 52 | 51 | 49 | 48 | 67 | 48 | 56 | 52 | 52 | **52,1 %** |
| Voleur | 50 | 49 | 41 | 44 | 49 | 63 | 51 | 56 | 47 | 39 | **48,8 %** |
| Archer | 34 | 47 | 51 | 44 | 45 | 64 | 55 | 60 | 45 | 42 | **48,6 %** |
| Prêtre | 57 | 50 | 46 | 48 | 50 | 48 | 45 | 51 | 50 | 42 | **48,7 %** |
| Alchimiste | 54 | 36 | 32 | 33 | 48 | 53 | 43 | 49 | 40 | 36 | **42,5 %** |
| Invocateur | 56 | 46 | 40 | 39 | 53 | 56 | 49 | 56 | 43 | 43 | **47,9 %** |
| Barde | 51 | 44 | 37 | 37 | 46 | 52 | 43 | 47 | 42 | 40 | **43,8 %** |
| Diplomate | 49 | 57 | 52 | 48 | 48 | 59 | 57 | 58 | 50 | 46 | **52,4 %** |
| Pugiliste | 47 | 52 | 51 | 49 | 50 | 63 | 57 | 57 | 46 | 49 | **51,9 %** |

### Les trois routes, l'usage des voies et la Tour, par classe

| Classe | Ruée | Éventail | Réactive | Voie 1 | Voie 2 | Voie 3 | Voie 4 | Voie 5 | Clé | Tour : étage 10 | étage 20 | étage moyen |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 38,4 % | 8,8 % | 50,0 % | 36,4 % | 47,2 % | 34,0 % | 83,2 % | 58,7 % | 95,3 % | 52,0 % | 4,7 % | 10,5 |
| Mage | 65,6 % | 22,8 % | 52,1 % | 37,2 % | 48,0 % | 28,7 % | 47,2 % | 25,5 % | 77,3 % | 52,0 % | 14,7 % | 11,1 |
| Voleur | 47,1 % | 22,9 % | 48,8 % | 36,9 % | 26,6 % | 46,8 % | 23,7 % | 40,4 % | 78,7 % | 45,3 % | 2,7 % | 9,8 |
| Archer | 55,1 % | 21,0 % | 48,6 % | 42,8 % | 44,3 % | 49,7 % | 21,2 % | 23,0 % | 70,8 % | 49,3 % | 7,3 % | 10,5 |
| Prêtre | 38,9 % | 14,6 % | 48,7 % | 31,4 % | 59,9 % | 36,0 % | 58,6 % | 76,3 % | 87,0 % | 34,7 % | 4,0 % | 9,2 |
| Alchimiste | 40,7 % | 8,3 % | 42,5 % | 47,6 % | 32,7 % | 31,2 % | 41,2 % | 53,3 % | 89,0 % | 38,7 % | 2,7 % | 9,7 |
| Invocateur | 43,9 % | 18,0 % | 47,9 % | 31,3 % | 22,5 % | 34,6 % | 68,5 % | 16,2 % | 67,0 % | 45,3 % | 7,3 % | 10,3 |
| Barde | 37,7 % | 14,2 % | 43,8 % | 34,9 % | 30,6 % | 39,5 % | 33,1 % | 64,4 % | 80,1 % | 44,0 % | 9,3 % | 10,2 |
| Diplomate | 33,3 % | 10,3 % | 52,4 % | 18,7 % | 54,0 % | 78,0 % | 45,7 % | 69,6 % | 81,1 % | 48,0 % | 9,3 % | 10,8 |
| Pugiliste | 14,4 % | 4,3 % | 51,9 % | 35,5 % | 40,9 % | 52,0 % | 84,2 % | 19,6 % | 92,9 % | 38,7 % | 6,7 % | 9,9 |

### Boutons touchés, et pourquoi

- k_classe Mage : 0,996 → 0,991 (52,1 % de victoires)
- k_classe Voleur : 0,843 → 0,848 (48,8 % de victoires)
- k_classe Archer : 0,916 → 0,917 (48,6 % de victoires)
- k_classe Prêtre : 0,826 → 0,827 (48,7 % de victoires)
- k_classe Alchimiste : 0,964 → 0,972 (42,5 % de victoires)
- k_classe Invocateur : 0,951 → 0,956 (47,9 % de victoires)
- k_classe Barde : 1,070 → 1,077 (43,8 % de victoires)
- k_classe Diplomate : 1,183 → 1,180 (52,4 % de victoires)
- k_classe Pugiliste : 0,940 → 0,938 (51,9 % de victoires)
- budgets des Clés (Guerrier) : +3 % (Ruée 38,4 %, une Clé jouée dans 95,3 % des combats)
- budgets des Clés (Archer) : -3 % (Ruée 55,1 %, une Clé jouée dans 70,8 % des combats)
- budgets de la Voie du Pacte (Invocateur) : +3 % (jouée dans 16,2 % des combats)
- budgets des Clés (Pugiliste) : +3 % (Ruée 14,4 %, une Clé jouée dans 92,9 % des combats)
- Tour : force des monstres au départ 0,391 → 0,385, en plus par étage 0,028 → 0,028 (étage 10 atteint dans 44,8 % des montées, étage 20 dans 6,9 %)
- Tour, Guerrier : facteur des monstres 1,577 → 1,583 (étage 10 dans 52,0 % des montées)
- Tour, Mage : facteur des monstres 0,741 → 0,762 (étage 10 dans 52,0 % des montées)
- Tour, Archer : facteur des monstres 0,750 → 0,764 (étage 10 dans 49,3 % des montées)
- Tour, Prêtre : facteur des monstres 1,127 → 1,122 (étage 10 dans 34,7 % des montées)
- Tour, Alchimiste : facteur des monstres 0,985 → 0,982 (étage 10 dans 38,7 % des montées)
- Tour, Diplomate : facteur des monstres 1,129 → 1,132 (étage 10 dans 48,0 % des montées)
- Tour, Pugiliste : facteur des monstres 0,955 → 0,950 (étage 10 dans 38,7 % des montées)

## Passe 14 (graines à partir de 1400043)

**1 critères tenus sur 6.** 30000 combats de duel (médiane 10 tours), 0 combats non finis.

### Les six critères (section 11.2)

- ❌ **1. Chaque classe entre 47 % et 53 % de victoires** : pretre 46,8 %, alchimiste 44,9 %, barde 45,1 %
- ❌ **2. Aucune case de la matrice hors de 40 % – 60 %** : guerrier contre archer 62,7 %, voleur contre alchimiste 61,3 %, archer contre guerrier 36,7 %, pretre contre invocateur 38,7 %, alchimiste contre voleur 37,0 %, alchimiste contre archer 39,3 %
- ❌ **3. Aucune route au-dessus de 55 % ni sous 40 % (Éventail : seulement pas au-dessus de 55 %)** : mage Ruée 64,8 %, pretre Ruée 35,9 %, alchimiste Ruée 35,6 %, invocateur Ruée 55,2 %, barde Ruée 34,7 %, diplomate Ruée 29,3 %
- ❌ **4. Chaque voie jouée dans 15 % des combats au moins, une Clé dans 60 %** : alchimiste voie 3 12,5 %
- ✅ **5. Longueur : médiane de 6 à 10 tours, 95 % finis avant le tour 20**
- ❌ **6. Tour : étage 10 dans 40 à 60 % des montées, étage 20 dans 5 à 10 %, à 5 points près entre classes** : guerrier étage 20 3,3 %, mage étage 20 12,0 %, voleur étage 20 3,3 %, invocateur étage 10 61,3 %, invocateur étage 20 14,0 %, diplomate étage 20 13,3 %, écart entre classes : étage 10 de 45,3 % à 61,3 %, étage 20 de 3,3 % à 14,0 %

### La matrice des classes (taux de victoire de la ligne contre la colonne)

| | Guer | Mage | Vole | Arch | Prêt | Alch | Invo | Bard | Dipl | Pugi | **Moyenne** |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 56 | 60 | 47 | 63 | 47 | 50 | 43 | 45 | 57 | 50 | **51,7 %** |
| Mage | 43 | 51 | 53 | 48 | 53 | 60 | 47 | 53 | 49 | 49 | **50,5 %** |
| Voleur | 50 | 49 | 52 | 45 | 55 | 61 | 53 | 57 | 49 | 47 | **51,8 %** |
| Archer | 37 | 52 | 55 | 50 | 48 | 58 | 54 | 52 | 52 | 46 | **50,3 %** |
| Prêtre | 48 | 49 | 46 | 46 | 48 | 50 | 39 | 48 | 51 | 44 | **46,8 %** |
| Alchimiste | 56 | 41 | 37 | 39 | 47 | 48 | 43 | 50 | 45 | 43 | **44,9 %** |
| Invocateur | 55 | 50 | 45 | 46 | 51 | 52 | 47 | 51 | 45 | 51 | **49,3 %** |
| Barde | 52 | 45 | 41 | 43 | 49 | 44 | 45 | 46 | 43 | 42 | **45,1 %** |
| Diplomate | 47 | 57 | 55 | 53 | 48 | 54 | 53 | 57 | 47 | 48 | **51,9 %** |
| Pugiliste | 43 | 45 | 51 | 51 | 54 | 56 | 50 | 53 | 52 | 50 | **50,5 %** |

### Les trois routes, l'usage des voies et la Tour, par classe

| Classe | Ruée | Éventail | Réactive | Voie 1 | Voie 2 | Voie 3 | Voie 4 | Voie 5 | Clé | Tour : étage 10 | étage 20 | étage moyen |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 41,9 % | 11,2 % | 51,7 % | 38,0 % | 43,9 % | 26,9 % | 85,1 % | 58,8 % | 94,9 % | 56,7 % | 3,3 % | 10,7 |
| Mage | 64,8 % | 22,4 % | 50,5 % | 38,2 % | 45,4 % | 31,6 % | 47,3 % | 22,3 % | 75,8 % | 56,7 % | 12,0 % | 11,3 |
| Voleur | 53,7 % | 23,0 % | 51,8 % | 36,3 % | 21,2 % | 41,6 % | 27,4 % | 45,6 % | 77,9 % | 49,3 % | 3,3 % | 10,1 |
| Archer | 52,8 % | 21,5 % | 50,3 % | 42,4 % | 42,3 % | 46,9 % | 20,8 % | 20,8 % | 69,7 % | 51,3 % | 5,3 % | 10,5 |
| Prêtre | 35,9 % | 10,2 % | 46,8 % | 31,3 % | 66,0 % | 24,2 % | 55,3 % | 67,6 % | 86,4 % | 51,3 % | 6,0 % | 10,5 |
| Alchimiste | 35,6 % | 9,3 % | 44,9 % | 49,0 % | 33,0 % | 12,5 % | 39,5 % | 66,5 % | 87,1 % | 57,3 % | 7,3 % | 11,3 |
| Invocateur | 55,2 % | 17,4 % | 49,3 % | 46,8 % | 19,2 % | 29,9 % | 53,2 % | 20,7 % | 66,5 % | 61,3 % | 14,0 % | 11,7 |
| Barde | 34,7 % | 14,0 % | 45,1 % | 36,0 % | 34,0 % | 35,4 % | 34,7 % | 63,2 % | 80,0 % | 45,3 % | 8,7 % | 10,4 |
| Diplomate | 29,3 % | 8,8 % | 51,9 % | 16,7 % | 41,7 % | 73,8 % | 38,3 % | 76,0 % | 80,1 % | 58,0 % | 13,3 % | 11,8 |
| Pugiliste | 44,2 % | 4,8 % | 50,5 % | 32,4 % | 39,3 % | 51,9 % | 84,7 % | 16,7 % | 92,7 % | 54,0 % | 6,7 % | 11,0 |

### Boutons touchés, et pourquoi

- k_classe Guerrier : 0,868 → 0,867 (51,7 % de victoires)
- k_classe Voleur : 0,848 → 0,844 (51,8 % de victoires)
- k_classe Prêtre : 0,827 → 0,830 (46,8 % de victoires)
- k_classe Alchimiste : 0,972 → 0,978 (44,9 % de victoires)
- k_classe Barde : 1,077 → 1,083 (45,1 % de victoires)
- k_classe Diplomate : 1,180 → 1,177 (51,9 % de victoires)
- budgets des premiers nœuds des autres voies (Alchimiste) : -3 % (la Voie des Fumées, jouée dans 12,5 % des combats, commence par un état seul)
- budgets des Clés (Invocateur) : -3 % (Ruée 55,2 %, une Clé jouée dans 66,5 % des combats)
- budgets de la Voie de l'Intimidation (Diplomate) : +3 % (jouée dans 16,7 % des combats)
- budgets de la Voie du Défi (Pugiliste) : +3 % (jouée dans 16,7 % des combats)
- Tour : force des monstres au départ 0,385 → 0,388, en plus par étage 0,028 → 0,028 (étage 10 atteint dans 54,1 % des montées, étage 20 dans 8,0 %)
- Tour, Guerrier : facteur des monstres 1,583 → 1,587 (étage 10 dans 56,7 % des montées)
- Tour, Mage : facteur des monstres 0,762 → 0,770 (étage 10 dans 56,7 % des montées)
- Tour, Voleur : facteur des monstres 0,860 → 0,858 (étage 10 dans 49,3 % des montées)
- Tour, Archer : facteur des monstres 0,764 → 0,759 (étage 10 dans 51,3 % des montées)
- Tour, Prêtre : facteur des monstres 1,122 → 1,119 (étage 10 dans 51,3 % des montées)
- Tour, Alchimiste : facteur des monstres 0,982 → 0,984 (étage 10 dans 57,3 % des montées)
- Tour, Invocateur : facteur des monstres 0,903 → 0,907 (étage 10 dans 61,3 % des montées)
- Tour, Barde : facteur des monstres 0,859 → 0,855 (étage 10 dans 45,3 % des montées)
- Tour, Diplomate : facteur des monstres 1,132 → 1,137 (étage 10 dans 58,0 % des montées)

## Passe 15 (graines à partir de 1500046)

**2 critères tenus sur 6.** 30000 combats de duel (médiane 10 tours), 0 combats non finis.

### Les six critères (section 11.2)

- ❌ **1. Chaque classe entre 47 % et 53 % de victoires** : alchimiste 43,5 %, barde 45,7 %
- ❌ **2. Aucune case de la matrice hors de 40 % – 60 %** : mage contre alchimiste 61,3 %, voleur contre archer 39,0 %, voleur contre alchimiste 61,7 %, archer contre alchimiste 62,7 %, alchimiste contre mage 38,3 %, alchimiste contre voleur 37,3 %, alchimiste contre archer 30,7 %, alchimiste contre pugiliste 38,0 %, invocateur contre archer 37,3 %
- ❌ **3. Aucune route au-dessus de 55 % ni sous 40 % (Éventail : seulement pas au-dessus de 55 %)** : mage Ruée 66,4 %, pretre Ruée 35,4 %, alchimiste Ruée 37,6 %, barde Ruée 36,2 %, diplomate Ruée 28,7 %
- ✅ **4. Chaque voie jouée dans 15 % des combats au moins, une Clé dans 60 %**
- ✅ **5. Longueur : médiane de 6 à 10 tours, 95 % finis avant le tour 20**
- ❌ **6. Tour : étage 10 dans 40 à 60 % des montées, étage 20 dans 5 à 10 %, à 5 points près entre classes** : guerrier étage 20 1,3 %, mage étage 20 12,0 %, voleur étage 20 1,3 %, archer étage 20 4,7 %, alchimiste étage 20 4,0 %, barde étage 20 11,3 %, écart entre classes : étage 10 de 46,7 % à 54,0 %, étage 20 de 1,3 % à 12,0 %

### La matrice des classes (taux de victoire de la ligne contre la colonne)

| | Guer | Mage | Vole | Arch | Prêt | Alch | Invo | Bard | Dipl | Pugi | **Moyenne** |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 51 | 49 | 47 | 57 | 52 | 41 | 50 | 48 | 56 | 52 | **50,4 %** |
| Mage | 47 | 48 | 52 | 43 | 49 | 61 | 50 | 57 | 53 | 48 | **51,0 %** |
| Voleur | 45 | 45 | 44 | 39 | 51 | 62 | 49 | 56 | 48 | 46 | **48,5 %** |
| Archer | 40 | 52 | 53 | 49 | 53 | 63 | 56 | 56 | 53 | 49 | **52,3 %** |
| Prêtre | 54 | 54 | 49 | 48 | 52 | 49 | 47 | 47 | 58 | 41 | **50,0 %** |
| Alchimiste | 54 | 38 | 37 | 31 | 48 | 49 | 42 | 51 | 48 | 38 | **43,5 %** |
| Invocateur | 50 | 47 | 47 | 37 | 54 | 53 | 52 | 57 | 45 | 43 | **48,6 %** |
| Barde | 49 | 45 | 41 | 43 | 54 | 47 | 43 | 49 | 44 | 43 | **45,7 %** |
| Diplomate | 50 | 45 | 51 | 47 | 45 | 57 | 54 | 52 | 49 | 50 | **50,0 %** |
| Pugiliste | 40 | 51 | 48 | 49 | 54 | 58 | 52 | 54 | 48 | 50 | **50,3 %** |

### Les trois routes, l'usage des voies et la Tour, par classe

| Classe | Ruée | Éventail | Réactive | Voie 1 | Voie 2 | Voie 3 | Voie 4 | Voie 5 | Clé | Tour : étage 10 | étage 20 | étage moyen |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 43,8 % | 8,1 % | 50,4 % | 36,7 % | 48,2 % | 31,7 % | 83,2 % | 59,3 % | 95,0 % | 50,7 % | 1,3 % | 10,2 |
| Mage | 66,4 % | 23,3 % | 51,0 % | 39,3 % | 48,4 % | 28,8 % | 48,9 % | 22,8 % | 77,3 % | 54,0 % | 12,0 % | 11,2 |
| Voleur | 46,3 % | 19,5 % | 48,5 % | 37,0 % | 27,6 % | 47,6 % | 32,6 % | 31,9 % | 79,4 % | 47,3 % | 1,3 % | 9,9 |
| Archer | 54,9 % | 23,3 % | 52,3 % | 46,5 % | 41,7 % | 47,6 % | 21,3 % | 23,3 % | 71,2 % | 49,3 % | 4,7 % | 10,5 |
| Prêtre | 35,4 % | 11,1 % | 50,0 % | 31,0 % | 61,3 % | 37,3 % | 57,7 % | 73,4 % | 86,1 % | 46,7 % | 5,3 % | 10,3 |
| Alchimiste | 37,6 % | 8,2 % | 43,5 % | 49,2 % | 32,5 % | 36,4 % | 38,3 % | 53,2 % | 88,2 % | 53,3 % | 4,0 % | 10,7 |
| Invocateur | 51,5 % | 16,8 % | 48,6 % | 41,3 % | 20,4 % | 32,8 % | 58,4 % | 23,1 % | 66,5 % | 49,3 % | 9,3 % | 10,6 |
| Barde | 36,2 % | 14,8 % | 45,7 % | 36,5 % | 33,7 % | 38,8 % | 34,3 % | 60,5 % | 80,8 % | 54,0 % | 11,3 % | 11,4 |
| Diplomate | 28,7 % | 10,8 % | 50,0 % | 19,6 % | 54,1 % | 78,9 % | 46,5 % | 67,0 % | 80,2 % | 47,3 % | 6,0 % | 10,6 |
| Pugiliste | 41,3 % | 5,3 % | 50,3 % | 34,4 % | 40,2 % | 56,2 % | 80,0 % | 20,2 % | 92,5 % | 46,7 % | 5,3 % | 10,4 |

### Boutons touchés, et pourquoi

- k_classe Mage : 0,991 → 0,989 (51,0 % de victoires)
- k_classe Voleur : 0,844 → 0,846 (48,5 % de victoires)
- k_classe Archer : 0,917 → 0,916 (52,3 % de victoires)
- k_classe Alchimiste : 0,978 → 0,985 (43,5 % de victoires)
- k_classe Invocateur : 0,956 → 0,959 (48,6 % de victoires)
- k_classe Barde : 1,083 → 1,089 (45,7 % de victoires)
- budgets des Clés (Archer) : -3 % (Ruée 54,9 %, une Clé jouée dans 71,2 % des combats)
- Tour, Mage : facteur des monstres 0,770 → 0,783 (étage 10 dans 54,0 % des montées)
- Tour, Voleur : facteur des monstres 0,858 → 0,856 (étage 10 dans 47,3 % des montées)
- Tour, Prêtre : facteur des monstres 1,119 → 1,115 (étage 10 dans 46,7 % des montées)
- Tour, Alchimiste : facteur des monstres 0,984 → 0,987 (étage 10 dans 53,3 % des montées)
- Tour, Barde : facteur des monstres 0,855 → 0,857 (étage 10 dans 54,0 % des montées)
- Tour, Diplomate : facteur des monstres 1,137 → 1,135 (étage 10 dans 47,3 % des montées)
- Tour, Pugiliste : facteur des monstres 0,950 → 0,947 (étage 10 dans 46,7 % des montées)

## Passe 16 (graines à partir de 1600049)

**2 critères tenus sur 6.** 30000 combats de duel (médiane 10 tours), 0 combats non finis.

### Les six critères (section 11.2)

- ❌ **1. Chaque classe entre 47 % et 53 % de victoires** : mage 54,6 %, alchimiste 46,3 %
- ❌ **2. Aucune case de la matrice hors de 40 % – 60 %** : guerrier contre archer 61,7 %, mage contre alchimiste 67,0 %, voleur contre alchimiste 70,3 %, archer contre guerrier 37,3 %, archer contre alchimiste 66,3 %, alchimiste contre voleur 34,7 %, alchimiste contre archer 32,0 %, alchimiste contre pretre 60,3 %, alchimiste contre pugiliste 39,3 %, invocateur contre guerrier 61,3 %, pugiliste contre pretre 60,7 %, pugiliste contre alchimiste 62,7 %
- ❌ **3. Aucune route au-dessus de 55 % ni sous 40 % (Éventail : seulement pas au-dessus de 55 %)** : mage Ruée 67,7 %, pretre Ruée 36,8 %, invocateur Ruée 56,4 %, barde Ruée 39,8 %, diplomate Ruée 29,6 %
- ✅ **4. Chaque voie jouée dans 15 % des combats au moins, une Clé dans 60 %**
- ✅ **5. Longueur : médiane de 6 à 10 tours, 95 % finis avant le tour 20**
- ❌ **6. Tour : étage 10 dans 40 à 60 % des montées, étage 20 dans 5 à 10 %, à 5 points près entre classes** : guerrier étage 20 3,3 %, mage étage 20 12,0 %, voleur étage 20 1,3 %, pretre étage 20 4,7 %, alchimiste étage 20 4,7 %, invocateur étage 20 12,0 %, barde étage 20 12,0 %, diplomate étage 20 4,0 %, écart entre classes : étage 10 de 44,0 % à 60,0 %, étage 20 de 1,3 % à 12,0 %

### La matrice des classes (taux de victoire de la ligne contre la colonne)

| | Guer | Mage | Vole | Arch | Prêt | Alch | Invo | Bard | Dipl | Pugi | **Moyenne** |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 53 | 57 | 52 | 62 | 49 | 46 | 40 | 46 | 52 | 57 | **51,5 %** |
| Mage | 40 | 49 | 55 | 53 | 56 | 67 | 57 | 58 | 58 | 53 | **54,6 %** |
| Voleur | 56 | 41 | 49 | 46 | 58 | 70 | 51 | 57 | 47 | 45 | **52,0 %** |
| Archer | 37 | 52 | 50 | 51 | 55 | 66 | 52 | 60 | 48 | 50 | **52,1 %** |
| Prêtre | 56 | 42 | 47 | 44 | 55 | 48 | 47 | 51 | 56 | 51 | **49,8 %** |
| Alchimiste | 60 | 41 | 35 | 32 | 60 | 52 | 47 | 52 | 45 | 39 | **46,3 %** |
| Invocateur | 61 | 45 | 46 | 40 | 56 | 57 | 52 | 56 | 46 | 54 | **51,4 %** |
| Barde | 54 | 42 | 45 | 42 | 54 | 50 | 47 | 56 | 47 | 47 | **48,4 %** |
| Diplomate | 46 | 50 | 52 | 50 | 51 | 58 | 55 | 57 | 52 | 53 | **52,4 %** |
| Pugiliste | 44 | 45 | 49 | 50 | 61 | 63 | 55 | 53 | 46 | 52 | **51,8 %** |

### Les trois routes, l'usage des voies et la Tour, par classe

| Classe | Ruée | Éventail | Réactive | Voie 1 | Voie 2 | Voie 3 | Voie 4 | Voie 5 | Clé | Tour : étage 10 | étage 20 | étage moyen |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 42,9 % | 10,5 % | 51,5 % | 37,5 % | 46,0 % | 28,9 % | 85,0 % | 59,4 % | 93,8 % | 60,0 % | 3,3 % | 10,9 |
| Mage | 67,7 % | 23,4 % | 54,6 % | 38,3 % | 46,2 % | 37,1 % | 38,4 % | 23,7 % | 75,4 % | 55,3 % | 12,0 % | 11,4 |
| Voleur | 50,1 % | 23,8 % | 52,0 % | 36,6 % | 25,7 % | 45,7 % | 28,2 % | 39,7 % | 80,0 % | 58,7 % | 1,3 % | 10,4 |
| Archer | 51,9 % | 23,3 % | 52,1 % | 42,5 % | 41,3 % | 50,4 % | 22,0 % | 19,9 % | 69,9 % | 46,0 % | 6,0 % | 10,1 |
| Prêtre | 36,8 % | 12,5 % | 49,8 % | 28,2 % | 61,5 % | 38,4 % | 58,5 % | 74,2 % | 86,4 % | 49,3 % | 4,7 % | 10,3 |
| Alchimiste | 40,1 % | 9,8 % | 46,3 % | 50,6 % | 31,5 % | 31,9 % | 35,4 % | 54,0 % | 88,5 % | 54,0 % | 4,7 % | 10,7 |
| Invocateur | 56,4 % | 18,1 % | 51,4 % | 34,7 % | 20,7 % | 29,1 % | 68,4 % | 21,1 % | 66,7 % | 48,7 % | 12,0 % | 10,7 |
| Barde | 39,8 % | 16,4 % | 48,4 % | 36,7 % | 32,5 % | 38,9 % | 34,5 % | 60,1 % | 80,5 % | 44,0 % | 12,0 % | 10,3 |
| Diplomate | 29,6 % | 10,4 % | 52,4 % | 21,3 % | 53,8 % | 77,4 % | 46,2 % | 67,1 % | 79,8 % | 44,0 % | 4,0 % | 10,1 |
| Pugiliste | 41,8 % | 5,9 % | 51,8 % | 35,4 % | 41,3 % | 54,7 % | 82,8 % | 18,2 % | 91,0 % | 54,7 % | 6,7 % | 10,8 |

### Boutons touchés, et pourquoi

- k_classe Guerrier : 0,867 → 0,866 (51,5 % de victoires)
- k_classe Mage : 0,989 → 0,979 (54,6 % de victoires)
- k_classe Voleur : 0,846 → 0,845 (52,0 % de victoires)
- k_classe Archer : 0,916 → 0,913 (52,1 % de victoires)
- k_classe Alchimiste : 0,985 → 0,989 (46,3 % de victoires)
- k_classe Invocateur : 0,959 → 0,958 (51,4 % de victoires)
- k_classe Barde : 1,089 → 1,091 (48,4 % de victoires)
- k_classe Diplomate : 1,177 → 1,174 (52,4 % de victoires)
- k_classe Pugiliste : 0,938 → 0,936 (51,8 % de victoires)
- budgets des Clés (Invocateur) : -3 % (Ruée 56,4 %, une Clé jouée dans 66,7 % des combats)
- Tour, Guerrier : facteur des monstres 1,587 → 1,600 (étage 10 dans 60,0 % des montées)
- Tour, Mage : facteur des monstres 0,783 → 0,795 (étage 10 dans 55,3 % des montées)
- Tour, Voleur : facteur des monstres 0,856 → 0,859 (étage 10 dans 58,7 % des montées)
- Tour, Archer : facteur des monstres 0,759 → 0,751 (étage 10 dans 46,0 % des montées)
- Tour, Prêtre : facteur des monstres 1,115 → 1,113 (étage 10 dans 49,3 % des montées)
- Tour, Alchimiste : facteur des monstres 0,987 → 0,990 (étage 10 dans 54,0 % des montées)
- Tour, Invocateur : facteur des monstres 0,907 → 0,905 (étage 10 dans 48,7 % des montées)
- Tour, Barde : facteur des monstres 0,857 → 0,853 (étage 10 dans 44,0 % des montées)
- Tour, Diplomate : facteur des monstres 1,135 → 1,127 (étage 10 dans 44,0 % des montées)
- Tour, Pugiliste : facteur des monstres 0,947 → 0,948 (étage 10 dans 54,7 % des montées)

## Passe 17 (graines à partir de 1700052)

**3 critères tenus sur 6.** 50000 combats de duel (médiane 10 tours), 0 combats non finis.

### Les six critères (section 11.2)

- ❌ **1. Chaque classe entre 47 % et 53 % de victoires** : guerrier 46,1 %, voleur 53,4 %, alchimiste 46,3 %
- ❌ **2. Aucune case de la matrice hors de 40 % – 60 %** : guerrier contre archer 62,8 %, guerrier contre alchimiste 35,4 %, guerrier contre invocateur 38,2 %, voleur contre guerrier 61,0 %, voleur contre alchimiste 62,6 %, archer contre alchimiste 62,0 %, alchimiste contre guerrier 62,8 %, alchimiste contre voleur 38,2 %
- ✅ **3. La route Réactive entre 40 % et 55 % (Ruée et Éventail : des repères, sans seuil)**
- ✅ **4. Chaque voie jouée dans 15 % des combats au moins, une Clé dans 60 %**
- ✅ **5. Longueur : médiane de 6 à 10 tours, 95 % finis avant le tour 20**
- ❌ **6. Tour : étage 10 dans 40 à 60 % des montées, étage 20 dans 5 à 10 %, à 5 points près entre classes** : guerrier étage 20 3,0 %, mage étage 20 13,0 %, voleur étage 20 2,0 %, invocateur étage 20 11,0 %, barde étage 20 13,5 %, pugiliste étage 20 3,0 %, écart entre classes : étage 10 de 50,0 % à 58,0 %, étage 20 de 2,0 % à 13,5 %

### La matrice des classes (taux de victoire de la ligne contre la colonne)

| | Guer | Mage | Vole | Arch | Prêt | Alch | Invo | Bard | Dipl | Pugi | **Moyenne** |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 48 | 51 | 42 | 63 | 41 | 35 | 38 | 40 | 49 | 53 | **46,1 %** |
| Mage | 44 | 48 | 52 | 50 | 48 | 59 | 53 | 53 | 48 | 52 | **50,8 %** |
| Voleur | 61 | 52 | 51 | 48 | 56 | 63 | 50 | 56 | 45 | 52 | **53,4 %** |
| Archer | 40 | 51 | 56 | 51 | 48 | 62 | 58 | 53 | 48 | 53 | **52,0 %** |
| Prêtre | 57 | 47 | 44 | 52 | 52 | 48 | 49 | 46 | 54 | 51 | **49,9 %** |
| Alchimiste | 63 | 40 | 38 | 40 | 49 | 49 | 44 | 50 | 46 | 43 | **46,3 %** |
| Invocateur | 58 | 51 | 46 | 45 | 55 | 60 | 50 | 53 | 47 | 56 | **52,1 %** |
| Barde | 58 | 51 | 47 | 46 | 55 | 50 | 46 | 52 | 49 | 53 | **50,7 %** |
| Diplomate | 51 | 53 | 50 | 54 | 44 | 56 | 53 | 55 | 51 | 54 | **52,0 %** |
| Pugiliste | 49 | 51 | 51 | 51 | 53 | 56 | 52 | 52 | 51 | 55 | **52,0 %** |

### Les trois routes, l'usage des voies et la Tour, par classe

| Classe | Ruée | Éventail | Réactive | Voie 1 | Voie 2 | Voie 3 | Voie 4 | Voie 5 | Clé | Tour : étage 10 | étage 20 | étage moyen |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 43,3 % | 10,7 % | 46,1 % | 36,1 % | 70,6 % | 38,9 % | 69,9 % | 63,8 % | 93,1 % | 50,5 % | 3,0 % | 10,0 |
| Mage | 71,5 % | 24,5 % | 50,8 % | 45,0 % | 47,5 % | 18,0 % | 53,4 % | 25,0 % | 76,5 % | 58,0 % | 13,0 % | 11,2 |
| Voleur | 51,0 % | 26,0 % | 53,4 % | 38,1 % | 25,1 % | 47,7 % | 35,3 % | 32,6 % | 79,1 % | 54,0 % | 2,0 % | 10,2 |
| Archer | 57,5 % | 24,0 % | 52,0 % | 45,6 % | 36,6 % | 51,9 % | 22,4 % | 28,3 % | 70,5 % | 51,5 % | 7,5 % | 10,9 |
| Prêtre | 34,5 % | 12,7 % | 49,9 % | 29,5 % | 59,9 % | 39,8 % | 57,0 % | 76,3 % | 85,8 % | 53,0 % | 6,0 % | 10,7 |
| Alchimiste | 39,0 % | 8,2 % | 46,3 % | 51,6 % | 32,0 % | 33,3 % | 38,6 % | 51,1 % | 88,7 % | 50,0 % | 8,0 % | 10,8 |
| Invocateur | 57,2 % | 20,5 % | 52,1 % | 39,7 % | 20,5 % | 31,7 % | 64,2 % | 22,4 % | 67,3 % | 54,0 % | 11,0 % | 10,8 |
| Barde | 37,2 % | 15,0 % | 50,7 % | 39,1 % | 31,6 % | 37,5 % | 34,5 % | 63,8 % | 80,0 % | 53,0 % | 13,5 % | 11,3 |
| Diplomate | 33,7 % | 10,8 % | 52,0 % | 19,1 % | 57,7 % | 77,9 % | 48,9 % | 67,3 % | 78,7 % | 57,5 % | 7,5 % | 11,4 |
| Pugiliste | 43,2 % | 5,7 % | 52,0 % | 39,1 % | 37,9 % | 59,2 % | 78,1 % | 20,8 % | 91,5 % | 51,0 % | 3,0 % | 10,5 |

### Boutons touchés, et pourquoi

- k_classe Guerrier : 0,866 → 0,868 (46,1 % de victoires)
- k_classe Mage : 0,979 → 0,977 (50,8 % de victoires)
- k_classe Voleur : 0,845 → 0,842 (53,4 % de victoires)
- k_classe Archer : 0,913 → 0,911 (52,0 % de victoires)
- k_classe Alchimiste : 0,989 → 0,993 (46,3 % de victoires)
- k_classe Invocateur : 0,958 → 0,955 (52,1 % de victoires)
- k_classe Diplomate : 1,174 → 1,171 (52,0 % de victoires)
- k_classe Pugiliste : 0,936 → 0,934 (52,0 % de victoires)
- duels de Guerrier (trop bas contre Prêtre, Alchimiste, Invocateur, Barde ; trop haut contre Archer) : Voie du Sang +3 %, Voie du Rempart -3 %, Voie de la Charge +3 %, Voie du Tonnerre +3 %, Voie du Cri -3 %
- duels de Mage (trop bas contre personne ; trop haut contre Alchimiste) : Voie du Brasier -3 %, Voie de la Foudre -3 %, Voie de l'Arcane -3 %
- duels de Archer (trop bas contre Guerrier ; trop haut contre Alchimiste) : Voie de la Précision -3 %, Voie de la Volée -3 %, Voie du Feu grégeois -3 %
- duels de Alchimiste (trop bas contre Mage, Voleur, Archer ; trop haut contre Guerrier) : Voie de l'Acide -3 %, Voie de l'Élixir +3 %, Voie du Mutagène +3 %, Voie de la Nitro -3 %
- duels de Barde (trop bas contre personne ; trop haut contre Guerrier) : Voie du Refrain -3 %, Voie du Solo +3 %
- Tour : force des monstres au départ 0,388 → 0,390, en plus par étage 0,028 → 0,028 (étage 10 atteint dans 53,2 % des montées, étage 20 dans 7,4 %)
- Tour, Guerrier : pente des monstres 1,000 → 0,910 (étage 20 dans 3,0 % des montées)
- Tour, Guerrier : facteur des monstres 1,600 → 1,598 (étage 10 dans 50,5 % des montées)
- Tour, Mage : pente des monstres 1,000 → 1,110 (étage 20 dans 13,0 % des montées)
- Tour, Mage : facteur des monstres 0,795 → 0,810 (étage 10 dans 58,0 % des montées)
- Tour, Voleur : pente des monstres 1,000 → 0,890 (étage 20 dans 2,0 % des montées)
- Tour, Alchimiste : facteur des monstres 0,990 → 0,988 (étage 10 dans 50,0 % des montées)
- Tour, Invocateur : pente des monstres 1,000 → 1,070 (étage 20 dans 11,0 % des montées)
- Tour, Barde : pente des monstres 1,000 → 1,120 (étage 20 dans 13,5 % des montées)
- Tour, Diplomate : facteur des monstres 1,127 → 1,129 (étage 10 dans 57,5 % des montées)
- Tour, Pugiliste : pente des monstres 1,000 → 0,910 (étage 20 dans 3,0 % des montées)
- Tour, Pugiliste : facteur des monstres 0,948 → 0,947 (étage 10 dans 51,0 % des montées)

## Passe 18 (graines à partir de 1800055)

**2 critères tenus sur 6.** 50000 combats de duel (médiane 10 tours), 0 combats non finis.

### Les six critères (section 11.2)

- ❌ **1. Chaque classe entre 47 % et 53 % de victoires** : guerrier 55,0 %, alchimiste 45,0 %, barde 46,1 %
- ❌ **2. Aucune case de la matrice hors de 40 % – 60 %** : guerrier contre mage 62,6 %, guerrier contre archer 66,0 %, guerrier contre pugiliste 60,8 %, voleur contre alchimiste 63,6 %, archer contre guerrier 33,8 %, alchimiste contre mage 33,6 %, alchimiste contre voleur 35,6 %
- ❌ **3. La route Réactive entre 40 % et 55 % (Ruée et Éventail : des repères, sans seuil)** : guerrier Réactive 55,0 %
- ✅ **4. Chaque voie jouée dans 15 % des combats au moins, une Clé dans 60 %**
- ✅ **5. Longueur : médiane de 6 à 10 tours, 95 % finis avant le tour 20**
- ❌ **6. Tour : étage 10 dans 40 à 60 % des montées, étage 20 dans 5 à 10 %, à 5 points près entre classes** : guerrier étage 20 4,5 %, voleur étage 20 4,0 %, pretre étage 20 2,0 %, invocateur étage 20 11,0 %, barde étage 10 31,0 %, écart entre classes : étage 10 de 31,0 % à 55,5 %, étage 20 de 2,0 % à 11,0 %

### La matrice des classes (taux de victoire de la ligne contre la colonne)

| | Guer | Mage | Vole | Arch | Prêt | Alch | Invo | Bard | Dipl | Pugi | **Moyenne** |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 46 | 63 | 53 | 66 | 56 | 47 | 48 | 52 | 59 | 61 | **55,0 %** |
| Mage | 42 | 52 | 53 | 54 | 51 | 59 | 53 | 56 | 55 | 51 | **52,4 %** |
| Voleur | 47 | 43 | 49 | 49 | 54 | 64 | 55 | 57 | 46 | 53 | **51,7 %** |
| Archer | 34 | 46 | 46 | 53 | 49 | 57 | 52 | 49 | 48 | 52 | **48,5 %** |
| Prêtre | 49 | 43 | 42 | 56 | 48 | 45 | 48 | 47 | 50 | 52 | **48,0 %** |
| Alchimiste | 53 | 34 | 36 | 42 | 51 | 50 | 44 | 50 | 46 | 46 | **45,0 %** |
| Invocateur | 52 | 41 | 46 | 48 | 52 | 54 | 50 | 55 | 49 | 55 | **50,2 %** |
| Barde | 49 | 41 | 45 | 47 | 46 | 44 | 44 | 50 | 43 | 51 | **46,1 %** |
| Diplomate | 42 | 43 | 51 | 51 | 47 | 55 | 53 | 55 | 50 | 54 | **49,9 %** |
| Pugiliste | 41 | 45 | 45 | 48 | 52 | 58 | 47 | 48 | 50 | 51 | **48,4 %** |

### Les trois routes, l'usage des voies et la Tour, par classe

| Classe | Ruée | Éventail | Réactive | Voie 1 | Voie 2 | Voie 3 | Voie 4 | Voie 5 | Clé | Tour : étage 10 | étage 20 | étage moyen |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 46,3 % | 12,5 % | 55,0 % | 43,6 % | 39,5 % | 44,4 % | 75,0 % | 54,4 % | 94,9 % | 52,0 % | 4,5 % | 10,6 |
| Mage | 69,3 % | 28,7 % | 52,4 % | 32,2 % | 52,2 % | 25,1 % | 54,4 % | 22,2 % | 76,1 % | 49,0 % | 6,5 % | 10,2 |
| Voleur | 54,2 % | 26,0 % | 51,7 % | 37,0 % | 22,7 % | 46,3 % | 24,6 % | 41,2 % | 77,0 % | 50,5 % | 4,0 % | 10,3 |
| Archer | 51,8 % | 28,8 % | 48,5 % | 35,4 % | 34,2 % | 58,4 % | 17,7 % | 25,4 % | 69,3 % | 48,0 % | 8,5 % | 10,5 |
| Prêtre | 37,7 % | 16,3 % | 48,0 % | 29,3 % | 59,9 % | 37,8 % | 58,3 % | 74,0 % | 87,2 % | 42,5 % | 2,0 % | 9,3 |
| Alchimiste | 42,8 % | 13,3 % | 45,0 % | 48,7 % | 42,1 % | 26,7 % | 41,8 % | 50,6 % | 87,7 % | 44,5 % | 6,0 % | 10,4 |
| Invocateur | 58,7 % | 20,0 % | 50,2 % | 36,6 % | 20,8 % | 32,8 % | 59,3 % | 20,3 % | 66,3 % | 55,5 % | 11,0 % | 11,2 |
| Barde | 34,7 % | 19,2 % | 46,1 % | 37,8 % | 31,5 % | 37,4 % | 31,0 % | 60,8 % | 79,9 % | 31,0 % | 7,0 % | 9,2 |
| Diplomate | 34,7 % | 13,5 % | 49,9 % | 20,5 % | 56,1 % | 77,1 % | 45,3 % | 66,6 % | 80,1 % | 49,0 % | 7,5 % | 10,2 |
| Pugiliste | 43,8 % | 5,5 % | 48,4 % | 37,8 % | 37,9 % | 58,4 % | 76,9 % | 18,6 % | 91,7 % | 41,0 % | 6,0 % | 9,8 |

### Boutons touchés, et pourquoi

- k_classe Guerrier : 0,868 → 0,865 (55,0 % de victoires)
- k_classe Mage : 0,977 → 0,971 (52,4 % de victoires)
- k_classe Voleur : 0,842 → 0,840 (51,7 % de victoires)
- k_classe Archer : 0,911 → 0,912 (48,5 % de victoires)
- k_classe Prêtre : 0,830 → 0,832 (48,0 % de victoires)
- k_classe Alchimiste : 0,993 → 0,999 (45,0 % de victoires)
- k_classe Barde : 1,091 → 1,095 (46,1 % de victoires)
- k_classe Pugiliste : 0,934 → 0,935 (48,4 % de victoires)
- duels de Mage (trop bas contre Guerrier ; trop haut contre Alchimiste) : Voie du Brasier -3 %, Voie de la Foudre -3 %, Voie de l'Arcane -3 %
- duels de Voleur (trop bas contre personne ; trop haut contre Alchimiste) : Voie des Ombres -3 %, Voie du Poison -3 %, Voie de l'Éventail -3 %
- duels de Archer (trop bas contre Guerrier ; trop haut contre personne) : Voie de la Précision -3 %, Voie de la Volée -3 %, Voie du Feu grégeois -3 %
- duels de Prêtre (trop bas contre Voleur ; trop haut contre personne) : Voie de la Lumière +3 %, Voie du Châtiment -3 %, Voie de la Protection +3 %, Voie de la Purification +3 %
- duels de Alchimiste (trop bas contre Mage, Voleur ; trop haut contre personne) : Voie de l'Acide -3 %, Voie de l'Élixir +3 %, Voie du Mutagène +3 %, Voie de la Nitro -3 %
- duels de Invocateur (trop bas contre Mage ; trop haut contre personne) : Voie de la Meute -3 %, Voie du Gardien +3 %, Voie de l'Élémentaire -3 %, Voie du Pacte +3 %
- duels de Barde (trop bas contre Mage ; trop haut contre personne) : Voie du Refrain +3 %, Voie du Solo -3 %
- duels de Diplomate (trop bas contre Guerrier ; trop haut contre personne) : Voie du Traité +3 %, Voie de l'Éloquence +3 %, Voie du Duel -3 %
- duels de Pugiliste (trop bas contre Guerrier ; trop haut contre personne) : Voie des Poings -3 %, Voie du Souffle +3 %, Voie du Tourbillon -3 %
- Tour : force des monstres au départ 0,390 → 0,388, en plus par étage 0,028 → 0,028 (étage 10 atteint dans 46,3 % des montées, étage 20 dans 6,3 %)
- Tour, Guerrier : pente des monstres 0,910 → 0,855 (étage 20 dans 4,5 % des montées)
- Tour, Guerrier : facteur des monstres 1,598 → 1,603 (étage 10 dans 52,0 % des montées)
- Tour, Mage : facteur des monstres 0,810 → 0,819 (étage 10 dans 49,0 % des montées)
- Tour, Voleur : pente des monstres 0,890 → 0,828 (étage 20 dans 4,0 % des montées)
- Tour, Voleur : facteur des monstres 0,859 → 0,863 (étage 10 dans 50,5 % des montées)
- Tour, Prêtre : pente des monstres 1,000 → 0,890 (étage 20 dans 2,0 % des montées)
- Tour, Prêtre : facteur des monstres 1,113 → 1,108 (étage 10 dans 42,5 % des montées)
- Tour, Invocateur : pente des monstres 1,070 → 1,145 (étage 20 dans 11,0 % des montées)
- Tour, Invocateur : facteur des monstres 0,905 → 0,909 (étage 10 dans 55,5 % des montées)
- Tour, Barde : facteur des monstres 0,853 → 0,840 (étage 10 dans 31,0 % des montées)
- Tour, Diplomate : facteur des monstres 1,129 → 1,132 (étage 10 dans 49,0 % des montées)
- Tour, Pugiliste : facteur des monstres 0,947 → 0,942 (étage 10 dans 41,0 % des montées)

## Passe 19 (graines à partir de 1900058)

**1 critères tenus sur 6.** 50000 combats de duel (médiane 11 tours), 0 combats non finis.

### Les six critères (section 11.2)

- ❌ **1. Chaque classe entre 47 % et 53 % de victoires** : guerrier 56,0 %, mage 55,6 %, pugiliste 36,1 %
- ❌ **2. Aucune case de la matrice hors de 40 % – 60 %** : guerrier contre mage 62,4 %, guerrier contre archer 63,2 %, guerrier contre pugiliste 64,2 %, mage contre guerrier 39,6 %, mage contre alchimiste 64,2 %, mage contre pugiliste 66,8 %, voleur contre alchimiste 60,8 %, voleur contre pugiliste 64,6 %, archer contre guerrier 35,0 %, archer contre pugiliste 68,4 %, pretre contre pugiliste 60,8 %, alchimiste contre voleur 34,6 %, alchimiste contre pugiliste 61,4 %, invocateur contre pugiliste 65,0 %, barde contre pugiliste 68,0 %, diplomate contre guerrier 36,6 %, pugiliste contre guerrier 32,8 %, pugiliste contre mage 36,8 %, pugiliste contre voleur 31,2 %, pugiliste contre archer 31,4 %, pugiliste contre pretre 36,6 %, pugiliste contre alchimiste 36,8 %, pugiliste contre invocateur 34,0 %, pugiliste contre barde 35,4 %, pugiliste contre diplomate 38,4 %
- ❌ **3. La route Réactive entre 40 % et 55 % (Ruée et Éventail : des repères, sans seuil)** : guerrier Réactive 56,0 %, mage Réactive 55,6 %, pugiliste Réactive 36,1 %
- ✅ **4. Chaque voie jouée dans 15 % des combats au moins, une Clé dans 60 %**
- ❌ **5. Longueur : médiane de 6 à 10 tours, 95 % finis avant le tour 20** : médiane 11 tours
- ❌ **6. Tour : étage 10 dans 40 à 60 % des montées, étage 20 dans 5 à 10 %, à 5 points près entre classes** : guerrier étage 10 62,0 %, guerrier étage 20 11,0 %, mage étage 20 4,5 %, voleur étage 20 4,5 %, archer étage 10 36,5 %, archer étage 20 4,5 %, invocateur étage 20 4,0 %, barde étage 20 11,0 %, écart entre classes : étage 10 de 36,5 % à 62,0 %, étage 20 de 4,0 % à 11,0 %

### La matrice des classes (taux de victoire de la ligne contre la colonne)

| | Guer | Mage | Vole | Arch | Prêt | Alch | Invo | Bard | Dipl | Pugi | **Moyenne** |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 50 | 62 | 56 | 63 | 51 | 48 | 53 | 53 | 59 | 64 | **56,0 %** |
| Mage | 40 | 52 | 59 | 50 | 54 | 64 | 57 | 59 | 56 | 67 | **55,6 %** |
| Voleur | 44 | 44 | 51 | 47 | 49 | 61 | 51 | 55 | 48 | 65 | **51,5 %** |
| Archer | 35 | 48 | 55 | 50 | 48 | 60 | 59 | 51 | 51 | 68 | **52,5 %** |
| Prêtre | 44 | 49 | 48 | 53 | 49 | 44 | 50 | 46 | 56 | 61 | **50,1 %** |
| Alchimiste | 56 | 40 | 35 | 44 | 52 | 52 | 49 | 52 | 49 | 61 | **49,0 %** |
| Invocateur | 44 | 48 | 45 | 43 | 48 | 50 | 47 | 55 | 41 | 65 | **48,5 %** |
| Barde | 46 | 47 | 42 | 49 | 54 | 50 | 44 | 48 | 45 | 68 | **49,2 %** |
| Diplomate | 37 | 44 | 54 | 51 | 46 | 51 | 56 | 51 | 46 | 60 | **49,5 %** |
| Pugiliste | 33 | 37 | 31 | 31 | 37 | 37 | 34 | 35 | 38 | 48 | **36,1 %** |

### Les trois routes, l'usage des voies et la Tour, par classe

| Classe | Ruée | Éventail | Réactive | Voie 1 | Voie 2 | Voie 3 | Voie 4 | Voie 5 | Clé | Tour : étage 10 | étage 20 | étage moyen |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 47,8 % | 14,2 % | 56,0 % | 35,3 % | 43,7 % | 48,4 % | 78,5 % | 58,1 % | 94,9 % | 62,0 % | 11,0 % | 11,8 |
| Mage | 72,7 % | 31,2 % | 55,6 % | 24,1 % | 64,6 % | 17,7 % | 53,1 % | 19,7 % | 78,4 % | 40,0 % | 4,5 % | 9,5 |
| Voleur | 56,8 % | 27,3 % | 51,5 % | 32,5 % | 22,5 % | 51,0 % | 38,5 % | 34,9 % | 81,1 % | 56,0 % | 4,5 % | 10,5 |
| Archer | 59,2 % | 32,5 % | 52,5 % | 19,5 % | 33,6 % | 63,3 % | 20,0 % | 40,2 % | 73,2 % | 36,5 % | 4,5 % | 9,5 |
| Prêtre | 34,2 % | 12,3 % | 50,1 % | 30,7 % | 58,7 % | 40,0 % | 62,7 % | 72,7 % | 86,5 % | 48,0 % | 7,0 % | 10,5 |
| Alchimiste | 45,7 % | 11,5 % | 49,0 % | 50,5 % | 43,2 % | 28,1 % | 44,1 % | 54,0 % | 88,1 % | 55,0 % | 8,0 % | 11,2 |
| Invocateur | 57,0 % | 20,0 % | 48,5 % | 37,9 % | 23,2 % | 42,9 % | 52,8 % | 23,9 % | 67,9 % | 48,0 % | 4,0 % | 10,3 |
| Barde | 39,7 % | 17,8 % | 49,2 % | 37,8 % | 32,6 % | 38,5 % | 35,6 % | 62,2 % | 80,8 % | 41,5 % | 11,0 % | 10,3 |
| Diplomate | 33,2 % | 11,5 % | 49,5 % | 20,7 % | 55,3 % | 79,9 % | 48,9 % | 63,6 % | 81,0 % | 47,0 % | 6,5 % | 10,1 |
| Pugiliste | 49,3 % | 8,2 % | 36,1 % | 25,4 % | 39,6 % | 82,7 % | 59,0 % | 24,3 % | 92,6 % | 45,0 % | 5,5 % | 9,9 |

### Boutons touchés, et pourquoi

- PV de toutes les classes : ×0,409 → ×0,372 des PV de la spécification (médiane 11 tours, 99,5 % finis avant le tour 20 ; on vise 10 tours)
- k_classe Guerrier : 0,865 → 0,859 (56,0 % de victoires)
- k_classe Mage : 0,971 → 0,959 (55,6 % de victoires)
- k_classe Voleur : 0,840 → 0,839 (51,5 % de victoires)
- k_classe Archer : 0,912 → 0,911 (52,5 % de victoires)
- k_classe Alchimiste : 0,999 → 1,000 (49,0 % de victoires)
- k_classe Invocateur : 0,955 → 0,956 (48,5 % de victoires)
- k_classe Pugiliste : 0,935 → 0,950 (36,1 % de victoires)
- duels de Mage (trop bas contre Guerrier ; trop haut contre Voleur, Alchimiste, Barde, Pugiliste) : Voie du Brasier -3 %, Voie de la Foudre -3 %, Voie de l'Arcane -3 %
- duels de Voleur (trop bas contre personne ; trop haut contre Alchimiste, Pugiliste) : Voie des Ombres -3 %, Voie du Poison -3 %, Voie de l'Éventail -3 %
- duels de Archer (trop bas contre Guerrier ; trop haut contre Alchimiste, Invocateur, Pugiliste) : Voie de la Précision -3 %, Voie de la Volée -3 %, Voie du Feu grégeois -3 %
- duels de Alchimiste (trop bas contre Mage, Voleur ; trop haut contre Pugiliste) : Voie de l'Acide -3 %, Voie de l'Élixir +3 %, Voie du Mutagène +3 %, Voie de la Nitro -3 %
- duels de Invocateur (trop bas contre Diplomate ; trop haut contre Pugiliste) : Voie de la Meute +3 %, Voie du Gardien -3 %, Voie de l'Élémentaire +3 %, Voie du Pacte -3 %
- duels de Diplomate (trop bas contre Guerrier ; trop haut contre Pugiliste) : Voie du Traité +3 %, Voie de l'Éloquence +3 %, Voie du Duel -3 %
- Tour, Guerrier : pente des monstres 0,855 → 0,885 (étage 20 dans 11,0 % des montées)
- Tour, Guerrier : facteur des monstres 1,603 → 1,625 (étage 10 dans 62,0 % des montées)
- Tour, Mage : pente des monstres 1,110 → 1,077 (étage 20 dans 4,5 % des montées)
- Tour, Mage : facteur des monstres 0,819 → 0,806 (étage 10 dans 40,0 % des montées)
- Tour, Voleur : pente des monstres 0,828 → 0,778 (étage 20 dans 4,5 % des montées)
- Tour, Voleur : facteur des monstres 0,863 → 0,870 (étage 10 dans 56,0 % des montées)
- Tour, Archer : pente des monstres 1,000 → 0,940 (étage 20 dans 4,5 % des montées)
- Tour, Archer : facteur des monstres 0,751 → 0,734 (étage 10 dans 36,5 % des montées)
- Tour, Alchimiste : facteur des monstres 0,988 → 0,992 (étage 10 dans 55,0 % des montées)
- Tour, Invocateur : pente des monstres 1,145 → 1,105 (étage 20 dans 4,0 % des montées)
- Tour, Barde : pente des monstres 1,120 → 1,198 (étage 20 dans 11,0 % des montées)
- Tour, Barde : facteur des monstres 0,840 → 0,835 (étage 10 dans 41,5 % des montées)
- Tour, Pugiliste : facteur des monstres 0,942 → 0,939 (étage 10 dans 45,0 % des montées)

## Passe 20 (graines à partir de 2000061)

**1 critères tenus sur 6.** 50000 combats de duel (médiane 10 tours), 0 combats non finis.

### Les six critères (section 11.2)

- ❌ **1. Chaque classe entre 47 % et 53 % de victoires** : guerrier 56,9 %, voleur 56,9 %, pretre 42,1 %, invocateur 55,6 %, barde 46,0 %, pugiliste 39,7 %
- ❌ **2. Aucune case de la matrice hors de 40 % – 60 %** : guerrier contre mage 62,4 %, guerrier contre archer 70,4 %, guerrier contre pugiliste 64,8 %, mage contre guerrier 36,6 %, mage contre pugiliste 63,6 %, voleur contre pretre 69,8 %, voleur contre alchimiste 66,6 %, voleur contre barde 66,2 %, voleur contre pugiliste 66,0 %, archer contre guerrier 31,2 %, archer contre pugiliste 64,0 %, pretre contre guerrier 39,4 %, pretre contre mage 38,4 %, pretre contre voleur 35,8 %, pretre contre alchimiste 38,6 %, pretre contre invocateur 33,8 %, alchimiste contre mage 39,0 %, alchimiste contre voleur 37,2 %, alchimiste contre archer 39,2 %, alchimiste contre pretre 63,2 %, alchimiste contre pugiliste 64,0 %, invocateur contre pretre 69,6 %, invocateur contre barde 64,6 %, invocateur contre pugiliste 68,6 %, barde contre voleur 36,2 %, barde contre invocateur 39,0 %, barde contre pugiliste 62,2 %, diplomate contre pugiliste 61,0 %, pugiliste contre guerrier 33,2 %, pugiliste contre mage 37,0 %, pugiliste contre voleur 37,4 %, pugiliste contre archer 37,0 %, pugiliste contre alchimiste 38,2 %, pugiliste contre invocateur 35,2 %, pugiliste contre diplomate 38,8 %
- ❌ **3. La route Réactive entre 40 % et 55 % (Ruée et Éventail : des repères, sans seuil)** : guerrier Réactive 56,9 %, voleur Réactive 56,9 %, invocateur Réactive 55,6 %, pugiliste Réactive 39,7 %
- ❌ **4. Chaque voie jouée dans 15 % des combats au moins, une Clé dans 60 %** : mage voie 3 13,6 %
- ✅ **5. Longueur : médiane de 6 à 10 tours, 95 % finis avant le tour 20**
- ❌ **6. Tour : étage 10 dans 40 à 60 % des montées, étage 20 dans 5 à 10 %, à 5 points près entre classes** : mage étage 10 39,5 %, mage étage 20 2,0 %, voleur étage 10 62,5 %, pretre étage 10 34,5 %, pretre étage 20 2,0 %, barde étage 10 31,5 %, barde étage 20 3,5 %, pugiliste étage 20 3,5 %, écart entre classes : étage 10 de 31,5 % à 62,5 %, étage 20 de 2,0 % à 6,5 %

### La matrice des classes (taux de victoire de la ligne contre la colonne)

| | Guer | Mage | Vole | Arch | Prêt | Alch | Invo | Bard | Dipl | Pugi | **Moyenne** |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 51 | 62 | 52 | 70 | 60 | 46 | 50 | 55 | 58 | 65 | **56,9 %** |
| Mage | 37 | 49 | 49 | 53 | 60 | 53 | 52 | 52 | 56 | 64 | **52,3 %** |
| Voleur | 51 | 48 | 49 | 51 | 70 | 67 | 52 | 66 | 50 | 66 | **56,9 %** |
| Archer | 31 | 49 | 50 | 54 | 57 | 55 | 48 | 55 | 47 | 64 | **51,1 %** |
| Prêtre | 39 | 38 | 36 | 43 | 50 | 39 | 34 | 43 | 48 | 52 | **42,1 %** |
| Alchimiste | 55 | 39 | 37 | 39 | 63 | 46 | 43 | 58 | 44 | 64 | **49,0 %** |
| Invocateur | 50 | 47 | 52 | 49 | 70 | 57 | 51 | 65 | 47 | 69 | **55,6 %** |
| Barde | 44 | 41 | 36 | 46 | 54 | 43 | 39 | 53 | 42 | 62 | **46,0 %** |
| Diplomate | 44 | 42 | 48 | 51 | 53 | 50 | 53 | 59 | 47 | 61 | **50,8 %** |
| Pugiliste | 33 | 37 | 37 | 37 | 48 | 38 | 35 | 42 | 39 | 50 | **39,7 %** |

### Les trois routes, l'usage des voies et la Tour, par classe

| Classe | Ruée | Éventail | Réactive | Voie 1 | Voie 2 | Voie 3 | Voie 4 | Voie 5 | Clé | Tour : étage 10 | étage 20 | étage moyen |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 47,8 % | 14,2 % | 56,9 % | 32,1 % | 42,1 % | 34,7 % | 86,7 % | 56,2 % | 94,5 % | 59,0 % | 5,0 % | 11,6 |
| Mage | 64,0 % | 33,0 % | 52,3 % | 23,5 % | 63,3 % | 13,6 % | 54,4 % | 18,0 % | 73,9 % | 39,5 % | 2,0 % | 9,3 |
| Voleur | 60,2 % | 32,7 % | 56,9 % | 30,9 % | 23,2 % | 49,1 % | 38,4 % | 32,6 % | 76,3 % | 62,5 % | 5,0 % | 11,0 |
| Archer | 60,3 % | 31,5 % | 51,1 % | 15,9 % | 34,9 % | 63,4 % | 19,5 % | 33,9 % | 69,0 % | 42,5 % | 5,5 % | 9,9 |
| Prêtre | 28,5 % | 7,5 % | 42,1 % | 28,3 % | 65,8 % | 34,8 % | 59,4 % | 66,9 % | 86,3 % | 34,5 % | 2,0 % | 8,6 |
| Alchimiste | 46,3 % | 16,3 % | 49,0 % | 44,3 % | 41,3 % | 27,6 % | 43,0 % | 54,5 % | 85,6 % | 48,0 % | 5,0 % | 10,5 |
| Invocateur | 59,8 % | 30,0 % | 55,6 % | 50,9 % | 20,2 % | 32,8 % | 49,4 % | 21,5 % | 62,0 % | 47,5 % | 6,5 % | 10,3 |
| Barde | 38,3 % | 18,7 % | 46,0 % | 35,6 % | 29,9 % | 33,5 % | 33,1 % | 66,5 % | 78,2 % | 31,5 % | 3,5 % | 8,6 |
| Diplomate | 36,8 % | 14,0 % | 50,8 % | 19,3 % | 56,8 % | 78,3 % | 53,9 % | 54,0 % | 77,1 % | 43,0 % | 5,5 % | 9,6 |
| Pugiliste | 50,5 % | 11,5 % | 39,7 % | 24,6 % | 38,4 % | 79,1 % | 60,2 % | 20,4 % | 90,7 % | 40,5 % | 3,5 % | 9,3 |

### Boutons touchés, et pourquoi

- k_classe Guerrier : 0,859 → 0,853 (56,9 % de victoires)
- k_classe Mage : 0,959 → 0,954 (52,3 % de victoires)
- k_classe Voleur : 0,839 → 0,832 (56,9 % de victoires)
- k_classe Archer : 0,911 → 0,910 (51,1 % de victoires)
- k_classe Prêtre : 0,832 → 0,839 (42,1 % de victoires)
- k_classe Alchimiste : 1,000 → 1,001 (49,0 % de victoires)
- k_classe Invocateur : 0,956 → 0,953 (55,6 % de victoires)
- k_classe Barde : 1,095 → 1,100 (46,0 % de victoires)
- k_classe Pugiliste : 0,950 → 0,961 (39,7 % de victoires)
- budgets de la Voie de la Foudre (Mage) : +3 % (jouée dans 13,6 % des combats)
- budgets de la Voie de la Précision (Archer) : +3 % (jouée dans 15,9 % des combats)
- duels de Mage (trop bas contre Guerrier ; trop haut contre Prêtre, Pugiliste) : Voie du Brasier -3 %, Voie de la Foudre -3 %, Voie de l'Arcane -3 %
- duels de Voleur (trop bas contre personne ; trop haut contre Prêtre, Alchimiste, Barde, Pugiliste) : Voie des Ombres -3 %, Voie du Poison -3 %, Voie de l'Éventail -3 %
- duels de Archer (trop bas contre Guerrier ; trop haut contre Pugiliste) : Voie de la Précision -3 %, Voie de la Volée -3 %, Voie du Feu grégeois -3 %
- duels de Prêtre (trop bas contre Guerrier, Mage, Voleur, Alchimiste, Invocateur ; trop haut contre personne) : Voie de la Lumière +3 %, Voie du Châtiment -3 %, Voie de la Protection +3 %, Voie de la Purification +3 %
- duels de Alchimiste (trop bas contre Mage, Voleur, Archer ; trop haut contre Prêtre, Barde, Pugiliste) : Voie de l'Acide -3 %, Voie de l'Élixir +3 %, Voie du Mutagène +3 %, Voie de la Nitro -3 %
- duels de Invocateur (trop bas contre personne ; trop haut contre Prêtre, Barde, Pugiliste) : Voie de la Meute -3 %, Voie du Gardien +3 %, Voie de l'Élémentaire -3 %, Voie du Pacte +3 %
- duels de Barde (trop bas contre Mage, Voleur, Invocateur, Diplomate ; trop haut contre Pugiliste) : Voie du Refrain +3 %, Voie du Solo -3 %
- duels de Diplomate (trop bas contre personne ; trop haut contre Barde, Pugiliste) : Voie du Traité +3 %, Voie de l'Éloquence +3 %, Voie du Duel -3 %
- Tour : force des monstres au départ 0,388 → 0,385, en plus par étage 0,028 → 0,025 (étage 10 atteint dans 44,9 % des montées, étage 20 dans 4,3 %)
- Tour, Guerrier : pente des monstres 0,885 → 0,874 (étage 20 dans 5,0 % des montées)
- Tour, Guerrier : facteur des monstres 1,625 → 1,648 (étage 10 dans 59,0 % des montées)
- Tour, Mage : pente des monstres 1,077 → 1,018 (étage 20 dans 2,0 % des montées)
- Tour, Mage : facteur des monstres 0,806 → 0,797 (étage 10 dans 39,5 % des montées)
- Tour, Voleur : pente des monstres 0,778 → 0,739 (étage 20 dans 5,0 % des montées)
- Tour, Voleur : facteur des monstres 0,870 → 0,885 (étage 10 dans 62,5 % des montées)
- Tour, Archer : facteur des monstres 0,734 → 0,731 (étage 10 dans 42,5 % des montées)
- Tour, Prêtre : pente des monstres 0,890 → 0,792 (étage 20 dans 2,0 % des montées)
- Tour, Prêtre : facteur des monstres 1,108 → 1,097 (étage 10 dans 34,5 % des montées)
- Tour, Alchimiste : pente des monstres 1,000 → 0,950 (étage 20 dans 5,0 % des montées)
- Tour, Alchimiste : facteur des monstres 0,992 → 0,995 (étage 10 dans 48,0 % des montées)
- Tour, Invocateur : facteur des monstres 0,909 → 0,912 (étage 10 dans 47,5 % des montées)
- Tour, Barde : pente des monstres 1,198 → 1,151 (étage 20 dans 3,5 % des montées)
- Tour, Barde : facteur des monstres 0,835 → 0,824 (étage 10 dans 31,5 % des montées)
- Tour, Pugiliste : pente des monstres 0,910 → 0,837 (étage 20 dans 3,5 % des montées)
- Tour, Pugiliste : facteur des monstres 0,939 → 0,935 (étage 10 dans 40,5 % des montées)

## Passe 21 (graines à partir de 2100064)

**2 critères tenus sur 6.** 50000 combats de duel (médiane 10 tours), 0 combats non finis.

### Les six critères (section 11.2)

- ❌ **1. Chaque classe entre 47 % et 53 % de victoires** : guerrier 55,6 %, voleur 54,7 %, pretre 40,1 %, alchimiste 46,9 %, barde 44,2 %, diplomate 53,1 %, pugiliste 41,8 %
- ❌ **2. Aucune case de la matrice hors de 40 % – 60 %** : guerrier contre mage 62,4 %, guerrier contre archer 69,2 %, mage contre guerrier 33,2 %, voleur contre pretre 65,6 %, voleur contre alchimiste 65,8 %, voleur contre barde 61,2 %, archer contre guerrier 34,2 %, pretre contre guerrier 38,8 %, pretre contre mage 39,6 %, pretre contre voleur 38,4 %, pretre contre alchimiste 32,4 %, pretre contre invocateur 33,6 %, pretre contre pugiliste 37,0 %, alchimiste contre mage 37,2 %, alchimiste contre voleur 34,8 %, alchimiste contre pretre 60,8 %, alchimiste contre invocateur 37,6 %, invocateur contre pretre 61,4 %, invocateur contre barde 61,6 %, barde contre voleur 35,4 %, barde contre invocateur 37,0 %, barde contre diplomate 36,2 %, diplomate contre barde 61,0 %, pugiliste contre guerrier 33,6 %, pugiliste contre voleur 38,8 %, pugiliste contre invocateur 36,2 %, pugiliste contre diplomate 38,4 %
- ❌ **3. La route Réactive entre 40 % et 55 % (Ruée et Éventail : des repères, sans seuil)** : guerrier Réactive 55,6 %
- ✅ **4. Chaque voie jouée dans 15 % des combats au moins, une Clé dans 60 %**
- ✅ **5. Longueur : médiane de 6 à 10 tours, 95 % finis avant le tour 20**
- ❌ **6. Tour : étage 10 dans 40 à 60 % des montées, étage 20 dans 5 à 10 %, à 5 points près entre classes** : mage étage 20 4,5 %, alchimiste étage 20 15,0 %, écart entre classes : étage 10 de 41,5 % à 60,0 %, étage 20 de 4,5 % à 15,0 %

### La matrice des classes (taux de victoire de la ligne contre la colonne)

| | Guer | Mage | Vole | Arch | Prêt | Alch | Invo | Bard | Dipl | Pugi | **Moyenne** |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 50 | 62 | 51 | 69 | 60 | 46 | 47 | 57 | 55 | 58 | **55,6 %** |
| Mage | 33 | 49 | 51 | 51 | 60 | 60 | 52 | 55 | 48 | 55 | **51,4 %** |
| Voleur | 50 | 47 | 47 | 52 | 66 | 66 | 53 | 61 | 46 | 59 | **54,7 %** |
| Archer | 34 | 47 | 46 | 52 | 55 | 57 | 48 | 56 | 43 | 53 | **49,2 %** |
| Prêtre | 39 | 40 | 38 | 44 | 48 | 32 | 34 | 46 | 43 | 37 | **40,1 %** |
| Alchimiste | 53 | 37 | 35 | 40 | 61 | 51 | 38 | 56 | 45 | 53 | **46,9 %** |
| Invocateur | 46 | 48 | 46 | 52 | 61 | 60 | 49 | 62 | 45 | 54 | **52,3 %** |
| Barde | 43 | 44 | 35 | 49 | 54 | 40 | 37 | 52 | 36 | 52 | **44,2 %** |
| Diplomate | 44 | 49 | 49 | 56 | 55 | 49 | 57 | 61 | 53 | 59 | **53,1 %** |
| Pugiliste | 34 | 41 | 39 | 44 | 53 | 43 | 36 | 44 | 38 | 46 | **41,8 %** |

### Les trois routes, l'usage des voies et la Tour, par classe

| Classe | Ruée | Éventail | Réactive | Voie 1 | Voie 2 | Voie 3 | Voie 4 | Voie 5 | Clé | Tour : étage 10 | étage 20 | étage moyen |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 45,7 % | 14,5 % | 55,6 % | 31,8 % | 42,1 % | 43,1 % | 83,7 % | 53,6 % | 95,2 % | 58,5 % | 9,0 % | 11,4 |
| Mage | 58,7 % | 29,0 % | 51,4 % | 25,1 % | 62,2 % | 15,7 % | 55,3 % | 16,7 % | 74,9 % | 44,5 % | 4,5 % | 10,0 |
| Voleur | 49,8 % | 31,3 % | 54,7 % | 27,7 % | 18,9 % | 50,2 % | 37,5 % | 35,4 % | 76,9 % | 60,0 % | 10,0 % | 11,3 |
| Archer | 53,8 % | 30,7 % | 49,2 % | 16,2 % | 34,2 % | 64,0 % | 17,4 % | 33,7 % | 68,3 % | 44,0 % | 8,0 % | 10,3 |
| Prêtre | 31,5 % | 9,8 % | 40,1 % | 33,9 % | 55,8 % | 48,4 % | 62,1 % | 72,4 % | 88,9 % | 41,5 % | 8,5 % | 9,7 |
| Alchimiste | 39,7 % | 14,5 % | 46,9 % | 47,5 % | 42,3 % | 26,6 % | 40,7 % | 54,2 % | 86,1 % | 56,0 % | 15,0 % | 11,9 |
| Invocateur | 60,2 % | 28,5 % | 52,3 % | 54,5 % | 18,7 % | 40,1 % | 32,8 % | 22,2 % | 60,9 % | 52,5 % | 10,0 % | 11,0 |
| Barde | 30,5 % | 13,7 % | 44,2 % | 32,1 % | 30,8 % | 33,8 % | 35,1 % | 65,6 % | 78,8 % | 44,5 % | 7,5 % | 9,6 |
| Diplomate | 32,5 % | 17,5 % | 53,1 % | 15,6 % | 56,6 % | 79,6 % | 65,2 % | 49,1 % | 78,9 % | 51,5 % | 10,0 % | 11,0 |
| Pugiliste | 46,5 % | 10,7 % | 41,8 % | 27,4 % | 39,6 % | 71,0 % | 66,7 % | 21,1 % | 91,2 % | 46,0 % | 8,5 % | 10,0 |

### Boutons touchés, et pourquoi

- k_classe Guerrier : 0,853 → 0,847 (55,6 % de victoires)
- k_classe Mage : 0,954 → 0,951 (51,4 % de victoires)
- k_classe Voleur : 0,832 → 0,828 (54,7 % de victoires)
- k_classe Prêtre : 0,839 → 0,849 (40,1 % de victoires)
- k_classe Alchimiste : 1,001 → 1,004 (46,9 % de victoires)
- k_classe Invocateur : 0,953 → 0,951 (52,3 % de victoires)
- k_classe Barde : 1,100 → 1,108 (44,2 % de victoires)
- k_classe Diplomate : 1,171 → 1,167 (53,1 % de victoires)
- k_classe Pugiliste : 0,961 → 0,970 (41,8 % de victoires)
- budgets de la Voie de la Foudre (Mage) : +3 % (jouée dans 15,7 % des combats)
- budgets de la Voie de l'Arcane (Mage) : +3 % (jouée dans 16,7 % des combats)
- budgets de la Voie de la Précision (Archer) : +3 % (jouée dans 16,2 % des combats)
- budgets des Clés (Invocateur) : +3 % (une Clé jouée dans 60,9 % des combats)
- budgets des premiers nœuds des autres voies (Diplomate) : -3 % (la Voie de l'Intimidation, jouée dans 15,6 % des combats, commence par un état seul)
- duels de Mage (trop bas contre Guerrier ; trop haut contre Prêtre, Alchimiste) : Voie du Brasier -3 %, Voie de la Foudre -3 %, Voie de l'Arcane -3 %
- duels de Voleur (trop bas contre personne ; trop haut contre Prêtre, Alchimiste, Barde, Pugiliste) : Voie des Ombres -3 %, Voie du Poison -3 %, Voie de l'Éventail -3 %
- duels de Archer (trop bas contre Guerrier ; trop haut contre personne) : Voie de la Précision -3 %, Voie de la Volée -3 %, Voie du Feu grégeois -3 %
- duels de Prêtre (trop bas contre Guerrier, Mage, Voleur, Alchimiste, Invocateur, Pugiliste ; trop haut contre personne) : Voie de la Lumière +3 %, Voie du Châtiment -3 %, Voie de la Protection +3 %, Voie de la Purification +3 %
- duels de Alchimiste (trop bas contre Mage, Voleur, Archer, Invocateur ; trop haut contre Prêtre) : Voie de l'Acide -3 %, Voie de l'Élixir +3 %, Voie du Mutagène +3 %, Voie de la Nitro -3 %
- duels de Invocateur (trop bas contre personne ; trop haut contre Prêtre, Alchimiste, Barde) : Voie de la Meute -3 %, Voie du Gardien +3 %, Voie de l'Élémentaire -3 %, Voie du Pacte +3 %
- duels de Diplomate (trop bas contre personne ; trop haut contre Barde, Pugiliste) : Voie du Traité +3 %, Voie de l'Éloquence +3 %, Voie du Duel -3 %
- duels de Pugiliste (trop bas contre Guerrier, Mage, Voleur, Invocateur, Diplomate ; trop haut contre personne) : Voie des Poings -3 %, Voie du Souffle +3 %, Voie du Tourbillon -3 %
- Tour : force des monstres au départ 0,385 → 0,385, en plus par étage 0,025 → 0,025 (étage 10 atteint dans 49,9 % des montées, étage 20 dans 9,1 %)
- Tour, Guerrier : facteur des monstres 1,648 → 1,662 (étage 10 dans 58,5 % des montées)
- Tour, Mage : pente des monstres 1,018 → 0,987 (étage 20 dans 4,5 % des montées)
- Tour, Mage : facteur des monstres 0,797 → 0,788 (étage 10 dans 44,5 % des montées)
- Tour, Voleur : pente des monstres 0,739 → 0,758 (étage 20 dans 10,0 % des montées)
- Tour, Voleur : facteur des monstres 0,885 → 0,894 (étage 10 dans 60,0 % des montées)
- Tour, Archer : facteur des monstres 0,731 → 0,722 (étage 10 dans 44,0 % des montées)
- Tour, Prêtre : facteur des monstres 1,097 → 1,088 (étage 10 dans 41,5 % des montées)
- Tour, Alchimiste : pente des monstres 0,950 → 1,021 (étage 20 dans 15,0 % des montées)
- Tour, Alchimiste : facteur des monstres 0,995 → 1,001 (étage 10 dans 56,0 % des montées)
- Tour, Invocateur : pente des monstres 1,105 → 1,119 (étage 20 dans 10,0 % des montées)
- Tour, Invocateur : facteur des monstres 0,912 → 0,914 (étage 10 dans 52,5 % des montées)
- Tour, Barde : facteur des monstres 0,824 → 0,819 (étage 10 dans 44,5 % des montées)
- Tour, Diplomate : pente des monstres 1,000 → 1,050 (étage 20 dans 10,0 % des montées)
- Tour, Pugiliste : facteur des monstres 0,935 → 0,931 (étage 10 dans 46,0 % des montées)

## Passe 22 (graines à partir de 2200067)

**1 critères tenus sur 6.** 50000 combats de duel (médiane 11 tours), 0 combats non finis.

### Les six critères (section 11.2)

- ❌ **1. Chaque classe entre 47 % et 53 % de victoires** : guerrier 56,5 %, voleur 56,5 %, pretre 42,7 %, invocateur 55,0 %, diplomate 43,5 %, pugiliste 42,4 %
- ❌ **2. Aucune case de la matrice hors de 40 % – 60 %** : guerrier contre mage 65,8 %, guerrier contre archer 71,6 %, guerrier contre pugiliste 64,4 %, mage contre guerrier 33,6 %, mage contre pugiliste 60,8 %, voleur contre pretre 64,4 %, voleur contre alchimiste 64,4 %, voleur contre diplomate 60,8 %, archer contre guerrier 29,2 %, archer contre pugiliste 60,8 %, pretre contre mage 38,8 %, pretre contre voleur 33,8 %, pretre contre alchimiste 34,0 %, pretre contre invocateur 38,8 %, alchimiste contre mage 39,6 %, alchimiste contre voleur 36,8 %, alchimiste contre pretre 64,8 %, alchimiste contre diplomate 64,8 %, invocateur contre pretre 61,6 %, invocateur contre pugiliste 61,8 %, barde contre diplomate 65,0 %, barde contre pugiliste 64,2 %, diplomate contre alchimiste 35,8 %, diplomate contre barde 39,4 %, pugiliste contre guerrier 35,6 %, pugiliste contre mage 39,6 %, pugiliste contre voleur 39,4 %, pugiliste contre archer 36,4 %, pugiliste contre alchimiste 38,4 %, pugiliste contre invocateur 37,4 %, pugiliste contre barde 37,6 %
- ❌ **3. La route Réactive entre 40 % et 55 % (Ruée et Éventail : des repères, sans seuil)** : guerrier Réactive 56,5 %, voleur Réactive 56,5 %
- ✅ **4. Chaque voie jouée dans 15 % des combats au moins, une Clé dans 60 %**
- ❌ **5. Longueur : médiane de 6 à 10 tours, 95 % finis avant le tour 20** : médiane 11 tours
- ❌ **6. Tour : étage 10 dans 40 à 60 % des montées, étage 20 dans 5 à 10 %, à 5 points près entre classes** : guerrier étage 10 61,5 %, diplomate étage 10 66,5 %, diplomate étage 20 10,5 %, écart entre classes : étage 10 de 42,5 % à 66,5 %, étage 20 de 6,0 % à 10,5 %

### La matrice des classes (taux de victoire de la ligne contre la colonne)

| | Guer | Mage | Vole | Arch | Prêt | Alch | Invo | Bard | Dipl | Pugi | **Moyenne** |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 51 | 66 | 53 | 72 | 60 | 44 | 50 | 50 | 56 | 64 | **56,5 %** |
| Mage | 34 | 50 | 51 | 55 | 60 | 58 | 48 | 51 | 58 | 61 | **52,6 %** |
| Voleur | 52 | 45 | 53 | 56 | 64 | 64 | 53 | 56 | 61 | 59 | **56,5 %** |
| Archer | 29 | 47 | 51 | 50 | 51 | 53 | 46 | 46 | 55 | 61 | **48,9 %** |
| Prêtre | 43 | 39 | 34 | 47 | 53 | 34 | 39 | 40 | 50 | 48 | **42,7 %** |
| Alchimiste | 56 | 40 | 37 | 43 | 65 | 47 | 46 | 57 | 65 | 56 | **51,0 %** |
| Invocateur | 49 | 51 | 49 | 52 | 62 | 56 | 51 | 59 | 60 | 62 | **55,0 %** |
| Barde | 47 | 49 | 41 | 54 | 59 | 43 | 46 | 54 | 65 | 64 | **52,2 %** |
| Diplomate | 44 | 40 | 40 | 44 | 48 | 36 | 48 | 39 | 49 | 47 | **43,5 %** |
| Pugiliste | 36 | 40 | 39 | 36 | 52 | 38 | 37 | 38 | 57 | 51 | **42,4 %** |

### Les trois routes, l'usage des voies et la Tour, par classe

| Classe | Ruée | Éventail | Réactive | Voie 1 | Voie 2 | Voie 3 | Voie 4 | Voie 5 | Clé | Tour : étage 10 | étage 20 | étage moyen |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 43,7 % | 17,2 % | 56,5 % | 34,5 % | 43,8 % | 48,1 % | 79,2 % | 57,1 % | 94,3 % | 61,5 % | 7,0 % | 11,4 |
| Mage | 62,8 % | 37,0 % | 52,6 % | 24,5 % | 64,5 % | 16,4 % | 52,8 % | 16,3 % | 73,0 % | 50,5 % | 8,0 % | 10,8 |
| Voleur | 54,5 % | 32,5 % | 56,5 % | 25,7 % | 18,1 % | 51,9 % | 46,4 % | 31,9 % | 76,2 % | 58,5 % | 6,0 % | 11,1 |
| Archer | 59,2 % | 33,7 % | 48,9 % | 17,5 % | 28,4 % | 69,6 % | 17,3 % | 30,9 % | 66,9 % | 43,5 % | 7,0 % | 9,9 |
| Prêtre | 25,3 % | 12,2 % | 42,7 % | 36,0 % | 53,7 % | 49,2 % | 64,3 % | 72,3 % | 87,5 % | 44,0 % | 9,5 % | 9,9 |
| Alchimiste | 45,0 % | 18,2 % | 51,0 % | 47,5 % | 44,4 % | 25,9 % | 45,3 % | 57,0 % | 85,6 % | 52,5 % | 10,0 % | 11,2 |
| Invocateur | 56,5 % | 31,3 % | 55,0 % | 41,4 % | 23,2 % | 50,5 % | 34,2 % | 30,0 % | 63,0 % | 52,0 % | 7,0 % | 10,6 |
| Barde | 31,5 % | 15,7 % | 52,2 % | 32,0 % | 29,5 % | 33,2 % | 36,4 % | 69,2 % | 78,1 % | 42,5 % | 7,5 % | 9,7 |
| Diplomate | 26,0 % | 10,5 % | 43,5 % | 15,7 % | 58,2 % | 83,7 % | 57,9 % | 58,0 % | 84,1 % | 66,5 % | 10,5 % | 12,5 |
| Pugiliste | 49,0 % | 14,2 % | 42,4 % | 23,0 % | 43,3 % | 78,3 % | 63,8 % | 23,1 % | 91,4 % | 43,5 % | 8,0 % | 9,6 |

### Boutons touchés, et pourquoi

- PV de toutes les classes : ×0,372 → ×0,338 des PV de la spécification (médiane 11 tours, 99,3 % finis avant le tour 20 ; on vise 10 tours)
- k_classe Guerrier : 0,847 → 0,841 (56,5 % de victoires)
- k_classe Mage : 0,951 → 0,946 (52,6 % de victoires)
- k_classe Voleur : 0,828 → 0,822 (56,5 % de victoires)
- k_classe Archer : 0,910 → 0,910 (48,9 % de victoires)
- k_classe Prêtre : 0,849 → 0,856 (42,7 % de victoires)
- k_classe Invocateur : 0,951 → 0,945 (55,0 % de victoires)
- k_classe Barde : 1,108 → 1,106 (52,2 % de victoires)
- k_classe Diplomate : 1,167 → 1,171 (43,5 % de victoires)
- k_classe Pugiliste : 0,970 → 0,978 (42,4 % de victoires)
- budgets de la Voie de la Foudre (Mage) : +3 % (jouée dans 16,4 % des combats)
- budgets de la Voie de l'Arcane (Mage) : +3 % (jouée dans 16,3 % des combats)
- budgets des premiers nœuds des autres voies (Diplomate) : -3 % (la Voie de l'Intimidation, jouée dans 15,7 % des combats, commence par un état seul)
- duels de Mage (trop bas contre Guerrier ; trop haut contre Prêtre, Alchimiste, Diplomate, Pugiliste) : Voie du Brasier -3 %, Voie de la Foudre -3 %, Voie de l'Arcane -3 %
- duels de Voleur (trop bas contre personne ; trop haut contre Prêtre, Alchimiste, Diplomate, Pugiliste) : Voie des Ombres -3 %, Voie du Poison -3 %, Voie de l'Éventail -3 %
- duels de Archer (trop bas contre Guerrier ; trop haut contre Pugiliste) : Voie de la Précision -3 %, Voie de la Volée -3 %, Voie du Feu grégeois -3 %
- duels de Alchimiste (trop bas contre Mage, Voleur ; trop haut contre Prêtre, Diplomate) : Voie de l'Acide -3 %, Voie de l'Élixir +3 %, Voie du Mutagène +3 %, Voie de la Nitro -3 %
- duels de Invocateur (trop bas contre personne ; trop haut contre Prêtre, Barde, Diplomate, Pugiliste) : Voie de la Meute -3 %, Voie du Gardien +3 %, Voie de l'Élémentaire -3 %, Voie du Pacte +3 %
- duels de Barde (trop bas contre Voleur ; trop haut contre Prêtre, Diplomate, Pugiliste) : Voie du Refrain +3 %, Voie du Solo -3 %
- duels de Pugiliste (trop bas contre Guerrier, Mage, Voleur, Archer, Alchimiste, Invocateur, Barde ; trop haut contre personne) : Voie des Poings -3 %, Voie du Souffle +3 %, Voie du Tourbillon -3 %
- Tour, Guerrier : facteur des monstres 1,662 → 1,679 (étage 10 dans 61,5 % des montées)
- Tour, Voleur : facteur des monstres 0,894 → 0,900 (étage 10 dans 58,5 % des montées)
- Tour, Archer : facteur des monstres 0,722 → 0,710 (étage 10 dans 43,5 % des montées)
- Tour, Prêtre : pente des monstres 0,792 → 0,808 (étage 20 dans 9,5 % des montées)
- Tour, Prêtre : facteur des monstres 1,088 → 1,079 (étage 10 dans 44,0 % des montées)
- Tour, Alchimiste : pente des monstres 1,021 → 1,047 (étage 20 dans 10,0 % des montées)
- Tour, Barde : facteur des monstres 0,819 → 0,812 (étage 10 dans 42,5 % des montées)
- Tour, Diplomate : pente des monstres 1,050 → 1,113 (étage 20 dans 10,5 % des montées)
- Tour, Diplomate : facteur des monstres 1,132 → 1,149 (étage 10 dans 66,5 % des montées)
- Tour, Pugiliste : facteur des monstres 0,931 → 0,924 (étage 10 dans 43,5 % des montées)

## Passe 23 (graines à partir de 2300070)

**1 critères tenus sur 6.** 50000 combats de duel (médiane 10 tours), 0 combats non finis.

### Les six critères (section 11.2)

- ❌ **1. Chaque classe entre 47 % et 53 % de victoires** : guerrier 59,7 %, mage 57,2 %, alchimiste 53,6 %, invocateur 46,8 %, diplomate 45,8 %, pugiliste 44,9 %
- ❌ **2. Aucune case de la matrice hors de 40 % – 60 %** : guerrier contre mage 64,6 %, guerrier contre archer 67,8 %, guerrier contre pretre 65,6 %, guerrier contre pugiliste 65,6 %, mage contre guerrier 36,6 %, mage contre pretre 61,0 %, mage contre alchimiste 65,4 %, mage contre invocateur 63,0 %, mage contre diplomate 63,4 %, mage contre pugiliste 62,6 %, archer contre guerrier 26,8 %, archer contre pugiliste 62,0 %, pretre contre alchimiste 39,8 %, alchimiste contre pretre 60,2 %, alchimiste contre diplomate 60,4 %, invocateur contre mage 39,8 %, barde contre pugiliste 65,0 %, diplomate contre alchimiste 39,2 %, pugiliste contre guerrier 37,6 %, pugiliste contre mage 38,8 %, pugiliste contre archer 37,4 %, pugiliste contre barde 37,6 %
- ❌ **3. La route Réactive entre 40 % et 55 % (Ruée et Éventail : des repères, sans seuil)** : guerrier Réactive 59,7 %, mage Réactive 57,2 %
- ❌ **4. Chaque voie jouée dans 15 % des combats au moins, une Clé dans 60 %** : voleur voie 1 13,6 %, invocateur : Clé jouée dans 59,8 % des combats
- ✅ **5. Longueur : médiane de 6 à 10 tours, 95 % finis avant le tour 20**
- ❌ **6. Tour : étage 10 dans 40 à 60 % des montées, étage 20 dans 5 à 10 %, à 5 points près entre classes** : guerrier étage 10 62,0 %, pretre étage 20 10,5 %, alchimiste étage 20 13,5 %, barde étage 10 38,5 %, écart entre classes : étage 10 de 38,5 % à 62,0 %, étage 20 de 5,5 % à 13,5 %

### La matrice des classes (taux de victoire de la ligne contre la colonne)

| | Guer | Mage | Vole | Arch | Prêt | Alch | Invo | Bard | Dipl | Pugi | **Moyenne** |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 50 | 65 | 60 | 68 | 66 | 51 | 56 | 57 | 60 | 66 | **59,7 %** |
| Mage | 37 | 51 | 57 | 54 | 61 | 65 | 63 | 58 | 63 | 63 | **57,2 %** |
| Voleur | 42 | 41 | 53 | 43 | 59 | 55 | 50 | 48 | 56 | 56 | **50,3 %** |
| Archer | 27 | 44 | 59 | 46 | 54 | 53 | 60 | 50 | 57 | 62 | **51,1 %** |
| Prêtre | 45 | 45 | 46 | 49 | 53 | 40 | 56 | 42 | 56 | 52 | **48,2 %** |
| Alchimiste | 56 | 43 | 47 | 45 | 60 | 53 | 59 | 52 | 60 | 60 | **53,6 %** |
| Invocateur | 44 | 40 | 50 | 42 | 51 | 46 | 50 | 42 | 48 | 54 | **46,8 %** |
| Barde | 41 | 45 | 56 | 49 | 58 | 48 | 57 | 49 | 59 | 65 | **52,9 %** |
| Diplomate | 43 | 46 | 50 | 42 | 45 | 39 | 53 | 42 | 52 | 46 | **45,8 %** |
| Pugiliste | 38 | 39 | 47 | 37 | 52 | 44 | 51 | 38 | 53 | 50 | **44,9 %** |

### Les trois routes, l'usage des voies et la Tour, par classe

| Classe | Ruée | Éventail | Réactive | Voie 1 | Voie 2 | Voie 3 | Voie 4 | Voie 5 | Clé | Tour : étage 10 | étage 20 | étage moyen |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 43,0 % | 20,0 % | 59,7 % | 34,1 % | 43,3 % | 49,0 % | 76,0 % | 59,5 % | 92,9 % | 62,0 % | 9,5 % | 11,7 |
| Mage | 63,5 % | 39,5 % | 57,2 % | 24,7 % | 65,1 % | 18,0 % | 49,1 % | 15,5 % | 65,7 % | 46,0 % | 9,0 % | 10,2 |
| Voleur | 48,5 % | 27,0 % | 50,3 % | 13,6 % | 18,3 % | 58,6 % | 46,0 % | 39,8 % | 74,4 % | 54,5 % | 6,5 % | 10,4 |
| Archer | 54,5 % | 40,5 % | 51,1 % | 16,0 % | 27,7 % | 71,3 % | 16,7 % | 31,8 % | 60,2 % | 44,0 % | 5,5 % | 10,0 |
| Prêtre | 31,3 % | 10,3 % | 48,2 % | 32,7 % | 54,6 % | 44,8 % | 62,2 % | 70,2 % | 84,2 % | 50,5 % | 10,5 % | 10,8 |
| Alchimiste | 46,5 % | 16,0 % | 53,6 % | 45,9 % | 49,3 % | 18,0 % | 52,0 % | 54,9 % | 80,2 % | 52,5 % | 13,5 % | 11,5 |
| Invocateur | 55,3 % | 26,5 % | 46,8 % | 36,4 % | 24,6 % | 56,8 % | 33,4 % | 28,8 % | 59,8 % | 42,5 % | 7,5 % | 9,7 |
| Barde | 43,8 % | 21,3 % | 52,9 % | 32,2 % | 35,2 % | 33,8 % | 34,3 % | 62,1 % | 74,4 % | 38,5 % | 8,5 % | 9,4 |
| Diplomate | 20,3 % | 10,5 % | 45,8 % | 22,6 % | 53,9 % | 81,3 % | 47,7 % | 56,6 % | 81,0 % | 55,0 % | 5,5 % | 11,2 |
| Pugiliste | 58,3 % | 20,3 % | 44,9 % | 23,8 % | 47,4 % | 81,3 % | 56,5 % | 21,6 % | 87,9 % | 52,0 % | 8,5 % | 10,6 |

### Boutons touchés, et pourquoi

- k_classe Guerrier : 0,841 → 0,792 (59,7 % de victoires)
- k_classe Mage : 0,946 → 0,905 (57,2 % de victoires)
- k_classe Archer : 0,910 → 0,907 (51,1 % de victoires)
- k_classe Prêtre : 0,856 → 0,865 (48,2 % de victoires)
- k_classe Alchimiste : 1,004 → 0,983 (53,6 % de victoires)
- k_classe Invocateur : 0,945 → 0,954 (46,8 % de victoires)
- k_classe Barde : 1,106 → 1,087 (52,9 % de victoires)
- k_classe Diplomate : 1,171 → 1,200 (45,8 % de victoires)
- k_classe Pugiliste : 0,978 → 1,008 (44,9 % de victoires)
- budgets de la Voie de l'Arcane (Mage) : +3 % (jouée dans 15,5 % des combats)
- budgets de la Voie des Ombres (Voleur) : +3 % (jouée dans 13,6 % des combats)
- budgets de la Voie de la Précision (Archer) : +3 % (jouée dans 16,0 % des combats)
- budgets de la Voie du Feu grégeois (Archer) : +3 % (jouée dans 16,7 % des combats)
- budgets des Clés (Archer) : +3 % (une Clé jouée dans 60,2 % des combats)
- budgets des Clés (Invocateur) : +3 % (une Clé jouée dans 59,8 % des combats)
- duels de Mage (trop bas contre Guerrier ; trop haut contre Prêtre, Alchimiste, Invocateur, Diplomate, Pugiliste) : Voie du Brasier -3 %, Voie de la Foudre -3 %, Voie de l'Arcane -3 %
- duels de Voleur (trop bas contre Mage ; trop haut contre Prêtre) : Voie des Ombres -3 %, Voie du Poison -3 %, Voie de l'Éventail -3 %
- duels de Barde (trop bas contre Guerrier ; trop haut contre Diplomate, Pugiliste) : Voie du Refrain +3 %, Voie du Solo -3 %
- Tour, Guerrier : pente des monstres 0,874 → 0,879 (étage 20 dans 9,5 % des montées)
- Tour, Guerrier : facteur des monstres 1,679 → 1,700 (étage 10 dans 62,0 % des montées)
- Tour, Mage : facteur des monstres 0,788 → 0,782 (étage 10 dans 46,0 % des montées)
- Tour, Voleur : facteur des monstres 0,900 → 0,905 (étage 10 dans 54,5 % des montées)
- Tour, Archer : facteur des monstres 0,710 → 0,702 (étage 10 dans 44,0 % des montées)
- Tour, Prêtre : pente des monstres 0,808 → 0,832 (étage 20 dans 10,5 % des montées)
- Tour, Alchimiste : pente des monstres 1,047 → 1,109 (étage 20 dans 13,5 % des montées)
- Tour, Alchimiste : facteur des monstres 1,001 → 1,004 (étage 10 dans 52,5 % des montées)
- Tour, Invocateur : facteur des monstres 0,914 → 0,911 (étage 10 dans 42,5 % des montées)
- Tour, Barde : facteur des monstres 0,812 → 0,803 (étage 10 dans 38,5 % des montées)
- Tour, Diplomate : facteur des monstres 1,149 → 1,155 (étage 10 dans 55,0 % des montées)
- Tour, Pugiliste : facteur des monstres 0,924 → 0,925 (étage 10 dans 52,0 % des montées)

## Passe 24 (graines à partir de 2400073)

**1 critères tenus sur 6.** 50000 combats de duel (médiane 10 tours), 0 combats non finis.

### Les six critères (section 11.2)

- ❌ **1. Chaque classe entre 47 % et 53 % de victoires** : guerrier 53,9 %, voleur 61,8 %, archer 46,8 %, pretre 44,1 %, invocateur 61,2 %, barde 43,3 %, pugiliste 43,8 %
- ❌ **2. Aucune case de la matrice hors de 40 % – 60 %** : guerrier contre mage 71,2 %, guerrier contre archer 70,2 %, guerrier contre barde 61,0 %, mage contre guerrier 33,0 %, mage contre voleur 38,0 %, mage contre invocateur 38,2 %, voleur contre mage 63,4 %, voleur contre pretre 71,0 %, voleur contre alchimiste 69,4 %, voleur contre barde 66,6 %, voleur contre diplomate 63,6 %, voleur contre pugiliste 62,8 %, archer contre guerrier 28,4 %, pretre contre voleur 31,0 %, pretre contre invocateur 36,0 %, alchimiste contre voleur 31,2 %, alchimiste contre invocateur 37,0 %, alchimiste contre barde 60,2 %, invocateur contre mage 63,4 %, invocateur contre pretre 66,2 %, invocateur contre alchimiste 65,0 %, invocateur contre barde 68,4 %, invocateur contre diplomate 61,6 %, invocateur contre pugiliste 67,2 %, barde contre voleur 34,6 %, barde contre invocateur 31,4 %, diplomate contre voleur 39,8 %, pugiliste contre voleur 36,6 %, pugiliste contre invocateur 34,8 %
- ❌ **3. La route Réactive entre 40 % et 55 % (Ruée et Éventail : des repères, sans seuil)** : voleur Réactive 61,8 %, invocateur Réactive 61,2 %
- ❌ **4. Chaque voie jouée dans 15 % des combats au moins, une Clé dans 60 %** : mage voie 5 14,0 %, voleur voie 1 10,3 %, invocateur : Clé jouée dans 59,6 % des combats
- ✅ **5. Longueur : médiane de 6 à 10 tours, 95 % finis avant le tour 20**
- ❌ **6. Tour : étage 10 dans 40 à 60 % des montées, étage 20 dans 5 à 10 %, à 5 points près entre classes** : guerrier étage 10 62,0 %, voleur étage 10 68,0 %, archer étage 20 12,0 %, pretre étage 20 11,0 %, alchimiste étage 20 10,5 %, pugiliste étage 20 12,5 %, écart entre classes : étage 10 de 42,5 % à 68,0 %, étage 20 de 6,5 % à 12,5 %

### La matrice des classes (taux de victoire de la ligne contre la colonne)

| | Guer | Mage | Vole | Arch | Prêt | Alch | Invo | Bard | Dipl | Pugi | **Moyenne** |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 48 | 71 | 45 | 70 | 50 | 46 | 43 | 61 | 48 | 57 | **53,9 %** |
| Mage | 33 | 46 | 38 | 51 | 54 | 53 | 38 | 56 | 51 | 56 | **47,6 %** |
| Voleur | 53 | 63 | 53 | 60 | 71 | 69 | 55 | 67 | 64 | 63 | **61,8 %** |
| Archer | 28 | 49 | 41 | 48 | 49 | 52 | 43 | 53 | 50 | 55 | **46,8 %** |
| Prêtre | 48 | 45 | 31 | 50 | 48 | 41 | 36 | 51 | 45 | 46 | **44,1 %** |
| Alchimiste | 56 | 47 | 31 | 46 | 59 | 49 | 37 | 60 | 55 | 50 | **49,1 %** |
| Invocateur | 56 | 63 | 50 | 59 | 66 | 65 | 55 | 68 | 62 | 67 | **61,2 %** |
| Barde | 42 | 41 | 35 | 44 | 49 | 41 | 31 | 50 | 48 | 53 | **43,3 %** |
| Diplomate | 49 | 49 | 40 | 51 | 54 | 43 | 41 | 52 | 47 | 50 | **47,5 %** |
| Pugiliste | 42 | 47 | 37 | 40 | 55 | 42 | 35 | 43 | 48 | 49 | **43,8 %** |

### Les trois routes, l'usage des voies et la Tour, par classe

| Classe | Ruée | Éventail | Réactive | Voie 1 | Voie 2 | Voie 3 | Voie 4 | Voie 5 | Clé | Tour : étage 10 | étage 20 | étage moyen |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 38,3 % | 16,3 % | 53,9 % | 31,9 % | 41,3 % | 49,6 % | 75,7 % | 59,6 % | 94,0 % | 62,0 % | 7,5 % | 11,7 |
| Mage | 64,5 % | 31,8 % | 47,6 % | 26,2 % | 64,4 % | 15,8 % | 43,6 % | 14,0 % | 67,0 % | 46,0 % | 8,5 % | 10,1 |
| Voleur | 72,0 % | 46,8 % | 61,8 % | 10,3 % | 21,5 % | 54,5 % | 44,9 % | 36,2 % | 72,0 % | 68,0 % | 8,0 % | 11,8 |
| Archer | 59,0 % | 31,3 % | 46,8 % | 17,1 % | 25,8 % | 65,6 % | 24,7 % | 31,4 % | 63,8 % | 44,0 % | 12,0 % | 10,6 |
| Prêtre | 30,3 % | 8,5 % | 44,1 % | 34,8 % | 53,9 % | 57,5 % | 63,3 % | 68,7 % | 85,1 % | 57,0 % | 11,0 % | 11,3 |
| Alchimiste | 39,8 % | 19,3 % | 49,1 % | 47,7 % | 47,7 % | 18,1 % | 49,1 % | 55,4 % | 82,2 % | 53,5 % | 10,5 % | 11,3 |
| Invocateur | 66,5 % | 41,0 % | 61,2 % | 31,4 % | 24,7 % | 55,0 % | 36,2 % | 31,8 % | 59,6 % | 54,5 % | 9,5 % | 11,2 |
| Barde | 38,5 % | 21,5 % | 43,3 % | 38,5 % | 58,5 % | 39,5 % | 38,2 % | 31,1 % | 77,9 % | 42,5 % | 6,5 % | 9,5 |
| Diplomate | 27,3 % | 14,5 % | 47,5 % | 23,2 % | 56,2 % | 81,4 % | 49,4 % | 55,0 % | 81,0 % | 57,5 % | 10,0 % | 11,4 |
| Pugiliste | 59,3 % | 17,0 % | 43,8 % | 22,9 % | 44,7 % | 81,5 % | 54,3 % | 21,7 % | 89,6 % | 59,0 % | 12,5 % | 11,4 |

### Boutons touchés, et pourquoi

- k_classe Guerrier : 0,792 → 0,774 (53,9 % de victoires)
- k_classe Mage : 0,905 → 0,911 (47,6 % de victoires)
- k_classe Voleur : 0,822 → 0,772 (61,8 % de victoires)
- k_classe Archer : 0,907 → 0,912 (46,8 % de victoires)
- k_classe Prêtre : 0,865 → 0,895 (44,1 % de victoires)
- k_classe Alchimiste : 0,983 → 0,986 (49,1 % de victoires)
- k_classe Invocateur : 0,954 → 0,938 (61,2 % de victoires)
- k_classe Barde : 1,087 → 1,109 (43,3 % de victoires)
- k_classe Pugiliste : 1,008 → 1,045 (43,8 % de victoires)
- budgets de la Voie de la Foudre (Mage) : +3 % (jouée dans 15,8 % des combats)
- budgets de la Voie de l'Arcane (Mage) : +3 % (jouée dans 14,0 % des combats)
- budgets de la Voie des Ombres (Voleur) : +3 % (jouée dans 10,3 % des combats)
- budgets des Clés (Invocateur) : +3 % (une Clé jouée dans 59,6 % des combats)
- duels de Alchimiste (trop bas contre Voleur, Invocateur ; trop haut contre Prêtre, Barde) : Voie de l'Acide -3 %, Voie de l'Élixir +3 %, Voie du Mutagène +3 %, Voie de la Nitro -3 %
- Tour : force des monstres au départ 0,385 → 0,387, en plus par étage 0,025 → 0,026 (étage 10 atteint dans 54,4 % des montées, étage 20 dans 9,6 %)
- Tour, Guerrier : facteur des monstres 1,700 → 1,712 (étage 10 dans 62,0 % des montées)
- Tour, Mage : facteur des monstres 0,782 → 0,769 (étage 10 dans 46,0 % des montées)
- Tour, Voleur : facteur des monstres 0,905 → 0,917 (étage 10 dans 68,0 % des montées)
- Tour, Archer : pente des monstres 0,940 → 0,982 (étage 20 dans 12,0 % des montées)
- Tour, Archer : facteur des monstres 0,702 → 0,688 (étage 10 dans 44,0 % des montées)
- Tour, Prêtre : pente des monstres 0,832 → 0,861 (étage 20 dans 11,0 % des montées)
- Tour, Prêtre : facteur des monstres 1,079 → 1,081 (étage 10 dans 57,0 % des montées)
- Tour, Alchimiste : pente des monstres 1,109 → 1,143 (étage 20 dans 10,5 % des montées)
- Tour, Invocateur : pente des monstres 1,119 → 1,130 (étage 20 dans 9,5 % des montées)
- Tour, Barde : facteur des monstres 0,803 → 0,793 (étage 10 dans 42,5 % des montées)
- Tour, Diplomate : pente des monstres 1,113 → 1,169 (étage 20 dans 10,0 % des montées)
- Tour, Diplomate : facteur des monstres 1,155 → 1,159 (étage 10 dans 57,5 % des montées)
- Tour, Pugiliste : pente des monstres 0,837 → 0,879 (étage 20 dans 12,5 % des montées)
- Tour, Pugiliste : facteur des monstres 0,925 → 0,929 (étage 10 dans 59,0 % des montées)

## Passe 25 (graines à partir de 2500076)

**1 critères tenus sur 6.** 50000 combats de duel (médiane 10 tours), 0 combats non finis.

### Les six critères (section 11.2)

- ❌ **1. Chaque classe entre 47 % et 53 % de victoires** : mage 46,5 %, voleur 61,0 %, invocateur 61,3 %, barde 46,4 %, diplomate 45,8 %
- ❌ **2. Aucune case de la matrice hors de 40 % – 60 %** : guerrier contre mage 68,4 %, guerrier contre archer 64,6 %, guerrier contre invocateur 39,8 %, mage contre guerrier 36,0 %, mage contre voleur 33,4 %, mage contre invocateur 29,8 %, voleur contre mage 68,0 %, voleur contre pretre 64,8 %, voleur contre alchimiste 72,2 %, voleur contre barde 69,0 %, archer contre guerrier 34,0 %, archer contre voleur 37,8 %, archer contre invocateur 37,2 %, pretre contre voleur 33,4 %, pretre contre invocateur 34,4 %, alchimiste contre voleur 27,6 %, alchimiste contre invocateur 32,0 %, invocateur contre guerrier 62,2 %, invocateur contre mage 69,0 %, invocateur contre archer 61,8 %, invocateur contre pretre 64,0 %, invocateur contre alchimiste 67,2 %, invocateur contre barde 66,6 %, invocateur contre diplomate 60,4 %, invocateur contre pugiliste 63,8 %, barde contre voleur 30,0 %, barde contre invocateur 33,8 %, diplomate contre voleur 37,6 %, diplomate contre invocateur 39,0 %, diplomate contre pugiliste 39,4 %, pugiliste contre voleur 38,8 %, pugiliste contre invocateur 32,6 %
- ❌ **3. La route Réactive entre 40 % et 55 % (Ruée et Éventail : des repères, sans seuil)** : voleur Réactive 61,0 %, invocateur Réactive 61,3 %
- ❌ **4. Chaque voie jouée dans 15 % des combats au moins, une Clé dans 60 %** : invocateur : Clé jouée dans 58,3 % des combats
- ✅ **5. Longueur : médiane de 6 à 10 tours, 95 % finis avant le tour 20**
- ❌ **6. Tour : étage 10 dans 40 à 60 % des montées, étage 20 dans 5 à 10 %, à 5 points près entre classes** : guerrier étage 20 4,0 %, mage étage 20 11,0 %, voleur étage 10 62,5 %, pretre étage 20 11,0 %, invocateur étage 20 15,5 %, pugiliste étage 20 14,0 %, écart entre classes : étage 10 de 44,0 % à 62,5 %, étage 20 de 4,0 % à 15,5 %

### La matrice des classes (taux de victoire de la ligne contre la colonne)

| | Guer | Mage | Vole | Arch | Prêt | Alch | Invo | Bard | Dipl | Pugi | **Moyenne** |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 50 | 68 | 43 | 65 | 52 | 46 | 40 | 52 | 45 | 52 | **51,2 %** |
| Mage | 36 | 52 | 33 | 52 | 49 | 55 | 30 | 55 | 57 | 46 | **46,5 %** |
| Voleur | 59 | 68 | 51 | 60 | 65 | 72 | 50 | 69 | 56 | 60 | **61,0 %** |
| Archer | 34 | 51 | 38 | 51 | 49 | 55 | 37 | 53 | 49 | 53 | **47,0 %** |
| Prêtre | 49 | 50 | 33 | 52 | 56 | 50 | 34 | 48 | 52 | 45 | **47,0 %** |
| Alchimiste | 59 | 48 | 28 | 46 | 56 | 53 | 32 | 59 | 56 | 54 | **49,1 %** |
| Invocateur | 62 | 69 | 48 | 62 | 64 | 67 | 50 | 67 | 60 | 64 | **61,3 %** |
| Barde | 47 | 50 | 30 | 50 | 52 | 46 | 34 | 49 | 51 | 56 | **46,4 %** |
| Diplomate | 55 | 45 | 38 | 51 | 51 | 42 | 39 | 48 | 50 | 39 | **45,8 %** |
| Pugiliste | 49 | 52 | 39 | 47 | 57 | 51 | 33 | 45 | 55 | 46 | **47,4 %** |

### Les trois routes, l'usage des voies et la Tour, par classe

| Classe | Ruée | Éventail | Réactive | Voie 1 | Voie 2 | Voie 3 | Voie 4 | Voie 5 | Clé | Tour : étage 10 | étage 20 | étage moyen |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 44,8 % | 18,8 % | 51,2 % | 29,8 % | 42,1 % | 39,5 % | 83,9 % | 60,2 % | 93,0 % | 59,0 % | 4,0 % | 11,2 |
| Mage | 55,3 % | 28,7 % | 46,5 % | 21,5 % | 69,5 % | 15,3 % | 35,3 % | 16,4 % | 65,4 % | 47,0 % | 11,0 % | 10,7 |
| Voleur | 64,3 % | 46,8 % | 61,0 % | 27,2 % | 23,5 % | 49,1 % | 37,9 % | 32,4 % | 68,6 % | 62,5 % | 8,5 % | 11,3 |
| Archer | 55,5 % | 30,5 % | 47,0 % | 16,2 % | 26,9 % | 59,8 % | 25,5 % | 42,0 % | 63,1 % | 44,0 % | 9,5 % | 10,1 |
| Prêtre | 36,3 % | 13,3 % | 47,0 % | 32,7 % | 54,4 % | 60,1 % | 61,3 % | 67,0 % | 83,4 % | 48,5 % | 11,0 % | 10,8 |
| Alchimiste | 46,3 % | 18,3 % | 49,1 % | 47,6 % | 48,2 % | 17,1 % | 49,8 % | 55,0 % | 80,5 % | 50,5 % | 7,5 % | 10,5 |
| Invocateur | 65,3 % | 42,8 % | 61,3 % | 34,8 % | 24,0 % | 51,2 % | 36,8 % | 28,0 % | 58,3 % | 57,0 % | 15,5 % | 11,8 |
| Barde | 41,5 % | 19,3 % | 46,4 % | 32,4 % | 56,4 % | 37,2 % | 38,0 % | 39,2 % | 75,7 % | 45,5 % | 8,0 % | 9,9 |
| Diplomate | 32,0 % | 17,0 % | 45,8 % | 21,7 % | 59,6 % | 80,0 % | 48,6 % | 56,3 % | 79,5 % | 59,0 % | 7,0 % | 11,2 |
| Pugiliste | 64,0 % | 21,0 % | 47,4 % | 23,8 % | 48,0 % | 78,0 % | 57,1 % | 20,7 % | 88,7 % | 54,0 % | 14,0 % | 11,4 |

### Boutons touchés, et pourquoi

- k_classe Guerrier : 0,774 → 0,768 (51,2 % de victoires)
- k_classe Mage : 0,911 → 0,921 (46,5 % de victoires)
- k_classe Voleur : 0,772 → 0,750 (61,0 % de victoires)
- k_classe Archer : 0,912 → 0,916 (47,0 % de victoires)
- k_classe Prêtre : 0,895 → 0,911 (47,0 % de victoires)
- k_classe Alchimiste : 0,986 → 0,988 (49,1 % de victoires)
- k_classe Invocateur : 0,938 → 0,922 (61,3 % de victoires)
- k_classe Barde : 1,109 → 1,121 (46,4 % de victoires)
- k_classe Pugiliste : 1,045 → 1,061 (47,4 % de victoires)
- budgets de la Voie de la Foudre (Mage) : +3 % (jouée dans 15,3 % des combats)
- budgets de la Voie de l'Arcane (Mage) : +3 % (jouée dans 16,4 % des combats)
- budgets de la Voie de la Précision (Archer) : +3 % (jouée dans 16,2 % des combats)
- duels de Guerrier (trop bas contre Invocateur ; trop haut contre Mage, Archer) : Voie du Sang +3 %, Voie du Rempart -3 %, Voie de la Charge +3 %, Voie du Tonnerre +3 %, Voie du Cri -3 %
- duels de Alchimiste (trop bas contre Voleur, Invocateur ; trop haut contre Guerrier, Barde) : Voie de l'Acide -3 %, Voie de l'Élixir +3 %, Voie du Mutagène +3 %, Voie de la Nitro -3 %
- Tour : force des monstres au départ 0,387 → 0,387, en plus par étage 0,026 → 0,027 (étage 10 atteint dans 52,7 % des montées, étage 20 dans 9,6 %)
- Tour, Guerrier : pente des monstres 0,879 → 0,875 (étage 20 dans 4,0 % des montées)
- Tour, Guerrier : facteur des monstres 1,712 → 1,723 (étage 10 dans 59,0 % des montées)
- Tour, Mage : pente des monstres 0,987 → 1,004 (étage 20 dans 11,0 % des montées)
- Tour, Mage : facteur des monstres 0,769 → 0,761 (étage 10 dans 47,0 % des montées)
- Tour, Voleur : facteur des monstres 0,917 → 0,926 (étage 10 dans 62,5 % des montées)
- Tour, Archer : pente des monstres 0,982 → 1,002 (étage 20 dans 9,5 % des montées)
- Tour, Archer : facteur des monstres 0,688 → 0,676 (étage 10 dans 44,0 % des montées)
- Tour, Prêtre : pente des monstres 0,861 → 0,891 (étage 20 dans 11,0 % des montées)
- Tour, Prêtre : facteur des monstres 1,081 → 1,079 (étage 10 dans 48,5 % des montées)
- Tour, Alchimiste : facteur des monstres 1,004 → 1,002 (étage 10 dans 50,5 % des montées)
- Tour, Invocateur : pente des monstres 1,130 → 1,175 (étage 20 dans 15,5 % des montées)
- Tour, Invocateur : facteur des monstres 0,911 → 0,913 (étage 10 dans 57,0 % des montées)
- Tour, Barde : facteur des monstres 0,793 → 0,787 (étage 10 dans 45,5 % des montées)
- Tour, Diplomate : facteur des monstres 1,159 → 1,166 (étage 10 dans 59,0 % des montées)
- Tour, Pugiliste : pente des monstres 0,879 → 0,936 (étage 20 dans 14,0 % des montées)

## Passe 26 (graines à partir de 2600079)

**1 critères tenus sur 6.** 50000 combats de duel (médiane 10 tours), 0 combats non finis.

### Les six critères (section 11.2)

- ❌ **1. Chaque classe entre 47 % et 53 % de victoires** : guerrier 54,0 %, mage 43,4 %, voleur 60,1 %, archer 44,7 %, alchimiste 43,3 %, invocateur 58,7 %, diplomate 44,7 %, pugiliste 56,9 %
- ❌ **2. Aucune case de la matrice hors de 40 % – 60 %** : guerrier contre mage 72,2 %, guerrier contre archer 68,0 %, mage contre guerrier 30,0 %, mage contre voleur 31,2 %, mage contre invocateur 27,8 %, mage contre pugiliste 39,8 %, voleur contre mage 65,0 %, voleur contre archer 64,2 %, voleur contre alchimiste 75,4 %, voleur contre barde 61,4 %, voleur contre diplomate 63,6 %, archer contre guerrier 30,4 %, archer contre invocateur 38,6 %, pretre contre invocateur 37,0 %, alchimiste contre voleur 26,0 %, alchimiste contre invocateur 28,2 %, invocateur contre mage 67,2 %, invocateur contre archer 62,4 %, invocateur contre pretre 62,0 %, invocateur contre alchimiste 70,6 %, invocateur contre diplomate 60,8 %, diplomate contre voleur 39,8 %, diplomate contre invocateur 37,2 %, diplomate contre barde 39,0 %, diplomate contre pugiliste 36,4 %, pugiliste contre mage 62,6 %, pugiliste contre pretre 63,6 %, pugiliste contre alchimiste 61,6 %, pugiliste contre diplomate 66,0 %
- ❌ **3. La route Réactive entre 40 % et 55 % (Ruée et Éventail : des repères, sans seuil)** : voleur Réactive 60,1 %, invocateur Réactive 58,7 %, pugiliste Réactive 56,9 %
- ❌ **4. Chaque voie jouée dans 15 % des combats au moins, une Clé dans 60 %** : mage voie 3 15,0 %, invocateur : Clé jouée dans 55,3 % des combats
- ✅ **5. Longueur : médiane de 6 à 10 tours, 95 % finis avant le tour 20**
- ❌ **6. Tour : étage 10 dans 40 à 60 % des montées, étage 20 dans 5 à 10 %, à 5 points près entre classes** : voleur étage 10 69,0 %, archer étage 20 10,5 %, pretre étage 10 63,5 %, invocateur étage 10 68,5 %, barde étage 20 20,0 %, pugiliste étage 20 16,0 %, écart entre classes : étage 10 de 43,0 % à 69,0 %, étage 20 de 7,0 % à 20,0 %

### La matrice des classes (taux de victoire de la ligne contre la colonne)

| | Guer | Mage | Vole | Arch | Prêt | Alch | Invo | Bard | Dipl | Pugi | **Moyenne** |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 51 | 72 | 48 | 68 | 48 | 50 | 44 | 50 | 58 | 51 | **54,0 %** |
| Mage | 30 | 54 | 31 | 50 | 45 | 56 | 28 | 42 | 58 | 40 | **43,4 %** |
| Voleur | 56 | 65 | 52 | 64 | 59 | 75 | 49 | 61 | 64 | 55 | **60,1 %** |
| Archer | 30 | 53 | 41 | 49 | 43 | 55 | 39 | 44 | 50 | 45 | **44,7 %** |
| Prêtre | 56 | 50 | 42 | 55 | 47 | 51 | 37 | 42 | 53 | 42 | **47,6 %** |
| Alchimiste | 52 | 44 | 26 | 44 | 54 | 49 | 28 | 41 | 54 | 41 | **43,3 %** |
| Invocateur | 57 | 67 | 51 | 62 | 62 | 71 | 48 | 57 | 61 | 52 | **58,7 %** |
| Barde | 55 | 55 | 45 | 58 | 54 | 58 | 41 | 49 | 56 | 52 | **52,2 %** |
| Diplomate | 50 | 45 | 40 | 49 | 44 | 52 | 37 | 39 | 55 | 36 | **44,7 %** |
| Pugiliste | 53 | 63 | 53 | 57 | 64 | 62 | 48 | 52 | 66 | 53 | **56,9 %** |

### Les trois routes, l'usage des voies et la Tour, par classe

| Classe | Ruée | Éventail | Réactive | Voie 1 | Voie 2 | Voie 3 | Voie 4 | Voie 5 | Clé | Tour : étage 10 | étage 20 | étage moyen |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 50,0 % | 20,8 % | 54,0 % | 33,1 % | 39,0 % | 47,8 % | 75,4 % | 58,1 % | 93,0 % | 58,5 % | 7,0 % | 11,5 |
| Mage | 61,3 % | 28,2 % | 43,4 % | 17,8 % | 66,4 % | 15,0 % | 43,1 % | 19,7 % | 65,3 % | 52,0 % | 8,5 % | 10,9 |
| Voleur | 63,0 % | 41,8 % | 60,1 % | 28,3 % | 23,3 % | 48,9 % | 36,7 % | 29,9 % | 67,4 % | 69,0 % | 7,0 % | 11,9 |
| Archer | 56,8 % | 30,8 % | 44,7 % | 17,4 % | 26,1 % | 61,3 % | 23,0 % | 38,9 % | 62,1 % | 43,0 % | 10,5 % | 10,2 |
| Prêtre | 27,8 % | 11,5 % | 47,6 % | 34,5 % | 54,3 % | 55,2 % | 58,9 % | 71,3 % | 84,0 % | 63,5 % | 10,0 % | 11,9 |
| Alchimiste | 36,3 % | 16,3 % | 43,3 % | 45,2 % | 45,8 % | 17,1 % | 52,0 % | 54,1 % | 78,9 % | 52,5 % | 9,0 % | 11,3 |
| Invocateur | 64,3 % | 43,3 % | 58,7 % | 38,8 % | 24,3 % | 55,2 % | 28,3 % | 24,8 % | 55,3 % | 68,5 % | 9,0 % | 11,9 |
| Barde | 47,3 % | 25,5 % | 52,2 % | 36,9 % | 50,9 % | 37,2 % | 38,1 % | 36,7 % | 73,5 % | 57,0 % | 20,0 % | 12,0 |
| Diplomate | 22,8 % | 8,3 % | 44,7 % | 20,8 % | 52,6 % | 79,5 % | 48,2 % | 58,5 % | 78,9 % | 60,0 % | 8,0 % | 11,4 |
| Pugiliste | 64,5 % | 21,0 % | 56,9 % | 27,9 % | 48,5 % | 63,8 % | 67,3 % | 19,7 % | 86,8 % | 57,5 % | 16,0 % | 11,9 |

### Boutons touchés, et pourquoi

- k_classe Guerrier : 0,768 → 0,750 (54,0 % de victoires)
- k_classe Mage : 0,921 → 0,939 (43,4 % de victoires)
- k_classe Archer : 0,916 → 0,923 (44,7 % de victoires)
- k_classe Prêtre : 0,911 → 0,924 (47,6 % de victoires)
- k_classe Alchimiste : 0,988 → 1,008 (43,3 % de victoires)
- k_classe Invocateur : 0,922 → 0,910 (58,7 % de victoires)
- k_classe Barde : 1,121 → 1,117 (52,2 % de victoires)
- k_classe Pugiliste : 1,061 → 1,039 (56,9 % de victoires)
- budgets de la Voie de la Foudre (Mage) : +3 % (jouée dans 15,0 % des combats)
- duels de Mage (trop bas contre Guerrier, Voleur, Invocateur, Barde, Pugiliste ; trop haut contre Diplomate) : Voie du Brasier -3 %, Voie de la Foudre -3 %, Voie de l'Arcane -3 %
- duels de Barde (trop bas contre Invocateur ; trop haut contre Archer) : Voie du Refrain -3 %, Voie du Solo +3 %
- Tour : force des monstres au départ 0,387 → 0,391, en plus par étage 0,027 → 0,028 (étage 10 atteint dans 58,1 % des montées, étage 20 dans 10,5 %)
- Tour, Mage : facteur des monstres 0,761 → 0,751 (étage 10 dans 52,0 % des montées)
- Tour, Voleur : facteur des monstres 0,926 → 0,936 (étage 10 dans 69,0 % des montées)
- Tour, Archer : pente des monstres 1,002 → 1,032 (étage 20 dans 10,5 % des montées)
- Tour, Archer : facteur des monstres 0,676 → 0,655 (étage 10 dans 43,0 % des montées)
- Tour, Prêtre : pente des monstres 0,891 → 0,914 (étage 20 dans 10,0 % des montées)
- Tour, Prêtre : facteur des monstres 1,079 → 1,081 (étage 10 dans 63,5 % des montées)
- Tour, Alchimiste : facteur des monstres 1,002 → 0,997 (étage 10 dans 52,5 % des montées)
- Tour, Invocateur : facteur des monstres 0,913 → 0,922 (étage 10 dans 68,5 % des montées)
- Tour, Barde : pente des monstres 1,151 → 1,222 (étage 20 dans 20,0 % des montées)
- Tour, Pugiliste : pente des monstres 0,936 → 1,016 (étage 20 dans 16,0 % des montées)

## Passe 27 (graines à partir de 2700082)

**1 critères tenus sur 6.** 50000 combats de duel (médiane 8 tours), 0 combats non finis.

### Les six critères (section 11.2)

- ❌ **1. Chaque classe entre 47 % et 53 % de victoires** : guerrier 38,1 %, voleur 56,9 %, pretre 62,5 %, diplomate 37,7 %, pugiliste 63,4 %
- ❌ **2. Aucune case de la matrice hors de 40 % – 60 %** : guerrier contre voleur 32,0 %, guerrier contre pretre 24,2 %, guerrier contre alchimiste 29,8 %, guerrier contre invocateur 35,8 %, guerrier contre barde 36,6 %, guerrier contre pugiliste 31,2 %, mage contre voleur 37,6 %, mage contre pretre 36,2 %, mage contre diplomate 61,2 %, mage contre pugiliste 37,2 %, voleur contre guerrier 68,2 %, voleur contre alchimiste 71,6 %, voleur contre barde 60,8 %, voleur contre diplomate 69,2 %, archer contre pretre 38,8 %, archer contre diplomate 67,6 %, archer contre pugiliste 37,0 %, pretre contre guerrier 77,6 %, pretre contre mage 66,0 %, pretre contre archer 66,0 %, pretre contre alchimiste 64,2 %, pretre contre invocateur 65,6 %, pretre contre barde 60,6 %, pretre contre diplomate 72,2 %, alchimiste contre guerrier 71,4 %, alchimiste contre voleur 33,8 %, alchimiste contre diplomate 60,4 %, alchimiste contre pugiliste 34,2 %, invocateur contre guerrier 62,8 %, invocateur contre pretre 37,4 %, invocateur contre diplomate 60,2 %, invocateur contre pugiliste 36,0 %, barde contre guerrier 63,0 %, barde contre pretre 38,2 %, barde contre pugiliste 33,8 %, diplomate contre voleur 33,8 %, diplomate contre archer 30,8 %, diplomate contre pretre 25,6 %, diplomate contre pugiliste 23,4 %, pugiliste contre guerrier 72,6 %, pugiliste contre mage 62,6 %, pugiliste contre voleur 61,0 %, pugiliste contre archer 61,4 %, pugiliste contre alchimiste 69,2 %, pugiliste contre invocateur 65,0 %, pugiliste contre barde 63,8 %, pugiliste contre diplomate 76,4 %
- ❌ **3. La route Réactive entre 40 % et 55 % (Ruée et Éventail : des repères, sans seuil)** : guerrier Réactive 38,1 %, voleur Réactive 56,9 %, pretre Réactive 62,5 %, diplomate Réactive 37,7 %, pugiliste Réactive 63,4 %
- ❌ **4. Chaque voie jouée dans 15 % des combats au moins, une Clé dans 60 %** : archer : Clé jouée dans 58,1 % des combats, alchimiste voie 3 9,0 %, invocateur voie 2 12,5 %, invocateur voie 5 11,3 %, invocateur : Clé jouée dans 47,1 % des combats, diplomate voie 1 5,5 %, pugiliste voie 5 8,1 %
- ✅ **5. Longueur : médiane de 6 à 10 tours, 95 % finis avant le tour 20**
- ❌ **6. Tour : étage 10 dans 40 à 60 % des montées, étage 20 dans 5 à 10 %, à 5 points près entre classes** : guerrier étage 20 3,5 %, mage étage 20 15,5 %, archer étage 20 16,0 %, invocateur étage 10 36,5 %, invocateur étage 20 2,5 %, barde étage 10 38,0 %, diplomate étage 10 31,0 %, diplomate étage 20 1,5 %, écart entre classes : étage 10 de 31,0 % à 58,0 %, étage 20 de 1,5 % à 16,0 %

### La matrice des classes (taux de victoire de la ligne contre la colonne)

| | Guer | Mage | Vole | Arch | Prêt | Alch | Invo | Bard | Dipl | Pugi | **Moyenne** |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 52 | 43 | 32 | 49 | 24 | 30 | 36 | 37 | 46 | 31 | **38,1 %** |
| Mage | 58 | 47 | 38 | 45 | 36 | 59 | 50 | 51 | 61 | 37 | **48,3 %** |
| Voleur | 68 | 55 | 48 | 54 | 45 | 72 | 56 | 61 | 69 | 42 | **56,9 %** |
| Archer | 52 | 50 | 46 | 51 | 39 | 58 | 55 | 53 | 68 | 37 | **50,9 %** |
| Prêtre | 78 | 66 | 55 | 66 | 54 | 64 | 66 | 61 | 72 | 44 | **62,5 %** |
| Alchimiste | 71 | 42 | 34 | 41 | 41 | 52 | 44 | 53 | 60 | 34 | **47,4 %** |
| Invocateur | 63 | 45 | 43 | 46 | 37 | 57 | 54 | 52 | 60 | 36 | **49,3 %** |
| Barde | 63 | 43 | 41 | 41 | 38 | 51 | 49 | 52 | 59 | 34 | **47,1 %** |
| Diplomate | 53 | 41 | 34 | 31 | 26 | 40 | 42 | 41 | 48 | 23 | **37,7 %** |
| Pugiliste | 73 | 63 | 61 | 61 | 54 | 69 | 65 | 64 | 76 | 48 | **63,4 %** |

### Les trois routes, l'usage des voies et la Tour, par classe

| Classe | Ruée | Éventail | Réactive | Voie 1 | Voie 2 | Voie 3 | Voie 4 | Voie 5 | Clé | Tour : étage 10 | étage 20 | étage moyen |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 32,3 % | 10,8 % | 38,1 % | 28,1 % | 65,4 % | 30,2 % | 69,0 % | 61,1 % | 89,3 % | 41,5 % | 3,5 % | 9,0 |
| Mage | 63,0 % | 26,0 % | 48,3 % | 32,2 % | 39,7 % | 42,1 % | 35,5 % | 20,6 % | 61,1 % | 56,0 % | 15,5 % | 11,5 |
| Voleur | 45,8 % | 28,2 % | 56,9 % | 16,9 % | 25,5 % | 44,5 % | 29,7 % | 42,2 % | 61,9 % | 54,5 % | 5,0 % | 10,6 |
| Archer | 53,3 % | 26,3 % | 50,9 % | 26,4 % | 47,9 % | 41,0 % | 21,9 % | 43,4 % | 58,1 % | 47,5 % | 16,0 % | 11,1 |
| Prêtre | 52,3 % | 27,3 % | 62,5 % | 26,5 % | 56,2 % | 37,9 % | 49,4 % | 71,2 % | 76,5 % | 58,0 % | 10,0 % | 11,9 |
| Alchimiste | 37,5 % | 13,3 % | 47,4 % | 46,1 % | 32,3 % | 9,0 % | 37,7 % | 69,3 % | 76,9 % | 44,0 % | 5,5 % | 10,0 |
| Invocateur | 44,0 % | 24,8 % | 49,3 % | 34,9 % | 12,5 % | 55,8 % | 35,8 % | 11,3 % | 47,1 % | 36,5 % | 2,5 % | 8,8 |
| Barde | 34,8 % | 17,3 % | 47,1 % | 35,5 % | 32,7 % | 30,1 % | 26,4 % | 59,6 % | 70,2 % | 38,0 % | 8,0 % | 9,7 |
| Diplomate | 9,5 % | 4,0 % | 37,7 % | 5,5 % | 43,4 % | 76,6 % | 35,5 % | 76,5 % | 75,4 % | 31,0 % | 1,5 % | 7,7 |
| Pugiliste | 55,0 % | 17,8 % | 63,4 % | 35,9 % | 37,1 % | 42,6 % | 80,1 % | 8,1 % | 86,2 % | 48,0 % | 10,0 % | 10,9 |

### Boutons touchés, et pourquoi

- k_classe Guerrier : 0,754 → 0,776 (38,1 % de victoires)
- k_classe Mage : 1,021 → 1,027 (48,3 % de victoires)
- k_classe Archer : 0,962 → 0,959 (50,9 % de victoires)
- k_classe Prêtre : 0,895 → 0,868 (62,5 % de victoires)
- k_classe Alchimiste : 1,061 → 1,071 (47,4 % de victoires)
- k_classe Barde : 1,045 → 1,056 (47,1 % de victoires)
- k_classe Pugiliste : 1,082 → 1,049 (63,4 % de victoires)
- budgets des Clés (Mage) : +3 % (une Clé jouée dans 61,1 % des combats)
- budgets de la Voie des Ombres (Voleur) : +3 % (jouée dans 16,9 % des combats)
- budgets des Clés (Voleur) : +3 % (une Clé jouée dans 61,9 % des combats)
- budgets des Clés (Archer) : +3 % (une Clé jouée dans 58,1 % des combats)
- budgets de la Voie des Fumées (Alchimiste) : +3 % (jouée dans 9,0 % des combats)
- budgets des premiers nœuds des autres voies (Alchimiste) : -3 % (la Voie des Fumées, jouée dans 9,0 % des combats, commence par un état seul)
- budgets de la Voie du Gardien (Invocateur) : +3 % (jouée dans 12,5 % des combats)
- budgets de la Voie du Pacte (Invocateur) : +3 % (jouée dans 11,3 % des combats)
- budgets des Clés (Invocateur) : +3 % (une Clé jouée dans 47,1 % des combats)
- budgets de la Voie de l'Intimidation (Diplomate) : +3 % (jouée dans 5,5 % des combats)
- budgets de la Voie du Défi (Pugiliste) : +3 % (jouée dans 8,1 % des combats)
- PV du Voleur : ×1,00 → ×0,97 (k déjà à sa borne, 56,9 % de victoires)
- PV du Diplomate : ×1,00 → ×1,03 (k déjà à sa borne, 37,7 % de victoires)
- Tour : force des monstres au départ 0,391 → 0,390, en plus par étage 0,028 → 0,028 (étage 10 atteint dans 45,5 % des montées, étage 20 dans 7,8 %)
- Tour, Guerrier : pente des monstres 0,825 → 0,816 (étage 20 dans 3,5 % des montées)
- Tour, Guerrier : facteur des monstres 1,723 → 1,716 (étage 10 dans 41,5 % des montées)
- Tour, Mage : pente des monstres 1,106 → 1,150 (étage 20 dans 15,5 % des montées)
- Tour, Mage : facteur des monstres 0,759 → 0,767 (étage 10 dans 56,0 % des montées)
- Tour, Voleur : pente des monstres 0,729 → 0,720 (étage 20 dans 5,0 % des montées)
- Tour, Voleur : facteur des monstres 0,979 → 0,988 (étage 10 dans 54,5 % des montées)
- Tour, Archer : pente des monstres 1,195 → 1,297 (étage 20 dans 16,0 % des montées)
- Tour, Archer : facteur des monstres 0,616 → 0,617 (étage 10 dans 47,5 % des montées)
- Tour, Prêtre : pente des monstres 0,937 → 0,943 (étage 20 dans 10,0 % des montées)
- Tour, Prêtre : facteur des monstres 1,058 → 1,072 (étage 10 dans 58,0 % des montées)
- Tour, Invocateur : pente des monstres 1,146 → 1,132 (étage 20 dans 2,5 % des montées)
- Tour, Invocateur : facteur des monstres 0,942 → 0,937 (étage 10 dans 36,5 % des montées)
- Tour, Barde : facteur des monstres 0,776 → 0,770 (étage 10 dans 38,0 % des montées)
- Tour, Diplomate : pente des monstres 0,972 → 0,913 (étage 20 dans 1,5 % des montées)
- Tour, Diplomate : facteur des monstres 1,134 → 1,118 (étage 10 dans 31,0 % des montées)
- Tour, Pugiliste : pente des monstres 1,036 → 1,062 (étage 20 dans 10,0 % des montées)
- Tour, Pugiliste : facteur des monstres 0,942 → 0,945 (étage 10 dans 48,0 % des montées)

## Passe 28 (graines à partir de 2800085)

**1 critères tenus sur 6.** 50000 combats de duel (médiane 8 tours), 0 combats non finis.

### Les six critères (section 11.2)

- ❌ **1. Chaque classe entre 47 % et 53 % de victoires** : guerrier 36,6 %, voleur 54,3 %, archer 55,0 %, pretre 60,5 %, diplomate 38,8 %, pugiliste 61,8 %
- ❌ **2. Aucune case de la matrice hors de 40 % – 60 %** : guerrier contre mage 39,0 %, guerrier contre voleur 34,6 %, guerrier contre pretre 22,6 %, guerrier contre alchimiste 28,6 %, guerrier contre invocateur 37,2 %, guerrier contre barde 33,6 %, guerrier contre pugiliste 32,0 %, mage contre guerrier 63,4 %, mage contre pretre 39,8 %, mage contre diplomate 66,6 %, voleur contre guerrier 66,2 %, voleur contre alchimiste 62,8 %, voleur contre diplomate 62,6 %, archer contre alchimiste 62,6 %, archer contre invocateur 60,4 %, archer contre diplomate 69,0 %, pretre contre guerrier 77,2 %, pretre contre mage 61,8 %, pretre contre alchimiste 60,6 %, pretre contre invocateur 65,2 %, pretre contre diplomate 69,4 %, alchimiste contre guerrier 70,2 %, alchimiste contre voleur 36,8 %, alchimiste contre archer 34,8 %, alchimiste contre pugiliste 37,2 %, invocateur contre guerrier 61,2 %, invocateur contre archer 36,4 %, invocateur contre pretre 39,2 %, invocateur contre diplomate 60,2 %, invocateur contre pugiliste 36,6 %, barde contre guerrier 66,2 %, diplomate contre mage 36,6 %, diplomate contre archer 31,2 %, diplomate contre pretre 31,0 %, diplomate contre barde 35,8 %, diplomate contre pugiliste 26,0 %, pugiliste contre guerrier 69,6 %, pugiliste contre alchimiste 64,4 %, pugiliste contre invocateur 64,4 %, pugiliste contre barde 62,0 %, pugiliste contre diplomate 70,2 %
- ❌ **3. La route Réactive entre 40 % et 55 % (Ruée et Éventail : des repères, sans seuil)** : guerrier Réactive 36,6 %, pretre Réactive 60,5 %, diplomate Réactive 38,8 %, pugiliste Réactive 61,8 %
- ❌ **4. Chaque voie jouée dans 15 % des combats au moins, une Clé dans 60 %** : voleur : Clé jouée dans 57,4 % des combats, archer : Clé jouée dans 55,3 % des combats, alchimiste voie 3 10,3 %, invocateur voie 2 12,0 %, invocateur voie 5 13,4 %, invocateur : Clé jouée dans 46,7 % des combats, diplomate voie 1 8,7 %, pugiliste voie 5 9,8 %
- ✅ **5. Longueur : médiane de 6 à 10 tours, 95 % finis avant le tour 20**
- ❌ **6. Tour : étage 10 dans 40 à 60 % des montées, étage 20 dans 5 à 10 %, à 5 points près entre classes** : guerrier étage 20 3,5 %, mage étage 20 13,5 %, voleur étage 20 2,0 %, archer étage 20 15,0 %, pretre étage 10 66,5 %, pretre étage 20 11,0 %, alchimiste étage 20 4,5 %, invocateur étage 20 2,5 %, diplomate étage 10 31,5 %, diplomate étage 20 4,0 %, écart entre classes : étage 10 de 31,5 % à 66,5 %, étage 20 de 2,0 % à 15,0 %

### La matrice des classes (taux de victoire de la ligne contre la colonne)

| | Guer | Mage | Vole | Arch | Prêt | Alch | Invo | Bard | Dipl | Pugi | **Moyenne** |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 50 | 39 | 35 | 44 | 23 | 29 | 37 | 34 | 44 | 32 | **36,6 %** |
| Mage | 63 | 53 | 49 | 43 | 40 | 58 | 55 | 52 | 67 | 41 | **52,1 %** |
| Voleur | 66 | 56 | 50 | 46 | 46 | 63 | 55 | 60 | 63 | 40 | **54,3 %** |
| Archer | 59 | 55 | 54 | 48 | 45 | 63 | 60 | 54 | 69 | 42 | **55,0 %** |
| Prêtre | 77 | 62 | 56 | 57 | 52 | 61 | 65 | 60 | 69 | 47 | **60,5 %** |
| Alchimiste | 70 | 41 | 37 | 35 | 42 | 51 | 46 | 54 | 59 | 37 | **47,2 %** |
| Invocateur | 61 | 49 | 46 | 36 | 39 | 52 | 51 | 48 | 60 | 37 | **48,0 %** |
| Barde | 66 | 47 | 43 | 43 | 40 | 50 | 54 | 50 | 59 | 42 | **49,5 %** |
| Diplomate | 54 | 37 | 41 | 31 | 31 | 41 | 42 | 36 | 49 | 26 | **38,8 %** |
| Pugiliste | 70 | 60 | 59 | 59 | 57 | 64 | 64 | 62 | 70 | 52 | **61,8 %** |

### Les trois routes, l'usage des voies et la Tour, par classe

| Classe | Ruée | Éventail | Réactive | Voie 1 | Voie 2 | Voie 3 | Voie 4 | Voie 5 | Clé | Tour : étage 10 | étage 20 | étage moyen |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 32,5 % | 10,8 % | 36,6 % | 35,1 % | 63,3 % | 31,8 % | 67,0 % | 58,5 % | 90,4 % | 40,0 % | 3,5 % | 8,8 |
| Mage | 66,3 % | 25,0 % | 52,1 % | 35,9 % | 41,2 % | 37,7 % | 34,1 % | 20,9 % | 62,1 % | 56,0 % | 13,5 % | 11,4 |
| Voleur | 50,7 % | 32,8 % | 54,3 % | 32,3 % | 18,7 % | 48,3 % | 21,2 % | 35,9 % | 57,4 % | 51,5 % | 2,0 % | 9,9 |
| Archer | 51,2 % | 26,5 % | 55,0 % | 26,7 % | 60,9 % | 36,5 % | 21,2 % | 22,3 % | 55,3 % | 53,0 % | 15,0 % | 11,5 |
| Prêtre | 49,0 % | 26,3 % | 60,5 % | 27,0 % | 54,5 % | 35,8 % | 48,1 % | 70,1 % | 77,8 % | 66,5 % | 11,0 % | 12,3 |
| Alchimiste | 21,0 % | 11,3 % | 47,2 % | 42,4 % | 31,7 % | 10,3 % | 35,5 % | 71,8 % | 78,9 % | 50,0 % | 4,5 % | 10,0 |
| Invocateur | 47,8 % | 31,5 % | 48,0 % | 29,2 % | 12,0 % | 59,8 % | 32,3 % | 13,4 % | 46,7 % | 45,0 % | 2,5 % | 9,3 |
| Barde | 33,8 % | 20,5 % | 49,5 % | 36,5 % | 30,3 % | 33,6 % | 27,1 % | 58,2 % | 70,2 % | 48,0 % | 6,5 % | 10,0 |
| Diplomate | 11,3 % | 6,3 % | 38,8 % | 8,7 % | 40,9 % | 76,2 % | 32,5 % | 78,4 % | 77,9 % | 31,5 % | 4,0 % | 8,7 |
| Pugiliste | 13,5 % | 12,0 % | 61,8 % | 33,4 % | 36,9 % | 43,3 % | 80,9 % | 9,8 % | 87,1 % | 48,0 % | 9,0 % | 10,6 |

### Boutons touchés, et pourquoi

- k_classe Guerrier : 0,776 → 0,800 (36,6 % de victoires)
- k_classe Mage : 1,027 → 1,023 (52,1 % de victoires)
- k_classe Archer : 0,959 → 0,942 (55,0 % de victoires)
- k_classe Prêtre : 0,868 → 0,842 (60,5 % de victoires)
- k_classe Alchimiste : 1,071 → 1,081 (47,2 % de victoires)
- k_classe Invocateur : 0,852 → 0,857 (48,0 % de victoires)
- k_classe Pugiliste : 1,049 → 1,018 (61,8 % de victoires)
- budgets des Clés (Voleur) : +3 % (une Clé jouée dans 57,4 % des combats)
- budgets des Clés (Archer) : +3 % (une Clé jouée dans 55,3 % des combats)
- budgets de la Voie des Fumées (Alchimiste) : +3 % (jouée dans 10,3 % des combats)
- budgets des premiers nœuds des autres voies (Alchimiste) : -3 % (la Voie des Fumées, jouée dans 10,3 % des combats, commence par un état seul)
- budgets de la Voie du Gardien (Invocateur) : +3 % (jouée dans 12,0 % des combats)
- budgets de la Voie du Pacte (Invocateur) : +3 % (jouée dans 13,4 % des combats)
- budgets des Clés (Invocateur) : +3 % (une Clé jouée dans 46,7 % des combats)
- budgets de la Voie de l'Intimidation (Diplomate) : +3 % (jouée dans 8,7 % des combats)
- budgets de la Voie du Défi (Pugiliste) : +3 % (jouée dans 9,8 % des combats)
- PV du Voleur : ×0,97 → ×0,94 (k déjà à sa borne, 54,3 % de victoires)
- PV du Diplomate : ×1,03 → ×1,06 (k déjà à sa borne, 38,8 % de victoires)
- Tour, Guerrier : pente des monstres 0,816 → 0,808 (étage 20 dans 3,5 % des montées)
- Tour, Guerrier : facteur des monstres 1,716 → 1,701 (étage 10 dans 40,0 % des montées)
- Tour, Mage : pente des monstres 1,150 → 1,184 (étage 20 dans 13,5 % des montées)
- Tour, Mage : facteur des monstres 0,767 → 0,772 (étage 10 dans 56,0 % des montées)
- Tour, Voleur : pente des monstres 0,720 → 0,701 (étage 20 dans 2,0 % des montées)
- Tour, Voleur : facteur des monstres 0,988 → 0,990 (étage 10 dans 51,5 % des montées)
- Tour, Archer : pente des monstres 1,297 → 1,394 (étage 20 dans 15,0 % des montées)
- Tour, Archer : facteur des monstres 0,617 → 0,619 (étage 10 dans 53,0 % des montées)
- Tour, Prêtre : pente des monstres 0,943 → 0,951 (étage 20 dans 11,0 % des montées)
- Tour, Prêtre : facteur des monstres 1,072 → 1,090 (étage 10 dans 66,5 % des montées)
- Tour, Alchimiste : pente des monstres 1,129 → 1,112 (étage 20 dans 4,5 % des montées)
- Tour, Invocateur : pente des monstres 1,132 → 1,117 (étage 20 dans 2,5 % des montées)
- Tour, Invocateur : facteur des monstres 0,937 → 0,934 (étage 10 dans 45,0 % des montées)
- Tour, Diplomate : pente des monstres 0,913 → 0,881 (étage 20 dans 4,0 % des montées)
- Tour, Diplomate : facteur des monstres 1,118 → 1,098 (étage 10 dans 31,5 % des montées)

## Passe 29 (graines à partir de 2900088)

**1 critères tenus sur 6.** 50000 combats de duel (médiane 8 tours), 0 combats non finis.

### Les six critères (section 11.2)

- ❌ **1. Chaque classe entre 47 % et 53 % de victoires** : guerrier 45,7 %, mage 53,7 %, voleur 46,1 %, archer 57,7 %, pretre 56,1 %, alchimiste 46,4 %, invocateur 43,7 %, barde 46,4 %, diplomate 41,6 %, pugiliste 59,7 %
- ❌ **2. Aucune case de la matrice hors de 40 % – 60 %** : guerrier contre pretre 33,0 %, mage contre alchimiste 64,8 %, voleur contre archer 37,4 %, voleur contre pugiliste 33,4 %, archer contre voleur 61,8 %, archer contre alchimiste 68,6 %, archer contre invocateur 61,8 %, archer contre barde 64,4 %, archer contre diplomate 62,2 %, pretre contre guerrier 64,8 %, pretre contre invocateur 62,0 %, pretre contre diplomate 64,0 %, alchimiste contre guerrier 63,6 %, alchimiste contre mage 36,6 %, alchimiste contre archer 35,0 %, alchimiste contre pugiliste 35,6 %, invocateur contre archer 38,4 %, invocateur contre pretre 35,4 %, invocateur contre pugiliste 34,0 %, barde contre archer 35,8 %, barde contre pugiliste 37,0 %, diplomate contre mage 34,8 %, diplomate contre archer 29,8 %, diplomate contre pretre 37,6 %, diplomate contre pugiliste 32,4 %, pugiliste contre voleur 61,2 %, pugiliste contre alchimiste 68,6 %, pugiliste contre invocateur 61,0 %, pugiliste contre barde 64,4 %, pugiliste contre diplomate 66,0 %
- ❌ **3. La route Réactive entre 40 % et 55 % (Ruée et Éventail : des repères, sans seuil)** : archer Réactive 57,7 %, pretre Réactive 56,1 %, pugiliste Réactive 59,7 %
- ❌ **4. Chaque voie jouée dans 15 % des combats au moins, une Clé dans 60 %** : voleur : Clé jouée dans 55,2 % des combats, archer : Clé jouée dans 53,5 % des combats, alchimiste voie 3 10,4 %, invocateur voie 5 14,1 %, invocateur : Clé jouée dans 47,2 % des combats, diplomate voie 1 12,2 %, pugiliste voie 5 11,5 %
- ✅ **5. Longueur : médiane de 6 à 10 tours, 95 % finis avant le tour 20**
- ❌ **6. Tour : étage 10 dans 40 à 60 % des montées, étage 20 dans 5 à 10 %, à 5 points près entre classes** : guerrier étage 20 3,0 %, mage étage 20 12,5 %, voleur étage 10 38,5 %, voleur étage 20 2,5 %, archer étage 20 14,5 %, invocateur étage 10 38,5 %, invocateur étage 20 2,0 %, barde étage 10 38,0 %, écart entre classes : étage 10 de 38,0 % à 59,5 %, étage 20 de 2,0 % à 14,5 %

### La matrice des classes (taux de victoire de la ligne contre la colonne)

| | Guer | Mage | Vole | Arch | Prêt | Alch | Invo | Bard | Dipl | Pugi | **Moyenne** |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 54 | 49 | 48 | 50 | 33 | 42 | 45 | 41 | 55 | 40 | **45,7 %** |
| Mage | 53 | 50 | 58 | 47 | 47 | 65 | 57 | 59 | 57 | 45 | **53,7 %** |
| Voleur | 53 | 44 | 48 | 37 | 41 | 53 | 50 | 49 | 53 | 33 | **46,1 %** |
| Archer | 53 | 55 | 62 | 52 | 49 | 69 | 62 | 64 | 62 | 49 | **57,7 %** |
| Prêtre | 65 | 55 | 58 | 49 | 52 | 54 | 62 | 57 | 64 | 45 | **56,1 %** |
| Alchimiste | 64 | 37 | 41 | 35 | 46 | 50 | 50 | 52 | 54 | 36 | **46,4 %** |
| Invocateur | 51 | 41 | 49 | 38 | 35 | 47 | 48 | 44 | 49 | 34 | **43,7 %** |
| Barde | 56 | 41 | 49 | 36 | 41 | 47 | 52 | 52 | 53 | 37 | **46,4 %** |
| Diplomate | 47 | 35 | 47 | 30 | 38 | 46 | 48 | 44 | 51 | 32 | **41,6 %** |
| Pugiliste | 60 | 55 | 61 | 57 | 55 | 69 | 61 | 64 | 66 | 49 | **59,7 %** |

### Les trois routes, l'usage des voies et la Tour, par classe

| Classe | Ruée | Éventail | Réactive | Voie 1 | Voie 2 | Voie 3 | Voie 4 | Voie 5 | Clé | Tour : étage 10 | étage 20 | étage moyen |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 38,0 % | 10,8 % | 45,7 % | 36,6 % | 38,1 % | 36,1 % | 75,8 % | 57,6 % | 92,7 % | 44,5 % | 3,0 % | 9,3 |
| Mage | 66,5 % | 32,5 % | 53,7 % | 39,6 % | 39,3 % | 25,1 % | 45,9 % | 20,4 % | 60,4 % | 58,0 % | 12,5 % | 11,4 |
| Voleur | 50,2 % | 29,0 % | 46,1 % | 34,5 % | 19,0 % | 42,5 % | 20,9 % | 34,4 % | 55,2 % | 38,5 % | 2,5 % | 9,1 |
| Archer | 62,7 % | 28,7 % | 57,7 % | 15,0 % | 63,5 % | 35,3 % | 22,5 % | 29,3 % | 53,5 % | 52,0 % | 14,5 % | 11,3 |
| Prêtre | 52,3 % | 23,8 % | 56,1 % | 25,1 % | 60,3 % | 26,6 % | 47,2 % | 65,8 % | 78,0 % | 59,5 % | 9,5 % | 11,7 |
| Alchimiste | 25,3 % | 13,5 % | 46,4 % | 41,8 % | 30,8 % | 10,4 % | 28,5 % | 72,9 % | 78,4 % | 41,5 % | 7,0 % | 10,2 |
| Invocateur | 49,5 % | 26,0 % | 43,7 % | 33,7 % | 15,2 % | 50,5 % | 35,5 % | 14,1 % | 47,2 % | 38,5 % | 2,0 % | 9,0 |
| Barde | 38,5 % | 20,5 % | 46,4 % | 31,0 % | 30,3 % | 31,5 % | 25,1 % | 62,6 % | 69,3 % | 38,0 % | 6,5 % | 9,5 |
| Diplomate | 18,5 % | 9,0 % | 41,6 % | 12,2 % | 41,6 % | 78,1 % | 30,9 % | 76,6 % | 77,9 % | 47,0 % | 8,5 % | 10,4 |
| Pugiliste | 16,5 % | 13,3 % | 59,7 % | 25,0 % | 37,5 % | 41,2 % | 87,0 % | 11,5 % | 86,9 % | 52,5 % | 6,5 % | 10,7 |

### Boutons touchés, et pourquoi

- k_classe Guerrier : 0,800 → 0,811 (45,7 % de victoires)
- k_classe Mage : 1,023 → 1,017 (53,7 % de victoires)
- k_classe Voleur : 0,750 → 0,755 (46,1 % de victoires)
- k_classe Archer : 0,942 → 0,917 (57,7 % de victoires)
- k_classe Prêtre : 0,842 → 0,824 (56,1 % de victoires)
- k_classe Alchimiste : 1,081 → 1,095 (46,4 % de victoires)
- k_classe Invocateur : 0,857 → 0,876 (43,7 % de victoires)
- k_classe Barde : 1,056 → 1,069 (46,4 % de victoires)
- k_classe Pugiliste : 1,018 → 0,987 (59,7 % de victoires)
- budgets des Clés (Mage) : +3 % (une Clé jouée dans 60,4 % des combats)
- budgets des Clés (Voleur) : +3 % (une Clé jouée dans 55,2 % des combats)
- budgets de la Voie de la Précision (Archer) : +3 % (jouée dans 15,0 % des combats)
- budgets des Clés (Archer) : +3 % (une Clé jouée dans 53,5 % des combats)
- budgets de la Voie des Fumées (Alchimiste) : +3 % (jouée dans 10,4 % des combats)
- budgets des premiers nœuds des autres voies (Alchimiste) : -3 % (la Voie des Fumées, jouée dans 10,4 % des combats, commence par un état seul)
- budgets de la Voie du Gardien (Invocateur) : +3 % (jouée dans 15,2 % des combats)
- budgets de la Voie du Pacte (Invocateur) : +3 % (jouée dans 14,1 % des combats)
- budgets des Clés (Invocateur) : +3 % (une Clé jouée dans 47,2 % des combats)
- budgets de la Voie de l'Intimidation (Diplomate) : +3 % (jouée dans 12,2 % des combats)
- budgets de la Voie du Défi (Pugiliste) : +3 % (jouée dans 11,5 % des combats)
- PV du Diplomate : ×1,06 → ×1,09 (k déjà à sa borne, 41,6 % de victoires)
- Tour, Guerrier : pente des monstres 0,808 → 0,799 (étage 20 dans 3,0 % des montées)
- Tour, Guerrier : facteur des monstres 1,701 → 1,696 (étage 10 dans 44,5 % des montées)
- Tour, Mage : pente des monstres 1,184 → 1,214 (étage 20 dans 12,5 % des montées)
- Tour, Mage : facteur des monstres 0,772 → 0,781 (étage 10 dans 58,0 % des montées)
- Tour, Voleur : pente des monstres 0,701 → 0,683 (étage 20 dans 2,5 % des montées)
- Tour, Voleur : facteur des monstres 0,990 → 0,986 (étage 10 dans 38,5 % des montées)
- Tour, Archer : pente des monstres 1,394 → 1,492 (étage 20 dans 14,5 % des montées)
- Tour, Archer : facteur des monstres 0,619 → 0,622 (étage 10 dans 52,0 % des montées)
- Tour, Prêtre : pente des monstres 0,951 → 0,956 (étage 20 dans 9,5 % des montées)
- Tour, Prêtre : facteur des monstres 1,090 → 1,104 (étage 10 dans 59,5 % des montées)
- Tour, Alchimiste : facteur des monstres 1,004 → 0,998 (étage 10 dans 41,5 % des montées)
- Tour, Invocateur : pente des monstres 1,117 → 1,102 (étage 20 dans 2,0 % des montées)
- Tour, Invocateur : facteur des monstres 0,934 → 0,926 (étage 10 dans 38,5 % des montées)
- Tour, Barde : facteur des monstres 0,770 → 0,763 (étage 10 dans 38,0 % des montées)
- Tour, Pugiliste : facteur des monstres 0,945 → 0,950 (étage 10 dans 52,5 % des montées)

## Passe 30 (graines à partir de 3000091)

**1 critères tenus sur 6.** 50000 combats de duel (médiane 8 tours), 0 combats non finis.

### Les six critères (section 11.2)

- ❌ **1. Chaque classe entre 47 % et 53 % de victoires** : guerrier 43,8 %, mage 54,9 %, voleur 47,0 %, archer 53,9 %, pretre 56,6 %, invocateur 45,9 %, diplomate 46,0 %, pugiliste 58,1 %
- ❌ **2. Aucune case de la matrice hors de 40 % – 60 %** : guerrier contre pretre 36,0 %, guerrier contre alchimiste 38,4 %, mage contre alchimiste 62,8 %, mage contre diplomate 63,6 %, voleur contre archer 39,6 %, voleur contre pugiliste 35,4 %, archer contre diplomate 70,8 %, archer contre pugiliste 39,6 %, pretre contre guerrier 64,6 %, pretre contre voleur 61,0 %, pretre contre invocateur 61,8 %, pretre contre diplomate 67,0 %, alchimiste contre mage 39,2 %, alchimiste contre diplomate 62,4 %, alchimiste contre pugiliste 37,4 %, invocateur contre archer 39,0 %, invocateur contre pretre 39,2 %, invocateur contre pugiliste 35,8 %, diplomate contre pretre 37,4 %, diplomate contre pugiliste 34,0 %, pugiliste contre voleur 61,4 %, pugiliste contre alchimiste 63,4 %, pugiliste contre invocateur 62,8 %, pugiliste contre barde 60,2 %, pugiliste contre diplomate 66,6 %
- ❌ **3. La route Réactive entre 40 % et 55 % (Ruée et Éventail : des repères, sans seuil)** : pretre Réactive 56,6 %, pugiliste Réactive 58,1 %
- ❌ **4. Chaque voie jouée dans 15 % des combats au moins, une Clé dans 60 %** : voleur : Clé jouée dans 55,5 % des combats, archer : Clé jouée dans 52,3 % des combats, alchimiste voie 3 11,1 %, invocateur : Clé jouée dans 47,4 % des combats, diplomate voie 1 11,7 %, pugiliste voie 5 12,7 %
- ✅ **5. Longueur : médiane de 6 à 10 tours, 95 % finis avant le tour 20**
- ❌ **6. Tour : étage 10 dans 40 à 60 % des montées, étage 20 dans 5 à 10 %, à 5 points près entre classes** : guerrier étage 20 1,5 %, mage étage 20 13,0 %, voleur étage 10 33,5 %, voleur étage 20 0,5 %, alchimiste étage 10 39,5 %, invocateur étage 10 36,5 %, barde étage 20 10,5 %, écart entre classes : étage 10 de 33,5 % à 57,5 %, étage 20 de 0,5 % à 13,0 %

### La matrice des classes (taux de victoire de la ligne contre la colonne)

| | Guer | Mage | Vole | Arch | Prêt | Alch | Invo | Bard | Dipl | Pugi | **Moyenne** |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 51 | 47 | 45 | 46 | 36 | 38 | 40 | 41 | 50 | 44 | **43,8 %** |
| Mage | 51 | 51 | 59 | 49 | 47 | 63 | 59 | 59 | 64 | 46 | **54,9 %** |
| Voleur | 49 | 40 | 50 | 40 | 45 | 56 | 53 | 50 | 51 | 35 | **47,0 %** |
| Archer | 48 | 51 | 58 | 47 | 48 | 59 | 60 | 58 | 71 | 40 | **53,9 %** |
| Prêtre | 65 | 52 | 61 | 53 | 51 | 54 | 62 | 57 | 67 | 45 | **56,6 %** |
| Alchimiste | 59 | 39 | 44 | 42 | 51 | 51 | 53 | 57 | 62 | 37 | **49,6 %** |
| Invocateur | 53 | 40 | 51 | 39 | 39 | 52 | 54 | 46 | 49 | 36 | **45,9 %** |
| Barde | 56 | 44 | 49 | 45 | 45 | 46 | 55 | 52 | 59 | 40 | **49,2 %** |
| Diplomate | 54 | 43 | 54 | 40 | 37 | 42 | 59 | 45 | 53 | 34 | **46,0 %** |
| Pugiliste | 52 | 51 | 61 | 56 | 57 | 63 | 63 | 60 | 67 | 51 | **58,1 %** |

### Les trois routes, l'usage des voies et la Tour, par classe

| Classe | Ruée | Éventail | Réactive | Voie 1 | Voie 2 | Voie 3 | Voie 4 | Voie 5 | Clé | Tour : étage 10 | étage 20 | étage moyen |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 35,8 % | 12,8 % | 43,8 % | 34,9 % | 42,2 % | 26,0 % | 81,0 % | 55,0 % | 89,5 % | 45,0 % | 1,5 % | 9,1 |
| Mage | 66,3 % | 28,5 % | 54,9 % | 34,5 % | 41,0 % | 29,6 % | 47,0 % | 17,5 % | 60,2 % | 47,5 % | 13,0 % | 10,9 |
| Voleur | 47,3 % | 27,3 % | 47,0 % | 34,0 % | 22,2 % | 41,2 % | 25,2 % | 31,6 % | 55,5 % | 33,5 % | 0,5 % | 8,6 |
| Archer | 54,8 % | 27,5 % | 53,9 % | 38,4 % | 42,4 % | 40,7 % | 18,7 % | 19,7 % | 52,3 % | 57,5 % | 9,0 % | 11,2 |
| Prêtre | 46,8 % | 20,8 % | 56,6 % | 23,6 % | 53,8 % | 38,7 % | 50,5 % | 70,5 % | 76,5 % | 45,5 % | 6,0 % | 10,4 |
| Alchimiste | 17,0 % | 10,3 % | 49,6 % | 40,9 % | 31,7 % | 11,1 % | 28,8 % | 70,4 % | 78,8 % | 39,5 % | 6,0 % | 9,7 |
| Invocateur | 43,0 % | 31,5 % | 45,9 % | 34,9 % | 16,1 % | 50,9 % | 33,9 % | 15,1 % | 47,4 % | 36,5 % | 5,0 % | 9,0 |
| Barde | 41,0 % | 24,3 % | 49,2 % | 36,5 % | 30,5 % | 31,4 % | 27,4 % | 57,2 % | 69,7 % | 47,5 % | 10,5 % | 10,2 |
| Diplomate | 18,3 % | 6,3 % | 46,0 % | 11,7 % | 44,4 % | 76,7 % | 32,2 % | 77,2 % | 80,0 % | 55,5 % | 10,0 % | 11,5 |
| Pugiliste | 15,5 % | 11,3 % | 58,1 % | 28,7 % | 35,1 % | 41,2 % | 84,8 % | 12,7 % | 86,6 % | 49,5 % | 5,0 % | 10,3 |

### Boutons touchés, et pourquoi

- k_classe Guerrier : 0,811 → 0,829 (43,8 % de victoires)
- k_classe Mage : 1,017 → 1,008 (54,9 % de victoires)
- k_classe Voleur : 0,755 → 0,759 (47,0 % de victoires)
- k_classe Archer : 0,917 → 0,904 (53,9 % de victoires)
- k_classe Prêtre : 0,824 → 0,805 (56,6 % de victoires)
- k_classe Invocateur : 0,876 → 0,889 (45,9 % de victoires)
- k_classe Pugiliste : 0,987 → 0,959 (58,1 % de victoires)
- budgets des Clés (Mage) : +3 % (une Clé jouée dans 60,2 % des combats)
- budgets des Clés (Voleur) : +3 % (une Clé jouée dans 55,5 % des combats)
- budgets des Clés (Archer) : +3 % (une Clé jouée dans 52,3 % des combats)
- budgets de la Voie des Fumées (Alchimiste) : +3 % (jouée dans 11,1 % des combats)
- budgets des premiers nœuds des autres voies (Alchimiste) : -3 % (la Voie des Fumées, jouée dans 11,1 % des combats, commence par un état seul)
- budgets de la Voie du Gardien (Invocateur) : +3 % (jouée dans 16,1 % des combats)
- budgets de la Voie du Pacte (Invocateur) : +3 % (jouée dans 15,1 % des combats)
- budgets des Clés (Invocateur) : +3 % (une Clé jouée dans 47,4 % des combats)
- budgets de la Voie de l'Intimidation (Diplomate) : +3 % (jouée dans 11,7 % des combats)
- budgets de la Voie du Défi (Pugiliste) : +3 % (jouée dans 12,7 % des combats)
- PV du Diplomate : ×1,09 → ×1,10 (k déjà à sa borne, 46,0 % de victoires)
- Tour : force des monstres au départ 0,390 → 0,388, en plus par étage 0,028 → 0,028 (étage 10 atteint dans 45,8 % des montées, étage 20 dans 6,7 %)
- Tour, Guerrier : pente des monstres 0,799 → 0,787 (étage 20 dans 1,5 % des montées)
- Tour, Mage : pente des monstres 1,214 → 1,247 (étage 20 dans 13,0 % des montées)
- Tour, Voleur : pente des monstres 0,683 → 0,659 (étage 20 dans 0,5 % des montées)
- Tour, Voleur : facteur des monstres 0,986 → 0,974 (étage 10 dans 33,5 % des montées)
- Tour, Archer : facteur des monstres 0,622 → 0,630 (étage 10 dans 57,5 % des montées)
- Tour, Alchimiste : facteur des monstres 0,998 → 0,992 (étage 10 dans 39,5 % des montées)
- Tour, Invocateur : pente des monstres 1,102 → 1,095 (étage 20 dans 5,0 % des montées)
- Tour, Invocateur : facteur des monstres 0,926 → 0,917 (étage 10 dans 36,5 % des montées)
- Tour, Barde : pente des monstres 1,306 → 1,326 (étage 20 dans 10,5 % des montées)
- Tour, Diplomate : pente des monstres 0,881 → 0,892 (étage 20 dans 10,0 % des montées)
- Tour, Diplomate : facteur des monstres 1,098 → 1,103 (étage 10 dans 55,5 % des montées)
- Tour, Pugiliste : pente des monstres 1,062 → 1,049 (étage 20 dans 5,0 % des montées)
- Tour, Pugiliste : facteur des monstres 0,950 → 0,953 (étage 10 dans 49,5 % des montées)

## Passe 31 (graines à partir de 3100094)

**1 critères tenus sur 6.** 50000 combats de duel (médiane 8 tours), 0 combats non finis.

### Les six critères (section 11.2)

- ❌ **1. Chaque classe entre 47 % et 53 % de victoires** : mage 59,4 %, voleur 42,6 %, archer 54,2 %, pretre 56,9 %, invocateur 43,1 %, diplomate 44,7 %, pugiliste 53,2 %
- ❌ **2. Aucune case de la matrice hors de 40 % – 60 %** : guerrier contre pretre 39,4 %, mage contre voleur 65,0 %, mage contre invocateur 64,4 %, mage contre diplomate 64,2 %, voleur contre mage 34,6 %, voleur contre archer 37,8 %, voleur contre pretre 37,4 %, voleur contre pugiliste 31,8 %, archer contre voleur 61,8 %, archer contre invocateur 61,2 %, archer contre diplomate 61,2 %, pretre contre guerrier 61,8 %, pretre contre voleur 62,0 %, pretre contre invocateur 63,4 %, pretre contre diplomate 63,2 %, alchimiste contre mage 39,0 %, alchimiste contre archer 37,8 %, invocateur contre mage 34,0 %, invocateur contre archer 37,4 %, invocateur contre pretre 39,4 %, invocateur contre pugiliste 37,4 %, barde contre mage 38,8 %, diplomate contre mage 34,0 %, diplomate contre archer 38,0 %, diplomate contre pretre 37,4 %, diplomate contre pugiliste 37,0 %, pugiliste contre voleur 61,8 %, pugiliste contre diplomate 61,6 %
- ❌ **3. La route Réactive entre 40 % et 55 % (Ruée et Éventail : des repères, sans seuil)** : mage Réactive 59,4 %, pretre Réactive 56,9 %
- ❌ **4. Chaque voie jouée dans 15 % des combats au moins, une Clé dans 60 %** : voleur : Clé jouée dans 54,9 % des combats, archer : Clé jouée dans 55,4 % des combats, alchimiste voie 3 11,6 %, invocateur voie 5 14,0 %, invocateur : Clé jouée dans 47,7 % des combats, diplomate voie 1 12,8 %, pugiliste voie 5 12,7 %
- ✅ **5. Longueur : médiane de 6 à 10 tours, 95 % finis avant le tour 20**
- ❌ **6. Tour : étage 10 dans 40 à 60 % des montées, étage 20 dans 5 à 10 %, à 5 points près entre classes** : guerrier étage 10 38,5 %, guerrier étage 20 2,0 %, voleur étage 10 37,5 %, voleur étage 20 0,5 %, archer étage 20 4,5 %, pretre étage 20 4,5 %, invocateur étage 20 4,0 %, écart entre classes : étage 10 de 37,5 % à 56,5 %, étage 20 de 0,5 % à 8,5 %

### La matrice des classes (taux de victoire de la ligne contre la colonne)

| | Guer | Mage | Vole | Arch | Prêt | Alch | Invo | Bard | Dipl | Pugi | **Moyenne** |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 52 | 44 | 54 | 52 | 39 | 42 | 51 | 43 | 51 | 56 | **48,5 %** |
| Mage | 57 | 53 | 65 | 59 | 55 | 60 | 64 | 60 | 64 | 56 | **59,4 %** |
| Voleur | 43 | 35 | 50 | 38 | 37 | 52 | 50 | 47 | 42 | 32 | **42,6 %** |
| Archer | 52 | 45 | 62 | 51 | 48 | 58 | 61 | 53 | 61 | 50 | **54,2 %** |
| Prêtre | 62 | 48 | 62 | 54 | 53 | 55 | 63 | 57 | 63 | 52 | **56,9 %** |
| Alchimiste | 57 | 39 | 43 | 38 | 53 | 52 | 59 | 54 | 52 | 43 | **49,0 %** |
| Invocateur | 48 | 34 | 50 | 37 | 39 | 47 | 50 | 45 | 43 | 37 | **43,1 %** |
| Barde | 53 | 39 | 54 | 47 | 45 | 47 | 53 | 51 | 53 | 44 | **48,6 %** |
| Diplomate | 49 | 34 | 54 | 38 | 37 | 44 | 57 | 46 | 50 | 37 | **44,7 %** |
| Pugiliste | 44 | 43 | 62 | 53 | 49 | 56 | 59 | 56 | 62 | 48 | **53,2 %** |

### Les trois routes, l'usage des voies et la Tour, par classe

| Classe | Ruée | Éventail | Réactive | Voie 1 | Voie 2 | Voie 3 | Voie 4 | Voie 5 | Clé | Tour : étage 10 | étage 20 | étage moyen |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 33,5 % | 11,5 % | 48,5 % | 30,1 % | 39,3 % | 39,0 % | 75,1 % | 58,1 % | 90,1 % | 38,5 % | 2,0 % | 8,4 |
| Mage | 67,5 % | 30,8 % | 59,4 % | 38,2 % | 42,4 % | 38,9 % | 27,5 % | 19,4 % | 61,3 % | 55,5 % | 7,5 % | 10,8 |
| Voleur | 34,0 % | 21,8 % | 42,6 % | 30,8 % | 22,2 % | 42,7 % | 19,7 % | 35,1 % | 54,9 % | 37,5 % | 0,5 % | 8,6 |
| Archer | 52,0 % | 24,0 % | 54,2 % | 42,6 % | 39,4 % | 43,6 % | 18,2 % | 16,5 % | 55,4 % | 48,5 % | 4,5 % | 10,1 |
| Prêtre | 49,0 % | 21,0 % | 56,9 % | 23,4 % | 49,9 % | 34,7 % | 49,7 % | 72,3 % | 75,1 % | 46,0 % | 4,5 % | 10,0 |
| Alchimiste | 26,3 % | 9,8 % | 49,0 % | 39,8 % | 33,7 % | 11,6 % | 27,7 % | 70,7 % | 78,0 % | 45,0 % | 6,5 % | 10,1 |
| Invocateur | 36,8 % | 22,5 % | 43,1 % | 32,9 % | 15,4 % | 51,3 % | 34,4 % | 14,0 % | 47,7 % | 45,0 % | 4,0 % | 9,7 |
| Barde | 39,0 % | 24,3 % | 48,6 % | 33,4 % | 30,5 % | 31,4 % | 25,3 % | 59,6 % | 67,9 % | 44,5 % | 6,5 % | 9,7 |
| Diplomate | 18,5 % | 6,5 % | 44,7 % | 12,8 % | 40,8 % | 77,5 % | 30,9 % | 78,5 % | 79,2 % | 56,5 % | 8,5 % | 11,6 |
| Pugiliste | 15,3 % | 10,0 % | 53,2 % | 30,2 % | 36,8 % | 44,5 % | 81,1 % | 12,7 % | 86,8 % | 40,5 % | 5,5 % | 9,4 |

### Boutons touchés, et pourquoi

- PV de toutes les classes : ×0,338 → ×0,352 des PV de la spécification (médiane 8 tours, 99,8 % finis avant le tour 20 ; on vise 10 tours)
- k_classe Guerrier : 0,829 → 0,834 (48,5 % de victoires)
- k_classe Mage : 1,008 → 0,992 (59,4 % de victoires)
- k_classe Voleur : 0,759 → 0,769 (42,6 % de victoires)
- k_classe Archer : 0,904 → 0,891 (54,2 % de victoires)
- k_classe Prêtre : 0,805 → 0,786 (56,9 % de victoires)
- k_classe Alchimiste : 1,095 → 1,099 (49,0 % de victoires)
- k_classe Invocateur : 0,889 → 0,910 (43,1 % de victoires)
- k_classe Barde : 1,069 → 1,075 (48,6 % de victoires)
- k_classe Pugiliste : 0,959 → 0,948 (53,2 % de victoires)
- budgets des Clés (Mage) : +3 % (une Clé jouée dans 61,3 % des combats)
- budgets de la Voie du Retrait (Archer) : +3 % (jouée dans 16,5 % des combats)
- budgets des premiers nœuds des autres voies (Invocateur) : -3 % (la Voie du Gardien, jouée dans 15,4 % des combats, commence par un état seul)
- budgets des premiers nœuds des autres voies (Invocateur) : -3 % (la Voie du Pacte, jouée dans 14,0 % des combats, commence par un état seul)
- budgets des premiers nœuds des autres voies (Diplomate) : -3 % (la Voie de l'Intimidation, jouée dans 12,8 % des combats, commence par un état seul)
- budgets des premiers nœuds des autres voies (Pugiliste) : -3 % (la Voie du Défi, jouée dans 12,7 % des combats, commence par un état seul)
- Tour : force des monstres au départ 0,388 → 0,385, en plus par étage 0,028 → 0,027 (étage 10 atteint dans 45,8 % des montées, étage 20 dans 5,0 %)
- Tour, Guerrier : pente des monstres 0,787 → 0,776 (étage 20 dans 2,0 % des montées)
- Tour, Guerrier : facteur des monstres 1,696 → 1,684 (étage 10 dans 38,5 % des montées)
- Tour, Mage : facteur des monstres 0,781 → 0,789 (étage 10 dans 55,5 % des montées)
- Tour, Voleur : pente des monstres 0,659 → 0,636 (étage 20 dans 0,5 % des montées)
- Tour, Voleur : facteur des monstres 0,974 → 0,966 (étage 10 dans 37,5 % des montées)
- Tour, Archer : pente des monstres 1,492 → 1,469 (étage 20 dans 4,5 % des montées)
- Tour, Archer : facteur des monstres 0,630 → 0,631 (étage 10 dans 48,5 % des montées)
- Tour, Prêtre : pente des monstres 0,956 → 0,952 (étage 20 dans 4,5 % des montées)
- Tour, Invocateur : pente des monstres 1,095 → 1,086 (étage 20 dans 4,0 % des montées)
- Tour, Diplomate : facteur des monstres 1,103 → 1,115 (étage 10 dans 56,5 % des montées)
- Tour, Pugiliste : facteur des monstres 0,953 → 0,951 (étage 10 dans 40,5 % des montées)

## Passe 32 (graines à partir de 3200097)

**1 critères tenus sur 6.** 50000 combats de duel (médiane 9 tours), 0 combats non finis.

### Les six critères (section 11.2)

- ❌ **1. Chaque classe entre 47 % et 53 % de victoires** : guerrier 43,7 %, mage 59,9 %, voleur 46,7 %, archer 53,7 %, pretre 55,2 %, alchimiste 54,6 %, invocateur 45,1 %
- ❌ **2. Aucune case de la matrice hors de 40 % – 60 %** : guerrier contre mage 39,6 %, guerrier contre pretre 31,0 %, guerrier contre alchimiste 28,2 %, guerrier contre barde 37,6 %, mage contre guerrier 60,2 %, mage contre voleur 68,8 %, mage contre invocateur 64,6 %, mage contre pugiliste 60,6 %, pretre contre guerrier 64,0 %, pretre contre invocateur 61,4 %, pretre contre diplomate 60,4 %, alchimiste contre guerrier 69,8 %, invocateur contre mage 39,0 %, invocateur contre archer 38,6 %, barde contre guerrier 61,4 %
- ❌ **3. La route Réactive entre 40 % et 55 % (Ruée et Éventail : des repères, sans seuil)** : mage Réactive 59,9 %, pretre Réactive 55,2 %
- ❌ **4. Chaque voie jouée dans 15 % des combats au moins, une Clé dans 60 %** : alchimiste voie 3 10,9 %, invocateur : Clé jouée dans 55,5 % des combats
- ✅ **5. Longueur : médiane de 6 à 10 tours, 95 % finis avant le tour 20**
- ❌ **6. Tour : étage 10 dans 40 à 60 % des montées, étage 20 dans 5 à 10 %, à 5 points près entre classes** : guerrier étage 10 36,5 %, guerrier étage 20 3,0 %, voleur étage 20 2,0 %, pretre étage 20 2,0 %, diplomate étage 10 70,0 %, diplomate étage 20 13,5 %, pugiliste étage 10 35,0 %, pugiliste étage 20 1,0 %, écart entre classes : étage 10 de 35,0 % à 70,0 %, étage 20 de 1,0 % à 13,5 %

### La matrice des classes (taux de victoire de la ligne contre la colonne)

| | Guer | Mage | Vole | Arch | Prêt | Alch | Invo | Bard | Dipl | Pugi | **Moyenne** |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 53 | 40 | 51 | 53 | 31 | 28 | 45 | 38 | 44 | 55 | **43,7 %** |
| Mage | 60 | 55 | 69 | 58 | 53 | 59 | 65 | 60 | 60 | 61 | **59,9 %** |
| Voleur | 54 | 41 | 50 | 42 | 46 | 48 | 51 | 46 | 43 | 47 | **46,7 %** |
| Archer | 52 | 48 | 60 | 51 | 49 | 52 | 58 | 55 | 57 | 54 | **53,7 %** |
| Prêtre | 64 | 51 | 56 | 56 | 51 | 46 | 61 | 52 | 60 | 55 | **55,2 %** |
| Alchimiste | 70 | 46 | 52 | 52 | 53 | 51 | 56 | 55 | 59 | 51 | **54,6 %** |
| Invocateur | 54 | 39 | 51 | 39 | 41 | 42 | 53 | 45 | 41 | 46 | **45,1 %** |
| Barde | 61 | 46 | 48 | 49 | 49 | 41 | 56 | 50 | 58 | 49 | **50,8 %** |
| Diplomate | 58 | 43 | 58 | 43 | 40 | 41 | 57 | 47 | 53 | 46 | **48,5 %** |
| Pugiliste | 46 | 42 | 56 | 46 | 48 | 45 | 55 | 46 | 57 | 48 | **48,8 %** |

### Les trois routes, l'usage des voies et la Tour, par classe

| Classe | Ruée | Éventail | Réactive | Voie 1 | Voie 2 | Voie 3 | Voie 4 | Voie 5 | Clé | Tour : étage 10 | étage 20 | étage moyen |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 36,3 % | 8,3 % | 43,7 % | 34,4 % | 56,2 % | 34,1 % | 76,2 % | 56,6 % | 91,6 % | 36,5 % | 3,0 % | 8,4 |
| Mage | 68,0 % | 29,5 % | 59,9 % | 34,1 % | 44,6 % | 28,4 % | 48,9 % | 23,4 % | 67,4 % | 50,0 % | 7,0 % | 10,4 |
| Voleur | 36,0 % | 17,5 % | 46,7 % | 33,1 % | 24,4 % | 45,0 % | 24,4 % | 32,9 % | 61,6 % | 41,5 % | 2,0 % | 9,1 |
| Archer | 56,5 % | 28,2 % | 53,7 % | 36,6 % | 33,6 % | 53,6 % | 17,7 % | 30,3 % | 61,9 % | 50,5 % | 8,0 % | 10,6 |
| Prêtre | 45,8 % | 18,5 % | 55,2 % | 23,1 % | 62,8 % | 22,0 % | 50,6 % | 66,5 % | 77,7 % | 41,5 % | 2,0 % | 9,5 |
| Alchimiste | 24,8 % | 11,5 % | 54,6 % | 43,0 % | 35,1 % | 10,9 % | 29,9 % | 72,0 % | 80,6 % | 48,0 % | 5,0 % | 10,4 |
| Invocateur | 44,5 % | 17,3 % | 45,1 % | 32,5 % | 20,8 % | 55,6 % | 34,7 % | 18,0 % | 55,5 % | 48,0 % | 5,5 % | 10,3 |
| Barde | 36,5 % | 16,5 % | 50,8 % | 34,6 % | 30,4 % | 35,5 % | 29,5 % | 58,4 % | 72,8 % | 43,5 % | 8,0 % | 9,8 |
| Diplomate | 27,5 % | 9,0 % | 48,5 % | 19,0 % | 57,5 % | 80,7 % | 33,7 % | 72,3 % | 82,6 % | 70,0 % | 13,5 % | 12,9 |
| Pugiliste | 15,3 % | 7,5 % | 48,8 % | 37,8 % | 32,0 % | 53,8 % | 75,2 % | 17,3 % | 86,8 % | 35,0 % | 1,0 % | 9,0 |

### Boutons touchés, et pourquoi

- PV de toutes les classes : ×0,351 → ×0,366 des PV de la spécification (médiane 9 tours, 99,7 % finis avant le tour 20 ; on vise 10 tours)
- k_classe Guerrier : 0,834 → 0,852 (43,7 % de victoires)
- k_classe Mage : 0,992 → 0,962 (59,9 % de victoires)
- k_classe Voleur : 0,769 → 0,778 (46,7 % de victoires)
- k_classe Archer : 0,891 → 0,879 (53,7 % de victoires)
- k_classe Prêtre : 0,786 → 0,772 (55,2 % de victoires)
- k_classe Alchimiste : 1,099 → 1,090 (54,6 % de victoires)
- k_classe Invocateur : 0,910 → 0,926 (45,1 % de victoires)
- k_classe Barde : 1,075 → 1,073 (50,8 % de victoires)
- k_classe Pugiliste : 0,948 → 0,950 (48,8 % de victoires)
- Tour : force des monstres au départ 0,385 → 0,383, en plus par étage 0,027 → 0,027 (étage 10 atteint dans 46,4 % des montées, étage 20 dans 5,5 %)
- Tour, Guerrier : pente des monstres 0,776 → 0,767 (étage 20 dans 3,0 % des montées)
- Tour, Guerrier : facteur des monstres 1,684 → 1,667 (étage 10 dans 36,5 % des montées)
- Tour, Mage : facteur des monstres 0,789 → 0,791 (étage 10 dans 50,0 % des montées)
- Tour, Voleur : pente des monstres 0,636 → 0,619 (étage 20 dans 2,0 % des montées)
- Tour, Voleur : facteur des monstres 0,966 → 0,961 (étage 10 dans 41,5 % des montées)
- Tour, Archer : facteur des monstres 0,631 → 0,634 (étage 10 dans 50,5 % des montées)
- Tour, Prêtre : pente des monstres 0,952 → 0,939 (étage 20 dans 2,0 % des montées)
- Tour, Prêtre : facteur des monstres 1,104 → 1,101 (étage 10 dans 41,5 % des montées)
- Tour, Alchimiste : pente des monstres 1,112 → 1,098 (étage 20 dans 5,0 % des montées)
- Tour, Barde : facteur des monstres 0,763 → 0,761 (étage 10 dans 43,5 % des montées)
- Tour, Diplomate : pente des monstres 0,892 → 0,919 (étage 20 dans 13,5 % des montées)
- Tour, Diplomate : facteur des monstres 1,115 → 1,142 (étage 10 dans 70,0 % des montées)
- Tour, Pugiliste : pente des monstres 1,049 → 1,015 (étage 20 dans 1,0 % des montées)
- Tour, Pugiliste : facteur des monstres 0,951 → 0,940 (étage 10 dans 35,0 % des montées)

## Passe 33 (graines à partir de 3300100)

**1 critères tenus sur 6.** 50000 combats de duel (médiane 9 tours), 0 combats non finis.

### Les six critères (section 11.2)

- ❌ **1. Chaque classe entre 47 % et 53 % de victoires** : guerrier 45,3 %, mage 55,8 %, voleur 46,3 %, archer 53,9 %, alchimiste 55,1 %
- ❌ **2. Aucune case de la matrice hors de 40 % – 60 %** : guerrier contre alchimiste 36,4 %, guerrier contre barde 39,8 %, guerrier contre diplomate 39,6 %, mage contre guerrier 60,2 %, voleur contre mage 39,8 %, voleur contre archer 39,2 %, archer contre invocateur 61,4 %, pretre contre guerrier 62,2 %, alchimiste contre guerrier 68,4 %, alchimiste contre pretre 60,4 %, alchimiste contre barde 61,2 %, invocateur contre archer 36,6 %, barde contre guerrier 63,2 %, diplomate contre voleur 61,2 %
- ❌ **3. La route Réactive entre 40 % et 55 % (Ruée et Éventail : des repères, sans seuil)** : mage Réactive 55,8 %, alchimiste Réactive 55,1 %
- ❌ **4. Chaque voie jouée dans 15 % des combats au moins, une Clé dans 60 %** : alchimiste voie 3 11,7 %, invocateur : Clé jouée dans 59,2 % des combats
- ✅ **5. Longueur : médiane de 6 à 10 tours, 95 % finis avant le tour 20**
- ❌ **6. Tour : étage 10 dans 40 à 60 % des montées, étage 20 dans 5 à 10 %, à 5 points près entre classes** : guerrier étage 20 3,5 %, voleur étage 20 4,5 %, pretre étage 20 1,5 %, alchimiste étage 20 3,5 %, diplomate étage 10 73,0 %, diplomate étage 20 18,5 %, écart entre classes : étage 10 de 41,5 % à 73,0 %, étage 20 de 1,5 % à 18,5 %

### La matrice des classes (taux de victoire de la ligne contre la colonne)

| | Guer | Mage | Vole | Arch | Prêt | Alch | Invo | Bard | Dipl | Pugi | **Moyenne** |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 49 | 43 | 53 | 50 | 42 | 36 | 45 | 40 | 40 | 55 | **45,3 %** |
| Mage | 60 | 55 | 60 | 51 | 54 | 53 | 59 | 55 | 54 | 58 | **55,8 %** |
| Voleur | 51 | 40 | 50 | 39 | 46 | 50 | 50 | 49 | 44 | 44 | **46,3 %** |
| Archer | 51 | 46 | 59 | 52 | 53 | 50 | 61 | 56 | 58 | 52 | **53,9 %** |
| Prêtre | 62 | 45 | 49 | 46 | 51 | 41 | 54 | 49 | 54 | 49 | **50,1 %** |
| Alchimiste | 68 | 47 | 52 | 47 | 60 | 47 | 58 | 61 | 58 | 53 | **55,1 %** |
| Invocateur | 56 | 45 | 54 | 37 | 47 | 43 | 53 | 49 | 43 | 51 | **47,8 %** |
| Barde | 63 | 47 | 51 | 47 | 54 | 41 | 57 | 53 | 55 | 54 | **52,1 %** |
| Diplomate | 59 | 42 | 61 | 47 | 48 | 40 | 56 | 46 | 55 | 45 | **49,9 %** |
| Pugiliste | 45 | 45 | 54 | 46 | 50 | 46 | 56 | 48 | 51 | 50 | **49,1 %** |

### Les trois routes, l'usage des voies et la Tour, par classe

| Classe | Ruée | Éventail | Réactive | Voie 1 | Voie 2 | Voie 3 | Voie 4 | Voie 5 | Clé | Tour : étage 10 | étage 20 | étage moyen |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 34,5 % | 10,8 % | 45,3 % | 35,7 % | 54,2 % | 29,8 % | 76,2 % | 58,2 % | 91,7 % | 46,5 % | 3,5 % | 9,3 |
| Mage | 73,0 % | 29,5 % | 55,8 % | 41,6 % | 45,4 % | 25,7 % | 44,4 % | 23,0 % | 68,5 % | 46,0 % | 7,5 % | 10,3 |
| Voleur | 44,0 % | 23,0 % | 46,3 % | 34,2 % | 24,6 % | 46,2 % | 21,5 % | 35,0 % | 65,4 % | 49,5 % | 4,5 % | 9,7 |
| Archer | 63,0 % | 32,0 % | 53,9 % | 39,3 % | 32,4 % | 55,1 % | 18,0 % | 32,5 % | 66,3 % | 51,0 % | 8,5 % | 10,7 |
| Prêtre | 40,0 % | 17,0 % | 50,1 % | 22,0 % | 56,5 % | 33,8 % | 57,0 % | 71,2 % | 81,3 % | 41,5 % | 1,5 % | 9,5 |
| Alchimiste | 32,0 % | 16,8 % | 55,1 % | 43,9 % | 34,1 % | 11,7 % | 32,3 % | 71,9 % | 82,6 % | 49,0 % | 3,5 % | 10,4 |
| Invocateur | 47,5 % | 22,3 % | 47,8 % | 32,8 % | 21,5 % | 56,0 % | 34,3 % | 18,6 % | 59,2 % | 47,5 % | 8,0 % | 10,4 |
| Barde | 38,0 % | 18,8 % | 52,1 % | 37,2 % | 31,4 % | 35,7 % | 33,3 % | 60,0 % | 74,9 % | 43,5 % | 7,0 % | 9,9 |
| Diplomate | 29,5 % | 11,8 % | 49,9 % | 17,6 % | 54,9 % | 82,5 % | 33,8 % | 74,6 % | 84,4 % | 73,0 % | 18,5 % | 13,3 |
| Pugiliste | 15,8 % | 10,5 % | 49,1 % | 35,4 % | 37,9 % | 55,0 % | 75,5 % | 18,0 % | 88,6 % | 42,0 % | 5,5 % | 9,6 |

### Boutons touchés, et pourquoi

- PV de toutes les classes : ×0,366 → ×0,380 des PV de la spécification (médiane 9 tours, 99,6 % finis avant le tour 20 ; on vise 10 tours)
- k_classe Guerrier : 0,852 → 0,866 (45,3 % de victoires)
- k_classe Mage : 0,962 → 0,942 (55,8 % de victoires)
- k_classe Voleur : 0,778 → 0,788 (46,3 % de victoires)
- k_classe Archer : 0,879 → 0,867 (53,9 % de victoires)
- k_classe Alchimiste : 1,090 → 1,080 (55,1 % de victoires)
- k_classe Invocateur : 0,926 → 0,933 (47,8 % de victoires)
- k_classe Barde : 1,073 → 1,069 (52,1 % de victoires)
- k_classe Pugiliste : 0,950 → 0,952 (49,1 % de victoires)
- Tour, Guerrier : pente des monstres 0,767 → 0,760 (étage 20 dans 3,5 % des montées)
- Tour, Guerrier : facteur des monstres 1,667 → 1,663 (étage 10 dans 46,5 % des montées)
- Tour, Mage : facteur des monstres 0,791 → 0,790 (étage 10 dans 46,0 % des montées)
- Tour, Voleur : pente des monstres 0,619 → 0,609 (étage 20 dans 4,5 % des montées)
- Tour, Archer : facteur des monstres 0,634 → 0,635 (étage 10 dans 51,0 % des montées)
- Tour, Prêtre : pente des monstres 0,939 → 0,925 (étage 20 dans 1,5 % des montées)
- Tour, Prêtre : facteur des monstres 1,101 → 1,093 (étage 10 dans 41,5 % des montées)
- Tour, Alchimiste : pente des monstres 1,098 → 1,076 (étage 20 dans 3,5 % des montées)
- Tour, Barde : facteur des monstres 0,761 → 0,757 (étage 10 dans 43,5 % des montées)
- Tour, Diplomate : pente des monstres 0,919 → 0,970 (étage 20 dans 18,5 % des montées)
- Tour, Diplomate : facteur des monstres 1,142 → 1,169 (étage 10 dans 73,0 % des montées)
- Tour, Pugiliste : facteur des monstres 0,940 → 0,933 (étage 10 dans 42,0 % des montées)

## Passe 34 (graines à partir de 3400103)

**1 critères tenus sur 6.** 50000 combats de duel (médiane 10 tours), 0 combats non finis.

### Les six critères (section 11.2)

- ❌ **1. Chaque classe entre 47 % et 53 % de victoires** : mage 58,7 %, voleur 45,7 %, alchimiste 53,4 %, invocateur 46,0 %
- ❌ **2. Aucune case de la matrice hors de 40 % – 60 %** : guerrier contre alchimiste 35,0 %, mage contre voleur 61,8 %, mage contre barde 61,0 %, mage contre diplomate 60,4 %, voleur contre mage 39,0 %, pretre contre alchimiste 38,0 %, alchimiste contre guerrier 62,0 %, alchimiste contre pretre 61,8 %, invocateur contre mage 39,4 %, barde contre guerrier 62,6 %, barde contre mage 38,4 %, barde contre alchimiste 37,4 %
- ❌ **3. La route Réactive entre 40 % et 55 % (Ruée et Éventail : des repères, sans seuil)** : mage Réactive 58,7 %
- ❌ **4. Chaque voie jouée dans 15 % des combats au moins, une Clé dans 60 %** : alchimiste voie 3 13,2 %
- ✅ **5. Longueur : médiane de 6 à 10 tours, 95 % finis avant le tour 20**
- ❌ **6. Tour : étage 10 dans 40 à 60 % des montées, étage 20 dans 5 à 10 %, à 5 points près entre classes** : pretre étage 10 37,5 %, pretre étage 20 4,5 %, diplomate étage 10 68,0 %, diplomate étage 20 18,0 %, écart entre classes : étage 10 de 37,5 % à 68,0 %, étage 20 de 4,5 % à 18,0 %

### La matrice des classes (taux de victoire de la ligne contre la colonne)

| | Guer | Mage | Vole | Arch | Prêt | Alch | Invo | Bard | Dipl | Pugi | **Moyenne** |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 51 | 47 | 50 | 57 | 44 | 35 | 43 | 44 | 46 | 59 | **47,7 %** |
| Mage | 56 | 51 | 62 | 57 | 60 | 60 | 59 | 61 | 60 | 60 | **58,7 %** |
| Voleur | 46 | 39 | 51 | 41 | 49 | 48 | 47 | 47 | 41 | 47 | **45,7 %** |
| Archer | 46 | 41 | 58 | 49 | 50 | 48 | 54 | 50 | 57 | 53 | **50,6 %** |
| Prêtre | 55 | 43 | 53 | 51 | 51 | 38 | 53 | 48 | 53 | 51 | **49,5 %** |
| Alchimiste | 62 | 41 | 49 | 51 | 62 | 47 | 54 | 57 | 57 | 54 | **53,4 %** |
| Invocateur | 55 | 39 | 51 | 42 | 45 | 41 | 46 | 47 | 44 | 50 | **46,0 %** |
| Barde | 63 | 38 | 51 | 48 | 51 | 37 | 49 | 49 | 49 | 53 | **48,9 %** |
| Diplomate | 58 | 44 | 58 | 46 | 51 | 45 | 57 | 57 | 48 | 51 | **51,5 %** |
| Pugiliste | 45 | 41 | 55 | 49 | 50 | 47 | 54 | 53 | 55 | 52 | **50,1 %** |

### Les trois routes, l'usage des voies et la Tour, par classe

| Classe | Ruée | Éventail | Réactive | Voie 1 | Voie 2 | Voie 3 | Voie 4 | Voie 5 | Clé | Tour : étage 10 | étage 20 | étage moyen |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 40,8 % | 12,3 % | 47,7 % | 40,7 % | 48,8 % | 32,4 % | 76,2 % | 59,7 % | 92,3 % | 46,0 % | 5,5 % | 9,7 |
| Mage | 68,3 % | 31,0 % | 58,7 % | 45,8 % | 45,4 % | 28,6 % | 37,6 % | 21,3 % | 69,4 % | 46,0 % | 8,5 % | 10,3 |
| Voleur | 47,5 % | 26,3 % | 45,7 % | 36,5 % | 21,1 % | 47,5 % | 28,5 % | 32,2 % | 68,7 % | 43,0 % | 5,5 % | 9,6 |
| Archer | 59,8 % | 29,5 % | 50,6 % | 27,9 % | 28,9 % | 62,5 % | 22,1 % | 27,0 % | 66,7 % | 50,5 % | 7,0 % | 10,7 |
| Prêtre | 43,8 % | 17,5 % | 49,5 % | 23,8 % | 55,7 % | 34,4 % | 56,4 % | 73,9 % | 81,8 % | 37,5 % | 4,5 % | 9,3 |
| Alchimiste | 36,0 % | 17,0 % | 53,4 % | 42,0 % | 38,1 % | 13,2 % | 33,7 % | 73,2 % | 82,9 % | 52,5 % | 5,5 % | 10,9 |
| Invocateur | 51,5 % | 25,5 % | 46,0 % | 37,3 % | 22,9 % | 52,5 % | 33,5 % | 20,1 % | 61,5 % | 49,5 % | 10,0 % | 10,6 |
| Barde | 38,8 % | 22,8 % | 48,9 % | 36,5 % | 32,2 % | 35,0 % | 32,4 % | 62,1 % | 74,4 % | 45,5 % | 10,0 % | 10,3 |
| Diplomate | 26,3 % | 10,5 % | 51,5 % | 18,8 % | 54,0 % | 83,1 % | 38,0 % | 72,8 % | 85,8 % | 68,0 % | 18,0 % | 13,0 |
| Pugiliste | 21,8 % | 11,0 % | 50,1 % | 41,2 % | 36,7 % | 52,1 % | 75,8 % | 18,4 % | 88,0 % | 44,5 % | 7,5 % | 10,1 |

### Boutons touchés, et pourquoi

- k_classe Guerrier : 0,866 → 0,873 (47,7 % de victoires)
- k_classe Mage : 0,942 → 0,914 (58,7 % de victoires)
- k_classe Voleur : 0,788 → 0,800 (45,7 % de victoires)
- k_classe Alchimiste : 1,080 → 1,074 (53,4 % de victoires)
- k_classe Invocateur : 0,933 → 0,946 (46,0 % de victoires)
- k_classe Barde : 1,069 → 1,070 (48,9 % de victoires)
- k_classe Diplomate : 1,200 → 1,197 (51,5 % de victoires)
- Tour, Guerrier : facteur des monstres 1,663 → 1,659 (étage 10 dans 46,0 % des montées)
- Tour, Mage : facteur des monstres 0,790 → 0,788 (étage 10 dans 46,0 % des montées)
- Tour, Voleur : facteur des monstres 0,961 → 0,956 (étage 10 dans 43,0 % des montées)
- Tour, Archer : facteur des monstres 0,635 → 0,637 (étage 10 dans 50,5 % des montées)
- Tour, Prêtre : pente des monstres 0,925 → 0,918 (étage 20 dans 4,5 % des montées)
- Tour, Prêtre : facteur des monstres 1,093 → 1,081 (étage 10 dans 37,5 % des montées)
- Tour, Alchimiste : facteur des monstres 0,992 → 0,994 (étage 10 dans 52,5 % des montées)
- Tour, Invocateur : pente des monstres 1,086 → 1,089 (étage 20 dans 10,0 % des montées)
- Tour, Barde : pente des monstres 1,326 → 1,343 (étage 20 dans 10,0 % des montées)
- Tour, Barde : facteur des monstres 0,757 → 0,755 (étage 10 dans 45,5 % des montées)
- Tour, Diplomate : pente des monstres 0,970 → 1,021 (étage 20 dans 18,0 % des montées)
- Tour, Diplomate : facteur des monstres 1,169 → 1,192 (étage 10 dans 68,0 % des montées)
- Tour, Pugiliste : facteur des monstres 0,933 → 0,930 (étage 10 dans 44,5 % des montées)

## Passe 35 (graines à partir de 3500106)

**1 critères tenus sur 6.** 50000 combats de duel (médiane 10 tours), 0 combats non finis.

### Les six critères (section 11.2)

- ❌ **1. Chaque classe entre 47 % et 53 % de victoires** : mage 56,6 %, pretre 43,9 %, alchimiste 54,2 %
- ❌ **2. Aucune case de la matrice hors de 40 % – 60 %** : guerrier contre alchimiste 33,6 %, mage contre pretre 62,6 %, mage contre barde 62,0 %, pretre contre mage 37,6 %, pretre contre voleur 39,0 %, pretre contre alchimiste 34,0 %, alchimiste contre guerrier 65,4 %, alchimiste contre pretre 64,8 %, alchimiste contre barde 61,0 %, barde contre mage 39,6 %, barde contre alchimiste 39,2 %
- ❌ **3. La route Réactive entre 40 % et 55 % (Ruée et Éventail : des repères, sans seuil)** : mage Réactive 56,6 %
- ❌ **4. Chaque voie jouée dans 15 % des combats au moins, une Clé dans 60 %** : alchimiste voie 3 11,9 %
- ✅ **5. Longueur : médiane de 6 à 10 tours, 95 % finis avant le tour 20**
- ❌ **6. Tour : étage 10 dans 40 à 60 % des montées, étage 20 dans 5 à 10 %, à 5 points près entre classes** : mage étage 20 3,5 %, voleur étage 20 2,5 %, archer étage 20 10,5 %, pretre étage 10 37,0 %, pretre étage 20 0,5 %, diplomate étage 10 65,5 %, pugiliste étage 10 39,5 %, écart entre classes : étage 10 de 37,0 % à 65,5 %, étage 20 de 0,5 % à 10,5 %

### La matrice des classes (taux de victoire de la ligne contre la colonne)

| | Guer | Mage | Vole | Arch | Prêt | Alch | Invo | Bard | Dipl | Pugi | **Moyenne** |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 51 | 48 | 52 | 53 | 48 | 34 | 42 | 45 | 45 | 58 | **47,6 %** |
| Mage | 54 | 52 | 58 | 52 | 63 | 57 | 55 | 62 | 56 | 56 | **56,6 %** |
| Voleur | 53 | 44 | 52 | 46 | 58 | 50 | 49 | 54 | 45 | 47 | **49,7 %** |
| Archer | 52 | 45 | 55 | 48 | 55 | 55 | 58 | 56 | 53 | 53 | **53,0 %** |
| Prêtre | 52 | 38 | 39 | 45 | 49 | 34 | 47 | 42 | 44 | 48 | **43,9 %** |
| Alchimiste | 65 | 45 | 47 | 47 | 65 | 49 | 54 | 61 | 53 | 55 | **54,2 %** |
| Invocateur | 58 | 46 | 51 | 40 | 52 | 40 | 48 | 51 | 45 | 54 | **48,6 %** |
| Barde | 55 | 40 | 46 | 48 | 55 | 39 | 52 | 51 | 49 | 52 | **48,7 %** |
| Diplomate | 55 | 42 | 48 | 41 | 52 | 41 | 55 | 45 | 47 | 43 | **47,0 %** |
| Pugiliste | 46 | 44 | 54 | 48 | 54 | 50 | 53 | 50 | 52 | 52 | **50,4 %** |

### Les trois routes, l'usage des voies et la Tour, par classe

| Classe | Ruée | Éventail | Réactive | Voie 1 | Voie 2 | Voie 3 | Voie 4 | Voie 5 | Clé | Tour : étage 10 | étage 20 | étage moyen |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 32,5 % | 9,5 % | 47,6 % | 29,6 % | 54,1 % | 36,4 % | 83,2 % | 53,6 % | 93,2 % | 47,5 % | 5,0 % | 9,8 |
| Mage | 69,0 % | 32,3 % | 56,6 % | 27,0 % | 53,9 % | 29,7 % | 40,8 % | 19,2 % | 69,3 % | 43,0 % | 3,5 % | 9,6 |
| Voleur | 51,7 % | 29,0 % | 49,7 % | 32,9 % | 19,6 % | 44,4 % | 21,0 % | 42,7 % | 67,0 % | 45,5 % | 2,5 % | 9,4 |
| Archer | 61,8 % | 28,7 % | 53,0 % | 22,6 % | 35,8 % | 58,9 % | 18,4 % | 29,9 % | 65,7 % | 50,0 % | 10,5 % | 10,8 |
| Prêtre | 38,5 % | 16,8 % | 43,9 % | 24,5 % | 58,8 % | 34,9 % | 60,4 % | 70,9 % | 83,9 % | 37,0 % | 0,5 % | 8,9 |
| Alchimiste | 32,5 % | 11,5 % | 54,2 % | 47,1 % | 35,5 % | 11,9 % | 30,3 % | 69,2 % | 84,1 % | 56,0 % | 7,0 % | 11,1 |
| Invocateur | 61,3 % | 27,0 % | 48,6 % | 31,0 % | 22,7 % | 52,6 % | 37,3 % | 23,6 % | 61,4 % | 55,5 % | 9,0 % | 11,0 |
| Barde | 39,5 % | 19,0 % | 48,7 % | 37,8 % | 31,5 % | 34,0 % | 31,5 % | 61,2 % | 76,9 % | 44,5 % | 7,5 % | 9,9 |
| Diplomate | 27,3 % | 8,8 % | 47,0 % | 17,2 % | 45,9 % | 82,6 % | 32,1 % | 76,0 % | 87,2 % | 65,5 % | 10,0 % | 12,1 |
| Pugiliste | 15,5 % | 7,0 % | 50,4 % | 37,3 % | 35,4 % | 53,9 % | 78,6 % | 19,4 % | 89,6 % | 39,5 % | 5,5 % | 9,6 |

### Boutons touchés, et pourquoi

- k_classe Guerrier : 0,873 → 0,881 (47,6 % de victoires)
- k_classe Mage : 0,914 → 0,893 (56,6 % de victoires)
- k_classe Archer : 0,867 → 0,858 (53,0 % de victoires)
- k_classe Prêtre : 0,772 → 0,780 (43,9 % de victoires)
- k_classe Alchimiste : 1,074 → 1,066 (54,2 % de victoires)
- k_classe Invocateur : 0,946 → 0,951 (48,6 % de victoires)
- k_classe Barde : 1,070 → 1,071 (48,7 % de victoires)
- k_classe Diplomate : 1,197 → 1,200 (47,0 % de victoires)
- Tour, Guerrier : pente des monstres 0,760 → 0,755 (étage 20 dans 5,0 % des montées)
- Tour, Mage : pente des monstres 1,247 → 1,235 (étage 20 dans 3,5 % des montées)
- Tour, Mage : facteur des monstres 0,788 → 0,784 (étage 10 dans 43,0 % des montées)
- Tour, Voleur : pente des monstres 0,609 → 0,594 (étage 20 dans 2,5 % des montées)
- Tour, Voleur : facteur des monstres 0,956 → 0,953 (étage 10 dans 45,5 % des montées)
- Tour, Archer : pente des monstres 1,469 → 1,480 (étage 20 dans 10,5 % des montées)
- Tour, Prêtre : pente des monstres 0,918 → 0,902 (étage 20 dans 0,5 % des montées)
- Tour, Prêtre : facteur des monstres 1,081 → 1,069 (étage 10 dans 37,0 % des montées)
- Tour, Alchimiste : facteur des monstres 0,994 → 1,002 (étage 10 dans 56,0 % des montées)
- Tour, Invocateur : facteur des monstres 0,917 → 0,920 (étage 10 dans 55,5 % des montées)
- Tour, Barde : facteur des monstres 0,755 → 0,752 (étage 10 dans 44,5 % des montées)
- Tour, Diplomate : pente des monstres 1,021 → 1,034 (étage 20 dans 10,0 % des montées)
- Tour, Diplomate : facteur des monstres 1,192 → 1,213 (étage 10 dans 65,5 % des montées)
- Tour, Pugiliste : facteur des monstres 0,930 → 0,922 (étage 10 dans 39,5 % des montées)

## Passe 36 (graines à partir de 3600109)

**1 critères tenus sur 6.** 50000 combats de duel (médiane 10 tours), 0 combats non finis.

### Les six critères (section 11.2)

- ❌ **1. Chaque classe entre 47 % et 53 % de victoires** : mage 59,2 %, pretre 43,7 %
- ❌ **2. Aucune case de la matrice hors de 40 % – 60 %** : guerrier contre archer 60,6 %, guerrier contre alchimiste 37,8 %, mage contre pretre 66,2 %, mage contre alchimiste 61,8 %, mage contre invocateur 60,4 %, mage contre barde 60,6 %, mage contre diplomate 63,6 %, mage contre pugiliste 60,4 %, voleur contre mage 39,4 %, pretre contre mage 30,6 %, alchimiste contre guerrier 60,2 %, alchimiste contre mage 38,2 %, alchimiste contre pretre 63,8 %, alchimiste contre barde 61,4 %, barde contre mage 34,8 %, barde contre alchimiste 38,6 %, diplomate contre mage 39,8 %
- ❌ **3. La route Réactive entre 40 % et 55 % (Ruée et Éventail : des repères, sans seuil)** : mage Réactive 59,2 %
- ❌ **4. Chaque voie jouée dans 15 % des combats au moins, une Clé dans 60 %** : alchimiste voie 3 10,7 %
- ✅ **5. Longueur : médiane de 6 à 10 tours, 95 % finis avant le tour 20**
- ❌ **6. Tour : étage 10 dans 40 à 60 % des montées, étage 20 dans 5 à 10 %, à 5 points près entre classes** : voleur étage 20 1,0 %, pretre étage 20 4,5 %, diplomate étage 10 63,0 %, pugiliste étage 20 4,5 %, écart entre classes : étage 10 de 43,5 % à 63,0 %, étage 20 de 1,0 % à 9,5 %

### La matrice des classes (taux de victoire de la ligne contre la colonne)

| | Guer | Mage | Vole | Arch | Prêt | Alch | Invo | Bard | Dipl | Pugi | **Moyenne** |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 48 | 47 | 54 | 61 | 52 | 38 | 46 | 50 | 47 | 59 | **50,2 %** |
| Mage | 54 | 49 | 58 | 58 | 66 | 62 | 60 | 61 | 64 | 60 | **59,2 %** |
| Voleur | 46 | 39 | 49 | 44 | 54 | 54 | 48 | 56 | 46 | 44 | **48,2 %** |
| Archer | 44 | 43 | 56 | 52 | 56 | 55 | 58 | 53 | 54 | 56 | **52,7 %** |
| Prêtre | 42 | 31 | 44 | 44 | 49 | 42 | 48 | 47 | 47 | 45 | **43,7 %** |
| Alchimiste | 60 | 38 | 47 | 43 | 64 | 49 | 55 | 61 | 52 | 47 | **51,7 %** |
| Invocateur | 53 | 42 | 52 | 45 | 52 | 47 | 52 | 52 | 47 | 48 | **48,9 %** |
| Barde | 56 | 35 | 46 | 46 | 55 | 39 | 51 | 49 | 53 | 49 | **47,8 %** |
| Diplomate | 54 | 40 | 57 | 45 | 54 | 46 | 58 | 48 | 49 | 47 | **49,7 %** |
| Pugiliste | 40 | 43 | 53 | 47 | 51 | 48 | 48 | 48 | 50 | 46 | **47,4 %** |

### Les trois routes, l'usage des voies et la Tour, par classe

| Classe | Ruée | Éventail | Réactive | Voie 1 | Voie 2 | Voie 3 | Voie 4 | Voie 5 | Clé | Tour : étage 10 | étage 20 | étage moyen |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 40,0 % | 12,3 % | 50,2 % | 31,1 % | 46,8 % | 32,5 % | 86,2 % | 52,4 % | 93,4 % | 56,5 % | 8,0 % | 10,8 |
| Mage | 63,5 % | 30,8 % | 59,2 % | 30,7 % | 66,0 % | 15,2 % | 23,3 % | 18,4 % | 68,2 % | 48,5 % | 7,0 % | 10,4 |
| Voleur | 47,0 % | 24,8 % | 48,2 % | 35,5 % | 20,5 % | 44,7 % | 19,7 % | 37,6 % | 67,3 % | 54,0 % | 1,0 % | 9,7 |
| Archer | 58,3 % | 30,8 % | 52,7 % | 23,6 % | 33,7 % | 57,2 % | 21,1 % | 27,9 % | 64,3 % | 55,5 % | 5,5 % | 11,1 |
| Prêtre | 34,8 % | 17,0 % | 43,7 % | 23,4 % | 63,7 % | 25,7 % | 56,1 % | 65,3 % | 82,7 % | 43,5 % | 4,5 % | 9,9 |
| Alchimiste | 23,5 % | 12,8 % | 51,7 % | 43,6 % | 33,3 % | 10,7 % | 29,3 % | 74,4 % | 83,8 % | 54,5 % | 5,5 % | 10,6 |
| Invocateur | 50,7 % | 25,8 % | 48,9 % | 36,4 % | 22,5 % | 52,7 % | 32,1 % | 24,5 % | 61,2 % | 50,5 % | 8,0 % | 10,4 |
| Barde | 37,3 % | 18,5 % | 47,8 % | 36,2 % | 29,0 % | 34,0 % | 30,9 % | 60,6 % | 76,0 % | 48,0 % | 9,5 % | 10,4 |
| Diplomate | 27,5 % | 12,5 % | 49,7 % | 18,2 % | 54,0 % | 81,6 % | 33,4 % | 72,6 % | 85,2 % | 63,0 % | 7,0 % | 11,9 |
| Pugiliste | 10,8 % | 8,8 % | 47,4 % | 38,8 % | 36,7 % | 52,7 % | 75,3 % | 17,4 % | 88,5 % | 48,0 % | 4,5 % | 10,0 |

### Boutons touchés, et pourquoi

- k_classe Mage : 0,893 → 0,866 (59,2 % de victoires)
- k_classe Voleur : 0,800 → 0,805 (48,2 % de victoires)
- k_classe Archer : 0,858 → 0,850 (52,7 % de victoires)
- k_classe Prêtre : 0,780 → 0,788 (43,7 % de victoires)
- k_classe Alchimiste : 1,066 → 1,063 (51,7 % de victoires)
- k_classe Invocateur : 0,951 → 0,954 (48,9 % de victoires)
- k_classe Barde : 1,071 → 1,073 (47,8 % de victoires)
- k_classe Pugiliste : 0,952 → 0,956 (47,4 % de victoires)
- budgets de la Voie de la Foudre (Mage) : +3 % (jouée dans 15,2 % des combats)
- Tour, Guerrier : facteur des monstres 1,659 → 1,663 (étage 10 dans 56,5 % des montées)
- Tour, Mage : facteur des monstres 0,784 → 0,781 (étage 10 dans 48,5 % des montées)
- Tour, Voleur : pente des monstres 0,594 → 0,575 (étage 20 dans 1,0 % des montées)
- Tour, Archer : facteur des monstres 0,637 → 0,639 (étage 10 dans 55,5 % des montées)
- Tour, Prêtre : pente des monstres 0,902 → 0,895 (étage 20 dans 4,5 % des montées)
- Tour, Prêtre : facteur des monstres 1,069 → 1,060 (étage 10 dans 43,5 % des montées)
- Tour, Alchimiste : facteur des monstres 1,002 → 1,004 (étage 10 dans 54,5 % des montées)
- Tour, Barde : pente des monstres 1,343 → 1,356 (étage 20 dans 9,5 % des montées)
- Tour, Barde : facteur des monstres 0,752 → 0,749 (étage 10 dans 48,0 % des montées)
- Tour, Diplomate : facteur des monstres 1,213 → 1,226 (étage 10 dans 63,0 % des montées)
- Tour, Pugiliste : pente des monstres 1,015 → 0,999 (étage 20 dans 4,5 % des montées)
- Tour, Pugiliste : facteur des monstres 0,922 → 0,918 (étage 10 dans 48,0 % des montées)

## Passe 37 (graines à partir de 3700112)

**1 critères tenus sur 6.** 50000 combats de duel (médiane 10 tours), 0 combats non finis.

### Les six critères (section 11.2)

- ❌ **1. Chaque classe entre 47 % et 53 % de victoires** : mage 58,6 %, pretre 40,9 %, alchimiste 53,4 %, barde 46,9 %
- ❌ **2. Aucune case de la matrice hors de 40 % – 60 %** : mage contre archer 60,4 %, mage contre pretre 67,2 %, mage contre alchimiste 63,4 %, mage contre barde 62,0 %, mage contre diplomate 64,2 %, archer contre guerrier 38,6 %, pretre contre mage 29,2 %, pretre contre alchimiste 32,2 %, pretre contre pugiliste 37,8 %, alchimiste contre guerrier 61,4 %, alchimiste contre mage 38,2 %, alchimiste contre pretre 66,2 %, alchimiste contre barde 62,8 %, barde contre mage 37,4 %, barde contre pretre 61,6 %, barde contre alchimiste 38,8 %, diplomate contre mage 39,8 %, pugiliste contre pretre 62,6 %
- ❌ **3. La route Réactive entre 40 % et 55 % (Ruée et Éventail : des repères, sans seuil)** : mage Réactive 58,6 %
- ❌ **4. Chaque voie jouée dans 15 % des combats au moins, une Clé dans 60 %** : alchimiste voie 3 13,0 %
- ✅ **5. Longueur : médiane de 6 à 10 tours, 95 % finis avant le tour 20**
- ❌ **6. Tour : étage 10 dans 40 à 60 % des montées, étage 20 dans 5 à 10 %, à 5 points près entre classes** : voleur étage 20 2,0 %, pretre étage 20 4,0 %, pugiliste étage 20 4,5 %, écart entre classes : étage 10 de 40,5 % à 57,5 %, étage 20 de 2,0 % à 9,0 %

### La matrice des classes (taux de victoire de la ligne contre la colonne)

| | Guer | Mage | Vole | Arch | Prêt | Alch | Invo | Bard | Dipl | Pugi | **Moyenne** |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 44 | 51 | 53 | 58 | 53 | 41 | 44 | 49 | 47 | 56 | **49,7 %** |
| Mage | 49 | 50 | 60 | 60 | 67 | 63 | 55 | 62 | 64 | 55 | **58,6 %** |
| Voleur | 47 | 44 | 51 | 49 | 59 | 50 | 46 | 56 | 41 | 40 | **48,3 %** |
| Archer | 39 | 41 | 54 | 52 | 56 | 55 | 53 | 53 | 53 | 42 | **49,7 %** |
| Prêtre | 43 | 29 | 41 | 46 | 49 | 32 | 44 | 43 | 43 | 38 | **40,9 %** |
| Alchimiste | 61 | 38 | 49 | 49 | 66 | 51 | 55 | 63 | 57 | 45 | **53,4 %** |
| Invocateur | 58 | 43 | 55 | 46 | 55 | 48 | 49 | 55 | 45 | 46 | **50,1 %** |
| Barde | 50 | 37 | 46 | 48 | 62 | 39 | 46 | 48 | 51 | 43 | **46,9 %** |
| Diplomate | 49 | 40 | 56 | 44 | 55 | 46 | 56 | 49 | 51 | 46 | **49,1 %** |
| Pugiliste | 43 | 49 | 55 | 54 | 63 | 51 | 56 | 54 | 58 | 48 | **52,9 %** |

### Les trois routes, l'usage des voies et la Tour, par classe

| Classe | Ruée | Éventail | Réactive | Voie 1 | Voie 2 | Voie 3 | Voie 4 | Voie 5 | Clé | Tour : étage 10 | étage 20 | étage moyen |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 34,3 % | 13,3 % | 49,7 % | 32,4 % | 48,2 % | 34,0 % | 82,9 % | 55,3 % | 93,1 % | 48,0 % | 5,5 % | 10,1 |
| Mage | 63,5 % | 31,8 % | 58,6 % | 27,5 % | 55,4 % | 43,4 % | 18,7 % | 16,0 % | 66,0 % | 46,0 % | 6,5 % | 10,1 |
| Voleur | 38,5 % | 21,3 % | 48,3 % | 34,6 % | 22,9 % | 42,7 % | 24,6 % | 35,2 % | 67,5 % | 47,5 % | 2,0 % | 9,5 |
| Archer | 57,8 % | 28,5 % | 49,7 % | 22,8 % | 30,2 % | 64,0 % | 20,1 % | 20,8 % | 64,1 % | 42,5 % | 5,0 % | 9,8 |
| Prêtre | 28,5 % | 9,0 % | 40,9 % | 26,9 % | 56,4 % | 37,0 % | 61,1 % | 72,1 % | 84,6 % | 40,5 % | 4,0 % | 9,5 |
| Alchimiste | 26,5 % | 9,8 % | 53,4 % | 46,0 % | 36,6 % | 13,0 % | 30,5 % | 68,3 % | 85,7 % | 55,0 % | 5,5 % | 10,8 |
| Invocateur | 50,7 % | 23,5 % | 50,1 % | 38,0 % | 22,2 % | 47,6 % | 34,4 % | 24,3 % | 61,6 % | 52,5 % | 8,0 % | 10,5 |
| Barde | 31,5 % | 14,0 % | 46,9 % | 34,9 % | 33,1 % | 35,2 % | 34,8 % | 60,7 % | 76,4 % | 47,0 % | 7,5 % | 10,4 |
| Diplomate | 24,3 % | 9,8 % | 49,1 % | 18,1 % | 56,4 % | 83,9 % | 32,5 % | 72,4 % | 86,8 % | 57,5 % | 9,0 % | 11,2 |
| Pugiliste | 15,5 % | 8,5 % | 52,9 % | 41,4 % | 35,2 % | 45,5 % | 79,8 % | 16,7 % | 88,4 % | 42,5 % | 4,5 % | 9,7 |

### Boutons touchés, et pourquoi

- k_classe Mage : 0,866 → 0,840 (58,6 % de victoires)
- k_classe Voleur : 0,805 → 0,810 (48,3 % de victoires)
- k_classe Prêtre : 0,788 → 0,801 (40,9 % de victoires)
- k_classe Alchimiste : 1,063 → 1,056 (53,4 % de victoires)
- k_classe Barde : 1,073 → 1,076 (46,9 % de victoires)
- k_classe Pugiliste : 0,956 → 0,954 (52,9 % de victoires)
- budgets de la Voie de l'Arcane (Mage) : +3 % (jouée dans 16,0 % des combats)
- budgets des premiers nœuds des autres voies (Pugiliste) : -3 % (la Voie du Défi, jouée dans 16,7 % des combats, commence par un état seul)
- Tour : force des monstres au départ 0,383 → 0,383, en plus par étage 0,027 → 0,027 (étage 10 atteint dans 47,9 % des montées, étage 20 dans 5,8 %)
- Tour, Voleur : pente des monstres 0,575 → 0,559 (étage 20 dans 2,0 % des montées)
- Tour, Archer : pente des monstres 1,480 → 1,476 (étage 20 dans 5,0 % des montées)
- Tour, Archer : facteur des monstres 0,639 → 0,637 (étage 10 dans 42,5 % des montées)
- Tour, Prêtre : pente des monstres 0,895 → 0,887 (étage 20 dans 4,0 % des montées)
- Tour, Prêtre : facteur des monstres 1,060 → 1,052 (étage 10 dans 40,5 % des montées)
- Tour, Alchimiste : facteur des monstres 1,004 → 1,011 (étage 10 dans 55,0 % des montées)
- Tour, Invocateur : facteur des monstres 0,920 → 0,925 (étage 10 dans 52,5 % des montées)
- Tour, Diplomate : facteur des monstres 1,226 → 1,238 (étage 10 dans 57,5 % des montées)
- Tour, Pugiliste : pente des monstres 0,999 → 0,984 (étage 20 dans 4,5 % des montées)
- Tour, Pugiliste : facteur des monstres 0,918 → 0,913 (étage 10 dans 42,5 % des montées)

## Passe 38 (graines à partir de 3800115)

**1 critères tenus sur 6.** 50000 combats de duel (médiane 10 tours), 0 combats non finis.

### Les six critères (section 11.2)

- ❌ **1. Chaque classe entre 47 % et 53 % de victoires** : guerrier 53,7 %, mage 58,4 %, pretre 39,9 %
- ❌ **2. Aucune case de la matrice hors de 40 % – 60 %** : guerrier contre archer 64,2 %, guerrier contre pugiliste 61,6 %, mage contre pretre 73,0 %, mage contre alchimiste 64,4 %, mage contre barde 61,8 %, mage contre diplomate 63,4 %, voleur contre pretre 65,4 %, pretre contre mage 28,8 %, pretre contre alchimiste 35,2 %, pretre contre barde 37,8 %, pretre contre pugiliste 38,0 %, alchimiste contre mage 39,0 %, alchimiste contre archer 39,4 %, alchimiste contre pretre 69,8 %, invocateur contre pretre 62,0 %, barde contre mage 37,4 %, diplomate contre mage 38,8 %, pugiliste contre guerrier 39,4 %, pugiliste contre pretre 61,6 %
- ❌ **3. La route Réactive entre 40 % et 55 % (Ruée et Éventail : des repères, sans seuil)** : mage Réactive 58,4 %, pretre Réactive 39,9 %
- ❌ **4. Chaque voie jouée dans 15 % des combats au moins, une Clé dans 60 %** : alchimiste voie 3 11,7 %
- ✅ **5. Longueur : médiane de 6 à 10 tours, 95 % finis avant le tour 20**
- ❌ **6. Tour : étage 10 dans 40 à 60 % des montées, étage 20 dans 5 à 10 %, à 5 points près entre classes** : mage étage 20 4,5 %, voleur étage 20 2,5 %, pretre étage 20 2,5 %, alchimiste étage 10 39,5 %, alchimiste étage 20 4,0 %, barde étage 10 39,5 %, diplomate étage 10 66,0 %, pugiliste étage 20 4,0 %, écart entre classes : étage 10 de 39,5 % à 66,0 %, étage 20 de 2,5 % à 9,0 %

### La matrice des classes (taux de victoire de la ligne contre la colonne)

| | Guer | Mage | Vole | Arch | Prêt | Alch | Invo | Bard | Dipl | Pugi | **Moyenne** |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 49 | 52 | 55 | 64 | 59 | 44 | 49 | 54 | 49 | 62 | **53,7 %** |
| Mage | 49 | 46 | 57 | 59 | 73 | 64 | 57 | 62 | 63 | 54 | **58,4 %** |
| Voleur | 44 | 42 | 50 | 41 | 65 | 56 | 46 | 55 | 43 | 47 | **49,0 %** |
| Archer | 40 | 43 | 58 | 51 | 60 | 59 | 58 | 51 | 58 | 51 | **53,0 %** |
| Prêtre | 40 | 29 | 42 | 40 | 49 | 35 | 44 | 38 | 44 | 38 | **39,9 %** |
| Alchimiste | 59 | 39 | 43 | 39 | 70 | 51 | 50 | 55 | 56 | 49 | **51,1 %** |
| Invocateur | 53 | 43 | 53 | 43 | 62 | 51 | 51 | 51 | 44 | 52 | **50,4 %** |
| Barde | 52 | 37 | 46 | 44 | 60 | 40 | 46 | 49 | 46 | 49 | **47,1 %** |
| Diplomate | 54 | 39 | 57 | 43 | 60 | 45 | 57 | 53 | 50 | 47 | **50,6 %** |
| Pugiliste | 39 | 44 | 53 | 49 | 62 | 51 | 55 | 50 | 53 | 50 | **50,7 %** |

### Les trois routes, l'usage des voies et la Tour, par classe

| Classe | Ruée | Éventail | Réactive | Voie 1 | Voie 2 | Voie 3 | Voie 4 | Voie 5 | Clé | Tour : étage 10 | étage 20 | étage moyen |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 41,5 % | 9,5 % | 53,7 % | 32,3 % | 46,8 % | 32,4 % | 84,5 % | 55,0 % | 92,7 % | 58,0 % | 6,5 % | 11,0 |
| Mage | 64,0 % | 29,8 % | 58,4 % | 22,7 % | 70,2 % | 24,9 % | 16,7 % | 18,8 % | 67,8 % | 42,5 % | 4,5 % | 9,6 |
| Voleur | 40,3 % | 19,0 % | 49,0 % | 35,7 % | 23,0 % | 40,7 % | 20,2 % | 41,2 % | 66,5 % | 43,0 % | 2,5 % | 9,3 |
| Archer | 53,3 % | 24,5 % | 53,0 % | 22,8 % | 31,5 % | 63,0 % | 19,2 % | 18,9 % | 64,7 % | 47,0 % | 8,0 % | 10,1 |
| Prêtre | 27,5 % | 10,0 % | 39,9 % | 26,6 % | 56,2 % | 34,5 % | 59,8 % | 72,4 % | 84,7 % | 43,0 % | 2,5 % | 9,3 |
| Alchimiste | 29,8 % | 11,3 % | 51,1 % | 51,8 % | 33,2 % | 11,7 % | 31,6 % | 64,1 % | 83,9 % | 39,5 % | 4,0 % | 9,7 |
| Invocateur | 42,5 % | 21,8 % | 50,4 % | 39,3 % | 23,5 % | 47,2 % | 34,8 % | 23,7 % | 62,4 % | 54,5 % | 9,0 % | 10,8 |
| Barde | 31,5 % | 13,0 % | 47,1 % | 36,9 % | 31,8 % | 33,4 % | 33,1 % | 61,1 % | 75,4 % | 39,5 % | 5,0 % | 9,4 |
| Diplomate | 32,3 % | 9,5 % | 50,6 % | 18,7 % | 54,4 % | 83,7 % | 34,5 % | 72,6 % | 86,6 % | 66,0 % | 9,0 % | 11,9 |
| Pugiliste | 17,5 % | 5,8 % | 50,7 % | 33,1 % | 32,2 % | 52,1 % | 80,3 % | 20,2 % | 88,5 % | 51,5 % | 4,0 % | 10,1 |

### Boutons touchés, et pourquoi

- k_classe Guerrier : 0,881 → 0,875 (53,7 % de victoires)
- k_classe Mage : 0,840 → 0,816 (58,4 % de victoires)
- k_classe Voleur : 0,810 → 0,812 (49,0 % de victoires)
- k_classe Archer : 0,850 → 0,841 (53,0 % de victoires)
- k_classe Prêtre : 0,801 → 0,815 (39,9 % de victoires)
- k_classe Alchimiste : 1,056 → 1,054 (51,1 % de victoires)
- k_classe Barde : 1,076 → 1,079 (47,1 % de victoires)
- budgets de la Voie du Voile (Mage) : +3 % (jouée dans 16,7 % des combats)
- Tour : force des monstres au départ 0,383 → 0,383, en plus par étage 0,027 → 0,026 (étage 10 atteint dans 48,4 % des montées, étage 20 dans 5,5 %)
- Tour, Guerrier : facteur des monstres 1,663 → 1,679 (étage 10 dans 58,0 % des montées)
- Tour, Mage : pente des monstres 1,235 → 1,226 (étage 20 dans 4,5 % des montées)
- Tour, Mage : facteur des monstres 0,781 → 0,777 (étage 10 dans 42,5 % des montées)
- Tour, Voleur : pente des monstres 0,559 → 0,545 (étage 20 dans 2,5 % des montées)
- Tour, Voleur : facteur des monstres 0,953 → 0,948 (étage 10 dans 43,0 % des montées)
- Tour, Prêtre : pente des monstres 0,887 → 0,876 (étage 20 dans 2,5 % des montées)
- Tour, Prêtre : facteur des monstres 1,052 → 1,046 (étage 10 dans 43,0 % des montées)
- Tour, Alchimiste : pente des monstres 1,076 → 1,057 (étage 20 dans 4,0 % des montées)
- Tour, Alchimiste : facteur des monstres 1,011 → 1,006 (étage 10 dans 39,5 % des montées)
- Tour, Invocateur : facteur des monstres 0,925 → 0,930 (étage 10 dans 54,5 % des montées)
- Tour, Barde : pente des monstres 1,356 → 1,347 (étage 20 dans 5,0 % des montées)
- Tour, Barde : facteur des monstres 0,749 → 0,742 (étage 10 dans 39,5 % des montées)
- Tour, Diplomate : facteur des monstres 1,238 → 1,259 (étage 10 dans 66,0 % des montées)
- Tour, Pugiliste : pente des monstres 0,984 → 0,967 (étage 20 dans 4,0 % des montées)
- Tour, Pugiliste : facteur des monstres 0,913 → 0,914 (étage 10 dans 51,5 % des montées)

## Passe 39 (graines à partir de 3900118)

**1 critères tenus sur 6.** 50000 combats de duel (médiane 10 tours), 0 combats non finis.

### Les six critères (section 11.2)

- ❌ **1. Chaque classe entre 47 % et 53 % de victoires** : mage 56,1 %, pretre 34,8 %
- ❌ **2. Aucune case de la matrice hors de 40 % – 60 %** : guerrier contre archer 60,6 %, guerrier contre pugiliste 60,6 %, mage contre pretre 78,2 %, mage contre alchimiste 60,4 %, mage contre barde 60,8 %, voleur contre pretre 66,4 %, voleur contre diplomate 37,8 %, archer contre pretre 66,2 %, pretre contre mage 26,6 %, pretre contre voleur 31,0 %, pretre contre archer 32,6 %, pretre contre alchimiste 30,4 %, pretre contre invocateur 32,4 %, pretre contre barde 34,8 %, pretre contre diplomate 38,4 %, pretre contre pugiliste 30,0 %, alchimiste contre pretre 74,6 %, invocateur contre pretre 66,6 %, invocateur contre diplomate 39,2 %, barde contre pretre 64,4 %, pugiliste contre guerrier 39,2 %, pugiliste contre pretre 69,6 %
- ❌ **3. La route Réactive entre 40 % et 55 % (Ruée et Éventail : des repères, sans seuil)** : mage Réactive 56,1 %, pretre Réactive 34,8 %
- ❌ **4. Chaque voie jouée dans 15 % des combats au moins, une Clé dans 60 %** : alchimiste voie 3 12,9 %, invocateur : Clé jouée dans 59,7 % des combats
- ✅ **5. Longueur : médiane de 6 à 10 tours, 95 % finis avant le tour 20**
- ❌ **6. Tour : étage 10 dans 40 à 60 % des montées, étage 20 dans 5 à 10 %, à 5 points près entre classes** : voleur étage 20 4,5 %, pretre étage 20 4,5 %, barde étage 20 13,5 %, pugiliste étage 20 4,0 %, écart entre classes : étage 10 de 42,5 % à 57,0 %, étage 20 de 4,0 % à 13,5 %

### La matrice des classes (taux de victoire de la ligne contre la colonne)

| | Guer | Mage | Vole | Arch | Prêt | Alch | Invo | Bard | Dipl | Pugi | **Moyenne** |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 49 | 50 | 53 | 61 | 57 | 42 | 47 | 49 | 44 | 61 | **51,1 %** |
| Mage | 43 | 53 | 53 | 58 | 78 | 60 | 49 | 61 | 54 | 52 | **56,1 %** |
| Voleur | 44 | 43 | 46 | 47 | 66 | 54 | 48 | 55 | 38 | 46 | **49,0 %** |
| Archer | 44 | 44 | 55 | 51 | 66 | 56 | 55 | 54 | 51 | 46 | **52,2 %** |
| Prêtre | 41 | 27 | 31 | 33 | 50 | 30 | 32 | 35 | 38 | 30 | **34,8 %** |
| Alchimiste | 58 | 42 | 44 | 47 | 75 | 49 | 54 | 58 | 53 | 49 | **53,0 %** |
| Invocateur | 49 | 45 | 49 | 44 | 67 | 50 | 52 | 54 | 39 | 45 | **49,4 %** |
| Barde | 51 | 41 | 45 | 45 | 64 | 46 | 48 | 50 | 48 | 48 | **48,6 %** |
| Diplomate | 52 | 45 | 57 | 47 | 60 | 46 | 55 | 52 | 45 | 46 | **50,5 %** |
| Pugiliste | 39 | 47 | 51 | 52 | 70 | 51 | 46 | 52 | 50 | 50 | **50,9 %** |

### Les trois routes, l'usage des voies et la Tour, par classe

| Classe | Ruée | Éventail | Réactive | Voie 1 | Voie 2 | Voie 3 | Voie 4 | Voie 5 | Clé | Tour : étage 10 | étage 20 | étage moyen |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 45,3 % | 11,3 % | 51,1 % | 31,7 % | 58,0 % | 38,1 % | 78,6 % | 56,4 % | 93,2 % | 55,5 % | 5,5 % | 10,9 |
| Mage | 61,5 % | 30,5 % | 56,1 % | 23,6 % | 70,7 % | 16,7 % | 24,8 % | 17,6 % | 67,7 % | 49,5 % | 5,5 % | 10,0 |
| Voleur | 49,0 % | 29,0 % | 49,0 % | 34,1 % | 19,8 % | 47,5 % | 22,0 % | 37,1 % | 65,9 % | 53,5 % | 4,5 % | 10,4 |
| Archer | 62,0 % | 31,0 % | 52,2 % | 17,1 % | 31,5 % | 63,2 % | 19,8 % | 27,0 % | 63,8 % | 51,5 % | 8,0 % | 10,5 |
| Prêtre | 20,0 % | 6,5 % | 34,8 % | 28,0 % | 70,7 % | 21,1 % | 56,3 % | 62,5 % | 84,9 % | 42,5 % | 4,5 % | 9,7 |
| Alchimiste | 31,3 % | 12,8 % | 53,0 % | 49,6 % | 35,2 % | 12,9 % | 31,6 % | 67,4 % | 84,0 % | 50,0 % | 7,0 % | 10,6 |
| Invocateur | 42,8 % | 24,0 % | 49,4 % | 35,5 % | 22,3 % | 54,8 % | 30,6 % | 23,8 % | 59,7 % | 49,5 % | 10,0 % | 10,6 |
| Barde | 35,3 % | 19,5 % | 48,6 % | 35,1 % | 32,2 % | 37,6 % | 33,9 % | 60,6 % | 75,5 % | 51,0 % | 13,5 % | 11,0 |
| Diplomate | 29,0 % | 11,8 % | 50,5 % | 19,1 % | 56,8 % | 83,0 % | 33,5 % | 71,3 % | 86,7 % | 57,0 % | 9,5 % | 11,4 |
| Pugiliste | 14,2 % | 11,5 % | 50,9 % | 30,8 % | 33,1 % | 53,9 % | 79,3 % | 20,2 % | 88,7 % | 49,0 % | 4,0 % | 10,0 |

### Boutons touchés, et pourquoi

- k_classe Guerrier : 0,875 → 0,873 (51,1 % de victoires)
- k_classe Mage : 0,816 → 0,798 (56,1 % de victoires)
- k_classe Voleur : 0,812 → 0,815 (49,0 % de victoires)
- k_classe Archer : 0,841 → 0,835 (52,2 % de victoires)
- k_classe Prêtre : 0,815 → 0,837 (34,8 % de victoires)
- k_classe Alchimiste : 1,054 → 1,049 (53,0 % de victoires)
- k_classe Barde : 1,079 → 1,080 (48,6 % de victoires)
- k_classe Pugiliste : 0,954 → 0,953 (50,9 % de victoires)
- budgets de la Voie de la Foudre (Mage) : +3 % (jouée dans 16,7 % des combats)
- Tour, Guerrier : facteur des monstres 1,679 → 1,687 (étage 10 dans 55,5 % des montées)
- Tour, Voleur : pente des monstres 0,545 → 0,537 (étage 20 dans 4,5 % des montées)
- Tour, Voleur : facteur des monstres 0,948 → 0,949 (étage 10 dans 53,5 % des montées)
- Tour, Prêtre : pente des monstres 0,876 → 0,870 (étage 20 dans 4,5 % des montées)
- Tour, Prêtre : facteur des monstres 1,046 → 1,037 (étage 10 dans 42,5 % des montées)
- Tour, Invocateur : pente des monstres 1,089 → 1,096 (étage 20 dans 10,0 % des montées)
- Tour, Barde : pente des monstres 1,347 → 1,357 (étage 20 dans 13,5 % des montées)
- Tour, Diplomate : pente des monstres 1,034 → 1,044 (étage 20 dans 9,5 % des montées)
- Tour, Diplomate : facteur des monstres 1,259 → 1,267 (étage 10 dans 57,0 % des montées)
- Tour, Pugiliste : pente des monstres 0,967 → 0,950 (étage 20 dans 4,0 % des montées)

## Passe 40 (graines à partir de 4000121)

**1 critères tenus sur 6.** 50000 combats de duel (médiane 10 tours), 0 combats non finis.

### Les six critères (section 11.2)

- ❌ **1. Chaque classe entre 47 % et 53 % de victoires** : guerrier 53,1 %, mage 53,8 %, pretre 34,6 %, barde 46,1 %
- ❌ **2. Aucune case de la matrice hors de 40 % – 60 %** : guerrier contre archer 61,2 %, guerrier contre pugiliste 65,8 %, mage contre pretre 70,2 %, voleur contre pretre 62,2 %, archer contre guerrier 32,6 %, archer contre pretre 62,8 %, pretre contre guerrier 37,0 %, pretre contre mage 27,0 %, pretre contre voleur 29,2 %, pretre contre archer 39,2 %, pretre contre alchimiste 28,4 %, pretre contre invocateur 31,6 %, pretre contre barde 33,4 %, pretre contre diplomate 36,0 %, pretre contre pugiliste 35,6 %, alchimiste contre pretre 67,2 %, invocateur contre pretre 66,2 %, barde contre mage 38,2 %, barde contre voleur 39,8 %, barde contre pretre 61,8 %, diplomate contre pretre 60,4 %, pugiliste contre guerrier 33,8 %, pugiliste contre pretre 66,0 %
- ❌ **3. La route Réactive entre 40 % et 55 % (Ruée et Éventail : des repères, sans seuil)** : pretre Réactive 34,6 %
- ❌ **4. Chaque voie jouée dans 15 % des combats au moins, une Clé dans 60 %** : alchimiste voie 3 13,6 %
- ✅ **5. Longueur : médiane de 6 à 10 tours, 95 % finis avant le tour 20**
- ❌ **6. Tour : étage 10 dans 40 à 60 % des montées, étage 20 dans 5 à 10 %, à 5 points près entre classes** : mage étage 20 4,0 %, pretre étage 20 3,5 %, diplomate étage 10 63,0 %, pugiliste étage 20 4,0 %, écart entre classes : étage 10 de 45,5 % à 63,0 %, étage 20 de 3,5 % à 10,0 %

### La matrice des classes (taux de victoire de la ligne contre la colonne)

| | Guer | Mage | Vole | Arch | Prêt | Alch | Invo | Bard | Dipl | Pugi | **Moyenne** |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 50 | 54 | 56 | 61 | 59 | 42 | 47 | 49 | 47 | 66 | **53,1 %** |
| Mage | 42 | 49 | 55 | 58 | 70 | 57 | 50 | 53 | 53 | 51 | **53,8 %** |
| Voleur | 43 | 47 | 50 | 47 | 62 | 53 | 48 | 49 | 42 | 52 | **49,3 %** |
| Archer | 33 | 43 | 53 | 52 | 63 | 51 | 52 | 50 | 54 | 49 | **50,0 %** |
| Prêtre | 37 | 27 | 29 | 39 | 49 | 28 | 32 | 33 | 36 | 36 | **34,6 %** |
| Alchimiste | 58 | 41 | 42 | 44 | 67 | 52 | 50 | 58 | 53 | 53 | **51,9 %** |
| Invocateur | 52 | 47 | 51 | 48 | 66 | 51 | 50 | 50 | 44 | 53 | **51,3 %** |
| Barde | 45 | 38 | 40 | 45 | 62 | 42 | 42 | 50 | 51 | 48 | **46,1 %** |
| Diplomate | 49 | 40 | 53 | 46 | 60 | 46 | 58 | 51 | 50 | 48 | **50,2 %** |
| Pugiliste | 34 | 49 | 48 | 50 | 66 | 48 | 48 | 50 | 51 | 47 | **49,0 %** |

### Les trois routes, l'usage des voies et la Tour, par classe

| Classe | Ruée | Éventail | Réactive | Voie 1 | Voie 2 | Voie 3 | Voie 4 | Voie 5 | Clé | Tour : étage 10 | étage 20 | étage moyen |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 43,8 % | 15,3 % | 53,1 % | 33,4 % | 54,4 % | 36,3 % | 80,0 % | 56,0 % | 92,8 % | 57,5 % | 10,0 % | 11,6 |
| Mage | 57,3 % | 31,5 % | 53,8 % | 21,5 % | 62,9 % | 31,3 % | 18,5 % | 19,1 % | 66,4 % | 51,0 % | 4,0 % | 10,0 |
| Voleur | 49,3 % | 30,0 % | 49,3 % | 32,2 % | 23,0 % | 43,2 % | 30,9 % | 34,2 % | 68,0 % | 53,5 % | 6,0 % | 10,9 |
| Archer | 60,0 % | 34,8 % | 50,0 % | 19,8 % | 32,2 % | 62,5 % | 17,1 % | 25,4 % | 62,8 % | 48,5 % | 5,0 % | 10,2 |
| Prêtre | 17,0 % | 3,5 % | 34,6 % | 27,5 % | 69,0 % | 31,6 % | 57,2 % | 62,9 % | 86,1 % | 49,0 % | 3,5 % | 10,0 |
| Alchimiste | 35,3 % | 17,0 % | 51,9 % | 50,8 % | 35,1 % | 13,6 % | 29,6 % | 64,2 % | 83,3 % | 56,5 % | 5,5 % | 11,3 |
| Invocateur | 53,8 % | 27,8 % | 51,3 % | 36,0 % | 23,3 % | 50,3 % | 33,4 % | 26,6 % | 61,2 % | 50,0 % | 7,5 % | 10,5 |
| Barde | 36,5 % | 18,8 % | 46,1 % | 34,2 % | 31,5 % | 33,5 % | 32,1 % | 61,3 % | 76,3 % | 51,5 % | 9,0 % | 10,5 |
| Diplomate | 33,0 % | 13,3 % | 50,2 % | 20,3 % | 55,4 % | 83,1 % | 30,9 % | 71,8 % | 86,1 % | 63,0 % | 6,0 % | 11,6 |
| Pugiliste | 19,3 % | 8,5 % | 49,0 % | 38,8 % | 32,2 % | 51,3 % | 78,3 % | 20,1 % | 88,3 % | 45,5 % | 4,0 % | 10,0 |

### Boutons touchés, et pourquoi

- pas des k calculés ensemble : le k d'une classe change aussi le duo dont elle est l'acolyte (effets mesurés à graines égales avant la passe 40)
- k_classe Guerrier : 0,873 → 0,806 (53,1 % de victoires)
- k_classe Mage : 0,798 → 0,810 (53,8 % de victoires)
- k_classe Prêtre : 0,837 → 0,895 (34,6 % de victoires)
- k_classe Alchimiste : 1,049 → 1,024 (51,9 % de victoires)
- k_classe Invocateur : 0,954 → 0,924 (51,3 % de victoires)
- k_classe Barde : 1,080 → 1,045 (46,1 % de victoires)
- k_classe Pugiliste : 0,953 → 0,945 (49,0 % de victoires)
- Tour, Guerrier : pente des monstres 0,755 → 0,757 (étage 20 dans 10,0 % des montées)
- Tour, Guerrier : facteur des monstres 1,687 → 1,695 (étage 10 dans 57,5 % des montées)
- Tour, Mage : pente des monstres 1,226 → 1,215 (étage 20 dans 4,0 % des montées)
- Tour, Archer : pente des monstres 1,476 → 1,466 (étage 20 dans 5,0 % des montées)
- Tour, Archer : facteur des monstres 0,637 → 0,634 (étage 10 dans 48,5 % des montées)
- Tour, Prêtre : pente des monstres 0,870 → 0,861 (étage 20 dans 3,5 % des montées)
- Tour, Prêtre : facteur des monstres 1,037 → 1,034 (étage 10 dans 49,0 % des montées)
- Tour, Alchimiste : facteur des monstres 1,006 → 1,008 (étage 10 dans 56,5 % des montées)
- Tour, Invocateur : facteur des monstres 0,930 → 0,929 (étage 10 dans 50,0 % des montées)
- Tour, Diplomate : facteur des monstres 1,267 → 1,280 (étage 10 dans 63,0 % des montées)
- Tour, Pugiliste : pente des monstres 0,950 → 0,934 (étage 20 dans 4,0 % des montées)
- Tour, Pugiliste : facteur des monstres 0,914 → 0,911 (étage 10 dans 45,5 % des montées)

## Passe 41 (graines à partir de 4100124)

**3 critères tenus sur 6.** 50000 combats de duel (médiane 10 tours), 0 combats non finis.

### Les six critères (section 11.2)

- ❌ **1. Chaque classe entre 47 % et 53 % de victoires** : guerrier 54,2 %, archer 46,7 %, alchimiste 53,1 %
- ❌ **2. Aucune case de la matrice hors de 40 % – 60 %** : guerrier contre archer 63,2 %, guerrier contre pugiliste 67,2 %, mage contre guerrier 39,4 %, archer contre guerrier 35,4 %, pugiliste contre guerrier 33,0 %
- ✅ **3. La route Réactive entre 40 % et 55 % (Ruée et Éventail : des repères, sans seuil)**
- ✅ **4. Chaque voie jouée dans 15 % des combats au moins, une Clé dans 60 %**
- ✅ **5. Longueur : médiane de 6 à 10 tours, 95 % finis avant le tour 20**
- ❌ **6. Tour : étage 10 dans 40 à 60 % des montées, étage 20 dans 5 à 10 %, à 5 points près entre classes** : guerrier étage 10 63,0 %, guerrier étage 20 14,5 %, mage étage 20 4,0 %, voleur étage 20 10,5 %, archer étage 10 38,0 %, pretre étage 20 11,5 %, invocateur étage 20 13,0 %, barde étage 20 10,5 %, diplomate étage 10 64,5 %, diplomate étage 20 10,5 %, pugiliste étage 20 13,0 %, écart entre classes : étage 10 de 38,0 % à 64,5 %, étage 20 de 4,0 % à 14,5 %

### La matrice des classes (taux de victoire de la ligne contre la colonne)

| | Guer | Mage | Vole | Arch | Prêt | Alch | Invo | Bard | Dipl | Pugi | **Moyenne** |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 50 | 60 | 57 | 63 | 49 | 41 | 53 | 53 | 49 | 67 | **54,2 %** |
| Mage | 39 | 51 | 50 | 57 | 56 | 58 | 51 | 56 | 52 | 55 | **52,4 %** |
| Voleur | 45 | 55 | 48 | 53 | 55 | 54 | 49 | 54 | 44 | 53 | **51,0 %** |
| Archer | 35 | 41 | 49 | 47 | 48 | 52 | 52 | 49 | 44 | 50 | **46,7 %** |
| Prêtre | 51 | 43 | 42 | 53 | 50 | 42 | 46 | 48 | 49 | 47 | **47,0 %** |
| Alchimiste | 59 | 46 | 44 | 51 | 59 | 55 | 53 | 60 | 49 | 56 | **53,1 %** |
| Invocateur | 49 | 49 | 46 | 52 | 56 | 42 | 44 | 50 | 41 | 55 | **48,4 %** |
| Barde | 48 | 43 | 45 | 49 | 53 | 44 | 49 | 54 | 50 | 53 | **48,7 %** |
| Diplomate | 53 | 46 | 58 | 50 | 52 | 49 | 60 | 55 | 49 | 51 | **52,3 %** |
| Pugiliste | 33 | 49 | 51 | 54 | 57 | 50 | 49 | 50 | 47 | 52 | **49,4 %** |

### Les trois routes, l'usage des voies et la Tour, par classe

| Classe | Ruée | Éventail | Réactive | Voie 1 | Voie 2 | Voie 3 | Voie 4 | Voie 5 | Clé | Tour : étage 10 | étage 20 | étage moyen |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 45,3 % | 22,5 % | 54,2 % | 39,1 % | 50,6 % | 34,4 % | 76,1 % | 60,0 % | 92,9 % | 63,0 % | 14,5 % | 12,2 |
| Mage | 53,5 % | 28,7 % | 52,4 % | 21,6 % | 60,8 % | 35,4 % | 18,7 % | 19,8 % | 67,7 % | 45,0 % | 4,0 % | 9,9 |
| Voleur | 50,2 % | 30,0 % | 51,0 % | 36,4 % | 24,7 % | 43,5 % | 26,5 % | 32,7 % | 69,0 % | 57,5 % | 10,5 % | 11,6 |
| Archer | 51,2 % | 31,5 % | 46,7 % | 19,0 % | 30,3 % | 66,5 % | 19,6 % | 23,3 % | 64,8 % | 38,0 % | 5,5 % | 9,4 |
| Prêtre | 27,5 % | 9,0 % | 47,0 % | 30,3 % | 70,7 % | 31,2 % | 57,7 % | 62,3 % | 86,1 % | 56,5 % | 11,5 % | 11,3 |
| Alchimiste | 31,5 % | 13,0 % | 53,1 % | 50,1 % | 38,6 % | 16,4 % | 31,2 % | 64,3 % | 84,7 % | 55,0 % | 7,0 % | 11,3 |
| Invocateur | 47,5 % | 23,5 % | 48,4 % | 34,4 % | 22,5 % | 54,1 % | 36,4 % | 21,1 % | 62,3 % | 57,0 % | 13,0 % | 11,8 |
| Barde | 31,0 % | 15,5 % | 48,7 % | 34,8 % | 35,3 % | 35,5 % | 32,8 % | 60,7 % | 77,3 % | 55,5 % | 10,5 % | 11,3 |
| Diplomate | 30,3 % | 11,3 % | 52,3 % | 19,6 % | 53,6 % | 83,2 % | 32,2 % | 73,6 % | 86,5 % | 64,5 % | 10,5 % | 12,1 |
| Pugiliste | 15,8 % | 10,8 % | 49,4 % | 37,5 % | 37,4 % | 57,5 % | 75,1 % | 22,6 % | 88,5 % | 59,5 % | 13,0 % | 11,7 |

### Boutons touchés, et pourquoi

- pas des k calculés ensemble : le k d'une classe change aussi le duo dont elle est l'acolyte (effets mesurés à graines égales avant la passe 40)
- k_classe Guerrier : 0,806 → 0,793 (54,2 % de victoires)
- k_classe Mage : 0,810 → 0,825 (52,4 % de victoires)
- k_classe Voleur : 0,815 → 0,815 (51,0 % de victoires)
- k_classe Archer : 0,835 → 0,874 (46,7 % de victoires)
- k_classe Prêtre : 0,895 → 0,901 (47,0 % de victoires)
- k_classe Alchimiste : 1,024 → 1,019 (53,1 % de victoires)
- k_classe Invocateur : 0,924 → 0,935 (48,4 % de victoires)
- k_classe Barde : 1,045 → 1,035 (48,7 % de victoires)
- k_classe Diplomate : 1,200 → 1,171 (52,3 % de victoires)
- k_classe Pugiliste : 0,945 → 0,956 (49,4 % de victoires)
- Tour : force des monstres au départ 0,383 → 0,385, en plus par étage 0,026 → 0,026 (étage 10 atteint dans 55,1 % des montées, étage 20 dans 10,0 %)
- Tour, Guerrier : pente des monstres 0,757 → 0,771 (étage 20 dans 14,5 % des montées)
- Tour, Guerrier : facteur des monstres 1,695 → 1,708 (étage 10 dans 63,0 % des montées)
- Tour, Mage : pente des monstres 1,215 → 1,204 (étage 20 dans 4,0 % des montées)
- Tour, Mage : facteur des monstres 0,777 → 0,769 (étage 10 dans 45,0 % des montées)
- Tour, Voleur : pente des monstres 0,537 → 0,541 (étage 20 dans 10,5 % des montées)
- Tour, Voleur : facteur des monstres 0,949 → 0,952 (étage 10 dans 57,5 % des montées)
- Tour, Archer : facteur des monstres 0,634 → 0,624 (étage 10 dans 38,0 % des montées)
- Tour, Prêtre : pente des monstres 0,861 → 0,865 (étage 20 dans 11,5 % des montées)
- Tour, Invocateur : pente des monstres 1,096 → 1,111 (étage 20 dans 13,0 % des montées)
- Tour, Barde : pente des monstres 1,357 → 1,368 (étage 20 dans 10,5 % des montées)
- Tour, Diplomate : pente des monstres 1,044 → 1,060 (étage 20 dans 10,5 % des montées)
- Tour, Diplomate : facteur des monstres 1,280 → 1,292 (étage 10 dans 64,5 % des montées)
- Tour, Pugiliste : pente des monstres 0,934 → 0,947 (étage 20 dans 13,0 % des montées)
- Tour, Pugiliste : facteur des monstres 0,911 → 0,913 (étage 10 dans 59,5 % des montées)

## Passe 42 (graines à partir de 4200127)

**2 critères tenus sur 6.** 50000 combats de duel (médiane 10 tours), 0 combats non finis.

### Les six critères (section 11.2)

- ❌ **1. Chaque classe entre 47 % et 53 % de victoires** : guerrier 53,6 %
- ❌ **2. Aucune case de la matrice hors de 40 % – 60 %** : guerrier contre mage 66,4 %, guerrier contre pugiliste 63,2 %, mage contre guerrier 38,8 %, archer contre guerrier 39,0 %, pugiliste contre guerrier 39,6 %
- ✅ **3. La route Réactive entre 40 % et 55 % (Ruée et Éventail : des repères, sans seuil)**
- ❌ **4. Chaque voie jouée dans 15 % des combats au moins, une Clé dans 60 %** : alchimiste voie 3 14,6 %
- ✅ **5. Longueur : médiane de 6 à 10 tours, 95 % finis avant le tour 20**
- ❌ **6. Tour : étage 10 dans 40 à 60 % des montées, étage 20 dans 5 à 10 %, à 5 points près entre classes** : guerrier étage 10 62,5 %, guerrier étage 20 11,5 %, archer étage 20 15,0 %, pretre étage 10 68,5 %, pretre étage 20 23,0 %, alchimiste étage 20 4,5 %, barde étage 20 10,5 %, diplomate étage 10 63,5 %, diplomate étage 20 13,0 %, pugiliste étage 20 12,5 %, écart entre classes : étage 10 de 46,0 % à 68,5 %, étage 20 de 4,5 % à 23,0 %

### La matrice des classes (taux de victoire de la ligne contre la colonne)

| | Guer | Mage | Vole | Arch | Prêt | Alch | Invo | Bard | Dipl | Pugi | **Moyenne** |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 49 | 66 | 55 | 60 | 45 | 43 | 53 | 54 | 49 | 63 | **53,6 %** |
| Mage | 39 | 53 | 49 | 50 | 48 | 51 | 50 | 50 | 52 | 45 | **48,6 %** |
| Voleur | 45 | 54 | 51 | 47 | 52 | 59 | 48 | 55 | 46 | 48 | **50,4 %** |
| Archer | 39 | 48 | 49 | 47 | 45 | 51 | 55 | 47 | 50 | 52 | **48,2 %** |
| Prêtre | 56 | 56 | 47 | 55 | 52 | 44 | 50 | 49 | 51 | 47 | **50,7 %** |
| Alchimiste | 58 | 52 | 42 | 45 | 59 | 50 | 53 | 55 | 53 | 50 | **51,6 %** |
| Invocateur | 51 | 52 | 49 | 48 | 47 | 50 | 52 | 51 | 44 | 49 | **49,3 %** |
| Barde | 47 | 52 | 43 | 48 | 55 | 46 | 47 | 48 | 55 | 48 | **49,0 %** |
| Diplomate | 50 | 42 | 53 | 44 | 45 | 46 | 52 | 47 | 52 | 45 | **47,5 %** |
| Pugiliste | 40 | 57 | 54 | 54 | 56 | 55 | 52 | 53 | 51 | 52 | **52,4 %** |

### Les trois routes, l'usage des voies et la Tour, par classe

| Classe | Ruée | Éventail | Réactive | Voie 1 | Voie 2 | Voie 3 | Voie 4 | Voie 5 | Clé | Tour : étage 10 | étage 20 | étage moyen |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 48,8 % | 21,3 % | 53,6 % | 33,8 % | 51,5 % | 38,7 % | 75,4 % | 63,9 % | 92,4 % | 62,5 % | 11,5 % | 11,9 |
| Mage | 65,3 % | 26,3 % | 48,6 % | 19,0 % | 57,2 % | 47,6 % | 17,8 % | 20,4 % | 68,9 % | 46,0 % | 9,0 % | 10,1 |
| Voleur | 48,8 % | 29,0 % | 50,4 % | 33,0 % | 22,9 % | 42,0 % | 21,0 % | 44,2 % | 66,9 % | 58,0 % | 7,5 % | 11,5 |
| Archer | 60,3 % | 27,3 % | 48,2 % | 30,7 % | 33,7 % | 56,6 % | 18,3 % | 39,1 % | 67,0 % | 52,0 % | 15,0 % | 11,3 |
| Prêtre | 28,7 % | 10,3 % | 50,7 % | 30,8 % | 63,5 % | 34,4 % | 57,2 % | 71,2 % | 86,4 % | 68,5 % | 23,0 % | 13,2 |
| Alchimiste | 43,8 % | 16,8 % | 51,6 % | 48,4 % | 30,2 % | 14,6 % | 31,4 % | 67,4 % | 83,9 % | 47,0 % | 4,5 % | 10,6 |
| Invocateur | 50,5 % | 24,8 % | 49,3 % | 38,1 % | 21,4 % | 53,9 % | 29,8 % | 21,8 % | 63,2 % | 55,0 % | 8,5 % | 11,0 |
| Barde | 35,5 % | 21,0 % | 49,0 % | 35,6 % | 33,2 % | 38,1 % | 30,6 % | 58,2 % | 76,4 % | 53,5 % | 10,5 % | 10,9 |
| Diplomate | 30,3 % | 12,0 % | 47,5 % | 20,5 % | 55,8 % | 84,2 % | 33,6 % | 71,4 % | 85,7 % | 63,5 % | 13,0 % | 12,3 |
| Pugiliste | 19,5 % | 8,3 % | 52,4 % | 34,3 % | 35,3 % | 52,1 % | 80,2 % | 19,5 % | 88,1 % | 55,0 % | 12,5 % | 11,2 |

### Boutons touchés, et pourquoi

- pas des k calculés ensemble : le k d'une classe change aussi le duo dont elle est l'acolyte (effets mesurés à graines égales avant la passe 40)
- k_classe Guerrier : 0,793 → 0,790 (53,6 % de victoires)
- k_classe Mage : 0,825 → 0,826 (48,6 % de victoires)
- k_classe Voleur : 0,815 → 0,811 (50,4 % de victoires)
- k_classe Archer : 0,874 → 0,877 (48,2 % de victoires)
- k_classe Prêtre : 0,901 → 0,879 (50,7 % de victoires)
- k_classe Alchimiste : 1,019 → 1,006 (51,6 % de victoires)
- k_classe Invocateur : 0,935 → 0,940 (49,3 % de victoires)
- k_classe Barde : 1,035 → 1,028 (49,0 % de victoires)
- k_classe Diplomate : 1,171 → 1,167 (47,5 % de victoires)
- k_classe Pugiliste : 0,956 → 0,945 (52,4 % de victoires)
- Tour : force des monstres au départ 0,385 → 0,388, en plus par étage 0,026 → 0,027 (étage 10 atteint dans 56,1 % des montées, étage 20 dans 11,5 %)
- Tour, Guerrier : pente des monstres 0,771 → 0,778 (étage 20 dans 11,5 % des montées)
- Tour, Guerrier : facteur des monstres 1,708 → 1,719 (étage 10 dans 62,5 % des montées)
- Tour, Mage : facteur des monstres 0,769 → 0,761 (étage 10 dans 46,0 % des montées)
- Tour, Archer : pente des monstres 1,466 → 1,480 (étage 20 dans 15,0 % des montées)
- Tour, Archer : facteur des monstres 0,624 → 0,621 (étage 10 dans 52,0 % des montées)
- Tour, Prêtre : pente des monstres 0,865 → 0,899 (étage 20 dans 23,0 % des montées)
- Tour, Prêtre : facteur des monstres 1,034 → 1,040 (étage 10 dans 68,5 % des montées)
- Tour, Alchimiste : pente des monstres 1,057 → 1,041 (étage 20 dans 4,5 % des montées)
- Tour, Alchimiste : facteur des monstres 1,008 → 1,004 (étage 10 dans 47,0 % des montées)
- Tour, Barde : pente des monstres 1,368 → 1,378 (étage 20 dans 10,5 % des montées)
- Tour, Barde : facteur des monstres 0,742 → 0,740 (étage 10 dans 53,5 % des montées)
- Tour, Diplomate : pente des monstres 1,060 → 1,089 (étage 20 dans 13,0 % des montées)
- Tour, Diplomate : facteur des monstres 1,292 → 1,302 (étage 10 dans 63,5 % des montées)
- Tour, Pugiliste : pente des monstres 0,947 → 0,958 (étage 20 dans 12,5 % des montées)

## Passe 43 (graines à partir de 4300130)

**3 critères tenus sur 6.** 50000 combats de duel (médiane 10 tours), 0 combats non finis.

### Les six critères (section 11.2)

- ❌ **1. Chaque classe entre 47 % et 53 % de victoires** : pugiliste 45,9 %
- ❌ **2. Aucune case de la matrice hors de 40 % – 60 %** : guerrier contre pugiliste 65,0 %, voleur contre alchimiste 65,6 %, pretre contre guerrier 60,6 %, alchimiste contre guerrier 64,4 %, alchimiste contre mage 38,2 %, alchimiste contre voleur 37,8 %, invocateur contre pugiliste 60,2 %
- ✅ **3. La route Réactive entre 40 % et 55 % (Ruée et Éventail : des repères, sans seuil)**
- ✅ **4. Chaque voie jouée dans 15 % des combats au moins, une Clé dans 60 %**
- ✅ **5. Longueur : médiane de 6 à 10 tours, 95 % finis avant le tour 20**
- ❌ **6. Tour : étage 10 dans 40 à 60 % des montées, étage 20 dans 5 à 10 %, à 5 points près entre classes** : archer étage 20 14,0 %, pretre étage 10 63,0 %, pretre étage 20 12,5 %, invocateur étage 20 15,5 %, écart entre classes : étage 10 de 45,0 % à 63,0 %, étage 20 de 6,0 % à 15,5 %

### La matrice des classes (taux de victoire de la ligne contre la colonne)

| | Guer | Mage | Vole | Arch | Prêt | Alch | Invo | Bard | Dipl | Pugi | **Moyenne** |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 51 | 51 | 48 | 56 | 41 | 42 | 42 | 44 | 44 | 65 | **48,5 %** |
| Mage | 42 | 47 | 46 | 51 | 55 | 58 | 45 | 54 | 53 | 51 | **50,3 %** |
| Voleur | 50 | 49 | 48 | 46 | 51 | 66 | 49 | 50 | 53 | 54 | **51,6 %** |
| Archer | 46 | 49 | 53 | 50 | 49 | 58 | 57 | 51 | 51 | 58 | **52,3 %** |
| Prêtre | 61 | 44 | 45 | 52 | 51 | 44 | 48 | 42 | 47 | 54 | **48,8 %** |
| Alchimiste | 64 | 38 | 38 | 40 | 55 | 51 | 45 | 56 | 50 | 52 | **48,9 %** |
| Invocateur | 59 | 50 | 50 | 48 | 53 | 59 | 50 | 51 | 47 | 60 | **52,8 %** |
| Barde | 57 | 44 | 44 | 48 | 53 | 48 | 49 | 49 | 50 | 58 | **50,2 %** |
| Diplomate | 57 | 48 | 52 | 45 | 46 | 50 | 52 | 44 | 49 | 54 | **49,8 %** |
| Pugiliste | 40 | 50 | 46 | 45 | 50 | 51 | 42 | 42 | 43 | 50 | **45,9 %** |

### Les trois routes, l'usage des voies et la Tour, par classe

| Classe | Ruée | Éventail | Réactive | Voie 1 | Voie 2 | Voie 3 | Voie 4 | Voie 5 | Clé | Tour : étage 10 | étage 20 | étage moyen |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 40,3 % | 16,3 % | 48,5 % | 37,0 % | 62,9 % | 33,7 % | 71,3 % | 61,4 % | 92,9 % | 54,0 % | 9,5 % | 10,8 |
| Mage | 57,8 % | 24,5 % | 50,3 % | 23,0 % | 55,7 % | 43,3 % | 18,7 % | 17,8 % | 65,1 % | 47,0 % | 8,0 % | 10,1 |
| Voleur | 43,0 % | 24,8 % | 51,6 % | 36,2 % | 21,9 % | 43,5 % | 24,1 % | 37,2 % | 67,6 % | 56,0 % | 7,0 % | 11,0 |
| Archer | 57,3 % | 25,3 % | 52,3 % | 36,7 % | 33,2 % | 53,1 % | 17,9 % | 30,6 % | 63,9 % | 45,0 % | 14,0 % | 10,6 |
| Prêtre | 37,3 % | 14,8 % | 48,8 % | 29,7 % | 67,0 % | 34,7 % | 59,9 % | 68,1 % | 86,0 % | 63,0 % | 12,5 % | 12,3 |
| Alchimiste | 35,5 % | 17,5 % | 48,9 % | 50,4 % | 29,3 % | 38,0 % | 32,3 % | 51,8 % | 85,4 % | 48,5 % | 6,0 % | 10,3 |
| Invocateur | 51,0 % | 23,0 % | 52,8 % | 36,4 % | 23,1 % | 50,1 % | 35,8 % | 24,8 % | 61,7 % | 58,5 % | 15,5 % | 11,9 |
| Barde | 38,5 % | 21,0 % | 50,2 % | 35,4 % | 37,5 % | 37,2 % | 32,4 % | 58,5 % | 77,3 % | 52,5 % | 10,0 % | 11,0 |
| Diplomate | 34,0 % | 15,0 % | 49,8 % | 23,6 % | 44,1 % | 83,1 % | 33,1 % | 71,4 % | 87,6 % | 54,5 % | 6,0 % | 10,8 |
| Pugiliste | 16,0 % | 7,2 % | 45,9 % | 36,1 % | 36,3 % | 59,0 % | 73,0 % | 21,2 % | 89,3 % | 52,5 % | 10,0 % | 10,8 |

### Boutons touchés, et pourquoi

- pas des k calculés ensemble : le k d'une classe change aussi le duo dont elle est l'acolyte (effets mesurés à graines égales avant la passe 40)
- k_classe Guerrier : 0,790 → 0,801 (48,5 % de victoires)
- k_classe Mage : 0,826 → 0,842 (50,3 % de victoires)
- k_classe Voleur : 0,811 → 0,802 (51,6 % de victoires)
- k_classe Archer : 0,877 → 0,881 (52,3 % de victoires)
- k_classe Prêtre : 0,879 → 0,888 (48,8 % de victoires)
- k_classe Alchimiste : 1,006 → 1,031 (48,9 % de victoires)
- k_classe Invocateur : 0,940 → 0,929 (52,8 % de victoires)
- k_classe Barde : 1,028 → 1,050 (50,2 % de victoires)
- k_classe Diplomate : 1,167 → 1,200 (49,8 % de victoires)
- k_classe Pugiliste : 0,945 → 0,964 (45,9 % de victoires)
- Tour : force des monstres au départ 0,388 → 0,390, en plus par étage 0,027 → 0,027 (étage 10 atteint dans 53,2 % des montées, étage 20 dans 9,8 %)
- Tour, Guerrier : pente des monstres 0,778 → 0,782 (étage 20 dans 9,5 % des montées)
- Tour, Mage : facteur des monstres 0,761 → 0,756 (étage 10 dans 47,0 % des montées)
- Tour, Voleur : facteur des monstres 0,952 → 0,954 (étage 10 dans 56,0 % des montées)
- Tour, Archer : pente des monstres 1,480 → 1,504 (étage 20 dans 14,0 % des montées)
- Tour, Archer : facteur des monstres 0,621 → 0,616 (étage 10 dans 45,0 % des montées)
- Tour, Prêtre : pente des monstres 0,899 → 0,910 (étage 20 dans 12,5 % des montées)
- Tour, Prêtre : facteur des monstres 1,040 → 1,050 (étage 10 dans 63,0 % des montées)
- Tour, Alchimiste : facteur des monstres 1,004 → 0,999 (étage 10 dans 48,5 % des montées)
- Tour, Invocateur : pente des monstres 1,111 → 1,133 (étage 20 dans 15,5 % des montées)
- Tour, Invocateur : facteur des monstres 0,929 → 0,932 (étage 10 dans 58,5 % des montées)
- Tour, Barde : pente des monstres 1,378 → 1,387 (étage 20 dans 10,0 % des montées)
- Tour, Pugiliste : pente des monstres 0,958 → 0,964 (étage 20 dans 10,0 % des montées)

## Passe 44 (graines à partir de 4400133)

**2 critères tenus sur 6.** 50000 combats de duel (médiane 10 tours), 0 combats non finis.

### Les six critères (section 11.2)

- ❌ **1. Chaque classe entre 47 % et 53 % de victoires** : mage 53,6 %, archer 53,9 %
- ❌ **2. Aucune case de la matrice hors de 40 % – 60 %** : guerrier contre pugiliste 64,6 %, mage contre alchimiste 60,4 %, pretre contre guerrier 60,4 %, alchimiste contre voleur 39,6 %, pugiliste contre guerrier 37,2 %
- ✅ **3. La route Réactive entre 40 % et 55 % (Ruée et Éventail : des repères, sans seuil)**
- ❌ **4. Chaque voie jouée dans 15 % des combats au moins, une Clé dans 60 %** : alchimiste voie 3 14,9 %
- ✅ **5. Longueur : médiane de 6 à 10 tours, 95 % finis avant le tour 20**
- ❌ **6. Tour : étage 10 dans 40 à 60 % des montées, étage 20 dans 5 à 10 %, à 5 points près entre classes** : guerrier étage 20 4,5 %, voleur étage 10 60,5 %, voleur étage 20 12,5 %, archer étage 20 11,5 %, pretre étage 10 61,0 %, pretre étage 20 11,5 %, invocateur étage 20 10,5 %, barde étage 20 12,0 %, écart entre classes : étage 10 de 47,5 % à 61,0 %, étage 20 de 4,5 % à 12,5 %

### La matrice des classes (taux de victoire de la ligne contre la colonne)

| | Guer | Mage | Vole | Arch | Prêt | Alch | Invo | Bard | Dipl | Pugi | **Moyenne** |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 54 | 56 | 52 | 60 | 43 | 44 | 48 | 52 | 44 | 65 | **51,6 %** |
| Mage | 51 | 50 | 51 | 51 | 54 | 60 | 56 | 54 | 53 | 55 | **53,6 %** |
| Voleur | 49 | 55 | 49 | 50 | 52 | 57 | 51 | 52 | 43 | 54 | **51,3 %** |
| Archer | 48 | 53 | 56 | 55 | 46 | 59 | 59 | 55 | 50 | 59 | **53,9 %** |
| Prêtre | 60 | 49 | 52 | 53 | 46 | 49 | 53 | 43 | 53 | 53 | **51,1 %** |
| Alchimiste | 60 | 44 | 40 | 44 | 50 | 48 | 49 | 55 | 54 | 53 | **49,5 %** |
| Invocateur | 52 | 49 | 52 | 47 | 53 | 50 | 50 | 52 | 45 | 53 | **50,4 %** |
| Barde | 54 | 45 | 49 | 50 | 48 | 48 | 51 | 49 | 53 | 53 | **49,9 %** |
| Diplomate | 57 | 47 | 56 | 51 | 48 | 49 | 59 | 49 | 54 | 51 | **52,2 %** |
| Pugiliste | 37 | 53 | 54 | 50 | 48 | 52 | 48 | 48 | 53 | 51 | **49,5 %** |

### Les trois routes, l'usage des voies et la Tour, par classe

| Classe | Ruée | Éventail | Réactive | Voie 1 | Voie 2 | Voie 3 | Voie 4 | Voie 5 | Clé | Tour : étage 10 | étage 20 | étage moyen |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 44,8 % | 15,0 % | 51,6 % | 34,4 % | 60,7 % | 34,7 % | 69,2 % | 65,5 % | 91,7 % | 52,0 % | 4,5 % | 10,5 |
| Mage | 60,0 % | 27,3 % | 53,6 % | 21,8 % | 51,5 % | 48,4 % | 19,0 % | 19,0 % | 65,4 % | 50,5 % | 9,0 % | 10,7 |
| Voleur | 57,3 % | 32,5 % | 51,3 % | 37,0 % | 19,4 % | 43,7 % | 31,1 % | 34,2 % | 67,7 % | 60,5 % | 12,5 % | 11,6 |
| Archer | 55,0 % | 31,5 % | 53,9 % | 30,7 % | 32,5 % | 53,6 % | 19,7 % | 37,6 % | 64,7 % | 52,5 % | 11,5 % | 11,1 |
| Prêtre | 35,3 % | 14,8 % | 51,1 % | 31,1 % | 62,3 % | 35,4 % | 56,9 % | 71,1 % | 85,8 % | 61,0 % | 11,5 % | 11,9 |
| Alchimiste | 33,3 % | 14,8 % | 49,5 % | 46,8 % | 33,2 % | 14,9 % | 35,2 % | 65,4 % | 83,6 % | 50,0 % | 8,5 % | 10,9 |
| Invocateur | 58,3 % | 28,2 % | 50,4 % | 35,0 % | 21,7 % | 51,9 % | 35,7 % | 20,3 % | 61,0 % | 52,0 % | 10,5 % | 11,2 |
| Barde | 44,0 % | 26,5 % | 49,9 % | 35,0 % | 33,8 % | 36,6 % | 30,8 % | 60,6 % | 75,5 % | 47,5 % | 12,0 % | 10,8 |
| Diplomate | 31,3 % | 14,8 % | 52,2 % | 18,8 % | 57,3 % | 82,9 % | 35,7 % | 73,9 % | 86,2 % | 57,5 % | 7,5 % | 10,9 |
| Pugiliste | 14,8 % | 10,8 % | 49,5 % | 38,3 % | 35,0 % | 55,6 % | 74,2 % | 20,7 % | 88,9 % | 56,5 % | 9,0 % | 11,0 |

### Boutons touchés, et pourquoi

- pas des k calculés ensemble : le k d'une classe change aussi le duo dont elle est l'acolyte (effets mesurés à graines égales avant la passe 44)
- k_classe Guerrier : 0,801 → 0,826 (51,6 % de victoires)
- k_classe Mage : 0,842 → 0,848 (53,6 % de victoires)
- k_classe Voleur : 0,802 → 0,836 (51,3 % de victoires)
- k_classe Archer : 0,881 → 0,880 (53,9 % de victoires)
- k_classe Prêtre : 0,888 → 0,904 (51,1 % de victoires)
- k_classe Alchimiste : 1,031 → 1,044 (49,5 % de victoires)
- k_classe Invocateur : 0,929 → 0,961 (50,4 % de victoires)
- k_classe Barde : 1,050 → 1,112 (49,9 % de victoires)
- k_classe Diplomate : 1,200 → 1,170 (52,2 % de victoires)
- k_classe Pugiliste : 0,964 → 0,965 (49,5 % de victoires)
- Tour : force des monstres au départ 0,390 → 0,392, en plus par étage 0,027 → 0,027 (étage 10 atteint dans 54,0 % des montées, étage 20 dans 9,7 %)
- Tour, Guerrier : pente des monstres 0,782 → 0,779 (étage 20 dans 4,5 % des montées)
- Tour, Guerrier : facteur des monstres 1,719 → 1,717 (étage 10 dans 52,0 % des montées)
- Tour, Mage : facteur des monstres 0,756 → 0,754 (étage 10 dans 50,5 % des montées)
- Tour, Voleur : pente des monstres 0,541 → 0,547 (étage 20 dans 12,5 % des montées)
- Tour, Voleur : facteur des monstres 0,954 → 0,961 (étage 10 dans 60,5 % des montées)
- Tour, Archer : pente des monstres 1,504 → 1,519 (étage 20 dans 11,5 % des montées)
- Tour, Prêtre : pente des monstres 0,910 → 0,919 (étage 20 dans 11,5 % des montées)
- Tour, Prêtre : facteur des monstres 1,050 → 1,058 (étage 10 dans 61,0 % des montées)
- Tour, Alchimiste : facteur des monstres 0,999 → 0,995 (étage 10 dans 50,0 % des montées)
- Tour, Invocateur : pente des monstres 1,133 → 1,142 (étage 20 dans 10,5 % des montées)
- Tour, Invocateur : facteur des monstres 0,932 → 0,931 (étage 10 dans 52,0 % des montées)
- Tour, Barde : pente des monstres 1,387 → 1,402 (étage 20 dans 12,0 % des montées)
- Tour, Barde : facteur des monstres 0,740 → 0,736 (étage 10 dans 47,5 % des montées)
- Tour, Diplomate : facteur des monstres 1,302 → 1,306 (étage 10 dans 57,5 % des montées)
- Tour, Pugiliste : facteur des monstres 0,913 → 0,915 (étage 10 dans 56,5 % des montées)

## Passe 45 (graines à partir de 4500136)

**2 critères tenus sur 6.** 50000 combats de duel (médiane 10 tours), 0 combats non finis.

### Les six critères (section 11.2)

- ❌ **1. Chaque classe entre 47 % et 53 % de victoires** : guerrier 53,6 %, barde 53,7 %, diplomate 46,0 %
- ❌ **2. Aucune case de la matrice hors de 40 % – 60 %** : guerrier contre mage 64,0 %, guerrier contre archer 61,8 %, guerrier contre pugiliste 60,6 %, voleur contre alchimiste 61,8 %, pretre contre diplomate 61,0 %, alchimiste contre guerrier 60,8 %, pugiliste contre guerrier 38,0 %
- ✅ **3. La route Réactive entre 40 % et 55 % (Ruée et Éventail : des repères, sans seuil)**
- ❌ **4. Chaque voie jouée dans 15 % des combats au moins, une Clé dans 60 %** : alchimiste voie 3 14,1 %
- ✅ **5. Longueur : médiane de 6 à 10 tours, 95 % finis avant le tour 20**
- ❌ **6. Tour : étage 10 dans 40 à 60 % des montées, étage 20 dans 5 à 10 %, à 5 points près entre classes** : mage étage 10 39,5 %, pretre étage 10 62,5 %, pretre étage 20 13,5 %, barde étage 20 11,0 %, diplomate étage 20 4,5 %, écart entre classes : étage 10 de 39,5 % à 62,5 %, étage 20 de 4,5 % à 13,5 %

### La matrice des classes (taux de victoire de la ligne contre la colonne)

| | Guer | Mage | Vole | Arch | Prêt | Alch | Invo | Bard | Dipl | Pugi | **Moyenne** |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 48 | 64 | 58 | 62 | 48 | 44 | 50 | 48 | 54 | 61 | **53,6 %** |
| Mage | 40 | 51 | 52 | 55 | 55 | 59 | 51 | 49 | 57 | 47 | **51,6 %** |
| Voleur | 50 | 51 | 52 | 48 | 57 | 62 | 51 | 54 | 51 | 47 | **52,2 %** |
| Archer | 42 | 48 | 55 | 50 | 45 | 57 | 56 | 53 | 55 | 46 | **50,6 %** |
| Prêtre | 55 | 51 | 53 | 54 | 55 | 46 | 53 | 50 | 61 | 47 | **52,4 %** |
| Alchimiste | 61 | 48 | 44 | 42 | 54 | 50 | 49 | 54 | 56 | 51 | **50,9 %** |
| Invocateur | 53 | 52 | 49 | 47 | 55 | 53 | 51 | 52 | 49 | 52 | **51,4 %** |
| Barde | 60 | 52 | 53 | 54 | 54 | 46 | 52 | 52 | 59 | 54 | **53,7 %** |
| Diplomate | 46 | 43 | 47 | 48 | 43 | 45 | 50 | 44 | 51 | 43 | **46,0 %** |
| Pugiliste | 38 | 52 | 49 | 50 | 53 | 53 | 49 | 49 | 58 | 50 | **50,0 %** |

### Les trois routes, l'usage des voies et la Tour, par classe

| Classe | Ruée | Éventail | Réactive | Voie 1 | Voie 2 | Voie 3 | Voie 4 | Voie 5 | Clé | Tour : étage 10 | étage 20 | étage moyen |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 46,3 % | 19,3 % | 53,6 % | 32,5 % | 46,3 % | 31,2 % | 84,0 % | 58,8 % | 93,1 % | 57,0 % | 8,5 % | 11,1 |
| Mage | 49,8 % | 22,3 % | 51,6 % | 23,9 % | 56,0 % | 43,8 % | 17,4 % | 18,7 % | 68,9 % | 39,5 % | 6,0 % | 9,3 |
| Voleur | 47,5 % | 26,3 % | 52,2 % | 36,1 % | 19,7 % | 44,4 % | 32,3 % | 32,8 % | 69,8 % | 54,5 % | 5,5 % | 10,5 |
| Archer | 50,2 % | 25,5 % | 50,6 % | 38,4 % | 32,8 % | 52,8 % | 18,1 % | 29,5 % | 65,9 % | 44,0 % | 8,5 % | 9,9 |
| Prêtre | 32,5 % | 10,3 % | 52,4 % | 31,9 % | 66,9 % | 26,5 % | 54,5 % | 65,2 % | 84,5 % | 62,5 % | 13,5 % | 12,0 |
| Alchimiste | 34,5 % | 16,3 % | 50,9 % | 49,3 % | 31,8 % | 14,1 % | 32,3 % | 64,4 % | 82,6 % | 44,5 % | 5,0 % | 10,4 |
| Invocateur | 51,5 % | 27,0 % | 51,4 % | 32,2 % | 24,6 % | 51,2 % | 37,8 % | 24,3 % | 62,9 % | 52,5 % | 9,5 % | 10,7 |
| Barde | 36,5 % | 21,3 % | 53,7 % | 37,7 % | 29,6 % | 33,5 % | 34,3 % | 61,4 % | 75,8 % | 51,0 % | 11,0 % | 11,1 |
| Diplomate | 25,8 % | 8,5 % | 46,0 % | 24,6 % | 55,0 % | 83,2 % | 32,1 % | 71,3 % | 85,9 % | 52,0 % | 4,5 % | 10,2 |
| Pugiliste | 18,3 % | 8,8 % | 50,0 % | 38,7 % | 35,1 % | 53,4 % | 76,4 % | 20,5 % | 87,8 % | 51,5 % | 7,5 % | 10,9 |

### Boutons touchés, et pourquoi

- pas des k calculés ensemble : le k d'une classe change aussi le duo dont elle est l'acolyte (effets mesurés à graines égales avant la passe 44)
- k_classe Guerrier : 0,826 → 0,863 (53,6 % de victoires)
- k_classe Mage : 0,848 → 0,889 (51,6 % de victoires)
- k_classe Voleur : 0,836 → 0,863 (52,2 % de victoires)
- k_classe Archer : 0,880 → 0,886 (50,6 % de victoires)
- k_classe Prêtre : 0,904 → 0,879 (52,4 % de victoires)
- k_classe Alchimiste : 1,044 → 1,067 (50,9 % de victoires)
- k_classe Invocateur : 0,961 → 0,989 (51,4 % de victoires)
- k_classe Barde : 1,112 → 1,153 (53,7 % de victoires)
- k_classe Diplomate : 1,170 → 1,188 (46,0 % de victoires)
- k_classe Pugiliste : 0,965 → 0,976 (50,0 % de victoires)
- Tour, Guerrier : facteur des monstres 1,717 → 1,723 (étage 10 dans 57,0 % des montées)
- Tour, Mage : facteur des monstres 0,754 → 0,745 (étage 10 dans 39,5 % des montées)
- Tour, Voleur : facteur des monstres 0,961 → 0,964 (étage 10 dans 54,5 % des montées)
- Tour, Archer : facteur des monstres 0,616 → 0,612 (étage 10 dans 44,0 % des montées)
- Tour, Prêtre : pente des monstres 0,919 → 0,933 (étage 20 dans 13,5 % des montées)
- Tour, Prêtre : facteur des monstres 1,058 → 1,070 (étage 10 dans 62,5 % des montées)
- Tour, Alchimiste : pente des monstres 1,041 → 1,028 (étage 20 dans 5,0 % des montées)
- Tour, Alchimiste : facteur des monstres 0,995 → 0,989 (étage 10 dans 44,5 % des montées)
- Tour, Invocateur : pente des monstres 1,142 → 1,147 (étage 20 dans 9,5 % des montées)
- Tour, Barde : pente des monstres 1,402 → 1,415 (étage 20 dans 11,0 % des montées)
- Tour, Diplomate : pente des monstres 1,089 → 1,081 (étage 20 dans 4,5 % des montées)

## Passe 46 (graines à partir de 4600139)

**1 critères tenus sur 6.** 50000 combats de duel (médiane 9 tours), 0 combats non finis.

### Les six critères (section 11.2)

- ❌ **1. Chaque classe entre 47 % et 53 % de victoires** : diplomate 55,0 %
- ❌ **2. Aucune case de la matrice hors de 40 % – 60 %** : guerrier contre alchimiste 39,0 %, voleur contre diplomate 38,0 %, invocateur contre diplomate 39,0 %, diplomate contre voleur 60,2 %, diplomate contre invocateur 61,8 %
- ❌ **3. La route Réactive entre 40 % et 55 % (Ruée et Éventail : des repères, sans seuil)** : diplomate Réactive 55,0 %
- ❌ **4. Chaque voie jouée dans 15 % des combats au moins, une Clé dans 60 %** : alchimiste voie 3 11,4 %
- ✅ **5. Longueur : médiane de 6 à 10 tours, 95 % finis avant le tour 20**
- ❌ **6. Tour : étage 10 dans 40 à 60 % des montées, étage 20 dans 5 à 10 %, à 5 points près entre classes** : voleur étage 10 62,0 %, voleur étage 20 4,0 %, barde étage 20 12,5 %, écart entre classes : étage 10 de 49,0 % à 62,0 %, étage 20 de 4,0 % à 12,5 %

### La matrice des classes (taux de victoire de la ligne contre la colonne)

| | Guer | Mage | Vole | Arch | Prêt | Alch | Invo | Bard | Dipl | Pugi | **Moyenne** |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 52 | 57 | 48 | 59 | 47 | 39 | 42 | 43 | 51 | 59 | **49,8 %** |
| Mage | 41 | 50 | 51 | 49 | 52 | 56 | 50 | 46 | 44 | 49 | **48,8 %** |
| Voleur | 51 | 49 | 48 | 49 | 51 | 53 | 50 | 49 | 38 | 48 | **48,7 %** |
| Archer | 43 | 51 | 54 | 53 | 45 | 51 | 52 | 47 | 45 | 46 | **48,7 %** |
| Prêtre | 52 | 47 | 48 | 56 | 51 | 44 | 47 | 41 | 47 | 47 | **48,1 %** |
| Alchimiste | 58 | 43 | 44 | 48 | 52 | 45 | 49 | 51 | 44 | 45 | **48,0 %** |
| Invocateur | 57 | 54 | 49 | 53 | 50 | 48 | 50 | 49 | 39 | 47 | **49,8 %** |
| Barde | 58 | 47 | 50 | 52 | 53 | 42 | 50 | 45 | 40 | 45 | **48,0 %** |
| Diplomate | 51 | 54 | 60 | 55 | 50 | 56 | 62 | 56 | 49 | 58 | **55,0 %** |
| Pugiliste | 45 | 52 | 51 | 49 | 51 | 51 | 48 | 49 | 41 | 50 | **48,7 %** |

### Les trois routes, l'usage des voies et la Tour, par classe

| Classe | Ruée | Éventail | Réactive | Voie 1 | Voie 2 | Voie 3 | Voie 4 | Voie 5 | Clé | Tour : étage 10 | étage 20 | étage moyen |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 46,3 % | 13,0 % | 49,8 % | 36,2 % | 51,2 % | 41,4 % | 76,6 % | 56,7 % | 93,7 % | 55,0 % | 8,0 % | 10,7 |
| Mage | 61,0 % | 21,5 % | 48,8 % | 25,0 % | 46,2 % | 47,4 % | 28,7 % | 21,8 % | 67,1 % | 51,5 % | 7,0 % | 10,4 |
| Voleur | 59,3 % | 25,5 % | 48,7 % | 35,3 % | 25,7 % | 41,6 % | 24,0 % | 37,3 % | 67,4 % | 62,0 % | 4,0 % | 10,9 |
| Archer | 56,3 % | 21,3 % | 48,7 % | 32,4 % | 33,9 % | 52,8 % | 20,0 % | 39,4 % | 67,6 % | 51,5 % | 9,0 % | 10,9 |
| Prêtre | 38,0 % | 14,8 % | 48,1 % | 31,8 % | 61,0 % | 38,0 % | 52,9 % | 71,6 % | 82,4 % | 54,5 % | 5,0 % | 10,8 |
| Alchimiste | 32,3 % | 11,8 % | 48,0 % | 47,2 % | 32,5 % | 11,4 % | 31,4 % | 67,7 % | 83,1 % | 56,5 % | 6,5 % | 10,9 |
| Invocateur | 53,5 % | 23,3 % | 49,8 % | 38,3 % | 22,5 % | 30,5 % | 54,3 % | 25,7 % | 60,3 % | 52,0 % | 6,0 % | 10,5 |
| Barde | 40,5 % | 21,8 % | 48,0 % | 35,1 % | 29,7 % | 33,4 % | 34,0 % | 61,2 % | 75,8 % | 49,0 % | 12,5 % | 10,9 |
| Diplomate | 40,5 % | 14,0 % | 55,0 % | 17,6 % | 44,5 % | 75,4 % | 40,2 % | 74,2 % | 81,0 % | 55,5 % | 7,0 % | 10,5 |
| Pugiliste | 16,0 % | 7,0 % | 48,7 % | 41,3 % | 33,3 % | 47,0 % | 76,9 % | 16,8 % | 90,7 % | 49,0 % | 5,5 % | 10,5 |

### Boutons touchés, et pourquoi

- PV de toutes les classes : ×0,380 → ×0,395 des PV de la spécification (médiane 9 tours, 99,6 % finis avant le tour 20 ; on vise 10 tours)
- pas des k calculés ensemble : le k d'une classe change aussi le duo dont elle est l'acolyte (effets mesurés à graines égales avant la passe 44)
- k_classe Guerrier : 0,863 → 0,840 (49,8 % de victoires)
- k_classe Mage : 0,889 → 0,883 (48,8 % de victoires)
- k_classe Voleur : 0,863 → 0,849 (48,7 % de victoires)
- k_classe Archer : 0,886 → 0,888 (48,7 % de victoires)
- k_classe Prêtre : 0,879 → 0,880 (48,1 % de victoires)
- k_classe Invocateur : 0,989 → 0,971 (49,8 % de victoires)
- k_classe Barde : 1,153 → 1,135 (48,0 % de victoires)
- k_classe Diplomate : 1,188 → 1,167 (55,0 % de victoires)
- k_classe Pugiliste : 0,976 → 0,975 (48,7 % de victoires)
- budgets des premiers nœuds des autres voies (Pugiliste) : -3 % (la Voie du Défi, jouée dans 16,8 % des combats, commence par un état seul)
- Tour : force des monstres au départ 0,392 → 0,394, en plus par étage 0,027 → 0,027 (étage 10 atteint dans 53,6 % des montées, étage 20 dans 7,1 %)
- Tour, Mage : facteur des monstres 0,745 → 0,743 (étage 10 dans 51,5 % des montées)
- Tour, Voleur : pente des monstres 0,547 → 0,545 (étage 20 dans 4,0 % des montées)
- Tour, Voleur : facteur des monstres 0,964 → 0,972 (étage 10 dans 62,0 % des montées)
- Tour, Archer : facteur des monstres 0,612 → 0,610 (étage 10 dans 51,5 % des montées)
- Tour, Prêtre : pente des monstres 0,933 → 0,930 (étage 20 dans 5,0 % des montées)
- Tour, Alchimiste : facteur des monstres 0,989 → 0,990 (étage 10 dans 56,5 % des montées)
- Tour, Barde : pente des monstres 1,415 → 1,432 (étage 20 dans 12,5 % des montées)
- Tour, Barde : facteur des monstres 0,736 → 0,732 (étage 10 dans 49,0 % des montées)
- Tour, Pugiliste : facteur des monstres 0,915 → 0,913 (étage 10 dans 49,0 % des montées)

## Passe 47 (graines à partir de 4700142)

**2 critères tenus sur 6.** 50000 combats de duel (médiane 10 tours), 0 combats non finis.

### Les six critères (section 11.2)

- ❌ **1. Chaque classe entre 47 % et 53 % de victoires** : pugiliste 45,9 %
- ❌ **2. Aucune case de la matrice hors de 40 % – 60 %** : guerrier contre archer 60,2 %, guerrier contre alchimiste 38,4 %, guerrier contre barde 35,4 %, guerrier contre pugiliste 62,4 %, archer contre pretre 38,2 %, pretre contre alchimiste 39,8 %, alchimiste contre guerrier 65,8 %, pugiliste contre guerrier 38,8 %
- ✅ **3. La route Réactive entre 40 % et 55 % (Ruée et Éventail : des repères, sans seuil)**
- ❌ **4. Chaque voie jouée dans 15 % des combats au moins, une Clé dans 60 %** : alchimiste voie 3 11,9 %
- ✅ **5. Longueur : médiane de 6 à 10 tours, 95 % finis avant le tour 20**
- ❌ **6. Tour : étage 10 dans 40 à 60 % des montées, étage 20 dans 5 à 10 %, à 5 points près entre classes** : voleur étage 20 4,0 %, diplomate étage 20 4,5 %, écart entre classes : étage 10 de 45,0 % à 53,5 %, étage 20 de 4,0 % à 8,5 %

### La matrice des classes (taux de victoire de la ligne contre la colonne)

| | Guer | Mage | Vole | Arch | Prêt | Alch | Invo | Bard | Dipl | Pugi | **Moyenne** |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 55 | 55 | 53 | 60 | 43 | 38 | 43 | 35 | 51 | 62 | **49,6 %** |
| Mage | 49 | 50 | 54 | 52 | 46 | 52 | 48 | 47 | 53 | 52 | **50,3 %** |
| Voleur | 48 | 46 | 52 | 47 | 49 | 51 | 47 | 51 | 44 | 47 | **48,1 %** |
| Archer | 44 | 50 | 56 | 52 | 38 | 48 | 52 | 45 | 52 | 52 | **49,0 %** |
| Prêtre | 58 | 51 | 54 | 55 | 48 | 40 | 54 | 42 | 57 | 54 | **51,3 %** |
| Alchimiste | 66 | 45 | 44 | 50 | 50 | 50 | 51 | 56 | 51 | 53 | **51,5 %** |
| Invocateur | 57 | 46 | 53 | 51 | 41 | 44 | 49 | 45 | 44 | 50 | **48,1 %** |
| Barde | 59 | 47 | 51 | 51 | 54 | 41 | 51 | 49 | 51 | 54 | **50,8 %** |
| Diplomate | 50 | 46 | 57 | 50 | 44 | 41 | 52 | 42 | 48 | 50 | **48,1 %** |
| Pugiliste | 39 | 44 | 55 | 46 | 43 | 45 | 46 | 42 | 51 | 49 | **45,9 %** |

### Les trois routes, l'usage des voies et la Tour, par classe

| Classe | Ruée | Éventail | Réactive | Voie 1 | Voie 2 | Voie 3 | Voie 4 | Voie 5 | Clé | Tour : étage 10 | étage 20 | étage moyen |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 37,5 % | 11,3 % | 49,6 % | 32,9 % | 48,1 % | 34,9 % | 83,9 % | 54,9 % | 93,6 % | 45,0 % | 6,0 % | 9,8 |
| Mage | 56,8 % | 22,3 % | 50,3 % | 27,2 % | 47,0 % | 49,8 % | 23,8 % | 20,6 % | 68,7 % | 48,5 % | 5,5 % | 10,2 |
| Voleur | 43,5 % | 21,0 % | 48,1 % | 34,3 % | 23,0 % | 45,5 % | 26,3 % | 34,2 % | 70,3 % | 50,5 % | 4,0 % | 10,1 |
| Archer | 57,5 % | 23,8 % | 49,0 % | 28,8 % | 38,2 % | 52,9 % | 20,4 % | 38,1 % | 68,4 % | 52,5 % | 5,0 % | 10,6 |
| Prêtre | 36,5 % | 13,8 % | 51,3 % | 30,6 % | 62,9 % | 37,3 % | 56,5 % | 70,1 % | 85,6 % | 53,5 % | 8,5 % | 10,9 |
| Alchimiste | 27,3 % | 10,5 % | 51,5 % | 48,9 % | 34,0 % | 11,9 % | 29,5 % | 69,3 % | 85,8 % | 49,0 % | 7,5 % | 10,7 |
| Invocateur | 45,8 % | 19,3 % | 48,1 % | 35,4 % | 22,4 % | 41,1 % | 47,1 % | 24,5 % | 63,9 % | 53,5 % | 6,5 % | 10,7 |
| Barde | 39,8 % | 22,5 % | 50,8 % | 33,8 % | 28,2 % | 34,8 % | 35,6 % | 64,3 % | 77,3 % | 48,0 % | 6,0 % | 10,1 |
| Diplomate | 31,8 % | 11,5 % | 48,1 % | 21,8 % | 43,6 % | 79,7 % | 40,8 % | 72,2 % | 86,9 % | 49,0 % | 4,5 % | 10,0 |
| Pugiliste | 15,0 % | 4,5 % | 45,9 % | 36,9 % | 34,6 % | 54,0 % | 75,3 % | 20,8 % | 90,3 % | 50,0 % | 6,5 % | 10,6 |

### Boutons touchés, et pourquoi

- pas des k calculés ensemble : le k d'une classe change aussi le duo dont elle est l'acolyte (effets mesurés à graines égales avant la passe 44)
- k_classe Guerrier : 0,840 → 0,834 (49,6 % de victoires)
- k_classe Mage : 0,883 → 0,867 (50,3 % de victoires)
- k_classe Voleur : 0,849 → 0,829 (48,1 % de victoires)
- k_classe Archer : 0,888 → 0,889 (49,0 % de victoires)
- k_classe Prêtre : 0,880 → 0,884 (51,3 % de victoires)
- k_classe Alchimiste : 1,067 → 1,060 (51,5 % de victoires)
- k_classe Invocateur : 0,971 → 0,957 (48,1 % de victoires)
- k_classe Barde : 1,135 → 1,102 (50,8 % de victoires)
- k_classe Diplomate : 1,167 → 1,192 (48,1 % de victoires)
- k_classe Pugiliste : 0,975 → 0,992 (45,9 % de victoires)
- Tour, Guerrier : facteur des monstres 1,723 → 1,718 (étage 10 dans 45,0 % des montées)
- Tour, Voleur : pente des monstres 0,545 → 0,540 (étage 20 dans 4,0 % des montées)
- Tour, Archer : pente des monstres 1,519 → 1,514 (étage 20 dans 5,0 % des montées)
- Tour, Archer : facteur des monstres 0,610 → 0,611 (étage 10 dans 52,5 % des montées)
- Tour, Prêtre : facteur des monstres 1,070 → 1,074 (étage 10 dans 53,5 % des montées)
- Tour, Invocateur : facteur des monstres 0,931 → 0,932 (étage 10 dans 53,5 % des montées)
- Tour, Diplomate : pente des monstres 1,081 → 1,072 (étage 20 dans 4,5 % des montées)

## Entre les passes 47 et 48 : l'état Aveuglé (bouton 3)

La Voie des Fumées de l'Alchimiste restait jouée dans 11 à 15 % des combats (il en faut 15) alors que le bouton 2 était au bout : ses nœuds à +10 % de budget, les premiers nœuds des autres voies à −10 %. Son premier nœud, Fumée aveuglante, ne fait que poser Aveuglé : l'IA le compte au prix de l'état dans la grille. Bouton 3 : le coût d'Aveuglé passe de 70 à 80 (+14 %, dans les ±20 % permis).

- Fumée aveuglante (Alchimiste) et Jet de sable (Voleur), qui ne posent qu'Aveuglé : budget 70 → 77 (+10 %, bouton 2), pour rester dans les ±6 %.
- Brume (Alchimiste) : dégâts 48 → 38 sur tous les ennemis ; Flèche aveuglante (Archer) : dégâts 70 → 60 (même budget, l'état coûtant plus cher).
- `tools/budget.gd` : 210 nœuds vérifiés, aucun hors budget.

Le calcul des pas de k devient aussi plus prudent (amortissement 0,5 au lieu de 0,7, pas de 6 % au plus, et la moyenne des pas reste nulle : monter tous les k ensemble ne change aucun taux, seulement la durée et la Tour).

## Passe 48 (graines à partir de 4800145)

**3 critères tenus sur 6.** 50000 combats de duel (médiane 10 tours), 0 combats non finis.

### Les six critères (section 11.2)

- ❌ **1. Chaque classe entre 47 % et 53 % de victoires** : alchimiste 46,7 %, diplomate 46,7 %
- ❌ **2. Aucune case de la matrice hors de 40 % – 60 %** : voleur contre alchimiste 60,6 %, alchimiste contre voleur 37,0 %, alchimiste contre pugiliste 39,6 %, diplomate contre pugiliste 37,4 %
- ✅ **3. La route Réactive entre 40 % et 55 % (Ruée et Éventail : des repères, sans seuil)**
- ✅ **4. Chaque voie jouée dans 15 % des combats au moins, une Clé dans 60 %**
- ✅ **5. Longueur : médiane de 6 à 10 tours, 95 % finis avant le tour 20**
- ❌ **6. Tour : étage 10 dans 40 à 60 % des montées, étage 20 dans 5 à 10 %, à 5 points près entre classes** : voleur étage 10 64,5 %, diplomate étage 20 2,5 %, pugiliste étage 20 12,0 %, écart entre classes : étage 10 de 42,0 % à 64,5 %, étage 20 de 2,5 % à 12,0 %

### La matrice des classes (taux de victoire de la ligne contre la colonne)

| | Guer | Mage | Vole | Arch | Prêt | Alch | Invo | Bard | Dipl | Pugi | **Moyenne** |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 50 | 54 | 53 | 56 | 43 | 42 | 43 | 44 | 51 | 57 | **49,2 %** |
| Mage | 47 | 49 | 51 | 51 | 54 | 55 | 49 | 53 | 57 | 46 | **51,1 %** |
| Voleur | 51 | 49 | 52 | 52 | 58 | 61 | 50 | 56 | 47 | 45 | **52,0 %** |
| Archer | 40 | 47 | 52 | 47 | 45 | 56 | 50 | 50 | 52 | 44 | **48,2 %** |
| Prêtre | 57 | 44 | 51 | 55 | 54 | 42 | 51 | 48 | 57 | 43 | **50,0 %** |
| Alchimiste | 56 | 42 | 37 | 42 | 56 | 50 | 43 | 49 | 52 | 40 | **46,7 %** |
| Invocateur | 56 | 51 | 52 | 46 | 50 | 52 | 50 | 51 | 47 | 44 | **50,0 %** |
| Barde | 55 | 49 | 47 | 52 | 57 | 46 | 52 | 53 | 56 | 48 | **51,4 %** |
| Diplomate | 55 | 42 | 51 | 44 | 47 | 44 | 52 | 44 | 49 | 37 | **46,7 %** |
| Pugiliste | 43 | 55 | 57 | 51 | 58 | 57 | 51 | 51 | 55 | 49 | **52,6 %** |

### Les trois routes, l'usage des voies et la Tour, par classe

| Classe | Ruée | Éventail | Réactive | Voie 1 | Voie 2 | Voie 3 | Voie 4 | Voie 5 | Clé | Tour : étage 10 | étage 20 | étage moyen |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 42,0 % | 15,3 % | 49,2 % | 43,0 % | 52,6 % | 32,9 % | 74,3 % | 58,4 % | 92,0 % | 56,5 % | 9,5 % | 11,4 |
| Mage | 60,0 % | 25,0 % | 51,1 % | 24,1 % | 51,6 % | 49,6 % | 17,6 % | 21,6 % | 69,4 % | 53,5 % | 10,0 % | 10,7 |
| Voleur | 47,5 % | 27,3 % | 52,0 % | 35,3 % | 20,2 % | 48,9 % | 18,1 % | 39,8 % | 69,1 % | 64,5 % | 6,0 % | 11,2 |
| Archer | 54,8 % | 28,7 % | 48,2 % | 31,7 % | 34,0 % | 55,9 % | 18,7 % | 38,7 % | 68,8 % | 48,5 % | 7,0 % | 10,7 |
| Prêtre | 28,2 % | 9,8 % | 50,0 % | 30,9 % | 59,5 % | 37,9 % | 58,9 % | 70,6 % | 85,9 % | 54,5 % | 9,5 % | 11,3 |
| Alchimiste | 30,8 % | 17,5 % | 46,7 % | 40,1 % | 29,8 % | 46,4 % | 23,8 % | 58,3 % | 86,4 % | 42,0 % | 7,5 % | 10,1 |
| Invocateur | 51,7 % | 25,3 % | 50,0 % | 34,5 % | 25,1 % | 52,3 % | 35,7 % | 23,9 % | 65,1 % | 45,0 % | 6,5 % | 10,4 |
| Barde | 35,0 % | 19,3 % | 51,4 % | 38,6 % | 31,0 % | 36,7 % | 35,8 % | 59,0 % | 77,5 % | 47,0 % | 9,0 % | 10,6 |
| Diplomate | 21,8 % | 7,5 % | 46,7 % | 18,7 % | 55,6 % | 83,5 % | 35,4 % | 73,4 % | 86,7 % | 55,0 % | 2,5 % | 10,6 |
| Pugiliste | 22,3 % | 10,0 % | 52,6 % | 43,2 % | 34,2 % | 48,3 % | 75,3 % | 21,5 % | 88,9 % | 47,0 % | 12,0 % | 11,0 |

### Boutons touchés, et pourquoi

- pas des k calculés ensemble : le k d'une classe change aussi le duo dont elle est l'acolyte (effets mesurés à graines égales avant la passe 48)
- k_classe Guerrier : 0,834 → 0,831 (49,2 % de victoires)
- k_classe Mage : 0,867 → 0,863 (51,1 % de victoires)
- k_classe Voleur : 0,829 → 0,827 (52,0 % de victoires)
- k_classe Archer : 0,889 → 0,894 (48,2 % de victoires)
- k_classe Prêtre : 0,884 → 0,887 (50,0 % de victoires)
- k_classe Alchimiste : 1,060 → 1,077 (46,7 % de victoires)
- k_classe Invocateur : 0,957 → 0,964 (50,0 % de victoires)
- k_classe Barde : 1,102 → 1,088 (51,4 % de victoires)
- k_classe Diplomate : 1,192 → 1,189 (46,7 % de victoires)
- k_classe Pugiliste : 0,992 → 0,985 (52,6 % de victoires)
- Tour, Guerrier : pente des monstres 0,779 → 0,781 (étage 20 dans 9,5 % des montées)
- Tour, Guerrier : facteur des monstres 1,718 → 1,723 (étage 10 dans 56,5 % des montées)
- Tour, Mage : pente des monstres 1,204 → 1,208 (étage 20 dans 10,0 % des montées)
- Tour, Mage : facteur des monstres 0,743 → 0,744 (étage 10 dans 53,5 % des montées)
- Tour, Voleur : facteur des monstres 0,972 → 0,985 (étage 10 dans 64,5 % des montées)
- Tour, Archer : facteur des monstres 0,611 → 0,610 (étage 10 dans 48,5 % des montées)
- Tour, Prêtre : pente des monstres 0,930 → 0,932 (étage 20 dans 9,5 % des montées)
- Tour, Prêtre : facteur des monstres 1,074 → 1,077 (étage 10 dans 54,5 % des montées)
- Tour, Alchimiste : facteur des monstres 0,990 → 0,986 (étage 10 dans 42,0 % des montées)
- Tour, Invocateur : facteur des monstres 0,932 → 0,929 (étage 10 dans 45,0 % des montées)
- Tour, Barde : facteur des monstres 0,732 → 0,729 (étage 10 dans 47,0 % des montées)
- Tour, Diplomate : pente des monstres 1,072 → 1,059 (étage 20 dans 2,5 % des montées)
- Tour, Diplomate : facteur des monstres 1,306 → 1,311 (étage 10 dans 55,0 % des montées)
- Tour, Pugiliste : pente des monstres 0,964 → 0,975 (étage 20 dans 12,0 % des montées)
- Tour, Pugiliste : facteur des monstres 0,913 → 0,909 (étage 10 dans 47,0 % des montées)

## Passe 49 (graines à partir de 4900148)

**4 critères tenus sur 6.** 50000 combats de duel (médiane 10 tours), 0 combats non finis.

### Les six critères (section 11.2)

- ✅ **1. Chaque classe entre 47 % et 53 % de victoires**
- ❌ **2. Aucune case de la matrice hors de 40 % – 60 %** : guerrier contre alchimiste 38,2 %, voleur contre alchimiste 61,6 %, pretre contre alchimiste 39,6 %, alchimiste contre guerrier 62,4 %, alchimiste contre pretre 65,4 %
- ✅ **3. La route Réactive entre 40 % et 55 % (Ruée et Éventail : des repères, sans seuil)**
- ✅ **4. Chaque voie jouée dans 15 % des combats au moins, une Clé dans 60 %**
- ✅ **5. Longueur : médiane de 6 à 10 tours, 95 % finis avant le tour 20**
- ❌ **6. Tour : étage 10 dans 40 à 60 % des montées, étage 20 dans 5 à 10 %, à 5 points près entre classes** : voleur étage 20 4,0 %, archer étage 20 14,0 %, pretre étage 10 61,5 %, pretre étage 20 10,5 %, écart entre classes : étage 10 de 45,5 % à 61,5 %, étage 20 de 4,0 % à 14,0 %

### La matrice des classes (taux de victoire de la ligne contre la colonne)

| | Guer | Mage | Vole | Arch | Prêt | Alch | Invo | Bard | Dipl | Pugi | **Moyenne** |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 48 | 54 | 51 | 55 | 40 | 38 | 41 | 46 | 46 | 56 | **47,6 %** |
| Mage | 44 | 49 | 45 | 47 | 51 | 57 | 47 | 51 | 54 | 44 | **48,9 %** |
| Voleur | 46 | 50 | 49 | 47 | 49 | 62 | 51 | 50 | 46 | 42 | **49,2 %** |
| Archer | 41 | 47 | 52 | 48 | 49 | 57 | 52 | 51 | 55 | 43 | **49,4 %** |
| Prêtre | 56 | 53 | 50 | 54 | 54 | 40 | 51 | 46 | 57 | 46 | **50,5 %** |
| Alchimiste | 62 | 48 | 45 | 46 | 65 | 54 | 49 | 60 | 54 | 46 | **53,0 %** |
| Invocateur | 54 | 50 | 50 | 47 | 48 | 50 | 49 | 47 | 48 | 46 | **48,9 %** |
| Barde | 54 | 49 | 45 | 49 | 58 | 47 | 52 | 54 | 56 | 48 | **51,3 %** |
| Diplomate | 59 | 45 | 51 | 48 | 48 | 48 | 50 | 48 | 53 | 46 | **49,6 %** |
| Pugiliste | 42 | 49 | 54 | 50 | 54 | 54 | 49 | 48 | 58 | 50 | **50,7 %** |

### Les trois routes, l'usage des voies et la Tour, par classe

| Classe | Ruée | Éventail | Réactive | Voie 1 | Voie 2 | Voie 3 | Voie 4 | Voie 5 | Clé | Tour : étage 10 | étage 20 | étage moyen |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 42,5 % | 11,0 % | 47,6 % | 29,0 % | 62,8 % | 39,9 % | 71,2 % | 64,3 % | 91,7 % | 53,5 % | 8,0 % | 10,7 |
| Mage | 64,3 % | 23,8 % | 48,9 % | 21,1 % | 53,0 % | 50,6 % | 22,7 % | 20,2 % | 69,5 % | 53,0 % | 10,0 % | 10,9 |
| Voleur | 50,2 % | 25,8 % | 49,2 % | 36,2 % | 20,5 % | 50,2 % | 18,6 % | 37,6 % | 68,6 % | 45,5 % | 4,0 % | 9,7 |
| Archer | 59,8 % | 26,0 % | 49,4 % | 40,0 % | 31,1 % | 57,0 % | 19,6 % | 29,4 % | 67,3 % | 54,0 % | 14,0 % | 11,7 |
| Prêtre | 43,0 % | 15,0 % | 50,5 % | 31,1 % | 61,0 % | 35,9 % | 58,4 % | 73,1 % | 85,9 % | 61,5 % | 10,5 % | 11,6 |
| Alchimiste | 29,8 % | 13,5 % | 53,0 % | 38,2 % | 29,9 % | 46,9 % | 24,3 % | 62,8 % | 87,6 % | 56,0 % | 7,5 % | 11,1 |
| Invocateur | 49,0 % | 22,5 % | 48,9 % | 36,5 % | 25,4 % | 50,4 % | 35,5 % | 24,2 % | 64,0 % | 50,0 % | 7,0 % | 10,6 |
| Barde | 41,3 % | 24,8 % | 51,3 % | 34,4 % | 31,0 % | 36,3 % | 33,1 % | 64,8 % | 76,3 % | 50,0 % | 8,0 % | 10,6 |
| Diplomate | 36,0 % | 14,8 % | 49,6 % | 19,4 % | 56,4 % | 83,1 % | 38,2 % | 73,6 % | 87,0 % | 57,0 % | 8,0 % | 10,9 |
| Pugiliste | 16,0 % | 9,3 % | 50,7 % | 36,5 % | 37,4 % | 52,1 % | 78,4 % | 20,0 % | 89,8 % | 52,5 % | 9,0 % | 10,5 |

### Boutons touchés, et pourquoi

- pas des k calculés ensemble : le k d'une classe change aussi le duo dont elle est l'acolyte (effets mesurés à graines égales avant la passe 48)
- k_classe Guerrier : 0,831 → 0,840 (47,6 % de victoires)
- k_classe Mage : 0,863 → 0,859 (48,9 % de victoires)
- k_classe Voleur : 0,827 → 0,829 (49,2 % de victoires)
- k_classe Archer : 0,894 → 0,894 (49,4 % de victoires)
- k_classe Prêtre : 0,887 → 0,894 (50,5 % de victoires)
- k_classe Alchimiste : 1,077 → 1,061 (53,0 % de victoires)
- k_classe Invocateur : 0,964 → 0,969 (48,9 % de victoires)
- k_classe Barde : 1,088 → 1,082 (51,3 % de victoires)
- k_classe Diplomate : 1,189 → 1,186 (49,6 % de victoires)
- k_classe Pugiliste : 0,985 → 0,988 (50,7 % de victoires)
- Tour : force des monstres au départ 0,394 → 0,396, en plus par étage 0,027 → 0,027 (étage 10 atteint dans 53,3 % des montées, étage 20 dans 8,6 %)
- Tour, Mage : pente des monstres 1,208 → 1,216 (étage 20 dans 10,0 % des montées)
- Tour, Voleur : pente des monstres 0,540 → 0,536 (étage 20 dans 4,0 % des montées)
- Tour, Voleur : facteur des monstres 0,985 → 0,981 (étage 10 dans 45,5 % des montées)
- Tour, Archer : pente des monstres 1,514 → 1,527 (étage 20 dans 14,0 % des montées)
- Tour, Prêtre : pente des monstres 0,932 → 0,939 (étage 20 dans 10,5 % des montées)
- Tour, Prêtre : facteur des monstres 1,077 → 1,086 (étage 10 dans 61,5 % des montées)
- Tour, Alchimiste : facteur des monstres 0,986 → 0,987 (étage 10 dans 56,0 % des montées)
- Tour, Invocateur : facteur des monstres 0,929 → 0,926 (étage 10 dans 50,0 % des montées)
- Tour, Barde : facteur des monstres 0,729 → 0,727 (étage 10 dans 50,0 % des montées)
- Tour, Diplomate : facteur des monstres 1,311 → 1,316 (étage 10 dans 57,0 % des montées)

## Passe 50 (graines à partir de 5000151)

**3 critères tenus sur 6.** 50000 combats de duel (médiane 10 tours), 0 combats non finis.

### Les six critères (section 11.2)

- ❌ **1. Chaque classe entre 47 % et 53 % de victoires** : voleur 45,9 %, alchimiste 44,3 %, barde 45,8 %
- ❌ **2. Aucune case de la matrice hors de 40 % – 60 %** : guerrier contre pugiliste 63,2 %, voleur contre diplomate 39,4 %, alchimiste contre voleur 36,0 %, alchimiste contre archer 39,2 %
- ✅ **3. La route Réactive entre 40 % et 55 % (Ruée et Éventail : des repères, sans seuil)**
- ✅ **4. Chaque voie jouée dans 15 % des combats au moins, une Clé dans 60 %**
- ✅ **5. Longueur : médiane de 6 à 10 tours, 95 % finis avant le tour 20**
- ❌ **6. Tour : étage 10 dans 40 à 60 % des montées, étage 20 dans 5 à 10 %, à 5 points près entre classes** : voleur étage 20 2,5 %, pretre étage 20 11,0 %, écart entre classes : étage 10 de 42,0 % à 53,0 %, étage 20 de 2,5 % à 11,0 %

### La matrice des classes (taux de victoire de la ligne contre la colonne)

| | Guer | Mage | Vole | Arch | Prêt | Alch | Invo | Bard | Dipl | Pugi | **Moyenne** |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 52 | 57 | 53 | 58 | 42 | 43 | 47 | 46 | 50 | 63 | **51,1 %** |
| Mage | 43 | 50 | 49 | 55 | 51 | 52 | 45 | 49 | 52 | 47 | **49,2 %** |
| Voleur | 46 | 45 | 46 | 45 | 45 | 56 | 46 | 49 | 39 | 43 | **45,9 %** |
| Archer | 40 | 47 | 53 | 49 | 43 | 58 | 54 | 46 | 49 | 47 | **48,5 %** |
| Prêtre | 54 | 45 | 47 | 51 | 44 | 42 | 47 | 44 | 51 | 45 | **47,0 %** |
| Alchimiste | 51 | 42 | 36 | 39 | 51 | 47 | 41 | 46 | 48 | 42 | **44,3 %** |
| Invocateur | 52 | 50 | 51 | 47 | 47 | 53 | 48 | 52 | 44 | 51 | **49,5 %** |
| Barde | 50 | 45 | 42 | 45 | 45 | 44 | 45 | 46 | 47 | 48 | **45,8 %** |
| Diplomate | 51 | 43 | 57 | 48 | 46 | 46 | 55 | 48 | 52 | 51 | **49,6 %** |
| Pugiliste | 42 | 54 | 57 | 55 | 50 | 54 | 50 | 48 | 51 | 49 | **50,9 %** |

### Les trois routes, l'usage des voies et la Tour, par classe

| Classe | Ruée | Éventail | Réactive | Voie 1 | Voie 2 | Voie 3 | Voie 4 | Voie 5 | Clé | Tour : étage 10 | étage 20 | étage moyen |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 45,5 % | 14,5 % | 51,1 % | 31,3 % | 47,6 % | 33,4 % | 82,1 % | 58,2 % | 91,9 % | 47,0 % | 6,5 % | 10,2 |
| Mage | 53,3 % | 22,8 % | 49,2 % | 22,9 % | 53,7 % | 48,6 % | 19,3 % | 20,1 % | 70,4 % | 47,5 % | 9,0 % | 10,5 |
| Voleur | 46,3 % | 24,3 % | 45,9 % | 33,8 % | 23,7 % | 44,2 % | 17,9 % | 41,4 % | 68,2 % | 42,0 % | 2,5 % | 9,2 |
| Archer | 48,8 % | 23,3 % | 48,5 % | 36,7 % | 37,5 % | 54,2 % | 18,4 % | 29,9 % | 67,7 % | 47,0 % | 8,0 % | 10,5 |
| Prêtre | 35,3 % | 12,0 % | 47,0 % | 29,7 % | 63,5 % | 35,2 % | 55,4 % | 67,8 % | 83,8 % | 50,5 % | 11,0 % | 10,9 |
| Alchimiste | 27,0 % | 12,0 % | 44,3 % | 43,2 % | 27,1 % | 46,1 % | 22,7 % | 54,5 % | 86,8 % | 46,0 % | 5,5 % | 10,4 |
| Invocateur | 51,5 % | 23,8 % | 49,5 % | 39,3 % | 22,6 % | 40,5 % | 41,4 % | 23,6 % | 64,3 % | 49,5 % | 6,5 % | 10,4 |
| Barde | 43,5 % | 23,3 % | 45,8 % | 37,0 % | 32,2 % | 32,3 % | 30,0 % | 60,7 % | 75,9 % | 49,5 % | 7,5 % | 10,5 |
| Diplomate | 31,3 % | 13,3 % | 49,6 % | 18,7 % | 55,6 % | 81,6 % | 42,0 % | 70,0 % | 84,5 % | 53,0 % | 7,0 % | 10,6 |
| Pugiliste | 14,5 % | 6,8 % | 50,9 % | 38,8 % | 32,2 % | 47,4 % | 78,8 % | 19,8 % | 89,2 % | 46,0 % | 5,0 % | 9,8 |

### Boutons touchés, et pourquoi

- pas des k calculés ensemble : le k d'une classe change aussi le duo dont elle est l'acolyte (effets mesurés à graines égales avant la passe 48)
- k_classe Guerrier : 0,840 → 0,826 (51,1 % de victoires)
- k_classe Mage : 0,859 → 0,865 (49,2 % de victoires)
- k_classe Voleur : 0,829 → 0,853 (45,9 % de victoires)
- k_classe Archer : 0,894 → 0,896 (48,5 % de victoires)
- k_classe Prêtre : 0,894 → 0,885 (47,0 % de victoires)
- k_classe Alchimiste : 1,061 → 1,063 (44,3 % de victoires)
- k_classe Invocateur : 0,969 → 0,963 (49,5 % de victoires)
- k_classe Barde : 1,082 → 1,083 (45,8 % de victoires)
- k_classe Pugiliste : 0,988 → 0,979 (50,9 % de victoires)
- Tour, Voleur : pente des monstres 0,536 → 0,529 (étage 20 dans 2,5 % des montées)
- Tour, Voleur : facteur des monstres 0,981 → 0,975 (étage 10 dans 42,0 % des montées)
- Tour, Prêtre : pente des monstres 0,939 → 0,947 (étage 20 dans 11,0 % des montées)
- Tour, Prêtre : facteur des monstres 1,086 → 1,089 (étage 10 dans 50,5 % des montées)
- Tour, Diplomate : facteur des monstres 1,316 → 1,323 (étage 10 dans 53,0 % des montées)
- Tour, Pugiliste : pente des monstres 0,975 → 0,972 (étage 20 dans 5,0 % des montées)

## Entre les passes 50 et 51 : le bruit de mesure

Les mêmes données mesurées sur des graines différentes (500 combats par case) : les taux des classes bougent de 0,3 à 1,6 point (écart-type), et une passe peut tomber à 5 points du vrai taux (l'Alchimiste à 44,3 % à la passe 50, 47,6 à 51,6 % sur quatre autres jeux de graines). C'est que le Destin d'un combat est le même contre les 10 classes : une classe ne voit que 500 Destins par passe. Les cases de la matrice bougent de 2,1 points. Le régleur corrigeait donc en partie du hasard. À partir de la passe 51 : 1 500 combats par case, 1 000 montées de la Tour par classe (au lieu de 200 : l'étage 10 bougeait de ±3,5 points par classe, plus que l'écart de 5 points permis entre classes), et le bouton 2 orienté par les duels mesurés.

## Passe 51 (graines à partir de 5100154)

**3 critères tenus sur 6.** 150000 combats de duel (médiane 10 tours), 0 combats non finis.

### Les six critères (section 11.2)

- ❌ **1. Chaque classe entre 47 % et 53 % de victoires** : pugiliste 46,9 %
- ❌ **2. Aucune case de la matrice hors de 40 % – 60 %** : guerrier contre pugiliste 62,5 %, alchimiste contre pretre 61,0 %, pugiliste contre guerrier 35,7 %
- ✅ **3. La route Réactive entre 40 % et 55 % (Ruée et Éventail : des repères, sans seuil)**
- ✅ **4. Chaque voie jouée dans 15 % des combats au moins, une Clé dans 60 %**
- ✅ **5. Longueur : médiane de 6 à 10 tours, 95 % finis avant le tour 20**
- ❌ **6. Tour : étage 10 dans 40 à 60 % des montées, étage 20 dans 5 à 10 %, à 5 points près entre classes** : voleur étage 20 4,6 %, barde étage 20 11,6 %, diplomate étage 20 4,2 %, écart entre classes : étage 10 de 45,4 % à 55,9 %, étage 20 de 4,2 % à 11,6 %

### La matrice des classes (taux de victoire de la ligne contre la colonne)

| | Guer | Mage | Vole | Arch | Prêt | Alch | Invo | Bard | Dipl | Pugi | **Moyenne** |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 49 | 57 | 56 | 58 | 43 | 43 | 49 | 47 | 47 | 62 | **51,3 %** |
| Mage | 44 | 51 | 49 | 51 | 50 | 54 | 51 | 52 | 54 | 52 | **50,8 %** |
| Voleur | 50 | 54 | 51 | 48 | 51 | 58 | 51 | 54 | 48 | 52 | **51,6 %** |
| Archer | 41 | 50 | 53 | 51 | 46 | 56 | 54 | 49 | 54 | 53 | **50,7 %** |
| Prêtre | 55 | 49 | 49 | 56 | 51 | 42 | 53 | 51 | 55 | 53 | **51,4 %** |
| Alchimiste | 60 | 48 | 42 | 48 | 61 | 49 | 52 | 57 | 55 | 50 | **52,2 %** |
| Invocateur | 53 | 50 | 49 | 49 | 51 | 51 | 51 | 52 | 47 | 55 | **50,7 %** |
| Barde | 53 | 51 | 49 | 53 | 54 | 45 | 53 | 53 | 56 | 54 | **51,9 %** |
| Diplomate | 51 | 48 | 56 | 49 | 44 | 47 | 54 | 45 | 49 | 51 | **49,5 %** |
| Pugiliste | 36 | 48 | 50 | 46 | 48 | 49 | 48 | 46 | 49 | 50 | **46,9 %** |

### Les trois routes, l'usage des voies et la Tour, par classe

| Classe | Ruée | Éventail | Réactive | Voie 1 | Voie 2 | Voie 3 | Voie 4 | Voie 5 | Clé | Tour : étage 10 | étage 20 | étage moyen |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 41,0 % | 14,5 % | 51,3 % | 37,2 % | 44,0 % | 32,9 % | 80,7 % | 57,2 % | 92,7 % | 52,9 % | 7,1 % | 10,7 |
| Mage | 59,0 % | 20,0 % | 50,8 % | 24,2 % | 49,4 % | 49,0 % | 25,6 % | 21,3 % | 69,6 % | 48,2 % | 7,6 % | 10,4 |
| Voleur | 51,0 % | 24,8 % | 51,6 % | 34,2 % | 20,8 % | 48,2 % | 20,0 % | 40,0 % | 69,7 % | 55,9 % | 4,6 % | 10,4 |
| Archer | 58,3 % | 24,8 % | 50,7 % | 33,1 % | 33,0 % | 56,2 % | 19,3 % | 38,9 % | 69,0 % | 50,6 % | 9,8 % | 10,9 |
| Prêtre | 37,0 % | 13,5 % | 51,4 % | 30,2 % | 62,1 % | 38,7 % | 59,2 % | 70,5 % | 85,7 % | 55,1 % | 9,0 % | 11,2 |
| Alchimiste | 24,8 % | 14,2 % | 52,2 % | 41,6 % | 30,9 % | 46,4 % | 24,8 % | 58,1 % | 86,9 % | 45,4 % | 5,9 % | 10,2 |
| Invocateur | 54,5 % | 24,0 % | 50,7 % | 35,2 % | 25,2 % | 51,0 % | 36,1 % | 26,0 % | 65,5 % | 47,5 % | 6,7 % | 10,3 |
| Barde | 43,3 % | 22,5 % | 51,9 % | 35,7 % | 32,1 % | 35,2 % | 34,9 % | 62,9 % | 77,5 % | 52,3 % | 11,6 % | 11,0 |
| Diplomate | 26,0 % | 9,3 % | 49,5 % | 19,1 % | 56,6 % | 84,1 % | 35,1 % | 74,0 % | 87,3 % | 53,5 % | 4,2 % | 10,4 |
| Pugiliste | 19,0 % | 8,8 % | 46,9 % | 37,9 % | 33,7 % | 57,9 % | 74,8 % | 22,5 % | 89,4 % | 50,2 % | 7,1 % | 10,7 |

### Boutons touchés, et pourquoi

- pas des k calculés ensemble : le k d'une classe change aussi le duo dont elle est l'acolyte (effets mesurés à graines égales avant la passe 48)
- k_classe Guerrier : 0,826 → 0,829 (51,3 % de victoires)
- k_classe Mage : 0,865 → 0,864 (50,8 % de victoires)
- k_classe Voleur : 0,853 → 0,836 (51,6 % de victoires)
- k_classe Archer : 0,896 → 0,894 (50,7 % de victoires)
- k_classe Prêtre : 0,885 → 0,884 (51,4 % de victoires)
- k_classe Alchimiste : 1,063 → 1,068 (52,2 % de victoires)
- k_classe Invocateur : 0,963 → 0,960 (50,7 % de victoires)
- k_classe Barde : 1,083 → 1,085 (51,9 % de victoires)
- k_classe Diplomate : 1,186 → 1,198 (49,5 % de victoires)
- k_classe Pugiliste : 0,979 → 0,987 (46,9 % de victoires)
- Tour, Mage : facteur des monstres 0,744 → 0,743 (étage 10 dans 48,2 % des montées)
- Tour, Voleur : pente des monstres 0,529 → 0,525 (étage 20 dans 4,6 % des montées)
- Tour, Voleur : facteur des monstres 0,975 → 0,978 (étage 10 dans 55,9 % des montées)
- Tour, Archer : pente des monstres 1,527 → 1,536 (étage 20 dans 9,8 % des montées)
- Tour, Prêtre : facteur des monstres 1,089 → 1,093 (étage 10 dans 55,1 % des montées)
- Tour, Alchimiste : facteur des monstres 0,987 → 0,984 (étage 10 dans 45,4 % des montées)
- Tour, Invocateur : facteur des monstres 0,926 → 0,923 (étage 10 dans 47,5 % des montées)
- Tour, Barde : pente des monstres 1,432 → 1,447 (étage 20 dans 11,6 % des montées)
- Tour, Diplomate : pente des monstres 1,059 → 1,050 (étage 20 dans 4,2 % des montées)
- Tour, Diplomate : facteur des monstres 1,323 → 1,326 (étage 10 dans 53,5 % des montées)

## Passe 52 (graines à partir de 5200157)

**4 critères tenus sur 6.** 150000 combats de duel (médiane 10 tours), 0 combats non finis.

### Les six critères (section 11.2)

- ❌ **1. Chaque classe entre 47 % et 53 % de victoires** : pugiliste 53,3 %
- ✅ **2. Aucune case de la matrice hors de 40 % – 60 %**
- ✅ **3. La route Réactive entre 40 % et 55 % (Ruée et Éventail : des repères, sans seuil)**
- ✅ **4. Chaque voie jouée dans 15 % des combats au moins, une Clé dans 60 %**
- ✅ **5. Longueur : médiane de 6 à 10 tours, 95 % finis avant le tour 20**
- ❌ **6. Tour : étage 10 dans 40 à 60 % des montées, étage 20 dans 5 à 10 %, à 5 points près entre classes** : barde étage 20 12,1 %, écart entre classes : étage 10 de 49,5 % à 55,7 %, étage 20 de 5,3 % à 12,1 %

### La matrice des classes (taux de victoire de la ligne contre la colonne)

| | Guer | Mage | Vole | Arch | Prêt | Alch | Invo | Bard | Dipl | Pugi | **Moyenne** |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 51 | 56 | 53 | 59 | 46 | 41 | 49 | 48 | 46 | 56 | **50,6 %** |
| Mage | 44 | 49 | 48 | 52 | 50 | 54 | 50 | 51 | 53 | 44 | **49,5 %** |
| Voleur | 49 | 49 | 48 | 47 | 49 | 59 | 49 | 51 | 47 | 44 | **49,4 %** |
| Archer | 41 | 47 | 54 | 51 | 45 | 55 | 56 | 51 | 54 | 44 | **49,9 %** |
| Prêtre | 52 | 50 | 49 | 54 | 51 | 44 | 50 | 48 | 49 | 47 | **49,3 %** |
| Alchimiste | 57 | 48 | 43 | 43 | 58 | 48 | 47 | 54 | 50 | 43 | **49,2 %** |
| Invocateur | 51 | 50 | 54 | 49 | 50 | 52 | 49 | 50 | 46 | 48 | **50,1 %** |
| Barde | 54 | 49 | 49 | 50 | 52 | 45 | 51 | 50 | 52 | 48 | **50,0 %** |
| Diplomate | 50 | 47 | 53 | 47 | 46 | 48 | 56 | 49 | 51 | 43 | **49,1 %** |
| Pugiliste | 43 | 57 | 54 | 56 | 55 | 57 | 51 | 53 | 57 | 48 | **53,3 %** |

### Les trois routes, l'usage des voies et la Tour, par classe

| Classe | Ruée | Éventail | Réactive | Voie 1 | Voie 2 | Voie 3 | Voie 4 | Voie 5 | Clé | Tour : étage 10 | étage 20 | étage moyen |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 38,8 % | 12,5 % | 50,6 % | 34,4 % | 47,4 % | 40,2 % | 76,8 % | 58,1 % | 92,2 % | 53,8 % | 7,1 % | 10,8 |
| Mage | 58,5 % | 18,5 % | 49,5 % | 24,3 % | 49,7 % | 48,4 % | 23,5 % | 21,1 % | 68,4 % | 50,1 % | 7,4 % | 10,5 |
| Voleur | 50,0 % | 24,8 % | 49,4 % | 35,8 % | 20,7 % | 50,2 % | 26,6 % | 31,9 % | 69,4 % | 55,7 % | 5,3 % | 10,5 |
| Archer | 56,8 % | 18,3 % | 49,9 % | 38,3 % | 33,8 % | 53,9 % | 20,1 % | 29,9 % | 67,0 % | 52,5 % | 8,7 % | 11,0 |
| Prêtre | 31,3 % | 11,8 % | 49,3 % | 30,8 % | 62,3 % | 36,0 % | 57,8 % | 70,0 % | 85,1 % | 54,3 % | 7,8 % | 11,0 |
| Alchimiste | 28,2 % | 12,3 % | 49,2 % | 41,8 % | 30,3 % | 46,4 % | 24,8 % | 58,0 % | 87,0 % | 49,5 % | 8,0 % | 10,8 |
| Invocateur | 48,5 % | 22,8 % | 50,1 % | 35,1 % | 23,9 % | 50,2 % | 35,9 % | 25,0 % | 63,1 % | 50,3 % | 10,0 % | 10,7 |
| Barde | 33,3 % | 17,5 % | 50,0 % | 36,8 % | 32,7 % | 34,0 % | 35,1 % | 62,7 % | 76,5 % | 51,7 % | 12,1 % | 11,0 |
| Diplomate | 30,5 % | 8,3 % | 49,1 % | 17,2 % | 43,6 % | 81,0 % | 33,5 % | 77,3 % | 87,6 % | 53,9 % | 5,5 % | 10,5 |
| Pugiliste | 17,0 % | 4,5 % | 53,3 % | 33,2 % | 38,2 % | 48,2 % | 82,6 % | 20,6 % | 89,0 % | 50,5 % | 9,1 % | 10,7 |

### Boutons touchés, et pourquoi

- pas des k calculés ensemble : le k d'une classe change aussi le duo dont elle est l'acolyte (effets mesurés à graines égales avant la passe 52)
- k_classe Guerrier : 0,829 → 0,825 (50,6 % de victoires)
- k_classe Mage : 0,864 → 0,869 (49,5 % de victoires)
- k_classe Voleur : 0,836 → 0,848 (49,4 % de victoires)
- k_classe Archer : 0,894 → 0,896 (49,9 % de victoires)
- k_classe Prêtre : 0,884 → 0,881 (49,3 % de victoires)
- k_classe Alchimiste : 1,068 → 1,067 (49,2 % de victoires)
- k_classe Invocateur : 0,960 → 0,965 (50,1 % de victoires)
- k_classe Barde : 1,085 → 1,081 (50,0 % de victoires)
- k_classe Diplomate : 1,198 → 1,190 (49,1 % de victoires)
- k_classe Pugiliste : 0,987 → 0,980 (53,3 % de victoires)
- Tour, Mage : facteur des monstres 0,743 → 0,742 (étage 10 dans 50,1 % des montées)
- Tour, Voleur : pente des monstres 0,525 → 0,522 (étage 20 dans 5,3 % des montées)
- Tour, Voleur : facteur des monstres 0,978 → 0,981 (étage 10 dans 55,7 % des montées)
- Tour, Prêtre : facteur des monstres 1,093 → 1,095 (étage 10 dans 54,3 % des montées)
- Tour, Alchimiste : facteur des monstres 0,984 → 0,981 (étage 10 dans 49,5 % des montées)
- Tour, Invocateur : pente des monstres 1,147 → 1,155 (étage 20 dans 10,0 % des montées)
- Tour, Barde : pente des monstres 1,447 → 1,464 (étage 20 dans 12,1 % des montées)

## Passe 53 (graines à partir de 5300160)

**4 critères tenus sur 6.** 150000 combats de duel (médiane 10 tours), 0 combats non finis.

### Les six critères (section 11.2)

- ✅ **1. Chaque classe entre 47 % et 53 % de victoires**
- ❌ **2. Aucune case de la matrice hors de 40 % – 60 %** : guerrier contre pugiliste 63,0 %, pretre contre alchimiste 39,8 %, pugiliste contre guerrier 37,7 %
- ✅ **3. La route Réactive entre 40 % et 55 % (Ruée et Éventail : des repères, sans seuil)**
- ✅ **4. Chaque voie jouée dans 15 % des combats au moins, une Clé dans 60 %**
- ✅ **5. Longueur : médiane de 6 à 10 tours, 95 % finis avant le tour 20**
- ❌ **6. Tour : étage 10 dans 40 à 60 % des montées, étage 20 dans 5 à 10 %, à 5 points près entre classes** : voleur étage 20 4,0 %, diplomate étage 20 4,9 %, écart entre classes : étage 10 de 46,6 % à 53,5 %, étage 20 de 4,0 % à 9,6 %

### La matrice des classes (taux de victoire de la ligne contre la colonne)

| | Guer | Mage | Vole | Arch | Prêt | Alch | Invo | Bard | Dipl | Pugi | **Moyenne** |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 49 | 57 | 53 | 60 | 46 | 44 | 48 | 48 | 48 | 63 | **51,6 %** |
| Mage | 46 | 48 | 50 | 51 | 52 | 51 | 53 | 52 | 54 | 49 | **50,7 %** |
| Voleur | 47 | 49 | 47 | 48 | 50 | 59 | 48 | 51 | 46 | 48 | **49,3 %** |
| Archer | 41 | 47 | 52 | 48 | 46 | 52 | 53 | 50 | 51 | 50 | **49,1 %** |
| Prêtre | 53 | 48 | 49 | 55 | 51 | 40 | 50 | 49 | 51 | 51 | **49,7 %** |
| Alchimiste | 56 | 43 | 43 | 44 | 57 | 47 | 50 | 54 | 52 | 49 | **49,6 %** |
| Invocateur | 53 | 48 | 52 | 46 | 51 | 51 | 53 | 49 | 46 | 53 | **50,1 %** |
| Barde | 51 | 49 | 48 | 51 | 52 | 45 | 53 | 51 | 54 | 52 | **50,5 %** |
| Diplomate | 50 | 45 | 53 | 49 | 44 | 45 | 54 | 45 | 51 | 47 | **48,3 %** |
| Pugiliste | 38 | 51 | 52 | 51 | 51 | 52 | 51 | 47 | 51 | 49 | **49,2 %** |

### Les trois routes, l'usage des voies et la Tour, par classe

| Classe | Ruée | Éventail | Réactive | Voie 1 | Voie 2 | Voie 3 | Voie 4 | Voie 5 | Clé | Tour : étage 10 | étage 20 | étage moyen |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 37,0 % | 15,8 % | 51,6 % | 33,3 % | 43,7 % | 32,5 % | 83,2 % | 60,5 % | 92,3 % | 53,5 % | 6,5 % | 10,7 |
| Mage | 54,0 % | 19,0 % | 50,7 % | 23,6 % | 51,4 % | 50,3 % | 19,3 % | 21,0 % | 69,8 % | 50,2 % | 8,7 % | 10,4 |
| Voleur | 38,0 % | 21,0 % | 49,3 % | 33,6 % | 21,4 % | 49,7 % | 22,9 % | 36,6 % | 70,4 % | 46,6 % | 4,0 % | 9,8 |
| Archer | 42,5 % | 16,5 % | 49,1 % | 32,5 % | 35,2 % | 55,5 % | 19,0 % | 36,8 % | 68,9 % | 51,7 % | 9,3 % | 11,0 |
| Prêtre | 32,8 % | 10,5 % | 49,7 % | 31,0 % | 63,5 % | 34,3 % | 59,5 % | 68,9 % | 85,2 % | 51,6 % | 7,0 % | 10,9 |
| Alchimiste | 32,3 % | 14,8 % | 49,6 % | 41,1 % | 29,8 % | 47,1 % | 23,1 % | 59,1 % | 87,1 % | 48,7 % | 6,6 % | 10,6 |
| Invocateur | 45,5 % | 23,8 % | 50,1 % | 34,8 % | 24,1 % | 51,1 % | 34,8 % | 24,7 % | 65,0 % | 50,4 % | 9,0 % | 10,6 |
| Barde | 36,3 % | 18,0 % | 50,5 % | 36,0 % | 31,4 % | 34,3 % | 33,8 % | 62,9 % | 77,8 % | 49,7 % | 9,6 % | 10,7 |
| Diplomate | 25,0 % | 10,8 % | 48,3 % | 18,5 % | 54,7 % | 83,7 % | 34,2 % | 74,5 % | 87,4 % | 52,5 % | 4,9 % | 10,5 |
| Pugiliste | 13,8 % | 7,0 % | 49,2 % | 39,4 % | 32,4 % | 52,1 % | 76,7 % | 20,7 % | 89,3 % | 47,6 % | 6,8 % | 10,4 |

### Boutons touchés, et pourquoi

- pas des k calculés ensemble : le k d'une classe change aussi le duo dont elle est l'acolyte (effets mesurés à graines égales avant la passe 52)
- k_classe Guerrier : 0,825 → 0,821 (51,6 % de victoires)
- k_classe Mage : 0,869 → 0,870 (50,7 % de victoires)
- k_classe Voleur : 0,848 → 0,847 (49,3 % de victoires)
- k_classe Archer : 0,896 → 0,899 (49,1 % de victoires)
- k_classe Prêtre : 0,881 → 0,876 (49,7 % de victoires)
- k_classe Alchimiste : 1,067 → 1,069 (49,6 % de victoires)
- k_classe Invocateur : 0,965 → 0,962 (50,1 % de victoires)
- k_classe Barde : 1,081 → 1,077 (50,5 % de victoires)
- k_classe Diplomate : 1,190 → 1,200 (48,3 % de victoires)
- k_classe Pugiliste : 0,980 → 0,982 (49,2 % de victoires)
- Tour, Guerrier : facteur des monstres 1,723 → 1,728 (étage 10 dans 53,5 % des montées)
- Tour, Voleur : pente des monstres 0,522 → 0,518 (étage 20 dans 4,0 % des montées)
- Tour, Voleur : facteur des monstres 0,981 → 0,979 (étage 10 dans 46,6 % des montées)
- Tour, Barde : pente des monstres 1,464 → 1,471 (étage 20 dans 9,6 % des montées)
- Tour, Diplomate : pente des monstres 1,050 → 1,044 (étage 20 dans 4,9 % des montées)
- Tour, Diplomate : facteur des monstres 1,326 → 1,329 (étage 10 dans 52,5 % des montées)
- Tour, Pugiliste : facteur des monstres 0,909 → 0,907 (étage 10 dans 47,6 % des montées)

## Passe 54 (graines à partir de 5400163)

**4 critères tenus sur 6.** 150000 combats de duel (médiane 10 tours), 0 combats non finis.

### Les six critères (section 11.2)

- ✅ **1. Chaque classe entre 47 % et 53 % de victoires**
- ❌ **2. Aucune case de la matrice hors de 40 % – 60 %** : pretre contre alchimiste 37,7 %, alchimiste contre pretre 61,1 %
- ✅ **3. La route Réactive entre 40 % et 55 % (Ruée et Éventail : des repères, sans seuil)**
- ✅ **4. Chaque voie jouée dans 15 % des combats au moins, une Clé dans 60 %**
- ✅ **5. Longueur : médiane de 6 à 10 tours, 95 % finis avant le tour 20**
- ❌ **6. Tour : étage 10 dans 40 à 60 % des montées, étage 20 dans 5 à 10 %, à 5 points près entre classes** : archer étage 20 10,5 %, barde étage 20 11,0 %, écart entre classes : étage 10 de 47,1 % à 54,8 %, étage 20 de 5,2 % à 11,0 %

### La matrice des classes (taux de victoire de la ligne contre la colonne)

| | Guer | Mage | Vole | Arch | Prêt | Alch | Invo | Bard | Dipl | Pugi | **Moyenne** |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 51 | 52 | 51 | 55 | 44 | 41 | 47 | 47 | 47 | 59 | **49,3 %** |
| Mage | 46 | 51 | 50 | 49 | 58 | 55 | 54 | 55 | 55 | 46 | **51,9 %** |
| Voleur | 48 | 51 | 52 | 45 | 53 | 58 | 49 | 54 | 46 | 45 | **50,1 %** |
| Archer | 45 | 50 | 54 | 52 | 53 | 56 | 56 | 53 | 55 | 46 | **52,1 %** |
| Prêtre | 55 | 43 | 50 | 48 | 50 | 38 | 50 | 48 | 55 | 46 | **48,1 %** |
| Alchimiste | 59 | 44 | 42 | 41 | 61 | 48 | 49 | 54 | 55 | 45 | **49,7 %** |
| Invocateur | 53 | 48 | 52 | 46 | 51 | 52 | 50 | 51 | 45 | 47 | **49,6 %** |
| Barde | 53 | 45 | 52 | 48 | 54 | 47 | 52 | 51 | 54 | 49 | **50,6 %** |
| Diplomate | 54 | 45 | 55 | 44 | 47 | 45 | 56 | 46 | 50 | 48 | **49,0 %** |
| Pugiliste | 40 | 53 | 54 | 51 | 55 | 53 | 52 | 51 | 54 | 50 | **51,2 %** |

### Les trois routes, l'usage des voies et la Tour, par classe

| Classe | Ruée | Éventail | Réactive | Voie 1 | Voie 2 | Voie 3 | Voie 4 | Voie 5 | Clé | Tour : étage 10 | étage 20 | étage moyen |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 38,3 % | 13,8 % | 49,3 % | 35,0 % | 49,8 % | 39,5 % | 75,1 % | 59,1 % | 91,9 % | 51,8 % | 5,8 % | 10,5 |
| Mage | 53,5 % | 22,8 % | 51,9 % | 23,5 % | 50,4 % | 50,1 % | 18,3 % | 17,9 % | 65,8 % | 47,7 % | 7,6 % | 10,2 |
| Voleur | 47,0 % | 21,8 % | 50,1 % | 34,8 % | 22,0 % | 47,2 % | 21,6 % | 36,8 % | 67,7 % | 54,1 % | 5,5 % | 10,5 |
| Archer | 51,5 % | 22,8 % | 52,1 % | 41,2 % | 32,2 % | 48,1 % | 19,0 % | 29,7 % | 64,8 % | 51,1 % | 10,5 % | 10,9 |
| Prêtre | 32,3 % | 12,8 % | 48,1 % | 29,9 % | 66,3 % | 27,3 % | 56,3 % | 65,7 % | 83,7 % | 54,0 % | 7,4 % | 10,9 |
| Alchimiste | 29,0 % | 15,3 % | 49,7 % | 41,4 % | 30,1 % | 45,9 % | 23,4 % | 57,7 % | 86,6 % | 49,6 % | 5,6 % | 10,6 |
| Invocateur | 48,5 % | 20,3 % | 49,6 % | 36,5 % | 23,6 % | 49,6 % | 33,5 % | 24,2 % | 62,6 % | 50,2 % | 7,5 % | 10,5 |
| Barde | 31,5 % | 16,0 % | 50,6 % | 35,6 % | 29,8 % | 36,2 % | 33,7 % | 61,0 % | 76,2 % | 48,4 % | 11,0 % | 10,7 |
| Diplomate | 25,3 % | 10,3 % | 49,0 % | 18,9 % | 56,8 % | 83,2 % | 35,3 % | 73,7 % | 86,6 % | 54,8 % | 5,2 % | 10,4 |
| Pugiliste | 16,8 % | 8,0 % | 51,2 % | 40,0 % | 33,1 % | 48,5 % | 78,5 % | 18,9 % | 88,5 % | 47,1 % | 7,9 % | 10,5 |

### Boutons touchés, et pourquoi

- pas des k calculés ensemble : le k d'une classe change aussi le duo dont elle est l'acolyte (effets mesurés à graines égales avant la passe 52)
- k_classe Guerrier : 0,821 → 0,814 (49,3 % de victoires)
- k_classe Mage : 0,870 → 0,870 (51,9 % de victoires)
- k_classe Voleur : 0,847 → 0,849 (50,1 % de victoires)
- k_classe Archer : 0,899 → 0,897 (52,1 % de victoires)
- k_classe Prêtre : 0,876 → 0,884 (48,1 % de victoires)
- k_classe Alchimiste : 1,069 → 1,070 (49,7 % de victoires)
- k_classe Invocateur : 0,962 → 0,965 (49,6 % de victoires)
- k_classe Barde : 1,077 → 1,075 (50,6 % de victoires)
- k_classe Diplomate : 1,200 → 1,199 (49,0 % de victoires)
- k_classe Pugiliste : 0,982 → 0,981 (51,2 % de victoires)
- Tour, Mage : facteur des monstres 0,742 → 0,730 (étage 10 dans 47,7 % des montées)
- Tour, Voleur : facteur des monstres 0,979 → 0,987 (étage 10 dans 54,1 % des montées)
- Tour, Archer : pente des monstres 1,536 → 1,582 (étage 20 dans 10,5 % des montées)
- Tour, Prêtre : facteur des monstres 1,095 → 1,113 (étage 10 dans 54,0 % des montées)
- Tour, Barde : pente des monstres 1,471 → 1,523 (étage 20 dans 11,0 % des montées)
- Tour, Barde : facteur des monstres 0,727 → 0,718 (étage 10 dans 48,4 % des montées)
- Tour, Diplomate : pente des monstres 1,044 → 1,020 (étage 20 dans 5,2 % des montées)
- Tour, Diplomate : facteur des monstres 1,329 → 1,355 (étage 10 dans 54,8 % des montées)
- Tour, Pugiliste : facteur des monstres 0,907 → 0,890 (étage 10 dans 47,1 % des montées)

## Passe 55 (graines à partir de 5500166)

**4 critères tenus sur 6.** 150000 combats de duel (médiane 10 tours), 0 combats non finis.

### Les six critères (section 11.2)

- ✅ **1. Chaque classe entre 47 % et 53 % de victoires**
- ❌ **2. Aucune case de la matrice hors de 40 % – 60 %** : pugiliste contre guerrier 38,1 %
- ✅ **3. La route Réactive entre 40 % et 55 % (Ruée et Éventail : des repères, sans seuil)**
- ✅ **4. Chaque voie jouée dans 15 % des combats au moins, une Clé dans 60 %**
- ✅ **5. Longueur : médiane de 6 à 10 tours, 95 % finis avant le tour 20**
- ❌ **6. Tour : étage 10 dans 40 à 60 % des montées, étage 20 dans 5 à 10 %, à 5 points près entre classes** : voleur étage 20 4,2 %, diplomate étage 20 4,6 %, écart entre classes : étage 10 de 48,5 % à 54,1 %, étage 20 de 4,2 % à 10,0 %

### La matrice des classes (taux de victoire de la ligne contre la colonne)

| | Guer | Mage | Vole | Arch | Prêt | Alch | Invo | Bard | Dipl | Pugi | **Moyenne** |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 50 | 55 | 51 | 60 | 44 | 41 | 46 | 44 | 45 | 59 | **49,5 %** |
| Mage | 43 | 48 | 48 | 51 | 51 | 52 | 50 | 52 | 54 | 49 | **49,9 %** |
| Voleur | 48 | 51 | 50 | 49 | 50 | 58 | 48 | 52 | 46 | 50 | **50,1 %** |
| Archer | 42 | 49 | 52 | 51 | 46 | 53 | 53 | 50 | 51 | 49 | **49,7 %** |
| Prêtre | 58 | 52 | 50 | 53 | 49 | 41 | 53 | 47 | 53 | 50 | **50,6 %** |
| Alchimiste | 60 | 48 | 43 | 46 | 57 | 47 | 48 | 56 | 52 | 50 | **50,4 %** |
| Invocateur | 55 | 49 | 51 | 48 | 49 | 50 | 51 | 48 | 46 | 49 | **49,6 %** |
| Barde | 54 | 50 | 47 | 52 | 53 | 45 | 51 | 51 | 55 | 53 | **51,1 %** |
| Diplomate | 51 | 46 | 53 | 49 | 46 | 44 | 54 | 44 | 50 | 47 | **48,5 %** |
| Pugiliste | 38 | 50 | 52 | 51 | 49 | 51 | 48 | 48 | 50 | 50 | **48,6 %** |

### Les trois routes, l'usage des voies et la Tour, par classe

| Classe | Ruée | Éventail | Réactive | Voie 1 | Voie 2 | Voie 3 | Voie 4 | Voie 5 | Clé | Tour : étage 10 | étage 20 | étage moyen |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 43,3 % | 13,8 % | 49,5 % | 35,8 % | 44,0 % | 40,0 % | 78,1 % | 57,7 % | 92,9 % | 52,1 % | 6,2 % | 10,5 |
| Mage | 60,3 % | 19,5 % | 49,9 % | 25,1 % | 52,5 % | 46,9 % | 20,2 % | 19,5 % | 69,4 % | 48,5 % | 7,6 % | 10,4 |
| Voleur | 54,0 % | 22,5 % | 50,1 % | 34,7 % | 22,6 % | 48,1 % | 23,7 % | 35,9 % | 69,4 % | 49,2 % | 4,2 % | 10,1 |
| Archer | 58,3 % | 23,3 % | 49,7 % | 42,1 % | 32,9 % | 51,5 % | 19,6 % | 31,6 % | 67,1 % | 49,9 % | 6,7 % | 10,5 |
| Prêtre | 37,8 % | 15,5 % | 50,6 % | 30,1 % | 62,0 % | 37,9 % | 58,5 % | 69,6 % | 85,4 % | 53,8 % | 8,3 % | 11,1 |
| Alchimiste | 29,0 % | 14,2 % | 50,4 % | 44,4 % | 30,9 % | 45,6 % | 22,8 % | 56,5 % | 87,1 % | 52,3 % | 7,3 % | 10,9 |
| Invocateur | 50,0 % | 23,0 % | 49,6 % | 38,8 % | 25,0 % | 49,1 % | 32,1 % | 23,7 % | 63,9 % | 50,3 % | 6,3 % | 10,4 |
| Barde | 40,3 % | 21,0 % | 51,1 % | 35,6 % | 31,2 % | 35,7 % | 34,2 % | 61,9 % | 76,9 % | 50,0 % | 10,0 % | 10,6 |
| Diplomate | 24,0 % | 7,2 % | 48,5 % | 19,5 % | 58,3 % | 83,9 % | 35,8 % | 72,4 % | 87,4 % | 54,1 % | 4,6 % | 10,3 |
| Pugiliste | 19,8 % | 8,8 % | 48,6 % | 38,8 % | 34,2 % | 52,8 % | 76,2 % | 21,4 % | 89,2 % | 53,3 % | 7,1 % | 10,9 |

### Boutons touchés, et pourquoi

- pas des k calculés ensemble : le k d'une classe change aussi le duo dont elle est l'acolyte (effets mesurés à graines égales avant la passe 52)
- k_classe Guerrier : 0,814 → 0,819 (49,5 % de victoires)
- k_classe Mage : 0,870 → 0,866 (49,9 % de victoires)
- k_classe Voleur : 0,849 → 0,843 (50,1 % de victoires)
- k_classe Archer : 0,897 → 0,895 (49,7 % de victoires)
- k_classe Prêtre : 0,884 → 0,885 (50,6 % de victoires)
- k_classe Invocateur : 0,965 → 0,964 (49,6 % de victoires)
- k_classe Barde : 1,075 → 1,072 (51,1 % de victoires)
- k_classe Diplomate : 1,199 → 1,200 (48,5 % de victoires)
- k_classe Pugiliste : 0,981 → 0,984 (48,6 % de victoires)
- Tour, Mage : facteur des monstres 0,730 → 0,719 (étage 10 dans 48,5 % des montées)
- Tour, Voleur : pente des monstres 0,518 → 0,500 (étage 20 dans 4,2 % des montées)
- Tour, Voleur : facteur des monstres 0,987 → 0,984 (étage 10 dans 49,2 % des montées)
- Tour, Prêtre : facteur des monstres 1,113 → 1,126 (étage 10 dans 53,8 % des montées)
- Tour, Barde : pente des monstres 1,523 → 1,561 (étage 20 dans 10,0 % des montées)
- Tour, Diplomate : pente des monstres 1,020 → 0,990 (étage 20 dans 4,6 % des montées)
- Tour, Diplomate : facteur des monstres 1,355 → 1,373 (étage 10 dans 54,1 % des montées)
- duel Guerrier contre Pugiliste (60,6 %) : budgets de la Voie de la Prise (Pugiliste) +4 % (effet propre mesuré : 9,6 % pour 8 %)

## Après la passe 55 : un duel mesuré annulé

Le +4 % sur la Voie de la Prise du Pugiliste (duel Guerrier contre Pugiliste) est retiré avant la passe 56 : renforcer cette voie faisait perdre environ 10 points au Pugiliste contre tout le monde (l'IA la jouait bien plus souvent), et son effet sur le duel ne venait que de la correction de son k qui aurait suivi. Désormais, une voie qui aggrave directement le duel, ou qui déplace de plus de 3 points la moyenne d'une des deux classes, n'est pas retenue.

## Passe 56 (graines à partir de 5600169)

**3 critères tenus sur 6.** 150000 combats de duel (médiane 10 tours), 0 combats non finis.

### Les six critères (section 11.2)

- ❌ **1. Chaque classe entre 47 % et 53 % de victoires** : pugiliste 54,1 %
- ❌ **2. Aucune case de la matrice hors de 40 % – 60 %** : guerrier contre alchimiste 38,3 %, alchimiste contre guerrier 60,1 %
- ✅ **3. La route Réactive entre 40 % et 55 % (Ruée et Éventail : des repères, sans seuil)**
- ✅ **4. Chaque voie jouée dans 15 % des combats au moins, une Clé dans 60 %**
- ✅ **5. Longueur : médiane de 6 à 10 tours, 95 % finis avant le tour 20**
- ❌ **6. Tour : étage 10 dans 40 à 60 % des montées, étage 20 dans 5 à 10 %, à 5 points près entre classes** : voleur étage 20 4,2 %, diplomate étage 20 4,0 %, écart entre classes : étage 10 de 46,7 % à 53,1 %, étage 20 de 4,0 % à 9,0 %

### La matrice des classes (taux de victoire de la ligne contre la colonne)

| | Guer | Mage | Vole | Arch | Prêt | Alch | Invo | Bard | Dipl | Pugi | **Moyenne** |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 50 | 52 | 50 | 53 | 42 | 38 | 43 | 43 | 43 | 59 | **47,2 %** |
| Mage | 47 | 50 | 45 | 50 | 47 | 53 | 47 | 52 | 52 | 42 | **48,4 %** |
| Voleur | 49 | 50 | 50 | 47 | 50 | 59 | 47 | 50 | 47 | 42 | **49,1 %** |
| Archer | 41 | 49 | 50 | 48 | 44 | 54 | 51 | 48 | 49 | 43 | **47,6 %** |
| Prêtre | 58 | 51 | 47 | 58 | 50 | 41 | 51 | 46 | 55 | 46 | **50,2 %** |
| Alchimiste | 60 | 48 | 40 | 45 | 58 | 49 | 51 | 53 | 53 | 43 | **50,0 %** |
| Invocateur | 56 | 51 | 49 | 45 | 47 | 48 | 49 | 49 | 45 | 44 | **48,4 %** |
| Barde | 54 | 46 | 45 | 49 | 49 | 43 | 49 | 49 | 54 | 46 | **48,5 %** |
| Diplomate | 56 | 48 | 53 | 50 | 45 | 45 | 54 | 46 | 52 | 43 | **49,4 %** |
| Pugiliste | 42 | 58 | 55 | 57 | 54 | 59 | 56 | 56 | 55 | 49 | **54,1 %** |

### Les trois routes, l'usage des voies et la Tour, par classe

| Classe | Ruée | Éventail | Réactive | Voie 1 | Voie 2 | Voie 3 | Voie 4 | Voie 5 | Clé | Tour : étage 10 | étage 20 | étage moyen |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 46,3 % | 15,0 % | 47,2 % | 39,3 % | 52,3 % | 38,0 % | 73,4 % | 57,7 % | 92,0 % | 49,3 % | 5,8 % | 10,2 |
| Mage | 61,0 % | 22,8 % | 48,4 % | 22,9 % | 50,1 % | 50,5 % | 25,5 % | 20,8 % | 68,5 % | 46,7 % | 7,6 % | 10,3 |
| Voleur | 59,3 % | 30,8 % | 49,1 % | 35,0 % | 23,7 % | 46,9 % | 19,1 % | 39,6 % | 68,0 % | 48,7 % | 4,2 % | 9,9 |
| Archer | 58,0 % | 28,5 % | 47,6 % | 31,9 % | 34,8 % | 56,3 % | 19,3 % | 38,1 % | 68,0 % | 47,3 % | 5,1 % | 10,1 |
| Prêtre | 36,8 % | 13,5 % | 50,2 % | 30,6 % | 63,6 % | 36,4 % | 58,7 % | 69,9 % | 85,4 % | 48,4 % | 6,5 % | 10,2 |
| Alchimiste | 34,5 % | 14,0 % | 50,0 % | 40,6 % | 31,1 % | 46,5 % | 24,9 % | 57,5 % | 86,8 % | 48,3 % | 7,3 % | 10,5 |
| Invocateur | 54,8 % | 27,5 % | 48,4 % | 37,6 % | 24,7 % | 49,8 % | 35,5 % | 24,5 % | 63,8 % | 47,3 % | 9,0 % | 10,5 |
| Barde | 41,3 % | 26,5 % | 48,5 % | 36,4 % | 32,0 % | 36,2 % | 33,2 % | 62,7 % | 76,7 % | 47,0 % | 7,6 % | 10,4 |
| Diplomate | 28,5 % | 11,5 % | 49,4 % | 19,2 % | 56,2 % | 83,5 % | 34,9 % | 74,3 % | 87,4 % | 48,3 % | 4,0 % | 10,1 |
| Pugiliste | 17,0 % | 6,8 % | 54,1 % | 34,5 % | 33,8 % | 47,0 % | 84,7 % | 20,2 % | 89,7 % | 53,1 % | 7,3 % | 10,8 |

### Boutons touchés, et pourquoi

- pas des k calculés ensemble : le k d'une classe change aussi le duo dont elle est l'acolyte (effets mesurés à graines égales avant la passe 56)
- k_classe Guerrier : 0,819 → 0,826 (47,2 % de victoires)
- k_classe Mage : 0,866 → 0,867 (48,4 % de victoires)
- k_classe Voleur : 0,843 → 0,859 (49,1 % de victoires)
- k_classe Archer : 0,895 → 0,899 (47,6 % de victoires)
- k_classe Prêtre : 0,885 → 0,880 (50,2 % de victoires)
- k_classe Alchimiste : 1,070 → 1,058 (50,0 % de victoires)
- k_classe Invocateur : 0,964 → 0,975 (48,4 % de victoires)
- k_classe Barde : 1,072 → 1,076 (48,5 % de victoires)
- k_classe Diplomate : 1,200 → 1,178 (49,4 % de victoires)
- k_classe Pugiliste : 0,984 → 0,974 (54,1 % de victoires)
- Tour, Voleur : pente des monstres 0,500 → 0,484 (étage 20 dans 4,2 % des montées)
- Tour, Archer : pente des monstres 1,582 → 1,563 (étage 20 dans 5,1 % des montées)
- Tour, Diplomate : pente des monstres 0,990 → 0,955 (étage 20 dans 4,0 % des montées)
- Tour, Pugiliste : facteur des monstres 0,890 → 0,900 (étage 10 dans 53,1 % des montées)
- duel Alchimiste contre Guerrier (60,9 %) : aucune voie n'y change rien à elle seule (le plus propre : 0,7 %)

## Passe 57 (graines à partir de 5700172)

**4 critères tenus sur 6.** 150000 combats de duel (médiane 10 tours), 0 combats non finis.

### Les six critères (section 11.2)

- ✅ **1. Chaque classe entre 47 % et 53 % de victoires**
- ❌ **2. Aucune case de la matrice hors de 40 % – 60 %** : alchimiste contre pretre 60,7 %
- ✅ **3. La route Réactive entre 40 % et 55 % (Ruée et Éventail : des repères, sans seuil)**
- ✅ **4. Chaque voie jouée dans 15 % des combats au moins, une Clé dans 60 %**
- ✅ **5. Longueur : médiane de 6 à 10 tours, 95 % finis avant le tour 20**
- ❌ **6. Tour : étage 10 dans 40 à 60 % des montées, étage 20 dans 5 à 10 %, à 5 points près entre classes** : guerrier étage 20 4,8 %, mage étage 20 10,5 %, écart entre classes : étage 10 de 48,5 % à 56,0 %, étage 20 de 4,8 % à 10,5 %

### La matrice des classes (taux de victoire de la ligne contre la colonne)

| | Guer | Mage | Vole | Arch | Prêt | Alch | Invo | Bard | Dipl | Pugi | **Moyenne** |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 48 | 54 | 50 | 55 | 43 | 40 | 42 | 43 | 48 | 59 | **48,4 %** |
| Mage | 45 | 51 | 49 | 49 | 53 | 55 | 50 | 54 | 53 | 50 | **50,9 %** |
| Voleur | 47 | 52 | 51 | 49 | 52 | 58 | 45 | 52 | 44 | 50 | **50,0 %** |
| Archer | 43 | 50 | 53 | 49 | 47 | 57 | 51 | 53 | 52 | 50 | **50,4 %** |
| Prêtre | 58 | 49 | 51 | 52 | 51 | 42 | 48 | 48 | 56 | 49 | **50,4 %** |
| Alchimiste | 58 | 46 | 43 | 44 | 61 | 50 | 50 | 58 | 53 | 51 | **51,3 %** |
| Invocateur | 56 | 53 | 52 | 48 | 53 | 53 | 51 | 54 | 46 | 54 | **52,0 %** |
| Barde | 56 | 50 | 47 | 47 | 54 | 45 | 47 | 52 | 53 | 51 | **50,2 %** |
| Diplomate | 53 | 50 | 57 | 50 | 47 | 52 | 53 | 50 | 51 | 54 | **51,8 %** |
| Pugiliste | 41 | 51 | 52 | 49 | 50 | 50 | 46 | 50 | 48 | 51 | **48,7 %** |

### Les trois routes, l'usage des voies et la Tour, par classe

| Classe | Ruée | Éventail | Réactive | Voie 1 | Voie 2 | Voie 3 | Voie 4 | Voie 5 | Clé | Tour : étage 10 | étage 20 | étage moyen |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 42,5 % | 14,5 % | 48,4 % | 31,2 % | 46,5 % | 32,7 % | 82,9 % | 59,3 % | 93,7 % | 53,0 % | 4,8 % | 10,4 |
| Mage | 60,8 % | 21,3 % | 50,9 % | 23,2 % | 51,6 % | 49,6 % | 19,7 % | 23,2 % | 70,2 % | 49,6 % | 10,5 % | 10,9 |
| Voleur | 52,0 % | 28,0 % | 50,0 % | 34,2 % | 22,0 % | 50,6 % | 22,3 % | 36,7 % | 70,8 % | 55,3 % | 5,4 % | 10,5 |
| Archer | 52,8 % | 23,8 % | 50,4 % | 43,2 % | 34,0 % | 52,7 % | 18,5 % | 29,2 % | 68,5 % | 52,1 % | 9,3 % | 10,9 |
| Prêtre | 37,3 % | 10,8 % | 50,4 % | 30,0 % | 62,5 % | 35,0 % | 58,0 % | 71,0 % | 85,6 % | 48,6 % | 6,0 % | 10,2 |
| Alchimiste | 34,8 % | 15,3 % | 51,3 % | 42,4 % | 30,6 % | 47,2 % | 24,0 % | 57,8 % | 87,6 % | 49,0 % | 7,5 % | 10,8 |
| Invocateur | 46,8 % | 21,8 % | 52,0 % | 36,0 % | 24,7 % | 41,6 % | 44,1 % | 26,0 % | 65,0 % | 51,4 % | 8,0 % | 10,8 |
| Barde | 39,5 % | 21,0 % | 50,2 % | 35,8 % | 30,9 % | 36,6 % | 35,6 % | 61,8 % | 77,2 % | 48,5 % | 8,9 % | 10,5 |
| Diplomate | 37,0 % | 15,3 % | 51,8 % | 22,7 % | 55,5 % | 82,4 % | 42,8 % | 68,5 % | 85,3 % | 55,0 % | 5,9 % | 10,4 |
| Pugiliste | 14,8 % | 7,5 % | 48,7 % | 34,0 % | 32,9 % | 53,6 % | 80,7 % | 20,9 % | 89,8 % | 56,0 % | 6,7 % | 10,9 |

### Boutons touchés, et pourquoi

- pas des k calculés ensemble : le k d'une classe change aussi le duo dont elle est l'acolyte ; les duels au-delà de 58 % comptent aussi (effets mesurés à graines égales avant la passe 57)
- k_classe Mage : 0,867 → 0,865 (50,9 % de victoires)
- k_classe Voleur : 0,859 → 0,853 (50,0 % de victoires)
- k_classe Archer : 0,899 → 0,900 (50,4 % de victoires)
- k_classe Prêtre : 0,880 → 0,885 (50,4 % de victoires)
- k_classe Alchimiste : 1,058 → 1,054 (51,3 % de victoires)
- k_classe Invocateur : 0,975 → 0,965 (52,0 % de victoires)
- k_classe Barde : 1,076 → 1,075 (50,2 % de victoires)
- k_classe Diplomate : 1,178 → 1,191 (51,8 % de victoires)
- k_classe Pugiliste : 0,974 → 0,979 (48,7 % de victoires)
- Tour, Guerrier : pente des monstres 0,781 → 0,771 (étage 20 dans 4,8 % des montées)
- Tour, Mage : pente des monstres 1,216 → 1,252 (étage 20 dans 10,5 % des montées)
- Tour, Mage : facteur des monstres 0,719 → 0,711 (étage 10 dans 49,6 % des montées)
- Tour, Voleur : pente des monstres 0,484 → 0,474 (étage 20 dans 5,4 % des montées)
- Tour, Voleur : facteur des monstres 0,984 → 0,987 (étage 10 dans 55,3 % des montées)
- Tour, Prêtre : facteur des monstres 1,126 → 1,117 (étage 10 dans 48,6 % des montées)
- Tour, Alchimiste : facteur des monstres 0,981 → 0,967 (étage 10 dans 49,0 % des montées)
- Tour, Barde : facteur des monstres 0,718 → 0,706 (étage 10 dans 48,5 % des montées)
- Tour, Diplomate : facteur des monstres 1,373 → 1,395 (étage 10 dans 55,0 % des montées)
- Tour, Pugiliste : facteur des monstres 0,900 → 0,909 (étage 10 dans 56,0 % des montées)

## Passe 58 (graines à partir de 5800175)

**4 critères tenus sur 6.** 150000 combats de duel (médiane 10 tours), 0 combats non finis.

### Les six critères (section 11.2)

- ✅ **1. Chaque classe entre 47 % et 53 % de victoires**
- ❌ **2. Aucune case de la matrice hors de 40 % – 60 %** : guerrier contre pugiliste 60,9 %, pugiliste contre guerrier 39,3 %
- ✅ **3. La route Réactive entre 40 % et 55 % (Ruée et Éventail : des repères, sans seuil)**
- ✅ **4. Chaque voie jouée dans 15 % des combats au moins, une Clé dans 60 %**
- ✅ **5. Longueur : médiane de 6 à 10 tours, 95 % finis avant le tour 20**
- ❌ **6. Tour : étage 10 dans 40 à 60 % des montées, étage 20 dans 5 à 10 %, à 5 points près entre classes** : guerrier étage 20 4,6 %, voleur étage 20 4,9 %, écart entre classes : étage 10 de 46,5 % à 52,5 %, étage 20 de 4,6 % à 9,2 %

### La matrice des classes (taux de victoire de la ligne contre la colonne)

| | Guer | Mage | Vole | Arch | Prêt | Alch | Invo | Bard | Dipl | Pugi | **Moyenne** |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 50 | 56 | 54 | 55 | 45 | 43 | 49 | 47 | 44 | 61 | **50,4 %** |
| Mage | 43 | 49 | 49 | 45 | 51 | 56 | 50 | 52 | 54 | 49 | **49,8 %** |
| Voleur | 47 | 52 | 48 | 44 | 52 | 59 | 49 | 52 | 45 | 47 | **49,5 %** |
| Archer | 45 | 54 | 56 | 49 | 49 | 58 | 56 | 53 | 55 | 53 | **52,8 %** |
| Prêtre | 55 | 50 | 47 | 50 | 48 | 42 | 52 | 47 | 55 | 51 | **49,7 %** |
| Alchimiste | 55 | 46 | 40 | 41 | 57 | 52 | 49 | 54 | 54 | 45 | **49,2 %** |
| Invocateur | 52 | 48 | 49 | 41 | 48 | 52 | 50 | 49 | 46 | 47 | **48,3 %** |
| Barde | 51 | 46 | 48 | 45 | 53 | 45 | 49 | 50 | 54 | 50 | **49,0 %** |
| Diplomate | 53 | 49 | 52 | 46 | 49 | 48 | 55 | 46 | 51 | 45 | **49,4 %** |
| Pugiliste | 39 | 49 | 51 | 45 | 53 | 51 | 49 | 47 | 51 | 49 | **48,5 %** |

### Les trois routes, l'usage des voies et la Tour, par classe

| Classe | Ruée | Éventail | Réactive | Voie 1 | Voie 2 | Voie 3 | Voie 4 | Voie 5 | Clé | Tour : étage 10 | étage 20 | étage moyen |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 46,8 % | 14,2 % | 50,4 % | 37,0 % | 44,2 % | 34,2 % | 79,3 % | 57,8 % | 92,3 % | 48,3 % | 4,6 % | 10,0 |
| Mage | 56,0 % | 18,3 % | 49,8 % | 24,5 % | 49,8 % | 50,9 % | 23,6 % | 20,5 % | 68,7 % | 49,0 % | 9,0 % | 10,6 |
| Voleur | 48,0 % | 21,5 % | 49,5 % | 35,0 % | 24,2 % | 45,4 % | 19,0 % | 40,7 % | 67,9 % | 52,5 % | 4,9 % | 10,1 |
| Archer | 55,8 % | 23,3 % | 52,8 % | 35,4 % | 38,1 % | 49,0 % | 20,7 % | 43,6 % | 68,3 % | 49,5 % | 8,4 % | 10,6 |
| Prêtre | 35,0 % | 11,5 % | 49,7 % | 29,9 % | 62,0 % | 35,8 % | 57,1 % | 69,9 % | 84,7 % | 48,7 % | 7,3 % | 10,3 |
| Alchimiste | 29,8 % | 17,0 % | 49,2 % | 44,8 % | 30,5 % | 45,6 % | 25,6 % | 54,4 % | 86,7 % | 50,2 % | 7,8 % | 10,8 |
| Invocateur | 44,0 % | 22,5 % | 48,3 % | 38,2 % | 25,0 % | 48,7 % | 35,9 % | 23,2 % | 64,1 % | 50,1 % | 7,3 % | 10,6 |
| Barde | 43,5 % | 22,5 % | 49,0 % | 35,1 % | 32,6 % | 34,9 % | 33,3 % | 62,2 % | 76,0 % | 49,3 % | 9,2 % | 10,6 |
| Diplomate | 21,8 % | 6,8 % | 49,4 % | 19,8 % | 56,3 % | 83,8 % | 34,8 % | 73,8 % | 86,9 % | 49,8 % | 5,3 % | 10,2 |
| Pugiliste | 15,0 % | 6,5 % | 48,5 % | 38,7 % | 32,7 % | 53,7 % | 77,6 % | 20,6 % | 89,0 % | 46,5 % | 7,1 % | 10,4 |

### Boutons touchés, et pourquoi

- pas des k calculés ensemble : le k d'une classe change aussi le duo dont elle est l'acolyte ; les duels au-delà de 58 % comptent aussi (effets mesurés à graines égales avant la passe 57)
- k_classe Guerrier : 0,826 → 0,824 (50,4 % de victoires)
- k_classe Mage : 0,865 → 0,866 (49,8 % de victoires)
- k_classe Voleur : 0,853 → 0,851 (49,5 % de victoires)
- k_classe Archer : 0,900 → 0,894 (52,8 % de victoires)
- k_classe Prêtre : 0,885 → 0,882 (49,7 % de victoires)
- k_classe Alchimiste : 1,054 → 1,060 (49,2 % de victoires)
- k_classe Invocateur : 0,965 → 0,968 (48,3 % de victoires)
- k_classe Barde : 1,075 → 1,085 (49,0 % de victoires)
- k_classe Diplomate : 1,191 → 1,182 (49,4 % de victoires)
- k_classe Pugiliste : 0,979 → 0,981 (48,5 % de victoires)
- Tour, Guerrier : pente des monstres 0,771 → 0,760 (étage 20 dans 4,6 % des montées)
- Tour, Voleur : pente des monstres 0,474 → 0,462 (étage 20 dans 4,9 % des montées)
- Tour, Voleur : facteur des monstres 0,987 → 0,990 (étage 10 dans 52,5 % des montées)
- Tour, Diplomate : pente des monstres 0,955 → 0,934 (étage 20 dans 5,3 % des montées)
- Tour, Pugiliste : facteur des monstres 0,909 → 0,906 (étage 10 dans 46,5 % des montées)

## Passe 59 (graines à partir de 5900178)

**4 critères tenus sur 6.** 150000 combats de duel (médiane 10 tours), 0 combats non finis.

### Les six critères (section 11.2)

- ✅ **1. Chaque classe entre 47 % et 53 % de victoires**
- ❌ **2. Aucune case de la matrice hors de 40 % – 60 %** : guerrier contre pugiliste 62,3 %, alchimiste contre guerrier 60,1 %, pugiliste contre guerrier 38,5 %
- ✅ **3. La route Réactive entre 40 % et 55 % (Ruée et Éventail : des repères, sans seuil)**
- ✅ **4. Chaque voie jouée dans 15 % des combats au moins, une Clé dans 60 %**
- ✅ **5. Longueur : médiane de 6 à 10 tours, 95 % finis avant le tour 20**
- ❌ **6. Tour : étage 10 dans 40 à 60 % des montées, étage 20 dans 5 à 10 %, à 5 points près entre classes** : écart entre classes : étage 10 de 45,1 % à 53,7 %, étage 20 de 5,3 % à 9,4 %

### La matrice des classes (taux de victoire de la ligne contre la colonne)

| | Guer | Mage | Vole | Arch | Prêt | Alch | Invo | Bard | Dipl | Pugi | **Moyenne** |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 50 | 55 | 52 | 59 | 44 | 43 | 48 | 45 | 47 | 62 | **50,7 %** |
| Mage | 43 | 51 | 46 | 51 | 52 | 52 | 49 | 50 | 54 | 54 | **50,2 %** |
| Voleur | 45 | 49 | 50 | 48 | 52 | 56 | 47 | 51 | 48 | 52 | **49,6 %** |
| Archer | 41 | 50 | 53 | 50 | 47 | 56 | 53 | 47 | 52 | 55 | **50,3 %** |
| Prêtre | 54 | 49 | 50 | 54 | 49 | 40 | 50 | 47 | 53 | 54 | **50,1 %** |
| Alchimiste | 60 | 46 | 42 | 44 | 60 | 51 | 49 | 54 | 53 | 50 | **50,8 %** |
| Invocateur | 51 | 50 | 50 | 48 | 49 | 51 | 48 | 49 | 48 | 54 | **49,8 %** |
| Barde | 54 | 51 | 48 | 52 | 51 | 45 | 52 | 49 | 53 | 54 | **50,8 %** |
| Diplomate | 51 | 45 | 52 | 46 | 48 | 46 | 52 | 44 | 50 | 48 | **48,4 %** |
| Pugiliste | 38 | 49 | 49 | 48 | 48 | 51 | 47 | 44 | 52 | 50 | **47,7 %** |

### Les trois routes, l'usage des voies et la Tour, par classe

| Classe | Ruée | Éventail | Réactive | Voie 1 | Voie 2 | Voie 3 | Voie 4 | Voie 5 | Clé | Tour : étage 10 | étage 20 | étage moyen |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 39,5 % | 14,2 % | 50,7 % | 35,3 % | 43,8 % | 37,9 % | 78,5 % | 57,8 % | 92,4 % | 53,7 % | 6,8 % | 10,8 |
| Mage | 56,0 % | 22,3 % | 50,2 % | 25,9 % | 48,7 % | 47,5 % | 24,8 % | 22,1 % | 68,0 % | 46,3 % | 8,9 % | 10,5 |
| Voleur | 46,5 % | 28,2 % | 49,6 % | 35,6 % | 23,6 % | 48,2 % | 26,8 % | 32,3 % | 69,5 % | 53,0 % | 5,3 % | 10,2 |
| Archer | 58,3 % | 26,3 % | 50,3 % | 37,4 % | 33,5 % | 54,1 % | 20,2 % | 28,8 % | 67,2 % | 48,8 % | 6,4 % | 10,4 |
| Prêtre | 42,0 % | 15,0 % | 50,1 % | 30,1 % | 62,2 % | 36,6 % | 59,9 % | 69,8 % | 86,1 % | 50,0 % | 6,3 % | 10,3 |
| Alchimiste | 29,0 % | 15,8 % | 50,8 % | 40,8 % | 29,7 % | 46,6 % | 24,4 % | 58,5 % | 87,3 % | 47,0 % | 7,1 % | 10,4 |
| Invocateur | 45,3 % | 21,8 % | 49,8 % | 39,9 % | 23,5 % | 47,8 % | 34,0 % | 24,3 % | 64,4 % | 48,1 % | 7,0 % | 10,4 |
| Barde | 39,3 % | 19,0 % | 50,8 % | 36,3 % | 30,6 % | 36,1 % | 35,8 % | 61,4 % | 77,2 % | 51,6 % | 9,4 % | 10,8 |
| Diplomate | 28,5 % | 9,3 % | 48,4 % | 17,9 % | 43,3 % | 82,3 % | 32,4 % | 78,1 % | 87,2 % | 49,5 % | 5,8 % | 10,2 |
| Pugiliste | 19,8 % | 9,0 % | 47,7 % | 38,9 % | 33,0 % | 56,9 % | 74,0 % | 21,2 % | 89,2 % | 45,1 % | 5,8 % | 10,1 |

### Boutons touchés, et pourquoi

- pas des k calculés ensemble : le k d'une classe change aussi le duo dont elle est l'acolyte ; les duels au-delà de 58 % comptent aussi (effets mesurés à graines égales avant la passe 57)
- k_classe Guerrier : 0,824 → 0,823 (50,7 % de victoires)
- k_classe Mage : 0,866 → 0,869 (50,2 % de victoires)
- k_classe Voleur : 0,851 → 0,846 (49,6 % de victoires)
- k_classe Archer : 0,894 → 0,897 (50,3 % de victoires)
- k_classe Prêtre : 0,882 → 0,879 (50,1 % de victoires)
- k_classe Alchimiste : 1,060 → 1,055 (50,8 % de victoires)
- k_classe Invocateur : 0,968 → 0,964 (49,8 % de victoires)
- k_classe Barde : 1,085 → 1,081 (50,8 % de victoires)
- k_classe Diplomate : 1,182 → 1,195 (48,4 % de victoires)
- k_classe Pugiliste : 0,981 → 0,987 (47,7 % de victoires)
- Tour, Guerrier : facteur des monstres 1,728 → 1,766 (étage 10 dans 53,7 % des montées)
- Tour, Mage : facteur des monstres 0,711 → 0,701 (étage 10 dans 46,3 % des montées)
- Tour, Voleur : pente des monstres 0,462 → 0,451 (étage 20 dans 5,3 % des montées)
- Tour, Voleur : facteur des monstres 0,990 → 0,993 (étage 10 dans 53,0 % des montées)
- Tour, Alchimiste : facteur des monstres 0,967 → 0,956 (étage 10 dans 47,0 % des montées)
- Tour, Barde : facteur des monstres 0,706 → 0,710 (étage 10 dans 51,6 % des montées)
- Tour, Pugiliste : facteur des monstres 0,906 → 0,901 (étage 10 dans 45,1 % des montées)

## Passe 60 (graines à partir de 6000181)

**3 critères tenus sur 6.** 150000 combats de duel (médiane 10 tours), 0 combats non finis.

### Les six critères (section 11.2)

- ❌ **1. Chaque classe entre 47 % et 53 % de victoires** : pugiliste 53,1 %
- ❌ **2. Aucune case de la matrice hors de 40 % – 60 %** : guerrier contre pretre 39,1 %, guerrier contre alchimiste 39,7 %, voleur contre alchimiste 60,8 %, alchimiste contre guerrier 60,7 %, alchimiste contre voleur 39,9 %
- ✅ **3. La route Réactive entre 40 % et 55 % (Ruée et Éventail : des repères, sans seuil)**
- ✅ **4. Chaque voie jouée dans 15 % des combats au moins, une Clé dans 60 %**
- ✅ **5. Longueur : médiane de 6 à 10 tours, 95 % finis avant le tour 20**
- ❌ **6. Tour : étage 10 dans 40 à 60 % des montées, étage 20 dans 5 à 10 %, à 5 points près entre classes** : voleur étage 20 4,8 %, écart entre classes : étage 10 de 48,4 % à 56,6 %, étage 20 de 4,8 % à 9,7 %

### La matrice des classes (taux de victoire de la ligne contre la colonne)

| | Guer | Mage | Vole | Arch | Prêt | Alch | Invo | Bard | Dipl | Pugi | **Moyenne** |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 50 | 53 | 48 | 55 | 39 | 40 | 42 | 45 | 47 | 55 | **47,3 %** |
| Mage | 46 | 49 | 49 | 52 | 53 | 57 | 51 | 52 | 55 | 44 | **50,7 %** |
| Voleur | 51 | 50 | 51 | 49 | 51 | 61 | 50 | 52 | 48 | 44 | **50,4 %** |
| Archer | 45 | 48 | 51 | 51 | 45 | 55 | 52 | 49 | 53 | 45 | **49,2 %** |
| Prêtre | 59 | 49 | 48 | 53 | 51 | 46 | 52 | 48 | 53 | 47 | **50,8 %** |
| Alchimiste | 61 | 47 | 40 | 42 | 57 | 52 | 47 | 53 | 50 | 43 | **49,1 %** |
| Invocateur | 58 | 50 | 51 | 48 | 51 | 52 | 52 | 49 | 45 | 45 | **50,2 %** |
| Barde | 57 | 50 | 48 | 52 | 54 | 49 | 52 | 51 | 55 | 51 | **52,0 %** |
| Diplomate | 54 | 48 | 51 | 48 | 49 | 53 | 56 | 47 | 50 | 42 | **50,0 %** |
| Pugiliste | 43 | 56 | 56 | 53 | 55 | 56 | 55 | 52 | 57 | 49 | **53,1 %** |

### Les trois routes, l'usage des voies et la Tour, par classe

| Classe | Ruée | Éventail | Réactive | Voie 1 | Voie 2 | Voie 3 | Voie 4 | Voie 5 | Clé | Tour : étage 10 | étage 20 | étage moyen |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 40,0 % | 17,5 % | 47,3 % | 35,0 % | 44,1 % | 31,5 % | 82,2 % | 59,5 % | 93,4 % | 49,9 % | 5,6 % | 10,2 |
| Mage | 61,3 % | 22,8 % | 50,7 % | 22,8 % | 52,0 % | 50,9 % | 18,0 % | 21,0 % | 68,6 % | 49,6 % | 9,7 % | 10,8 |
| Voleur | 46,3 % | 24,3 % | 50,4 % | 34,7 % | 22,3 % | 48,0 % | 23,3 % | 35,7 % | 69,7 % | 52,3 % | 4,8 % | 10,0 |
| Archer | 56,0 % | 24,0 % | 49,2 % | 44,5 % | 31,8 % | 51,6 % | 19,4 % | 28,8 % | 66,1 % | 50,9 % | 8,2 % | 10,7 |
| Prêtre | 27,5 % | 10,0 % | 50,8 % | 31,9 % | 62,1 % | 35,6 % | 57,6 % | 69,9 % | 84,9 % | 48,4 % | 5,4 % | 9,9 |
| Alchimiste | 30,0 % | 15,5 % | 49,1 % | 45,8 % | 30,5 % | 45,6 % | 24,6 % | 53,4 % | 87,1 % | 50,9 % | 8,3 % | 10,9 |
| Invocateur | 50,2 % | 20,3 % | 50,2 % | 36,4 % | 25,3 % | 49,5 % | 35,3 % | 24,8 % | 63,2 % | 56,6 % | 8,4 % | 10,9 |
| Barde | 35,0 % | 20,3 % | 52,0 % | 34,6 % | 30,8 % | 34,2 % | 34,4 % | 65,2 % | 76,5 % | 50,1 % | 8,6 % | 10,5 |
| Diplomate | 33,8 % | 13,5 % | 50,0 % | 17,1 % | 42,4 % | 81,4 % | 33,1 % | 77,8 % | 87,7 % | 50,4 % | 7,9 % | 10,3 |
| Pugiliste | 18,0 % | 8,8 % | 53,1 % | 44,1 % | 38,0 % | 46,8 % | 75,5 % | 20,4 % | 89,5 % | 51,0 % | 7,2 % | 10,7 |

### Boutons touchés, et pourquoi

- pas des k calculés ensemble : le k d'une classe change aussi le duo dont elle est l'acolyte ; les duels au-delà de 58 % comptent aussi (effets mesurés à graines égales avant la passe 57)
- k_classe Guerrier : 0,823 → 0,822 (47,3 % de victoires)
- k_classe Mage : 0,869 → 0,851 (50,7 % de victoires)
- k_classe Voleur : 0,846 → 0,856 (50,4 % de victoires)
- k_classe Archer : 0,897 → 0,901 (49,2 % de victoires)
- k_classe Prêtre : 0,879 → 0,912 (50,8 % de victoires)
- k_classe Alchimiste : 1,055 → 1,056 (49,1 % de victoires)
- k_classe Invocateur : 0,964 → 0,996 (50,2 % de victoires)
- k_classe Barde : 1,081 → 1,075 (52,0 % de victoires)
- k_classe Diplomate : 1,195 → 1,138 (50,0 % de victoires)
- k_classe Pugiliste : 0,987 → 0,977 (53,1 % de victoires)
- Tour, Mage : pente des monstres 1,252 → 1,280 (étage 20 dans 9,7 % des montées)
- Tour, Voleur : pente des monstres 0,451 → 0,439 (étage 20 dans 4,8 % des montées)
- Tour, Prêtre : pente des monstres 0,947 → 0,938 (étage 20 dans 5,4 % des montées)
- Tour, Prêtre : facteur des monstres 1,117 → 1,110 (étage 10 dans 48,4 % des montées)
- Tour, Invocateur : facteur des monstres 0,923 → 0,936 (étage 10 dans 56,6 % des montées)

## Passe 61 (graines à partir de 6100184)

**3 critères tenus sur 6.** 150000 combats de duel (médiane 10 tours), 0 combats non finis.

### Les six critères (section 11.2)

- ❌ **1. Chaque classe entre 47 % et 53 % de victoires** : archer 53,1 %, alchimiste 45,8 %, diplomate 54,7 %, pugiliste 45,5 %
- ❌ **2. Aucune case de la matrice hors de 40 % – 60 %** : guerrier contre pugiliste 63,4 %, voleur contre alchimiste 60,8 %, voleur contre diplomate 38,5 %, archer contre alchimiste 62,3 %, alchimiste contre voleur 37,2 %, alchimiste contre archer 37,6 %, alchimiste contre diplomate 36,9 %, diplomate contre voleur 61,3 %, diplomate contre alchimiste 60,4 %, diplomate contre pugiliste 60,2 %, pugiliste contre guerrier 35,7 %, pugiliste contre diplomate 39,9 %
- ✅ **3. La route Réactive entre 40 % et 55 % (Ruée et Éventail : des repères, sans seuil)**
- ✅ **4. Chaque voie jouée dans 15 % des combats au moins, une Clé dans 60 %**
- ✅ **5. Longueur : médiane de 6 à 10 tours, 95 % finis avant le tour 20**
- ❌ **6. Tour : étage 10 dans 40 à 60 % des montées, étage 20 dans 5 à 10 %, à 5 points près entre classes** : écart entre classes : étage 10 de 46,9 % à 54,6 %, étage 20 de 5,4 % à 10,0 %

### La matrice des classes (taux de victoire de la ligne contre la colonne)

| | Guer | Mage | Vole | Arch | Prêt | Alch | Invo | Bard | Dipl | Pugi | **Moyenne** |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 49 | 57 | 52 | 53 | 46 | 41 | 44 | 45 | 53 | 63 | **50,4 %** |
| Mage | 45 | 50 | 52 | 46 | 50 | 58 | 45 | 50 | 48 | 48 | **49,0 %** |
| Voleur | 50 | 54 | 51 | 44 | 51 | 61 | 46 | 50 | 39 | 51 | **49,6 %** |
| Archer | 49 | 54 | 58 | 51 | 49 | 62 | 53 | 53 | 47 | 54 | **53,1 %** |
| Prêtre | 57 | 49 | 51 | 50 | 50 | 45 | 46 | 48 | 52 | 52 | **49,9 %** |
| Alchimiste | 58 | 41 | 37 | 38 | 54 | 50 | 45 | 52 | 37 | 47 | **45,8 %** |
| Invocateur | 56 | 56 | 56 | 47 | 53 | 57 | 52 | 54 | 42 | 57 | **52,9 %** |
| Barde | 54 | 46 | 51 | 46 | 53 | 47 | 46 | 50 | 42 | 53 | **49,0 %** |
| Diplomate | 48 | 51 | 61 | 52 | 49 | 60 | 58 | 58 | 50 | 60 | **54,7 %** |
| Pugiliste | 36 | 49 | 49 | 43 | 47 | 51 | 45 | 47 | 40 | 49 | **45,5 %** |

### Les trois routes, l'usage des voies et la Tour, par classe

| Classe | Ruée | Éventail | Réactive | Voie 1 | Voie 2 | Voie 3 | Voie 4 | Voie 5 | Clé | Tour : étage 10 | étage 20 | étage moyen |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 37,5 % | 9,5 % | 50,4 % | 37,2 % | 51,0 % | 40,2 % | 73,8 % | 59,9 % | 94,0 % | 54,6 % | 6,8 % | 11,0 |
| Mage | 49,8 % | 16,5 % | 49,0 % | 21,3 % | 55,2 % | 44,9 % | 19,3 % | 18,4 % | 68,3 % | 46,9 % | 6,8 % | 10,3 |
| Voleur | 42,5 % | 17,5 % | 49,6 % | 35,1 % | 19,2 % | 48,6 % | 23,7 % | 36,7 % | 71,1 % | 53,5 % | 6,5 % | 10,4 |
| Archer | 48,8 % | 12,8 % | 53,1 % | 34,1 % | 36,9 % | 47,1 % | 18,3 % | 44,1 % | 68,2 % | 50,3 % | 8,3 % | 10,5 |
| Prêtre | 38,0 % | 13,3 % | 49,9 % | 32,9 % | 62,3 % | 37,3 % | 54,7 % | 70,8 % | 85,6 % | 52,0 % | 7,4 % | 10,8 |
| Alchimiste | 22,5 % | 10,3 % | 45,8 % | 44,6 % | 28,0 % | 46,2 % | 24,6 % | 53,0 % | 86,8 % | 48,3 % | 8,8 % | 10,7 |
| Invocateur | 44,3 % | 18,5 % | 52,9 % | 37,2 % | 24,8 % | 33,6 % | 53,4 % | 23,6 % | 63,0 % | 51,0 % | 7,3 % | 10,6 |
| Barde | 35,5 % | 16,8 % | 49,0 % | 37,1 % | 32,5 % | 34,3 % | 33,7 % | 61,0 % | 77,7 % | 50,4 % | 10,0 % | 10,7 |
| Diplomate | 34,8 % | 13,5 % | 54,7 % | 22,9 % | 43,6 % | 75,7 % | 40,3 % | 72,2 % | 81,7 % | 49,7 % | 7,0 % | 10,3 |
| Pugiliste | 12,8 % | 3,8 % | 45,5 % | 38,1 % | 31,5 % | 53,2 % | 76,7 % | 20,2 % | 91,5 % | 49,1 % | 5,4 % | 10,2 |

### Boutons touchés, et pourquoi

- pas des k calculés ensemble : le k d'une classe change aussi le duo dont elle est l'acolyte ; les duels au-delà de 58 % comptent aussi (effets mesurés à graines égales avant la passe 61)
- k_classe Guerrier : 0,822 → 0,844 (50,4 % de victoires)
- k_classe Mage : 0,851 → 0,870 (49,0 % de victoires)
- k_classe Voleur : 0,856 → 0,851 (49,6 % de victoires)
- k_classe Archer : 0,901 → 0,873 (53,1 % de victoires)
- k_classe Prêtre : 0,912 → 0,877 (49,9 % de victoires)
- k_classe Alchimiste : 1,056 → 1,075 (45,8 % de victoires)
- k_classe Invocateur : 0,996 → 0,952 (52,9 % de victoires)
- k_classe Barde : 1,075 → 1,090 (49,0 % de victoires)
- k_classe Diplomate : 1,138 → 1,171 (54,7 % de victoires)
- k_classe Pugiliste : 0,977 → 0,989 (45,5 % de victoires)
- Tour, Guerrier : facteur des monstres 1,766 → 1,802 (étage 10 dans 54,6 % des montées)
- Tour, Mage : facteur des monstres 0,701 → 0,688 (étage 10 dans 46,9 % des montées)
- Tour, Voleur : facteur des monstres 0,993 → 0,996 (étage 10 dans 53,5 % des montées)
- Tour, Alchimiste : facteur des monstres 0,956 → 0,945 (étage 10 dans 48,3 % des montées)
- Tour, Barde : pente des monstres 1,561 → 1,600 (étage 20 dans 10,0 % des montées)
- Tour, Pugiliste : pente des monstres 0,972 → 0,952 (étage 20 dans 5,4 % des montées)

## Vérification des données de la passe 57, sur des graines jamais vues (3 000 combats par case, 4 000 montées par classe)

**4 critères tenus sur 6.** 300000 combats de duel (médiane 10 tours), 0 combats non finis.

### Les six critères (section 11.2)

- ✅ **1. Chaque classe entre 47 % et 53 % de victoires**
- ❌ **2. Aucune case de la matrice hors de 40 % – 60 %** : pretre contre alchimiste 39,8 %
- ✅ **3. La route Réactive entre 40 % et 55 % (Ruée et Éventail : des repères, sans seuil)**
- ✅ **4. Chaque voie jouée dans 15 % des combats au moins, une Clé dans 60 %**
- ✅ **5. Longueur : médiane de 6 à 10 tours, 95 % finis avant le tour 20**
- ❌ **6. Tour : étage 10 dans 40 à 60 % des montées, étage 20 dans 5 à 10 %, à 5 points près entre classes** : voleur étage 20 5,0 %

### La matrice des classes (taux de victoire de la ligne contre la colonne)

| | Guer | Mage | Vole | Arch | Prêt | Alch | Invo | Bard | Dipl | Pugi | **Moyenne** |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 51 | 55 | 50 | 56 | 45 | 40 | 41 | 43 | 47 | 60 | **48,7 %** |
| Mage | 45 | 49 | 49 | 50 | 51 | 53 | 47 | 50 | 53 | 49 | **49,4 %** |
| Voleur | 47 | 51 | 48 | 47 | 51 | 56 | 47 | 51 | 42 | 48 | **48,8 %** |
| Archer | 44 | 49 | 53 | 49 | 48 | 57 | 50 | 50 | 51 | 51 | **50,1 %** |
| Prêtre | 56 | 47 | 48 | 51 | 49 | 40 | 47 | 46 | 53 | 50 | **48,6 %** |
| Alchimiste | 59 | 45 | 41 | 43 | 59 | 50 | 47 | 55 | 52 | 47 | **49,8 %** |
| Invocateur | 57 | 52 | 51 | 49 | 51 | 50 | 49 | 51 | 46 | 53 | **50,8 %** |
| Barde | 56 | 48 | 47 | 50 | 53 | 44 | 47 | 49 | 51 | 52 | **49,8 %** |
| Diplomate | 54 | 48 | 57 | 51 | 46 | 48 | 53 | 47 | 48 | 50 | **50,2 %** |
| Pugiliste | 41 | 50 | 51 | 49 | 49 | 52 | 44 | 47 | 48 | 50 | **48,2 %** |

### Les trois routes, l'usage des voies et la Tour, par classe

| Classe | Ruée | Éventail | Réactive | Voie 1 | Voie 2 | Voie 3 | Voie 4 | Voie 5 | Clé | Tour : étage 10 | étage 20 | étage moyen |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 47,5 % | 16,2 % | 48,7 % | 32,3 % | 44,8 % | 34,2 % | 83,8 % | 58,7 % | 93,6 % | 51,6 % | 5,1 % | 10,4 |
| Mage | 57,3 % | 22,3 % | 49,4 % | 23,8 % | 50,6 % | 49,4 % | 18,9 % | 22,5 % | 70,1 % | 48,9 % | 9,3 % | 10,6 |
| Voleur | 52,1 % | 30,0 % | 48,8 % | 35,1 % | 22,6 % | 48,5 % | 22,8 % | 37,1 % | 70,2 % | 51,4 % | 5,0 % | 10,2 |
| Archer | 55,9 % | 26,9 % | 50,1 % | 41,9 % | 35,0 % | 50,8 % | 18,9 % | 30,2 % | 67,6 % | 50,2 % | 8,8 % | 10,6 |
| Prêtre | 31,2 % | 9,3 % | 48,6 % | 29,6 % | 63,2 % | 36,0 % | 57,4 % | 70,0 % | 85,1 % | 48,8 % | 6,2 % | 10,2 |
| Alchimiste | 35,7 % | 14,8 % | 49,8 % | 41,9 % | 30,2 % | 46,7 % | 23,9 % | 57,3 % | 87,1 % | 48,9 % | 7,0 % | 10,6 |
| Invocateur | 53,9 % | 24,2 % | 50,8 % | 35,2 % | 24,5 % | 39,4 % | 48,1 % | 26,0 % | 64,7 % | 51,6 % | 7,7 % | 10,7 |
| Barde | 39,7 % | 19,0 % | 49,8 % | 37,2 % | 31,8 % | 35,7 % | 35,2 % | 60,7 % | 77,4 % | 49,1 % | 8,5 % | 10,6 |
| Diplomate | 32,4 % | 10,7 % | 50,2 % | 21,3 % | 55,5 % | 83,0 % | 41,2 % | 69,0 % | 85,7 % | 52,6 % | 7,3 % | 10,5 |
| Pugiliste | 19,8 % | 8,0 % | 48,2 % | 34,2 % | 32,0 % | 52,1 % | 80,8 % | 20,8 % | 89,9 % | 53,4 % | 6,8 % | 10,7 |

### Boutons touchés, et pourquoi

Aucun (mesure seule).

## Après la vérification de la passe 57 : deux retouches

Les passes 58 à 61 n'ont pas fait mieux que la passe 57 (pas plus grands : le Diplomate a bondi à 54,7 %). Les données de la passe 57 ont donc été remises en place et vérifiées sur des graines jamais vues (ci-dessus) : 4 critères sur 6, et les deux autres manqués d'un cheveu (Prêtre contre Alchimiste à 39,8 %, l'étage 20 du Voleur à 5,0 %). Deux retouches, avec les effets mesurés des k sur les duels :

- k_classe Mage : +1 % (bouton 1). Le Mage est l'acolyte du Prêtre : le duel Alchimiste contre Prêtre perd environ 1,5 point, la moyenne du Prêtre gagne environ 1 point (48,6 % avant).
- La Tour : pente des monstres du Voleur −3 % (étage 20 au-dessus de 5 %) ; facteur des monstres du Mage et du Prêtre +1 % (pour que le Mage plus fort ne rende pas leur Tour plus facile).

Puis une nouvelle vérification, sur d'autres graines jamais vues.

## Vérification finale, sur des graines jamais vues (3 000 combats par case, 4 000 montées par classe)

**5 critères tenus sur 6.** 300000 combats de duel (médiane 10 tours), 0 combats non finis.

### Les six critères (section 11.2)

- ✅ **1. Chaque classe entre 47 % et 53 % de victoires**
- ❌ **2. Aucune case de la matrice hors de 40 % – 60 %** : alchimiste contre guerrier 61,1 %
- ✅ **3. La route Réactive entre 40 % et 55 % (Ruée et Éventail : des repères, sans seuil)**
- ✅ **4. Chaque voie jouée dans 15 % des combats au moins, une Clé dans 60 %**
- ✅ **5. Longueur : médiane de 6 à 10 tours, 95 % finis avant le tour 20**
- ✅ **6. Tour : étage 10 dans 40 à 60 % des montées, étage 20 dans 5 à 10 %, à 5 points près entre classes**

### La matrice des classes (taux de victoire de la ligne contre la colonne)

| | Guer | Mage | Vole | Arch | Prêt | Alch | Invo | Bard | Dipl | Pugi | **Moyenne** |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 50 | 55 | 51 | 58 | 44 | 41 | 43 | 44 | 46 | 59 | **49,2 %** |
| Mage | 46 | 49 | 50 | 50 | 50 | 52 | 47 | 51 | 49 | 52 | **49,5 %** |
| Voleur | 50 | 50 | 50 | 45 | 50 | 57 | 47 | 52 | 44 | 51 | **49,7 %** |
| Archer | 44 | 51 | 54 | 50 | 48 | 57 | 52 | 51 | 51 | 51 | **50,9 %** |
| Prêtre | 54 | 49 | 50 | 51 | 50 | 41 | 49 | 47 | 55 | 51 | **49,6 %** |
| Alchimiste | 61 | 48 | 43 | 43 | 58 | 49 | 48 | 55 | 53 | 49 | **50,7 %** |
| Invocateur | 57 | 52 | 53 | 47 | 51 | 50 | 49 | 52 | 44 | 54 | **50,9 %** |
| Barde | 56 | 47 | 48 | 50 | 51 | 42 | 47 | 49 | 51 | 51 | **49,1 %** |
| Diplomate | 53 | 50 | 57 | 49 | 46 | 47 | 54 | 49 | 49 | 53 | **50,8 %** |
| Pugiliste | 41 | 49 | 52 | 50 | 49 | 50 | 47 | 49 | 48 | 50 | **48,6 %** |

### Les trois routes, l'usage des voies et la Tour, par classe

| Classe | Ruée | Éventail | Réactive | Voie 1 | Voie 2 | Voie 3 | Voie 4 | Voie 5 | Clé | Tour : étage 10 | étage 20 | étage moyen |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 46,6 % | 16,9 % | 49,2 % | 32,9 % | 46,5 % | 32,6 % | 83,5 % | 59,7 % | 93,5 % | 53,0 % | 5,5 % | 10,6 |
| Mage | 58,6 % | 23,9 % | 49,5 % | 23,5 % | 49,4 % | 48,6 % | 25,3 % | 23,4 % | 69,9 % | 49,8 % | 8,7 % | 10,5 |
| Voleur | 55,9 % | 27,8 % | 49,7 % | 35,7 % | 21,0 % | 49,2 % | 23,4 % | 37,1 % | 70,4 % | 52,8 % | 5,4 % | 10,3 |
| Archer | 56,0 % | 25,3 % | 50,9 % | 42,3 % | 33,8 % | 51,6 % | 19,4 % | 32,0 % | 68,4 % | 49,5 % | 8,4 % | 10,6 |
| Prêtre | 29,1 % | 12,4 % | 49,6 % | 30,0 % | 62,8 % | 36,1 % | 57,1 % | 70,6 % | 85,1 % | 50,1 % | 5,8 % | 10,2 |
| Alchimiste | 36,2 % | 17,0 % | 50,7 % | 41,8 % | 30,2 % | 46,3 % | 24,6 % | 58,0 % | 87,3 % | 48,0 % | 6,6 % | 10,6 |
| Invocateur | 54,6 % | 22,9 % | 50,9 % | 36,6 % | 24,6 % | 39,5 % | 47,2 % | 25,5 % | 64,1 % | 51,2 % | 7,8 % | 10,7 |
| Barde | 38,7 % | 22,6 % | 49,1 % | 37,1 % | 32,0 % | 36,5 % | 34,7 % | 60,5 % | 76,9 % | 48,6 % | 8,4 % | 10,5 |
| Diplomate | 30,9 % | 13,9 % | 50,8 % | 22,2 % | 56,1 % | 82,3 % | 42,1 % | 69,0 % | 85,9 % | 51,6 % | 6,1 % | 10,2 |
| Pugiliste | 19,3 % | 7,1 % | 48,6 % | 34,0 % | 33,8 % | 53,3 % | 80,3 % | 20,9 % | 89,7 % | 52,8 % | 7,2 % | 10,7 |

### Boutons touchés, et pourquoi

Aucun (mesure seule).

## Passe 62 (graines à partir de 6200187)

**4 critères tenus sur 6.** 150000 combats de duel (médiane 10 tours), 0 combats non finis.

### Les six critères (section 11.2)

- ✅ **1. Chaque classe entre 47 % et 53 % de victoires**
- ❌ **2. Aucune case de la matrice hors de 40 % – 60 %** : pugiliste contre guerrier 38,1 %
- ✅ **3. La route Réactive entre 40 % et 55 % (Ruée et Éventail : des repères, sans seuil)**
- ✅ **4. Chaque voie jouée dans 15 % des combats au moins, une Clé dans 60 %**
- ✅ **5. Longueur : médiane de 6 à 10 tours, 95 % finis avant le tour 20**
- ❌ **6. Tour : étage 10 dans 40 à 60 % des montées, étage 20 dans 5 à 10 %, à 5 points près entre classes** : voleur étage 20 4,0 %, pretre étage 20 4,1 %, alchimiste étage 20 4,4 %, écart entre classes : étage 10 de 45,6 % à 54,3 %, étage 20 de 4,0 % à 8,0 %

### La matrice des classes (taux de victoire de la ligne contre la colonne)

| | Guer | Mage | Vole | Arch | Prêt | Alch | Invo | Bard | Dipl | Pugi | **Moyenne** |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 49 | 57 | 51 | 58 | 44 | 41 | 43 | 46 | 47 | 60 | **49,7 %** |
| Mage | 45 | 51 | 49 | 49 | 50 | 52 | 47 | 51 | 48 | 48 | **49,0 %** |
| Voleur | 50 | 50 | 51 | 48 | 51 | 57 | 49 | 52 | 42 | 47 | **49,5 %** |
| Archer | 45 | 51 | 54 | 54 | 49 | 57 | 53 | 50 | 49 | 49 | **51,1 %** |
| Prêtre | 55 | 51 | 45 | 54 | 49 | 42 | 48 | 47 | 55 | 51 | **49,6 %** |
| Alchimiste | 58 | 45 | 42 | 44 | 57 | 49 | 48 | 54 | 50 | 47 | **49,4 %** |
| Invocateur | 58 | 52 | 52 | 50 | 51 | 51 | 50 | 53 | 46 | 52 | **51,4 %** |
| Barde | 55 | 48 | 47 | 47 | 53 | 44 | 46 | 47 | 49 | 48 | **48,4 %** |
| Diplomate | 54 | 50 | 56 | 49 | 45 | 47 | 55 | 48 | 50 | 49 | **50,3 %** |
| Pugiliste | 38 | 48 | 50 | 51 | 49 | 50 | 44 | 48 | 47 | 49 | **47,4 %** |

### Les trois routes, l'usage des voies et la Tour, par classe

| Classe | Ruée | Éventail | Réactive | Voie 1 | Voie 2 | Voie 3 | Voie 4 | Voie 5 | Clé | Tour : étage 10 | étage 20 | étage moyen |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 42,5 % | 17,5 % | 49,7 % | 32,5 % | 46,8 % | 34,5 % | 83,2 % | 59,1 % | 93,4 % | 48,3 % | 5,8 % | 10,2 |
| Mage | 59,8 % | 24,0 % | 49,0 % | 22,7 % | 47,9 % | 51,4 % | 27,9 % | 22,9 % | 69,3 % | 47,8 % | 7,5 % | 10,3 |
| Voleur | 53,3 % | 30,0 % | 49,5 % | 35,3 % | 21,4 % | 48,7 % | 24,6 % | 37,9 % | 70,3 % | 51,5 % | 4,0 % | 10,0 |
| Archer | 54,5 % | 25,3 % | 51,1 % | 43,6 % | 35,7 % | 50,0 % | 18,0 % | 31,6 % | 67,6 % | 48,9 % | 7,2 % | 10,4 |
| Prêtre | 43,0 % | 16,8 % | 49,6 % | 30,3 % | 61,8 % | 36,9 % | 56,6 % | 70,8 % | 84,9 % | 49,3 % | 4,1 % | 10,0 |
| Alchimiste | 31,3 % | 15,5 % | 49,4 % | 44,0 % | 29,3 % | 46,9 % | 25,9 % | 56,2 % | 86,7 % | 45,6 % | 4,4 % | 10,4 |
| Invocateur | 53,8 % | 22,3 % | 51,4 % | 35,6 % | 24,9 % | 40,2 % | 48,6 % | 25,0 % | 64,2 % | 49,8 % | 6,4 % | 10,5 |
| Barde | 42,5 % | 24,0 % | 48,4 % | 37,4 % | 32,0 % | 35,8 % | 35,0 % | 60,1 % | 77,2 % | 46,4 % | 7,2 % | 10,4 |
| Diplomate | 31,8 % | 15,3 % | 50,3 % | 21,9 % | 57,9 % | 82,9 % | 42,1 % | 69,5 % | 85,9 % | 50,8 % | 5,3 % | 10,1 |
| Pugiliste | 22,5 % | 9,8 % | 47,4 % | 34,0 % | 32,4 % | 53,8 % | 79,9 % | 21,1 % | 89,6 % | 54,3 % | 8,0 % | 10,9 |

### Boutons touchés, et pourquoi

- pas des k calculés ensemble : le k d'une classe change aussi le duo dont elle est l'acolyte ; les duels au-delà de 58 % comptent aussi (effets mesurés à graines égales avant la passe 61)
- k_classe Guerrier : 0,826 → 0,828 (49,7 % de victoires)
- k_classe Mage : 0,875 → 0,881 (49,0 % de victoires)
- k_classe Voleur : 0,859 → 0,850 (49,5 % de victoires)
- k_classe Archer : 0,899 → 0,895 (51,1 % de victoires)
- k_classe Prêtre : 0,880 → 0,875 (49,6 % de victoires)
- k_classe Alchimiste : 1,058 → 1,059 (49,4 % de victoires)
- k_classe Invocateur : 0,975 → 0,963 (51,4 % de victoires)
- k_classe Barde : 1,076 → 1,086 (48,4 % de victoires)
- k_classe Diplomate : 1,178 → 1,184 (50,3 % de victoires)
- k_classe Pugiliste : 0,974 → 0,980 (47,4 % de victoires)
- Tour : force des monstres au départ 0,396 → 0,396, en plus par étage 0,027 → 0,027 (étage 10 atteint dans 49,3 % des montées, étage 20 dans 6,0 %)
- Tour, Voleur : pente des monstres 0,469 → 0,453 (étage 20 dans 4,0 % des montées)
- Tour, Voleur : facteur des monstres 0,984 → 0,987 (étage 10 dans 51,5 % des montées)
- Tour, Prêtre : pente des monstres 0,947 → 0,931 (étage 20 dans 4,1 % des montées)
- Tour, Alchimiste : pente des monstres 1,028 → 0,996 (étage 20 dans 4,4 % des montées)
- Tour, Alchimiste : facteur des monstres 0,981 → 0,963 (étage 10 dans 45,6 % des montées)
- Tour, Barde : facteur des monstres 0,718 → 0,715 (étage 10 dans 46,4 % des montées)
- Tour, Diplomate : pente des monstres 0,955 → 0,934 (étage 20 dans 5,3 % des montées)
- Tour, Pugiliste : facteur des monstres 0,900 → 0,903 (étage 10 dans 54,3 % des montées)

## Passe 63 (graines à partir de 6300190)

**4 critères tenus sur 6.** 150000 combats de duel (médiane 10 tours), 0 combats non finis.

### Les six critères (section 11.2)

- ✅ **1. Chaque classe entre 47 % et 53 % de victoires**
- ❌ **2. Aucune case de la matrice hors de 40 % – 60 %** : guerrier contre pugiliste 62,9 %, pugiliste contre guerrier 37,0 %
- ✅ **3. La route Réactive entre 40 % et 55 % (Ruée et Éventail : des repères, sans seuil)**
- ✅ **4. Chaque voie jouée dans 15 % des combats au moins, une Clé dans 60 %**
- ✅ **5. Longueur : médiane de 6 à 10 tours, 95 % finis avant le tour 20**
- ❌ **6. Tour : étage 10 dans 40 à 60 % des montées, étage 20 dans 5 à 10 %, à 5 points près entre classes** : écart entre classes : étage 10 de 49,2 % à 55,9 %, étage 20 de 5,2 % à 10,0 %

### La matrice des classes (taux de victoire de la ligne contre la colonne)

| | Guer | Mage | Vole | Arch | Prêt | Alch | Invo | Bard | Dipl | Pugi | **Moyenne** |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 50 | 56 | 55 | 58 | 47 | 47 | 47 | 46 | 52 | 63 | **52,0 %** |
| Mage | 43 | 49 | 49 | 52 | 50 | 56 | 50 | 52 | 55 | 51 | **50,6 %** |
| Voleur | 47 | 50 | 51 | 46 | 47 | 58 | 48 | 50 | 49 | 50 | **49,5 %** |
| Archer | 41 | 49 | 53 | 50 | 45 | 56 | 54 | 49 | 53 | 53 | **50,3 %** |
| Prêtre | 53 | 50 | 52 | 56 | 50 | 41 | 55 | 50 | 56 | 54 | **51,6 %** |
| Alchimiste | 53 | 45 | 44 | 45 | 59 | 48 | 51 | 53 | 55 | 51 | **50,3 %** |
| Invocateur | 51 | 49 | 51 | 47 | 45 | 50 | 51 | 47 | 44 | 52 | **48,6 %** |
| Barde | 52 | 48 | 48 | 48 | 51 | 43 | 50 | 49 | 55 | 53 | **49,7 %** |
| Diplomate | 52 | 48 | 55 | 48 | 44 | 46 | 56 | 45 | 49 | 49 | **49,2 %** |
| Pugiliste | 37 | 48 | 50 | 49 | 48 | 51 | 47 | 47 | 50 | 49 | **47,7 %** |

### Les trois routes, l'usage des voies et la Tour, par classe

| Classe | Ruée | Éventail | Réactive | Voie 1 | Voie 2 | Voie 3 | Voie 4 | Voie 5 | Clé | Tour : étage 10 | étage 20 | étage moyen |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 41,5 % | 16,5 % | 52,0 % | 30,2 % | 46,1 % | 41,4 % | 78,9 % | 60,5 % | 92,7 % | 52,8 % | 5,2 % | 10,5 |
| Mage | 60,8 % | 24,0 % | 50,6 % | 22,7 % | 48,7 % | 49,1 % | 25,7 % | 23,0 % | 69,2 % | 50,7 % | 9,9 % | 10,8 |
| Voleur | 58,5 % | 32,0 % | 49,5 % | 37,5 % | 21,2 % | 49,7 % | 27,8 % | 32,6 % | 70,4 % | 54,0 % | 6,1 % | 10,6 |
| Archer | 61,8 % | 26,3 % | 50,3 % | 29,7 % | 34,9 % | 56,4 % | 19,5 % | 36,7 % | 68,7 % | 49,5 % | 6,1 % | 10,5 |
| Prêtre | 31,0 % | 15,0 % | 51,6 % | 31,2 % | 61,6 % | 35,6 % | 58,1 % | 70,4 % | 84,6 % | 51,8 % | 7,8 % | 10,5 |
| Alchimiste | 31,0 % | 12,0 % | 50,3 % | 40,5 % | 30,4 % | 47,6 % | 23,7 % | 59,1 % | 86,9 % | 52,3 % | 8,2 % | 11,0 |
| Invocateur | 50,5 % | 24,5 % | 48,6 % | 38,6 % | 25,6 % | 50,0 % | 33,0 % | 25,4 % | 65,2 % | 50,1 % | 9,3 % | 10,7 |
| Barde | 35,3 % | 24,3 % | 49,7 % | 37,2 % | 31,0 % | 35,9 % | 36,2 % | 60,5 % | 78,2 % | 49,2 % | 10,0 % | 10,5 |
| Diplomate | 25,5 % | 7,5 % | 49,2 % | 19,6 % | 55,0 % | 84,3 % | 36,4 % | 73,0 % | 87,5 % | 51,7 % | 8,5 % | 10,4 |
| Pugiliste | 19,0 % | 9,3 % | 47,7 % | 37,4 % | 34,8 % | 56,5 % | 75,3 % | 22,5 % | 89,4 % | 55,9 % | 8,9 % | 11,0 |

### Boutons touchés, et pourquoi

- pas des k calculés ensemble : le k d'une classe change aussi le duo dont elle est l'acolyte ; les duels au-delà de 58 % comptent aussi (effets mesurés à graines égales avant la passe 61)
- k_classe Guerrier : 0,828 → 0,820 (52,0 % de victoires)
- k_classe Voleur : 0,850 → 0,844 (49,5 % de victoires)
- k_classe Archer : 0,895 → 0,897 (50,3 % de victoires)
- k_classe Alchimiste : 1,059 → 1,055 (50,3 % de victoires)
- k_classe Barde : 1,086 → 1,089 (49,7 % de victoires)
- k_classe Diplomate : 1,184 → 1,191 (49,2 % de victoires)
- k_classe Pugiliste : 0,980 → 0,991 (47,7 % de victoires)
- Tour, Guerrier : pente des monstres 0,781 → 0,772 (étage 20 dans 5,2 % des montées)
- Tour, Mage : pente des monstres 1,216 → 1,245 (étage 20 dans 9,9 % des montées)
- Tour, Voleur : facteur des monstres 0,987 → 0,989 (étage 10 dans 54,0 % des montées)
- Tour, Archer : facteur des monstres 0,610 → 0,603 (étage 10 dans 49,5 % des montées)
- Tour, Barde : pente des monstres 1,561 → 1,600 (étage 20 dans 10,0 % des montées)
- Tour, Barde : facteur des monstres 0,715 → 0,713 (étage 10 dans 49,2 % des montées)
- Tour, Pugiliste : facteur des monstres 0,903 → 0,907 (étage 10 dans 55,9 % des montées)

## Passe 64 (graines à partir de 6400193)

**4 critères tenus sur 6.** 150000 combats de duel (médiane 10 tours), 0 combats non finis.

### Les six critères (section 11.2)

- ✅ **1. Chaque classe entre 47 % et 53 % de victoires**
- ❌ **2. Aucune case de la matrice hors de 40 % – 60 %** : voleur contre alchimiste 62,9 %, alchimiste contre voleur 39,6 %
- ✅ **3. La route Réactive entre 40 % et 55 % (Ruée et Éventail : des repères, sans seuil)**
- ✅ **4. Chaque voie jouée dans 15 % des combats au moins, une Clé dans 60 %**
- ✅ **5. Longueur : médiane de 6 à 10 tours, 95 % finis avant le tour 20**
- ❌ **6. Tour : étage 10 dans 40 à 60 % des montées, étage 20 dans 5 à 10 %, à 5 points près entre classes** : archer étage 20 10,1 %, écart entre classes : étage 10 de 47,7 % à 53,9 %, étage 20 de 5,4 % à 10,1 %

### La matrice des classes (taux de victoire de la ligne contre la colonne)

| | Guer | Mage | Vole | Arch | Prêt | Alch | Invo | Bard | Dipl | Pugi | **Moyenne** |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 48 | 55 | 54 | 55 | 46 | 46 | 46 | 48 | 49 | 59 | **50,6 %** |
| Mage | 47 | 51 | 48 | 50 | 51 | 58 | 52 | 54 | 56 | 51 | **51,8 %** |
| Voleur | 48 | 52 | 51 | 50 | 49 | 63 | 49 | 54 | 47 | 48 | **51,1 %** |
| Archer | 45 | 49 | 52 | 48 | 48 | 59 | 52 | 51 | 55 | 50 | **50,8 %** |
| Prêtre | 55 | 47 | 50 | 52 | 48 | 48 | 52 | 49 | 57 | 52 | **50,9 %** |
| Alchimiste | 55 | 43 | 40 | 41 | 53 | 51 | 47 | 52 | 53 | 43 | **47,8 %** |
| Invocateur | 51 | 51 | 51 | 46 | 46 | 54 | 49 | 50 | 45 | 50 | **49,4 %** |
| Barde | 56 | 47 | 48 | 49 | 53 | 50 | 52 | 52 | 53 | 50 | **51,0 %** |
| Diplomate | 52 | 43 | 52 | 44 | 45 | 48 | 54 | 46 | 48 | 43 | **47,5 %** |
| Pugiliste | 43 | 51 | 53 | 51 | 50 | 56 | 51 | 50 | 55 | 49 | **50,9 %** |

### Les trois routes, l'usage des voies et la Tour, par classe

| Classe | Ruée | Éventail | Réactive | Voie 1 | Voie 2 | Voie 3 | Voie 4 | Voie 5 | Clé | Tour : étage 10 | étage 20 | étage moyen |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 34,5 % | 15,5 % | 50,6 % | 35,0 % | 49,2 % | 40,7 % | 74,3 % | 61,3 % | 92,8 % | 50,2 % | 6,3 % | 10,4 |
| Mage | 55,8 % | 21,5 % | 51,8 % | 23,6 % | 46,9 % | 49,7 % | 25,4 % | 20,0 % | 66,5 % | 48,5 % | 8,8 % | 10,5 |
| Voleur | 49,8 % | 28,5 % | 51,1 % | 33,8 % | 21,6 % | 48,3 % | 18,2 % | 38,2 % | 68,1 % | 52,9 % | 5,4 % | 10,3 |
| Archer | 53,5 % | 24,8 % | 50,8 % | 40,3 % | 32,5 % | 50,2 % | 18,0 % | 30,9 % | 64,9 % | 47,7 % | 10,1 % | 10,7 |
| Prêtre | 36,0 % | 13,8 % | 50,9 % | 30,6 % | 61,1 % | 36,2 % | 58,3 % | 69,5 % | 84,3 % | 53,9 % | 7,5 % | 10,6 |
| Alchimiste | 24,5 % | 12,5 % | 47,8 % | 45,9 % | 29,1 % | 45,0 % | 24,0 % | 54,8 % | 86,4 % | 48,6 % | 8,0 % | 10,6 |
| Invocateur | 57,8 % | 22,8 % | 49,4 % | 37,2 % | 23,5 % | 51,2 % | 32,7 % | 22,6 % | 63,1 % | 49,2 % | 8,4 % | 10,5 |
| Barde | 42,3 % | 20,8 % | 51,0 % | 38,0 % | 29,6 % | 35,1 % | 34,8 % | 61,7 % | 76,8 % | 48,6 % | 8,7 % | 10,5 |
| Diplomate | 28,5 % | 9,0 % | 47,5 % | 19,6 % | 56,8 % | 83,7 % | 34,5 % | 73,6 % | 86,9 % | 53,2 % | 6,0 % | 10,4 |
| Pugiliste | 15,0 % | 7,2 % | 50,9 % | 43,7 % | 35,0 % | 50,6 % | 73,6 % | 20,7 % | 89,5 % | 48,9 % | 8,4 % | 10,6 |

### Boutons touchés, et pourquoi

- pas des k calculés ensemble : le k d'une classe change aussi le duo dont elle est l'acolyte ; les duels au-delà de 58 % comptent aussi (effets mesurés à graines égales avant la passe 61)
- k_classe Guerrier : 0,820 → 0,815 (50,6 % de victoires)
- k_classe Mage : 0,881 → 0,875 (51,8 % de victoires)
- k_classe Voleur : 0,844 → 0,837 (51,1 % de victoires)
- k_classe Prêtre : 0,875 → 0,874 (50,9 % de victoires)
- k_classe Alchimiste : 1,055 → 1,069 (47,8 % de victoires)
- k_classe Invocateur : 0,963 → 0,967 (49,4 % de victoires)
- k_classe Barde : 1,089 → 1,081 (51,0 % de victoires)
- k_classe Diplomate : 1,191 → 1,200 (47,5 % de victoires)
- Tour, Voleur : pente des monstres 0,453 → 0,444 (étage 20 dans 5,4 % des montées)
- Tour, Voleur : facteur des monstres 0,989 → 0,992 (étage 10 dans 52,9 % des montées)
- Tour, Archer : pente des monstres 1,563 → 1,573 (étage 20 dans 10,1 % des montées)
- Tour, Archer : facteur des monstres 0,603 → 0,596 (étage 10 dans 47,7 % des montées)
- Tour, Prêtre : facteur des monstres 1,137 → 1,143 (étage 10 dans 53,9 % des montées)
- Tour, Diplomate : facteur des monstres 1,373 → 1,394 (étage 10 dans 53,2 % des montées)

## Passe 65 (graines à partir de 6500196)

**3 critères tenus sur 6.** 150000 combats de duel (médiane 10 tours), 1 combats non finis.

### Les six critères (section 11.2)

- ✅ **1. Chaque classe entre 47 % et 53 % de victoires**
- ❌ **2. Aucune case de la matrice hors de 40 % – 60 %** : alchimiste contre pretre 60,2 %
- ✅ **3. La route Réactive entre 40 % et 55 % (Ruée et Éventail : des repères, sans seuil)**
- ✅ **4. Chaque voie jouée dans 15 % des combats au moins, une Clé dans 60 %**
- ❌ **5. Longueur : médiane de 6 à 10 tours, 95 % finis avant le tour 20** : 1 combats non finis
- ❌ **6. Tour : étage 10 dans 40 à 60 % des montées, étage 20 dans 5 à 10 %, à 5 points près entre classes** : archer étage 20 11,7 %, alchimiste étage 20 10,2 %, écart entre classes : étage 10 de 48,6 % à 54,5 %, étage 20 de 5,2 % à 11,7 %

### La matrice des classes (taux de victoire de la ligne contre la colonne)

| | Guer | Mage | Vole | Arch | Prêt | Alch | Invo | Bard | Dipl | Pugi | **Moyenne** |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 47 | 57 | 49 | 55 | 44 | 41 | 42 | 45 | 48 | 54 | **48,1 %** |
| Mage | 44 | 49 | 47 | 49 | 50 | 55 | 48 | 50 | 53 | 45 | **48,9 %** |
| Voleur | 48 | 52 | 49 | 49 | 51 | 57 | 48 | 51 | 46 | 45 | **49,7 %** |
| Archer | 42 | 50 | 51 | 48 | 47 | 57 | 51 | 52 | 51 | 42 | **49,1 %** |
| Prêtre | 53 | 51 | 48 | 52 | 51 | 41 | 48 | 46 | 54 | 47 | **49,0 %** |
| Alchimiste | 59 | 48 | 42 | 45 | 60 | 49 | 48 | 55 | 53 | 46 | **50,6 %** |
| Invocateur | 56 | 51 | 51 | 47 | 54 | 53 | 48 | 52 | 45 | 48 | **50,6 %** |
| Barde | 57 | 48 | 46 | 49 | 52 | 46 | 47 | 50 | 55 | 49 | **49,8 %** |
| Diplomate | 53 | 49 | 52 | 48 | 46 | 46 | 53 | 46 | 50 | 44 | **48,7 %** |
| Pugiliste | 43 | 57 | 52 | 55 | 55 | 56 | 50 | 52 | 57 | 49 | **52,5 %** |

### Les trois routes, l'usage des voies et la Tour, par classe

| Classe | Ruée | Éventail | Réactive | Voie 1 | Voie 2 | Voie 3 | Voie 4 | Voie 5 | Clé | Tour : étage 10 | étage 20 | étage moyen |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 37,8 % | 10,3 % | 48,1 % | 32,5 % | 43,8 % | 40,1 % | 80,5 % | 58,7 % | 93,8 % | 52,9 % | 5,5 % | 10,6 |
| Mage | 64,8 % | 22,3 % | 48,9 % | 25,2 % | 48,4 % | 49,8 % | 24,1 % | 22,5 % | 68,5 % | 48,6 % | 7,2 % | 10,4 |
| Voleur | 52,0 % | 28,0 % | 49,7 % | 35,6 % | 22,7 % | 48,1 % | 23,0 % | 35,7 % | 69,6 % | 53,5 % | 7,2 % | 10,8 |
| Archer | 53,3 % | 24,3 % | 49,1 % | 41,0 % | 32,7 % | 52,6 % | 19,9 % | 30,0 % | 66,6 % | 50,1 % | 11,7 % | 10,9 |
| Prêtre | 33,5 % | 13,8 % | 49,0 % | 31,8 % | 61,3 % | 36,7 % | 58,5 % | 71,1 % | 85,6 % | 52,0 % | 6,5 % | 10,4 |
| Alchimiste | 28,0 % | 14,2 % | 50,6 % | 41,3 % | 30,7 % | 47,3 % | 24,8 % | 58,7 % | 87,3 % | 54,5 % | 10,2 % | 11,1 |
| Invocateur | 55,8 % | 21,3 % | 50,6 % | 38,1 % | 25,5 % | 49,5 % | 34,5 % | 25,8 % | 64,0 % | 50,7 % | 9,0 % | 10,8 |
| Barde | 36,3 % | 16,5 % | 49,8 % | 37,0 % | 32,5 % | 34,9 % | 33,8 % | 63,0 % | 77,4 % | 50,8 % | 6,8 % | 10,6 |
| Diplomate | 27,0 % | 8,0 % | 48,7 % | 19,5 % | 55,4 % | 83,5 % | 34,6 % | 75,0 % | 87,3 % | 52,8 % | 5,2 % | 10,4 |
| Pugiliste | 14,8 % | 7,2 % | 52,5 % | 44,7 % | 34,8 % | 48,1 % | 75,9 % | 21,0 % | 89,7 % | 50,5 % | 8,9 % | 10,8 |

### Boutons touchés, et pourquoi

- pas des k calculés ensemble : le k d'une classe change aussi le duo dont elle est l'acolyte ; les duels au-delà de 58 % comptent aussi (effets mesurés à graines égales avant la passe 65)
- k_classe Guerrier : 0,815 → 0,817 (48,1 % de victoires)
- k_classe Mage : 0,875 → 0,877 (48,9 % de victoires)
- k_classe Voleur : 0,837 → 0,844 (49,7 % de victoires)
- k_classe Prêtre : 0,874 → 0,877 (49,0 % de victoires)
- k_classe Alchimiste : 1,069 → 1,059 (50,6 % de victoires)
- k_classe Invocateur : 0,967 → 0,969 (50,6 % de victoires)
- k_classe Barde : 1,081 → 1,079 (49,8 % de victoires)
- k_classe Pugiliste : 0,991 → 0,983 (52,5 % de victoires)
- Tour, Mage : facteur des monstres 0,727 → 0,716 (étage 10 dans 48,6 % des montées)
- Tour, Archer : pente des monstres 1,573 → 1,589 (étage 20 dans 11,7 % des montées)
- Tour, Alchimiste : pente des monstres 0,996 → 1,010 (étage 20 dans 10,2 % des montées)
- Tour, Alchimiste : facteur des monstres 0,963 → 0,970 (étage 10 dans 54,5 % des montées)
- Tour, Diplomate : pente des monstres 0,934 → 0,913 (étage 20 dans 5,2 % des montées)

## Passe 66 (graines à partir de 6600199)

**3 critères tenus sur 6.** 150000 combats de duel (médiane 10 tours), 0 combats non finis.

### Les six critères (section 11.2)

- ❌ **1. Chaque classe entre 47 % et 53 % de victoires** : guerrier 46,2 %, pugiliste 54,7 %
- ❌ **2. Aucune case de la matrice hors de 40 % – 60 %** : guerrier contre pretre 38,8 %, guerrier contre alchimiste 36,7 %, pretre contre guerrier 61,9 %, pretre contre alchimiste 39,7 %, alchimiste contre guerrier 60,1 %, alchimiste contre voleur 39,5 %
- ✅ **3. La route Réactive entre 40 % et 55 % (Ruée et Éventail : des repères, sans seuil)**
- ✅ **4. Chaque voie jouée dans 15 % des combats au moins, une Clé dans 60 %**
- ✅ **5. Longueur : médiane de 6 à 10 tours, 95 % finis avant le tour 20**
- ❌ **6. Tour : étage 10 dans 40 à 60 % des montées, étage 20 dans 5 à 10 %, à 5 points près entre classes** : écart entre classes : étage 10 de 44,4 % à 54,2 %, étage 20 de 5,8 % à 9,6 %

### La matrice des classes (taux de victoire de la ligne contre la colonne)

| | Guer | Mage | Vole | Arch | Prêt | Alch | Invo | Bard | Dipl | Pugi | **Moyenne** |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 51 | 53 | 47 | 55 | 39 | 37 | 43 | 42 | 40 | 55 | **46,2 %** |
| Mage | 49 | 51 | 49 | 50 | 49 | 55 | 46 | 49 | 47 | 45 | **49,1 %** |
| Voleur | 50 | 54 | 49 | 49 | 53 | 58 | 47 | 53 | 42 | 42 | **49,6 %** |
| Archer | 47 | 50 | 55 | 48 | 49 | 55 | 53 | 51 | 49 | 42 | **49,9 %** |
| Prêtre | 62 | 48 | 47 | 50 | 48 | 40 | 46 | 48 | 52 | 43 | **48,5 %** |
| Alchimiste | 60 | 47 | 39 | 43 | 57 | 50 | 45 | 52 | 48 | 41 | **48,3 %** |
| Invocateur | 57 | 52 | 51 | 50 | 52 | 53 | 49 | 51 | 43 | 46 | **50,4 %** |
| Barde | 58 | 49 | 46 | 50 | 53 | 44 | 49 | 51 | 50 | 45 | **49,5 %** |
| Diplomate | 59 | 52 | 59 | 51 | 51 | 52 | 54 | 52 | 50 | 49 | **52,9 %** |
| Pugiliste | 47 | 58 | 57 | 58 | 57 | 58 | 54 | 56 | 51 | 51 | **54,7 %** |

### Les trois routes, l'usage des voies et la Tour, par classe

| Classe | Ruée | Éventail | Réactive | Voie 1 | Voie 2 | Voie 3 | Voie 4 | Voie 5 | Clé | Tour : étage 10 | étage 20 | étage moyen |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 37,3 % | 11,8 % | 46,2 % | 33,1 % | 62,4 % | 35,5 % | 72,5 % | 61,7 % | 91,9 % | 44,4 % | 5,8 % | 9,8 |
| Mage | 60,3 % | 24,0 % | 49,1 % | 22,7 % | 48,3 % | 50,2 % | 24,9 % | 22,9 % | 69,2 % | 48,1 % | 9,1 % | 10,5 |
| Voleur | 48,0 % | 25,3 % | 49,6 % | 33,7 % | 22,2 % | 47,2 % | 17,9 % | 41,0 % | 68,4 % | 52,1 % | 7,2 % | 10,4 |
| Archer | 59,5 % | 24,0 % | 49,9 % | 42,9 % | 34,0 % | 52,0 % | 17,8 % | 30,6 % | 67,1 % | 49,5 % | 9,2 % | 10,7 |
| Prêtre | 38,0 % | 11,0 % | 48,5 % | 30,0 % | 65,5 % | 27,1 % | 55,7 % | 66,3 % | 84,7 % | 51,0 % | 7,4 % | 10,5 |
| Alchimiste | 27,5 % | 13,0 % | 48,3 % | 42,1 % | 29,7 % | 46,4 % | 24,0 % | 56,8 % | 87,3 % | 47,4 % | 6,7 % | 10,6 |
| Invocateur | 47,0 % | 26,8 % | 50,4 % | 39,3 % | 24,0 % | 43,5 % | 38,8 % | 25,2 % | 63,5 % | 52,8 % | 9,6 % | 10,9 |
| Barde | 41,3 % | 22,3 % | 49,5 % | 37,0 % | 31,4 % | 34,8 % | 33,4 % | 61,4 % | 77,1 % | 51,3 % | 8,8 % | 10,7 |
| Diplomate | 26,5 % | 9,5 % | 52,9 % | 18,9 % | 56,1 % | 82,2 % | 41,0 % | 71,9 % | 85,8 % | 54,2 % | 7,4 % | 10,7 |
| Pugiliste | 12,8 % | 6,5 % | 54,7 % | 33,8 % | 32,9 % | 46,7 % | 83,7 % | 19,0 % | 89,5 % | 48,9 % | 7,0 % | 10,6 |

### Boutons touchés, et pourquoi

- pas des k calculés ensemble : le k d'une classe change aussi le duo dont elle est l'acolyte ; les duels au-delà de 58 % comptent aussi (effets mesurés à graines égales avant la passe 65)
- k_classe Guerrier : 0,817 → 0,820 (46,2 % de victoires)
- k_classe Mage : 0,877 → 0,869 (49,1 % de victoires)
- k_classe Voleur : 0,844 → 0,846 (49,6 % de victoires)
- k_classe Archer : 0,897 → 0,894 (49,9 % de victoires)
- k_classe Prêtre : 0,877 → 0,890 (48,5 % de victoires)
- k_classe Alchimiste : 1,059 → 1,051 (48,3 % de victoires)
- k_classe Invocateur : 0,969 → 0,965 (50,4 % de victoires)
- k_classe Barde : 1,079 → 1,088 (49,5 % de victoires)
- k_classe Pugiliste : 0,983 → 0,974 (54,7 % de victoires)
- Tour, Guerrier : facteur des monstres 1,728 → 1,704 (étage 10 dans 44,4 % des montées)
- Tour, Voleur : facteur des monstres 0,992 → 0,994 (étage 10 dans 52,1 % des montées)
- Tour, Alchimiste : facteur des monstres 0,970 → 0,967 (étage 10 dans 47,4 % des montées)
- Tour, Invocateur : pente des monstres 1,155 → 1,179 (étage 20 dans 9,6 % des montées)
- Tour, Invocateur : facteur des monstres 0,923 → 0,929 (étage 10 dans 52,8 % des montées)
- Tour, Diplomate : facteur des monstres 1,394 → 1,424 (étage 10 dans 54,2 % des montées)

## Passe 67 (graines à partir de 6700202)

**3 critères tenus sur 6.** 150000 combats de duel (médiane 10 tours), 0 combats non finis.

### Les six critères (section 11.2)

- ❌ **1. Chaque classe entre 47 % et 53 % de victoires** : mage 53,2 %
- ❌ **2. Aucune case de la matrice hors de 40 % – 60 %** : guerrier contre pugiliste 61,3 %, voleur contre alchimiste 61,1 %, alchimiste contre voleur 39,8 %, alchimiste contre archer 39,9 %, pugiliste contre guerrier 37,0 %
- ✅ **3. La route Réactive entre 40 % et 55 % (Ruée et Éventail : des repères, sans seuil)**
- ✅ **4. Chaque voie jouée dans 15 % des combats au moins, une Clé dans 60 %**
- ✅ **5. Longueur : médiane de 6 à 10 tours, 95 % finis avant le tour 20**
- ❌ **6. Tour : étage 10 dans 40 à 60 % des montées, étage 20 dans 5 à 10 %, à 5 points près entre classes** : mage étage 20 11,0 %, archer étage 20 11,1 %, écart entre classes : étage 10 de 48,0 % à 56,2 %, étage 20 de 5,8 % à 11,1 %

### La matrice des classes (taux de victoire de la ligne contre la colonne)

| | Guer | Mage | Vole | Arch | Prêt | Alch | Invo | Bard | Dipl | Pugi | **Moyenne** |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 51 | 58 | 53 | 57 | 45 | 44 | 49 | 46 | 47 | 61 | **51,1 %** |
| Mage | 45 | 50 | 51 | 51 | 57 | 60 | 53 | 56 | 57 | 53 | **53,2 %** |
| Voleur | 47 | 52 | 53 | 47 | 52 | 61 | 51 | 52 | 45 | 52 | **51,3 %** |
| Archer | 41 | 46 | 53 | 51 | 49 | 59 | 53 | 49 | 51 | 52 | **50,3 %** |
| Prêtre | 59 | 46 | 47 | 50 | 49 | 46 | 54 | 48 | 53 | 52 | **50,4 %** |
| Alchimiste | 58 | 42 | 40 | 40 | 56 | 52 | 49 | 54 | 50 | 53 | **49,4 %** |
| Invocateur | 53 | 46 | 51 | 44 | 48 | 51 | 48 | 49 | 45 | 55 | **49,0 %** |
| Barde | 56 | 45 | 51 | 51 | 54 | 46 | 55 | 54 | 54 | 57 | **52,2 %** |
| Diplomate | 52 | 44 | 58 | 48 | 47 | 50 | 56 | 47 | 51 | 52 | **50,5 %** |
| Pugiliste | 37 | 47 | 50 | 46 | 49 | 50 | 46 | 46 | 50 | 53 | **47,5 %** |

### Les trois routes, l'usage des voies et la Tour, par classe

| Classe | Ruée | Éventail | Réactive | Voie 1 | Voie 2 | Voie 3 | Voie 4 | Voie 5 | Clé | Tour : étage 10 | étage 20 | étage moyen |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 43,3 % | 16,3 % | 51,1 % | 34,7 % | 51,7 % | 39,9 % | 75,6 % | 59,5 % | 93,2 % | 55,2 % | 6,2 % | 10,7 |
| Mage | 56,3 % | 20,3 % | 53,2 % | 22,8 % | 50,9 % | 49,3 % | 20,4 % | 18,9 % | 66,6 % | 48,3 % | 11,0 % | 10,7 |
| Voleur | 48,8 % | 25,3 % | 51,3 % | 35,0 % | 20,6 % | 49,5 % | 24,3 % | 35,7 % | 69,7 % | 56,2 % | 5,8 % | 10,6 |
| Archer | 53,0 % | 25,8 % | 50,3 % | 36,8 % | 30,7 % | 55,2 % | 18,3 % | 31,1 % | 64,9 % | 48,0 % | 11,1 % | 10,8 |
| Prêtre | 36,8 % | 13,3 % | 50,4 % | 30,9 % | 65,6 % | 28,1 % | 57,3 % | 66,2 % | 84,6 % | 52,6 % | 8,7 % | 10,8 |
| Alchimiste | 29,8 % | 14,8 % | 49,4 % | 47,2 % | 30,0 % | 46,6 % | 25,6 % | 52,3 % | 86,8 % | 51,4 % | 7,6 % | 10,9 |
| Invocateur | 47,5 % | 26,0 % | 49,0 % | 33,3 % | 24,4 % | 52,1 % | 35,6 % | 25,1 % | 63,2 % | 51,3 % | 6,7 % | 10,5 |
| Barde | 36,5 % | 22,5 % | 52,2 % | 38,2 % | 29,6 % | 35,4 % | 34,4 % | 62,4 % | 76,6 % | 50,9 % | 9,4 % | 10,8 |
| Diplomate | 23,3 % | 6,3 % | 50,5 % | 20,0 % | 57,3 % | 82,5 % | 34,3 % | 74,4 % | 87,1 % | 52,7 % | 6,6 % | 10,3 |
| Pugiliste | 14,5 % | 7,0 % | 47,5 % | 36,3 % | 36,2 % | 57,5 % | 73,7 % | 22,5 % | 89,3 % | 50,5 % | 7,2 % | 10,6 |

### Boutons touchés, et pourquoi

- pas des k calculés ensemble : le k d'une classe change aussi le duo dont elle est l'acolyte ; les duels au-delà de 58 % comptent aussi (effets mesurés à graines égales avant la passe 65)
- k_classe Guerrier : 0,820 → 0,812 (51,1 % de victoires)
- k_classe Voleur : 0,846 → 0,820 (51,3 % de victoires)
- k_classe Archer : 0,894 → 0,902 (50,3 % de victoires)
- k_classe Prêtre : 0,890 → 0,893 (50,4 % de victoires)
- k_classe Alchimiste : 1,051 → 1,075 (49,4 % de victoires)
- k_classe Invocateur : 0,965 → 0,964 (49,0 % de victoires)
- k_classe Barde : 1,088 → 1,074 (52,2 % de victoires)
- k_classe Pugiliste : 0,974 → 0,986 (47,5 % de victoires)
- Tour, Guerrier : facteur des monstres 1,704 → 1,712 (étage 10 dans 55,2 % des montées)
- Tour, Mage : pente des monstres 1,245 → 1,288 (étage 20 dans 11,0 % des montées)
- Tour, Mage : facteur des monstres 0,716 → 0,703 (étage 10 dans 48,3 % des montées)
- Tour, Voleur : facteur des monstres 0,994 → 0,998 (étage 10 dans 56,2 % des montées)
- Tour, Archer : pente des monstres 1,589 → 1,604 (étage 20 dans 11,1 % des montées)
- Tour, Archer : facteur des monstres 0,596 → 0,585 (étage 10 dans 48,0 % des montées)

## Après la passe 67 : un combat sans fin, et l'IA corrigée

Les passes 62 à 67 n'ont pas fait mieux que la vérification finale de la PR #39 (les duels hors fourchette changent d'une passe à l'autre : Guerrier contre Pugiliste, Alchimiste contre Guerrier, Voleur contre Alchimiste, Prêtre contre Guerrier). La passe 65 a trouvé un combat qui ne finissait pas en 100 tours : deux Prêtres seuls, leurs Mages tombés au tour 4. Le moyeu du Prêtre soigne, et sa voie de dégâts, en forme persistante, ne pose que des Saignements ; chacun retirait le Saignement de l'autre par une Purge avant qu'il ne fasse mal. L'IA ne comptait pas la mort subite dans la valeur d'un DoT (le moteur, si) : elle préférait la Purge même au tour 99, où le Saignement aurait fait 18 fois ses dégâts. Corrigé (le total d'un DoT posé est multiplié par la mort subite du tour, comme les dégâts directs) : le même combat finit au tour 14.

Les données repartent de celles de la PR #39 (vérifiées), avec l'IA corrigée et une nouvelle mesure des effets des k.

## Passe 68 (graines à partir de 6800205)

**4 critères tenus sur 6.** 150000 combats de duel (médiane 10 tours), 0 combats non finis.

### Les six critères (section 11.2)

- ✅ **1. Chaque classe entre 47 % et 53 % de victoires**
- ❌ **2. Aucune case de la matrice hors de 40 % – 60 %** : guerrier contre alchimiste 38,7 %, guerrier contre pugiliste 60,5 %, alchimiste contre pretre 60,6 %, pugiliste contre guerrier 38,1 %
- ✅ **3. La route Réactive entre 40 % et 55 % (Ruée et Éventail : des repères, sans seuil)**
- ✅ **4. Chaque voie jouée dans 15 % des combats au moins, une Clé dans 60 %**
- ✅ **5. Longueur : médiane de 6 à 10 tours, 95 % finis avant le tour 20**
- ❌ **6. Tour : étage 10 dans 40 à 60 % des montées, étage 20 dans 5 à 10 %, à 5 points près entre classes** : barde étage 20 10,6 %, diplomate étage 20 4,7 %, écart entre classes : étage 10 de 49,2 % à 54,5 %, étage 20 de 4,7 % à 10,6 %

### La matrice des classes (taux de victoire de la ligne contre la colonne)

| | Guer | Mage | Vole | Arch | Prêt | Alch | Invo | Bard | Dipl | Pugi | **Moyenne** |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 50 | 56 | 49 | 57 | 44 | 39 | 42 | 45 | 47 | 60 | **48,9 %** |
| Mage | 42 | 52 | 46 | 48 | 51 | 53 | 47 | 52 | 50 | 50 | **49,0 %** |
| Voleur | 47 | 52 | 48 | 46 | 52 | 59 | 46 | 53 | 44 | 49 | **49,6 %** |
| Archer | 42 | 51 | 53 | 50 | 48 | 55 | 52 | 51 | 50 | 51 | **50,3 %** |
| Prêtre | 56 | 52 | 49 | 53 | 50 | 43 | 47 | 49 | 53 | 51 | **50,4 %** |
| Alchimiste | 59 | 46 | 41 | 45 | 61 | 50 | 48 | 57 | 49 | 48 | **50,5 %** |
| Invocateur | 58 | 55 | 51 | 49 | 54 | 51 | 48 | 53 | 47 | 52 | **51,9 %** |
| Barde | 56 | 48 | 47 | 49 | 53 | 44 | 45 | 50 | 52 | 50 | **49,4 %** |
| Diplomate | 53 | 53 | 55 | 51 | 47 | 49 | 56 | 49 | 49 | 51 | **51,3 %** |
| Pugiliste | 38 | 50 | 49 | 51 | 51 | 51 | 46 | 48 | 48 | 48 | **48,0 %** |

### Les trois routes, l'usage des voies et la Tour, par classe

| Classe | Ruée | Éventail | Réactive | Voie 1 | Voie 2 | Voie 3 | Voie 4 | Voie 5 | Clé | Tour : étage 10 | étage 20 | étage moyen |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 39,8 % | 15,5 % | 48,9 % | 38,1 % | 46,1 % | 30,5 % | 79,3 % | 59,8 % | 93,8 % | 49,8 % | 5,0 % | 10,4 |
| Mage | 50,7 % | 19,5 % | 49,0 % | 25,4 % | 48,9 % | 49,4 % | 25,5 % | 22,4 % | 70,3 % | 51,2 % | 9,0 % | 10,7 |
| Voleur | 50,2 % | 25,5 % | 49,6 % | 35,7 % | 23,6 % | 47,5 % | 23,1 % | 37,9 % | 70,8 % | 52,0 % | 5,0 % | 10,1 |
| Archer | 48,8 % | 18,5 % | 50,3 % | 45,0 % | 30,8 % | 51,8 % | 20,8 % | 31,9 % | 68,7 % | 51,4 % | 9,5 % | 10,8 |
| Prêtre | 30,8 % | 8,5 % | 50,4 % | 29,1 % | 63,9 % | 36,0 % | 56,3 % | 72,0 % | 85,3 % | 49,8 % | 6,1 % | 10,2 |
| Alchimiste | 37,8 % | 19,5 % | 50,5 % | 44,1 % | 30,9 % | 45,4 % | 25,4 % | 61,4 % | 87,2 % | 49,9 % | 5,6 % | 10,5 |
| Invocateur | 47,5 % | 21,8 % | 51,9 % | 36,7 % | 24,8 % | 37,5 % | 50,5 % | 26,2 % | 65,1 % | 51,3 % | 7,5 % | 10,6 |
| Barde | 34,0 % | 17,5 % | 49,4 % | 36,8 % | 31,3 % | 35,3 % | 34,6 % | 63,5 % | 77,6 % | 49,2 % | 10,6 % | 10,7 |
| Diplomate | 32,3 % | 12,0 % | 51,3 % | 21,7 % | 55,7 % | 82,9 % | 43,0 % | 70,0 % | 85,3 % | 53,4 % | 4,7 % | 10,3 |
| Pugiliste | 15,5 % | 6,0 % | 48,0 % | 36,2 % | 33,0 % | 51,4 % | 80,4 % | 21,4 % | 89,8 % | 54,5 % | 7,6 % | 10,9 |

### Boutons touchés, et pourquoi

- pas des k calculés ensemble : le k d'une classe change aussi le duo dont elle est l'acolyte ; les duels au-delà de 58 % comptent aussi (effets mesurés à graines égales avant la passe 68)
- k_classe Guerrier : 0,826 → 0,827 (48,9 % de victoires)
- k_classe Mage : 0,875 → 0,878 (49,0 % de victoires)
- k_classe Voleur : 0,859 → 0,835 (49,6 % de victoires)
- k_classe Archer : 0,899 → 0,902 (50,3 % de victoires)
- k_classe Alchimiste : 1,058 → 1,062 (50,5 % de victoires)
- k_classe Invocateur : 0,975 → 0,966 (51,9 % de victoires)
- k_classe Barde : 1,076 → 1,070 (49,4 % de victoires)
- k_classe Diplomate : 1,178 → 1,200 (51,3 % de victoires)
- k_classe Pugiliste : 0,974 → 0,985 (48,0 % de victoires)
- Tour, Guerrier : pente des monstres 0,781 → 0,772 (étage 20 dans 5,0 % des montées)
- Tour, Voleur : pente des monstres 0,469 → 0,458 (étage 20 dans 5,0 % des montées)
- Tour, Archer : pente des monstres 1,563 → 1,571 (étage 20 dans 9,5 % des montées)
- Tour, Barde : pente des monstres 1,561 → 1,609 (étage 20 dans 10,6 % des montées)
- Tour, Barde : facteur des monstres 0,718 → 0,716 (étage 10 dans 49,2 % des montées)
- Tour, Diplomate : pente des monstres 0,955 → 0,929 (étage 20 dans 4,7 % des montées)
- Tour, Diplomate : facteur des monstres 1,373 → 1,388 (étage 10 dans 53,4 % des montées)
- Tour, Pugiliste : facteur des monstres 0,900 → 0,903 (étage 10 dans 54,5 % des montées)

## Passe 69 (graines à partir de 6900208)

**3 critères tenus sur 6.** 150000 combats de duel (médiane 10 tours), 0 combats non finis.

### Les six critères (section 11.2)

- ❌ **1. Chaque classe entre 47 % et 53 % de victoires** : archer 54,4 %
- ❌ **2. Aucune case de la matrice hors de 40 % – 60 %** : archer contre voleur 61,9 %, archer contre alchimiste 62,9 %, archer contre invocateur 60,1 %, alchimiste contre archer 39,3 %
- ✅ **3. La route Réactive entre 40 % et 55 % (Ruée et Éventail : des repères, sans seuil)**
- ✅ **4. Chaque voie jouée dans 15 % des combats au moins, une Clé dans 60 %**
- ✅ **5. Longueur : médiane de 6 à 10 tours, 95 % finis avant le tour 20**
- ❌ **6. Tour : étage 10 dans 40 à 60 % des montées, étage 20 dans 5 à 10 %, à 5 points près entre classes** : voleur étage 20 4,5 %, écart entre classes : étage 10 de 42,3 % à 52,9 %, étage 20 de 4,5 % à 9,1 %

### La matrice des classes (taux de victoire de la ligne contre la colonne)

| | Guer | Mage | Vole | Arch | Prêt | Alch | Invo | Bard | Dipl | Pugi | **Moyenne** |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 50 | 56 | 51 | 56 | 43 | 43 | 46 | 47 | 49 | 56 | **49,7 %** |
| Mage | 44 | 50 | 52 | 48 | 52 | 58 | 53 | 54 | 55 | 46 | **51,3 %** |
| Voleur | 45 | 46 | 52 | 41 | 47 | 58 | 47 | 49 | 43 | 44 | **47,1 %** |
| Archer | 46 | 53 | 62 | 50 | 50 | 63 | 60 | 57 | 55 | 49 | **54,4 %** |
| Prêtre | 56 | 45 | 53 | 51 | 49 | 40 | 51 | 49 | 54 | 47 | **49,6 %** |
| Alchimiste | 58 | 42 | 43 | 39 | 57 | 48 | 49 | 53 | 50 | 42 | **48,1 %** |
| Invocateur | 55 | 45 | 53 | 43 | 50 | 50 | 49 | 49 | 44 | 45 | **48,3 %** |
| Barde | 54 | 44 | 48 | 44 | 51 | 44 | 52 | 50 | 53 | 44 | **48,5 %** |
| Diplomate | 51 | 48 | 58 | 43 | 44 | 44 | 56 | 43 | 50 | 45 | **48,4 %** |
| Pugiliste | 42 | 51 | 56 | 50 | 52 | 58 | 55 | 54 | 55 | 50 | **52,4 %** |

### Les trois routes, l'usage des voies et la Tour, par classe

| Classe | Ruée | Éventail | Réactive | Voie 1 | Voie 2 | Voie 3 | Voie 4 | Voie 5 | Clé | Tour : étage 10 | étage 20 | étage moyen |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 36,0 % | 9,5 % | 49,7 % | 34,3 % | 41,6 % | 41,7 % | 77,8 % | 57,5 % | 93,6 % | 52,9 % | 7,0 % | 10,8 |
| Mage | 63,0 % | 23,5 % | 51,3 % | 23,6 % | 47,8 % | 50,0 % | 24,1 % | 21,1 % | 66,5 % | 48,3 % | 9,1 % | 10,3 |
| Voleur | 44,0 % | 23,0 % | 47,1 % | 34,0 % | 22,4 % | 48,9 % | 25,6 % | 33,4 % | 69,7 % | 48,6 % | 4,5 % | 9,9 |
| Archer | 51,2 % | 23,0 % | 54,4 % | 33,3 % | 36,8 % | 47,6 % | 21,4 % | 43,2 % | 67,1 % | 51,6 % | 7,6 % | 10,7 |
| Prêtre | 42,0 % | 13,8 % | 49,6 % | 28,9 % | 65,9 % | 36,0 % | 56,5 % | 68,9 % | 84,8 % | 47,3 % | 5,0 % | 10,0 |
| Alchimiste | 26,0 % | 10,8 % | 48,1 % | 44,3 % | 29,1 % | 46,5 % | 23,4 % | 61,9 % | 86,8 % | 47,5 % | 6,2 % | 10,4 |
| Invocateur | 52,3 % | 19,3 % | 48,3 % | 38,0 % | 23,9 % | 49,1 % | 36,2 % | 24,5 % | 63,5 % | 50,8 % | 8,7 % | 10,7 |
| Barde | 37,8 % | 15,8 % | 48,5 % | 36,3 % | 33,2 % | 34,0 % | 32,4 % | 64,6 % | 76,9 % | 42,3 % | 6,9 % | 9,9 |
| Diplomate | 27,3 % | 9,5 % | 48,4 % | 20,3 % | 55,7 % | 83,8 % | 33,3 % | 75,7 % | 87,0 % | 52,0 % | 6,0 % | 10,3 |
| Pugiliste | 15,8 % | 6,3 % | 52,4 % | 33,9 % | 32,8 % | 46,6 % | 84,6 % | 20,0 % | 89,1 % | 47,1 % | 6,0 % | 10,2 |

### Boutons touchés, et pourquoi

- pas des k calculés ensemble : le k d'une classe change aussi le duo dont elle est l'acolyte ; les duels au-delà de 58 % comptent aussi (effets mesurés à graines égales avant la passe 68)
- k_classe Guerrier : 0,827 → 0,821 (49,7 % de victoires)
- k_classe Mage : 0,878 → 0,882 (51,3 % de victoires)
- k_classe Voleur : 0,835 → 0,847 (47,1 % de victoires)
- k_classe Archer : 0,902 → 0,895 (54,4 % de victoires)
- k_classe Prêtre : 0,880 → 0,878 (49,6 % de victoires)
- k_classe Alchimiste : 1,062 → 1,059 (48,1 % de victoires)
- k_classe Invocateur : 0,966 → 0,967 (48,3 % de victoires)
- k_classe Barde : 1,070 → 1,079 (48,5 % de victoires)
- k_classe Diplomate : 1,200 → 1,199 (48,4 % de victoires)
- k_classe Pugiliste : 0,985 → 0,976 (52,4 % de victoires)
- Tour, Guerrier : facteur des monstres 1,728 → 1,737 (étage 10 dans 52,9 % des montées)
- Tour, Voleur : pente des monstres 0,458 → 0,444 (étage 20 dans 4,5 % des montées)
- Tour, Archer : facteur des monstres 0,610 → 0,615 (étage 10 dans 51,6 % des montées)
- Tour, Prêtre : pente des monstres 0,947 → 0,936 (étage 20 dans 5,0 % des montées)
- Tour, Barde : facteur des monstres 0,716 → 0,710 (étage 10 dans 42,3 % des montées)
- Tour, Diplomate : facteur des monstres 1,388 → 1,410 (étage 10 dans 52,0 % des montées)

## Passe 70 (graines à partir de 7000211)

**4 critères tenus sur 6.** 150000 combats de duel (médiane 10 tours), 0 combats non finis.

### Les six critères (section 11.2)

- ✅ **1. Chaque classe entre 47 % et 53 % de victoires**
- ❌ **2. Aucune case de la matrice hors de 40 % – 60 %** : guerrier contre pretre 38,5 %, guerrier contre alchimiste 36,3 %, guerrier contre pugiliste 62,1 %, pretre contre guerrier 60,7 %, alchimiste contre guerrier 61,9 %, pugiliste contre guerrier 39,7 %
- ✅ **3. La route Réactive entre 40 % et 55 % (Ruée et Éventail : des repères, sans seuil)**
- ✅ **4. Chaque voie jouée dans 15 % des combats au moins, une Clé dans 60 %**
- ✅ **5. Longueur : médiane de 6 à 10 tours, 95 % finis avant le tour 20**
- ❌ **6. Tour : étage 10 dans 40 à 60 % des montées, étage 20 dans 5 à 10 %, à 5 points près entre classes** : écart entre classes : étage 10 de 46,8 % à 54,4 %, étage 20 de 5,0 % à 9,1 %

### La matrice des classes (taux de victoire de la ligne contre la colonne)

| | Guer | Mage | Vole | Arch | Prêt | Alch | Invo | Bard | Dipl | Pugi | **Moyenne** |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 50 | 50 | 51 | 57 | 39 | 36 | 44 | 43 | 44 | 62 | **47,6 %** |
| Mage | 47 | 51 | 51 | 52 | 49 | 58 | 52 | 53 | 54 | 51 | **51,8 %** |
| Voleur | 51 | 47 | 53 | 45 | 48 | 58 | 50 | 53 | 44 | 51 | **50,0 %** |
| Archer | 45 | 49 | 53 | 49 | 44 | 57 | 54 | 50 | 53 | 50 | **50,3 %** |
| Prêtre | 61 | 49 | 53 | 57 | 48 | 44 | 51 | 50 | 53 | 51 | **51,8 %** |
| Alchimiste | 62 | 41 | 42 | 44 | 55 | 49 | 50 | 52 | 52 | 48 | **49,4 %** |
| Invocateur | 59 | 47 | 53 | 45 | 48 | 50 | 48 | 50 | 45 | 53 | **49,6 %** |
| Barde | 57 | 45 | 46 | 48 | 50 | 42 | 49 | 49 | 55 | 52 | **49,2 %** |
| Diplomate | 53 | 46 | 56 | 48 | 42 | 46 | 55 | 47 | 50 | 48 | **49,0 %** |
| Pugiliste | 40 | 46 | 52 | 48 | 46 | 52 | 49 | 48 | 49 | 51 | **48,1 %** |

### Les trois routes, l'usage des voies et la Tour, par classe

| Classe | Ruée | Éventail | Réactive | Voie 1 | Voie 2 | Voie 3 | Voie 4 | Voie 5 | Clé | Tour : étage 10 | étage 20 | étage moyen |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 42,5 % | 14,2 % | 47,6 % | 36,5 % | 50,1 % | 41,7 % | 75,4 % | 57,7 % | 93,0 % | 47,5 % | 6,4 % | 10,2 |
| Mage | 63,5 % | 27,8 % | 51,8 % | 23,4 % | 47,5 % | 51,8 % | 25,0 % | 19,7 % | 65,6 % | 49,8 % | 8,8 % | 10,5 |
| Voleur | 50,7 % | 25,0 % | 50,0 % | 34,1 % | 22,4 % | 47,3 % | 24,1 % | 37,9 % | 68,6 % | 54,4 % | 5,0 % | 10,5 |
| Archer | 60,8 % | 24,3 % | 50,3 % | 29,6 % | 33,6 % | 54,4 % | 19,7 % | 37,2 % | 66,2 % | 46,8 % | 7,1 % | 10,2 |
| Prêtre | 32,3 % | 14,0 % | 51,8 % | 28,2 % | 70,1 % | 24,7 % | 54,9 % | 65,6 % | 84,2 % | 53,9 % | 7,9 % | 10,8 |
| Alchimiste | 36,0 % | 16,0 % | 49,4 % | 45,5 % | 28,8 % | 46,6 % | 24,7 % | 60,2 % | 86,8 % | 46,9 % | 5,3 % | 10,5 |
| Invocateur | 48,5 % | 23,8 % | 49,6 % | 35,6 % | 24,4 % | 49,9 % | 37,3 % | 26,3 % | 63,8 % | 51,1 % | 8,0 % | 10,6 |
| Barde | 35,3 % | 17,5 % | 49,2 % | 36,0 % | 31,7 % | 35,7 % | 33,8 % | 64,7 % | 77,5 % | 51,2 % | 9,1 % | 10,7 |
| Diplomate | 31,8 % | 11,5 % | 49,0 % | 20,2 % | 56,6 % | 83,8 % | 34,6 % | 76,0 % | 86,7 % | 47,7 % | 6,9 % | 10,2 |
| Pugiliste | 16,5 % | 6,8 % | 48,1 % | 40,4 % | 31,3 % | 53,3 % | 77,1 % | 21,9 % | 89,4 % | 49,7 % | 7,8 % | 10,6 |

### Boutons touchés, et pourquoi

- pas des k calculés ensemble : le k d'une classe change aussi le duo dont elle est l'acolyte ; les duels au-delà de 58 % comptent aussi (effets mesurés à graines égales avant la passe 68)
- k_classe Mage : 0,882 → 0,871 (51,8 % de victoires)
- k_classe Voleur : 0,847 → 0,830 (50,0 % de victoires)
- k_classe Archer : 0,895 → 0,900 (50,3 % de victoires)
- k_classe Prêtre : 0,878 → 0,886 (51,8 % de victoires)
- k_classe Alchimiste : 1,059 → 1,053 (49,4 % de victoires)
- k_classe Invocateur : 0,967 → 0,965 (49,6 % de victoires)
- k_classe Barde : 1,079 → 1,071 (49,2 % de victoires)
- k_classe Diplomate : 1,199 → 1,200 (49,0 % de victoires)
- k_classe Pugiliste : 0,976 → 0,990 (48,1 % de victoires)
- Tour, Guerrier : facteur des monstres 1,737 → 1,734 (étage 10 dans 47,5 % des montées)
- Tour, Voleur : pente des monstres 0,444 → 0,433 (étage 20 dans 5,0 % des montées)
- Tour, Voleur : facteur des monstres 0,984 → 0,989 (étage 10 dans 54,4 % des montées)
- Tour, Archer : facteur des monstres 0,615 → 0,612 (étage 10 dans 46,8 % des montées)
- Tour, Prêtre : facteur des monstres 1,137 → 1,143 (étage 10 dans 53,9 % des montées)
- Tour, Alchimiste : pente des monstres 1,028 → 1,022 (étage 20 dans 5,3 % des montées)
- Tour, Alchimiste : facteur des monstres 0,981 → 0,978 (étage 10 dans 46,9 % des montées)
- Tour, Diplomate : facteur des monstres 1,410 → 1,402 (étage 10 dans 47,7 % des montées)

## Vérification finale avec l'IA corrigée (données de la PR #39), sur des graines jamais vues (3 000 combats par case, 4 000 montées par classe)

**5 critères tenus sur 6.** 300000 combats de duel (médiane 10 tours), 0 combats non finis.

### Les six critères (section 11.2)

- ✅ **1. Chaque classe entre 47 % et 53 % de victoires**
- ❌ **2. Aucune case de la matrice hors de 40 % – 60 %** : pugiliste contre guerrier 39,9 %
- ✅ **3. La route Réactive entre 40 % et 55 % (Ruée et Éventail : des repères, sans seuil)**
- ✅ **4. Chaque voie jouée dans 15 % des combats au moins, une Clé dans 60 %**
- ✅ **5. Longueur : médiane de 6 à 10 tours, 95 % finis avant le tour 20**
- ✅ **6. Tour : étage 10 dans 40 à 60 % des montées, étage 20 dans 5 à 10 %, à 5 points près entre classes**

### La matrice des classes (taux de victoire de la ligne contre la colonne)

| | Guer | Mage | Vole | Arch | Prêt | Alch | Invo | Bard | Dipl | Pugi | **Moyenne** |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 50 | 55 | 51 | 56 | 42 | 40 | 42 | 43 | 48 | 59 | **48,6 %** |
| Mage | 43 | 51 | 49 | 50 | 50 | 54 | 49 | 52 | 50 | 51 | **50,0 %** |
| Voleur | 49 | 52 | 50 | 47 | 50 | 58 | 48 | 52 | 41 | 49 | **49,4 %** |
| Archer | 43 | 49 | 52 | 48 | 47 | 56 | 50 | 52 | 49 | 51 | **49,9 %** |
| Prêtre | 57 | 51 | 50 | 56 | 50 | 44 | 48 | 49 | 55 | 51 | **51,0 %** |
| Alchimiste | 59 | 47 | 41 | 43 | 57 | 51 | 48 | 55 | 50 | 49 | **50,1 %** |
| Invocateur | 57 | 53 | 54 | 50 | 50 | 52 | 51 | 53 | 44 | 54 | **51,8 %** |
| Barde | 56 | 48 | 46 | 49 | 51 | 44 | 46 | 50 | 52 | 53 | **49,5 %** |
| Diplomate | 53 | 51 | 57 | 50 | 47 | 50 | 55 | 48 | 50 | 53 | **51,6 %** |
| Pugiliste | 40 | 50 | 51 | 48 | 48 | 50 | 47 | 49 | 47 | 51 | **48,2 %** |

### Les trois routes, l'usage des voies et la Tour, par classe

| Classe | Ruée | Éventail | Réactive | Voie 1 | Voie 2 | Voie 3 | Voie 4 | Voie 5 | Clé | Tour : étage 10 | étage 20 | étage moyen |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 37,7 % | 12,9 % | 48,6 % | 37,2 % | 44,4 % | 31,1 % | 80,4 % | 57,8 % | 93,2 % | 50,7 % | 5,6 % | 10,5 |
| Mage | 57,2 % | 23,0 % | 50,0 % | 24,2 % | 49,2 % | 50,5 % | 24,1 % | 22,9 % | 70,3 % | 49,9 % | 9,4 % | 10,6 |
| Voleur | 50,7 % | 22,9 % | 49,4 % | 34,1 % | 24,0 % | 47,3 % | 23,4 % | 37,8 % | 70,8 % | 51,7 % | 5,1 % | 10,2 |
| Archer | 55,4 % | 23,7 % | 49,9 % | 43,3 % | 34,0 % | 51,3 % | 19,8 % | 29,6 % | 68,3 % | 50,2 % | 9,4 % | 10,7 |
| Prêtre | 31,5 % | 14,4 % | 51,0 % | 28,1 % | 64,7 % | 35,9 % | 57,0 % | 70,2 % | 85,8 % | 49,6 % | 6,2 % | 10,2 |
| Alchimiste | 30,8 % | 13,8 % | 50,1 % | 44,5 % | 29,2 % | 45,4 % | 24,4 % | 60,9 % | 87,5 % | 48,0 % | 6,8 % | 10,6 |
| Invocateur | 48,8 % | 22,6 % | 51,8 % | 37,8 % | 24,4 % | 38,3 % | 49,0 % | 25,9 % | 64,9 % | 51,5 % | 8,5 % | 10,7 |
| Barde | 37,4 % | 21,9 % | 49,5 % | 36,3 % | 31,9 % | 35,5 % | 34,7 % | 64,0 % | 77,7 % | 49,9 % | 8,4 % | 10,5 |
| Diplomate | 31,6 % | 13,6 % | 51,6 % | 21,8 % | 55,5 % | 82,8 % | 41,3 % | 71,4 % | 86,0 % | 52,1 % | 6,1 % | 10,3 |
| Pugiliste | 14,6 % | 5,6 % | 48,2 % | 34,5 % | 31,6 % | 53,4 % | 80,4 % | 21,4 % | 90,1 % | 52,8 % | 7,7 % | 10,8 |

### Boutons touchés, et pourquoi

Aucun (mesure seule).

## Passe 71 (graines à partir de 7100214)

**2 critères tenus sur 6.** 50000 combats de duel (médiane 20 tours), 0 combats non finis.

### Les six critères (section 11.2)

- ❌ **1. Chaque classe entre 47 % et 53 % de victoires** : guerrier 45,7 %, mage 43,9 %, voleur 44,6 %, archer 41,7 %, alchimiste 63,5 %, barde 56,7 %, diplomate 54,4 %, pugiliste 39,7 %
- ❌ **2. Aucune case de la matrice hors de 40 % – 60 %** : guerrier contre mage 62,0 %, guerrier contre archer 64,8 %, guerrier contre pretre 36,6 %, guerrier contre alchimiste 25,4 %, guerrier contre invocateur 35,6 %, guerrier contre barde 32,8 %, guerrier contre diplomate 32,0 %, guerrier contre pugiliste 64,2 %, mage contre pretre 38,6 %, mage contre alchimiste 34,2 %, mage contre invocateur 38,0 %, mage contre barde 33,6 %, mage contre diplomate 38,2 %, voleur contre alchimiste 36,8 %, voleur contre barde 38,4 %, voleur contre diplomate 33,4 %, archer contre guerrier 37,6 %, archer contre pretre 29,8 %, archer contre alchimiste 34,0 %, archer contre invocateur 37,4 %, archer contre barde 33,8 %, archer contre diplomate 38,2 %, pretre contre guerrier 63,4 %, pretre contre archer 66,0 %, pretre contre alchimiste 22,0 %, pretre contre barde 36,2 %, pretre contre pugiliste 60,2 %, alchimiste contre guerrier 71,4 %, alchimiste contre mage 68,0 %, alchimiste contre archer 63,0 %, alchimiste contre pretre 71,4 %, alchimiste contre invocateur 63,2 %, alchimiste contre diplomate 61,2 %, alchimiste contre pugiliste 69,2 %, invocateur contre guerrier 62,6 %, invocateur contre mage 63,4 %, invocateur contre alchimiste 36,0 %, invocateur contre pugiliste 65,2 %, barde contre guerrier 67,2 %, barde contre voleur 61,2 %, barde contre archer 64,8 %, barde contre pretre 60,4 %, barde contre alchimiste 34,4 %, barde contre pugiliste 66,8 %, diplomate contre guerrier 61,0 %, diplomate contre mage 62,8 %, diplomate contre voleur 64,2 %, diplomate contre archer 61,4 %, diplomate contre alchimiste 36,0 %, diplomate contre pugiliste 62,0 %, pugiliste contre guerrier 32,6 %, pugiliste contre alchimiste 30,6 %, pugiliste contre invocateur 38,2 %, pugiliste contre barde 30,4 %, pugiliste contre diplomate 37,8 %
- ❌ **3. La route Réactive entre 40 % et 55 % (Ruée et Éventail : des repères, sans seuil)** : alchimiste Réactive 63,5 %, barde Réactive 56,7 %, pugiliste Réactive 39,7 %
- ✅ **4. Chaque voie jouée dans 15 % des combats au moins, une Clé dans 60 %**
- ✅ **5. Longueur : médiane de 18 à 22 tours, 95 % finis avant le tour 30**
- ❌ **6. Tour : étage 10 dans 40 à 60 % des montées, étage 20 dans 5 à 10 %, à 5 points près entre classes** : guerrier étage 10 60,3 %, guerrier étage 20 11,0 %, mage étage 20 10,3 %, voleur étage 10 76,0 %, voleur étage 20 14,7 %, archer étage 10 64,0 %, pretre étage 10 64,7 %, pretre étage 20 11,7 %, alchimiste étage 10 74,7 %, alchimiste étage 20 22,3 %, invocateur étage 10 77,3 %, invocateur étage 20 26,0 %, barde étage 10 82,7 %, barde étage 20 22,7 %, diplomate étage 10 76,3 %, diplomate étage 20 21,0 %, pugiliste étage 10 80,0 %, pugiliste étage 20 21,3 %, écart entre classes : étage 10 de 60,0 % à 82,7 %, étage 20 de 9,7 % à 26,0 %

### La matrice des classes (taux de victoire de la ligne contre la colonne)

| | Guer | Mage | Vole | Arch | Prêt | Alch | Invo | Bard | Dipl | Pugi | **Moyenne** |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 54 | 62 | 50 | 65 | 37 | 25 | 36 | 33 | 32 | 64 | **45,7 %** |
| Mage | 42 | 49 | 50 | 56 | 39 | 34 | 38 | 34 | 38 | 60 | **43,9 %** |
| Voleur | 46 | 51 | 50 | 47 | 46 | 37 | 41 | 38 | 33 | 56 | **44,6 %** |
| Archer | 38 | 46 | 53 | 52 | 30 | 34 | 37 | 34 | 38 | 55 | **41,7 %** |
| Prêtre | 63 | 59 | 55 | 66 | 46 | 22 | 49 | 36 | 48 | 60 | **50,5 %** |
| Alchimiste | 71 | 68 | 59 | 63 | 71 | 49 | 63 | 60 | 61 | 69 | **63,5 %** |
| Invocateur | 63 | 63 | 57 | 60 | 53 | 36 | 47 | 45 | 40 | 65 | **53,0 %** |
| Barde | 67 | 58 | 61 | 65 | 60 | 34 | 56 | 46 | 53 | 67 | **56,7 %** |
| Diplomate | 61 | 63 | 64 | 61 | 45 | 36 | 59 | 42 | 50 | 62 | **54,4 %** |
| Pugiliste | 33 | 42 | 46 | 47 | 41 | 31 | 38 | 30 | 38 | 51 | **39,7 %** |

### Les trois routes, l'usage des voies et la Tour, par classe

| Classe | Ruée | Éventail | Réactive | Voie 1 | Voie 2 | Voie 3 | Voie 4 | Voie 5 | Clé | Tour : étage 10 | étage 20 | étage moyen |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 36,5 % | 10,0 % | 45,7 % | 47,4 % | 65,5 % | 38,7 % | 89,4 % | 68,2 % | 97,5 % | 60,3 % | 11,0 % | 11,8 |
| Mage | 41,5 % | 9,5 % | 43,9 % | 30,2 % | 62,8 % | 54,3 % | 31,4 % | 39,2 % | 91,1 % | 60,0 % | 10,3 % | 11,5 |
| Voleur | 51,0 % | 20,5 % | 44,6 % | 48,5 % | 29,7 % | 66,6 % | 39,2 % | 48,3 % | 92,6 % | 76,0 % | 14,7 % | 12,9 |
| Archer | 40,0 % | 10,0 % | 41,7 % | 47,5 % | 41,7 % | 63,7 % | 26,6 % | 39,0 % | 90,7 % | 64,0 % | 9,7 % | 11,7 |
| Prêtre | 25,0 % | 5,5 % | 50,5 % | 52,4 % | 77,3 % | 42,4 % | 83,7 % | 77,6 % | 97,0 % | 64,7 % | 11,7 % | 11,9 |
| Alchimiste | 40,0 % | 11,5 % | 63,5 % | 52,7 % | 49,6 % | 58,0 % | 38,5 % | 72,1 % | 96,9 % | 74,7 % | 22,3 % | 14,1 |
| Invocateur | 48,0 % | 10,0 % | 53,0 % | 45,2 % | 54,2 % | 58,3 % | 59,4 % | 53,1 % | 93,0 % | 77,3 % | 26,0 % | 14,2 |
| Barde | 45,0 % | 11,5 % | 56,7 % | 48,5 % | 41,9 % | 56,9 % | 60,9 % | 68,9 % | 94,0 % | 82,7 % | 22,7 % | 14,5 |
| Diplomate | 35,0 % | 6,5 % | 54,4 % | 38,0 % | 62,1 % | 95,4 % | 53,7 % | 86,1 % | 97,2 % | 76,3 % | 21,0 % | 13,7 |
| Pugiliste | 15,5 % | 3,5 % | 39,7 % | 44,2 % | 46,6 % | 72,2 % | 87,9 % | 44,3 % | 97,0 % | 80,0 % | 21,3 % | 13,8 |

### Boutons touchés, et pourquoi

- pas des k calculés ensemble : le k d'une classe change aussi le duo dont elle est l'acolyte ; les duels au-delà de 58 % comptent aussi (effets mesurés à graines égales avant la passe 71)
- k_classe Guerrier : 0,826 → 0,838 (45,7 % de victoires)
- k_classe Mage : 0,875 → 0,881 (43,9 % de victoires)
- k_classe Voleur : 0,859 → 0,853 (44,6 % de victoires)
- k_classe Archer : 0,899 → 0,905 (41,7 % de victoires)
- k_classe Prêtre : 0,880 → 0,882 (50,5 % de victoires)
- k_classe Alchimiste : 1,058 → 1,032 (63,5 % de victoires)
- k_classe Invocateur : 0,975 → 0,954 (53,0 % de victoires)
- k_classe Barde : 1,076 → 1,061 (56,7 % de victoires)
- k_classe Diplomate : 1,178 → 1,199 (54,4 % de victoires)
- k_classe Pugiliste : 0,974 → 0,993 (39,7 % de victoires)
- Tour : force des monstres au départ 0,396 → 0,495, en plus par étage 0,027 → 0,034 (étage 10 atteint dans 71,6 % des montées, étage 20 dans 17,1 %)
- Tour, Guerrier : pente des monstres 0,781 → 0,836 (étage 20 dans 11,0 % des montées)
- Tour, Guerrier : facteur des monstres 1,728 → 1,573 (étage 10 dans 60,3 % des montées)
- Tour, Mage : pente des monstres 1,216 → 1,284 (étage 20 dans 10,3 % des montées)
- Tour, Mage : facteur des monstres 0,727 → 0,659 (étage 10 dans 60,0 % des montées)
- Tour, Voleur : pente des monstres 0,469 → 0,537 (étage 20 dans 14,7 % des montées)
- Tour, Voleur : facteur des monstres 0,984 → 1,019 (étage 10 dans 76,0 % des montées)
- Tour, Archer : pente des monstres 1,563 → 1,630 (étage 20 dans 9,7 % des montées)
- Tour, Archer : facteur des monstres 0,610 → 0,573 (étage 10 dans 64,0 % des montées)
- Tour, Prêtre : pente des monstres 0,947 → 1,026 (étage 20 dans 11,7 % des montées)
- Tour, Prêtre : facteur des monstres 1,137 → 1,074 (étage 10 dans 64,7 % des montées)
- Tour, Alchimiste : pente des monstres 1,028 → 1,182 (étage 20 dans 22,3 % des montées)
- Tour, Alchimiste : facteur des monstres 0,981 → 1,005 (étage 10 dans 74,7 % des montées)
- Tour, Invocateur : pente des monstres 1,155 → 1,328 (étage 20 dans 26,0 % des montées)
- Tour, Invocateur : facteur des monstres 0,923 → 0,965 (étage 10 dans 77,3 % des montées)
- Tour, Barde : pente des monstres 1,561 → 1,795 (étage 20 dans 22,7 % des montées)
- Tour, Barde : facteur des monstres 0,718 → 0,781 (étage 10 dans 82,7 % des montées)
- Tour, Diplomate : pente des monstres 0,955 → 1,099 (étage 20 dans 21,0 % des montées)
- Tour, Diplomate : facteur des monstres 1,373 → 1,425 (étage 10 dans 76,3 % des montées)
- Tour, Pugiliste : pente des monstres 0,972 → 1,118 (étage 20 dans 21,3 % des montées)
- Tour, Pugiliste : facteur des monstres 0,900 → 0,961 (étage 10 dans 80,0 % des montées)

## Passe 72 (graines à partir de 7200217)

**2 critères tenus sur 6.** 50000 combats de duel (médiane 20 tours), 0 combats non finis.

### Les six critères (section 11.2)

- ❌ **1. Chaque classe entre 47 % et 53 % de victoires** : guerrier 46,4 %, mage 46,6 %, voleur 46,9 %, pretre 53,6 %, alchimiste 55,4 %, barde 57,6 %, diplomate 53,2 %, pugiliste 41,6 %
- ❌ **2. Aucune case de la matrice hors de 40 % – 60 %** : guerrier contre pretre 32,4 %, guerrier contre alchimiste 34,0 %, guerrier contre barde 34,2 %, guerrier contre diplomate 35,4 %, guerrier contre pugiliste 67,6 %, mage contre pugiliste 60,6 %, archer contre pretre 37,4 %, archer contre pugiliste 65,2 %, pretre contre guerrier 63,8 %, pretre contre mage 62,8 %, pretre contre archer 62,2 %, pretre contre alchimiste 37,8 %, pretre contre barde 39,0 %, pretre contre pugiliste 61,6 %, alchimiste contre guerrier 66,0 %, alchimiste contre pretre 60,8 %, alchimiste contre barde 60,4 %, alchimiste contre pugiliste 61,2 %, invocateur contre diplomate 39,8 %, invocateur contre pugiliste 63,2 %, barde contre guerrier 64,8 %, barde contre voleur 60,8 %, barde contre archer 62,0 %, barde contre pugiliste 67,6 %, diplomate contre guerrier 64,0 %, diplomate contre alchimiste 38,4 %, diplomate contre pugiliste 60,2 %, pugiliste contre guerrier 35,0 %, pugiliste contre pretre 37,4 %, pugiliste contre alchimiste 38,4 %, pugiliste contre barde 35,2 %, pugiliste contre diplomate 38,4 %
- ❌ **3. La route Réactive entre 40 % et 55 % (Ruée et Éventail : des repères, sans seuil)** : alchimiste Réactive 55,4 %, barde Réactive 57,6 %
- ✅ **4. Chaque voie jouée dans 15 % des combats au moins, une Clé dans 60 %**
- ✅ **5. Longueur : médiane de 18 à 22 tours, 95 % finis avant le tour 30**
- ❌ **6. Tour : étage 10 dans 40 à 60 % des montées, étage 20 dans 5 à 10 %, à 5 points près entre classes** : mage étage 20 2,3 %, voleur étage 10 30,0 %, voleur étage 20 2,3 %, pretre étage 20 3,7 %, alchimiste étage 10 34,7 %, alchimiste étage 20 3,7 %, invocateur étage 20 4,3 %, diplomate étage 10 37,7 %, diplomate étage 20 1,7 %, pugiliste étage 20 3,0 %, écart entre classes : étage 10 de 30,0 % à 54,3 %, étage 20 de 1,7 % à 5,3 %

### La matrice des classes (taux de victoire de la ligne contre la colonne)

| | Guer | Mage | Vole | Arch | Prêt | Alch | Invo | Bard | Dipl | Pugi | **Moyenne** |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 52 | 56 | 55 | 57 | 32 | 34 | 41 | 34 | 35 | 68 | **46,4 %** |
| Mage | 48 | 46 | 46 | 48 | 42 | 47 | 40 | 44 | 45 | 61 | **46,6 %** |
| Voleur | 47 | 51 | 50 | 46 | 46 | 49 | 43 | 42 | 40 | 56 | **46,9 %** |
| Archer | 44 | 52 | 56 | 51 | 37 | 50 | 47 | 45 | 44 | 65 | **49,2 %** |
| Prêtre | 64 | 63 | 53 | 62 | 48 | 38 | 55 | 39 | 52 | 62 | **53,6 %** |
| Alchimiste | 66 | 51 | 50 | 49 | 61 | 48 | 53 | 60 | 55 | 61 | **55,4 %** |
| Invocateur | 60 | 57 | 59 | 55 | 45 | 48 | 51 | 49 | 40 | 63 | **52,7 %** |
| Barde | 65 | 60 | 61 | 62 | 57 | 43 | 54 | 52 | 56 | 68 | **57,6 %** |
| Diplomate | 64 | 55 | 60 | 59 | 44 | 38 | 60 | 44 | 48 | 60 | **53,2 %** |
| Pugiliste | 35 | 43 | 50 | 44 | 37 | 38 | 42 | 35 | 38 | 53 | **41,6 %** |

### Les trois routes, l'usage des voies et la Tour, par classe

| Classe | Ruée | Éventail | Réactive | Voie 1 | Voie 2 | Voie 3 | Voie 4 | Voie 5 | Clé | Tour : étage 10 | étage 20 | étage moyen |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 50,0 % | 11,0 % | 46,4 % | 47,0 % | 68,3 % | 37,0 % | 87,2 % | 68,6 % | 97,3 % | 43,0 % | 5,3 % | 9,7 |
| Mage | 49,5 % | 17,0 % | 46,6 % | 26,1 % | 63,6 % | 55,4 % | 32,1 % | 37,4 % | 90,7 % | 50,3 % | 2,3 % | 10,4 |
| Voleur | 56,0 % | 22,0 % | 46,9 % | 47,2 % | 28,9 % | 63,6 % | 35,9 % | 51,5 % | 91,6 % | 30,0 % | 2,3 % | 8,1 |
| Archer | 45,5 % | 14,0 % | 49,2 % | 43,5 % | 43,8 % | 62,7 % | 24,5 % | 51,3 % | 90,7 % | 53,3 % | 5,0 % | 10,6 |
| Prêtre | 33,0 % | 13,5 % | 53,6 % | 51,5 % | 77,6 % | 44,0 % | 83,4 % | 80,0 % | 96,9 % | 41,0 % | 3,7 % | 9,3 |
| Alchimiste | 40,5 % | 10,5 % | 55,4 % | 56,5 % | 35,3 % | 63,8 % | 40,9 % | 65,3 % | 96,3 % | 34,7 % | 3,7 % | 9,1 |
| Invocateur | 53,0 % | 19,0 % | 52,7 % | 47,2 % | 54,3 % | 66,0 % | 47,6 % | 53,1 % | 92,6 % | 50,0 % | 4,3 % | 10,3 |
| Barde | 47,5 % | 12,5 % | 57,6 % | 48,7 % | 38,1 % | 57,2 % | 59,1 % | 72,6 % | 93,6 % | 54,3 % | 5,0 % | 11,0 |
| Diplomate | 43,0 % | 9,0 % | 53,2 % | 35,2 % | 63,9 % | 95,9 % | 49,5 % | 87,1 % | 98,0 % | 37,7 % | 1,7 % | 8,9 |
| Pugiliste | 22,5 % | 5,5 % | 41,6 % | 55,8 % | 46,3 % | 69,0 % | 85,1 % | 44,7 % | 97,0 % | 40,3 % | 3,0 % | 9,1 |

### Boutons touchés, et pourquoi

- pas des k calculés ensemble : le k d'une classe change aussi le duo dont elle est l'acolyte ; les duels au-delà de 58 % comptent aussi (effets mesurés à graines égales avant la passe 71)
- k_classe Guerrier : 0,838 → 0,853 (46,4 % de victoires)
- k_classe Mage : 0,881 → 0,880 (46,6 % de victoires)
- k_classe Voleur : 0,853 → 0,845 (46,9 % de victoires)
- k_classe Archer : 0,905 → 0,895 (49,2 % de victoires)
- k_classe Alchimiste : 1,032 → 1,026 (55,4 % de victoires)
- k_classe Invocateur : 0,954 → 0,944 (52,7 % de victoires)
- k_classe Barde : 1,061 → 1,060 (57,6 % de victoires)
- k_classe Diplomate : 1,199 → 1,200 (53,2 % de victoires)
- k_classe Pugiliste : 0,993 → 1,008 (41,6 % de victoires)
- Tour : force des monstres au départ 0,495 → 0,476, en plus par étage 0,034 → 0,032 (étage 10 atteint dans 43,5 % des montées, étage 20 dans 3,6 %)
- Tour, Guerrier : pente des monstres 0,836 → 0,818 (étage 20 dans 5,3 % des montées)
- Tour, Mage : pente des monstres 1,284 → 1,218 (étage 20 dans 2,3 % des montées)
- Tour, Mage : facteur des monstres 0,659 → 0,677 (étage 10 dans 50,3 % des montées)
- Tour, Voleur : pente des monstres 0,537 → 0,509 (étage 20 dans 2,3 % des montées)
- Tour, Voleur : facteur des monstres 1,019 → 0,964 (étage 10 dans 30,0 % des montées)
- Tour, Archer : pente des monstres 1,630 → 1,590 (étage 20 dans 5,0 % des montées)
- Tour, Archer : facteur des monstres 0,573 → 0,596 (étage 10 dans 53,3 % des montées)
- Tour, Prêtre : pente des monstres 1,026 → 0,987 (étage 20 dans 3,7 % des montées)
- Tour, Prêtre : facteur des monstres 1,074 → 1,053 (étage 10 dans 41,0 % des montées)
- Tour, Alchimiste : pente des monstres 1,182 → 1,137 (étage 20 dans 3,7 % des montées)
- Tour, Alchimiste : facteur des monstres 1,005 → 0,970 (étage 10 dans 34,7 % des montées)
- Tour, Invocateur : pente des monstres 1,328 → 1,286 (étage 20 dans 4,3 % des montées)
- Tour, Invocateur : facteur des monstres 0,965 → 1,016 (étage 10 dans 50,0 % des montées)
- Tour, Barde : pente des monstres 1,795 → 1,750 (étage 20 dans 5,0 % des montées)
- Tour, Barde : facteur des monstres 0,781 → 0,849 (étage 10 dans 54,3 % des montées)
- Tour, Diplomate : pente des monstres 1,099 → 1,034 (étage 20 dans 1,7 % des montées)
- Tour, Diplomate : facteur des monstres 1,425 → 1,392 (étage 10 dans 37,7 % des montées)
- Tour, Pugiliste : pente des monstres 1,118 → 1,068 (étage 20 dans 3,0 % des montées)
- Tour, Pugiliste : facteur des monstres 0,961 → 0,949 (étage 10 dans 40,3 % des montées)

## Passe 73 (graines à partir de 7300220)

**2 critères tenus sur 6.** 50000 combats de duel (médiane 20 tours), 0 combats non finis.

### Les six critères (section 11.2)

- ❌ **1. Chaque classe entre 47 % et 53 % de victoires** : archer 45,5 %, pretre 54,3 %, alchimiste 55,8 %, invocateur 54,6 %, barde 57,1 %, diplomate 54,6 %, pugiliste 44,4 %
- ❌ **2. Aucune case de la matrice hors de 40 % – 60 %** : guerrier contre archer 64,8 %, guerrier contre alchimiste 36,4 %, guerrier contre pugiliste 66,4 %, archer contre guerrier 34,6 %, archer contre pretre 34,0 %, pretre contre guerrier 64,2 %, pretre contre archer 68,0 %, pretre contre alchimiste 38,2 %, alchimiste contre guerrier 62,0 %, alchimiste contre pretre 60,4 %, alchimiste contre diplomate 60,4 %, invocateur contre guerrier 62,6 %, invocateur contre archer 60,2 %, invocateur contre pugiliste 61,6 %, barde contre guerrier 61,0 %, barde contre archer 64,2 %, barde contre pugiliste 65,0 %, diplomate contre guerrier 62,8 %, diplomate contre voleur 61,6 %, pugiliste contre guerrier 35,0 %, pugiliste contre barde 38,2 %
- ❌ **3. La route Réactive entre 40 % et 55 % (Ruée et Éventail : des repères, sans seuil)** : alchimiste Réactive 55,8 %, barde Réactive 57,1 %
- ✅ **4. Chaque voie jouée dans 15 % des combats au moins, une Clé dans 60 %**
- ✅ **5. Longueur : médiane de 18 à 22 tours, 95 % finis avant le tour 30**
- ❌ **6. Tour : étage 10 dans 40 à 60 % des montées, étage 20 dans 5 à 10 %, à 5 points près entre classes** : guerrier étage 10 64,3 %, voleur étage 20 4,7 %, archer étage 20 3,0 %, pretre étage 20 4,7 %, barde étage 20 2,7 %, diplomate étage 20 4,0 %, écart entre classes : étage 10 de 41,3 % à 64,3 %, étage 20 de 2,7 % à 9,3 %

### La matrice des classes (taux de victoire de la ligne contre la colonne)

| | Guer | Mage | Vole | Arch | Prêt | Alch | Invo | Bard | Dipl | Pugi | **Moyenne** |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 53 | 59 | 53 | 65 | 43 | 36 | 43 | 42 | 40 | 66 | **50,1 %** |
| Mage | 42 | 50 | 45 | 55 | 46 | 50 | 44 | 44 | 51 | 56 | **48,3 %** |
| Voleur | 48 | 54 | 51 | 48 | 47 | 50 | 46 | 44 | 44 | 53 | **48,6 %** |
| Archer | 35 | 47 | 50 | 52 | 34 | 49 | 45 | 41 | 50 | 54 | **45,5 %** |
| Prêtre | 64 | 56 | 50 | 68 | 50 | 38 | 54 | 46 | 60 | 58 | **54,3 %** |
| Alchimiste | 62 | 53 | 52 | 55 | 60 | 52 | 53 | 55 | 60 | 56 | **55,8 %** |
| Invocateur | 63 | 59 | 58 | 60 | 51 | 49 | 49 | 50 | 47 | 62 | **54,6 %** |
| Barde | 61 | 55 | 56 | 64 | 57 | 45 | 55 | 54 | 58 | 65 | **57,1 %** |
| Diplomate | 63 | 56 | 62 | 60 | 51 | 46 | 57 | 42 | 53 | 57 | **54,6 %** |
| Pugiliste | 35 | 44 | 52 | 45 | 44 | 44 | 44 | 38 | 45 | 52 | **44,4 %** |

### Les trois routes, l'usage des voies et la Tour, par classe

| Classe | Ruée | Éventail | Réactive | Voie 1 | Voie 2 | Voie 3 | Voie 4 | Voie 5 | Clé | Tour : étage 10 | étage 20 | étage moyen |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 47,0 % | 9,0 % | 50,1 % | 49,6 % | 65,3 % | 39,2 % | 87,4 % | 70,0 % | 97,2 % | 64,3 % | 7,3 % | 12,1 |
| Mage | 56,0 % | 15,5 % | 48,3 % | 30,1 % | 62,3 % | 53,5 % | 31,5 % | 41,2 % | 90,1 % | 53,3 % | 5,0 % | 10,7 |
| Voleur | 63,5 % | 26,5 % | 48,6 % | 51,1 % | 28,3 % | 63,9 % | 40,1 % | 45,4 % | 91,7 % | 49,0 % | 4,7 % | 10,1 |
| Archer | 46,0 % | 15,0 % | 45,5 % | 43,0 % | 41,2 % | 66,2 % | 28,3 % | 40,9 % | 89,8 % | 57,0 % | 3,0 % | 10,7 |
| Prêtre | 36,5 % | 9,0 % | 54,3 % | 53,9 % | 76,7 % | 40,2 % | 82,8 % | 79,2 % | 96,9 % | 49,3 % | 4,7 % | 10,2 |
| Alchimiste | 46,0 % | 11,5 % | 55,8 % | 54,9 % | 37,7 % | 61,8 % | 42,2 % | 67,7 % | 96,1 % | 41,3 % | 6,3 % | 9,8 |
| Invocateur | 50,5 % | 18,0 % | 54,6 % | 46,7 % | 56,2 % | 65,2 % | 47,8 % | 54,8 % | 92,7 % | 57,0 % | 9,3 % | 11,1 |
| Barde | 45,5 % | 16,0 % | 57,1 % | 47,7 % | 41,0 % | 53,7 % | 59,3 % | 75,0 % | 93,3 % | 50,0 % | 2,7 % | 10,3 |
| Diplomate | 42,5 % | 5,5 % | 54,6 % | 34,2 % | 61,0 % | 95,8 % | 51,0 % | 87,6 % | 97,8 % | 57,0 % | 4,0 % | 10,9 |
| Pugiliste | 16,0 % | 3,5 % | 44,4 % | 52,0 % | 54,8 % | 70,3 % | 85,2 % | 44,6 % | 97,0 % | 53,7 % | 5,0 % | 10,5 |

### Boutons touchés, et pourquoi

- pas des k calculés ensemble : le k d'une classe change aussi le duo dont elle est l'acolyte ; les duels au-delà de 58 % comptent aussi (effets mesurés à graines égales avant la passe 71)
- k_classe Guerrier : 0,853 → 0,864 (50,1 % de victoires)
- k_classe Mage : 0,880 → 0,881 (48,3 % de victoires)
- k_classe Voleur : 0,845 → 0,829 (48,6 % de victoires)
- k_classe Archer : 0,895 → 0,904 (45,5 % de victoires)
- k_classe Prêtre : 0,882 → 0,874 (54,3 % de victoires)
- k_classe Alchimiste : 1,026 → 1,022 (55,8 % de victoires)
- k_classe Invocateur : 0,944 → 0,927 (54,6 % de victoires)
- k_classe Barde : 1,060 → 1,056 (57,1 % de victoires)
- k_classe Pugiliste : 1,008 → 1,028 (44,4 % de victoires)
- Tour : force des monstres au départ 0,476 → 0,480, en plus par étage 0,032 → 0,031 (étage 10 atteint dans 53,2 % des montées, étage 20 dans 5,2 %)
- Tour, Guerrier : facteur des monstres 1,573 → 1,643 (étage 10 dans 64,3 % des montées)
- Tour, Mage : pente des monstres 1,218 → 1,188 (étage 20 dans 5,0 % des montées)
- Tour, Voleur : pente des monstres 0,509 → 0,495 (étage 20 dans 4,7 % des montées)
- Tour, Voleur : facteur des monstres 0,964 → 0,948 (étage 10 dans 49,0 % des montées)
- Tour, Archer : pente des monstres 1,590 → 1,518 (étage 20 dans 3,0 % des montées)
- Tour, Archer : facteur des monstres 0,596 → 0,605 (étage 10 dans 57,0 % des montées)
- Tour, Prêtre : pente des monstres 0,987 → 0,959 (étage 20 dans 4,7 % des montées)
- Tour, Prêtre : facteur des monstres 1,053 → 1,021 (étage 10 dans 49,3 % des montées)
- Tour, Alchimiste : facteur des monstres 0,970 → 0,924 (étage 10 dans 41,3 % des montées)
- Tour, Invocateur : facteur des monstres 1,016 → 1,046 (étage 10 dans 57,0 % des montées)
- Tour, Barde : pente des monstres 1,750 → 1,665 (étage 20 dans 2,7 % des montées)
- Tour, Barde : facteur des monstres 0,849 → 0,838 (étage 10 dans 50,0 % des montées)
- Tour, Diplomate : pente des monstres 1,034 → 0,998 (étage 20 dans 4,0 % des montées)
- Tour, Diplomate : facteur des monstres 1,392 → 1,403 (étage 10 dans 57,0 % des montées)
- Tour, Pugiliste : pente des monstres 1,068 → 1,041 (étage 20 dans 5,0 % des montées)

## Passe 74 (graines à partir de 7400223)

**2 critères tenus sur 6.** 50000 combats de duel (médiane 20 tours), 0 combats non finis.

### Les six critères (section 11.2)

- ❌ **1. Chaque classe entre 47 % et 53 % de victoires** : alchimiste 54,5 %, barde 55,1 %
- ❌ **2. Aucune case de la matrice hors de 40 % – 60 %** : guerrier contre archer 61,0 %, guerrier contre pretre 39,0 %, guerrier contre alchimiste 36,2 %, guerrier contre invocateur 36,8 %, guerrier contre barde 39,4 %, guerrier contre pugiliste 62,8 %, mage contre pretre 38,2 %, archer contre pugiliste 60,2 %, pretre contre guerrier 60,2 %, pretre contre alchimiste 33,4 %, pretre contre barde 39,0 %, alchimiste contre guerrier 62,4 %, alchimiste contre pretre 63,0 %, invocateur contre guerrier 63,6 %, barde contre guerrier 62,2 %, barde contre pugiliste 62,4 %, diplomate contre barde 38,2 %
- ❌ **3. La route Réactive entre 40 % et 55 % (Ruée et Éventail : des repères, sans seuil)** : barde Réactive 55,1 %
- ✅ **4. Chaque voie jouée dans 15 % des combats au moins, une Clé dans 60 %**
- ✅ **5. Longueur : médiane de 18 à 22 tours, 95 % finis avant le tour 30**
- ❌ **6. Tour : étage 10 dans 40 à 60 % des montées, étage 20 dans 5 à 10 %, à 5 points près entre classes** : mage étage 20 4,7 %, voleur étage 20 4,7 %, invocateur étage 20 4,7 %, barde étage 20 4,0 %, écart entre classes : étage 10 de 43,0 % à 58,7 %, étage 20 de 4,0 % à 7,7 %

### La matrice des classes (taux de victoire de la ligne contre la colonne)

| | Guer | Mage | Vole | Arch | Prêt | Alch | Invo | Bard | Dipl | Pugi | **Moyenne** |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 51 | 54 | 52 | 61 | 39 | 36 | 37 | 39 | 42 | 63 | **47,5 %** |
| Mage | 47 | 53 | 48 | 52 | 38 | 51 | 43 | 43 | 45 | 59 | **47,9 %** |
| Voleur | 52 | 54 | 54 | 48 | 50 | 56 | 48 | 47 | 47 | 52 | **51,0 %** |
| Archer | 45 | 53 | 57 | 53 | 40 | 54 | 47 | 44 | 51 | 60 | **50,4 %** |
| Prêtre | 60 | 55 | 49 | 60 | 48 | 33 | 52 | 39 | 59 | 56 | **51,1 %** |
| Alchimiste | 62 | 50 | 52 | 49 | 63 | 48 | 50 | 57 | 56 | 57 | **54,5 %** |
| Invocateur | 64 | 58 | 56 | 54 | 47 | 49 | 51 | 46 | 44 | 55 | **52,4 %** |
| Barde | 62 | 55 | 57 | 55 | 55 | 46 | 53 | 48 | 57 | 62 | **55,1 %** |
| Diplomate | 58 | 50 | 56 | 50 | 45 | 46 | 55 | 38 | 47 | 49 | **49,5 %** |
| Pugiliste | 41 | 48 | 53 | 49 | 46 | 48 | 46 | 40 | 48 | 53 | **47,2 %** |

### Les trois routes, l'usage des voies et la Tour, par classe

| Classe | Ruée | Éventail | Réactive | Voie 1 | Voie 2 | Voie 3 | Voie 4 | Voie 5 | Clé | Tour : étage 10 | étage 20 | étage moyen |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 38,0 % | 9,0 % | 47,5 % | 49,0 % | 75,9 % | 45,3 % | 83,9 % | 67,7 % | 97,8 % | 52,0 % | 5,7 % | 10,7 |
| Mage | 47,5 % | 11,0 % | 47,9 % | 29,9 % | 62,5 % | 52,8 % | 35,3 % | 40,1 % | 91,3 % | 58,7 % | 4,7 % | 11,3 |
| Voleur | 50,0 % | 19,0 % | 51,0 % | 46,7 % | 28,5 % | 64,1 % | 36,0 % | 53,1 % | 92,1 % | 55,3 % | 4,7 % | 10,7 |
| Archer | 42,0 % | 11,5 % | 50,4 % | 44,4 % | 45,8 % | 61,0 % | 27,1 % | 49,2 % | 90,8 % | 58,3 % | 6,3 % | 11,2 |
| Prêtre | 29,5 % | 10,0 % | 51,1 % | 53,6 % | 75,0 % | 47,4 % | 82,3 % | 81,1 % | 96,7 % | 50,7 % | 7,3 % | 10,7 |
| Alchimiste | 44,0 % | 15,5 % | 54,5 % | 54,5 % | 36,8 % | 62,7 % | 41,9 % | 67,1 % | 96,3 % | 43,7 % | 5,0 % | 9,8 |
| Invocateur | 57,5 % | 16,0 % | 52,4 % | 45,8 % | 52,4 % | 68,7 % | 43,8 % | 51,8 % | 92,1 % | 43,0 % | 4,7 % | 9,7 |
| Barde | 44,5 % | 12,5 % | 55,1 % | 51,1 % | 39,4 % | 55,5 % | 60,2 % | 70,7 % | 93,7 % | 49,0 % | 4,0 % | 10,2 |
| Diplomate | 40,5 % | 5,5 % | 49,5 % | 34,5 % | 64,9 % | 96,1 % | 47,8 % | 86,9 % | 98,0 % | 49,3 % | 5,7 % | 10,3 |
| Pugiliste | 9,0 % | 2,5 % | 47,2 % | 54,5 % | 51,4 % | 65,5 % | 85,4 % | 43,2 % | 97,3 % | 51,3 % | 7,7 % | 10,5 |

### Boutons touchés, et pourquoi

- pas des k calculés ensemble : le k d'une classe change aussi le duo dont elle est l'acolyte ; les duels au-delà de 58 % comptent aussi (effets mesurés à graines égales avant la passe 71)
- k_classe Guerrier : 0,864 → 0,870 (47,5 % de victoires)
- k_classe Voleur : 0,829 → 0,813 (51,0 % de victoires)
- k_classe Archer : 0,904 → 0,907 (50,4 % de victoires)
- k_classe Prêtre : 0,874 → 0,877 (51,1 % de victoires)
- k_classe Alchimiste : 1,022 → 1,010 (54,5 % de victoires)
- k_classe Invocateur : 0,927 → 0,910 (52,4 % de victoires)
- k_classe Barde : 1,056 → 1,044 (55,1 % de victoires)
- k_classe Pugiliste : 1,028 → 1,041 (47,2 % de victoires)
- Tour : force des monstres au départ 0,480 → 0,480, en plus par étage 0,031 → 0,030 (étage 10 atteint dans 51,1 % des montées, étage 20 dans 5,6 %)
- Tour, Mage : pente des monstres 1,188 → 1,154 (étage 20 dans 4,7 % des montées)
- Tour, Mage : facteur des monstres 0,677 → 0,698 (étage 10 dans 58,7 % des montées)
- Tour, Voleur : pente des monstres 0,495 → 0,481 (étage 20 dans 4,7 % des montées)
- Tour, Voleur : facteur des monstres 0,948 → 0,956 (étage 10 dans 55,3 % des montées)
- Tour, Archer : facteur des monstres 0,605 → 0,622 (étage 10 dans 58,3 % des montées)
- Tour, Alchimiste : pente des monstres 1,137 → 1,109 (étage 20 dans 5,0 % des montées)
- Tour, Alchimiste : facteur des monstres 0,924 → 0,896 (étage 10 dans 43,7 % des montées)
- Tour, Invocateur : pente des monstres 1,286 → 1,249 (étage 20 dans 4,7 % des montées)
- Tour, Invocateur : facteur des monstres 1,046 → 1,012 (étage 10 dans 43,0 % des montées)
- Tour, Barde : pente des monstres 1,665 → 1,607 (étage 20 dans 4,0 % des montées)
- Tour, Barde : facteur des monstres 0,838 → 0,831 (étage 10 dans 49,0 % des montées)

## Passe 75 (graines à partir de 7500226)

**2 critères tenus sur 6.** 50000 combats de duel (médiane 20 tours), 0 combats non finis.

### Les six critères (section 11.2)

- ❌ **1. Chaque classe entre 47 % et 53 % de victoires** : barde 55,3 %, pugiliste 46,5 %
- ❌ **2. Aucune case de la matrice hors de 40 % – 60 %** : guerrier contre archer 62,0 %, archer contre guerrier 37,8 %, archer contre pretre 39,0 %, barde contre guerrier 61,0 %, barde contre diplomate 61,2 %, pugiliste contre guerrier 39,8 %
- ❌ **3. La route Réactive entre 40 % et 55 % (Ruée et Éventail : des repères, sans seuil)** : barde Réactive 55,3 %
- ✅ **4. Chaque voie jouée dans 15 % des combats au moins, une Clé dans 60 %**
- ✅ **5. Longueur : médiane de 18 à 22 tours, 95 % finis avant le tour 30**
- ❌ **6. Tour : étage 10 dans 40 à 60 % des montées, étage 20 dans 5 à 10 %, à 5 points près entre classes** : guerrier étage 10 63,0 %, guerrier étage 20 11,3 %, archer étage 10 60,3 %, pretre étage 10 63,3 %, diplomate étage 20 3,7 %, écart entre classes : étage 10 de 47,7 % à 63,3 %, étage 20 de 3,7 % à 11,3 %

### La matrice des classes (taux de victoire de la ligne contre la colonne)

| | Guer | Mage | Vole | Arch | Prêt | Alch | Invo | Bard | Dipl | Pugi | **Moyenne** |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 49 | 55 | 58 | 62 | 46 | 48 | 44 | 49 | 46 | 60 | **51,6 %** |
| Mage | 42 | 52 | 49 | 50 | 49 | 59 | 46 | 51 | 49 | 52 | **49,7 %** |
| Voleur | 45 | 51 | 51 | 48 | 46 | 53 | 44 | 47 | 49 | 47 | **48,1 %** |
| Archer | 38 | 48 | 55 | 51 | 39 | 57 | 46 | 43 | 54 | 50 | **48,0 %** |
| Prêtre | 58 | 56 | 52 | 59 | 50 | 45 | 54 | 46 | 56 | 50 | **52,7 %** |
| Alchimiste | 54 | 49 | 47 | 47 | 60 | 49 | 52 | 56 | 56 | 49 | **51,8 %** |
| Invocateur | 58 | 57 | 56 | 55 | 47 | 50 | 53 | 48 | 46 | 52 | **52,1 %** |
| Barde | 61 | 51 | 56 | 52 | 58 | 47 | 53 | 54 | 61 | 59 | **55,3 %** |
| Diplomate | 53 | 46 | 57 | 47 | 45 | 47 | 53 | 44 | 50 | 48 | **49,0 %** |
| Pugiliste | 40 | 45 | 49 | 46 | 48 | 49 | 48 | 44 | 50 | 45 | **46,5 %** |

### Les trois routes, l'usage des voies et la Tour, par classe

| Classe | Ruée | Éventail | Réactive | Voie 1 | Voie 2 | Voie 3 | Voie 4 | Voie 5 | Clé | Tour : étage 10 | étage 20 | étage moyen |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 48,0 % | 10,0 % | 51,6 % | 48,0 % | 67,0 % | 51,9 % | 85,0 % | 70,1 % | 97,5 % | 63,0 % | 11,3 % | 12,3 |
| Mage | 48,0 % | 10,0 % | 49,7 % | 31,2 % | 64,0 % | 55,7 % | 30,4 % | 40,0 % | 90,6 % | 56,0 % | 7,0 % | 11,0 |
| Voleur | 50,0 % | 21,0 % | 48,1 % | 47,2 % | 30,4 % | 66,6 % | 36,2 % | 47,0 % | 91,0 % | 57,7 % | 9,0 % | 11,3 |
| Archer | 48,5 % | 13,0 % | 48,0 % | 47,3 % | 37,3 % | 67,0 % | 26,4 % | 50,0 % | 90,0 % | 60,3 % | 7,0 % | 11,4 |
| Prêtre | 21,5 % | 8,0 % | 52,7 % | 55,4 % | 78,1 % | 32,7 % | 82,6 % | 77,1 % | 96,5 % | 63,3 % | 9,7 % | 11,7 |
| Alchimiste | 33,0 % | 12,0 % | 51,8 % | 54,1 % | 39,4 % | 63,4 % | 41,8 % | 68,5 % | 96,3 % | 50,3 % | 9,0 % | 10,9 |
| Invocateur | 52,5 % | 16,5 % | 52,1 % | 42,5 % | 51,8 % | 71,1 % | 46,1 % | 51,0 % | 92,1 % | 47,7 % | 6,3 % | 10,2 |
| Barde | 49,5 % | 11,0 % | 55,3 % | 47,2 % | 42,6 % | 58,0 % | 59,1 % | 70,2 % | 92,9 % | 55,0 % | 6,3 % | 11,3 |
| Diplomate | 36,0 % | 6,5 % | 49,0 % | 35,7 % | 63,5 % | 96,3 % | 49,2 % | 87,3 % | 97,5 % | 52,7 % | 3,7 % | 10,5 |
| Pugiliste | 22,5 % | 3,5 % | 46,5 % | 50,7 % | 57,3 % | 69,0 % | 84,7 % | 43,4 % | 96,9 % | 53,0 % | 7,3 % | 10,8 |

### Boutons touchés, et pourquoi

- pas des k calculés ensemble : le k d'une classe change aussi le duo dont elle est l'acolyte ; les duels au-delà de 58 % comptent aussi (effets mesurés à graines égales avant la passe 75)
- k_classe Guerrier : 0,870 → 0,873 (51,6 % de victoires)
- k_classe Mage : 0,881 → 0,887 (49,7 % de victoires)
- k_classe Archer : 0,907 → 0,913 (48,0 % de victoires)
- k_classe Prêtre : 0,877 → 0,869 (52,7 % de victoires)
- k_classe Alchimiste : 1,010 → 1,009 (51,8 % de victoires)
- k_classe Invocateur : 0,910 → 0,894 (52,1 % de victoires)
- k_classe Barde : 1,044 → 1,028 (55,3 % de victoires)
- k_classe Pugiliste : 1,041 → 1,056 (46,5 % de victoires)
- Tour : force des monstres au départ 0,480 → 0,489, en plus par étage 0,030 → 0,030 (étage 10 atteint dans 55,9 % des montées, étage 20 dans 7,7 %)
- Tour, Guerrier : pente des monstres 0,818 → 0,834 (étage 20 dans 11,3 % des montées)
- Tour, Guerrier : facteur des monstres 1,643 → 1,689 (étage 10 dans 63,0 % des montées)
- Tour, Archer : facteur des monstres 0,622 → 0,633 (étage 10 dans 60,3 % des montées)
- Tour, Prêtre : pente des monstres 0,959 → 0,970 (étage 20 dans 9,7 % des montées)
- Tour, Prêtre : facteur des monstres 1,021 → 1,051 (étage 10 dans 63,3 % des montées)
- Tour, Alchimiste : facteur des monstres 0,896 → 0,876 (étage 10 dans 50,3 % des montées)
- Tour, Invocateur : facteur des monstres 1,012 → 0,979 (étage 10 dans 47,7 % des montées)
- Tour, Diplomate : pente des monstres 0,998 → 0,960 (étage 20 dans 3,7 % des montées)
- Tour, Diplomate : facteur des monstres 1,403 → 1,399 (étage 10 dans 52,7 % des montées)
- Tour, Pugiliste : facteur des monstres 0,949 → 0,938 (étage 10 dans 53,0 % des montées)

## Passe 76 (graines à partir de 7600229)

**3 critères tenus sur 6.** 50000 combats de duel (médiane 19 tours), 0 combats non finis.

### Les six critères (section 11.2)

- ❌ **1. Chaque classe entre 47 % et 53 % de victoires** : guerrier 46,4 %, invocateur 53,6 %
- ❌ **2. Aucune case de la matrice hors de 40 % – 60 %** : guerrier contre invocateur 39,2 %, pretre contre guerrier 61,4 %, alchimiste contre guerrier 61,2 %, invocateur contre guerrier 63,4 %, barde contre guerrier 61,4 %
- ✅ **3. La route Réactive entre 40 % et 55 % (Ruée et Éventail : des repères, sans seuil)**
- ✅ **4. Chaque voie jouée dans 15 % des combats au moins, une Clé dans 60 %**
- ✅ **5. Longueur : médiane de 18 à 22 tours, 95 % finis avant le tour 30**
- ❌ **6. Tour : étage 10 dans 40 à 60 % des montées, étage 20 dans 5 à 10 %, à 5 points près entre classes** : guerrier étage 20 3,0 %, archer étage 10 60,7 %, alchimiste étage 20 10,7 %, barde étage 20 4,0 %, diplomate étage 20 3,0 %, écart entre classes : étage 10 de 40,7 % à 60,7 %, étage 20 de 3,0 % à 10,7 %

### La matrice des classes (taux de victoire de la ligne contre la colonne)

| | Guer | Mage | Vole | Arch | Prêt | Alch | Invo | Bard | Dipl | Pugi | **Moyenne** |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 49 | 50 | 49 | 60 | 41 | 40 | 39 | 43 | 40 | 54 | **46,4 %** |
| Mage | 46 | 51 | 48 | 49 | 49 | 56 | 44 | 49 | 56 | 51 | **49,9 %** |
| Voleur | 52 | 53 | 56 | 47 | 50 | 54 | 47 | 48 | 48 | 53 | **50,8 %** |
| Archer | 45 | 51 | 53 | 52 | 44 | 60 | 48 | 52 | 58 | 53 | **51,6 %** |
| Prêtre | 61 | 53 | 51 | 58 | 56 | 41 | 52 | 45 | 53 | 55 | **52,5 %** |
| Alchimiste | 61 | 46 | 46 | 41 | 60 | 50 | 52 | 57 | 52 | 48 | **51,4 %** |
| Invocateur | 63 | 57 | 59 | 51 | 45 | 53 | 50 | 53 | 47 | 57 | **53,6 %** |
| Barde | 61 | 48 | 53 | 50 | 52 | 47 | 52 | 53 | 59 | 55 | **53,0 %** |
| Diplomate | 55 | 42 | 52 | 45 | 49 | 46 | 53 | 44 | 52 | 48 | **48,6 %** |
| Pugiliste | 46 | 50 | 46 | 48 | 48 | 49 | 44 | 43 | 53 | 50 | **47,8 %** |

### Les trois routes, l'usage des voies et la Tour, par classe

| Classe | Ruée | Éventail | Réactive | Voie 1 | Voie 2 | Voie 3 | Voie 4 | Voie 5 | Clé | Tour : étage 10 | étage 20 | étage moyen |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 43,5 % | 8,5 % | 46,4 % | 47,8 % | 70,3 % | 44,4 % | 86,6 % | 66,9 % | 97,2 % | 46,0 % | 3,0 % | 9,7 |
| Mage | 57,0 % | 21,5 % | 49,9 % | 28,9 % | 62,7 % | 55,2 % | 33,1 % | 38,8 % | 91,2 % | 58,7 % | 6,3 % | 11,1 |
| Voleur | 59,0 % | 25,0 % | 50,8 % | 47,0 % | 32,0 % | 65,3 % | 34,7 % | 44,4 % | 90,3 % | 56,3 % | 7,7 % | 10,9 |
| Archer | 52,5 % | 22,0 % | 51,6 % | 47,2 % | 39,4 % | 64,2 % | 29,5 % | 50,1 % | 89,9 % | 60,7 % | 7,7 % | 11,5 |
| Prêtre | 33,0 % | 7,0 % | 52,5 % | 56,2 % | 74,2 % | 42,6 % | 81,5 % | 79,2 % | 96,3 % | 56,7 % | 6,7 % | 11,0 |
| Alchimiste | 39,0 % | 12,5 % | 51,4 % | 55,3 % | 35,5 % | 63,2 % | 39,6 % | 68,6 % | 95,6 % | 51,0 % | 10,7 % | 11,1 |
| Invocateur | 52,5 % | 20,0 % | 53,6 % | 47,4 % | 51,3 % | 68,8 % | 45,1 % | 51,0 % | 91,0 % | 53,0 % | 8,0 % | 10,9 |
| Barde | 38,5 % | 14,0 % | 53,0 % | 46,5 % | 46,6 % | 56,2 % | 56,4 % | 68,3 % | 92,9 % | 56,7 % | 4,0 % | 10,9 |
| Diplomate | 29,0 % | 7,5 % | 48,6 % | 35,2 % | 61,7 % | 95,7 % | 47,0 % | 87,0 % | 97,5 % | 40,7 % | 3,0 % | 9,3 |
| Pugiliste | 23,5 % | 7,0 % | 47,8 % | 51,5 % | 58,8 % | 66,0 % | 84,2 % | 44,1 % | 96,5 % | 56,7 % | 7,3 % | 11,4 |

### Boutons touchés, et pourquoi

- pas des k calculés ensemble : le k d'une classe change aussi le duo dont elle est l'acolyte ; les duels au-delà de 58 % comptent aussi (effets mesurés à graines égales avant la passe 75)
- k_classe Guerrier : 0,873 → 0,880 (46,4 % de victoires)
- k_classe Mage : 0,887 → 0,877 (49,9 % de victoires)
- k_classe Voleur : 0,813 → 0,808 (50,8 % de victoires)
- k_classe Archer : 0,913 → 0,901 (51,6 % de victoires)
- k_classe Prêtre : 0,869 → 0,878 (52,5 % de victoires)
- k_classe Alchimiste : 1,009 → 1,006 (51,4 % de victoires)
- k_classe Invocateur : 0,894 → 0,879 (53,6 % de victoires)
- k_classe Barde : 1,028 → 1,042 (53,0 % de victoires)
- k_classe Pugiliste : 1,056 → 1,061 (47,8 % de victoires)
- Tour : force des monstres au départ 0,489 → 0,494, en plus par étage 0,030 → 0,030 (étage 10 atteint dans 53,6 % des montées, étage 20 dans 6,4 %)
- Tour, Guerrier : pente des monstres 0,834 → 0,824 (étage 20 dans 3,0 % des montées)
- Tour, Guerrier : facteur des monstres 1,689 → 1,663 (étage 10 dans 46,0 % des montées)
- Tour, Mage : facteur des monstres 0,698 → 0,712 (étage 10 dans 58,7 % des montées)
- Tour, Voleur : facteur des monstres 0,956 → 0,961 (étage 10 dans 56,3 % des montées)
- Tour, Archer : facteur des monstres 0,633 → 0,651 (étage 10 dans 60,7 % des montées)
- Tour, Prêtre : facteur des monstres 1,051 → 1,064 (étage 10 dans 56,7 % des montées)
- Tour, Alchimiste : pente des monstres 1,109 → 1,126 (étage 20 dans 10,7 % des montées)
- Tour, Alchimiste : facteur des monstres 0,876 → 0,867 (étage 10 dans 51,0 % des montées)
- Tour, Barde : pente des monstres 1,607 → 1,551 (étage 20 dans 4,0 % des montées)
- Tour, Barde : facteur des monstres 0,831 → 0,836 (étage 10 dans 56,7 % des montées)
- Tour, Diplomate : pente des monstres 0,960 → 0,917 (étage 20 dans 3,0 % des montées)
- Tour, Diplomate : facteur des monstres 1,399 → 1,380 (étage 10 dans 40,7 % des montées)
- Tour, Pugiliste : facteur des monstres 0,938 → 0,943 (étage 10 dans 56,7 % des montées)

## Passe 77 (graines à partir de 7700232)

**3 critères tenus sur 6.** 50000 combats de duel (médiane 20 tours), 0 combats non finis.

### Les six critères (section 11.2)

- ❌ **1. Chaque classe entre 47 % et 53 % de victoires** : barde 53,6 %
- ❌ **2. Aucune case de la matrice hors de 40 % – 60 %** : mage contre alchimiste 63,0 %, archer contre alchimiste 62,2 %, pretre contre guerrier 61,8 %, alchimiste contre guerrier 61,6 %
- ✅ **3. La route Réactive entre 40 % et 55 % (Ruée et Éventail : des repères, sans seuil)**
- ✅ **4. Chaque voie jouée dans 15 % des combats au moins, une Clé dans 60 %**
- ✅ **5. Longueur : médiane de 18 à 22 tours, 95 % finis avant le tour 30**
- ❌ **6. Tour : étage 10 dans 40 à 60 % des montées, étage 20 dans 5 à 10 %, à 5 points près entre classes** : archer étage 20 3,3 %, diplomate étage 20 4,3 %, écart entre classes : étage 10 de 40,3 % à 55,0 %, étage 20 de 3,3 % à 9,7 %

### La matrice des classes (taux de victoire de la ligne contre la colonne)

| | Guer | Mage | Vole | Arch | Prêt | Alch | Invo | Bard | Dipl | Pugi | **Moyenne** |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 53 | 55 | 51 | 58 | 41 | 45 | 43 | 46 | 50 | 56 | **49,8 %** |
| Mage | 44 | 53 | 41 | 52 | 49 | 63 | 45 | 46 | 59 | 55 | **50,7 %** |
| Voleur | 56 | 54 | 49 | 49 | 46 | 56 | 47 | 44 | 49 | 49 | **50,0 %** |
| Archer | 44 | 53 | 53 | 51 | 43 | 62 | 51 | 52 | 58 | 55 | **52,2 %** |
| Prêtre | 62 | 50 | 51 | 59 | 47 | 41 | 50 | 43 | 58 | 50 | **51,0 %** |
| Alchimiste | 62 | 41 | 42 | 43 | 58 | 54 | 51 | 53 | 55 | 46 | **50,4 %** |
| Invocateur | 58 | 53 | 54 | 51 | 49 | 56 | 53 | 48 | 46 | 53 | **52,2 %** |
| Barde | 59 | 51 | 51 | 52 | 56 | 48 | 52 | 49 | 59 | 59 | **53,6 %** |
| Diplomate | 53 | 41 | 51 | 45 | 45 | 49 | 57 | 42 | 49 | 48 | **47,9 %** |
| Pugiliste | 43 | 45 | 53 | 47 | 49 | 51 | 52 | 45 | 52 | 52 | **48,9 %** |

### Les trois routes, l'usage des voies et la Tour, par classe

| Classe | Ruée | Éventail | Réactive | Voie 1 | Voie 2 | Voie 3 | Voie 4 | Voie 5 | Clé | Tour : étage 10 | étage 20 | étage moyen |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 40,5 % | 8,0 % | 49,8 % | 51,2 % | 70,1 % | 49,4 % | 83,3 % | 68,6 % | 97,1 % | 51,3 % | 6,7 % | 10,5 |
| Mage | 40,5 % | 15,0 % | 50,7 % | 27,9 % | 63,3 % | 55,1 % | 30,3 % | 38,6 % | 89,6 % | 53,3 % | 5,0 % | 10,7 |
| Voleur | 54,0 % | 25,5 % | 50,0 % | 48,6 % | 28,1 % | 66,3 % | 35,2 % | 46,4 % | 90,4 % | 49,7 % | 8,0 % | 10,5 |
| Archer | 44,0 % | 17,0 % | 52,2 % | 42,6 % | 39,4 % | 62,7 % | 29,6 % | 48,6 % | 89,1 % | 55,0 % | 3,3 % | 10,5 |
| Prêtre | 29,5 % | 6,5 % | 51,0 % | 55,3 % | 74,6 % | 44,0 % | 82,0 % | 78,1 % | 96,7 % | 54,3 % | 7,0 % | 10,7 |
| Alchimiste | 27,5 % | 9,0 % | 50,4 % | 56,7 % | 38,1 % | 62,1 % | 42,2 % | 66,9 % | 95,5 % | 50,3 % | 9,0 % | 10,6 |
| Invocateur | 48,5 % | 17,0 % | 52,2 % | 44,3 % | 50,8 % | 69,1 % | 43,7 % | 48,7 % | 91,2 % | 50,3 % | 6,3 % | 10,6 |
| Barde | 41,5 % | 15,0 % | 53,6 % | 48,9 % | 43,5 % | 55,8 % | 58,5 % | 68,4 % | 92,8 % | 55,0 % | 6,7 % | 11,1 |
| Diplomate | 22,5 % | 6,0 % | 47,9 % | 34,2 % | 61,7 % | 96,3 % | 49,6 % | 87,3 % | 97,2 % | 40,3 % | 4,3 % | 9,2 |
| Pugiliste | 18,5 % | 6,0 % | 48,9 % | 46,9 % | 58,1 % | 66,7 % | 87,5 % | 43,3 % | 96,7 % | 54,0 % | 9,7 % | 11,2 |

### Boutons touchés, et pourquoi

- pas des k calculés ensemble : le k d'une classe change aussi le duo dont elle est l'acolyte ; les duels au-delà de 58 % comptent aussi (effets mesurés à graines égales avant la passe 75)
- k_classe Guerrier : 0,880 → 0,882 (49,8 % de victoires)
- k_classe Mage : 0,877 → 0,863 (50,7 % de victoires)
- k_classe Voleur : 0,808 → 0,810 (50,0 % de victoires)
- k_classe Archer : 0,901 → 0,897 (52,2 % de victoires)
- k_classe Prêtre : 0,878 → 0,891 (51,0 % de victoires)
- k_classe Invocateur : 0,879 → 0,874 (52,2 % de victoires)
- k_classe Pugiliste : 1,061 → 1,063 (48,9 % de victoires)
- Tour, Mage : pente des monstres 1,154 → 1,125 (étage 20 dans 5,0 % des montées)
- Tour, Archer : pente des monstres 1,518 → 1,455 (étage 20 dans 3,3 % des montées)
- Tour, Archer : facteur des monstres 0,651 → 0,661 (étage 10 dans 55,0 % des montées)
- Tour, Prêtre : facteur des monstres 1,064 → 1,076 (étage 10 dans 54,3 % des montées)
- Tour, Barde : facteur des monstres 0,836 → 0,842 (étage 10 dans 55,0 % des montées)
- Tour, Diplomate : pente des monstres 0,917 → 0,888 (étage 20 dans 4,3 % des montées)
- Tour, Diplomate : facteur des monstres 1,380 → 1,365 (étage 10 dans 40,3 % des montées)
- Tour, Pugiliste : pente des monstres 1,041 → 1,052 (étage 20 dans 9,7 % des montées)
- Tour, Pugiliste : facteur des monstres 0,943 → 0,948 (étage 10 dans 54,0 % des montées)

## Passe 78 (graines à partir de 7800235)

**3 critères tenus sur 6.** 50000 combats de duel (médiane 19 tours), 0 combats non finis.

### Les six critères (section 11.2)

- ❌ **1. Chaque classe entre 47 % et 53 % de victoires** : guerrier 53,3 %, diplomate 45,1 %
- ❌ **2. Aucune case de la matrice hors de 40 % – 60 %** : guerrier contre mage 62,0 %, guerrier contre archer 68,0 %, guerrier contre pugiliste 61,4 %, mage contre guerrier 38,0 %, mage contre diplomate 60,8 %, archer contre guerrier 36,0 %, diplomate contre archer 39,2 %, pugiliste contre guerrier 37,8 %
- ✅ **3. La route Réactive entre 40 % et 55 % (Ruée et Éventail : des repères, sans seuil)**
- ✅ **4. Chaque voie jouée dans 15 % des combats au moins, une Clé dans 60 %**
- ✅ **5. Longueur : médiane de 18 à 22 tours, 95 % finis avant le tour 30**
- ❌ **6. Tour : étage 10 dans 40 à 60 % des montées, étage 20 dans 5 à 10 %, à 5 points près entre classes** : mage étage 20 4,3 %, barde étage 20 4,0 %, écart entre classes : étage 10 de 45,0 % à 57,0 %, étage 20 de 4,0 % à 8,7 %

### La matrice des classes (taux de victoire de la ligne contre la colonne)

| | Guer | Mage | Vole | Arch | Prêt | Alch | Invo | Bard | Dipl | Pugi | **Moyenne** |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 49 | 62 | 56 | 68 | 45 | 48 | 46 | 48 | 49 | 61 | **53,3 %** |
| Mage | 38 | 49 | 44 | 53 | 46 | 54 | 47 | 49 | 61 | 52 | **49,3 %** |
| Voleur | 46 | 56 | 48 | 51 | 52 | 57 | 49 | 48 | 48 | 47 | **50,2 %** |
| Archer | 36 | 46 | 48 | 51 | 42 | 57 | 48 | 45 | 56 | 48 | **47,7 %** |
| Prêtre | 46 | 49 | 45 | 58 | 52 | 40 | 45 | 45 | 58 | 51 | **48,9 %** |
| Alchimiste | 53 | 43 | 43 | 43 | 60 | 49 | 50 | 54 | 56 | 49 | **50,0 %** |
| Invocateur | 54 | 54 | 50 | 51 | 49 | 50 | 49 | 47 | 46 | 48 | **49,8 %** |
| Barde | 54 | 48 | 50 | 56 | 54 | 45 | 53 | 50 | 57 | 51 | **51,9 %** |
| Diplomate | 46 | 42 | 48 | 39 | 42 | 43 | 52 | 44 | 51 | 44 | **45,1 %** |
| Pugiliste | 38 | 53 | 52 | 53 | 51 | 57 | 50 | 48 | 56 | 51 | **50,8 %** |

### Les trois routes, l'usage des voies et la Tour, par classe

| Classe | Ruée | Éventail | Réactive | Voie 1 | Voie 2 | Voie 3 | Voie 4 | Voie 5 | Clé | Tour : étage 10 | étage 20 | étage moyen |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 53,5 % | 8,5 % | 53,3 % | 50,8 % | 65,4 % | 44,0 % | 88,1 % | 65,1 % | 97,5 % | 57,0 % | 5,7 % | 11,1 |
| Mage | 46,0 % | 17,0 % | 49,3 % | 31,2 % | 66,0 % | 52,8 % | 28,4 % | 35,5 % | 90,4 % | 50,0 % | 4,3 % | 10,3 |
| Voleur | 59,5 % | 29,0 % | 50,2 % | 44,8 % | 26,8 % | 65,2 % | 32,2 % | 52,2 % | 90,9 % | 45,0 % | 6,0 % | 9,8 |
| Archer | 41,5 % | 19,5 % | 47,7 % | 49,6 % | 38,1 % | 64,4 % | 26,9 % | 37,2 % | 89,3 % | 50,7 % | 5,0 % | 10,4 |
| Prêtre | 24,5 % | 8,0 % | 48,9 % | 53,5 % | 80,6 % | 32,7 % | 83,1 % | 74,8 % | 96,7 % | 54,7 % | 5,3 % | 10,6 |
| Alchimiste | 40,0 % | 9,5 % | 50,0 % | 52,9 % | 35,3 % | 65,0 % | 40,6 % | 68,6 % | 96,2 % | 50,7 % | 7,7 % | 10,7 |
| Invocateur | 53,0 % | 22,0 % | 49,8 % | 42,6 % | 50,3 % | 71,0 % | 41,5 % | 48,3 % | 91,7 % | 47,3 % | 8,7 % | 10,4 |
| Barde | 45,0 % | 17,0 % | 51,9 % | 46,6 % | 41,0 % | 56,6 % | 58,7 % | 67,7 % | 92,8 % | 45,0 % | 4,0 % | 10,0 |
| Diplomate | 19,0 % | 7,0 % | 45,1 % | 34,3 % | 58,6 % | 94,9 % | 47,3 % | 86,5 % | 97,6 % | 46,0 % | 7,0 % | 9,7 |
| Pugiliste | 23,0 % | 9,0 % | 50,8 % | 44,4 % | 55,7 % | 66,8 % | 88,2 % | 41,3 % | 96,8 % | 50,3 % | 6,0 % | 10,5 |

### Boutons touchés, et pourquoi

- pas des k calculés ensemble : le k d'une classe change aussi le duo dont elle est l'acolyte ; les duels au-delà de 58 % comptent aussi (effets mesurés à graines égales avant la passe 75)
- k_classe Guerrier : 0,882 → 0,873 (53,3 % de victoires)
- k_classe Mage : 0,863 → 0,881 (49,3 % de victoires)
- k_classe Voleur : 0,810 → 0,804 (50,2 % de victoires)
- k_classe Archer : 0,897 → 0,910 (47,7 % de victoires)
- k_classe Prêtre : 0,891 → 0,879 (48,9 % de victoires)
- k_classe Alchimiste : 1,006 → 1,006 (50,0 % de victoires)
- k_classe Invocateur : 0,874 → 0,870 (49,8 % de victoires)
- k_classe Barde : 1,042 → 1,024 (51,9 % de victoires)
- k_classe Pugiliste : 1,063 → 1,069 (50,8 % de victoires)
- Tour : force des monstres au départ 0,494 → 0,494, en plus par étage 0,030 → 0,029 (étage 10 atteint dans 49,7 % des montées, étage 20 dans 6,0 %)
- Tour, Guerrier : facteur des monstres 1,663 → 1,675 (étage 10 dans 57,0 % des montées)
- Tour, Mage : pente des monstres 1,125 → 1,089 (étage 20 dans 4,3 % des montées)
- Tour, Voleur : facteur des monstres 0,961 → 0,957 (étage 10 dans 45,0 % des montées)
- Tour, Archer : pente des monstres 1,455 → 1,418 (étage 20 dans 5,0 % des montées)
- Tour, Prêtre : pente des monstres 0,970 → 0,964 (étage 20 dans 5,3 % des montées)
- Tour, Prêtre : facteur des monstres 1,076 → 1,098 (étage 10 dans 54,7 % des montées)
- Tour, Invocateur : facteur des monstres 0,979 → 0,970 (étage 10 dans 47,3 % des montées)
- Tour, Barde : pente des monstres 1,551 → 1,497 (étage 20 dans 4,0 % des montées)
- Tour, Barde : facteur des monstres 0,842 → 0,838 (étage 10 dans 45,0 % des montées)
- Tour, Diplomate : facteur des monstres 1,365 → 1,360 (étage 10 dans 46,0 % des montées)

## Passe 79 (graines à partir de 7900238)

**3 critères tenus sur 6.** 100000 combats de duel (médiane 19 tours), 0 combats non finis.

### Les six critères (section 11.2)

- ❌ **1. Chaque classe entre 47 % et 53 % de victoires** : pretre 53,2 %, diplomate 45,7 %
- ❌ **2. Aucune case de la matrice hors de 40 % – 60 %** : archer contre alchimiste 61,7 %, pretre contre guerrier 61,8 %, alchimiste contre archer 39,1 %
- ✅ **3. La route Réactive entre 40 % et 55 % (Ruée et Éventail : des repères, sans seuil)**
- ✅ **4. Chaque voie jouée dans 15 % des combats au moins, une Clé dans 60 %**
- ✅ **5. Longueur : médiane de 18 à 22 tours, 95 % finis avant le tour 30**
- ❌ **6. Tour : étage 10 dans 40 à 60 % des montées, étage 20 dans 5 à 10 %, à 5 points près entre classes** : alchimiste étage 20 11,4 %, écart entre classes : étage 10 de 43,6 % à 58,1 %, étage 20 de 5,3 % à 11,4 %

### La matrice des classes (taux de victoire de la ligne contre la colonne)

| | Guer | Mage | Vole | Arch | Prêt | Alch | Invo | Bard | Dipl | Pugi | **Moyenne** |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 50 | 54 | 45 | 56 | 42 | 44 | 42 | 44 | 45 | 55 | **47,5 %** |
| Mage | 46 | 49 | 43 | 44 | 50 | 60 | 41 | 54 | 59 | 51 | **49,7 %** |
| Voleur | 52 | 53 | 47 | 45 | 48 | 56 | 46 | 49 | 51 | 48 | **49,5 %** |
| Archer | 44 | 52 | 53 | 50 | 43 | 62 | 50 | 51 | 58 | 52 | **51,3 %** |
| Prêtre | 62 | 56 | 50 | 54 | 51 | 45 | 53 | 47 | 58 | 55 | **53,2 %** |
| Alchimiste | 59 | 41 | 46 | 39 | 55 | 49 | 45 | 56 | 56 | 46 | **49,2 %** |
| Invocateur | 58 | 55 | 52 | 48 | 49 | 56 | 46 | 50 | 45 | 52 | **51,0 %** |
| Barde | 57 | 49 | 48 | 47 | 56 | 48 | 50 | 51 | 58 | 54 | **51,7 %** |
| Diplomate | 52 | 43 | 50 | 42 | 43 | 44 | 49 | 42 | 50 | 43 | **45,7 %** |
| Pugiliste | 46 | 49 | 51 | 48 | 50 | 56 | 49 | 46 | 55 | 52 | **50,0 %** |

### Les trois routes, l'usage des voies et la Tour, par classe

| Classe | Ruée | Éventail | Réactive | Voie 1 | Voie 2 | Voie 3 | Voie 4 | Voie 5 | Clé | Tour : étage 10 | étage 20 | étage moyen |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 35,5 % | 9,3 % | 47,5 % | 46,6 % | 72,0 % | 46,0 % | 86,3 % | 66,7 % | 97,2 % | 50,2 % | 6,4 % | 10,5 |
| Mage | 50,0 % | 13,0 % | 49,7 % | 28,7 % | 63,1 % | 55,3 % | 31,8 % | 39,1 % | 90,0 % | 56,3 % | 6,3 % | 11,1 |
| Voleur | 52,5 % | 19,5 % | 49,5 % | 44,5 % | 28,9 % | 66,2 % | 37,4 % | 46,5 % | 91,1 % | 58,1 % | 8,5 % | 11,3 |
| Archer | 45,5 % | 16,0 % | 51,3 % | 44,6 % | 42,9 % | 62,6 % | 28,9 % | 50,3 % | 89,6 % | 56,8 % | 7,9 % | 11,1 |
| Prêtre | 25,5 % | 8,0 % | 53,2 % | 54,9 % | 74,8 % | 42,0 % | 82,4 % | 80,0 % | 96,2 % | 55,9 % | 8,6 % | 11,1 |
| Alchimiste | 37,8 % | 9,3 % | 49,2 % | 53,6 % | 36,5 % | 63,6 % | 40,8 % | 68,0 % | 95,9 % | 51,0 % | 11,4 % | 11,1 |
| Invocateur | 40,8 % | 12,8 % | 51,0 % | 40,8 % | 51,1 % | 71,7 % | 42,2 % | 51,0 % | 91,6 % | 55,0 % | 7,9 % | 10,9 |
| Barde | 30,0 % | 8,0 % | 51,7 % | 47,2 % | 43,0 % | 57,1 % | 57,7 % | 67,5 % | 93,3 % | 55,4 % | 6,4 % | 11,2 |
| Diplomate | 20,0 % | 4,8 % | 45,7 % | 34,4 % | 60,5 % | 95,3 % | 47,4 % | 87,1 % | 97,4 % | 43,6 % | 5,3 % | 9,5 |
| Pugiliste | 14,5 % | 3,5 % | 50,0 % | 47,6 % | 57,1 % | 66,0 % | 89,1 % | 42,1 % | 97,1 % | 56,1 % | 8,4 % | 11,2 |

### Boutons touchés, et pourquoi

- pas des k calculés ensemble : le k d'une classe change aussi le duo dont elle est l'acolyte ; les duels au-delà de 58 % comptent aussi (effets mesurés à graines égales avant la passe 79)
- k_classe Guerrier : 0,873 → 0,877 (47,5 % de victoires)
- k_classe Mage : 0,881 → 0,877 (49,7 % de victoires)
- k_classe Voleur : 0,804 → 0,806 (49,5 % de victoires)
- k_classe Archer : 0,910 → 0,896 (51,3 % de victoires)
- k_classe Prêtre : 0,879 → 0,873 (53,2 % de victoires)
- k_classe Alchimiste : 1,006 → 1,010 (49,2 % de victoires)
- k_classe Invocateur : 0,870 → 0,876 (51,0 % de victoires)
- k_classe Barde : 1,024 → 1,034 (51,7 % de victoires)
- k_classe Pugiliste : 1,069 → 1,062 (50,0 % de victoires)
- Tour : force des monstres au départ 0,494 → 0,500, en plus par étage 0,029 → 0,029 (étage 10 atteint dans 53,8 % des montées, étage 20 dans 7,7 %)
- Tour, Guerrier : facteur des monstres 1,675 → 1,673 (étage 10 dans 50,2 % des montées)
- Tour, Mage : facteur des monstres 0,712 → 0,719 (étage 10 dans 56,2 % des montées)
- Tour, Voleur : facteur des monstres 0,957 → 0,959 (étage 10 dans 58,1 % des montées)
- Tour, Archer : facteur des monstres 0,661 → 0,668 (étage 10 dans 56,8 % des montées)
- Tour, Prêtre : facteur des monstres 1,098 → 1,107 (étage 10 dans 55,9 % des montées)
- Tour, Alchimiste : pente des monstres 1,126 → 1,148 (étage 20 dans 11,4 % des montées)
- Tour, Alchimiste : facteur des monstres 0,867 → 0,857 (étage 10 dans 51,0 % des montées)
- Tour, Diplomate : pente des monstres 0,888 → 0,868 (étage 20 dans 5,2 % des montées)
- Tour, Diplomate : facteur des monstres 1,360 → 1,346 (étage 10 dans 43,6 % des montées)
- Tour, Pugiliste : facteur des monstres 0,948 → 0,953 (étage 10 dans 56,1 % des montées)

## Passe 80 (graines à partir de 8000241)

**3 critères tenus sur 6.** 100000 combats de duel (médiane 19 tours), 0 combats non finis.

### Les six critères (section 11.2)

- ❌ **1. Chaque classe entre 47 % et 53 % de victoires** : archer 46,5 %, diplomate 46,5 %
- ❌ **2. Aucune case de la matrice hors de 40 % – 60 %** : guerrier contre archer 63,5 %, guerrier contre pugiliste 60,1 %, archer contre guerrier 37,9 %, archer contre pretre 38,8 %, pretre contre archer 61,4 %, pretre contre alchimiste 38,7 %
- ✅ **3. La route Réactive entre 40 % et 55 % (Ruée et Éventail : des repères, sans seuil)**
- ✅ **4. Chaque voie jouée dans 15 % des combats au moins, une Clé dans 60 %**
- ✅ **5. Longueur : médiane de 18 à 22 tours, 95 % finis avant le tour 30**
- ❌ **6. Tour : étage 10 dans 40 à 60 % des montées, étage 20 dans 5 à 10 %, à 5 points près entre classes** : archer étage 20 3,0 %, alchimiste étage 20 10,1 %, écart entre classes : étage 10 de 43,0 % à 58,1 %, étage 20 de 3,0 % à 10,1 %

### La matrice des classes (taux de victoire de la ligne contre la colonne)

| | Guer | Mage | Vole | Arch | Prêt | Alch | Invo | Bard | Dipl | Pugi | **Moyenne** |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 50 | 56 | 51 | 64 | 44 | 44 | 43 | 43 | 51 | 60 | **50,4 %** |
| Mage | 46 | 48 | 45 | 56 | 47 | 57 | 44 | 51 | 59 | 52 | **50,7 %** |
| Voleur | 50 | 55 | 47 | 52 | 52 | 55 | 45 | 47 | 48 | 49 | **50,0 %** |
| Archer | 38 | 45 | 46 | 53 | 39 | 53 | 46 | 45 | 55 | 45 | **46,5 %** |
| Prêtre | 55 | 48 | 46 | 61 | 49 | 39 | 51 | 40 | 56 | 49 | **49,4 %** |
| Alchimiste | 54 | 41 | 41 | 43 | 57 | 48 | 44 | 52 | 52 | 46 | **47,8 %** |
| Invocateur | 57 | 56 | 52 | 55 | 52 | 52 | 51 | 49 | 46 | 51 | **52,1 %** |
| Barde | 55 | 48 | 50 | 53 | 54 | 44 | 51 | 47 | 57 | 53 | **51,3 %** |
| Diplomate | 50 | 41 | 52 | 46 | 42 | 43 | 53 | 44 | 50 | 44 | **46,5 %** |
| Pugiliste | 43 | 50 | 51 | 54 | 52 | 54 | 45 | 45 | 56 | 53 | **50,3 %** |

### Les trois routes, l'usage des voies et la Tour, par classe

| Classe | Ruée | Éventail | Réactive | Voie 1 | Voie 2 | Voie 3 | Voie 4 | Voie 5 | Clé | Tour : étage 10 | étage 20 | étage moyen |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 40,3 % | 11,3 % | 50,4 % | 49,7 % | 66,8 % | 45,9 % | 87,3 % | 66,0 % | 97,5 % | 50,0 % | 5,5 % | 10,3 |
| Mage | 48,8 % | 16,3 % | 50,7 % | 29,0 % | 62,6 % | 56,2 % | 30,0 % | 41,5 % | 89,6 % | 58,1 % | 6,1 % | 11,1 |
| Voleur | 51,0 % | 22,0 % | 50,0 % | 45,9 % | 27,8 % | 65,9 % | 37,5 % | 49,4 % | 91,0 % | 48,8 % | 5,5 % | 10,2 |
| Archer | 47,8 % | 14,5 % | 46,5 % | 40,7 % | 41,1 % | 69,0 % | 25,7 % | 42,1 % | 88,8 % | 48,1 % | 3,0 % | 10,3 |
| Prêtre | 26,8 % | 12,5 % | 49,4 % | 52,7 % | 75,4 % | 43,8 % | 83,4 % | 78,4 % | 96,7 % | 43,0 % | 5,5 % | 9,8 |
| Alchimiste | 36,5 % | 12,0 % | 47,8 % | 57,9 % | 34,6 % | 62,9 % | 39,2 % | 63,8 % | 95,7 % | 47,6 % | 10,1 % | 10,7 |
| Invocateur | 47,5 % | 16,0 % | 52,1 % | 42,0 % | 50,8 % | 70,4 % | 43,7 % | 50,7 % | 91,2 % | 51,4 % | 7,8 % | 10,6 |
| Barde | 44,3 % | 14,0 % | 51,3 % | 46,6 % | 44,3 % | 56,0 % | 56,5 % | 69,1 % | 92,8 % | 49,1 % | 6,0 % | 10,6 |
| Diplomate | 23,3 % | 5,8 % | 46,5 % | 33,9 % | 61,0 % | 95,4 % | 47,4 % | 86,3 % | 97,3 % | 43,5 % | 5,6 % | 9,6 |
| Pugiliste | 14,8 % | 6,0 % | 50,3 % | 41,1 % | 53,7 % | 62,8 % | 91,7 % | 40,6 % | 97,3 % | 48,9 % | 7,2 % | 10,5 |

### Boutons touchés, et pourquoi

- pas des k calculés ensemble : le k d'une classe change aussi le duo dont elle est l'acolyte ; les duels au-delà de 58 % comptent aussi (effets mesurés à graines égales avant la passe 79)
- k_classe Guerrier : 0,877 → 0,876 (50,4 % de victoires)
- k_classe Mage : 0,877 → 0,884 (50,7 % de victoires)
- k_classe Voleur : 0,806 → 0,797 (50,0 % de victoires)
- k_classe Archer : 0,896 → 0,911 (46,5 % de victoires)
- k_classe Prêtre : 0,873 → 0,870 (49,4 % de victoires)
- k_classe Alchimiste : 1,010 → 1,015 (47,8 % de victoires)
- k_classe Invocateur : 0,876 → 0,861 (52,1 % de victoires)
- k_classe Barde : 1,034 → 1,019 (51,3 % de victoires)
- k_classe Pugiliste : 1,062 → 1,069 (50,3 % de victoires)
- Tour, Mage : facteur des monstres 0,719 → 0,745 (étage 10 dans 58,1 % des montées)
- Tour, Archer : pente des monstres 1,418 → 1,355 (étage 20 dans 3,0 % des montées)
- Tour, Prêtre : facteur des monstres 1,107 → 1,094 (étage 10 dans 43,0 % des montées)
- Tour, Alchimiste : pente des monstres 1,148 → 1,163 (étage 20 dans 10,1 % des montées)
- Tour, Invocateur : facteur des monstres 0,970 → 0,975 (étage 10 dans 51,4 % des montées)
- Tour, Diplomate : facteur des monstres 1,346 → 1,339 (étage 10 dans 43,5 % des montées)

## Passe 81 (graines à partir de 8100244)

**3 critères tenus sur 6.** 100000 combats de duel (médiane 19 tours), 0 combats non finis.

### Les six critères (section 11.2)

- ❌ **1. Chaque classe entre 47 % et 53 % de victoires** : diplomate 45,6 %
- ❌ **2. Aucune case de la matrice hors de 40 % – 60 %** : mage contre diplomate 60,2 %
- ✅ **3. La route Réactive entre 40 % et 55 % (Ruée et Éventail : des repères, sans seuil)**
- ✅ **4. Chaque voie jouée dans 15 % des combats au moins, une Clé dans 60 %**
- ✅ **5. Longueur : médiane de 18 à 22 tours, 95 % finis avant le tour 30**
- ❌ **6. Tour : étage 10 dans 40 à 60 % des montées, étage 20 dans 5 à 10 %, à 5 points près entre classes** : mage étage 20 3,9 %, diplomate étage 20 4,4 %, écart entre classes : étage 10 de 41,0 % à 55,4 %, étage 20 de 3,9 % à 8,3 %

### La matrice des classes (taux de victoire de la ligne contre la colonne)

| | Guer | Mage | Vole | Arch | Prêt | Alch | Invo | Bard | Dipl | Pugi | **Moyenne** |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 50 | 51 | 47 | 57 | 42 | 43 | 42 | 44 | 43 | 60 | **47,9 %** |
| Mage | 48 | 51 | 45 | 50 | 47 | 58 | 45 | 53 | 60 | 52 | **50,8 %** |
| Voleur | 50 | 54 | 52 | 47 | 52 | 58 | 46 | 50 | 50 | 52 | **51,0 %** |
| Archer | 42 | 48 | 52 | 51 | 43 | 60 | 47 | 50 | 57 | 52 | **50,1 %** |
| Prêtre | 58 | 52 | 50 | 58 | 50 | 45 | 52 | 47 | 58 | 53 | **52,3 %** |
| Alchimiste | 56 | 43 | 42 | 41 | 58 | 50 | 45 | 57 | 55 | 46 | **49,3 %** |
| Invocateur | 56 | 57 | 51 | 54 | 50 | 53 | 47 | 50 | 50 | 57 | **52,3 %** |
| Barde | 55 | 45 | 52 | 50 | 54 | 43 | 49 | 48 | 57 | 56 | **50,9 %** |
| Diplomate | 52 | 41 | 49 | 42 | 43 | 43 | 52 | 41 | 50 | 43 | **45,6 %** |
| Pugiliste | 42 | 48 | 46 | 49 | 44 | 54 | 45 | 43 | 55 | 50 | **47,5 %** |

### Les trois routes, l'usage des voies et la Tour, par classe

| Classe | Ruée | Éventail | Réactive | Voie 1 | Voie 2 | Voie 3 | Voie 4 | Voie 5 | Clé | Tour : étage 10 | étage 20 | étage moyen |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 42,3 % | 7,8 % | 47,9 % | 45,4 % | 70,7 % | 47,4 % | 86,9 % | 65,6 % | 97,3 % | 53,4 % | 6,1 % | 10,6 |
| Mage | 46,8 % | 13,8 % | 50,8 % | 31,0 % | 62,3 % | 55,6 % | 30,2 % | 39,3 % | 90,3 % | 47,4 % | 3,9 % | 10,3 |
| Voleur | 53,8 % | 23,5 % | 51,0 % | 43,5 % | 28,5 % | 66,0 % | 33,3 % | 50,9 % | 91,2 % | 50,6 % | 5,0 % | 10,1 |
| Archer | 47,0 % | 14,2 % | 50,1 % | 50,5 % | 45,6 % | 59,9 % | 28,0 % | 39,2 % | 89,3 % | 55,4 % | 5,4 % | 10,9 |
| Prêtre | 27,5 % | 9,3 % | 52,3 % | 54,9 % | 76,8 % | 39,8 % | 82,5 % | 77,4 % | 96,7 % | 49,3 % | 5,0 % | 10,1 |
| Alchimiste | 36,3 % | 8,3 % | 49,3 % | 52,9 % | 33,8 % | 65,2 % | 39,4 % | 69,0 % | 96,6 % | 46,5 % | 8,3 % | 10,5 |
| Invocateur | 45,8 % | 15,3 % | 52,3 % | 43,5 % | 48,7 % | 71,1 % | 43,4 % | 50,7 % | 91,6 % | 51,5 % | 6,9 % | 10,6 |
| Barde | 40,3 % | 10,8 % | 50,9 % | 49,4 % | 42,9 % | 58,1 % | 56,8 % | 67,0 % | 93,4 % | 49,5 % | 5,0 % | 10,4 |
| Diplomate | 25,0 % | 6,5 % | 45,6 % | 34,2 % | 61,1 % | 95,7 % | 48,1 % | 86,8 % | 97,6 % | 41,0 % | 4,4 % | 9,2 |
| Pugiliste | 14,0 % | 4,8 % | 47,5 % | 57,2 % | 56,4 % | 65,6 % | 82,5 % | 41,9 % | 97,2 % | 52,0 % | 6,5 % | 10,7 |

### Boutons touchés, et pourquoi

- pas des k calculés ensemble : le k d'une classe change aussi le duo dont elle est l'acolyte ; les duels au-delà de 58 % comptent aussi (effets mesurés à graines égales avant la passe 79)
- k_classe Guerrier : 0,876 → 0,880 (47,9 % de victoires)
- k_classe Mage : 0,884 → 0,880 (50,8 % de victoires)
- k_classe Voleur : 0,797 → 0,788 (51,0 % de victoires)
- k_classe Archer : 0,911 → 0,907 (50,1 % de victoires)
- k_classe Prêtre : 0,870 → 0,869 (52,3 % de victoires)
- k_classe Alchimiste : 1,015 → 1,022 (49,3 % de victoires)
- k_classe Invocateur : 0,861 → 0,845 (52,3 % de victoires)
- k_classe Barde : 1,019 → 1,024 (50,9 % de victoires)
- k_classe Pugiliste : 1,069 → 1,075 (47,5 % de victoires)
- Tour : force des monstres au départ 0,500 → 0,500, en plus par étage 0,029 → 0,029 (étage 10 atteint dans 49,6 % des montées, étage 20 dans 5,6 %)
- Tour, Guerrier : facteur des monstres 1,673 → 1,676 (étage 10 dans 53,4 % des montées)
- Tour, Mage : pente des monstres 1,089 → 1,050 (étage 20 dans 3,9 % des montées)
- Tour, Mage : facteur des monstres 0,745 → 0,742 (étage 10 dans 47,4 % des montées)
- Tour, Voleur : pente des monstres 0,481 → 0,469 (étage 20 dans 5,0 % des montées)
- Tour, Archer : pente des monstres 1,355 → 1,326 (étage 20 dans 5,4 % des montées)
- Tour, Archer : facteur des monstres 0,668 → 0,684 (étage 10 dans 55,4 % des montées)
- Tour, Prêtre : pente des monstres 0,964 → 0,958 (étage 20 dans 5,0 % des montées)
- Tour, Alchimiste : facteur des monstres 0,857 → 0,847 (étage 10 dans 46,5 % des montées)
- Tour, Barde : pente des monstres 1,497 → 1,459 (étage 20 dans 5,0 % des montées)
- Tour, Diplomate : pente des monstres 0,868 → 0,841 (étage 20 dans 4,4 % des montées)
- Tour, Diplomate : facteur des monstres 1,339 → 1,327 (étage 10 dans 41,0 % des montées)
- Tour, Pugiliste : facteur des monstres 0,953 → 0,957 (étage 10 dans 52,0 % des montées)

## Passe 82 (graines à partir de 8200247)

**3 critères tenus sur 6.** 100000 combats de duel (médiane 19 tours), 0 combats non finis.

### Les six critères (section 11.2)

- ❌ **1. Chaque classe entre 47 % et 53 % de victoires** : diplomate 43,2 %
- ❌ **2. Aucune case de la matrice hors de 40 % – 60 %** : mage contre diplomate 60,9 %, archer contre alchimiste 60,1 %, archer contre diplomate 60,9 %, alchimiste contre mage 38,8 %, diplomate contre mage 36,0 %, diplomate contre archer 36,9 %, diplomate contre barde 38,8 %
- ✅ **3. La route Réactive entre 40 % et 55 % (Ruée et Éventail : des repères, sans seuil)**
- ✅ **4. Chaque voie jouée dans 15 % des combats au moins, une Clé dans 60 %**
- ✅ **5. Longueur : médiane de 18 à 22 tours, 95 % finis avant le tour 30**
- ❌ **6. Tour : étage 10 dans 40 à 60 % des montées, étage 20 dans 5 à 10 %, à 5 points près entre classes** : archer étage 20 4,9 %, alchimiste étage 20 10,6 %, invocateur étage 20 4,8 %, diplomate étage 10 36,8 %, diplomate étage 20 4,0 %, écart entre classes : étage 10 de 36,8 % à 55,8 %, étage 20 de 4,0 % à 10,6 %

### La matrice des classes (taux de victoire de la ligne contre la colonne)

| | Guer | Mage | Vole | Arch | Prêt | Alch | Invo | Bard | Dipl | Pugi | **Moyenne** |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 48 | 53 | 47 | 56 | 40 | 42 | 41 | 43 | 48 | 54 | **47,3 %** |
| Mage | 48 | 48 | 44 | 48 | 49 | 57 | 45 | 55 | 61 | 49 | **50,5 %** |
| Voleur | 50 | 53 | 49 | 47 | 49 | 56 | 48 | 49 | 47 | 51 | **49,8 %** |
| Archer | 42 | 50 | 53 | 47 | 45 | 60 | 51 | 53 | 61 | 51 | **51,3 %** |
| Prêtre | 58 | 50 | 49 | 54 | 49 | 40 | 51 | 45 | 57 | 50 | **50,2 %** |
| Alchimiste | 59 | 39 | 43 | 40 | 59 | 51 | 46 | 55 | 55 | 46 | **49,3 %** |
| Invocateur | 55 | 54 | 51 | 49 | 49 | 52 | 48 | 50 | 48 | 51 | **50,6 %** |
| Barde | 56 | 44 | 51 | 47 | 54 | 44 | 51 | 50 | 57 | 53 | **50,5 %** |
| Diplomate | 52 | 36 | 48 | 37 | 41 | 42 | 51 | 39 | 46 | 41 | **43,2 %** |
| Pugiliste | 42 | 46 | 49 | 45 | 49 | 56 | 47 | 45 | 56 | 48 | **48,2 %** |

### Les trois routes, l'usage des voies et la Tour, par classe

| Classe | Ruée | Éventail | Réactive | Voie 1 | Voie 2 | Voie 3 | Voie 4 | Voie 5 | Clé | Tour : étage 10 | étage 20 | étage moyen |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 41,8 % | 9,0 % | 47,3 % | 50,8 % | 70,0 % | 46,2 % | 84,9 % | 65,8 % | 97,1 % | 50,6 % | 6,4 % | 10,5 |
| Mage | 53,8 % | 19,5 % | 50,5 % | 28,8 % | 63,4 % | 56,5 % | 29,6 % | 38,8 % | 89,7 % | 46,8 % | 5,3 % | 10,5 |
| Voleur | 49,8 % | 23,3 % | 49,8 % | 45,8 % | 27,5 % | 68,7 % | 39,2 % | 44,3 % | 90,9 % | 51,9 % | 8,8 % | 10,6 |
| Archer | 52,8 % | 19,8 % | 51,3 % | 44,5 % | 42,6 % | 64,0 % | 26,9 % | 45,5 % | 89,3 % | 54,4 % | 4,9 % | 10,9 |
| Prêtre | 27,5 % | 7,5 % | 50,2 % | 54,9 % | 75,8 % | 41,2 % | 83,0 % | 78,8 % | 96,4 % | 51,4 % | 7,0 % | 10,6 |
| Alchimiste | 34,0 % | 10,0 % | 49,3 % | 55,1 % | 36,4 % | 61,7 % | 39,2 % | 67,2 % | 96,3 % | 50,7 % | 10,6 % | 11,0 |
| Invocateur | 44,8 % | 17,8 % | 50,6 % | 37,2 % | 47,7 % | 73,3 % | 43,1 % | 51,2 % | 90,9 % | 47,8 % | 4,8 % | 10,2 |
| Barde | 43,3 % | 15,8 % | 50,5 % | 48,1 % | 44,2 % | 58,0 % | 57,5 % | 66,6 % | 93,2 % | 55,8 % | 6,0 % | 11,0 |
| Diplomate | 21,0 % | 3,3 % | 43,2 % | 33,9 % | 59,8 % | 95,5 % | 47,9 % | 86,6 % | 97,4 % | 36,8 % | 4,0 % | 9,0 |
| Pugiliste | 19,3 % | 6,3 % | 48,2 % | 50,2 % | 54,3 % | 65,6 % | 85,5 % | 42,6 % | 97,0 % | 52,6 % | 8,3 % | 10,7 |

### Boutons touchés, et pourquoi

- pas des k calculés ensemble : le k d'une classe change aussi le duo dont elle est l'acolyte ; les duels au-delà de 58 % comptent aussi (effets mesurés à graines égales avant la passe 79)
- k_classe Guerrier : 0,880 → 0,878 (47,3 % de victoires)
- k_classe Mage : 0,880 → 0,871 (50,5 % de victoires)
- k_classe Voleur : 0,788 → 0,783 (49,8 % de victoires)
- k_classe Archer : 0,907 → 0,899 (51,3 % de victoires)
- k_classe Prêtre : 0,869 → 0,881 (50,2 % de victoires)
- k_classe Invocateur : 0,845 → 0,848 (50,6 % de victoires)
- k_classe Barde : 1,024 → 1,030 (50,5 % de victoires)
- k_classe Pugiliste : 1,075 → 1,072 (48,2 % de victoires)
- Tour, Mage : pente des monstres 1,050 → 1,026 (étage 20 dans 5,2 % des montées)
- Tour, Mage : facteur des monstres 0,742 → 0,737 (étage 10 dans 46,8 % des montées)
- Tour, Voleur : facteur des monstres 0,959 → 0,961 (étage 10 dans 51,9 % des montées)
- Tour, Archer : pente des monstres 1,326 → 1,291 (étage 20 dans 4,9 % des montées)
- Tour, Archer : facteur des monstres 0,684 → 0,696 (étage 10 dans 54,4 % des montées)
- Tour, Alchimiste : pente des monstres 1,163 → 1,181 (étage 20 dans 10,6 % des montées)
- Tour, Invocateur : pente des monstres 1,249 → 1,215 (étage 20 dans 4,8 % des montées)
- Tour, Invocateur : facteur des monstres 0,975 → 0,973 (étage 10 dans 47,8 % des montées)
- Tour, Barde : facteur des monstres 0,838 → 0,841 (étage 10 dans 55,8 % des montées)
- Tour, Diplomate : pente des monstres 0,841 → 0,811 (étage 20 dans 4,0 % des montées)
- Tour, Diplomate : facteur des monstres 1,327 → 1,310 (étage 10 dans 36,8 % des montées)
- Tour, Pugiliste : facteur des monstres 0,957 → 0,962 (étage 10 dans 52,6 % des montées)

## Passe 83 (graines à partir de 8300250)

**3 critères tenus sur 6.** 100000 combats de duel (médiane 20 tours), 0 combats non finis.

### Les six critères (section 11.2)

- ❌ **1. Chaque classe entre 47 % et 53 % de victoires** : diplomate 44,3 %
- ❌ **2. Aucune case de la matrice hors de 40 % – 60 %** : mage contre diplomate 60,3 %, archer contre guerrier 38,5 %, pretre contre alchimiste 39,7 %, alchimiste contre pretre 61,2 %, diplomate contre mage 38,7 %
- ✅ **3. La route Réactive entre 40 % et 55 % (Ruée et Éventail : des repères, sans seuil)**
- ✅ **4. Chaque voie jouée dans 15 % des combats au moins, une Clé dans 60 %**
- ✅ **5. Longueur : médiane de 18 à 22 tours, 95 % finis avant le tour 30**
- ❌ **6. Tour : étage 10 dans 40 à 60 % des montées, étage 20 dans 5 à 10 %, à 5 points près entre classes** : archer étage 20 4,9 %, alchimiste étage 20 11,1 %, écart entre classes : étage 10 de 40,3 % à 57,3 %, étage 20 de 4,9 % à 11,1 %

### La matrice des classes (taux de victoire de la ligne contre la colonne)

| | Guer | Mage | Vole | Arch | Prêt | Alch | Invo | Bard | Dipl | Pugi | **Moyenne** |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 51 | 56 | 55 | 60 | 44 | 48 | 44 | 47 | 49 | 59 | **51,3 %** |
| Mage | 41 | 48 | 47 | 51 | 45 | 55 | 44 | 52 | 60 | 54 | **49,6 %** |
| Voleur | 45 | 54 | 49 | 47 | 51 | 55 | 46 | 48 | 50 | 51 | **49,5 %** |
| Archer | 39 | 47 | 52 | 47 | 41 | 55 | 48 | 48 | 56 | 50 | **48,3 %** |
| Prêtre | 56 | 51 | 50 | 57 | 49 | 40 | 49 | 45 | 56 | 50 | **50,3 %** |
| Alchimiste | 56 | 47 | 45 | 46 | 61 | 49 | 47 | 56 | 59 | 47 | **51,1 %** |
| Invocateur | 50 | 55 | 52 | 50 | 50 | 54 | 51 | 50 | 51 | 52 | **51,5 %** |
| Barde | 51 | 49 | 54 | 48 | 56 | 45 | 50 | 49 | 59 | 55 | **51,5 %** |
| Diplomate | 49 | 39 | 49 | 43 | 42 | 42 | 50 | 41 | 47 | 42 | **44,3 %** |
| Pugiliste | 40 | 47 | 48 | 48 | 51 | 52 | 46 | 47 | 57 | 52 | **48,6 %** |

### Les trois routes, l'usage des voies et la Tour, par classe

| Classe | Ruée | Éventail | Réactive | Voie 1 | Voie 2 | Voie 3 | Voie 4 | Voie 5 | Clé | Tour : étage 10 | étage 20 | étage moyen |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 39,0 % | 8,5 % | 51,3 % | 49,8 % | 67,5 % | 45,6 % | 87,0 % | 68,2 % | 97,5 % | 57,3 % | 8,6 % | 11,1 |
| Mage | 54,0 % | 18,0 % | 49,6 % | 28,8 % | 65,9 % | 55,6 % | 29,6 % | 37,9 % | 90,4 % | 53,4 % | 5,3 % | 10,8 |
| Voleur | 51,5 % | 22,0 % | 49,5 % | 46,7 % | 27,4 % | 69,0 % | 40,5 % | 43,0 % | 91,1 % | 51,6 % | 7,1 % | 10,6 |
| Archer | 52,5 % | 19,8 % | 48,3 % | 44,7 % | 39,9 % | 66,5 % | 26,1 % | 48,4 % | 89,5 % | 47,9 % | 4,9 % | 10,3 |
| Prêtre | 25,3 % | 8,0 % | 50,3 % | 53,5 % | 76,6 % | 40,6 % | 82,6 % | 78,8 % | 96,7 % | 51,2 % | 9,1 % | 10,5 |
| Alchimiste | 33,8 % | 9,8 % | 51,1 % | 54,9 % | 37,7 % | 61,1 % | 39,2 % | 68,2 % | 96,5 % | 51,4 % | 11,1 % | 11,1 |
| Invocateur | 44,3 % | 15,0 % | 51,5 % | 35,5 % | 48,8 % | 73,9 % | 44,5 % | 55,1 % | 91,7 % | 50,2 % | 8,3 % | 10,7 |
| Barde | 37,3 % | 9,0 % | 51,5 % | 48,0 % | 41,8 % | 57,1 % | 56,7 % | 69,9 % | 93,8 % | 56,4 % | 7,0 % | 11,2 |
| Diplomate | 27,5 % | 5,0 % | 44,3 % | 33,8 % | 60,9 % | 95,8 % | 49,0 % | 86,3 % | 97,1 % | 40,3 % | 6,4 % | 9,3 |
| Pugiliste | 15,3 % | 4,8 % | 48,6 % | 59,8 % | 56,5 % | 64,4 % | 82,0 % | 41,7 % | 97,8 % | 51,7 % | 8,1 % | 10,8 |

### Boutons touchés, et pourquoi

- pas des k calculés ensemble : le k d'une classe change aussi le duo dont elle est l'acolyte ; les duels au-delà de 58 % comptent aussi (effets mesurés à graines égales avant la passe 83)
- k_classe Guerrier : 0,878 → 0,872 (51,3 % de victoires)
- k_classe Mage : 0,871 → 0,874 (49,6 % de victoires)
- k_classe Voleur : 0,783 → 0,779 (49,5 % de victoires)
- k_classe Archer : 0,899 → 0,910 (48,3 % de victoires)
- k_classe Prêtre : 0,881 → 0,882 (50,3 % de victoires)
- k_classe Alchimiste : 1,022 → 1,020 (51,1 % de victoires)
- k_classe Invocateur : 0,848 → 0,845 (51,5 % de victoires)
- k_classe Barde : 1,030 → 1,020 (51,5 % de victoires)
- k_classe Pugiliste : 1,072 → 1,077 (48,6 % de victoires)
- Tour, Guerrier : facteur des monstres 1,676 → 1,686 (étage 10 dans 57,2 % des montées)
- Tour, Mage : pente des monstres 1,026 → 1,003 (étage 20 dans 5,2 % des montées)
- Tour, Mage : facteur des monstres 0,737 → 0,739 (étage 10 dans 53,4 % des montées)
- Tour, Archer : pente des monstres 1,291 → 1,257 (étage 20 dans 4,9 % des montées)
- Tour, Archer : facteur des monstres 0,696 → 0,691 (étage 10 dans 47,9 % des montées)
- Tour, Alchimiste : pente des monstres 1,181 → 1,203 (étage 20 dans 11,1 % des montées)
- Tour, Barde : facteur des monstres 0,841 → 0,845 (étage 10 dans 56,4 % des montées)
- Tour, Diplomate : facteur des monstres 1,310 → 1,296 (étage 10 dans 40,2 % des montées)

## Passe 84 (graines à partir de 8400253)

**3 critères tenus sur 6.** 100000 combats de duel (médiane 19 tours), 0 combats non finis.

### Les six critères (section 11.2)

- ❌ **1. Chaque classe entre 47 % et 53 % de victoires** : diplomate 44,6 %
- ❌ **2. Aucune case de la matrice hors de 40 % – 60 %** : archer contre diplomate 62,5 %, alchimiste contre archer 39,4 %, diplomate contre barde 37,8 %
- ✅ **3. La route Réactive entre 40 % et 55 % (Ruée et Éventail : des repères, sans seuil)**
- ✅ **4. Chaque voie jouée dans 15 % des combats au moins, une Clé dans 60 %**
- ✅ **5. Longueur : médiane de 18 à 22 tours, 95 % finis avant le tour 30**
- ❌ **6. Tour : étage 10 dans 40 à 60 % des montées, étage 20 dans 5 à 10 %, à 5 points près entre classes** : écart entre classes : étage 10 de 42,3 % à 56,8 %, étage 20 de 5,5 % à 8,9 %

### La matrice des classes (taux de victoire de la ligne contre la colonne)

| | Guer | Mage | Vole | Arch | Prêt | Alch | Invo | Bard | Dipl | Pugi | **Moyenne** |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 51 | 57 | 52 | 59 | 43 | 45 | 47 | 47 | 49 | 55 | **50,5 %** |
| Mage | 40 | 48 | 45 | 48 | 49 | 56 | 44 | 53 | 59 | 49 | **49,2 %** |
| Voleur | 49 | 54 | 49 | 47 | 51 | 57 | 48 | 49 | 51 | 52 | **50,6 %** |
| Archer | 40 | 54 | 54 | 54 | 45 | 59 | 51 | 53 | 63 | 53 | **52,5 %** |
| Prêtre | 55 | 51 | 47 | 55 | 48 | 42 | 49 | 44 | 57 | 48 | **49,7 %** |
| Alchimiste | 54 | 41 | 43 | 39 | 56 | 51 | 48 | 53 | 57 | 45 | **48,8 %** |
| Invocateur | 55 | 58 | 53 | 49 | 51 | 51 | 48 | 51 | 51 | 53 | **52,0 %** |
| Barde | 53 | 44 | 51 | 46 | 55 | 43 | 50 | 50 | 57 | 54 | **50,3 %** |
| Diplomate | 49 | 40 | 50 | 41 | 43 | 43 | 47 | 38 | 50 | 45 | **44,6 %** |
| Pugiliste | 45 | 48 | 50 | 49 | 50 | 53 | 47 | 47 | 57 | 50 | **49,5 %** |

### Les trois routes, l'usage des voies et la Tour, par classe

| Classe | Ruée | Éventail | Réactive | Voie 1 | Voie 2 | Voie 3 | Voie 4 | Voie 5 | Clé | Tour : étage 10 | étage 20 | étage moyen |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 45,5 % | 10,8 % | 50,5 % | 51,4 % | 66,7 % | 49,9 % | 85,9 % | 66,3 % | 97,5 % | 55,6 % | 5,9 % | 10,8 |
| Mage | 58,0 % | 16,3 % | 49,2 % | 28,8 % | 63,4 % | 55,6 % | 29,7 % | 37,4 % | 90,1 % | 55,4 % | 6,0 % | 11,0 |
| Voleur | 57,0 % | 24,0 % | 50,6 % | 44,8 % | 28,6 % | 65,2 % | 32,9 % | 50,3 % | 91,2 % | 53,3 % | 8,1 % | 10,7 |
| Archer | 54,3 % | 18,3 % | 52,5 % | 42,0 % | 45,5 % | 61,0 % | 29,6 % | 47,2 % | 89,5 % | 55,8 % | 6,6 % | 11,0 |
| Prêtre | 24,0 % | 8,8 % | 49,7 % | 52,7 % | 77,8 % | 42,8 % | 82,5 % | 78,4 % | 96,9 % | 48,0 % | 5,5 % | 10,0 |
| Alchimiste | 37,0 % | 8,5 % | 48,8 % | 56,0 % | 36,3 % | 60,5 % | 39,5 % | 68,4 % | 96,0 % | 52,0 % | 8,8 % | 11,0 |
| Invocateur | 49,0 % | 17,8 % | 52,0 % | 39,1 % | 49,2 % | 72,4 % | 44,2 % | 50,4 % | 91,4 % | 54,3 % | 8,9 % | 10,9 |
| Barde | 44,5 % | 13,8 % | 50,3 % | 48,4 % | 44,4 % | 56,7 % | 55,7 % | 67,2 % | 94,0 % | 52,6 % | 6,8 % | 11,0 |
| Diplomate | 29,0 % | 6,5 % | 44,6 % | 35,0 % | 60,1 % | 95,5 % | 45,8 % | 86,8 % | 97,4 % | 42,3 % | 5,5 % | 9,4 |
| Pugiliste | 17,8 % | 6,5 % | 49,5 % | 51,0 % | 58,7 % | 64,5 % | 86,3 % | 40,9 % | 97,5 % | 56,8 % | 8,3 % | 11,5 |

### Boutons touchés, et pourquoi

- pas des k calculés ensemble : le k d'une classe change aussi le duo dont elle est l'acolyte ; les duels au-delà de 58 % comptent aussi (effets mesurés à graines égales avant la passe 83)
- k_classe Guerrier : 0,872 → 0,869 (50,5 % de victoires)
- k_classe Voleur : 0,779 → 0,777 (50,6 % de victoires)
- k_classe Archer : 0,910 → 0,910 (52,5 % de victoires)
- k_classe Prêtre : 0,882 → 0,880 (49,7 % de victoires)
- k_classe Alchimiste : 1,020 → 1,028 (48,8 % de victoires)
- k_classe Invocateur : 0,845 → 0,831 (52,0 % de victoires)
- k_classe Barde : 1,020 → 1,023 (50,3 % de victoires)
- k_classe Pugiliste : 1,077 → 1,075 (49,5 % de victoires)
- Tour, Guerrier : facteur des monstres 1,686 → 1,691 (étage 10 dans 55,6 % des montées)
- Tour, Mage : facteur des monstres 0,739 → 0,741 (étage 10 dans 55,4 % des montées)
- Tour, Archer : facteur des monstres 0,691 → 0,694 (étage 10 dans 55,8 % des montées)
- Tour, Prêtre : facteur des monstres 1,094 → 1,084 (étage 10 dans 48,0 % des montées)
- Tour, Diplomate : facteur des monstres 1,296 → 1,282 (étage 10 dans 42,2 % des montées)
- Tour, Pugiliste : facteur des monstres 0,962 → 0,970 (étage 10 dans 56,8 % des montées)

## Passe 85 (graines à partir de 8500256)

**3 critères tenus sur 6.** 100000 combats de duel (médiane 20 tours), 0 combats non finis.

### Les six critères (section 11.2)

- ❌ **1. Chaque classe entre 47 % et 53 % de victoires** : barde 53,5 %, diplomate 44,8 %
- ❌ **2. Aucune case de la matrice hors de 40 % – 60 %** : guerrier contre archer 61,9 %, archer contre guerrier 39,4 %, archer contre diplomate 61,2 %, alchimiste contre diplomate 60,1 %, barde contre diplomate 60,9 %, diplomate contre barde 39,3 %
- ✅ **3. La route Réactive entre 40 % et 55 % (Ruée et Éventail : des repères, sans seuil)**
- ✅ **4. Chaque voie jouée dans 15 % des combats au moins, une Clé dans 60 %**
- ✅ **5. Longueur : médiane de 18 à 22 tours, 95 % finis avant le tour 30**
- ❌ **6. Tour : étage 10 dans 40 à 60 % des montées, étage 20 dans 5 à 10 %, à 5 points près entre classes** : écart entre classes : étage 10 de 45,6 % à 58,5 %, étage 20 de 5,6 % à 9,4 %

### La matrice des classes (taux de victoire de la ligne contre la colonne)

| | Guer | Mage | Vole | Arch | Prêt | Alch | Invo | Bard | Dipl | Pugi | **Moyenne** |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 50 | 58 | 51 | 62 | 45 | 42 | 43 | 43 | 55 | 57 | **50,5 %** |
| Mage | 43 | 48 | 46 | 48 | 47 | 54 | 48 | 50 | 58 | 47 | **49,0 %** |
| Voleur | 50 | 56 | 50 | 49 | 49 | 55 | 47 | 51 | 52 | 50 | **50,7 %** |
| Archer | 39 | 49 | 49 | 49 | 42 | 56 | 48 | 48 | 61 | 49 | **49,0 %** |
| Prêtre | 57 | 54 | 48 | 58 | 51 | 41 | 51 | 44 | 60 | 49 | **51,2 %** |
| Alchimiste | 56 | 48 | 45 | 46 | 59 | 50 | 49 | 53 | 60 | 48 | **51,5 %** |
| Invocateur | 54 | 56 | 54 | 52 | 45 | 52 | 52 | 48 | 49 | 50 | **51,2 %** |
| Barde | 56 | 51 | 51 | 54 | 58 | 47 | 51 | 51 | 61 | 54 | **53,5 %** |
| Diplomate | 48 | 42 | 46 | 41 | 42 | 41 | 52 | 39 | 54 | 43 | **44,8 %** |
| Pugiliste | 43 | 49 | 51 | 50 | 51 | 50 | 48 | 47 | 57 | 50 | **49,5 %** |

### Les trois routes, l'usage des voies et la Tour, par classe

| Classe | Ruée | Éventail | Réactive | Voie 1 | Voie 2 | Voie 3 | Voie 4 | Voie 5 | Clé | Tour : étage 10 | étage 20 | étage moyen |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 48,3 % | 10,0 % | 50,5 % | 46,7 % | 65,2 % | 50,9 % | 85,7 % | 68,5 % | 97,5 % | 57,4 % | 8,5 % | 11,2 |
| Mage | 48,8 % | 19,0 % | 49,0 % | 28,3 % | 64,3 % | 57,5 % | 28,0 % | 39,2 % | 90,5 % | 56,8 % | 7,6 % | 11,1 |
| Voleur | 45,0 % | 20,5 % | 50,7 % | 44,9 % | 30,7 % | 68,8 % | 36,6 % | 43,7 % | 91,3 % | 52,0 % | 7,8 % | 10,6 |
| Archer | 44,3 % | 15,0 % | 49,0 % | 51,7 % | 42,9 % | 63,0 % | 28,2 % | 38,8 % | 89,5 % | 57,3 % | 7,6 % | 11,0 |
| Prêtre | 36,8 % | 11,5 % | 51,2 % | 53,3 % | 77,2 % | 40,5 % | 82,4 % | 78,7 % | 96,8 % | 51,9 % | 7,9 % | 10,7 |
| Alchimiste | 30,8 % | 8,8 % | 51,5 % | 54,9 % | 37,3 % | 60,9 % | 39,3 % | 69,3 % | 96,7 % | 53,8 % | 9,4 % | 11,3 |
| Invocateur | 39,3 % | 12,0 % | 51,2 % | 37,6 % | 49,3 % | 73,0 % | 42,7 % | 50,9 % | 91,8 % | 49,6 % | 7,5 % | 10,6 |
| Barde | 44,3 % | 13,8 % | 53,5 % | 47,6 % | 45,0 % | 57,6 % | 58,1 % | 67,7 % | 93,5 % | 58,5 % | 7,6 % | 11,5 |
| Diplomate | 34,0 % | 7,0 % | 44,8 % | 34,1 % | 59,8 % | 95,1 % | 48,9 % | 86,9 % | 97,5 % | 45,6 % | 7,6 % | 10,1 |
| Pugiliste | 20,8 % | 5,8 % | 49,5 % | 50,7 % | 57,2 % | 66,2 % | 84,8 % | 44,7 % | 97,4 % | 54,5 % | 5,6 % | 10,8 |

### Boutons touchés, et pourquoi

- pas des k calculés ensemble : le k d'une classe change aussi le duo dont elle est l'acolyte ; les duels au-delà de 58 % comptent aussi (effets mesurés à graines égales avant la passe 83)
- k_classe Guerrier : 0,869 → 0,870 (50,5 % de victoires)
- k_classe Mage : 0,874 → 0,882 (49,0 % de victoires)
- k_classe Voleur : 0,777 → 0,774 (50,7 % de victoires)
- k_classe Archer : 0,910 → 0,912 (49,0 % de victoires)
- k_classe Prêtre : 0,880 → 0,870 (51,2 % de victoires)
- k_classe Alchimiste : 1,028 → 1,025 (51,5 % de victoires)
- k_classe Invocateur : 0,831 → 0,834 (51,2 % de victoires)
- k_classe Barde : 1,023 → 1,015 (53,5 % de victoires)
- k_classe Pugiliste : 1,075 → 1,076 (49,5 % de victoires)
- Tour : force des monstres au départ 0,500 → 0,505, en plus par étage 0,029 → 0,029 (étage 10 atteint dans 53,7 % des montées, étage 20 dans 7,7 %)
- Tour, Guerrier : facteur des monstres 1,691 → 1,697 (étage 10 dans 57,4 % des montées)
- Tour, Mage : facteur des monstres 0,741 → 0,743 (étage 10 dans 56,8 % des montées)
- Tour, Archer : facteur des monstres 0,694 → 0,696 (étage 10 dans 57,2 % des montées)
- Tour, Invocateur : facteur des monstres 0,973 → 0,969 (étage 10 dans 49,6 % des montées)
- Tour, Barde : facteur des monstres 0,845 → 0,849 (étage 10 dans 58,5 % des montées)
- Tour, Diplomate : facteur des monstres 1,282 → 1,272 (étage 10 dans 45,6 % des montées)

## Passe 86 (graines à partir de 8600259)

**3 critères tenus sur 6.** 100000 combats de duel (médiane 20 tours), 0 combats non finis.

### Les six critères (section 11.2)

- ❌ **1. Chaque classe entre 47 % et 53 % de victoires** : diplomate 44,7 %
- ❌ **2. Aucune case de la matrice hors de 40 % – 60 %** : mage contre diplomate 60,5 %, archer contre pretre 38,6 %, archer contre diplomate 62,7 %, diplomate contre archer 39,5 %, diplomate contre pretre 39,7 %, diplomate contre barde 39,7 %
- ✅ **3. La route Réactive entre 40 % et 55 % (Ruée et Éventail : des repères, sans seuil)**
- ✅ **4. Chaque voie jouée dans 15 % des combats au moins, une Clé dans 60 %**
- ✅ **5. Longueur : médiane de 18 à 22 tours, 95 % finis avant le tour 30**
- ❌ **6. Tour : étage 10 dans 40 à 60 % des montées, étage 20 dans 5 à 10 %, à 5 points près entre classes** : pretre étage 20 4,8 %, écart entre classes : étage 10 de 41,0 % à 51,1 %, étage 20 de 4,8 % à 8,6 %

### La matrice des classes (taux de victoire de la ligne contre la colonne)

| | Guer | Mage | Vole | Arch | Prêt | Alch | Invo | Bard | Dipl | Pugi | **Moyenne** |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 51 | 55 | 51 | 59 | 41 | 43 | 43 | 44 | 49 | 54 | **48,9 %** |
| Mage | 45 | 52 | 48 | 49 | 45 | 55 | 47 | 53 | 61 | 51 | **50,5 %** |
| Voleur | 50 | 53 | 51 | 47 | 52 | 53 | 47 | 47 | 50 | 50 | **50,0 %** |
| Archer | 42 | 52 | 50 | 51 | 39 | 56 | 47 | 50 | 63 | 49 | **50,0 %** |
| Prêtre | 57 | 54 | 49 | 58 | 49 | 41 | 54 | 42 | 57 | 49 | **50,9 %** |
| Alchimiste | 56 | 43 | 46 | 41 | 58 | 48 | 51 | 53 | 55 | 48 | **50,0 %** |
| Invocateur | 57 | 53 | 51 | 51 | 48 | 50 | 49 | 48 | 53 | 53 | **51,3 %** |
| Barde | 56 | 46 | 51 | 50 | 55 | 42 | 52 | 53 | 59 | 53 | **51,6 %** |
| Diplomate | 50 | 42 | 48 | 40 | 40 | 43 | 51 | 40 | 52 | 43 | **44,7 %** |
| Pugiliste | 44 | 49 | 50 | 51 | 49 | 51 | 49 | 44 | 56 | 50 | **49,2 %** |

### Les trois routes, l'usage des voies et la Tour, par classe

| Classe | Ruée | Éventail | Réactive | Voie 1 | Voie 2 | Voie 3 | Voie 4 | Voie 5 | Clé | Tour : étage 10 | étage 20 | étage moyen |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 42,5 % | 7,0 % | 48,9 % | 46,1 % | 66,2 % | 49,4 % | 86,2 % | 66,0 % | 97,2 % | 51,1 % | 6,6 % | 10,5 |
| Mage | 51,7 % | 18,5 % | 50,5 % | 30,1 % | 62,8 % | 54,4 % | 31,4 % | 40,7 % | 90,0 % | 44,8 % | 5,0 % | 10,2 |
| Voleur | 46,3 % | 22,8 % | 50,0 % | 46,1 % | 31,2 % | 66,6 % | 43,5 % | 42,8 % | 90,9 % | 47,6 % | 5,3 % | 10,0 |
| Archer | 48,5 % | 16,3 % | 50,0 % | 49,8 % | 44,6 % | 62,0 % | 29,1 % | 40,8 % | 89,4 % | 42,9 % | 7,6 % | 10,1 |
| Prêtre | 32,5 % | 13,3 % | 50,9 % | 53,5 % | 76,2 % | 42,1 % | 81,8 % | 79,0 % | 96,5 % | 50,1 % | 4,8 % | 10,1 |
| Alchimiste | 32,3 % | 8,8 % | 50,0 % | 56,9 % | 35,8 % | 61,0 % | 40,3 % | 66,3 % | 96,2 % | 48,1 % | 8,6 % | 10,7 |
| Invocateur | 46,0 % | 13,3 % | 51,3 % | 39,5 % | 50,8 % | 73,6 % | 41,8 % | 52,7 % | 91,6 % | 50,4 % | 7,2 % | 10,6 |
| Barde | 40,0 % | 10,5 % | 51,6 % | 49,0 % | 42,6 % | 57,5 % | 57,3 % | 68,0 % | 93,2 % | 50,2 % | 5,3 % | 10,6 |
| Diplomate | 25,3 % | 4,8 % | 44,7 % | 34,4 % | 60,3 % | 95,3 % | 48,0 % | 86,7 % | 97,5 % | 41,0 % | 8,1 % | 9,6 |
| Pugiliste | 15,5 % | 6,8 % | 49,2 % | 50,5 % | 58,0 % | 65,3 % | 86,4 % | 43,0 % | 97,1 % | 50,1 % | 6,0 % | 10,4 |

### Boutons touchés, et pourquoi

- pas des k calculés ensemble : le k d'une classe change aussi le duo dont elle est l'acolyte ; les duels au-delà de 58 % comptent aussi (effets mesurés à graines égales avant la passe 83)
- k_classe Guerrier : 0,870 → 0,873 (48,9 % de victoires)
- k_classe Voleur : 0,774 → 0,775 (50,0 % de victoires)
- k_classe Archer : 0,912 → 0,909 (50,0 % de victoires)
- k_classe Prêtre : 0,870 → 0,865 (50,9 % de victoires)
- k_classe Alchimiste : 1,025 → 1,018 (50,0 % de victoires)
- k_classe Invocateur : 0,834 → 0,843 (51,3 % de victoires)
- k_classe Barde : 1,015 → 1,017 (51,6 % de victoires)
- k_classe Pugiliste : 1,076 → 1,072 (49,2 % de victoires)
- Tour, Guerrier : facteur des monstres 1,697 → 1,703 (étage 10 dans 51,1 % des montées)
- Tour, Mage : pente des monstres 1,003 → 0,978 (étage 20 dans 5,0 % des montées)
- Tour, Mage : facteur des monstres 0,743 → 0,742 (étage 10 dans 44,8 % des montées)
- Tour, Voleur : pente des monstres 0,469 → 0,458 (étage 20 dans 5,2 % des montées)
- Tour, Archer : facteur des monstres 0,696 → 0,694 (étage 10 dans 42,9 % des montées)
- Tour, Prêtre : pente des monstres 0,958 → 0,952 (étage 20 dans 4,8 % des montées)
- Tour, Prêtre : facteur des monstres 1,084 → 1,087 (étage 10 dans 50,1 % des montées)
- Tour, Invocateur : facteur des monstres 0,969 → 0,970 (étage 10 dans 50,4 % des montées)
- Tour, Barde : pente des monstres 1,459 → 1,426 (étage 20 dans 5,2 % des montées)
- Tour, Barde : facteur des monstres 0,849 → 0,851 (étage 10 dans 50,2 % des montées)
- Tour, Diplomate : facteur des monstres 1,272 → 1,264 (étage 10 dans 41,0 % des montées)
- Tour, Pugiliste : facteur des monstres 0,970 → 0,975 (étage 10 dans 50,1 % des montées)

## Passe 87 (graines à partir de 8700262)

**3 critères tenus sur 6.** 100000 combats de duel (médiane 19 tours), 0 combats non finis.

### Les six critères (section 11.2)

- ❌ **1. Chaque classe entre 47 % et 53 % de victoires** : diplomate 45,7 %
- ❌ **2. Aucune case de la matrice hors de 40 % – 60 %** : mage contre diplomate 63,0 %, archer contre diplomate 60,9 %, pretre contre diplomate 62,0 %, alchimiste contre archer 38,7 %, diplomate contre mage 37,6 %, diplomate contre archer 39,5 %
- ✅ **3. La route Réactive entre 40 % et 55 % (Ruée et Éventail : des repères, sans seuil)**
- ✅ **4. Chaque voie jouée dans 15 % des combats au moins, une Clé dans 60 %**
- ✅ **5. Longueur : médiane de 18 à 22 tours, 95 % finis avant le tour 30**
- ❌ **6. Tour : étage 10 dans 40 à 60 % des montées, étage 20 dans 5 à 10 %, à 5 points près entre classes** : alchimiste étage 20 11,3 %, diplomate étage 20 10,1 %, écart entre classes : étage 10 de 46,9 % à 55,8 %, étage 20 de 6,0 % à 11,3 %

### La matrice des classes (taux de victoire de la ligne contre la colonne)

| | Guer | Mage | Vole | Arch | Prêt | Alch | Invo | Bard | Dipl | Pugi | **Moyenne** |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 51 | 56 | 54 | 60 | 42 | 48 | 44 | 45 | 48 | 56 | **50,3 %** |
| Mage | 46 | 51 | 47 | 48 | 50 | 58 | 47 | 55 | 63 | 55 | **51,9 %** |
| Voleur | 53 | 50 | 50 | 46 | 51 | 55 | 47 | 48 | 51 | 52 | **50,2 %** |
| Archer | 41 | 54 | 53 | 49 | 47 | 58 | 49 | 50 | 61 | 54 | **51,6 %** |
| Prêtre | 58 | 50 | 52 | 56 | 51 | 44 | 53 | 47 | 62 | 50 | **52,3 %** |
| Alchimiste | 55 | 41 | 47 | 39 | 57 | 49 | 48 | 56 | 55 | 48 | **49,5 %** |
| Invocateur | 56 | 52 | 52 | 48 | 45 | 52 | 52 | 50 | 49 | 53 | **50,9 %** |
| Barde | 56 | 48 | 54 | 49 | 54 | 44 | 50 | 49 | 58 | 55 | **51,6 %** |
| Diplomate | 51 | 38 | 53 | 40 | 42 | 45 | 51 | 41 | 53 | 45 | **45,7 %** |
| Pugiliste | 46 | 49 | 53 | 48 | 49 | 52 | 49 | 43 | 57 | 52 | **49,7 %** |

### Les trois routes, l'usage des voies et la Tour, par classe

| Classe | Ruée | Éventail | Réactive | Voie 1 | Voie 2 | Voie 3 | Voie 4 | Voie 5 | Clé | Tour : étage 10 | étage 20 | étage moyen |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 42,0 % | 8,3 % | 50,3 % | 49,0 % | 68,3 % | 47,7 % | 86,1 % | 68,9 % | 97,3 % | 53,6 % | 6,0 % | 10,5 |
| Mage | 54,5 % | 20,5 % | 51,9 % | 28,6 % | 62,8 % | 56,1 % | 31,3 % | 39,1 % | 90,3 % | 55,8 % | 8,1 % | 11,0 |
| Voleur | 53,0 % | 22,0 % | 50,2 % | 45,4 % | 32,7 % | 68,9 % | 40,1 % | 40,3 % | 91,0 % | 53,5 % | 7,4 % | 10,7 |
| Archer | 48,5 % | 18,8 % | 51,6 % | 43,5 % | 41,5 % | 63,8 % | 29,0 % | 48,5 % | 89,6 % | 46,9 % | 6,0 % | 10,3 |
| Prêtre | 28,2 % | 9,8 % | 52,3 % | 50,9 % | 76,1 % | 42,4 % | 83,3 % | 81,4 % | 96,6 % | 52,5 % | 6,3 % | 10,6 |
| Alchimiste | 37,3 % | 12,5 % | 49,5 % | 57,5 % | 35,8 % | 62,7 % | 40,1 % | 65,8 % | 96,0 % | 53,5 % | 11,3 % | 11,3 |
| Invocateur | 49,8 % | 17,3 % | 50,9 % | 41,6 % | 49,1 % | 72,4 % | 42,2 % | 49,2 % | 91,0 % | 51,1 % | 7,2 % | 10,6 |
| Barde | 50,2 % | 13,3 % | 51,6 % | 48,1 % | 44,6 % | 57,8 % | 56,5 % | 65,3 % | 93,3 % | 55,6 % | 6,8 % | 11,1 |
| Diplomate | 27,3 % | 4,0 % | 45,7 % | 34,2 % | 60,6 % | 95,6 % | 47,9 % | 86,7 % | 97,4 % | 48,6 % | 10,1 % | 10,4 |
| Pugiliste | 23,0 % | 5,0 % | 49,7 % | 51,1 % | 56,7 % | 64,3 % | 86,0 % | 41,9 % | 97,5 % | 52,3 % | 7,2 % | 10,6 |

### Boutons touchés, et pourquoi

- pas des k calculés ensemble : le k d'une classe change aussi le duo dont elle est l'acolyte ; les duels au-delà de 58 % comptent aussi (effets mesurés à graines égales avant la passe 87)
- k_classe Guerrier : 0,873 → 0,860 (50,3 % de victoires)
- k_classe Mage : 0,882 → 0,863 (51,9 % de victoires)
- k_classe Voleur : 0,775 → 0,764 (50,2 % de victoires)
- k_classe Archer : 0,909 → 0,892 (51,6 % de victoires)
- k_classe Prêtre : 0,865 → 0,853 (52,3 % de victoires)
- k_classe Alchimiste : 1,018 → 1,008 (49,5 % de victoires)
- k_classe Invocateur : 0,843 → 0,829 (50,9 % de victoires)
- k_classe Barde : 1,017 → 1,001 (51,6 % de victoires)
- k_classe Pugiliste : 1,072 → 1,058 (49,7 % de victoires)
- Tour, Mage : facteur des monstres 0,742 → 0,762 (étage 10 dans 55,8 % des montées)
- Tour, Archer : facteur des monstres 0,694 → 0,664 (étage 10 dans 46,9 % des montées)
- Tour, Alchimiste : pente des monstres 1,203 → 1,293 (étage 20 dans 11,2 % des montées)
- Tour, Barde : facteur des monstres 0,851 → 0,874 (étage 10 dans 55,6 % des montées)
- Tour, Diplomate : pente des monstres 0,811 → 0,854 (étage 20 dans 10,1 % des montées)
- Tour, Diplomate : facteur des monstres 1,264 → 1,226 (étage 10 dans 48,6 % des montées)

## Passe 88 (graines à partir de 8800265)

**4 critères tenus sur 6.** 100000 combats de duel (médiane 20 tours), 0 combats non finis.

### Les six critères (section 11.2)

- ✅ **1. Chaque classe entre 47 % et 53 % de victoires**
- ❌ **2. Aucune case de la matrice hors de 40 % – 60 %** : guerrier contre pretre 39,7 %, mage contre alchimiste 60,2 %, mage contre diplomate 61,7 %, archer contre alchimiste 62,7 %, alchimiste contre pretre 60,4 %, diplomate contre mage 39,8 %
- ✅ **3. La route Réactive entre 40 % et 55 % (Ruée et Éventail : des repères, sans seuil)**
- ✅ **4. Chaque voie jouée dans 15 % des combats au moins, une Clé dans 60 %**
- ✅ **5. Longueur : médiane de 18 à 22 tours, 95 % finis avant le tour 30**
- ❌ **6. Tour : étage 10 dans 40 à 60 % des montées, étage 20 dans 5 à 10 %, à 5 points près entre classes** : guerrier étage 20 4,8 %, pretre étage 20 4,8 %, barde étage 20 4,8 %, écart entre classes : étage 10 de 47,4 % à 57,4 %, étage 20 de 4,8 % à 9,6 %

### La matrice des classes (taux de victoire de la ligne contre la colonne)

| | Guer | Mage | Vole | Arch | Prêt | Alch | Invo | Bard | Dipl | Pugi | **Moyenne** |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 51 | 50 | 48 | 57 | 40 | 41 | 43 | 43 | 47 | 54 | **47,3 %** |
| Mage | 50 | 51 | 48 | 51 | 55 | 60 | 45 | 54 | 62 | 51 | **52,8 %** |
| Voleur | 52 | 51 | 50 | 48 | 50 | 57 | 47 | 49 | 48 | 46 | **49,8 %** |
| Archer | 43 | 49 | 50 | 49 | 46 | 63 | 47 | 50 | 59 | 48 | **50,3 %** |
| Prêtre | 59 | 48 | 48 | 54 | 52 | 41 | 49 | 46 | 56 | 49 | **50,0 %** |
| Alchimiste | 59 | 41 | 45 | 42 | 60 | 51 | 48 | 54 | 55 | 45 | **50,1 %** |
| Invocateur | 59 | 53 | 51 | 53 | 51 | 52 | 48 | 48 | 48 | 49 | **51,3 %** |
| Barde | 54 | 42 | 51 | 49 | 56 | 44 | 50 | 49 | 56 | 51 | **50,1 %** |
| Diplomate | 56 | 40 | 52 | 43 | 48 | 44 | 51 | 44 | 52 | 44 | **47,4 %** |
| Pugiliste | 40 | 48 | 51 | 51 | 53 | 55 | 48 | 47 | 57 | 50 | **50,0 %** |

### Les trois routes, l'usage des voies et la Tour, par classe

| Classe | Ruée | Éventail | Réactive | Voie 1 | Voie 2 | Voie 3 | Voie 4 | Voie 5 | Clé | Tour : étage 10 | étage 20 | étage moyen |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 40,3 % | 9,5 % | 47,3 % | 50,1 % | 69,2 % | 44,1 % | 85,6 % | 66,4 % | 97,1 % | 50,7 % | 4,8 % | 10,2 |
| Mage | 49,3 % | 17,3 % | 52,8 % | 28,4 % | 64,7 % | 55,7 % | 28,9 % | 34,8 % | 90,5 % | 47,9 % | 6,1 % | 10,3 |
| Voleur | 53,3 % | 22,3 % | 49,8 % | 46,3 % | 28,4 % | 66,5 % | 37,6 % | 47,0 % | 91,1 % | 50,6 % | 8,4 % | 10,5 |
| Archer | 49,3 % | 18,3 % | 50,3 % | 49,3 % | 38,3 % | 67,4 % | 25,3 % | 35,2 % | 89,4 % | 57,4 % | 8,1 % | 11,1 |
| Prêtre | 19,8 % | 3,3 % | 50,0 % | 51,8 % | 75,8 % | 40,7 % | 83,4 % | 80,6 % | 96,7 % | 49,3 % | 4,8 % | 10,1 |
| Alchimiste | 33,3 % | 7,2 % | 50,1 % | 55,3 % | 35,2 % | 63,6 % | 39,8 % | 67,9 % | 96,0 % | 51,1 % | 9,6 % | 11,0 |
| Invocateur | 45,3 % | 18,0 % | 51,3 % | 38,0 % | 50,0 % | 73,3 % | 44,3 % | 51,2 % | 91,8 % | 50,5 % | 7,4 % | 10,6 |
| Barde | 39,0 % | 10,0 % | 50,1 % | 47,3 % | 48,7 % | 59,1 % | 56,5 % | 64,1 % | 93,2 % | 48,1 % | 4,8 % | 10,3 |
| Diplomate | 30,8 % | 6,5 % | 47,4 % | 35,7 % | 61,0 % | 95,8 % | 50,1 % | 86,8 % | 97,4 % | 47,4 % | 8,6 % | 10,3 |
| Pugiliste | 19,3 % | 6,5 % | 50,0 % | 48,6 % | 55,5 % | 65,5 % | 88,8 % | 43,0 % | 97,2 % | 48,0 % | 6,8 % | 10,2 |

### Boutons touchés, et pourquoi

- pas des k calculés ensemble : le k d'une classe change aussi le duo dont elle est l'acolyte ; les duels au-delà de 58 % comptent aussi (effets mesurés à graines égales avant la passe 87)
- k_classe Guerrier : 0,860 → 0,859 (47,3 % de victoires)
- k_classe Mage : 0,863 → 0,855 (52,8 % de victoires)
- k_classe Voleur : 0,764 → 0,752 (49,8 % de victoires)
- k_classe Archer : 0,892 → 0,889 (50,3 % de victoires)
- k_classe Prêtre : 0,853 → 0,859 (50,0 % de victoires)
- k_classe Alchimiste : 1,008 → 1,009 (50,1 % de victoires)
- k_classe Invocateur : 0,829 → 0,836 (51,3 % de victoires)
- k_classe Barde : 1,001 → 0,996 (50,1 % de victoires)
- k_classe Pugiliste : 1,058 → 1,056 (50,0 % de victoires)
- Tour, Guerrier : pente des monstres 0,824 → 0,779 (étage 20 dans 4,8 % des montées)
- Tour, Mage : facteur des monstres 0,762 → 0,755 (étage 10 dans 47,9 % des montées)
- Tour, Archer : facteur des monstres 0,664 → 0,683 (étage 10 dans 57,4 % des montées)
- Tour, Prêtre : pente des monstres 0,952 → 0,899 (étage 20 dans 4,8 % des montées)
- Tour, Alchimiste : pente des monstres 1,293 → 1,348 (étage 20 dans 9,6 % des montées)
- Tour, Barde : pente des monstres 1,426 → 1,348 (étage 20 dans 4,8 % des montées)
- Tour, Diplomate : facteur des monstres 1,226 → 1,199 (étage 10 dans 47,4 % des montées)
- Tour, Pugiliste : facteur des monstres 0,975 → 0,959 (étage 10 dans 48,0 % des montées)

## Passe 89 (graines à partir de 8900268)

**3 critères tenus sur 6.** 100000 combats de duel (médiane 20 tours), 0 combats non finis.

### Les six critères (section 11.2)

- ❌ **1. Chaque classe entre 47 % et 53 % de victoires** : alchimiste 53,9 %, diplomate 46,7 %
- ❌ **2. Aucune case de la matrice hors de 40 % – 60 %** : guerrier contre alchimiste 37,2 %, mage contre diplomate 62,1 %, pretre contre alchimiste 35,5 %, alchimiste contre guerrier 61,2 %, alchimiste contre pretre 65,5 %, alchimiste contre barde 62,7 %, barde contre alchimiste 36,2 %, diplomate contre mage 37,0 %
- ✅ **3. La route Réactive entre 40 % et 55 % (Ruée et Éventail : des repères, sans seuil)**
- ✅ **4. Chaque voie jouée dans 15 % des combats au moins, une Clé dans 60 %**
- ✅ **5. Longueur : médiane de 18 à 22 tours, 95 % finis avant le tour 30**
- ❌ **6. Tour : étage 10 dans 40 à 60 % des montées, étage 20 dans 5 à 10 %, à 5 points près entre classes** : alchimiste étage 20 10,9 %, barde étage 20 4,6 %, diplomate étage 20 13,0 %, écart entre classes : étage 10 de 45,4 % à 56,6 %, étage 20 de 4,6 % à 13,0 %

### La matrice des classes (taux de victoire de la ligne contre la colonne)

| | Guer | Mage | Vole | Arch | Prêt | Alch | Invo | Bard | Dipl | Pugi | **Moyenne** |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 48 | 54 | 48 | 59 | 46 | 37 | 41 | 48 | 45 | 55 | **48,2 %** |
| Mage | 47 | 50 | 49 | 52 | 53 | 52 | 46 | 59 | 62 | 49 | **51,8 %** |
| Voleur | 51 | 52 | 48 | 49 | 54 | 53 | 48 | 53 | 45 | 47 | **49,8 %** |
| Archer | 40 | 49 | 53 | 50 | 44 | 53 | 48 | 54 | 57 | 49 | **49,6 %** |
| Prêtre | 57 | 52 | 45 | 57 | 53 | 36 | 51 | 49 | 55 | 50 | **50,3 %** |
| Alchimiste | 61 | 47 | 51 | 44 | 66 | 51 | 51 | 63 | 56 | 49 | **53,9 %** |
| Invocateur | 58 | 55 | 56 | 50 | 52 | 48 | 50 | 55 | 45 | 52 | **52,1 %** |
| Barde | 55 | 42 | 47 | 46 | 55 | 36 | 46 | 49 | 54 | 50 | **47,8 %** |
| Diplomate | 53 | 37 | 53 | 43 | 45 | 44 | 52 | 48 | 50 | 43 | **46,7 %** |
| Pugiliste | 44 | 50 | 53 | 51 | 53 | 51 | 48 | 50 | 55 | 51 | **50,4 %** |

### Les trois routes, l'usage des voies et la Tour, par classe

| Classe | Ruée | Éventail | Réactive | Voie 1 | Voie 2 | Voie 3 | Voie 4 | Voie 5 | Clé | Tour : étage 10 | étage 20 | étage moyen |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 43,3 % | 10,8 % | 48,2 % | 53,1 % | 72,8 % | 45,9 % | 80,2 % | 69,4 % | 96,6 % | 56,6 % | 7,4 % | 11,2 |
| Mage | 55,3 % | 20,8 % | 51,8 % | 30,1 % | 69,8 % | 50,1 % | 23,1 % | 35,7 % | 89,4 % | 45,4 % | 5,0 % | 10,2 |
| Voleur | 50,5 % | 21,3 % | 49,8 % | 46,6 % | 27,7 % | 68,0 % | 34,9 % | 50,4 % | 90,2 % | 50,7 % | 6,4 % | 10,5 |
| Archer | 54,8 % | 20,3 % | 49,6 % | 39,9 % | 38,4 % | 69,3 % | 27,2 % | 45,4 % | 88,4 % | 56,1 % | 6,9 % | 11,0 |
| Prêtre | 32,3 % | 13,3 % | 50,3 % | 52,9 % | 75,8 % | 41,3 % | 83,3 % | 81,7 % | 96,4 % | 53,5 % | 5,3 % | 10,5 |
| Alchimiste | 38,0 % | 10,8 % | 53,9 % | 52,9 % | 39,1 % | 65,3 % | 40,1 % | 70,1 % | 97,5 % | 54,8 % | 10,9 % | 11,4 |
| Invocateur | 46,0 % | 15,8 % | 52,1 % | 39,8 % | 49,9 % | 74,4 % | 42,7 % | 52,3 % | 90,9 % | 53,5 % | 7,6 % | 10,8 |
| Barde | 47,3 % | 13,8 % | 47,8 % | 50,3 % | 63,1 % | 60,5 % | 54,0 % | 51,3 % | 92,4 % | 45,6 % | 4,6 % | 10,1 |
| Diplomate | 31,5 % | 6,0 % | 46,7 % | 36,4 % | 61,9 % | 95,4 % | 49,5 % | 86,2 % | 96,8 % | 52,9 % | 13,0 % | 11,2 |
| Pugiliste | 21,8 % | 5,3 % | 50,4 % | 55,1 % | 59,4 % | 64,5 % | 87,2 % | 43,9 % | 96,8 % | 50,5 % | 7,6 % | 10,6 |

### Boutons touchés, et pourquoi

- pas des k calculés ensemble : le k d'une classe change aussi le duo dont elle est l'acolyte ; les duels au-delà de 58 % comptent aussi (effets mesurés à graines égales avant la passe 87)
- k_classe Guerrier : 0,859 → 0,846 (48,2 % de victoires)
- k_classe Mage : 0,855 → 0,837 (51,8 % de victoires)
- k_classe Voleur : 0,752 → 0,750 (49,8 % de victoires)
- k_classe Archer : 0,889 → 0,881 (49,6 % de victoires)
- k_classe Prêtre : 0,859 → 0,858 (50,3 % de victoires)
- k_classe Alchimiste : 1,009 → 0,985 (53,9 % de victoires)
- k_classe Invocateur : 0,836 → 0,820 (52,1 % de victoires)
- k_classe Barde : 0,996 → 0,990 (47,8 % de victoires)
- k_classe Pugiliste : 1,056 → 1,039 (50,4 % de victoires)
- Tour, Guerrier : facteur des monstres 1,703 → 1,766 (étage 10 dans 56,6 % des montées)
- Tour, Mage : pente des monstres 0,978 → 0,929 (étage 20 dans 5,0 % des montées)
- Tour, Mage : facteur des monstres 0,755 → 0,736 (étage 10 dans 45,4 % des montées)
- Tour, Archer : facteur des monstres 0,683 → 0,695 (étage 10 dans 56,1 % des montées)
- Tour, Prêtre : pente des monstres 0,899 → 0,859 (étage 20 dans 5,2 % des montées)
- Tour, Alchimiste : pente des monstres 1,348 → 1,439 (étage 20 dans 10,9 % des montées)
- Tour, Alchimiste : facteur des monstres 0,847 → 0,866 (étage 10 dans 54,8 % des montées)
- Tour, Barde : pente des monstres 1,348 → 1,270 (étage 20 dans 4,6 % des montées)
- Tour, Barde : facteur des monstres 0,874 → 0,851 (étage 10 dans 45,6 % des montées)
- Tour, Diplomate : pente des monstres 0,854 → 0,948 (étage 20 dans 13,0 % des montées)

## Passe 90 (graines à partir de 9000271)

**3 critères tenus sur 6.** 100000 combats de duel (médiane 20 tours), 0 combats non finis.

### Les six critères (section 11.2)

- ❌ **1. Chaque classe entre 47 % et 53 % de victoires** : alchimiste 53,8 %
- ❌ **2. Aucune case de la matrice hors de 40 % – 60 %** : guerrier contre archer 64,4 %, archer contre guerrier 33,5 %, pretre contre alchimiste 37,0 %, alchimiste contre guerrier 60,1 %, alchimiste contre pretre 63,4 %, alchimiste contre barde 60,5 %, barde contre alchimiste 37,8 %
- ✅ **3. La route Réactive entre 40 % et 55 % (Ruée et Éventail : des repères, sans seuil)**
- ✅ **4. Chaque voie jouée dans 15 % des combats au moins, une Clé dans 60 %**
- ✅ **5. Longueur : médiane de 18 à 22 tours, 95 % finis avant le tour 30**
- ❌ **6. Tour : étage 10 dans 40 à 60 % des montées, étage 20 dans 5 à 10 %, à 5 points près entre classes** : diplomate étage 10 35,5 %, écart entre classes : étage 10 de 35,5 % à 53,5 %, étage 20 de 5,1 % à 9,4 %

### La matrice des classes (taux de victoire de la ligne contre la colonne)

| | Guer | Mage | Vole | Arch | Prêt | Alch | Invo | Bard | Dipl | Pugi | **Moyenne** |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 49 | 58 | 51 | 64 | 43 | 41 | 44 | 50 | 47 | 56 | **50,2 %** |
| Mage | 41 | 49 | 49 | 54 | 49 | 52 | 46 | 58 | 59 | 50 | **50,7 %** |
| Voleur | 50 | 54 | 52 | 50 | 51 | 52 | 47 | 51 | 47 | 46 | **50,0 %** |
| Archer | 34 | 46 | 51 | 51 | 40 | 53 | 47 | 50 | 54 | 48 | **47,2 %** |
| Prêtre | 55 | 53 | 49 | 60 | 49 | 37 | 49 | 48 | 54 | 50 | **50,3 %** |
| Alchimiste | 60 | 52 | 47 | 50 | 63 | 52 | 50 | 61 | 55 | 48 | **53,8 %** |
| Invocateur | 58 | 57 | 53 | 52 | 50 | 47 | 52 | 52 | 47 | 49 | **51,7 %** |
| Barde | 50 | 46 | 48 | 48 | 52 | 38 | 48 | 50 | 53 | 52 | **48,5 %** |
| Diplomate | 54 | 40 | 55 | 45 | 46 | 46 | 53 | 48 | 48 | 47 | **48,1 %** |
| Pugiliste | 48 | 52 | 52 | 54 | 50 | 49 | 49 | 48 | 53 | 49 | **50,3 %** |

### Les trois routes, l'usage des voies et la Tour, par classe

| Classe | Ruée | Éventail | Réactive | Voie 1 | Voie 2 | Voie 3 | Voie 4 | Voie 5 | Clé | Tour : étage 10 | étage 20 | étage moyen |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 45,3 % | 10,8 % | 50,2 % | 51,9 % | 69,5 % | 43,7 % | 83,7 % | 69,9 % | 96,8 % | 49,6 % | 7,9 % | 10,5 |
| Mage | 43,8 % | 16,8 % | 50,7 % | 28,1 % | 71,9 % | 51,1 % | 22,6 % | 36,0 % | 90,8 % | 51,7 % | 7,2 % | 10,8 |
| Voleur | 56,8 % | 25,0 % | 50,0 % | 47,5 % | 29,1 % | 67,3 % | 39,0 % | 45,8 % | 90,8 % | 50,9 % | 9,1 % | 10,6 |
| Archer | 49,0 % | 17,8 % | 47,2 % | 41,9 % | 35,4 % | 71,8 % | 27,5 % | 42,6 % | 89,0 % | 45,8 % | 6,6 % | 10,3 |
| Prêtre | 27,5 % | 10,0 % | 50,3 % | 53,1 % | 77,3 % | 35,1 % | 83,9 % | 79,0 % | 96,4 % | 51,6 % | 8,6 % | 10,7 |
| Alchimiste | 39,0 % | 9,8 % | 53,8 % | 53,3 % | 38,0 % | 61,4 % | 43,3 % | 72,9 % | 97,4 % | 43,5 % | 7,8 % | 10,2 |
| Invocateur | 51,0 % | 18,5 % | 51,7 % | 43,2 % | 44,4 % | 74,0 % | 41,1 % | 53,7 % | 91,6 % | 49,6 % | 8,6 % | 10,5 |
| Barde | 49,5 % | 16,3 % | 48,5 % | 48,2 % | 63,6 % | 61,6 % | 52,7 % | 52,0 % | 92,5 % | 52,0 % | 9,4 % | 11,2 |
| Diplomate | 25,0 % | 5,8 % | 48,1 % | 35,4 % | 59,1 % | 95,3 % | 49,0 % | 86,1 % | 97,1 % | 35,5 % | 5,1 % | 9,0 |
| Pugiliste | 21,3 % | 8,8 % | 50,3 % | 52,8 % | 56,7 % | 67,7 % | 84,4 % | 45,7 % | 96,1 % | 53,5 % | 7,8 % | 10,8 |

### Boutons touchés, et pourquoi

- pas des k calculés ensemble : le k d'une classe change aussi le duo dont elle est l'acolyte ; les duels au-delà de 58 % comptent aussi (effets mesurés à graines égales avant la passe 87)
- k_classe Guerrier : 0,846 → 0,839 (50,2 % de victoires)
- k_classe Mage : 0,837 → 0,829 (50,7 % de victoires)
- k_classe Archer : 0,881 → 0,883 (47,2 % de victoires)
- k_classe Prêtre : 0,858 → 0,852 (50,3 % de victoires)
- k_classe Alchimiste : 0,985 → 0,965 (53,8 % de victoires)
- k_classe Invocateur : 0,820 → 0,807 (51,7 % de victoires)
- k_classe Barde : 0,990 → 0,980 (48,5 % de victoires)
- k_classe Pugiliste : 1,039 → 1,029 (50,3 % de victoires)
- Tour, Mage : facteur des monstres 0,736 → 0,741 (étage 10 dans 51,7 % des montées)
- Tour, Voleur : facteur des monstres 0,961 → 0,980 (étage 10 dans 50,9 % des montées)
- Tour, Archer : facteur des monstres 0,695 → 0,691 (étage 10 dans 45,8 % des montées)
- Tour, Prêtre : facteur des monstres 1,087 → 1,115 (étage 10 dans 51,6 % des montées)
- Tour, Alchimiste : facteur des monstres 0,866 → 0,849 (étage 10 dans 43,5 % des montées)
- Tour, Barde : facteur des monstres 0,851 → 0,858 (étage 10 dans 52,0 % des montées)
- Tour, Diplomate : pente des monstres 0,948 → 0,925 (étage 20 dans 5,1 % des montées)
- Tour, Diplomate : facteur des monstres 1,199 → 1,076 (étage 10 dans 35,5 % des montées)
- Tour, Pugiliste : facteur des monstres 0,959 → 0,979 (étage 10 dans 53,5 % des montées)

## Passe 91 (graines à partir de 9100274)

**4 critères tenus sur 6.** 100000 combats de duel (médiane 20 tours), 0 combats non finis.

### Les six critères (section 11.2)

- ✅ **1. Chaque classe entre 47 % et 53 % de victoires**
- ❌ **2. Aucune case de la matrice hors de 40 % – 60 %** : guerrier contre archer 64,2 %, mage contre guerrier 36,7 %, archer contre guerrier 34,6 %, pretre contre alchimiste 37,0 %, alchimiste contre pretre 64,7 %, alchimiste contre barde 61,7 %, barde contre alchimiste 39,4 %
- ✅ **3. La route Réactive entre 40 % et 55 % (Ruée et Éventail : des repères, sans seuil)**
- ✅ **4. Chaque voie jouée dans 15 % des combats au moins, une Clé dans 60 %**
- ✅ **5. Longueur : médiane de 18 à 22 tours, 95 % finis avant le tour 30**
- ❌ **6. Tour : étage 10 dans 40 à 60 % des montées, étage 20 dans 5 à 10 %, à 5 points près entre classes** : invocateur étage 20 4,5 %, diplomate étage 20 10,8 %, écart entre classes : étage 10 de 46,9 % à 59,1 %, étage 20 de 4,5 % à 10,8 %

### La matrice des classes (taux de victoire de la ligne contre la colonne)

| | Guer | Mage | Vole | Arch | Prêt | Alch | Invo | Bard | Dipl | Pugi | **Moyenne** |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 50 | 58 | 53 | 64 | 43 | 42 | 47 | 52 | 45 | 58 | **51,1 %** |
| Mage | 37 | 51 | 49 | 53 | 52 | 53 | 45 | 57 | 55 | 47 | **49,8 %** |
| Voleur | 47 | 56 | 49 | 49 | 59 | 52 | 47 | 53 | 46 | 49 | **50,8 %** |
| Archer | 35 | 47 | 50 | 47 | 47 | 56 | 47 | 54 | 53 | 51 | **48,7 %** |
| Prêtre | 55 | 49 | 45 | 53 | 52 | 37 | 45 | 44 | 52 | 48 | **47,9 %** |
| Alchimiste | 53 | 46 | 47 | 45 | 65 | 51 | 52 | 62 | 55 | 50 | **52,7 %** |
| Invocateur | 53 | 57 | 51 | 50 | 52 | 48 | 52 | 51 | 45 | 52 | **51,0 %** |
| Barde | 49 | 45 | 50 | 46 | 55 | 39 | 52 | 53 | 50 | 52 | **49,0 %** |
| Diplomate | 55 | 45 | 54 | 43 | 50 | 47 | 54 | 48 | 49 | 46 | **49,2 %** |
| Pugiliste | 41 | 50 | 50 | 49 | 52 | 47 | 46 | 48 | 54 | 48 | **48,7 %** |

### Les trois routes, l'usage des voies et la Tour, par classe

| Classe | Ruée | Éventail | Réactive | Voie 1 | Voie 2 | Voie 3 | Voie 4 | Voie 5 | Clé | Tour : étage 10 | étage 20 | étage moyen |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 44,3 % | 8,8 % | 51,1 % | 47,3 % | 68,5 % | 40,8 % | 86,5 % | 71,1 % | 96,5 % | 51,4 % | 7,4 % | 10,7 |
| Mage | 51,2 % | 18,5 % | 49,8 % | 24,9 % | 75,6 % | 43,2 % | 22,8 % | 35,9 % | 91,0 % | 55,9 % | 7,6 % | 11,0 |
| Voleur | 52,0 % | 25,8 % | 50,8 % | 45,9 % | 28,4 % | 69,5 % | 38,9 % | 46,9 % | 91,4 % | 50,5 % | 6,5 % | 10,3 |
| Archer | 53,3 % | 21,0 % | 48,7 % | 47,9 % | 36,0 % | 71,8 % | 26,8 % | 37,5 % | 89,5 % | 59,1 % | 6,8 % | 11,1 |
| Prêtre | 23,8 % | 5,5 % | 47,9 % | 50,7 % | 78,4 % | 41,2 % | 83,9 % | 80,1 % | 97,1 % | 50,1 % | 5,9 % | 10,5 |
| Alchimiste | 34,8 % | 9,0 % | 52,7 % | 53,9 % | 39,1 % | 64,0 % | 44,7 % | 70,1 % | 97,5 % | 51,7 % | 7,9 % | 11,0 |
| Invocateur | 47,3 % | 17,5 % | 51,0 % | 41,1 % | 42,4 % | 77,3 % | 41,8 % | 51,1 % | 91,4 % | 48,6 % | 4,5 % | 10,2 |
| Barde | 45,8 % | 15,0 % | 49,0 % | 50,5 % | 65,4 % | 62,4 % | 51,9 % | 49,5 % | 92,8 % | 55,5 % | 8,6 % | 11,3 |
| Diplomate | 27,3 % | 8,5 % | 49,2 % | 36,3 % | 58,5 % | 95,7 % | 48,1 % | 86,9 % | 97,6 % | 46,9 % | 10,8 % | 10,3 |
| Pugiliste | 21,0 % | 5,5 % | 48,7 % | 54,0 % | 53,7 % | 68,6 % | 85,0 % | 45,1 % | 96,7 % | 49,9 % | 6,9 % | 10,3 |

### Boutons touchés, et pourquoi

- pas des k calculés ensemble : le k d'une classe change aussi le duo dont elle est l'acolyte ; les duels au-delà de 58 % comptent aussi (effets mesurés à graines égales avant la passe 91)
- k_classe Guerrier : 0,839 → 0,833 (51,1 % de victoires)
- k_classe Mage : 0,829 → 0,837 (49,8 % de victoires)
- k_classe Archer : 0,883 → 0,891 (48,7 % de victoires)
- k_classe Prêtre : 0,852 → 0,849 (47,9 % de victoires)
- k_classe Alchimiste : 0,965 → 0,951 (52,7 % de victoires)
- k_classe Invocateur : 0,807 → 0,802 (51,0 % de victoires)
- k_classe Barde : 0,980 → 0,973 (49,0 % de victoires)
- k_classe Pugiliste : 1,029 → 1,027 (48,7 % de victoires)
- Tour, Mage : facteur des monstres 0,741 → 0,746 (étage 10 dans 55,9 % des montées)
- Tour, Archer : facteur des monstres 0,691 → 0,696 (étage 10 dans 59,1 % des montées)
- Tour, Invocateur : pente des monstres 1,215 → 1,142 (étage 20 dans 4,5 % des montées)
- Tour, Invocateur : facteur des monstres 0,970 → 0,944 (étage 10 dans 48,6 % des montées)
- Tour, Barde : facteur des monstres 0,858 → 0,864 (étage 10 dans 55,5 % des montées)
- Tour, Diplomate : pente des monstres 0,925 → 0,940 (étage 20 dans 10,8 % des montées)
- Tour, Diplomate : facteur des monstres 1,076 → 1,032 (étage 10 dans 46,9 % des montées)
- Tour, Pugiliste : facteur des monstres 0,979 → 0,974 (étage 10 dans 49,9 % des montées)

## Passe 92 (graines à partir de 9200277)

**3 critères tenus sur 6.** 100000 combats de duel (médiane 20 tours), 0 combats non finis.

### Les six critères (section 11.2)

- ❌ **1. Chaque classe entre 47 % et 53 % de victoires** : pretre 53,5 %
- ❌ **2. Aucune case de la matrice hors de 40 % – 60 %** : guerrier contre archer 60,7 %, pretre contre guerrier 61,2 %, alchimiste contre pretre 64,3 %, alchimiste contre barde 60,1 %
- ✅ **3. La route Réactive entre 40 % et 55 % (Ruée et Éventail : des repères, sans seuil)**
- ✅ **4. Chaque voie jouée dans 15 % des combats au moins, une Clé dans 60 %**
- ✅ **5. Longueur : médiane de 18 à 22 tours, 95 % finis avant le tour 30**
- ❌ **6. Tour : étage 10 dans 40 à 60 % des montées, étage 20 dans 5 à 10 %, à 5 points près entre classes** : voleur étage 20 4,0 %, diplomate étage 20 10,6 %, écart entre classes : étage 10 de 44,3 % à 52,1 %, étage 20 de 4,0 % à 10,6 %

### La matrice des classes (taux de victoire de la ligne contre la colonne)

| | Guer | Mage | Vole | Arch | Prêt | Alch | Invo | Bard | Dipl | Pugi | **Moyenne** |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 49 | 56 | 51 | 61 | 43 | 46 | 48 | 46 | 44 | 55 | **49,8 %** |
| Mage | 45 | 51 | 47 | 51 | 47 | 52 | 48 | 54 | 60 | 50 | **50,4 %** |
| Voleur | 47 | 55 | 50 | 47 | 49 | 52 | 47 | 48 | 47 | 48 | **48,9 %** |
| Archer | 41 | 52 | 52 | 47 | 41 | 59 | 53 | 50 | 56 | 46 | **49,7 %** |
| Prêtre | 61 | 54 | 50 | 59 | 52 | 43 | 54 | 52 | 57 | 53 | **53,5 %** |
| Alchimiste | 60 | 48 | 49 | 45 | 64 | 49 | 53 | 60 | 55 | 45 | **52,8 %** |
| Invocateur | 55 | 55 | 53 | 53 | 49 | 52 | 49 | 49 | 45 | 49 | **50,9 %** |
| Barde | 53 | 45 | 52 | 50 | 52 | 41 | 53 | 53 | 52 | 49 | **50,0 %** |
| Diplomate | 54 | 42 | 53 | 44 | 49 | 46 | 58 | 49 | 49 | 48 | **49,0 %** |
| Pugiliste | 41 | 47 | 49 | 47 | 45 | 51 | 46 | 46 | 52 | 47 | **47,2 %** |

### Les trois routes, l'usage des voies et la Tour, par classe

| Classe | Ruée | Éventail | Réactive | Voie 1 | Voie 2 | Voie 3 | Voie 4 | Voie 5 | Clé | Tour : étage 10 | étage 20 | étage moyen |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 44,0 % | 12,5 % | 49,8 % | 51,8 % | 68,2 % | 42,4 % | 83,0 % | 69,2 % | 96,2 % | 49,1 % | 7,8 % | 10,3 |
| Mage | 50,2 % | 18,5 % | 50,4 % | 29,9 % | 70,9 % | 48,8 % | 22,9 % | 35,3 % | 89,5 % | 50,6 % | 6,1 % | 10,7 |
| Voleur | 48,0 % | 20,8 % | 48,9 % | 46,3 % | 28,5 % | 66,9 % | 37,2 % | 48,3 % | 90,5 % | 44,3 % | 4,0 % | 9,6 |
| Archer | 54,8 % | 21,8 % | 49,7 % | 48,4 % | 39,2 % | 68,3 % | 26,7 % | 35,1 % | 88,2 % | 45,5 % | 6,8 % | 10,5 |
| Prêtre | 31,8 % | 9,0 % | 53,5 % | 50,9 % | 78,7 % | 32,0 % | 84,3 % | 77,3 % | 96,0 % | 51,6 % | 7,1 % | 10,5 |
| Alchimiste | 35,8 % | 10,3 % | 52,8 % | 56,3 % | 37,0 % | 63,7 % | 42,9 % | 67,5 % | 97,3 % | 48,8 % | 8,5 % | 10,8 |
| Invocateur | 42,3 % | 16,8 % | 50,9 % | 38,2 % | 40,7 % | 75,3 % | 42,6 % | 49,7 % | 91,0 % | 46,6 % | 8,5 % | 10,5 |
| Barde | 45,0 % | 13,8 % | 50,0 % | 49,2 % | 66,0 % | 60,5 % | 50,7 % | 48,8 % | 92,2 % | 52,1 % | 9,1 % | 10,9 |
| Diplomate | 22,5 % | 1,8 % | 49,0 % | 34,3 % | 60,9 % | 95,0 % | 49,3 % | 86,7 % | 97,3 % | 48,0 % | 10,6 % | 10,5 |
| Pugiliste | 23,8 % | 6,8 % | 47,2 % | 52,7 % | 50,8 % | 68,8 % | 83,4 % | 44,0 % | 96,4 % | 46,0 % | 5,4 % | 10,1 |

### Boutons touchés, et pourquoi

- pas des k calculés ensemble : le k d'une classe change aussi le duo dont elle est l'acolyte ; les duels au-delà de 58 % comptent aussi (effets mesurés à graines égales avant la passe 91)
- k_classe Guerrier : 0,833 → 0,829 (49,8 % de victoires)
- k_classe Mage : 0,837 → 0,825 (50,4 % de victoires)
- k_classe Archer : 0,891 → 0,883 (49,7 % de victoires)
- k_classe Prêtre : 0,849 → 0,839 (53,5 % de victoires)
- k_classe Alchimiste : 0,951 → 0,935 (52,8 % de victoires)
- k_classe Invocateur : 0,802 → 0,787 (50,9 % de victoires)
- k_classe Barde : 0,973 → 0,968 (50,0 % de victoires)
- k_classe Pugiliste : 1,027 → 1,025 (47,2 % de victoires)
- Tour, Mage : facteur des monstres 0,746 → 0,750 (étage 10 dans 50,6 % des montées)
- Tour, Voleur : pente des monstres 0,458 → 0,426 (étage 20 dans 4,0 % des montées)
- Tour, Voleur : facteur des monstres 0,980 → 0,964 (étage 10 dans 44,2 % des montées)
- Tour, Archer : facteur des monstres 0,696 → 0,695 (étage 10 dans 45,5 % des montées)
- Tour, Prêtre : facteur des monstres 1,115 → 1,145 (étage 10 dans 51,6 % des montées)
- Tour, Barde : facteur des monstres 0,864 → 0,870 (étage 10 dans 52,1 % des montées)
- Tour, Diplomate : pente des monstres 0,940 → 0,955 (étage 20 dans 10,6 % des montées)
- Tour, Pugiliste : pente des monstres 1,052 → 1,008 (étage 20 dans 5,4 % des montées)
- Tour, Pugiliste : facteur des monstres 0,974 → 0,970 (étage 10 dans 46,0 % des montées)

## Passe 93 (graines à partir de 9300280)

**4 critères tenus sur 6.** 100000 combats de duel (médiane 20 tours), 0 combats non finis.

### Les six critères (section 11.2)

- ✅ **1. Chaque classe entre 47 % et 53 % de victoires**
- ❌ **2. Aucune case de la matrice hors de 40 % – 60 %** : guerrier contre archer 60,1 %, archer contre guerrier 37,6 %, pretre contre alchimiste 38,0 %, alchimiste contre pretre 61,4 %
- ✅ **3. La route Réactive entre 40 % et 55 % (Ruée et Éventail : des repères, sans seuil)**
- ✅ **4. Chaque voie jouée dans 15 % des combats au moins, une Clé dans 60 %**
- ✅ **5. Longueur : médiane de 18 à 22 tours, 95 % finis avant le tour 30**
- ❌ **6. Tour : étage 10 dans 40 à 60 % des montées, étage 20 dans 5 à 10 %, à 5 points près entre classes** : diplomate étage 20 11,4 %, écart entre classes : étage 10 de 40,1 % à 55,0 %, étage 20 de 5,0 % à 11,4 %

### La matrice des classes (taux de victoire de la ligne contre la colonne)

| | Guer | Mage | Vole | Arch | Prêt | Alch | Invo | Bard | Dipl | Pugi | **Moyenne** |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 50 | 57 | 46 | 60 | 44 | 45 | 46 | 48 | 46 | 57 | **49,9 %** |
| Mage | 42 | 53 | 46 | 53 | 52 | 53 | 47 | 57 | 57 | 49 | **50,9 %** |
| Voleur | 50 | 59 | 50 | 50 | 56 | 54 | 52 | 54 | 48 | 46 | **51,8 %** |
| Archer | 38 | 51 | 51 | 51 | 46 | 55 | 53 | 54 | 55 | 48 | **50,1 %** |
| Prêtre | 54 | 51 | 43 | 55 | 50 | 38 | 49 | 48 | 51 | 47 | **48,4 %** |
| Alchimiste | 55 | 49 | 45 | 46 | 61 | 51 | 51 | 59 | 53 | 49 | **52,0 %** |
| Invocateur | 52 | 56 | 50 | 48 | 53 | 50 | 51 | 49 | 41 | 50 | **50,0 %** |
| Barde | 51 | 45 | 48 | 50 | 53 | 42 | 50 | 51 | 50 | 51 | **49,1 %** |
| Diplomate | 52 | 44 | 53 | 46 | 48 | 47 | 55 | 49 | 49 | 46 | **48,9 %** |
| Pugiliste | 43 | 53 | 49 | 51 | 54 | 54 | 52 | 50 | 53 | 50 | **50,7 %** |

### Les trois routes, l'usage des voies et la Tour, par classe

| Classe | Ruée | Éventail | Réactive | Voie 1 | Voie 2 | Voie 3 | Voie 4 | Voie 5 | Clé | Tour : étage 10 | étage 20 | étage moyen |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 42,5 % | 10,8 % | 49,9 % | 47,8 % | 67,3 % | 49,3 % | 85,0 % | 67,9 % | 97,0 % | 51,0 % | 6,0 % | 10,4 |
| Mage | 51,7 % | 19,5 % | 50,9 % | 28,2 % | 71,7 % | 51,7 % | 24,7 % | 36,5 % | 90,6 % | 55,0 % | 6,9 % | 11,0 |
| Voleur | 57,3 % | 25,8 % | 51,8 % | 45,3 % | 29,0 % | 69,6 % | 38,3 % | 47,2 % | 91,1 % | 52,4 % | 6,9 % | 10,6 |
| Archer | 53,8 % | 21,3 % | 50,1 % | 39,1 % | 41,5 % | 69,8 % | 29,8 % | 44,6 % | 89,4 % | 50,5 % | 6,0 % | 10,6 |
| Prêtre | 27,8 % | 9,3 % | 48,4 % | 49,7 % | 77,7 % | 41,1 % | 84,0 % | 80,2 % | 96,9 % | 40,1 % | 5,0 % | 9,4 |
| Alchimiste | 38,3 % | 12,8 % | 52,0 % | 53,0 % | 35,6 % | 66,3 % | 42,9 % | 69,7 % | 97,5 % | 48,0 % | 6,5 % | 10,6 |
| Invocateur | 51,0 % | 20,5 % | 50,0 % | 40,9 % | 40,8 % | 79,8 % | 37,6 % | 48,1 % | 91,5 % | 45,9 % | 8,1 % | 10,0 |
| Barde | 48,0 % | 16,3 % | 49,1 % | 52,6 % | 66,8 % | 62,9 % | 50,1 % | 45,0 % | 92,9 % | 52,5 % | 8,1 % | 10,8 |
| Diplomate | 25,3 % | 8,0 % | 48,9 % | 35,6 % | 58,7 % | 95,4 % | 48,9 % | 85,5 % | 97,3 % | 49,6 % | 11,4 % | 10,6 |
| Pugiliste | 15,3 % | 6,3 % | 50,7 % | 54,2 % | 51,8 % | 67,1 % | 84,7 % | 46,2 % | 96,4 % | 50,7 % | 8,3 % | 10,5 |

### Boutons touchés, et pourquoi

- pas des k calculés ensemble : le k d'une classe change aussi le duo dont elle est l'acolyte ; les duels au-delà de 58 % comptent aussi (effets mesurés à graines égales avant la passe 91)
- k_classe Guerrier : 0,829 → 0,833 (49,9 % de victoires)
- k_classe Mage : 0,825 → 0,829 (50,9 % de victoires)
- k_classe Archer : 0,883 → 0,892 (50,1 % de victoires)
- k_classe Prêtre : 0,839 → 0,855 (48,4 % de victoires)
- k_classe Alchimiste : 0,935 → 0,937 (52,0 % de victoires)
- k_classe Invocateur : 0,787 → 0,792 (50,0 % de victoires)
- k_classe Barde : 0,968 → 0,972 (49,1 % de victoires)
- k_classe Pugiliste : 1,025 → 1,031 (50,7 % de victoires)
- PV du Voleur : ×0,94 → ×0,91 (k déjà à sa borne, 51,8 % de victoires)
- Tour, Mage : facteur des monstres 0,750 → 0,758 (étage 10 dans 55,0 % des montées)
- Tour, Voleur : facteur des monstres 0,964 → 0,970 (étage 10 dans 52,4 % des montées)
- Tour, Prêtre : pente des monstres 0,859 → 0,816 (étage 20 dans 5,0 % des montées)
- Tour, Prêtre : facteur des monstres 1,145 → 1,101 (étage 10 dans 40,1 % des montées)
- Tour, Invocateur : facteur des monstres 0,944 → 0,916 (étage 10 dans 45,9 % des montées)
- Tour, Barde : facteur des monstres 0,870 → 0,875 (étage 10 dans 52,5 % des montées)
- Tour, Diplomate : pente des monstres 0,955 → 0,974 (étage 20 dans 11,4 % des montées)

## Passe 94 (graines à partir de 9400283)

**4 critères tenus sur 6.** 100000 combats de duel (médiane 20 tours), 0 combats non finis.

### Les six critères (section 11.2)

- ✅ **1. Chaque classe entre 47 % et 53 % de victoires**
- ❌ **2. Aucune case de la matrice hors de 40 % – 60 %** : pretre contre guerrier 60,8 %, pretre contre alchimiste 39,8 %
- ✅ **3. La route Réactive entre 40 % et 55 % (Ruée et Éventail : des repères, sans seuil)**
- ✅ **4. Chaque voie jouée dans 15 % des combats au moins, une Clé dans 60 %**
- ✅ **5. Longueur : médiane de 18 à 22 tours, 95 % finis avant le tour 30**
- ❌ **6. Tour : étage 10 dans 40 à 60 % des montées, étage 20 dans 5 à 10 %, à 5 points près entre classes** : mage étage 20 4,5 %, invocateur étage 20 11,4 %, diplomate étage 20 11,0 %, écart entre classes : étage 10 de 44,3 % à 55,6 %, étage 20 de 4,5 % à 11,4 %

### La matrice des classes (taux de victoire de la ligne contre la colonne)

| | Guer | Mage | Vole | Arch | Prêt | Alch | Invo | Bard | Dipl | Pugi | **Moyenne** |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 48 | 55 | 51 | 60 | 40 | 47 | 47 | 49 | 46 | 54 | **49,6 %** |
| Mage | 45 | 48 | 44 | 49 | 48 | 56 | 43 | 57 | 59 | 46 | **49,4 %** |
| Voleur | 51 | 55 | 53 | 45 | 53 | 54 | 45 | 50 | 48 | 45 | **49,7 %** |
| Archer | 41 | 49 | 52 | 50 | 44 | 60 | 52 | 53 | 59 | 46 | **50,4 %** |
| Prêtre | 61 | 51 | 47 | 53 | 49 | 40 | 45 | 47 | 52 | 48 | **49,3 %** |
| Alchimiste | 55 | 44 | 45 | 41 | 60 | 49 | 47 | 57 | 50 | 42 | **48,9 %** |
| Invocateur | 54 | 55 | 53 | 50 | 52 | 52 | 51 | 49 | 46 | 49 | **51,0 %** |
| Barde | 55 | 44 | 51 | 46 | 52 | 44 | 49 | 52 | 54 | 51 | **49,8 %** |
| Diplomate | 55 | 42 | 54 | 41 | 48 | 50 | 55 | 51 | 49 | 46 | **49,1 %** |
| Pugiliste | 46 | 53 | 54 | 53 | 52 | 58 | 51 | 49 | 56 | 49 | **52,1 %** |

### Les trois routes, l'usage des voies et la Tour, par classe

| Classe | Ruée | Éventail | Réactive | Voie 1 | Voie 2 | Voie 3 | Voie 4 | Voie 5 | Clé | Tour : étage 10 | étage 20 | étage moyen |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 44,0 % | 12,5 % | 49,6 % | 51,3 % | 69,6 % | 45,1 % | 83,3 % | 67,9 % | 96,8 % | 53,3 % | 6,1 % | 10,5 |
| Mage | 45,0 % | 17,8 % | 49,4 % | 25,3 % | 74,4 % | 43,6 % | 24,5 % | 34,6 % | 90,5 % | 44,3 % | 4,5 % | 10,0 |
| Voleur | 45,3 % | 22,8 % | 49,7 % | 46,2 % | 29,1 % | 65,4 % | 38,4 % | 48,2 % | 89,6 % | 47,0 % | 6,0 % | 9,9 |
| Archer | 53,8 % | 23,0 % | 50,4 % | 49,3 % | 39,8 % | 69,8 % | 25,3 % | 33,8 % | 88,4 % | 48,3 % | 7,2 % | 10,5 |
| Prêtre | 26,3 % | 9,0 % | 49,3 % | 52,3 % | 81,3 % | 32,8 % | 83,7 % | 77,2 % | 97,2 % | 50,7 % | 8,4 % | 10,4 |
| Alchimiste | 39,0 % | 13,3 % | 48,9 % | 54,6 % | 35,8 % | 65,6 % | 43,8 % | 69,4 % | 97,6 % | 46,8 % | 5,8 % | 10,3 |
| Invocateur | 40,0 % | 16,0 % | 51,0 % | 39,6 % | 43,1 % | 76,8 % | 42,7 % | 49,1 % | 91,5 % | 55,6 % | 11,4 % | 11,4 |
| Barde | 42,5 % | 15,3 % | 49,8 % | 51,0 % | 65,8 % | 62,2 % | 50,8 % | 48,3 % | 92,6 % | 49,9 % | 6,4 % | 10,6 |
| Diplomate | 30,3 % | 8,8 % | 49,1 % | 34,9 % | 59,1 % | 95,3 % | 49,3 % | 86,2 % | 97,4 % | 48,0 % | 11,0 % | 10,3 |
| Pugiliste | 21,5 % | 8,5 % | 52,1 % | 44,3 % | 56,7 % | 68,3 % | 89,7 % | 44,5 % | 96,7 % | 54,1 % | 9,0 % | 11,0 |

### Boutons touchés, et pourquoi

- pas des k calculés ensemble : le k d'une classe change aussi le duo dont elle est l'acolyte ; les duels au-delà de 58 % comptent aussi (effets mesurés à graines égales avant la passe 91)
- k_classe Guerrier : 0,833 → 0,838 (49,6 % de victoires)
- k_classe Mage : 0,829 → 0,820 (49,4 % de victoires)
- k_classe Archer : 0,892 → 0,887 (50,4 % de victoires)
- k_classe Prêtre : 0,855 → 0,876 (49,3 % de victoires)
- k_classe Alchimiste : 0,937 → 0,947 (48,9 % de victoires)
- k_classe Invocateur : 0,792 → 0,791 (51,0 % de victoires)
- k_classe Barde : 0,972 → 0,976 (49,8 % de victoires)
- Tour, Guerrier : facteur des monstres 1,766 → 1,815 (étage 10 dans 53,2 % des montées)
- Tour, Mage : pente des monstres 0,929 → 0,874 (étage 20 dans 4,5 % des montées)
- Tour, Mage : facteur des monstres 0,758 → 0,754 (étage 10 dans 44,2 % des montées)
- Tour, Voleur : facteur des monstres 0,970 → 0,967 (étage 10 dans 47,0 % des montées)
- Tour, Alchimiste : facteur des monstres 0,849 → 0,838 (étage 10 dans 46,8 % des montées)
- Tour, Invocateur : pente des monstres 1,142 → 1,186 (étage 20 dans 11,4 % des montées)
- Tour, Invocateur : facteur des monstres 0,916 → 0,938 (étage 10 dans 55,6 % des montées)
- Tour, Diplomate : pente des monstres 0,974 → 0,991 (étage 20 dans 11,0 % des montées)
- Tour, Pugiliste : facteur des monstres 0,970 → 0,974 (étage 10 dans 54,1 % des montées)

## Passe 95 (graines à partir de 9500286)

**4 critères tenus sur 6.** 100000 combats de duel (médiane 20 tours), 0 combats non finis.

### Les six critères (section 11.2)

- ✅ **1. Chaque classe entre 47 % et 53 % de victoires**
- ❌ **2. Aucune case de la matrice hors de 40 % – 60 %** : guerrier contre mage 62,4 %, guerrier contre archer 63,1 %, mage contre guerrier 36,4 %, archer contre guerrier 36,7 %, archer contre alchimiste 61,3 %
- ✅ **3. La route Réactive entre 40 % et 55 % (Ruée et Éventail : des repères, sans seuil)**
- ✅ **4. Chaque voie jouée dans 15 % des combats au moins, une Clé dans 60 %**
- ✅ **5. Longueur : médiane de 18 à 22 tours, 95 % finis avant le tour 30**
- ❌ **6. Tour : étage 10 dans 40 à 60 % des montées, étage 20 dans 5 à 10 %, à 5 points près entre classes** : pretre étage 20 10,3 %, écart entre classes : étage 10 de 45,1 % à 54,5 %, étage 20 de 5,3 % à 10,3 %

### La matrice des classes (taux de victoire de la ligne contre la colonne)

| | Guer | Mage | Vole | Arch | Prêt | Alch | Invo | Bard | Dipl | Pugi | **Moyenne** |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 49 | 62 | 56 | 63 | 42 | 49 | 51 | 51 | 47 | 59 | **52,9 %** |
| Mage | 36 | 47 | 48 | 50 | 49 | 56 | 45 | 57 | 58 | 48 | **49,3 %** |
| Voleur | 46 | 53 | 51 | 44 | 55 | 56 | 47 | 49 | 45 | 44 | **49,0 %** |
| Archer | 37 | 50 | 53 | 50 | 46 | 61 | 50 | 53 | 59 | 51 | **51,1 %** |
| Prêtre | 57 | 55 | 47 | 55 | 50 | 44 | 48 | 47 | 56 | 49 | **50,8 %** |
| Alchimiste | 51 | 44 | 48 | 40 | 60 | 48 | 52 | 57 | 54 | 44 | **49,8 %** |
| Invocateur | 48 | 54 | 55 | 50 | 54 | 53 | 52 | 49 | 43 | 49 | **50,8 %** |
| Barde | 49 | 43 | 51 | 46 | 55 | 42 | 50 | 49 | 50 | 53 | **48,7 %** |
| Diplomate | 54 | 42 | 55 | 41 | 47 | 45 | 56 | 45 | 49 | 48 | **48,0 %** |
| Pugiliste | 40 | 51 | 54 | 49 | 52 | 55 | 51 | 47 | 56 | 50 | **50,6 %** |

### Les trois routes, l'usage des voies et la Tour, par classe

| Classe | Ruée | Éventail | Réactive | Voie 1 | Voie 2 | Voie 3 | Voie 4 | Voie 5 | Clé | Tour : étage 10 | étage 20 | étage moyen |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 47,3 % | 14,5 % | 52,9 % | 47,4 % | 67,0 % | 41,8 % | 84,7 % | 69,5 % | 96,4 % | 53,3 % | 6,5 % | 10,6 |
| Mage | 47,8 % | 18,8 % | 49,3 % | 27,3 % | 73,1 % | 42,7 % | 23,9 % | 33,3 % | 90,0 % | 54,0 % | 8,1 % | 11,0 |
| Voleur | 42,8 % | 18,5 % | 49,0 % | 44,9 % | 29,7 % | 67,5 % | 37,3 % | 44,8 % | 89,5 % | 45,1 % | 5,5 % | 9,8 |
| Archer | 48,5 % | 19,3 % | 51,1 % | 40,3 % | 38,2 % | 69,9 % | 26,4 % | 46,0 % | 88,6 % | 53,9 % | 7,1 % | 10,8 |
| Prêtre | 26,8 % | 7,2 % | 50,8 % | 53,9 % | 83,6 % | 31,6 % | 82,7 % | 72,8 % | 97,5 % | 52,9 % | 10,3 % | 10,7 |
| Alchimiste | 36,3 % | 7,8 % | 49,8 % | 54,0 % | 36,2 % | 64,9 % | 42,3 % | 69,5 % | 97,5 % | 54,5 % | 7,5 % | 11,0 |
| Invocateur | 40,5 % | 15,8 % | 50,8 % | 40,6 % | 39,7 % | 77,5 % | 39,6 % | 48,3 % | 90,5 % | 46,3 % | 5,3 % | 10,1 |
| Barde | 43,8 % | 13,3 % | 48,7 % | 50,5 % | 66,0 % | 60,1 % | 48,8 % | 48,8 % | 92,3 % | 49,1 % | 5,3 % | 10,4 |
| Diplomate | 25,8 % | 5,8 % | 48,0 % | 35,6 % | 60,4 % | 94,9 % | 48,9 % | 85,0 % | 97,1 % | 45,5 % | 9,3 % | 10,1 |
| Pugiliste | 16,5 % | 6,3 % | 50,6 % | 43,8 % | 55,6 % | 68,6 % | 87,5 % | 45,0 % | 96,5 % | 54,4 % | 9,3 % | 10,9 |

### Boutons touchés, et pourquoi

- pas des k calculés ensemble : le k d'une classe change aussi le duo dont elle est l'acolyte ; les duels au-delà de 58 % comptent aussi (effets mesurés à graines égales avant la passe 95)
- k_classe Guerrier : 0,838 → 0,831 (52,9 % de victoires)
- k_classe Mage : 0,820 → 0,829 (49,3 % de victoires)
- k_classe Voleur : 0,750 → 0,764 (49,0 % de victoires)
- k_classe Archer : 0,887 → 0,885 (51,1 % de victoires)
- k_classe Prêtre : 0,876 → 0,859 (50,8 % de victoires)
- k_classe Alchimiste : 0,947 → 0,959 (49,8 % de victoires)
- k_classe Invocateur : 0,791 → 0,792 (50,8 % de victoires)
- k_classe Barde : 0,976 → 0,974 (48,7 % de victoires)
- k_classe Diplomate : 1,200 → 1,195 (48,0 % de victoires)
- k_classe Pugiliste : 1,031 → 1,023 (50,6 % de victoires)
- Tour, Guerrier : facteur des monstres 1,815 → 1,850 (étage 10 dans 53,2 % des montées)
- Tour, Mage : facteur des monstres 0,754 → 0,755 (étage 10 dans 54,0 % des montées)
- Tour, Voleur : facteur des monstres 0,967 → 0,961 (étage 10 dans 45,1 % des montées)
- Tour, Archer : facteur des monstres 0,695 → 0,696 (étage 10 dans 53,9 % des montées)
- Tour, Prêtre : pente des monstres 0,816 → 0,838 (étage 20 dans 10,2 % des montées)
- Tour, Alchimiste : facteur des monstres 0,838 → 0,844 (étage 10 dans 54,5 % des montées)
- Tour, Invocateur : pente des monstres 1,186 → 1,173 (étage 20 dans 5,2 % des montées)
- Tour, Invocateur : facteur des monstres 0,938 → 0,929 (étage 10 dans 46,2 % des montées)
- Tour, Barde : pente des monstres 1,270 → 1,213 (étage 20 dans 5,2 % des montées)
- Tour, Diplomate : facteur des monstres 1,032 → 0,988 (étage 10 dans 45,5 % des montées)
- Tour, Pugiliste : facteur des monstres 0,974 → 0,978 (étage 10 dans 54,4 % des montées)

## Passe 96 (graines à partir de 9600289)

**4 critères tenus sur 6.** 100000 combats de duel (médiane 20 tours), 0 combats non finis.

### Les six critères (section 11.2)

- ✅ **1. Chaque classe entre 47 % et 53 % de victoires**
- ❌ **2. Aucune case de la matrice hors de 40 % – 60 %** : guerrier contre archer 61,6 %, archer contre guerrier 37,6 %, alchimiste contre pretre 61,0 %
- ✅ **3. La route Réactive entre 40 % et 55 % (Ruée et Éventail : des repères, sans seuil)**
- ✅ **4. Chaque voie jouée dans 15 % des combats au moins, une Clé dans 60 %**
- ✅ **5. Longueur : médiane de 18 à 22 tours, 95 % finis avant le tour 30**
- ❌ **6. Tour : étage 10 dans 40 à 60 % des montées, étage 20 dans 5 à 10 %, à 5 points près entre classes** : guerrier étage 20 2,6 %, archer étage 20 4,9 %, diplomate étage 20 12,9 %, écart entre classes : étage 10 de 45,0 % à 53,5 %, étage 20 de 2,6 % à 12,9 %

### La matrice des classes (taux de victoire de la ligne contre la colonne)

| | Guer | Mage | Vole | Arch | Prêt | Alch | Invo | Bard | Dipl | Pugi | **Moyenne** |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 51 | 57 | 49 | 62 | 44 | 49 | 50 | 51 | 47 | 59 | **52,0 %** |
| Mage | 44 | 50 | 46 | 51 | 49 | 59 | 45 | 56 | 54 | 50 | **50,4 %** |
| Voleur | 53 | 53 | 48 | 47 | 54 | 53 | 48 | 49 | 47 | 46 | **49,6 %** |
| Archer | 38 | 49 | 53 | 49 | 45 | 59 | 50 | 52 | 56 | 53 | **50,5 %** |
| Prêtre | 59 | 52 | 48 | 58 | 48 | 44 | 51 | 48 | 49 | 50 | **50,7 %** |
| Alchimiste | 52 | 44 | 43 | 41 | 61 | 53 | 49 | 55 | 51 | 43 | **49,3 %** |
| Invocateur | 56 | 52 | 53 | 48 | 51 | 53 | 50 | 49 | 45 | 50 | **50,7 %** |
| Barde | 50 | 42 | 48 | 45 | 54 | 46 | 54 | 49 | 53 | 53 | **49,3 %** |
| Diplomate | 56 | 47 | 56 | 44 | 52 | 54 | 59 | 51 | 50 | 47 | **51,5 %** |
| Pugiliste | 44 | 52 | 54 | 50 | 52 | 58 | 51 | 48 | 54 | 52 | **51,4 %** |

### Les trois routes, l'usage des voies et la Tour, par classe

| Classe | Ruée | Éventail | Réactive | Voie 1 | Voie 2 | Voie 3 | Voie 4 | Voie 5 | Clé | Tour : étage 10 | étage 20 | étage moyen |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 49,3 % | 12,3 % | 52,0 % | 45,5 % | 74,2 % | 47,9 % | 83,6 % | 69,6 % | 97,1 % | 45,0 % | 2,6 % | 9,5 |
| Mage | 55,5 % | 19,0 % | 50,4 % | 24,9 % | 73,7 % | 44,2 % | 25,2 % | 35,0 % | 91,3 % | 48,5 % | 6,0 % | 10,5 |
| Voleur | 50,7 % | 25,3 % | 49,6 % | 45,8 % | 29,3 % | 65,0 % | 38,8 % | 48,5 % | 90,3 % | 52,3 % | 7,4 % | 10,6 |
| Archer | 55,3 % | 18,5 % | 50,5 % | 41,9 % | 38,9 % | 70,9 % | 26,6 % | 43,6 % | 89,7 % | 48,6 % | 4,9 % | 10,5 |
| Prêtre | 29,5 % | 12,5 % | 50,7 % | 50,5 % | 78,8 % | 41,5 % | 83,8 % | 80,7 % | 97,4 % | 52,4 % | 7,2 % | 10,5 |
| Alchimiste | 34,5 % | 10,5 % | 49,3 % | 54,7 % | 36,5 % | 66,3 % | 44,9 % | 66,7 % | 96,3 % | 49,3 % | 6,1 % | 10,7 |
| Invocateur | 49,5 % | 17,8 % | 50,7 % | 40,5 % | 43,0 % | 78,0 % | 42,8 % | 49,0 % | 92,3 % | 49,3 % | 8,9 % | 10,6 |
| Barde | 44,5 % | 12,0 % | 49,3 % | 52,0 % | 65,2 % | 61,4 % | 50,8 % | 47,9 % | 93,3 % | 51,1 % | 7,1 % | 10,6 |
| Diplomate | 30,5 % | 7,8 % | 51,5 % | 34,1 % | 50,5 % | 95,5 % | 47,9 % | 88,0 % | 97,9 % | 53,5 % | 12,9 % | 11,3 |
| Pugiliste | 16,5 % | 5,3 % | 51,4 % | 51,9 % | 52,6 % | 67,7 % | 87,4 % | 45,6 % | 97,2 % | 51,6 % | 6,9 % | 10,6 |

### Boutons touchés, et pourquoi

- pas des k calculés ensemble : le k d'une classe change aussi le duo dont elle est l'acolyte ; les duels au-delà de 58 % comptent aussi (effets mesurés à graines égales avant la passe 95)
- k_classe Guerrier : 0,831 → 0,826 (52,0 % de victoires)
- k_classe Mage : 0,829 → 0,833 (50,4 % de victoires)
- k_classe Voleur : 0,764 → 0,773 (49,6 % de victoires)
- k_classe Archer : 0,885 → 0,887 (50,5 % de victoires)
- k_classe Prêtre : 0,859 → 0,852 (50,7 % de victoires)
- k_classe Alchimiste : 0,959 → 0,970 (49,3 % de victoires)
- k_classe Invocateur : 0,792 → 0,794 (50,7 % de victoires)
- k_classe Barde : 0,974 → 0,970 (49,3 % de victoires)
- k_classe Diplomate : 1,195 → 1,184 (51,5 % de victoires)
- k_classe Pugiliste : 1,023 → 1,019 (51,4 % de victoires)
- Tour, Guerrier : pente des monstres 0,779 → 0,703 (étage 20 dans 2,6 % des montées)
- Tour, Guerrier : facteur des monstres 1,850 → 1,812 (étage 10 dans 45,0 % des montées)
- Tour, Voleur : facteur des monstres 0,961 → 0,962 (étage 10 dans 52,2 % des montées)
- Tour, Archer : pente des monstres 1,257 → 1,191 (étage 20 dans 4,9 % des montées)
- Tour, Prêtre : facteur des monstres 1,101 → 1,106 (étage 10 dans 52,4 % des montées)
- Tour, Diplomate : pente des monstres 0,991 → 1,017 (étage 20 dans 12,9 % des montées)
- Tour, Diplomate : facteur des monstres 0,988 → 1,001 (étage 10 dans 53,5 % des montées)

## Vérification finale à 20 tours (données de la passe 94), sur des graines jamais vues (3 000 combats par case, 4 000 montées par classe)

**5 critères tenus sur 6.** 300000 combats de duel (médiane 20 tours), 0 combats non finis.

### Les six critères (section 11.2)

- ✅ **1. Chaque classe entre 47 % et 53 % de victoires**
- ✅ **2. Aucune case de la matrice hors de 40 % – 60 %**
- ✅ **3. La route Réactive entre 40 % et 55 % (Ruée et Éventail : des repères, sans seuil)**
- ✅ **4. Chaque voie jouée dans 15 % des combats au moins, une Clé dans 60 %**
- ✅ **5. Longueur : médiane de 18 à 22 tours, 95 % finis avant le tour 30**
- ❌ **6. Tour : étage 10 dans 40 à 60 % des montées, étage 20 dans 5 à 10 %, à 5 points près entre classes** : invocateur étage 20 10,1 %, diplomate étage 20 10,8 %, écart entre classes : étage 10 de 45,4 % à 54,4 %, étage 20 de 5,9 % à 10,8 %

### La matrice des classes (taux de victoire de la ligne contre la colonne)

| | Guer | Mage | Vole | Arch | Prêt | Alch | Invo | Bard | Dipl | Pugi | **Moyenne** |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 50 | 56 | 50 | 59 | 41 | 46 | 44 | 45 | 44 | 54 | **49,1 %** |
| Mage | 46 | 50 | 45 | 53 | 49 | 54 | 44 | 54 | 59 | 45 | **49,8 %** |
| Voleur | 50 | 54 | 49 | 46 | 53 | 55 | 46 | 49 | 46 | 44 | **49,3 %** |
| Archer | 41 | 49 | 53 | 52 | 45 | 60 | 50 | 53 | 57 | 46 | **50,5 %** |
| Prêtre | 60 | 51 | 45 | 53 | 50 | 41 | 46 | 45 | 52 | 47 | **49,0 %** |
| Alchimiste | 53 | 44 | 43 | 40 | 58 | 52 | 47 | 55 | 50 | 42 | **48,4 %** |
| Invocateur | 54 | 55 | 52 | 50 | 51 | 52 | 49 | 49 | 43 | 49 | **50,4 %** |
| Barde | 53 | 44 | 50 | 48 | 54 | 43 | 50 | 50 | 50 | 51 | **49,2 %** |
| Diplomate | 55 | 43 | 55 | 44 | 48 | 49 | 56 | 47 | 50 | 46 | **49,3 %** |
| Pugiliste | 43 | 53 | 54 | 53 | 53 | 57 | 49 | 48 | 55 | 50 | **51,5 %** |

### Les trois routes, l'usage des voies et la Tour, par classe

| Classe | Ruée | Éventail | Réactive | Voie 1 | Voie 2 | Voie 3 | Voie 4 | Voie 5 | Clé | Tour : étage 10 | étage 20 | étage moyen |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 44,7 % | 10,9 % | 49,1 % | 51,8 % | 69,5 % | 41,4 % | 83,9 % | 67,0 % | 96,8 % | 49,3 % | 7,2 % | 10,4 |
| Mage | 50,2 % | 19,1 % | 49,8 % | 26,2 % | 74,3 % | 43,9 % | 23,8 % | 35,2 % | 90,5 % | 46,2 % | 5,9 % | 10,3 |
| Voleur | 51,6 % | 24,9 % | 49,3 % | 45,8 % | 27,9 % | 66,9 % | 38,5 % | 48,6 % | 90,3 % | 46,4 % | 7,0 % | 10,0 |
| Archer | 53,2 % | 20,8 % | 50,5 % | 48,0 % | 39,7 % | 69,5 % | 25,8 % | 35,4 % | 88,4 % | 50,2 % | 6,7 % | 10,6 |
| Prêtre | 27,3 % | 8,3 % | 49,0 % | 51,8 % | 82,0 % | 32,8 % | 82,8 % | 76,1 % | 97,0 % | 51,1 % | 8,0 % | 10,5 |
| Alchimiste | 35,3 % | 10,0 % | 48,4 % | 53,8 % | 34,1 % | 66,5 % | 43,9 % | 68,6 % | 97,5 % | 45,4 % | 6,3 % | 10,3 |
| Invocateur | 47,3 % | 18,4 % | 50,4 % | 38,1 % | 41,7 % | 77,9 % | 42,1 % | 49,1 % | 91,3 % | 54,4 % | 10,1 % | 11,2 |
| Barde | 45,5 % | 14,2 % | 49,2 % | 50,7 % | 65,1 % | 61,5 % | 50,7 % | 48,5 % | 92,6 % | 49,6 % | 7,6 % | 10,6 |
| Diplomate | 27,7 % | 6,9 % | 49,3 % | 35,2 % | 59,1 % | 95,4 % | 49,0 % | 86,4 % | 97,2 % | 50,1 % | 10,8 % | 10,6 |
| Pugiliste | 19,5 % | 7,3 % | 51,5 % | 45,2 % | 55,3 % | 68,0 % | 88,2 % | 45,0 % | 96,6 % | 52,8 % | 9,3 % | 10,9 |

### Boutons touchés, et pourquoi

Aucun (mesure seule).

## La Tour retouchée après la vérification finale, puis remesurée sur des graines jamais vues (4 000 montées par classe)

La vérification finale à 20 tours tenait les critères 1 à 5 ; le critère 6 était manqué de peu (étage 10 de 45,4 % à 54,4 % selon la classe, étage 20 au-delà de 10 % pour l'Invocateur et le Diplomate). Le facteur des monstres de chaque classe a été corrigé deux fois d'après la mesure (une première correction, mesurée sur d'autres graines, allait trop loin pour le Mage et le Voleur), la pente de l'Invocateur et du Diplomate une fois. La Tour ne change rien aux duels : les critères 1 à 5 de la vérification finale restent valables.

**Critère 6 tenu** : étage 10 de 49,0 % à 53,6 %, étage 20 de 6,3 % à 9,8 %. Avec la vérification finale, **les six critères sont tenus**.

| Classe | Facteur des monstres | Pente | Étage 10 (vérification finale → maintenant) | Étage 20 | Étage moyen |
| --- | --- | --- | --- | --- | --- |
| Guerrier | 1,766 → 1,769 | 0,779 | 49,3 % → 50,7 % | 7,2 % → 6,3 % | 10,4 |
| Mage | 0,758 → 0,743 | 0,929 | 46,2 % → 52,2 % | 5,9 % → 7,8 % | 11,0 |
| Voleur | 0,970 → 0,951 | 0,426 | 46,4 % → 49,5 % | 7,0 % → 8,6 % | 10,6 |
| Archer | 0,695 → 0,698 | 1,257 | 50,2 % → 49,5 % | 6,7 % → 6,7 % | 10,7 |
| Prêtre | 1,101 → 1,118 | 0,816 | 51,1 % → 51,9 % | 8,0 % → 7,4 % | 10,5 |
| Alchimiste | 0,849 → 0,815 | 1,439 | 45,4 % → 50,8 % | 6,3 % → 8,7 % | 10,9 |
| Invocateur | 0,916 → 0,937 | 1,142 → 1,202 | 54,4 % → 49,0 % | 10,1 % → 8,0 % | 10,4 |
| Barde | 0,875 → 0,878 | 1,270 | 49,6 % → 49,4 % | 7,6 % → 7,2 % | 10,6 |
| Diplomate | 1,032 → 1,025 | 0,974 → 1,038 | 50,1 % → 50,3 % | 10,8 % → 9,8 % | 10,6 |
| Pugiliste | 0,970 → 0,986 | 1,008 | 52,8 % → 53,6 % | 9,3 % → 9,0 % | 11,0 |

## Premier trio contre trio (29 octobre, PR 1.1 du plan, sans réglage)

Le joueur et ses deux Échos générés contre un autre trio (`docs/GDD_V2.md`), avec les chiffres réglés pour le duo (PR #47) : 100 duels par case (10 000) et 300 montées par classe, au niveau 30, graines 5 000 à 7 299. Rien n'est réglé pour le trio : c'est la PR 1.5 du plan. À retenir : la longueur tient toute seule (médiane de 19 tours) ; les classes vont de 45 à 63 % (le Pugiliste et l'Archer trop forts, l'Invocateur trop faible) ; la Tour est bien trop facile à trois (presque tous les trios atteignent l'étage 10).

**2 critères tenus sur 6.** 10000 combats de duel (médiane 19 tours), 0 combats non finis.

### Les six critères (section 11.2)

- ❌ **1. Chaque classe entre 47 % et 53 % de victoires** : mage 53,1 %, archer 58,8 %, invocateur 45,3 %, diplomate 55,7 %, pugiliste 63,0 %
- ❌ **2. Aucune case de la matrice hors de 40 % – 60 %** : guerrier contre barde 62,0 %, voleur contre diplomate 39,0 %, archer contre voleur 62,0 %, archer contre archer 61,0 %, archer contre alchimiste 64,0 %, archer contre barde 61,0 %, pretre contre diplomate 37,0 %, alchimiste contre diplomate 34,0 %, invocateur contre archer 37,0 %, invocateur contre diplomate 30,0 %, barde contre mage 34,0 %, barde contre diplomate 37,0 %, diplomate contre voleur 64,0 %, diplomate contre invocateur 61,0 %, pugiliste contre guerrier 74,0 %, pugiliste contre mage 64,0 %, pugiliste contre voleur 67,0 %, pugiliste contre pretre 62,0 %, pugiliste contre alchimiste 65,0 %, pugiliste contre barde 71,0 %, pugiliste contre pugiliste 61,0 %
- ❌ **3. La route Réactive entre 40 % et 55 % (Ruée et Éventail : des repères, sans seuil)** : archer Réactive 58,8 %, diplomate Réactive 55,7 %, pugiliste Réactive 63,0 %
- ✅ **4. Chaque voie jouée dans 15 % des combats au moins, une Clé dans 60 %**
- ✅ **5. Longueur : médiane de 18 à 22 tours, 95 % finis avant le tour 30**
- ❌ **6. Tour : étage 10 dans 40 à 60 % des montées, étage 20 dans 5 à 10 %, à 5 points près entre classes** : guerrier étage 10 96,7 %, guerrier étage 20 75,0 %, mage étage 10 100,0 %, mage étage 20 96,7 %, voleur étage 10 99,7 %, voleur étage 20 93,7 %, archer étage 10 100,0 %, archer étage 20 97,7 %, pretre étage 10 100,0 %, pretre étage 20 96,3 %, alchimiste étage 10 99,7 %, alchimiste étage 20 89,0 %, invocateur étage 10 99,0 %, invocateur étage 20 91,7 %, barde étage 10 99,3 %, barde étage 20 91,0 %, diplomate étage 10 100,0 %, diplomate étage 20 94,0 %, pugiliste étage 10 100,0 %, pugiliste étage 20 96,3 %, écart entre classes : étage 10 de 96,7 % à 100,0 %, étage 20 de 75,0 % à 97,7 %

### La matrice des classes (taux de victoire de la ligne contre la colonne)

| | Guer | Mage | Vole | Arch | Prêt | Alch | Invo | Bard | Dipl | Pugi | **Moyenne** |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 49 | 44 | 55 | 48 | 49 | 53 | 53 | 62 | 43 | 50 | **50,6 %** |
| Mage | 55 | 45 | 54 | 50 | 55 | 58 | 52 | 57 | 52 | 53 | **53,1 %** |
| Voleur | 47 | 49 | 49 | 44 | 51 | 52 | 46 | 50 | 39 | 48 | **47,5 %** |
| Archer | 59 | 57 | 62 | 61 | 59 | 64 | 60 | 61 | 52 | 53 | **58,8 %** |
| Prêtre | 52 | 53 | 50 | 52 | 54 | 54 | 53 | 55 | 37 | 43 | **50,3 %** |
| Alchimiste | 48 | 45 | 53 | 50 | 49 | 49 | 50 | 53 | 34 | 54 | **48,5 %** |
| Invocateur | 47 | 40 | 52 | 37 | 47 | 51 | 46 | 53 | 30 | 50 | **45,3 %** |
| Barde | 51 | 34 | 56 | 49 | 55 | 44 | 52 | 53 | 37 | 50 | **48,1 %** |
| Diplomate | 56 | 55 | 64 | 54 | 53 | 55 | 61 | 56 | 49 | 54 | **55,7 %** |
| Pugiliste | 74 | 64 | 67 | 60 | 62 | 65 | 57 | 71 | 49 | 61 | **63,0 %** |

### Les trois routes, l'usage des voies et la Tour, par classe

| Classe | Ruée | Éventail | Réactive | Voie 1 | Voie 2 | Voie 3 | Voie 4 | Voie 5 | Clé | Tour : étage 10 | étage 20 | étage moyen |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 39,5 % | 18,0 % | 50,6 % | 43,8 % | 54,7 % | 38,1 % | 89,0 % | 67,1 % | 98,5 % | 96,7 % | 75,0 % | 19,4 |
| Mage | 59,0 % | 22,5 % | 53,1 % | 24,7 % | 58,4 % | 48,3 % | 47,1 % | 34,3 % | 90,7 % | 100,0 % | 96,7 % | 20,8 |
| Voleur | 44,5 % | 20,0 % | 47,5 % | 43,1 % | 23,9 % | 47,9 % | 47,2 % | 68,6 % | 89,7 % | 99,7 % | 93,7 % | 20,6 |
| Archer | 58,0 % | 23,5 % | 58,8 % | 41,4 % | 62,5 % | 51,4 % | 26,3 % | 46,7 % | 88,9 % | 100,0 % | 97,7 % | 20,9 |
| Prêtre | 38,0 % | 22,0 % | 50,3 % | 41,9 % | 64,2 % | 51,7 % | 83,3 % | 75,1 % | 97,3 % | 100,0 % | 96,3 % | 20,8 |
| Alchimiste | 57,0 % | 26,5 % | 48,5 % | 42,4 % | 27,2 % | 50,7 % | 51,0 % | 55,3 % | 96,1 % | 99,7 % | 89,0 % | 20,4 |
| Invocateur | 39,0 % | 21,5 % | 45,3 % | 36,3 % | 44,8 % | 66,2 % | 44,4 % | 50,4 % | 92,0 % | 99,0 % | 91,7 % | 20,6 |
| Barde | 49,0 % | 24,5 % | 48,1 % | 45,3 % | 45,7 % | 53,7 % | 37,2 % | 46,2 % | 95,7 % | 99,3 % | 91,0 % | 20,4 |
| Diplomate | 48,5 % | 23,5 % | 55,7 % | 35,9 % | 60,9 % | 91,8 % | 59,0 % | 61,7 % | 96,9 % | 100,0 % | 94,0 % | 20,7 |
| Pugiliste | 34,0 % | 16,0 % | 63,0 % | 30,3 % | 46,1 % | 62,4 % | 92,3 % | 46,0 % | 98,2 % | 100,0 % | 96,3 % | 20,8 |

### Boutons touchés, et pourquoi

Aucun (mesure seule).

## L'IA de bon sens (29 octobre, PR 1.2 du plan)

Les règles de bon sens (`engine/ia.gd`, `docs/JOURNAL-COMBAT-V2.md`) mesurées au simulateur : les erreurs de l'IA pour 100 actions de chaque rôle, avant (l'IA de la section 10 seule) → **après** ; puis les deux IA l'une contre l'autre. Graines neuves, niveau 30.

### En trio (le format visé : 6 000 duels par mesure d'erreurs, 20 000 pour l'affrontement des deux IA)

| Rôle | Coup perdu | Soin perdu | Barrière inutile | Clé gaspillée | Achèvement raté |
| --- | --- | --- | --- | --- | --- |
| Front | 3,9 → **2,9** | 0,6 → **0,2** | 6,1 → **3,3** | 4,5 → **2,7** | 2,7 → **1,4** |
| Dégâts | 3,8 → **3,1** | 0,7 → **0,4** | 4,9 → **1,9** | 3,3 → **2,3** | 2,1 → **0,8** |
| Soutien | 3,5 → **2,9** | 1,0 → **0,6** | 4,9 → **1,7** | 2,5 → **1,6** | 2,9 → **1,7** |

**L'IA de bon sens contre l'IA de la section 10** : 51,7 % de victoires sur 20000 duels de trios (200 graines : sur 20 graines seulement, on lisait de 48 à 56 %, chaque graine fixant les Destins de toutes les classes). Classes, sans réglage pour le trio : 40,8 % à 57,7 % avant, 39,3 % à 55,8 % après.

### En duo (le jeu publié)

| Rôle | Coup perdu | Soin perdu | Barrière inutile | Clé gaspillée | Achèvement raté |
| --- | --- | --- | --- | --- | --- |
| Front | 2,2 → **1,2** | 0,4 → **0,1** | 4,8 → **2,4** | 3,7 → **1,9** | 1,8 → **0,9** |
| Dégâts | 2,6 → **1,5** | 0,2 → **0,0** | 1,4 → **0,7** | 2,3 → **1,2** | 1,3 → **0,6** |
| Soutien | 1,9 → **1,0** | 0,7 → **0,4** | 3,5 → **1,4** | 1,7 → **0,9** | 2,0 → **0,9** |

**L'IA de bon sens contre l'IA de la section 10** : 56,2 % de victoires sur 6000 duels. Le duo publié avec la nouvelle IA (10 000 duels, 3 000 montées) : **1 critères tenus sur 6**, classes de 42,7 % à 51,2 %, médiane de 17 tours. **Le jeu publié, encore en duo, garde donc l'IA de la section 10 jusqu'à la PR 1.4** (le trio à l'écran), réglée de nouveau à la PR 1.5.

### Le duo publié avec l'IA de bon sens (le rapport complet)

**1 critères tenus sur 6.** 10000 combats de duel (médiane 17 tours), 0 combats non finis.

### Les six critères (section 11.2)

- ❌ **1. Chaque classe entre 47 % et 53 % de victoires** : voleur 45,4 %, archer 44,5 %, pretre 46,8 %, alchimiste 42,7 %, diplomate 45,0 %
- ❌ **2. Aucune case de la matrice hors de 40 % – 60 %** : guerrier contre archer 63,0 %, mage contre guerrier 33,0 %, mage contre mage 36,0 %, mage contre alchimiste 68,0 %, voleur contre guerrier 32,0 %, voleur contre mage 35,0 %, archer contre guerrier 23,0 %, archer contre mage 35,0 %, pretre contre mage 37,0 %, alchimiste contre mage 32,0 %, alchimiste contre voleur 33,0 %, alchimiste contre archer 24,0 %, alchimiste contre pugiliste 38,0 %, barde contre guerrier 39,0 %, barde contre mage 38,0 %, diplomate contre guerrier 37,0 %, diplomate contre mage 34,0 %, diplomate contre diplomate 37,0 %, pugiliste contre guerrier 26,0 %
- ✅ **3. La route Réactive entre 40 % et 55 % (Ruée et Éventail : des repères, sans seuil)**
- ❌ **4. Chaque voie jouée dans 15 % des combats au moins, une Clé dans 60 %** : mage voie 4 4,9 %, voleur voie 4 13,6 %, archer voie 5 8,9 %, pretre voie 3 11,5 %
- ❌ **5. Longueur : médiane de 18 à 22 tours, 95 % finis avant le tour 30** : médiane 17 tours
- ❌ **6. Tour : étage 10 dans 40 à 60 % des montées, étage 20 dans 5 à 10 %, à 5 points près entre classes** : guerrier étage 20 3,0 %, mage étage 10 35,0 %, mage étage 20 0,3 %, archer étage 10 26,7 %, archer étage 20 0,0 %, écart entre classes : étage 10 de 26,7 % à 58,3 %, étage 20 de 0,0 % à 9,3 %

### La matrice des classes (taux de victoire de la ligne contre la colonne)

| | Guer | Mage | Vole | Arch | Prêt | Alch | Invo | Bard | Dipl | Pugi | **Moyenne** |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 46 | 56 | 55 | 63 | 41 | 49 | 48 | 41 | 45 | 58 | **50,2 %** |
| Mage | 33 | 36 | 47 | 55 | 54 | 68 | 52 | 55 | 50 | 49 | **49,9 %** |
| Voleur | 32 | 35 | 51 | 44 | 51 | 59 | 49 | 46 | 40 | 47 | **45,4 %** |
| Archer | 23 | 35 | 52 | 44 | 46 | 60 | 45 | 51 | 45 | 44 | **44,5 %** |
| Prêtre | 50 | 37 | 49 | 48 | 48 | 41 | 52 | 48 | 42 | 53 | **46,8 %** |
| Alchimiste | 44 | 32 | 33 | 24 | 52 | 59 | 43 | 58 | 44 | 38 | **42,7 %** |
| Invocateur | 40 | 45 | 50 | 52 | 54 | 59 | 59 | 52 | 41 | 60 | **51,2 %** |
| Barde | 39 | 38 | 48 | 54 | 57 | 41 | 46 | 52 | 42 | 54 | **47,1 %** |
| Diplomate | 37 | 34 | 44 | 40 | 60 | 52 | 55 | 45 | 37 | 46 | **45,0 %** |
| Pugiliste | 26 | 42 | 59 | 54 | 50 | 55 | 51 | 41 | 51 | 46 | **47,5 %** |

### Les trois routes, l'usage des voies et la Tour, par classe

| Classe | Ruée | Éventail | Réactive | Voie 1 | Voie 2 | Voie 3 | Voie 4 | Voie 5 | Clé | Tour : étage 10 | étage 20 | étage moyen |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guerrier | 48,5 % | 17,5 % | 50,2 % | 56,9 % | 37,3 % | 47,3 % | 84,8 % | 72,9 % | 96,3 % | 51,7 % | 3,0 % | 10,4 |
| Mage | 55,0 % | 20,5 % | 49,9 % | 27,4 % | 74,0 % | 37,0 % | 4,9 % | 19,4 % | 85,0 % | 35,0 % | 0,3 % | 8,6 |
| Voleur | 47,5 % | 23,0 % | 45,4 % | 37,5 % | 34,6 % | 66,3 % | 13,6 % | 49,6 % | 87,4 % | 58,3 % | 7,3 % | 11,1 |
| Archer | 60,5 % | 19,0 % | 44,5 % | 35,1 % | 42,7 % | 65,6 % | 19,4 % | 8,9 % | 83,0 % | 26,7 % | 0,0 % | 8,2 |
| Prêtre | 22,0 % | 8,0 % | 46,8 % | 52,8 % | 80,5 % | 11,5 % | 82,6 % | 81,5 % | 95,2 % | 53,7 % | 8,0 % | 10,9 |
| Alchimiste | 33,0 % | 9,5 % | 42,7 % | 58,7 % | 28,4 % | 61,0 % | 36,1 % | 67,8 % | 96,3 % | 53,7 % | 9,0 % | 11,1 |
| Invocateur | 45,5 % | 18,5 % | 51,2 % | 36,3 % | 34,8 % | 69,9 % | 45,1 % | 39,5 % | 88,9 % | 48,7 % | 5,7 % | 10,2 |
| Barde | 44,0 % | 16,0 % | 47,1 % | 45,8 % | 64,2 % | 59,5 % | 47,0 % | 48,3 % | 90,7 % | 52,0 % | 6,7 % | 10,7 |
| Diplomate | 24,5 % | 6,0 % | 45,0 % | 33,2 % | 18,3 % | 91,8 % | 50,8 % | 91,6 % | 95,7 % | 50,7 % | 9,3 % | 10,5 |
| Pugiliste | 16,5 % | 5,5 % | 47,5 % | 40,6 % | 50,7 % | 62,7 % | 88,1 % | 40,5 % | 95,8 % | 46,3 % | 6,7 % | 10,2 |

### Les erreurs de l'IA (pour 100 actions de chaque rôle)

| Rôle | Actions | Coup perdu | Soin perdu | Barrière inutile | Clé gaspillée | Achèvement raté |
| --- | --- | --- | --- | --- | --- | --- |
| Front | 193099 | 1,2 | 0,1 | 2,4 | 1,9 | 0,9 |
| Dégâts | 172314 | 1,5 | 0,0 | 0,7 | 1,2 | 0,6 |
| Soutien | 172003 | 1,0 | 0,4 | 1,4 | 0,9 | 0,9 |

### Boutons touchés, et pourquoi

Aucun (mesure seule).
