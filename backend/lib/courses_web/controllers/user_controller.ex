defmodule CoursesWeb.UserController do
  use CoursesWeb, :controller
  use OpenApiSpex.ControllerSpecs

  alias Courses.User
  alias CoursesWeb.AuthController

  alias CoursesWeb.Schemas.{
    FailedResponse,
    UserResponse,
    ListCoursesResponse
  }

  @tag_user "User"

  operation(:enroll,
    summary: "Enroll in a course",
    description: "Enroll in a course",
    tags: [@tag_user],
    parameters: [
      id: [
        in: :path,
        description: "Course ID",
        required: true,
        type: :string,
        example: "123456"
      ]
    ],
    responses: [
      ok: {"Enrolled in course", "application/json", UserResponse}
    ]
  )

  def enroll(conn, %{"id" => id}) do
    conn
    |> AuthController.fetch_current_user(%{"id" => id})
    |> case do
      %{status: 401} = conn ->
        conn

      conn ->
        case User.enroll_user(conn.assigns.current_user, id) do
          {:ok, user} ->
            conn
            |> put_status(:ok)
            |> render("enroll.json", user: user)

          {:error, reason} ->
            conn
            |> put_status(:internal_server_error)
            |> render("error.json", %{reason: reason})
        end
    end
  end

  operation(:unenroll,
    summary: "Unenroll from a course",
    description: "Unenroll from a course",
    tags: [@tag_user],
    parameters: [
      id: [
        in: :path,
        name: "id",
        description: "Course ID",
        required: true,
        type: :string,
        example: "123456"
      ]
    ],
    responses: [
      ok: {"Unenrolled from course", "application/json", User}
    ]
  )

  def unenroll(conn, %{"id" => id}) do
    conn
    |> AuthController.fetch_current_user(%{"id" => id})
    |> case do
      %{status: 401} = conn ->
        conn

      conn ->
        case User.unenroll_user(conn.assigns.current_user, id) do
          {:ok, user} ->
            conn
            |> put_status(:ok)
            |> render("enroll.json", user: user)

          {:error, reason} ->
            conn
            |> put_status(:internal_server_error)
            |> render("error.json", %{reason: reason})
        end
    end
  end

  operation(:courses,
    summary: "List courses",
    description: "List all courses",
    tags: [@tag_user],
    responses: [
      ok: {"List of courses", "application/json", ListCoursesResponse},
      internal_server_error: {"Failed to list courses", "application/json", FailedResponse}
    ]
  )

  def courses(conn, _params) do
    conn
    |> AuthController.fetch_current_user(_params)
    |> case do
      %{status: 401} = conn ->
        conn

      conn ->
        case User.list_courses(conn.assigns.current_user) do
          {:ok, courses} ->
            conn
            |> put_status(:ok)
            |> render("courses.json", courses: courses)

          {:error, reason} ->
            conn
            |> put_status(:internal_server_error)
            |> render("error.json", %{reason: reason})
        end
    end
  end
end
