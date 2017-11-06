%% @author rickard
%% @doc @todo Add description to main.


-module(filemanager).
-compile(export_all).

-define(SEARCHPATHDATA, "/home/rickard/workspace/rickieServer/src/data.txt").
-define(SEARCHPATHCOMMENTS, "/home/rickard/workspace/rickieServer/src/comments.txt").

start()->
	register(managerPID, spawn(fun()->manager() end)).

manager()->
	receive
		{store, Data}-> [];
		{read, Sender, File} -> Sender ! {ok, readfile(File)};
		_ -> "Manager: Bad argument"
	end.


readfile(Filepath) ->
	
	case file:read_file(Filepath) of
		{ok, Binary}-> binary_to_list(Binary);
		{error, Error} -> "Could not open file: " ++ Error
	end.

%%Counts number of words in file given by filepath
lengthCounter(Filepath)->
	counter(0, filemanager:readfile(Filepath)).

counter(Nr,[])-> Nr;
counter(Nr,[_|T])->counter(Nr+1,T).

%%DESSA FUNKAR EJ!
appendlightdata(Data)->
	{ok, IoDevice} = file:open(?SEARCHPATHDATA, append),
	file:write(IoDevice, Data),
	file:close(IoDevice).
	
%%ANVÄND EJ
addLightDevice(Device)->
	{lightDevice, ID, IP, Status}=Device,
	String = "{""LightID"":"++integer_to_list(ID)++",""IP"":"++IP++", ""state"":"++integer_to_list(Status)++", ""comment"":""NULL""}",
	appendlightdata(String).
%%_____________________


