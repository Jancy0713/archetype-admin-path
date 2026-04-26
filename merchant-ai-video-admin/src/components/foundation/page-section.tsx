import type { PropsWithChildren, ReactNode } from "react";

type PageSectionProps = PropsWithChildren<{
  title: string;
  description: string;
  aside?: ReactNode;
}>;

export function PageSection({ title, description, aside, children }: PageSectionProps) {
  return (
    <section className="space-y-4">
      <div className="flex flex-col gap-3 lg:flex-row lg:items-end lg:justify-between">
        <div className="space-y-1">
          <h2 className="text-[var(--text-lg)] leading-[var(--text-lg-line-height)] font-semibold text-foreground">
            {title}
          </h2>
          <p className="text-sm text-muted-foreground">{description}</p>
        </div>
        {aside}
      </div>
      {children}
    </section>
  );
}
