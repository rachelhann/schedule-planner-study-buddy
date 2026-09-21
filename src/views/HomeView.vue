<script setup>
import { useAuthStore } from '../stores/auth'

const authStore = useAuthStore()
</script>

<template>
  <section>
    <h1>Welcome back{{ authStore.user ? `, ${authStore.user.email}` : '' }}</h1>
    <p>Your week-ahead schedule view goes here.</p>
  </section>
</template>
