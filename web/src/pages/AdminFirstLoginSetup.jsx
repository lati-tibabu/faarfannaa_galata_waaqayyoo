import { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { userService } from '../services/api';
import { getToken, getUser, setSession } from '../lib/session';
import { Button } from '../components/ui/button';
import { Input } from '../components/ui/input';
import { Card, CardContent, CardHeader, CardTitle } from '../components/ui/card';

const AdminFirstLoginSetup = () => {
  const navigate = useNavigate();
  const [formData, setFormData] = useState({
    newAdminPassword: '',
    confirmAdminPassword: '',
    editorName: '',
    editorEmail: '',
    editorPassword: '',
  });
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState('');

  useEffect(() => {
    const user = getUser();
    if (!user || user.role !== 'admin') {
      navigate('/login', { replace: true });
      return;
    }

    if (!user.first_login) {
      navigate('/admin/dashboard', { replace: true });
    }
  }, [navigate]);

  const handleChange = (event) => {
    const { name, value } = event.target;
    setFormData((previous) => ({ ...previous, [name]: value }));
  };

  const handleSubmit = async (event) => {
    event.preventDefault();
    setError('');

    if (formData.newAdminPassword !== formData.confirmAdminPassword) {
      setError('Admin password confirmation does not match.');
      return;
    }

    setSaving(true);
    try {
      const response = await userService.completeAdminFirstLogin({
        newAdminPassword: formData.newAdminPassword,
        editorName: formData.editorName.trim(),
        editorEmail: formData.editorEmail.trim().toLowerCase(),
        editorPassword: formData.editorPassword,
      });

      const token = response.data.token || getToken();
      if (!token) {
        throw new Error('Missing updated token after setup.');
      }

      setSession(token, response.data.user);
      navigate('/admin/dashboard', { replace: true });
    } catch (err) {
      console.error(err);
      setError(err?.response?.data?.error || 'Failed to complete admin setup.');
    } finally {
      setSaving(false);
    }
  };

  return (
    <div className="mx-auto flex w-full max-w-6xl justify-center px-4 py-10 sm:px-6 lg:px-8">
      <Card className="w-full max-w-2xl border-border/70 bg-card/95 shadow-sm">
        <CardHeader className="gap-2">
          <CardTitle className="text-2xl tracking-tight">Complete Admin Setup</CardTitle>
          <p className="text-sm text-muted-foreground">
            For first login, update admin password and create one editor account before continuing.
          </p>
        </CardHeader>
        <CardContent>
          <form onSubmit={handleSubmit} className="space-y-6">
            <div className="grid gap-4 sm:grid-cols-2">
              <div className="sm:col-span-2">
                <label htmlFor="newAdminPassword" className="mb-1 block text-sm font-medium">
                  New Admin Password
                </label>
                <Input
                  id="newAdminPassword"
                  type="password"
                  name="newAdminPassword"
                  value={formData.newAdminPassword}
                  onChange={handleChange}
                  minLength={6}
                  required
                />
              </div>
              <div className="sm:col-span-2">
                <label htmlFor="confirmAdminPassword" className="mb-1 block text-sm font-medium">
                  Confirm Admin Password
                </label>
                <Input
                  id="confirmAdminPassword"
                  type="password"
                  name="confirmAdminPassword"
                  value={formData.confirmAdminPassword}
                  onChange={handleChange}
                  minLength={6}
                  required
                />
              </div>
              <div className="sm:col-span-2">
                <p className="text-sm font-semibold tracking-wide">Create Editor Account</p>
              </div>
              <div className="sm:col-span-2">
                <label htmlFor="editorName" className="mb-1 block text-sm font-medium">
                  Editor Name
                </label>
                <Input
                  id="editorName"
                  type="text"
                  name="editorName"
                  value={formData.editorName}
                  onChange={handleChange}
                  required
                />
              </div>
              <div>
                <label htmlFor="editorEmail" className="mb-1 block text-sm font-medium">
                  Editor Email
                </label>
                <Input
                  id="editorEmail"
                  type="email"
                  name="editorEmail"
                  value={formData.editorEmail}
                  onChange={handleChange}
                  required
                />
              </div>
              <div>
                <label htmlFor="editorPassword" className="mb-1 block text-sm font-medium">
                  Editor Password
                </label>
                <Input
                  id="editorPassword"
                  type="password"
                  name="editorPassword"
                  value={formData.editorPassword}
                  onChange={handleChange}
                  minLength={6}
                  required
                />
              </div>
            </div>
            {error && <p className="rounded-md bg-destructive/10 p-2 text-sm text-destructive">{error}</p>}
            <Button type="submit" disabled={saving} className="w-full sm:w-auto">
              {saving ? 'Saving...' : 'Complete Setup'}
            </Button>
          </form>
        </CardContent>
      </Card>
    </div>
  );
};

export default AdminFirstLoginSetup;
