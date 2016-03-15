defmodule Exroul do
	use Application

	# See http://elixir-lang.org/docs/stable/elixir/Application.html
	# for more information on OTP Applications
	def start(_type, _args) do
		import Supervisor.Spec, warn: false

		children = [
		# Define workers and child supervisors to be supervised
		# worker(Exroul.Worker, [arg1, arg2, arg3]),
		]

		# See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
		# for other strategies and supported options
		opts = [strategy: :one_for_one, name: Exroul.Supervisor]
		Supervisor.start_link(children, opts)
	end


	#
	#	balls - dicts mandatory unique field : value (int)
	#	zeros - unique ints
	#


	defp make_combos_win(combos_odds, values) do
		Enum.reduce(combos_odds, nil, fn
			{len, odd}, nil ->
				make_combos_win_process(len, odd, values)
			{len, odd}, acc ->
				quote location: :keep do
					unquote(acc)
					unquote(make_combos_win_process(len, odd, values))
				end
		end)
	end
	defp make_combos_win_process(len, odd, values) do
		quote location: :keep do
			def win(n, bet = [_|_]) when ((length(bet) == unquote(len)) and (n in unquote(values))) do
				case Enum.member?(bet, n) do
					true -> unquote(odd)
					false -> 0
				end
			end
		end
	end


	defp make_props_win(balls, prop_keys, props_odds) do
		Enum.reduce(prop_keys, nil, fn(key, acc) ->
			Enum.group_by(balls, &(&1[key]))
			|> Enum.reduce(acc, fn
				{prop_val, balls}, nil -> make_props_win_process(prop_val, balls, props_odds)
				{prop_val, balls}, acc ->
					quote location: :keep do
						unquote(acc)
						unquote(make_props_win_process(prop_val, balls, props_odds))
					end
			end)
		end)
	end
	defp make_props_win_process(prop_val, balls, props_odds) do
		quote location: :keep do
			def win(n, unquote(prop_val)) when (n in unquote(Enum.map(balls, &(&1[:value])))), do: unquote(Map.get(props_odds, prop_val))
		end
	end


	defp check_prop_uniq(other_props, this_prop, balls) do
		other_vals = Enum.flat_map(balls, fn(this_ball) -> Enum.map(other_props, &(this_ball[&1])) end)
		Enum.all?(balls, &(not(Enum.member?(other_vals,&1[this_prop]))))
	end


	defmacro __using__([balls: balls = [_|_], zeros: zeros = [_|_], combos: combos = [_|_], debug: debug]) do
		prop_keys = List.first(balls) |> Dict.keys |> Stream.filter(&(&1 != :value)) |> Enum.sort
		prop_vals = Stream.flat_map(balls, fn(ball) -> Enum.map(prop_keys, &(ball[&1])) end) |> Enum.uniq
		values = Enum.map(balls, &(&1[:value]))++zeros
		true = Enum.all?(balls, fn(ball) -> prop_keys == (ball |> Dict.keys |> Stream.filter(&(&1 != :value)) |> Enum.sort) end)
		true = Enum.all?(values, &is_integer/1)
		true = (length(balls++zeros) == (values |> Enum.uniq |> length))
		base_odd = length(balls)
		true = Enum.all?(combos, &(is_integer(&1) and (&1 > 0) and (&1 < base_odd)))
		true = Enum.all?(prop_keys, fn(prop) -> Enum.filter(prop_keys, &(&1 != prop)) |> check_prop_uniq(prop, balls) end)
		combos_odds = Enum.reduce(combos, %{}, fn(n, acc) ->
			raw = base_odd / n
			res = round(raw)
			true = ((raw == res) and is_integer(res) and (res > 1))
			Map.put(acc, n, res)
		end)
		props_odds = Enum.reduce(prop_keys, %{}, fn(prop_key, acc) ->
			Enum.group_by(balls, &(&1[prop_key]))
			|> Enum.reduce(acc, fn({prop_val, balls = [_|_]}, acc) ->
				this_odd = base_odd / length(balls)
				case round(this_odd) do
					odd when (is_integer(odd) and (odd > 1) and (odd == this_odd)) -> Map.put(acc, prop_val, odd)
					_ -> raise("got wrong odd #{inspect this_odd}")
				end
			end)
		end)
		res = quote location: :keep do
			def valid?(subj) when (subj in unquote(prop_vals)), do: true
			def valid?(subj = [_|_]) do
				Enum.all?(subj, &(&1 in unquote(values)))
				and
				(length(subj) == (subj |> Enum.uniq |> length))
				and
				(length(subj) in unquote(combos))
			end
			def valid?(_), do: false
			unquote(make_combos_win(combos_odds, values))
			unquote(make_props_win(balls, prop_keys, props_odds))
			def win(n, bet) when ((n in unquote(values)) and (bet in unquote(prop_vals))), do: 0
		end
		if (debug), do: (Macro.to_string(res) |> IO.puts)
		res
	end

end
