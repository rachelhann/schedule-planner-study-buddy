<script setup>
import {ref}from 'vue'
const currentDate = ref(new Date()) //Today's date
const days = ref([])

const eventsByDate = {}

function addEvent(date, message) {
  if (!eventsByDate[date]) {
    eventsByDate[date] = []
  }
  eventsByDate[date].push(message)
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

addEvent(getDateKey(new Date()), {
  message: "Someone's birthday 🎂",
  start: "00:00",
  end: "12:00"
})
updateWeek()
</script>

<template>
  <div class="Calendar-page">

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
          </div>

        </div>
      </div>

    </div>

  </div>
</template>

<style scoped>
.calendar-header {
  display: grid;
  grid-template-columns: 1fr auto 1fr;
  align-items: center;
}

.calendar-header button:first-child {
  justify-self: start;
}
.Title {
  color: black;
  font-size: 24px;
}

.calendar-header button:last-child {
  justify-self: end;
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
  height: 1200px;
  overflow: hidden;
  display: grid;
  grid-template-rows: repeat(24,50px);
}
.hour-slot {
  border-top: 1px solid #ccc;
}


</style>