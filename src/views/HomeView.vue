<script setup>
import { useAuthStore } from '../stores/auth'

const authStore = useAuthStore()
</script>

<template>
  <section>
    <p class="home-welcome">Welcome back{{ authStore.user ? `, ${authStore.user.email}` : '' }}</p>
  </section>
</template>

<style scoped>
.home-welcome {
  color: var(--shell-text-muted);
}
</style>
