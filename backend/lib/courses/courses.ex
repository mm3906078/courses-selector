defmodule Courses.Courses do
  require EtcdEx
  require UUID
  require Logger

  def create_course(name, days, time, professor) do
    with {:ok, start_time, end_time} <- parse_time(time),
         true <- start_time < end_time,
         {:ok, courses} <- get_courses_for_professor(professor),
         false <- has_conflict?(courses, days, start_time, end_time),
         course = %{
           course_id: UUID.uuid4(),
           name: name,
           days: days,
           time: time,
           professor: professor
         },
         {:ok, course_str} <- Jason.encode(course),
         {:ok, _} <- EtcdEx.put(Courses.Etcd, "courses/#{course.course_id}", course_str) do
      {:ok, Map.delete(course, :password)}
    else
      {:error, :invalid_time_format} ->
        {:error, "Invalid time format"}
      false when is_boolean(false) ->
        {:error, "Time conflict or invalid time"}
      {:error, reason} ->
        {:error, reason}
      true when is_boolean(true) ->
        {:error, "Time conflict with existing course and same professor"}
      _ ->
        {:error, "Failed to create course"}
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
          res.kvs
          |> Enum.map(&parse_course/1)
          |> Enum.filter(& &1)

        Logger.info("Courses: #{inspect(courses)}")

        limit = Map.get(params, "limit")
        page = Map.get(params, "page")
        days = Map.get(params, "days")
        name = Map.get(params, "name")
        professor = Map.get(params, "professor")

        filters = Map.drop(params, ["limit", "page", "days", "name", "professor"])

        Logger.debug("Filters: #{inspect(filters)}")

        parsed_days = if days, do: parse_days(days), else: []

        filtered_courses =
          Enum.filter(courses, fn course ->
            Enum.all?(filters, fn
              {key, value} ->
                value == nil or value == "" or Map.get(course, key) == value
            end) and
              (parsed_days == [] or Enum.any?(parsed_days, &(&1 in course["days"]))) and
              (name == nil or name == "" or regex_match?(course["name"], name)) and
              (professor == nil or professor == "" or regex_match?(course["professor"], professor))
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

  def get_all_courses do
    case EtcdEx.get(Courses.Etcd, "courses/", prefix: true) do
      {:ok, res} ->
        courses =
          res.kvs
          |> Enum.map(&parse_course/1)
          |> Enum.filter(& &1)
        {:ok, courses}

      {:error, _} ->
        {:error, "Failed to retrieve courses"}
    end
  end

  defp parse_course(%{value: value}) do
    case Jason.decode(value) do
      {:ok, course} -> course
      {:error, _} -> nil
    end
  end

  defp parse_days(days) when is_binary(days) do
    days
    |> String.split(",")
    |> Enum.map(&String.trim/1)
  end

  defp parse_time(time) do
    regex = ~r/(?<start_hour>\d{1,2}):(?<start_minute>\d{2}) (?<start_period>AM|PM) - (?<end_hour>\d{1,2}):(?<end_minute>\d{2}) (?<end_period>AM|PM)/
    case Regex.named_captures(regex, time) do
      %{"start_hour" => start_hour, "start_minute" => start_minute, "start_period" => start_period, "end_hour" => end_hour, "end_minute" => end_minute, "end_period" => end_period} ->
        start_time = to_24_hour_format(start_hour, start_minute, start_period)
        end_time = to_24_hour_format(end_hour, end_minute, end_period)
        {:ok, start_time, end_time}

      _ ->
        {:error, :invalid_time_format}
    end
  end

  defp to_24_hour_format(hour, minute, period) do
    hour = String.to_integer(hour)
    minute = String.to_integer(minute)

    case period do
      "PM" when hour < 12 -> {hour + 12, minute}
      "AM" when hour == 12 -> {0, minute}
      "AM" when hour < 12 -> {hour, minute}
      "PM" when hour == 12 -> {12, minute}
      _ -> {hour, minute}
    end
  end

  defp get_courses_for_professor(professor) do
    get_all_courses()
    |> case do
      {:ok, courses} ->
        professor_courses = Enum.filter(courses, fn course -> course["professor"] == professor end)
        {:ok, professor_courses}

      error -> error
    end
  end

  defp has_conflict?(courses, days, start_time, end_time) do
    Enum.any?(courses, fn course ->
      Enum.any?(course["days"], fn day ->
        day in days and time_overlap?(course["time"], start_time, end_time)
      end)
    end)
  end

  defp time_overlap?(time, start_time, end_time) do
    case parse_time(time) do
      {:ok, course_start, course_end} ->
        (course_start < end_time and start_time < course_end)
      _ -> false
    end
  end

  defp regex_match?(text, pattern) do
    regex = ~r/#{Regex.escape(pattern)}/i
    Regex.match?(regex, text)
  end

  def within_time_range?(course_time, filter_time) do
    case String.split(course_time, "-", trim: true) do
      [course_start_str, course_end_str] ->
        course_start_str = String.trim(course_start_str)
        course_end_str = String.trim(course_end_str)

        with {:ok, course_start} <- Timex.parse(course_start_str, "{h12}:{m} {AM}"),
             {:ok, course_end} <- Timex.parse(course_end_str, "{h12}:{m} {AM}"),
             {:ok, filter_time} <- Timex.parse(filter_time, "{h12}:{m} {AM}") do
          Timex.between?(filter_time, course_start, course_end, inclusive: true)
        else
          _ -> false
        end

      _ ->
        Logger.error("Invalid time range: #{course_time}")
        false
    end
  end
end
