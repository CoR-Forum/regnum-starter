; 	// file includes all main functions related to the user interface.
; 	// some things might be splitted into seperated files for better overview and workflow.

; initialize the UI

#Include %A_ScriptDir%\lib\shortcut.ahk

gui_main:

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

  	Gui, Add, Picture, x0 y0, %APPDATA%\bg_main_v5_0_1.png

;	// Window title
	Gui, Font, s11 bold cD8D8D8, Verdana
	gui, add, text, x240 center y6 backgroundtrans, RegnumStarter

;	// version number next to the window title
	Gui, Font, s7 normal cD8D8D8, Verdana
	gui, add, text, x+5 y10 w120 h25 backgroundtrans, v%rs_version_release%

;	// cor logo
	Gui, Add, Picture, x570 y30 h85 w120 backgroundtrans, %APPDATA%\logo_cor.png

;	// discord and forum logo
	;Gui, Add, Picture, gDiscordLink x30 y440 h32 w32 backgroundtrans, %APPDATA%\logo_discord.png
	Gui, Add, Picture, gForumLink x30 y434 h40 w174 backgroundtrans, %APPDATA%\logo_forum.png
	;Gui, Add, Picture, gWikiLink x+1 y436 h40 w153 backgroundtrans, %APPDATA%\logo_wiki.png
Gui, Font, normal s7 underline, Verdana
;Gui, Add, Text, ggui7_Changelogs x540 y460 backgroundtrans, changelogs
	;Gui, Add, Text, gForumLink x605 y460 backgroundtrans, cor-forum.de

;	// display RegnumNews.txt
	Gui, Font, normal s7 cD8D8D8, Verdana
	; FileRead, RegnumNewsText, %APPDATA%/ronews.txt
	Gui, Add, Text, x265 y55 w500 h265 backgroundtrans, %RegnumNewsText%

;	// settings heading
	Gui, Font, bold s9 cD8D8D8, Verdana
	Gui, Add, Text, x90 y340 w500 h270 backgroundtrans, % T.UI_HEADING_QUICK_OPTIONS
	Gui, Font, s7 normal cD8D8D8, Verdana

; // settings
	Gui, Add, Picture, gSettings x70 y370 backgroundtrans, %APPDATA%\btn_blue_134px.png
	gui, add, Text, xp+20 yp+5 backgroundtrans, % T.UI_SETTINGS

; // screenshot folder
	Gui, Add, Picture, x263 y334 gOpenScreenshotsFolder backgroundtrans, %APPDATA%\btn_blue_134px.png
	gui, add, Text, xp+25 yp+4 backgroundtrans, Screenshots

; // account management
	Gui, Add, Picture, x263 y358 gAccounts backgroundtrans, %APPDATA%\btn_blue_134px.png
	gui, add, Text, xp+15 yp+4 backgroundtrans, % T.MANAGE_ACCOUNTS

;	// create shortcut
	Gui, Add, Picture, gshortcutCreate x400 y358 backgroundtrans, %APPDATA%\btn_blue_134px.png
	gui, add, Text, xp+15 yp+4 backgroundtrans, % T.CREATE_SHORTCUT

;	// conjurer mode
	Gui, Font, s8 cD8D8D8, Verdana
	gui, add, checkbox, x550 y362 checked%cl_invert_selection_priority% backgroundtrans w%CBW% h%CBH% vcl_invert_selection_priority
	gui, add, text, x+3 yp backgroundtrans, % T.CONJ_MODE

; // user selection
	Gui, Font, s8 normal cD8D8D8, Verdana
	gui, add, dropdownlist, x262 y396 w200 gwriteAllConfigs vselected_user altsubmit
	goSub updateUserlist

; 	// server selection
	gui, add, dropdownlist, x+5 yp w70 gwriteAllConfigs vselected_server altsubmit
	gosub updateServerlist

; 	// login button
	Gui, Font, normal s11, Verdana
	Gui, Add, Picture, glogin x+8 y392 h30 w125 backgroundtrans, %APPDATA%\btn_green_162px.png
	gui, add, Text, xp+40 yp+5 BackgroundTrans, % T.LOGIN

; 	// notes
	;Gui, Font, s7 cD8D8D8, Verdana
	;Gui, Add, Picture, x34 y443 gNotes backgroundtrans, %APPDATA%\btn_blue_70px.png
	;gui, add, Text, xp+20 yp+4 backgroundtrans, Notes

;	// close on start
	Gui, Font, s8 cD8D8D8, Verdana
	gui, add, checkbox, w%CBW% h%CBH% x550 y450 checked%rs_close_on_login% backgroundtrans vrs_close_on_login
	gui, add, text, x+3 yp backgroundtrans, close rs on login


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

language_changed:
goSub, writeAllConfigs
reload
