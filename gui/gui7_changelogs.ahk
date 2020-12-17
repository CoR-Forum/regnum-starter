gui7_changelogs:
    Gui, 7: -DPIScale
	SysGet, CBW, 71
	SysGet, CBH, 72
	cbw -= 2
	cbh  -= 2

	;Gui, 7:Color, EEAA99
	Gui, 7:+LastFound

	Gui, 1:+disabled ; disable main GUI
	Gui, 7:-SysMenu
	Gui, 7:-Caption

;	// Window title
	Gui, 7:Font, s11 bold cD8D8D8, Verdana
	Gui, 7:add, text, x240 center y6 w140 h25 backgroundtrans, settings
	Gui, 7:Font, s7 cD8D8D8, Verdana
  	Gui, 7:Add, Picture, x0 y0, %APPDATA%\bg_settings.png
	Gui, 7:Font, s8  normal cD8D8D8, Verdana

;	// close button
	Gui, 7:Font, s12 cD8D8D8, Verdana
	Gui, 7:add, text, x533 backgroundtrans y4 gSettingsGuiCancel
Gui, 7:Font, s7 cD8D8D8, Verdana
	Gui, 7:Add, Picture, gSettingsGuiCancel x340 y305  backgroundtrans, %APPDATA%\btn_red_90px.png
	Gui, 7:add, Text, xp+10 yp+5 backgroundtrans, % T.UI_CANCEL
	;Gui, 7:Add, Picture, gSettingsGuiSave xp+130 y310 backgroundtrans, %APPDATA%\button-blue-small.png
	;Gui, 7:add, Text, xp+40 yp+5 backgroundtrans, % T.UI_SAVE
	Gui, 7:Add, Picture, gSettingsGuiOk xp+85 y305 backgroundtrans, %APPDATA%\btn_green_90px.png
	Gui, 7:add, Text, xp+10 yp+5 backgroundtrans, % T.UI_SAVE

	Gui, 7:Font, s9 bold cD8D8D8, Verdana

Gui, 7:add, Text, x20 y30 backgroundtrans, % T.UI_SETTINGS_REGNUMSTARTER
Gui, 7:add, Text, x+15 y30 backgroundtrans, % T.UI_SETTINGS_GAME
Gui, 7:add, Text, x+15 y30 backgroundtrans, % T.UI_SETTINGS_GRAPHICS
Gui, 7:add, Text, x+15 y30 backgroundtrans, % T.UI_SETTINGS_SOUND
Gui, 7:add, Text, x+15 y30 backgroundtrans, % T.UI_SETTINGS_CONTROLS
Gui, 7:add, Text, x+15 y30 backgroundtrans, % T.UI_SETTINGS_DEBUG
Gui, 7:add, Text, x+15 y30 backgroundtrans, special

Gui, 7:Add, Tab2 , +Theme -Background x20 y25 w500 h20, RegnumStart|Game|Graphics|Sound|Controls|Debug|Special
	Gui, 7:Font, s8 normal cD8D8D8, Verdana

	;	// regnum path
	Gui, 7:Tab, 1
