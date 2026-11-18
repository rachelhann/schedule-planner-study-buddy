import { supabase } from './supabaseClient'
import { syncEventNotification } from './notificationsApi'

export async function fetchEvents() {
  const { data, error } = await supabase
    .from('events')
    .select('*')
    .order('starts_at', { ascending: true })

  if (error) throw error
  return data
}

export async function createEvent(userId, payload) {
  const { data, error } = await supabase
    .from('events')
    .insert({ user_id: userId, ...payload })
    .select()
    .single()

  if (error) throw error
  return data
}

export async function updateEvent(id, payload) {
  const { data, error } = await supabase
    .from('events')
    .update(payload)
    .eq('id', id)
    .select()
    .single()

  if (error) throw error

  if (payload.title !== undefined || payload.starts_at !== undefined) {
    await syncEventNotification(id, { title: data.title, startsAt: data.starts_at })
  }

  return data
}

export async function deleteEvent(id) {
  const { error: notificationsError } = await supabase.from('notifications').delete().eq('event_id', id)
  if (notificationsError) throw notificationsError

  const { error } = await supabase.from('events').delete().eq('id', id)
  if (error) throw error
}
