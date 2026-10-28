# Projet Arena — Spécification du combat V2 : « l'Arbre vivant »

**Statut : spécification de référence, validée par Gautier le 28 octobre 2026.** Elle **remplace** la section « Combat » du GDD (compétences à recharge, 3 actives + 1 passif, vitesse) et les sections de `CLAUDE.md` qui en découlent. En cas de contradiction entre ce document et le GDD, `CLAUDE.md` ou le code existant, **ce document fait foi**.

**À qui il s'adresse.** À Claude Code (Opus), qui doit l'implémenter **sans rien inventer**. Tout ce qui est décidé est écrit ici : règles, chiffres, ordre de résolution, données, interface, tests, critères d'équilibrage et plan de travail. Quand un point n'est pas couvert, la règle est : **prendre l'option la plus simple qui ne change aucune règle écrite ici, et la noter dans `docs/JOURNAL-COMBAT-V2.md`** (une ligne par choix, en français courant). Ne jamais ajouter de mécanique, de statistique, de hasard ou d'état qui ne figure pas ici.

**Ce qui est conservé du code actuel.** L'infrastructure : projet Godot 4.5, CI, export web, outils de simulation (`tools/`), la Tour (étages, menaces d'étage, classement), l'écran du Destin, le matchmaking et les Échos, les écrans hors combat. **Ce qui est remplacé** : le moteur de règles du combat (`engine/combat*.gd`), l'IA de combat, les données `skills.json`, `passives.json`, `synergies.json`, `statuses.json`, `destin_nodes.json`, `destins.json`, la créature de l'Invocateur, l'écran de combat et l'écran de résolution. Les anciens tests du moteur sont remplacés par ceux de la section 14. Le bestiaire de la Tour est réécrit avec le nouveau système (section 10.4).

---

## 1. Le combat en douze lignes

1. Deux duos (joueur + acolyte IA contre joueur + acolyte IA, ou contre les ennemis de la Tour). Tours **simultanés** : chacun choisit une action, puis tout se résout en même temps.
2. Chaque personnage a un **Destin** : une roue. Au centre, le **moyeu** (son action basique, toujours disponible). Autour, **5 voies** de 4 nœuds chacune : nœud 1 (ouverture), 2, 3 (préparations), 4 = la **Clé** (le gros coup).
3. **Jouer, c'est faire un pas sur la roue** : une action par tour = un nœud. Le nœud joué est **éteint** pendant 3 tours.
4. Chaque voie garde un **jalon** : le dernier nœud joué sur cette voie. Le prochain nœud jouable d'une voie est celui qui suit son jalon.
5. Jouer la Clé **remet la voie à zéro**.
6. Un jalon **refroidit** : une voie qu'on ne joue pas pendant 2 tours recule d'un nœud.
7. Les jalons, les nœuds éteints et les états sont **visibles des deux camps**. Une Clé à un tour d'être jouée se voit : c'est une **menace**, et on peut y répondre (barrière, silence, égarement, étourdissement).
8. **Aucun hasard** en combat. Le seul hasard est la génération du Destin à la création du personnage.
9. Les **états** (Étourdi, Gelé, Silencié, Enraciné, Aveuglé, Désarmé, Provoqué, Égaré, Saignement, Brûlure, Poison, Familier, Gardien, Barrière, Renfort, Affaiblissement) sont déterministes, durent un nombre fixe de tours, s'appliquent **à partir du tour suivant** (sauf Égaré, immédiat).
10. **L'acolyte** choisit en premier et son choix est affiché ; il ne reçoit aucun ordre. Ennemis de la Tour et Échos jouent avec la **même IA déterministe**.
11. Toutes les valeurs d'un nœud découlent d'un **budget** (section 7). C'est ce budget, puis le simulateur, qui garantissent qu'aucune classe ni aucune voie ne domine.
12. Pas de mana, pas de recharge classique, pas de vitesse, pas de pierre-feuille-ciseaux, pas de timing, pas de Tempo, pas de Garde/Brèche, pas de posture. Ne pas les réintroduire.

---

## 2. Vocabulaire (à utiliser tel quel dans le code, les données, l'interface et le journal)

