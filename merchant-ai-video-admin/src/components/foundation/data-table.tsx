import type { ReactNode } from "react";

import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";

type Column<T> = {
  key: keyof T | string;
  title: string;
  render?: (item: T) => ReactNode;
};

type DataTableProps<T> = {
  columns: Column<T>[];
  data: T[];
};

export function DataTable<T extends Record<string, unknown>>({
  columns,
  data,
}: DataTableProps<T>) {
  return (
    <div className="overflow-hidden rounded-2xl border bg-card shadow-elevated-sm">
      <Table>
        <TableHeader className="bg-surface-muted">
          <TableRow>
            {columns.map((column) => (
              <TableHead key={String(column.key)}>{column.title}</TableHead>
            ))}
          </TableRow>
        </TableHeader>
        <TableBody>
          {data.map((item, index) => (
            <TableRow key={String(item.id ?? index)}>
              {columns.map((column) => (
                <TableCell key={String(column.key)}>
                  {column.render ? column.render(item) : String(item[column.key as keyof T] ?? "-")}
                </TableCell>
              ))}
            </TableRow>
          ))}
        </TableBody>
      </Table>
    </div>
  );
}
