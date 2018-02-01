%% @author rictid
%% @doc @todo Add description to ui.


-module(ui).



-compile(export_all).
-define(PATH, file:get_cwd()).

init()->
	Wx=wx:new(),
	F=wxFrame:new(Wx, -1, "Hello, World!"),
	wxFrame:createStatusBar(F),
	wxFrame:setStatusText(F, server:serverVersion()),
	{_,SP}=?PATH,
	Image = wxImage:new(SP ++"/rickieServer/src/images/RN.jpg"),
%% 	wxButton:create(Button, F, 0),
	ClientDC = wxClientDC:new(F),
	Bitmap = wxBitmap:new(Image),
	wxDC:drawBitmap(ClientDC, Bitmap, {0,0}),
	
	wxFrame:show(F).

