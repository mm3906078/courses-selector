defmodule CoursesWeb.Schemas do
  alias OpenApiSpex.Schema

  defmodule User do
    require OpenApiSpex

    OpenApiSpex.schema(%{
      title: "User",
      description: "User information",
      type: :object,
      properties: %{
        student_id: %Schema{
          type: :string,
          description: "Student ID"
        },
        email: %Schema{
          type: :string,
          description: "Email"
        },
        name: %Schema{
          type: :string,
          description: "Name"
        }
      }
    })
  end

  defmodule Course do
    require OpenApiSpex

    OpenApiSpex.schema(%{
      title: "Course",
      description: "Course information",
      type: :object,
      properties: %{
        id: %Schema{
          type: :string,
          description: "Course ID"
        },
        name: %Schema{
          type: :string,
          description: "Course name"
        },
        days: %Schema{
          type: :string,
          description: "Days of the week"
        },
        time: %Schema{
          type: :string,
          description: "Time of day"
        }
      },
      example: %{
        "id" => "123456",
        "name" => "Math 101",
        "days" => "MWF",
        "time" => "10:00 AM"
      }
    })
  end

  defmodule CourseResponse do
    require OpenApiSpex

    OpenApiSpex.schema(%{
      title: "CourseResponse",
      description: "Response to a course request",
      type: :object,
      properties: %{
        course: Course
      }
    })
  end

  defmodule LoginResponse do
    require OpenApiSpex

    OpenApiSpex.schema(%{
      title: "LoginResponse",
      description: "Response to a login request",
      type: :object,
      properties: %{
        user: User,
        token: %Schema{
          type: :string
        }
      },
      example: %{
        "user" => %{
          "student_id" => "123456",
          "email" => "test@test.com",
          "name" => "Test User"
        },
        "token" => "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdHVkZW50X2lkIjoiMTIzNDU2In0.1Jf8"
      }
    })
  end

  defmodule AuthErrorResponse do
    require OpenApiSpex

    OpenApiSpex.schema(%{
      title: "AuthErrorResponse",
      description: "Response to a failed login request",
      type: :object,
      properties: %{
        reason: %Schema{
          type: :string
        }
      },
      example: %{
        "reason" => "Invalid student ID or password"
      }
    })
  end

  defmodule RegisterResponse do
    require OpenApiSpex

    OpenApiSpex.schema(%{
      title: "RegisterResponse",
      description: "Response to a register request",
      type: :object,
      properties: %{
        user: User
      },
      example: %{
        user: %{
          student_id: "123456",
          email: "test@test.com",
          name: "Test User"
        }
      }
    })
  end

  defmodule UserResponse do
    require OpenApiSpex

    OpenApiSpex.schema(%{
      title: "UserResponse",
      description: "Response to a user request",
      type: :object,
      properties: %{
        user: User
      }
    })
  end

  defmodule CourseList do
    require OpenApiSpex

    OpenApiSpex.schema(%{
      title: "CourseList",
      description: "List of courses",
      type: :array,
      items: Course
    })
  end

  defmodule FailedResponse do
    require OpenApiSpex

    OpenApiSpex.schema(%{
      title: "FailedResponse",
      description: "Response to a failed request",
      type: :object,
      properties: %{
        reason: %Schema{
          type: :string
        }
      }
    })
  end

  defmodule ListCoursesResponse do
    require OpenApiSpex

    OpenApiSpex.schema(%{
      title: "ListCoursesResponse",
      description: "Response to a list courses request",
      type: :object,
      properties: %{
        courses: CourseList
      }
    })
  end
end
