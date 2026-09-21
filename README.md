# Schedule Planner - Study Buddy

COMP 585 project — a scheduling app for students with Pomodoro-based focus
sessions, streaks, and a growth mechanic (pet/plant) tied to study habits.

## Tech Stack

- **Frontend:** Vue.js (Vite)
- **Backend/DB:** Supabase (PostgreSQL + Auth)
- **Hosting:** Vercel
- **Language:** JavaScript, SQL

## Getting Started

1. Install dependencies:
   ```
   npm install
   ```
2. Create a Supabase project, then copy `.env.example` to `.env` and fill in
   your project's URL and anon key:
   ```
   cp .env.example .env
   ```
3. Apply the database schema in `supabase/schema.sql` via the Supabase SQL
   editor (or `supabase db push` if using the Supabase CLI).
4. Run the dev server:
   ```
   npm run dev
   ```

## Project Structure

```
src/
  lib/            Supabase client
  stores/         Pinia stores (auth, etc.)
  router/         Vue Router routes and auth guard
  views/          Page-level components (login, calendar, focus, growth, stats, notifications)
  components/     Shared/reusable components
supabase/
  schema.sql      Database schema and row-level security policies
```

## Deployment

The app deploys to Vercel as a static Vite build. Set the `VITE_SUPABASE_URL`
and `VITE_SUPABASE_ANON_KEY` environment variables in the Vercel project
settings.
