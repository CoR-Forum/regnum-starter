make_gui:
	SysGet, CBW, 71
	SysGet, CBH, 72
	cbw -= 2
	cbh  -= 2
	
	Gui, Color, EEAA99
	Gui +LastFound
	WinSet, TransColor, EEAA99
	

;   // number generator for background image
    Random, BgNum , 1, 1 ; the function Random generates a number between 1 and 2 and sets it to the variable BgNum
    BgNumRound := Round(BgNum) ; variable BgNum will be round up or down and named BgNumRound

; 	// background image	
	;gui, add, picture, x0 y0, %APPDATA%\background.png
    
    ; new background image below
    Gui, Add, Picture, x0 y0, %APPDATA%\bg%BgNumRound%.png ; uses the previously generated BgNumRound variable



;	// Window title
	Gui, Font, s10 bold cD8D8D8, Verdana
	gui, add, text, x240 center y7 w120 h25 backgroundtrans, RegnumStarter
	
;	// version number
	Gui, Font, s7 cD8D8D8, Verdana
	gui, add, text, x500 center y10 w120 h25 backgroundtrans, v3.1.0

;	// link to the forum post	
	Gui, add, link, x380 center y10 w87 h14 backgroundtrans, <a href="https://www.cor-forum.de/index.php?page=Thread&threadID=811">Help / Discussion</a>
	
; 	// login button
	Gui, Font, s10 bold, Verdana
	gui, add, button, w140 h35 x550 y390 glogin, % T.LOGIN
	Gui, Font, s7 c000000, Verdana

; 	// user selection
	gui, add, dropdownlist, x500 y240 w120 vselected_user altsubmit
	goSub updateUserlist

; 	// account management
	gui, add, button, x400 y245 w80 h35 gaccounts_edit, % T.MANAGE_ACCOUNTS

; 	// graphic settings
;	gui, add, button, x300 y150 h40 w80 ggraphic_settings, % T.GRAPHIC_SETTINGS

; 	// server selection
	gui, add, dropdownlist, x500 y265 w120 vselected_server altsubmit
	gosub updateServerlist

;	// create shortcut
	Gui, Font, s6 c000000, Verdana
	gui, add, button, w80 h35 x400 y290 gshortcutCreate, % T.CREATE_SHORTCUT

;	// window resolution
	Gui, Font, s7 norm cD8D8D8, Verdana
	gui, add, text, x220 y260 backgroundtrans, % T.WINDOW_RESOLUTION ":"
	Gui, Font, s7 c000000, Verdana
	gui, add, edit, x225 y275 w42 h18 limit4 center number -multi vwidth, %width%
	Gui, Font, s7 cD8D8D8, Verdana
	gui, add, text, x270 y275 backgroundtrans, x
	Gui, Font, s7 c000000, Verdana
	gui, add, edit, x280 y275 w42 h18 limit4 center number -multi vheight, %height%
	


;	// regnum path
	Gui, Font, s8 bold cD8D8D8, Verdana
	gui  add, text, backgroundtrans x10 y30, % T.REGNUM_PATH ":"
	Gui, Font, s7 cD8D8D8, Verdana
	gui, add, text, x10 w300 r2 y50 backgroundtrans vregnum_path, %regnum_path%
	Gui, Font, s7 c000000 norm, Verdana
	gui, add, button, x150 w80 y30 gpath_edit, % T.CHANGE

	Gui, Font, s8 c000000, Verdana

;	// hide NGE intro
	Gui, Font, s7 cD8D8D8, Verdana
	gui, add, checkbox, w%CBW% h%CBH% x10 y110 checked%skip_logo% backgroundtrans vskip_logo
	gui, add, text, x+3 yp backgroundtrans, % T.DELETE_SPLASH

;	// screenshot quality
	Gui, Font, s7 cD8D8D8, Verdana
	gui, add, checkbox, w%CBW% h%CBH% x10 y130 checked%screenshot_quality% backgroundtrans vscreenshot_quality
	gui, add, text, x+3 yp backgroundtrans, % T.SCREENSHOT_QUALITY

;	// screenshot autosave
	Gui, Font, s7 cD8D8D8, Verdana
	gui, add, checkbox, w%CBW% h%CBH% x10 y150 checked%screenshot_autosave% backgroundtrans vscreenshot_autosave
	gui, add, text, x+3 yp backgroundtrans, % T.SCREENSHOT_AUTOSAVE

;	// cl_update_all_resources
	Gui, Font, s7 cD8D8D8, Verdana
	gui, add, checkbox, w%CBW% h%CBH% x10 y170 checked%cl_update_all_resources% backgroundtrans vcl_update_all_resources
	gui, add, text, x+3 yp backgroundtrans, % T.UPDATE_ALL_RES

;	// debug mode
	Gui, Font, s7 cD8D8D8, Verdana
	gui, add, checkbox, w%CBW% h%CBH% x10 y190 checked%debug_mode% backgroundtrans vdebug_mode
	gui, add, text, x+3 yp backgroundtrans, % "debug mode (experimental)"

;	// change 64bit mode
	gui, add, checkbox, w%CBW% h%CBH% x10 y70 checked%win64% backgroundtrans vwin64
	gui, add, text, x+3 yp backgroundtrans, % T.64BIT_MODE
	
;	// hide loading screen	
	gui, add, checkbox, w%CBW% h%CBH% x10 y90 checked%hide_loading_screen% backgroundtrans vhide_loading_screen
	gui, add, text, x+3 yp backgroundtrans, % T.HIDE_LOADING_SCREEN

