import { AuthState, User, LoginCredentials } from '@/types';
import { apiService } from '@/services/api';

// Initialize state from localStorage
const savedState = localStorage.getItem('auth')
const initialState: AuthState = savedState ? JSON.parse(savedState) : {
  user: null,
  token: null,
  isAdmin: false
}

export default {
  namespaced: true,
  state: (): AuthState => ({
    ...initialState
  }),
  mutations: {
    SET_USER(state: AuthState, user: User) {
      state.user = user
      localStorage.setItem('auth', JSON.stringify(state))
    },
    SET_TOKEN(state: AuthState, token: string) {
      state.token = token
      localStorage.setItem('auth', JSON.stringify(state))
    },
    SET_ADMIN(state: AuthState, isAdmin: boolean) {
      state.isAdmin = isAdmin
      localStorage.setItem('auth', JSON.stringify(state))
    },
    CLEAR_AUTH(state: AuthState) {
      state.user = null
      state.token = null
      state.isAdmin = false
      localStorage.removeItem('auth')
    }
  },
  actions: {
    async login({ commit }: { commit: Function }, credentials: LoginCredentials) {
      try {
        const response = await apiService.login(credentials)
        const { user, token } = response
        
        commit('SET_USER', user)
        commit('SET_TOKEN', token)
        commit('SET_ADMIN', user.roles?.includes('administrator') || user.roles?.includes('editor') || false)
        
        return response
      } catch (error) {
        console.error('Login error:', error)
        throw error
      }
    },
    async logout({ commit, state }: { commit: Function; state: AuthState }) {
      try {
        if (!state.token) {
          commit('CLEAR_AUTH')
          window.location.href = '/'
          return
        }
        
        await apiService.logout()
        commit('CLEAR_AUTH')
        window.location.href = '/'
      } catch (error) {
        console.error('Logout error:', error)
        commit('CLEAR_AUTH')
        window.location.href = '/'
      }
    },
    // Initialize auth state from localStorage
    async initAuth({ commit, state, dispatch }: { commit: Function; state: AuthState; dispatch: Function }) {
      if (state.token) {
        try{
          const response = await apiService.checkAuth()
          if(response.status !== 200) {
            dispatch('logout')
            return
          }
        } catch (error) {
          dispatch('logout')
        }
      }
    }
  },
  getters: {
    isAuthenticated: (state: AuthState) => !!state.token,
    isAdmin: (state: AuthState) => state.isAdmin,
    currentUser: (state: AuthState) => state.user
  }
} 