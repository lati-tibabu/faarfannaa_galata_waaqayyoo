import { Link } from 'react-router-dom';
import { ArrowRight, Disc3, Headphones, ShieldCheck, Sparkles } from 'lucide-react';
import { Button } from '../components/ui/button';
import { getUser } from '../lib/session';

const Home = () => {
  const user = getUser();

  return (
    <div className="mx-auto w-full max-w-6xl px-4 py-10 sm:px-6 lg:px-8">
      <section className="reveal rounded-3xl border border-border/70 bg-card/75 p-7 shadow-sm sm:p-10 md:p-12">
        <div className="inline-flex items-center gap-2 rounded-full bg-primary/10 px-3 py-1 text-xs font-semibold uppercase tracking-[0.18em] text-primary">
          <Sparkles className="size-3.5" />
          Oromo Worship Music
        </div>
        <h1 className="mt-4 max-w-3xl font-display text-4xl leading-tight sm:text-6xl">
          Faarfannaa Galata Waaqayyoo
        </h1>
        <p className="mt-4 max-w-2xl text-base text-muted-foreground sm:text-lg">
          Discover worship songs, stream uploaded music, and read beautifully structured lyrics from one focused library.
        </p>
        <div className="mt-8 flex flex-wrap gap-3">
          <Button asChild size="lg" className="gap-2">
            <Link to="/songs">
              Browse Songs <ArrowRight className="size-4" />
            </Link>
          </Button>
          {!user && (
            <Button asChild variant="outline" size="lg">
              <Link to="/login">Login</Link>
            </Button>
          )}
          {user && (
            <Button asChild variant="outline" size="lg">
              <Link to="/my-library">Open My Library</Link>
            </Button>
          )}
          {user?.role === 'admin' && !user.first_login && (
            <Button asChild variant="outline" size="lg">
              <Link to="/admin/dashboard">Admin Dashboard</Link>
            </Button>
          )}
        </div>
      </section>

      <section className="mt-6 grid gap-4 md:grid-cols-3">
        <article className="reveal rounded-2xl border border-border/70 bg-card/80 p-5 shadow-sm [animation-delay:120ms]">
          <Disc3 className="size-5 text-primary" />
          <h2 className="mt-4 font-semibold">Curated Song Library</h2>
          <p className="mt-2 text-sm text-muted-foreground">
            Fast filtering, better detail pages, and cleaner readability for rehearsals and services.
          </p>
        </article>
        <article className="reveal rounded-2xl border border-border/70 bg-card/80 p-5 shadow-sm [animation-delay:210ms]">
          <Headphones className="size-5 text-primary" />
          <h2 className="mt-4 font-semibold">Playback With Artwork</h2>
          <p className="mt-2 text-sm text-muted-foreground">
            Embedded album art is extracted from uploaded tracks to elevate the listening experience.
          </p>
        </article>
        <article className="reveal rounded-2xl border border-border/70 bg-card/80 p-5 shadow-sm [animation-delay:300ms]">
          <ShieldCheck className="size-5 text-primary" />
          <h2 className="mt-4 font-semibold">Protected User Route</h2>
          <p className="mt-2 text-sm text-muted-foreground">
            Authenticated members get access to private library space via route guarding.
          </p>
        </article>
      </section>
    </div>
  );
};

export default Home;
