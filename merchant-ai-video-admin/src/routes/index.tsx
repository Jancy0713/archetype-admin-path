import { Route, Routes } from "react-router";

import { AppShellLayout } from "./app-shell-layout";
import { FoundationOverviewPage } from "./foundation-overview-page";
import { NotFoundPage } from "./not-found-page";
import { PlatformCapabilitiesPage } from "./platform-capabilities-page";

export function AppRouter() {
  return (
    <Routes>
      <Route element={<AppShellLayout />}>
        <Route index element={<FoundationOverviewPage />} />
        <Route path="/platform-capabilities" element={<PlatformCapabilitiesPage />} />
        <Route path="*" element={<NotFoundPage />} />
      </Route>
    </Routes>
  );
}
