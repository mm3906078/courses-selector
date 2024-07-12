import AdminCoursesList from "./AdminCoursesList";
import AdminCoursesHeader from "./Header";

const AdminCoursesSection = () => {
  return (
    <section style={{ marginTop: "20px" }}>
      <AdminCoursesHeader />
      <AdminCoursesList />
    </section>
  );
};

export default AdminCoursesSection;
