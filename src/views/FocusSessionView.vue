<script setup>
import { computed, onBeforeUnmount, ref, watch } from 'vue'
import { useAuthStore } from '../stores/auth'

const authStore = useAuthStore()

const PRESETS = [
  { key: '25-5', label: '25 / 5', work: 25, break: 5 },
  { key: '50-10', label: '50 / 10', work: 50, break: 10 },
]
const GROWTH_STAGES = ['Seedling', 'Sprouting', 'Budding', 'Blooming', 'Flourishing']
const SESSIONS_PER_STAGE = 3
const TARGET_ROUNDS = 4

const activePreset = ref(PRESETS[0].key)
const workMinutes = ref(PRESETS[0].work)
const breakMinutes = ref(PRESETS[0].break)

const mode = ref('work') // 'work' | 'break'
const remainingSeconds = ref(workMinutes.value * 60)
const running = ref(false)
const completedSessions = ref(0)

let intervalId = null

const totalSeconds = computed(() => Math.max(1, mode.value === 'work' ? workMinutes.value : breakMinutes.value) * 60)
const minutesLabel = computed(() => Math.floor(remainingSeconds.value / 60))
const secondsLabel = computed(() => String(remainingSeconds.value % 60).padStart(2, '0'))

const ringCircumference = 2 * Math.PI * 90
const ringOffset = computed(() => {
  const elapsedFraction = 1 - remainingSeconds.value / totalSeconds.value
  return ringCircumference * (1 - elapsedFraction)
})

const currentRound = computed(() => (completedSessions.value % TARGET_ROUNDS) + 1)
const todaysRounds = computed(() => {
  const doneInCycle = completedSessions.value % TARGET_ROUNDS
  return Array.from({ length: TARGET_ROUNDS }, (_, i) => {
    const roundNumber = i + 1
    let status = 'upcoming'
    if (roundNumber <= doneInCycle) status = 'done'
    else if (roundNumber === doneInCycle + 1) status = mode.value === 'work' ? 'current' : 'upcoming'
    return { roundNumber, status }
  })
})

const stageIndex = computed(() => Math.min(Math.floor(completedSessions.value / SESSIONS_PER_STAGE), GROWTH_STAGES.length - 1))
const stageName = computed(() => GROWTH_STAGES[stageIndex.value])
const sessionsToNextStage = computed(() => {
  if (stageIndex.value >= GROWTH_STAGES.length - 1) return null
  return SESSIONS_PER_STAGE - (completedSessions.value % SESSIONS_PER_STAGE)
})

const userInitial = computed(() => authStore.user?.email?.[0]?.toUpperCase() ?? '?')

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

function toggleRunning() {
  if (running.value) {
    running.value = false
    clearInterval(intervalId)
    intervalId = null
  } else {
    running.value = true
    intervalId = setInterval(tick, 1000)
  }
}

function restartInterval() {
  running.value = false
  clearInterval(intervalId)
  intervalId = null
  remainingSeconds.value = totalSeconds.value
}

function applyPreset(preset) {
  if (running.value) return
  activePreset.value = preset.key
  workMinutes.value = preset.work
  breakMinutes.value = preset.break
  remainingSeconds.value = (mode.value === 'work' ? preset.work : preset.break) * 60
}

function useCustom() {
  if (running.value) return
  activePreset.value = 'custom'
}

watch([workMinutes, breakMinutes], () => {
  if (running.value) return
  remainingSeconds.value = totalSeconds.value
})

onBeforeUnmount(() => {
  clearInterval(intervalId)
})
</script>

