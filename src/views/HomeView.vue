<script setup>
import { ref } from 'vue'
import { useAuthStore } from '../stores/auth'

const authStore = useAuthStore()

const currentDate = ref(new Date()) //Today's date
const days = ref([])
const colors = [
  "lightblue",
  "lightgreen",
  "lightcoral",
  "plum",
  "lightyellow"
]

const eventsByDate = {}

const popupMode = ref(null)

const editingEvent = ref(null)
const editingDate = ref(null)
const editingIndex = ref(null)

const originalEvent = ref(null)

function addEvent(date, message) {
  if (!eventsByDate[date]) {
    eventsByDate[date] = []
  }
  eventsByDate[date].push(message)
}

function createEvent() {
  addEvent(editingDate.value, {
    message: editingEvent.value.message,
    start: editingEvent.value.start,
    end: editingEvent.value.end,
    color: editingEvent.value.color
  })

  closePopup()
}

function saveEvent() {
  Object.assign(originalEvent.value, editingEvent.value)

  editingEvent.value = null
  originalEvent.value = null
  editingDate.value = null
  editingIndex.value = null
}

function addEventPopup(day, hour) {
  popupMode.value = "create"

  editingEvent.value = {
    message: "",
    start: `${String(hour).padStart(2, '0')}:00`,
    end: `${String(hour + 1).padStart(2, '0')}:00`,
    color: "green"
  }

  editingDate.value = getDateKey(day)
}

function removeEvent() {
  eventsByDate[editingDate.value].splice(editingIndex.value, 1)

  if (eventsByDate[editingDate.value].length === 0) {
    delete eventsByDate[editingDate.value]
  }

  editingEvent.value = null
  originalEvent.value = null
  editingDate.value = null
  editingIndex.value = null
}

function openNewEvent() {
  popupMode.value = "create"

  editingDate.value = getDateKey(new Date())

  editingEvent.value = {
    message: "",
    start: "09:00",
    end: "10:00",
    color: "lightblue"
  }
}

function getDateKey(date) {
  const year = date.getFullYear()
  const month = String(date.getMonth() + 1).padStart(2, '0')
  const day = String(date.getDate()).padStart(2, '0')

  return `${year}-${month}-${day}`
}

function updateWeek(){
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

function previousWeek(){
  currentDate.value.setDate(currentDate.value.getDate() - 7)
  updateWeek()
}
function nextWeek(){
  currentDate.value.setDate(currentDate.value.getDate() + 7)
  updateWeek()
}

function timeToHours(time, isEnd = false) {
  const [hours, minutes] = time.split(':').map(Number)

  if (isEnd && hours === 0 && minutes === 0) {
    return 24
  }

  return hours + minutes / 60
}

function eventClicked(event, date, index) {
  popupMode.value = "edit"

  editingEvent.value = { ...event }
  originalEvent.value = event

  editingDate.value = date
  editingIndex.value = index
}

function closePopup(){
  editingEvent.value = null
  originalEvent.value = null
  editingDate.value = null
  editingIndex.value = null
}

updateWeek()
</script>

<template>
  <section>
    <p class="home-welcome">Welcome back{{ authStore.user ? `, ${authStore.user.email}` : '' }}</p>

    <div class="Calendar-page">
      <div v-if="editingEvent" class="popup-background" @click="closePopup">

        <div class="popup" @click.stop>

          <input v-model="editingEvent.message">

          <input v-model="editingEvent.start" type="time">

          <input v-model="editingEvent.end" type="time">

          <label>
            Event date:
            <input
                type="date"
                v-model="editingDate"
            >
          </label>

          <div class="color-options">
            <button
                v-for="color in colors"
                :key="color"
                :style="{ backgroundColor: color }"
                @click="editingEvent.color = color"
            >
            </button>
          </div>

          <button @click="popupMode === 'edit' ? saveEvent() : createEvent()">
            Save
          </button>

          <button v-if="popupMode === 'edit'" @click="removeEvent()">
            Delete
          </button>

        </div>

      </div>
      <div class="calendar-header">
        <button @click="previousWeek()"> ← </button>
        <h2 class="Title">
          {{ days[0].getMonth() === days[6].getMonth()
            ? days[0].toLocaleDateString('en-US', { month: 'long', year: 'numeric' })
            : days[0].toLocaleDateString('en-US', { month: 'long' }) + ' - ' +
            days[6].toLocaleDateString('en-US', { month: 'long', year: 'numeric' })
          }}
        </h2>
        <div class="header-right">
          <button @click="openNewEvent">+ Add Event</button>
          <button @click="nextWeek()"> → </button>
        </div>
      </div>


      <div class="calendar-body">

        <div class="time-bar">
          <div v-for="hour in 23" :key="hour" class="time">
            {{ String(hour).padStart(2, '0') }}:00
          </div>
        </div>

        <div class="week">

          <div v-for="day in days" :key="day.toDateString()" class="day">
            <div class="day-name">
              {{day.toLocaleDateString('en-US', {weekday: 'short' }) }}<br>
              {{day.toLocaleDateString('en-US', {day: 'numeric' }) }}
            </div>

            <div class="day-content">

              <div
                  v-for="hour in 24"
                  :key="hour"
                  class="hour-slot"
                  @click="addEventPopup(day, hour)"
              >
              </div>

              <div
                  v-for="(event, index) in eventsByDate[getDateKey(day)] || []"
                  :key="index"
                  class="event"
                  :style="{
                    top: timeToHours(event.start) * 50 + 'px',
                    height: (  timeToHours(event.end, true) -  timeToHours(event.start)) * 50 + 'px',
                    backgroundColor: event.color
                  }"
                  @click="eventClicked(event, getDateKey(day), index)"
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
}

.calendar-header {
  display: grid;
  grid-template-columns: 1fr auto 1fr;
  align-items: center;
}

.calendar-header button:first-child {
  justify-self: start;
  cursor: pointer;
}
.Title {
  color: black;
  font-size: 24px;
  user-select: none;
}

.calendar-header button:last-child {
  justify-self: end;
  cursor: pointer;
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
}

.time-bar {
  margin-top: 110px;
  width: 55px;
  flex-shrink: 0;
  display: grid;
  grid-template-rows: repeat(25, 50px);
  user-select: none;
}
.time {
  font-size: 12px;
}


.day {
  border: 1px solid black;
  min-height: 0;
}

.day-name {
  font-weight: bold;
  padding: 10px;
  text-align: center;
}
.day-content {
  position: relative;

  display: grid;
  grid-template-rows: repeat(24, 50px);
}

.event {
  position: absolute;
  left: 0;
  right: 0;
  box-sizing: border-box;
  padding: 5px;
  border-radius: 5px;
  opacity: 90%;
  cursor: pointer;
}

.hour-slot {
  border-top: 1px solid #ccc;
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
  background: white;
  padding: 25px;
  border-radius: 10px;

  width: 300px;

  box-shadow: 0 5px 20px rgba(0, 0, 0, 0.3);
}

.color-options {
  display: flex;
  gap: 8px;
  margin: 10px 0;
}

.color-options button {
  width: 30px;
  height: 30px;
  border: 1px solid #999;
  border-radius: 50%;
  cursor: pointer;
}

.header-right {
  display: flex;
  justify-content: flex-end;
  gap: 8px;
  align-items: center;
}

</style>
