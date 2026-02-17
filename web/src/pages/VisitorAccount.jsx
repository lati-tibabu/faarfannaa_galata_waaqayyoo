import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { Ghost } from 'lucide-react';
import { Button } from '../components/ui/button';
import { Input } from '../components/ui/input';
import { Card, CardContent, CardHeader, CardTitle } from '../components/ui/card';
import { visitorService } from '../services/api';
import { setVisitor } from '../lib/session';

const VisitorAccount = () => {
  const [username, setUsername] = useState('');
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState('');
  const navigate = useNavigate();

  const handleSubmit = async (event) => {
    event.preventDefault();
    setSaving(true);
    setError('');
    try {
      const response = await visitorService.registerVisitor(username.trim());
      setVisitor(response.data?.visitor);
      navigate('/', { replace: true });
    } catch (err) {
      console.error(err);
      setError(err?.response?.data?.error || 'Failed to create visitor account.');
    } finally {
      setSaving(false);
    }
  };

  return (
    <div className="mx-auto w-full max-w-xl px-4 py-10 sm:px-6 lg:px-8">
      <Card className="border-border/70 bg-card/85 dark:border-white/10 dark:bg-zinc-950/60">
        <CardHeader>
          <CardTitle className="flex items-center gap-2 text-2xl">
            <Ghost className="size-6 text-primary" />
            Visitor Account
          </CardTitle>
          <p className="text-sm text-muted-foreground">
            Create a simple visitor profile using only a username.
          </p>
        </CardHeader>
        <CardContent>
          <form className="space-y-4" onSubmit={handleSubmit}>
            <div>
              <label htmlFor="username" className="mb-1 block text-sm font-medium">Username</label>
              <Input
                id="username"
                value={username}
                onChange={(event) => setUsername(event.target.value)}
                placeholder="guest_singer"
                required
              />
            </div>
            {error && <p className="rounded-md bg-destructive/10 p-2 text-sm text-destructive">{error}</p>}
            <Button type="submit" disabled={saving}>
              {saving ? 'Creating...' : 'Continue as Visitor'}
            </Button>
          </form>
        </CardContent>
      </Card>
    </div>
  );
};

export default VisitorAccount;
