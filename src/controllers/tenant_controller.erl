-module(tenant_controller).
-behavior(cowboy_handler).

-export([init/2]).

init(Req0, State) ->
    Method = cowboy_req:method(Req0),
    Req = application(Method, Req0),
    {ok, Req, State}.


application(<<"POST">>, Req) ->
    tenant_delegate:create_tenant(Req);

application(_, Req) ->
    %% Method not allowed.
    Body = jsone:encode(#{error => <<"method not allowed">>}),
    cowboy_req:reply(405, #{<<"content-type">> => <<"application/json">>}, Body, Req).