<template>
  <div class="focus-mock">
    <aside class="focus-mock__sidebar">
      <div class="focus-mock__brand">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6">
          <path d="M4 20c1-8 6-13 15-15-2 9-7 14-15 15Z" />
          <path d="M4.5 19.5c2-5 5-9 10-12" />
        </svg>
        <span>Schedule<br />Planner</span>
      </div>

      <nav class="focus-mock__nav">
        <RouterLink to="/" class="focus-mock__nav-item">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6">
            <path d="M3 10.5 12 3l9 7.5" />
            <path d="M5 9.5V21h5v-6h4v6h5V9.5" />
          </svg>
          Home
        </RouterLink>
        <RouterLink to="/focus" class="focus-mock__nav-item focus-mock__nav-item--active">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6">
            <circle cx="12" cy="12" r="9" />
            <path d="M12 7v5l3 2" />
          </svg>
          Focus Session
        </RouterLink>
        <RouterLink to="/growth" class="focus-mock__nav-item">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6">
            <path d="M12 21c-5-1-8-5-8-10 7 0 11-2 16-9 0 9-3 16-8 19Z" />
          </svg>
          Growth
        </RouterLink>
        <RouterLink to="/stats" class="focus-mock__nav-item">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6">
            <path d="M5 20V11M12 20V5M19 20v-7" />
          </svg>
          Stats
        </RouterLink>
        <RouterLink to="/notifications" class="focus-mock__nav-item">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6">
            <path d="M6 9a6 6 0 1 1 12 0c0 4 1.5 5.5 2 6H4c.5-.5 2-2 2-6Z" />
            <path d="M10 19a2 2 0 0 0 4 0" />
          </svg>
          Notifications
        </RouterLink>
      </nav>

      <div class="focus-mock__user">
        <span class="focus-mock__avatar">{{ userInitial }}</span>
        <span class="focus-mock__email">{{ authStore.user?.email ?? 'Signed out' }}</span>
      </div>
    </aside>

    <main class="focus-mock__main">
      <header class="focus-mock__header">
        <h1>Focus session</h1>
        <p>Round {{ currentRound }} of {{ TARGET_ROUNDS }}</p>
      </header>

      <section class="focus-mock__card">
        <div class="focus-mock__badges">
          <span class="focus-mock__badge focus-mock__badge--mode">{{ mode === 'work' ? 'Work interval' : 'Break' }}</span>
          <span class="focus-mock__badge focus-mock__badge--round">Round {{ currentRound }} of {{ TARGET_ROUNDS }}</span>
        </div>

        <div class="focus-mock__ring-wrap">
          <svg class="focus-mock__ring" viewBox="0 0 200 200">
            <circle class="focus-mock__ring-bg" cx="100" cy="100" r="90" />
            <circle
              class="focus-mock__ring-progress"
              cx="100"
              cy="100"
              r="90"
              :stroke-dasharray="ringCircumference"
              :stroke-dashoffset="ringOffset"
              transform="rotate(-90 100 100)"
            />
          </svg>
          <div class="focus-mock__ring-label">
            <strong>{{ minutesLabel }}:{{ secondsLabel }}</strong>
            <span>remaining</span>
          </div>
        </div>

        <div class="focus-mock__controls">
          <button type="button" class="focus-mock__btn focus-mock__btn--ghost" @click="restartInterval">Restart</button>
          <button type="button" class="focus-mock__btn focus-mock__btn--primary" @click="toggleRunning">
            {{ running ? 'Pause' : 'Start' }}
          </button>
        </div>

        <div class="focus-mock__presets">
          <button
            v-for="preset in PRESETS"
            :key="preset.key"
            type="button"
            class="focus-mock__pill"
            :class="{ 'focus-mock__pill--active': activePreset === preset.key }"
            :disabled="running"
            @click="applyPreset(preset)"
          >
            {{ preset.label }}
          </button>
          <button
            type="button"
            class="focus-mock__pill"
            :class="{ 'focus-mock__pill--active': activePreset === 'custom' }"
            :disabled="running"
            @click="useCustom"
          >
            Custom
          </button>
        </div>

        <div v-if="activePreset === 'custom'" class="focus-mock__custom">
          <label>
            Work minutes
            <input v-model.number="workMinutes" type="number" min="1" max="120" :disabled="running" />
          </label>
          <label>
            Break minutes
            <input v-model.number="breakMinutes" type="number" min="1" max="60" :disabled="running" />
          </label>
        </div>
      </section>
    </main>

    <aside class="focus-mock__side">
      <div class="focus-mock__plant-card">
        <span class="focus-mock__plant-icon">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6">
            <path d="M12 21c-5-1-8-5-8-10 7 0 11-2 16-9 0 9-3 16-8 19Z" />
          </svg>
        </span>
        <div>
          <p class="focus-mock__plant-label">Your plant</p>
          <p class="focus-mock__plant-stage">{{ stageName }} stage</p>
          <p class="focus-mock__plant-caption">
            {{ sessionsToNextStage !== null ? `${sessionsToNextStage} session${sessionsToNextStage === 1 ? '' : 's'} to ${GROWTH_STAGES[stageIndex + 1]}` : 'Fully grown' }}
          </p>
        </div>
      </div>

      <div class="focus-mock__sessions-card">
        <p class="focus-mock__sessions-title">Today's sessions</p>
        <ul class="focus-mock__sessions-list">
          <li v-for="round in todaysRounds" :key="round.roundNumber" :class="`focus-mock__session focus-mock__session--${round.status}`">
            <span class="focus-mock__session-dot">
              <svg v-if="round.status === 'done'" viewBox="0 0 16 16" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M3.5 8.5 6.5 11.5 12.5 4.5" />
              </svg>
            </span>
            <span>Round {{ round.roundNumber }}</span>
            <span v-if="round.status === 'current'" class="focus-mock__session-status">In progress</span>
            <span v-else-if="round.status === 'upcoming'" class="focus-mock__session-status focus-mock__session-status--muted">Up next</span>
          </li>
        </ul>
      </div>
    </aside>
  </div>
