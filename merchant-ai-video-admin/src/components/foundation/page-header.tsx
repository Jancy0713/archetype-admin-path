import type { PropsWithChildren, ReactNode } from "react";

type PageHeaderProps = PropsWithChildren<{
  title: string;
  description: string;
  actions?: ReactNode;
}>;

export function PageHeader({ title, description, actions, children }: PageHeaderProps) {
  return (
    <header className="flex flex-col gap-4 rounded-2xl border bg-card p-6 shadow-elevated-sm">
      <div className="flex flex-col gap-4 lg:flex-row lg:items-start lg:justify-between">
        <div className="space-y-2">
          <p className="text-sm font-medium text-primary">工程初始化基座</p>
          <div className="space-y-1">
            <h1 className="text-[var(--text-xl)] leading-[var(--text-xl-line-height)] font-semibold text-foreground">
              {title}
            </h1>
            <p className="max-w-3xl text-sm text-muted-foreground">{description}</p>
          </div>
        </div>
        {actions ? <div className="flex flex-wrap gap-3">{actions}</div> : null}
      </div>
      {children}
    </header>
  );
}
