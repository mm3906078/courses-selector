import { Avatar, Box, Button, Text } from "@chakra-ui/react";
import React from "react";
import { useTranslation } from "react-i18next";
import { IoMdExit } from "react-icons/io";
import { useNavigate } from "react-router-dom";

const Sidebar = () => {
  const { t } = useTranslation();
  const navigate = useNavigate();

  return (
    <Box
      width="200px"
      backgroundColor="#F3F4FF"
      display="flex"
      flexDirection="column"
      justifyContent="space-between"
      alignItems="center"
      py="40px"
    >
      <Box display="flex" flexDirection="column" alignItems="center">
        <Avatar name={localStorage.getItem("name") as string} />
        <Text>{localStorage.getItem("name")}</Text>
      </Box>
      <Button
        onClick={() => {
          localStorage.clear();
          navigate("/login");
        }}
        leftIcon={<IoMdExit size={20} />}
        background="transparent"
        width="90%"
      >
        {t("logout")}
      </Button>
    </Box>
  );
};

export default Sidebar;
