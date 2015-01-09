%% @author Fabrizio
%% @doc @todo Add description to dijkstra.


-module(dijkstra).

%% ====================================================================
%% API functions
%% ====================================================================
-export([replace/4, entry/2, update/4, iterate/3, table/2, route/2]).

entry(Node, Sorted) ->
	case lists:keysearch(Node,1,Sorted) of
		{value, {_ , Len, _}} -> Len;
		false ->
			0
	end.

replace(Node, N, Gateway, Sorted) ->
	case lists:keysearch(Node, 1, Sorted) of
		{value,_} -> lists:keysort(2,lists:keydelete(Node, 1, Sorted) ++ [{Node,N,Gateway}]);
	false ->
		io:format("not found... ~n")
	end.

update(Node, N, Gateway, Sorted) ->
	case dijkstra:entry(Node, Sorted) of
		Len -> io:format("Len returned 	~p ~n", [Len]), 
			if
			   %Len /= 0 ->
			   %   if
					 N < Len ->
						 dijkstra:replace(Node, N, Gateway, Sorted);
					 true ->
						io:format("Worse case...~n"),
						Sorted
			% 		end;
			%   true ->
			%	   io:format("No match...~n"),
			%	   Sorted
			end
	end.

iterate(Sorted, Map, Table) ->
		io:format("Sorted now: ~p ~n", [Sorted]),
		case Sorted of
		[] ->
			Table;
		[{_,inf,_}|_] ->
			Table;
		[{N,L,G}|T] ->
			Ls = map:reachable(N, Map),
			io:format("Reahcables ~p ~n", [Ls]),
			NewLs = lists:foldl(fun(X,Acc)-> update(X, L+1, G, Acc) end, T, Ls),
			iterate(NewLs,Map,[{N,G}|Table])
		end.

table(Gateways, Map) ->
    Nodes = map:all_nodes(Map),
	%%setting the gateways to distance 0
    NoGt = lists:filter(fun (X) -> not lists:member(X, Gateways) end, Nodes),
	Indirect = lists:map(fun (X) -> {X,inf,unknown} end, NoGt),
	%%setting indirect nodes to distance infinite
    Direct = lists:map(fun (X) -> {X,0,X} end, Gateways),
    Sorted = lists:append(Direct, Indirect),
	io:format("Reahcables ~p ~n", [Sorted]),
	%%Passing to iterate the raw table to extrapolate route info
    iterate(Sorted, Map, []).

 route(Node, Table) ->
	case lists:keysearch(Node, 1, Table) of
	{value, {_, unknown}} ->
        unreachable;
	{value, {_, Gtw}} ->
		{ok,Gtw};
	false ->
		notfound
	end.
	

%% ====================================================================
%% Internal functions
%% ====================================================================


