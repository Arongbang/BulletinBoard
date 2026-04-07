<template>
  <div>
    <div v-if="loading" class="status">불러오는 중...</div>
    <div v-else-if="error" class="status error">{{ error }}</div>

    <template v-else-if="post">
      <!-- 게시글 -->
      <div class="card">
        <div class="post-meta">
          <span class="author">{{ post.author }}</span>
          <span class="date">{{ formatDate(post.createdAt) }}</span>
          <div class="actions" v-if="authStore.isAdmin || authStore.user?.id === post.authorId">
            <button class="btn-edit" @click="goEdit">수정</button>
            <button class="btn-del" @click="handleDelete">삭제</button>
          </div>
        </div>
        <h2 class="post-title">{{ post.title }}</h2>
        <hr />
        <pre class="post-content">{{ post.content }}</pre>
      </div>

      <button class="btn-back" @click="router.push('/')">목록으로</button>

      <!-- 댓글 -->
      <div class="card comments-card">
        <h3>댓글 {{ post.comments.length }}개</h3>

        <div v-if="post.comments.length === 0" class="no-comment">댓글이 없습니다.</div>
        <CommentItem
          v-for="c in post.comments"
          :key="c.id"
          :comment="c"
          @delete="handleDeleteComment"
        />

        <!-- 댓글 작성 -->
        <div v-if="authStore.user" class="comment-form">
          <textarea
            v-model="newComment"
            placeholder="댓글을 입력하세요..."
            rows="3"
          ></textarea>
          <button class="btn-submit" @click="submitComment" :disabled="!newComment.trim()">
            댓글 등록
          </button>
        </div>
        <p v-else class="login-hint">댓글을 작성하려면 <router-link to="/login">로그인</router-link>하세요.</p>
      </div>
    </template>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { postsApi } from '../api/posts'
import { commentsApi } from '../api/comments'
import { useAuthStore } from '../stores/auth'
import CommentItem from '../components/CommentItem.vue'

const route = useRoute()
const router = useRouter()
const authStore = useAuthStore()

const post = ref(null)
const loading = ref(false)
const error = ref('')
const newComment = ref('')

async function fetchPost() {
  loading.value = true
  error.value = ''
  try {
    post.value = await postsApi.getOne(route.params.id)
  } catch (e) {
    error.value = e.message
  } finally {
    loading.value = false
  }
}

async function handleDelete() {
  if (!confirm('게시글을 삭제하시겠습니까?')) return
  try {
    await postsApi.remove(route.params.id)
    router.push('/')
  } catch (e) {
    alert(e.message)
  }
}

function goEdit() {
  router.push(`/posts/${route.params.id}/edit`)
}

async function submitComment() {
  if (!newComment.value.trim()) return
  try {
    const comment = await commentsApi.create(route.params.id, newComment.value.trim())
    post.value.comments.push(comment)
    newComment.value = ''
  } catch (e) {
    alert(e.message)
  }
}

async function handleDeleteComment(commentId) {
  if (!confirm('댓글을 삭제하시겠습니까?')) return
  try {
    await commentsApi.remove(route.params.id, commentId)
    post.value.comments = post.value.comments.filter((c) => c.id !== commentId)
  } catch (e) {
    alert(e.message)
  }
}

function formatDate(dateStr) {
  return new Date(dateStr).toLocaleString('ko-KR')
}

onMounted(fetchPost)
</script>

<style scoped>
.status { text-align: center; padding: 40px; color: #6b7280; }
.status.error { color: #ef4444; }
.card {
  background: #fff;
  border-radius: 10px;
  padding: 28px;
  box-shadow: 0 2px 8px rgba(0,0,0,.06);
  margin-bottom: 16px;
}
.post-meta {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 12px;
  font-size: 0.875rem;
}
.author { font-weight: 600; color: #1e40af; }
.date { color: #9ca3af; }
.actions { margin-left: auto; display: flex; gap: 8px; }
.btn-edit, .btn-del {
  padding: 4px 12px;
  border-radius: 6px;
  font-size: 0.8rem;
  cursor: pointer;
  border: none;
}
.btn-edit { background: #dbeafe; color: #1e40af; }
.btn-del { background: #fee2e2; color: #ef4444; }
.post-title { font-size: 1.4rem; color: #1e3a8a; margin-bottom: 16px; }
hr { border: none; border-top: 1px solid #e5e7eb; margin-bottom: 20px; }
.post-content { font-size: 0.95rem; line-height: 1.7; color: #374151; white-space: pre-wrap; font-family: inherit; }
.btn-back {
  background: none;
  border: 1px solid #d1d5db;
  padding: 7px 18px;
  border-radius: 7px;
  cursor: pointer;
  margin-bottom: 20px;
  font-size: 0.875rem;
  color: #6b7280;
}
.comments-card h3 { margin-bottom: 16px; font-size: 1rem; color: #1e3a8a; }
.no-comment { color: #9ca3af; font-size: 0.875rem; margin-bottom: 16px; }
.comment-form { margin-top: 20px; }
textarea {
  width: 100%;
  padding: 10px 12px;
  border: 1px solid #d1d5db;
  border-radius: 8px;
  resize: vertical;
  font-size: 0.9rem;
  font-family: inherit;
  outline: none;
}
textarea:focus { border-color: #1e40af; }
.btn-submit {
  margin-top: 8px;
  padding: 8px 20px;
  background: #1e40af;
  color: #fff;
  border: none;
  border-radius: 7px;
  cursor: pointer;
  font-size: 0.875rem;
}
.btn-submit:disabled { opacity: .5; cursor: default; }
.login-hint { margin-top: 16px; font-size: 0.875rem; color: #6b7280; }
.login-hint a { color: #1e40af; }
</style>
