<script setup>
import { computed, ref } from 'vue'

// Presentation-only fixtures; connect to real activity data later.
const summary = [
  { label: 'Total focus time', value: '38h 20m', detail: '↑ 12% vs last month' },
  { label: 'Sessions completed', value: '92', detail: '↑ 8 sessions vs last month' },
  { label: 'Current streak', value: '12 days', detail: 'Best: 19 days', warm: true },
]
const week = [
  { day: 'Mon', sessions: 3 }, { day: 'Tue', sessions: 5 },
  { day: 'Wed', sessions: 2 }, { day: 'Thu', sessions: 6 },
  { day: 'Fri', sessions: 4 }, { day: 'Sat', sessions: 1 },
  { day: 'Sun', sessions: 5 },
]
const activity = [2, 1, 3, 4, 0, 0, 3, 4, 0, 2, 4, 0, 4, 1, 0, 0, 3, 3, 0, 1, 0, 4, 3, 0, 3, 4, 0, 1]
const subjects = [
  { name: 'Math', percent: 35, time: '13h 25m', color: '#83a98c' },
  { name: 'Science', percent: 25, time: '9h 35m', color: '#e99c78' },
  { name: 'English', percent: 18, time: '6h 54m', color: '#f1cf83' },
  { name: 'History', percent: 12, time: '4h 36m', color: '#afc6d8' },
  { name: 'Other', percent: 10, time: '3h 50m', color: '#c9b9dc' },
]
const hoveredSubject = ref(null)
const focusedSubject = ref(null)
const activeSubject = computed(() => hoveredSubject.value ?? focusedSubject.value)
function slicePoint(radius, percent) {
  const angle = percent / 100 * Math.PI * 2 - Math.PI / 2
  return `${75 + radius * Math.cos(angle)} ${75 + radius * Math.sin(angle)}`
}

let subjectOffset = 0
const subjectSlices = subjects.map((subject) => {
  const start = subjectOffset
  const end = start + subject.percent
  const largeArc = subject.percent > 50 ? 1 : 0
  const middleAngle = (start + end) / 2 / 100 * Math.PI * 2 - Math.PI / 2
  const slice = {
    ...subject,
    liftX: `${Math.cos(middleAngle) * 6}px`,
    liftY: `${Math.sin(middleAngle) * 6}px`,
    path: `M ${slicePoint(75, start)} A 75 75 0 ${largeArc} 1 ${slicePoint(75, end)} L ${slicePoint(54, end)} A 54 54 0 ${largeArc} 0 ${slicePoint(54, start)} Z`,
  }
  subjectOffset = end
  return slice
})

function dismissSubjectTooltip() {
  hoveredSubject.value = null
  focusedSubject.value = null
}

const goals = [
  { name: 'Prepare for calculus exam', current: 12, target: 20 },
  { name: 'Finish science revision', current: 8, target: 10 },
  { name: 'Read for 5 hours', current: 2, target: 5 },
]
</script>