</template>

<style scoped>
.focus-mock {
  --fm-bg: #f5f1e6;
  --fm-card: #ffffff;
  --fm-border: #e7e1d0;
  --fm-text: #22281f;
  --fm-text-muted: #747a6a;
  --fm-green: #3f6b4d;
  --fm-green-soft: #e1ebe0;
  --fm-orange: #c15f35;
  --fm-serif: Georgia, 'Iowan Old Style', 'Palatino Linotype', 'Book Antiqua', serif;

  position: fixed;
  inset: 0;
  z-index: 1000;
  display: flex;
  background: var(--fm-bg);
  color: var(--fm-text);
  font-family: var(--sans);
  overflow: auto;
}

.focus-mock__sidebar {
  width: 240px;
  flex-shrink: 0;
  display: flex;
  flex-direction: column;
  padding: 1.75rem 1.25rem;
  border-right: 1px solid var(--fm-border);
}

.focus-mock__brand {
  display: flex;
  align-items: center;
  gap: 0.6rem;
  font-family: var(--fm-serif);
  font-weight: 700;
  font-size: 1.1rem;
  line-height: 1.15;
  color: var(--fm-text);
  margin-bottom: 2rem;
}

.focus-mock__brand svg {
  width: 24px;
  height: 24px;
  color: var(--fm-green);
  flex-shrink: 0;
}

.focus-mock__nav {
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
  flex: 1;
}

.focus-mock__nav-item {
  display: flex;
  align-items: center;
  gap: 0.65rem;
  padding: 0.55rem 0.7rem;
  border-radius: 10px;
  color: var(--fm-text-muted);
  text-decoration: none;
  font-size: 0.92rem;
}

.focus-mock__nav-item svg {
  width: 18px;
  height: 18px;
  flex-shrink: 0;
}

.focus-mock__nav-item--active {
  background: var(--fm-green-soft);
  color: var(--fm-green);
  font-weight: 600;
}

.focus-mock__user {
  display: flex;
  align-items: center;
  gap: 0.6rem;
  padding-top: 1rem;
  border-top: 1px solid var(--fm-border);
}

.focus-mock__avatar {
  width: 32px;
  height: 32px;
  border-radius: 50%;
  background: var(--fm-green);
  color: #fff;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 0.85rem;
  font-weight: 700;
  flex-shrink: 0;
}

