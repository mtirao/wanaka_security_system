-module(profile_controller).
-behavior(cowboy_handler).
-export([init/2]).


init(Req0, State) ->
    Method = cowboy_req:method(Req0),
    Req = application(Method, Req0),
    {ok, Req, State}.

application(<<"GET">>, Req) ->
    profile_delegate:get_profile(Req);

application(<<"POST">>, Req) ->
    profile_delegate:create_profile(Req);

application(_, Req) ->
    %% Method not allowed.
    cowboy_req:reply(405, Req).

