# Créer le serveur du jeu (Supabase, gratuit) — guide pas à pas pour Gautier

Le jeu sait parler à un serveur Supabase (une base de données en ligne avec des comptes). Tant que `data/serveur.json` n'a pas d'adresse, le jeu fait tourner un **serveur simulé** sur l'appareil. Pour passer au vrai serveur, il faut un projet Supabase : c'est gratuit (palier « Free », pas de carte bancaire), ça prend dix minutes, et seul le propriétaire du projet peut le créer. Voici quoi faire, bouton par bouton. À la fin, tu me donnes deux textes et je branche le jeu.

## 1. Créer le compte et le projet

1. Ouvre **https://supabase.com** et touche **Start your project** (en haut à droite).
2. Crée un compte : **Continue with GitHub** (tu as déjà un compte GitHub : josalystest1-sudo), ou avec une adresse e-mail. Accepte les conditions.
3. Une fois dans le tableau de bord, touche **New project**.
   - **Organization** : laisse celle qui est proposée (ton nom).
   - **Project name** : `projet-arena`.
   - **Database password** : touche **Generate a password** puis copie-le quelque part (tu n'en auras pas besoin pour le jeu, mais Supabase l'exige).
   - **Region** : choisis **West EU (Paris)** ou **Central EU (Frankfurt)**.
   - **Pricing plan** : **Free**.
   - Touche **Create new project** et attends une à deux minutes (une roue tourne).

## 2. Autoriser les comptes anonymes

Le jeu crée un compte par appareil, sans e-mail ni mot de passe. Il faut l'autoriser une fois.

1. Dans le menu de gauche, touche **Authentication** (l'icône avec un personnage).
2. Touche **Sign In / Providers** (ou **Providers**).
3. Dans la liste, trouve **Anonymous sign-ins** et mets l'interrupteur sur **Enabled** (vert), puis **Save**.

## 3. Créer la table des personnages

1. Dans le menu de gauche, touche **SQL Editor** (l'icône avec `>_` ou une feuille).
2. Touche **New query** (ou **+ New query**).
3. Colle tout le contenu du fichier `docs/serveur/supabase.sql` (je peux te l'envoyer tel quel si tu préfères le recevoir dans la conversation).
4. Touche **Run** (en bas à droite, ou Ctrl + Entrée). Tu dois voir « Success. No rows returned ».

## 4. Me donner l'adresse et la clé publique

1. Dans le menu de gauche, tout en bas, touche **Project Settings** (la roue dentée).
2. Touche **API** (ou **Data API**).
3. Copie et envoie-moi deux textes :
   - **Project URL** : une adresse qui ressemble à `https://abcdefghijkl.supabase.co`
   - **anon public** (dans la partie « Project API keys », parfois appelée **publishable key**) : un long texte qui commence par `eyJ…` ou `sb_publishable_…`

Cette clé est **faite pour être dans le jeu** (elle est publique) : ce sont les règles de la table (étape 3) qui empêchent un joueur de modifier la fiche d'un autre. Ne m'envoie jamais la clé **service_role** (secrète), on n'en a pas besoin.

Dès que je les ai, je les mets dans `data/serveur.json`, je republie le jeu, et ton profil affichera « Serveur en ligne · compte connecté ». Tant que ce n'est pas fait, tout marche en mode simulé.

## Ce que le serveur fera, étape par étape

- **PR 5.1** (faite) : le compte, le pseudo, ta fiche publiée (classe, graine, niveau, nœuds allumés, équipement), la liste des joueurs autour de ton niveau.
- **PR 5.2** : les vrais Échos : les personnages des autres joueurs dans ton trio, à leur vrai niveau, trois aides par jour.
- **PR 5.3** : l'Arène contre de vrais personnages, le classement.
- Ensuite : le chat, le Marché, les guildes.

## Si quelque chose coince

- « Connexion impossible » dans le profil : vérifie l'étape 2 (comptes anonymes autorisés).
- « Publication refusée » : vérifie l'étape 3 (la table existe et la requête s'est bien terminée par « Success »).
- Le palier gratuit met le projet **en pause après une semaine sans activité** : dans le tableau de bord, touche **Restore project** ; le jeu repasse en simulé le temps que le projet redémarre.
