defmodule Tokenizer do
  def tokenize(chars) do
    chars
    |> Enum.reduce([], fn
      "(", acc -> ["LEFT_PAREN ( null" | acc]
      ")", acc -> ["RIGHT_PAREN ) null" | acc]
      _, acc -> acc
    end)
  end
end