<template>
  <section class="stats-page" aria-labelledby="stats-title">
    <header class="page-heading">
      <div>
        <h1 id="stats-title">Your stats</h1>
        <p>Last 4 weeks of focus activity.</p>
      </div>
      <span class="preview-label">Sample data</span>
    </header>

    <div class="summary-grid">
      <article v-for="stat in summary" :key="stat.label" class="panel summary-card">
        <h2>{{ stat.label }}</h2>
        <p class="stat-value">{{ stat.value }}</p>
        <p class="stat-detail" :class="{ 'stat-detail--warm': stat.warm }">{{ stat.detail }}</p>
      </article>
    </div>

    <div class="activity-grid">
      <section class="panel sessions-panel" aria-labelledby="sessions-title">
        <div class="panel-heading">
          <h2 id="sessions-title">Sessions this week</h2>
          <span class="period-label">This week</span>
        </div>
        <p class="panel-description">Every session is a step forward.</p>
        <div class="bar-chart" role="img" aria-label="Sessions this week: Monday 3, Tuesday 5, Wednesday 2, Thursday 6, Friday 4, Saturday 1, Sunday 5.">
          <div v-for="day in week" :key="day.day" class="bar-column">
            <div class="bar-track">
              <div class="bar" :style="{ height: `${day.sessions / 6 * 85}%` }"><span class="bar-value">{{ day.sessions }}</span></div>
            </div>
            <span class="bar-label">{{ day.day }}</span>
          </div>
        </div>
      </section>

      <section class="panel streak-panel" aria-labelledby="streak-title">
        <h2 id="streak-title">Streak calendar</h2>
        <p class="panel-description">Darker means more sessions that day.</p>
        <div class="heatmap-days" aria-hidden="true">
          <span v-for="day in week" :key="day.day">{{ day.day.charAt(0) }}</span>
        </div>
        <div class="heatmap" role="img" aria-label="Sample activity for the last four weeks. Each row runs Monday through Sunday; darker squares represent more sessions.">
          <span v-for="(level, index) in activity" :key="index" class="heatmap-cell" :class="`level-${level}`" :title="`Week ${Math.floor(index / 7) + 1}, ${week[index % 7].day}: ${level} sessions`"></span>
        </div>
        <div class="heatmap-legend" aria-hidden="true">
          <span>Less</span><span v-for="level in 5" :key="level" class="heatmap-cell" :class="`level-${level - 1}`"></span><span>More</span>
        </div>
        <p class="streak-note">✧ Small steps. Steady progress.</p>
      </section>
    </div>

    <div class="details-grid">
      <section class="panel subject-panel" aria-labelledby="subjects-title">
        <h2 id="subjects-title">Subject breakdown</h2>
        <p class="panel-description">Where your focus time went.</p>
        <div class="subject-content">
          <div class="donut" @keydown.esc="dismissSubjectTooltip">
            <svg class="donut-chart" viewBox="0 0 150 150" role="group" aria-label="Focus time by subject">
              <g
                v-for="subject in subjectSlices"
                :key="subject.name"
                class="donut-slice"
                :class="{ 'donut-slice--active': activeSubject?.name === subject.name }"
                :style="{ '--slice-x': subject.liftX, '--slice-y': subject.liftY }"
                tabindex="0" role="img"
                :aria-label="`${subject.name}: ${subject.percent}%, ${subject.time} of focus time`"
                :aria-describedby="activeSubject?.name === subject.name ? 'subject-tooltip' : undefined"
                @pointerenter="hoveredSubject = subject"
                @pointerleave="hoveredSubject = null"
                @focus="focusedSubject = subject"
                @blur="focusedSubject = null"
              >
                <!-- Keep the original area interactive while the visible slice lifts. -->
                <path :d="subject.path" fill="transparent" aria-hidden="true" />
                <path class="donut-slice-shape" :d="subject.path" :fill="subject.color" aria-hidden="true" />
              </g>
            </svg>
            <div class="donut-center" aria-hidden="true"><strong>38h 20m</strong><span>total focus</span></div>
            <div v-if="activeSubject" id="subject-tooltip" class="subject-tooltip" role="tooltip">
              <strong>{{ activeSubject.name }}</strong>
              <span>{{ activeSubject.time }} · {{ activeSubject.percent }}% of total</span>
            </div>
          </div>
          <ul class="subject-legend" aria-label="Subject percentages">
            <li v-for="subject in subjects" :key="subject.name" :class="{ 'subject-legend__active': activeSubject?.name === subject.name }">
              <span class="subject-name"><i :style="{ background: subject.color }" aria-hidden="true"></i>{{ subject.name }}</span>
              <span class="subject-percentage">{{ subject.percent }}%</span>
            </li>
          </ul>
        </div>
      </section>

      <section class="panel goals-panel" aria-labelledby="goals-title">
        <h2 id="goals-title">Upcoming goals</h2>
        <p class="panel-description">Make room for what matters.</p>
        <ul class="goal-list">
          <li v-for="goal in goals" :key="goal.name">
            <div class="goal-heading"><span>{{ goal.name }}</span><span>{{ goal.current }}/{{ goal.target }}h</span></div>
            <progress :value="goal.current" :max="goal.target" :aria-label="goal.name"></progress>
          </li>
        </ul>
      </section>

      <section class="panel plant-panel" aria-labelledby="plant-title">
        <h2 id="plant-title">Plant progress</h2>
        <div class="plant-content">
          <svg class="plant-illustration" viewBox="0 0 100 140" role="img" aria-label="A young green plant in a terracotta pot">
            <ellipse cx="50" cy="131" rx="28" ry="4" fill="#eae7de" />
            <path d="M50 101V36" fill="none" stroke="#547e60" stroke-width="4" stroke-linecap="round" />
            <path d="M49 77C26 75 22 58 23 46C43 47 54 58 49 77Z" fill="#88ac8e" />
            <path d="M51 59C74 55 80 39 78 25C58 29 47 41 51 59Z" fill="#416e53" />
            <path d="M49 45C34 42 31 31 32 22C45 24 53 32 49 45Z" fill="#a5bfa5" />
            <path d="M29 105H71L65 129H35Z" fill="#c77246" />
            <rect x="25" y="96" width="50" height="16" rx="4" fill="#df8d5b" />
          </svg>
          <div class="plant-status"><span class="eyebrow">Current stage</span><h3>Young plant</h3><p>Growing with every session.</p></div>
        </div>
        <progress :value="6" :max="8" aria-label="Plant growth: 6 of 8 sessions to the next stage"></progress>
        <p class="plant-encouragement"><strong>Keep it up!</strong> 2 more focus sessions until your next growth stage.</p>
      </section>
    </div>
  </section>
