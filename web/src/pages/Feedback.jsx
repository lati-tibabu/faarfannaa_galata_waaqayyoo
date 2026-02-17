import { useState } from 'react';
import { MessageCircleHeart } from 'lucide-react';
import { Button } from '../components/ui/button';
import { Input } from '../components/ui/input';
import { Card, CardContent, CardHeader, CardTitle } from '../components/ui/card';
import { feedbackService } from '../services/api';

const CATEGORIES = [
  { value: 'general', label: 'General' },
  { value: 'ui', label: 'UI/UX' },
  { value: 'bug', label: 'Bug Report' },
  { value: 'feature', label: 'Feature Request' },
  { value: 'music', label: 'Music Playback' },
  { value: 'lyrics', label: 'Lyrics Content' },
];

const Feedback = () => {
  const [form, setForm] = useState({
    category: 'general',
    rating: '',
    page: '',
    message: '',
  });
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');

  const handleChange = (event) => {
    const { name, value } = event.target;
    setForm((previous) => ({ ...previous, [name]: value }));
  };

  const handleSubmit = async (event) => {
    event.preventDefault();
    setError('');
    setSuccess('');
    setSubmitting(true);

    try {
      const payload = {
        category: form.category,
        rating: form.rating ? Number(form.rating) : null,
        page: form.page.trim() || null,
        message: form.message.trim(),
      };
      const response = await feedbackService.submitAnonymousFeedback(payload);
      setSuccess(response.data?.message || 'Thanks, your feedback was submitted.');
      setForm({
        category: 'general',
        rating: '',
        page: '',
        message: '',
      });
    } catch (err) {
      console.error(err);
      setError(err?.response?.data?.error || 'Failed to submit feedback.');
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <div className="mx-auto w-full max-w-3xl px-4 py-10 sm:px-6 lg:px-8">
      <Card className="border-border/70 bg-card/85 dark:border-white/10 dark:bg-zinc-950/60">
        <CardHeader>
          <CardTitle className="flex items-center gap-2 text-2xl">
            <MessageCircleHeart className="size-6 text-primary" />
            Anonymous Feedback
          </CardTitle>
          <p className="text-sm text-muted-foreground">
            Share your thoughts without logging in. No name or email is required.
          </p>
        </CardHeader>
        <CardContent>
          <form onSubmit={handleSubmit} className="space-y-4">
            <div className="grid gap-3 sm:grid-cols-3">
              <div>
                <label htmlFor="category" className="mb-1 block text-sm font-medium">Category</label>
                <select
                  id="category"
                  name="category"
                  value={form.category}
                  onChange={handleChange}
                  className="h-9 w-full rounded-md border border-input bg-background px-3 text-sm"
                >
                  {CATEGORIES.map((item) => (
                    <option key={item.value} value={item.value}>
                      {item.label}
                    </option>
                  ))}
                </select>
              </div>
              <div>
                <label htmlFor="rating" className="mb-1 block text-sm font-medium">Rating (optional)</label>
                <Input
                  id="rating"
                  name="rating"
                  type="number"
                  min="1"
                  max="5"
                  placeholder="1-5"
                  value={form.rating}
                  onChange={handleChange}
                />
              </div>
              <div>
                <label htmlFor="page" className="mb-1 block text-sm font-medium">Page (optional)</label>
                <Input
                  id="page"
                  name="page"
                  placeholder="/songs/12"
                  value={form.page}
                  onChange={handleChange}
                />
              </div>
            </div>

            <div>
              <label htmlFor="message" className="mb-1 block text-sm font-medium">Feedback</label>
              <textarea
                id="message"
                name="message"
                value={form.message}
                onChange={handleChange}
                rows={6}
                className="w-full rounded-md border border-input bg-background px-3 py-2 text-sm"
                placeholder="What should we improve?"
                required
              />
            </div>

            {error && <p className="rounded-md bg-destructive/10 p-2 text-sm text-destructive">{error}</p>}
            {success && <p className="rounded-md bg-primary/10 p-2 text-sm text-primary">{success}</p>}

            <Button type="submit" disabled={submitting}>
              {submitting ? 'Submitting...' : 'Submit Feedback'}
            </Button>
          </form>
        </CardContent>
      </Card>
    </div>
  );
};

export default Feedback;
