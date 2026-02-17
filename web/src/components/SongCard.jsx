import { Link } from 'react-router-dom';
import { Card, CardContent, CardHeader, CardTitle } from './ui/card';
import { Button } from './ui/button';

const SongCard = ({ song }) => {
  const sections = Array.isArray(song?.content?.sections) ? song.content.sections : [];
  const lineCount = sections.reduce((total, section) => {
    if (!Array.isArray(section?.lines)) {
      return total;
    }
    return total + section.lines.length;
  }, 0);

  return (
    <Card className="h-full border-border/70 bg-card/90 py-5">
      <CardHeader className="gap-1">
        <CardTitle className="text-lg">{song.title}</CardTitle>
        <p className="text-sm text-muted-foreground">{song.category || 'Uncategorized'}</p>
      </CardHeader>
      <CardContent className="mt-auto space-y-4">
        <div className="grid grid-cols-2 gap-3 text-sm">
          <div>
            <p className="text-xs font-medium uppercase tracking-wide text-muted-foreground">Sections</p>
            <p className="mt-1 font-medium">{sections.length}</p>
          </div>
          <div>
            <p className="text-xs font-medium uppercase tracking-wide text-muted-foreground">Lines</p>
            <p className="mt-1 font-medium">{lineCount}</p>
          </div>
        </div>
        <Link to={`/songs/${song.id}`} className="block">
          <Button className="w-full">View Details</Button>
        </Link>
      </CardContent>
    </Card>
  );
};

export default SongCard;
