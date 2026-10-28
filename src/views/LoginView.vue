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
    <aside class="auth-page__panel" aria-label="Schedule Planner">
      <div class="auth-page__mark">
        <svg aria-hidden="true" viewBox="0 0 24 24">
          <path d="M5 19C7.4 9.9 13.1 5 21 4c-1 7.9-5.9 13.6-15 16" />
          <path d="M5 19c3.8-4.7 8-8.2 12.5-10.5" />
        </svg>
        <span>Schedule Planner</span>
      </div>

      <div class="auth-page__story">
        <h2>Plan your week.<br />Grow your streak.</h2>
        <p>One calendar for classes, exams and appointments, plus focus sessions that help your garden grow.</p>
      </div>

      <div class="auth-page__stats">
        <div>
          <strong>4,200+</strong>
          <span>Focus sessions logged</span>
        </div>
        <div>
          <strong>98%</strong>
          <span>Assignments never missed</span>
        </div>
      </div>
    </aside>
    <section class="auth-page__content">
      <div class="auth-page__card">
        <p class="auth-page__eyebrow">Welcome back</p>
        <h1>Log in to your planner</h1>
        <p class="auth-page__intro">Pick up your schedule, streak and focus history right where you left off.</p>
        <form @submit.prevent="handleSubmit">
          <label>
            <span>Email</span>
            <input v-model="email" type="email" required autocomplete="email" placeholder="you@example.com" />
          </label>
          <label>
            <span>Password</span>
            <input
              v-model="password"
              type="password"
              required
              autocomplete="current-password"
              placeholder="••••••••"
            />
          </label>
          <div class="auth-page__options">
            <label class="auth-page__remember">
              <input type="checkbox" />
              <span>Remember me</span>
            </label>
            <button type="button" class="auth-page__text-button">Forgot password?</button>
          </div>
          <p v-if="error" class="auth-page__error">{{ error }}</p>
          <button class="auth-page__primary" type="submit" :disabled="loading">
            {{ loading ? 'Logging in...' : 'Log in' }}
          </button>
        </form>
        <div class="auth-page__divider">
          <span></span>
          <p>New to Schedule Planner?</p>
          <span></span>
        </div>
        <RouterLink class="auth-page__secondary" to="/register">Create Account</RouterLink>
      </div>
    </section>
  </div>
</template>

<style scoped>
.auth-page {
  height: 100vh;
  display: flex;
  overflow: hidden;
  background: #f7f4ee;
  color: #25231f;
  font-family: Inter, ui-sans-serif, system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
}

.auth-page__panel {
  position: relative;
  flex: 0 0 42%;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
  min-height: 100svh;
  padding: clamp(30px, 3.6vw, 56px);
  overflow: hidden;
  background: #3f704f;
  box-sizing: border-box;
}

.auth-page__panel::before,
.auth-page__panel::after {
  content: '';
  position: absolute;
  border: 3px solid rgba(232, 244, 230, 0.16);
  border-radius: 50%;
  pointer-events: none;
}

.auth-page__panel::before {
  width: 210px;
  height: 210px;
  top: -44px;
  left: -22px;
}

.auth-page__panel::after {
  width: 430px;
  height: 430px;
  top: -28px;
  right: -70px;
}

.auth-page__mark,
.auth-page__story,
.auth-page__stats {
  position: relative;
  z-index: 1;
}

.auth-page__mark {
  display: flex;
  align-items: center;
  gap: 18px;
  color: #f6f2e9;
  font-family: Georgia, 'Times New Roman', serif;
  font-size: clamp(24px, 2vw, 34px);
  font-weight: 700;
}

.auth-page__mark svg {
  width: 34px;
  height: 34px;
  fill: none;
  stroke: currentColor;
  stroke-linecap: round;
  stroke-linejoin: round;
  stroke-width: 2;
}

.auth-page__story {
  max-width: 660px;
  margin: auto 0;
}

.auth-page__story h2 {
  margin: 0 0 22px;
  color: #f7f4ee;
  font-family: Georgia, 'Times New Roman', serif;
  font-size: clamp(42px, 4.4vw, 66px);
  font-weight: 500;
  line-height: 1.12;
  letter-spacing: 0;
}

.auth-page__story p {
  max-width: 620px;
  margin: 0;
  color: rgba(247, 244, 238, 0.72);
  font-size: clamp(17px, 1.25vw, 22px);
  font-weight: 700;
  line-height: 1.55;
}

.auth-page__stats {
  display: flex;
  gap: clamp(42px, 6vw, 96px);
}

