defmodule CoursesWeb.CourseController do
  use CoursesWeb, :controller
  use OpenApiSpex.ControllerSpecs

  alias Courses.Courses

  alias CoursesWeb.AuthController

  alias CoursesWeb.Schemas.{
    CourseResponse,
    FailedResponse,
    CourseList,
    CreateCourseRequest
  }

  @tag_course "Course"

  operation(:index,
    summary: "List courses",
    description: "List all courses",
    tags: [@tag_course],
    parameters: [
      page: [
        in: :query,
        description: "Page number",
        required: false,
        type: :integer,
        example: 1
      ],
      limit: [
        in: :query,
        description: "Number of courses per page",
        required: false,
        type: :integer,
        example: 10
      ],
      course_id: [
        in: :query,
        description: "Course ID",
        required: false,
        type: :string,
        example: "123456"
      ],
      name: [
        in: :query,
        description: "Course name",
        required: false,
        type: :string,
        example: "Math 101"
      ],
      days: [
        in: :query,
        description: "Days of the week",
        required: false,
        type: :array,
        example: ["Monday", "Wednesday"]
      ],
      professor: [
        in: :query,
        description: "Professor name",
        required: false,
        type: :string,
        example: "John Doe"
      ]
    ],
    responses: [
      ok: {"Courses listed", "application/json", CourseList},
      internal_server_error: {"Failed to get list courses", "application/json", FailedResponse}
    ],
    security: []
  )

  def index(conn, params) do
    conn
    |> AuthController.fetch_current_user()
    |> case do
      %{status: 401} = conn ->
        conn

      conn ->
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
  end

  operation(:create,
    summary: "Create course",
    description: "Create a new course",
    tags: [@tag_course],
    request_body: {"Course details", "application/json", CreateCourseRequest},
    responses: [
      ok: {"Course created", "application/json", CourseResponse},
      internal_server_error: {"Failed to create course", "application/json", FailedResponse}
    ]
  )

  def create(conn, %{"name" => name, "days" => days, "time" => time, "professor" => professor}) do
    conn
    |> AuthController.fetch_current_user()
    |> AuthController.admin_only()
    |> case do
      %{status: 401} = conn ->
        conn

      conn ->
        case Courses.create_course(name, days, time, professor) do
          {:ok, course} ->
            conn
            |> put_status(:ok)
            |> render("create.json", course: course)

          {:error, reason} ->
            conn
            |> put_status(:internal_server_error)
            |> render("error.json", reason: reason)
        end
    end
  end

  operation(:remove,
    summary: "Remove course",
    description: "Remove a course",
    tags: [@tag_course],
    parameters: [
      id: [
        in: :path,
        description: "Course ID",
        required: true,
        type: :string,
        example: "a979aa36-fb7a-4d04-bdb7-8200e7c719bd"
      ]
    ],
    responses: [
      ok: {"Course removed", "application/json", CourseResponse},
      internal_server_error: {"Failed to remove course", "application/json", FailedResponse}
    ]
  )

  def remove(conn, %{"id" => id}) do
    conn
    |> AuthController.fetch_current_user()
    |> AuthController.admin_only()
    |> case do
      %{status: 401} = conn ->
        conn

      conn ->
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
end
