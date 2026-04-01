<template>
  <div class="form-wrap">
    <div class="card">
      <h2>{{ isEdit ? '게시글 수정' : '게시글 작성' }}</h2>
      <form @submit.prevent="handleSubmit">
        <div class="field">
          <label>제목</label>
          <input v-model="form.title" type="text" placeholder="제목을 입력하세요" maxlength="200" required />
        </div>
        <div class="field">
          <label>내용</label>
          <textarea v-model="form.content" placeholder="내용을 입력하세요" rows="14" required></textarea>
        </div>
        <p v-if="error" class="error">{{ error }}</p>
        <div class="btn-row">
          <button type="button" class="btn-cancel" @click="router.back()">취소</button>
          <button type="submit" class="btn-submit" :disabled="loading">
            {{ loading ? '저장 중...' : (isEdit ? '수정' : '등록') }}
          </button>
        </div>
      </form>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { postsApi } from '../api/posts'

const route = useRoute()
const router = useRouter()

const isEdit = computed(() => !!route.params.id && route.path.includes('/edit'))
const form = ref({ title: '', content: '' })
const loading = ref(false)
const error = ref('')

async function fetchPost() {
  if (!isEdit.value) return
  try {
    const post = await postsApi.getOne(route.params.id)
    form.value.title = post.title
    form.value.content = post.content
  } catch (e) {
    error.value = e.message
  }
}

async function handleSubmit() {
  error.value = ''
  loading.value = true
  try {
    if (isEdit.value) {
      await postsApi.update(route.params.id, form.value)
      router.push(`/posts/${route.params.id}`)
    } else {
      const post = await postsApi.create(form.value)
      router.push(`/posts/${post.id}`)
    }
  } catch (e) {
    error.value = e.message
  } finally {
    loading.value = false
  }
}

onMounted(fetchPost)
</script>

<style scoped>
.form-wrap { max-width: 720px; margin: 0 auto; }
.card {
  background: #fff;
  border-radius: 10px;
  padding: 32px;
  box-shadow: 0 2px 8px rgba(0,0,0,.06);
}
h2 { font-size: 1.3rem; color: #1e3a8a; margin-bottom: 24px; }
.field { margin-bottom: 18px; }
label { display: block; font-size: 0.85rem; color: #6b7280; margin-bottom: 5px; }
input, textarea {
  width: 100%;
  padding: 10px 13px;
  border: 1px solid #d1d5db;
  border-radius: 8px;
  font-size: 0.95rem;
  font-family: inherit;
  outline: none;
  resize: vertical;
  transition: border-color .2s;
}
input:focus, textarea:focus { border-color: #1e40af; }
.error { color: #ef4444; font-size: 0.85rem; margin-bottom: 10px; }
.btn-row { display: flex; justify-content: flex-end; gap: 10px; }
.btn-cancel {
  padding: 9px 22px;
  background: #f3f4f6;
  border: none;
  border-radius: 8px;
  cursor: pointer;
  font-size: 0.9rem;
  color: #6b7280;
}
.btn-submit {
  padding: 9px 26px;
  background: #1e40af;
  color: #fff;
  border: none;
  border-radius: 8px;
  cursor: pointer;
  font-size: 0.9rem;
}
.btn-submit:disabled { opacity: .5; cursor: default; }
</style>
