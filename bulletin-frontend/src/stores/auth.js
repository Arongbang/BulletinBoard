import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { authApi } from '../api/auth'

export const useAuthStore = defineStore('auth', () => {
  const user = ref(null)

  // 관리자 여부: 백엔드 LoginResponse의 role 필드 기반
  const isAdmin = computed(() => user.value?.role === 'ADMIN')

  async function fetchMe() {
    try {
      user.value = await authApi.me()
    } catch {
      user.value = null
    }
  }

  async function login(username, password) {
    user.value = await authApi.login(username, password)
  }

  async function logout() {
    await authApi.logout()
    user.value = null
  }

  return { user, isAdmin, fetchMe, login, logout }
})
