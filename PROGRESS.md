# Projet Arena — avancement

Mis à jour le **29 octobre 2026** (PR #61). `main` = la PR #61 fusionnée et publiée (la Forge, le butin, les Éclats, le revenu passif). À lire avec `CLAUDE.md`. Le plan complet, PR par PR, est dans `docs/PLAN.md` (phases 1 à 10) ; l'historique de toutes les PR et des retours de Gautier dans `docs/SUIVI.md`.

Jeu publié (mis à jour à chaque fusion sur `main`) : https://josalystest1-sudo.github.io/projet-arena/ — ajouter `?graine=7` pour des tirages reproductibles.

---

## 1. Terminé et qui fonctionne

Vérifié après la PR #61 : **94 tests passent**, le budget des **210 nœuds** est tenu (`tools/budget.gd`), la CI est verte, le jeu publié se charge (y compris un profil d'avant le trio, qui reçoit ses Échos) et se joue au format téléphone (vérifié dans le navigateur intégré en 375 × 812).

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
| #60 (PR 3.1) | **L'équipement, données et moteur** (décisions de Gautier : +50 % de puissance pour un joueur équipé, noms de fantasy classique, huit lignes par effet) : `data/items.json` (5 emplacements, 14 bases avec leur réserve de 4 lignes, 8 lignes avec fourchette et plafond, 4 raretés, échelle du niveau, butin par source, reforge) ; `engine/equipement.gd` (tirage à graine, qualité en %, jeu complet, butin lié ou échangeable, bonus plafonnés, équiper = lier, reforge d'une ligne à coût croissant, textes et fiche) ; `Destin.mods` lu une fois à la création d'un combat (PV max, Force) et dans chaque valeur selon le type de l'effet et le rang (Clés, Ouvertures) ; sans équipement, le combat est le même au bit près (simulation à graine fixe vérifiée, duo et trio). Le simulateur équipe les camps (dernier argument : une rareté). |
| #61 (PR 3.2) | **La Forge, le butin, les Éclats, le revenu passif** : onglet **Forge** (ce que tu portes par emplacement, tes bonus, ton sac ; la fiche d'un objet : lignes avec fourchette entre crochets, qualité, lié ou échangeable, reforge de chaque ligne contre des Éclats, comparaison « Si tu l'équipes » avant → après ligne par ligne et « Sur ta roue » avec jusqu'à trois exemples « Taillade : 48 → 54 », Équiper (l'objet devient lié), Retirer, Recycler avec confirmation) ; **le butin** à chaque étage franchi de la Tour (`Tour.butin` : du niveau de l'étage, épique au Gardien, échangeable au premier passage, lié sinon, une fois sur deux si rejoué), montré dans l'écran de fin et rangé dans le sac ; **les Éclats** (duel gagné 15, perdu 5 ; étage 10 + 2 × n, moitié si rejoué ; recyclage 5 / 15 / 40 / 100 par rareté) dans le profil, l'accueil et l'écran de fin ; **le revenu passif** à l'ouverture du jeu, une fois par jour de calendrier (3 Éclats et 2 XP par étage du meilleur record, plafonnés à 150 et 120), montré une fois sur l'accueil ; les bonus portés entrent dans la roue du joueur (`Destin.mods`) en duel comme à la Tour ; les fiches des nœuds (Destin, combat) comptent les lignes typées de l'équipement. Profil : section `[forge]` (portés, sac, Éclats, jour du revenu). Étape `{"sac": n}` de l'outil de capture. |

Phase 1 du plan terminée (la PR 1.5, le réglage du trio, est reportée à la phase 9). **Phase 2 terminée** (PR 2.1 et 2.2 ; le revenu passif de la 2.2 est reporté à la PR 3.2 ; le réglage « niveau → étage » à la phase 9). **Phase 3 terminée** (PR 3.1 et 3.2 ; la PR 3.3, le réglage des lignes, va à la phase 9).

---

## 2. En cours : phase 4, la ville et la navigation en portrait (PR 4.1)

**État exact : rien de codé, aucune branche créée.** La phase 3 est finie (PR #60 et #61). La suite du plan (`docs/PLAN.md`, phase 4 ; GDD V2, § 11) : **la ville**, l'écran d'accueil à bâtiments. À faire :

- `data/ville.json` : les bâtiments (identifiant, nom, position sur la carte en portrait, écran ouvert, disponible ou « bientôt ») : la Tour, l'Arène (le duel), le Donjon (bientôt), la Guilde (bientôt), le Comptoir (bientôt), la Forge, la Maison (le personnage et le Destin), la Boutique (bientôt), le Tableau (objectifs du jour, bientôt). Validé par `Donnees` (clés connues).
- `scenes/screens/ville_screen.gd` : la carte en portrait, un bâtiment = une zone touchable avec son nom (sprites provisoires en pixels, comme les persos), qui ouvre l'écran voulu ; le trio en bas ou en haut ; les points de Destin à placer et le revenu du jour signalés.
- **La barre du bas réduite** : Ville, Chat (grisé jusqu'au serveur), Profil. Les onglets Trio, Destin, Forge, La Tour deviennent des bâtiments (le Trio s'ouvre avant chaque combat comme aujourd'hui). Garder `ArenaApp.NAV` et `SCREENS` comme table unique.
- **Les objectifs du jour** (GDD V2, § 10.3, proposé) : trois objectifs simples (un duel, un étage, un objet équipé…), un bonus d'XP et d'Éclats chacun, remis à zéro chaque jour de calendrier (comme le revenu passif). À demander à Gautier s'il les veut maintenant ou à la phase 5.
- **Gautier teste** : se repérer dans la ville sur son téléphone, ouvrir chaque bâtiment, revenir.

Chiffres et textes à la main, sans réglage (phase 9) ; graphismes provisoires (phase 10).

---

## 3. Ce qui reste à faire (dans l'ordre de `docs/PLAN.md`)

1. ~~**Phase 3, l'équipement**~~ : ~~PR 3.1 données et moteur~~ (PR #60) ; ~~PR 3.2 la Forge, le butin, les Éclats, le revenu passif~~ (PR #61). La PR 3.3 (réglage des lignes) va à la phase 9.
2. **Phase 4, la ville** (en cours, ci-dessus) : `data/ville.json` (bâtiments, positions, écran ouvert), écran ville en portrait, barre du bas réduite (Ville, Chat grisé, Profil), objectifs du jour.
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
- **L'équipement** (PR #60) : chiffres de départ à la main. Estimation sur 2 000 jeux épiques tirés au niveau 30 : PV max +15 %, Force +7 %, lignes de valeurs +10 à +15 %, soit une puissance d'environ ×1,46 (Gautier veut +50 %) ; un jeu légendaire ≈ ×1,72, rare ≈ ×1,26, commun ≈ ×1,11. À la Tour (10 montées par classe, niveau 30, trio généré, montées arrêtées à l'étage 21) : nu, l'étage 20 dans 70 à 100 % des montées selon la classe ; en épique, 100 % partout (mesure saturée, détail dans `docs/JOURNAL-COMBAT-V2.md`). À régler à la phase 9 (fourchettes, échelles des raretés, plafonds).

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
- **L'équipement** (PR #61) : les Échos n'en portent pas (ils en auront avec le serveur, quand ce seront de vrais personnages) ; le sac n'a pas de limite ; un objet échangeable n'a nulle part où s'échanger avant le Marché (phase 5) ; le revenu passif compte les jours de calendrier à l'horloge de l'appareil (une fois par jour, sans rattrapage des jours manqués) ; la barre du bas a six onglets (Accueil, Trio, Destin, Forge, La Tour, Profil), serrés : la ville (phase 4) la réduira à trois.
- Pas de trait légendaire sur les objets (le GDD en propose un par objet légendaire, pris dans `docs/MECANIQUES.md`) : à voir avec les donjons (phase 6), d'où viendront les légendaires.
- L'étape `{"fin":1}` de `tools/capture.gd` ne passe pas la part de chacun : la carte « La part de chacun » n'apparaît pas sur cette capture (elle apparaît en vrai combat).
- Les noms des Échos viennent d'une liste fixe de 12 (`ArenaApp.ECHO_NAMES`).

### Outils et restes

- **`tools/regleur_boutons.py` plante s'il règle la Tour** : il lit `tour.json` → `classes` et `classes_pente`, retirées par la PR #57 (`KeyError`). À réécrire à la phase 9 (la Tour est maintenant absolue).
- `tools/regleur.py` et `tools/regleur_boutons.py` ne règlent que le duo (pas de format trio).
- `.github/workflows/web.yml` publie encore un aperçu de la branche `combat-v2` sous `/v2/` si elle existe (reste de la migration ; inoffensif). Les branches distantes `combat-v2` et `claude/duo-combat-prototype-5n3gqc` sont anciennes (déjà fusionnées ou reportées sur `main`).
- Le moteur garde la notion d'acolyte (place « acolyte », `Destin.acolyte`, `Generateur.acolyte`, clé `acolyte` des classes) pour les tests et le simulateur en duo ; l'application ne s'en sert plus.
- Sur le PC de Gautier, des copies de travail de PR déjà fusionnées restent dans `C:/Users/Gautier/Documents/` (`arena-cache`, `arena-duree`, `arena-ecran`, `arena-gdd2`, `arena-ia`, `arena-reprise`, `arena-soutiens`, `arena-synergies`, `arena-tour`, `arena-trio`, `projet-arena-wt`, `projet-arena-wt2`) : on peut les retirer (`git worktree remove <dossier>` depuis le dépôt principal).
