-module(rss_feed).

-behavior(gen_server).

-export([init/1,
         handle_cast/2,
         handle_info/2,
         handle_call/3]).

-export([start_link/1,
         append/1,
         get/1]).

-record(state, {tid :: ets:tid()}).

-type feed_entry() :: #{new := rss_reader:new(),
                        pos := non_neg_integer()}.

-export_type([feed_entry/0]).

%%====================================================================
%% Public API
%%====================================================================

-spec start_link(atom()) -> {ok, pid()} | {error, term()} | ignore.
start_link(Name) ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [Name], []).

-spec append(rss_reader:rss_new()) -> ok | {error, term()}.
append(New) ->
    gen_server:call(?MODULE, {append, New}).

-spec get(first | last) -> {ok, rss_reader:rss_new()} | {error, term()}.
get(Ref) ->
    gen_server:call(?MODULE, {get, Ref}).


%%====================================================================
%% gen_server handle
%%====================================================================

init([Name]) ->
    Tid = ets:new(Name, []),
    ets:insert(Tid, {count, 0}),
    {ok, #state{tid = Tid}}.

handle_info(_Info, State) ->
    {noreply, State}.

handle_call({append, New}, _From, #state{tid = Tid}=State) ->
    Current = ets:lookup_element(Tid, count, 2),
    true = ets:insert(State#state.tid, {Current, New}),
    ets:update_counter(Tid, count, 1),
    {reply, ok, State};
handle_call({get, first}, _From, State) ->
    [{_, New}] = ets:lookup(State#state.tid, 0),
    FeedEntry = #{new => New, pos => 0},
    {reply, {ok, FeedEntry}, State};
handle_call({get, last}, _From, #state{tid = Tid}=State) ->
    Current = ets:lookup_element(Tid, count, 2),
    [{_, New}] = ets:lookup(State#state.tid, Current - 1),
    FeedEntry = #{new => New, pos => Current - 1},
    {reply,  {ok, FeedEntry}, State};
handle_call(_Request, _From, State) ->
    {noreply, State}.

handle_cast(_Request, State) ->
    {noreply, State}.
