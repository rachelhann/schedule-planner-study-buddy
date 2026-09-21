<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '../stores/auth'

const email = ref('')
const password = ref('')
const error = ref('')
const loading = ref(false)

const authStore = useAuthStore()
const router = useRouter()

async function handleSubmit() {
  error.value = ''
  loading.value = true
  try {
    await authStore.signIn(email.value, password.value)
    router.push({ name: 'home' })
  } catch (err) {
    error.value = err.message
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <div class="auth-page">
    <h1>Log in</h1>
    <form @submit.prevent="handleSubmit">
      <label>
        Email
        <input v-model="email" type="email" required autocomplete="email" />
      </label>
      <label>
        Password
        <input v-model="password" type="password" required autocomplete="current-password" />
      </label>
      <p v-if="error" class="auth-page__error">{{ error }}</p>
      <button type="submit" :disabled="loading">{{ loading ? 'Logging in…' : 'Log in' }}</button>
    </form>
    <p>No account? <RouterLink to="/register">Register</RouterLink></p>
  </div>
</template>

<style scoped>
.auth-page {
  max-width: 320px;
  margin: 4rem auto;
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

form {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}

label {
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
}

.auth-page__error {
  color: #c0392b;
  margin: 0;
}
</style>
