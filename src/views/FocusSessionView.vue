<script setup>
import { computed, onBeforeUnmount, ref, watch } from 'vue'

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
  <div class="focus-page">
    <div class="focus-page__main">
      <p class="focus-page__subtitle">Round {{ currentRound }} of {{ TARGET_ROUNDS }}</p>

      <section class="focus-page__card">
        <div class="focus-page__badges">
          <span class="focus-page__badge focus-page__badge--mode">{{ mode === 'work' ? 'Work interval' : 'Break' }}</span>
          <span class="focus-page__badge focus-page__badge--round">Round {{ currentRound }} of {{ TARGET_ROUNDS }}</span>
        </div>

        <div class="focus-page__ring-wrap">
          <svg class="focus-page__ring" viewBox="0 0 200 200">
            <circle class="focus-page__ring-bg" cx="100" cy="100" r="90" />
            <circle
              class="focus-page__ring-progress"
              cx="100"
              cy="100"
              r="90"
              :stroke-dasharray="ringCircumference"
              :stroke-dashoffset="ringOffset"
              transform="rotate(-90 100 100)"
            />
          </svg>
          <div class="focus-page__ring-label">
            <strong>{{ minutesLabel }}:{{ secondsLabel }}</strong>
            <span>remaining</span>
          </div>
        </div>

        <div class="focus-page__controls">
          <button type="button" class="focus-page__btn focus-page__btn--ghost" @click="restartInterval">Restart</button>
          <button type="button" class="focus-page__btn focus-page__btn--primary" @click="toggleRunning">
            {{ running ? 'Pause' : 'Start' }}
          </button>
        </div>

        <div class="focus-page__presets">
          <button
            v-for="preset in PRESETS"
            :key="preset.key"
            type="button"
            class="focus-page__pill"
            :class="{ 'focus-page__pill--active': activePreset === preset.key }"
            :disabled="running"
            @click="applyPreset(preset)"
          >
            {{ preset.label }}
          </button>
          <button
            type="button"
            class="focus-page__pill"
            :class="{ 'focus-page__pill--active': activePreset === 'custom' }"
            :disabled="running"
            @click="useCustom"
          >
            Custom
          </button>
        </div>

        <div v-if="activePreset === 'custom'" class="focus-page__custom">
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
    </div>

    <aside class="focus-page__side">
      <div class="focus-page__plant-card">
        <span class="focus-page__plant-icon">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6">
            <path d="M12 21c-5-1-8-5-8-10 7 0 11-2 16-9 0 9-3 16-8 19Z" />
          </svg>
        </span>
        <div>
          <p class="focus-page__plant-label">Your plant</p>
          <p class="focus-page__plant-stage">{{ stageName }} stage</p>
          <p class="focus-page__plant-caption">
            {{ sessionsToNextStage !== null ? `${sessionsToNextStage} session${sessionsToNextStage === 1 ? '' : 's'} to ${GROWTH_STAGES[stageIndex + 1]}` : 'Fully grown' }}
          </p>
        </div>
      </div>

      <div class="focus-page__sessions-card">
        <p class="focus-page__sessions-title">Today's sessions</p>
        <ul class="focus-page__sessions-list">
          <li v-for="round in todaysRounds" :key="round.roundNumber" :class="`focus-page__session focus-page__session--${round.status}`">
            <span class="focus-page__session-dot">
              <svg v-if="round.status === 'done'" viewBox="0 0 16 16" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M3.5 8.5 6.5 11.5 12.5 4.5" />
              </svg>
            </span>
            <span>Round {{ round.roundNumber }}</span>
            <span v-if="round.status === 'current'" class="focus-page__session-status">In progress</span>
            <span v-else-if="round.status === 'upcoming'" class="focus-page__session-status focus-page__session-status--muted">Up next</span>
          </li>
        </ul>
      </div>
    </aside>
  </div>
</template>

<style scoped>
.focus-page {
  display: flex;
  gap: 2rem;
  align-items: flex-start;
}

.focus-page__main {
  flex: 1;
  min-width: 0;
}

.focus-page__subtitle {
  margin: -1rem 0 1.5rem;
  color: var(--shell-text-muted);
}

.focus-page__card {
  background: var(--shell-card);
  border: 1px solid var(--shell-border);
  border-radius: 20px;
  padding: 2.5rem;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 1.5rem;
}

.focus-page__badges {
  display: flex;
  gap: 0.6rem;
}

.focus-page__badge {
  font-size: 0.8rem;
  padding: 0.3rem 0.75rem;
  border-radius: 999px;
  border: 1px solid var(--shell-border);
  color: var(--shell-text-muted);
}

.focus-page__badge--mode {
  background: var(--shell-green-soft);
  color: var(--shell-green);
  border-color: transparent;
  font-weight: 600;
}

