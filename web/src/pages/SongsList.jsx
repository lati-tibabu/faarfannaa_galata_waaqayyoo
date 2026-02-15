import { useEffect, useState } from 'react';
import { songService } from '../services/api';
import SongCard from '../components/SongCard';

const SongsList = () => {
  const [songs, setSongs] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

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

  if (loading) return <div className="mx-auto w-full max-w-6xl px-4 py-10 sm:px-6 lg:px-8">Loading songs...</div>;
  if (error) return <div className="mx-auto w-full max-w-6xl px-4 py-10 text-red-500 sm:px-6 lg:px-8">{error}</div>;

  return (
    <div className="mx-auto w-full max-w-6xl px-4 py-10 sm:px-6 lg:px-8">
      <div className="mb-7 flex flex-wrap items-end justify-between gap-3">
        <div>
          <h1 className="text-3xl font-semibold tracking-tight">Songs</h1>
          <p className="mt-1 text-sm text-muted-foreground">Browse the worship song collection.</p>
        </div>
        <span className="rounded-full bg-muted px-3 py-1 text-sm font-medium text-muted-foreground">
          {songs.length} total
        </span>
      </div>
      {songs.length === 0 ? (
        <div className="rounded-xl border border-dashed border-border/80 bg-card/70 p-8 text-center text-muted-foreground">
          No songs available yet.
        </div>
      ) : (
        <div className="grid grid-cols-1 gap-4 md:grid-cols-2 lg:grid-cols-3">
          {songs.map(song => (
            <SongCard key={song.id} song={song} />
          ))}
        </div>
      )}
    </div>
  );
};

export default SongsList;
