defmodule Courses.Courses do
  require EtcdEx
  require UUID
  require Logger

  def create_course(name, days, time) do
    course = %{
      course_id: UUID.uuid4(),
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

  def remove_course(course_id) do
    case EtcdEx.get(Courses.Etcd, "courses/#{course_id}") do
      {:ok, %{kvs: [kv | _]}} ->
        case Jason.decode(kv.value) do
          {:ok, course} ->
            case EtcdEx.delete(Courses.Etcd, "courses/#{course_id}") do
              {:ok, _} ->
                {:ok, Map.delete(course, :password)}

              {:error, _} ->
                {:error, "Failed to remove course"}
            end

          {:error, _} ->
            {:error, "Failed to decode course data"}
        end

      {:ok, %{kvs: []}} ->
        {:error, "Course not found"}

      {:error, _} ->
        {:error, "Failed to retrieve course"}
    end
  end

  def list_courses(params) do
    case EtcdEx.get(Courses.Etcd, "courses/", prefix: true) do
      {:ok, res} ->
        courses =
          Enum.map(res.kvs, fn kv ->
            case Jason.decode(kv.value) do
              {:ok, course} -> course
              {:error, _} -> nil
            end
          end)
          # Remove any nil values
          |> Enum.filter(& &1)

        Logger.info("Courses: #{inspect(courses)}")

        # Separate limit, page, days, and time from other filters
        limit = Map.get(params, "limit")
        page = Map.get(params, "page")
        days = Map.get(params, "days")
        time = Map.get(params, "time")

        filters = Map.drop(params, ["limit", "page", "days", "time"])

        Logger.debug("Filters: #{inspect(filters)}")

        # Parse days into a list
        parsed_days = if days, do: parse_days(days), else: []

        filtered_courses =
          Enum.filter(courses, fn course ->
            Enum.all?(filters, fn
              {key, value} ->
                value == nil or value == "" or Map.get(course, key) == value
            end) and
              (parsed_days == [] or Enum.any?(parsed_days, &(&1 in parse_days(course["days"])))) and
              (time == nil or time == "" or within_time_range?(course["time"], time))
          end)

        paginated_courses =
          case {limit, page} do
            {nil, nil} ->
              filtered_courses

            {limit, nil} ->
              Enum.take(filtered_courses, String.to_integer(limit))

            {limit, page} ->
              limit = String.to_integer(limit)
              page = String.to_integer(page)

              filtered_courses
              |> Enum.chunk_every(limit)
              |> Enum.at(page - 1, [])
          end

        {:ok, paginated_courses}

      {:error, _} ->
        {:error, "Failed to list courses"}
    end
  end

  def parse_days(days) do
    days
    |> String.split("-", trim: true)
    |> Enum.map(&String.trim/1)
  end

  def within_time_range?(course_time, filter_time) do
    case String.split(course_time, "-", trim: true) do
      [course_start_str, course_end_str] ->
        course_start_str = String.trim(course_start_str)
        course_end_str = String.trim(course_end_str)

        with {:ok, course_start} <- Timex.parse(course_start_str, "{h12}:{m} {AM}"),
             {:ok, course_end} <- Timex.parse(course_end_str, "{h12}:{m} {AM}"),
             {:ok, filter_time} <- Timex.parse(filter_time, "{h12}:{m} {AM}") do
          case Timex.between?(filter_time, course_start, course_end, inclusive: true) do
            true -> true
            false -> false
          end
        else
          _ -> false
        end

      _ ->
        Logger.error("Invalid time range: #{course_time}")
        false
    end
  end
end
