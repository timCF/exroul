defmodule ExroulTest.Macro do
	defmacro __using__([]) do
		balls = Enum.map(1..36, fn(n) ->
			[
				value: n,
				is_odd: (case rem(n,2) do ; 0 -> :odd ; 1 -> :even ; end),
				color: (case (n in [1,3,5,7,9,12,14,16,18,19,21,23,25,27,30,32,34,36]) do ; true -> :red ; false -> :black ; end)
			]
		end)
		quote location: :keep do
			use Exroul, [balls: unquote(balls), zeros: [0], combos: [1,2,3,4,6], debug: true]
		end
	end
end

defmodule ExroulTest do
	use ExUnit.Case
	doctest Exroul
	use ExroulTest.Macro

	test "the truth" do
		assert Enum.sort([{:black, 2}, {:even, 2}, {:odd, 2}, {:red, 2}, {1, 36}, {2, 18}, {3, 12}, {4, 9}, {6, 6}]) == list_odds
		assert Enum.sort([:odd, :even, :red, :black]) == list_props
		assert Enum.sort(0..36) == list_vals
		assert Enum.all?(0..36, &(win(&1,[&1]) == 36))
	end
end
