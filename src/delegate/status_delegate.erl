-module(status_delegate).
-export([create_status/1]).

create_status(Req) ->
    case cowboy_req:has_body(Req) of
        true -> 
            case jwt_util:validate_token(Req) of
                {error, Reason} ->
                    Body = jsone:encode(#{error => Reason}),
                    cowboy_req:reply(403, #{<<"content-type">> => <<"application/json">>}, Body, Req);
                {ok, Claims} ->
                    io:format("Creating status for user: ~p~n", [maps:get(<<"sub">>, Claims)]),
                    Length = cowboy_req:body_length(Req),
                    {ok, Data, _} = cowboy_req:read_body(Req, #{length => Length}),
                    %% Use try_decode which returns {ok, Value, Remainings} or {error, {Reason, Stack}}
                    case status_service:create_status(Data, maps:get(<<"sub">>, Claims)) of
                        {error, Reason} ->
                            Body = jsone:encode(#{error => Reason}),
                            cowboy_req:reply(400, #{<<"content-type">> => <<"application/json">>}, Body, Req);
                        {ok, _StatusId} ->
                            cowboy_req:reply(204, Req)
                    end  
            end;
        false ->
            Body = jsone:encode(#{error => <<"missing request body">>}),
            cowboy_req:reply(400, #{<<"content-type">> => <<"application/json">>}, Body,Req)
    end.
    