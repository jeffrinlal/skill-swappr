-- ============================================================================
--  SKILL SWAPPR - DATABASE SCHEMA (Phase 1: Foundation + Auth)
-- ============================================================================
--  HOW TO RUN: Supabase -> SQL Editor -> New query -> paste -> Run
-- ============================================================================

-- 1. PROFILES TABLE (one row per user, everyone starts with 3 credits)
create table if not exists public.profiles (
  id          uuid primary key references auth.users(id) on delete cascade,
  full_name   text,
  bio         text,
  avatar_url  text,
  credits     integer not null default 3,
  rating      numeric(2,1) not null default 0.0,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

-- 2. ROW LEVEL SECURITY
alter table public.profiles enable row level security;

create policy "Profiles are viewable by everyone"
  on public.profiles for select
  using (true);

create policy "Users can insert their own profile"
  on public.profiles for insert
  with check (auth.uid() = id);

create policy "Users can update their own profile"
  on public.profiles for update
  using (auth.uid() = id);

-- 3. AUTO-CREATE PROFILE ON SIGNUP
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.profiles (id, full_name)
  values (new.id, new.raw_user_meta_data ->> 'full_name');
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();
