import { Box } from "@chakra-ui/react";
import Header from "../components/course-selection/CoursePageHeader";
import AdminCoursesSection from "../components/course-selection/admin/AdminCoursesSection";

const AdminPanelPage = () => {
  return (
    <Box height="100%" padding="40px 80px">
      <Header />
      <AdminCoursesSection />
    </Box>
  );
};

export default AdminPanelPage;
