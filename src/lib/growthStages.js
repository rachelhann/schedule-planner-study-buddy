export const GROWTH_STAGES = [
  { key: 'seedling', label: 'Seedling' },
  { key: 'sprout', label: 'Sprout' },
  { key: 'budding', label: 'Budding' },
  { key: 'blooming', label: 'Blooming' },
  { key: 'full-bloom', label: 'Full Bloom' },
]

export const SESSIONS_PER_STAGE = 15

export function getStageIndex(totalSessions) {
  return Math.min(Math.floor(totalSessions / SESSIONS_PER_STAGE), GROWTH_STAGES.length - 1)
}
