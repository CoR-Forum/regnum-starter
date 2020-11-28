; 	// file includes all main functions related to the user interface.
; 	// some things might be splitted into seperated files for better overview and workflow.

; initialize the UI

make_gui:

    Gui -DPIScale
	SysGet, CBW, 71
	SysGet, CBH, 72
	cbw -= 2
	cbh  -= 2

	Gui, Color, EEAA99
	Gui +LastFound
	WinSet, TransColor, EEAA99

	if(PosGuiX="" || PosGuiX<0)
		PosGuiX = center
	if(PosGuiY="" || PosGuiY<0)
		PosGuiY = center

;	// display native windows title name - usually only seen when hovering over the task bar
	gui, show, w700 h486 x%PosGuiX% y%PosGuiY%, % T.WINDOW_TITLE " v" rs_version_release

;   // number generator for background image
  Random, BgNum , 2, 2 ; the function Random generates a number between 1 and 2 and sets it to the variable BgNum
  BgNumRound := Round(BgNum) ; variable BgNum will be round up or down and named BgNumRound

;		// add border

;		// randomly choose a background image based on the function above
  Gui, Add, Picture, x0 y0, %APPDATA%\bg_main_v5_0_1.png ; uses the previously generated BgNumRound variable


;	// Window title
	Gui, Font, s11 bold cD8D8D8, Verdana
	gui, add, text, x240 center y6 w140 h25 backgroundtrans, RegnumStarter

;	// version number next to the window title
	Gui, Font, s7 normal cD8D8D8, Verdana
	gui, add, text, x+5 y10 w120 h25 backgroundtrans, v%rs_version_release%

;	// cor logo
	Gui, Add, Picture, x570 y30 h85 w120 backgroundtrans, %APPDATA%\logo_cor.png

;	// discord and forum logo
	;Gui, Add, Picture, gDiscordLink x30 y440 h32 w32 backgroundtrans, %APPDATA%\logo_discord.png
	;Gui, Add, Picture, gForumLink x+15 y438 h40 w174 backgroundtrans, %APPDATA%\logo_forum.png
	;Gui, Add, Picture, gWikiLink x+1 y436 h40 w153 backgroundtrans, %APPDATA%\logo_wiki.png

	Gui, Add, Text, gForumLink x605 y460 backgroundtrans, cor-forum.de

;	// display RegnumNews.txt
	Gui, Font, s7 cD8D8D8, Verdana
	FileRead, RegnumNewsText, %APPDATA%/RegnumNews.txt
	Gui, Add, Text, x265 y55 w500 h255 backgroundtrans, %RegnumNewsText%

;	// quick access to options
	Gui, Font, bold s9 cD8D8D8, Verdana
	Gui, Add, Text, x90 y55 w500 h270 backgroundtrans, % T.UI_HEADING_QUICK_OPTIONS
	Gui, Font, s7 normal cD8D8D8, Verdana

; 	// settings
	Gui, Add, Picture, gSettings x70 y300 backgroundtrans, %APPDATA%\btn_blue_134px.png
	gui, add, Text, xp+20 yp+5 backgroundtrans, % T.UI_SETTINGS

;	// server status
	Gui, Font, bold s9 cD8D8D8, Verdana
	Gui, Add, Text, x80 y335 w500 h270 backgroundtrans, Server Status
	Gui, Font, normal s9 cD8D8D8, Verdana
	Gui, Add, Picture, x35 yp+25 backgroundtrans, %APPDATA%\circle-on.png
		Gui, Add, Text, x+10 yp w500 h270 backgroundtrans, Ra
	Gui, Add, Picture, x35 yp+20 backgroundtrans, %APPDATA%\circle-on.png
			Gui, Add, Text, x+10 yp w500 h270 backgroundtrans, Valhalla
	Gui, Add, Picture, x35 yp+20 backgroundtrans, %APPDATA%\circle-off.png
			Gui, Add, Text, x+10 yp w500 h270 backgroundtrans, Amun (Test Server)
	Gui, Font, s7 cD8D8D8, Verdana


; 	// account management
	Gui, Add, Picture, x263 y356 gAccounts backgroundtrans, %APPDATA%\btn_blue_134px.png
	gui, add, Text, xp+15 yp+5 backgroundtrans gAccounts, % T.MANAGE_ACCOUNTS

;	// create shortcut
	Gui, Add, Picture, gshortcutCreate x400 y356 backgroundtrans, %APPDATA%\btn_blue_134px.png
	gui, add, Text, xp+15 yp+5 backgroundtrans gshortcutCreate, % T.CREATE_SHORTCUT

;	// conjurer mode
	Gui, Font, s8 cD8D8D8, Verdana
	gui, add, checkbox, x550 y360 checked%cl_invert_selection_priority% backgroundtrans w%CBW% h%CBH% vcl_invert_selection_priority
	gui, add, text, x+3 yp backgroundtrans, % T.CONJ_MODE

; 	// user selection
	Gui, Font, s8 normal cD8D8D8, Verdana
	gui, add, dropdownlist, x260 y396 w200 vselected_user altsubmit
	goSub updateUserlist

; 	// server selection
	gui, add, dropdownlist, x+5 yp w70 vselected_server altsubmit
	gosub updateServerlist

; 	// login button
	Gui, Font, normal s11, Verdana
	Gui, Add, Picture, glogin x+8 y392 h30 w125 backgroundtrans, %APPDATA%\btn_green_162px.png
	gui, add, Text, xp+40 yp+5 BackgroundTrans, % T.LOGIN

;	// close on start
	;Gui, Font, s8 cD8D8D8, Verdana
	;gui, add, checkbox, w%CBW% h%CBH% xp y+8 checked%rs_close_on_login% backgroundtrans vrs_close_on_login
	;gui, add, text, x+3 yp backgroundtrans, close rs on login


;	// language selection. this will change both regnums and regnumstarters language.
	Gui, Font, s6 c000000, Verdana
	gui, add, dropdownlist, x620 y6 w45 vlanguage glanguage_changed, eng|deu|spa
	gosub, updateLanguageList

;	// close button
	Gui, Font, s12 cD8D8D8, Verdana
	gui, add, text, x680 backgroundtrans y4 gguiclose, 

	Gui, Margin , 0, 0
	Gui -Caption




	WinGet, GuiID, ID, A



return

