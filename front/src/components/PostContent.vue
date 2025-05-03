<template>
  <div class="post-content">
    <img v-if="post.thumbnail" :src="post.thumbnail" :alt="post.title" class="post-thumbnail" />
    <h1 class="post-title">{{ post.title }}</h1>
    <div class="post-meta">
      <span class="post-date">{{ post.date }}</span>
      <span class="post-author">by {{ post.author }}</span>
    </div>
    <div class="post-body" v-html="post.content"></div>
    <div class="post-actions">
      <router-link to="/posts" class="btn btn-view">Back to Posts</router-link>
      <button
        v-if="isAdmin"
        @click="handleDelete"
        class="btn btn-delete"
      >
        Delete
      </button>
    </div>
  </div>
</template>

<script lang="ts">
import { defineComponent, PropType } from 'vue'
import { Post } from '@/types'

export default defineComponent({
  name: 'PostContent',
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