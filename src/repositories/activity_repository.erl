-module(activity_repository).
-export([insert_activity/4, read_activity/1, delete_activity/1]).
-include("../models/db_schema.hrl").

%% Insert a new activity with auto-generated UUID
insert_activity(Id, Date, Activity, User) ->
    mnesia:transaction(fun() ->
        mnesia:write(#activity{
            id = Id,
            date = Date,
            activity = Activity,
            user = User
        })
    end).

%% Read an activity by Id
read_activity(Id) ->
    mnesia:transaction(fun() ->
        mnesia:read(activity, Id)
    end).

%% Delete an activity by Id
delete_activity(Id) ->
    mnesia:transaction(fun() ->
        mnesia:delete({activity, Id})
    end).
