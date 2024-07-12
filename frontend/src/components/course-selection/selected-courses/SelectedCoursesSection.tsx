import { Heading } from "@chakra-ui/react";
import { useTranslation } from "react-i18next";
import SelectedCoursesList from "./List";

const SelectedCoursesSection = () => {
  const { t } = useTranslation();
  return (
    <section>
      <Heading as="h3" size="md">
        {t("selectedCourses")}
      </Heading>
      <SelectedCoursesList />
    </section>
  );
};

export default SelectedCoursesSection;
