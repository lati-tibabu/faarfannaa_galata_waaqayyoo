import { useEffect, useState } from 'react';
import { userService } from '../services/api';
import { getUser } from '../lib/session';
import { Card, CardContent, CardHeader, CardTitle } from '../components/ui/card';
import { Input } from '../components/ui/input';
import { Button } from '../components/ui/button';

const UsersList = () => {
  const currentUser = getUser();
  const [users, setUsers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [createError, setCreateError] = useState('');
  const [actionInfo, setActionInfo] = useState('');
  const [creatingUser, setCreatingUser] = useState(false);
  const [deletingUserId, setDeletingUserId] = useState(null);
  const [formData, setFormData] = useState({
    name: '',
    email: '',
    password: '',
    role: 'user',
  });

  useEffect(() => {
    const fetchUsers = async () => {
      try {
        const response = await userService.getAllUsers();
        setUsers(response.data);
      } catch (err) {
        console.error(err);
        setError('Failed to load users');
      } finally {
        setLoading(false);
      }
    };
    fetchUsers();
  }, []);

  const handleFormChange = (event) => {
    const { name, value } = event.target;
    setFormData((previous) => ({ ...previous, [name]: value }));
  };

  const handleCreateUser = async (event) => {
    event.preventDefault();
    setCreateError('');
    setActionInfo('');
    setCreatingUser(true);

    try {
      const response = await userService.createManagedUser({
        name: formData.name.trim(),
        email: formData.email.trim().toLowerCase(),
        password: formData.password,
        role: formData.role,
      });
      setUsers((previous) => [response.data, ...previous]);
      setFormData({ name: '', email: '', password: '', role: 'user' });
      setActionInfo('User created successfully.');
    } catch (err) {
      console.error(err);
      setCreateError(err?.response?.data?.error || 'Failed to create user.');
    } finally {
      setCreatingUser(false);
    }
  };

  const handleDeleteUser = async (userId) => {
    setCreateError('');
    setActionInfo('');
    setDeletingUserId(userId);

    try {
      await userService.deleteUser(userId);
      setUsers((previous) => previous.filter((user) => user.id !== userId));
      setActionInfo('User deleted successfully.');
    } catch (err) {
      console.error(err);
      setCreateError(err?.response?.data?.error || 'Failed to delete user.');
    } finally {
      setDeletingUserId(null);
    }
  };

  if (loading) return <div className="mx-auto w-full max-w-6xl px-4 py-10 sm:px-6 lg:px-8">Loading users...</div>;
  if (error) return <div className="mx-auto w-full max-w-6xl px-4 py-10 text-red-500 sm:px-6 lg:px-8">{error}</div>;

  return (
    <div className="mx-auto w-full max-w-6xl px-4 py-10 sm:px-6 lg:px-8">
      <div className="mb-7">
        <h1 className="text-3xl font-semibold tracking-tight">Users</h1>
        <p className="mt-1 text-sm text-muted-foreground">Admin controls for account management.</p>
      </div>

      <Card className="mb-6 border-border/70 bg-card/90 py-5">
        <CardHeader>
          <CardTitle className="text-lg">Create Account</CardTitle>
        </CardHeader>
        <CardContent>
          <form onSubmit={handleCreateUser} className="grid gap-3 md:grid-cols-2 lg:grid-cols-4">
            <Input
              placeholder="Name"
              name="name"
              value={formData.name}
              onChange={handleFormChange}
              required
            />
            <Input
              placeholder="Email"
              type="email"
              name="email"
              value={formData.email}
              onChange={handleFormChange}
              required
            />
            <Input
              placeholder="Password"
              type="password"
              name="password"
              minLength={6}
              value={formData.password}
              onChange={handleFormChange}
              required
            />
            <select
              name="role"
              value={formData.role}
              onChange={handleFormChange}
              className="h-10 rounded-md border border-input bg-background px-3 text-sm"
            >
              <option value="user">User</option>
              <option value="editor">Editor</option>
              <option value="admin">Admin</option>
            </select>
            <div className="md:col-span-2 lg:col-span-4">
              <Button type="submit" disabled={creatingUser}>
                {creatingUser ? 'Creating...' : 'Create User'}
              </Button>
            </div>
          </form>
          {createError && <p className="mt-3 rounded-md bg-destructive/10 p-2 text-sm text-destructive">{createError}</p>}
          {actionInfo && <p className="mt-3 rounded-md bg-muted p-2 text-sm">{actionInfo}</p>}
        </CardContent>
      </Card>

      {users.length === 0 ? (
        <div className="rounded-xl border border-dashed border-border/80 bg-card/70 p-8 text-center text-muted-foreground">
          No users found.
        </div>
      ) : (
        <div className="grid grid-cols-1 gap-4 md:grid-cols-2 lg:grid-cols-3">
          {users.map(user => (
            <Card key={user.id} className="border-border/70 bg-card/90 py-5">
              <CardHeader className="gap-1">
                <CardTitle className="text-lg">{user.name}</CardTitle>
                <p className="text-sm text-muted-foreground">{user.email}</p>
              </CardHeader>
              <CardContent>
                <div className="flex items-center justify-between gap-3">
                  <span className="inline-flex rounded-full bg-muted px-3 py-1 text-xs font-semibold uppercase tracking-wide text-muted-foreground">
                    {user.role || 'user'}
                  </span>
                  <Button
                    variant="outline"
                    size="sm"
                    disabled={deletingUserId === user.id || currentUser?.id === user.id}
                    onClick={() => handleDeleteUser(user.id)}
                  >
                    {deletingUserId === user.id ? 'Deleting...' : 'Delete'}
                  </Button>
                </div>
              </CardContent>
            </Card>
          ))}
        </div>
      )}
    </div>
  );
};

export default UsersList;
