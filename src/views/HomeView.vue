<script setup>
import { ref, reactive, computed } from 'vue'
import { useAuthStore } from '../stores/auth'

const authStore = useAuthStore()

const currentDate = ref(new Date())
const days = ref([])

const eventsByDate = reactive({})

const editingEvent = ref(null)
const originalEvent = ref(null)

const colorOptions = ['green', 'orange', 'pink', 'lavender', 'mint', 'yellow', 'sky']

const startHour = ref(1)
const endHour = ref(23)

const visibleHours = computed(() => {
  const hours = []
  for (let hour = startHour.value; hour <= endHour.value; hour++) {
    hours.push(hour)
  }
  return hours
})

function onStartHourChange() {
  if (startHour.value >= endHour.value) {
    endHour.value = Math.min(23, startHour.value + 1)
  }
}

function onEndHourChange() {
  if (endHour.value <= startHour.value) {
    startHour.value = Math.max(0, endHour.value - 1)
  }
}

function addEvent(date, eventData) {
  if (!eventsByDate[date]) {
    eventsByDate[date] = []
  }
  eventsByDate[date].push({ id: crypto.randomUUID(), ...eventData })
}
function saveEvent() {
  if (originalEvent.value) {
    Object.assign(originalEvent.value, editingEvent.value)
  } else {
    const { dateKey, ...eventData } = editingEvent.value
    addEvent(dateKey, eventData)
  }

  editingEvent.value = null
  originalEvent.value = null
}

function removeEvent(date, index) {
  if (!eventsByDate[date]) return
  eventsByDate[date].splice(index, 1)
  if (eventsByDate[date].length === 0) {
    delete eventsByDate[date]
  }
}

function getDateKey(date) {
  const year = date.getFullYear()
  const month = String(date.getMonth() + 1).padStart(2, '0')
  const day = String(date.getDate()).padStart(2, '0')

  return `${year}-${month}-${day}`
}

function updateWeek() {
  const date = new Date(currentDate.value)

  const dayOfWeek = date.getDay()

  date.setDate(date.getDate() - dayOfWeek)
  days.value = []

  for (let i = 0; i < 7; i++) {
    const newDate = new Date(date)
    newDate.setDate(date.getDate() + i)

    days.value.push(newDate)
  }
}

function previousWeek() {
  currentDate.value.setDate(currentDate.value.getDate() - 7)
  updateWeek()
}
function nextWeek() {
  currentDate.value.setDate(currentDate.value.getDate() + 7)
  updateWeek()
}

function formatHourLabel(hour) {
  const period = hour < 12 ? 'AM' : 'PM'
  const displayHour = hour % 12 === 0 ? 12 : hour % 12
  return `${displayHour} ${period}`
}

function timeToHours(time) {
  const [hours, minutes] = time.split(':').map(Number)

  return hours + minutes / 60
}

function eventClicked(event) {
  originalEvent.value = event
  editingEvent.value = { ...event }
}

function openNewEvent(day, hour) {
  const endHourValue = Math.min(hour + 1, 23)
  originalEvent.value = null
  editingEvent.value = {
    dateKey: getDateKey(day),
    message: '',
    start: `${String(hour).padStart(2, '0')}:00`,
    end: `${String(endHourValue).padStart(2, '0')}:00`,
    color: 'sky'
  }
}

function openNewEventDefault() {
  const today = new Date()
  const todayInView = days.value.find((day) => getDateKey(day) === getDateKey(today))
  openNewEvent(todayInView ?? days.value[0], today.getHours())
}

function closePopup() {
  editingEvent.value = null
  originalEvent.value = null
}

function deleteEvent() {
  if (!originalEvent.value) return

  for (const dateKey of Object.keys(eventsByDate)) {
    const index = eventsByDate[dateKey].indexOf(originalEvent.value)
    if (index !== -1) {
      removeEvent(dateKey, index)
      break
    }
  }

  editingEvent.value = null
  originalEvent.value = null
}

addEvent(getDateKey(new Date()), {
  message: "Someone's birthday 🎂",
  start: "03:10",
  end: "08:00",
  color: "green"
})
addEvent(getDateKey(new Date()), {
  message: "Someone's  🎂",
  start: "02:00",
  end: "03:15",
  color: "orange"
})
updateWeek()
</script>

