import { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import { BookMarked, Music4, ShieldCheck, Trash2 } from 'lucide-react';
import { Card, CardContent, CardHeader, CardTitle } from '../components/ui/card';
import { Button } from '../components/ui/button';
import { getUser } from '../lib/session';
import { userService } from '../services/api';

const MyLibrary = () => {
  const user = getUser();
  const [loading, setLoading] = useState(true);
  const [items, setItems] = useState([]);
  const [error, setError] = useState('');
  const [removingSongId, setRemovingSongId] = useState(null);

  useEffect(() => {
    const fetchLibrary = async () => {
      try {
        const response = await userService.getMyLibrary();
        setItems(Array.isArray(response.data) ? response.data : []);
      } catch (err) {
        console.error(err);
        setError(err?.response?.data?.error || 'Failed to load your library.');
      } finally {
        setLoading(false);
      }
    };

    fetchLibrary();
  }, []);

  const handleRemove = async (songId) => {
    setRemovingSongId(songId);
    setError('');

    try {
      await userService.removeSongFromMyLibrary(songId);
      setItems((previous) => previous.filter((item) => item.song?.id !== songId));
    } catch (err) {
      console.error(err);
      setError(err?.response?.data?.error || 'Failed to remove song from your library.');
    } finally {
      setRemovingSongId(null);
    }
  };

  if (loading) {
    return <div className="mx-auto w-full max-w-6xl px-4 py-10 sm:px-6 lg:px-8">Loading your library...</div>;
  }

  return (
    <div className="mx-auto w-full max-w-6xl px-4 py-10 sm:px-6 lg:px-8">
      <section className="rounded-3xl border border-border/70 bg-card/80 p-8 shadow-sm sm:p-10">
        <p className="text-xs font-semibold uppercase tracking-[0.22em] text-muted-foreground">Protected Space</p>
        <h1 className="mt-3 text-3xl font-semibold tracking-tight sm:text-4xl">My Library</h1>
        <p className="mt-3 max-w-2xl text-sm text-muted-foreground sm:text-base">
          Your private saved songs list, available only for signed-in users.
        </p>
        <div className="mt-5 inline-flex items-center gap-2 rounded-full bg-primary/10 px-4 py-2 text-sm font-medium text-primary">
          <ShieldCheck className="size-4" />
          Signed in as {user?.name || user?.email || 'member'}
        </div>
      </section>

      <div className="mt-6 flex items-center justify-between rounded-2xl border border-border/70 bg-card/80 px-4 py-3">
        <p className="text-sm text-muted-foreground">
          <BookMarked className="mr-2 inline size-4" />
          {items.length} saved song{items.length === 1 ? '' : 's'}
        </p>
        <Button asChild variant="outline" size="sm">
          <Link to="/songs">Browse Songs</Link>
        </Button>
      </div>

      {error && <p className="mt-4 rounded-md bg-destructive/10 p-2 text-sm text-destructive">{error}</p>}

      {items.length === 0 ? (
        <Card className="mt-5 border-dashed border-border/70 bg-card/70">
          <CardContent className="flex flex-col items-center gap-3 py-12 text-center">
            <Music4 className="size-10 text-muted-foreground/60" />
            <p className="text-sm text-muted-foreground">No songs saved yet. Add from Song Detail to build your library.</p>
          </CardContent>
        </Card>
      ) : (
        <div className="mt-5 grid gap-4 md:grid-cols-2 lg:grid-cols-3">
          {items.map((item) => {
            const song = item.song;
            if (!song) {
              return null;
            }

            const sectionCount = Array.isArray(song?.content?.sections) ? song.content.sections.length : 0;

            return (
              <Card key={song.id} className="border-border/70 bg-card/90">
                <CardHeader className="gap-1">
                  <CardTitle className="text-lg">{song.title}</CardTitle>
                  <p className="text-sm text-muted-foreground">{song.category || 'Uncategorized'}</p>
                </CardHeader>
                <CardContent className="space-y-4">
                  <div className="text-sm text-muted-foreground">
                    <p>#{song.id} | {sectionCount} sections</p>
                    <p className="mt-1 text-xs">Saved: {item.addedAt ? new Date(item.addedAt).toLocaleString() : 'N/A'}</p>
                  </div>
                  <div className="flex gap-2">
                    <Button asChild size="sm" className="flex-1">
                      <Link to={`/songs/${song.id}`}>Open</Link>
                    </Button>
                    <Button
                      variant="outline"
                      size="sm"
                      onClick={() => handleRemove(song.id)}
                      disabled={removingSongId === song.id}
                    >
                      <Trash2 className="size-4" />
                    </Button>
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

export default MyLibrary;
