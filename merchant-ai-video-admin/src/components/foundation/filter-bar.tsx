import type { PropsWithChildren } from "react";

export function FilterBar({ children }: PropsWithChildren) {
  return (
    <div className="grid gap-3 rounded-2xl border bg-card p-4 shadow-elevated-sm lg:grid-cols-3">
      {children}
    </div>
  );
}