</template>

<style scoped>
.stats-page {
  width: 100%;
  background: var(--bg);
  color: var(--text-h);
  text-align: left;
  font-size: 16px;
  line-height: 1.5;
  letter-spacing: 0;
  color-scheme: light;
}
.page-heading p, .panel-description { color: var(--text); }
.preview-label, .period-label { background: var(--accent-bg); color: var(--accent); border-radius: 24px; padding: 6px 12px; white-space: nowrap; font-size: 12px; }
.preview-label { background: #fff; color: var(--text); border: 1px solid var(--border); }
.summary-grid { display: grid; grid-template-columns: repeat(3, minmax(0, 1fr)); gap: 20px; margin-bottom: 20px; }
.summary-card h2 { color: var(--text); font-size: 15px; font-weight: 400; }
.stat-value { font: 700 clamp(30px, 3vw, 40px)/1.3 Georgia, serif; letter-spacing: -0.8px; margin: 10px 0; }
.stat-detail { font-size: 12px; font-weight: 600; color: var(--accent); }
.stat-detail--warm { color: var(--terracotta); }
.activity-grid { display: grid; grid-template-columns: minmax(0, 2fr) minmax(270px, 1fr); gap: 20px; margin-bottom: 20px; }
.panel-heading { display: flex; align-items: center; justify-content: space-between; gap: 12px; }
.panel-description { font-size: 14px; margin-top: 6px; }
.bar-chart { display: grid; grid-template-columns: repeat(7, minmax(0, 1fr)); height: 260px; gap: 12px; margin-top: 20px; }
.bar-column { min-width: 0; display: flex; flex-direction: column; align-items: center; }
.bar-track { width: 100%; flex: 1; display: flex; align-items: end; justify-content: center; border-bottom: 1px solid #eceee8; }
.bar { position: relative; width: min(100%, 34px); background: var(--accent); border-radius: 8px 8px 3px 3px; }
.bar-value { position: absolute; top: -25px; width: 100%; text-align: center; color: var(--text); font-size: 12px; }
.bar-label { color: var(--text); font-size: 11px; padding-top: 10px; }
.heatmap-days, .heatmap { display: grid; grid-template-columns: repeat(7, minmax(0, 1fr)); gap: 8px; }
.heatmap-days { margin: 24px 0 8px; color: var(--text); font-size: 10px; text-align: center; }
.heatmap-cell { display: block; aspect-ratio: 1; border-radius: 6px; }
.level-0 { background: #f4f1e6; }
.level-1 { background: #d0dcd5; }
.level-2 { background: #a8beb0; }
.level-3 { background: #7b9b87; }
.level-4 { background: var(--accent); }
.heatmap-legend { display: flex; align-items: center; justify-content: flex-end; gap: 5px; margin-top: 14px; font-size: 10px; color: var(--text); }
.heatmap-legend .heatmap-cell { width: 11px; border-radius: 3px; }
.streak-note { border-top: 1px solid var(--border); margin-top: 22px; padding-top: 16px; color: var(--accent); font-size: 12px; }
.details-grid { display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 20px; }
.subject-panel { grid-column: 1 / -1; container-type: inline-size; }
.subject-content { display: flex; flex-wrap: wrap; align-items: center; justify-content: space-evenly; gap: 28px; margin-top: 22px; }
.donut { position: relative; width: min(220px, 100%); aspect-ratio: 1; flex-shrink: 0; display: grid; place-items: center; }
.donut-chart { position: absolute; inset: 0; width: 100%; height: 100%; overflow: visible; }
.donut-slice { pointer-events: visiblePainted; }
.donut-slice-shape { transition: transform 180ms ease, filter 180ms ease; }
.donut-slice--active .donut-slice-shape {
  transform: translate(var(--slice-x), var(--slice-y));
  filter: drop-shadow(0 2px 2px rgb(37 43 33 / 18%));
}
.donut-slice:focus-visible { outline: none; }
.donut-slice:focus-visible .donut-slice-shape { stroke: var(--accent); stroke-width: 2; }
@media (prefers-reduced-motion: reduce) {
  .donut-slice-shape { transition: none; }
}
.donut-center { width: 72%; height: 72%; border-radius: 50%; background: #fff; display: flex; flex-direction: column; align-items: center; justify-content: center; pointer-events: none; }
.subject-tooltip { position: absolute; top: 50%; left: calc(100% + 18px); transform: translateY(-50%); z-index: 2; width: 210px; padding: 16px 18px; border: 1px solid var(--border); border-radius: 10px; background: #fff; box-shadow: 0 4px 14px rgb(37 43 33 / 10%); pointer-events: none; font-size: 14px; }
.subject-tooltip strong { display: block; color: var(--accent); font-size: 18px; margin-bottom: 6px; }
.subject-tooltip span { color: var(--text); }
.donut-center strong { font: 600 26px Georgia, serif; }
.donut-center span { font-size: 12px; color: var(--text); margin-top: 4px; }
.subject-legend, .goal-list { list-style: none; margin: 0; padding: 0; }
.subject-legend { width: 100%; max-width: 240px; flex: 1 1 180px; }
.subject-legend li { display: flex; justify-content: space-between; gap: 24px; align-items: center; padding: 10px 0; font-size: 14px; }
.subject-legend li + li { border-top: 1px solid #f0ede5; }
.subject-name { display: flex; align-items: center; gap: 12px; font-weight: 400; }
.subject-name i { width: 10px; height: 10px; flex-shrink: 0; border-radius: 3px; }
.subject-percentage { color: var(--text); font: 600 14px/1.5 var(--sans); font-variant-numeric: tabular-nums; white-space: nowrap; }
.subject-legend__active .subject-name, .subject-legend__active .subject-percentage { color: var(--accent); }
.goal-list { margin-top: 24px; }
.goal-list li + li { margin-top: 22px; }
.goal-heading { display: flex; justify-content: space-between; gap: 12px; font-size: 12px; margin-bottom: 8px; }
.goal-heading span:last-child { color: var(--text); white-space: nowrap; }
progress { display: block; width: 100%; height: 7px; border: 0; border-radius: 8px; overflow: hidden; background: var(--accent-bg); accent-color: var(--accent); }
progress::-webkit-progress-bar { background: var(--accent-bg); border-radius: 8px; }
progress::-webkit-progress-value { background: var(--accent); border-radius: 8px; }
progress::-moz-progress-bar { background: var(--accent); border-radius: 8px; }
.plant-content { display: flex; align-items: center; gap: 20px; margin: 12px 0 16px; }
.plant-illustration { width: 86px; height: 120px; flex-shrink: 0; }
.eyebrow { color: var(--text); font-size: 11px; }
.plant-status h3 { color: var(--accent); font: 700 24px/1.3 Georgia, serif; margin: 3px 0 6px; }
.plant-status p { font-size: 14px; color: var(--text); }
.plant-encouragement { background: var(--accent-bg); border-radius: 8px; margin-top: 14px; padding: 12px; font-size: 12px; color: var(--accent); }
.plant-encouragement strong { display: block; margin-bottom: 2px; color: var(--accent); }
@container (max-width: 520px) {
  .subject-tooltip { top: auto; bottom: calc(100% + 14px); left: 50%; transform: translateX(-50%); }
}
@media (max-width: 1100px) {
  .page-heading { align-items: flex-start; flex-direction: column; }
  .summary-grid { gap: 12px; }
  .summary-card { padding: 18px 14px; }
  .activity-grid { grid-template-columns: 1fr; }
  .streak-panel .heatmap, .heatmap-days { max-width: 340px; margin-left: auto; margin-right: auto; }
  .details-grid { grid-template-columns: 1fr; }
}
@media (max-width: 480px) {
  .summary-grid { grid-template-columns: 1fr; }
  .panel { padding: 20px; }
  .summary-card { padding: 18px 20px; }
  .stat-value { font-size: 32px; margin: 5px 0; }
  .subject-content { flex-direction: column; gap: 20px; }
  .subject-legend { flex-basis: auto; }
  .bar-chart { gap: 8px; height: 210px; }
}
</style>
