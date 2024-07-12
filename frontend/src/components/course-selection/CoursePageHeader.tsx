import { Box, Heading, Select, Text } from "@chakra-ui/react";
import { ChangeEvent } from "react";
import { useTranslation } from "react-i18next";

const Header = () => {
  const { t, i18n } = useTranslation();

  const changeLangHandler = (event: ChangeEvent<HTMLSelectElement>) => {
    i18n.changeLanguage(event.target.value);
    document.dir = event.target.value === "fa" ? "rtl" : "ltr";
  };

  return (
    <Box display="flex" justifyContent="space-between" alignItems="center">
      <Heading>{t("courseSelectionSystem")}</Heading>
      <Select
        bg="primary.400"
        width="150px"
        onChange={changeLangHandler}
        dir="ltr"
        color="white"
      >
        <option style={{ color: "black" }} value="fa">
          فارسی
        </option>
        <option style={{ color: "black" }} value="en">
          English
        </option>
      </Select>
    </Box>
  );
};

export default Header;
