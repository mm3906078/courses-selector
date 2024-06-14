defmodule CoursesWeb.AuthController do
  use CoursesWeb, :controller
  use OpenApiSpex.ControllerSpecs

  import Plug.Conn
  require Jason
  require Logger

  alias Courses.Accounts

  alias CoursesWeb.Schemas.{
    LoginResponse,
    AuthErrorResponse,
    RegisterResponse,
    User
  }

  @tag_user "Auth"

  def fetch_current_user(conn, _params) do
    case get_req_header(conn, "authorization") do
      [token] ->
        case Phoenix.Token.verify(CoursesWeb.Endpoint, "user", token, max_age: 86400) do
          {:ok, user_id} ->
            case Accounts.get_user_by_id(user_id) do
              nil ->
                conn

              user ->
                assign(conn, :current_user, user)
            end

          {:error, _reason} ->
            conn
        end

      _ ->
        conn
    end
  end

  def user_only(conn, _params) do
    case conn.assigns[:current_user] do
      nil ->
        Logger.info("No user found")
        conn |> put_status(:unauthorized) |> render("error.json", %{reason: "Unauthorized"})

      _ ->
        conn
    end
  end

  def admin_only(conn, _params) do
    case conn.assigns[:current_user] do
      nil ->
        Logger.info("No user found")
        conn |> put_status(:unauthorized) |> render("error.json", %{reason: "Unauthorized"})

      user ->
        case Accounts.is_admin?(user) do
          true ->
            Logger.info("User #{user["student_id"]} is an admin")
            conn

          false ->
            Logger.info("User #{user["student_id"]} is not an admin")
            conn |> put_status(:unauthorized) |> render("error.json", %{reason: "Unauthorized"})
        end
    end
  end

  operation(:login,
    summary: "Login",
    description: "Login as a user",
    tags: [@tag_user],
    security: [],
    parameters: [
      student_id: [
        in: :query,
        description: "Student ID",
        required: true,
        type: :string,
        example: "e6bc16c5-319a-43bb-9ecc-77bfd5f8f417"
      ],
      password: [
        in: :query,
        description: "Password",
        required: true,
        type: :string,
        example: "password"
      ]
    ],
    responses: [
      ok: {"Login successful", "application/json", LoginResponse},
      internal_server_error: {"Failed to login", "application/json", AuthErrorResponse}
    ]
  )

  def login(conn, %{"student_id" => student_id, "password" => password}) do
    case Accounts.authenticate_user(student_id, password) do
      {:ok, user} ->
        token = Phoenix.Token.sign(CoursesWeb.Endpoint, "user", user["student_id"])

        conn
        |> put_status(:ok)
        |> render("login.json", %{user: user, token: token})

      {:error, reason} ->
        conn
        |> put_status(:internal_server_error)
        |> render("error.json", %{reason: reason})
    end
  end

  operation(:register,
    summary: "Register",
    description: "Register a new user",
    tags: [@tag_user],
    security: [],
    parameters: [
      email: [
        in: :query,
        description: "Email",
        required: true,
        type: :string,
        example: "test@test.com"
      ],
      password: [
        in: :query,
        description: "Password",
        required: true,
        type: :string,
        example: "password"
      ],
      name: [
        in: :query,
        description: "Name",
        required: true,
        type: :string,
        example: "Test User"
      ]
    ],
    responses: [
      ok: {"Registration successful", "application/json", RegisterResponse},
      internal_server_error: {"Failed to register user", "application/json", AuthErrorResponse}
    ]
  )

  def register(conn, %{"email" => email, "password" => password, "name" => name}) do
    case Accounts.create_user(email, password, name) do
      {:ok, user} ->
        conn
        |> put_status(:ok)
        |> render("register.json", user: user)

      {:error, reason} ->
        conn
        |> put_status(:internal_server_error)
        |> render("error.json", reason: reason)
    end
  end

  operation(:list,
    summary: "List users",
    description: "List all users",
    tags: [@tag_user],
    responses: [
      ok: {"List of users", "application/json", [User]},
      internal_server_error: {"Failed to list users", "application/json", AuthErrorResponse}
    ]
  )

  def list(conn, _params) do
    conn
    |> fetch_current_user(_params)
    |> admin_only(_params)
    |> case do
      %{status: 401} = conn ->
        conn

      conn ->
        {:ok, users} = Accounts.list_users()
        render(conn, "list.json", %{users: users})
    end
  end

  operation(:remove,
    summary: "Remove user",
    tags: [@tag_user],
    description: "Remove a user",
    parameters: [
      %{
        in: :path,
        name: "student_id",
        description: "Student ID",
        required: true,
        schema: %{
          type: :string
        }
      }
    ],
    responses: [
      ok: {"User removed", "application/json", UserResponse},
      internal_server_error: {"Failed to remove user", "application/json", FailedResponse}
    ]
  )

  def remove(conn, %{"student_id" => student_id}) do
    conn
    |> fetch_current_user(%{"student_id" => student_id})
    |> admin_only(%{"student_id" => student_id})
    |> case do
      %{status: 401} = conn ->
        conn

      conn ->
        case Accounts.remove_user(student_id) do
          {:ok, user} ->
            conn
            |> put_status(:ok)
            |> render("remove.json", user: user)

          {:error, reason} ->
            conn
            |> put_status(:internal_server_error)
            |> render("error.json", %{reason: reason})
        end
    end
  end
end
