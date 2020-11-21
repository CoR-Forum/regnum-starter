SettingsGuiOk:
	gui, 4:submit, nohide
	gui, 1:-disabled
	gosub writeUserConfig
	gui, 4:destroy
	winactivate, ahk_id %GUIID%
;	Reload
return
SettingsGuiSave:
	gui, 4:submit, nohide
	gosub writeUserConfig
return
SettingsGuiCancel:
	gui, 1:-disabled
	gui, 4:destroy
;	Reload
	winactivate, ahk_id %GUIID%
return

Settings:
    Gui, 4: -DPIScale
	SysGet, CBW, 71
	SysGet, CBH, 72
	cbw -= 2
	cbh  -= 2

	Gui, 4:Color, EEAA99
	Gui, 4:+LastFound

	Gui, 1:+disabled ; disable main GUI
	Gui, 4:-SysMenu
	Gui, 4:-Caption
;	// Window title
	Gui, 4:Font, s11 bold cD8D8D8, Verdana
	Gui, 4:add, text, x240 center y6 w140 h25 backgroundtrans, settings
	Gui, 4:Font, s7 cD8D8D8, Verdana
  	Gui, 4:Add, Picture, x0 y0, %APPDATA%\bg2.png ; uses the previously generated BgNumRound variable
	Gui, 4:Font, s8 cD8D8D8, Verdana


	Gui, 4:Add, Picture, gSettingsGuiCancel x20 y350  h23 w159 backgroundtrans, %APPDATA%\button-blue-small.png
	Gui, 4:add, Text, xp+40 yp+5 backgroundtrans, cancel
	Gui, 4:Add, Picture, gSettingsGuiSave xp+120 y350 h23 w159 backgroundtrans, %APPDATA%\button-blue-small.png
	Gui, 4:add, Text, xp+40 yp+5 backgroundtrans, save
	Gui, 4:Add, Picture, gSettingsGuiOk xp+120 y350 h23 w159 backgroundtrans, %APPDATA%\button-blue-small.png
	Gui, 4:add, Text, xp+40 yp+5 backgroundtrans, close


Gui, 4:add, Text, x20 y30 backgroundtrans, RegnumStarter
Gui, 4:add, Text, x+15 y30 backgroundtrans, Game
Gui, 4:add, Text, x+15 y30 backgroundtrans, Graphics
Gui, 4:add, Text, x+15 y30 backgroundtrans, Sound
Gui, 4:add, Text, x+15 y30 backgroundtrans, Controls
Gui, 4:add, Text, x+15 y30 backgroundtrans, Debug

Gui, 4:Add, Tab2 , +Theme -Background x20 y30 w500 h20, RegnumStarter|Game|Graphics|Sound|Controls|Debug
	Gui, 4:Font, s7 cD8D8D8, Verdana

	;	// regnum path
	gui, 4:Tab, 1
		gui  4:add, text, backgroundtrans x10 y80, % T.REGNUM_PATH ":"
		Gui, 4:Font, s7
		gui, 4:add, text, backgroundtrans x10 w500 r2 y+8 vregnum_path, %regnum_path%
		Gui, 4:Font, s8
		gui, 4:add, button, x100 w80 y85 gpath_edit, % T.CHANGE

	;	// hide NGE intro
		gui, 4:add, checkbox, w%CBW% h%CBH% x10 y+25 checked%skip_logo% backgroundtrans vskip_logo
		gui, 4:add, text, x+3 yp backgroundtrans, % T.DELETE_SPLASH



	gui, 4:Tab,2
		gui  4:add, text, backgroundtrans x10 y80, 2

	gui, 4:Tab, 3
		gui  4:add, text, backgroundtrans x10 y80, 3

	gui, 4:Tab, 4
		gui  4:add, text, backgroundtrans x10 y80, 4
	gui, 4:Tab, 5
		gui  4:add, text, backgroundtrans x10 y80, 5
	gui, 4:Tab, 6
		gui  4:add, text, backgroundtrans x10 y80, 6


Gui, 4:Show, w540 h380, settings

return