-- Schedule Planner - Study Buddy
--
-- Supabase Auth handles logins, users, password hashing, sessions, and tokens
-- in Supabase's built-in auth schema.

create table if not exists public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  email text,
  display_name text,
  timezone text not null default 'America/Los_Angeles',
  default_focus_minutes integer not null default 25,
  default_break_minutes integer not null default 5,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint profiles_default_focus_minutes_check check (default_focus_minutes > 0),
  constraint profiles_default_break_minutes_check check (default_break_minutes > 0)
);

alter table public.profiles enable row level security;

drop policy if exists "Users manage their own profile" on public.profiles;

create policy "Users manage their own profile" on public.profiles
  for all using (auth.uid() = id) with check (auth.uid() = id);

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists set_profiles_updated_at on public.profiles;

create trigger set_profiles_updated_at
  before update on public.profiles
  for each row execute function public.set_updated_at();

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, email, display_name)
  values (
    new.id,
    new.email,
    coalesce(new.raw_user_meta_data->>'display_name', new.raw_user_meta_data->>'name')
  )
  on conflict (id) do nothing;

  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

create table if not exists public.tasks (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  title text not null,
  notes text,
  category text,
  due_at timestamptz not null,
  priority text not null default 'normal',
  completed boolean not null default false,
  created_at timestamptz not null default now(),
  constraint tasks_priority_check check (priority in ('low', 'normal', 'high'))
);

alter table public.tasks enable row level security;

create policy "Users manage their own tasks" on public.tasks
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

create table if not exists public.study_sessions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  task_id uuid references public.tasks (id) on delete set null,
  started_at timestamptz not null default now(),
  ended_at timestamptz,
  completed boolean not null default false,
  created_at timestamptz not null default now()
);

alter table public.study_sessions enable row level security;

create policy "Users manage their own study sessions" on public.study_sessions
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
