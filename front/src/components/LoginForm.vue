<template>
  <form @submit.prevent="handleSubmit" class="login-form">
    <h2>Login</h2>
    <div class="form-group">
      <label for="username">Username</label>
      <input
        type="text"
        id="username"
        v-model="username"
        required
        class="form-control"
      />
    </div>
    <div class="form-group">
      <label for="password">Password</label>
      <input
        type="password"
        id="password"
        v-model="password"
        required
        class="form-control"
      />
    </div>
    <button type="submit" class="btn btn-primary">Login</button>
    <p v-if="error" class="error-message">{{ error }}</p>
  </form>
</template>

<script lang="ts">
import { defineComponent } from 'vue'

export default defineComponent({
  name: 'LoginForm',
  emits: ['submit'],
  data() {
    return {
      username: '',
      password: '',
      error: ''
    }
  },
  methods: {
    handleSubmit() {
      this.$emit('submit', {
        username: this.username,
        password: this.password
      })
    },
    setError(error: string) {
      this.error = error
    }
  }
})
</script>
