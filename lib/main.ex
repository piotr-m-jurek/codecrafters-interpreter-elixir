defmodule CLI do
  # This is the main entry point of our program

  def main(args) do
    case args do
      ["tokenize", filename] ->
        case File.read(filename) do
          {:ok, file_contents} ->
            {tokens, errors} = file_contents |> Scanner.scan()

            Enum.each(
              errors,
              fn error ->
                IO.puts(:standard_error, error)
              end
            )

            Enum.each(tokens, fn token ->
              token |> Scanner.print_token() |> IO.puts()
            end)

            System.halt(if(Enum.empty?(errors), do: 0, else: 65))

          {:error, reason} ->
            IO.puts(:stderr, "Error reading file: #{reason}")
            System.halt(1)
        end

      [command, _filename] ->
        IO.puts(:stderr, "Unknown command: #{command}")
        System.halt(1)

      _ ->
        IO.puts(:stderr, "Usage: ./your_program.sh tokenize <filename>")
        System.halt(1)
    end
  end
end
