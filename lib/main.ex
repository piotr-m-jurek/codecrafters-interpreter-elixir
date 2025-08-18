defmodule CLI do
  # This is the main entry point of our program

  def main(args) do
    case args do
      ["tokenize", filename] ->
        case File.read(filename) do
          {:ok, file_contents} ->
            tokens =
              file_contents
              |> Scanner.scan()

            Enum.each(tokens, fn token ->
              token |> Scanner.print_token() |> IO.puts()
            end)

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
