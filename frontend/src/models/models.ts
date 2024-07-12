export type UserRole = "STUDENT" | "ADMIN";

export interface User {
  email: string;
  password: string;
  role?: UserRole;
}

export interface Course {
  course_id: string;
  name: string;
  time: string;
  professor: string;
  days: string[];
}
