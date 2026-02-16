import axios from 'axios';
import { getOrCreateDeviceId, getToken } from '../lib/session';

const API_BASE_URL = import.meta.env.VITE_API_URL || 'http://localhost:3000/api';

const api = axios.create({
  baseURL: API_BASE_URL,
});

// Add token to requests if available
api.interceptors.request.use((config) => {
  const token = getToken();
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
    config.headers['X-Device-Id'] = getOrCreateDeviceId();
  }
  return config;
});

export const authService = {
  register: (userData) => api.post('/users/register', userData),
  login: (credentials) => api.post('/users/login', credentials, {
    headers: { 'X-Device-Id': getOrCreateDeviceId() },
  }),
  me: () => api.get('/users/me'),
};

export const songService = {
  getAllSongs: () => api.get('/songs'),
  getSongById: (id) => api.get(`/songs/${id}`),
  getRecentSongs: () => api.get('/songs/recent'),
  getSongChanges: (status = 'pending') => api.get('/songs/changes', { params: { status } }),
  reviewSongChange: (changeId, data) => api.post(`/songs/changes/${changeId}/review`, data),
  submitSongChange: (id, data) => api.put(`/songs/${id}`, data),
  uploadSongMusic: (id, file) => {
    const formData = new FormData();
    formData.append('music', file);
    return api.post(`/songs/${id}/music`, formData);
  },
  removeSongMusic: (id, fileName) => api.delete(`/songs/${id}/music`, { data: { fileName } }),
  getMusicUrl: (id, fileName) => {
    const baseUrl = API_BASE_URL;
    const url = `${baseUrl}/songs/${id}/music`;
    return fileName ? `${url}?fileName=${fileName}` : url;
  },
  deleteSong: (id) => api.delete(`/songs/${id}`),
  getSyncChanges: (since) => api.get('/songs/sync', { params: since ? { since } : {} }),
};

export const userService = {
  getAdminDashboard: () => api.get('/users/admin/dashboard'),
  completeAdminFirstLogin: (data) => api.post('/users/admin/first-login-setup', data),
  createManagedUser: (data) => api.post('/users/admin/users', data),
  getAllUsers: () => api.get('/users'),
  getUserById: (id) => api.get(`/users/${id}`),
  createUser: (userData) => api.post('/users', userData),
  updateUser: (id, data) => api.put(`/users/${id}`, data),
  deleteUser: (id) => api.delete(`/users/${id}`),
};

export default api;
