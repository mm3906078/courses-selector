import { useState } from "react";
import AllCoursesHeader from "./Header";
import AllCoursesList from "./List";
import { Button } from "@chakra-ui/react";
import { useTranslation } from "react-i18next";

const CoursesSection = () => {
  const { t } = useTranslation();
  const [queryParams, setQueryParams] = useState<{
    name?: string;
    professor?: string;
  } | null>(null);

  const setQueryParamsHandler = (values: {
    name?: string;
    professor?: string;
  }) => {
    setQueryParams(values);
  };

  return (
    <section style={{ marginTop: "20px" }}>
      <AllCoursesHeader onSubmitForm={setQueryParamsHandler} />
      {(queryParams?.name || queryParams?.professor) && (
        <Button
          mt="10px"
          onClick={() => {
            setQueryParams(null);
          }}
        >
          {t("clearParams")}
        </Button>
      )}
      <AllCoursesList params={queryParams} />
    </section>
  );
};

export default CoursesSection;
