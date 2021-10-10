defmodule GenReport.Parser do
  def parse_file(filename) do
    filename
    |> File.stream!()
    |> Stream.map(&parse_line/1)
  end

  defp parse_line(line) do
    line
    |> String.split(",")
    |> create_line()
  end

  defp create_line([name, hours, day, month, year]) do
    [
      String.downcase(name),
      String.to_integer(hours),
      String.to_integer(day),
      parse_month(month),
      String.to_integer(String.trim(year))
    ]
  end

  defp parse_month(month_number) do
    case month_number do
      "1" -> "janeiro"
      "2" -> "fevereiro"
      "3" -> "março"
      "4" -> "abril"
      "5" -> "maio"
      "6" -> "junho"
      "7" -> "julho"
      "8" -> "agosto"
      "9" -> "setembro"
      "10" -> "outubro"
      "11" -> "novembro"
      "12" -> "dezembro"
    end
  end
end
