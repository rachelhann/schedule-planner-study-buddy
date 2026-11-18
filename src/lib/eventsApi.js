import { supabase } from './supabaseClient'

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
  return data
}

export async function deleteEvent(id) {
  const { error } = await supabase.from('events').delete().eq('id', id)
  if (error) throw error
}
