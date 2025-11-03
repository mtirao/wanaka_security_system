-module(profile_service).
-export([create_profile/2, get_profile/1]).
-include("../models/db_schema.hrl").

%% Create a new profile

create_profile(Data, UserId) ->
    case jsone:try_decode(Data) of
        {ok, Json, _Remainings} ->
            case {maps:find(<<"lastname">>, Json),
                    maps:find(<<"firstname">>, Json),
                    maps:find(<<"email">>, Json),
                    maps:find(<<"phone">>, Json),
                    maps:find(<<"phonecell">>, Json),
                    maps:find(<<"gender">>, Json),
                    maps:find(<<"address">>, Json),
                    maps:find(<<"city">>, Json)} of
                {{ok, LastName},
                    {ok, FirstName},
                    {ok, Email},
                    {ok, Phone},
                    {ok, PhoneCell},
                    {ok, Gender},
                    {ok, Address},
                    {ok, City}} ->
                    case is_valid_email(Email) of
                        true ->
                            profile_repository:insert_profile(UserId, FirstName, LastName, Email, Phone, PhoneCell, Gender, Address, City),
                            {ok, UserId};
                        false -> 
                            {error, <<"invalid email format">>}
                    end;
                _ ->
                    {error, <<"missing required fields">>}
            end;
        {error, {Reason, _Stack}} ->
            %% Reason is typically an atom like badarg; return a 400 with reason
            ReasonBin = case Reason of
                            Atom when is_atom(Atom) -> list_to_binary(atom_to_list(Atom));
                            Other -> list_to_binary(io_lib:format("~p", [Other]))
                        end,
            {error, ReasonBin}
    end.

get_profile(Id) ->
    Profile = profile_repository:read_profile(Id),
    case Profile of
        {atomic, [#profile{lastname = LastName, firstname = FirstName, email = Email, phone = Phone, phonecell = PhoneCell, gender = Gender, address = Address, city = City}]} ->
            {ok, #{lastname => LastName,
                  firstname => FirstName,
                  email => Email,
                  phone => Phone,
                  phonecell => PhoneCell,
                  gender => Gender,
                  address => Address,
                  city => City}};
        _ ->
            {error, <<"invalid credentials">>}
    end.

is_valid_email(Email) ->
    re:run(Email, "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$", [{capture, none}]) =:= match.