defmodule Scanner do
  @type token :: {name :: String.t(), sign :: String.t()}

  def scan(contents), do: scan(contents, [])

  def scan("(" <> rest, tokens) do
    scan(rest, [{"LEFT_PAREN", "("} | tokens])
  end

  def scan(")" <> rest, tokens) do
    scan(rest, [{"RIGHT_PAREN", ")"} | tokens])
  end

  def scan("{" <> rest, tokens) do
    scan(rest, [{"LEFT_BRACE", "}"} | tokens])
  end

  def scan("}" <> rest, tokens) do
    scan(rest, [{"RIGHT_BRACE", "}"} | tokens])
  end

  def scan("\n" <> rest, tokens) do
    scan(rest, tokens)
  end

  def scan("", tokens) do
    Enum.reverse([{"EOF", ""} | tokens])
  end

  @spec print_token(token :: token()) :: binary()
  def print_token({name, sign}) do
    [name, sign, "null"] |> Enum.join(" ")
  end
end
