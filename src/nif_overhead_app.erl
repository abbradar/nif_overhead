%%%-------------------------------------------------------------------
%% @doc nif_overhead public API
%% @end
%%%-------------------------------------------------------------------

-module(nif_overhead_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    nif_overhead_sup:start_link().

stop(_State) ->
    ok.

%% internal functions
