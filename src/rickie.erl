%% @author rickard
%% @doc @todo Add description to rickie.



-module(rickie).

-compile(export_all).


-define(SEARCHPATHDATA, "/home/rickard/workspace/rickieServer/src/data.txt").
-define(SEARCHPATHCOMMENTS, "/home/rickard/workspace/rickieServer/src/comments.txt").
-define(PORT, 8080).

start() ->
	
	register(rickie, spawn(fun() -> init(?PORT) end)),
	Date = server:getTime(),
	register(datecell, mem:init(Date)),
	register(lightdevicehandler, devices:inithandler()),
	register(devicememcell, mem:init([])).

stop() ->
	exit(whereis(lightdevicehandler), "lightdevicehandler dead"),
	exit(whereis(devicememcell), "devicememcell dead"),
	exit(whereis(rickie), "time to die"),
	exit(whereis(datecell), "Mem cell dead").

restart()->
	stop(),
	start().

init(Port) ->
	Opt = [list, {active, false}, {reuseaddr, true}],
	case gen_tcp:listen(Port, Opt) of
	{ok, Listen} ->
		handler(Listen),
		gen_tcp:close(Listen),
		ok;
	{error, Error} ->
		error
	end.

handler(Listen) ->
	case gen_tcp:accept(Listen) of
	{ok, Client} -> 
		spawn(fun()->request(Client) end),
		handler(Listen);

	{error, Error} ->
		error
	end.

request(Client) ->
	Recv = gen_tcp:recv(Client, 0),
	case Recv of
	{ok, Str} ->
		R={Request,Headers, Body} = http:parse_request(Str),
		io:format("Rickie: Recieved: ~w~n", [Request]),
		
		case Request of
			{ok,_,_} ->io:format("Rickie: Recieved: ~w~n", [Body]);
			{get, _,_}-> Response = reply(R),
							  gen_tcp:send(Client, Response)
		end;
		
	{error, Error} ->
		io:format("Rickie: error: ~w~n", [Error])
	end,
	gen_tcp:close(Client).


%% reply({{ok, URI, _}, _, _})->{};

reply({{get, URI, _}, _, Body}) ->
	case URI of
		"/lightdata" ->
			Length = integer_to_list(filemanager:lengthCounter(?SEARCHPATHDATA)),
			http:jsonok(filemanager:readfile(?SEARCHPATHDATA),Length);
		"/status" ->
			http:ok(server:serverVersion());
		"/comments" ->
			Length = integer_to_list(filemanager:lengthCounter(?SEARCHPATHCOMMENTS)),
			http:jsonok(filemanager:readfile(?SEARCHPATHCOMMENTS),Length);
		"/D2"-> http:ok(send:toDevice("192.168.0.7", ?PORT, http:get(URI)));
		"/hello"->
			http:ok(Body);
		_ ->
			http:ok(URI)
	end.

getStartDate() ->
	Cell = whereis(datecell),
	Cell ! {get, self()},
		receive
			{ok, Val}->Val
		end.
