defmodule Courses.User do
  require Logger

  def enroll_user(user, course_id) do
    user = Enum.into(user, %{}, fn {k, v} -> {String.to_atom(k), v} end)

    if !user_exists?(user.student_id) do
      {:error, "User not found"}
    else
      if !course_exists?(course_id) do
        {:error, "Course not found"}
      else
        if user_enrolled?(user.student_id, course_id) do
          {:error, "User already enrolled in course"}
        else
          if !enroll_user_possible?(user, course_id) do
            {:error, "User cannot enroll in course because of time conflicts"}
          else
            case EtcdEx.get(Courses.Etcd, "users/#{user.student_id}/courses/") do
              {:ok, %{kvs: [kv | _]}} ->
                case Jason.decode(kv.value) do
                  {:ok, courses} ->
                    courses = [course_id | courses]

                    with {:ok, courses_str} <- Jason.encode(courses),
                         {:ok, _} <-
                           EtcdEx.put(
                             Courses.Etcd,
                             "users/#{user.student_id}/courses/",
                             courses_str
                           ) do
                      {:ok, remove_password(user)}
                    else
                      {:error, _} -> {:error, "Failed to enroll user in course"}
                    end

                  {:error, _} ->
                    {:error, "Failed to decode course data"}
                end

              {:ok, %{kvs: []}} ->
                with {:ok, courses_str} <- Jason.encode([course_id]),
                     {:ok, _} <-
                       EtcdEx.put(Courses.Etcd, "users/#{user.student_id}/courses/", courses_str) do
                  {:ok, remove_password(user)}
                else
                  {:error, _} -> {:error, "Failed to enroll user in course"}
                end

              {:error, _} ->
                {:error, "Failed to retrieve user's courses"}
            end
          end
        end
      end
    end
  end

  def list_courses(user) do
    user = Enum.into(user, %{}, fn {k, v} -> {String.to_atom(k), v} end)

    if !user_exists?(user.student_id) do
      {:error, "User not found"}
    else
      case EtcdEx.get(Courses.Etcd, "users/#{user.student_id}/courses/") do
        {:ok, %{kvs: [kv | _]}} ->
          case Jason.decode(kv.value) do
            {:ok, courses} ->
              # Retrieve course data
              courses =
                Enum.map(courses, fn course_id ->
                  case EtcdEx.get(Courses.Etcd, "courses/#{course_id}") do
                    {:ok, %{kvs: [kv | _]}} ->
                      case Jason.decode(kv.value) do
                        {:ok, course} -> course
                        {:error, _} -> nil
                      end

                    {:ok, %{kvs: []}} ->
                      nil

                    {:error, _} ->
                      nil
                  end
                end)
                # Remove any nil values
                |> Enum.filter(& &1)

              {:ok, courses}

            {:error, _} ->
              {:error, "Failed to decode course data"}
          end

        {:ok, %{kvs: []}} ->
          {:ok, []}

        {:error, _} ->
          {:error, "Failed to retrieve user's courses"}
      end
    end
  end

  def unenroll_user(user, course_id) do
    user = Enum.into(user, %{}, fn {k, v} -> {String.to_atom(k), v} end)

    if !user_exists?(user.student_id) do
      {:error, "User not found"}
    else
      if !course_exists?(course_id) do
        {:error, "Course not found"}
      else
        if !user_enrolled?(user.student_id, course_id) do
          {:error, "User not enrolled in course"}
        else
          case EtcdEx.get(Courses.Etcd, "users/#{user.student_id}/courses/") do
            {:ok, %{kvs: [kv | _]}} ->
              case Jason.decode(kv.value) do
                {:ok, courses} ->
                  courses = Enum.reject(courses, &(&1 == course_id))

                  with {:ok, courses_str} <- Jason.encode(courses),
                       {:ok, _} <-
                         EtcdEx.put(
                           Courses.Etcd,
                           "users/#{user.student_id}/courses/",
                           courses_str
                         ) do
                    Logger.debug("Unenrolled user #{user.student_id} from course #{course_id}")
                    {:ok, remove_password(user)}
                  else
                    {:error, _} -> {:error, "Failed to unenroll user from course"}
                  end

                {:error, _} ->
                  {:error, "Failed to decode course data"}
              end

            {:ok, %{kvs: []}} ->
              {:error, "User not enrolled in course"}

            {:error, _} ->
              {:error, "Failed to retrieve user's courses"}
          end
        end
      end
    end
  end

  defp course_exists?(course_id) do
    case EtcdEx.get(Courses.Etcd, "courses/#{course_id}") do
      {:ok, %{kvs: [kv | _]}} ->
        case Jason.decode(kv.value) do
          {:ok, _} -> true
          {:error, _} -> false
        end

      {:ok, %{kvs: []}} ->
        false

      {:error, _} ->
        false
    end
  end

  defp user_exists?(student_id) do
    case EtcdEx.get(Courses.Etcd, "users/#{student_id}") do
      {:ok, %{kvs: [kv | _]}} ->
        case Jason.decode(kv.value) do
          {:ok, _} -> true
          {:error, _} -> false
        end

      {:ok, %{kvs: []}} ->
        false

      {:error, _} ->
        false
    end
  end

  def user_enrolled?(student_id, course_id) do
    case EtcdEx.get(Courses.Etcd, "users/#{student_id}/courses/") do
      {:ok, %{kvs: [kv | _]}} ->
        case Jason.decode(kv.value) do
          {:ok, courses} ->
            Enum.member?(courses, course_id)

          {:error, _} ->
            false
        end

      {:ok, %{kvs: []}} ->
        false

      {:error, _} ->
        false
    end
  end

  defp remove_password(user) do
    Map.delete(user, :password)
  end

  defp enroll_user_possible?(user, course_id) do
    # Check time and day conflicts
    true
  end
end
