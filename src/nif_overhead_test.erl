-module(nif_overhead_test).
-behaviour(gen_server).

-export([start_link/0]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2]).

start_link() ->
    gen_server:start_link(nif_overhead_test, [], []).

init(_Args) ->
    % Warm up measuring function.
    measure(),
    % Give VM some time to settle.
    erlang:send_after(100, self(), run_test),
    {ok, []}.

measure() ->
    T1 = os:perf_counter(),
    dummy_lib:dummy(),
    T2 = os:perf_counter(),
    erlang:convert_time_unit(T2 - T1, perf_counter, nanosecond).

quantile(Sorted, Quantile) ->
    Len = length(Sorted),
    lists:nth(trunc((Len - 1) * Quantile) + 1, Sorted).

show_quantile(Name, Sorted, Quantile) ->
    Value = quantile(Sorted, Quantile),
    io:format("~.2f quantile for ~s: ~B~n", [Quantile, Name, Value]).

show_statistics(Name, Results) ->
    Sorted = lists:sort(Results),
    show_quantile(Name, Sorted, 0.01),
    show_quantile(Name, Sorted, 0.1),
    show_quantile(Name, Sorted, 0.5),
    show_quantile(Name, Sorted, 0.9),
    show_quantile(Name, Sorted, 0.99),
    io:format("~n").

handle_call(_Msg, _From, State) -> {noreply, State}.
handle_cast(_Msg, State) -> {noreply, State}.

handle_info({run_measurement, 0, Results}, State) ->
    Firsts = lists:map(fun({A, _, _}) -> A end, Results),
    show_statistics("first", Firsts),
    Seconds = lists:map(fun({_, B, _}) -> B end, Results),
    show_statistics("second", Seconds),
    Thirds = lists:map(fun({_, _, C}) -> C end, Results),
    show_statistics("third", Thirds),
    io:format("~n"),
    run_test(),
    {noreply, State};

handle_info({run_measurement, N, Results}, State) ->
    % erlang:garbage_collect(),
    D1 = measure(),
    D2 = measure(),
    D3 = measure(),
    erlang:send_after(1, self(), {run_measurement, N - 1, [{D1, D2, D3} | Results]}),
    % erlang:garbage_collect(),
    {noreply, State};

handle_info(run_test, State) ->
    run_test(),
    {noreply, State}.

run_test() ->
    io:format("~nStarting measurement~n"),
    self() ! {run_measurement, 10000, []},
    % erlang:garbage_collect(),
    ok.
