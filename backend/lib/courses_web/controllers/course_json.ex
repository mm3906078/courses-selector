defmodule CoursesWeb.CourseJSON do
  def render("error.json", %{reason: reason}) do
    %{error: reason}
  end

  def render("create.json", %{course: course}) do
    %{course: course}
  end

  def render("remove.json", %{course: course}) do
    %{course: course}
  end

  def render("show.json", %{course: course}) do
    %{course: course}
  end

  def render("index.json", %{courses: courses}) do
    %{courses: courses}
  end
end
