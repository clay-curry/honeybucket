import React from 'react';
import '@testing-library/jest-dom/vitest';
import { cleanup } from '@testing-library/react';
import { vi } from 'vitest';
import { afterEach } from 'vitest';

vi.mock('next/link', () => ({
  default: ({ href, children, ...props }: { href: unknown; children: React.ReactNode }) => {
    const resolvedHref = typeof href === 'string' ? href : String(href);
    return React.createElement('a', { href: resolvedHref, ...props }, children);
  },
}));

afterEach(() => {
  cleanup();
});
