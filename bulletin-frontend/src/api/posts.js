import api from './axios'

export const postsApi = {
  getList: (page = 0, size = 10) =>
    api.get('/posts', { params: { page, size } }).then((r) => r.data),

  getOne: (id) =>
    api.get(`/posts/${id}`).then((r) => r.data),

  create: (data) =>
    api.post('/posts', data).then((r) => r.data),

  update: (id, data) =>
    api.put(`/posts/${id}`, data).then((r) => r.data),

  remove: (id) =>
    api.delete(`/posts/${id}`).then((r) => r.data)
}
