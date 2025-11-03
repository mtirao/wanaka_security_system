-module(profile_delegate).
-export([get_profile/1, create_profile/1]).


get_profile(Req) ->
    case jwt_util:validate_token(Req) of
        {error, Reason} ->
            Body = jsone:encode(#{error => Reason}),
            cowboy_req:reply(403, #{<<"content-type">> => <<"application/json">>}, Body, Req);
        {ok, Claims} ->
            UserId = maps:get(<<"sub">>, Claims),
            case profile_service:get_profile(UserId) of
                {error, Reason} ->
                    Body = jsone:encode(#{error => Reason}),
                    cowboy_req:reply(404, #{<<"content-type">> => <<"application/json">>}, Body, Req);
                {ok, Profile} ->
                    Body = jsone:encode(Profile),
                    cowboy_req:reply(200, #{<<"content-type">> => <<"application/json">>}, Body, Req)
            end
    end.

create_profile(Req) ->
    case cowboy_req:has_body(Req) of
        true -> 
            case jwt_util:validate_token(Req) of
                {error, Reason} ->
                    Body = jsone:encode(#{error => Reason}),
                    cowboy_req:reply(403, #{<<"content-type">> => <<"application/json">>}, Body, Req);
                {ok, Claims} ->
                    io:format("Creating profile for user: ~p~n", [maps:get(<<"sub">>, Claims)]),
                    Length = cowboy_req:body_length(Req),
                    {ok, Data, _} = cowboy_req:read_body(Req, #{length => Length}),
                    %% Use try_decode which returns {ok, Value, Remainings} or {error, {Reason, Stack}}
                    case profile_service:create_profile(Data, maps:get(<<"sub">>, Claims)) of
                        {error, Reason} ->
                            Body = jsone:encode(#{error => Reason}),
                            cowboy_req:reply(400, #{<<"content-type">> => <<"application/json">>}, Body, Req);
                        {ok, _UserId} ->
                            cowboy_req:reply(204, Req)
                    end
            end;
        false ->
            Body = jsone:encode(#{error => <<"missing request body">>}),
            cowboy_req:reply(400, #{<<"content-type">> => <<"application/json">>}, Body, Req)
    end.