%% @author rickard
%% @doc @todo Add description to send.


-module(send).

-compile(export_all).
test()->
	toDevice("192.168.0.7", 8080, http:get("/D2")).

toDevice(IP, Port, Data)->
	Opt = [list, {active, false}, {reuseaddr, true}],
	case gen_tcp:connect(IP, Port, Opt) of
		{ok, Socket} ->
			sendhandler(Socket, Data);
		{error, Error}->
			io:format("Rickie: toDevice connect error: ~w~n", [Error])
		end.

sendhandler(Socket, Data)->
	case gen_tcp:send(Socket, Data) of
		ok ->io:format("Rickie: Sent data ~w~n", [Data]),
			 deviceresponse(Socket);
		{error, Error} ->io:format("Rickie: sendhandler error: ~w~n", [Error])
	end.

deviceresponse(Socket)->
	case gen_tcp:recv(Socket, 0) of
		{ok, String}-> {Request,Headers, Body} = http:parse_request(String),
					   io:format("Rickie: getresponse request: ~w~n", [Request]),
					   Body;
		{error, Error} ->io:format("Rickie: getresponse error: ~w~n", [Error]),
						 Error
end.
