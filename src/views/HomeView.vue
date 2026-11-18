<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { useAuthStore } from '../stores/auth'
import { fetchEvents, createEvent, updateEvent, deleteEvent as deleteEventRow } from '../lib/eventsApi'

const authStore = useAuthStore()

const currentDate = ref(new Date())
const days = ref([])

const eventsByDate = reactive({})
const saveError = ref('')
const isSaving = ref(false)

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

function addLocalEvent(event) {
  if (!eventsByDate[event.dateKey]) {
    eventsByDate[event.dateKey] = []
  }
  eventsByDate[event.dateKey].push(event)
}

function removeLocalEvent(event) {
  const bucket = eventsByDate[event.dateKey]
  if (!bucket) return

  const index = bucket.indexOf(event)
  if (index === -1) return

  bucket.splice(index, 1)
  if (bucket.length === 0) {
    delete eventsByDate[event.dateKey]
  }
}

function getDateKey(date) {
  const year = date.getFullYear()
  const month = String(date.getMonth() + 1).padStart(2, '0')
  const day = String(date.getDate()).padStart(2, '0')

  return `${year}-${month}-${day}`
}

function toDateTime(dateKey, time) {
  const [year, month, day] = dateKey.split('-').map(Number)
  const [hours, minutes] = time.split(':').map(Number)

  return new Date(year, month - 1, day, hours, minutes)
}

function toDbPayload(localEvent) {
  return {
    title: localEvent.message,
    starts_at: toDateTime(localEvent.dateKey, localEvent.start).toISOString(),
    ends_at: toDateTime(localEvent.dateKey, localEvent.end).toISOString(),
    color: localEvent.color
  }
}

function toLocalEvent(row) {
  const starts = new Date(row.starts_at)
  const ends = new Date(row.ends_at)

  return {
    id: row.id,
    dateKey: getDateKey(starts),
    message: row.title,
    start: `${String(starts.getHours()).padStart(2, '0')}:${String(starts.getMinutes()).padStart(2, '0')}`,
    end: `${String(ends.getHours()).padStart(2, '0')}:${String(ends.getMinutes()).padStart(2, '0')}`,
    color: row.color
  }
}

async function saveEvent() {
  if (isSaving.value) return

  if (editingEvent.value.start >= editingEvent.value.end) {
    saveError.value = 'End time must be after start time.'
    return
  }

  isSaving.value = true
  saveError.value = ''

  try {
    const payload = toDbPayload(editingEvent.value)

    if (originalEvent.value) {
      const updated = await updateEvent(originalEvent.value.id, payload)
      Object.assign(originalEvent.value, toLocalEvent(updated))
    } else {
      const created = await createEvent(authStore.user.id, payload)
      addLocalEvent(toLocalEvent(created))
    }

    editingEvent.value = null
    originalEvent.value = null
  } catch (error) {
    saveError.value = error.message ?? 'Could not save this event.'
  } finally {
    isSaving.value = false
  }
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

function hoursToTime(hours) {
  const wholeHours = Math.floor(hours)
  const minutes = Math.round((hours - wholeHours) * 60)

  return `${String(wholeHours).padStart(2, '0')}:${String(minutes).padStart(2, '0')}`
}

const dragState = ref(null)
const draggingEvent = ref(null)
const justDragged = ref(false)

function startEventDrag(event, pointerEvent) {
  dragState.value = {
    event,
    startClientY: pointerEvent.clientY,
    originalStart: timeToHours(event.start),
    duration: timeToHours(event.end) - timeToHours(event.start),
    moved: false
  }
  draggingEvent.value = event

  window.addEventListener('pointermove', onEventDragMove)
  window.addEventListener('pointerup', onEventDragEnd)
}

function onEventDragMove(pointerEvent) {
  if (!dragState.value) return

  const deltaPx = pointerEvent.clientY - dragState.value.startClientY
  if (Math.abs(deltaPx) > 3) {
    dragState.value.moved = true
  }

  const snappedDeltaHours = Math.round((deltaPx / 50) * 4) / 4
  const maxStart = Math.max(0, 24 - dragState.value.duration)
  const newStart = Math.max(0, Math.min(maxStart, dragState.value.originalStart + snappedDeltaHours))

  dragState.value.event.start = hoursToTime(newStart)
  dragState.value.event.end = hoursToTime(newStart + dragState.value.duration)
}

async function onEventDragEnd() {
  window.removeEventListener('pointermove', onEventDragMove)
  window.removeEventListener('pointerup', onEventDragEnd)

  const draggedEvent = dragState.value?.event
  const moved = dragState.value?.moved

  dragState.value = null
  draggingEvent.value = null

  if (!moved) return

  justDragged.value = true

  try {
    await updateEvent(draggedEvent.id, toDbPayload(draggedEvent))
  } catch (error) {
    console.error('Failed to save rescheduled event', error)
  }
}

const isManualEntry = ref(false)

function eventClicked(event) {
  if (justDragged.value) {
    justDragged.value = false
    return
  }

  isManualEntry.value = false
  originalEvent.value = event
  editingEvent.value = { ...event }
}

function openNewEvent(day, hour, manual = false) {
  const endHourValue = Math.min(hour + 1, 23)
  isManualEntry.value = manual
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
  openNewEvent(todayInView ?? days.value[0], today.getHours(), true)
}

function closePopup() {
  editingEvent.value = null
  originalEvent.value = null
  saveError.value = ''
}

async function deleteEvent() {
  if (!originalEvent.value || isSaving.value) return

  isSaving.value = true
  saveError.value = ''

  try {
    await deleteEventRow(originalEvent.value.id)
    removeLocalEvent(originalEvent.value)
    editingEvent.value = null
    originalEvent.value = null
  } catch (error) {
    saveError.value = error.message ?? 'Could not delete this event.'
  } finally {
    isSaving.value = false
  }
}

updateWeek()

onMounted(async () => {
  try {
    const rows = await fetchEvents()
    rows.forEach((row) => addLocalEvent(toLocalEvent(row)))
  } catch (error) {
    console.error('Failed to load events', error)
  }
})
</script>

<template>
  <section>
    <p class="home-welcome">Welcome back{{ authStore.user ? `, ${authStore.user.email}` : '' }}</p>

    <div class="calendar-card">
      <div v-if="editingEvent" class="popup-background" @click="closePopup">

        <div class="popup" @click.stop>

          <h3 class="popup-title">{{ originalEvent ? 'Edit Event' : 'New Event' }}</h3>

          <div class="field">
            <label for="event-title">Title</label>
            <input id="event-title" v-model="editingEvent.message" placeholder="e.g. Study group, exam, appointment">
          </div>

          <div v-if="isManualEntry" class="field">
            <label for="event-date">Date</label>
            <input id="event-date" v-model="editingEvent.dateKey" type="date">
          </div>

          <div class="field-row">
            <div class="field">
              <label for="event-start">Start</label>
              <input id="event-start" v-model="editingEvent.start" type="time">
            </div>
            <div class="field">
              <label for="event-end">End</label>
              <input id="event-end" v-model="editingEvent.end" type="time">
            </div>
          </div>

          <div class="field">
            <label>Color</label>
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
          </div>

          <p v-if="saveError" class="popup-error">{{ saveError }}</p>

          <div class="popup-actions">
            <button class="popup-save" :disabled="isSaving" @click="saveEvent">
              {{ isSaving ? 'Saving…' : 'Save' }}
            </button>

            <button v-if="originalEvent" class="popup-delete" type="button" :disabled="isSaving" @click="deleteEvent">
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
        <button class="new-task-btn" @click="openNewEventDefault()">+ Add Event</button>
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
                  :class="[`event-${event.color}`, { 'event--dragging': draggingEvent === event }]"
                  :style="{
                    top: (timeToHours(event.start) - startHour) * 50 + 'px',
                    height: (timeToHours(event.end) - timeToHours(event.start)) * 50 + 'px'
                  }"
                  @pointerdown="startEventDrag(event, $event)"
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
  background: var(--shell-orange);
  color: #fff;
  font-size: 15px;
  font-weight: 600;
  white-space: nowrap;
  cursor: pointer;
  transition: background 150ms ease;
}

