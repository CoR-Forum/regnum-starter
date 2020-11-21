GraphicSettingsGuiOk:
	gui, 3:submit, nohide
	gui, 1:-disabled
	gosub writeUserConfig
	gui, 3:destroy
	winactivate, ahk_id %GUIID%
;	Reload
return
GraphicSettingsGuiSave:
	gui, 3:submit, nohide
	gosub writeUserConfig
return
GraphicSettingsGuiCancel:
	gui, 1:-disabled
	gui, 3:destroy
;	Reload
	winactivate, ahk_id %GUIID%
return

graphic_settings:
	Gui, 1:+disabled ; disable main GUI
	Gui, 3:-SysMenu
	Gui, 3:Show, w400 h300, % T.SETTINGS
	Gui, 3:-Caption
	Gui, 3:Font, s8 c000000, Verdana
	Gui, 3:Add, Tab2, x20 y10 w400 h20, RegnumStarter|Game|Graphics|Sound|Controls|Debug

	;	// regnum path
	gui, 3:Tab, 1
		gui  3:add, text, x10 y30, % T.REGNUM_PATH ":"
		Gui, 3:Font, s7
		gui, 3:add, text, x10 w500 r2 y+8 vregnum_path, %regnum_path%
		Gui, 3:Font, s8
		gui, 3:add, button, x100 w80 y25 gpath_edit, % T.CHANGE

	;	// hide NGE intro
		gui, 3:add, checkbox, w%CBW% h%CBH% x10 y+25 checked%skip_logo% backgroundtrans vskip_logo
		gui, 3:add, text, x+3 yp backgroundtrans, % T.DELETE_SPLASH

	;	// hide loading screen
	  gui, 3:add, checkbox, w%CBW% h%CBH% x10 y+8 checked%hide_loading_screen% backgroundtrans vhide_loading_screen
		gui, 3:add, text, x+3 yp backgroundtrans, % T.HIDE_LOADING_SCREEN

	;	// screenshot quality
		gui, 3:add, checkbox, w%CBW% h%CBH% x10 y+8 checked%screenshot_quality% backgroundtrans vscreenshot_quality
		gui, 3:add, text, x+3 yp backgroundtrans, % T.SCREENSHOT_QUALITY

	;	// screenshot autosave
		gui, 3:add, checkbox, w%CBW% h%CBH% x10 y+8 checked%screenshot_autosave% backgroundtrans vscreenshot_autosave
		gui, 3:add, text, x+3 yp backgroundtrans, % T.SCREENSHOT_AUTOSAVE

	;	// server time and weather
		gui, 3:add, checkbox, x10 y+8 checked%dbg_ignore_server_time% backgroundtrans w%CBW% h%CBH% vdbg_ignore_server_time
		gui, 3:add, text, x+3 yp, % T.WEATHER
		gui, 3:add, dropdownlist, x+20 yp w70 vserver_time AltSubmit, morning|afternoon|evening|night
		gui, 3:add, dropdownlist, x+25 yp w50 vweather AltSubmit, clear|rainy|storm

	;	// run as windows user
		gui, 3:add, checkbox, x10 y+15 checked%runas% w%CBW% h%CBH% grunAsGuiToggled vrunas
		gui, 3:add, text, x+3 yp backgroundtrans, % T.RUN_AS

		Gui, 3:Font, s7 c000000, Verdana
		gui, 3:add, text, x15 y+8 vgui_runas_name_text, % "Windows " T.USER ; windows user text
		gui, 3:add, text, x140 yp vgui_runas_pw_text, % "Win " T.PASSWORD ; windows password text
		Gui, 3:Font, s8 c000000, Verdana

		gui, 3:add, edit, x10 y+5 w90 h18 -multi vrunas_name, %runas_name%
		gui, 3:add, edit, x+30 yp w90 h18 -multi vrunas_pw, %runas_pw%

		Gui, 3:Font, s6 cD8D8D8, Verdana
		gui, 3:add, text, x80 y+2 vgui_runas_required_text, % "(" T.REQUIRED ")"
		Gui, 3:Font, s8 c000000, Verdana

		gosub, runAsGuiToggled

	gui, 3:Tab, 2

	;	// cl_update_all_resources
		gui, 3:add, checkbox, w%CBW% h%CBH% x10 y30 checked%cl_update_all_resources% backgroundtrans vcl_update_all_resources
		gui, 3:add, text, x+3 yp backgroundtrans, % T.UPDATE_ALL_RES

		gui, 3:add, checkbox, x10 y+8 checked%ingame_log% backgroundtrans w%CBW% h%CBH% vingame_log
		gui, 3:add, text, x+3 yp backgroundtrans, % T.INGAME_LOG

	gui, 3:Tab, 3
	; row1
	;	// fullscreen mode
		gui, 3:add, checkbox, x10 y30 checked%vg_fullscreen_mode% backgroundtrans w%CBW% h%CBH% vvg_fullscreen_mode
		gui, 3:add, text, x+3 yp backgroundtrans, % T.FULLSCREEN_MODE

	;	// vsync
		gui, 3:add, checkbox, x10 y+8 checked%vg_vertical_sync% backgroundtrans w%CBW% h%CBH% vvg_vertical_sync
		gui, 3:add, text, x+3 yp backgroundtrans, % T.VSYNC

	; row2
	;	// window resolution
		gui, 3:add, text, x200 y30 backgroundtrans, % T.WINDOW_RESOLUTION ":"
		gui, 3:add, edit, x265 yp w42 h18 limit4 center number -multi vwidth, %width%
		gui, 3:add, text, x+7 yp backgroundtrans, x
		gui, 3:add, edit, x+5 yp w42 h18 limit4 center number -multi vheight, %height%

	gui, 3:Tab, 6
	;	// change 64bit mode
		gui, 3:add, checkbox, w%CBW% h%CBH% x10 y30 checked%win64% backgroundtrans vwin64
		gui, 3:add, text, x+3 yp backgroundtrans, % T.64BIT_MODE

		;	// hide window border
		gui, 3:add, checkbox, w%CBW% h%CBH% x10 y+8 checked%hide_window_border% backgroundtrans w%CBW% h%CBH% vhide_window_border
		gui, 3:add, text, x+3 yp, % T.HIDE_WINDOW_BORDER

	;	// fake net lag
		gui, 3:add, text, x10 y+8 backgroundtrans, % T.NET_FAKE_LAG " (ms)"
		gui, 3:add, edit, x150 yp w60 h15 -multi vnet_fake_lag, %net_fake_lag%

	;	// debug mode
		gui, 3:add, checkbox, w%CBW% h%CBH% x10 y+8 checked%debug_mode% backgroundtrans vdebug_mode
		gui, 3:add, text, x+3 yp backgroundtrans, % "debug mode (experimental (?))"

	;	// cl_crafting_show_min_level
		gui, 3:add, checkbox, w%CBW% h%CBH% x10 y+8 checked%cl_crafting_show_min_level% backgroundtrans w%CBW% h%CBH% vcl_crafting_show_min_level
		gui, 3:add, text, x+3 yp backgroundtrans, % "cl_crafting_show_min_level (experimental)"

	;	// cl_show_subclass_on_players
		gui, 3:add, checkbox, w%CBW% h%CBH% x10 y+8 checked%cl_show_subclass_on_players% backgroundtrans w%CBW% h%CBH% vcl_show_subclass_on_players
		gui, 3:add, text, x+3 yp backgroundtrans, % "cl_show_subclass_on_players (experimental)"

	;	// cl_show_hidden_armors
		gui, 3:add, checkbox, w%CBW% h%CBH% x10 y+8 checked%cl_show_hidden_armors% backgroundtrans w%CBW% h%CBH% vcl_show_hidden_armors
		gui, 3:add, text, x+3 yp backgroundtrans, % "cl_show_hidden_armors (experimental)"

