import { createRouter, createWebHistory } from 'vue-router'
import { useAuthStore } from '../stores/auth'
import LoginView from '../views/LoginView.vue'
import PostListView from '../views/PostListView.vue'
import PostDetailView from '../views/PostDetailView.vue'
import PostFormView from '../views/PostFormView.vue'

const routes = [
  { path: '/login', component: LoginView },
  { path: '/', component: PostListView },
  { path: '/posts/:id', component: PostDetailView },
  { path: '/posts/new', component: PostFormView, meta: { requiresAuth: true } },
  { path: '/posts/:id/edit', component: PostFormView, meta: { requiresAuth: true } }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

router.beforeEach((to) => {
  if (to.meta.requiresAuth) {
    const authStore = useAuthStore()
    if (!authStore.user) {
      return '/login'
    }
  }
})

export default router
