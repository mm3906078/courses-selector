import { ChakraProvider, extendTheme } from "@chakra-ui/react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import React, { useState } from "react";
import ReactDOM from "react-dom/client";
import { RouterProvider } from "react-router-dom";
import router from "./routes.tsx";
// import Fonts from "./Fonts.tsx";

import "./i18n";

const queryClient = new QueryClient();
// const [direction, setDirection] = useState("rtl");

const theme = extendTheme({
  colors: {
    primary: {
      400: "#FB881D",
    },
  },
  // fonts: {
  //   heading: `'IranSans', sans-serif`,
  //   body: `'IranSans', sans-serif`,
  // },
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