| Terme | Définition |
| --- | --- |
| **Destin** | La roue complète d'un personnage : moyeu + 5 voies × (4 nœuds actifs + 5 éclats) = 45 nœuds, plus le moyeu (non compté). |
| **Moyeu** | L'action basique de la classe. Toujours jouable, jamais éteinte, ne touche aucun jalon. |
| **Voie** | Un rayon de la roue : 4 nœuds actifs en ligne (N1 → N2 → N3 → Clé) et 5 éclats accrochés. |
| **Nœud (actif)** | Une action jouable. Rang 1 à 4. Le rang 4 est la **Clé**. |
| **Éclat** | Nœud passif accroché à un nœud actif : petit bonus permanent, hors combat. |
| **Allumé / éteint (hors combat)** | Un nœud dans lequel le joueur a mis un point est *allumé* ; seuls les nœuds allumés existent en combat. |
| **Éteint (en combat)** | Un nœud joué au tour T ne peut pas être rejoué aux tours T+1, T+2, T+3 ; il redevient jouable au tour T+4. Ne pas confondre avec « non allumé » : dans le code, utiliser `lit` (allumé hors combat) et `spent_until` (tour de retour en combat). |
| **Jalon** | Par voie, entier de 0 à 3 : rang du dernier nœud joué sur cette voie. 0 = rien d'engagé. |
| **Prochain nœud** | Pour une voie de jalon j : le nœud de rang j+1, s'il est allumé. |
| **Échéance** | Pour un nœud de rang k sur une voie de jalon j : `max(k − j, tours avant la fin de son extinction)`. 1 = jouable au prochain tour. **Le mot « pas » n'existe plus** : ni dans les règles, ni à l'écran. |
| **Refroidissement** | Mécanisme qui fait reculer un jalon d'un rang après 2 tours sans jouer la voie. |
| **Menace** | Nœud ennemi de rang 3 ou 4 dont l'échéance est ≤ 2. Affiché sous l'ennemi. |
| **Fiche** | Description complète d'un nœud (appui long) ou d'un personnage (appui long sur lui). |
| **Cible** | `un_ennemi`, `tous_les_ennemis`, `soi`, `un_allie` (soi ou l'autre), `duo` (les deux alliés). |
| **Duo** | Les deux personnages d'un camp. |
| **KO** | PV à 0. Le personnage ne joue plus ; il reste ciblable par rien. |

---

## 3. Structure du Destin et allumage

### 3.1 Le joueur

- 5 voies **fixes par classe** (section 9) : tout Guerrier a les mêmes 5 voies, dans le même ordre. Ce qui rend chaque Destin unique, ce sont les **variantes** de ses nœuds (section 4) et ses éclats allumés.
- Chaque voie : 4 nœuds actifs (N1, N2, N3, Clé) + 5 éclats : É1 et É2 accrochés à N1, É3 à N2, É4 à N3, É5 à la Clé.
- **À la création** : le moyeu et les 5 nœuds N1 sont allumés gratuitement.
- **Un point par niveau**, niveaux 1 à 30 → 30 points à placer parmi les 40 nœuds restants (15 actifs + 25 éclats). Le joueur clique le nœud dans l'écran du Destin ; **irréversible**.
- **Règle d'allumage** : un nœud actif de rang k s'allume seulement si le rang k−1 de la même voie est allumé. Un éclat s'allume seulement si le nœud actif auquel il est accroché est allumé.
- Un nœud actif non allumé n'existe pas en combat : la voie s'arrête au dernier nœud allumé (une voie dont la Clé n'est pas allumée n'a pas de Clé ; jouer son N3 laisse le jalon à 3, et le refroidissement le fera redescendre).
- **Éclats** (bonus permanents, appliqués à la création de l'état de combat) : É1 : +5 % sur toutes les valeurs numériques des nœuds de la voie · É2 : +3 % PV max · É3 : +5 % valeurs de la voie · É4 : +3 % PV max · É5 : +10 % valeurs de la Clé de la voie. Les pourcentages d'une même voie s'additionnent (É1 + É3 = +10 %). Les « valeurs numériques » sont les dégâts, soins, barrières, DoT/HoT, pourcentages de Renfort/Affaiblissement ; jamais les durées.
- **Allumage par défaut** (IA, Échos sans historique, simulateur, personnages de test) : à chaque niveau, allumer dans l'ordre : N2 de chaque voie (voies 1 à 5), puis N3 de chaque voie, puis Clé de chaque voie, puis É1 de chaque voie, puis É3, puis É2. Au niveau 30 : 15 actifs + É1, É3, É2 de chaque voie.

### 3.2 L'acolyte

- Même classe-système que le joueur, **3 voies** seulement (les 3 premières voies de sa classe dans la section 9, marquées « acolyte »), toutes entièrement allumées quel que soit le niveau à partir du niveau 10 ; avant, il suit l'allumage par défaut avec `niveau` points (N2 des 3 voies, puis N3, puis Clés, puis É1, É3).
- 15 nœuds : moyeu + 12 actifs + É1 et É3 de sa première voie. Le joueur ne choisit rien.
- Classe de l'acolyte, fixe, selon la classe du joueur : Guerrier → Prêtre · Pugiliste → Barde · Mage → Guerrier · Voleur → Pugiliste · Archer → Guerrier · Invocateur → Pugiliste · Prêtre → Mage · Alchimiste → Voleur · Barde → Archer · Diplomate → Invocateur. (Rôles : Front = Guerrier, Pugiliste ; Dégâts = Mage, Voleur, Archer, Invocateur ; Soutien = Prêtre, Alchimiste, Barde, Diplomate. Front → Soutien, Dégâts → Front, Soutien → Dégâts.)

### 3.3 Niveau et échelle

- Tous les PV et toutes les valeurs numériques des nœuds (dégâts, soins, barrières, DoT, HoT) sont multipliés par `M(niveau) = 1 + 0,05 × (niveau − 1)`. Les pourcentages et les durées ne sont pas multipliés.
- Les chiffres de la section 9 sont les valeurs au niveau 1 (M = 1). En PvP les deux duos ont le même niveau ; à la Tour les ennemis prennent le niveau du joueur. Le niveau ne crée donc aucun déséquilibre, il ne sert qu'à faire grossir les chiffres.
- Arrondi : toutes les valeurs finales sont des entiers, arrondis à l'inférieur (`floor`) **après** application de tous les multiplicateurs.

---

## 4. Génération du Destin (le seul hasard du jeu)

- Entrée : `classe`, `graine` (entier 64 bits tiré à la création, stocké). Sortie déterministe : pour chacun des 20 nœuds actifs, une **forme**.
- Formes possibles d'un nœud (toutes **neutres en budget** : les valeurs sont recalculées par la grille de coûts de la section 7, pas copiées) :
  - **Base** : le nœud tel qu'écrit en section 9.
  - **Diffuse** : chaque effet `un_ennemi` devient `tous_les_ennemis`, chaque effet `un_allie` ou `soi` devient `duo` ; valeurs divisées par 1,3. S'applique seulement si le nœud a au moins un effet mono-cible.
  - **Concentrée** : chaque effet `tous_les_ennemis` devient `un_ennemi`, chaque `duo` devient `un_allie` ; valeurs multipliées par 1,3. S'applique seulement si le nœud a au moins un effet multi-cible.
  - **Persistante** : chaque effet de dégâts directs devient un DoT de même valeur totale × 1,43 sur 3 tours (type : Saignement pour Guerrier/Voleur/Pugiliste/Diplomate/Archer-Précision, Brûlure pour Mage/Archer, Poison pour Alchimiste, Familier pour Invocateur, Saignement pour Prêtre/Barde) ; chaque soin direct devient un Gardien de valeur totale × 1,38 sur 3 tours. S'applique seulement si le nœud a des dégâts directs ou un soin direct.
  - **Vive** : chaque DoT devient des dégâts directs de valeur `total × 0,7` ; chaque Gardien devient un soin direct `total × 0,65`. S'applique seulement si le nœud a un DoT ou un Gardien.
- Pour chaque nœud, le générateur dresse la liste des formes applicables (Base toujours incluse) et en tire une **uniformément** avec le générateur pseudo-aléatoire initialisé par `graine` + index du nœud. Un nœud sans forme applicable autre que Base reste Base.
- Les états (Étourdi, etc.), Purge, Dissipe, Égaré ne changent jamais de forme ; seule leur cible peut passer de mono à multi via Diffuse/Concentrée, avec le coût multi ×1,3.
- Le nom affiché prend un suffixe : « Boule de feu diffuse », « Prière persistante », « Nuée corrosive concentrée », « Acide vif ». Le texte et les pictogrammes de la fiche se recalculent depuis les données (section 12.6).
- **Interdit** : toute autre source d'unicité (stats aléatoires, ordre de voies aléatoire, nœuds aléatoires).
- L'acolyte est généré avec la même fonction (graine dérivée : `graine_joueur XOR 0x5A5A5A5A`).
- **Test de validité** d'un Destin généré : chaque nœud a un coût dans ±6 % de son budget (section 7.4). Sinon, bug du générateur, pas du tirage.

---

## 5. Règles de combat — le tour, phase par phase

Un combat oppose le camp A (joueur + acolyte) au camp B (joueur ou Écho + acolyte, ou 1 à 4 ennemis de la Tour). Un **tour** se déroule ainsi. **L'ordre ci-dessous est impératif** et doit être reproduit à l'identique par le serveur, le client, l'IA et le simulateur.

### 5.1 Phase 0 — Début de tour

1. `tour += 1` (le premier tour est le tour 1).
2. Pour chaque personnage vivant, calcul de **la liste de ses actions légales** (section 5.2). Cette liste est figée pour le tour ; le client ne propose que celles-ci.
3. Calcul des **menaces** de chaque personnage (section 12.3), figées pour le tour.

### 5.2 Actions légales d'un personnage

Toujours : le **moyeu**.
Pour chaque voie v de jalon j : le nœud de rang j+1 s'il est allumé, pas éteint (`spent_until ≤ tour`), et si les états le permettent :
- **Étourdi** : aucune action (pas même le moyeu). Le personnage saute le tour.
- **Gelé** : seulement le moyeu.
- **Silencié** : aucune Clé.
- **Enraciné** : seulement le moyeu et le prochain nœud de la voie de **sa dernière action non-moyeu** (`last_voie`). Si `last_voie` est vide (début de combat ou après une Clé), Enraciné n'interdit rien.
- **Aveuglé** : les nœuds restent légaux mais leurs effets de cible `un_ennemi` ne font rien (section 5.4). Le client l'indique (nœud barré d'un œil).
- **Désarmé, Provoqué, Égaré, Renfort, Affaiblissement, DoT, Barrière, Gardien** : ne retirent aucune action.

Choix de cible : pour un nœud dont au moins un effet est `un_ennemi`, la cible est `cible_ennemie` du personnage (sélectionnée en touchant un ennemi ; par défaut l'ennemi vivant qui a le moins de PV en pourcentage ; en cas d'égalité, le joueur adverse avant son acolyte, ou le premier de la liste à la Tour). Pour `un_allie` : `cible_alliee` (par défaut l'allié vivant, soi compris, qui a le moins de PV en pourcentage). **Provoqué** force `cible_ennemie` = le provocateur s'il est vivant. Une cible KO au moment du choix est illégale ; si la cible choisie meurt avant la résolution (impossible en simultané : les KO sont constatés en fin de tour), rien à gérer.

### 5.3 Phase 1 — Déclaration

1. Les **acolytes** des deux camps choisissent (IA, section 10) et leur choix est visible de tous.
2. Les **joueurs** choisissent, sans voir le choix du joueur adverse. Délai : **20 secondes** en PvP ; à la Tour, pas de limite. Sans choix à la fin du délai : le **moyeu** (ou rien si Étourdi).
3. Les ennemis de la Tour et les Échos choisissent avec l'IA (section 10), **sans** voir les choix des joueurs humains du tour (ils voient tout l'état du début de tour, dont les acolytes).
4. Validation : toute action illégale (uniquement possible par bug ou triche) est remplacée par le moyeu.

### 5.4 Phase 2 — Résolution simultanée

Toutes les actions se calculent sur **l'instantané de l'état en fin de phase 0** (PV, états, barrières, Renfort, Affaiblissement de chacun). L'ordre d'application ci-dessous ne change aucun calcul de montant, seulement l'ordre des écritures ; il est fixé pour que les résultats soient reproductibles et pour l'ordre d'affichage.

Ordre des personnages pour l'application : joueur A, acolyte A, joueur B (ou ennemi 1), acolyte B (ou ennemis 2, 3, 4). Pour chaque personnage, ses effets dans l'ordre où ils sont écrits dans la donnée du nœud.

**Étape 2a — Dissipe et Purge.** `dissipe` retire du **ciblé ennemi** : Barrière, Renfort, Gardien. `purge` retire de l'allié ciblé : Étourdi (déjà consommé de toute façon), Gelé, Silencié, Enraciné, Aveuglé, Désarmé, Provoqué, Affaiblissement, Saignement, Brûlure, Poison, Familier. Appliqués avant tout le reste (une barrière dissipée ce tour ne protège pas ce tour).

**Étape 2b — Dégâts directs.** Pour chaque effet `degats` :
`montant = floor(valeur × M(niveau) × bonus_eclats × (1 + renfort_attaquant − affaiblissement_attaquant) × (0,5 si attaquant Désarmé) )`.
`renfort_attaquant` et `affaiblissement_attaquant` sont ceux **actifs au début du tour** (0 sinon). Un attaquant **Aveuglé** inflige 0 à une cible `un_ennemi` (l'effet est consommé, le nœud quand même joué) ; `tous_les_ennemis` n'est pas affecté. La **Barrière** du défenseur absorbe en premier (`absorbé = min(barrière, montant)` ; la barrière diminue d'autant) ; le reste va aux PV. Les PV peuvent passer sous 0 (on tronque à 0 en 2i). Le même nœud de dégâts sur `tous_les_ennemis` calcule le montant une fois et l'applique à chaque ennemi vivant.

**Étape 2c — Soins directs.** `montant = floor(valeur × M × bonus_eclats × (1 + renfort_soigneur − affaiblissement_soigneur))`, puis **×0,5 si la cible est Poison** (arrondi à l'inférieur). PV plafonnés à PV max. Un soin sur un personnage à PV ≤ 0 à cet instant **le sauve** (les KO ne sont constatés qu'en 2i).

**Étape 2d — Barrières nouvelles.** `montant = floor(valeur × M × bonus_eclats × (1 + renfort − affaiblissement du poseur))`, puis **×0,5 si la cible est Brûlure**. La Barrière **ne se cumule pas** : la nouvelle remplace l'ancienne si elle est plus grande, sinon rien. Durée : 2 tours (expire au début de la phase 2g du 2e tour suivant ; concrètement `barrier_until = tour + 2`, et à l'étape 2g, si `tour ≥ barrier_until`, barrière = 0).

**Étape 2e — États nouveaux.** Pour chaque effet d'état (Étourdi, Gelé, Silencié, Enraciné, Aveuglé, Désarmé, Provoqué, Renfort, Affaiblissement, Saignement, Brûlure, Poison, Familier, Gardien) : l'état est posé avec `tours_restants = durée` et devient **actif au tour suivant**. Si l'état est déjà présent : **la durée la plus longue est gardée, la valeur la plus forte est gardée** (pour DoT/HoT/Renfort/Affaiblissement) ; jamais de cumul, jamais deux instances. Provoqué enregistre le provocateur. **Égaré** s'applique immédiatement : tous les jalons de la cible reculent d'un rang (minimum 0) ; les nœuds éteints le restent ; `last_voie` inchangé ; les compteurs d'inactivité sont remis à 0.

**Étape 2f — Ticks.** Pour chaque personnage vivant, pour chaque DoT **posé avant ce tour** (pas ceux posés en 2e) : dégâts = `valeur_par_tour` (déjà calculée au moment de la pose, avec M, éclats et Renfort/Affaiblissement du poseur, arrondie) ; Saignement **ignore la Barrière** ; Brûlure, Poison et Familier passent par la Barrière comme des dégâts directs. Puis chaque Gardien posé avant ce tour soigne `valeur_par_tour` (×0,5 si Poison). Ordre : DoT dans l'ordre Saignement, Brûlure, Poison, Familier, puis Gardien.

**Étape 2g — Durées.** Pour chaque état posé **avant ce tour** : `tours_restants −= 1` ; à 0, l'état disparaît. Barrière : expire si `tour ≥ barrier_until`. Étourdi et Gelé posés en 2e de ce tour ont donc effet au tour suivant exactement, et disparaissent à la fin de ce tour suivant.

**Étape 2h — Jalons et extinction.** Pour chaque personnage qui a joué un nœud de voie v, rang k :
- `spent_until[nœud] = tour + 4` (rejouable à partir du tour `tour + 4`, donc éteint 3 tours pleins).
- Si k < 4 : `jalon[v] = k`. Si k = 4 (Clé) : `jalon[v] = 0`.
- `last_voie = v` (vidé si Clé).
- `inactivite[v] = 0` ; pour toute autre voie w : `inactivite[w] += 1`.
- Si le personnage a joué le moyeu, ou n'a rien joué (Étourdi) : `inactivite[w] += 1` pour toutes ses voies.
- Refroidissement : pour toute voie w avec `inactivite[w] ≥ 2` : `jalon[w] = max(0, jalon[w] − 1)`, `inactivite[w] = 0`.

**Étape 2i — KO et fin de combat.** Tout personnage à PV ≤ 0 est KO (PV = 0, tous ses états retirés, ses jalons figés). Puis :
- Un camp dont tous les membres sont KO perd. Si les deux camps sont KO au même tour : **gagne le camp dont la somme des PV en début de tour était la plus élevée en pourcentage de PV max** ; égalité parfaite → le camp A (joueur local, ou camp 1 côté serveur) gagne. Aucun match nul.
- Un acolyte KO ne revient pas ; le joueur continue seul. Idem pour le joueur KO : l'acolyte continue seul.

### 5.5 Mort subite

À partir du **tour 12**, tous les dégâts directs et DoT sont multipliés par `1 + 0,15 × (tour − 11)` (tour 12 : ×1,15 ; tour 13 : ×1,30 ; …). Soins et barrières ne sont pas multipliés. Pas de mort subite à la Tour. Le tour de départ (`12`) et le pas (`0,15`) sont dans `data/rules.json` et réglables par le simulateur (section 11).

### 5.6 La Tour

- Un étage = 1 à 4 ennemis (section 10.4), au niveau du joueur, contre le duo. Même moteur, mêmes phases ; le camp B n'a pas de « joueur » : l'ordre d'application est ennemi 1, 2, 3, 4.
- Entre deux étages : +20 % des PV max rendus à chaque membre du duo vivant ; un acolyte KO revient au début de l'étage suivant avec 20 % de ses PV ; jalons remis à 0, extinctions levées, états retirés.
- Les règles d'étage (« menaces d'étage ») existantes sont conservées **si elles ne contredisent pas ce document** ; celles qui touchaient aux recharges ou aux postures sont supprimées et remplacées par des équivalents sur ce système (ex. « à cet étage, l'extinction dure 4 tours », « les Clés coûtent un tour de plus », « les jalons ne refroidissent pas »). Les lister dans le journal.

---

## 6. Les états

Toutes les durées se comptent en tours pleins après le tour de pose. « 1 tour » = l'état est actif pendant exactement le tour qui suit la pose.

| État | Type | Effet exact | Durée type | Posé par (classes) | Retiré par |
| --- | --- | --- | --- | --- | --- |
| Étourdi | Contrôle | Aucune action possible au tour suivant. | 1 | Mage, Voleur, Archer, Alchimiste, Invocateur, Barde, Diplomate, Pugiliste | Expiration (une Purge arrive trop tard : l'action est déjà perdue en phase 0) |
| Gelé | Contrôle | Seul le moyeu est jouable. | 1 | Guerrier, Mage, Voleur, Alchimiste, Invocateur, Barde | Expiration, Purge |
| Silencié | Contrôle | Aucune Clé jouable. | 1–2 | Mage, Prêtre, Barde, Diplomate, Pugiliste | Expiration, Purge |
| Enraciné | Contrôle | Ne peut jouer que le moyeu ou continuer la voie de sa dernière action (`last_voie`). | 1–2 | Guerrier, Mage, Voleur, Archer, Invocateur, Pugiliste | Expiration, Purge |
| Aveuglé | Contrôle | Ses effets de cible `un_ennemi` ne font rien. | 1 | Voleur, Archer, Alchimiste | Expiration, Purge |
| Désarmé | Affaiblissement | Ses dégâts directs ×0,5. | 1 | Guerrier, Voleur, Alchimiste, Barde, Diplomate, Pugiliste | Expiration, Purge |
| Provoqué | Contrôle | Ses effets `un_ennemi` ne peuvent viser que le provocateur. | 1 | Guerrier, Diplomate, Pugiliste | Expiration, Purge, KO du provocateur |
| Égaré | Déplacement | **Immédiat** : tous ses jalons reculent d'un rang. | — | Mage, Voleur, Alchimiste, Barde, Diplomate, Pugiliste | — |
| Saignement | DoT | `v` dégâts par tour, **ignore la Barrière**. | 3–4 | Guerrier, Voleur, Invocateur | Expiration, Purge |
| Brûlure | DoT | `v` dégâts par tour ; les Barrières reçues sont ×0,5. | 3–5 | Mage, Archer | Expiration, Purge |
| Poison | DoT | `v` dégâts par tour ; les soins reçus sont ×0,5. | 4–5 | Voleur, Alchimiste | Expiration, Purge |
| Familier | DoT | `v` dégâts par tour (créature invoquée, rien de plus). | 4–5 | Invocateur | Expiration, Purge |
| Gardien | HoT | `v` soins par tour sur l'allié. | 4–5 | Invocateur | Expiration, Dissipe |
| Barrière | Protection | Absorbe `v` dégâts (sauf Saignement). Ne se cumule pas. | 2 | Guerrier, Mage, Voleur, Archer, Prêtre, Alchimiste, Invocateur, Diplomate, Pugiliste | Épuisement, expiration, Dissipe |
| Renfort | Renfort | +x % aux dégâts, soins et barrières qu'il produit. | 2 | Guerrier, Mage, Archer, Prêtre, Alchimiste, Invocateur, Barde, Diplomate, Pugiliste | Expiration, Dissipe |
| Affaiblissement | Affaiblissement | −x % aux dégâts, soins et barrières qu'il produit. | 2 | Archer, Prêtre, Alchimiste, Barde, Diplomate | Expiration, Purge |

Règle de conception respectée : chaque état est posé par au moins 2 classes et retiré par au moins 2 moyens dont un Soutien (Purge : Prêtre, Alchimiste, Barde, Diplomate ; Dissipe : Voleur, Prêtre, Barde, Diplomate).

Effets instantanés qui ne sont pas des états : **Purge** retire d'un **allié** tous ses états négatifs (Gelé, Silencié, Enraciné, Aveuglé, Désarmé, Provoqué, Affaiblissement, Saignement, Brûlure, Poison, Familier) ; **Dissipe** retire d'un **ennemi** tous ses états positifs (Barrière, Renfort, Gardien). Règle simple à retenir : Purge = les mauvais états d'un allié ; Dissipe = les bons états d'un ennemi. Le champ `negatif` de `data/etats.json` décide de quel côté tombe chaque état.

---

## 7. Effets, coûts et budgets

### 7.1 Les effets (et leurs pictogrammes, section 12.1)

| Effet | Paramètres | Pictogramme / couleur |
| --- | --- | --- |
| `degats` | valeur, cible | épée · or `#e3b85f` |
| `soin` | valeur, cible | cœur · teal `#5cc8b8` |
| `barriere` | valeur, cible | bouclier · teal clair `#9bd3ca` |
| `dot` | type (saignement/brulure/poison/familier), par_tour, tours, cible | flamme/goutte/fiole/patte · rouge `#d35b5b` |
| `gardien` | par_tour, tours, cible | patte+cœur · teal |
| `etat` | nom (etourdi/gele/silencie/enracine/aveugle/desarme/provoque), tours, cible | chaînes/flocon/bâillon/racine/œil barré/épée brisée/bouclier pointé · violet `#c9a0ff` |
| `egare` | cible | flèche en arrière · violet |
| `renfort` | pourcent, tours (2), cible | étoile · or |
| `affaiblissement` | pourcent, tours (2), cible | étoile fendue · orange `#e08a4f` |
| `purge` | cible (allié) | rayon · teal |
| `dissipe` | cible (ennemi) | rayon barré · orange |

### 7.2 Grille des coûts (budget par unité, cible unique)

| Effet | Coût |
| --- | --- |
| Dégâts | 1,0 par point |
| Soin | 0,9 par point |
| Barrière (2 tours) | 0,7 par point |
| DoT (tous types), sur le **total** `par_tour × tours` | 0,7 par point |
| Gardien, sur le total | 0,65 par point |
| Renfort (2 tours) | 2,0 par % |
| Affaiblissement (2 tours) | 2,0 par % |
| Étourdi | 120 par tour |
| Gelé | 80 par tour |
| Aveuglé | 70 par tour |
| Désarmé | 60 par tour |
| Égaré | 60 |
| Silencié | 45 par tour |
| Provoqué | 40 par tour |
| Enraciné | 35 par tour |
| Purge | 50 |
| Dissipe | 50 |
| **Multi-cible** (`tous_les_ennemis` ou `duo`) | coût de l'effet **×1,3**, quel que soit l'effet (Purge duo = 100) |

### 7.3 Budgets par rang

| Rang | Budget |
| --- | --- |
| Moyeu | 55 |
| N1 | 70 |
| N2 | 100 |
| N3 | 140 |
| Clé | 230 |

Par classe, un **multiplicateur de classe** `k_classe` (valeurs de départ : Guerrier 0,85 · Pugiliste 0,90 · toutes les autres 1,00) multiplie toutes les valeurs numériques de ses nœuds (pas les durées, pas les pourcentages). C'est le premier bouton du simulateur (section 11).

### 7.4 Outil obligatoire : `tools/budget.gd`

Lit `data/classes/*.json`, calcule le coût de chaque nœud avec la grille 7.2 et **échoue** (code de sortie ≠ 0, liste des nœuds fautifs) si un coût sort de **±6 %** du budget de son rang. Lancé par la CI avec les tests. Les chiffres de la section 9 ont été calculés avec cette grille ; **si l'outil en trouve un faux, c'est la valeur qui est corrigée pour coller au budget, jamais le budget ni la grille.**

### 7.5 PV de base (niveau 1)

Guerrier 1400 · Pugiliste 1200 · Voleur 1000 · Diplomate 1000 · Prêtre 950 · Alchimiste 950 · Barde 950 · Mage 900 · Archer 900 · Invocateur 900.

---

## 8. Synergies

Quand, **au même tour**, le joueur et son acolyte jouent des nœuds dont les tags se répondent, un bonus s'applique. Quatre Synergies, universelles (aucune par couple de classes) :

| Nom | Condition (même tour, même camp) | Effet |
| --- | --- | --- |
| **Brisure** | L'un pose un état de contrôle (Étourdi, Gelé, Enraciné, Aveuglé, Silencié, Provoqué) sur une cible, l'autre inflige des dégâts directs `un_ennemi` à **la même cible**. | Ces dégâts directs ×1,25. |
| **Embrasement** | Les deux posent un DoT sur la même cible. | Les deux DoT durent +1 tour. |
| **Bastion** | L'un pose une Barrière sur un allié, l'autre soigne **le même allié**. | La Barrière ×1,3. |
| **Harmonie** | L'un pose un Renfort sur un allié, l'autre inflige des dégâts directs. | Le Renfort dure +1 tour. |

Vérifiées en phase 2 avant 2b sur les déclarations ; affichées en doré dans la résolution. Pas de règle d'attente : l'IA de l'acolyte compte simplement la Synergie dans son score (section 10).

---

## 9. Les dix classes

Format d'un nœud : **Nom** · effets (valeur · cible). « un » = `un_ennemi`, « tous » = `tous_les_ennemis`, « allié » = `un_allie`, « soi » = `soi`, « duo » = `duo`. DoT noté `type par_tour×tours`. Les coûts entre parenthèses sont ceux de la grille 7.2 ; ils doivent tomber dans ±6 % du budget du rang. Les 3 premières voies de chaque classe sont celles de l'**acolyte**.

### 9.1 Guerrier — PV 1400 · k = 0,85 · Front · acolyte : Prêtre
Moyeu **Taillade** : dégâts 55 · un.

| Voie | N1 (70) | N2 (100) | N3 (140) | Clé (230) |
| --- | --- | --- | --- | --- |
| **Sang** (acolyte) | **Entaille** : dégâts 45 · un + Saignement 12×3 · un (70) | **Déchirure** : dégâts 55 + Saignement 21×3 · un (99) | **Hémorragie** : dégâts 30 · tous + Saignement 28×4 · tous (141) | **Exsangue** : dégâts 90 + Saignement 30×4 + Désarmé 1 · un (234) |
| **Rempart** (acolyte) | **Garde haute** : barrière 100 · soi (70) | **Provocation** : Provoqué 1 + dégâts 60 · un (100) | **Mur de fer** : barrière 154 · duo (140) | **Rempart vivant** : barrière 180 · soi + Provoqué 1 · tous + dégâts 52 · un (230) |
| **Charge** (acolyte) | **Élan** : dégâts 70 · un | **Charge** : dégâts 100 · un | **Fracas** : dégâts 60 + Gelé 1 · un (140) | **Coup de grâce** : dégâts 230 · un |
| **Tonnerre** | **Balayage** : dégâts 54 · tous (70) | **Onde de choc** : dégâts 77 · tous (100) | **Tremblement** : dégâts 73 · tous + Enraciné 1 · tous (140) | **Séisme** : dégâts 120 · tous + Désarmé 1 · tous (234) |
| **Cri** | **Cri de guerre** : Renfort +25 % · soi + dégâts 20 · un (70) | **Second souffle** : soin 110 · soi (99) | **Rage** : Renfort +40 % · soi + dégâts 60 · un (140) | **Dernier rempart** : soin 150 · soi + barrière 135 · soi (230) |

### 9.2 Mage — PV 900 · k = 1,00 · Dégâts · acolyte : Guerrier
Moyeu **Trait arcanique** : dégâts 55 · un.

| Voie | N1 | N2 | N3 | Clé |
| --- | --- | --- | --- | --- |
| **Brasier** (acolyte) | **Étincelle** : dégâts 45 + Brûlure 12×3 · un (70) | **Boule de feu** : dégâts 100 · un | **Embrasement** : dégâts 38 · tous + Brûlure 25×4 · tous (140) | **Tempête de feu** : dégâts 105 · tous + Brûlure 25×4 · tous (228) |
| **Givre** (acolyte) | **Éclat de givre** : dégâts 35 + Enraciné 1 · un (70) | **Gel** : Gelé 1 + dégâts 20 · un (100) | **Blizzard** : dégâts 73 · tous + Enraciné 1 · tous (140) | **Hiver** : Gelé 1 · tous + dégâts 97 · tous (230) |
| **Foudre** (acolyte) | **Arc** : dégâts 70 · un | **Éclair** : dégâts 100 · un | **Chaîne** : dégâts 140 · un | **Foudre céleste** : dégâts 110 + Étourdi 1 · un (230) |
| **Voile** | **Voile** : barrière 100 · soi (70) | **Silence** : Silencié 2 + dégâts 10 · un (100) | **Miroir** : barrière 154 · duo (140) | **Bannissement** : Égaré + Silencié 2 + dégâts 80 · un (230) |
| **Arcane** | **Siphon** : dégâts 40 · un + soin 33 · soi (70) | **Drain** : dégâts 55 · un + soin 50 · soi (100) | **Renvoi** : Renfort +30 % · soi + dégâts 80 · un (140) | **Apothéose** : dégâts 130 · un + Renfort +50 % · soi (230) |

### 9.3 Voleur — PV 1000 · k = 1,00 · Dégâts · acolyte : Pugiliste
Moyeu **Dague** : dégâts 55 · un.

| Voie | N1 | N2 | N3 | Clé |
| --- | --- | --- | --- | --- |
| **Ombres** (acolyte) | **Coup sournois** : dégâts 70 · un | **Lame dansante** : dégâts 100 · un | **Frappe des ombres** : dégâts 80 + Désarmé 1 · un (140) | **Assassinat** : dégâts 230 · un |
| **Poison** (acolyte) | **Lame empoisonnée** : dégâts 35 + Poison 10×5 · un (70) | **Toxine** : Poison 20×5 + dégâts 30 · un (100) | **Nuage toxique** : Poison 20×4 · tous + dégâts 52 · tous (140) | **Venin noir** : Poison 40×5 + dégâts 90 · un (230) |
| **Ruse** (acolyte) | **Jet de sable** : Aveuglé 1 · un (70) | **Croc-en-jambe** : Enraciné 1 + dégâts 65 · un (100) | **Bombe fumigène** : Gelé 1 · tous + dégâts 28 · tous (140) | **Coup du lapin** : Étourdi 1 + dégâts 110 · un (230) |
| **Larcin** | **Esquive** : barrière 100 · soi (70) | **Vol** : dégâts 55 · un + soin 50 · soi (100) | **Diversion** : Égaré + dégâts 80 · un (140) | **Pillage** : dégâts 120 + Dissipe + Égaré · un (230) |
| **Éventail** | **Éventail de lames** : dégâts 54 · tous (70) | **Pluie de dagues** : dégâts 77 · tous (100) | **Tourbillon** : dégâts 108 · tous (140) | **Mille coupures** : dégâts 100 · tous + Saignement 28×4 · tous (232) |

### 9.4 Archer — PV 900 · k = 1,00 · Dégâts · acolyte : Guerrier
Moyeu **Flèche** : dégâts 55 · un.

| Voie | N1 | N2 | N3 | Clé |
| --- | --- | --- | --- | --- |
| **Précision** (acolyte) | **Tir précis** : dégâts 70 · un | **Tir perçant** : dégâts 100 · un | **Flèche lourde** : dégâts 140 · un | **Flèche du jugement** : dégâts 230 · un |
| **Volée** (acolyte) | **Volée** : dégâts 54 · tous (70) | **Pluie de flèches** : dégâts 77 · tous (100) | **Déluge** : dégâts 108 · tous (140) | **Ciel noir** : dégâts 140 · tous + Affaiblissement −20 % · tous (234) |
| **Pièges** (acolyte) | **Flèche entravante** : Enraciné 1 + dégâts 35 · un (70) | **Piège** : Enraciné 2 + dégâts 30 · un (100) | **Flèche aveuglante** : Aveuglé 1 + dégâts 70 · un (140) | **Filet** : Étourdi 1 + Enraciné 2 + dégâts 40 · un (230) |
| **Feu grégeois** | **Flèche enflammée** : dégâts 40 + Brûlure 14×3 · un (69) | **Tir incendiaire** : Brûlure 24×4 + dégâts 33 · un (100) | **Mur de flammes** : Brûlure 22×4 · tous + dégâts 46 · tous (140) | **Pluie de feu** : Brûlure 30×5 · tous + dégâts 72 · tous (230) |
| **Retrait** | **Pas en arrière** : barrière 100 · soi (70) | **Pansement** : soin 110 · soi (99) | **Œil de faucon** : Renfort +35 % · soi + dégâts 70 · un (140) | **Dernière flèche** : dégâts 150 · un + soin 90 · soi (231) |

### 9.5 Prêtre — PV 950 · k = 1,00 · Soutien · acolyte : Mage
Moyeu **Lueur** : soin 60 · allié (54).

| Voie | N1 | N2 | N3 | Clé |
| --- | --- | --- | --- | --- |
| **Lumière** (acolyte) | **Prière** : soin 78 · allié (70) | **Grâce** : soin 111 · allié (100) | **Bénédiction** : soin 120 · duo (140) | **Miracle** : soin 197 · duo (230) |
| **Châtiment** (acolyte) | **Châtiment** : dégâts 70 · un | **Jugement** : dégâts 100 · un | **Colère divine** : dégâts 100 + Affaiblissement −20 % · un (140) | **Verdict** : dégâts 230 · un |
| **Protection** (acolyte) | **Égide** : barrière 100 · allié (70) | **Rempart de foi** : barrière 143 · allié (100) | **Sanctuaire** : barrière 154 · duo (140) | **Sanctification** : barrière 200 · duo + soin 41 · duo (230) |
| **Purification** | **Purge** : Purge + soin 22 · allié (70) | **Exorcisme** : Dissipe + Silencié 1 + dégâts 5 · un (100) | **Absolution** : Purge · duo + soin 34 · duo (140) | **Ascension** : Purge · duo + Renfort +30 % · duo + soin 44 · duo (230) |
| **Ferveur** | **Ferveur** : Renfort +25 % · soi + dégâts 20 · un (70) | **Zèle** : dégâts 55 · un + soin 50 · soi (100) | **Martyre** : barrière 100 · soi + dégâts 70 · un (140) | **Transcendance** : soin 100 · soi + Renfort +40 % · soi + dégâts 60 · un (230) |

### 9.6 Alchimiste — PV 950 · k = 1,00 · Soutien · acolyte : Voleur
Moyeu **Fiole** : dégâts 55 · un.

| Voie | N1 | N2 | N3 | Clé |
| --- | --- | --- | --- | --- |
| **Acide** (acolyte) | **Éclaboussure** : dégâts 35 + Poison 10×5 · un (70) | **Acide** : Poison 20×5 + dégâts 30 · un (100) | **Nuée corrosive** : Poison 24×4 · tous + dégâts 40 · tous (139) | **Dissolution** : Poison 40×5 + Désarmé 1 + dégâts 30 · un (230) |
| **Élixir** (acolyte) | **Tonique** : soin 78 · allié (70) | **Élixir** : soin 111 · allié (100) | **Vapeurs curatives** : soin 120 · duo (140) | **Panacée** : Purge · duo + soin 111 · duo (230) |
| **Fumées** (acolyte) | **Fumée aveuglante** : Aveuglé 1 · un (70) | **Gaz soporifique** : Gelé 1 + dégâts 20 · un (100) | **Brume** : Aveuglé 1 · tous + dégâts 38 · tous (140) | **Nuée paralysante** : Étourdi 1 + Affaiblissement −30 % + dégâts 50 · un (230) |
| **Mutagène** | **Stimulant** : Renfort +25 % · allié + soin 22 · allié (70) | **Sérum** : Renfort +25 % · duo + soin 30 · duo (100) | **Peau de pierre** : barrière 154 · duo (140) | **Transmutation** : Renfort +40 % · duo + barrière 138 · duo (230) |
| **Nitro** | **Nitro** : dégâts 70 · un | **Bombe** : dégâts 100 · un | **Grenade** : dégâts 108 · tous (140) | **Explosion** : dégâts 120 · tous + Égaré · tous (234) |

### 9.7 Invocateur — PV 900 · k = 1,00 · Dégâts · acolyte : Pugiliste
Moyeu **Griffe** : dégâts 55 · un. (Plus de créature avec des PV : les invocations sont les DoT « Familier » et les HoT « Gardien ». À l'écran, un petit sprite de créature apparaît à côté de la cible tant que l'état dure.)

| Voie | N1 | N2 | N3 | Clé |
| --- | --- | --- | --- | --- |
| **Meute** (acolyte) | **Loup** : Familier 12×4 + dégâts 36 · un (70) | **Meute** : Familier 20×5 + dégâts 30 · un (100) | **Nuée de corbeaux** : Familier 20×4 · tous + dégâts 52 · tous (140) | **Béhémoth** : Familier 45×5 + dégâts 72 · un (230) |
| **Gardien** (acolyte) | **Esprit gardien** : Gardien 27×4 · allié (70) | **Totem de vie** : Gardien 30×4 · duo (101) | **Carapace** : barrière 154 · duo (140) | **Grand gardien** : Gardien 40×5 · duo + barrière 67 · duo (230) |
| **Liens** (acolyte) | **Entrave** : Enraciné 2 · un (70) | **Lianes** : Enraciné 1 · tous + dégâts 42 · tous (100) | **Étreinte** : Gelé 1 + dégâts 60 · un (140) | **Prison d'épines** : Étourdi 1 + Saignement 25×4 + dégâts 40 · un (230) |
| **Élémentaire** | **Flammèche** : dégâts 70 · un | **Golem** : dégâts 100 · un | **Élémentaire** : dégâts 90 · un + Renfort +25 % · soi (140) | **Titan** : dégâts 230 · un |
| **Pacte** | **Pacte** : dégâts 40 · un + soin 33 · soi (70) | **Sacrifice** : soin 111 · soi (100) | **Lien vital** : soin 60 · duo + barrière 100 · soi (140) | **Communion** : soin 100 · duo + Renfort +30 % · duo + dégâts 35 · un (230) |

### 9.8 Barde — PV 950 · k = 1,00 · Soutien · acolyte : Archer
Moyeu **Note** : dégâts 55 · un.

| Voie | N1 | N2 | N3 | Clé |
| --- | --- | --- | --- | --- |
| **Hymne** (acolyte) | **Hymne** : Renfort +25 % · allié + dégâts 20 · un (70) | **Marche** : Renfort +25 % · duo + dégâts 35 · un (100) | **Ode** : Renfort +40 % · allié + soin 67 · allié (140) | **Chant héroïque** : Renfort +50 % · duo + soin 85 · duo (230) |
| **Complainte** (acolyte) | **Complainte** : Affaiblissement −25 % + dégâts 20 · un (70) | **Lamentation** : Affaiblissement −20 % · tous + dégâts 37 · tous (100) | **Dissonance** : Dissipe + Affaiblissement −30 % + dégâts 30 · un (140) | **Requiem** : Affaiblissement −40 % · tous + Désarmé 1 · tous + dégâts 37 · tous (230) |
| **Berceuse** (acolyte) | **Berceuse** : Silencié 1 + dégâts 25 · un (70) | **Sommeil** : Gelé 1 + dégâts 20 · un (100) | **Fugue** : Égaré + dégâts 80 · un (140) | **Cacophonie** : Étourdi 1 + Silencié 2 + dégâts 20 · un (230) |
| **Refrain** | **Refrain** : soin 78 · allié (70) | **Ballade** : soin 85 · duo (100) | **Cantique** : soin 120 · duo (140) | **Chant de renouveau** : Purge · duo + soin 111 · duo (230) |
| **Solo** | **Accord** : dégâts 70 · un | **Crescendo** : dégâts 100 · un | **Solo** : dégâts 90 · un + Renfort +25 % · soi (140) | **Finale** : dégâts 230 · un |

### 9.9 Diplomate — PV 1000 · k = 1,00 · Soutien · acolyte : Invocateur
Moyeu **Réplique** : dégâts 55 · un.

| Voie | N1 | N2 | N3 | Clé |
| --- | --- | --- | --- | --- |
| **Intimidation** (acolyte) | **Menace** : Provoqué 1 + dégâts 30 · un (70) | **Ultimatum** : Silencié 1 + Affaiblissement −25 % + dégâts 5 · un (100) | **Humiliation** : Désarmé 1 + dégâts 80 · un (140) | **Capitulation** : Étourdi 1 + Égaré + dégâts 50 · un (230) |
| **Traité** (acolyte) | **Trêve** : barrière 100 · allié (70) | **Pacte** : barrière 143 · allié (100) | **Alliance** : barrière 154 · duo (140) | **Armistice** : barrière 143 · duo + Purge · duo (230) |
| **Rhétorique** (acolyte) | **Confusion** : Égaré + dégâts 10 · un (70) | **Contre-argument** : Dissipe + dégâts 50 · un (100) | **Discrédit** : Affaiblissement −30 % · tous + dégâts 48 · tous (140) | **Volte-face** : Égaré · tous + Silencié 2 · tous + dégâts 27 · tous (230) |
| **Éloquence** | **Encouragement** : Renfort +25 % · allié + dégâts 20 · un (70) | **Harangue** : Renfort +25 % · duo + soin 30 · duo (100) | **Plaidoyer** : soin 120 · duo (140) | **Grand discours** : Renfort +40 % · duo + soin 108 · duo (230) |
| **Duel** | **Estocade** : dégâts 70 · un | **Riposte** : dégâts 55 · un + barrière 64 · soi (100) | **Botte secrète** : dégâts 140 · un | **Mise à mort** : dégâts 170 + Désarmé 1 · un (230) |

### 9.10 Pugiliste — PV 1200 · k = 0,90 · Front · acolyte : Barde
Moyeu **Direct** : dégâts 55 · un.

| Voie | N1 | N2 | N3 | Clé |
| --- | --- | --- | --- | --- |
| **Poings** (acolyte) | **Crochet** : dégâts 70 · un | **Uppercut** : dégâts 100 · un | **Enchaînement** : dégâts 140 · un | **KO** : dégâts 110 + Étourdi 1 · un (230) |
| **Souffle** (acolyte) | **Souffle** : soin 78 · soi (70) | **Posture de fer** : barrière 143 · soi (100) | **Concentration** : Renfort +35 % · soi + soin 78 · soi (140) | **Second vent** : soin 150 · soi + barrière 136 · soi (230) |
| **Prise** (acolyte) | **Saisie** : Enraciné 1 + dégâts 35 · un (70) | **Clé de bras** : Désarmé 1 + dégâts 40 · un (100) | **Étranglement** : Silencié 2 + dégâts 50 · un (140) | **Projection** : Étourdi 1 + Égaré + dégâts 50 · un (230) |
| **Tourbillon** | **Balayage** : dégâts 54 · tous (70) | **Coup de pied circulaire** : dégâts 77 · tous (100) | **Tornade** : dégâts 108 · tous (140) | **Onde de choc** : Enraciné 1 · tous + dégâts 142 · tous (230) |
| **Défi** | **Défi** : Provoqué 1 + dégâts 30 · un (70) | **Garde** : barrière 86 · soi + Provoqué 1 · un (100) | **Contre** : barrière 100 · soi + dégâts 70 · un (140) | **Mur de chair** : barrière 200 · soi + Provoqué 1 · tous + dégâts 38 · un (230) |

Les noms de nœuds sont uniques **dans une classe** ; un même nom peut exister dans deux classes (identifiant = `classe.voie.rang`).

---

## 10. L'IA (une seule, déterministe)

Sert à l'acolyte (les deux camps), aux Échos, aux ennemis de la Tour, au simulateur. **Aucun tirage aléatoire.** Elle évalue chaque action légale et joue celle de **score maximal** ; en cas d'égalité, l'ordre : moyeu < voie 1 < voie 2 < … (la dernière de la liste gagne, donc une voie plutôt que le moyeu, et la voie de rang le plus élevé si égalité stricte).

### 10.1 Score d'une action

`score = valeur_offensive + valeur_defensive + bonus_synergie + bonus_progression − penalite`

- **valeur_offensive** : somme, sur les ennemis vivants touchés, de : dégâts directs effectifs (après Renfort/Affaiblissement/Désarmé de l'attaquant, Barrière de la cible, Aveuglé → 0, plafonnés aux PV restants de la cible + 0) ; + total d'un DoT posé × 0,7 (plafonné aux PV de la cible) ; + valeur d'un état posé selon la grille 7.2 **× 1,5 si la cible a une menace d'échéance 1** (Étourdi, Gelé, Silencié, Égaré, Enraciné répondent à une menace) ; + Affaiblissement : `% × 2` ; + Dissipe : 50 si la cible a une Barrière ≥ 50 ou un Renfort, 0 sinon ; + Égaré : 60 + 60 × (nombre de jalons ennemis ≥ 2).
- **valeur_defensive** : soin effectif = `min(soin, PV manquants de la cible) × 1,0` ; Gardien : total × 0,65 plafonné aux PV manquants + 20 ; Barrière : `min(barrière, dégâts potentiels)` × 0,7 où `dégâts potentiels` = somme des menaces ennemies d'échéance 1 visant ce camp (budget des nœuds) + 55 par ennemi vivant ; Purge : 50 par état négatif retiré, 0 si aucun ; Renfort : `% × 2` si l'allié renforcé a une Clé ou un N3 d'échéance ≤ 2, sinon `% × 1` ; Provoqué : 40 si le provocateur a plus de PV (en %) que son allié, 0 sinon.
- **bonus_synergie** : +40 si l'action complète une Synergie avec l'action **déjà déclarée** de l'allié (pour le joueur IA, c'est celle de l'acolyte ; pour l'acolyte, qui déclare en premier, 0).
- **bonus_progression** : +15 × rang du nœud (N1 : 15, N2 : 30, N3 : 45, Clé : 60) pour favoriser l'avancée sur une voie ; +25 si la voie est celle de `last_voie` (continuité).
- **penalite** : +∞ (action retirée) si l'action est un soin/barrière/renfort dont la valeur effective est < 10 (pas de soin à PV pleins) ; +40 si c'est le moyeu alors qu'au moins une autre action est légale.

### 10.2 Choix de cible de l'IA

Avant de scorer, l'IA fixe `cible_ennemie` : l'ennemi vivant qui maximise `(PV manquants en %) × 100 + (a une menace d'échéance 1 ? 30 : 0)`, sauf si Provoqué. `cible_alliee` : l'allié vivant (soi compris) aux PV les plus bas en pourcentage. Ces deux cibles valent pour toutes les actions scorées de ce tour.

### 10.3 Règles spéciales de l'acolyte

Aucune : il n'attend plus un tour pour une Synergie (règle du 27 octobre supprimée). Il est prévisible parce que la fonction de score l'est.

### 10.4 Ennemis de la Tour

Le bestiaire est réécrit : chaque monstre est **une classe + une liste de voies + un multiplicateur de PV** (`pv_mult`, 0,5 à 1,5) + un sprite. Un étage tire (avec la graine de l'étage) 1 à 4 monstres dont la somme des `pv_mult` est entre 1,6 et 2,4. Un monstre à 1 voie n'a que cette voie (et le moyeu). Aucun monstre n'a de mécanique propre : tout passe par les nœuds de ce document. Les 14 monstres actuels sont transposés (même nom, même sprite) ; le journal liste la transposition.

---

## 11. Simulateur et équilibrage

Le simulateur existant (`tools/equilibrage.*`) est adapté au nouveau moteur. Il joue des combats **IA contre IA**, niveau 30, allumage par défaut, Destins générés avec des graines successives. Trois mesures, trois critères, cinq boutons.

### 11.1 Mesures

1. **Matrice des classes** : 10 × 10 matchs (classe A + son acolyte contre classe B + son acolyte), 1 000 combats par case (graines 1 à 1 000, les deux camps en alternance A/B pour annuler l'avantage du camp 1), taux de victoire de A.
2. **Les trois routes** : pour chaque classe, trois joueurs scriptés contre l'IA standard de chacune des 10 classes (1 000 combats par couple) : **Ruée** (toujours continuer la voie dont la Clé a le plus gros budget restant, moyeu sinon), **Éventail** (jouer N1 puis N2 de chaque voie à tour de rôle, jamais N3 ni Clé sauf si rien d'autre), **Réactive** (l'IA standard).
3. **Usage** : part des combats où chaque voie est jouée au moins une fois ; part des combats où une Clé est jouée ; longueur des combats.

### 11.2 Critères d'acceptation (tous obligatoires)

- Chaque classe : taux de victoire global (moyenne de sa ligne) entre **47 % et 53 %**.
- Aucune case de la matrice hors de **40 % – 60 %**.
- Pour chaque classe, aucune des trois routes ne gagne plus de **55 %** de ses combats, et aucune moins de 40 %.
- Chaque voie de chaque classe jouée dans ≥ **15 %** des combats de sa classe ; une Clé jouée dans ≥ **60 %** des combats.
- Longueur : médiane entre **6 et 10 tours** ; ≥ 95 % des combats finis avant le tour 20.
- Tour : avec l'allumage par défaut, l'IA standard atteint l'étage 10 dans 40–60 % des montées, l'étage 20 dans 5–10 %, pour **chaque** classe (±5 points entre classes).

### 11.3 Boutons de réglage, dans cet ordre, et seulement ceux-là

1. `k_classe` (bornes 0,75 – 1,20).
2. Budget d'un nœud précis, ±10 % autour du budget de son rang (la grille 7.2 ne bouge pas ; c'est `budget_override` dans la donnée du nœud, et `tools/budget.gd` accepte alors cet override).
3. Le coût d'un **état** dans la grille 7.2, ±20 % (un état trop fort coûte plus cher → ses nœuds portent moins de dégâts).
4. PV de base d'une classe, ±10 %.
5. Règles globales (tour de mort subite 10–14, pas 0,10–0,20, extinction 3 ou 4 tours, refroidissement 2 ou 3 tours) — **seulement si les quatre premiers boutons ne suffisent pas**, et avec une ligne de justification dans le journal.

Le régleur automatique existant est conservé dans son principe (passes, mesure sur des combats neufs avant fusion) avec ces boutons. Chaque passe de réglage finit par **un rapport en français** dans `docs/EQUILIBRAGE-V2.md` : la matrice, les trois routes, l'usage, les boutons touchés et pourquoi.

---

## 12. Interface

Les maquettes de référence sont dans le fichier Wonder « Projet Arena — Interface » (page unique) : l'artboard **« Combat Arena Scene Screen »** est l'écran de combat à reproduire ; « Combat Resolution Screen », « Enemy Sheet Screen », « Victory Result Screen », « Destiny Wheel Screen », « Acolyte Profile Screen » complètent. Jetons de couleur : nuit `#0f0e17`, surface `#1c1a28`, surface relevée `#262337`, bord `#3a3650`, texte `#efe9d9`, texte atténué `#aaa49b`, or `#e3b85f`, teal `#5cc8b8`, rouge `#d35b5b`, violet `#c9a0ff`, orange `#e08a4f`. Police titres : Pixelify Sans ; texte : Inter (ou équivalents libres déjà dans le projet).

### 12.1 Le langage visuel (une seule grammaire, partout)

- **Effet** = un pictogramme + une couleur (table 7.1).
- **Cible** = un glyphe : une silhouette (un), deux silhouettes (tous / duo), silhouette cerclée (soi), silhouette avec cœur (allié).
- **Nombre** = la valeur (dégâts, soin, %, `par_tour×tours`).
- **Échéance** = un chiffre seul dans une pastille ; **halo** si 1. Jamais le mot « pas », jamais le mot « tour » dans la pastille.
- **Formes de nœud** : rond = nœud ; losange = Clé ; pointillé = éteint ; grisé = non allumé.
- Une **menace** = pictogramme d'effet principal + glyphe de cible + échéance. Exemple : flamme · deux silhouettes · 1. Jamais de texte.
- Un **état subi** = pictogramme + tours restants (ex. flocon · 1).
- **Texte** : nom du nœud (≤ 3 mots) ; ligne chiffrée en symboles (« 60 + 30×3 ») ; phrase ≤ 10 mots, sans chiffres, uniquement dans la fiche. Les trois sont **générés depuis les données** (section 12.6), jamais écrits à la main.

### 12.2 L'écran de combat (une seule scène)

- Une seule scène d'arène, pas deux panneaux. Vue trois-quarts : le duo ennemi en haut à droite, tourné vers le bas-gauche ; le duo du joueur en bas à gauche, tourné vers le haut-droite (de trois-quarts dos). À la Tour, 1 à 4 ennemis répartis en haut, du plus gros au centre.
- Tailles (écran de 390 px de large) : joueur ≈ 150 px, joueur adverse ≈ 112 px, acolytes ≈ 100 px, monstres selon `pv_mult`. Les skins doivent être lisibles : rien ne recouvre un personnage sauf sa propre plaque.
- **Chaque sprite existe sous deux angles** : face trois-quarts (quand il est ennemi) et dos trois-quarts (quand il est allié). Contrainte à passer au pipeline d'art.
- **Plaque** sous chaque personnage : barre de PV (rouge côté ennemi, teal côté allié), puis une rangée de pastilles : **menaces** (bord violet ou rouge, halo si échéance 1) puis **états** (bord gris). Maximum 3 menaces + 3 états ; au-delà, une pastille « +n ».
- L'acolyte du joueur, dès qu'il a déclaré : une pastille (effet · cible · son nom) près de lui et un trait fin vers sa cible. Même chose pour l'acolyte adverse.
- **Cible** : toucher un ennemi le cible (anneau doré en pointillé autour de lui). Toucher un allié fixe la cible alliée (anneau teal). Un nœud dont la cible est `soi`, `duo` ou `tous` ignore la sélection.
- **HUD bas** (par-dessus le sol de l'arène, jamais par-dessus un personnage) :
  - une ligne : **compteur de tour** à gauche, **chrono** 20 s au centre en or, « Quitter » à droite (en haut de l'écran, en fait : voir maquette).
  - la **bande de la voie courante** (`last_voie` ou, à défaut, la voie 1) : 4 points reliés, jalon = point doré épais, nœuds éteints en pointillé, Clé en losange ; à droite, « Clé » + son échéance.
  - **six cases fixes**, toujours au même endroit (mémoire des doigts) : moyeu, voie 1, voie 2, voie 3, voie 4, voie 5. Chaque case montre **le prochain nœud** de la voie : pictogramme(s) d'effet + glyphe de cible, nom, ligne chiffrée. Case grisée si illégale (éteint, Gelé, Silencié, Enraciné) avec le pictogramme de la raison (sablier, flocon, bâillon, racine). Sous Aveuglé, un œil barré sur les cases mono-cible. Disposition : deux rangées de trois ; le moyeu est la première case en bas à gauche.
  - Sous les cases, une ligne d'aide : « cible : Kael · touche un nœud deux fois pour jouer ».
- **Jouer** : premier toucher = la case se surélève et la bande de voie passe sur cette voie ; deuxième toucher sur la même case = joué (la case se verrouille, le chrono s'arrête pour le joueur). Toucher une autre case annule la première. Avant la fin du chrono, un appui long sur la case verrouillée la déverrouille.
- **Rien ne s'ouvre pendant le combat** à part la fiche (appui long) et le menu Quitter.

### 12.3 Les menaces (calcul, figé en phase 0)

Pour chaque personnage : pour chaque voie allumée, pour chaque nœud de rang ≥ 3 allumé, `échéance = max(rang − jalon, spent_until − tour)` si `spent_until > tour`, sinon `rang − jalon`. Garder les nœuds d'échéance ≤ 2 ; trier par échéance croissante puis budget décroissant ; afficher les 3 premiers. Un nœud **illégal au prochain tour pour cause d'état déjà posé** (Silencié actif au tour suivant → Clé) est affiché quand même, mais barré : l'adversaire voit que la réponse a porté.

### 12.4 La fiche d'un nœud (appui long sur une pastille de menace, une case du HUD, un point de la bande de voie, ou un nœud de l'écran du Destin)

S'ouvre au bout de 250 ms d'appui, ancrée au-dessus de l'élément, se ferme au relâchement (ou au toucher ailleurs si ouverte depuis l'écran du Destin). Contenu, **toujours dans cet ordre**, généré depuis les données :

1. **Nom** (avec le suffixe de forme) — Classe · Voie · Rang (« Voie du Givre · 3 / 4 » ou « Clé »).
2. **Rangée de pictogrammes** : chaque effet avec sa cible et sa valeur.
3. **Ligne chiffrée** : « 73 à tous + Enraciné 1 ».
4. **Phrase** (≤ 10 mots, sans chiffres).
5. **Détail des états** : pour chaque état posé, une ligne « Enraciné : ne peut pas changer de voie » (texte fixe par état, table 6).
6. **Échéance** : « Jouable au prochain tour » / « Jouable dans 2 tours » / « Éteint encore 2 tours » / (pour soi) « Jouable maintenant ».
7. Pour un nœud **ennemi** : **« Pour l'empêcher »** : la liste des réponses que **le joueur ou son acolyte** a réellement en main ce tour (nœuds légaux) qui l'annuleraient ou le retarderaient : Étourdi, Gelé (si le nœud n'est pas le moyeu), Silencié (si Clé), Égaré, Enraciné (si le nœud n'est pas sur `last_voie` de l'ennemi), Barrière/soin si c'est des dégâts. Chaque réponse = nom du nœud + son pictogramme ; « Aucune réponse en main ce tour » sinon.
8. Pour un nœud **à soi** : **« Après »** : le nœud suivant de la voie (nom + pictos), ou « Clé : remet la voie à zéro ».
9. Pour une Clé à soi : la valeur avec les éclats (É5) déjà incluse ; indiquer « (+10 % éclat) » en petit.

Appui long sur un **personnage** : la fiche personnage (maquette « Enemy Sheet Screen ») : nom, classe, PV, états avec tours restants, et ses 5 (ou 3) bandes de voie avec jalons, nœuds éteints et échéances ; appui long sur un point d'une bande → fiche du nœud.

### 12.5 La résolution

Plein écran, après la déclaration : un cut-in par action, dans l'ordre joueur A, acolyte A, joueur B, acolyte B (ou ennemis), puis les ticks (DoT/HoT) regroupés, puis les KO. Chaque cut-in : le sprite en grand, le nom du nœud, les pictogrammes, les nombres qui tombent sur les cibles (or : dégâts ; teal : soin ; teal clair : barrière ; violet : état posé ; rouge : tick). Synergie : bandeau doré avec son nom. Durée totale ≤ 4 s ; un toucher accélère, un deuxième saute à la fin. Le moteur fournit un **journal d'événements ordonné** (section 13.4) ; l'affichage ne recalcule rien.

### 12.6 Textes générés

Trois fonctions pures dans `engine/texte.gd`, testées :
- `nom(noeud)` : nom de base + suffixe de forme (« diffuse », « concentrée », « persistante », « vive », accordés au nom tel qu'écrit dans la donnée avec un champ `genre`).
- `ligne(noeud)` : effets séparés par « + », valeurs avec M, éclats et k appliqués, format « 60 à un ennemi », « 30×3 Saignement », « +25 % Renfort 2 t », « Gelé 1 ».
- `phrase(noeud)` : assemblée depuis des gabarits par effet (table dans `data/textes.json`), ≤ 10 mots, sans chiffre. Exemple : « Entaille » → « Une lame qui ouvre une plaie qui saigne. » ; forme diffuse → « … sur tous les ennemis. »

---

## 13. Données et code

### 13.1 Fichiers de données (JSON, UTF-8, clés en français sans accents)

- `data/rules.json` : `{ "extinction": 3, "refroidissement": 2, "mort_subite_tour": 12, "mort_subite_pas": 0.15, "chrono_s": 20, "niveau_pente": 0.05, "multi_cible": 1.3, "tolerance_budget": 0.06, "budgets": { "moyeu": 55, "1": 70, "2": 100, "3": 140, "4": 230 }, "couts": { ... grille 7.2 ... } }`
- `data/etats.json` : par état : `type`, `texte` (la ligne fixe de la fiche), `pictogramme`, `couleur`, `negatif` (bool), `dissipable`, `purgeable`.
- `data/classes/<classe>.json` :
  ```json
  { "id": "guerrier", "nom": "Guerrier", "genre": "m", "role": "front", "pv": 1400, "k": 0.85, "acolyte": "pretre",
    "moyeu": { "nom": "Taillade", "genre": "f", "effets": [ { "type": "degats", "valeur": 55, "cible": "un_ennemi" } ] },
    "voies": [
      { "id": "sang", "nom": "Voie du Sang", "acolyte": true,
        "noeuds": [
          { "rang": 1, "nom": "Entaille", "genre": "f", "effets": [ { "type": "degats", "valeur": 45, "cible": "un_ennemi" }, { "type": "dot", "sous_type": "saignement", "par_tour": 12, "tours": 3, "cible": "un_ennemi" } ] },
          ...
        ] }
    ] }
  ```
  Champ optionnel par nœud : `budget_override`. Les éclats ne sont pas dans les données (règle fixe de la section 3.1).
- `data/textes.json` : gabarits de phrases par effet, suffixes de forme.
- `data/bestiaire.json` : monstres (section 10.4).
- `data/tour.json` : conservé, règles d'étage transposées.

### 13.2 Modules du moteur (purs, sans nœud de scène, sans `randi` sauf `generateur.gd`)

- `engine/donnees.gd` : chargement et validation des JSON (toute clé inconnue = erreur).
- `engine/budget.gd` : coût d'un nœud (grille 7.2) ; utilisé par `tools/budget.gd` et par le générateur.
- `engine/generateur.gd` : `generer(classe, graine, niveau, allumage) -> Destin` ; formes ; allumage par défaut ; acolyte.
- `engine/etat_combat.gd` : structure de données complète d'un combat (sérialisable en dictionnaire, pour le serveur et les tests) : tour, personnages (PV, PV max, états avec tours restants et valeurs, barrière et `barrier_until`, jalons, `spent_until` par nœud, `inactivite` par voie, `last_voie`, cibles), journal.
- `engine/regles.gd` : `actions_legales(etat, perso)`, `menaces(etat, perso)`, `resoudre_tour(etat, declarations) -> etat` (phases 2a → 2i, section 5), `synergies(declarations)`.
- `engine/ia.gd` : `choisir(etat, perso, declarations_connues) -> action` (section 10).
- `engine/texte.gd` : section 12.6.
- `engine/tour.gd` : conservé, adapté.
- Aucune autre logique de règle nulle part (ni dans les scènes, ni dans les outils).

### 13.3 API du moteur (signatures stables)

```
Regles.nouveau_combat(camp_a: Array[Destin], camp_b: Array[Destin], niveau: int, mode: "pvp"|"tour") -> EtatCombat
Regles.actions_legales(etat, perso_id) -> Array[Action]      # Action = { perso, source: "moyeu"|"voie", voie, rang, cible_ennemie, cible_alliee }
Regles.menaces(etat, perso_id) -> Array[Menace]              # Menace = { voie, rang, echeance, barre: bool }
Regles.resoudre_tour(etat, declarations: Dictionary) -> EtatCombat   # déclarations : perso_id -> Action (absent = moyeu ; Étourdi = ignoré)
Regles.fini(etat) -> { fini: bool, vainqueur: "a"|"b"|"" }
IA.choisir(etat, perso_id, declarations_connues) -> Action
Generateur.generer(classe_id, graine, niveau, allumage: Array[String]) -> Destin
Texte.nom / ligne / phrase / fiche(etat, noeud, point_de_vue) -> Dictionary
```

### 13.4 Journal d'événements (produit par `resoudre_tour`, consommé par l'affichage et les tests)

Liste ordonnée de dictionnaires : `{ "tour", "phase": "2a"…"2i", "acteur", "noeud", "cible", "type": "degats|soin|barriere|etat|egare|tick|expire|dissipe|purge|jalon|refroidissement|ko|fin|synergie", "valeur", "absorbe", "detail" }`. Les tests de la section 14 s'appuient dessus.

---

## 14. Tests obligatoires (`tests/`, lancés en CI, tous verts avant toute PR)

Données et budget : 1. chaque classe a 5 voies × 4 nœuds + moyeu ; 2. `tools/budget.gd` passe sur les 10 classes ; 3. toutes les clés JSON sont connues ; 4. chaque état de la table 6 est posé par ≥ 2 classes.
Générateur : 5. même graine → même Destin ; 6. graines différentes → formes différentes sur au moins un nœud (sur 100 graines) ; 7. chaque forme générée reste dans ±6 % du budget ; 8. Diffuse ne s'applique qu'aux nœuds mono-cible, Concentrée qu'aux multi, Persistante qu'aux dégâts/soins directs, Vive qu'aux DoT/Gardien ; 9. allumage par défaut niveau 30 = 15 actifs + É1, É3, É2 par voie ; 10. règle d'allumage (rang k exige k−1 ; éclat exige son nœud).
Règles : 11. le moyeu est toujours légal sauf Étourdi ; 12. un nœud joué est éteint exactement 3 tours ; 13. Clé → jalon 0 ; 14. refroidissement après 2 tours d'inactivité, remise à 0 du compteur ; 15. Égaré recule tous les jalons et ne touche pas les extinctions ; 16. Gelé → seul le moyeu ; 17. Silencié → pas de Clé ; 18. Enraciné → moyeu ou `last_voie` seulement, rien d'interdit si `last_voie` vide ; 19. Aveuglé → 0 dégâts mono-cible, multi intacts ; 20. Désarmé ×0,5 ; 21. Provoqué force la cible ; 22. Barrière absorbe en premier, Saignement l'ignore, Brûlure halve la barrière reçue, Poison halve le soin reçu ; 23. états posés ce tour actifs au tour suivant seulement ; 24. Étourdi dure exactement 1 tour ; 25. pas de cumul : durée max, valeur max ; 26. ticks avant durées, pas de tick le tour de la pose ; 27. KO constatés en 2i seulement (un soin sauve) ; 28. double KO → PV % en début de tour ; 29. mort subite au tour 12 : ×1,15, soins non touchés, absente à la Tour ; 30. M(niveau) multiplie PV et valeurs, pas les durées ; 31. éclats : +5 %/+3 %/+10 % appliqués ; 32. chrono dépassé → moyeu ; 33. les 4 Synergies ; 34. ordre d'application : joueur A, acolyte A, joueur B, acolyte B, et dans l'ordre des effets du nœud ; 35. résolution identique pour un même état et les mêmes déclarations, 1 000 fois (déterminisme) ; 36. `EtatCombat` sérialisé puis désérialisé donne la même résolution.
IA : 37. déterminisme ; 38. ne soigne jamais à PV pleins ; 39. pose un contrôle sur l'ennemi qui a une menace d'échéance 1 plutôt que des dégâts égaux ; 40. ne joue le moyeu que si rien d'autre n'est légal ou meilleur.
Menaces et fiches : 41. échéance = `max(rang − jalon, extinction restante)` ; 42. seulement rang ≥ 3 et échéance ≤ 2, 3 maximum, tri ; 43. menace barrée si état posé l'empêche ; 44. « Pour l'empêcher » ne liste que des nœuds légaux ce tour pour le camp du joueur ; 45. `texte.gd` : nom avec suffixe accordé, ligne chiffrée, phrase ≤ 10 mots sans chiffre, pour les 200 nœuds × 5 formes.
Tour : 46. +20 % PV entre étages, acolyte KO revient ; 47. règles d'étage transposées actives ; 48. un étage tire 1 à 4 monstres, somme `pv_mult` entre 1,6 et 2,4.
Simulateur : 49. le rapport est produit et contient les six critères ; 50. un combat IA contre IA finit toujours (borne : 60 tours → le test échoue).

---

## 15. Plan de travail pour Opus (ordre impératif, une PR par étape)

Chaque PR : titre et description en français, tests verts, `docs/SUIVI.md` mis à jour, une entrée dans `docs/JOURNAL-COMBAT-V2.md` pour chaque choix fait hors de ce document. Pas d'agents en parallèle, pas de session cloud (voir `docs/SUIVI.md`). À la fin de chaque étape, écrire à Gautier trois phrases en français courant : ce qui existe, ce qu'il peut tester, ce qui vient ensuite.

1. **Données et budget.** `data/rules.json`, `data/etats.json`, `data/textes.json`, les 10 fichiers `data/classes/*.json` recopiés de la section 9, `engine/budget.gd`, `tools/budget.gd`, tests 1–4. Critère : `tools/budget.gd` passe. Si un chiffre de la section 9 sort des ±6 %, le corriger **vers le budget** et le lister dans le journal.
2. **Moteur de règles.** `etat_combat.gd`, `regles.gd` (phases 2a → 2i), journal d'événements, tests 11–36. L'ancien moteur est supprimé dans cette PR (pas de cohabitation).
3. **Générateur et Destin.** `generateur.gd`, formes, allumage, éclats, acolyte ; adaptation de l'écran du Destin (roue : moyeu au centre, 5 rayons, éclats accrochés ; appui long → fiche) ; tests 5–10, 45.
4. **IA.** `ia.gd`, bestiaire transposé, Tour adaptée ; tests 37–40, 46–48.
5. **Simulateur.** Adaptation du simulateur et du régleur aux boutons de la section 11.3, rapport `docs/EQUILIBRAGE-V2.md` ; tests 49–50. Puis **une première passe de réglage** sur le PC de Gautier ou GitHub, jusqu'à satisfaire les six critères. Ne pas passer à l'étape 6 avant : l'interface se construit sur des chiffres stables.
6. **Écran de combat.** Scène unique (12.2), plaques, menaces, cibles, HUD six cases, jouer en deux touches, chrono, fiche sur appui long (12.4), fiche personnage ; tests 41–44 sur les fonctions pures de menaces/fiche.
7. **Résolution et fin.** Cut-ins depuis le journal d'événements, Synergies, écran de victoire ; raccourcis (toucher = accélérer).
8. **Export web** et vérification sur téléphone par Gautier (une adresse à ouvrir). Rapport final : matrice, trois routes, usage, longueur, Tour, et la liste du journal.

**Interdits pendant tout le plan** : ajouter une mécanique, un état, une statistique (vitesse, précision, critique…), un tirage aléatoire en combat, une recharge, du mana, une posture, une règle d'attente de l'acolyte, un « système de créature » avec PV, un texte de menace en toutes lettres, un écran qui s'ouvre pendant le choix. Si quelque chose semble manquer, c'est voulu : appliquer la règle de la première page (choix le plus simple + journal).

---

## 16. Questions déjà tranchées (ne pas les reposer)

- **« 1 » sur une pastille** = jouable au prochain tour. **« 2 »** = dans deux tours au plus tôt. Le mot « pas » est banni.
- **Une seule action par tour**, jamais deux nœuds, jamais deux Clés.
- **On peut s'arrêter avant une Clé** et garder le jalon ; le refroidissement le fera reculer au bout de 2 tours d'inactivité ; l'adversaire le voit.
- **Deux voies en parallèle** : oui, chacune garde son jalon ; une seule avance par tour.
- **Premier tour** : tout le monde est au jalon 0 sur toutes les voies ; seules les ouvertures (N1) et le moyeu sont jouables.
- **Les menaces montrent l'avenir, pas l'intention** : l'adversaire peut toujours faire autre chose. C'est l'anticipation qui est stratégique.
- **Supports en 1 contre 1** : chaque Soutien a au moins une voie de dégâts (Châtiment, Nitro, Solo, Duel) et une voie d'auto-sustain.
- **Rocades** (passerelles entre voies) : **pas en V1**. Candidates pour la V2.
- **Équipement, économie, univers, nom** : hors périmètre de ce document.
- **Évolutions (niveau 30 → 3 classes)** : hors périmètre ; le système les accueillera (nouveau Destin = nouvelles voies).
