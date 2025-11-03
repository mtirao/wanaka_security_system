-module(tenant_service).
-export([create_tenant/2, validate_tenant/2]).
-include("../models/db_schema.hrl").

%% Create a new tenant password
create_tenant(Passwd, User) ->
    UUID = uuid:uuid_to_string(uuid:get_v4()),
    Id = list_to_binary(UUID),
    tenant_repository:insert_tenant(Id, Passwd, User),
    {ok, Id}.

validate_tenant(User, Passwd) ->
    Tenant = tenant_repository:read_tenant(User),
    case Tenant of
        {atomic, [#tenant{password = StoredPasswd, id=Id}]} when StoredPasswd =:= Passwd ->
            {ok, Id};
        _ ->
            {error, <<"invalid credentials">>}
    end.