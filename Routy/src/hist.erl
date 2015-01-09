%% @author Fabrizio
%% @doc @todo Add description to hist.


-module(hist).

%% ====================================================================
%% API functions
%% ====================================================================
-export([new/1, update/3]).

new(Name) ->
    [{Name, infinite}].

update(Node, H, History)->
    case lists:keysearch(Node, 1, History) of
    {value, {Node, TimeStamp}} ->
        if
        H > TimeStamp -> 
			Tmp = lists:keydelete(Node, 1, History),
			{new, [{Node,H}|Tmp]};
        true -> 
            old
        end;
    false ->
			Tmp = lists:keydelete(Node, 1, History),
			{new, [{Node,H}|Tmp]}
    end.


%% ====================================================================
%% Internal functions
%% ====================================================================


