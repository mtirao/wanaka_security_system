-module(message_service).
-export([create_message/2]).

create_message(Data, UserId) ->
    case jsone:try_decode(Data) of
        {ok, Json, _Remainings} ->
            case {maps:find(<<"type">>, Json), maps:find(<<"content">>, Json)} of
                {{ok, Type}, {ok, Content}} ->
                    UUID = uuid:uuid_to_string(uuid:get_v4()),
                    Id = list_to_binary(UUID),
                    Date = os:system_time(seconds), 
                    message_repository:insert_message(Id, Date, Type, Content, UserId),
                    {ok, ok};
                _ ->
                    {error, <<"missing required fields">>}
            end;
        {error, {Reason, _Stack}} ->
            {error, Reason}
    end.