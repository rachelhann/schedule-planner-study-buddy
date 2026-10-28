<script setup>
import { computed, ref } from 'vue'

const STAGES = [
  { key: 'seedling', label: 'Seedling' },
  { key: 'sprout', label: 'Sprout' },
  { key: 'budding', label: 'Budding' },
  { key: 'blooming', label: 'Blooming' },
  { key: 'full-bloom', label: 'Full Bloom' },
]
const SESSIONS_PER_STAGE = 15

// placeholder state for a brand-new plant. TODO(backend): replace these four
// refs with real session/streak/history data once API exists.
const totalSessions = ref(0)
const currentStreak = ref(0)
const longestStreak = ref(0)
const growthHistory = ref([
  { label: 'Planted seedling', date: 'Today' },
])

const stageIndex = computed(() => Math.min(Math.floor(totalSessions.value / SESSIONS_PER_STAGE), STAGES.length - 1))
const currentStage = computed(() => STAGES[stageIndex.value])
const isFullyGrown = computed(() => stageIndex.value === STAGES.length - 1)
const sessionsIntoStage = computed(() => totalSessions.value - stageIndex.value * SESSIONS_PER_STAGE)
const progressPercent = computed(() => (isFullyGrown.value ? 100 : Math.min(100, (sessionsIntoStage.value / SESSIONS_PER_STAGE) * 100)))
const sessionsToNext = computed(() => (isFullyGrown.value ? null : SESSIONS_PER_STAGE - sessionsIntoStage.value))
const nextStageLabel = computed(() => (isFullyGrown.value ? null : STAGES[stageIndex.value + 1].label))
</script>

