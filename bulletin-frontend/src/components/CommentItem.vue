<template>
  <div class="comment">
    <div class="avatar">{{ comment.author[0].toUpperCase() }}</div>
    <div class="comment-body">
      <div class="comment-header">
        <span class="comment-author">{{ comment.author }}</span>
        <span class="comment-date">{{ formatDate(comment.createdAt) }}</span>
        <button
          v-if="authStore.isAdmin || authStore.user?.id === comment.authorId"
          class="btn-delete"
          @click="$emit('delete', comment.id)"
        >삭제</button>
      </div>
      <p class="comment-content">{{ comment.content }}</p>
    </div>
  </div>
</template>

<script setup>
import { useAuthStore } from '../stores/auth'

defineProps({ comment: Object })
defineEmits(['delete'])

const authStore = useAuthStore()

function formatDate(dateStr) {
  const d = new Date(dateStr)
  const now = new Date()
  const diff = Math.floor((now - d) / 1000)
  if (diff < 60) return '방금 전'
  if (diff < 3600) return `${Math.floor(diff / 60)}분 전`
  if (diff < 86400) return `${Math.floor(diff / 3600)}시간 전`
  return d.toLocaleDateString('ko-KR', { month: '2-digit', day: '2-digit', hour: '2-digit', minute: '2-digit' })
}
</script>

<style scoped>
.comment {
  display: flex;
  gap: 12px;
  padding: 16px 0;
  border-bottom: 1px solid #f5f5f5;
}
.comment:last-of-type { border-bottom: none; }

.avatar {
  width: 34px;
  height: 34px;
  background: linear-gradient(135deg, #03C75A, #02a34a);
  color: #fff;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 0.85rem;
  font-weight: 700;
  flex-shrink: 0;
}

.comment-body { flex: 1; }

.comment-header {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 6px;
}

.comment-author {
  font-size: 0.875rem;
  font-weight: 700;
  color: #1a1a1a;
}

.comment-date {
  font-size: 0.78rem;
  color: #bbb;
}

.btn-delete {
  margin-left: auto;
  background: none;
  border: none;
  color: #ccc;
  font-size: 0.78rem;
  cursor: pointer;
  font-family: inherit;
  padding: 0;
  transition: color 0.12s;
}
.btn-delete:hover { color: #e53e3e; }

.comment-content {
  font-size: 0.9rem;
  color: #444;
  line-height: 1.65;
  white-space: pre-wrap;
}
</style>
