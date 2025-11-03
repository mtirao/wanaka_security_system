-module(activity_service).  
-export([create_activity/2]).

%% Create a new activity entry
create_activity(Data, UserId) ->
    case jsone:try_decode(Data) of
        {ok, Json, _Remainings} ->
            case {maps:find(<<"activity">>, Json)} of
                {{ok, Activity}} -> 
                    UUID = uuid:uuid_to_string(uuid:get_v4()),
                    Id = list_to_binary(UUID),
                    Date = os:system_time(seconds), 
                    activity_repository:insert_activity(Id, Date, Activity, UserId),
                    {ok, UserId};
                _ ->
                    {error, <<"missing required fields">>}
            end;
        {error, Reason} ->
            {error, Reason}
    end.