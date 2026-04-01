<template>
  <div>
    <div class="list-header">
      <h2>게시글 목록</h2>
    </div>

    <div v-if="loading" class="status">불러오는 중...</div>
    <div v-else-if="error" class="status error">{{ error }}</div>
    <div v-else-if="posts.length === 0" class="status">게시글이 없습니다.</div>

    <table v-else class="post-table">
      <thead>
        <tr>
          <th class="col-id">번호</th>
          <th class="col-title">제목</th>
          <th class="col-author">작성자</th>
          <th class="col-date">작성일</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="post in posts" :key="post.id" @click="goDetail(post.id)" class="row">
          <td>{{ post.id }}</td>
          <td class="title">{{ post.title }}</td>
          <td>{{ post.author }}</td>
          <td>{{ formatDate(post.createdAt) }}</td>
        </tr>
      </tbody>
    </table>

    <div class="pagination" v-if="totalPages > 1">
      <button :disabled="page === 0" @click="changePage(page - 1)">이전</button>
      <span>{{ page + 1 }} / {{ totalPages }}</span>
      <button :disabled="page + 1 >= totalPages" @click="changePage(page + 1)">다음</button>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { postsApi } from '../api/posts'

const router = useRouter()
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

function formatDate(dateStr) {
  return new Date(dateStr).toLocaleDateString('ko-KR')
}

onMounted(fetchPosts)
</script>

<style scoped>
.list-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 16px;
}
h2 { font-size: 1.3rem; color: #1e3a8a; }
.status { text-align: center; padding: 40px; color: #6b7280; }
.status.error { color: #ef4444; }
.post-table {
  width: 100%;
  border-collapse: collapse;
  background: #fff;
  border-radius: 10px;
  overflow: hidden;
  box-shadow: 0 2px 8px rgba(0,0,0,.06);
}
thead { background: #1e40af; color: #fff; }
th, td { padding: 12px 16px; text-align: left; font-size: 0.9rem; }
th { font-weight: 600; }
.col-id { width: 60px; }
.col-author { width: 110px; }
.col-date { width: 120px; }
.row { cursor: pointer; transition: background .15s; }
.row:hover { background: #eff6ff; }
td { border-bottom: 1px solid #f3f4f6; color: #374151; }
.title { font-weight: 500; color: #1e3a8a; }
.pagination {
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 16px;
  margin-top: 24px;
}
.pagination button {
  padding: 6px 16px;
  border: 1px solid #d1d5db;
  border-radius: 6px;
  background: #fff;
  cursor: pointer;
}
.pagination button:disabled { opacity: .4; cursor: default; }
</style>
