<template>
  <NavBar />
  <main class="container">
    <router-view />
  </main>
</template>

<script setup>
import NavBar from './components/NavBar.vue'
</script>

<style>
@import url('https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@400;500;700&display=swap');

*, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

body {
  font-family: 'Noto Sans KR', -apple-system, BlinkMacSystemFont, sans-serif;
  background: #f5f6f7;
  color: #1a1a1a;
  line-height: 1.6;
  min-height: 100vh;
}

a { text-decoration: none; color: inherit; }

.container {
  max-width: 960px;
  margin: 32px auto;
  padding: 0 20px;
}
</style>