.focus-page__ring-wrap {
  position: relative;
  width: 220px;
  height: 220px;
}

.focus-page__ring {
  width: 100%;
  height: 100%;
}

.focus-page__ring-bg {
  fill: none;
  stroke: var(--shell-green-soft);
  stroke-width: 14;
}

.focus-page__ring-progress {
  fill: none;
  stroke: var(--shell-orange);
  stroke-width: 14;
  stroke-linecap: round;
  transition: stroke-dashoffset 0.3s linear;
}

.focus-page__ring-label {
  position: absolute;
  inset: 0;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 0.25rem;
}

.focus-page__ring-label strong {
  font-family: var(--shell-serif);
  font-size: 2.6rem;
  font-weight: 700;
  color: var(--shell-text);
}

.focus-page__ring-label span {
  font-size: 0.8rem;
  color: var(--shell-text-muted);
}

.focus-page__controls {
  display: flex;
  gap: 0.75rem;
}

.focus-page__btn {
  padding: 0.65rem 1.6rem;
  border-radius: 10px;
  border: 1px solid var(--shell-border);
  background: #fff;
  color: var(--shell-text);
  font-weight: 600;
  cursor: pointer;
}

.focus-page__btn--primary {
  background: var(--shell-orange);
  border-color: var(--shell-orange);
  color: #fff;
}

.focus-page__presets {
  display: flex;
  gap: 0.5rem;
}

.focus-page__pill {
  padding: 0.4rem 0.9rem;
  border-radius: 999px;
  border: 1px solid var(--shell-border);
  background: #fff;
  color: var(--shell-text-muted);
  font-size: 0.85rem;
  cursor: pointer;
}

.focus-page__pill--active {
  border-color: var(--shell-green);
  color: var(--shell-green);
  background: var(--shell-green-soft);
  font-weight: 600;
}

.focus-page__pill:disabled,
.focus-page__btn:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.focus-page__custom {
  display: flex;
  gap: 1.5rem;
}

.focus-page__custom label {
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
  font-size: 0.85rem;
  color: var(--shell-text-muted);
}

.focus-page__custom input {
  width: 4rem;
  padding: 0.3rem 0.5rem;
  border-radius: 6px;
  border: 1px solid var(--shell-border);
}

.focus-page__side {
  width: 300px;
  flex-shrink: 0;
  display: flex;
  flex-direction: column;
  gap: 1.25rem;
}

.focus-page__plant-card {
  display: flex;
  gap: 0.9rem;
  background: var(--shell-card);
  border: 1px solid var(--shell-border);
  border-radius: 16px;
  padding: 1.25rem;
}

.focus-page__plant-icon {
  width: 40px;
  height: 40px;
  border-radius: 10px;
  background: var(--shell-green-soft);
  color: var(--shell-green);
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.focus-page__plant-icon svg {
  width: 20px;
  height: 20px;
}

.focus-page__plant-label {
  margin: 0;
  font-size: 0.8rem;
  color: var(--shell-text-muted);
}

.focus-page__plant-stage {
  margin: 0.15rem 0;
  font-family: var(--shell-serif);
  font-weight: 700;
  color: var(--shell-green);
}

.focus-page__plant-caption {
  margin: 0;
  font-size: 0.8rem;
  color: var(--shell-text-muted);
}

.focus-page__sessions-card {
  background: var(--shell-card);
  border: 1px solid var(--shell-border);
  border-radius: 16px;
  padding: 1.25rem;
}

.focus-page__sessions-title {
  margin: 0 0 0.9rem;
  font-size: 0.9rem;
  font-weight: 700;
}

.focus-page__sessions-list {
  list-style: none;
  margin: 0;
  padding: 0;
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}

.focus-page__session {
  display: flex;
  align-items: center;
  gap: 0.6rem;
  font-size: 0.88rem;
}

.focus-page__session-dot {
  width: 20px;
  height: 20px;
  border-radius: 50%;
  border: 1.5px solid var(--shell-border);
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.focus-page__session-dot svg {
  width: 12px;
  height: 12px;
}

.focus-page__session--done .focus-page__session-dot {
  background: var(--shell-green);
  border-color: var(--shell-green);
  color: #fff;
}

.focus-page__session--current .focus-page__session-dot {
  border-color: var(--shell-orange);
}

.focus-page__session-status {
  margin-left: auto;
  font-size: 0.78rem;
  color: var(--shell-orange);
  font-weight: 600;
}

.focus-page__session-status--muted {
  color: var(--shell-text-muted);
  font-weight: 500;
}

@media (max-width: 800px) {
  .focus-page {
    flex-direction: column;
  }
  .focus-page__side {
    width: auto;
  }
}
</style>
