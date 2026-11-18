import { supabase } from './supabaseClient'

export async function fetchNotifications() {
  const { data, error } = await supabase
    .from('notifications')
    .select('*')
    .order('scheduled_for', { ascending: false })

  if (error) throw error
  return data
}

export async function createNotification(userId, payload) {
  const { data, error } = await supabase
    .from('notifications')
    .insert({ user_id: userId, ...payload })
    .select()
    .single()

  if (error) throw error
  return data
}

export async function markNotificationRead(id) {
  const { data, error } = await supabase
    .from('notifications')
    .update({ read_at: new Date().toISOString() })
    .eq('id', id)
    .select()
    .single()

  if (error) throw error
  return data
}

export async function markNotificationUnread(id) {
  const { data, error } = await supabase
    .from('notifications')
    .update({ read_at: null })
    .eq('id', id)
    .select()
    .single()

  if (error) throw error
  return data
}

export async function deleteNotification(id) {
  const { error } = await supabase.from('notifications').delete().eq('id', id)
  if (error) throw error
}

export async function syncEventNotification(eventId, { title, startsAt }) {
  const { error } = await supabase
    .from('notifications')
    .update({
      title: `Reminder: ${title}`,
      message: `Starts ${new Date(startsAt).toLocaleString('en-US', {
        month: 'short',
        day: 'numeric',
        hour: 'numeric',
        minute: '2-digit',
      })}`,
      scheduled_for: startsAt,
    })
    .eq('event_id', eventId)

  if (error) throw error
}
