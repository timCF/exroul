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

	defmacro __using__([balls: balls = [_|_], zeros: zeros = [_|_]]) do
		prop_keys = List.first(balls) |> Dict.keys |> Enum.sort
		prop_vals = Stream.flat_map(balls, fn(ball) -> Enum.map(prop_keys, &(ball[&1])) end) |> Enum.uniq
		values = Enum.map(balls, &(&1[:value]))++zeros
		true = Enum.all?(balls, &(prop_keys == (&1 |> Dict.keys |> Enum.sort)))
		true = Enum.all?(values, &is_integer/1)
		true = (length(balls++zeros) == (values |> Enum.uniq |> length))
		base_odd = length(balls)
		properties_oddsmap = Enum.reduce(prop_keys, %{}, fn(prop, acc) ->
			#
			#	TODO
			#
		end)
		quote location: :keep do
			def valid?(subj) when (subj in unquote(prop_vals)), do: true
			def valid?(subj = [_|_]) do
				Enum.all?(subj, &(&1 in unquote(values)))
				and
				(length(subj) == (subj |> Enum.uniq |> length))
				and
				(length(subj) in [1,2,3,4,6])
			end
			def valid?(_), do: false
		end
	end

end