.new-task-btn:hover {
  background: color-mix(in srgb, var(--shell-orange) 85%, black);
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
  cursor: grab;
  user-select: none;
  touch-action: none;
  transition: transform 150ms ease, box-shadow 150ms ease;
}

.event:hover {
  transform: translateY(-1px);
  box-shadow: 0 4px 10px color-mix(in srgb, var(--shell-text) 15%, transparent);
}

.event--dragging {
  cursor: grabbing;
  z-index: 1;
  transition: none;
  box-shadow: 0 6px 16px color-mix(in srgb, var(--shell-text) 25%, transparent);
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
  padding: 28px;
  border-radius: 18px;

  width: 360px;
  display: flex;
  flex-direction: column;
  gap: 16px;

  box-shadow: 0 10px 30px color-mix(in srgb, var(--shell-text) 20%, transparent);
}

.popup-title {
  font-family: var(--shell-serif);
  font-weight: 700;
  font-size: 1.2rem;
  color: var(--shell-text);
  margin: 0;
}

.field {
  display: flex;
  flex-direction: column;
  gap: 6px;
}

.field label {
  font-size: 12px;
  font-weight: 600;
  color: var(--shell-text-muted);
}

.field-row {
  display: flex;
  gap: 12px;
}

.field-row .field {
  flex: 1;
  min-width: 0;
}

.popup input {
  border: 1px solid var(--shell-border);
  border-radius: 8px;
  padding: 8px 10px;
  font: inherit;
  color: var(--shell-text);
  background: var(--shell-bg);
}

.popup-error {
  color: #dc2626;
  font-size: 13px;
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

.popup-save:disabled,
.popup-delete:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

@media (max-width: 640px) {
  .calendar-card {
    padding: 16px;
  }

  .calendar-header {
    flex-wrap: wrap;
    justify-content: center;
  }

  .new-task-btn {
    width: 100%;
  }

  .hour-range-picker {
    flex-wrap: wrap;
  }

  .calendar-body {
    overflow-x: auto;
  }

  .time-bar {
    position: sticky;
    left: 0;
    background: var(--shell-card);
    z-index: 1;
  }

  .week {
    min-width: 630px;
  }

  .popup {
    width: min(360px, calc(100vw - 48px));
  }
}
</style>
