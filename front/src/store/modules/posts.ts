import { Module } from 'vuex';
import { RootState, PostsState, Post, ApiError } from '@/types';
import { apiService } from '@/services/api';

const posts: Module<PostsState, RootState> = {
  namespaced: true,

  state: (): PostsState => ({
    posts: [],
    currentPost: null,
    loading: false,
    error: null,
  }),

  mutations: {
    SET_POSTS(state, posts: Post[]) {
      state.posts = posts;
    },
    SET_LOADING(state, loading: boolean) {
      state.loading = loading;
    },
    SET_CURRENT_POST(state, post: Post) {
      state.currentPost = post;
    },
    SET_ERROR(state, error: string | null) {
      state.error = error;
    },
    REMOVE_POST(state, postId: number) {
      if (Array.isArray(state.posts)) {
        state.posts = state.posts.filter(post => post.id !== postId);
        if (state.currentPost?.id === postId) {
          state.currentPost = null;
        }
      }
    }
  },

  actions: {
    async fetchPosts({ commit }) {
      commit('SET_LOADING', true);
      commit('SET_ERROR', null);
      try {
        const response = await apiService.getPosts();
        commit('SET_POSTS', response.data);
        return response;
      } catch (error: unknown) {
        const apiError = error as ApiError;
        commit('SET_ERROR', apiError.message);
        throw error;
      } finally {
        commit('SET_LOADING', false);
      }
    },

    async fetchPost({ commit }, id: number) {
      commit('SET_LOADING', true);
      commit('SET_ERROR', null);
      try {
        const response = await apiService.getPost(id);
        commit('SET_CURRENT_POST', response);
        return response;
      } catch (error: unknown) {
        const apiError = error as ApiError;
        commit('SET_ERROR', apiError.message);
        throw error;
      } finally {
        commit('SET_LOADING', false);
      }
    },

    async deletePost({ commit }, id: number) {
      commit('SET_LOADING', true);
      commit('SET_ERROR', null);
      try {
        await apiService.deletePost(id);
        commit('REMOVE_POST', id);
      } catch (error: unknown) {
        const apiError = error as ApiError;
        commit('SET_ERROR', apiError.message);
        throw error;
      } finally {
        commit('SET_LOADING', false);
      }
    },
  },

  getters: {
    allPosts: (state) => state.posts,
    currentPost: (state) => state.currentPost,
    isLoading: (state) => state.loading,
    error: (state) => state.error,
  },
};

export default posts; 