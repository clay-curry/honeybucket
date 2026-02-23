import { render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import HomePage from '@/app/(home)/page';

describe('HomePage', () => {
  it('renders the primary calls to action', () => {
    render(<HomePage />);

    expect(screen.getByRole('heading', { name: /honeybucket/i })).toBeInTheDocument();
    expect(screen.getByRole('link', { name: /open docs/i })).toHaveAttribute('href', '/docs');
    expect(screen.getByRole('link', { name: 'Project Trackers' })).toHaveAttribute(
      'href',
      '/docs/trackers/month-1-deliverables',
    );
  });

  it('keeps the Clay profile link external', () => {
    render(<HomePage />);

    const profileLink = screen.getByRole('link', { name: /@clay__curry/i });

    expect(profileLink).toHaveAttribute('href', 'https://x.com/clay__curry');
    expect(profileLink).toHaveAttribute('target', '_blank');
    expect(profileLink).toHaveAttribute('rel', expect.stringContaining('noopener'));
  });
});
