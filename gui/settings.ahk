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

	;Gui, 4:Color, EEAA99
	Gui, 4:+LastFound

	Gui, 1:+disabled ; disable main GUI
	Gui, 4:-SysMenu
	Gui, 4:-Caption

;	// Window title
	Gui, 4:Font, s11 bold cD8D8D8, Verdana
	Gui, 4:add, text, x240 center y6 w140 h25 backgroundtrans, settings
	Gui, 4:Font, s7 cD8D8D8, Verdana
  	Gui, 4:Add, Picture, x0 y0, %APPDATA%\bg_settings.png
	Gui, 4:Font, s8  normal cD8D8D8, Verdana

;	// close button
	Gui, 4:Font, s12 cD8D8D8, Verdana
	gui, 4:add, text, x533 backgroundtrans y4 gSettingsGuiCancel
Gui, 4:Font, s7 cD8D8D8, Verdana
	Gui, 4:Add, Picture, gSettingsGuiCancel x340 y305  backgroundtrans, %APPDATA%\btn_red_90px.png
	Gui, 4:add, Text, xp+10 yp+5 backgroundtrans, % T.UI_CANCEL
	;Gui, 4:Add, Picture, gSettingsGuiSave xp+130 y310 backgroundtrans, %APPDATA%\button-blue-small.png
	;Gui, 4:add, Text, xp+40 yp+5 backgroundtrans, % T.UI_SAVE
	Gui, 4:Add, Picture, gSettingsGuiOk xp+85 y305 backgroundtrans, %APPDATA%\btn_green_90px.png
	Gui, 4:add, Text, xp+10 yp+5 backgroundtrans, % T.UI_SAVE

	Gui, 4:Font, s9 bold cD8D8D8, Verdana

Gui, 4:add, Text, x20 y30 backgroundtrans, % T.UI_SETTINGS_REGNUMSTARTER
Gui, 4:add, Text, x+15 y30 backgroundtrans, % T.UI_SETTINGS_GAME
Gui, 4:add, Text, x+15 y30 backgroundtrans, % T.UI_SETTINGS_GRAPHICS
Gui, 4:add, Text, x+15 y30 backgroundtrans, % T.UI_SETTINGS_SOUND
Gui, 4:add, Text, x+15 y30 backgroundtrans, % T.UI_SETTINGS_CONTROLS
Gui, 4:add, Text, x+15 y30 backgroundtrans, % T.UI_SETTINGS_DEBUG
Gui, 4:add, Text, x+15 y30 backgroundtrans, special

Gui, 4:Add, Tab2 , +Theme -Background x20 y25 w500 h20, RegnumStart|Game|Graphics|Sound|Controls|Debug|Special
	Gui, 4:Font, s8 normal cD8D8D8, Verdana

	;	// regnum path
	gui, 4:Tab, 1
gui  4:add, text, x30 y60 backgroundtrans, % T.REGNUM_PATH ":"
		Gui, 4:Font, s7
		gui, 4:add, text, backgroundtrans xp w500 r2 y+8 vregnum_path, %regnum_path%
		Gui, 4:Font, s8
		gui, 4:add, button, x120 w80 y55 gpath_edit, % T.CHANGE

	;	// hide NGE intro
		gui, 4:add, checkbox, w%CBW% h%CBH% x30 y+25 checked%skip_logo% backgroundtrans vskip_logo
		gui, 4:add, text, x+3 yp backgroundtrans, % T.DELETE_SPLASH

	;	// hide loading screen
	  gui, 4:add, checkbox, w%CBW% h%CBH% x30 y+8 checked%hide_loading_screen% backgroundtrans vhide_loading_screen
		gui, 4:add, text, x+3 yp backgroundtrans, % T.HIDE_LOADING_SCREEN

	;	// screenshot quality
		gui, 4:add, checkbox, w%CBW% h%CBH% x30 y+8 checked%screenshot_quality% backgroundtrans vscreenshot_quality
		gui, 4:add, text, x+3 yp backgroundtrans, % T.SCREENSHOT_QUALITY

	;	// screenshot autosave
		gui, 4:add, checkbox, w%CBW% h%CBH% x30 y+8 checked%screenshot_autosave% backgroundtrans vscreenshot_autosave
		gui, 4:add, text, x+3 yp backgroundtrans, % T.SCREENSHOT_AUTOSAVE

	;	// server time and weather
		gui, 4:add, checkbox, x30 y+8 checked%dbg_ignore_server_time% backgroundtrans w%CBW% h%CBH% vdbg_ignore_server_time
		gui, 4:add, text, x+3 yp backgroundtrans, % T.WEATHER
		gui, 4:add, dropdownlist, x+20 yp w70 vserver_time AltSubmit, morning|afternoon|evening|night
		gui, 4:add, dropdownlist, x+25 yp w50 vweather AltSubmit, clear|rainy|storm

	;	// run as windows user
		gui, 4:add, checkbox, x30 y+15 checked%runas% w%CBW% h%CBH% grunAsGuiToggled vrunas
		gui, 4:add, text, x+3 yp backgroundtrans, % T.RUN_AS

		Gui, 4:Font, s7 cD8D8D8, Verdana
		gui, 4:add, text, x30 y+8 backgroundtrans vgui_runas_name_text, % "Windows " T.USER ; windows user text
		gui, 4:add, text, x155 yp backgroundtrans vgui_runas_pw_text, % "Win " T.PASSWORD ; windows password text
		Gui, 4:Font, s8 c000000, Verdana

		gui, 4:add, edit, x30 y+5 w90 h18 -multi vrunas_name, %runas_name%
		gui, 4:add, edit, x+30 yp w90 h18 -multi vrunas_pw, %runas_pw%

		Gui, 4:Font, s6 cD8D8D8, Verdana
		gui, 4:add, text, x80 y+2 backgroundtrans vgui_runas_required_text, % "(" T.REQUIRED ")"
		Gui, 4:Font, s8 cD8D8D8, Verdana

		gosub, runAsGuiToggled

	gui, 4:Tab,2
			;	// cl_update_all_resources
		gui, 4:add, checkbox, w%CBW% h%CBH% x30 y60 checked%cl_update_all_resources% backgroundtrans vcl_update_all_resources
		gui, 4:add, text, x+3 yp backgroundtrans, % T.UPDATE_ALL_RES

		gui, 4:add, checkbox, x30 y+8 checked%ingame_log% backgroundtrans w%CBW% h%CBH% vingame_log
		gui, 4:add, text, x+3 yp backgroundtrans, % T.INGAME_LOG

	gui, 4:Tab, 3
