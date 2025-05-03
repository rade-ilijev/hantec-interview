<template>
  <nav class="navbar">
    <div class="nav-content">
      <router-link to="/posts" class="nav-brand">WordPress Posts</router-link>
      
      <div class="nav-right">
        <template v-if="isAuthenticated">
          <span class="welcome-text">Welcome, {{ currentUser?.name }}</span>
          <button @click="handleLogout" class="btn btn-logout">Logout</button>
        </template>
      </div>
    </div>
  </nav>
</template>

<script lang="ts">
import { defineComponent, computed } from 'vue';
import { useStore } from 'vuex';
import { useRouter } from 'vue-router';

export default defineComponent({
  name: 'NavBar',
  
  setup() {
    const store = useStore();
    const router = useRouter();

    const isAuthenticated = computed(() => store.getters['auth/isAuthenticated']);
    const currentUser = computed(() => store.getters['auth/currentUser']);

    const handleLogout = async () => {
      store.dispatch('auth/logout');
      router.push('/login');
    };

    return {
      isAuthenticated,
      currentUser,
      handleLogout
    };
  }
});
</script>