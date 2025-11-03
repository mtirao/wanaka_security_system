-module(message_repository).
-export([insert_message/5, read_message/1, delete_message/1]).
-include("../models/db_schema.hrl").

%% Insert a new message with auto-generated UUID
insert_message(Id, Date, Type, Content, User) ->
    mnesia:transaction(fun() ->
        mnesia:write(#message{
            id = Id,
            date = Date,
            type = Type,
            content = Content,
            user = User
        })
    end).

%% Read a message by Id
read_message(Id) ->
    mnesia:transaction(fun() ->
        mnesia:read(message, Id)
    end).

%% Delete a message by Id
delete_message(Id) ->
    mnesia:transaction(fun() ->
        mnesia:delete({message, Id})
    end).
