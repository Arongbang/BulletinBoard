<template>
  <NavBar />
  <main class="container">
    <router-view />
  </main>
</template>

<script setup>
import { onMounted } from 'vue'
import NavBar from './components/NavBar.vue'
import { useAuthStore } from './stores/auth'

const authStore = useAuthStore()

onMounted(() => {
  authStore.fetchMe()
})
</script>

<style>
.container {
  max-width: 900px;
  margin: 30px auto;
  padding: 0 16px;
}
</style>
