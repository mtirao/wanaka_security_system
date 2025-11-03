-module(auth_delegate).
-export([login/1]).


login(Req) ->
    %% Read Authorization header (expecting Basic <base64(user:pass)>)
    Auth = cowboy_req:parse_header(<<"authorization">>, Req),
    case Auth of
        undefined ->
            Body = jsone:encode(#{error => <<"missing authorization header">>}),
            cowboy_req:reply(401, #{<<"content-type">> => <<"application/json">>}, Body, Req);
        {basic, UserBin, PassBin} ->
            case tenant_service:validate_tenant(UserBin, PassBin) of
                {error, Reason} ->
                    Body = jsone:encode(#{error => Reason}),
                    cowboy_req:reply(403, #{<<"content-type">> => <<"application/json">>}, Body, Req);
                {ok, Id} ->
                    {_, Token} = jwt_service:generate_token(Id),                         
                    Body = jsone:encode(#{accesstoken => Token, tokentype => <<"Bearer">>, refreshtoken => <<>>}),
                    cowboy_req:reply(200, #{<<"content-type">> => <<"application/json">>}, Body, Req)
            end;
        _ ->
            Body = jsone:encode(#{error => <<"invalid authorization header">>}),
            cowboy_req:reply(401, #{<<"content-type">> => <<"application/json">>}, Body, Req)
    end.