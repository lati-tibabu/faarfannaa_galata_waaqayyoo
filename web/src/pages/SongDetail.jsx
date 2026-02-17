import { useEffect, useMemo, useRef, useState } from 'react';
import { Link, useNavigate, useParams } from 'react-router-dom';
import { BookMarked, Image, Music2, Upload } from 'lucide-react';
import { parseBlob } from 'music-metadata-browser';
import { songService, userService } from '../services/api';
import { getUser } from '../lib/session';
import { Button } from '../components/ui/button';
import { Input } from '../components/ui/input';
import { Card, CardContent, CardHeader, CardTitle } from '../components/ui/card';

const SECTION_TYPE_OPTIONS = ['VRS', 'CHRS', 'INTR', 'BRDG', 'PRE', 'OUTR', 'TAG'];

const normalizeSectionType = (type = '') => {
  const normalized = String(type).trim().toUpperCase();
  return normalized || 'VRS';
};

const sectionsToEditableSections = (sections = []) => {
  const mappedSections = sections
    .map((section) => ({
      type: normalizeSectionType(section?.type),
      linesText: Array.isArray(section?.lines) ? section.lines.join('\n') : '',
    }))
    .filter((section) => section.type || section.linesText.trim());

  if (mappedSections.length > 0) {
    return mappedSections;
  }

  return [{ type: 'VRS', linesText: '' }];
};

const editableSectionsToPayload = (sections = []) => sections
  .map((section) => {
    const lines = String(section?.linesText || '')
      .split('\n')
      .map((line) => line.trim())
      .filter(Boolean);

    if (lines.length === 0) {
      return null;
    }

    return {
      type: normalizeSectionType(section?.type),
      lines,
    };
  })
  .filter(Boolean);

const getSectionEditCardClassName = (type = '') => {
  const normalizedType = normalizeSectionType(type);

  if (normalizedType === 'CHRS') {
    return 'rounded-xl border border-border/70 border-dashed bg-muted/40 p-3';
  }

  if (normalizedType === 'INTR') {
    return 'rounded-xl border border-border/70 bg-card/80 p-3';
  }

  if (normalizedType === 'BRDG') {
    return 'rounded-xl border-2 border-border/70 bg-background p-3';
  }

  if (normalizedType === 'OUTR' || normalizedType === 'TAG') {
    return 'rounded-xl border border-border/70 bg-muted/20 p-3';
  }

  return 'rounded-xl border border-border/70 bg-background p-3';
};

