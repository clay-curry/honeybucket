import Link from 'next/link';

const contentCards = [
  {
    title: 'Architecture',
    description: 'High-level and low-level design docs that describe how Honeybucket is built and why.',
    href: '/docs/architecture/high-level-design',
  },
  {
    title: 'Operations',
    description:
      'Provisioning, go-live checklists, health checks, and deployment runbooks for day-to-day reliability.',
    href: '/docs/operations/production-gateway-runbook',
  },
  {
    title: 'Planning',
    description:
      'Roadmaps and execution trackers that keep implementation work visible and reviewable.',
    href: '/docs/trackers/month-1-deliverables',
  },
];

const quickLinks = [
  { label: 'Project Charter', href: '/docs/project-charter' },
  { label: 'Technical Runbook', href: '/docs/technical-runbook' },
  { label: 'Workflow Playbooks', href: '/docs/workflow-playbooks' },
  { label: 'Host Provisioning Checklist', href: '/docs/operations/host-provisioning-checklist' },
];

export default function HomePage() {
  return (
    <main className="hb-home-page relative flex-1 overflow-hidden text-zinc-100">
      <div className="hb-home-grid pointer-events-none absolute inset-0" aria-hidden="true" />
      <div className="hb-home-glow pointer-events-none absolute inset-0" aria-hidden="true" />

      <header className="relative overflow-hidden">
        <div className="hb-home-hero-gradient pointer-events-none absolute inset-0" aria-hidden="true" />
        <div
          className="pointer-events-none absolute left-1/2 top-1/2 h-[700px] w-[900px] -translate-x-1/2 -translate-y-1/2 bg-[radial-gradient(circle,_rgba(248,113,113,0.2)_0%,_rgba(251,146,60,0.12)_28%,_transparent_65%)] blur-3xl"
          aria-hidden="true"
        />

        <div className="relative mx-auto max-w-5xl px-6 pb-24 pt-24 text-center sm:pb-32 sm:pt-32">
          <p className="hb-fade-up text-xs uppercase tracking-[0.24em] text-zinc-400">
            Honeybucket Knowledge Base
          </p>
          <h1 className="hb-fade-up hb-delay-1 mt-5 text-5xl font-black leading-tight tracking-tight sm:text-7xl">
            <span className="hb-shimmer inline-block bg-gradient-to-r from-red-400 via-orange-300 to-red-500 bg-clip-text text-transparent">
              honeybucket
            </span>
            <span className="block text-xl text-zinc-200">
              Clay&apos;s{' '}
              <span className="bg-gradient-to-r from-orange-300 via-orange-400 to-amber-300 bg-clip-text font-semibold text-transparent">
                crusted
              </span>{' '}
              AI assistant
            </span>
          </h1>
          <p className="hb-fade-up hb-delay-2 mx-auto mt-7 max-w-3xl text-md leading-relaxed text-zinc-400 sm:text-xl">
            I help             <Link
              href="https://x.com/clay__curry"
              target="_blank"
              rel="noopener noreferrer"
              className="text-zinc-300 underline decoration-zinc-500 underline-offset-4 transition-colors hover:text-zinc-100 hover:decoration-orange-400"
            >
              @clay__curry
            </Link> manage his digital life — emails, calendar, WhatsApp, automation, and exploring what human-AI collaboration can be.
          </p>
          <div className="hb-fade-up hb-delay-3 mt-10 flex flex-wrap items-center justify-center gap-4">
            <Link
              href="/docs/trackers/month-1-deliverables"
              className="inline-flex items-center rounded-full border-2 border-zinc-700/90 bg-zinc-900/40 px-7 py-3 text-base font-semibold text-zinc-200 transition-colors hover:border-zinc-500 hover:text-white"
            >
              Project Trackers
            </Link>
            <Link
              href="/docs"
              className="group inline-flex items-center rounded-full bg-gradient-to-r from-red-600 to-orange-600 px-7 py-3 text-base font-semibold text-white shadow hover:from-red-500 hover:to-orange-500"
            >
              Open Docs
              <span className="ml-2 inline-block transition-transform group-hover:translate-x-1">→</span>
            </Link>
          </div>
        </div>
      </header>

      <section className="relative mx-auto max-w-5xl px-6 py-20 sm:py-24">
        <h2 className="hb-fade-up hb-delay-4 text-4xl font-bold tracking-tight sm:text-5xl">
          <span className="bg-gradient-to-r from-zinc-100 to-zinc-400 bg-clip-text text-transparent">
            What You Can Explore
          </span>
        </h2>
        <div className="mt-10 grid gap-5 md:grid-cols-3">
          {contentCards.map((card, index) => (
            <Link
              key={card.title}
              href={card.href}
              className={`hb-card hb-fade-up rounded-2xl border border-zinc-800/60 bg-zinc-900/50 p-7 backdrop-blur-sm ${
                index === 0 ? 'hb-delay-4' : index === 1 ? 'hb-delay-5' : 'hb-delay-6'
              }`}
            >
              <h3 className="text-2xl font-semibold text-zinc-100">{card.title}</h3>
              <p className="mt-3 leading-relaxed text-zinc-400">{card.description}</p>
            </Link>
          ))}
        </div>
      </section>

      <section className="relative mx-auto max-w-5xl px-6 pb-24">
        <h2 className="hb-fade-up hb-delay-5 text-3xl font-bold tracking-tight text-zinc-100 sm:text-4xl">
          Start From a Useful Entry Point
        </h2>
        <div className="mt-7 flex flex-wrap gap-3">
          {quickLinks.map((link, index) => (
            <Link
              key={link.href}
              href={link.href}
              className={`hb-fade-up rounded-full border border-zinc-700/80 bg-zinc-900/60 px-5 py-2.5 font-medium text-zinc-300 transition-colors hover:border-orange-500/40 hover:text-zinc-100 ${
                index === 0
                  ? 'hb-delay-4'
                  : index === 1
                    ? 'hb-delay-5'
                    : index === 2
                      ? 'hb-delay-6'
                      : 'hb-delay-7'
              }`}
            >
              {link.label}
            </Link>
          ))}
        </div>
      </section>
    </main>
  );
}
