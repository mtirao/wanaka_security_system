-module(auth_service).
-export([authenticate_user/2]).

%% Authenticate a user with username and password
authenticate_user(Username, Password) when Username =:= <<"admin">> ->
   if Password =:= <<"supersecretadminpassword">> ->
          {ok, authenticated};
      true ->
          {error, <<"Invalidate credentials">>}
   end; 

authenticate_user(_Username, _Password) ->
    {error, <<"Invalidate credentials">>}.

