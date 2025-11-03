-module(status_service).
-export([create_status/2]).
-include("../models/db_schema.hrl").


%% Create a new status
create_status(Data, UserId) ->
    case jsone:try_decode(Data) of
        {ok, Json, _Remainings} ->
            case {maps:find(<<"status">>, Json)} of
                {{ok, Status}} -> 
                    UUID = uuid:uuid_to_string(uuid:get_v4()),
                    Id = list_to_binary(UUID),
                    Date = os:system_time(seconds), 
                    status_repository:insert_status(Id, Date, Status, UserId),
                    {ok, UserId};
                _ ->
                    {error, <<"missing required fields">>}
            end;
        {error, Reason} ->
            {error, Reason}
    end.