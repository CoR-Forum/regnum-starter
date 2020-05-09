; 	// file includes all main functions related to the user interface.
; 	// some things might be splitted into seperated files for better overview and workflow.

; initialize the UI
make_gui:
	SysGet, CBW, 71
	SysGet, CBH, 72
	cbw -= 2
	cbh  -= 2

	Gui, Color, EEAA99
	Gui +LastFound
	WinSet, TransColor, EEAA99

;	// display native windows title name - usually only seen when hovering over the task bar
	gui, show, w710 h450 x%PosGuiX% y%PosGuiY%, % T.WINDOW_TITLE " v" rs_version_release

;   // number generator for background image
  Random, BgNum , 1, 1 ; the function Random generates a number between 1 and 2 and sets it to the variable BgNum
  BgNumRound := Round(BgNum) ; variable BgNum will be round up or down and named BgNumRound

;		// randomly choose a background image based on the function above
  Gui, Add, Picture, x0 y0, %APPDATA%\bg%BgNumRound%.png ; uses the previously generated BgNumRound variable


;	// Window title
	Gui, Font, s10 bold cD8D8D8, Verdana
	gui, add, text, x240 center y7 w120 h25 backgroundtrans, RegnumStarter

;	// version number next to the window title
	Gui, Font, s7 cD8D8D8, Verdana
	gui, add, text, x+2 center y10 w120 h25 backgroundtrans, %rs_version_release%

;	// discord and forum logo
	Gui, Add, Picture, gDiscordLink x20 y380 h60 w61 backgroundtrans, %APPDATA%\logo_discord.png
	Gui, Add, Picture, gForumLink x90 y390 h45 w196 backgroundtrans, %APPDATA%\logo_forum.png

;	// display RegnumNews.txt
	Gui, Font, s7 cD8D8D8, Verdana
	FileRead, RegnumNewsText, %APPDATA%/RegnumNews.txt
	Gui, Add, Text, x20 y50 w500 h250 backgroundtrans, %RegnumNewsText%

; 	// graphic settings
	gui, add, button, x445 y280 h40 w80 ggraphic_settings, % T.SETTINGS

;	// conjurer mode
	Gui, Font, s7 cD8D8D8, Verdana
	gui, add, checkbox, xp y+10 checked%cl_invert_selection_priority% backgroundtrans w%CBW% h%CBH% vcl_invert_selection_priority
	gui, add, text, x+3 yp backgroundtrans, % T.CONJ_MODE

; 	// account management
	gui, add, button, xp y+10 w80 h35 gManageAccounts, % T.MANAGE_ACCOUNTS

;	// create shortcut
	gui, add, button, w80 h35 xp y+10 gshortcutCreate, % T.CREATE_SHORTCUT

; 	// user selection
	gui, add, dropdownlist, x+20 y310 w120 vselected_user altsubmit
	goSub updateUserlist

; 	// server selection
	gui, add, dropdownlist, xp y+10 w120 vselected_server altsubmit
	gosub updateServerlist

; 	// login button
	Gui, Font, s10 bold, Verdana
	gui, add, button, w140 h35 x550 y390 glogin, % T.LOGIN

;	// language selection. this will change both regnums and regnumstarters language.
	Gui, Font, s7 c000000, Verdana
	gui, add, dropdownlist, x480 y6 w45 vlanguage glanguage_changed, eng|deu|spa
	gosub, updateLanguageList


;	// close button
	Gui, Font, s13 bold cD8D8D8, Verdana
	gui, add, text, x620 backgroundtrans y4 gguiclose, X

	Gui, Margin , 0, 0
	Gui -Caption
	if(PosGuiX="" || PosGuiX<0)
		PosGuiX = center
	if(PosGuiY="" || PosGuiY<0)
		PosGuiY = center




	WinGet, GuiID, ID, A

return
