
begin;

create table if not exists public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  email text,
  display_name text,
  timezone text not null default 'America/Los_Angeles',
  default_focus_minutes integer not null default 25 check (default_focus_minutes > 0),
  default_break_minutes integer not null default 5 check (default_break_minutes > 0),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.tasks (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  title text not null,
  notes text,
  category text,
  due_at timestamptz not null,
  priority text not null default 'normal' check (priority in ('low', 'normal', 'high')),
  completed boolean not null default false,
  created_at timestamptz not null default now()
);

create table if not exists public.events (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  title text not null,
  notes text,
  event_type text not null default 'other'
    check (event_type in ('class', 'exam', 'appointment', 'study', 'other')),
  location text,
  starts_at timestamptz not null,
  ends_at timestamptz not null,
  all_day boolean not null default false,
  created_at timestamptz not null default now(),
  check (ends_at > starts_at)
);

-- comp keys
create unique index if not exists tasks_user_id_id_key on public.tasks (user_id, id);
create unique index if not exists events_user_id_id_key on public.events (user_id, id);

-- study sessions
create table if not exists public.study_sessions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  task_id uuid,
  started_at timestamptz not null default now(),
  ended_at timestamptz,
  completed boolean not null default false,
  created_at timestamptz not null default now()
);

alter table public.study_sessions drop constraint if exists study_sessions_task_id_fkey;
alter table public.study_sessions add constraint study_sessions_task_id_fkey
  foreign key (user_id, task_id) references public.tasks (user_id, id)
  on delete set null (task_id);
alter table public.study_sessions drop constraint if exists study_sessions_time_range_check;
alter table public.study_sessions add constraint study_sessions_time_range_check
  check (ended_at is null or ended_at >= started_at);
alter table public.study_sessions drop constraint if exists study_sessions_completed_check;
alter table public.study_sessions add constraint study_sessions_completed_check
  check (not completed or ended_at is not null);

create table if not exists public.notifications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  task_id uuid,
  event_id uuid,
  title text not null,
  message text,
  scheduled_for timestamptz not null default now(),
  read_at timestamptz,
  created_at timestamptz not null default now(),
  check (num_nonnulls(task_id, event_id) <= 1),
  foreign key (user_id, task_id) references public.tasks (user_id, id) on delete cascade,
  foreign key (user_id, event_id) references public.events (user_id, id) on delete cascade
);

create index if not exists tasks_user_due_at_idx on public.tasks (user_id, due_at);
create index if not exists events_user_starts_at_idx on public.events (user_id, starts_at);
create index if not exists study_sessions_user_started_at_idx on public.study_sessions (user_id, started_at);
create index if not exists notifications_user_scheduled_for_idx on public.notifications (user_id, scheduled_for);

-- rls
alter table public.profiles enable row level security;
alter table public.tasks enable row level security;
alter table public.events enable row level security;
alter table public.study_sessions enable row level security;
alter table public.notifications enable row level security;

drop policy if exists "Users manage their own profile" on public.profiles;
create policy "Users manage their own profile" on public.profiles
  for all to authenticated using (auth.uid() = id) with check (auth.uid() = id);

drop policy if exists "Users manage their own tasks" on public.tasks;
create policy "Users manage their own tasks" on public.tasks
  for all to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);

drop policy if exists "Users manage their own events" on public.events;
create policy "Users manage their own events" on public.events
  for all to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);

drop policy if exists "Users manage their own study sessions" on public.study_sessions;
create policy "Users manage their own study sessions" on public.study_sessions
  for all to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);

drop policy if exists "Users manage their own notifications" on public.notifications;
create policy "Users manage their own notifications" on public.notifications
  for all to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- sync auth
create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = '' as $$
begin
  insert into public.profiles (id, email, display_name)
  values (new.id, new.email,
    coalesce(new.raw_user_meta_data->>'display_name', new.raw_user_meta_data->>'name'))
  on conflict (id) do update set email = excluded.email;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
drop trigger if exists on_auth_user_email_updated on auth.users;
create trigger on_auth_user_created
  after insert or update of email on auth.users
  for each row execute function public.handle_new_user();

insert into public.profiles (id, email, display_name)
select id, email, coalesce(raw_user_meta_data->>'display_name', raw_user_meta_data->>'name')
from auth.users on conflict (id) do nothing;

create or replace function public.set_updated_at()
returns trigger language plpgsql set search_path = '' as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists set_profiles_updated_at on public.profiles;
create trigger set_profiles_updated_at before update on public.profiles
  for each row execute function public.set_updated_at();

revoke all on public.profiles, public.tasks, public.events,
  public.study_sessions, public.notifications from anon;
grant usage on schema public to authenticated;
grant select, insert, update, delete on public.profiles, public.tasks,
  public.events, public.study_sessions, public.notifications to authenticated;
revoke all on function public.handle_new_user() from public, anon, authenticated;
revoke all on function public.set_updated_at() from public, anon, authenticated;

commit;
