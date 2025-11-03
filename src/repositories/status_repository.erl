-module(status_repository).
-export([insert_status/4, read_status/1, delete_status/1]).
-include("../models/db_schema.hrl").

%% Insert a new status with auto-generated UUID
insert_status(Id, Date, Status, User) ->
    mnesia:transaction(fun() ->
        mnesia:write(#status{
            id = Id,
            date = Date,
            status = Status,
            user = User
        })
    end).

%% Read a status by Id
read_status(Id) ->
    mnesia:transaction(fun() ->
        mnesia:read(status, Id)
    end).

%% Delete a status by Id
delete_status(Id) ->
    mnesia:transaction(fun() ->
        mnesia:delete({status, Id})
    end).
