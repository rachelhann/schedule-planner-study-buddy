<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '../stores/auth'

const email = ref('')
const password = ref('')
const error = ref('')
const message = ref('')
const loading = ref(false)

const authStore = useAuthStore()
const router = useRouter()

async function handleSubmit() {
  error.value = ''
  message.value = ''
  loading.value = true
  try {
    const data = await authStore.signUp(email.value, password.value)
    if (data.session) {
      router.push({ name: 'home' })
    } else {
      message.value = 'Check your email to confirm your account before logging in.'
    }
  } catch (err) {
    error.value = err.message
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <div class="auth-page">
    <h1>Register</h1>
    <form @submit.prevent="handleSubmit">
      <label>
        Email
        <input v-model="email" type="email" required autocomplete="email" />
      </label>
      <label>
        Password
        <input v-model="password" type="password" required minlength="6" autocomplete="new-password" />
      </label>
      <p v-if="error" class="auth-page__error">{{ error }}</p>
      <p v-if="message" class="auth-page__message">{{ message }}</p>
      <button type="submit" :disabled="loading">{{ loading ? 'Creating account…' : 'Register' }}</button>
    </form>
    <p>Already have an account? <RouterLink to="/login">Log in</RouterLink></p>
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

.auth-page__message {
  color: #2c7a4b;
  margin: 0;
}
</style>