<template>
  <div class="growth-page">
    <div class="growth-page__main">
      <p class="growth-page__subtitle">Fed by every completed focus session, not the ones you skip.</p>

      <section class="growth-page__card">
        <span class="growth-page__badge">{{ currentStage.label }} stage</span>

        <div class="growth-page__plant">
          <transition name="grow" mode="out-in">
            <svg v-if="currentStage.key === 'seedling'" key="seedling" class="growth-plant" viewBox="0 0 160 190">
              <rect x="34" y="144" width="92" height="14" rx="5" fill="#a8532f" />
              <path d="M40 156 L120 156 L110 188 Q108 190 80 190 Q52 190 50 188 Z" fill="var(--shell-orange)" />
              <ellipse cx="80" cy="150" rx="38" ry="5" fill="#5b4330" />
              <g class="growth-plant__sway growth-plant__sway--sm">
                <path d="M80 150 Q77 140 80 130" stroke="var(--shell-green)" stroke-width="4" fill="none" stroke-linecap="round" />
                <ellipse cx="71" cy="132" rx="9" ry="5" transform="rotate(-30 71 132)" fill="var(--shell-green)" />
                <ellipse cx="89" cy="132" rx="9" ry="5" transform="rotate(30 89 132)" fill="var(--shell-green)" />
              </g>
            </svg>

            <svg v-else-if="currentStage.key === 'sprout'" key="sprout" class="growth-plant" viewBox="0 0 160 190">
              <rect x="34" y="144" width="92" height="14" rx="5" fill="#a8532f" />
              <path d="M40 156 L120 156 L110 188 Q108 190 80 190 Q52 190 50 188 Z" fill="var(--shell-orange)" />
              <ellipse cx="80" cy="150" rx="38" ry="5" fill="#5b4330" />
              <g class="growth-plant__sway growth-plant__sway--md">
                <path d="M80 150 Q75 115 80 95" stroke="var(--shell-green)" stroke-width="4.5" fill="none" stroke-linecap="round" />
                <ellipse cx="66" cy="135" rx="11" ry="6" transform="rotate(-35 66 135)" fill="var(--shell-green)" />
                <ellipse cx="94" cy="135" rx="11" ry="6" transform="rotate(35 94 135)" fill="var(--shell-green)" />
                <ellipse cx="68" cy="105" rx="10" ry="5.5" transform="rotate(-25 68 105)" fill="var(--shell-green)" />
                <ellipse cx="92" cy="105" rx="10" ry="5.5" transform="rotate(25 92 105)" fill="var(--shell-green)" />
              </g>
            </svg>

            <svg v-else-if="currentStage.key === 'budding'" key="budding" class="growth-plant" viewBox="0 0 160 190">
              <rect x="34" y="144" width="92" height="14" rx="5" fill="#a8532f" />
              <path d="M40 156 L120 156 L110 188 Q108 190 80 190 Q52 190 50 188 Z" fill="var(--shell-orange)" />
              <ellipse cx="80" cy="150" rx="38" ry="5" fill="#5b4330" />
              <g class="growth-plant__sway growth-plant__sway--md">
                <path d="M80 150 Q74 100 80 72" stroke="var(--shell-green)" stroke-width="5" fill="none" stroke-linecap="round" />
                <ellipse cx="62" cy="128" rx="13" ry="7" transform="rotate(-35 62 128)" fill="var(--shell-green)" />
                <ellipse cx="98" cy="118" rx="13" ry="7" transform="rotate(30 98 118)" fill="var(--shell-green)" />
                <ellipse cx="66" cy="95" rx="11" ry="6" transform="rotate(-30 66 95)" fill="var(--shell-green)" />
                <g class="growth-plant__bud">
                  <path d="M80 80 Q70 78 72 66 Q80 70 80 80Z" fill="var(--shell-green)" />
                  <path d="M80 80 Q90 78 88 66 Q80 70 80 80Z" fill="var(--shell-green)" />
                  <circle cx="80" cy="68" r="11" fill="var(--growth-bud)" />
                </g>
              </g>
            </svg>

            <svg v-else-if="currentStage.key === 'blooming'" key="blooming" class="growth-plant" viewBox="0 0 160 190">
              <rect x="34" y="144" width="92" height="14" rx="5" fill="#a8532f" />
              <path d="M40 156 L120 156 L110 188 Q108 190 80 190 Q52 190 50 188 Z" fill="var(--shell-orange)" />
              <ellipse cx="80" cy="150" rx="38" ry="5" fill="#5b4330" />
              <g class="growth-plant__sway growth-plant__sway--lg">
                <path d="M80 150 Q73 95 80 65" stroke="var(--shell-green)" stroke-width="5" fill="none" stroke-linecap="round" />
                <ellipse cx="60" cy="125" rx="14" ry="7.5" transform="rotate(-35 60 125)" fill="var(--shell-green)" />
                <ellipse cx="100" cy="115" rx="14" ry="7.5" transform="rotate(30 100 115)" fill="var(--shell-green)" />
                <ellipse cx="64" cy="90" rx="12" ry="6.5" transform="rotate(-25 64 90)" fill="var(--shell-green)" />
                <g class="growth-plant__flower" style="transform-origin:80px 60px">
                  <ellipse cx="80" cy="42" rx="11" ry="16" fill="var(--growth-bud)" />
                  <ellipse cx="80" cy="42" rx="11" ry="16" fill="var(--growth-bud)" transform="rotate(72 80 60)" />
                  <ellipse cx="80" cy="42" rx="11" ry="16" fill="var(--growth-bud)" transform="rotate(144 80 60)" />
                  <ellipse cx="80" cy="42" rx="11" ry="16" fill="var(--growth-bud)" transform="rotate(216 80 60)" />
                  <ellipse cx="80" cy="42" rx="11" ry="16" fill="var(--growth-bud)" transform="rotate(288 80 60)" />
                  <circle cx="80" cy="60" r="7" fill="var(--shell-orange)" />
                </g>
              </g>
            </svg>

            <svg v-else key="full-bloom" class="growth-plant" viewBox="0 0 160 190">
              <rect x="34" y="144" width="92" height="14" rx="5" fill="#a8532f" />
              <path d="M40 156 L120 156 L110 188 Q108 190 80 190 Q52 190 50 188 Z" fill="var(--shell-orange)" />
              <ellipse cx="80" cy="150" rx="38" ry="5" fill="#5b4330" />
              <g class="growth-plant__sway growth-plant__sway--lg">
                <path d="M80 150 Q70 90 80 55" stroke="var(--shell-green)" stroke-width="5.5" fill="none" stroke-linecap="round" />
                <path d="M80 110 Q95 100 100 85" stroke="var(--shell-green)" stroke-width="3.5" fill="none" stroke-linecap="round" />
                <ellipse cx="58" cy="122" rx="15" ry="8" transform="rotate(-35 58 122)" fill="var(--shell-green)" />
                <ellipse cx="102" cy="112" rx="14" ry="7.5" transform="rotate(30 102 112)" fill="var(--shell-green)" />
                <ellipse cx="62" cy="85" rx="12" ry="6.5" transform="rotate(-25 62 85)" fill="var(--shell-green)" />
                <g class="growth-plant__flower growth-plant__flower--full" style="transform-origin:80px 48px">
                  <ellipse cx="80" cy="26" rx="13" ry="19" fill="var(--growth-bud)" />
                  <ellipse cx="80" cy="26" rx="13" ry="19" fill="var(--growth-bud)" transform="rotate(60 80 48)" />
                  <ellipse cx="80" cy="26" rx="13" ry="19" fill="var(--growth-bud)" transform="rotate(120 80 48)" />
                  <ellipse cx="80" cy="26" rx="13" ry="19" fill="var(--growth-bud)" transform="rotate(180 80 48)" />
                  <ellipse cx="80" cy="26" rx="13" ry="19" fill="var(--growth-bud)" transform="rotate(240 80 48)" />
                  <ellipse cx="80" cy="26" rx="13" ry="19" fill="var(--growth-bud)" transform="rotate(300 80 48)" />
                  <circle cx="80" cy="48" r="8" fill="var(--shell-orange)" />
                </g>
                <g class="growth-plant__flower growth-plant__flower--small" style="transform-origin:100px 85px">
                  <ellipse cx="100" cy="72" rx="7" ry="10" fill="var(--growth-bud)" />
                  <ellipse cx="100" cy="72" rx="7" ry="10" fill="var(--growth-bud)" transform="rotate(90 100 85)" />
                  <ellipse cx="100" cy="72" rx="7" ry="10" fill="var(--growth-bud)" transform="rotate(180 100 85)" />
                  <ellipse cx="100" cy="72" rx="7" ry="10" fill="var(--growth-bud)" transform="rotate(270 100 85)" />
                  <circle cx="100" cy="85" r="4" fill="var(--shell-orange)" />
                </g>
                <g class="growth-plant__sparkles">
                  <circle cx="50" cy="40" r="2.5" class="growth-plant__sparkle growth-plant__sparkle--a" />
                  <circle cx="112" cy="55" r="2" class="growth-plant__sparkle growth-plant__sparkle--b" />
                  <circle cx="96" cy="20" r="2" class="growth-plant__sparkle growth-plant__sparkle--c" />
                </g>
              </g>
            </svg>
          </transition>
        </div>

        <div class="growth-page__progress-row">
          <span>{{ totalSessions }} sessions completed</span>
          <span v-if="!isFullyGrown">{{ sessionsToNext }} more to {{ nextStageLabel }}</span>
          <span v-else>Fully grown</span>
        </div>
        <div class="growth-page__progress-track">
          <div class="growth-page__progress-fill" :style="{ width: progressPercent + '%' }"></div>
        </div>

        <div class="growth-page__stepper">
          <template v-for="(stage, i) in STAGES" :key="stage.key">
            <div
              class="growth-page__step"
              :class="`growth-page__step--${i < stageIndex ? 'done' : i === stageIndex ? 'current' : 'upcoming'}`"
            >
              <span class="growth-page__step-dot">
                <svg v-if="i < stageIndex" viewBox="0 0 16 16" fill="none" stroke="currentColor" stroke-width="2">
                  <path d="M3.5 8.5 6.5 11.5 12.5 4.5" />
                </svg>
                <span v-else-if="i === stageIndex" class="growth-page__step-current"></span>
              </span>
              <span class="growth-page__step-label">{{ stage.label }}</span>
            </div>
            <div v-if="i < STAGES.length - 1" class="growth-page__step-line" :class="{ 'growth-page__step-line--done': i < stageIndex }"></div>
          </template>
        </div>
      </section>
    </div>

    <aside class="growth-page__side">
      <div class="growth-page__stat-card">
        <div>
          <p class="growth-page__stat-label">Current streak</p>
          <p class="growth-page__stat-value">{{ currentStreak }} days</p>
        </div>
        <span class="growth-page__stat-icon growth-page__stat-icon--flame">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6">
            <path d="M12 21c-3.5 0-6-2.5-6-6 0-3 2-5 3-8 .5 2 2 3 2 5 1-1 1.5-3 1-5 3 2 6 5 6 8 0 3.5-2.5 6-6 6Z" />
          </svg>
        </span>
      </div>

      <div class="growth-page__stat-card">
        <div>
          <p class="growth-page__stat-label">Longest streak</p>
          <p class="growth-page__stat-value">{{ longestStreak }} days</p>
        </div>
        <span class="growth-page__stat-icon growth-page__stat-icon--leaf">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6">
            <path d="M12 21c-5-1-8-5-8-10 7 0 11-2 16-9 0 9-3 16-8 19Z" />
          </svg>
        </span>
      </div>

      <div class="growth-page__history-card">
        <p class="growth-page__history-title">Growth history</p>
        <ul class="growth-page__history-list">
          <li v-for="entry in growthHistory" :key="entry.label" class="growth-page__history-item">
            <span>{{ entry.label }}</span>
            <span class="growth-page__history-date">{{ entry.date }}</span>
          </li>
        </ul>
      </div>
    </aside>
  </div>
