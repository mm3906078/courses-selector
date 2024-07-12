import { HStack } from "@chakra-ui/react";
import { useQuery } from "@tanstack/react-query";
import { axiosInstance } from "../../../api/axiosInstance";
import { Course } from "../../../models/models";
import SelectedCourseBox from "./SelectedCourseBox";

const SelectedCoursesList = () => {
  const { data } = useQuery({
    queryKey: ["selected-courses"],
    queryFn: async (): Promise<{ courses: Course[] }> => {
      const { data } = await axiosInstance.get("/user/courses");
      return data;
    },
  });

  return (
    <HStack spacing={10} mt="20px" overflowX="hidden">
      {data?.courses.map((course) => (
        <SelectedCourseBox key={course.course_id} {...course} />
      ))}
    </HStack>
  );
};

export default SelectedCoursesList;
