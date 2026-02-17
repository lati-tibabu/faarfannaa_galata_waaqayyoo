import { Link } from 'react-router-dom';
import { Card, CardContent, CardHeader, CardTitle } from './ui/card';
import { Button } from './ui/button';
import { Headphones } from 'lucide-react';

const SongCard = ({ song }) => {
  const sections = Array.isArray(song?.content?.sections) ? song.content.sections : [];
  const lineCount = sections.reduce((total, section) => {
    if (!Array.isArray(section?.lines)) {
      return total;
    }
    return total + section.lines.length;
  }, 0);

  return (
    <Card className="h-full border-border/70 bg-card/90 py-5 shadow-sm transition-all hover:-translate-y-0.5 hover:shadow-lg dark:border-white/10 dark:bg-zinc-950/70">
      <CardHeader className="gap-2">
        <div className="flex items-center justify-between gap-2">
          <CardTitle className="line-clamp-2 text-xl leading-tight">{song.title}</CardTitle>
          {song?.hasMusic && (
            <span className="inline-flex items-center gap-1 rounded-full border border-primary/20 bg-primary/10 px-2.5 py-1 text-[10px] font-semibold uppercase tracking-wide text-primary dark:border-white/10 dark:bg-white/5 dark:text-white/80">
              <Headphones className="size-3" />
              Audio
            </span>
          )}
        </div>
        <p className="text-sm capitalize text-muted-foreground">{song.category || 'Uncategorized'}</p>
      </CardHeader>
      <CardContent className="mt-auto space-y-4">
        <div className="grid grid-cols-2 gap-3 text-sm">
          <div className="rounded-lg bg-muted/50 p-2.5 dark:bg-white/[0.04]">
            <p className="text-xs font-medium uppercase tracking-wide text-muted-foreground">Sections</p>
            <p className="mt-1 font-medium">{sections.length}</p>
          </div>
          <div className="rounded-lg bg-muted/50 p-2.5 dark:bg-white/[0.04]">
            <p className="text-xs font-medium uppercase tracking-wide text-muted-foreground">Lines</p>
            <p className="mt-1 font-medium">{lineCount}</p>
          </div>
        </div>
        <Link to={`/songs/${song.id}`} className="block">
          <Button variant="outline" className="w-full dark:border-white/15 dark:bg-white/[0.03] dark:text-white dark:hover:bg-white/10">
            View Details
          </Button>
        </Link>
      </CardContent>
    </Card>
  );
};

export default SongCard;
