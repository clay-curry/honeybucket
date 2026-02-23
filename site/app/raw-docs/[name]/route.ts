import { readFile } from 'node:fs/promises';
import path from 'node:path';
import { notFound } from 'next/navigation';

const allowedFiles = new Set([
  'month-1-deliverables.csv',
  'project-charter-tracker.csv',
]);

function getFilePath(name: string) {
  return path.resolve(process.cwd(), '..', 'docs', name);
}

export const revalidate = false;

export async function GET(_req: Request, { params }: RouteContext<'/raw-docs/[name]'>) {
  const { name } = await params;
  if (!allowedFiles.has(name)) notFound();

  const data = await readFile(getFilePath(name), 'utf8');
  return new Response(data, {
    headers: {
      'Content-Type': 'text/csv; charset=utf-8',
      'Content-Disposition': `inline; filename="${name}"`,
      'Cache-Control': 'no-store',
    },
  });
}