<template>
  <section>
    <p class="home-welcome">Welcome back{{ authStore.user ? `, ${authStore.user.email}` : '' }}</p>

    <div class="calendar-card">
      <div v-if="editingEvent" class="popup-background" @click="closePopup">

        <div class="popup" @click.stop>

          <input v-model="editingEvent.message" placeholder="Add a title">

          <input v-model="editingEvent.start" type="time">

          <input v-model="editingEvent.end" type="time">

          <div class="color-picker">
            <button
                v-for="colorOption in colorOptions"
                :key="colorOption"
                type="button"
                class="color-swatch"
                :class="[`event-${colorOption}`, { 'color-swatch--active': editingEvent.color === colorOption }]"
                :aria-label="colorOption"
                @click="editingEvent.color = colorOption"
            ></button>
          </div>

          <div class="popup-actions">
            <button class="popup-save" @click="saveEvent">
              Save
            </button>

            <button v-if="originalEvent" class="popup-delete" type="button" @click="deleteEvent">
              Delete
            </button>
          </div>

        </div>

      </div>
      <div class="calendar-header">
        <div class="calendar-nav-group">
          <button class="calendar-nav" @click="previousWeek()"> &lt; </button>
          <h2 class="calendar-title">
            {{ days[0].getMonth() === days[6].getMonth()
              ? days[0].toLocaleDateString('en-US', { month: 'long', year: 'numeric' })
              : days[0].toLocaleDateString('en-US', { month: 'long' }) + ' - ' +
              days[6].toLocaleDateString('en-US', { month: 'long', year: 'numeric' })
            }}
          </h2>
          <button class="calendar-nav" @click="nextWeek()"> &gt; </button>
        </div>
        <button class="new-task-btn" @click="openNewEventDefault()">+ New Task</button>
      </div>

      <div class="hour-range-picker">
        <label>
          From
          <select v-model.number="startHour" @change="onStartHourChange">
            <option v-for="hour in 24" :key="hour - 1" :value="hour - 1">{{ formatHourLabel(hour - 1) }}</option>
          </select>
        </label>
        <label>
          To
          <select v-model.number="endHour" @change="onEndHourChange">
            <option v-for="hour in 24" :key="hour - 1" :value="hour - 1">{{ formatHourLabel(hour - 1) }}</option>
          </select>
        </label>
      </div>

      <div class="calendar-body">

        <div class="time-bar" :style="{ gridTemplateRows: `repeat(${visibleHours.length}, 50px)` }">
          <div v-for="hour in visibleHours" :key="hour" class="time">
            {{ formatHourLabel(hour) }}
          </div>
        </div>

        <div class="week">

          <div v-for="day in days" :key="day.toDateString()" class="day">
            <div class="day-name">
              {{day.toLocaleDateString('en-US', {weekday: 'short' }) }}<br>
              {{day.toLocaleDateString('en-US', {day: 'numeric' }) }}
            </div>

            <div class="day-content" :style="{ gridTemplateRows: `repeat(${visibleHours.length}, 50px)` }">

              <div
                  v-for="hour in visibleHours"
                  :key="hour"
                  class="hour-slot"
                  @click="openNewEvent(day, hour)"
              ></div>

              <div
                  v-for="event in eventsByDate[getDateKey(day)] || []"
                  :key="event.id"
                  class="event"
                  :class="`event-${event.color}`"
                  :style="{
                    top: (timeToHours(event.start) - startHour) * 50 + 'px',
                    height: (timeToHours(event.end) - timeToHours(event.start)) * 50 + 'px'
                  }"
                  @click="eventClicked(event)"
              >
                {{ event.message }}
              </div>

            </div>

          </div>
        </div>

      </div>

    </div>
  </section>
</template>

<style scoped>
.home-welcome {
  color: var(--shell-text-muted);
  margin-bottom: 1.5rem;
}

.calendar-card {
  background: var(--shell-card);
  border: 1px solid var(--shell-border);
  border-radius: 22px;
  padding: 28px;
}

.calendar-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 16px;
  margin-bottom: 20px;
}

.calendar-nav-group {
  display: flex;
  align-items: center;
  gap: 14px;
}

.new-task-btn {
  border: none;
  border-radius: 10px;
  padding: 12px 22px;
  background: var(--shell-green);
  color: #fff;
  font-size: 15px;
  font-weight: 600;
  white-space: nowrap;
  cursor: pointer;
  transition: background 150ms ease;
}

.new-task-btn:hover {
  background: color-mix(in srgb, var(--shell-green) 85%, black);
}

.calendar-nav {
  cursor: pointer;
  width: 36px;
  height: 36px;
  border: 1px solid var(--shell-border);
  border-radius: 8px;
  background: var(--shell-card);
  color: var(--shell-text-muted);
  font-size: 15px;
  line-height: 1;
  transition: color 150ms ease, border-color 150ms ease;
}

.calendar-nav:hover {
  color: var(--shell-green);
  border-color: var(--shell-green-soft);
}

.calendar-title {
  font-family: var(--shell-serif);
  font-weight: 700;
  color: var(--shell-text);
  font-size: 1.3rem;
  user-select: none;
  margin: 0;
}

