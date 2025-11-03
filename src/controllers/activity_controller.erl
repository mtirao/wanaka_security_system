-module(activity_controller).
-behavior(cowboy_handler).

-export([init/2]).

init(Req0, State) ->
    Method = cowboy_req:method(Req0),
    Req = application(Method, Req0),
    {ok, Req, State}.


application(<<"POST">>, Req) ->
    activity_delegate:create_activity(Req); 

application(_, Req) ->
    %% Method not allowed.
    cowboy_req:reply(405, Req).