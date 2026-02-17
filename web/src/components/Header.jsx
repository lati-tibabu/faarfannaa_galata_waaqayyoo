import { useEffect, useRef, useState } from 'react';
import { NavLink, useNavigate } from 'react-router-dom';
import { Check, ChevronDown, LogOut, Moon, Sun } from 'lucide-react';
import { Button } from './ui/button';
import { AUTH_CHANGED_EVENT, clearSession, getToken, getUser } from '../lib/session';
import {
  applyColorMode,
  applyTheme,
  getStoredColorMode,
  getStoredTheme,
  THEMES,
} from '../lib/theme';

const Header = () => {
  const [sessionUser, setSessionUser] = useState(getUser());
  const [theme, setTheme] = useState('gray');
  const [colorMode, setColorMode] = useState('light');
  const [themeMenuOpen, setThemeMenuOpen] = useState(false);
  const isLoggedIn = Boolean(getToken());
  const themeMenuRef = useRef(null);
  const navigate = useNavigate();
  const navLinkClass = ({ isActive }) =>
    `rounded-md px-3 py-2 text-sm font-medium transition-colors ${
      isActive
        ? 'bg-background shadow-sm dark:bg-black dark:text-white dark:shadow-[inset_0_0_0_1px_rgba(255,255,255,0.08)]'
        : 'text-muted-foreground hover:text-foreground dark:text-white/72 dark:hover:text-white'
    }`;

  useEffect(() => {
    const syncSession = () => {
      setSessionUser(getUser());
    };

    window.addEventListener(AUTH_CHANGED_EVENT, syncSession);
    window.addEventListener('storage', syncSession);

    return () => {
      window.removeEventListener(AUTH_CHANGED_EVENT, syncSession);
      window.removeEventListener('storage', syncSession);
    };
  }, []);

  useEffect(() => {
    const storedTheme = getStoredTheme();
    const storedColorMode = getStoredColorMode();
    setTheme(storedTheme);
    setColorMode(storedColorMode);
    applyTheme(storedTheme);
    applyColorMode(storedColorMode);
  }, []);

  useEffect(() => {
    const handleClickOutside = (event) => {
      if (themeMenuRef.current && !themeMenuRef.current.contains(event.target)) {
        setThemeMenuOpen(false);
      }
    };

    window.addEventListener('mousedown', handleClickOutside);
    return () => window.removeEventListener('mousedown', handleClickOutside);
  }, []);

  const handleLogout = () => {
    clearSession();
    navigate('/login');
  };

  const handleThemeChange = (nextThemeValue) => {
    const nextTheme = applyTheme(nextThemeValue);
    setTheme(nextTheme);
    setThemeMenuOpen(false);
  };

  const handleToggleColorMode = () => {
    const nextMode = colorMode === 'dark' ? 'light' : 'dark';
    const appliedMode = applyColorMode(nextMode);
    setColorMode(appliedMode);
  };

  return (
    <header className="relative z-50 border-b border-border/70 bg-background/95 backdrop-blur dark:border-white/10 dark:bg-black/80">
      <nav className="mx-auto flex w-full max-w-6xl flex-col gap-3 px-4 py-3 sm:px-6 lg:px-8">
        <div className="flex w-full items-center justify-between gap-3">
          <NavLink to="/" className="text-base font-semibold tracking-tight dark:text-white">
            Faarfannaa
          </NavLink>
          <div className="flex items-center gap-2">
            <Button variant="outline" size="icon-sm" onClick={handleToggleColorMode} aria-label="Toggle dark mode">
              {colorMode === 'dark' ? <Sun className="size-4" /> : <Moon className="size-4" />}
            </Button>
            <div className="relative" ref={themeMenuRef}>
              <Button
                variant="outline"
                size="sm"
                className="min-w-24 justify-between gap-2 dark:border-white/15 dark:bg-white/5 dark:text-white dark:hover:bg-white/10"
                onClick={() => setThemeMenuOpen((previous) => !previous)}
                aria-haspopup="menu"
                aria-expanded={themeMenuOpen}
              >
                {THEMES.find((item) => item.value === theme)?.label || 'Gray'}
                <ChevronDown className={`size-4 transition-transform ${themeMenuOpen ? 'rotate-180' : ''}`} />
              </Button>
              {themeMenuOpen && (
                <div className="absolute right-0 top-10 z-[70] w-44 overflow-hidden rounded-xl border border-border bg-popover p-1.5 shadow-xl dark:border-white/10 dark:bg-zinc-900">
                  {THEMES.map((themeOption) => {
                    const isActive = themeOption.value === theme;
                    return (
                      <button
                        key={themeOption.value}
                        type="button"
                        className={`flex w-full items-center justify-between rounded-lg px-2.5 py-2 text-left text-sm transition-colors ${
                          isActive
                            ? 'bg-primary text-primary-foreground'
                            : 'text-foreground hover:bg-accent hover:text-accent-foreground dark:text-white/90 dark:hover:bg-white/10 dark:hover:text-white'
                        }`}
                        onClick={() => handleThemeChange(themeOption.value)}
                      >
                        <span>{themeOption.label}</span>
                        {isActive && <Check className="size-4" />}
                      </button>
                    );
                  })}
                </div>
              )}
            </div>
            {isLoggedIn ? (
              <Button onClick={handleLogout} variant="outline" size="sm">
                <LogOut className="size-4" />
                Logout
              </Button>
            ) : (
              <Button asChild variant="outline" size="sm">
                <NavLink to="/login">Login</NavLink>
              </Button>
            )}
          </div>
        </div>

        <div className="w-full overflow-x-auto pb-1">
          <div className="flex min-w-max items-center gap-1 rounded-2xl bg-muted/60 p-1.5 dark:border dark:border-white/10 dark:bg-white/10 dark:shadow-[inset_0_1px_0_rgba(255,255,255,0.08)]">
          <NavLink to="/" className={navLinkClass}>
            Home
          </NavLink>
          <NavLink to="/songs" className={navLinkClass}>
            Songs
          </NavLink>
          {isLoggedIn && (
            <NavLink to="/my-library" className={navLinkClass}>
              My Library
            </NavLink>
          )}
          {sessionUser?.role === 'admin' && !sessionUser.first_login && (
            <NavLink to="/admin/dashboard" className={navLinkClass}>
              Dashboard
            </NavLink>
          )}
          {sessionUser?.role === 'admin' && !sessionUser.first_login && (
            <NavLink to="/users" className={navLinkClass}>
              Users
            </NavLink>
          )}
          {sessionUser?.role === 'admin' && !sessionUser.first_login && (
            <NavLink to="/admin/song-changes" className={navLinkClass}>
              Song Reviews
            </NavLink>
          )}
          {isLoggedIn && (
            <NavLink to="/profile" className={navLinkClass}>
              Profile
            </NavLink>
          )}
          {sessionUser?.role === 'admin' && sessionUser.first_login && (
            <NavLink to="/admin/first-login" className={navLinkClass}>
              Setup
            </NavLink>
          )}
        </div>
        </div>
      </nav>
    </header>
  );
};

export default Header;
