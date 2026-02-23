import { readFile } from 'node:fs/promises';
import path from 'node:path';
import { parse } from 'csv-parse/sync';

type Row = Record<string, string>;

function docsPath(filename: string) {
  return path.resolve(process.cwd(), '..', 'docs', filename);
}

function getHeaders(rows: Row[]) {
  return rows.length > 0 ? Object.keys(rows[0]) : [];
}

export async function CSVTable({ filename }: { filename: string }) {
  const data = await readFile(docsPath(filename), 'utf8');
  const rows = parse(data, {
    columns: true,
    skip_empty_lines: true,
    trim: true,
  }) as Row[];
  const headers = getHeaders(rows);

  return (
    <div className="space-y-3">
      <p className="text-sm text-fd-muted-foreground">
        {rows.length} rows from <code>{filename}</code>
      </p>
      <div className="overflow-x-auto rounded-lg border">
        <table className="min-w-full text-sm">
          <thead>
            <tr className="bg-fd-muted/40">
              {headers.map((header) => (
                <th
                  key={header}
                  className="px-3 py-2 text-left font-semibold whitespace-nowrap border-b"
                >
                  {header}
                </th>
              ))}
            </tr>
          </thead>
          <tbody>
            {rows.map((row, rowIndex) => (
              <tr key={`${filename}-${rowIndex}`} className="align-top">
                {headers.map((header) => (
                  <td key={`${rowIndex}-${header}`} className="px-3 py-2 border-b whitespace-pre-wrap">
                    {row[header]}
                  </td>
                ))}
              </tr>
            ))}
          </tbody>
        </table>
      </div>
      <a
        href={`/raw-docs/${filename}`}
        className="inline-flex rounded-md border border-fd-border px-3 py-1.5 text-sm"
      >
        Download CSV
      </a>
    </div>
  );
}
