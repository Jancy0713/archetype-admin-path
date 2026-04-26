import { MenuIcon, SearchIcon } from "lucide-react";
import { NavLink, Outlet } from "react-router";

import { zhCN } from "@/shared/copy/zh-cn";
import { cn } from "@/lib/utils";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import {
  Sheet,
  SheetContent,
  SheetHeader,
  SheetTitle,
  SheetTrigger,
} from "@/components/ui/sheet";
import { StatusBadge } from "@/components/foundation";

function NavigationContent() {
  return (
    <div className="flex h-full flex-col gap-6">
      <div className="space-y-2">
        <p className="text-sm font-semibold text-foreground">{zhCN.appName}</p>
        <p className="text-sm text-muted-foreground">{zhCN.shell.subtitle}</p>
      </div>

      <div className="space-y-3">
        <p className="text-xs font-medium uppercase tracking-[0.12em] text-muted-foreground">
          已落地
        </p>
        <div className="space-y-2">
          {zhCN.navigation.active.map((item) => (
            <NavLink
              key={item.label}
              to={item.href ?? "/"}
              end={item.href === "/"}
              className={({ isActive }) =>
                cn(
                  "flex items-center justify-between rounded-xl border px-3 py-2 text-sm transition-colors",
                  isActive
                    ? "border-primary bg-sidebar-accent text-sidebar-accent-foreground"
                    : "border-transparent text-muted-foreground hover:border-border hover:bg-surface"
                )
              }
            >
              <span>{item.label}</span>
              <StatusBadge tone="success">已落地</StatusBadge>
            </NavLink>
          ))}
        </div>
      </div>

      <div className="space-y-3">
        <p className="text-xs font-medium uppercase tracking-[0.12em] text-muted-foreground">
          待后续 PRD
        </p>
        <div className="space-y-2">
          {zhCN.navigation.placeholders.map((item) => (
            <div key={item.label} className="rounded-xl border bg-surface px-3 py-3">
              <div className="flex items-center justify-between gap-3">
                <span className="text-sm font-medium text-foreground">{item.label}</span>
                <StatusBadge tone="warning">占位</StatusBadge>
              </div>
              <p className="mt-2 text-xs text-muted-foreground">{item.note}</p>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}

export function AppShellLayout() {
  return (
    <div className="min-h-screen bg-background">
      <div className="mx-auto grid min-h-screen max-w-[1600px] lg:grid-cols-[280px_minmax(0,1fr)]">
        <aside className="hidden border-r bg-sidebar p-6 lg:block">
          <NavigationContent />
        </aside>

        <div className="flex min-w-0 flex-col">
          <header className="sticky top-0 z-10 border-b bg-background/95 px-4 py-4 backdrop-blur lg:px-8">
            <div className="flex flex-col gap-4 lg:flex-row lg:items-center lg:justify-between">
              <div className="flex items-center gap-3">
                <Sheet>
                  <SheetTrigger asChild>
                    <Button type="button" variant="outline" size="icon" className="lg:hidden">
                      <MenuIcon className="h-4 w-4" />
                    </Button>
                  </SheetTrigger>
                  <SheetContent side="left" className="w-full max-w-xs p-6">
                    <SheetHeader className="sr-only">
                      <SheetTitle>主导航</SheetTitle>
                    </SheetHeader>
                    <NavigationContent />
                  </SheetContent>
                </Sheet>

                <div className="relative min-w-[280px] max-w-xl flex-1">
                  <SearchIcon className="pointer-events-none absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
                  <Input
                    disabled
                    className="pl-10"
                    value="预留给租户内搜索、任务查询与通知入口"
                    readOnly
                  />
                </div>
              </div>

              <div className="flex flex-wrap items-center gap-3">
                <div className="rounded-xl border bg-card px-4 py-2">
                  <p className="text-xs text-muted-foreground">租户上下文</p>
                  <p className="text-sm font-medium text-foreground">默认商家工作区占位</p>
                </div>
                <Button type="button" variant="outline" disabled>
                  通知中心待 PRD
                </Button>
              </div>
            </div>
          </header>

          <main className="flex-1 px-4 py-6 lg:px-8 lg:py-8">
            <Outlet />
          </main>
        </div>
      </div>
    </div>
  );
}
