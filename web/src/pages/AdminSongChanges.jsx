import { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import { songService } from '../services/api';
import { Button } from '../components/ui/button';
import { Card, CardContent, CardHeader, CardTitle } from '../components/ui/card';

const statusOptions = ['pending', 'approved', 'rejected'];

const AdminSongChanges = () => {
  const [statusFilter, setStatusFilter] = useState('pending');
  const [changes, setChanges] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [processingId, setProcessingId] = useState(null);

  const fetchChanges = async (status) => {
    setLoading(true);
    setError('');
    try {
      const response = await songService.getSongChanges(status);
      setChanges(response.data);
    } catch (err) {
      console.error(err);
      setError(err?.response?.data?.error || 'Failed to load song change requests.');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchChanges(statusFilter);
  }, [statusFilter]);

  const handleReview = async (changeId, action) => {
    setProcessingId(changeId);
    setError('');
    try {
      await songService.reviewSongChange(changeId, { action });
      await fetchChanges(statusFilter);
    } catch (err) {
      console.error(err);
      setError(err?.response?.data?.error || `Failed to ${action} change.`);
    } finally {
      setProcessingId(null);
    }
  };

  if (loading) {
    return <div className="mx-auto w-full max-w-6xl px-4 py-10 sm:px-6 lg:px-8">Loading song changes...</div>;
  }

  return (
    <div className="mx-auto w-full max-w-6xl px-4 py-10 sm:px-6 lg:px-8">
      <div className="mb-6 flex flex-wrap items-center justify-between gap-3">
        <div>
          <h1 className="text-3xl font-semibold tracking-tight">Song Change Reviews</h1>
          <p className="mt-1 text-sm text-muted-foreground">Approve or reject editor changes before publishing.</p>
        </div>
        <div className="flex gap-2">
          {statusOptions.map((status) => (
            <Button
              key={status}
              variant={statusFilter === status ? 'default' : 'outline'}
              onClick={() => setStatusFilter(status)}
              className="capitalize"
            >
              {status}
            </Button>
          ))}
        </div>
      </div>

      {error && <p className="mb-4 rounded-md bg-destructive/10 p-2 text-sm text-destructive">{error}</p>}

      {changes.length === 0 ? (
        <div className="rounded-xl border border-dashed border-border/80 bg-card/70 p-8 text-center text-muted-foreground">
          No {statusFilter} song changes found.
        </div>
      ) : (
        <div className="space-y-4">
          {changes.map((change) => {
            const proposedSections = Array.isArray(change.proposedContent?.sections)
              ? change.proposedContent.sections.length
              : 0;

            return (
              <Card key={change.id} className="border-border/70 bg-card/90">
                <CardHeader className="gap-2">
                  <CardTitle className="text-lg">
                    #{change.song?.id} {change.song?.title || change.proposedTitle}
                  </CardTitle>
                  <p className="text-sm text-muted-foreground">
                    Base version: {change.baseVersion} • Requested by {change.requestedByUser?.name || 'Unknown'}
                  </p>
                </CardHeader>
                <CardContent className="space-y-3 text-sm">
                  <div className="grid gap-3 rounded-lg bg-muted/50 p-3 sm:grid-cols-2">
                    <div>
                      <p className="text-xs uppercase tracking-wide text-muted-foreground">Proposed Title</p>
                      <p className="font-medium">{change.proposedTitle}</p>
                    </div>
                    <div>
                      <p className="text-xs uppercase tracking-wide text-muted-foreground">Proposed Category</p>
                      <p className="font-medium">{change.proposedCategory}</p>
                    </div>
                    <div>
                      <p className="text-xs uppercase tracking-wide text-muted-foreground">Sections</p>
                      <p className="font-medium">{proposedSections}</p>
                    </div>
                    <div>
                      <p className="text-xs uppercase tracking-wide text-muted-foreground">Status</p>
                      <p className="font-medium capitalize">{change.status}</p>
                    </div>
                  </div>
                  {change.changeNotes && (
                    <div>
                      <p className="text-xs uppercase tracking-wide text-muted-foreground">Editor Notes</p>
                      <p>{change.changeNotes}</p>
                    </div>
                  )}
                  {change.reviewNotes && (
                    <div>
                      <p className="text-xs uppercase tracking-wide text-muted-foreground">Review Notes</p>
                      <p>{change.reviewNotes}</p>
                    </div>
                  )}
                  <div className="flex flex-wrap gap-2">
                    <Button asChild variant="outline">
                      <Link to={`/songs/${change.songId}`}>Open Song</Link>
                    </Button>
                    {change.status === 'pending' && (
                      <>
                        <Button
                          onClick={() => handleReview(change.id, 'approve')}
                          disabled={processingId === change.id}
                        >
                          {processingId === change.id ? 'Processing...' : 'Approve'}
                        </Button>
                        <Button
                          variant="destructive"
                          onClick={() => handleReview(change.id, 'reject')}
                          disabled={processingId === change.id}
                        >
                          {processingId === change.id ? 'Processing...' : 'Reject'}
                        </Button>
                      </>
                    )}
                  </div>
                </CardContent>
              </Card>
            );
          })}
        </div>
      )}
    </div>
  );
};

export default AdminSongChanges;
