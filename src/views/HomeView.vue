<script setup>
import { ref } from 'vue'
import { useAuthStore } from '../stores/auth'

const authStore = useAuthStore()

const currentDate = ref(new Date()) //Today's date
const days = ref([])

const eventsByDate = {}

const editingEvent = ref(null)
const originalEvent = ref(null)

function addEvent(date, message) {
  if (!eventsByDate[date]) {
    eventsByDate[date] = []
  }
  eventsByDate[date].push(message)
}
function saveEvent() {
  Object.assign(originalEvent.value, editingEvent.value)

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

function timeToHours(time) {
  const [hours, minutes] = time.split(':').map(Number)

  return hours + minutes / 60
}

function eventClicked(event) {
  originalEvent.value = event
  editingEvent.value = { ...event }
}

function closePopup(){
  editingEvent.value = null
}

addEvent(getDateKey(new Date()), {
  message: "Someone's birthday 🎂",
  start: "03:10",
  end: "08:00",
  color: "lightblue"
})
addEvent(getDateKey(new Date()), {
  message: "Someone's  🎂",
  start: "02:00",
  end: "03:15",
  color: "green"
})
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

          <button @click="saveEvent">
            Save
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
        <button @click="nextWeek()"> → </button>
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

              <div v-for="hour in 24" :key="hour" class="hour-slot"></div>

              <div
                  v-for="event in eventsByDate[getDateKey(day)] || []"
                  :key="event.message"
                  class="event"
                  :style="{
                    top: timeToHours(event.start) * 50 + 'px',
                    height: (  timeToHours(event.end) -  timeToHours(event.start)) * 50 + 'px',
                    backgroundColor: event.color
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
</style>
