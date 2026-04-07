<template>
  <header class="header">
    <div class="header-inner">
      <router-link to="/" class="logo">
        <span class="logo-icon">B</span>
        <span class="logo-text">Board</span>
      </router-link>

      <nav class="nav-right">
        <template v-if="authStore.user">
          <span class="badge-admin" v-if="authStore.isAdmin">관리자</span>
          <span class="username">{{ authStore.user.username }}</span>
          <router-link to="/posts/new" class="btn btn-write">글쓰기</router-link>
          <button class="btn btn-logout" @click="handleLogout">로그아웃</button>
        </template>
        <template v-else>
          <router-link to="/login" class="btn btn-login">로그인</router-link>
        </template>
      </nav>
    </div>
  </header>
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
.header {
  background: #fff;
  border-bottom: 2px solid #03C75A;
  position: sticky;
  top: 0;
  z-index: 100;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.06);
}

.header-inner {
  max-width: 960px;
  margin: 0 auto;
  padding: 0 20px;
  height: 58px;
  display: flex;
  align-items: center;
  justify-content: space-between;
}

/* 로고 */
.logo {
  display: flex;
  align-items: center;
  gap: 6px;
  text-decoration: none;
}
.logo-icon {
  width: 34px;
  height: 34px;
  background: #03C75A;
  color: #fff;
  font-size: 1.1rem;
  font-weight: 900;
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  letter-spacing: -1px;
}
.logo-text {
  font-size: 1.25rem;
  font-weight: 700;
  color: #03C75A;
  letter-spacing: -0.5px;
}

/* 우측 네비 */
.nav-right {
  display: flex;
  align-items: center;
  gap: 10px;
}

.badge-admin {
  background: #fff3cd;
  color: #856404;
  font-size: 0.72rem;
  font-weight: 700;
  padding: 2px 8px;
  border-radius: 20px;
  border: 1px solid #ffc107;
}

.username {
  font-size: 0.875rem;
  color: #555;
  font-weight: 500;
}

.btn {
  padding: 6px 16px;
  border-radius: 4px;
  font-size: 0.875rem;
  font-weight: 600;
  cursor: pointer;
  border: none;
  text-decoration: none;
  transition: all 0.15s;
  font-family: inherit;
}

.btn-write {
  background: #03C75A;
  color: #fff;
}
.btn-write:hover { background: #02b351; }

.btn-logout {
  background: #fff;
  color: #555;
  border: 1px solid #ddd;
}
.btn-logout:hover { background: #f5f6f7; }

.btn-login {
  background: #03C75A;
  color: #fff;
}
.btn-login:hover { background: #02b351; }
</style>
