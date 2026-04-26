import type { PropsWithChildren } from "react";
import { createContext, useContext, useMemo, useState } from "react";

export type AuditEvent = {
  id: string;
  category: string;
  action: string;
  detail: string;
  status: "placeholder" | "triggered";
  timestamp: string;
};

type AuditContextValue = {
  events: AuditEvent[];
  logEvent: (event: Omit<AuditEvent, "id" | "timestamp">) => void;
};

const seedEvents: AuditEvent[] = [
  {
    id: "seed-foundation",
    category: "foundation",
    action: "init.foundation.ready",
    detail: "工程基座、主题 token 和平台能力占位已完成初始化。",
    status: "placeholder",
    timestamp: new Date().toISOString(),
  },
];

const AuditContext = createContext<AuditContextValue | null>(null);

export function AuditProvider({ children }: PropsWithChildren) {
  const [events, setEvents] = useState<AuditEvent[]>(seedEvents);

  const value = useMemo<AuditContextValue>(
    () => ({
      events,
      logEvent: (event) => {
        setEvents((current) => [
          {
            ...event,
            id: crypto.randomUUID(),
            timestamp: new Date().toISOString(),
          },
          ...current,
        ]);
      },
    }),
    [events]
  );

  return <AuditContext.Provider value={value}>{children}</AuditContext.Provider>;
}

export function useAuditLog() {
  const context = useContext(AuditContext);

  if (!context) {
    throw new Error("useAuditLog must be used within AuditProvider.");
  }

  return context;
}
