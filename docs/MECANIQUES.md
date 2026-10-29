# L'éventail des mécaniques de combat

Inventaire du 29 octobre 2026, demandé par Gautier : « la liste de tout ce sur quoi on peut jouer dans une partie », pour ensuite distribuer ces mécaniques aux classes selon leur rôle et leur ambiance. Les kits actuels (`data/`) suivent le tableau du GDD ; cette liste sert à vérifier qu'ils restent cohérents, et à nourrir les Évolutions (étape 7), les nœuds du Destin et le bestiaire.

- ✔ = existe déjà dans le moteur (avec l'exemple qui s'en sert).
- ◇ = idée, pas encore faite. À n'ajouter qu'une fois le reste équilibré, et seulement si c'est lisible en 12 secondes.

**Règle d'or : aucun hasard dans le moteur.** Même situation, même résultat : c'est ce qui rend l'IA prévisible, l'annonce de l'acolyte fiable et l'équilibrage mesurable. Donc jamais de « 20 % de chances ». Une mécanique « aléatoire » dans les autres jeux devient ici :
- une **condition** (ça arrive si la cible est étourdie, si on n'a pas encore agi, si l'allié est KO…),
- un **compte** (un coup sur trois, le troisième coup consécutif, un coup sur N visant l'allié),
- ou une **garantie limitée** (la première fois du combat, une fois par combat, la prochaine attaque).

## 1. Faire des dégâts

- **Éléments** ✔ : tranchant, contondant, perforant (physiques : au contact ou à distance), feu, givre, foudre, lumière, ombre. Les nœuds du Destin renforcent un élément de la classe. ◇ Faiblesses et résistances par élément (un monstre de feu craint le givre). ◇ Poison et acide comme éléments à part entière (aujourd'hui ce sont des états).
- **Formes** ✔ : coup simple ; plusieurs coups (Arc de foudre) ; tous les ennemis (Nova, Sacrifice) ; rebond sur un second ennemi (nœud de Destin) ; dégâts fixes en plus (Éclat) ; frappe en plus d'un autre effet (Cri de guerre, Hymne).
- **Dégâts sur la durée** ✔ : saignement, brûlure, poison (chaque fin de tour). Brasier : chaque coup de feu brûle ✔.
- **Vol de vie** ✔ (Dévorer, Drain d'âme, Synergies).
- **Exécution** ✔ : plus fort sur une cible sous un seuil de PV (Mise à mort).
- **Bonus de situation** ✔ : cible déjà touchée ce tour (Opportuniste) ; cible marquée ; cible qui saigne, brûle ou s'empoisonne (Traqueur) ; coups consécutifs sur la même cible (Enchaîneur) ; Crochet après Jab ; plus fort si on n'a pas encore agi ; plus fort à chaque tour (Crescendo) ; par quart de PV manquant (Colère) ; par allié debout (Meute) ; quand l'allié est KO (Vétéran) ; sous un seuil de PV (Foi) ; sur une seule cible (bonus mono-cible).
- **Ripostes** ✔ : contre-attaque quand on est frappé au contact (Garde haute, Sang acide, Ultimatum). Les flèches et les lancers ne déclenchent pas de riposte ✔.
- **Traverser les barrières** ✔ (Vibrato : une part des dégâts passe).
- **Sacrifice** ✔ : la créature explose.
- ◇ **Coup critique déterministe** : garanti sur une cible étourdie ou gelée (« coup de grâce »), ou sur une cible marquée, ou le troisième coup consécutif, ou la première attaque après une esquive réussie. Affiché en grand, comme une Synergie.
- ◇ **Dégâts à retardement** (bombe : explose 2 tours plus tard, plus fort si la cible n'a pas été soignée entre-temps).
- ◇ **Détonation** : consomme les états négatifs de la cible et fait des dégâts par état consommé (le Mage fait exploser le poison du Voleur).
- ◇ **Perce-armure** : ignore la réduction de dégâts. ◇ **Dégâts selon les PV max** de la cible (contre les gros monstres). ◇ **Dégâts partagés** : une part du coup va au partenaire de la cible.

## 2. Se protéger et survivre

- **Barrières** ✔ : Rempart (tient jusqu'au premier coup ou la fin du tour suivant), Barrière à points (Égide, Bouclier de mana), le soin en trop devient une barrière (Prière). Les barrières ne se cumulent pas ✔. Barrières plus grosses (Sanctuaire, nœuds) ✔.
- **Réduction de dégâts** ✔ : permanente (Peau de fer), physique ou élémentaire seulement, temporaire (En garde).
- **Intouchable** ✔ (Voilé, Enfumé : les attaques directes se rabattent sur l'autre, les zones l'ignorent). **Esquive** ✔ : la première attaque directe est annulée (Fuite, Esquive). **Immunité** à certains états ✔ (Impassible).
- **Détourner les coups** ✔ : provocation (Provocation, Défi, Ultimatum) ; un coup sur N visant l'allié est pris à sa place (Charisme) ; les coups vers l'allié vont à la créature (Lien) ; le Golem encaisse tout ; Martyr partage les dégâts de l'allié.
- **Soins** ✔ : direct, régénération en fin de tour (Régénération, nœuds), baume sur le plus blessé du duo (Baume), soin du duo (Synergies). **Purification** ✔ (retire un état négatif), **retirer un contrôle** ✔ (Protocole). **Relève** ✔ (Résurrection, une fois par combat). **Second souffle** ✔.
- **Trêve** ✔ : deux persos ne peuvent pas se viser ce tour. **Piège** ✔ : le premier ennemi qui frappe l'allié piégé est étourdi.
- ◇ **Renvoi** : une part des dégâts subis repart sur l'attaquant. ◇ **Barrière qui explose** quand elle casse. ◇ **Dernier souffle** : survit à 1 PV une fois par combat. ◇ **Absorber un élément** (un Mage de feu soigné par le feu). ◇ **Interception** : prendre le prochain coup destiné à l'allié, une fois. ◇ **Transfert d'état** : prendre sur soi l'état négatif de l'allié.

## 3. Contrôler l'adversaire

- ✔ **Étourdi** (perd son action, ne dépense pas sa compétence : Berceuse, Piège), **Gelé** (agit en dernier au tour suivant : Trait de givre, Uppercut), **Provoqué**, **Sommé** (Ultimatum : provoqué et chaque coup lui vaut une riposte), **Sous chantage** (forte interdite), **fin de file** et **échange de place** dans la file (Trait de givre, Coup de bouclier), **retarder une recharge** (Sabotage : la forte repart à zéro).
- ◇ **Silence** (moyenne interdite). ◇ **Désarmé** (sa prochaine attaque ne fait que la moitié). ◇ **Enraciné** (ne peut plus changer de cible). ◇ **Peur** (sa forte revient un tour plus tard). ◇ **Sommeil** (étourdi jusqu'au prochain coup reçu). ◇ **Aveuglé** : sa prochaine attaque vise l'ennemi le plus solide (pas de hasard). À éviter : la confusion (jouer contre soi-même), trop punitive en duo.

## 4. Affaiblir (états négatifs sans contrôle)

- ✔ **Affaibli** (inflige X % de moins : Acide, Malédiction), **Marqué** (subit X % de plus : Marque), **saignement, brûlure, poison**.
- ◇ **Lent** (vitesse en moins). ◇ **Vulnérable** à un élément. ◇ **Plaie** (soins reçus réduits). ◇ **Fragile** (barrières moitié moins grosses). ◇ **Corrodé** (réduction de dégâts annulée). ◇ **Épuisé** (sa prochaine compétence a un tour de recharge en plus). ◇ **Maudit** (ses dégâts sur la durée durent un tour de plus).

## 5. Renforcer (états positifs)

- ✔ **Galvanisé** (+dégâts : Cri de guerre, Totem), **Vif** (+vitesse), **Célérité** (agit en premier), **En garde** (moins de dégâts et riposte), **Encouragement** (+dégâts d'un allié), états posés qui durent un tour de plus (Distillation, Virtuose).
- ◇ **Concentré** (sa prochaine compétence +X %). ◇ **Précis** (sa prochaine attaque ignore esquive et intouchable). ◇ **Béni** (soins reçus +X %). ◇ **Endurci** (immunisé aux dégâts sur la durée). ◇ **Inspiré** (sa prochaine moyenne ne lance pas sa recharge). ◇ **Ailé** (agit en premier et +dégâts si personne ne l'a touché au tour d'avant).

## 6. Jouer sur le temps : vitesse, ordre, recharges

- **Ordre de la file** ✔ : vitesse du perso, bonus de vitesse de la compétence, agir en premier (Célérité, Voile le tour d'après), agir en dernier avec bonus (Calme), tout le duo avant les ennemis (Hymne), échange de place, fin de file. À vitesse égale, la priorité alterne ✔.
- **Vitesse** ✔ : +vitesse (Vif, nœuds du Destin), +vitesse par tour sans être touché (Cardio), par ennemi marqué, quand l'allié est KO (Vétéran). ◇ -vitesse (Lent). ◇ **Vol de vitesse** (le Voleur gagne ce qu'il enlève).
- **Recharges** ✔ : plus courtes (Météorologue, Rythme, Doigts agiles, Résonance, nœuds), retardées (Sabotage), remises à zéro chez l'allié (Catalyseur), gratuite une fois (Clé du Destin), raccourcie par Synergie (Hymne + n'importe quelle forte).
- ◇ **Compétence chargée** : plus forte si on l'a gardée prête un tour de plus (récompense l'attente, comme l'acolyte le fait pour une Synergie). ◇ **Rechargement** : la basique rend un tour de recharge à la moyenne.

## 7. Jouer à deux : le duo

- **Synergies** ✔ (un couple de compétences joueur + acolyte le même tour, un effet unique par couple) : amplifier, dégâts en plus, prolonger un état, poser un état (sur la cible, sur le duo, sur tous les ennemis), étendre au partenaire (barrière, soin, état), étendre aux ennemis, recharge raccourcie, soin ou barrière du duo, purification du duo, vol de vie, riposte en plus, la créature frappe ou se soigne.
- **Effets sur le partenaire** ✔ : Encouragement, Fumigène, Piège, Lien, Trêve, Baume, Protocole ; un renfort va au partenaire plutôt qu'à soi (IA).
- **L'attente** ✔ : l'acolyte garde sa forte un tour pour une Synergie au tour suivant.
- ◇ **Relais** : un état posé par l'un est consommé par l'autre (Détonation). ◇ **Couverture** : si les deux visent la même cible le même tour, le second coup est critique. ◇ **Transfert d'état** du partenaire vers soi (Prêtre).

## 8. Créatures et objets posés

- ✔ **Golem** (encaisse les coups du duo), **Spectre** (frappe en fin de tour), **Ordre**, **Lien**, **Sacrifice**, **Pacte**, **Symbiose**, **Essaim**, **Nourrice** ; **Totem** (monstres : galvanise la bande).
- ◇ **Tourelle** (frappe le même ennemi chaque fin de tour, sans PV : disparaît au bout de N tours). ◇ **Mur** (barrière pour les deux, casse au deuxième coup). ◇ **Potion posée** (soigne au début du tour suivant celui du duo qui est le plus bas). ◇ **Familier** qui donne un passif à son maître tant qu'il vit.

## 9. Le cadre du combat (ne pas toucher sans Gautier)

- ✔ Tour simultané de 12 s ; 3 compétences à recharge (basique sans recharge, moyenne 2 tours, forte 4 tours dès le tour 3) ; résolution par vitesse ; mort subite au tour 8 (soins ÷ 2, dégâts +50 % par tour) ; fin forcée au tour 13 ; KO et relève une fois ; à la Tour, 20 % de PV entre les étages et ennemis épuisés au tour 12.
- Interdits (décisions verrouillées) : mana, Tempo, Garde/Brèche, timing en temps réel, pierre-feuille-ciseaux, hasard, puissance vendue.
- Décision du 29 octobre (à confirmer) : en combat, l'adversaire est **opaque** (ni ses sorts, ni son Destin, ni ses recharges) ; seules exceptions, les icônes d'état sur les persos et une lueur « forte prête » ; son Destin peut s'afficher après le combat.

## 10. Proposition de distribution par classe (ambiance → mécaniques)

| Classe (rôle) | Ambiance | Mécaniques qui lui vont | Sa signature (à ne donner à personne d'autre) |
| --- | --- | --- | --- |
| **Guerrier** (Front) | Le mur qui frappe | Rempart, provocation, réduction de dégâts, galvaniser le duo, Colère, échange de place dans la file, coups tranchants et contondants | Le Rempart (bloque un coup entier) et la Provocation du duo |
| **Mage** (Dégâts) | Les éléments | Feu (brûlure), givre (gelé, fin de file), foudre (plusieurs coups, rebond), zones, Bouclier de mana, recharges plus courtes ; ◇ Détonation, Vulnérable | Les zones élémentaires |
| **Voleur** (Dégâts) | Rapide et vicieux | Poison, Vif, esquive, Voile, exécution (Mise à mort), Sabotage, coups perforants ; ◇ vol de vitesse, coup critique sur cible étourdie ou marquée | Voler (recharge, vitesse) et achever |
| **Archer** (Dégâts) | Précis, à distance | Pas de riposte, Marque, Piège, saignement, coups multiples, Traqueur, vitesse par ennemi marqué ; ◇ Précis | La Marque et le Piège |
| **Pugiliste** (Front) | L'enchaînement | Combos (Enchaîneur, Crochet après Jab), Garde haute (riposte), Uppercut (gelé), Cardio, esquive, contondant ; ◇ Concentré | Le combo (plus fort à chaque coup enchaîné) |
| **Prêtre** (Soutien) | La lumière | Soins, Égide, Prière (soin en trop → barrière), purification, Résurrection, Châtiment (lumière), Foi, Martyr ; ◇ Béni, transfert d'état, dernier souffle | Relever et purifier |
| **Alchimiste** (Soutien) | Potions et acides | Acide (Affaibli), poison, Baume, Catalyseur (recharges de l'allié), Fumigène (intouchable), Distillation ; ◇ bombe à retardement, Plaie, potion posée, Corrodé | Les états qui durent et les recharges de l'allié |
| **Barde** (Soutien) | Le rythme | Hymne (le duo agit en premier), Rythme (recharges), Berceuse (étourdi), Crescendo, Vibrato (traverse les barrières), Virtuose ; ◇ Inspiré, Ailé | Jouer sur l'ordre du tour |
| **Diplomate** (Soutien) | La parole | Trêve, Ultimatum, Chantage, Charisme (détourne un coup sur N), Encouragement, Protocole ; ◇ Silence, Peur, Enraciné | Interdire et détourner |
| **Invocateur** (Front) | La créature | Golem, Spectre, Ordre, Lien, Sacrifice, Pacte, Essaim, Nourrice, ombre ; ◇ Tourelle, Familier | La créature |

Les monstres de la Tour piochent dans tout l'éventail sans règle de classe (Meute, Régénération, vol de vie, Totem…), ce qui les rend différents des personnages.

## 11. Avant d'ajouter une mécanique

1. Est-elle lisible en 12 secondes, sans texte à lire ? (Une icône et un chiffre suffisent-ils ?)
2. Se passe-t-elle de hasard ? (Condition, compte ou garantie limitée.)
3. L'IA peut-elle la jouer avec une règle courte et prévisible ?
4. A-t-elle un chiffre réglable (un levier pour le régleur) ? Sinon elle passe par le budget du Destin.
5. Existe-t-il déjà une mécanique proche ? (Fuite et Esquive, Doigts agiles et Rythme sont les mêmes : c'est voulu, un même effet peut servir deux classes avec un habillage différent.)
