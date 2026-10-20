<script setup>
import { computed, onBeforeUnmount, ref, watch } from 'vue'

const workMinutes = ref(25)
const breakMinutes = ref(5)

const mode = ref('work') // 'work' | 'break'
const remainingSeconds = ref(workMinutes.value * 60)
const running = ref(false)
const completedSessions = ref(0)

let intervalId = null

const minutesLabel = computed(() => Math.floor(remainingSeconds.value / 60))
const secondsLabel = computed(() => String(remainingSeconds.value % 60).padStart(2, '0'))

function tick() {
  if (remainingSeconds.value > 0) {
    remainingSeconds.value -= 1
    return
  }
  if (mode.value === 'work') {
    completedSessions.value += 1
    mode.value = 'break'
    remainingSeconds.value = breakMinutes.value * 60
  } else {
    mode.value = 'work'
    remainingSeconds.value = workMinutes.value * 60
  }
}

function start() {
  if (running.value) return
  running.value = true
  intervalId = setInterval(tick, 1000)
}

function pause() {
  running.value = false
  clearInterval(intervalId)
  intervalId = null
}

function reset() {
  pause()
  mode.value = 'work'
  remainingSeconds.value = workMinutes.value * 60
}

function skip() {
  if (mode.value === 'work') {
    completedSessions.value += 1
    mode.value = 'break'
    remainingSeconds.value = breakMinutes.value * 60
  } else {
    mode.value = 'work'
    remainingSeconds.value = workMinutes.value * 60
  }
}

watch([workMinutes, breakMinutes], () => {
  if (running.value) return
  remainingSeconds.value = (mode.value === 'work' ? workMinutes.value : breakMinutes.value) * 60
})

onBeforeUnmount(() => {
  clearInterval(intervalId)
})
</script>

<template>
  <section class="focus-page">
    <h1>Focus Session</h1>
    <p class="focus-page__intro">Configurable Pomodoro timer with work/break intervals.</p>

    <div class="focus-page__timer" :class="`focus-page__timer--${mode}`">
      <span class="focus-page__mode">{{ mode === 'work' ? 'Focus' : 'Break' }}</span>
      <span class="focus-page__clock">{{ minutesLabel }}:{{ secondsLabel }}</span>
    </div>

    <div class="focus-page__controls">
      <button type="button" @click="start" :disabled="running">Start</button>
      <button type="button" @click="pause" :disabled="!running">Pause</button>
      <button type="button" @click="skip">Skip</button>
      <button type="button" @click="reset">Reset</button>
    </div>

    <div class="focus-page__settings">
      <label>
        Work minutes
        <input v-model.number="workMinutes" type="number" min="1" max="120" :disabled="running" />
      </label>
      <label>
        Break minutes
        <input v-model.number="breakMinutes" type="number" min="1" max="60" :disabled="running" />
      </label>
    </div>

    <p class="focus-page__sessions">Completed focus sessions today: {{ completedSessions }}</p>
  </section>
</template>

<style scoped>
.focus-page {
  max-width: 420px;
  margin: 0 auto;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 1.5rem;
  text-align: center;
}

.focus-page__intro {
  color: var(--text);
}

.focus-page__timer {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 0.5rem;
  padding: 2.5rem 3rem;
  border-radius: 16px;
  border: 1px solid var(--border);
  background: var(--accent-bg);
}

.focus-page__timer--break {
  background: var(--code-bg);
}

.focus-page__mode {
  font-size: 0.9rem;
  text-transform: uppercase;
  letter-spacing: 0.08em;
  color: var(--accent);
}

.focus-page__clock {
  font-family: var(--mono);
  font-size: 3.5rem;
  color: var(--text-h);
}

.focus-page__controls {
  display: flex;
  gap: 0.75rem;
}

.focus-page__settings {
  display: flex;
  gap: 1.5rem;
}

.focus-page__settings label {
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
  font-size: 0.9rem;
}

.focus-page__settings input {
  width: 4rem;
}

.focus-page__sessions {
  color: var(--text);
}
</style>
