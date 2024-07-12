import { Box, Divider } from "@chakra-ui/react";
import Header from "../components/course-selection/CoursePageHeader";
import AllCoursesSection from "../components/course-selection/student-courses/StudentCoursesSection";
import SelectedCoursesSection from "../components/course-selection/selected-courses/SelectedCoursesSection";

const CourseSelectionPage = () => {
  return (
    <Box height="100%" padding="40px 80px">
      <Header />
      <AllCoursesSection />
      <Divider my="20px" />
      <SelectedCoursesSection />
    </Box>
  );
};

export default CourseSelectionPage;