; row1
	;	// fullscreen mode
		gui, 4:add, checkbox, x30 y60 checked%vg_fullscreen_mode% backgroundtrans w%CBW% h%CBH% vvg_fullscreen_mode
		gui, 4:add, text, x+3 yp backgroundtrans, % T.FULLSCREEN_MODE

	;	// vsync
		gui, 4:add, checkbox, x30 y+8 checked%vg_vertical_sync% backgroundtrans w%CBW% h%CBH% vvg_vertical_sync
		gui, 4:add, text, x+3 yp backgroundtrans, % T.VSYNC

	; row2
	;	// window resolution
		gui, 4:add, text, x210 y60 backgroundtrans, % T.WINDOW_RESOLUTION ":"
		gui, 4:add, edit, x280 yp w42 h18 limit4 center number -multi vwidth, %width%
		gui, 4:add, text, x+7 yp backgroundtrans, x
		gui, 4:add, edit, x+5 yp w42 h18 limit4 center number -multi vheight, %height%

	gui, 4:Tab, 4
		gui  4:add, text, backgroundtrans x30 y80, coming soon
	gui, 4:Tab, 5
		gui  4:add, text, backgroundtrans x30 y80, coming soon
	gui, 4:Tab, 6
	;	// change 64bit mode
		gui, 4:add, checkbox, w%CBW% h%CBH% x30 y60 checked%win64% backgroundtrans vwin64
		gui, 4:add, text, x+3 yp backgroundtrans, % T.64BIT_MODE

		;	// hide window border
		gui, 4:add, checkbox, w%CBW% h%CBH% x30 y+8 checked%hide_window_border% backgroundtrans w%CBW% h%CBH% vhide_window_border
		gui, 4:add, text, x+3 yp backgroundtrans, % T.HIDE_WINDOW_BORDER

	;	// fake net lag
		gui, 4:add, text, x30 y+8 backgroundtrans, % T.NET_FAKE_LAG " (ms)"
		gui, 4:add, edit, x150 yp w60 h15 -multi vnet_fake_lag, %net_fake_lag%

	;	// debug mode
		gui, 4:add, checkbox, w%CBW% h%CBH% x30 y+8 checked%debug_mode% backgroundtrans vdebug_mode
		gui, 4:add, text, x+3 yp backgroundtrans, % "debug mode (experimental (?))"

	;	// cl_crafting_show_min_level
		gui, 4:add, checkbox, w%CBW% h%CBH% x30 y+8 checked%cl_crafting_show_min_level% backgroundtrans w%CBW% h%CBH% vcl_crafting_show_min_level
		gui, 4:add, text, x+3 yp backgroundtrans, % "cl_crafting_show_min_level (experimental)"

	;	// cl_show_subclass_on_players
		gui, 4:add, checkbox, w%CBW% h%CBH% x30 y+8 checked%cl_show_subclass_on_players% backgroundtrans w%CBW% h%CBH% vcl_show_subclass_on_players
		gui, 4:add, text, x+3 yp backgroundtrans, % "cl_show_subclass_on_players (experimental)"

	;	// cl_show_hidden_armors
		gui, 4:add, checkbox, w%CBW% h%CBH% x30 y+8 checked%cl_show_hidden_armors% backgroundtrans w%CBW% h%CBH% vcl_show_hidden_armors
		gui, 4:add, text, x+3 yp backgroundtrans, % "cl_show_hidden_armors (experimental)"



	Gui, 4:Tab, 7
	;	// server time and weather
		gui, 4:add, text, x30 y60 backgroundtrans, GUI SKIN
		gui, 4:add, dropdownlist, x+20 yp w70 v_gui_skin AltSubmit, regnum_default|regnum_test|test
Gui, 4:Show, w550 h336, settings

return

