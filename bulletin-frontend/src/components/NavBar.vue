<template>
  <nav class="navbar">
    <router-link to="/" class="brand">게시판</router-link>
    <div class="nav-right">
      <template v-if="authStore.user">
        <span class="username">{{ authStore.user.username }}</span>
        <router-link to="/posts/new" class="btn btn-primary">글쓰기</router-link>
        <button class="btn btn-outline" @click="handleLogout">로그아웃</button>
      </template>
      <template v-else>
        <router-link to="/login" class="btn btn-primary">로그인</router-link>
      </template>
    </div>
  </nav>
</template>

<script setup>
import { useRouter } from 'vue-router'
import { useAuthStore } from '../stores/auth'

const authStore = useAuthStore()
const router = useRouter()

async function handleLogout() {
  await authStore.logout()
  router.push('/login')
}
</script>

<style scoped>
.navbar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 24px;
  height: 56px;
  background: #1e40af;
  box-shadow: 0 2px 4px rgba(0,0,0,.15);
}
.brand {
  font-size: 1.2rem;
  font-weight: 700;
  color: #fff;
  text-decoration: none;
}
.nav-right {
  display: flex;
  align-items: center;
  gap: 12px;
}
.username {
  color: #bfdbfe;
  font-size: 0.9rem;
}
.btn {
  padding: 6px 16px;
  border-radius: 6px;
  font-size: 0.875rem;
  cursor: pointer;
  text-decoration: none;
  border: none;
}
.btn-primary {
  background: #fff;
  color: #1e40af;
  font-weight: 600;
}
.btn-outline {
  background: transparent;
  color: #fff;
  border: 1px solid #93c5fd;
}
.btn-outline:hover { background: rgba(255,255,255,.1); }
</style>
