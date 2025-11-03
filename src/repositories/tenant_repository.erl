-module(tenant_repository).
-export([insert_tenant/3, read_tenant/1, delete_tenant/1]).
-include("../models/db_schema.hrl").

%% Insert a new token
insert_tenant(Id, Passwd, User) ->
    mnesia:transaction(fun() ->
        mnesia:write(#tenant{
            user = User,
            password = Passwd,
            created = erlang:system_time(seconds),
            status = active,    
            id = Id
        })
    end).

%% Read a token by Token value
read_tenant(User) ->
    mnesia:transaction(fun() ->
        mnesia:read(tenant, User)
    end).

%% Delete a token by Token value
delete_tenant(User) ->
    mnesia:transaction(fun() ->
        mnesia:delete({tenant, User})
    end).