</template>

<style scoped>
.growth-page {
  --growth-bud: #e3a98f;
  --growth-orange-soft: #f6e6da;

  display: flex;
  gap: 2rem;
  align-items: flex-start;
}

.growth-page__main {
  flex: 1;
  min-width: 0;
}

.growth-page__subtitle {
  margin: -1rem 0 1.5rem;
  color: var(--shell-text-muted);
}

.growth-page__card {
  background: var(--shell-card);
  border: 1px solid var(--shell-border);
  border-radius: 20px;
  padding: 2.5rem;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 1.5rem;
}

.growth-page__badge {
  font-size: 0.8rem;
  font-weight: 600;
  padding: 0.3rem 0.9rem;
  border-radius: 999px;
  background: var(--shell-green-soft);
  color: var(--shell-green);
}

.growth-page__plant {
  width: 220px;
  height: 220px;
}

.growth-plant {
  width: 100%;
  height: 100%;
}

.growth-plant__sway {
  transform-origin: 80px 150px;
  animation: sway-md 4s ease-in-out infinite;
}
.growth-plant__sway--sm {
  animation-name: sway-sm;
  animation-duration: 3.2s;
}
.growth-plant__sway--lg {
  animation-name: sway-lg;
  animation-duration: 4.6s;
}

.growth-plant__bud {
  transform-origin: 80px 74px;
  animation: bud-pulse 2.4s ease-in-out infinite;
}

