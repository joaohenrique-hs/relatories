defmodule GenReport do
  def build(filename) do
    filename
    |> GenReport.Parser.parse_file()
    |> Enum.reduce(report(), &sum_line/2)
  end

  def build() do
    {:error, "Insira o nome de um arquivo"}
  end

  def build_from_many(filenames) when not is_list(filenames) do
    {:error, "Please provide a list of string!"}
  end

  def build_from_many(filenames) do
    filenames
    |> Task.async_stream(&build/1)
    |> Enum.reduce(report(), fn {:ok, result}, report -> sum_reports(report, result) end)
  end

  defp sum_reports(
         %{
           "all_hours" => all_hours1,
           "hours_per_month" => hours_per_month1,
           "hours_per_year" => hours_per_year1
         },
         %{
           "all_hours" => all_hours2,
           "hours_per_month" => hours_per_month2,
           "hours_per_year" => hours_per_year2
         }
       ) do
    all_hours = Map.merge(all_hours1, all_hours2, fn _key, value1, value2 -> value1 + value2 end)

    hours_per_month = merge_report_fields(hours_per_month1, hours_per_month2)

    hours_per_year = merge_report_fields(hours_per_year1, hours_per_year2)

    %{
      "all_hours" => all_hours,
      "hours_per_month" => hours_per_month,
      "hours_per_year" => hours_per_year
    }
  end

  defp merge_report_fields(map1, map2) do
    Map.merge(map1, map2, fn _key, value1, value2 ->
      Map.merge(value1, value2, fn _key, final_value1, final_value2 ->
        final_value1 + final_value2
      end)
    end)
  end

  defp report, do: %{"all_hours" => %{}, "hours_per_month" => %{}, "hours_per_year" => %{}}

  defp sum_line(line, %{
         "all_hours" => all_hours,
         "hours_per_month" => hours_per_month,
         "hours_per_year" => hours_per_year
       }) do
    new_all_hours =
      Map.update(all_hours, Enum.at(line, 0), Enum.at(line, 1), fn existing_value ->
        existing_value + Enum.at(line, 1)
      end)

    new_hours_per_month =
      Map.update(
        hours_per_month,
        Enum.at(line, 0),
        Map.put(%{}, Enum.at(line, 3), Enum.at(line, 1)),
        &handle_hours_calculation(&1, line, 3)
      )

    new_hours_per_year =
      Map.update(
        hours_per_year,
        Enum.at(line, 0),
        Map.put(%{}, Enum.at(line, 4), Enum.at(line, 1)),
        &handle_hours_calculation(&1, line, 4)
      )

    %{
      "all_hours" => new_all_hours,
      "hours_per_month" => new_hours_per_month,
      "hours_per_year" => new_hours_per_year
    }
  end

  defp handle_hours_calculation(existing_value, line, position) do
    existing_month_value = existing_value[Enum.at(line, position)]

    case existing_month_value do
      nil ->
        Map.put(existing_value, Enum.at(line, position), Enum.at(line, 1))

      _ ->
        Map.put(existing_value, Enum.at(line, position), existing_month_value + Enum.at(line, 1))
    end
  end
end
