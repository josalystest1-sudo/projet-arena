# Projet Arena — avancement

Mis à jour le **29 octobre 2026** (PR #59). `main` = la PR #59 fusionnée et publiée (les Faveurs de la Tour). À lire avec `CLAUDE.md`. Le plan complet, PR par PR, est dans `docs/PLAN.md` (phases 1 à 10) ; l'historique de toutes les PR et des retours de Gautier dans `docs/SUIVI.md`.

Jeu publié (mis à jour à chaque fusion sur `main`) : https://josalystest1-sudo.github.io/projet-arena/ — ajouter `?graine=7` pour des tirages reproductibles.

---

## 1. Terminé et qui fonctionne

Vérifié après la PR #59 : **81 tests passent**, le budget des **210 nœuds** est tenu (`tools/budget.gd`), la CI est verte, le jeu publié se charge (y compris un profil d'avant le trio, qui reçoit ses Échos) et se joue au format téléphone (vérifié dans le navigateur intégré en 375 × 812).

### Le combat V2 (PR #34 à #47, 28 et 29 octobre)

- Moteur pur et déterministe (`engine/`) : roue du Destin (moyeu + 5 voies × 4 nœuds + éclats), formes tirées à la création, allumage (un point par niveau, 30 niveaux), jalons, extinction (3 tours), refroidissement (2 tours), 16 états, résolution simultanée phases 2a à 2i, menaces, 4 Synergies universelles, mort subite au tour 18 en PvP, KO en fin de tour.
- Données des 10 classes (`data/classes/`), budget par rang, outil `tools/budget.gd` en CI.
- IA à score déterministe (`engine/ia.gd`).
- Simulateur et régleur (`tools/equilibrage*.gd`, `tools/regleur*.py`) ; le duo à 20 tours a tenu les six critères de la spécification sur 300 000 duels neufs (PR #47 ; rapport en bas de `docs/EQUILIBRAGE-V2.md`). Ce réglage valait pour le **duo**, qui n'est plus joué.
- Écrans : roue du Destin, combat (cases, bande de voie, bandeau des Synergies, fiches au toucher, résolution animée, écran de fin), Tour, bestiaire (14 monstres, 4 familles), profil, paramètres.

### Depuis le GDD V2 (PR #48 à #57, 29 octobre)

| PR | Ce qui marche |
| --- | --- |
| #48 | Le GDD V2, le plan (`docs/PLAN.md`) et `docs/MECANIQUES.md` sur `main`, avec le « raccord avec le combat V2 » en tête du plan. |
| #49 (PR 1.1) | **Le trio dans le moteur** : `engine/trio.gd` (Front + Dégâts + Soutien, Échos générés : roue entière au niveau du joueur), annonces en chaîne (`IA.declarer` : Écho 1, puis Écho 2 qui connaît le 1, puis le joueur), Synergies entre chaque paire d'un camp, Tour à trois, simulateur en trio (`… simuler matrice … trio`). Le duo rejoue au bit près comme avant. |
| #50 | **L'adversaire caché** : plus de bandeau « en face », de menaces ennemies, d'annonce adverse, de voies dans la fiche d'un ennemi ; pastille « Clé » ; sa fiche liste ce qu'on l'a vu jouer. |
| #51 | La règle « 3 contre X » écrite dans le GDD V2 et le plan. |
| #52 | **« CLÉ PRÊTE »** : halo violet vif et étiquette au-dessus d'un ennemi dont une Clé est jouable (après le retour de Gautier : la première lueur ne se voyait pas). |
| #53 (PR 1.2) | **L'IA de bon sens** (`IA.bon_sens`) : achever (avec les coups annoncés et les DoT de fin de tour, +120), pas de coup sur un ennemi qui tombe déjà, pas de Clé gaspillée, barrière seulement sur un allié que les ennemis viseront. **Tableau des erreurs de l'IA** dans le rapport du simulateur (coup perdu, soin perdu, barrière inutile, Clé gaspillée, achèvement raté, pour 100 actions par rôle) et mesure `bon_sens` (A/B contre l'IA de la section 10). Résultats : en trio, au plus 3,3 erreurs de chaque type pour 100 actions (6,1 avant) ; l'IA de bon sens gagne 51,7 % des 20 000 duels de trios contre l'ancienne, 56,2 % en duo. |
| #54 | Le plan réécrit : construire tout le jeu, puis l'équilibrage global (phase 9), puis les graphismes (phase 10). |
| #55 (PR 1.3) | **Les Soutiens presque sans dégâts** : une seule voie de dégâts chacun ; 31 nœuds convertis en effets de soutien de même coût ; la voie de la Nitro de l'Alchimiste est devenue la voie de la Corrosion (Solvant, Dissolvant, Corrosion, Effondrement) ; la Ferveur du Prêtre renforce un allié. Test : deux actions utiles à PV pleins pour chaque Soutien, aux niveaux 1, 10, 30. |
| #56 (PR 1.4) | **Le jeu se joue en trio** : deux Échos proposés par le jeu (graine + nom par rôle, gardés dans le profil, version 3), écran « Ton trio » (onglet Trio ; avant chaque duel et chaque montée ; « Un autre Écho »), arène à 3 contre 3 et 1 à 6 monstres, annonces des deux Échos, part de chacun en fin de combat, création qui enchaîne sur l'étage 1 de la Tour. Acolyte, écran de rencontre et onglet Acolyte retirés. Le jeu joue avec l'IA de bon sens. |
| #57 (PR 2.1) | **La Tour infinie** : monstres au niveau de l'étage (1 + 2,5 par étage) quel que soit le niveau du trio, jusqu'à 6 monstres, somme des PV plafonnée à 3 ; paliers après chaque Gardien (reprise à l'étage 6, 11, 16… avec tous ses PV, par classe, dans le profil) ; « Reprendre » et « Rejouer depuis un palier plus bas » ; un étage déjà franchi rapporte 20 XP au lieu de 40 ; plus d'abandon des monstres au tour 48 ; soins des monstres × 0,75 à chaque usage. Contrôle (40 montées par niveau) : niveau 1 → étage 5 en médiane, niveau 10 → 11, niveau 20 → 18, niveau 30 → 24, de 8 à 13 tours par étage. |

| #59 (PR 2.2) | **Les Faveurs de la Tour** : six Faveurs cumulables (`data/faveurs.json` : Vigueur +4 % de PV max, Puissance +4 % de force, Répit +5 points de PV rendus entre deux étages, Égide une barrière de 8 % au début de chaque étage, Effroi les monstres affaiblis de 10 % pendant 2 tours (50 % au plus), Savoir +10 % d'XP) ; chaque Gardien vaincu pour la première fois avec la classe en propose trois (tirées avec la graine de l'étage), une au choix dans l'écran de fin ; gardées par classe dans le profil, valables seulement dans la Tour, listées dans l'écran de la Tour. Le record et le palier sont enregistrés dès l'étage franchi. Étape `{"gardien": n}` de l'outil de capture. |

Phase 1 du plan terminée (la PR 1.5, le réglage du trio, est reportée à la phase 9). **Phase 2 terminée** (PR 2.1 et 2.2 ; le revenu passif de la 2.2 est reporté à la PR 3.2 ; le réglage « niveau → étage » à la phase 9).

---

## 2. En cours : phase 3, l'équipement (PR 3.1)

**État exact : rien de codé, aucune branche créée.** La PR 3.1 (données et moteur de l'équipement) est la prochaine du plan (`docs/PLAN.md`, phase 3). Avant de la commencer, **demander à Gautier** (questions prévues au § 4 du plan) : l'écart de puissance voulu entre un joueur équipé et un joueur sans équipement à son niveau (le plan propose +30 à +50 %), et les noms des objets (fantasy classique). Si la réponse tarde, avancer avec +40 % et des noms génériques, et le noter dans `docs/JOURNAL-COMBAT-V2.md`.

À savoir pour l'équipement : les fichiers cités par le plan (`engine/combat_unit.gd`, `apply_mods`) sont ceux de l'ancien moteur. Dans le combat V2, les bonus d'un perso passent par `Destin.bonus_valeurs` / `bonus_pv` (les éclats) et par le multiplicateur de classe `k` ; les Faveurs de la Tour (PR 2.2) montrent la façon la plus simple d'ajouter un bonus : modifier `statique[id]` (`pv_max`, `k`) juste après `Regles.nouveau_combat`, jamais pendant le combat. L'équipement devra s'additionner au Destin de la même façon, en duel comme à la Tour.

---

## 3. Ce qui reste à faire (dans l'ordre de `docs/PLAN.md`)

1. **Phase 3, l'équipement** (en cours, ci-dessus) : PR 3.1 données (`data/items.json` : bases, raretés, lignes et fourchettes, plafonds, butin par source) et moteur (`engine/equipment.gd` : tirage d'un objet à graine, `mods`, lié / échangeable, reforge ; l'équipement doit s'additionner au Destin comme les éclats ou le `k`) ; PR 3.2 la Forge (inventaire 5 emplacements, fiche, comparaison, équiper, recycler, reforger), le butin de la Tour (premier passage : échangeable ; rejoué : lié), **les Éclats et le revenu passif** (reporté ici). La PR 3.3 (réglage des lignes) va à la phase 9.
2. **Phase 4, la ville** : `data/ville.json` (bâtiments, positions, écran ouvert), écran ville en portrait, barre du bas réduite (Ville, Chat grisé, Profil), objectifs du jour.
3. **Phase 5, le serveur** (Nakama + PostgreSQL, prévu depuis le début) : comptes, vrais Échos (amis, guilde, proposés ; 3 aides par jour ; récompenses de sélection), PvP asynchrone classé (5 par jour, saisons de 3 mois), chat, Marché et Comptoir, classements. **À demander à Gautier avant de commencer** : l'hébergement du serveur (un service payant ou gratuit, un compte à créer), la durée de saison, les plafonds d'or et d'Éclats.
4. **Phase 6** : guildes (rôles, chat, bannière, Influence), carte du monde, donjons à routes secrètes et portes sans nom, boss unique au serveur, grimoires de classe.
5. **Phase 7** : territoires, guerres du soir, classements et ligues de guilde.
6. **Phase 8** : évolutions de rang 1 (30) et 2 (90), classes de grimoire, PvP synchrone à 6.
7. **Phase 9, l'équilibrage global** : classes et rôles en trio, Soutiens à égalité, courbe « niveau → étage » de la Tour (cible du plan : étage 3 au niveau 1, Gardien 5 vers les niveaux 8–10, étage 10 vers 25–30), lignes d'équipement, Faveurs, bonus de guilde, évolutions. **Adapter d'abord les outils** : `tools/regleur.py` et `tools/regleur_boutons.py` ne savent régler que le duo et l'ancienne Tour (voir les bugs).
8. **Phase 10** : graphismes (art PixelLab, animations, écrans soignés), boutique de cosmétiques, bêta Android puis TestFlight, lancement. **À demander à Gautier** : l'univers et le nom du jeu (trois pistes dans `docs/GDD.md`).

Questions déjà prévues pour Gautier, au bon moment (`docs/PLAN.md`, § 4) : phase 3 (l'écart de puissance voulu entre équipé et non équipé, les noms des objets), phase 5 (saison, plafonds), phase 6 (qui reçoit le grimoire, premiers boss, embranchements des donjons).

---

## 4. Bugs connus et limites

### Équilibre (volontairement pas réglé avant la phase 9)

- **Trio** (mesure de contrôle après la PR #55, 3 000 duels, niveau 30, IA de bon sens) : de 39 % (Voleur) à 69 % (Pugiliste) de victoires selon la classe du joueur ; Guerrier 58 %, Mage 54 %, Archer 54 %, Invocateur 42 % ; médiane de 17 tours (la cible de 18 à 22 était tenue en duo). La première mesure en trio, avant les Soutiens, est en bas de `docs/EQUILIBRAGE-V2.md`.
- **Les Soutiens** ont perdu leurs dégâts (PR #55) : dans la même mesure en trio, Prêtre 44 %, Alchimiste 44 %, Barde 45 %, Diplomate 54 % ; en duo, l'Alchimiste était tombé à 24 %.
- **La Tour** est plus facile que la cible du plan (niveau 1 → étage 5 au lieu de 3 ; niveau 30 → étage 24).
- Les coûts des états dans `data/rules.json` et les `k` des classes sont ceux du réglage du duo (PR #47).

### IA

- Il reste environ 3 « coups perdus » pour 100 actions : l'Écho 1 annonce sans connaître les autres, c'est en partie inévitable. Les « barrières inutiles » des Fronts sont à 3,3.
- L'IA de bon sens ne gagne que 51,7 % contre l'ancienne en trio (56 % en duo) : gain réel mais faible.
- L'IA voit les voies et les menaces de ses adversaires, alors qu'un joueur humain ne voit plus celles des siens (adversaire caché) : avantage à l'IA, à revoir avec le PvP réel.

### Interface

- La rangée de pastilles sous un perso peut dépasser du bord de l'écran quand il en a 5 ou plus (Écho de droite avec menace + 3 états + « +n »).
- Écran « Ton trio » : la ligne « Avec toi » liste presque toujours les quatre Synergies dès le milieu de partie (peu informatif).
- Le signal « CLÉ PRÊTE » n'apparaît pas à bas niveau : les adversaires n'ont pas de Clé allumée avant le niveau 7 (acolyte) ou 11 (perso).
- L'outil « Gagner un niveau » (Paramètres) ouvre l'écran du Destin à chaque niveau.
- Une Faveur du Gardien se choisit dans l'écran de fin ; si le jeu est fermé à cet écran avant le choix, le palier n'a pas avancé : le Gardien se rejoue et la propose encore (voulu). Les Faveurs n'ont pas été mesurées (phase 9).
- L'étape `{"fin":1}` de `tools/capture.gd` ne passe pas la part de chacun : la carte « La part de chacun » n'apparaît pas sur cette capture (elle apparaît en vrai combat).
- Les noms des Échos viennent d'une liste fixe de 12 (`ArenaApp.ECHO_NAMES`).

### Outils et restes

- **`tools/regleur_boutons.py` plante s'il règle la Tour** : il lit `tour.json` → `classes` et `classes_pente`, retirées par la PR #57 (`KeyError`). À réécrire à la phase 9 (la Tour est maintenant absolue).
- `tools/regleur.py` et `tools/regleur_boutons.py` ne règlent que le duo (pas de format trio).
- `.github/workflows/web.yml` publie encore un aperçu de la branche `combat-v2` sous `/v2/` si elle existe (reste de la migration ; inoffensif). Les branches distantes `combat-v2` et `claude/duo-combat-prototype-5n3gqc` sont anciennes (déjà fusionnées ou reportées sur `main`).
- Le moteur garde la notion d'acolyte (place « acolyte », `Destin.acolyte`, `Generateur.acolyte`, clé `acolyte` des classes) pour les tests et le simulateur en duo ; l'application ne s'en sert plus.
- Sur le PC de Gautier, des copies de travail de PR déjà fusionnées restent dans `C:/Users/Gautier/Documents/` (`arena-cache`, `arena-duree`, `arena-ecran`, `arena-gdd2`, `arena-ia`, `arena-reprise`, `arena-soutiens`, `arena-synergies`, `arena-tour`, `arena-trio`, `projet-arena-wt`, `projet-arena-wt2`) : on peut les retirer (`git worktree remove <dossier>` depuis le dépôt principal).
