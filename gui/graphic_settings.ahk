graphic_settings:
	;gui, 1:+disabled
	Gui, 3:Font, s8 c000000, Verdana
	gui, 3:add, text, x+40 y+6, % "under development"
	;	// hide window boarder
	Gui, 3:Font, s7,, Verdana
	gui, 3:add, checkbox, x20 x20 checked%hide_window_border% backgroundtrans w%CBW% h%CBH% vhide_window_border
	gui, 3:add, text, x+3 yp, % T.HIDE_WINDOW_BORDER
	gui, 3:add, button, g3guiok x235, Save
	gui, 3:show
return
