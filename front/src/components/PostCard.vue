<template>
  <div class="post-card">
    <img v-if="post.thumbnail" :src="post.thumbnail" :alt="post.title" class="post-thumbnail" />
    <div class="post-content">
      <h2 class="post-title">{{ post.title }}</h2>
      <p class="post-excerpt">{{ post.excerpt }}</p>
      <div class="post-meta">
        <span class="post-date">{{ post.date }}</span>
        <span class="post-time">{{ post.time }}</span>
        <span class="post-author">by {{ post.author }}</span>
      </div>
      <div class="post-actions">
        <router-link :to="'/post/' + post.id" class="btn btn-view">View Post</router-link>
        <button
          v-if="isAdmin"
          @click="handleDelete"
          class="btn btn-delete"
        >
          Delete
        </button>
      </div>
    </div>
  </div>
</template>

<script lang="ts">
import { defineComponent, PropType } from 'vue'
import { Post } from '@/types'

export default defineComponent({
  name: 'PostCard',
  props: {
    post: {
      type: Object as PropType<Post>,
      required: true
    },
    isAdmin: {
      type: Boolean,
      default: false
    }
  },
  emits: ['delete'],
  methods: {
    handleDelete() {
      if (confirm('Are you sure you want to delete this post?')) {
        this.$emit('delete', this.post.id)
      }
    }
  }
})
</script>