.auth-page__stats div {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.auth-page__stats strong {
  color: #f7f4ee;
  font-family: Georgia, 'Times New Roman', serif;
  font-size: clamp(30px, 2.4vw, 42px);
  line-height: 1;
}

.auth-page__stats span {
  color: rgba(247, 244, 238, 0.68);
  font-size: clamp(14px, 0.95vw, 17px);
  font-weight: 700;
}

.auth-page__content {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: clamp(28px, 6vw, 84px);
  box-sizing: border-box;
}

.auth-page__card {
  width: min(100%, 620px);
  text-align: left;
}

.auth-page__eyebrow {
  margin: 0 0 12px;
  color: #3f704f;
  font-size: 16px;
  font-weight: 900;
  letter-spacing: 0.1em;
  text-transform: uppercase;
}

h1 {
  margin: 0 0 14px;
  color: #22211f;
  font-family: Georgia, 'Times New Roman', serif;
  font-size: clamp(38px, 3.6vw, 52px);
  font-weight: 700;
  line-height: 1.08;
  letter-spacing: 0;
}

.auth-page__intro {
  max-width: 600px;
  margin: 0 0 34px;
  color: #8a8377;
  font-size: 19px;
  font-weight: 700;
  line-height: 1.38;
}

form {
  display: flex;
  flex-direction: column;
  gap: 18px;
}

label {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

label > span {
  color: #5d594f;
  font-size: 16px;
  font-weight: 900;
}

input {
  width: 100%;
  height: 60px;
  border: 2px solid #e7e1d7;
  border-radius: 14px;
  padding: 0 24px;
  box-sizing: border-box;
  background: #ffffff;
  color: #22211f;
  font: 22px/1 Inter, ui-sans-serif, system-ui, sans-serif;
  font-weight: 700;
  letter-spacing: 0;
  outline: none;
  transition:
    border-color 180ms ease,
    box-shadow 180ms ease,
    background 180ms ease;
}

input::placeholder {
  color: #aaa49a;
  opacity: 1;
}

input:focus {
  border-color: #2f563d;
  background: #ffffff;
  box-shadow: 0 0 0 5px rgba(63, 112, 79, 0.13);
}

.auth-page__options {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 20px;
}

.auth-page__remember {
  flex-direction: row;
  align-items: center;
  gap: 14px;
  color: #777064;
  font-size: 18px;
  font-weight: 700;
}

.auth-page__remember input {
  width: 24px;
  height: 24px;
  border-radius: 5px;
  accent-color: #3f704f;
}

.auth-page__text-button {
  border: 0;
  padding: 0;
  background: transparent;
  color: #618765;
  font: 18px/1 Inter, ui-sans-serif, system-ui, sans-serif;
  font-weight: 900;
  letter-spacing: 0;
  cursor: pointer;
  transition: color 180ms ease;
}

.auth-page__text-button:hover {
  color: #cc6938;
}

.auth-page__primary,
.auth-page__secondary {
  width: 100%;
  height: 60px;
  border-radius: 14px;
  box-sizing: border-box;
  font: 20px/1 Inter, ui-sans-serif, system-ui, sans-serif;
  font-weight: 900;
  letter-spacing: 0;
  text-align: center;
  transition:
    transform 180ms ease,
    box-shadow 180ms ease,
    border-color 180ms ease,
    background 180ms ease;
}

.auth-page__primary {
  border: 0;
  background: #cc6938;
  color: #ffffff;
  cursor: pointer;
  box-shadow: 0 14px 30px rgba(204, 105, 56, 0.24);
}

.auth-page__primary:hover:not(:disabled) {
  transform: translateY(-1px);
  box-shadow: 0 18px 36px rgba(204, 105, 56, 0.3);
}

.auth-page__primary:disabled {
  cursor: wait;
  opacity: 0.75;
}

.auth-page__divider {
  display: grid;
  grid-template-columns: 1fr auto 1fr;
  align-items: center;
  gap: 20px;
  margin: 34px 0 22px;
  color: #b7afa3;
}

.auth-page__divider span {
  height: 1px;
  background: #e5ded3;
}

.auth-page__divider p {
  margin: 0;
  font-size: 17px;
  font-weight: 800;
  line-height: 1;
  white-space: nowrap;
}

.auth-page__secondary {
  display: flex;
  align-items: center;
  justify-content: center;
  border: 2px solid #e7e1d7;
  color: #33302b;
  background: #ffffff;
  text-decoration: none;
}

.auth-page__secondary:hover {
  border-color: #6a6864;
  background: #ffffff;
  transform: translateY(-1px);
}

.auth-page__error {
  color: #c0392b;
  margin: 0;
  font-family: system-ui, sans-serif;
  font-size: 16px;
  line-height: 1.3;
}

@media (max-width: 900px) {
  .auth-page {
    height: auto;
    min-height: 100vh;
    flex-direction: column;
    overflow: visible;
  }

  .auth-page__panel {
    flex: none;
    min-height: 360px;
    padding: 28px;
  }

  .auth-page__panel::before {
    width: 150px;
    height: 150px;
  }

  .auth-page__panel::after {
    width: 260px;
    height: 260px;
  }

  .auth-page__story h2 {
    font-size: 42px;
  }

  .auth-page__story p,
  .auth-page__stats {
    display: none;
  }

  .auth-page__content {
    flex: 1;
    padding: 40px 24px;
  }

  h1 {
    font-size: 38px;
  }

  .auth-page__intro {
    margin-bottom: 36px;
    font-size: 18px;
  }

  input,
  .auth-page__primary,
  .auth-page__secondary {
    height: 58px;
    font-size: 17px;
  }

  .auth-page__options {
    align-items: flex-start;
    flex-direction: column;
  }

  .auth-page__remember {
    font-size: 16px;
  }

  .auth-page__text-button {
    font-size: 16px;
  }

  .auth-page__divider {
    margin-top: 42px;
    gap: 12px;
  }

  .auth-page__divider p {
    font-size: 14px;
  }
}
</style>
