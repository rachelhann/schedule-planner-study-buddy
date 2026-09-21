-- Schedule Planner - Study Buddy
-- Initial schema for Supabase (PostgreSQL)
-- Run in the Supabase SQL editor, or via `supabase db push`.

-- Calendar events: tasks, exams, appointments, birthdays, etc.
create table if not exists public.events (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  title text not null,
  description text,
  category text not null default 'task', -- task, exam, appointment, birthday, study_session
  start_at timestamptz not null,
  end_at timestamptz,
  completed boolean not null default false,
  notify boolean not null default true,
  created_at timestamptz not null default now()
);

-- Focus (Pomodoro) sessions
create table if not exists public.focus_sessions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  event_id uuid references public.events (id) on delete set null,
  work_minutes integer not null default 25,
  break_minutes integer not null default 5,
  started_at timestamptz not null default now(),
  ended_at timestamptz,
  status text not null default 'in_progress', -- in_progress, completed, cancelled
  created_at timestamptz not null default now()
);

-- Per-user growth/streak stats, derived from completed focus sessions
create table if not exists public.user_stats (
  user_id uuid primary key references auth.users (id) on delete cascade,
  total_completed_sessions integer not null default 0,
  current_streak integer not null default 0,
  last_completed_date date,
  updated_at timestamptz not null default now()
);

-- Shared events/schedules between users
create table if not exists public.event_shares (
  id uuid primary key default gen_random_uuid(),
  event_id uuid not null references public.events (id) on delete cascade,
  shared_by uuid not null references auth.users (id) on delete cascade,
  shared_with uuid not null references auth.users (id) on delete cascade,
  created_at timestamptz not null default now()
);

alter table public.events enable row level security;
alter table public.focus_sessions enable row level security;
alter table public.user_stats enable row level security;
alter table public.event_shares enable row level security;

create policy "Users manage their own events" on public.events
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy "Users manage their own focus sessions" on public.focus_sessions
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy "Users manage their own stats" on public.user_stats
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy "Users see shares they sent or received" on public.event_shares
  for select using (auth.uid() = shared_by or auth.uid() = shared_with);

create policy "Users create shares from their own events" on public.event_shares
  for insert with check (auth.uid() = shared_by);
