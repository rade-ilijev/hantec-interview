<template>
  <div class="post-container">
    <NotFoundView v-if="notFound" />
    <PostContent
      v-else-if="post"
      :post="post"
      :is-admin="isAdmin"
      @delete="handleDelete"
    />
    <div v-else class="loading">Loading...</div>
  </div>
</template>

<script lang="ts">
import { defineComponent } from 'vue'
import { useStore } from 'vuex'
import { useRoute, useRouter } from 'vue-router'
import NotFoundView from './NotFoundView.vue'
import PostContent from '@/components/PostContent.vue'

export default defineComponent({
  name: 'PostView',
  components: {
    NotFoundView,
    PostContent
  },
  setup() {
    const store = useStore()
    const route = useRoute()
    const router = useRouter()
    return { store, route, router }
  },
  data() {
    return {
      post: null,
      notFound: false,
      isAdmin: false
    }
  },
  async created() {
    this.isAdmin = this.store.getters['auth/isAdmin']
    try {
      const postId = parseInt(this.route.params.id as string)
      await this.store.dispatch('posts/fetchPost', postId)
      this.post = this.store.getters['posts/currentPost']
      if (!this.post) {
        this.notFound = true
      }
    } catch (error: any) {
      console.error('Failed to fetch post:', error)
      if (error.response?.status === 404 || error.message?.includes('not found')) {
        this.notFound = true
      } else {
        this.notFound = true
      }
    }
  },
  methods: {
    async handleDelete(id: number) {
      try {
        await this.store.dispatch('posts/deletePost', id)
        this.router.push('/posts')
      } catch (error) {
        console.error('Failed to delete post:', error)
      }
    }
  }
})
</script>