const getMusicFiles = (song) => {
  if (!song?.hasMusic) {
    return [];
  }

  if (Array.isArray(song.musicFiles) && song.musicFiles.length > 0) {
    return song.musicFiles;
  }

  if (song.musicFileName) {
    return [{ fileName: song.musicFileName, originalName: 'Original Track' }];
  }

  return [];
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
  const [uploadingMusic, setUploadingMusic] = useState(false);
  const [musicFile, setMusicFile] = useState(null);
  const [deleting, setDeleting] = useState(false);
  const [actionError, setActionError] = useState('');
  const [actionInfo, setActionInfo] = useState('');
  const [activeTrackName, setActiveTrackName] = useState('');
  const [artworkUrl, setArtworkUrl] = useState('');
  const [artworkLoading, setArtworkLoading] = useState(false);
  const [inLibrary, setInLibrary] = useState(false);
  const [checkingLibrary, setCheckingLibrary] = useState(false);
  const [updatingLibrary, setUpdatingLibrary] = useState(false);

  const artworkObjectUrlRef = useRef('');

  const [editForm, setEditForm] = useState({
    title: '',
    category: '',
    sections: [{ type: 'VRS', linesText: '' }],
    changeNotes: '',
  });

  const sections = Array.isArray(song?.content?.sections) ? song.content.sections : [];
  const musicFiles = useMemo(() => getMusicFiles(song), [song]);
  const activeTrack = useMemo(
    () => musicFiles.find((file) => file.fileName === activeTrackName) || musicFiles[0] || null,
    [activeTrackName, musicFiles],
  );

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
          sections: sectionsToEditableSections(songSections),
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

  useEffect(() => {
    const fetchLibraryStatus = async () => {
      if (!user) {
        setInLibrary(false);
        return;
      }

      setCheckingLibrary(true);
      try {
        const response = await userService.getMyLibrarySongStatus(id);
        setInLibrary(Boolean(response.data?.inLibrary));
      } catch (err) {
        console.error(err);
      } finally {
        setCheckingLibrary(false);
      }
    };

    fetchLibraryStatus();
  }, [id, user]);

  useEffect(() => {
    if (!activeTrackName && musicFiles.length > 0) {
      setActiveTrackName(musicFiles[0].fileName);
    }

    if (musicFiles.length === 0) {
      setActiveTrackName('');
    }
  }, [activeTrackName, musicFiles]);

  useEffect(() => {
    let cancelled = false;

    const clearPreviousArtwork = () => {
      if (artworkObjectUrlRef.current) {
        URL.revokeObjectURL(artworkObjectUrlRef.current);
        artworkObjectUrlRef.current = '';
      }
    };

    const extractArtwork = async () => {
      if (!activeTrack?.fileName) {
        clearPreviousArtwork();
        setArtworkUrl('');
        setArtworkLoading(false);
        return;
      }

      setArtworkLoading(true);
      try {
        const response = await fetch(songService.getMusicUrl(id, activeTrack.fileName));
        if (!response.ok) {
          throw new Error('Track fetch failed');
        }

        const blob = await response.blob();
        const metadata = await parseBlob(blob, { skipCovers: false });
        const picture = metadata.common.picture?.[0];

        if (!picture?.data) {
          clearPreviousArtwork();
          if (!cancelled) {
            setArtworkUrl('');
          }
          return;
        }

        const imageBlob = new Blob([picture.data], { type: picture.format || 'image/jpeg' });
        const nextObjectUrl = URL.createObjectURL(imageBlob);

        clearPreviousArtwork();
        artworkObjectUrlRef.current = nextObjectUrl;

        if (!cancelled) {
          setArtworkUrl(nextObjectUrl);
        }
      } catch {
        clearPreviousArtwork();
        if (!cancelled) {
          setArtworkUrl('');
        }
      } finally {
        if (!cancelled) {
          setArtworkLoading(false);
        }
      }
    };

    extractArtwork();

    return () => {
      cancelled = true;
    };
  }, [activeTrack, id]);

  useEffect(() => () => {
    if (artworkObjectUrlRef.current) {
      URL.revokeObjectURL(artworkObjectUrlRef.current);
      artworkObjectUrlRef.current = '';
    }
  }, []);

  const handleEditChange = (event) => {
    const { name, value } = event.target;
    setEditForm((previous) => ({ ...previous, [name]: value }));
  };

  const handleSectionTypeChange = (index, value) => {
    setEditForm((previous) => ({
      ...previous,
      sections: previous.sections.map((section, sectionIndex) => (
        sectionIndex === index
          ? { ...section, type: normalizeSectionType(value) }
          : section
      )),
    }));
  };

  const handleSectionLinesChange = (index, value) => {
    setEditForm((previous) => ({
      ...previous,
      sections: previous.sections.map((section, sectionIndex) => (
        sectionIndex === index
          ? { ...section, linesText: value }
          : section
      )),
    }));
  };

  const handleAddSection = () => {
    setEditForm((previous) => ({
      ...previous,
      sections: [...previous.sections, { type: 'VRS', linesText: '' }],
    }));
  };

  const handleRemoveSection = (index) => {
    setEditForm((previous) => {
      if (previous.sections.length <= 1) {
        return {
          ...previous,
          sections: [{ type: 'VRS', linesText: '' }],
        };
      }

      return {
        ...previous,
        sections: previous.sections.filter((_, sectionIndex) => sectionIndex !== index),
      };
    });
  };

  const handleSubmitEdit = async (event) => {
    event.preventDefault();
    setActionError('');
    setActionInfo('');

    const sectionsPayload = editableSectionsToPayload(editForm.sections);
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

  const handleMusicFileChange = (event) => {
    const selected = event.target.files?.[0] || null;
    setMusicFile(selected);
  };

  const handleUploadMusic = async () => {
    setActionError('');
    setActionInfo('');

    if (!musicFile) {
      setActionError('Choose an audio file first.');
      return;
    }

    setUploadingMusic(true);
    try {
      const response = await songService.uploadSongMusic(id, musicFile);
      setSong(response.data.song);
      setActionInfo(response.data.message || 'Music uploaded successfully.');
      setMusicFile(null);
    } catch (err) {
      console.error(err);
      setActionError(err?.response?.data?.error || 'Failed to upload music.');
    } finally {
      setUploadingMusic(false);
    }
  };

  const handleRemoveMusic = async (fileName) => {
    setActionError('');
    setActionInfo('');

    const confirmed = window.confirm('Remove this music track?');
    if (!confirmed) return;

    try {
      const response = await songService.removeSongMusic(id, fileName);
      setSong(response.data.song);
      setActionInfo(response.data.message || 'Music removed successfully.');
    } catch (err) {
      console.error(err);
      setActionError(err?.response?.data?.error || 'Failed to remove music.');
    }
  };

  const handleToggleLibrary = async () => {
    if (!user) {
      navigate('/login');
      return;
    }

    setUpdatingLibrary(true);
    setActionError('');
    setActionInfo('');
    try {
      if (inLibrary) {
        const response = await userService.removeSongFromMyLibrary(id);
        setInLibrary(false);
        setActionInfo(response.data?.message || 'Song removed from My Library.');
      } else {
        const response = await userService.addSongToMyLibrary(id);
        setInLibrary(true);
        setActionInfo(response.data?.message || 'Song added to My Library.');
      }
    } catch (err) {
      console.error(err);
      setActionError(err?.response?.data?.error || 'Failed to update My Library.');
    } finally {
      setUpdatingLibrary(false);
    }
  };

  if (loading) {
    return <div className="mx-auto w-full max-w-6xl px-4 py-10 sm:px-6 lg:px-8">Loading song...</div>;
  }

  if (error) {
    return <div className="mx-auto w-full max-w-6xl px-4 py-10 text-red-500 sm:px-6 lg:px-8">{error}</div>;
  }

  if (!song) {
    return <div className="mx-auto w-full max-w-6xl px-4 py-10 sm:px-6 lg:px-8">Song not found.</div>;
  }

  return (
    <div className="mx-auto w-full max-w-6xl px-4 py-10 sm:px-6 lg:px-8">
      <Card className="border-border/70 bg-card/90">
        <CardHeader className="gap-2 border-b border-border/60 pb-6">
          <p className="text-xs font-semibold uppercase tracking-[0.2em] text-muted-foreground">
            {song.category || 'Uncategorized'}
          </p>
          <CardTitle className="font-display text-3xl tracking-tight sm:text-4xl">{song.title}</CardTitle>
          <p className="text-sm text-muted-foreground">{sections.length} sections | {lineCount} lines</p>
        </CardHeader>

        <CardContent className="space-y-6 pt-6">
          <div className="grid gap-3 rounded-xl bg-muted/40 p-4 text-sm sm:grid-cols-2 md:grid-cols-3">
            <div>
              <p className="text-xs uppercase tracking-wide text-muted-foreground">Song Number</p>
              <p className="mt-1 font-semibold">#{song.id}</p>
            </div>
            <div>
              <p className="text-xs uppercase tracking-wide text-muted-foreground">Version</p>
              <p className="mt-1 font-semibold">{song.version || '1.0'}</p>
            </div>
            <div>
              <p className="text-xs uppercase tracking-wide text-muted-foreground">Published</p>
              <p className="mt-1 font-semibold">
                {song.lastPublishedAt ? new Date(song.lastPublishedAt).toLocaleString() : 'N/A'}
              </p>
            </div>
          </div>

          {musicFiles.length > 0 && (
            <section className="space-y-4 rounded-2xl border border-border/70 bg-card/80 p-4">
              <h2 className="text-lg font-semibold">Music Playback</h2>

              <div className="grid gap-4 lg:grid-cols-[220px_1fr]">
                <div className="overflow-hidden rounded-xl border border-border/70 bg-muted/30">
                  {artworkLoading ? (
                    <div className="flex h-[220px] items-center justify-center text-xs text-muted-foreground">
                      Extracting artwork...
                    </div>
                  ) : artworkUrl ? (
                    <img src={artworkUrl} alt="Track artwork" className="h-[220px] w-full object-cover" />
                  ) : (
                    <div className="flex h-[220px] flex-col items-center justify-center gap-2 text-muted-foreground">
                      <Image className="size-8 opacity-60" />
                      <p className="text-xs">No embedded artwork</p>
                    </div>
                  )}
                </div>

                <div className="space-y-3">
                  {musicFiles.map((file, index) => (
                    <div
                      key={file.fileName}
                      className={`rounded-lg border p-3 ${activeTrack?.fileName === file.fileName ? 'border-primary/50 bg-primary/5' : 'border-border/70 bg-background'}`}
                    >
                      <div className="mb-2 flex items-center justify-between gap-3">
                        <button
                          type="button"
                          className="text-left"
                          onClick={() => setActiveTrackName(file.fileName)}
                        >
                          <p className="text-sm font-medium">{file.originalName || `Track ${index + 1}`}</p>
                          <p className="text-xs text-muted-foreground">
                            Uploaded: {file.uploadedAt ? new Date(file.uploadedAt).toLocaleDateString() : 'N/A'}
                          </p>
                        </button>
                        {(user?.role === 'editor' || user?.role === 'admin') && (
                          <Button
                            variant="ghost"
                            size="sm"
                            className="text-destructive hover:bg-destructive/10 hover:text-destructive"
                            onClick={() => handleRemoveMusic(file.fileName)}
                          >
                            Remove
                          </Button>
                        )}
                      </div>

                      <audio
                        controls
                        className="h-8 w-full"
                        src={songService.getMusicUrl(id, file.fileName)}
                        onPlay={() => setActiveTrackName(file.fileName)}
                      >
                        Your browser does not support the audio element.
                      </audio>
                    </div>
                  ))}
                </div>
              </div>
            </section>
          )}

          {user && (
            <div className="flex flex-wrap items-center gap-3">
              <Button variant="outline" onClick={handleToggleLibrary} disabled={checkingLibrary || updatingLibrary}>
                <BookMarked className="size-4" />
                {checkingLibrary ? 'Checking...' : (inLibrary ? 'Remove From My Library' : 'Save To My Library')}
              </Button>
              <Button asChild variant="ghost">
                <Link to="/my-library">Open My Library</Link>
              </Button>
            </div>
          )}

          {(user?.role === 'editor' || user?.role === 'admin') && (
            <div className="flex flex-wrap items-center gap-3">
              <Button variant="outline" onClick={() => setEditing((previous) => !previous)}>
                {editing ? 'Cancel Edit' : 'Propose Edit'}
              </Button>
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
                <div className="mb-2 flex items-center justify-between gap-2">
                  <label className="block text-sm font-medium">Lyrics Sections</label>
                  <Button type="button" variant="outline" onClick={handleAddSection}>Add Section</Button>
                </div>
                <div className="space-y-3">
                  {editForm.sections.map((section, index) => {
                    const sectionType = normalizeSectionType(section.type);
                    return (
                      <div key={`edit-section-${index}`} className={getSectionEditCardClassName(sectionType)}>
                        <div className="mb-2 flex flex-wrap items-center justify-between gap-2">
                          <div className="flex items-center gap-2">
                            <label htmlFor={`section-type-${index}`} className="text-xs font-medium uppercase tracking-wide text-muted-foreground">
                              Section Type
                            </label>
                            <Input
                              id={`section-type-${index}`}
                              list="section-types"
                              value={sectionType}
                              onChange={(event) => handleSectionTypeChange(index, event.target.value)}
                              className="h-8 w-24 text-sm"
                            />
                          </div>
                          <Button type="button" variant="outline" onClick={() => handleRemoveSection(index)}>
                            Remove
                          </Button>
                        </div>
                        <textarea
                          value={section.linesText}
                          onChange={(event) => handleSectionLinesChange(index, event.target.value)}
                          rows={4}
                          className="w-full rounded-md border border-input bg-background px-3 py-2 text-sm"
                          placeholder="Enter lines for this section, one per line"
                        />
                      </div>
                    );
                  })}
                </div>
                <datalist id="section-types">
                  {SECTION_TYPE_OPTIONS.map((sectionType) => (
                    <option key={sectionType} value={sectionType} />
                  ))}
                </datalist>
                <p className="mt-2 text-xs text-muted-foreground">
                  Empty sections are ignored when submitting your proposal.
                </p>
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

          {(user?.role === 'editor' || user?.role === 'admin') && (
            <div className="space-y-3 rounded-xl border border-border/70 bg-card p-4">
              <h2 className="flex items-center gap-2 text-lg font-semibold">
                <Upload className="size-4" />
                Music Upload
              </h2>
              <p className="text-sm text-muted-foreground">
                Upload audio for this song. Embedded artwork from the track will be shown in playback when available.
              </p>
              <Input type="file" accept="audio/*" onChange={handleMusicFileChange} />
              <Button onClick={handleUploadMusic} disabled={uploadingMusic || !musicFile}>
                {uploadingMusic ? 'Uploading...' : 'Upload Music'}
              </Button>
            </div>
          )}

          {actionError && <p className="rounded-md bg-destructive/10 p-2 text-sm text-destructive">{actionError}</p>}
          {actionInfo && <p className="rounded-md bg-muted p-2 text-sm">{actionInfo}</p>}

          <div>
            <h2 className="mb-3 flex items-center gap-2 text-lg font-semibold">
              <Music2 className="size-5" />
              Lyrics
            </h2>
            <div className="rounded-xl border border-border/70 bg-background p-4 text-sm leading-7 whitespace-pre-wrap">
              {lyrics || 'No lyrics available for this song.'}
            </div>
          </div>
        </CardContent>
      </Card>
    </div>
  );
};

export default SongDetail;
