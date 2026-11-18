<script setup>
import { ref, computed, onMounted } from 'vue'
import { useAuthStore } from '../stores/auth'
import { fetchEvents, updateEvent } from '../lib/eventsApi'
import {
  fetchNotifications,
  createNotification,
  markNotificationRead,
  markNotificationUnread,
  deleteNotification,
} from '../lib/notificationsApi'

const authStore = useAuthStore()

const notifications = ref([])
const isLoading = ref(true)
const loadError = ref('')

function isPastDue(notification) {
  if (!notification.event_id) return false
  const startOfToday = new Date()
  startOfToday.setHours(0, 0, 0, 0)
  return new Date(notification.scheduled_for) < startOfToday
}

const activeNotifications = computed(() => notifications.value.filter((n) => !isPastDue(n)))

const sortedNotifications = computed(() =>
  [...activeNotifications.value].sort((a, b) => new Date(b.scheduled_for) - new Date(a.scheduled_for))
)

const unreadCount = computed(() => activeNotifications.value.filter((n) => !n.read_at).length)

function formatScheduledFor(iso) {
  return new Date(iso).toLocaleString('en-US', {
    month: 'short',
    day: 'numeric',
    hour: 'numeric',
    minute: '2-digit',
  })
}

async function syncEventReminders() {
  const events = await fetchEvents()
  const now = new Date()
  const startOfToday = new Date(now.getFullYear(), now.getMonth(), now.getDate())

  const upcoming = events.filter(
    (event) => new Date(event.starts_at) >= startOfToday && !event.reminder_sent
  )

  for (const event of upcoming) {
    const created = await createNotification(authStore.user.id, {
      event_id: event.id,
      title: `Reminder: ${event.title}`,
      message: `Starts ${formatScheduledFor(event.starts_at)}`,
      scheduled_for: event.starts_at,
    })
    await updateEvent(event.id, { reminder_sent: true })
    notifications.value.push(created)
  }
}

async function loadNotifications() {
  isLoading.value = true
  loadError.value = ''

  try {
    notifications.value = await fetchNotifications()
    await syncEventReminders()
  } catch (error) {
    loadError.value = error.message ?? 'Could not load notifications.'
  } finally {
    isLoading.value = false
  }
}

async function handleMarkRead(notification) {
  if (notification.read_at) return

  try {
    const updated = await markNotificationRead(notification.id)
    Object.assign(notification, updated)
  } catch (error) {
    loadError.value = error.message ?? 'Could not mark this notification as read.'
  }
}

async function handleMarkUnread(notification) {
  if (!notification.read_at) return

  try {
    const updated = await markNotificationUnread(notification.id)
    Object.assign(notification, updated)
  } catch (error) {
    loadError.value = error.message ?? 'Could not mark this notification as unread.'
  }
}

async function handleDelete(notification) {
  try {
    await deleteNotification(notification.id)
    notifications.value = notifications.value.filter((n) => n.id !== notification.id)
  } catch (error) {
    loadError.value = error.message ?? 'Could not delete this notification.'
  }
}

async function markAllRead() {
  await Promise.all(notifications.value.filter((n) => !n.read_at).map((n) => handleMarkRead(n)))
}

onMounted(loadNotifications)
</script>

<template>
  <section class="notifications-page">
    <div class="page-heading">
      <p class="page-subtitle">
        {{ unreadCount > 0 ? `${unreadCount} unread` : "You're all caught up" }}
      </p>
      <button class="mark-all-btn" :disabled="unreadCount === 0" @click="markAllRead">
        Mark all as read
      </button>
    </div>

    <p v-if="loadError" class="load-error">{{ loadError }}</p>

    <p v-if="isLoading" class="status-message">Loading notifications…</p>

    <p v-else-if="sortedNotifications.length === 0" class="status-message">
      No notifications yet. Reminders for upcoming calendar events will show up here.
    </p>

    <ul v-else class="notification-list">
      <li
        v-for="notification in sortedNotifications"
        :key="notification.id"
        class="notification-card"
        :class="{ 'notification-card--unread': !notification.read_at }"
      >
        <span v-if="!notification.read_at" class="unread-dot" aria-hidden="true"></span>

        <div class="notification-body">
          <p class="notification-title">{{ notification.title }}</p>
          <p v-if="notification.message" class="notification-message">{{ notification.message }}</p>
          <p class="notification-time">{{ formatScheduledFor(notification.scheduled_for) }}</p>
        </div>

        <div class="notification-actions">
          <button
            v-if="!notification.read_at"
            class="mark-read-btn"
            type="button"
            @click="handleMarkRead(notification)"
          >
            Mark as read
          </button>

          <button
            v-else
            class="mark-unread-btn"
            type="button"
            @click="handleMarkUnread(notification)"
          >
            Mark as unread
          </button>

          <button
            class="delete-btn"
            type="button"
            aria-label="Delete notification"
            @click="handleDelete(notification)"
          >
            &times;
          </button>
        </div>
      </li>
    </ul>
  </section>
