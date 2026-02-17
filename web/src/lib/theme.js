export const THEME_STORAGE_KEY = 'ui_theme';
export const COLOR_MODE_STORAGE_KEY = 'ui_color_mode';

export const THEMES = [
  { value: 'gray', label: 'Gray' },
  { value: 'ocean', label: 'Ocean' },
  { value: 'forest', label: 'Forest' },
  { value: 'amber', label: 'Amber' },
  { value: 'rose', label: 'Rose' },
  { value: 'indigo', label: 'Indigo' },
  { value: 'sunset', label: 'Sunset' },
];

const THEME_SET = new Set(THEMES.map((theme) => theme.value));

export const resolveTheme = (theme) => (THEME_SET.has(theme) ? theme : 'gray');

export const getStoredTheme = () => {
  const stored = localStorage.getItem(THEME_STORAGE_KEY);
  return resolveTheme(stored);
};

export const applyTheme = (theme) => {
  const resolvedTheme = resolveTheme(theme);
  document.documentElement.setAttribute('data-theme', resolvedTheme);
  localStorage.setItem(THEME_STORAGE_KEY, resolvedTheme);
  return resolvedTheme;
};

export const getStoredColorMode = () => {
  const stored = localStorage.getItem(COLOR_MODE_STORAGE_KEY);
  return stored === 'dark' ? 'dark' : 'light';
};

export const applyColorMode = (mode) => {
  const resolvedMode = mode === 'dark' ? 'dark' : 'light';
  document.documentElement.classList.toggle('dark', resolvedMode === 'dark');
  localStorage.setItem(COLOR_MODE_STORAGE_KEY, resolvedMode);
  return resolvedMode;
};
