import { describe, expect, it } from 'vitest';
import { baseOptions } from '@/lib/layout.shared';

describe('baseOptions', () => {
  it('provides the Honeybucket GitHub repo link', () => {
    const options = baseOptions();

    expect(options.githubUrl).toBe('https://github.com/clay-curry/honeybucket');
  });

  it('keeps the docs navigation title stable', () => {
    const options = baseOptions();

    expect(options.nav?.title).toBe('Honeybucket Docs');
  });
});
