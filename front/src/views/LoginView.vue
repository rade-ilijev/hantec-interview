<template>
  <div class="login-container">
    <LoginForm @submit="handleLogin" ref="loginForm" />
  </div>
</template>

<script lang="ts">
import { defineComponent } from 'vue'
import { useStore } from 'vuex'
import { useRouter } from 'vue-router'
import LoginForm from '@/components/LoginForm.vue'

export default defineComponent({
  name: 'LoginView',
  components: {
    LoginForm
  },
  setup() {
    const store = useStore()
    const router = useRouter()
    return { store, router }
  },
  methods: {
    async handleLogin(credentials: { username: string; password: string }) {
      try {
        await this.store.dispatch('auth/login', credentials)
        this.router.push('/posts')
      } catch (error: any) {
        const loginForm = this.$refs.loginForm as any
        loginForm.setError(error.message || 'Login failed')
      }
    }
  }
})
</script>

<style scoped>
.login-container {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 100vh;
  background-color: #f8f9fa;
}
</style>