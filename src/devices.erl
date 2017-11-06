%% @author rickard
%% @doc @todo Add description to devices.


-module(devices).

-compile(export_all).

-define(PORT, 8080).
-define(HandlerPid, whereis(lightdevicehandler)).

%%{lightDevice, ID, IP, status}
lightDevices()-> [{lightDevice, 1, "192.168.0.7", 0}, {lightDevice, 2, "192.168.0.7", 0}].

%%{mediaDevice, ID, IP, mode(bass|all|dis), decodeType(mp3), volume}
mediaDevices()-> [{}].


loadDevices()->
	Light = lightDevices(),
	Media = mediaDevices(),
	{devices, Light, Media}.

inithandler()->
	Pid = spawn(fun()->lightdevicehandler() end).
	
lightdevicehandler()->
	receive
		{getState,ID, Sender} -> 
			LightDevice =lookuplightdevice(ID),
			if 
				LightDevice == nil -> Sender ! error
			end,
			{lightDevice, ID,IP, _} = LightDevice,
			State = send:toDevice(IP, ?PORT, http:get("/state"++integer_to_list(ID))),
			Sender ! {state, State},
			lightdevicehandler();
		{setState, Sender,ID, Data} -> 
			{lightDevice, ID,IP, Status} =lookuplightdevice(ID),
			send:toDevice(IP, 8080, Data),
			Sender ! {ok,Data},
			lightdevicehandler();
		{storeDevice,Sender, Device}-> storeDevice(Device),
									   Sender!ok
	end.


lookuplightdevice(ID)->
	lookuplightdevice(ID,lightDevices()).
lookuplightdevice(_,[])-> nil;
lookuplightdevice(ID,[{lightDevice, ID,IP, Status}|_])->
	{lightDevice, ID,IP, Status};
lookuplightdevice(ID,[{lightDevice, _,_, _}|T])->
	lookuplightdevice(ID,T).

storeDevice(Device)->[].

audiodevicehandler()->{}.

