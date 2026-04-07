<template>
  <div>
    <!-- 헤더 영역 -->
    <div class="list-header">
      <div>
        <h1 class="page-title">커뮤니티</h1>
        <p class="page-desc">자유롭게 글을 작성하고 소통하세요.</p>
      </div>
      <router-link v-if="authStore.user" to="/posts/new" class="btn-write">
        ✏️ 글쓰기
      </router-link>
    </div>

    <!-- 로딩 / 에러 / 빈 목록 -->
    <div v-if="loading" class="status-box">
      <div class="spinner"></div>
      <span>불러오는 중...</span>
    </div>
    <div v-else-if="error" class="status-box error">⚠️ {{ error }}</div>
    <div v-else-if="posts.length === 0" class="status-box">
      아직 게시글이 없습니다. 첫 글을 작성해보세요!
    </div>

    <!-- 게시글 목록 -->
    <div v-else class="post-list">
      <div
        v-for="post in posts"
        :key="post.id"
        class="post-item"
        @click="goDetail(post.id)"
      >
        <div class="post-main">
          <span class="post-num">{{ post.id }}</span>
          <div class="post-info">
            <p class="post-title">{{ post.title }}</p>
            <div class="post-meta">
              <span class="author">{{ post.author }}</span>
              <span class="sep">·</span>
              <span class="date">{{ formatDate(post.createdAt) }}</span>
            </div>
          </div>
        </div>
        <div
          v-if="authStore.user && (authStore.isAdmin || authStore.user.username === post.author)"
          class="post-actions"
          @click.stop
        >
          <button class="act-btn edit" @click.stop="goEdit(post.id)">수정</button>
          <button class="act-btn del" @click.stop="handleDelete(post.id)">삭제</button>
        </div>
      </div>
    </div>

    <!-- 페이지네이션 -->
    <div class="pagination" v-if="totalPages > 1">
      <button class="page-btn" :disabled="page === 0" @click="changePage(page - 1)">
        &#8249; 이전
      </button>
      <span class="page-info">{{ page + 1 }} / {{ totalPages }}</span>
      <button class="page-btn" :disabled="page + 1 >= totalPages" @click="changePage(page + 1)">
        다음 &#8250;
      </button>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { postsApi } from '../api/posts'
import { useAuthStore } from '../stores/auth'

const router = useRouter()
const authStore = useAuthStore()

const posts = ref([])
const loading = ref(false)
const error = ref('')
const page = ref(0)
const totalPages = ref(0)

async function fetchPosts() {
  loading.value = true
  error.value = ''
  try {
    const data = await postsApi.getList(page.value, 10)
    posts.value = data.content
    totalPages.value = data.totalPages
  } catch (e) {
    error.value = e.message
  } finally {
    loading.value = false
  }
}

function changePage(p) {
  page.value = p
  fetchPosts()
}

function goDetail(id) {
  router.push(`/posts/${id}`)
}

function goEdit(id) {
  router.push(`/posts/${id}/edit`)
}

async function handleDelete(id) {
  if (!confirm('게시글을 삭제하시겠습니까?')) return
  try {
    await postsApi.remove(id)
    await fetchPosts()
  } catch (e) {
    alert(e.message)
  }
}

function formatDate(dateStr) {
  const d = new Date(dateStr)
  const now = new Date()
  if (d.toDateString() === now.toDateString()) {
    return d.toLocaleTimeString('ko-KR', { hour: '2-digit', minute: '2-digit' })
  }
  return d.toLocaleDateString('ko-KR', { year: 'numeric', month: '2-digit', day: '2-digit' })
}

onMounted(fetchPosts)
</script>

<style scoped>
/* 헤더 */
.list-header {
  display: flex;
  align-items: flex-end;
  justify-content: space-between;
  margin-bottom: 20px;
}
.page-title {
  font-size: 1.4rem;
  font-weight: 700;
  color: #1a1a1a;
}
.page-desc {
  font-size: 0.85rem;
  color: #888;
  margin-top: 2px;
}

.btn-write {
  display: inline-flex;
  align-items: center;
  gap: 4px;
  background: #03C75A;
  color: #fff;
  padding: 8px 20px;
  border-radius: 6px;
  font-size: 0.9rem;
  font-weight: 600;
  text-decoration: none;
  transition: background 0.15s;
}
.btn-write:hover { background: #02b351; }

/* 상태 박스 */
.status-box {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 10px;
  padding: 60px 0;
  color: #888;
  font-size: 0.95rem;
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

/* 게시글 목록 */
.post-list {
  background: #fff;
  border-radius: 10px;
  box-shadow: 0 1px 4px rgba(0,0,0,.06);
  overflow: hidden;
}

.post-item {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 16px 20px;
  border-bottom: 1px solid #f0f0f0;
  cursor: pointer;
  transition: background 0.12s;
}
.post-item:last-child { border-bottom: none; }
.post-item:hover { background: #f9fff9; }

.post-main {
  display: flex;
  align-items: center;
  gap: 16px;
  flex: 1;
  min-width: 0;
}

.post-num {
  font-size: 0.8rem;
  color: #bbb;
  min-width: 28px;
  text-align: center;
  font-weight: 500;
}

.post-info { flex: 1; min-width: 0; }

.post-title {
  font-size: 0.975rem;
  font-weight: 500;
  color: #222;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  margin-bottom: 4px;
  transition: color 0.12s;
}
.post-item:hover .post-title { color: #03C75A; }

.post-meta {
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 0.8rem;
  color: #aaa;
}
.author { color: #888; font-weight: 500; }
.sep { color: #ddd; }

/* 액션 버튼 */
.post-actions { display: flex; gap: 6px; flex-shrink: 0; }

.act-btn {
  padding: 4px 11px;
  border-radius: 4px;
  font-size: 0.78rem;
  font-weight: 600;
  cursor: pointer;
  border: 1px solid transparent;
  transition: all 0.12s;
  font-family: inherit;
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

/* 페이지네이션 */
.pagination {
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 16px;
  margin-top: 24px;
}
.page-btn {
  padding: 7px 18px;
  border: 1px solid #ddd;
  border-radius: 6px;
  background: #fff;
  font-size: 0.875rem;
  cursor: pointer;
  font-family: inherit;
  transition: all 0.12s;
  color: #555;
}
.page-btn:hover:not(:disabled) { border-color: #03C75A; color: #03C75A; }
.page-btn:disabled { opacity: 0.4; cursor: default; }
.page-info { font-size: 0.875rem; color: #888; }
</style>
