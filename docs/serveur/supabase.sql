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

drop trigger if exists personnages_mis_a_jour on public.personnages;
create trigger personnages_mis_a_jour
  before update on public.personnages
  for each row execute function public.personnages_touche();
