<script setup>
import { computed } from 'vue'
import { RouterView, useRoute, useRouter } from 'vue-router'
import { useAuthStore } from './stores/auth'

const NAV_ITEMS = [
  { name: 'home', label: 'Home', to: '/' },
  { name: 'focus', label: 'Focus Session', to: '/focus' },
  { name: 'growth', label: 'Growth', to: '/growth' },
  { name: 'stats', label: 'Stats', to: '/stats' },
  { name: 'notifications', label: 'Notifications', to: '/notifications' },
]

const authStore = useAuthStore()
const route = useRoute()
const router = useRouter()

const userInitial = computed(() => authStore.user?.email?.[0]?.toUpperCase() ?? '?')

async function handleSignOut() {
  await authStore.signOut()
  router.push({ name: 'login' })
}
</script>

<template>
  <div v-if="!authStore.loading" class="app-shell">
    <template v-if="authStore.user">
      <aside class="app-sidebar">
        <div class="app-sidebar__brand">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6">
            <path d="M4 20c1-8 6-13 15-15-2 9-7 14-15 15Z" />
            <path d="M4.5 19.5c2-5 5-9 10-12" />
          </svg>
          <span>Schedule<br />Planner</span>
        </div>

        <nav class="app-sidebar__nav">
          <RouterLink
            v-for="item in NAV_ITEMS"
            :key="item.name"
            :to="item.to"
            class="app-sidebar__nav-item"
            :class="{ 'app-sidebar__nav-item--active': route.name === item.name }"
          >
            <svg v-if="item.name === 'home'" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6">
              <path d="M3 10.5 12 3l9 7.5" />
              <path d="M5 9.5V21h5v-6h4v6h5V9.5" />
            </svg>
            <svg v-else-if="item.name === 'focus'" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6">
              <circle cx="12" cy="12" r="9" />
              <path d="M12 7v5l3 2" />
            </svg>
            <svg v-else-if="item.name === 'growth'" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6">
              <path d="M12 21c-5-1-8-5-8-10 7 0 11-2 16-9 0 9-3 16-8 19Z" />
            </svg>
            <svg v-else-if="item.name === 'stats'" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6">
              <path d="M5 20V11M12 20V5M19 20v-7" />
            </svg>
            <svg v-else viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6">
              <path d="M6 9a6 6 0 1 1 12 0c0 4 1.5 5.5 2 6H4c.5-.5 2-2 2-6Z" />
              <path d="M10 19a2 2 0 0 0 4 0" />
            </svg>
            {{ item.label }}
          </RouterLink>
        </nav>

        <div class="app-sidebar__user">
          <span class="app-sidebar__avatar">{{ userInitial }}</span>
          <span class="app-sidebar__email">{{ authStore.user?.email }}</span>
          <button type="button" class="app-sidebar__signout" @click="handleSignOut">Sign out</button>
        </div>
      </aside>

      <main class="app-main">
        <header class="app-main__header">
          <h1>{{ route.meta.title }}</h1>
        </header>
        <RouterView />
      </main>
    </template>

    <main v-else class="app-main app-main--auth">
      <RouterView />
    </main>
  </div>
</template>

<style scoped>
.app-shell {
  --shell-bg: #f7f4ee;
  --shell-card: #ffffff;
  --shell-border: #e5ded3;
  --shell-text: #22211f;
  --shell-text-muted: #777064;
  --shell-green: #3f704f;
  --shell-green-soft: #e4ece3;
  --shell-orange: #cc6938;
  --shell-serif: Georgia, 'Iowan Old Style', 'Palatino Linotype', 'Book Antiqua', serif;

  min-height: 100vh;
  display: flex;
  background: var(--shell-bg);
  color: var(--shell-text);
}

.app-sidebar {
  width: 240px;
  flex-shrink: 0;
  display: flex;
  flex-direction: column;
  padding: 1.75rem 1.25rem;
  border-right: 1px solid var(--shell-border);
}

.app-sidebar__brand {
  display: flex;
  align-items: center;
  gap: 0.6rem;
  font-family: var(--shell-serif);
  font-weight: 700;
  font-size: 1.1rem;
  line-height: 1.15;
  margin-bottom: 2rem;
}

.app-sidebar__brand svg {
  width: 24px;
  height: 24px;
  color: var(--shell-green);
  flex-shrink: 0;
}

.app-sidebar__nav {
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
  flex: 1;
}

.app-sidebar__nav-item {
  display: flex;
  align-items: center;
  gap: 0.65rem;
  padding: 0.55rem 0.7rem;
  border-radius: 10px;
  color: var(--shell-text-muted);
  text-decoration: none;
  font-size: 0.92rem;
}

.app-sidebar__nav-item svg {
  width: 18px;
  height: 18px;
  flex-shrink: 0;
}

.app-sidebar__nav-item--active {
  background: var(--shell-green-soft);
  color: var(--shell-green);
  font-weight: 600;
}

.app-sidebar__user {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  gap: 0.6rem;
  padding-top: 1rem;
  border-top: 1px solid var(--shell-border);
}

.app-sidebar__avatar {
  width: 32px;
  height: 32px;
  border-radius: 50%;
  background: var(--shell-green);
  color: #fff;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 0.85rem;
  font-weight: 700;
  flex-shrink: 0;
}

.app-sidebar__email {
  font-size: 0.8rem;
  color: var(--shell-text-muted);
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  flex: 1;
  min-width: 0;
}

.app-sidebar__signout {
  width: 100%;
  margin-top: 0.4rem;
  padding: 0.4rem 0;
  border: 1px solid var(--shell-border);
  border-radius: 8px;
  background: #fff;
  color: var(--shell-text-muted);
  font-size: 0.8rem;
  cursor: pointer;
}

.app-sidebar__signout:hover {
  color: var(--shell-text);
}

.app-main {
  flex: 1;
  min-width: 0;
  padding: 2.5rem 2rem;
}

.app-main--auth {
  padding: 0;
}

.app-main__header h1 {
  font-family: var(--shell-serif);
  font-size: 2rem;
  font-weight: 700;
  margin: 0 0 1.5rem;
  color: var(--shell-text);
}

@media (max-width: 960px) {
  .app-shell {
    flex-direction: column;
  }
  .app-sidebar {
    width: auto;
  }
}
</style>