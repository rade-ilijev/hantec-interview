export interface User {
  id: number;
  name: string;
  email: string;
  roles: string[];
}

export interface Post {
  id: number;
  title: string;
  content: string;
  excerpt: string;
  date: string;
  time: string;
  author: string;
  thumbnail: string | null;
  link: string;
}

export interface AuthState {
  token: string | null;
  user: User | null;
  isAdmin: boolean;
  isAuthenticated: boolean;
}

export interface PostsState {
  posts: Post[];
  currentPost: Post | null;
  loading: boolean;
  error: string | null;
}

export interface RootState {
  auth: AuthState;
  posts: PostsState;
}

export interface ApiResponse<T> {
  data: T;
  message?: string;
  status: number;
}

export interface LoginCredentials {
  username: string;
  password: string;
}

export interface ApiError {
  message: string;
  status: number;
  code?: string;
} 