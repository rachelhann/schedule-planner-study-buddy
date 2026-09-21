<script setup>
import { RouterLink, RouterView } from 'vue-router'
import { useAuthStore } from './stores/auth'

const authStore = useAuthStore()

async function handleSignOut() {
  await authStore.signOut()
}
</script>

<template>
  <div v-if="!authStore.loading" class="app-shell">
    <nav v-if="authStore.user" class="app-nav">
      <span class="app-nav__brand">Schedule Planner</span>
      <RouterLink to="/">Home</RouterLink>
      <RouterLink to="/calendar">Calendar</RouterLink>
      <RouterLink to="/focus">Focus</RouterLink>
      <RouterLink to="/growth">Growth</RouterLink>
      <RouterLink to="/stats">Stats</RouterLink>
      <RouterLink to="/notifications">Notifications</RouterLink>
      <button type="button" class="app-nav__signout" @click="handleSignOut">Sign out</button>
    </nav>
    <main class="app-main">
      <RouterView />
    </main>
  </div>
</template>

<style scoped>
.app-shell {
  min-height: 100vh;
  display: flex;
  flex-direction: column;
}

.app-nav {
  display: flex;
  align-items: center;
  gap: 1.25rem;
  padding: 0.75rem 1.5rem;
  border-bottom: 1px solid #e2e2e2;
}

.app-nav__brand {
  font-weight: 700;
  margin-right: 0.5rem;
}

.app-nav__signout {
  margin-left: auto;
}

.app-main {
  flex: 1;
  padding: 1.5rem;
}
</style>
