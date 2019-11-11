-module(rss_feed_SUITE).
-include_lib("common_test/include/ct.hrl").
-include_lib("eunit/include/eunit.hrl").
-compile(nowarn_export_all).
-compile(export_all).

-define(A_NAME, a_name).
-define(A_STORY, #{title => <<"hello">>}).
-define(AN_OTHER_STORY, #{title => <<"you">>}).

all() ->
    [given_no_new_then_can_append,
     one_new,
     one_new_last,
     multiple_news_get_first,
     multiple_news_get_last].

init_per_testcase(_, Config) ->
    {ok, _} = rss_feed:start_link(?A_NAME),
    Config.

end_per_testcase(_, Config) ->
    Config.

given_no_new_then_can_append() ->
    [{doc, "Given no new, when apppend a new, then return ok."}].
given_no_new_then_can_append(_Config) ->
    ?assertEqual(ok, rss_feed:append(?A_STORY)).

one_new() ->
    [{doc, "Given one new appended, when request the first, then return it."}].
one_new(_Config) ->
    ok = rss_feed:append(?A_STORY),

    {ok, #{new := S}} = rss_feed:get(first),

    ?assertEqual(?A_STORY, S).

one_new_last() ->
    [{doc, "Given one new appended, when get the last new, then return it."}].
one_new_last(_Config) ->
    ok = rss_feed:append(?A_STORY),

    {ok, #{new := S}} = rss_feed:get(last),

    ?assertEqual(?A_STORY, S).

multiple_news_get_first() ->
    [{doc, "Given multiples news, when get the fist, then return it."}].
multiple_news_get_first(_Config) ->
    ok = rss_feed:append(?A_STORY),
    ok = rss_feed:append(?AN_OTHER_STORY),

    {ok, #{new := S}} = rss_feed:get(first),

    ?assertEqual(?A_STORY, S).

multiple_news_get_last() ->
    [{doc, "Given multiples news, when get the fist, then return it."}].
multiple_news_get_last(_Config) ->
    ok = rss_feed:append(?A_STORY),
    ok = rss_feed:append(?AN_OTHER_STORY),

    {ok, #{new := S}} = rss_feed:get(last),

    ?assertEqual(?AN_OTHER_STORY, S).
