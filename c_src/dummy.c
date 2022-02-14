#include <erl_nif.h>

struct my_priv
{
    ERL_NIF_TERM atom_ok;
};

static ERL_NIF_TERM dummy(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
    struct my_priv* priv = enif_priv_data(env);
    return priv->atom_ok;
}

static int load(ErlNifEnv* env, void** priv_data, ERL_NIF_TERM load_info)
{
    struct my_priv* priv = enif_alloc(sizeof(struct my_priv));
    priv->atom_ok = enif_make_atom(env, "ok");

    *priv_data = priv;

    return 0;
}

static int upgrade(ErlNifEnv* env, void** priv_data, void** old_priv_data, ERL_NIF_TERM load_info)
{
    return load(env, priv_data, load_info);
}

static void unload(ErlNifEnv* env, void* priv_data)
{
    enif_free(enif_priv_data(env));
}

static ErlNifFunc nif_funcs[] =
{
    {"dummy", 0, dummy}
};

ERL_NIF_INIT(dummy_lib, nif_funcs, load, NULL, upgrade, unload)