.calendar-body {
  display: flex;
  align-items: stretch;
}

.week {
  flex: 1;
  display: grid;
  grid-template-columns: repeat(7, 1fr);
  align-items: start;
  gap: 8px;
}

.hour-range-picker {
  display: flex;
  gap: 16px;
  margin-bottom: 16px;
}

.hour-range-picker label {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 13px;
  color: var(--shell-text-muted);
}

.hour-range-picker select {
  border: 1px solid var(--shell-border);
  border-radius: 8px;
  padding: 6px 8px;
  font: inherit;
  font-size: 13px;
  color: var(--shell-text);
  background: var(--shell-card);
  cursor: pointer;
}

.time-bar {
  margin-top: 110px;
  width: 55px;
  flex-shrink: 0;
  display: grid;
  user-select: none;
}

.time {
  font-size: 12px;
  color: var(--shell-text-muted);
}

.day {
  border: 1px solid var(--shell-border);
  border-radius: 12px;
  overflow: hidden;
  min-height: 0;
}

.day-name {
  font-weight: 600;
  color: var(--shell-text-muted);
  padding: 10px;
  text-align: center;
  background: var(--shell-bg);
  border-bottom: 1px solid var(--shell-border);
}

.day-content {
  position: relative;

  display: grid;
  overflow: hidden;
}

.event {
  position: absolute;
  left: 4px;
  right: 4px;
  box-sizing: border-box;
  padding: 5px 8px;
  border-radius: 8px;
  border: 1px solid color-mix(in srgb, var(--event-hue) 55%, transparent);
  background: color-mix(in srgb, var(--event-hue) 32%, transparent);
  color: var(--event-hue);
  font-size: 12px;
  font-weight: 600;
  cursor: pointer;
  transition: transform 150ms ease, box-shadow 150ms ease;
}

.event:hover {
  transform: translateY(-1px);
  box-shadow: 0 4px 10px color-mix(in srgb, var(--shell-text) 15%, transparent);
}

.event-green {
  --event-hue: #22c55e;
}

.event-orange {
  --event-hue: #f97316;
}

.event-pink {
  --event-hue: #ec4899;
}

.event-lavender {
  --event-hue: #8b5cf6;
}

.event-mint {
  --event-hue: #14b8a6;
}

.event-yellow {
  --event-hue: #f59e0b;
}

.event-sky {
  --event-hue: #0ea5e9;
}

.hour-slot {
  border-top: 1px solid var(--shell-border);
  cursor: pointer;
  transition: background 100ms ease;
}

.hour-slot:hover {
  background: var(--shell-green-soft);
}

.popup-background {
  position: fixed;
  top: 0;
  left: 0;
  width: 100vw;
  height: 100vh;

  background: rgba(0, 0, 0, 0.5);

  display: flex;
  justify-content: center;
  align-items: center;

  z-index: 1000;
}

.popup {
  background: var(--shell-card);
  border: 1px solid var(--shell-border);
  padding: 25px;
  border-radius: 16px;

  width: 300px;
  display: flex;
  flex-direction: column;
  gap: 12px;

  box-shadow: 0 10px 30px color-mix(in srgb, var(--shell-text) 20%, transparent);
}

.popup input {
  border: 1px solid var(--shell-border);
  border-radius: 8px;
  padding: 8px 10px;
  font: inherit;
  color: var(--shell-text);
  background: var(--shell-bg);
}

.color-picker {
  display: flex;
  gap: 10px;
  flex-wrap: wrap;
}

.color-swatch {
  width: 26px;
  height: 26px;
  border-radius: 50%;
  border: none;
  padding: 0;
  background: var(--event-hue);
  cursor: pointer;
  transition: transform 100ms ease, box-shadow 100ms ease;
}

.color-swatch:hover {
  transform: scale(1.1);
}

.color-swatch--active {
  box-shadow: 0 0 0 2px var(--shell-card), 0 0 0 4px var(--event-hue);
}

.popup-actions {
  display: flex;
  gap: 8px;
  margin-top: 4px;
}

.popup-save {
  flex: 1;
  border: none;
  border-radius: 8px;
  padding: 10px;
  background: var(--shell-green);
  color: #fff;
  font-weight: 600;
  cursor: pointer;
}

.popup-save:hover {
  background: color-mix(in srgb, var(--shell-green) 85%, black);
}

.popup-delete {
  flex: 1;
  border: none;
  border-radius: 8px;
  padding: 10px;
  background: #dc2626;
  color: #fff;
  font-weight: 600;
  cursor: pointer;
}

.popup-delete:hover {
  background: color-mix(in srgb, #dc2626 85%, black);
}
</style>
