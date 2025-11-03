-module(token_repository).
-export([insert_token/2, read_token/1, delete_token/1]).
-include("../models/db_schema.hrl").

%% Insert a new token
insert_token(Token, User) ->
    mnesia:transaction(fun() ->
        mnesia:write(#token{
            token = Token,
            user = User
        })
    end).

%% Read a token by Token value
read_token(Token) ->
    mnesia:transaction(fun() ->
        mnesia:read(token, Token)
    end).

%% Delete a token by Token value
delete_token(Token) ->
    mnesia:transaction(fun() ->
        mnesia:delete({token, Token})
    end).
