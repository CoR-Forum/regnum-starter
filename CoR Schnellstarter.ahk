#persistent
#singleinstance off
setworkingdir %a_scriptDir%

BASE_URL = http://www.cor-forum.de/regnum/schnellstarter/

language = de
gosub, setTranslations

gosub checkDataFolder

try menu, tray, icon, data/icon.ico
coordmode,mouse,screen

goSub, readUsers
gosub, readUserConfig
gosub, readServerConfig
iniread, server_version, data/serverConfig.txt, version, version, -1
iniread, program_version, data/serverConfig.txt, version, program_version, -1
iniread, autopatch_server, data/serverConfig.txt, general, autopatch_server

gosub make_gui

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
} else {
	tooltip, % T.CHECKING_UPDATES
	settimer, updateServerConfig, -10
	tooltip
}

return
; //
checkDataFolder:
	if(!fileexist("data")) {
		FileCreateDir, data
		if(errorlevel) {
			msgbox, % T.COULD_NOT_CREATE_DATA_FOLDER ": " errorlevel
			exitapp
		}
	}
	for k,v in ["data/bckg.png", "data/icon.ico"] {
		if(!FileExist(v)) {
			tooltip, Downloading %v%...
			UrlDownloadToFile, %BASE_URL%%v%, %v%
			if(errorlevel) { ; note: no error will be detected when response is an error message like 404
				msgbox, % "Downloading " v " " T.FAILED ": " errorlevel
			}
		}
	}
return
updateServerConfig:
	urldownloadtofile, *0 %BASE_URL%serverConfig.txt?disablecache=%A_TickCount%, data/serverConfig.txt
	iniread, server_version_new, data/serverConfig.txt, version, version, -1
	if(server_version_new > server_version) {
		msgbox, ,"CoR Schnellstarter - Metaupdate", % T.SERVERS_PUBLISHERS_UPDATED
		reload
	}
	iniread, program_version_new, data/serverConfig.txt, version, program_version, -1
	if(program_version_new > program_version) {
		iniread, update_info, data/serverConfig.txt, version, update_info, -1
		if(update_info==-1 || empty(update_info)) {
		
		} else {
			msgbox, ,CoR Schnellstarter - Programmupdate, % T.NEW_UPDATE_AVAILABLE ": `n" update_info
		}
	}
return
; //
patchLiveGamefile(file) {
	global autopatch_server
	global live
	url = %autopatch_server%/autopatch/autopatch_files_rgn/%file%?nocache
	livefile = %live%%file%
	tooltip, Downloading %url%...
	urldownloadtofile, % "*0 " url, % livefile
	if(errorlevel) {
		msgbox, % "Downloading " url " --> " livefile " " T.FAILED "."
		return false
	}
	tooltip
	return true
}
updateGamefiles:
	ifnotexist, %live%ROClientGame.exe
	{
		; Download all necessary files if not present
		msgbox, 4, Regnum Download, % T.LIVE_GAME_MISSING ":`n" regnum_path "`n" T.DOWNLOAD_LIVE_GAME_NOW
		ifmsgbox, No
			goto exitThread ; and I am sorry
		if(!FileExist(live))
			FileCreateDir, %live%
		for k,file in ["ROClientGame.exe", "shaders.ngz", "scripts.ngz", "current_build", "steam_api.dll", "openal.dll"] ; dbghelp.dll, libbz2.dll, libjpeg62.dll, libpng13.dll, libtheora.dll, libzip.dll, ngdlogo.png, ogg.dll, readme.txt, resources, splash_ngd.ogg, steamclient.dll, Steam.dll, tier0_s.dll, vorbis.dll, vorbisfile.dll, vstdlib_s.dll, zlib1.dll
			if(!FileExist(file))
				if(!patchLiveGamefile(file))
					goto exitThread
		msgbox, % T.DOWNLOADING_LIVE_GAME_FINISHED
	} else {
		; Check if update available, then download and overwrite those files that might contain changes
		tooltip, % T.CHECKING_GAME_UPDATES
		fileRead, current_build, %live%current_build
		patchLiveGamefile("current_build")
		fileRead, current_build_new, %live%current_build
		if(!empty(current_build_new) && current_build != current_build_new) {
			msgbox, 1, Regnum Update, % T.NOTICED_NEW_UPDATE
			IfMsgBox, Cancel
			{
				FileDelete, %live%current_build
				goto exitThread
			}
			for k,file in ["ROClientGame.exe", "shaders.ngz", "scripts.ngz"]
				patchLiveGamefile(file)
			msgbox, % T.UPDATING_FINISHED
		}
		tooltip
	}
