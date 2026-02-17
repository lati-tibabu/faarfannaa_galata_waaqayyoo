import { useEffect, useMemo, useRef, useState } from 'react';
import { Link } from 'react-router-dom';
import {
  ChevronLeft,
  ChevronRight,
  ExternalLink,
  LayoutGrid,
  List,
  Music2,
  Pause,
  Play,
  Search,
} from 'lucide-react';
import { songService } from '../services/api';
import SongCard from '../components/SongCard';
import { Input } from '../components/ui/input';
import { Button } from '../components/ui/button';
import { Card, CardContent, CardHeader, CardTitle } from '../components/ui/card';
import { cn } from '../lib/utils';

const PAGE_SIZE = 12;

const formatSeconds = (seconds) => {
  if (!Number.isFinite(seconds) || seconds < 0) {
    return '0:00';
  }

  const minutes = Math.floor(seconds / 60);
  const remaining = Math.floor(seconds % 60);
  return `${minutes}:${String(remaining).padStart(2, '0')}`;
};

const normalizeTrack = (song) => {
  if (!song?.hasMusic) {
    return null;
  }

  const files = Array.isArray(song.musicFiles) ? song.musicFiles : [];
  if (files.length > 0) {
    return files[0];
  }

  if (song.musicFileName) {
    return { fileName: song.musicFileName, originalName: 'Track 1' };
  }

  return null;
};

