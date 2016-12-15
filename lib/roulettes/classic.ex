
########################
### classic roulette ###
########################

defmodule Exroul.Roulettes.Classic.MacroWrapper do

  @full 36
  @half round(@full / 2)

  @col1 ((1..@full) |> Enum.filter(&(rem(&1,3) == 1)))
  @col2 Enum.map(@col1, fn(x)-> x+1 end)
  @col3 Enum.map(@col1, fn(x)-> x+2 end)

  @row1 1..12
  @row2 13..24
  @row3 25..36

  defp is_odd(n) when (rem(n,2) == 0), do: :even
  defp is_odd(n) when (rem(n,2) == 1), do: :odd

  defp color(n) when (n in [1,3,5,7,9,12,14,16,18,19,21,23,25,27,30,32,34,36]), do: :red
  defp color(n) when (n in 1..@full), do: :black

  defp big(n) when (n <= @half), do: :small
  defp big(n) when ((n > @half) and (n <= @full)), do: :big

  defp col(n) when (n in @col1), do: :col1
  defp col(n) when (n in @col2), do: :col2
  defp col(n) when (n in @col3), do: :col3

  defp row(n) when (n in @row1), do: :row1
  defp row(n) when (n in @row2), do: :row2
  defp row(n) when (n in @row3), do: :row3

  defmacro __using__(_) do
    quote location: :keep do
      use Exroul, [
        balls: unquote(Enum.map(1..@full, &([value: &1, is_odd: is_odd(&1), color: color(&1), big: big(&1), col: col(&1), row: row(&1)]))),
        zeros: [0],
        combos: [1,2,3,4,6],
        debug: false
      ]
    end
  end
end

defmodule Exroul.Roulettes.Classic do
  use Exroul.Roulettes.Classic.MacroWrapper
end