return
exitThread:
	gui, 1:-disabled
	tooltip
exit
; ////
readUsers:
	users := Array()
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
readUserConfig:
	; name: defaultvalue
	configEntries := {selected_user: 1,selected_server: 1,selected_referer: 1,skip_logo: 1,hide_loading_screen: 0,width: 1366,height: 768,regnum_path: "C:\Games\NGD Studios\Champions of Regnum\",runas: 0,runas_name: a_space,runas_pw: a_space,PosGuiX: -1,PosGuiY: -1,shortcut_last: a_space}
	for k,default in configEntries {
		%k% := config_read(k, default)
	}
return
writeConfig:
	for k,v in configEntries {
		config_write(k, %k%)
	}
return
; ////
readServerConfig:
	servers := Array()
	referers := Array()
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
	name := "(" T.EMPTY ")"
	pw := "(" T.EMPTY ")"
	comment := "(" T.EMPTY ")"
	
	__New(name,pw,comment) {
		this.name := name
		this.pw := pw
		this.comment := comment
	}
}
class Server {
	name := "(" T.EMPTY ")"
	ip := "(" T.EMPTY ")"
	port := "(" T.EMPTY ")"
	retr := "(" T.EMPTY ")"
	
	__New(name,ip,port,retr) {
		this.name := name
		this.ip := ip
		this.port := port
		this.retr := retr
	}
}
class Referer {
	name := "(" T.EMPTY ")"
	token := "(" T.EMPTY ")"
	
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
make_gui:
	SysGet, CBW, 71
	SysGet, CBH, 72
	cbw -= 2
	cbh  -= 2
	
	Gui, Color, EEAA99
	Gui +LastFound
	WinSet, TransColor, EEAA99
	
	gui, add, picture, x0 y0, data\bckg.png

	Gui, Font, s8 bold, Verdana
	gui, add, button, w70 x36 y136 glogin, % T.LOGIN

	Gui, Font, s7 c000000, Verdana

	gui, add, dropdownlist, x11 y105 w125 vselected_user altsubmit
	goSub updateUserlist

	gui, add, button, x11 y77 w125 gaccounts_edit, % T.MANAGE_ACCOUNTS

	gui, add, dropdownlist, x157 y77 w80 vselected_server altsubmit
	gosub updateServerlist

	Gui, Font, s7 cD8D8D8, Verdana
	gui, add, text, x272 y90 backgroundtrans, % T.PUBLISHER ":"
	Gui, Font, s7 c000000, Verdana
	gui, add, dropdownlist, x256 y105 w80 vselected_referer altsubmit
	gosub updateRefererlist

	Gui, Font, s7 c000000, Verdana
	gui, add, button, w70 x36 y165 gshortcutCreate, % T.CREATE_SHORTCUT

	Gui, Font, s7 norm cD8D8D8, Verdana
	gui, add, checkbox, w%CBW% h%CBH% x11 y217 checked%skip_logo% backgroundtrans vskip_logo
	gui, add, text, x+3 yp backgroundtrans, % T.DELETE_SPLASH
	
	gui, add, checkbox, w%CBW% h%CBH% x11 y237 checked%hide_loading_screen% backgroundtrans vhide_loading_screen
	gui, add, text, x+3 yp backgroundtrans, % T.HIDE_LOADING_SCREEN
	
	gui, add, text, x238 y259 backgroundtrans, % T.WINDOW_RESOLUTION ":"
	Gui, Font, s7 c000000, Verdana
	gui, add, edit, x237 y275 w42 h18 limit4 center number -multi vwidth, %width%
	Gui, Font, s7 cD8D8D8, Verdana
	gui, add, text, x282 y276 backgroundtrans, x
	Gui, Font, s7 c000000, Verdana
	gui, add, edit, x293 y275 w42 h18 limit4 center number -multi vheight, %height%

	Gui, Font, s7 cD8D8D8, Verdana
	gui add,text, backgroundtrans x260 y145, % T.REGNUM_PATH ":"
	Gui, Font, s7 bold cD8D8D8, Verdana
	gui, add, text, x256 w80 r2 y160 backgroundtrans vregnum_path, %regnum_path%
	Gui, Font, s7 c000000 norm, Verdana
	gui, add, button, x256 w80 y189 gpath_edit, % T.CHANGE