.growth-plant__flower {
  animation: bloom-breathe 3.4s ease-in-out infinite;
}
.growth-plant__flower--small {
  animation-duration: 2.8s;
}

.growth-plant__sparkle {
  fill: var(--shell-orange);
  animation: sparkle-twinkle 1.8s ease-in-out infinite;
}
.growth-plant__sparkle--b {
  animation-delay: 0.5s;
}
.growth-plant__sparkle--c {
  animation-delay: 1s;
}

@keyframes sway-sm {
  0%, 100% { transform: rotate(-1.5deg); }
  50% { transform: rotate(1.5deg); }
}
@keyframes sway-md {
  0%, 100% { transform: rotate(-2.5deg); }
  50% { transform: rotate(2.5deg); }
}
@keyframes sway-lg {
  0%, 100% { transform: rotate(-3deg); }
  50% { transform: rotate(3deg); }
}
@keyframes bud-pulse {
  0%, 100% { transform: scale(1); }
  50% { transform: scale(1.08); }
}
@keyframes bloom-breathe {
  0%, 100% { transform: scale(1); }
  50% { transform: scale(1.04); }
}
@keyframes sparkle-twinkle {
  0%, 100% { opacity: 0.2; transform: scale(0.6); }
  50% { opacity: 1; transform: scale(1); }
}

