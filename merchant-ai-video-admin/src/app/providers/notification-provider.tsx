import type { PropsWithChildren } from "react";
import { createContext, useContext, useMemo } from "react";
import { toast } from "sonner";

import { Toaster } from "@/components/ui/sonner";

export type NotificationPayload = {
  title: string;
  description?: string;
  tone?: "info" | "success" | "warning" | "error";
};

type NotificationContextValue = {
  notify: (payload: NotificationPayload) => void;
};

const NotificationContext = createContext<NotificationContextValue | null>(null);

function emitNotification({ title, description, tone = "info" }: NotificationPayload) {
  if (tone === "success") {
    toast.success(title, { description });
    return;
  }

  if (tone === "warning") {
    toast.warning(title, { description });
    return;
  }

  if (tone === "error") {
    toast.error(title, { description });
    return;
  }

  toast(title, { description });
}

export function NotificationProvider({ children }: PropsWithChildren) {
  const value = useMemo<NotificationContextValue>(
    () => ({
      notify: emitNotification,
    }),
    []
  );

  return (
    <NotificationContext.Provider value={value}>
      {children}
      <Toaster richColors position="top-right" closeButton />
    </NotificationContext.Provider>
  );
}

export function useNotificationCenter() {
  const context = useContext(NotificationContext);

  if (!context) {
    throw new Error("useNotificationCenter must be used within NotificationProvider.");
  }

  return context;
}
