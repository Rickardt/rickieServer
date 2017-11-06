%% @author rickard
%% @doc @todo Add description to http.


-module(http).
-compile(export_all).


parse_request(R0) ->
	{Request, R1} = request_line(R0),
	{Headers, R2} = headers(R1),
	{Body, _} = message_body(R2),
	{Request, Headers, Body}.

request_line([$H,$T,$T,$P,$/,$1,$.,$1, 32,$2,$0,$0, 32, $O,$K|T])->
	URI = "/",
	Ver = v11,
	[13,10|R3] = T,
	{{ok,URI, Ver},R3};

request_line([$G, $E, $T, 32 |R0]) ->
	{URI, R1} = request_uri(R0),
	{Ver, R2} = http_version(R1),
	[13,10|R3] = R2,
	{{get, URI, Ver}, R3}.

request_uri([32|R0])->
	{[], R0};

request_uri([C|R0]) ->
	{Rest, R1} = request_uri(R0),
	{[C|Rest], R1}.

http_version([$H, $T, $T, $P, $/, $1, $., $1 | R0]) ->
	{v11, R0};

http_version([$H, $T, $T, $P, $/, $1, $., $0 | R0]) ->
	{v10, R0}.



headers([13,10|R0]) ->
	{[],R0};

headers(R0) ->
	{Header, R1} = header(R0),
	{Rest, R2} = headers(R1),
	{[Header|Rest], R2}.

header([13,10|R0]) ->
	{[], R0};

header([C|R0]) ->
	{Rest, R1} = header(R0),
	{[C|Rest], R1}.

message_body(R) ->
	{R, []}.

hellobodyparse(Data)->
	{IP, T1} = getip(Data),
	{State,Rest} = getstate(T1),
	{IP, State, Rest}.

getip([$1,$9,$2,$.,$1,$6,$8,$.,$0,$.,A, 32|T])->
	{"192.168.0."++A, T}.

getstate([State|Rest])->
	{State, Rest}.

ok(Body) ->
	"HTTP/1.1 200 OK \r\n"
	++"Content-type: text/html\r\n"
	++ "Access-Control-Allow-Origin: * \r\n"
	++"Access-Control-Allow-Headers: Accept, Origin, Content-Type\r\n
"
	++ Body.
jsonok(Body, Length)->
	"HTTP/1.1 200 OK \r\n"
	++"Content-type: application/json\r\n"
	++"Content-Length:"++Length++"\r\n"
	++ "Access-Control-Allow-Origin: * \r\n"
	++"Access-Control-Allow-Headers: Accept, Origin, Content-Type\r\n
"
	++ Body.
get(URI) ->

	"GET " ++ URI ++ " HTTP/1.1\r\n"++
		"\r\n".



