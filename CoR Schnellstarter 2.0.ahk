#persistent
#singleinstance off
setworkingdir %a_scriptDir%
if(!fileexist("data")) {
	msgbox, data Ordner nicht gefunden! Bitte pack diese Datei in das gleiche Verzeichnis wie der zugeh�rige "data" Ordner.
	exitapp
}
menu, tray, icon, data/icon.ico
coordmode,mouse,screen
	
users := Array()
goSub, readUsers

gosub, readConfig

servers := Array()
referers := Array()
gosub, readServerConfig
iniread, server_version, data/serverConfig.txt, version, version, -1
iniread, program_version, data/serverConfig.txt, version, program_version, -1

gosub GUI_

argc = %0%
if(argc >= 4) {
	gui,submit
	run_name = %1%
	run_pw = %2%
	run_referername = %3%
	run_servername = %4%
	run_runas = %5%
	run_runas_name = %6%
	run_runas_pw = %7%
	gosub run
	
	exitapp
}

settimer, updateServerConfig, -10

return
; //
updateServerConfig:
	tooltip, Hole Update Info...
	urldownloadtofile, http://www.cor-forum.de/regnum/schnellstarter/serverConfig.txt, data/serverConfig.txt
	iniread, server_version_new, data/serverConfig.txt, version, version, -1
	if(server_version_new > server_version) {
		msgbox, ,"CoR Schnellstarter - Metaupdate", "Server und Publisher wurden erfolgreich aktualisiert."
		reload
	}
	iniread, program_version_new, data/serverConfig.txt, version, program_version, -1
	if(program_version_new > program_version) {
		iniread, update_info, data/serverConfig.txt, version, update_info, -1
		if(update_info==-1 || empty(update_info)) {
		
		} else {
			msgbox, ,CoR Schnellstarter - Selfupdate", "CoR Schnellstarter erfolgreich auf Version `n aktualisiert." update_info
		}
	}
	tooltip
return
; ////
readUsers:
	loop, read, data/users.txt
		{
			blub := strsplit(a_loopreadline,":")
			users.push(new User(blub[1],blub[2],blub[3]))
		}
return
writeUsers:
	filedelete, data/users.txt
	for i,user in users {
		if(a_index>1)
			fileappend, `r`n, data/users.txt
		fileappend, % user.name ":" user.pw ":" user.comment, data/users.txt
	}
return
; ///
readConfig:
	user_last 		:= config_read("user_last",1)
		if(empty(user_last))
			user_last:=1
	server_last 	:= config_read("server_last",1)
	referer_last 	:= config_read("referer_last",1)
	skip_logo 		:= config_read("skip_logo",1)
	hide_loading_screen := config_read("hide_loading_screen",1)
	width 			:= config_read("width",1366)
	height			:=config_read("height",768)
	regnum_path		:=config_read("regnum_path","C:\Games\NGD Studios\Regnum Online\")
	runas			:=config_read("runas",-1)
	runas_name		:=config_read("runas_name",a_space)
	runas_pw		:=config_read("runas_pw",a_space)
	PosGuiX			:=config_read("PosGuiX",-1)
	PosGuiY			:=config_read("PosGuiY",-1)
	shortcut_last	:=config_read("shortcut_last",a_space)
return
writeConfig:
	config_write("user_last",gui_userlist)
	config_write("server_last",gui_serverlist)
	config_write("referer_last",gui_refererlist)
	config_write("skip_logo",gui_skip_logo)
	config_write("hide_loading_screen",gui_hide_loading_screen)
	config_write("width",gui_width)
	config_write("height",gui_height)
	config_write("regnum_path",regnum_path)
	config_write("runas",gui_runas)
	config_write("runas_name",gui_runas_name)
	config_write("runas_pw",gui_runas_pw)
	config_write("PosGuiX",PosGuiX)
	config_write("PosGuiY",PosGuiY)
	config_write("shortcut_last",shortcut_last)
return
; ////
readServerConfig:
	loop, read, data/serverConfig.txt
		{
			line := a_loopreadline
			if(instr(line,"#"))
				continue
			if(line=="[servers]") {
				wat := "servers"
				continue
			} else if(line=="[referers]") {
				wat := "referers"
				continue
			}
			blub := strsplit(line,",")
			if(wat=="servers") {
				servers.push(new Server(blub[1],blub[2],blub[3],blub[4]))
			}
			else if(wat=="referers")
				referers.push(new Referer(blub[1],blub[2]))
		}
return
; ///
onexit:
guiClose:
	gui,submit,nohide
	goSub writeUsers
	goSub writeConfig
exitapp
; ///
config_read(key,default) {
	iniread,tmp1,data/config.ini,config,%key%,%default%
	return tmp1
}
config_write(key,val) {
	iniwrite,%val%,data/config.ini,config,%key%
}
; ///
class User {
	name := "(empty)"
	pw := "(empty)"
	comment := "(empty)"
	
	__New(name,pw,comment) {
		this.name := name
		this.pw := pw
		this.comment := comment
	}
}
class Server {
	name := "(empty)"
	ip := "(empty)"
	port := "(empty)"
	retr := "(empty)"
	
	__New(name,ip,port,retr) {
		this.name := name
		this.ip := ip
		this.port := port
		this.retr := retr
	}
}
class Referer {
	name := "(empty)"
	token := "(empty)"
	
	__New(name,token) {
		this.name := name
		this.token := token
	}
}
; /////
empty(v) {
	if(strlen(v)<1)
		return true
	return false
}
; //////////////////////////////////
; //////////////////////////////////
; //////////////////////////////////
; //////////////////////////////////
GUI_:
	SysGet, CBW, 71
	SysGet, CBH, 72
	cbw -= 2
	cbh  -= 2
	
	Gui, Color, EEAA99
	Gui +LastFound
	WinSet, TransColor, EEAA99
	
	gui, add, picture, x0 y0, data\bckg.png

	Gui, Font, s8 bold, Verdana
	gui, add, button, w70 x36 y136 glogin, Login

	Gui, Font, s7 c000000, Verdana

	gui, add, dropdownlist, x11 y105 w125 vgui_userlist altsubmit
	goSub updateUserlist

	gui, add, button, x11 y77 w125 gaccounts_edit, Accounts verwalten

	gui, add, dropdownlist, x157 y77 w80 vgui_serverlist altsubmit
	gosub updateServerlist

	Gui, Font, s7 cD8D8D8, Verdana
	gui, add, text, x272 y90 backgroundtrans, Publisher:
	Gui, Font, s7 c000000, Verdana
	gui, add, dropdownlist, x256 y105 w80 vgui_refererlist altsubmit
	gosub updateRefererlist

	Gui, Font, s7 c000000, Verdana
	gui, add, button, w70 x36 y165 gshortcutCreate, Direktlink`nerstellen

	Gui, Font, s7 norm cD8D8D8, Verdana
	checked=
	if skip_logo = 1
		checked = checked
	gui, add, checkbox, w%CBW% h%CBH% x11 y217 %checked% backgroundtrans vgui_skip_logo
	gui, add, text, x+3 yp backgroundtrans, NGD/Gamigo-Vorspann l�schen
	
	checked=
	if hide_loading_screen = 1
		checked = checked
	gui, add, checkbox, w%CBW% h%CBH% x11 y237 %checked% backgroundtrans vgui_hide_loading_screen
	gui, add, text, x+3 yp backgroundtrans, Ladescreen ausblenden
	
	gui, add, text, x238 y259 backgroundtrans, Regnum-Aufl�sung:
	Gui, Font, s7 c000000, Verdana
	gui, add, edit, x237 y275 w42 h18 limit4 center number -multi vgui_width, %width%
	Gui, Font, s7 cD8D8D8, Verdana
	gui, add, text, x282 y276 backgroundtrans, x
	Gui, Font, s7 c000000, Verdana
	gui, add, edit, x293 y275 w42 h18 limit4 center number -multi vgui_height, %height%

	Gui, Font, s7 cD8D8D8, Verdana
	gui add,text, backgroundtrans x260 y145, Regnum-Pfad:
	Gui, Font, s7 bold cD8D8D8, Verdana
	gui, add, text, x256 w80 r2 y160 backgroundtrans vgui_regnum_path, %regnum_path%
	Gui, Font, s7 c000000 norm, Verdana
	gui, add, button, x256 w80 y189 gpath_edit, �ndern

	Gui, Font, s7 c009000, Verdana
	gui, add, text, x117 center y136 w130 h100 backgroundtrans, Mit diesem Programm wird der Update-Server umgangen! Neue Inhalte k�nnen nur �ber den normalen Launcher geladen werden!
	Gui, Font, s8 c000000, Verdana

	checked=
	if runas = 1
		checked = checked
	Gui, Font, s7 cD8D8D8, Verdana
	gui, add, checkbox, x11 y257 %checked% w%CBW% h%CBH% grunasGuiToggled vgui_runas
	gui, add, text, x29 y257 backgroundtrans, als anderer Win-Nutzer ausf�hren:
	Gui, Font, s7 c000000, Verdana
	gui, add, edit, x11 y275 w85 h18 -multi vgui_runas_name, %runas_name%
	Gui, Font, s7 cD8D8D8, Verdana
	gui, add, text, x18 y295 backgroundtrans vgui_runas02, Windows User
	Gui, Font, s7 c000000, Verdana
	gui, add, edit, x109 y275 w85 h18 -multi vgui_runas_pw, %runas_pw%
	Gui, Font, s7 cD8D8D8, Verdana
	gui, add, text, x118 y295 backgroundtrans vgui_runas03, Win Passwort
	Gui, Font, s5 cD8D8D8, Verdana
	gui, add, text, x133 y305 backgroundtrans vgui_runas04, (ben�tigt)
	Gui, Font, s7 cD8D8D8, Verdana
	
	gosub, runasGuiToggled

	Gui, Font, s13 bold cD8D8D8, Verdana
	gui, add, text, x320 backgroundtrans y4 gguiclose, X

	Gui, Margin , 0, 0
	Gui -Caption
	if(PosGuiX="" || PosGuiX<0)
		PosGuiX = center
	if(PosGuiY="" || PosGuiY<0)
		PosGuiY = center
	gui, show, w347 h317 x%PosGuiX% y%PosGuiY%, CoR Schnellstarter

	WinGet, GuiID, ID, A

return

runasGuiToggled:
	gui,submit,nohide
	if(gui_runas)
		wat:="show"
	else
		wat:="hide"
	guicontrol,1:%wat%,gui_runas_name
	guicontrol,1:%wat%,gui_runas_pw
	guicontrol,1:%wat%,gui_runas02
	guicontrol,1:%wat%,gui_runas03
	guicontrol,1:%wat%,gui_runas04
return

; //////
updateUserlist:
		userlist := ""
		for i,user in users {
			userlist .= "|" user.name
		}
		guicontrol, 1:, gui_userlist, %userlist%
		guicontrol, 1:choose, gui_userlist, %user_last%
return
; ///
updateServerlist:
		serverlist := ""
		for i,server in servers {
			serverlist .= "|" server.name
		}
		guicontrol, 1:, gui_serverlist, %serverlist%
		guicontrol, 1:choose, gui_serverlist, %server_last%
return
; ///
updateRefererlist:
		refererlist := ""
		for i,referer in referers {
			refererlist .= "|" referer.name
		}
		guicontrol, 1:, gui_refererlist, %refererlist%
		guicontrol, 1:choose, gui_refererlist, %referer_last%
return

; //////////////////
path_edit:
	fileselectfolder, p, *%regnum_path%,, Bitte w�hle das den Hauptordner von Regnum aus! zB. "Regnum Online", oder "Realms Online", evtl. "Champions of Regnum", ...
	ifnotinstring, p, \
		return
	regnum_path = %p%\
	guicontrol, 1:, gui_regnum_path, % regnum_path
return
; ///////////

guimin:
winminimize
return

; //////////////////////////

shortcutCreate:

	gui, submit, nohide
	user := users[gui_userlist]
	server := servers[gui_serverlist]
	referer := referers[gui_refererlist]
	
	fileselectfile, shortcut, S18, % shortcut_last "\" user.name " " server.name " Login", % "W�hle den Speicherort f�r die Verkn�pfung f�r " user.name " " server.name " aus!"
	ifnotinstring, shortcut, \
		return
		
	pw := MD5_( user.pw , StrLen( user.pw ))
	
	params := """" user.name """ " pw " " referer.name " " server.name " " gui_runas " """ gui_runas_name """ """ gui_runas_pw """"
	if(a_iscompiled) {
		exe = "%A_ScriptFullPath%"
		filecreateshortcut, %exe%, %shortcut%.lnk, %a_workingDir%,% params,, data\icon.ico
	} else {
		script = "%A_ScriptFullPath%"
		filecreateshortcut,"%a_ahkpath%", %shortcut%.lnk, %a_workingDir%,% script " " params,, data\icon.ico
	}
	
	if(errorlevel) {
		msgbox, Direktlink Erstellung war nicht erfolgreich.
	} else {
		wat :=  user.name " " pw " " referer.name " " server.name
		if(gui_runas==1)
			wat .= " " gui_runas_name " " gui_runas_pw
		msgbox, Direktlink Erstellung erfolgreich erstellt f�r folgende Werte:`n%wat%
	}
	
	shortcut_last := shortcut
	
return

; ////////////////////////
accounts_edit:
	gui, 1:+disabled
	Gui, 2:Font, s8 c000000, Verdana
	gui, 2:add, text, x+40 y+6, Name`t`t`tPasswort`t`tKommentar
	if(users.Length()==0)
		users.push(new User("","",""))
	for i,user in users {
		y := 0 + a_index * 28
		Gui, 2:Font, s8 c000000, Verdana
		gui, 2:add, edit, -multi x20 y%y% w130 vgui_user%a_index%, % user.name
		Gui, 2:Font, s8 c9B0000, Verdana
		gui, 2:add, edit, -multi x160 y%y% w130 vgui_pw%a_index%, % user.pw
		Gui, 2:Font, s8 c000000, Verdana
		gui, 2:add, edit, -multi r1 x300 y%y% w130 vgui_comment%a_index%, % user.comment
	}
	gui, 2:add, button, ggui2_add x20,+
	gui, 2:add, button, g2guiok x180, Ok
	gui, 2:add, button, g2guicancel x180 yp+0 xp+38, Cancel
	gui, 2:show	
return

gui2_add:
	gosub 2guiok
	users.push(new User("","",""))
	gosub accounts_edit
return

2guiok:
	gui, 2:submit, nohide
	gui, 2:+disabled
	; Update users:
	amnt := users.Length()
	users := Array()
	loop, % amnt
	{
		name:= gui_user%a_index%
		pw:=gui_pw%a_index%
		comment:=gui_comment%a_index%
		if(empty(name) || empty(pw))
			continue
		users.push(new User(name,pw,comment))
	}
	
	; apply users to gui1:
	goSub updateUserlist
	gosub 2guiclose
return

2guiclose:
2guicancel:	
	gui, 1:-disabled
	gui, 2:-disabled
	gui, 2:destroy
	winactivate, ahk_id %GUIID%
return
; ////////////

login:
	gosub setupParams
	gosub run
return

setupParams:
	gui,submit,nohide
	user := users[gui_userlist]
	server := servers[gui_serverlist]
	referer := referers[gui_refererlist]
	run_pw := MD5_( user.pw , StrLen( user.pw ))
	run_name := user.name
	run_referername := referer.name
	if(run_pw==-1) {
		msgbox, Fehler beim Login: 20
		return
	}
	run_servername := server.name
	run_runas := gui_runas
	run_runas_name := gui_runas_name
	run_runas_pw := gui_runas_pw
return

run:	
	live = %regnum_path%LiveServer\
	test = %regnum_path%TestServer\
	ifnotexist, %regnum_path%game.cfg
	{
		msgbox, Regnum-Ordnerpfad unzul�ssig! (keine game.cfg gefunden)
		return
	}
	filegetsize, size, %regnum_path%game.cfg, K
	if(size<0.5) {
		msgbox, Regnum-Ordnerpfad unzul�ssig! (game.cfg gefunden, aber kleiner als 0.1 KB)
		return
	}
	if(empty(gui_width) || empty(gui_height)){
		msgbox, Bitte w�hle eine Aufl�sung!
		return
	}
	server := -1
	for i,s in servers {
		if(s.name == run_servername) {
			server := s
			break
		}
	}
	if(server==-1) {
		msgbox Server "%run_servername%" nicht vorhanden!
		return
	}
	referer := -1
	for i,s in referers {
		if(s.name == run_referername) {
			referer := s
			break
		}
	}
	if(referer==-1) {
		msgbox Referer "%run_referername%" nicht vorhanden!
		return
	}
	
	if(empty(run_pw) || empty(run_name)) {
		msgbox Du hast keinen Account ausgew�hlt! W�hle zuerst "Accounts verwalten" aus!
		return
	}
	
	iniwrite,% server.ip,%regnum_path%game.cfg,server,sv_game_server_host
	iniwrite,% server.port,%regnum_path%game.cfg,server,sv_game_server_tcp_port
	iniwrite,% server.retr,%regnum_path%game.cfg,server,sv_retriever_host
	iniwrite,% referer.token,%regnum_path%game.cfg,client,cl_referer
	show := ! gui_hide_loading_screen
	iniwrite,% show,%regnum_path%game.cfg,client,cl_show_loading_screen
	iniwrite,% gui_width,%regnum_path%game.cfg,video_graphics,vg_screen_width
	iniwrite,% gui_height,%regnum_path%game.cfg,video_graphics,vg_screen_height

	if(gui_skip_logo==1) {
		filedelete, %live%splash.ngz
		filedelete, %live%splash_ngd.ogg
		filedelete, %live%splash_gmg.png
		filedelete, %live%splash.ngz
		filedelete, %live%splash_ngd.ogg
		filedelete, %live%splash_gmg.png
	}

	if(server.name == "Amun") {
		ifnotexist, %test%ROClientGame.exe
		{
			msgbox, Regnum-Ordnerpfad unzul�ssig (keine ROClientGame.exe im TestServer-Ordner gefunden) [Amun]
			return
		}
	} else {
		ifnotexist, %live%ROClientGame.exe
		{
			msgbox, Regnum-Ordnerpfad unzul�ssig (keine ROClientGame.exe im LiveServer-Ordner gefunden)
			return
		}
	}
	  
	if run_runas = 1
	{
		runas, %run_runas_name%, %run_runas_pw%
	}
	else
		runas
	 
	if(server.name == "Amun") {
		run "%test%ROClientGame.exe" %run_name% %run_pw%, %test%, UseErrorLevel
	}
	else
	{
		run "%live%ROClientGame.exe" %run_name% %run_pw%, %live%, UseErrorLevel
	}
	if(errorlevel == "ERROR") {
		msgbox, Falsche Windows-Benutzeraccount-Daten!
		return
	}

return



; /////////////////////


~LButton::
errorlevel_safe := errorlevel
MouseGetPos, MouseStartX, MouseStartY, MouseWin, MouseControl
if MouseWin <> %GuiID%
  {
	errorlevel := errorlevel_safe
	return
  }
ifinstring, MouseControl, edit
  {
	errorlevel := errorlevel_safe
	return
  }
ifinstring, MouseControl, combobox
  {
	errorlevel := errorlevel_safe
	return
  }
ifinstring, MouseControl, button
  {
	errorlevel := errorlevel_safe
	return
  }
SetTimer, WatchMouse, 10
errorlevel := errorlevel_safe
return

WatchMouse:
GetKeyState, LButtonState, LButton, P
if LButtonState = U  ; Button has been released, so drag is complete.
{
			wingetpos, OL_Ecke_GuiX, OL_Ecke_GuiY,,,, Server
			PosGuiX = %OL_Ecke_GuiX%
			PosGuiY = %Ol_Ecke_GuiY%
	SetTimer, WatchMouse, off
	errorlevel := errorlevel_safe
	return
}
MouseGetPos, MouseX, MouseY
DeltaX = %MouseX%
DeltaX -= %MouseStartX%
DeltaY = %MouseY%
DeltaY -= %MouseStartY%
MouseStartX = %MouseX%
MouseStartY = %MouseY%
WinGetPos, GuiX, GuiY,,, ahk_id %GuiID%
GuiX += %DeltaX%
GuiY += %DeltaY%
SetWinDelay, -1   ; Makes the below move faster/smoother.
WinMove, ahk_id %GuiID%,, %GuiX%, %GuiY%
errorlevel := errorlevel_safe
return









md5_(string, case := False)    ; by SKAN | rewritten by jNizM
{
    static MD5_DIGEST_LENGTH := 16
    hModule := DllCall("LoadLibrary", "Str", "advapi32.dll", "Ptr")
    , VarSetCapacity(MD5_CTX, 104, 0), DllCall("advapi32\MD5Init", "Ptr", &MD5_CTX)
    , DllCall("advapi32\MD5Update", "Ptr", &MD5_CTX, "AStr", string, "UInt", StrLen(string))
    , DllCall("advapi32\MD5Final", "Ptr", &MD5_CTX)
    loop % MD5_DIGEST_LENGTH
        o .= Format("{:02" (case ? "X" : "x") "}", NumGet(MD5_CTX, 87 + A_Index, "UChar"))
    return o, DllCall("FreeLibrary", "Ptr", hModule)
} ;https://autohotkey.com/boards/viewtopic.php?f=6&t=21





































