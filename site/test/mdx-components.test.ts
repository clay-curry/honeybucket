import { describe, expect, it } from 'vitest';
import { Mermaid } from '@/components/mdx/mermaid';
import { getMDXComponents } from '@/mdx-components';

describe('getMDXComponents', () => {
  it('registers Mermaid for MDX content', () => {
    const components = getMDXComponents();

    expect(components.Mermaid).toBe(Mermaid);
  });

  it('lets consumers override Mermaid when needed', () => {
    const CustomMermaid = () => null;
    const components = getMDXComponents({ Mermaid: CustomMermaid });

    expect(components.Mermaid).toBe(CustomMermaid);
  });
});
