defmodule Scanner do
  @type token :: {name :: String.t(), sign :: String.t(), literal :: String.t() | nil}
  @type scanner_error :: String.t()

  @spec scan(contents :: String.t()) :: {[token()], [scanner_error()]}
  def scan(contents), do: scan(contents, [], [], 1)

  @spec scan(
          contents :: String.t(),
          tokens :: [token()],
          errors :: [scanner_error()],
          row_index :: non_neg_integer()
        ) ::
          {[token()], [scanner_error()]}

  def scan("//" <> rest, tokens, errors, row_index) do
    case String.split(rest, "\n", parts: 2) do
      [_] ->
        scan("", tokens, errors, row_index)

      [_, rest] ->
        scan(rest, tokens, errors, row_index + 1)
    end
  end

  def scan("\"" <> rest, tokens, errors, row_index) do
    case String.split(rest, "\"", parts: 2) do
      [value, rest] ->
        token = {"STRING", "\"#{value}\"", value}
        scan(rest, [token | tokens], errors, row_index)

      [_] ->
        error = "[line #{row_index}] Error: Unterminated string."

        case String.split(rest, "\n", parts: 2) do
          [_, rest] ->
            scan(rest, tokens, [error | errors], row_index + 1)

          [_] ->
            scan("", tokens, [error | errors], row_index)
        end
    end
  end

  def scan("!=" <> rest, tokens, errors, row_index) do
    scan(rest, [{"BANG_EQUAL", "!=", nil} | tokens], errors, row_index)
  end

  def scan("==" <> rest, tokens, errors, row_index) do
    scan(rest, [{"EQUAL_EQUAL", "==", nil} | tokens], errors, row_index)
  end

  def scan(">=" <> rest, tokens, errors, row_index) do
    scan(rest, [{"GREATER_EQUAL", ">=", nil} | tokens], errors, row_index)
  end

  def scan("<=" <> rest, tokens, errors, row_index) do
    scan(rest, [{"LESS_EQUAL", "<=", nil} | tokens], errors, row_index)
  end

  def scan("<" <> rest, tokens, errors, row_index) do
    scan(rest, [{"LESS", "<", nil} | tokens], errors, row_index)
  end

  def scan(">" <> rest, tokens, errors, row_index) do
    scan(rest, [{"GREATER", ">", nil} | tokens], errors, row_index)
  end

  def scan("(" <> rest, tokens, errors, row_index) do
    scan(rest, [{"LEFT_PAREN", "(", nil} | tokens], errors, row_index)
  end

  def scan(")" <> rest, tokens, errors, row_index) do
    scan(rest, [{"RIGHT_PAREN", ")", nil} | tokens], errors, row_index)
  end

  def scan("{" <> rest, tokens, errors, row_index) do
    scan(rest, [{"LEFT_BRACE", "{", nil} | tokens], errors, row_index)
  end

  def scan("}" <> rest, tokens, errors, row_index) do
    scan(rest, [{"RIGHT_BRACE", "}", nil} | tokens], errors, row_index)
  end

  def scan("*" <> rest, tokens, errors, row_index) do
    scan(rest, [{"STAR", "*", nil} | tokens], errors, row_index)
  end

  def scan("." <> rest, tokens, errors, row_index) do
    scan(rest, [{"DOT", ".", nil} | tokens], errors, row_index)
  end

  def scan("," <> rest, tokens, errors, row_index) do
    scan(rest, [{"COMMA", ",", nil} | tokens], errors, row_index)
  end

  def scan("+" <> rest, tokens, errors, row_index) do
    scan(rest, [{"PLUS", "+", nil} | tokens], errors, row_index)
  end

  def scan("-" <> rest, tokens, errors, row_index) do
    scan(rest, [{"MINUS", "-", nil} | tokens], errors, row_index)
  end

  def scan(";" <> rest, tokens, errors, row_index) do
    scan(rest, [{"SEMICOLON", ";", nil} | tokens], errors, row_index)
  end

  def scan("/" <> rest, tokens, errors, row_index) do
    scan(rest, [{"SLASH", "/", nil} | tokens], errors, row_index)
  end

  def scan("!" <> rest, tokens, errors, row_index) do
    scan(rest, [{"BANG", "!", nil} | tokens], errors, row_index)
  end

  def scan("=" <> rest, tokens, errors, row_index) do
    scan(rest, [{"EQUAL", "=", nil} | tokens], errors, row_index)
  end

  def scan("\n" <> rest, tokens, errors, row_index) do
    scan(rest, tokens, errors, row_index + 1)
  end

  def scan(" " <> rest, tokens, errors, row_index) do
    scan(rest, tokens, errors, row_index)
  end

  def scan("\t" <> rest, tokens, errors, row_index) do
    scan(rest, tokens, errors, row_index)
  end

  def scan("", tokens, errors, _) do
    {Enum.reverse([{"EOF", "", nil} | tokens]), Enum.reverse(errors)}
  end

  def scan(<<ch::utf8>> <> rest, tokens, errors, row_index) when ch in ?0..?9 do
    {whole_number, new_rest} = read_number(rest, [to_string([ch])], false)
    {value, _} = Float.parse(whole_number)

    scan(new_rest, [{"NUMBER", whole_number, value} | tokens], errors, row_index)
  end

  def scan(<<ch::utf8>> <> rest, tokens, errors, row_index) do
    error = "[line #{row_index}] Error: Unexpected character: #{to_string([ch])}"

    scan(
      rest,
      tokens,
      [error | errors],
      row_index
    )
  end

  defp read_number("." <> rest, acc, false) do
    read_number(rest, ["." | acc], true)
  end

  defp read_number("", acc, false) do
    {acc |> Enum.reverse() |> Enum.join(""), ""}
  end

  defp read_number(<<ch::utf8>> <> rest, acc, false) when ch not in ?0..?9 do
    {acc |> Enum.reverse() |> Enum.join(""), to_string([ch]) <> rest}
  end

  defp read_number(<<ch::utf8>> <> rest, acc, true) when ch not in ?0..?9 do
    {["0" | acc] |> Enum.reverse() |> Enum.join(""), to_string([ch]) <> rest}
  end

  defp read_number(<<ch::utf8>> <> rest, acc, false) when ch in ?0..?9 do
    read_number(rest, [to_string([ch]) | acc], false)
  end

  defp read_number(<<ch::utf8>> <> rest, acc, true) when ch in ?0..?9 do
    read_number(rest, [to_string([ch]) | acc], false)
  end

  @spec print_token(token :: token()) :: binary()
  def print_token({name, sign, value}) do
    value = if(value == nil, do: "null", else: value)
    [name, sign, value] |> Enum.join(" ")
  end
end
