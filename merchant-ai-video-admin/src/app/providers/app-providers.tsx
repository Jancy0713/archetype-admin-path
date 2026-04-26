import type { PropsWithChildren } from "react";

import { AuditProvider } from "./audit-provider";
import { NotificationProvider } from "./notification-provider";
import { ThemeProvider } from "./theme-provider";

export function AppProviders({ children }: PropsWithChildren) {
  return (
    <ThemeProvider>
      <NotificationProvider>
        <AuditProvider>{children}</AuditProvider>
      </NotificationProvider>
    </ThemeProvider>
  );
}
