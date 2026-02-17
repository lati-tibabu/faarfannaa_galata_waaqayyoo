const TOKEN_KEY = 'token';
const USER_KEY = 'auth_user';
const DEVICE_KEY = 'device_id';
const VISITOR_KEY = 'visitor_profile';
export const AUTH_CHANGED_EVENT = 'auth:changed';

export const getToken = () => localStorage.getItem(TOKEN_KEY);

export const getUser = () => {
  const rawUser = localStorage.getItem(USER_KEY);
  if (!rawUser) {
    return null;
  }

  try {
    return JSON.parse(rawUser);
  } catch {
    localStorage.removeItem(USER_KEY);
    return null;
  }
};

export const setSession = (token, user) => {
  localStorage.setItem(TOKEN_KEY, token);
  localStorage.setItem(USER_KEY, JSON.stringify(user));
  window.dispatchEvent(new Event(AUTH_CHANGED_EVENT));
};

export const clearSession = () => {
  localStorage.removeItem(TOKEN_KEY);
  localStorage.removeItem(USER_KEY);
  window.dispatchEvent(new Event(AUTH_CHANGED_EVENT));
};

export const getVisitor = () => {
  const raw = localStorage.getItem(VISITOR_KEY);
  if (!raw) {
    return null;
  }
  try {
    return JSON.parse(raw);
  } catch {
    localStorage.removeItem(VISITOR_KEY);
    return null;
  }
};

export const setVisitor = (visitor) => {
  localStorage.setItem(VISITOR_KEY, JSON.stringify(visitor));
};

export const clearVisitor = () => {
  localStorage.removeItem(VISITOR_KEY);
};

export const getOrCreateDeviceId = () => {
  const existing = localStorage.getItem(DEVICE_KEY);
  if (existing) {
    return existing;
  }

  const deviceId = typeof crypto?.randomUUID === 'function'
    ? crypto.randomUUID()
    : `web-${Date.now()}-${Math.random().toString(36).slice(2, 10)}`;

  localStorage.setItem(DEVICE_KEY, deviceId);
  return deviceId;
};
