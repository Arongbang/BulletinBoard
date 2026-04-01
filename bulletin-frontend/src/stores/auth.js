import { defineStore } from 'pinia'
import { ref } from 'vue'
import { authApi } from '../api/auth'

export const useAuthStore = defineStore('auth', () => {
  const user = ref(null)

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

  return { user, fetchMe, login, logout }
})