	Gui, Font, s7 c009000, Verdana
	gui, add, text, x117 center y136 w130 h100 backgroundtrans, .
	Gui, Font, s8 c000000, Verdana

	Gui, Font, s7 cD8D8D8, Verdana
	gui, add, checkbox, x11 y257 checked%runas% w%CBW% h%CBH% grunasGuiToggled vrunas
	gui, add, text, x29 y257 backgroundtrans, % T.RUN_AS ":"
	Gui, Font, s7 c000000, Verdana
	gui, add, edit, x11 y275 w85 h18 -multi vrunas_name, %runas_name%
	Gui, Font, s7 cD8D8D8, Verdana
	gui, add, text, x18 y295 backgroundtrans vgui_runas_name_text, % "Windows " T.USER
	Gui, Font, s7 c000000, Verdana
	gui, add, edit, x109 y275 w85 h18 -multi vrunas_pw, %runas_pw%
	Gui, Font, s7 cD8D8D8, Verdana
	gui, add, text, x118 y295 backgroundtrans vgui_runas_pw_text, % "Win " T.PASSWORD
	Gui, Font, s5 cD8D8D8, Verdana
	gui, add, text, x133 y305 backgroundtrans vgui_runas_required_text, % "(" T.REQUIRED ")"
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
	gui, show, w347 h317 x%PosGuiX% y%PosGuiY%, % T.WINDOW_TITLE

	WinGet, GuiID, ID, A

return

runasGuiToggled:
	gui,submit,nohide
	if(runas)
		wat:="show"
	else
		wat:="hide"
	guicontrol,1:%wat%,runas_name
	guicontrol,1:%wat%,runas_pw
	guicontrol,1:%wat%,gui_runas_name_text
	guicontrol,1:%wat%,gui_runas_pw_text
	guicontrol,1:%wat%,gui_runas_required_text
return

; //////
updateUserlist:
		userlist := ""
		for i,user in users {
			userlist .= "|" user.name
		}
		guicontrol, 1:, selected_user, %userlist%
		if(empty(selected_user))
			selected_user:=1
		guicontrol, 1:choose, selected_user, %selected_user%
return
; ///
updateServerlist:
		serverlist := ""
		for i,server in servers {
			serverlist .= "|" server.name
		}
		guicontrol, 1:, selected_server, %serverlist%
		guicontrol, 1:choose, selected_server, %selected_server%
return
; ///
updateRefererlist:
		refererlist := ""
		for i,referer in referers {
			refererlist .= "|" referer.name
		}
		guicontrol, 1:, selected_referer, %refererlist%
		guicontrol, 1:choose, selected_referer, %selected_referer%
return

; //////////////////
path_edit:
	fileselectfolder, p, *%regnum_path%,, % T.SELECT_PATH
	ifnotinstring, p, \
		return
	regnum_path = %p%\
	guicontrol, 1:, regnum_path, % regnum_path
return
; ///////////

guimin:
winminimize
return

; //////////////////////////

shortcutCreate:

	gui, submit, nohide
	user := users[selected_user]
	server := servers[selected_server]
	referer := referers[selected_referer]
	
	fileselectfile, shortcut, S18, % shortcut_last "\" user.name " " server.name " Login", % T.CHOOSE_LINK_DESTINATION_FOR " " user.name " " server.name
	ifnotinstring, shortcut, \
		return
		
	pw := MD5(user.pw)
	
	params := """" user.name """ " pw " " referer.name " " server.name " " runas " """ runas_name """ """ runas_pw """"
	if(a_iscompiled) {
		exe = "%A_ScriptFullPath%"
		filecreateshortcut, %exe%, %shortcut%.lnk, %a_workingDir%,% params,, data\icon.ico
	} else {
		script = "%A_ScriptFullPath%"
		filecreateshortcut,"%a_ahkpath%", %shortcut%.lnk, %a_workingDir%,% script " " params,, data\icon.ico
	}
	
	if(errorlevel) {
		msgbox, % T.CREATE_LINK_FAILED
	} else {
		wat :=  user.name " " pw " " referer.name " " server.name
		if(runas==1)
			wat .= " " runas_name " " runas_pw
		msgbox, % T.CREATE_LINK_SUCCESS_FOR ":`n" wat
	}
	