.focus-mock__email {
  font-size: 0.8rem;
  color: var(--fm-text-muted);
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.focus-mock__main {
  flex: 1;
  min-width: 0;
  padding: 2.5rem 2rem;
}

.focus-mock__header h1 {
  font-family: var(--fm-serif);
  font-size: 2rem;
  font-weight: 700;
  margin: 0 0 0.25rem;
  color: var(--fm-text);
}

.focus-mock__header p {
  margin: 0 0 1.5rem;
  color: var(--fm-text-muted);
}

.focus-mock__card {
  background: var(--fm-card);
  border: 1px solid var(--fm-border);
  border-radius: 20px;
  padding: 2.5rem;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 1.5rem;
}

.focus-mock__badges {
  display: flex;
  gap: 0.6rem;
}

.focus-mock__badge {
  font-size: 0.8rem;
  padding: 0.3rem 0.75rem;
  border-radius: 999px;
  border: 1px solid var(--fm-border);
  color: var(--fm-text-muted);
}

.focus-mock__badge--mode {
  background: var(--fm-green-soft);
  color: var(--fm-green);
  border-color: transparent;
  font-weight: 600;
}

.focus-mock__ring-wrap {
  position: relative;
  width: 220px;
  height: 220px;
}

.focus-mock__ring {
  width: 100%;
  height: 100%;
}

.focus-mock__ring-bg {
  fill: none;
  stroke: var(--fm-green-soft);
  stroke-width: 14;
}

.focus-mock__ring-progress {
  fill: none;
  stroke: var(--fm-orange);
  stroke-width: 14;
  stroke-linecap: round;
  transition: stroke-dashoffset 0.3s linear;
}

.focus-mock__ring-label {
  position: absolute;
  inset: 0;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 0.25rem;
}

.focus-mock__ring-label strong {
  font-family: var(--fm-serif);
  font-size: 2.6rem;
  font-weight: 700;
}

.focus-mock__ring-label span {
  font-size: 0.8rem;
  color: var(--fm-text-muted);
}

.focus-mock__controls {
  display: flex;
  gap: 0.75rem;
}

.focus-mock__btn {
  padding: 0.65rem 1.6rem;
  border-radius: 10px;
  border: 1px solid var(--fm-border);
  background: #fff;
  color: var(--fm-text);
  font-weight: 600;
  cursor: pointer;
}

.focus-mock__btn--primary {
  background: var(--fm-orange);
  border-color: var(--fm-orange);
  color: #fff;
}

.focus-mock__presets {
  display: flex;
  gap: 0.5rem;
}

.focus-mock__pill {
  padding: 0.4rem 0.9rem;
  border-radius: 999px;
  border: 1px solid var(--fm-border);
  background: #fff;
  color: var(--fm-text-muted);
  font-size: 0.85rem;
  cursor: pointer;
}

.focus-mock__pill--active {
  border-color: var(--fm-green);
  color: var(--fm-green);
  background: var(--fm-green-soft);
  font-weight: 600;
}

.focus-mock__pill:disabled,
.focus-mock__btn:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.focus-mock__custom {
  display: flex;
  gap: 1.5rem;
}

.focus-mock__custom label {
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
  font-size: 0.85rem;
  color: var(--fm-text-muted);
}

.focus-mock__custom input {
  width: 4rem;
  padding: 0.3rem 0.5rem;
  border-radius: 6px;
  border: 1px solid var(--fm-border);
}

.focus-mock__side {
  width: 300px;
  flex-shrink: 0;
  padding: 2.5rem 1.75rem;
  display: flex;
  flex-direction: column;
  gap: 1.25rem;
}

.focus-mock__plant-card {
  display: flex;
  gap: 0.9rem;
  background: var(--fm-card);
  border: 1px solid var(--fm-border);
  border-radius: 16px;
  padding: 1.25rem;
}

.focus-mock__plant-icon {
  width: 40px;
  height: 40px;
  border-radius: 10px;
  background: var(--fm-green-soft);
  color: var(--fm-green);
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.focus-mock__plant-icon svg {
  width: 20px;
  height: 20px;
}

.focus-mock__plant-label {
  margin: 0;
  font-size: 0.8rem;
  color: var(--fm-text-muted);
}

.focus-mock__plant-stage {
  margin: 0.15rem 0;
  font-family: var(--fm-serif);
  font-weight: 700;
  color: var(--fm-green);
}

.focus-mock__plant-caption {
  margin: 0;
  font-size: 0.8rem;
  color: var(--fm-text-muted);
}

.focus-mock__sessions-card {
  background: var(--fm-card);
  border: 1px solid var(--fm-border);
  border-radius: 16px;
  padding: 1.25rem;
}

.focus-mock__sessions-title {
  margin: 0 0 0.9rem;
  font-size: 0.9rem;
  font-weight: 700;
}

.focus-mock__sessions-list {
  list-style: none;
  margin: 0;
  padding: 0;
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}

.focus-mock__session {
  display: flex;
  align-items: center;
  gap: 0.6rem;
  font-size: 0.88rem;
}

.focus-mock__session-dot {
  width: 20px;
  height: 20px;
  border-radius: 50%;
  border: 1.5px solid var(--fm-border);
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.focus-mock__session-dot svg {
  width: 12px;
  height: 12px;
}

.focus-mock__session--done .focus-mock__session-dot {
  background: var(--fm-green);
  border-color: var(--fm-green);
  color: #fff;
}

.focus-mock__session--current .focus-mock__session-dot {
  border-color: var(--fm-orange);
}

.focus-mock__session-status {
  margin-left: auto;
  font-size: 0.78rem;
  color: var(--fm-orange);
  font-weight: 600;
}

.focus-mock__session-status--muted {
  color: var(--fm-text-muted);
  font-weight: 500;
}

@media (max-width: 960px) {
  .focus-mock {
    flex-direction: column;
    overflow: auto;
  }
  .focus-mock__sidebar,
  .focus-mock__side {
    width: auto;
  }
}
</style>
