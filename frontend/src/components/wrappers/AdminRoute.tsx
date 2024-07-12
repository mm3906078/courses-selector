import { PropsWithChildren } from "react";
import { Navigate } from "react-router-dom";

const AdminRoute = (props: PropsWithChildren) => {
  if (localStorage.getItem("role") !== "admin") {
    return <Navigate to="/login" replace />;
  }
  return <>{props.children}</>;
};

export default AdminRoute;
