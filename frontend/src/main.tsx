import { ChakraProvider, extendTheme } from "@chakra-ui/react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import React from "react";
import ReactDOM from "react-dom/client";
import { RouterProvider } from "react-router-dom";
import "./assets/css/Fontiran.css";
import "./assets/css/Roboto.css";
import router from "./routes.tsx";

import "./i18n";

const queryClient = new QueryClient();

const theme = extendTheme({
  colors: {
    primary: {
      400: "#FB881D",
    },
  },
  fonts: {
    heading: `'IranSans','Roboto', sans-serif`,
    body: `'IranSans','Roboto', sans-serif`,
  },
  // direction,
});

ReactDOM.createRoot(document.getElementById("root")!).render(
  <React.StrictMode>
    <QueryClientProvider client={queryClient}>
      <ChakraProvider theme={theme}>
        {/* <Fonts /> */}
        <RouterProvider router={router} />
      </ChakraProvider>
    </QueryClientProvider>
  </React.StrictMode>
);
