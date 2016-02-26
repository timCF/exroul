defmodule ExroulTest.Macro do
	defmacro __using__([]) do
		balls = Enum.map(1..36, fn(n) -> [value: n, color: (case rem(n,2) do ; 0 -> :red ; 1 -> :black ; end)] end)
		quote location: :keep do
			use Exroul, [balls: unquote(balls), zeros: [0], combos: [1,2,3,4,6]]
		end
	end
end

defmodule ExroulTest do
	use ExUnit.Case
	doctest Exroul
	use ExroulTest.Macro

	test "the truth" do
		assert 1 + 1 == 2
	end
end
