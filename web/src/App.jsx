import { useEffect, useState } from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import Header from './components/Header';
import ProtectedRoute from './components/ProtectedRoute';
import Home from './pages/Home';
import SongsList from './pages/SongsList';
import SongDetail from './pages/SongDetail';
import Login from './pages/Login';
import Register from './pages/Register';
import UsersList from './pages/UsersList';
import AdminDashboard from './pages/AdminDashboard';
import AdminFirstLoginSetup from './pages/AdminFirstLoginSetup';
import AdminSongChanges from './pages/AdminSongChanges';
import { authService } from './services/api';
import { clearSession, getToken, getUser, setSession } from './lib/session';

function App() {
  const [bootstrapping, setBootstrapping] = useState(true);

  useEffect(() => {
    const bootstrapSession = async () => {
      const token = getToken();
      const user = getUser();
      if (!token || user) {
        setBootstrapping(false);
        return;
      }

      try {
        const response = await authService.me();
        setSession(token, response.data.user);
      } catch {
        clearSession();
      } finally {
        setBootstrapping(false);
      }
    };

    bootstrapSession();
  }, []);

  if (bootstrapping) {
    return <div className="mx-auto w-full max-w-6xl px-4 py-10 sm:px-6 lg:px-8">Loading session...</div>;
  }

  return (
    <Router>
      <div className="min-h-screen bg-[radial-gradient(circle_at_top,_#f1f5f9_0,_#ffffff_40%)]">
        <Header />
        <main className="pb-12">
          <Routes>
            <Route path="/" element={<Home />} />
            <Route path="/songs" element={<SongsList />} />
            <Route path="/songs/:id" element={<SongDetail />} />
            <Route path="/login" element={<Login />} />
            <Route path="/register" element={<Register />} />
            <Route
              path="/admin/first-login"
              element={(
                <ProtectedRoute allowedRoles={['admin']}>
                  <AdminFirstLoginSetup />
                </ProtectedRoute>
              )}
            />
            <Route
              path="/admin/dashboard"
              element={(
                <ProtectedRoute allowedRoles={['admin']}>
                  <AdminDashboard />
                </ProtectedRoute>
              )}
            />
            <Route
              path="/users"
              element={(
                <ProtectedRoute allowedRoles={['admin']}>
                  <UsersList />
                </ProtectedRoute>
              )}
            />
            <Route
              path="/admin/song-changes"
              element={(
                <ProtectedRoute allowedRoles={['admin']}>
                  <AdminSongChanges />
                </ProtectedRoute>
              )}
            />
          </Routes>
        </main>
      </div>
    </Router>
  );
}

export default App;
