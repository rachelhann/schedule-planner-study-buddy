import { supabase } from './supabaseClient'

export async function fetchCompletedSessionCount() {
  const { count, error } = await supabase
    .from('study_sessions')
    .select('*', { count: 'exact', head: true })
    .eq('completed', true)

  if (error) throw error
  return count ?? 0
}

export async function createCompletedSession(userId, { startedAt, endedAt }) {
  const { data, error } = await supabase
    .from('study_sessions')
    .insert({ user_id: userId, started_at: startedAt, ended_at: endedAt, completed: true })
    .select()
    .single()

  if (error) throw error
  return data
}
