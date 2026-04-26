import { Refine } from "@refinedev/core";
import routerProvider from "@refinedev/react-router";
import { BrowserRouter } from "react-router";

import { AppProviders } from "@/app/providers";
import { AppRouter } from "@/routes";

function App() {
  return (
    <BrowserRouter>
      <AppProviders>
        <Refine
          routerProvider={routerProvider}
          resources={[
            {
              name: "foundation",
              list: "/",
              meta: {
                label: "工程基座",
              },
            },
            {
              name: "platform-capabilities",
              list: "/platform-capabilities",
              meta: {
                label: "平台能力占位",
              },
            },
          ]}
          options={{
            syncWithLocation: true,
          }}
        >
          <AppRouter />
        </Refine>
      </AppProviders>
    </BrowserRouter>
  );
}

export default App;
