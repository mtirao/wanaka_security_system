-module(tenant_delegate).
-export([create_tenant/1]).


create_tenant(Req) -> 
    %% Read Authorization header (expecting Basic <base64(user:pass)>)
    Auth = cowboy_req:parse_header(<<"authorization">>, Req),
    case Auth of
        undefined ->
            Body = jsone:encode(#{error => <<"missing authorization header">>}),
            cowboy_req:reply(401, #{<<"content-type">> => <<"application/json">>}, Body, Req);

        {basic, UserBin, PassBin} ->
            case auth_service:authenticate_user(UserBin, PassBin) of
                {ok, authenticated} ->
                    create_tenant_util(Req);
                {error, Reason} ->
                    Body = jsone:encode(#{error => Reason}),
                    cowboy_req:reply(403, #{<<"content-type">> => <<"application/json">>}, Body, Req)
            end; 
        _ ->
            Body = jsone:encode(#{error => <<"invalid authorization header">>}),
            cowboy_req:reply(401, #{<<"content-type">> => <<"application/json">>}, Body, Req)                          
    end.

create_tenant_util(Req) ->
    case cowboy_req:has_body(Req) of
        true -> 
            Length = cowboy_req:body_length(Req),
            {ok, Data, _} = cowboy_req:read_body(Req, #{length => Length}),
            #{<<"user">> := Username, <<"password">> := Password} = jsone:decode(Data),
            {ok, _TenantId} = tenant_service:create_tenant(Password, Username),
            cowboy_req:reply(204, Req);
        false ->
            Body = jsone:encode(#{error => <<"missing request body">>}),
            cowboy_req:reply(400, #{<<"content-type">> => <<"application/json">>}, Body, Req)
    end.