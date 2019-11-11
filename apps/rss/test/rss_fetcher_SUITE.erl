-module(rss_fetcher_SUITE).
-include_lib("common_test/include/ct.hrl").
-include_lib("eunit/include/eunit.hrl").

-compile(nowarn_export_all).
-compile(export_all).

-define(AN_URL, <<"https://host.com/some/rss">>).
-define(OUT_DIR, <<"a/b/c">>).
-define(TIMEOUT, 1000).

all() ->
    [basic_fetch].

init_per_testcase(_, Config) ->
    meck:new(hackney),
    Config.

end_per_testcase(_, Config) ->
    meck:unload(),
    Config.

basic_fetch(Config) ->
    Ref = make_ref(),
    Data = filename:join([?config(data_dir, Config), "valid_rss.xml"]),
    {ok, B} = file:read_file(Data),
    meck:expect(hackney, request, fun(get, _) -> {ok, 200, Ref} end),
    meck:expect(hackney, body, fun(R) when R =:= Ref -> {ok, B} end),

    {ok, Pid} = rss_fetcher:start_link(?AN_URL, ?OUT_DIR),

    meck:wait(hackney, request, '_', ?TIMEOUT),

    gen_server:stop(Pid).
