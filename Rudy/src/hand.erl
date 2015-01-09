%% @author Fabrizio
%% @doc @todo Add description to hand.


-module(hand).

%% ====================================================================
%% API functions
%% ====================================================================
-export([handler/1]).

handler(Listen) ->
	case gen_tcp:accept(Listen) of
		{ok, Client} ->
			request(Client),
			handler(Listen);
		{error, Error} ->
			error
	end.

request(Client) ->
	Recv = gen_tcp:recv(Client, 0),
	case Recv of
	{ok, Str} ->
		Request = http:parse_request(Str),
		Response = reply(Request),
		gen_tcp:send(Client, Response);
	{error, Error} ->
		io:format("rudy: error: ~w~n", [Error])
	end,
	gen_tcp:close(Client).

reply({{get, URI, _}, _, _}) ->
	timer:sleep(40),
	http:ok("").

%% ====================================================================
%% Internal functions
%% ====================================================================


