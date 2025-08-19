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

  def scan(<<ch::utf8>> <> rest, tokens, errors, row_index) do
    error = "[line #{row_index}] Error: Unexpected character: #{to_string([ch])}"

    scan(
      rest,
      tokens,
      [error | errors],
      row_index
    )
  end

  @spec print_token(token :: token()) :: binary()
  def print_token({name, sign, _}) do
    [name, sign, "null"] |> Enum.join(" ")
  end
end
