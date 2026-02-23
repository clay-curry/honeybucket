import defaultMdxComponents from 'fumadocs-ui/mdx';
import type { MDXComponents } from 'mdx/types';
import { MermaidPre } from '@/components/mdx/mermaid-pre';

export function getMDXComponents(components?: MDXComponents): MDXComponents {
  return {
    ...defaultMdxComponents,
    pre: (props) => <MermaidPre {...props} />,
    ...components,
  };
}
