<script setup>
import { computed } from 'vue'
import { RouterLink, RouterView, useRouter } from 'vue-router'
import { useAuthStore } from './stores/auth'

const authStore = useAuthStore()
const router = useRouter()
const initial = computed(() => (authStore.user?.email?.charAt(0) || 'S').toUpperCase())
const navigation = [
  { to: '/', label: 'Home', icon: 'M3 10 12 3l9 7M5 9v12h5v-7h4v7h5V9' },
  { to: '/calendar', label: 'Calendar', icon: 'M5 5h14a2 2 0 0 1 2 2v12a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V7a2 2 0 0 1 2-2ZM7 3v4m10-4v4M3 11h18' },
  { to: '/focus', label: 'Focus Session', icon: 'M12 8v5l3 2M22 12a10 10 0 1 1-20 0 10 10 0 0 1 20 0' },
  { to: '/growth', label: 'Growth', icon: 'M4 12c8 0 13-3 16-9 0 12-3 18-9 18-4 0-7-4-7-9Zm1 8 10-10' },
  { to: '/stats', label: 'Stats', icon: 'M5 20v-8m7 8V5m7 15v-6' },
  { to: '/notifications', label: 'Notifications', icon: 'M18 8a6 6 0 0 0-12 0c0 7-3 7-3 9h18c0-2-3-2-3-9M10 21h4' },
]

async function handleSignOut() {
  await authStore.signOut()
  router.push({ name: 'login' })
}
</script>

<template>
  <div v-if="!authStore.loading" class="app-shell" :class="{ 'app-shell--signed-in': authStore.user }">
    <aside v-if="authStore.user" class="app-sidebar">
      <RouterLink to="/" class="app-brand" aria-label="Schedule Planner home">
        <svg viewBox="0 0 32 32" fill="none" aria-hidden="true"><path d="M5 27C5 14 14 7 27 4 25 17 18 26 5 27Zm0 0L23 9" /></svg>
        <span>Schedule<br />Planner</span>
      </RouterLink>
      <nav class="app-nav" aria-label="Main navigation">
        <RouterLink v-for="item in navigation" :key="item.to" :to="item.to" class="app-nav__link" exact-active-class="app-nav__link--active">
          <svg viewBox="0 0 24 24" fill="none" aria-hidden="true"><path :d="item.icon" /></svg>
          <span>{{ item.label }}</span>
        </RouterLink>
      </nav>
      <div class="app-account">
        <span class="app-account__avatar" aria-hidden="true">{{ initial }}</span>
        <div class="app-account__details">
          <span class="app-account__email" :title="authStore.user.email">{{ authStore.user.email }}</span>
          <button type="button" class="app-account__signout" @click="handleSignOut">Sign out</button>
        </div>
      </div>
    </aside>
    <main class="app-main" :class="{ 'app-main--auth': !authStore.user }">
      <RouterView />
    </main>
  </div>
</template>

<style scoped>
.app-shell { min-height: 100svh; }
.app-shell--signed-in { min-height: 100svh; display: grid; grid-template-columns: clamp(240px, 20vw, 320px) minmax(0, 1fr); }
.app-sidebar { position: sticky; top: 0; height: 100svh; display: flex; flex-direction: column; gap: 48px; padding: 32px 24px 24px; border-right: 1px solid var(--border); overflow-y: auto; }
.app-brand { display: flex; align-items: center; gap: 16px; color: var(--text-h); font: 700 28px/1.05 var(--heading); text-decoration: none; }
.app-brand svg { width: 28px; height: 32px; flex-shrink: 0; stroke: var(--accent); stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
.app-nav { display: flex; flex-direction: column; gap: 8px; }
.app-nav__link { display: flex; align-items: center; gap: 16px; padding: 14px 16px; border-radius: 12px; color: var(--text); text-decoration: none; font-size: 18px; }
.app-nav__link svg { width: 22px; height: 22px; flex-shrink: 0; stroke: currentColor; stroke-width: 1.7; stroke-linecap: round; stroke-linejoin: round; }
.app-nav__link:hover { background: #e9ecdf; }
.app-nav__link--active { background: var(--accent-bg); color: var(--accent); font-weight: 600; }
.app-account { margin-top: auto; padding-top: 20px; border-top: 1px solid var(--border); display: flex; align-items: center; gap: 12px; min-width: 0; }
.app-account__avatar { display: grid; place-items: center; width: 38px; height: 38px; flex-shrink: 0; border-radius: 50%; background: var(--accent); color: #fff; font-weight: 600; }
.app-account__details { min-width: 0; }
.app-account__email { display: block; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; font-size: 14px; }
.app-account__signout { background: transparent; border: 0; padding: 2px 0; color: var(--text); font-size: 12px; cursor: pointer; }
.app-account__signout:hover { color: var(--accent); text-decoration: underline; }

.app-main { min-width: 0; padding: clamp(24px, 3vw, 48px); }
@media (max-width: 1000px) and (min-width: 701px) {
  .app-shell--signed-in { grid-template-columns: 220px minmax(0, 1fr); }
  .app-sidebar { padding: 28px 16px 20px; }
  .app-nav__link { padding: 12px; gap: 12px; font-size: 16px; }
}
@media (max-width: 700px) {
  .app-shell--signed-in { display: flex; flex-direction: column; }
  .app-sidebar { position: static; height: auto; gap: 20px; border-right: 0; border-bottom: 1px solid var(--border); }
  .app-nav { flex-direction: row; overflow-x: auto; }
  .app-nav__link { flex-shrink: 0; padding: 10px; gap: 8px; font-size: 14px; }
  .app-account { margin-top: 0; }
}

.app-main--auth { min-height: 100svh; }
</style>
