<template>
  <div class="form-wrap">
    <div class="form-card">
      <h2 class="form-title">{{ isEdit ? '✏️ 게시글 수정' : '✏️ 글쓰기' }}</h2>

      <form @submit.prevent="handleSubmit">
        <div class="field">
          <label>제목</label>
          <input
            v-model="form.title"
            type="text"
            placeholder="제목을 입력하세요"
            maxlength="200"
            required
          />
          <span class="char-limit">{{ form.title.length }} / 200</span>
        </div>

        <div class="field">
          <label>내용</label>
          <textarea
            v-model="form.content"
            placeholder="내용을 입력하세요"
            rows="16"
            required
          ></textarea>
        </div>

        <p v-if="error" class="error">⚠️ {{ error }}</p>

        <div class="btn-row">
          <button type="button" class="btn-cancel" @click="router.back()">취소</button>
          <button type="submit" class="btn-submit" :disabled="loading">
            {{ loading ? '저장 중...' : (isEdit ? '수정 완료' : '게시글 등록') }}
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
.form-wrap { max-width: 760px; margin: 0 auto; }

.form-card {
  background: #fff;
  border-radius: 12px;
  padding: 36px 36px 32px;
  box-shadow: 0 1px 6px rgba(0,0,0,.07);
}

.form-title {
  font-size: 1.25rem;
  font-weight: 700;
  color: #1a1a1a;
  margin-bottom: 28px;
  padding-bottom: 16px;
  border-bottom: 2px solid #f0f0f0;
}

.field {
  margin-bottom: 20px;
  position: relative;
}

label {
  display: block;
  font-size: 0.85rem;
  font-weight: 600;
  color: #555;
  margin-bottom: 7px;
}

input {
  width: 100%;
  height: 46px;
  padding: 0 14px;
  border: 1px solid #e0e0e0;
  border-radius: 8px;
  font-size: 0.95rem;
  font-family: inherit;
  outline: none;
  transition: border-color 0.2s;
  background: #fafafa;
}
input:focus { border-color: #03C75A; background: #fff; box-shadow: 0 0 0 3px rgba(3,199,90,0.08); }

.char-limit {
  position: absolute;
  right: 14px;
  bottom: 13px;
  font-size: 0.75rem;
  color: #ccc;
}

textarea {
  width: 100%;
  padding: 14px;
  border: 1px solid #e0e0e0;
  border-radius: 8px;
  font-size: 0.95rem;
  font-family: inherit;
  outline: none;
  resize: vertical;
  min-height: 300px;
  line-height: 1.7;
  transition: border-color 0.2s;
  background: #fafafa;
}
textarea:focus { border-color: #03C75A; background: #fff; box-shadow: 0 0 0 3px rgba(3,199,90,0.08); }

.error {
  color: #e53e3e;
  font-size: 0.85rem;
  margin-bottom: 14px;
  padding: 10px 14px;
  background: #fff5f5;
  border-radius: 6px;
  border: 1px solid #fed7d7;
}

.btn-row {
  display: flex;
  justify-content: flex-end;
  gap: 10px;
  padding-top: 8px;
  border-top: 1px solid #f0f0f0;
  margin-top: 8px;
}

.btn-cancel {
  padding: 10px 24px;
  background: #fff;
  border: 1px solid #ddd;
  border-radius: 6px;
  cursor: pointer;
  font-size: 0.9rem;
  color: #666;
  font-family: inherit;
  transition: all 0.12s;
}
.btn-cancel:hover { background: #f5f6f7; }

.btn-submit {
  padding: 10px 28px;
  background: #03C75A;
  color: #fff;
  border: none;
  border-radius: 6px;
  cursor: pointer;
  font-size: 0.9rem;
  font-weight: 700;
  font-family: inherit;
  transition: background 0.15s;
}
.btn-submit:hover { background: #02b351; }
.btn-submit:disabled { opacity: 0.5; cursor: default; }
</style>
