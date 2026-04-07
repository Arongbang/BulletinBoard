<template>
  <div class="comment">
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
</template>

<script setup>
import { useAuthStore } from '../stores/auth'

defineProps({ comment: Object })
defineEmits(['delete'])

const authStore = useAuthStore()

function formatDate(dateStr) {
  return new Date(dateStr).toLocaleString('ko-KR')
}
</script>

<style scoped>
.comment {
  padding: 12px 0;
  border-bottom: 1px solid #e5e7eb;
}
.comment-header {
  display: flex;
  align-items: center;
  gap: 10px;
  margin-bottom: 6px;
}
.comment-author {
  font-weight: 600;
  font-size: 0.875rem;
  color: #1e40af;
}
.comment-date {
  font-size: 0.8rem;
  color: #9ca3af;
}
.btn-delete {
  margin-left: auto;
  background: none;
  border: none;
  color: #ef4444;
  font-size: 0.8rem;
  cursor: pointer;
}
.btn-delete:hover { text-decoration: underline; }
.comment-content {
  font-size: 0.9rem;
  color: #374151;
  white-space: pre-wrap;
}
</style>
