# Combat V2 « l'Arbre vivant » : rapport final (étape 8)

Le 29 octobre 2026. Ce rapport clôt le plan de `docs/SPEC-COMBAT-V2.md` (section 15) : la matrice des classes, les trois routes, l'usage des voies, la longueur des combats, la Tour, puis la liste des choix du journal (`docs/JOURNAL-COMBAT-V2.md`). Le détail de chaque passe de réglage est dans `docs/EQUILIBRAGE-V2.md`.

**Depuis le 29 octobre après-midi (PR #47), les combats visent 20 tours** (demande de Gautier) : les chiffres de l'équilibrage ci-dessous sont ceux des combats de 10 tours ; ceux des combats de 20 tours (six critères tenus) sont en bas de `docs/EQUILIBRAGE-V2.md`.

## Ce qui existe

1. Les données des 10 classes et l'outil de budget (PR #34).
2. Le moteur de règles, phase par phase, avec son journal d'événements (PR #35).
3. Le générateur de Destin, les formes, l'allumage, les éclats, l'acolyte, et la roue à l'écran (PR #37).
4. L'IA à score, le bestiaire transposé et la Tour (PR #38).
5. Le simulateur, le régleur et le réglage (PR #39), puis une correction de l'IA trouvée en continuant le réglage (PR #42 : un combat sur 150 000 ne finissait pas).
6. L'écran de combat : une seule arène, les six cases, la bande de la voie, les menaces, les fiches (PR #40).
7. La résolution en cut-ins et l'écran de fin (PR #41).
8. L'export web : le combat V2 remplace l'ancien sur l'adresse de test (PR #43).

## L'équilibrage : vérification finale

Sur des combats jamais vus pendant le réglage : 300 000 duels (3 000 par case de la matrice, au niveau 30, l'IA des deux côtés) et 40 000 montées de la Tour (4 000 par classe). Médiane de 10 tours, aucun combat sans fin.

### Les six critères (section 11.2)

- ✅ **1. Chaque classe entre 47 % et 53 % de victoires**
- ❌ **2. Aucune case de la matrice hors de 40 % – 60 %** : pugiliste contre guerrier 39,9 %
- ✅ **3. La route Réactive entre 40 % et 55 % (Ruée et Éventail : des repères, sans seuil)**
- ✅ **4. Chaque voie jouée dans 15 % des combats au moins, une Clé dans 60 %**
- ✅ **5. Longueur : médiane de 6 à 10 tours, 95 % finis avant le tour 20**
- ✅ **6. Tour : étage 10 dans 40 à 60 % des montées, étage 20 dans 5 à 10 %, à 5 points près entre classes**

Le critère 2 est manqué d'une case : Pugiliste contre Guerrier à 39,9 % (un dixième de point sous la limite ; le bruit de mesure d'une case est d'environ 0,9 point). Sur d'autres graines, avant la correction de l'IA, c'était Alchimiste contre Guerrier à 61,1 % : deux ou trois duels tournent autour de 60 % (Guerrier contre Pugiliste, Alchimiste contre Guerrier, Alchimiste contre Prêtre), et aucun bouton n'a d'effet propre sur eux (essais des passes 55 et 56). Le régleur garde son état (`tools/regleur_etat.json`) pour reprendre.

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


## Les choix du journal

Chaque choix fait hors de la spécification, dans l'ordre (le détail et la raison de chacun sont dans `docs/JOURNAL-COMBAT-V2.md`). Ceux marqués « à valider » attendent Gautier.

- étape 1 — Les nouveaux fichiers de données ont les mêmes noms que les anciens (`data/rules.json`, `data/classes/`)
- étape 1 — Le texte de la grille dit « ×1,3 quel que soit l'effet » mais aussi « Purge duo = 100 » (50 × 1,3 = 65)
- étape 1 — Le coût se calcule-t-il avant ou après le multiplicateur de classe et le niveau ?
- étape 1 — Comment écrire « Affaiblissement −20 % » dans la donnée
- étape 1 — Nom affiché d'un état avec ses accents (« Enraciné »)
- étape 1 — Texte fixe de chaque état sur la fiche
- étape 1 — Étourdi est-il retiré par une Purge ? (oui en 2a, non dans la table 6)
- étape 1 — Genre des noms au pluriel (« Mille coupures », « Lianes », « Vapeurs curatives »)
- étape 1 — Nom complet d'une voie
- étape 1 — Ordre des classes à l'écran
- étape 1 — Test 4 : Familier et Gardien ne sont posés que par l'Invocateur (table 6)
- étape 1 — Phrases de la fiche (≤ 10 mots, sans chiffre)
- étape 1 — Où vérifier qu'un `budget_override` reste à ±10 % de son rang
- étape 1 — Comment livrer les étapes 2 à 7 sans casser le jeu publié (l'étape 2 supprime l'ancien moteur, l'écran de combat n'arrive qu'à l'étape 6)
- étape 2 — Le multiplicateur de classe `k` n'apparaît pas dans les formules de 2b à 2d
- étape 2 — Comment compter la durée d'un état et l'effet d'une seconde pose
- étape 2 — Un DoT déjà présent reçoit une valeur plus forte : quand tique-t-elle ?
- étape 2 — Un perso déjà Provoqué est provoqué par quelqu'un d'autre
- étape 2 — Aveuglé : seulement les dégâts, ou tous les effets sur un seul ennemi ?
- étape 2 — Ce que lit l'instantané de la phase 0
- étape 2 — Poison sur un Gardien qui tique (2f)
- étape 2 — Mort subite et DoT
- étape 2 — Une menace sur un nœud que le jalon a déjà dépassé (N3 avec un jalon à 3)
- étape 2 — Quand une menace est-elle barrée ?
- étape 2 — Double KO : « somme des PV en pourcentage de PV max »
- étape 2 — Synergies à la Tour et entre monstres
- étape 2 — Où ranger les chiffres des Synergies et des états (×1,25, +1 tour, ×1,3, ×0,5…)
- étape 2 — Que garde le journal d'événements ?
- étape 2 — Arrondi à l'inférieur et erreurs de virgule
- étape 2 — Une cible déclarée KO ou du mauvais camp ; une cible absente
- étape 2 — L'ancienne Tour (`engine/tower.gd`) dépendait de l'ancien moteur
- étape 3 — Les facteurs des formes (×1,43, ×1,38, ×0,65) ne sont pas exactement neutres en budget
- étape 3 — Une forme rend des états multi-cibles (ou mono) : leur coût change, pas leur valeur
- étape 3 — Une forme crée un effet du même type que l'un déjà là (Entaille persistante : un Saignement de plus sur la même cible)
- étape 3 — Le DoT d'une forme Persistante pour l'Archer
- étape 3 — Le paramètre « allumage » du générateur
- étape 3 — Les points de l'acolyte avant le niveau 10
- étape 3 — La graine d'un nouveau perso
- étape 3 — Les profils gardés sur le téléphone avant le combat V2
- étape 3 — L'onglet « Compétences » de la barre du bas
- étape 3 — L'écran de la roue : toucher ou appui long ?
- étape 3 — Le texte d'un éclat
- étape 3 — Les pictogrammes
- étape 3 — Phrases de 10 mots au plus
- étape 3 — Ligne chiffrée d'un soin et d'une barrière
- étape 3 — Le combat et la Tour pendant les étapes 3 à 5
- étape 3 — Tester le combat V2 sur téléphone avant l'étape 8
- étape 4 — Transposition des 14 monstres (section 10.4)
- étape 4 — Règles d'étage de l'ancienne Tour gardées
- étape 4 — Règles d'étage de l'ancienne Tour retirées
- étape 4 — Un étage d'un seul monstre est-il possible ?
- étape 4 — Le sommet de la Tour
- étape 4 — Le joueur KO entre deux étages
- étape 4 — Les roues des monstres
- étape 4 — IA : où compter Provoqué ?
- étape 4 — IA : une menace d'échéance 1 déjà barrée
- étape 4 — IA : valeur d'une barrière quand l'allié en a déjà une
- étape 4 — IA : « une action de soin, barrière ou renfort de valeur effective < 10 » est retirée
- étape 4 — IA : « dégâts potentiels » pour une barrière
- étape 4 — IA : un état déjà posé sur la cible
- étape 4 — IA : qui voit quoi au moment de choisir
- étape 4 — Caractères que la police du jeu n'a pas sur le web (« → », « ○ », le signe moins « − »)
- étape 5 — **Décision de Gautier** — durée des combats
- étape 5 — **Décision de Gautier** — route Éventail
- étape 5 — **Décision de Gautier** — difficulté de la Tour
- étape 5 — Le score de l'IA au niveau 30
- étape 5 — Le Gardien d'un étage multiple de 5 quand la Tour est encore faible
- étape 5 — La route Ruée (« la voie dont la Clé a le plus gros budget restant »)
- étape 5 — La route Éventail (« N1 puis N2 de chaque voie à tour de rôle »)
- étape 5 — Mesure de l'usage (critère 4)
- étape 5 — Graines de la matrice
- étape 5 — **Décision de Gautier** — routes Ruée et Éventail
- étape 5 — La difficulté de la Tour classe par classe
- étape 5 — Les duels de la matrice hors de 40 – 60 %
- étape 5 — Une voie peu jouée qui commence par un état seul (Fumées de l'Alchimiste)
- étape 5 — Le pas de `k_classe` quand l'acolyte est fixe
- étape 5 — Un nœud qui ne pose qu'un état quand le coût de cet état change (bouton 3)
- étape 5 — La taille des mesures
- étape 5 — **À valider par Gautier** — les PV au-delà de −40 %
- étape 5 — **Décision de Claude Code, à valider par Gautier** — l'étape 5 avec 5 critères sur 6
- étape 5 — Les DoT dans le score de l'IA pendant la mort subite
- étape 6 — Les sprites vus de dos
- étape 6 — Les tailles des persos sur un écran de 540 de large (la maquette : 390)
- étape 6 — L'ordre des six cases
- étape 6 — Quand part le tour, contre l'IA
- étape 6 — La ligne d'aide sous les cases
- étape 6 — La fiche d'un nœud que le jalon a déjà dépassé
- étape 7 — La couleur des dégâts dans la résolution
- étape 7 — La fin d'un combat