;	// conjurer mode
	Gui, Font, s7 cD8D8D8, Verdana
	gui, add, checkbox, x400 y220 checked%cl_invert_selection_priority% backgroundtrans w%CBW% h%CBH% vcl_invert_selection_priority
	gui, add, text, x+3 yp backgroundtrans, % T.CONJ_MODE

;	// fullscreen mode
	Gui, Font, s7 cD8D8D8, Verdana
	gui, add, checkbox, x400 y200 checked%vg_fullscreen_mode% backgroundtrans w%CBW% h%CBH% vvg_fullscreen_mode
	gui, add, text, x+3 yp backgroundtrans, % T.FULLSCREEN_MODE

;	// vsync
	Gui, Font, s7 cD8D8D8, Verdana
	gui, add, checkbox, x510 y200 checked%vg_vertical_sync% backgroundtrans w%CBW% h%CBH% vvg_vertical_sync
	gui, add, text, x+3 yp backgroundtrans, % T.VSYNC
	
;	// advanced ingame log
	Gui, Font, s7 cD8D8D8, Verdana
	gui, add, checkbox, x400 y40 checked%ingame_log% backgroundtrans w%CBW% h%CBH% vingame_log
	gui, add, text, x+3 yp backgroundtrans, % T.INGAME_LOG

;	// cl_crafting_show_min_level
	Gui, Font, s7 cD8D8D8, Verdana
	gui, add, checkbox, x400 y110 checked%cl_crafting_show_min_level% backgroundtrans w%CBW% h%CBH% vcl_crafting_show_min_level
	gui, add, text, x+3 yp backgroundtrans, % "cl_crafting_show_min_level (experimental)"

;	// cl_show_subclass_on_players
	Gui, Font, s7 cD8D8D8, Verdana
	gui, add, checkbox, x400 y90 checked%cl_show_subclass_on_players% backgroundtrans w%CBW% h%CBH% vcl_show_subclass_on_players
	gui, add, text, x+3 yp backgroundtrans, % "cl_show_subclass_on_players (experimental)"

;	// cl_show_hidden_armors
	Gui, Font, s7 cD8D8D8, Verdana
	gui, add, checkbox, x400 y70 checked%cl_show_hidden_armors% backgroundtrans w%CBW% h%CBH% vcl_show_hidden_armors
	gui, add, text, x+3 yp backgroundtrans, % "cl_show_hidden_armors (experimental)"
	
;	// server time and weather
	Gui, Font, s7 cD8D8D8, Verdana
	gui, add, checkbox, x400 y150 checked%dbg_ignore_server_time% backgroundtrans w%CBW% h%CBH% vdbg_ignore_server_time
	gui, add, text, x+3 yp backgroundtrans, % T.WEATHER
	gui, add, dropdownlist, x510 y150 w70 vserver_time AltSubmit, morning|afternoon|evening|night
	gui, add, dropdownlist, x590 y150 w50 vweather AltSubmit, clear|rainy|storm

;	// fake net lag
	gui, add, text, x10 y240 backgroundtrans, % T.NET_FAKE_LAG " (ms)"
	gui, add, edit, x150 y240 w60 h15 -multi vnet_fake_lag, %net_fake_lag%,
	
;	// run as windows user	
	gui, add, checkbox, x10 y260 checked%runas% w%CBW% h%CBH% grunasGuiToggled vrunas
	gui, add, text, x+3 y260 backgroundtrans, % T.RUN_AS ":"
	
;	// hide window boarder
	Gui, Font, s7 cD8D8D8, Verdana
	gui, add, checkbox, x220 y305 checked%hide_window_border% backgroundtrans w%CBW% h%CBH% vhide_window_border
	gui, add, text, x+3 yp backgroundtrans, % T.HIDE_WINDOW_BORDER

	Gui, Font, s7 c000000, Verdana
	gui, add, edit, x10 y280 w85 h18 -multi vrunas_name, %runas_name%
	Gui, Font, s7 cD8D8D8, Verdana
	gui, add, text, x20 y300 backgroundtrans vgui_runas_name_text, % "Windows " T.USER
	Gui, Font, s7 c000000, Verdana
	gui, add, edit, x109 y280 w85 h18 -multi vrunas_pw, %runas_pw%
	Gui, Font, s7 cD8D8D8, Verdana
	gui, add, text, x120 y300 backgroundtrans vgui_runas_pw_text, % "Win " T.PASSWORD
	Gui, Font, s6 cD8D8D8, Verdana
	gui, add, text, x80 y315 backgroundtrans vgui_runas_required_text, % "(" T.REQUIRED ")"
	Gui, Font, s7 cD8D8D8, Verdana
	
	gosub, runasGuiToggled

;	// language selection. this will change both regnums and regnumstarters language.	
	Gui, Font, s7 c000000, Verdana
	gui, add, dropdownlist, x480 y6 w45 vlanguage glanguage_changed, eng|deu|spa
	gosub, updateLanguageList



	Gui, Font, s13 bold cD8D8D8, Verdana
	gui, add, text, x620 backgroundtrans y4 gguiclose, X

	Gui, Margin , 0, 0
	Gui -Caption
	if(PosGuiX="" || PosGuiX<0)
		PosGuiX = center
	if(PosGuiY="" || PosGuiY<0)
		PosGuiY = center
	gui, show, w710 h450 x%PosGuiX% y%PosGuiY%, % T.WINDOW_TITLE " v" rs_version_release

	WinGet, GuiID, ID, A

return