gui  4:add, text, x30 y60 backgroundtrans, % T.REGNUM_PATH ":"
		Gui, 7:Font, s7
		Gui, 7:add, text, backgroundtrans xp w500 r2 y+8 vregnum_path, %regnum_path%
		Gui, 7:Font, s8
		Gui, 7:add, button, x120 w80 y55 gpath_edit, % T.CHANGE

	;	// hide NGE intro
		Gui, 7:add, checkbox, w%CBW% h%CBH% x30 y+25 checked%skip_logo% backgroundtrans vskip_logo
		Gui, 7:add, text, x+3 yp backgroundtrans, % T.DELETE_SPLASH

	;	// hide loading screen
	  Gui, 7:add, checkbox, w%CBW% h%CBH% x30 y+8 checked%hide_loading_screen% backgroundtrans vhide_loading_screen
		Gui, 7:add, text, x+3 yp backgroundtrans, % T.HIDE_LOADING_SCREEN

	;	// screenshot quality
		Gui, 7:add, checkbox, w%CBW% h%CBH% x30 y+8 checked%screenshot_quality% backgroundtrans vscreenshot_quality
		Gui, 7:add, text, x+3 yp backgroundtrans, % T.SCREENSHOT_QUALITY

	;	// screenshot autosave
		Gui, 7:add, checkbox, w%CBW% h%CBH% x30 y+8 checked%screenshot_autosave% backgroundtrans vscreenshot_autosave
		Gui, 7:add, text, x+3 yp backgroundtrans, % T.SCREENSHOT_AUTOSAVE

	;	// server time and weather
		Gui, 7:add, checkbox, x30 y+8 checked%dbg_ignore_server_time% backgroundtrans w%CBW% h%CBH% vdbg_ignore_server_time
		Gui, 7:add, text, x+3 yp backgroundtrans, % T.WEATHER
		Gui, 7:add, dropdownlist, x+20 yp w70 vserver_time AltSubmit, morning|afternoon|evening|night
		Gui, 7:add, dropdownlist, x+25 yp w50 vweather AltSubmit, clear|rainy|storm

	;	// run as windows user
		Gui, 7:add, checkbox, x30 y+15 checked%runas% w%CBW% h%CBH% grunAsGuiToggled vrunas
		Gui, 7:add, text, x+3 yp backgroundtrans, % T.RUN_AS

		Gui, 7:Font, s7 cD8D8D8, Verdana
		Gui, 7:add, text, x30 y+8 backgroundtrans vgui_runas_name_text, % "Windows " T.USER ; windows user text
		Gui, 7:add, text, x155 yp backgroundtrans vgui_runas_pw_text, % "Win " T.PASSWORD ; windows password text
		Gui, 7:Font, s8 c000000, Verdana

		Gui, 7:add, edit, x30 y+5 w90 h18 -multi vrunas_name, %runas_name%
		Gui, 7:add, edit, x+30 yp w90 h18 -multi vrunas_pw, %runas_pw%

		Gui, 7:Font, s6 cD8D8D8, Verdana
		Gui, 7:add, text, x80 y+2 backgroundtrans vgui_runas_required_text, % "(" T.REQUIRED ")"
		Gui, 7:Font, s8 cD8D8D8, Verdana

		gosub, runAsGuiToggled


		;	// delete all regnumstarter tmp files at program close
		Gui, 7:add, checkbox, w%CBW% h%CBH% x30 y+8 checked%rs_delete_tmp_files% backgroundtrans vrs_delete_tmp_files
		Gui, 7:add, text, x+3 yp backgroundtrans, rs delete tmp files

	Gui, 7:Tab,2
			;	// cl_update_all_resources
		Gui, 7:add, checkbox, w%CBW% h%CBH% x30 y60 checked%cl_update_all_resources% backgroundtrans vcl_update_all_resources
		Gui, 7:add, text, x+3 yp backgroundtrans, % T.UPDATE_ALL_RES

		Gui, 7:add, checkbox, x30 y+8 checked%ingame_log% backgroundtrans w%CBW% h%CBH% vingame_log
		Gui, 7:add, text, x+3 yp backgroundtrans, % T.INGAME_LOG

	Gui, 7:Tab, 3
