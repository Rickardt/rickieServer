%% @author rickard
%% @doc @todo Add description to mem.


-module(mem).

-compile(export_all).


init(Val)->
	Pid = spawn(fun()-> cell(Val) end).

cell(Val)->
	receive
		{get, Sender}-> Sender !{ok, Val},
						cell(Val);
		{set, Sender, New} -> Sender !{ok, New},
						cell(New);
		{kill, Sender} -> Sender ! {dead, Val}
	end.