@media (prefers-reduced-motion: reduce) {
  .growth-plant__sway,
  .growth-plant__bud,
  .growth-plant__flower,
  .growth-plant__sparkle {
    animation: none;
  }
}

.grow-enter-active,
.grow-leave-active {
  transition: opacity 0.4s ease, transform 0.4s ease;
}
.grow-enter-from {
  opacity: 0;
  transform: scale(0.85);
}
.grow-leave-to {
  opacity: 0;
  transform: scale(1.1);
}

.growth-page__progress-row {
  width: 100%;
  display: flex;
  justify-content: space-between;
  font-size: 0.85rem;
  color: var(--shell-text-muted);
}

.growth-page__progress-track {
  width: 100%;
  height: 8px;
  border-radius: 999px;
  background: #efe8da;
  overflow: hidden;
}

.growth-page__progress-fill {
  height: 100%;
  border-radius: 999px;
  background: var(--shell-green);
  transition: width 0.3s ease;
}

.growth-page__stepper {
  width: 100%;
  display: flex;
  align-items: flex-start;
}

.growth-page__step {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 0.4rem;
  width: 64px;
}

.growth-page__step-line {
  flex: 1;
  height: 1.5px;
  margin-top: 13px;
  background: var(--shell-border);
}
.growth-page__step-line--done {
  background: var(--shell-green);
}

.growth-page__step-dot {
  width: 28px;
  height: 28px;
  border-radius: 50%;
  border: 1.5px solid var(--shell-border);
  display: flex;
  align-items: center;
  justify-content: center;
  color: #fff;
  flex-shrink: 0;
}
.growth-page__step-dot svg {
  width: 13px;
  height: 13px;
}

.growth-page__step--done .growth-page__step-dot {
  background: var(--shell-green);
  border-color: var(--shell-green);
}
.growth-page__step--current .growth-page__step-dot {
  border-color: var(--shell-orange);
}
.growth-page__step-current {
  width: 9px;
  height: 9px;
  border-radius: 50%;
  background: var(--shell-orange);
}

.growth-page__step-label {
  font-size: 0.78rem;
  color: var(--shell-text-muted);
  text-align: center;
}
.growth-page__step--current .growth-page__step-label {
  color: var(--shell-text);
  font-weight: 700;
}

.growth-page__side {
  width: 300px;
  flex-shrink: 0;
  display: flex;
  flex-direction: column;
  gap: 1.25rem;
}

.growth-page__stat-card {
  display: flex;
  align-items: center;
  justify-content: space-between;
  background: var(--shell-card);
  border: 1px solid var(--shell-border);
  border-radius: 16px;
  padding: 1.25rem;
}

.growth-page__stat-label {
  margin: 0;
  font-size: 0.8rem;
  color: var(--shell-text-muted);
}

.growth-page__stat-value {
  margin: 0.25rem 0 0;
  font-family: var(--shell-serif);
  font-size: 1.6rem;
  font-weight: 700;
  color: var(--shell-text);
}

.growth-page__stat-icon {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}
.growth-page__stat-icon svg {
  width: 18px;
  height: 18px;
}
.growth-page__stat-icon--flame {
  background: var(--growth-orange-soft);
  color: var(--shell-orange);
}
.growth-page__stat-icon--leaf {
  background: var(--shell-green-soft);
  color: var(--shell-green);
}

.growth-page__history-card {
  background: var(--shell-card);
  border: 1px solid var(--shell-border);
  border-radius: 16px;
  padding: 1.25rem;
}

.growth-page__history-title {
  margin: 0 0 0.9rem;
  font-size: 0.9rem;
  font-weight: 700;
}

.growth-page__history-list {
  list-style: none;
  margin: 0;
  padding: 0;
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}

.growth-page__history-item {
  display: flex;
  justify-content: space-between;
  font-size: 0.88rem;
}

.growth-page__history-date {
  color: var(--shell-text-muted);
}

@media (max-width: 800px) {
  .growth-page {
    flex-direction: column;
  }
  .growth-page__side {
    width: auto;
  }
}
</style>
