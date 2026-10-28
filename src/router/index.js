import { createRouter, createWebHistory } from 'vue-router'
import { useAuthStore } from '../stores/auth'

const routes = [
  { path: '/login', name: 'login', component: () => import('../views/LoginView.vue'), meta: { public: true } },
  { path: '/register', name: 'register', component: () => import('../views/RegisterView.vue'), meta: { public: true } },
  { path: '/', name: 'home', component: () => import('../views/HomeView.vue'), meta: { title: 'Home' } },
  { path: '/focus', name: 'focus', component: () => import('../views/FocusSessionView.vue'), meta: { title: 'Focus Session' } },
  { path: '/growth', name: 'growth', component: () => import('../views/GrowthView.vue'), meta: { title: 'Growth' } },
  { path: '/stats', name: 'stats', component: () => import('../views/StatsView.vue'), meta: { title: 'Stats' } },
  { path: '/notifications', name: 'notifications', component: () => import('../views/NotificationsView.vue'), meta: { title: 'Notifications' } },
]

const router = createRouter({
  history: createWebHistory(),
  routes,
})

router.beforeEach((to) => {
  const authStore = useAuthStore()
  if (!to.meta.public && !authStore.user) {
    return { name: 'login' }
  }
  if (to.meta.public && authStore.user) {
    return { name: 'home' }
  }
  return true
})

export default router
