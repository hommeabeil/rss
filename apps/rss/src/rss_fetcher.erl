-module(rss_fetcher).

-behavior(gen_server).

-export([init/1,
         handle_cast/2,
         handle_info/2,
         handle_call/3]).

-export([start_link/2]).


-type url() :: string() | binary().

-record(state, {url :: url(),
                output_dir :: file:filename_all(),
                timer :: reference()}).

-define(DEFAULT_TIMEOUT, 60000).


%%====================================================================
%% Public API
%%====================================================================

-spec start_link(url(), file:filename_all()) -> {ok, pid()} | {error, term()} | ignore.
start_link(Url, OutputDir) ->
    gen_server:start_link(?MODULE, [Url, OutputDir], []).


%%====================================================================
%% gen_server handle
%%====================================================================

init([Url, OutputDir]) ->
    Ref = erlang:start_timer(?DEFAULT_TIMEOUT, self(), fetch_now),
    {ok, #state{url = Url, output_dir = OutputDir, timer = Ref}}.

handle_info({timeout, Ref, fetch_now}, #state{timer=Ref}=State) ->
    {ok, 200, Ref} = hackney:request(get, State#state.url),
    hackney:stream_body(Ref),
    {noreply, State};
handle_info(_Info, State) ->
    {noreply, State}.

handle_call(_Request, _From, State) ->
    {noreply, State}.

handle_cast(_Request, State) ->
    {noreply, State}.
