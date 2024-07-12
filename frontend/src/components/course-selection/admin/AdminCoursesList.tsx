import { SimpleGrid, Text } from "@chakra-ui/react";
import { useQuery } from "@tanstack/react-query";
import { axiosInstance } from "../../../api/axiosInstance";
import { Course } from "../../../models/models";
import AdminCourseBox from "./CourseBox";
import { useTranslation } from "react-i18next";

const AdminCoursesList = () => {
  const { t } = useTranslation();
  const { data } = useQuery({
    queryKey: ["total-courses"],
    queryFn: async (): Promise<{ courses: Course[] }> => {
      const { data } = await axiosInstance.get("/courses");
      return data;
    },
  });

  if (data?.courses.length === 0) {
    return (
      <Text fontSize="4xl" fontWeight="600" mt="20px" textAlign="center">
        {t("noCoursesYet")}!
      </Text>
    );
  }

  return (
    <SimpleGrid mt="10px" columns={4} spacing={10}>
      {data?.courses.map((course) => (
        <AdminCourseBox key={course.course_id} {...course} />
      ))}
    </SimpleGrid>
  );
};

export default AdminCoursesList;
