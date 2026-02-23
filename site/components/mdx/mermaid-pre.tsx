'use client';

import { useEffect, useId, useMemo, useState } from 'react';
import type React from 'react';

type CodeProps = {
  className?: string;
  children?: React.ReactNode;
};

type MermaidRenderResult = {
  svg: string;
};

let mermaidLoader: Promise<typeof import('mermaid').default> | undefined;

function loadMermaid() {
  if (!mermaidLoader) {
    mermaidLoader = import('mermaid').then((m) => {
      m.default.initialize({
        startOnLoad: false,
        securityLevel: 'strict',
        theme: 'neutral',
      });
      return m.default;
    });
  }

  return mermaidLoader;
}

function MermaidChart({ chart }: { chart: string }) {
  const [svg, setSvg] = useState<string>('');
  const [error, setError] = useState<string>('');
  const id = useId().replace(/:/g, '');
  const diagram = useMemo(() => chart.trim(), [chart]);

  useEffect(() => {
    let cancelled = false;

    loadMermaid()
      .then((mermaid) => mermaid.render(`mermaid-${id}`, diagram))
      .then((result: MermaidRenderResult) => {
        if (!cancelled) setSvg(result.svg);
      })
      .catch((renderErr: unknown) => {
        if (!cancelled) setError(String(renderErr));
      });

    return () => {
      cancelled = true;
    };
  }, [diagram, id]);

  if (error) {
    return (
      <div className="my-6 rounded-lg border border-red-300 p-4">
        <p className="font-medium text-red-700">Mermaid render failed.</p>
        <pre className="mt-2 overflow-x-auto text-xs">{error}</pre>
        <pre className="mt-4 overflow-x-auto text-xs">{diagram}</pre>
      </div>
    );
  }

  if (!svg) {
    return (
      <pre className="my-6 overflow-x-auto rounded-lg border p-4 text-sm">
        <code>{diagram}</code>
      </pre>
    );
  }

  return (
    <div className="my-6 overflow-x-auto rounded-lg border p-4">
      <div dangerouslySetInnerHTML={{ __html: svg }} />
    </div>
  );
}

function isMermaidCode(node: unknown): node is React.ReactElement<CodeProps> {
  return (
    !!node &&
    typeof node === 'object' &&
    'props' in node &&
    !!(node as { props?: CodeProps }).props &&
    typeof (node as { props?: CodeProps }).props?.className === 'string' &&
    (node as { props?: CodeProps }).props?.className?.includes('language-mermaid') === true
  );
}

type PreProps = React.ComponentPropsWithoutRef<'pre'>;

export function MermaidPre(props: PreProps) {
  const child = props.children;
  if (!isMermaidCode(child)) return <pre {...props} />;

  const raw = typeof child.props.children === 'string' ? child.props.children : '';
  return <MermaidChart chart={raw} />;
}
