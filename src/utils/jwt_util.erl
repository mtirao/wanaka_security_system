-module(jwt_util).  
-export([validate_token/1]).

validate_token(Req) ->
    AuthHeader = cowboy_req:parse_header(<<"authorization">>, Req),
    case AuthHeader of
        undefined ->
            {error, <<"missing authorization header">>};
        {bearer, Token} ->
            case jwt_service:verify_token(Token) of
                {ok, Claims} ->
                    {ok, Claims};
                {error, Reason} ->
                    {error, Reason}
            end;
        _Other ->
            {error, <<"unsupported authorization scheme">>}
    end.