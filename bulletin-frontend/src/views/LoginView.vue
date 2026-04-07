<template>
  <div class="login-wrap">
    <div class="login-card">
      <!-- 로고 -->
      <div class="card-logo">
        <span class="logo-icon">B</span>
        <span class="logo-text">Board</span>
      </div>

      <h2 class="card-title">{{ isRegister ? '회원가입' : '로그인' }}</h2>

      <form @submit.prevent="handleLogin">
        <div class="field">
          <input
            v-model="form.username"
            type="text"
            placeholder="아이디"
            autocomplete="username"
            required
          />
        </div>
        <div class="field">
          <input
            v-model="form.password"
            type="password"
            placeholder="비밀번호"
            autocomplete="current-password"
            required
          />
        </div>

        <p v-if="error" :class="['msg', { success: isSuccessMsg }]">{{ error }}</p>

        <button type="submit" class="btn-submit" :disabled="loading">
          {{ loading ? '처리 중...' : (isRegister ? '회원가입' : '로그인') }}
        </button>
      </form>

      <div class="divider"><span>또는</span></div>

      <p class="toggle-link">
        {{ isRegister ? '이미 계정이 있으신가요?' : '계정이 없으신가요?' }}
        <a href="#" @click.prevent="toggleMode">
          {{ isRegister ? '로그인' : '회원가입' }}
        </a>
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
const isSuccessMsg = ref(false)

function toggleMode() {
  isRegister.value = !isRegister.value
  error.value = ''
  isSuccessMsg.value = false
  form.value = { username: '', password: '' }
}

async function handleLogin() {
  error.value = ''
  isSuccessMsg.value = false
  loading.value = true
  try {
    if (isRegister.value) {
      await authApi.register(form.value.username, form.value.password)
      isRegister.value = false
      isSuccessMsg.value = true
      error.value = '회원가입이 완료됐습니다. 로그인해주세요.'
      form.value = { username: '', password: '' }
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
  min-height: 70vh;
  display: flex;
  align-items: center;
  justify-content: center;
}

.login-card {
  background: #fff;
  border-radius: 12px;
  padding: 48px 40px 40px;
  width: 380px;
  box-shadow: 0 4px 24px rgba(0, 0, 0, 0.08);
}

/* 카드 로고 */
.card-logo {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  margin-bottom: 8px;
}
.logo-icon {
  width: 38px;
  height: 38px;
  background: #03C75A;
  color: #fff;
  font-size: 1.2rem;
  font-weight: 900;
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
}
.logo-text {
  font-size: 1.4rem;
  font-weight: 700;
  color: #03C75A;
}

.card-title {
  text-align: center;
  font-size: 1rem;
  color: #888;
  font-weight: 400;
  margin-bottom: 28px;
}

/* 입력 필드 */
.field {
  margin-bottom: 10px;
}
input {
  width: 100%;
  height: 46px;
  padding: 0 14px;
  border: 1px solid #ddd;
  border-radius: 6px;
  font-size: 0.95rem;
  font-family: inherit;
  outline: none;
  transition: border-color 0.2s;
  background: #fff;
}
input:focus { border-color: #03C75A; box-shadow: 0 0 0 3px rgba(3,199,90,0.1); }
input::placeholder { color: #aaa; }

/* 메시지 */
.msg {
  font-size: 0.83rem;
  color: #e53e3e;
  margin: 6px 0 10px;
  text-align: center;
}
.msg.success { color: #03C75A; }

/* 로그인 버튼 */
.btn-submit {
  width: 100%;
  height: 46px;
  background: #03C75A;
  color: #fff;
  border: none;
  border-radius: 6px;
  font-size: 1rem;
  font-weight: 700;
  font-family: inherit;
  cursor: pointer;
  margin-top: 8px;
  transition: background 0.15s;
}
.btn-submit:hover { background: #02b351; }
.btn-submit:disabled { opacity: 0.6; cursor: default; }

/* 구분선 */
.divider {
  display: flex;
  align-items: center;
  gap: 12px;
  margin: 24px 0 16px;
  color: #ccc;
  font-size: 0.8rem;
}
.divider::before, .divider::after {
  content: '';
  flex: 1;
  height: 1px;
  background: #eee;
}

/* 하단 링크 */
.toggle-link {
  text-align: center;
  font-size: 0.875rem;
  color: #888;
}
.toggle-link a {
  color: #03C75A;
  font-weight: 600;
}
.toggle-link a:hover { text-decoration: underline; }
</style>
