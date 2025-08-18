defmodule Scanner do
  @type token :: {name :: String.t(), sign :: String.t(), nil}

  @spec scan(contents :: String.t()) :: [token()]
  def scan(contents), do: scan(contents, [])

  @spec scan(contents :: String.t(), tokens :: [token()]) :: [token()]
  def scan("(" <> rest, tokens) do
    scan(rest, [{"LEFT_PAREN", "(", nil} | tokens])
  end

  def scan(")" <> rest, tokens) do
    scan(rest, [{"RIGHT_PAREN", ")", nil} | tokens])
  end

  def scan("{" <> rest, tokens) do
    scan(rest, [{"LEFT_BRACE", "{", nil} | tokens])
  end

  def scan("}" <> rest, tokens) do
    scan(rest, [{"RIGHT_BRACE", "}", nil} | tokens])
  end

  def scan("*" <> rest, tokens) do
    scan(rest, [{"STAR", "*", nil} | tokens])
  end

  def scan("." <> rest, tokens) do
    scan(rest, [{"DOT", ".", nil} | tokens])
  end

  def scan("," <> rest, tokens) do
    scan(rest, [{"COMMA", ",", nil} | tokens])
  end

  def scan("+" <> rest, tokens) do
    scan(rest, [{"PLUS", "+", nil} | tokens])
  end

  def scan("-" <> rest, tokens) do
    scan(rest, [{"MINUS", "-", nil} | tokens])
  end

  def scan(";" <> rest, tokens) do
    scan(rest, [{"SEMICOLON", ";", nil} | tokens])
  end

  def scan("/" <> rest, tokens) do
    scan(rest, [{"SLASH", "/", nil} | tokens])
  end

  def scan("\n" <> rest, tokens) do
    scan(rest, tokens)
  end

  def scan("", tokens) do
    Enum.reverse([{"EOF", "", nil} | tokens])
  end

  @spec print_token(token :: token()) :: binary()
  def print_token({name, sign, _}) do
    [name, sign, "null"] |> Enum.join(" ")
  end
end
