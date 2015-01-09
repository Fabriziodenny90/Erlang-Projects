%% @author Fabrizio
%% @doc @todo Add description to intf.


-module(intf).

%% ====================================================================
%% API functions
%% ====================================================================
-export([new/0, add/4, remove/2, lookup/2, ref/2, name/2, list/1, broadcast/2]).

new()->
	[].

add(Name, Ref, Pid, Intf) ->
	[{Name, Ref, Pid}]++Intf.

remove(Name, Intf) ->
    lists:keydelete(Name, 1, Intf).

lookup(Name, Intfs) ->
    case lists:keysearch(Name, 1, Intfs) of
    {value, {_, _, Pid}} ->
        {ok, Pid};
    false ->
        unknown
    end.

ref(Name, Intfs) ->
    case lists:keysearch(Name, 1, Intfs) of
    {value, {_, Ref, _}} ->
        {ok, Ref};
    false ->
        unknown
    end.

name(Ref, Intfs) ->
    case lists:keysearch(Ref, 2, Intfs) of
    {value, {Name, _, _}} ->
        {ok, Name};
    false ->
        unknown
    end.

list(Intfs) ->
	lists:map(fun({Name,_,_}) -> Name end, Intfs).

broadcast(Message, Intf) ->
    lists:map(fun({_,_,Pid}) -> Pid ! Message end, Intf).


%% ====================================================================
%% Internal functions
%% ====================================================================


