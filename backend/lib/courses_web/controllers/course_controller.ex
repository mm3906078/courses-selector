defmodule CoursesWeb.CourseController do
  use CoursesWeb, :controller
  use OpenApiSpex.ControllerSpecs

  alias Courses.Courses

  alias CoursesWeb.AuthController
  alias CoursesWeb.Schemas.{
    CourseResponse,
    FailedResponse,
    CourseList
  }

  operation(:index,
    summary: "List courses",
    parameters: [
      page: [
        in: :query,
        description: "Page number",
        required: false,
        type: :integer
      ],
      limit: [
        in: :query,
        description: "Number of courses per page",
        required: false,
        type: :integer
      ],
      course_id: [
        in: :query,
        description: "Course ID",
        required: false,
        type: :string
      ],
      name: [
        in: :query,
        description: "Course name",
        required: false,
        type: :string
      ],
      days: [
        in: :query,
        description: "Days of the week",
        required: false,
        type: :string
      ],
      time: [
        in: :query,
        description: "Time of day",
        required: false,
        type: :string
      ]
    ],
    responses: [
      ok: {"Courses listed", "application/json", CourseList},
      internal_server_error: {"Failed to get list courses", "application/json", FailedResponse}
    ]
  )

  def index(conn, params) do
    case Courses.list_courses(params) do
      {:ok, courses} ->
        conn
        |> put_status(:ok)
        |> render("index.json", courses: courses)

      {:error, reason} ->
        conn
        |> put_status(:internal_server_error)
        |> render("error.json", %{reason: reason})
    end
  end

  operation(:create,
    summary: "Create course",
    description: "Create a new course",
    parameters: [
      name: [
        in: :query,
        name: "name",
        description: "Course name",
        required: true,
        type: :string
      ],
      days: [
        in: :query,
        name: "days",
        description: "Days of the week",
        required: true,
        type: :string
      ],
      time: [
        in: :query,
        name: "time",
        description: "Time of day",
        required: true,
        type: :string
      ]
    ],
    responses: [
      ok: {"Course created", "application/json", CourseResponse},
      internal_server_error: {"Failed to create course", "application/json", FailedResponse}
    ]
  )

  def create(conn, %{"name" => name, "days" => days, "time" => time}) do
    conn
    |> AuthController.current_user()
    |> AuthController.admin_only()
    |> case do
      %{status: 401} = conn ->
        conn

      conn ->
        case Courses.create_course(name, days, time) do
          {:ok, course} ->
            conn
            |> put_status(:ok)
            |> render("create.json", course: course)

          {:error, reason} ->
            conn
            |> put_status(:internal_server_error)
            |> render("error.json", %{reason: reason})
        end
    end
  end

  operation(:remove,
    summary: "Remove course",
    description: "Remove a course",
    parameters: [
      %{
        in: :path,
        name: "id",
        description: "Course ID",
        required: true,
        schema: %{
          type: :string
        }
      }
    ],
    responses: [
      ok: {"Course removed", "application/json", CourseResponse},
      internal_server_error: {"Failed to remove course", "application/json", FailedResponse}
    ]
  )

  def remove(conn, %{"id" => id}) do
    case Courses.remove_course(id) do
      {:ok, course} ->
        conn
        |> put_status(:ok)
        |> render("remove.json", course: course)

      {:error, reason} ->
        conn
        |> put_status(:internal_server_error)
        |> render("error.json", %{reason: reason})
    end
  end
end
