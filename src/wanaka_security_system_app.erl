%%%-------------------------------------------------------------------
%% @doc wanaka_security_system public API
%% @end
%%%-------------------------------------------------------------------

-module(wanaka_security_system_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    application:start(sasl),
    application:start(crypto),
    application:start(uuid),
    
    %% Initialize Mnesia before web server
    mnesia_init:init(),
    mnesia_init:wait_for_tables(),
    
    application:start(cowlib),
    application:start(ranch),
    application:start(cowboy),
    Dispatch = cowboy_router:compile([
		{'_', [ {"/api/wanaka/accounts/login", auth_controller, []},
                {"/api/wanaka/activity", activity_controller, []},
                {"/api/wanaka/message", message_controller, []},
                {"/api/wanaka/profile", profile_controller, []},
                {"/api/wanaka/status", status_controller, []},
                {"/api/wanaka/accounts/tenant", tenant_controller, []}  ] }  
    ]),
    {ok, _} = cowboy:start_clear(my_http_listener,
        [{port, 8081}],
        #{env => #{dispatch => Dispatch}}
	),
    wanaka_security_system_sup:start_link().

stop(_State) ->
    ok.

%% internal functions
