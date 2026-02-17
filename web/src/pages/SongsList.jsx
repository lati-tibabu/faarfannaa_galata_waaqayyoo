import { useEffect, useState, useRef } from 'react';
import { Link } from 'react-router-dom';
import { songService } from '../services/api';
import SongCard from '../components/SongCard';
import { Input } from '../components/ui/input';
import { Button } from '../components/ui/button';
import { Card, CardContent, CardHeader, CardTitle } from '../components/ui/card';
import { 
  Search, 
  LayoutGrid, 
  List, 
  Play, 
  Pause, 
  Music2, 
  Disc,
  ChevronRight,
  ExternalLink
} from 'lucide-react';
import { cn } from '../lib/utils';

const SongsList = () => {
  const [songs, setSongs] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [searchTerm, setSearchTerm] = useState('');
  const [viewMode, setViewMode] = useState('grid');
  const [selectedSongId, setSelectedSongId] = useState(null);
  const [isPlaying, setIsPlaying] = useState(false);
  const [progress, setProgress] = useState(0);
  const audioRef = useRef(null);

  useEffect(() => {
    const fetchSongs = async () => {
      try {
        const response = await songService.getAllSongs();
        setSongs(response.data);
      } catch (err) {
        console.error(err);
        setError('Failed to load songs');
      } finally {
        setLoading(false);
      }
    };
    fetchSongs();
  }, []);

  const handleTimeUpdate = () => {
    if (audioRef.current) {
      const current = audioRef.current.currentTime;
      const duration = audioRef.current.duration;
      setProgress((current / duration) * 100);
    }
  };

  const handleProgressChange = (e) => {
    if (audioRef.current) {
      const newTime = (e.target.value / 100) * audioRef.current.duration;
      audioRef.current.currentTime = newTime;
      setProgress(e.target.value);
    }
  };

  const filteredSongs = songs.filter(song => 
    song.title.toLowerCase().includes(searchTerm.toLowerCase()) ||
    song.category.toLowerCase().includes(searchTerm.toLowerCase()) ||
    String(song.id).includes(searchTerm)
  );

  const selectedSong = songs.find(s => s.id === selectedSongId);

  const togglePlayback = () => {
    if (!audioRef.current) return;
    if (isPlaying) {
      audioRef.current.pause();
    } else {
      audioRef.current.play();
    }
    setIsPlaying(!isPlaying);
  };

  useEffect(() => {
    setIsPlaying(false);
    setProgress(0);
  }, [selectedSongId]);

  if (loading) return <div className="mx-auto w-full max-w-6xl px-4 py-10 sm:px-6 lg:px-8">Loading songs...</div>;
  if (error) return <div className="mx-auto w-full max-w-6xl px-4 py-10 text-red-500 sm:px-6 lg:px-8">{error}</div>;

  return (
    <div className="mx-auto w-full max-w-7xl px-4 py-10 sm:px-6 lg:px-8">
      <div className="mb-8 flex flex-col gap-6 md:flex-row md:items-end md:justify-between">
        <div className="flex-1 space-y-4">
          <div>
            <h1 className="text-3xl font-semibold tracking-tight">Songs</h1>
            <p className="mt-1 text-sm text-muted-foreground">Browse and search the worship song collection.</p>
          </div>
          <div className="relative max-w-md">
            <Search className="absolute left-3 top-1/2 size-4 -translate-y-1/2 text-muted-foreground" />
            <Input 
              placeholder="Search by title, category, or number..." 
              className="pl-10"
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
            />
          </div>
        </div>

        <div className="flex items-center gap-2">
          <div className="flex rounded-lg bg-muted p-1">
            <Button 
              variant={viewMode === 'grid' ? 'secondary' : 'ghost'} 
              size="icon-sm"
              onClick={() => setViewMode('grid')}
            >
              <LayoutGrid className="size-4" />
            </Button>
            <Button 
              variant={viewMode === 'list' ? 'secondary' : 'ghost'} 
              size="icon-sm"
              onClick={() => setViewMode('list')}
            >
              <List className="size-4" />
            </Button>
          </div>
          <span className="rounded-full bg-muted px-3 py-1 text-sm font-medium text-muted-foreground">
            {filteredSongs.length} songs
          </span>
        </div>
      </div>

      {filteredSongs.length === 0 ? (
        <div className="rounded-xl border border-dashed border-border/80 bg-card/70 p-12 text-center">
          <Music2 className="mx-auto mb-3 size-10 text-muted-foreground/50" />
          <p className="text-muted-foreground">No songs found matching your search.</p>
        </div>
      ) : viewMode === 'grid' ? (
        <div className="grid grid-cols-1 gap-4 md:grid-cols-2 lg:grid-cols-3">
          {filteredSongs.map(song => (
            <SongCard key={song.id} song={song} />
          ))}
        </div>
      ) : (
        <div className="flex flex-col gap-6 lg:flex-row">
          {/* List Section */}
          <div className="flex-1 space-y-2">
            {filteredSongs.map(song => (
              <div 
                key={song.id}
                onClick={() => setSelectedSongId(song.id)}
                className={cn(
                  "group flex cursor-pointer items-center justify-between rounded-xl border border-border/50 bg-card/50 p-4 transition-all hover:border-primary/30 hover:bg-card",
                  selectedSongId === song.id && "border-primary/50 bg-card ring-1 ring-primary/20"
                )}
              >
                <div className="flex items-center gap-4">
                  <div className={cn(
                    "flex size-10 items-center justify-center rounded-lg bg-muted text-sm font-bold",
                    selectedSongId === song.id && "bg-primary text-primary-foreground"
                  )}>
                    {song.id}
                  </div>
                  <div>
                    <h3 className="font-semibold leading-none">{song.title}</h3>
                    <p className="mt-1 text-sm text-muted-foreground">{song.category}</p>
                  </div>
                </div>
                <ChevronRight className={cn(
                  "size-5 text-muted-foreground transition-transform",
                  selectedSongId === song.id && "translate-x-1 text-primary"
                )} />
              </div>
            ))}
          </div>

          {/* Details Panel */}
          <div className="lg:sticky lg:top-24 lg:h-fit lg:w-96">
            {selectedSong ? (
              <Card className="overflow-hidden border-border/70 bg-card/90 shadow-xl">
                <CardHeader className="text-center pb-2">
                  <CardTitle className="text-xl tracking-tight">{selectedSong.title}</CardTitle>
                  <p className="text-sm text-muted-foreground">#{selectedSong.id} • {selectedSong.category}</p>
                </CardHeader>
                <CardContent className="space-y-6">
                  {/* Spinning Disk Section */}
                  <div className="relative flex flex-col items-center justify-center pt-4">
                    <div className={cn(
                      "relative flex size-48 items-center justify-center rounded-full bg-neutral-900 shadow-2xl transition-transform duration-[4000ms] linear",
                      isPlaying ? "animate-spin" : ""
                    )}>
                      {/* Vinyl Grooves */}
                      <div className="absolute inset-2 rounded-full border border-white/5 opacity-50"></div>
                      <div className="absolute inset-6 rounded-full border border-white/5 opacity-50"></div>
                      <div className="absolute inset-10 rounded-full border border-white/5 opacity-50"></div>
                      
                      {/* Center Label */}
                      <div className="z-10 flex size-16 items-center justify-center rounded-full bg-primary p-1 text-primary-foreground shadow-lg">
                        <div className="flex size-full items-center justify-center rounded-full border-2 border-white/20">
                          <Disc className="size-8" />
                        </div>
                      </div>
                      
                      {/* Tone arm visualization (optional, maybe too complex) */}
                    </div>

                    {/* Controls */}
                    <div className="mt-8 w-full space-y-4 px-6">
                      <div className="flex items-center gap-3">
                        <span className="text-[10px] tabular-nums text-muted-foreground w-8">
                          {audioRef.current ? Math.floor(audioRef.current.currentTime / 60) + ":" + String(Math.floor(audioRef.current.currentTime % 60)).padStart(2, '0') : "0:00"}
                        </span>
                        <input 
                          type="range"
                          className="h-1 flex-1 cursor-pointer appearance-none rounded-full bg-muted accent-primary"
                          value={progress}
                          onChange={handleProgressChange}
                          disabled={!selectedSong.hasMusic}
                        />
                        <span className="text-[10px] tabular-nums text-muted-foreground w-8">
                          {audioRef.current && !isNaN(audioRef.current.duration) ? Math.floor(audioRef.current.duration / 60) + ":" + String(Math.floor(audioRef.current.duration % 60)).padStart(2, '0') : "0:00"}
                        </span>
                      </div>
                      <div className="flex items-center justify-center">
                        <Button 
                          variant="secondary" 
                          size="icon-lg" 
                          className="rounded-full shadow-md"
                          onClick={togglePlayback}
                          disabled={!selectedSong.hasMusic}
                        >
                          {isPlaying ? <Pause className="size-6 fill-current" /> : <Play className="size-6 fill-current ml-1" />}
                        </Button>
                      </div>
                    </div>
                  </div>

                  <div className="rounded-xl bg-muted/50 p-4 text-center">
                    <p className="text-xs font-medium uppercase tracking-wider text-muted-foreground">Description</p>
                    <p className="mt-2 text-sm leading-relaxed text-balance">
                      A beautiful worship song in the {selectedSong.category} category. 
                      {selectedSong.content?.sections?.length || 0} sections of worship and praise.
                    </p>
                  </div>

                  {selectedSong.hasMusic && (
                    <audio 
                      ref={audioRef} 
                      src={songService.getMusicUrl(selectedSong.id)}
                      onEnded={() => setIsPlaying(false)}
                      onTimeUpdate={handleTimeUpdate}
                      className="hidden" 
                    />
                  )}

                  {!selectedSong.hasMusic && (
                    <p className="text-center text-xs text-muted-foreground italic">No audio preview available</p>
                  )}

                  <Button asChild className="w-full" variant="outline">
                    <Link to={`/songs/${selectedSong.id}`} className="flex items-center justify-center gap-2">
                      View Full Lyrics <ExternalLink className="size-4" />
                    </Link>
                  </Button>
                </CardContent>
              </Card>
            ) : (
              <div className="flex h-64 flex-col items-center justify-center rounded-2xl border-2 border-dashed border-border/50 bg-muted/20 p-8 text-center text-muted-foreground">
                <Music2 className="mb-4 size-12 opacity-20" />
                <p>Select a song from the list to see details and play music.</p>
              </div>
            )}
          </div>
        </div>
      )}
    </div>
  );
};

export default SongsList;

