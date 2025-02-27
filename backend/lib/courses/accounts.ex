defmodule Courses.Accounts do
  require UUID
  require EtcdEx

  require Logger

  def create_user(email, password, name, role) do
    # make sure all elements are strings
    password = to_string(password)
    email = to_string(email)
    name = to_string(name)
    role = to_string(role)

    # check if password or email are not empty
    if password == "" or email == "" do
      {:error, "Email or password cannot be empty"}
    else
      if role != "admin" and role != "student" do
        {:error, "Invalid role"}
      else
        user = %{
          student_id: UUID.uuid4(),
          email: email,
          name: name,
          password: Base.encode64(password),
          role: role
        }

        # Check if user already exists
        case EtcdEx.get(Courses.Etcd, "users/emails/#{email}") do
          {:ok, res} ->
            if res.count > 0 do
              {:error, "User already exists"}
            else
              with {:ok, user_str} <- Jason.encode(user),
                   {:ok, _} <- EtcdEx.put(Courses.Etcd, "users/#{user.student_id}", user_str),
                   {:ok, _} <- EtcdEx.put(Courses.Etcd, "users/emails/#{email}", user.student_id) do
                {:ok, Map.delete(user, :password)}
              else
                {:error, _} -> {:error, "Failed to register user"}
              end
            end

          {:error, _} ->
            {:error, "Failed to register user"}
        end
      end
    end
  end

  def authenticate_user_stid(student_id, password) do
    case EtcdEx.get(Courses.Etcd, "users/#{student_id}") do
      {:ok, %{kvs: [kv | _]}} ->
        case Jason.decode(kv.value) do
          {:ok, user} ->
            if Base.encode64(password) == user["password"] do
              {:ok, Map.delete(user, "password")}
            else
              {:error, "Invalid student ID or password"}
            end

          {:error, _} ->
            {:error, "Failed to decode user data"}
        end

      {:ok, %{kvs: []}} ->
        {:error, "User not found"}

      {:error, _} ->
        {:error, "Invalid student ID or password"}
    end
  end

  def authenticate_user_email(email, password) do
    # make sure all elements are strings
    email = to_string(email)
    password = to_string(password)

    case EtcdEx.get(Courses.Etcd, "users/emails/#{email}") do
      {:ok, %{kvs: [kv | _]}} ->
        case authenticate_user_stid(kv.value, password) do
          {:ok, user} -> {:ok, user}
          {:error, reason} -> {:error, reason}
        end

      {:ok, %{kvs: []}} ->
        {:error, "User not found"}

      {:error, _} ->
        {:error, "Invalid email or password"}
    end
  end

  def list_users do
    case EtcdEx.get(Courses.Etcd, "users/", prefix: true) do
      {:ok, res} ->
        users =
          res.kvs
          |> Enum.map(fn kv ->
            case Jason.decode(kv.value) do
              {:ok, user} -> Map.delete(user, "password")
              {:error, _} -> nil
            end
          end)
          |> Enum.filter(&(&1 != nil))

        {:ok, users}

      {:error, _} ->
        {:error, "Failed to list users"}
    end
  end

  def remove_user(student_id) do
    # Check if user exists
    case EtcdEx.get(Courses.Etcd, "users/#{student_id}") do
      {:ok, %{kvs: [kv | _]}} ->
        case Jason.decode(kv.value) do
          {:ok, user} ->
            with {:ok, _} <- EtcdEx.delete(Courses.Etcd, "users/#{student_id}"),
                 {:ok, _} <- EtcdEx.delete(Courses.Etcd, "users/emails/#{user["email"]}") do
              {:ok, Map.delete(user, "password")}
            else
              {:error, reason} -> {:error, "Failed to remove user: #{reason}"}
            end

          {:error, reason} ->
            {:error, "Failed to decode user data: #{reason}"}
        end

      {:ok, %{kvs: []}} ->
        {:error, "User not found"}

      {:error, reason} ->
        {:error, "Failed to retrieve user: #{reason}"}
    end
  end

  def is_admin?(user) do
    user["role"] == "admin"
  end

  def get_user_by_id(student_id) do
    case EtcdEx.get(Courses.Etcd, "users/#{student_id}") do
      {:ok, %{kvs: [kv | _]}} ->
        case Jason.decode(kv.value) do
          {:ok, user} -> user
          {:error, _} -> nil
        end

      {:ok, %{kvs: []}} ->
        nil

      {:error, _} ->
        nil
    end
  end

  def get_user_by_email(email) do
    case EtcdEx.get(Courses.Etcd, "users/emails/#{email}") do
      {:ok, %{kvs: [kv | _]}} ->
        case get_user_by_id(kv.value) do
          user when is_map(user) -> user
          _ -> nil
        end

      {:ok, %{kvs: []}} ->
        nil

      {:error, _} ->
        nil
    end
  end
end
