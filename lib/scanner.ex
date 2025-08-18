defmodule Scanner do
  @type token :: {name :: String.t(), sign :: String.t(), nil}
  @type scanner_error :: String.t()

  @spec scan(contents :: String.t()) :: {[token()], [scanner_error()]}
  def scan(contents), do: scan(contents, [], [])

  @spec scan(contents :: String.t(), tokens :: [token()], errors :: [scanner_error()]) ::
          {[token()], [scanner_error()]}
  def scan("(" <> rest, tokens, errors) do
    scan(rest, [{"LEFT_PAREN", "(", nil} | tokens], errors)
  end

  def scan(")" <> rest, tokens, errors) do
    scan(rest, [{"RIGHT_PAREN", ")", nil} | tokens], errors)
  end

  def scan("{" <> rest, tokens, errors) do
    scan(rest, [{"LEFT_BRACE", "{", nil} | tokens], errors)
  end

  def scan("}" <> rest, tokens, errors) do
    scan(rest, [{"RIGHT_BRACE", "}", nil} | tokens], errors)
  end

  def scan("*" <> rest, tokens, errors) do
    scan(rest, [{"STAR", "*", nil} | tokens], errors)
  end

  def scan("." <> rest, tokens, errors) do
    scan(rest, [{"DOT", ".", nil} | tokens], errors)
  end

  def scan("," <> rest, tokens, errors) do
    scan(rest, [{"COMMA", ",", nil} | tokens], errors)
  end

  def scan("+" <> rest, tokens, errors) do
    scan(rest, [{"PLUS", "+", nil} | tokens], errors)
  end

  def scan("-" <> rest, tokens, errors) do
    scan(rest, [{"MINUS", "-", nil} | tokens], errors)
  end

  def scan(";" <> rest, tokens, errors) do
    scan(rest, [{"SEMICOLON", ";", nil} | tokens], errors)
  end

  def scan("/" <> rest, tokens, errors) do
    scan(rest, [{"SLASH", "/", nil} | tokens], errors)
  end

  def scan("\n" <> rest, tokens, errors) do
    scan(rest, tokens, errors)
  end

  def scan(<<ch::utf8>> <> rest, tokens, errors) do
    scan(rest, tokens, ["[line 1] Error: Unexpected character: #{to_string([ch])}" | errors])
  end

  def scan("", tokens, errors) do
    {Enum.reverse([{"EOF", "", nil} | tokens]), Enum.reverse(errors)}
  end

  @spec print_token(token :: token()) :: binary()
  def print_token({name, sign, _}) do
    [name, sign, "null"] |> Enum.join(" ")
  end
end