</template>

<style scoped>
.page-heading {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 16px;
  margin-bottom: 20px;
}

.page-subtitle {
  color: var(--shell-text-muted);
  font-size: 14px;
}

.mark-all-btn {
  border: 1px solid var(--shell-border);
  border-radius: 8px;
  padding: 8px 14px;
  background: var(--shell-card);
  color: var(--shell-text);
  font-size: 13px;
  font-weight: 600;
  cursor: pointer;
  transition: border-color 150ms ease, color 150ms ease;
}

.mark-all-btn:hover:not(:disabled) {
  color: var(--shell-green);
  border-color: var(--shell-green-soft);
}

.mark-all-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.load-error {
  color: #dc2626;
  font-size: 13px;
  margin-bottom: 16px;
}

.status-message {
  color: var(--shell-text-muted);
  background: var(--shell-card);
  border: 1px solid var(--shell-border);
  border-radius: 16px;
  padding: 24px;
  text-align: center;
}

.notification-list {
  list-style: none;
  margin: 0;
  padding: 0;
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.notification-card {
  display: flex;
  align-items: flex-start;
  gap: 12px;
  background: var(--shell-card);
  border: 1px solid var(--shell-border);
  border-left: 4px solid transparent;
  border-radius: 14px;
  padding: 16px 18px;
  transition: background 200ms ease, border-color 200ms ease, box-shadow 150ms ease;
}

.notification-card:hover {
  box-shadow: 0 4px 14px color-mix(in srgb, var(--shell-text) 8%, transparent);
}

.notification-card--unread {
  border-left-color: var(--shell-green);
  background: var(--shell-green-soft);
}

.unread-dot {
  flex-shrink: 0;
  width: 8px;
  height: 8px;
  margin-top: 6px;
  border-radius: 50%;
  background: var(--shell-green);
}

.notification-body {
  flex: 1;
  min-width: 0;
}

.notification-actions {
  flex-shrink: 0;
  display: flex;
  align-items: center;
  gap: 10px;
}

.mark-read-btn {
  border: 1px solid var(--shell-green-soft);
  border-radius: 8px;
  padding: 6px 10px;
  background: var(--shell-card);
  color: var(--shell-green);
  font-size: 12px;
  font-weight: 600;
  white-space: nowrap;
  cursor: pointer;
  transition: background 150ms ease;
}

.mark-read-btn:hover {
  background: var(--shell-green-soft);
}

.mark-unread-btn {
  border: 1px solid var(--shell-border);
  border-radius: 8px;
  padding: 6px 10px;
  background: var(--shell-card);
  color: var(--shell-text-muted);
  font-size: 12px;
  font-weight: 600;
  white-space: nowrap;
  cursor: pointer;
  transition: color 150ms ease, border-color 150ms ease;
}

.mark-unread-btn:hover {
  color: var(--shell-text);
  border-color: var(--shell-text-muted);
}

.notification-title {
  font-weight: 600;
  color: var(--shell-text);
  margin: 0 0 4px;
}

.notification-message {
  color: var(--shell-text-muted);
  font-size: 14px;
  margin: 0 0 6px;
}

.notification-time {
  color: var(--shell-text-muted);
  font-size: 12px;
  margin: 0;
}

.delete-btn {
  flex-shrink: 0;
  border: none;
  background: transparent;
  color: var(--shell-text-muted);
  font-size: 20px;
  line-height: 1;
  cursor: pointer;
  padding: 0 4px;
}

.delete-btn:hover {
  color: #dc2626;
}
</style>
