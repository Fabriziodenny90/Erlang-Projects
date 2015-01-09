%% @author Fabrizio
%% @doc @todo Add description to routy.


-module(routy).

%% ====================================================================
%% API functions
%% ====================================================================
-export([start/1, stop/1, init/1, status/1, update/1, broadcast/1]).
 
 
start(Name) ->
    register(Name, spawn(routy, init, [Name])).
     
stop(Node) ->
    Node ! stop,
    unregister(Node).
 
init(Name) ->
    Intf = intf:new(),
    Map = map:new(),
    Table = dijkstra:table(Intf, Map),
    Msgs = hist:new(Name),
    router(Name, 0, Msgs, Intf, Table, Map).

update(Router) ->
    Router ! update.
 
broadcast(Router) ->
    Router ! broadcast.
     
status(Router) ->
    Router ! {status, self()},
    receive
    {status, {Name, N, Msg, Intf, Table, Map}}->
        io:format("Status -------------~n"),
        io:format(" name: ~w~n", [Name]),
        io:format("    n: ~w~n", [N]),
        io:format(" msgs: ~w~n", [Msg]),
            io:format(" intf: ~w~n", [Intf]),
            io:format("table: ~w~n", [Table]),
            io:format("  map: ~w~n", [Map]), 
        ok
    after 4000 ->
        io:format("No reply -------------~n"),
        ok
    end.
 
router(Name, N, Hist, Intf, Table, Map) ->
	io:format("Server attivo~n"),
    receive
    {route, Name, From, Message} ->
        io:format("~w: received message (~s) from ~w~n", [Name, Message, From]),
        router(Name, N, Hist, Intf, Table, Map);
 
    {route, To, From, Message} ->
        io:format("~w: routing message (~s) from ~w to ~w~n", [Name, Message, From, To]),
        case dijkstra:route(To, Table) of
        {ok, Gw} -> 
            case intf:lookup(Gw, Intf) of
            unknown ->
                io:format("~w: interface for gw ~w not found ~n", [Name, Gw]);
            {ok, Pid} ->
                io:format("~w: forward to ~w~n", [Name, Gw]),
                Pid ! {route, To, From, Message}
            end;
        notfound ->
            io:format("~w: routing entry for ~w not found ~n", [Name, To])
        end,
        router(Name, N, Hist, Intf, Table, Map);     
 
    {add, Node, Pid} ->
        Ref = erlang:monitor(process,Pid),
        Intf1 = intf:add(Node, Ref, Pid, Intf),
        router(Name, N, Hist, Intf1, Table, Map);
		 
    {remove, Node} ->
        {ok, Ref} = intf:ref(Node, Intf),
        erlang:demonitor(Ref),
        Intf1 = intf:remove(Node, Intf),
        router(Name, N, Hist, Intf1, Table, Map);
 
    {'DOWN', Ref, process, _, _}  ->
        {ok, Down} = intf:name(Ref, Intf),
        io:format("~w: exit recived from ~w~n", [Name, Down]),
        Intf1 = intf:remove(Down, Intf),
        router(Name, N, Hist, Intf1, Table, Map);

 
 
    {links, Node, R, Links} ->
		io:format("Sono in 1~n"),
        case hist:update(Node, R, Hist) of
        {new, Hist1} ->
			io:format("Sono in 2~n"),
            intf:broadcast({links, Node, R, Links}, Intf),
            Map1 = map:update(Node, Links, Map),
            router(Name, N, Hist1, Intf, Table, Map1);
        old -> 
			io:format("Sono in 3~n"),
            router(Name, N, Hist, Intf, Table, Map)
        end;
 
    {ping, From} ->
        From ! pong,
        router(Name, N, Hist, Intf, Table, Map); 
 
 
    {send, To, Message} ->
        self() ! {route, To, Name, Message},
        router(Name, N, Hist, Intf, Table, Map);
 
    {status, From} ->
        From ! {status, {Name, N, Hist, Intf, Table, Map}},
        router(Name, N, Hist, Intf, Table, Map);             
 
    update ->
        Table1 = dijkstra:table(intf:list(Intf), Map),
        router(Name, N, Hist, Intf, Table1, Map);
 
    broadcast ->
        Message = {links, Name, N, intf:list(Intf)},
        intf:broadcast(Message, Intf),
        router(Name, N+1, Hist, Intf, Table, Map);       
 	
	printtable ->
		io:format("~w: my table  ~w and my map ~w~n", [Name, Table, Map]),
		router(Name, N, Hist, Intf, Table, Map);
    
	stop ->
        ok
    end.

%% ====================================================================
%% Internal functions
%% ====================================================================


