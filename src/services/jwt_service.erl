 -module(jwt_service).
 -export([generate_token/1, verify_token/1]).

%% NOTE:
%% Uses the jose library. For HMAC (HS256) we create a symmetric JWK
%% and call jose_jwt:sign/3, then compact with jose_jws:compact/1.

generate_token(User) ->
    Claims = #{<<"sub">> => User, <<"exp">> => os:system_time(seconds) + 3600},
    %% Secret should come from configuration in a real app. Keep as a binary here.
    Secret = <<"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9">>,
    %% Build JWK for an octet (symmetric) key using base64url encoding
    JWK = #{<<"kty">> => <<"oct">>, <<"k">> => jose_base64url:encode(Secret)},
    JWS = #{<<"alg">> => <<"HS256">>},
    Signed = jose_jwt:sign(JWK, JWS, Claims),
    jose_jws:compact(Signed).

verify_token(Token) ->
    Secret = <<"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9">>,
    JWK = #{<<"kty">> => <<"oct">>, <<"k">> => jose_base64url:encode(Secret)},
    case jose_jwt:verify(JWK, Token) of
        {true, {jose_jwt, Fields}, _JWS} ->
            {ok, Fields};
        {false, Reason} ->
            {error, Reason};
        {error, Reason} ->
            {error, Reason}
    end.