; row1
	;	// fullscreen mode
		Gui, 7:add, checkbox, x30 y60 checked%vg_fullscreen_mode% backgroundtrans w%CBW% h%CBH% vvg_fullscreen_mode
		Gui, 7:add, text, x+3 yp backgroundtrans, % T.FULLSCREEN_MODE

	;	// vsync
		Gui, 7:add, checkbox, x30 y+8 checked%vg_vertical_sync% backgroundtrans w%CBW% h%CBH% vvg_vertical_sync
		Gui, 7:add, text, x+3 yp backgroundtrans, % T.VSYNC

	; row2
	;	// window resolution
		Gui, 7:add, text, x210 y60 backgroundtrans, % T.WINDOW_RESOLUTION ":"
		Gui, 7:add, edit, x280 yp w42 h18 limit4 center number -multi vwidth, %width%
		Gui, 7:add, text, x+7 yp backgroundtrans, x
		Gui, 7:add, edit, x+5 yp w42 h18 limit4 center number -multi vheight, %height%

	Gui, 7:Tab, 4
		gui  4:add, text, backgroundtrans x30 y80, coming soon
	Gui, 7:Tab, 5
		gui  4:add, text, backgroundtrans x30 y80, coming soon
	Gui, 7:Tab, 6
	;	// change 64bit mode
		Gui, 7:add, checkbox, w%CBW% h%CBH% x30 y60 checked%win64% backgroundtrans vwin64
		Gui, 7:add, text, x+3 yp backgroundtrans, % T.64BIT_MODE

	;	// hide window border
		Gui, 7:add, checkbox, w%CBW% h%CBH% x30 y+8 checked%hide_window_border% backgroundtrans w%CBW% h%CBH% vhide_window_border
		Gui, 7:add, text, x+3 yp backgroundtrans, % T.HIDE_WINDOW_BORDER

	;	// fake net lag
		Gui, 7:add, text, x30 y+8 backgroundtrans, % T.NET_FAKE_LAG " (ms)"
		Gui, 7:Font, s7 c000000, Verdana
		Gui, 7:add, edit, x170 yp w60 h15 -multi vnet_fake_lag, %net_fake_lag%
		Gui, 7:Font, s7 cD8D8D8, Verdana

	;	// debug mode
		Gui, 7:add, checkbox, w%CBW% h%CBH% x30 y+8 checked%debug_mode% backgroundtrans vdebug_mode
		Gui, 7:add, text, x+3 yp backgroundtrans, % "debug mode (enables a bunch of debugging options)"

	;	// cl_crafting_show_min_level
		Gui, 7:add, checkbox, w%CBW% h%CBH% x30 y+8 checked%cl_crafting_show_min_level% backgroundtrans w%CBW% h%CBH% vcl_crafting_show_min_level
		Gui, 7:add, text, x+3 yp backgroundtrans, % "cl_crafting_show_min_level (useless)"

	;	// cl_show_subclass_on_players
		Gui, 7:add, checkbox, w%CBW% h%CBH% x30 y+8 checked%cl_show_subclass_on_players% backgroundtrans w%CBW% h%CBH% vcl_show_subclass_on_players
		Gui, 7:add, text, x+3 yp backgroundtrans, % "cl_show_subclass_on_players (useless)"

	;	// cl_show_hidden_armors
		Gui, 7:add, checkbox, w%CBW% h%CBH% x30 y+8 checked%cl_show_hidden_armors% backgroundtrans w%CBW% h%CBH% vcl_show_hidden_armors
		Gui, 7:add, text, x+3 yp backgroundtrans, % "cl_show_hidden_armors (useless)"

	;	// cl_disable_terrain_loading
		Gui, 7:add, checkbox, w%CBW% h%CBH% x30 y+8 checked%cl_disable_terrain_loading% backgroundtrans w%CBW% h%CBH% vcl_disable_terrain_loading
		Gui, 7:add, text, x+3 yp backgroundtrans, % "cl_disable_terrain_loading"

;		// cl_terrain_load_radius
		Gui, 7:add, text, x30 y+8 backgroundtrans, cl_terrain_load_radius
		Gui, 7:Font, s7 c000000, Verdana
		Gui, 7:add, edit, x170 yp w60 h16 -multi vcl_terrain_load_radius, %cl_terrain_load_radius%
		Gui, 7:Font, s7 cD8D8D8, Verdana


	Gui, 7:Tab, 7
	;	// vg_gui_skin
		Gui, 7:add, text, x30 y60 backgroundtrans, GUI SKIN
		Gui, 7:add, dropdownlist, x+20 yp w140 vreg_vg_gui_skin AltSubmit, 1:regnum_default (newest)|2:regnum_loadingscreen|3:regnum_mainmenu|4:regnum_mainmenuv2|5:test|6:default
		Gui, 7:add, text, x+10 yp backgroundtrans, Current nr: %reg_vg_gui_skin%
Gui, 7:Show, w550 h336 x%GuiX% y%GuiY%, settings


return