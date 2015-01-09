%% @author Fabrizio
%% @doc @todo Add description to map.


-module(map).

%% ====================================================================
%% API functions
%% ====================================================================
-export([all_nodes/1, reachable/2, update/3, new/0]).

new() -> 
	[].

reachable(Node, Map) ->
	case lists:keysearch(Node,1,Map) of
		{value, {_ , Tuple}} -> Tuple;
		false ->
			[]
	end.

update(Node, Links, Map) ->
	case lists:keysearch(Node,1,Map) of
	{value,_} ->
			io:format("Going to update this map: ~w~n", [Map]),
			[{Node, Links}|lists:keydelete(Node, 1, Map)];
	false ->
			io:format("Going to update this map: ~w~n", [Map]),
			[{Node, Links}|Map]
	end.

all_nodes(Map) ->
    lists:foldl(fun(E,Acc) -> add_all(E,Acc) end, [], Map).
 
add_all({Node, Links}, All) ->
    lists:foldl(fun(N,Acc) -> add_node(N,Acc) end, All, [Node|Links]).
 
add_node(Node, All) ->
    case lists:member(Node, All) of
    true -> All; 
    false -> [Node|All] 
    end.

%% ====================================================================
%% Internal functions
%% ====================================================================


