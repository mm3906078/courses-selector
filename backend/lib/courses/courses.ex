defmodule Courses.Courses do
  require EtcdEx

  def create_course(course_id, name, days, time) do
    course = %{
      course_id: course_id,
      name: name,
      days: days,
      time: time
    }

    with {:ok, course_str} <- Jason.encode(course),
         {:ok, _} <- EtcdEx.put(Courses.Etcd, "courses/#{course.course_id}", course_str) do
      {:ok, Map.delete(course, :password)}
    else
      {:error, _} -> {:error, "Failed to create course"}
    end
  end
end
