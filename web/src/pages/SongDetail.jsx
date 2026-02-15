import { useEffect, useState } from 'react';
import { Link, useNavigate, useParams } from 'react-router-dom';
import { songService } from '../services/api';
import { getUser } from '../lib/session';
import { Button } from '../components/ui/button';
import { Input } from '../components/ui/input';
import { Card, CardContent, CardHeader, CardTitle } from '../components/ui/card';

const sectionsToEditorText = (sections = []) => sections
  .map((section) => {
    const header = section?.type ? `[${section.type}]` : '[VRS]';
    const lines = Array.isArray(section?.lines) ? section.lines.join('\n') : '';
    return `${header}\n${lines}`.trim();
  })
  .join('\n\n')
  .trim();

const parseEditorTextToSections = (text = '') => {
  const blocks = text
    .split(/\n\s*\n/g)
    .map((block) => block.trim())
    .filter(Boolean);

  return blocks
    .map((block) => {
      const lines = block.split('\n').map((line) => line.trim()).filter(Boolean);
      if (lines.length === 0) {
        return null;
      }

      const headerMatch = lines[0].match(/^\[(.+)]$/);
      const type = headerMatch ? headerMatch[1].trim() : 'VRS';
      const bodyLines = headerMatch ? lines.slice(1) : lines;
      if (bodyLines.length === 0) {
        return null;
      }

      return { type, lines: bodyLines };
    })
    .filter(Boolean);
};

