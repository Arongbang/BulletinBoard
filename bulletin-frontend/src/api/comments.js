import api from './axios'

export const commentsApi = {
  getList: (postId) =>
    api.get(`/posts/${postId}/comments`).then((r) => r.data),

  create: (postId, content) =>
    api.post(`/posts/${postId}/comments`, { content }).then((r) => r.data),

  remove: (postId, commentId) =>
    api.delete(`/posts/${postId}/comments/${commentId}`).then((r) => r.data)
}
