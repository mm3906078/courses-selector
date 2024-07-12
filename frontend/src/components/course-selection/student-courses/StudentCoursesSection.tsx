import { useState } from "react";
import AllCoursesHeader from "./Header";
import AllCoursesList from "./List";

const CoursesSection = () => {
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
      <AllCoursesList params={queryParams} />
    </section>
  );
};

export default CoursesSection;