gui, 3:Tab, 1
	gui, 3:add, button, gGraphicSettingsGuiCancel x180 y275, % T.GRAPHIC_SETTINGS_CANCEL
	gui, 3:add, button, gGraphicSettingsGuiSave x255 y275, % T.GRAPHIC_SETTINGS_SAVE
	gui, 3:add, button, gGraphicSettingsGuiOk x330 y275, % T.GRAPHIC_SETTINGS_SAVE_CLOSE
	gui, 3:show

gui, 3:Tab, 2
	gui, 3:add, button, gGraphicSettingsGuiCancel x180 y275, % T.GRAPHIC_SETTINGS_CANCEL
	gui, 3:add, button, gGraphicSettingsGuiSave x255 y275, % T.GRAPHIC_SETTINGS_SAVE
	gui, 3:add, button, gGraphicSettingsGuiOk x330 y275, % T.GRAPHIC_SETTINGS_SAVE_CLOSE
	gui, 3:show

gui, 3:Tab, 3
	gui, 3:add, button, gGraphicSettingsGuiCancel x180 y275, % T.GRAPHIC_SETTINGS_CANCEL
	gui, 3:add, button, gGraphicSettingsGuiSave x255 y275, % T.GRAPHIC_SETTINGS_SAVE
	gui, 3:add, button, gGraphicSettingsGuiOk x330 y275, % T.GRAPHIC_SETTINGS_SAVE_CLOSE
	gui, 3:show

gui, 3:Tab, 4
	gui, 3:add, button, gGraphicSettingsGuiCancel x180 y275, % T.GRAPHIC_SETTINGS_CANCEL
	gui, 3:add, button, gGraphicSettingsGuiSave x255 y275, % T.GRAPHIC_SETTINGS_SAVE
	gui, 3:add, button, gGraphicSettingsGuiOk x330 y275, % T.GRAPHIC_SETTINGS_SAVE_CLOSE
	gui, 3:show

gui, 3:Tab, 5
	gui, 3:add, button, gGraphicSettingsGuiCancel x180 y275, % T.GRAPHIC_SETTINGS_CANCEL
	gui, 3:add, button, gGraphicSettingsGuiSave x255 y275, % T.GRAPHIC_SETTINGS_SAVE
	gui, 3:add, button, gGraphicSettingsGuiOk x330 y275, % T.GRAPHIC_SETTINGS_SAVE_CLOSE
	gui, 3:show

gui, 3:Tab, 6
	gui, 3:add, button, gGraphicSettingsGuiCancel x180 y275, % T.GRAPHIC_SETTINGS_CANCEL
	gui, 3:add, button, gGraphicSettingsGuiSave x255 y275, % T.GRAPHIC_SETTINGS_SAVE
	gui, 3:add, button, gGraphicSettingsGuiOk x330 y275, % T.GRAPHIC_SETTINGS_SAVE_CLOSE
	gui, 3:show
return