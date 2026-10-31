-- Projet Arena, le serveur (phase 5) : la table des fiches de personnage.
-- À coller tel quel dans l'éditeur SQL de Supabase (docs/serveur/GUIDE-SUPABASE.md), puis « Run ».
-- Chaque joueur (un compte anonyme par appareil) a une seule fiche, qu'il est le seul à pouvoir écrire ;
-- tous les joueurs connectés peuvent lire toutes les fiches (Échos, Arène, classements).

create table if not exists public.personnages (
  id uuid primary key references auth.users (id) on delete cascade,
  pseudo text not null,
  classe text not null,
  role text not null,
  graine text not null,
  niveau integer not null default 1,
  allumage jsonb not null default '[]'::jsonb,
  equipement jsonb not null default '[]'::jsonb,
  points integer not null default 0,
  saison integer not null default 0,
  mis_a_jour timestamptz not null default now()
);

create index if not exists personnages_saison_points on public.personnages (saison, points desc);

create index if not exists personnages_role_niveau on public.personnages (role, niveau);

alter table public.personnages enable row level security;

drop policy if exists "lecture par les joueurs connectes" on public.personnages;
create policy "lecture par les joueurs connectes"
  on public.personnages for select
  to authenticated
  using (true);

drop policy if exists "chacun cree sa fiche" on public.personnages;
create policy "chacun cree sa fiche"
  on public.personnages for insert
  to authenticated
  with check (auth.uid() = id);

drop policy if exists "chacun modifie sa fiche" on public.personnages;
create policy "chacun modifie sa fiche"
  on public.personnages for update
  to authenticated
  using (auth.uid() = id)
  with check (auth.uid() = id);

create or replace function public.personnages_touche()
returns trigger
language plpgsql
as $$
begin
  new.mis_a_jour := now();
  return new;
end;
$$;

-- Le Marché : les annonces (anonymes pour les joueurs : le jeu ne montre jamais le vendeur), au premier acheteur.
create table if not exists public.annonces (
  id text primary key,
  vendeur uuid not null references auth.users (id) on delete cascade,
  objet jsonb not null,
  prix integer not null,
  rarete text not null default '',
  niveau integer not null default 1,
  acheteur uuid references auth.users (id) on delete set null,
  encaisse boolean not null default false,
  cree timestamptz not null default now()
);
alter table public.annonces enable row level security;
drop policy if exists "annonces lues par les connectes" on public.annonces;
create policy "annonces lues par les connectes" on public.annonces for select to authenticated using (true);
drop policy if exists "chacun depose ses annonces" on public.annonces;
create policy "chacun depose ses annonces" on public.annonces for insert to authenticated with check (auth.uid() = vendeur);
drop policy if exists "chacun retire ses annonces" on public.annonces;
create policy "chacun retire ses annonces" on public.annonces for delete to authenticated using (auth.uid() = vendeur and acheteur is null);
drop policy if exists "acheter ou encaisser" on public.annonces;
create policy "acheter ou encaisser" on public.annonces for update to authenticated
  using ((acheteur is null and vendeur <> auth.uid()) or vendeur = auth.uid())
  with check ((acheteur = auth.uid() and vendeur <> auth.uid()) or vendeur = auth.uid());

-- L'économie : les mouvements d'Or (créé au Comptoir, détruit par la taxe, échangé entre joueurs), pour le bilan de
-- chaque semaine et la taxe qui monte (engine/economie.gd). Chacun écrit les siens ; tout le monde lit les totaux.
create table if not exists public.mouvements (
  id bigint generated always as identity primary key,
  compte uuid not null references auth.users (id) on delete cascade,
  type text not null check (type in ('comptoir', 'taxe', 'achat')),
  montant integer not null check (montant >= 0),
  jour text not null,
  semaine integer not null,
  cree timestamptz not null default now()
);
create index if not exists mouvements_semaine on public.mouvements (semaine);
alter table public.mouvements enable row level security;
drop policy if exists "mouvements lus par les connectes" on public.mouvements;
create policy "mouvements lus par les connectes" on public.mouvements for select to authenticated using (true);
drop policy if exists "chacun note ses mouvements" on public.mouvements;
create policy "chacun note ses mouvements" on public.mouvements for insert to authenticated with check (auth.uid() = compte);

-- Les guildes (engine/guilde.gd) : la guilde entière dans sa ligne (bannière, effets, membres). Prototype : tout
-- connecté peut la lire ; seul son chef la crée ; ses membres la modifient (le jeu applique les règles avant d'écrire).
create table if not exists public.guildes (
  id text primary key,
  nom text not null,
  banniere jsonb not null,
  chef uuid not null references auth.users (id) on delete cascade,
  influence integer not null default 0,
  influence_totale integer not null default 0,
  effets jsonb not null default '{}'::jsonb,
  membres jsonb not null default '[]'::jsonb,
  cree text not null,
  mis_a_jour timestamptz not null default now()
);
create unique index if not exists guildes_nom on public.guildes (lower(nom));
alter table public.guildes enable row level security;
drop policy if exists "guildes lues par les connectes" on public.guildes;
create policy "guildes lues par les connectes" on public.guildes for select to authenticated using (true);
drop policy if exists "le chef fonde sa guilde" on public.guildes;
create policy "le chef fonde sa guilde" on public.guildes for insert to authenticated with check (auth.uid() = chef);
drop policy if exists "les membres modifient leur guilde" on public.guildes;
create policy "les membres modifient leur guilde" on public.guildes for update to authenticated
  using (membres @> jsonb_build_array(jsonb_build_object('id', auth.uid()::text)) or chef = auth.uid());
drop policy if exists "le chef dissout sa guilde" on public.guildes;
create policy "le chef dissout sa guilde" on public.guildes for delete to authenticated using (chef = auth.uid());

drop trigger if exists personnages_mis_a_jour on public.personnages;
create trigger personnages_mis_a_jour
  before update on public.personnages
  for each row execute function public.personnages_touche();
