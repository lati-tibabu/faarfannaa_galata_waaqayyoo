import { Link } from 'react-router-dom';
import { Button } from '../components/ui/button';
import { getUser } from '../lib/session';

const Home = () => {
  const user = getUser();

  return (
    <div className="mx-auto w-full max-w-6xl px-4 py-12 sm:px-6 lg:px-8">
      <section className="rounded-2xl border border-border/70 bg-card/80 p-8 shadow-sm sm:p-10 md:p-12">
        <p className="text-sm font-semibold uppercase tracking-[0.2em] text-muted-foreground">
          Oromo Worship Music
        </p>
        <h1 className="mt-4 text-3xl font-semibold tracking-tight sm:text-5xl">
          Faarfannaa Galata Waaqayyoo
        </h1>
        <p className="mt-4 max-w-2xl text-base text-muted-foreground sm:text-lg">
          A simple place to discover songs, read lyrics, and keep your favorite worship music in one clean library.
        </p>
        <div className="mt-8 flex flex-wrap gap-3">
          <Button asChild size="lg">
            <Link to="/songs">Browse Songs</Link>
          </Button>
          {!user && (
            <Button asChild variant="outline" size="lg">
              <Link to="/login">Login</Link>
            </Button>
          )}
          {user?.role === 'admin' && !user.first_login && (
            <Button asChild variant="outline" size="lg">
              <Link to="/admin/dashboard">Admin Dashboard</Link>
            </Button>
          )}
        </div>
      </section>
      <div className="mt-6 rounded-xl border border-dashed border-border/80 bg-background/70 p-5 text-sm text-muted-foreground">
        Clean interface, quick navigation, and readable lyrics across desktop and mobile.
      </div>
    </div>
  );
};

export default Home;
