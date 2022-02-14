-module(dummy_lib).
-export([dummy/0]).
-on_load(init/0).

init() ->
    Priv = code:priv_dir(nif_overhead),
    Nif = filename:absname_join(Priv, "dummy_lib"),
    ok = erlang:load_nif(Nif, 0).

dummy() ->
    exit(nif_library_not_loaded).
