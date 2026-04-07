<template>
  <div>
    <div v-if="loading" class="status-box">
      <div class="spinner"></div> 불러오는 중...
    </div>
    <div v-else-if="error" class="status-box error">⚠️ {{ error }}</div>

    <template v-else-if="post">
      <!-- 게시글 카드 -->
      <div class="post-card">
        <!-- 제목 영역 -->
        <div class="post-head">
          <h1 class="post-title">{{ post.title }}</h1>
          <div class="post-meta">
            <span class="meta-author">{{ post.author }}</span>
            <span class="meta-sep">·</span>
            <span class="meta-date">{{ formatDate(post.createdAt) }}</span>
            <div
              class="post-actions"
              v-if="authStore.isAdmin || authStore.user?.id === post.authorId"
            >
              <button class="act-btn edit" @click="goEdit">수정</button>
              <button class="act-btn del" @click="handleDelete">삭제</button>
            </div>
          </div>
        </div>

        <div class="divider"></div>

        <!-- 본문 -->
        <div class="post-body">
          <pre class="post-content">{{ post.content }}</pre>
        </div>
      </div>

      <!-- 목록 버튼 -->
      <button class="btn-back" @click="router.push('/')">← 목록으로</button>

      <!-- 댓글 섹션 -->
      <div class="comments-card">
        <h3 class="comments-title">
          댓글 <span class="count">{{ post.comments.length }}</span>
        </h3>

        <div v-if="post.comments.length === 0" class="no-comment">
          첫 번째 댓글을 남겨보세요.
        </div>

        <CommentItem
          v-for="c in post.comments"
          :key="c.id"
          :comment="c"
          @delete="handleDeleteComment"
        />

        <!-- 댓글 작성 폼 -->
        <div v-if="authStore.user" class="comment-form">
          <div class="form-avatar">{{ authStore.user.username[0].toUpperCase() }}</div>
          <div class="form-input-wrap">
            <textarea
              v-model="newComment"
              placeholder="댓글을 입력하세요..."
              rows="3"
            ></textarea>
            <div class="form-footer">
              <span class="char-count">{{ newComment.length }} / 500</span>
              <button
                class="btn-submit"
                @click="submitComment"
                :disabled="!newComment.trim()"
              >
                댓글 등록
              </button>
            </div>
          </div>
        </div>
        <div v-else class="login-hint">
          <router-link to="/login">로그인</router-link> 후 댓글을 작성할 수 있습니다.
        </div>
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
  return new Date(dateStr).toLocaleString('ko-KR', {
    year: 'numeric', month: '2-digit', day: '2-digit',
    hour: '2-digit', minute: '2-digit'
  })
}

onMounted(fetchPost)
</script>

<style scoped>
/* 상태 박스 */
.status-box {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 10px;
  padding: 60px 0;
  color: #888;
  background: #fff;
  border-radius: 10px;
  box-shadow: 0 1px 4px rgba(0,0,0,.05);
}
.status-box.error { color: #e53e3e; }
.spinner {
  width: 20px;
  height: 20px;
  border: 2px solid #eee;
  border-top-color: #03C75A;
  border-radius: 50%;
  animation: spin 0.7s linear infinite;
}
@keyframes spin { to { transform: rotate(360deg); } }

/* 게시글 카드 */
.post-card {
  background: #fff;
  border-radius: 12px;
  box-shadow: 0 1px 6px rgba(0,0,0,.07);
  overflow: hidden;
  margin-bottom: 16px;
}

.post-head {
  padding: 28px 28px 20px;
}

.post-title {
  font-size: 1.5rem;
  font-weight: 700;
  color: #1a1a1a;
  line-height: 1.4;
  margin-bottom: 14px;
}

.post-meta {
  display: flex;
  align-items: center;
  gap: 8px;
  flex-wrap: wrap;
}
.meta-author {
  font-size: 0.9rem;
  font-weight: 600;
  color: #03C75A;
}
.meta-sep { color: #ddd; }
.meta-date {
  font-size: 0.85rem;
  color: #aaa;
}

.post-actions {
  margin-left: auto;
  display: flex;
  gap: 6px;
}
.act-btn {
  padding: 4px 12px;
  border-radius: 4px;
  font-size: 0.8rem;
  font-weight: 600;
  cursor: pointer;
  border: 1px solid transparent;
  font-family: inherit;
  transition: all 0.12s;
}
.act-btn.edit {
  background: #f0fdf4;
  color: #16a34a;
  border-color: #bbf7d0;
}
.act-btn.edit:hover { background: #dcfce7; }
.act-btn.del {
  background: #fff5f5;
  color: #e53e3e;
  border-color: #fed7d7;
}
.act-btn.del:hover { background: #ffe4e6; }

.divider {
  height: 1px;
  background: #f0f0f0;
  margin: 0 28px;
}

.post-body {
  padding: 24px 28px 32px;
}
.post-content {
  font-size: 0.975rem;
  line-height: 1.85;
  color: #333;
  white-space: pre-wrap;
  font-family: inherit;
}

/* 목록 버튼 */
.btn-back {
  background: none;
  border: 1px solid #ddd;
  padding: 8px 18px;
  border-radius: 6px;
  cursor: pointer;
  font-size: 0.875rem;
  color: #666;
  margin-bottom: 20px;
  font-family: inherit;
  transition: all 0.12s;
}
.btn-back:hover { border-color: #03C75A; color: #03C75A; }

/* 댓글 카드 */
.comments-card {
  background: #fff;
  border-radius: 12px;
  padding: 24px 28px;
  box-shadow: 0 1px 6px rgba(0,0,0,.07);
}

.comments-title {
  font-size: 1rem;
  font-weight: 700;
  color: #1a1a1a;
  margin-bottom: 20px;
}
.count {
  color: #03C75A;
  font-weight: 700;
}

.no-comment {
  color: #bbb;
  font-size: 0.9rem;
  padding: 20px 0;
  text-align: center;
}

/* 댓글 작성 폼 */
.comment-form {
  display: flex;
  gap: 12px;
  margin-top: 20px;
  padding-top: 20px;
  border-top: 1px solid #f0f0f0;
}
.form-avatar {
  width: 36px;
  height: 36px;
  background: #03C75A;
  color: #fff;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: 700;
  font-size: 0.9rem;
  flex-shrink: 0;
}
.form-input-wrap { flex: 1; }
textarea {
  width: 100%;
  padding: 12px 14px;
  border: 1px solid #e0e0e0;
  border-radius: 8px;
  font-size: 0.9rem;
  font-family: inherit;
  outline: none;
  resize: vertical;
  transition: border-color 0.2s;
  background: #fafafa;
}
textarea:focus { border-color: #03C75A; background: #fff; box-shadow: 0 0 0 3px rgba(3,199,90,0.08); }

.form-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: 8px;
}
.char-count { font-size: 0.78rem; color: #bbb; }
.btn-submit {
  padding: 8px 20px;
  background: #03C75A;
  color: #fff;
  border: none;
  border-radius: 6px;
  font-size: 0.875rem;
  font-weight: 600;
  cursor: pointer;
  font-family: inherit;
  transition: background 0.15s;
}
.btn-submit:hover { background: #02b351; }
.btn-submit:disabled { opacity: 0.5; cursor: default; }

.login-hint {
  margin-top: 20px;
  padding-top: 20px;
  border-top: 1px solid #f0f0f0;
  font-size: 0.875rem;
  color: #aaa;
  text-align: center;
}
.login-hint a { color: #03C75A; font-weight: 600; }
</style>