const SongsList = () => {
  const [songs, setSongs] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [searchTerm, setSearchTerm] = useState('');
  const [viewMode, setViewMode] = useState('grid');
  const [selectedSongId, setSelectedSongId] = useState(null);
  const [isPlaying, setIsPlaying] = useState(false);
  const [progress, setProgress] = useState(0);
  const [duration, setDuration] = useState(0);
  const [currentPage, setCurrentPage] = useState(1);
  const audioRef = useRef(null);

  useEffect(() => {
    const fetchSongs = async () => {
      try {
        const response = await songService.getAllSongs();
        setSongs(Array.isArray(response.data) ? response.data : []);
      } catch (err) {
        console.error(err);
        setError('Failed to load songs');
      } finally {
        setLoading(false);
      }
    };

    fetchSongs();
  }, []);

  const filteredSongs = useMemo(() => {
    const normalizedTerm = searchTerm.trim().toLowerCase();
    if (!normalizedTerm) {
      return songs;
    }

    return songs.filter((song) => {
      const title = String(song?.title || '').toLowerCase();
      const category = String(song?.category || '').toLowerCase();
      const id = String(song?.id || '');

      return title.includes(normalizedTerm)
        || category.includes(normalizedTerm)
        || id.includes(normalizedTerm);
    });
  }, [songs, searchTerm]);

  const totalPages = Math.max(1, Math.ceil(filteredSongs.length / PAGE_SIZE));

  useEffect(() => {
    setCurrentPage(1);
  }, [searchTerm, viewMode]);

  useEffect(() => {
    setCurrentPage((previous) => Math.min(previous, totalPages));
  }, [totalPages]);

  const pagedSongs = useMemo(() => {
    const startIndex = (currentPage - 1) * PAGE_SIZE;
    return filteredSongs.slice(startIndex, startIndex + PAGE_SIZE);
  }, [currentPage, filteredSongs]);

  useEffect(() => {
    if (viewMode !== 'list') {
      return;
    }

    if (pagedSongs.length === 0) {
      setSelectedSongId(null);
      return;
    }

    const isVisible = pagedSongs.some((song) => song.id === selectedSongId);
    if (!isVisible) {
      setSelectedSongId(pagedSongs[0].id);
    }
  }, [viewMode, pagedSongs, selectedSongId]);

  const selectedSong = useMemo(
    () => pagedSongs.find((song) => song.id === selectedSongId) || null,
    [pagedSongs, selectedSongId],
  );

  const activeTrack = selectedSong ? normalizeTrack(selectedSong) : null;

  useEffect(() => {
    setIsPlaying(false);
    setProgress(0);
    setDuration(0);
  }, [selectedSongId]);

  const handleTimeUpdate = () => {
    if (!audioRef.current) {
      return;
    }

    const nextDuration = Number(audioRef.current.duration) || 0;
    const current = Number(audioRef.current.currentTime) || 0;

    setDuration(nextDuration);

    if (nextDuration > 0) {
      setProgress((current / nextDuration) * 100);
    } else {
      setProgress(0);
    }
  };

  const handleProgressChange = (event) => {
    if (!audioRef.current || !duration) {
      return;
    }

    const nextProgress = Number(event.target.value);
    const newTime = (nextProgress / 100) * duration;
    audioRef.current.currentTime = newTime;
    setProgress(nextProgress);
  };

  const togglePlayback = async () => {
    if (!audioRef.current || !activeTrack) {
      return;
    }

    if (isPlaying) {
      audioRef.current.pause();
      setIsPlaying(false);
      return;
    }

    try {
      await audioRef.current.play();
      setIsPlaying(true);
    } catch {
      setIsPlaying(false);
    }
  };

  const canGoPrevious = currentPage > 1;
  const canGoNext = currentPage < totalPages;

  const pageNumbers = Array.from({ length: totalPages }, (_, index) => index + 1)
    .filter((page) => Math.abs(page - currentPage) <= 2);

  if (loading) {
    return <div className="mx-auto w-full max-w-6xl px-4 py-10 sm:px-6 lg:px-8">Loading songs...</div>;
  }

  if (error) {
    return <div className="mx-auto w-full max-w-6xl px-4 py-10 text-red-500 sm:px-6 lg:px-8">{error}</div>;
  }

  return (
    <div className={cn(
      'mx-auto w-full max-w-7xl px-4 py-10 sm:px-6 lg:px-8',
      viewMode === 'list' && selectedSong && 'pb-40 lg:pb-10',
    )}>
      <div className="mb-7 flex flex-col gap-5 rounded-3xl border border-border/70 bg-card/70 p-5 shadow-sm sm:p-6 md:flex-row md:items-end md:justify-between dark:border-white/10 dark:bg-zinc-950/55">
        <div className="flex-1 space-y-4">
          <div>
            <h1 className="font-display text-3xl font-semibold tracking-tight">Songs</h1>
            <p className="mt-1 text-sm text-muted-foreground">
              Search quickly, browse in pages, and preview uploaded tracks.
            </p>
          </div>
          <div className="relative max-w-xl">
            <Search className="absolute left-3 top-1/2 size-4 -translate-y-1/2 text-muted-foreground" />
            <Input
              placeholder="Search by title, category, or song number..."
              className="h-11 rounded-xl border-border/70 bg-background/60 pl-10 dark:border-white/10 dark:bg-white/[0.03]"
              value={searchTerm}
              onChange={(event) => setSearchTerm(event.target.value)}
            />
          </div>
        </div>

        <div className="flex w-full items-center gap-2 self-start md:w-auto md:self-auto">
          <div className="flex rounded-xl border border-border/70 bg-muted/80 p-1 dark:border-white/10 dark:bg-white/[0.05]">
            <Button
              variant={viewMode === 'grid' ? 'default' : 'ghost'}
              size="icon"
              className={cn(
                'size-9 rounded-lg',
                viewMode === 'grid'
                  ? 'shadow-sm dark:bg-white dark:text-black'
                  : 'text-muted-foreground dark:text-white/70 dark:hover:bg-white/10 dark:hover:text-white',
              )}
              onClick={() => setViewMode('grid')}
            >
              <LayoutGrid className="size-4" />
            </Button>
            <Button
              variant={viewMode === 'list' ? 'default' : 'ghost'}
              size="icon"
              className={cn(
                'size-9 rounded-lg',
                viewMode === 'list'
                  ? 'shadow-sm dark:bg-white dark:text-black'
                  : 'text-muted-foreground dark:text-white/70 dark:hover:bg-white/10 dark:hover:text-white',
              )}
              onClick={() => setViewMode('list')}
            >
              <List className="size-4" />
            </Button>
          </div>
          <span className="inline-flex h-9 items-center rounded-full border border-border/70 bg-muted/70 px-3 text-sm font-semibold text-muted-foreground dark:border-white/10 dark:bg-white/[0.06] dark:text-white/85">
            {filteredSongs.length} songs
          </span>
        </div>
      </div>

      {filteredSongs.length === 0 ? (
        <div className="rounded-xl border border-dashed border-border/80 bg-card/60 p-12 text-center">
          <Music2 className="mx-auto mb-3 size-10 text-muted-foreground/50" />
          <p className="text-muted-foreground">No songs found matching your search.</p>
        </div>
      ) : viewMode === 'grid' ? (
        <div className="grid grid-cols-1 gap-4 md:grid-cols-2 lg:grid-cols-3">
          {pagedSongs.map((song) => (
            <SongCard key={song.id} song={song} />
          ))}
        </div>
      ) : (
        <div className="flex flex-col gap-6 lg:flex-row">
          <div className="flex-1 space-y-2">
            {pagedSongs.map((song) => (
              <div
                key={song.id}
                onClick={() => setSelectedSongId(song.id)}
                className={cn(
                  'group flex cursor-pointer items-center justify-between rounded-xl border border-border/60 bg-card/70 p-4 transition-all hover:border-primary/40 hover:bg-card',
                  selectedSongId === song.id && 'border-primary/50 bg-card ring-1 ring-primary/20',
                )}
              >
                <div className="flex items-center gap-4">
                  <div
                    className={cn(
                      'flex size-10 items-center justify-center rounded-lg bg-muted text-sm font-bold text-foreground/85 dark:bg-white/12 dark:text-white/85',
                      selectedSongId === song.id && 'bg-primary text-primary-foreground dark:bg-primary dark:text-primary-foreground',
                    )}
                  >
                    {song.id}
                  </div>
                  <div>
                    <h3 className="font-semibold leading-none">{song.title}</h3>
                    <p className="mt-1 text-sm text-muted-foreground">{song.category || 'Uncategorized'}</p>
                  </div>
                </div>
                <ChevronRight
                  className={cn(
                    'size-5 text-muted-foreground transition-transform',
                    selectedSongId === song.id && 'translate-x-1 text-primary',
                  )}
                />
              </div>
            ))}
          </div>

          <div className="hidden lg:sticky lg:top-24 lg:block lg:h-fit lg:w-96">
            {selectedSong ? (
              <Card className="overflow-hidden border-border/70 bg-card/90 shadow-xl dark:border-white/10 dark:bg-zinc-950/70">
                <CardHeader className="pb-2 text-center">
                  <CardTitle className="text-xl tracking-tight">{selectedSong.title}</CardTitle>
                  <p className="text-sm text-muted-foreground">
                    #{selectedSong.id} | {selectedSong.category || 'Uncategorized'}
                  </p>
                </CardHeader>
                <CardContent className="space-y-5">
                  <div className="rounded-2xl border border-border/70 bg-muted/40 p-4 dark:border-white/12 dark:bg-white/[0.06]">
                    <div className="flex items-center justify-center">
                      <Button
                        variant="secondary"
                        size="icon-lg"
                        className="rounded-full shadow-md dark:border dark:border-white/10 dark:bg-white/12 dark:text-white dark:hover:bg-white/20"
                        onClick={togglePlayback}
                        disabled={!activeTrack}
                      >
                        {isPlaying ? (
                          <Pause className="size-6 fill-current" />
                        ) : (
                          <Play className="ml-1 size-6 fill-current" />
                        )}
                      </Button>
                    </div>
                    <div className="mt-4 flex items-center gap-2">
                      <span className="w-9 text-[10px] tabular-nums text-muted-foreground">
                        {audioRef.current ? formatSeconds(audioRef.current.currentTime) : '0:00'}
                      </span>
                      <input
                        type="range"
                        className="h-1 flex-1 cursor-pointer appearance-none rounded-full bg-muted accent-primary dark:bg-white/20 dark:accent-white"
                        value={progress}
                        onChange={handleProgressChange}
                        disabled={!activeTrack}
                      />
                      <span className="w-9 text-[10px] tabular-nums text-muted-foreground">
                        {formatSeconds(duration)}
                      </span>
                    </div>
                    {!activeTrack && (
                      <p className="mt-3 text-center text-xs text-muted-foreground">No audio preview available</p>
                    )}
                  </div>

                  <Button asChild className="w-full" variant="outline">
                    <Link to={`/songs/${selectedSong.id}`} className="flex items-center justify-center gap-2">
                      View Song Detail <ExternalLink className="size-4" />
                    </Link>
                  </Button>
                </CardContent>
              </Card>
            ) : (
              <div className="flex h-64 flex-col items-center justify-center rounded-2xl border-2 border-dashed border-border/50 bg-muted/20 p-8 text-center text-muted-foreground">
                <Music2 className="mb-4 size-12 opacity-20" />
                <p>Select a song from the list to preview playback.</p>
              </div>
            )}
          </div>
        </div>
      )}

      {viewMode === 'list' && selectedSong && (
        <div className="fixed inset-x-3 bottom-3 z-40 lg:hidden">
          <Card className="overflow-hidden border-border/80 bg-card/95 shadow-2xl backdrop-blur dark:border-white/10 dark:bg-zinc-950/95">
            <CardContent className="space-y-3 p-3">
              <div className="flex items-center justify-between gap-3">
                <div className="min-w-0">
                  <p className="truncate text-sm font-semibold">{selectedSong.title}</p>
                  <p className="text-xs text-muted-foreground">
                    #{selectedSong.id} | {selectedSong.category || 'Uncategorized'}
                  </p>
                </div>
                <div className="flex items-center gap-2">
                  <Button
                    variant="secondary"
                    size="icon-sm"
                    className="rounded-full border border-border/70 bg-secondary text-secondary-foreground shadow-sm hover:bg-secondary/90 dark:border-white/10 dark:bg-white/12 dark:text-white dark:hover:bg-white/20"
                    onClick={togglePlayback}
                    disabled={!activeTrack}
                  >
                    {isPlaying ? <Pause className="size-4 fill-current" /> : <Play className="ml-0.5 size-4 fill-current" />}
                  </Button>
                  <Button asChild variant="outline" size="sm">
                    <Link to={`/songs/${selectedSong.id}`} className="flex items-center gap-1">
                      Open <ExternalLink className="size-3.5" />
                    </Link>
                  </Button>
                </div>
              </div>
              <div className="flex items-center gap-2">
                <span className="w-8 text-[10px] tabular-nums text-muted-foreground">
                  {audioRef.current ? formatSeconds(audioRef.current.currentTime) : '0:00'}
                </span>
                <input
                  type="range"
                  className="h-1.5 flex-1 cursor-pointer appearance-none rounded-full bg-muted accent-primary"
                  value={progress}
                  onChange={handleProgressChange}
                  disabled={!activeTrack}
                />
                <span className="w-8 text-[10px] tabular-nums text-muted-foreground">
                  {formatSeconds(duration)}
                </span>
              </div>
            </CardContent>
          </Card>
        </div>
      )}

      {activeTrack && selectedSong && (
        <audio
          ref={audioRef}
          src={songService.getMusicUrl(selectedSong.id, activeTrack.fileName)}
          onEnded={() => setIsPlaying(false)}
          onLoadedMetadata={handleTimeUpdate}
          onTimeUpdate={handleTimeUpdate}
          className="hidden"
        />
      )}

      {filteredSongs.length > 0 && (
        <div className="mt-8 flex flex-wrap items-center justify-between gap-3 rounded-2xl border border-border/60 bg-card/75 p-3 dark:border-white/10 dark:bg-white/[0.03]">
          <p className="text-sm text-muted-foreground">
            Page {currentPage} of {totalPages}
          </p>
          <div className="flex items-center gap-1 rounded-xl bg-muted/60 p-1 dark:bg-white/[0.04]">
            <Button
              variant="outline"
              size="icon-sm"
              className="dark:border-white/12 dark:bg-transparent dark:text-white/75 dark:hover:bg-white/10 dark:hover:text-white"
              onClick={() => setCurrentPage((previous) => previous - 1)}
              disabled={!canGoPrevious}
              aria-label="Previous page"
            >
              <ChevronLeft className="size-4" />
            </Button>
            {pageNumbers.map((page) => (
              <Button
                key={page}
                variant={page === currentPage ? 'default' : 'ghost'}
                size="sm"
                className={
                  page === currentPage
                    ? 'min-w-9 rounded-lg dark:bg-white dark:text-black dark:hover:bg-white'
                    : 'min-w-9 rounded-lg text-foreground/80 hover:text-foreground dark:text-white/80 dark:hover:bg-white/10 dark:hover:text-white'
                }
                onClick={() => setCurrentPage(page)}
              >
                {page}
              </Button>
            ))}
            <Button
              variant="outline"
              size="icon-sm"
              className="dark:border-white/12 dark:bg-transparent dark:text-white/75 dark:hover:bg-white/10 dark:hover:text-white"
              onClick={() => setCurrentPage((previous) => previous + 1)}
              disabled={!canGoNext}
              aria-label="Next page"
            >
              <ChevronRight className="size-4" />
            </Button>
          </div>
        </div>
      )}
    </div>
  );
};

export default SongsList;
