%%%-------------------------------------------------------------------
%% @doc Mnesia initialization and schema management
%% @end
%%%-------------------------------------------------------------------

-module(mnesia_init).

-export([init/0, wait_for_tables/0]).
-include("../models/db_schema.hrl").

%% Initialize Mnesia and create schema and tables
init() ->
    case mnesia:create_schema([node()]) of
        ok -> ok;
        {error, {_, {already_exists, _}}} -> ok;
        Error -> Error
    end,
    
    application:start(mnesia),
    
    %% Create tables based on records
    mnesia:create_table(activity,
        [{attributes, record_info(fields, activity)},
         {disc_copies, [node()]},
         {type, set}]),
         
    mnesia:create_table(message,
        [{attributes, record_info(fields, message)},
         {disc_copies, [node()]},
         {type, set}]),
         
    mnesia:create_table(profile,
        [{attributes, record_info(fields, profile)},
         {disc_copies, [node()]},
         {type, set}]),
         
    mnesia:create_table(status,
        [{attributes, record_info(fields, status)},
         {disc_copies, [node()]},
         {type, set}]),
         
    mnesia:create_table(tokens,
        [{attributes, record_info(fields, token)},
         {disc_copies, [node()]},
         {type, set}]),
    
    mnesia:create_table(tenant,
        [{attributes, record_info(fields, tenant)},
         {disc_copies, [node()]},
         {type, set}]),
    
    ok.

%% Wait for tables to be ready
wait_for_tables() ->
    Tables = [activity, message, profile, status, tokens],
    case mnesia:wait_for_tables(Tables, 5000) of
        ok -> ok;
        {timeout, BadTables} -> {error, {tables_not_ready, BadTables}};
        {error, Reason} -> {error, Reason}
    end.