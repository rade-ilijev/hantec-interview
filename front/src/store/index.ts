import { createStore } from 'vuex';
import { RootState } from '@/types';
import auth from './modules/auth'
import posts from './modules/posts'

export default createStore<RootState>({
  modules: {
    auth,
    posts
  },
});
