-module(profile_repository).
-export([insert_profile/9, read_profile/1, delete_profile/1]).

-include("../models/db_schema.hrl").

%% Insert a new profile with auto-generated UUID
insert_profile(Id, LastName, FirstName, Email, Phone, PhoneCell, Gender, Address, City) ->
    mnesia:transaction(fun() ->
        mnesia:write(#profile{
            id = Id,
            lastname = LastName,
            firstname = FirstName,
            email = Email,
            phone = Phone,
            phonecell = PhoneCell,
            gender = Gender,
            address = Address,
            city = City
        })
    end).

%% Read a profile
read_profile(Id) ->
    mnesia:transaction(fun() ->
        mnesia:read(profile, Id)
    end).

%% Delete a profile
delete_profile(Id) ->
    mnesia:transaction(fun() ->
        mnesia:delete({profile, Id})
    end).