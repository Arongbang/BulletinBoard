<template>
  <div class="login-wrap">
    <div class="login-card">
      <h2>로그인</h2>
      <form @submit.prevent="handleLogin">
        <div class="field">
          <label>아이디</label>
          <input v-model="form.username" type="text" placeholder="아이디" required />
        </div>
        <div class="field">
          <label>비밀번호</label>
          <input v-model="form.password" type="password" placeholder="비밀번호" required />
        </div>
        <p v-if="error" class="error">{{ error }}</p>
        <button type="submit" class="btn-submit" :disabled="loading">
          {{ loading ? '로그인 중...' : '로그인' }}
        </button>
      </form>
      <p class="register-link">
        계정이 없으신가요?
        <a href="#" @click.prevent="toggleMode">{{ isRegister ? '로그인' : '회원가입' }}</a>
      </p>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '../stores/auth'
import { authApi } from '../api/auth'

const authStore = useAuthStore()
const router = useRouter()

const form = ref({ username: '', password: '' })
const error = ref('')
const loading = ref(false)
const isRegister = ref(false)

function toggleMode() {
  isRegister.value = !isRegister.value
  error.value = ''
}

async function handleLogin() {
  error.value = ''
  loading.value = true
  try {
    if (isRegister.value) {
      await authApi.register(form.value.username, form.value.password)
      isRegister.value = false
      error.value = '회원가입 완료! 로그인해주세요.'
    } else {
      await authStore.login(form.value.username, form.value.password)
      router.push('/')
    }
  } catch (e) {
    error.value = e.message
  } finally {
    loading.value = false
  }
}
</script>

<style scoped>
.login-wrap {
  display: flex;
  justify-content: center;
  padding-top: 60px;
}
.login-card {
  background: #fff;
  border-radius: 12px;
  padding: 40px;
  width: 360px;
  box-shadow: 0 4px 20px rgba(0,0,0,.08);
}
h2 {
  margin-bottom: 28px;
  font-size: 1.4rem;
  color: #1e40af;
  text-align: center;
}
.field {
  margin-bottom: 16px;
}
label {
  display: block;
  font-size: 0.85rem;
  color: #6b7280;
  margin-bottom: 4px;
}
input {
  width: 100%;
  padding: 10px 12px;
  border: 1px solid #d1d5db;
  border-radius: 8px;
  font-size: 0.95rem;
  outline: none;
  transition: border-color .2s;
}
input:focus { border-color: #1e40af; }
.error {
  color: #ef4444;
  font-size: 0.85rem;
  margin-bottom: 12px;
}
.btn-submit {
  width: 100%;
  padding: 11px;
  background: #1e40af;
  color: #fff;
  border: none;
  border-radius: 8px;
  font-size: 1rem;
  cursor: pointer;
  margin-top: 4px;
}
.btn-submit:disabled { opacity: .6; cursor: default; }
.register-link {
  text-align: center;
  margin-top: 16px;
  font-size: 0.875rem;
  color: #6b7280;
}
.register-link a { color: #1e40af; }
</style>