	shortcut_last := shortcut
	
return

; ////////////////////////
accounts_edit:
	gui, 1:+disabled
	Gui, 2:Font, s8 c000000, Verdana
	gui, 2:add, text, x+40 y+6, % T.NAME "`t`t`t" T.PASSWORD "`t`t" T.COMMENT
	if(users.Length()==0)
		users.push(new User("","",""))
	for i,user in users {
		y := 0 + a_index * 28
		Gui, 2:Font, s8 c000000, Verdana
		gui, 2:add, edit, -multi x20 y%y% w130 vuser%a_index%, % user.name
		Gui, 2:Font, s8 c9B0000, Verdana
		gui, 2:add, edit, -multi x160 y%y% w130 vpw%a_index%, % user.pw
		Gui, 2:Font, s8 c000000, Verdana
		gui, 2:add, edit, -multi r1 x300 y%y% w130 vcomment%a_index%, % user.comment
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
		if(empty(user%a_index%) || empty(pw%a_index%))
			continue
		users.push(new User(user%a_index%,pw%a_index%,comment%a_index%))
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
	user := users[selected_user]
	server := servers[selected_server]
	referer := referers[selected_referer]
	run_pw := MD5(user.pw)
	run_name := user.name
	run_referername := referer.name
	run_servername := server.name
	run_runas := runas
	run_runas_name := runas_name
	run_runas_pw := runas_pw
return

run:	
	live = %regnum_path%LiveServer\
	test = %regnum_path%TestServer\

	;;;;;;;; USER INPUT VALIDATION

	if(empty(width) || empty(height)){
		msgbox, % T.CHOOSE_RESOLUTION
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
		msgbox, % T.NO_SUCH_SERVER ": " run_servername
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
		msgbox % T.NO_SUCH_PUBLISHER ": " run_referername
		return
	}
	
	if(empty(run_pw) || empty(run_name)) {
		msgbox % T.NO_ACCOUNT_CHOSEN
		return
	}

	;;;;;;;; CHECK / DOWNLOAD / UPDATE LIVESERVER

	gui, 1:+disabled
	gosub updateGamefiles
	gui, 1:-disabled

	;;;;;;;; CHECK AMUN

	if(server.name == "Amun") {
		ifnotexist, %test%ROClientGame.exe
		{
			msgbox, % T.TEST_GAME_MISSING
			return
		}
	}

	;;;;;;;; GAME.CFG

	gamecfg := regnum_path "game.cfg"
	if(!FileExist(gamecfg)) {
		FileAppend, [Regnum Config File], %gamecfg% ; somehow fixes weird iniwrite behaviour
		iniwrite, .., %gamecfg%, client, cl_sdb_path ; would otherwise wrongly be set to "." afterwards, when the file is being filled up by the game itself (as apposed to the one included in the installers where it is ".."). For compatibility's sake, set it to ".." here.)
	}

	iniwrite,% server.ip,%gamecfg%,server,sv_game_server_host
	iniwrite,% server.port,%gamecfg%,server,sv_game_server_tcp_port
	iniwrite,% server.retr,%gamecfg%,server,sv_retriever_host
	iniwrite,% referer.token,%gamecfg%,client,cl_referer
	iniwrite,% ! hide_loading_screen,%gamecfg%,client,cl_show_loading_screen
	iniwrite,% width,%gamecfg%,video_graphics,vg_screen_width
	iniwrite,% height,%gamecfg%,video_graphics,vg_screen_height

	;;;;;;;; SPLASHES

	if(skip_logo==1) {
		filedelete, %live%splash.ngz
		filedelete, %live%splash_ngd.ogg
		filedelete, %live%splash_gmg.png
		filedelete, %live%splash.ngz
		filedelete, %live%splash_ngd.ogg
		filedelete, %live%splash_gmg.png
	}

	;;;;;;;; RUN
	
	if run_runas = 1
	{
		if(empty(run_runas_name) || empty(run_runas_pw)) {
			msgbox, % T.EMPTY_WINDOWS_CREDENTIALS
			return
		}
		runas, %run_runas_name%, %run_runas_pw%
	}
	else
		runas
	 
	if(server.name == "Amun") {
		runwait "%test%ROClientGame.exe" %run_name% %run_pw%, %test%, UseErrorLevel
	}
	else
	{
		runwait "%live%ROClientGame.exe" %run_name% %run_pw%, %live%, UseErrorLevel
	}
	if(errorlevel == "ERROR") {
		msgbox, % T.RUN_ERROR
		return
	}

	;;;;;;; PROMPT LOG.TXT CONNECTION ERROR

	Loop, Read, %live%log.txt
	{
		IfInString, A_LoopReadLine, % "Connection error: "
		{
			connection_error := RegExReplace(A_LoopReadLine, "^.*Connection error: (.+)$", "$1")
			connection_error_extra =
			ifinstring, connection_error, % "not found"
			{
				connection_error_extra := "`n" T.NOT_FOUND_POSSIBLE_REASONS
			}
			else ifinstring, connection_error, % "is disabled"
			{
				connection_error_extra := "`n" T.IS_DISABLED_POSSIBLE_REASONS
			}
			msgbox % "Regnum connection error: `n" connection_error connection_error_extra
		}
	}
	log=

return

; //////

setTranslations:
translations := []
translations["WINDOW_TITLE"] := { de: "CoR Schnellstarter"
    , en: ""
    , es: "" }
translations["COULD_NOT_CREATE_DATA_FOLDER"] := { de: "Konnte Unterordner 'data' nicht erstellen. Das Programm kann nicht starten."
	, en: ""
	, es: "" }
translations["CHECKING_UPDATES"] := { de: "Checke Schnellstarter Updates..."
    , en: ""
    , es: "" }
translations["SERVERS_PUBLISHERS_UPDATED"] := { de: "Server und Publisher wurden erfolgreich aktualisiert."
    , en: ""
    , es: "" }
translations["NEW_UPDATE_AVAILABLE"] := { de: "Ein neues Update für den CoR-Schnellstarter ist verfügbar"
    , en: ""
    , es: "" }
translations["CHECKING_GAME_UPDATES"] := { de: "Checke Spielversion..."
    , en: ""
    , es: "" }
translations["NOTICED_NEW_UPDATE"] := { de: "Neues Regnum Update erkannt: Schnellstarter wird jetzt die Spieldateien updaten."
    , en: ""
    , es: "" }
translations["FAILED"] := { de: "fehlgeschlagen"
    , en: ""
    , es: "" }
translations["UPDATING_FINISHED"] := { de: "Updateprozess abgeschlossen."
    , en: ""
    , es: "" }
translations["EMPTY"] := { de: "leer"
    , en: ""
    , es: "" }
translations["LOGIN"] := { de: "Login"
	, en: "Login"
	, es: "Login" }
translations["MANAGE_ACCOUNTS"] := { de: "Accounts verwalten"
    , en: ""
    , es: "" }
translations["PUBLISHER"] := { de: "Publisher"
    , en: ""
    , es: "" }
translations["CREATE_SHORTCUT"] := { de: "Direktlink`nerstellen"
    , en: ""
    , es: "" }
translations["DELETE_SPLASH"] := { de: "Vorspann löschen"
    , en: ""
    , es: "" }
translations["HIDE_LOADING_SCREEN"] := { de: "Ladescreen ausblenden"
    , en: ""
    , es: "" }
translations["WINDOW_RESOLUTION"] := { de: "Fenster-Auflösung"
    , en: ""
    , es: "" }
translations["REGNUM_PATH"] := { de: "Regnum-Pfad"
    , en: ""
    , es: "" }
translations["CHANGE"] := { de: "ändern"
    , en: "change"
    , es: "" }
translations["RUN_AS"] := { de: "als anderer Win-Nutzer ausführen"
    , en: "run as other windows user"
    , es: "" }
translations["USER"] := { de: "Nutzer"
    , en: "User"
    , es: "" }
translations["PASSWORD"] := { de: "Passwort"
    , en: "Password"
    , es: "" }
translations["REQUIRED"] := { de: "erforderlich"
    , en: "required"
    , es: "" }
translations["SELECT_PATH"] := { de: "Bitte wähle das den Speicherort der Regnumdateien aus!"
    , en: ""
    , es: "" }
translations["CHOOSE_LINK_DESTINATION_FOR"] := { de: "Wähle den Speicherort aus für die Verknüpfung für"
    , en: ""
    , es: "" }
translations["CREATE_LINK_FAILED"] := { de: "Erstellung der Verknüpfung war nicht erfolgreich."
    , en: ""
    , es: "" }
translations["CREATE_LINK_SUCCESS_FOR"] := { de: "Erstellung des Direktlinks erfolgreich erstellt für"
    , en: ""
    , es: "" }
translations["NAME"] := { de: "Name"
    , en: ""
    , es: "" }
translations["COMMENT"] := { de: "Kommentar"
    , en: ""
    , es: "" }
translations["PATH_INVALID"] := { de: "Regnum-Ordnerpfad ungültig!"
    , en: ""
    , es: "" }
translations["NO_CFG_FOUND"] := { de: "keine game.cfg gefunden"
    , en: ""
    , es: "" }
translations["CFG_TOO_SMALL"] := { de: "game.cfg gefunden, aber kleiner als 0.5 kB"
    , en: ""
    , es: "" }
translations["CHOOSE_RESOLUTION"] := { de: "Bitte wähle eine Auflösung!"
    , en: ""
    , es: "" }
translations["NO_SUCH_SERVER"] := { de: "Server nicht vorhanden"
    , en: ""
    , es: "" }
translations["NO_SUCH_PUBLISHER"] := { de: "Publisher nicht vorhanden"
    , en: ""
    , es: "" }
translations["NO_ACCOUNT_CHOSEN"] := { de: "Du hast keinen Account ausgewählt! Wähle zuerst 'Accounts verwalten' aus!"
    , en: ""
    , es: "" }
translations["TEST_GAME_MISSING"] := { de: "TestServer\ROClientGame.exe fehlt (Amun-Integration ist experimental)"
    , en: ""
    , es: "" }
translations["LIVE_GAME_MISSING"] := { de: "Keine Spieldaten im angegeben Ordner gefunden"
	, en: ""
	, es: "" }
translations["DOWNLOAD_LIVE_GAME_NOW"] := { de: "Soll das Spiel jetzt dorthin heruntergeladen werden? Das dauert nur ca. 1 Minute."
	, en: ""
	, es: "" }
translations["DOWNLOADING_LIVE_GAME_FINISHED"] := { de: "Downloadprozess abgeschlossen.`nWenn die Logindaten stimmen, wird das Spiel wird jetzt starten. Dann werden lange Zeit Resourcen heruntergeladen werden. Das ist ganz normal: Alle Texturen, die normalerweise im Installer enthalten sind, müssen vom Spiel noch nachgeladen werden."
	, en: ""
	, es: "" }
translations["EMPTY_WINDOWS_CREDENTIALS"] := { de: "Windowsnutzer-Daten müssen deaktiviert oder ausgefüllt sein!"
    , en: ""
    , es: "" }
translations["RUN_ERROR"] := { de: "Konnte ROClientGame.exe nicht starten! Falsche Win-Nutzer-Daten oder fehlende Berechtigung?"
    , en: ""
    , es: "" }
translations["NOT_FOUND_POSSIBLE_REASONS"] := { de: "Mögliche Gründe hierfür: 1. falscher Publisher ausgewählt, 2. falscher Benutzername, 3. falsches Passwort"
    , en: ""
    , es: "" }
translations["IS_DISABLED_POSSIBLE_REASONS"] := { de: "Mögliche Gründe hierfür: 1. Account nicht autorisiert. Hierfür bitte einmalig den normalen Launcher von NGD benutzen (Spiel betreten nicht notwendig, nur Autorisierung), 2. Account gebannt" ; todo right?
    , en: ""
    , es: "" }
global T := []
for k,v in translations {
    T[k] := v[language]
}
translations=
return

; ///// make gui moveable:
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









md5(string)    ; by SKAN | rewritten by jNizM
{
    static MD5_DIGEST_LENGTH := 16
    hModule := DllCall("LoadLibrary", "Str", "advapi32.dll", "Ptr")
    , VarSetCapacity(MD5_CTX, 104, 0), DllCall("advapi32\MD5Init", "Ptr", &MD5_CTX)
    , DllCall("advapi32\MD5Update", "Ptr", &MD5_CTX, "AStr", string, "UInt", StrLen(string))
    , DllCall("advapi32\MD5Final", "Ptr", &MD5_CTX)
    loop % MD5_DIGEST_LENGTH
        o .= Format("{:02" (case ? "X" : "x") "}", NumGet(MD5_CTX, 87 + A_Index, "UChar"))
    DllCall("FreeLibrary", "Ptr", hModule)
	StringLower, o,o
	return o
} ;https://autohotkey.com/boards/viewtopic.php?f=6&t=21





































