import { Box, Button, Heading, useDisclosure } from "@chakra-ui/react";
import { useTranslation } from "react-i18next";
import { CiSquarePlus } from "react-icons/ci";
import AddCourseModal from "./AddCourseModal";

const AdminCoursesHeader = () => {
  const { isOpen, onOpen, onClose } = useDisclosure();
  const { t } = useTranslation();
  return (
    <>
      <Box display="flex" justifyContent="space-between" alignItems="center">
        <Heading as="h3" size="md">
          {t("definedCourses")}
        </Heading>
        <Button
          variant="outlined"
          color="blue"
          onClick={onOpen}
          leftIcon={<CiSquarePlus size={20} />}
        >
          {t("defineNewCourse")}
        </Button>
      </Box>
      <AddCourseModal isOpen={isOpen} onClose={onClose} />
    </>
  );
};

export default AdminCoursesHeader;
