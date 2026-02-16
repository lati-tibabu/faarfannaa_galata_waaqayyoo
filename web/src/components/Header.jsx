import { useEffect, useState } from 'react';
import { NavLink, useNavigate } from 'react-router-dom';
import { Button } from './ui/button';
import { AUTH_CHANGED_EVENT, clearSession, getToken, getUser } from '../lib/session';

const Header = () => {
  const [sessionUser, setSessionUser] = useState(getUser());
  const isLoggedIn = Boolean(getToken());
  const navigate = useNavigate();
  const navLinkClass = ({ isActive }) =>
    `rounded-md px-3 py-2 text-sm font-medium transition-colors ${
      isActive ? 'bg-background shadow-sm' : 'text-muted-foreground hover:text-foreground'
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

  const handleLogout = () => {
    clearSession();
    navigate('/login');
  };

  return (
    <header className="border-b border-border/70 bg-background/95 backdrop-blur">
      <nav className="mx-auto flex w-full max-w-6xl flex-wrap items-center gap-3 px-4 py-3 sm:px-6 lg:px-8">
        <NavLink to="/" className="mr-2 text-base font-semibold tracking-tight">
          Faarfannaa
        </NavLink>
        <div className="flex items-center gap-1 rounded-lg bg-muted/60 p-1">
          <NavLink to="/" className={navLinkClass}>
            Home
          </NavLink>
          <NavLink to="/songs" className={navLinkClass}>
            Songs
          </NavLink>
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
        <div className="ml-auto">
          {isLoggedIn ? (
            <Button onClick={handleLogout} variant="outline" size="sm">
              Logout
            </Button>
          ) : (
            <Button asChild variant="outline" size="sm">
              <NavLink to="/login">Login</NavLink>
            </Button>
          )}
        </div>
      </nav>
    </header>
  );
};

export default Header;