const SongDetail = () => {
  const { id } = useParams();
  const navigate = useNavigate();
  const user = getUser();
  const [song, setSong] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [editing, setEditing] = useState(false);
  const [saving, setSaving] = useState(false);
  const [deleting, setDeleting] = useState(false);
  const [actionError, setActionError] = useState('');
  const [actionInfo, setActionInfo] = useState('');
  const [editForm, setEditForm] = useState({
    title: '',
    category: '',
    lyricsText: '',
    changeNotes: '',
  });

  const sections = Array.isArray(song?.content?.sections) ? song.content.sections : [];
  const lineCount = sections.reduce((total, section) => {
    if (!Array.isArray(section?.lines)) {
      return total;
    }
    return total + section.lines.length;
  }, 0);
  const lyrics = sections
    .map((section) => {
      const sectionType = section?.type ? `[${section.type}]` : '';
      const lines = Array.isArray(section?.lines) ? section.lines.join('\n') : '';
      return [sectionType, lines].filter(Boolean).join('\n');
    })
    .filter(Boolean)
    .join('\n\n');

  useEffect(() => {
    const fetchSong = async () => {
      try {
        const response = await songService.getSongById(id);
        setSong(response.data);
        const songSections = Array.isArray(response.data?.content?.sections) ? response.data.content.sections : [];
        setEditForm({
          title: response.data.title || '',
          category: response.data.category || '',
          lyricsText: sectionsToEditorText(songSections),
          changeNotes: '',
        });
      } catch (err) {
        console.error(err);
        setError('Failed to load song');
      } finally {
        setLoading(false);
      }
    };
    fetchSong();
  }, [id]);

  const handleEditChange = (event) => {
    const { name, value } = event.target;
    setEditForm((previous) => ({ ...previous, [name]: value }));
  };

  const handleSubmitEdit = async (event) => {
    event.preventDefault();
    setActionError('');
    setActionInfo('');

    const sectionsPayload = parseEditorTextToSections(editForm.lyricsText);
    if (sectionsPayload.length === 0) {
      setActionError('Lyrics must contain at least one section with lines.');
      return;
    }

    setSaving(true);
    try {
      const response = await songService.submitSongChange(id, {
        title: editForm.title.trim(),
        category: editForm.category.trim(),
        sections: sectionsPayload,
        changeNotes: editForm.changeNotes.trim(),
      });
      setActionInfo(response.data.message || 'Song edit submitted for admin review.');
      setEditing(false);
      setEditForm((previous) => ({ ...previous, changeNotes: '' }));
    } catch (err) {
      console.error(err);
      setActionError(err?.response?.data?.error || 'Failed to submit song edit.');
    } finally {
      setSaving(false);
    }
  };

  const handleDeleteSong = async () => {
    setActionError('');
    setActionInfo('');

    const confirmed = window.confirm(`Delete song #${id}? This cannot be undone.`);
    if (!confirmed) {
      return;
    }

    setDeleting(true);
    try {
      await songService.deleteSong(id);
      navigate('/songs', { replace: true });
    } catch (err) {
      console.error(err);
      setActionError(err?.response?.data?.error || 'Failed to delete song.');
      setDeleting(false);
    }
  };

  if (loading) return <div className="mx-auto w-full max-w-6xl px-4 py-10 sm:px-6 lg:px-8">Loading song...</div>;
  if (error) return <div className="mx-auto w-full max-w-6xl px-4 py-10 text-red-500 sm:px-6 lg:px-8">{error}</div>;
  if (!song) return <div className="mx-auto w-full max-w-6xl px-4 py-10 sm:px-6 lg:px-8">Song not found.</div>;

  return (
    <div className="mx-auto w-full max-w-6xl px-4 py-10 sm:px-6 lg:px-8">
      <Card className="border-border/70 bg-card/90">
        <CardHeader className="gap-2">
          <p className="text-xs font-semibold uppercase tracking-[0.2em] text-muted-foreground">
            {song.category || 'Uncategorized'}
          </p>
          <CardTitle className="text-2xl tracking-tight sm:text-3xl">{song.title}</CardTitle>
          <p className="text-base text-muted-foreground">{sections.length} sections � {lineCount} lines</p>
        </CardHeader>
        <CardContent className="space-y-6">
          <div className="grid gap-4 rounded-xl bg-muted/50 p-4 text-sm sm:grid-cols-2">
            <div>
              <p className="text-xs font-medium uppercase tracking-wide text-muted-foreground">Category</p>
              <p className="mt-1 font-medium capitalize">{song.category || 'Uncategorized'}</p>
            </div>
            <div>
              <p className="text-xs font-medium uppercase tracking-wide text-muted-foreground">Song Number</p>
              <p className="mt-1 font-medium">#{song.id}</p>
            </div>
            <div>
              <p className="text-xs font-medium uppercase tracking-wide text-muted-foreground">Current Version</p>
              <p className="mt-1 font-medium">{song.version || '1.0'}</p>
            </div>
            <div>
              <p className="text-xs font-medium uppercase tracking-wide text-muted-foreground">Published</p>
              <p className="mt-1 font-medium">
                {song.lastPublishedAt ? new Date(song.lastPublishedAt).toLocaleString() : 'N/A'}
              </p>
            </div>
          </div>
          {(user?.role === 'editor' || user?.role === 'admin') && (
            <div className="flex flex-wrap items-center gap-3">
              {(user?.role === 'editor' || user?.role === 'admin') && (
                <Button variant="outline" onClick={() => setEditing((previous) => !previous)}>
                  {editing ? 'Cancel Edit' : 'Propose Edit'}
                </Button>
              )}
              {user?.role === 'admin' && (
                <Button asChild variant="outline">
                  <Link to="/admin/song-changes">Review Song Changes</Link>
                </Button>
              )}
              {user?.role === 'admin' && (
                <Button variant="destructive" onClick={handleDeleteSong} disabled={deleting}>
                  {deleting ? 'Deleting...' : 'Delete Song'}
                </Button>
              )}
            </div>
          )}
          {editing && (user?.role === 'editor' || user?.role === 'admin') && (
            <form onSubmit={handleSubmitEdit} className="space-y-4 rounded-xl border border-border/70 bg-card p-4">
              <h2 className="text-lg font-semibold">Submit Edit for Admin Review</h2>
              <div className="grid gap-3 sm:grid-cols-2">
                <div>
                  <label htmlFor="title" className="mb-1 block text-sm font-medium">Title</label>
                  <Input
                    id="title"
                    name="title"
                    value={editForm.title}
                    onChange={handleEditChange}
                    required
                  />
                </div>
                <div>
                  <label htmlFor="category" className="mb-1 block text-sm font-medium">Category</label>
                  <Input
                    id="category"
                    name="category"
                    value={editForm.category}
                    onChange={handleEditChange}
                    required
                  />
                </div>
              </div>
              <div>
                <label htmlFor="lyricsText" className="mb-1 block text-sm font-medium">Lyrics Sections</label>
                <textarea
                  id="lyricsText"
                  name="lyricsText"
                  value={editForm.lyricsText}
                  onChange={handleEditChange}
                  rows={14}
                  className="w-full rounded-md border border-input bg-background px-3 py-2 text-sm"
                  placeholder="[VRS]\nline 1\nline 2\n\n[CHR]\nline 1"
                  required
                />
              </div>
              <div>
                <label htmlFor="changeNotes" className="mb-1 block text-sm font-medium">Change Notes (optional)</label>
                <textarea
                  id="changeNotes"
                  name="changeNotes"
                  value={editForm.changeNotes}
                  onChange={handleEditChange}
                  rows={3}
                  className="w-full rounded-md border border-input bg-background px-3 py-2 text-sm"
                  placeholder="Explain why this edit is needed."
                />
              </div>
              <Button type="submit" disabled={saving}>
                {saving ? 'Submitting...' : 'Submit for Review'}
              </Button>
            </form>
          )}
          {actionError && <p className="rounded-md bg-destructive/10 p-2 text-sm text-destructive">{actionError}</p>}
          {actionInfo && <p className="rounded-md bg-muted p-2 text-sm">{actionInfo}</p>}
          <div>
            <h2 className="text-lg font-semibold">Lyrics</h2>
            <div className="mt-2 rounded-xl border border-border/70 bg-background p-4 text-sm leading-7 whitespace-pre-wrap">
              {lyrics || 'No lyrics available for this song.'}
            </div>
          </div>
        </CardContent>
      </Card>
    </div>
  );
};

export default SongDetail;
