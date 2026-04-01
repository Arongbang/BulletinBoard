import axios from 'axios'

const api = axios.create({
  baseURL: '/api',
  withCredentials: true,
  headers: { 'Content-Type': 'application/json' }
})

api.interceptors.response.use(
  (res) => res,
  (error) => {
    const message = error.response?.data?.message || '오류가 발생했습니다.'
    return Promise.reject(new Error(message))
  }
)

export default api
