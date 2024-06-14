defmodule CoursesWeb.UserJSON do
  def render("error.json", %{reason: reason}) do
    %{error: reason}
  end

  def render("courses.json", %{courses: courses}) do
    %{courses: courses}
  end

  def render("enroll.json", %{user: user}) do
    %{user: user}
  end
end
