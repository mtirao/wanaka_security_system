-module(message_controller).
-behavior(cowboy_handler).

-export([init/2]).

init(Req0, State) ->
    Method = cowboy_req:method(Req0),
    Req = application(Method, Req0),
    {ok, Req, State}.


application(<<"POST">>, Req) ->
    message_delegate:create_message(Req);


application(_, Req) ->
    %% Method not allowed.
    cowboy_req:reply(405, Req).