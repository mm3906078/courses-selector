import { HStack, Text } from "@chakra-ui/react";
import { useQuery } from "@tanstack/react-query";
import { axiosInstance } from "../../../api/axiosInstance";
import { Course } from "../../../models/models";
import StudentCourseBox from "./StudentCourseBox";
import { objectCleaner } from "../../../utils";
import { useTranslation } from "react-i18next";

interface Props {
  params: { name?: string; professor?: string } | null;
}

const AllCoursesList = (props: Props) => {
  const { t } = useTranslation();
  const { data } = useQuery({
    queryKey: ["total-courses", props.params],
    queryFn: async (): Promise<{ courses: Course[] }> => {
      const { data } = await axiosInstance.get("/courses", {
        params: objectCleaner({ ...props.params }) || null,
      });
      return data;
    },
  });

  if (data?.courses.length === 0) {
    return (
      <Text fontSize="2xl" fontWeight="600" mt="20px" textAlign="center">
        {t("noCoursesYet")}!
      </Text>
    );
  }

  return (
    <HStack py="20px" spacing={10} overflowX="hidden">
      {data?.courses.map((course) => (
        <StudentCourseBox key={course.course_id} {...course} />
      ))}
    </HStack>
  );
};

export default AllCoursesList;
