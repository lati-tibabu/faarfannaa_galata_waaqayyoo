import { useEffect, useState } from 'react';
import { MessageSquareMore } from 'lucide-react';
import { Button } from '../components/ui/button';
import { Card, CardContent, CardHeader, CardTitle } from '../components/ui/card';
import { feedbackService } from '../services/api';

const AdminFeedback = () => {
  const [items, setItems] = useState([]);
  const [loading, setLoading] = useState(true);
  const [status, setStatus] = useState('new');
  const [error, setError] = useState('');
  const [reviewingId, setReviewingId] = useState(null);

  useEffect(() => {
    const fetchFeedback = async () => {
      setLoading(true);
      setError('');
      try {
        const response = await feedbackService.getAllFeedback(status);
        setItems(Array.isArray(response.data) ? response.data : []);
      } catch (err) {
        console.error(err);
        setError(err?.response?.data?.error || 'Failed to load feedback.');
      } finally {
        setLoading(false);
      }
    };

    fetchFeedback();
  }, [status]);

  const markReviewed = async (id) => {
    setReviewingId(id);
    setError('');
    try {
      await feedbackService.markFeedbackReviewed(id);
      setItems((previous) => previous.map((item) => (
        item.id === id ? { ...item, status: 'reviewed' } : item
      )));
    } catch (err) {
      console.error(err);
      setError(err?.response?.data?.error || 'Failed to mark feedback as reviewed.');
    } finally {
      setReviewingId(null);
    }
  };

  if (loading) {
    return <div className="mx-auto w-full max-w-6xl px-4 py-10 sm:px-6 lg:px-8">Loading feedback...</div>;
  }

  return (
    <div className="mx-auto w-full max-w-6xl px-4 py-10 sm:px-6 lg:px-8">
      <div className="mb-5 flex flex-wrap items-center justify-between gap-3">
        <h1 className="flex items-center gap-2 text-2xl font-semibold tracking-tight">
          <MessageSquareMore className="size-6" />
          Anonymous Feedback
        </h1>
        <div className="flex items-center gap-2">
          <Button variant={status === 'new' ? 'default' : 'outline'} size="sm" onClick={() => setStatus('new')}>
            New
          </Button>
          <Button variant={status === 'reviewed' ? 'default' : 'outline'} size="sm" onClick={() => setStatus('reviewed')}>
            Reviewed
          </Button>
        </div>
      </div>

      {error && <p className="mb-4 rounded-md bg-destructive/10 p-2 text-sm text-destructive">{error}</p>}

      {items.length === 0 ? (
        <Card className="border-dashed border-border/70">
          <CardContent className="py-10 text-center text-muted-foreground">
            No {status} feedback items found.
          </CardContent>
        </Card>
      ) : (
        <div className="space-y-3">
          {items.map((item) => (
            <Card key={item.id} className="border-border/70 bg-card/85 dark:border-white/10 dark:bg-zinc-950/55">
              <CardHeader className="pb-2">
                <CardTitle className="text-base">
                  #{item.id} {item.category?.toUpperCase()} {item.rating ? `| ${item.rating}/5` : ''}
                </CardTitle>
              </CardHeader>
              <CardContent className="space-y-2">
                <p className="text-sm whitespace-pre-wrap">{item.message}</p>
                <div className="flex flex-wrap items-center justify-between gap-2 text-xs text-muted-foreground">
                  <p>Page: {item.page || 'N/A'}</p>
                  <p>{new Date(item.createdAt).toLocaleString()}</p>
                </div>
                {item.status !== 'reviewed' && (
                  <Button size="sm" variant="outline" onClick={() => markReviewed(item.id)} disabled={reviewingId === item.id}>
                    {reviewingId === item.id ? 'Updating...' : 'Mark Reviewed'}
                  </Button>
                )}
              </CardContent>
            </Card>
          ))}
        </div>
      )}
    </div>
  );
};

export default AdminFeedback;
