# Schedule Planner - Study Buddy

A scheduling app for students with Pomodoro-based focus
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
2. Create .env file in project root

3. Paste env variables into .env file
   
4. TODO: Apply the database schema in `supabase/schema.sql` via the Supabase SQL
   editor (or `supabase db push` if using the Supabase CLI).
5. Run the dev server:
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
