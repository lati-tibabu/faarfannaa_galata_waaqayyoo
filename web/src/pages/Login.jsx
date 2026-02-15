import { useEffect, useState } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import { authService } from '../services/api';
import { getToken, getUser, setSession } from '../lib/session';
import { Button } from '../components/ui/button';
import { Input } from '../components/ui/input';
import { Card, CardContent, CardHeader, CardTitle } from '../components/ui/card';

const Login = () => {
  const [formData, setFormData] = useState({ email: '', password: '' });
  const [error, setError] = useState('');
  const navigate = useNavigate();

  useEffect(() => {
    const token = getToken();
    const user = getUser();

    if (!token || !user) {
      return;
    }

    if (user.role === 'admin' && user.first_login) {
      navigate('/admin/first-login', { replace: true });
      return;
    }

    if (user.role === 'admin') {
      navigate('/admin/dashboard', { replace: true });
      return;
    }

    navigate('/', { replace: true });
  }, [navigate]);

  const handleChange = (e) => {
    setFormData({ ...formData, [e.target.name]: e.target.value });
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');
    try {
      const response = await authService.login({
        email: formData.email.trim().toLowerCase(),
        password: formData.password,
      });
      setSession(response.data.token, response.data.user);

      if (response.data.mustSetupAdmin) {
        navigate('/admin/first-login', { replace: true });
        return;
      }

      if (response.data.user?.role === 'admin') {
        navigate('/admin/dashboard', { replace: true });
        return;
      }

      navigate('/', { replace: true });
    } catch (err) {
      console.error(err);
      setError(err?.response?.data?.error || 'Login failed');
    }
  };

  return (
    <div className="mx-auto flex w-full max-w-6xl justify-center px-4 py-10 sm:px-6 lg:px-8">
      <Card className="w-full max-w-md border-border/70 bg-card/95 shadow-sm">
        <CardHeader className="gap-2">
          <CardTitle className="text-2xl tracking-tight">Login</CardTitle>
          <p className="text-sm text-muted-foreground">Sign in to access your account.</p>
        </CardHeader>
        <CardContent>
          <form onSubmit={handleSubmit} className="space-y-4">
            <div>
              <label htmlFor="email" className="mb-1 block text-sm font-medium">
                Username or email
              </label>
              <Input
                id="email"
                type="text"
                name="email"
                value={formData.email}
                onChange={handleChange}
                required
              />
            </div>
            <div>
              <label htmlFor="password" className="mb-1 block text-sm font-medium">
                Password
              </label>
              <Input
                id="password"
                type="password"
                name="password"
                value={formData.password}
                onChange={handleChange}
                required
              />
            </div>
            {error && <p className="rounded-md bg-destructive/10 p-2 text-sm text-destructive">{error}</p>}
            <Button type="submit" className="w-full">
              Login
            </Button>
          </form>
          <p className="mt-4 text-center text-sm text-muted-foreground">
            Don&apos;t have an account?{' '}
            <Link to="/register" className="font-medium text-primary hover:underline">
              Register
            </Link>
          </p>
        </CardContent>
      </Card>
    </div>
  );
};

export default Login;
