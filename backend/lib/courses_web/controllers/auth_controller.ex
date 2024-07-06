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
    User,
    CreateUserRequest,
    LoginUserRequest,
    RemoveUserResponse
  }

  @tag_user "Auth"

  def fetch_current_user(conn, _params) do
    fetch_current_user(conn)
  end

  def fetch_current_user(conn) do
    case get_req_header(conn, "authorization") do
      [token] ->
        case Phoenix.Token.verify(CoursesWeb.Endpoint, "user", token, max_age: 86400) do
          {:ok, email} ->
            case Accounts.get_user_by_email(email) do
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

  def admin_only(conn, _params) do
    admin_only(conn)
  end

  def user_only(conn) do
    case conn.assigns[:current_user] do
      nil ->
        Logger.info("No user found")
        conn |> put_status(:unauthorized) |> render("error.json", %{reason: "Unauthorized"})

      _ ->
        conn
    end
  end

  def admin_only(conn) do
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
    request_body: {"User credentials", "application/json", LoginUserRequest},
    responses: [
      ok: {"Login successful", "application/json", LoginResponse},
      internal_server_error: {"Failed to login", "application/json", AuthErrorResponse}
    ]
  )

  def login(conn, %{"email" => email, "password" => password}) do
    case Accounts.authenticate_user_email(email, password) do
      {:ok, user} ->
        token = Phoenix.Token.sign(CoursesWeb.Endpoint, "user", user["email"])

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
    request_body: {"User details", "application/json", CreateUserRequest},
    responses: [
      ok: {"Registration successful", "application/json", RegisterResponse},
      internal_server_error: {"Failed to register user", "application/json", AuthErrorResponse}
    ]
  )

  def register(conn, %{"email" => email, "password" => password, "name" => name, "role" => role}) do
    case Accounts.create_user(email, password, name, role) do
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
    |> fetch_current_user()
    |> admin_only()
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
      student_id: [
        in: :path,
        description: "Student ID",
        required: true,
        type: :string,
        example: "123456"
      ]
    ],
    responses: [
      ok: {"User removed", "application/json", RemoveUserResponse},
      internal_server_error: {"Failed to remove user", "application/json", AuthErrorResponse}
    ]
  )

  def remove(conn, %{"student_id" => student_id}) do
    conn
    |> fetch_current_user()
    |> admin_only()
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
