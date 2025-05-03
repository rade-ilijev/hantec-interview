import axios, { AxiosInstance, AxiosRequestConfig, AxiosResponse } from 'axios';
import { ApiError, ApiResponse, LoginCredentials, Post, User } from '@/types';

class ApiService {
  private api: AxiosInstance;

  constructor() {
    this.api = axios.create({
      baseURL: import.meta.env.VITE_API_URL,
      withCredentials: true,
      headers: {
        'Content-Type': 'application/json',
      },
    });

    this.setupInterceptors();
  }

  private setupInterceptors(): void {
    this.api.interceptors.request.use(
      (config) => {
        const token = localStorage.getItem('token');
        if (token) {
          config.headers['X-WP-Nonce'] = token;
        }
        return config;
      },
      (error) => Promise.reject(error)
    );

    this.api.interceptors.response.use(
      (response) => response,
      (error) => {
        if (error.response?.status === 401) {
          localStorage.removeItem('token');
          window.location.href = '/login';
        }
        return Promise.reject(this.handleError(error));
      }
    );
  }

  private handleError(error: any): ApiError {
    if (error.response) {
      const status = error.response.status;
      const message = error.response.data.message || 'An error occurred';
      
      if (status === 404) {
        return {
          message: 'Post not found',
          status: 404,
          code: 'not_found'
        };
      }
      
      return {
        message,
        status,
        code: error.response.data.code,
      };
    }
    return {
      message: 'Network error',
      status: 0,
    };
  }

  // Auth endpoints
  async login(credentials: LoginCredentials): Promise<ApiResponse<{ token: string; user: User }>> {
    const response = await this.api.post('/wp-json/custom/v1/login', credentials);
    return response.data;
  }

  async logout(): Promise<ApiResponse<void>> {
    const response = await this.api.post('/wp-json/custom/v1/logout');
    return response.data;
  }

  async checkAuth(): Promise<ApiResponse<User>> {
    try { 
      const response = await this.api.get('/wp-json/custom/v1/is-authenticated');
      return response;
    } catch (error: any) {
      return error
    }
  }

  // Posts endpoints
  async getPosts(): Promise<ApiResponse<Post[]>> {
    const response = await this.api.get('/wp-json/custom/v1/posts');
    return response.data;
  }

  async getPost(id: number): Promise<ApiResponse<Post>> {
    try {
      const response = await this.api.get(`/wp-json/custom/v1/post/${id}`);
      if (!response.data) {
        throw new Error('Post not found');
      }
      return response.data;
    } catch (error: any) {
      if (error.response?.status === 404) {
        throw {
          message: 'Post not found',
          status: 404,
          code: 'not_found'
        };
      }
      throw error;
    }
  }

  async deletePost(id: number): Promise<ApiResponse<void>> {
    const response = await this.api.delete(`/wp-json/custom/v1/post/${id}`);
    return response.data;
  }
}

export const apiService = new ApiService(); 