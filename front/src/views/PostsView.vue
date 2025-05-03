<template>
  <div class="posts-container">
    <h1>Posts</h1>
    <div class="posts-grid">
      <PostCard
        v-for="post in posts"
        :key="post.id"
        :post="post"
        :is-admin="isAdmin"
        @delete="deletePost"
      />
    </div>
  </div>
</template>

<script lang="ts">
import { defineComponent } from 'vue'
import { useStore } from 'vuex'
import PostCard from '@/components/PostCard.vue'

export default defineComponent({
  name: 'PostsView',
  components: {
    PostCard
  },
  setup() {
    const store = useStore()
    return { store }
  },
  data() {
    return {
      posts: [],
      isAdmin: false
    }
  },
  async created() {
    try {
      await this.fetchPosts()
      this.isAdmin = this.store.getters['auth/isAdmin']
    } catch (error) {
      console.error('Failed to fetch posts:', error)
    }
  },
  methods: {
    async fetchPosts() {
      const posts = await this.store.dispatch('posts/fetchPosts')
      this.posts = posts
    },
    async deletePost(id: number) {
      try {
        await this.store.dispatch('posts/deletePost', id)
        this.posts = this.posts.filter(post => post.id !== id)
      } catch (error) {
        console.error('Failed to delete post:', error)
      }
    }
  }
})
</script>