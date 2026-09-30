-- Schedule Planner - Study Buddy
--
-- Supabase Auth handles logins, users, password hashing, sessions, and tokens
-- in Supabase's built-in auth schema.

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
