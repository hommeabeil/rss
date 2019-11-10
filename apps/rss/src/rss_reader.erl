-module(rss_reader).
-export([read/1]).
-include_lib("xmerl/include/xmerl.hrl").

-type rss_new() :: #{title := binary(),
                 description := binary()}.
-type rss_news() :: [rss_new()].

-export_type([rss_news/0, rss_new/0]).

-spec read(binary() | string()) -> {ok, rss_news()}.
read(Content) when is_binary(Content) ->
    read(binary_to_list(Content));
read(Content) ->
    {Xml, _} = xmerl_scan:string(Content),
    Res = xmerl_xpath:string("/rss/channel/item", Xml),
    Items = lists:map(fun read_item/1, Res),
    {ok, Items}.

read_item(Item) ->
    Keys = [title, description],
    Xpaths = ["/item/title", "/item/description"],
    F = fun(Kp, Map) -> read_an_item(Item, Kp, Map) end,
    lists:foldl(F, #{}, lists:zip(Keys, Xpaths)).

read_an_item(Item, {K, P}, Map) ->
    case xmerl_xpath:string(P, Item) of
        [] ->
            Map;
        [V] ->
            [Content] = V#xmlElement.content,
            Map#{K => Content#xmlText.value}
    end.
