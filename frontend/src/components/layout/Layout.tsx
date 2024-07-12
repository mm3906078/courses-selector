import { Box } from "@chakra-ui/react";
import { Outlet } from "react-router-dom";
import Sidebar from "./Sidebar";

const Layout = () => {
  return (
    <Box height="100vh" width="100%" display="flex">
      <Sidebar />
      <Box as="main" flexGrow="1">
        <Outlet />
      </Box>
    </Box>
  );
};

export default Layout;
