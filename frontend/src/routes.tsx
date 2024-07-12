import { Navigate, createBrowserRouter } from "react-router-dom";
import ErrorPage from "./components/error/ErrorPage.tsx";
import LoginForm from "./components/forms/LoginForm.tsx";
import SignUpForm from "./components/forms/SignUpForm.tsx";
import Layout from "./components/layout/Layout.tsx";
import CourseSelectionPage from "./pages/CourseSelection.tsx";
import RequireAuth from "./components/wrappers/RequireAuth.tsx";
import AdminRoute from "./components/wrappers/AdminRoute.tsx";
import AdminPanelPage from "./pages/AdminPanel.tsx";

const router = createBrowserRouter([
  {
    path: "/",
    element: <Layout />,
    errorElement: <ErrorPage />,
    children: [
      {
        path: "",
        element: <Navigate to="course-selection" />,
      },
      {
        path: "course-selection",
        element: (
          <RequireAuth>
            <CourseSelectionPage />
          </RequireAuth>
        ),
      },
      {
        path: "admin-panel",
        element: (
          <RequireAuth>
            <AdminRoute>
              <AdminPanelPage />
            </AdminRoute>
          </RequireAuth>
        ),
      },
    ],
  },
  { path: "/login", element: <LoginForm /> },
  { path: "/signup", element: <SignUpForm /> },
]);

export default router;
