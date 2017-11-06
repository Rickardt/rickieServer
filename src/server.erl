%% @author rickard
%% @doc @todo Add description to server.


-module(server).
-compile(export_all).


status()->
	NumDevices= numDevices(),
	TimeOnline= timeOnline(),
	ServerV = serverVersion(),
{status, NumDevices, TimeOnline, ServerV}.

numDevices()->
	Num = lightDeviceCounter(devices:loadDevices()),
	NumMed = lightDeviceCounter(devices:loadDevices()),
	Num+NumMed.

lightDeviceCounter({_, [],_})-> 0;
lightDeviceCounter({_,[H|T], _})->
	1+lightDeviceCounter(T).
	
mediaDeviceCounter({_, [],_})-> 0;
mediaDeviceCounter({_,_,[H|T]})->
	1+mediaDeviceCounter(T).


timeOnline()->
	Time = timeCounter(),
	Time.

timeCounter() ->
	Start = timer:time().

getTime()->
	{{Year,Month,Day},{Hour,Min,Sec}} = erlang:localtime().

getStartedTime()->
	{{Year, Month, Day},{Hour, Minute, Second}} = rickie:getStartDate(),
	List = loop([Year, Month, Day, Hour, Minute, Second]).

loop([])->[];
loop([H|T])->integer_to_list(H)++[32]++loop(T).

serverVersion()-> "1.0 : 2017-08-31 \nStarted: "++getStartedTime().
