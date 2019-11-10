-module(rss_reader_SUITE).
-include_lib("common_test/include/ct.hrl").
-include_lib("eunit/include/eunit.hrl").

-compile(nowarn_export_all).
-compile(export_all).

all() ->
    [can_parse_valid_title,
     can_parse_valid_description].

init_per_testcase(_, Config) ->
    Config.

end_per_testcase(_, Config) ->
    Config.

can_parse_valid_title(Config) ->
    Data = filename:join([?config(data_dir, Config), "valid_rss.xml"]),
    {ok, B} = file:read_file(Data),
    {ok, Content} = rss_reader:read(B),
    ?assertMatch([#{title := _} | _], Content).

can_parse_valid_description(Config) ->
    Data = filename:join([?config(data_dir, Config), "valid_rss.xml"]),
    {ok, B} = file:read_file(Data),
    {ok, Content} = rss_reader:read(B),
    ?assertMatch([#{description := _} | _], Content).
