#persistent
#singleinstance off
APPDATA := A_AppData "\RegnumStarter"
global APPDATA
BASE_URL = http://www.cor-forum.de/regnum/schnellstarter/
SetWorkingDir, %A_ScriptDir%
OnError("ErrorFunc")
gosub, checkAppdata
gosub, readUserConfig
gosub, checkLanguage
gosub, setTranslations
try menu, tray, icon, %APPDATA%/icon.ico
coordmode,mouse,screen
gosub, readServerConfig ; servers and referers
goSub, readUsers
iniread, server_version, %APPDATA%/serverConfig.txt, version, version, -1
iniread, rs_version, %APPDATA%/serverConfig.txt, version, rs_version, -1
iniread, autopatch_server, %APPDATA%/serverConfig.txt, general, autopatch_server
rs_version_release = v2.2.0
gosub, make_gui

argc = %0%
if(argc >= 4) {
	; program is being run from a shortcut: run game & exit
	gui,submit
	name = %1%
	referertoken = %3%
	referer := referer_by_token(referertoken)
	pw_hashed = %2%
	run_user := new User(name,,referer,pw_hashed)
	servername = %4%
	server := server_by_name(servername)
	run_server := server
	run_runas = %5%
	run_runas_name = %6%
	run_runas_pw = %7%
	gosub run
	
	exitapp
}
tooltip, % T.CHECKING_UPDATES
settimer, updateServerConfig, -10 ; todo .. ? - do not block the gui
tooltip

OnExit, ExitSub

return
; //
checkAppdata:
	if(!fileexist(APPDATA)) {
		FileCreateDir, %APPDATA%
		if(errorlevel) {
			msgbox, % "Couldn't create " APPDATA " folder. Can't startup [" errorlevel "]"
			exitapp
		}
		if(FileExist("data") == "D") {
			; change from v2.0 to v2.1
			FileCopy, data\*, %APPDATA%
		}
	}
	for k,v in ["background.png", "icon.ico"] {
		if(!FileExist(APPDATA "/" v)) {
			tooltip, Downloading %v%...
			UrlDownloadToFile, %BASE_URL%%v%, %APPDATA%/%v%
			if(errorlevel) { ; note: no error will be detected when response is an error message like 404
				; who cares
			}
		}
	}
return
updateServerConfig:
	urldownloadtofile, *0 %BASE_URL%serverConfig.txt?disablecache=%A_TickCount%, %APPDATA%/serverConfig.txt
	
	; main program update?
	iniread, rs_version_new, %APPDATA%/serverConfig.txt, version, rs_version, -1 ; in versions < 2.1, this was program_version
	if(rs_version > -1 && rs_version_new > rs_version) { ; is not first program start and update
		iniread, rs_update_info, %APPDATA%/serverConfig.txt, version, rs_update_info, -1
		for k,f in [ "RegnumStarter.ahk", "RegnumStarter.exe" ] {
			tooltip, New update found. Downloading %f%_new...
			urldownloadtofile, *0 %BASE_URL%%f%, %f%_new
			if(errorlevel)
				gosub autoUpdateFailed
			FileGetSize, size, %f%_new, K
			if(size < 10)
				gosub autoUpdateFailed
		}
		fc=
		tooltip
		updateBat =
(
Del RegnumStarter.ahk
Del RegnumStarter.exe
Rename RegnumStarter.ahk_new RegnumStarter.ahk
Rename RegnumStarter.exe_new RegnumStarter.exe
%A_ScriptFullPath%
Del `%0
)
		filedelete, update.bat
		fileAppend, %updateBat%, update.bat
		if(errorlevel)
			gosub autoUpdateFailed
		msgbox, ,RegnumStarter - Update, % T.NEW_UPDATE_DOWNLOADED "`n`n" rs_update_info
		run, update.bat,, hide
		onExit
		exitapp
	}
	
	; otherwise, metaupdate?
	iniread, server_version_new, %APPDATA%/serverConfig.txt, version, version, -1
	if(server_version_new == -1) {
		msgbox, % T.INVALID_SERVER_CONFIG
		exitapp
	}
	if(server_version_new > server_version) {
		if(server_version > -1)
			msgbox, ,RegnumStarter - Metaupdate, % T.SERVERS_PUBLISHERS_UPDATED
		reload
	}
return
autoUpdateFailed:
	msgbox % errorlevel " " T.AUTO_UPDATE_FAILED "`n`n" update_info
	tooltip
	fc=
	filedelete updateBat
	filedelete RegnumStarter.ahk_new
	filedelete RegnumStarter.exe_new
exit
; //
patchLiveGamefile(file) {
	global autopatch_server
	global live
	global win64
	add := win64 ? "64" : ""
	url := autopatch_server "/autopatch/autopatch_files" add "_rgn/" file "?nocache"
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
	launcherini := regnum_path "ROLauncher.ini"
	iniread, current_win64, %launcherini%, build, win64
	if(current_win64 != 1)
		current_win64 := 0
	ifnotexist, %live%ROClientGame.exe
	{
		; Download all necessary files if not present
		msgbox, 4, Regnum Download, % T.LIVE_GAME_MISSING ":`n" regnum_path "`n" T.DOWNLOAD_LIVE_GAME_NOW
		ifmsgbox, No
			goto exitThread ; and I am sorry
		downloadAll := true
	} else if(win64 != current_win64) {
		msgbox, 4, Regnum Download, % T.64_BIT_CHANGED
		ifmsgbox, No
			goto exitThread
		downloadAll := true
	} else {
		downloadAll := false
	}

	if(downloadAll) {
		if(!FileExist(live))
			FileCreateDir, %live%
		necessaryLiveFiles := ["ROClientGame.exe", "shaders.ngz", "scripts.ngz", "current_build", "openal.dll"] ; minimally necessary files inside liveserver folder for the game to start. more or less coincidentally, these are also the ones that need to be downloaded when 32/64 mode changed (according to the normal launcher workflow, did not check if this is optimizable)
		if(win64)
			necessaryLiveFiles.Push("steam_api64.dll") ; the only file with a different name in 64 bit mode...
		else
			necessaryLiveFiles.Push("steam_api.dll")
		;unnecessaryLiveFiles := [ "dbghelp.dll", "libbz2.dll", "libjpeg62.dll", "libpng13.dll", "libtheora.dll", "libzip.dll", "ngdlogo.png", "ogg.dll", "readme.txt", "resources", "splash_ngd.ogg", "steamclient.dll", "Steam.dll", "tier0_s.dll", "vorbis.dll", "vorbisfile.dll", "vstdlib_s.dll", "zlib1.dll" ] ; all the waste the normal launcher downloads but is actually not needed
		for k,file in necessaryLiveFiles {
			if(!patchLiveGamefile(file)) {
				FileDelete, %live%ROClientGame.exe ; so downloadAll will surely be true next time
				goto exitThread
			}
		}
		IniWrite, %win64%, %launcherini%, build, win64
		msgbox
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
	loop, read, %APPDATA%/users.txt
		{
			blub := strsplit(a_loopreadline,":")
			name := blub[1]
			pw_hashed := blub[2]
			comment := blub[3]
			try {
				referer := referer_by_token(blub[4])
			} catch {
				referer := referers[1]
			}
			if(StrLen(pw_hashed) != 32 || RegExMatch(pw_hashed, "i)[^a-f0-9]")) { ; not an md5 hash
				; -> running >= v2.1.0 for the first time with old users.txt
				pw := pw_hashed ; backwards-compatibility: transform cleartext password (old) into md5hash password (new)
				users.push(new User(name,comment,referer,,pw))
			} else {
				users.push(new User(name,comment,referer,pw_hashed))
			}
		}
return
writeUsers:
	filedelete, %APPDATA%/users.txt
	for i,user in users {
		if(a_index>1)
			fileappend, `r`n, %APPDATA%/users.txt
		fileappend, % user.name ":" user.pw_hashed ":" user.comment ":" user.referer.token, %APPDATA%/users.txt
	}
return
; ///
readUserConfig:
	; name: defaultvalue
	configEntries := { language: a_space
		, selected_user: 1
		, selected_server: 1
		, skip_logo: 1
		, win64: 0
		, hide_loading_screen: 0
		, net_fake_lag: 0
		, width: 1366
		, height: 768
		, vg_fullscreen_mode: 0
		, vg_vertical_sync: 1
		, screenshot_quality: 1
		, screenshot_autosave: 1
		, cl_crafting_show_min_level: 0
		, dbg_ignore_server_time: 0
		, env_weather: clear
		, debug_mode: 0
		, hide_window_border:0
		, regnum_path: "C:\Games\NGD Studios\Champions of Regnum\"
		, runas: 0
		, runas_name: a_space
		, runas_pw: a_space
		, PosGuiX: -1
		, PosGuiY: -1
		, shortcut_last: a_space }
	for k,default in configEntries {
		%k% := config_read(k, default)
	}
return
writeUserConfig:
	if(selected_server=="")
		selected_server := 1
	for k,v in configEntries {
		config_write(k, %k%)
	}
return
; ////
readServerConfig:
	servers := Array()
	referers := Array()
	loop, read, %APPDATA%/serverConfig.txt
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

guiClose:
exitapp

ExitSub:
	gui,submit,nohide
	goSub writeUsers
	goSub writeUserConfig
exitapp

ErrorFunc(e) {
	msgbox % e e.Message
	exitapp
}

; ///
config_read(key,default) {
	iniread,tmp1,%APPDATA%/config.ini,config,%key%,%default%
	if(tmp1==a_space) { ; blank value, as suggested by the documentation, does not work here (maybe due to wine?)
		tmp1=
	}
	return tmp1
}
config_write(key,val) {
	iniwrite,%val%,%APPDATA%/config.ini,config,%key%
}
; ///
class User {
	__New(name:="", comment:="", referer:="", pw_hashed:="", pw:="") {
		global referers
		this.name := name
		this.comment := comment
		if(empty(referer.token))
			this.referer := referers[1]
		else
			this.referer := referer
		if(!empty(pw)) {
			this.pw := pw
			this.pw_hashed := md5(this.pw)
		} else {
			this.pw := ""
			this.pw_hashed := pw_hashed
		}
	}
}
class Server {
	__New(name,ip,port,retr) {
		this.name := name
		this.ip := ip
		this.port := port
		this.retr := retr
	}
}
class Referer {
	__New(name,token) {
		this.name := name
		this.token := token
	}
}
server_by_name(name) {
	global servers
	for i,s in servers {
		if(s.name == name) {
			return s
		}
	}
	throw % T.NO_SUCH_SERVER ": " name
}
referer_by_token(token) {
	global referers
	for i,s in referers {
		if(s.token == token || s.name == token) { ; .name: backwards-compatibility
			return s
		}
	}
	throw % T.NO_SUCH_PUBLISHER ": " token
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
	
; 	// background image	
	gui, add, picture, x0 y0, %APPDATA%\background.png

;	// Window title
	Gui, Font, s10 bold cD8D8D8, Verdana
	gui, add, text, x240 center y7 w120 h25 backgroundtrans, RegnumStarter
	
;	// version number
	Gui, Font, s7 cD8D8D8, Verdana
	gui, add, text, x500 center y10 w120 h25 backgroundtrans, v3.0.0-beta1
;	Gui, add, link, x450 center y10 w120 h25 backgroundtrans, <a href="https://github.com/phil294/regnum-starter">GitHub</a>
	
; 	// login button
	Gui, Font, s10 bold, Verdana
	gui, add, button, w140 h30 x490 y290 glogin, % T.LOGIN

	Gui, Font, s7 c000000, Verdana

; 	// user selection
	gui, add, dropdownlist, x490 y250 w140 vselected_user altsubmit
	goSub updateUserlist

; 	// account management
	gui, add, button, x400 y250 w80 gaccounts_edit, % T.MANAGE_ACCOUNTS

; 	// graphic settings
	gui, add, button, x300 y150 w80 ggraphic_settings, % "graphic settings"



; 	// server selection
	gui, add, dropdownlist, x400 y220 w120 vselected_server altsubmit
	gosub updateServerlist

;	// create shortcut
	Gui, Font, s6 c000000, Verdana
	gui, add, button, w80 h30 x400 y290 gshortcutCreate, % T.CREATE_SHORTCUT

;	// window resolution
	Gui, Font, s7 norm cD8D8D8, Verdana
	gui, add, text, x220 y260 backgroundtrans, % T.WINDOW_RESOLUTION ":"
	Gui, Font, s7 c000000, Verdana
	gui, add, edit, x225 y275 w42 h18 limit4 center number -multi vwidth, %width%
	Gui, Font, s7 cD8D8D8, Verdana
	gui, add, text, x270 y275 backgroundtrans, x
	Gui, Font, s7 c000000, Verdana
	gui, add, edit, x280 y275 w42 h18 limit4 center number -multi vheight, %height%
	
;	// hide window boarder
	Gui, Font, s7 cD8D8D8, Verdana
	gui, add, checkbox, x220 y305 checked%hide_window_border% backgroundtrans w%CBW% h%CBH% vhide_window_border
	gui, add, text, x+3 yp backgroundtrans, % T.HIDE_WINDOW_BORDER

;	// regnum path
	Gui, Font, s8 bold cD8D8D8, Verdana
	gui  add, text, backgroundtrans x10 y30, % T.REGNUM_PATH ":"
	Gui, Font, s7 cD8D8D8, Verdana
	gui, add, text, x10 w300 r2 y50 backgroundtrans vregnum_path, %regnum_path%
	Gui, Font, s7 c000000 norm, Verdana
	gui, add, button, x150 w80 y30 gpath_edit, % T.CHANGE

	Gui, Font, s8 c000000, Verdana

;	// hide NGD intro
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

;	// debug mode
	Gui, Font, s7 cD8D8D8, Verdana
	gui, add, checkbox, w%CBW% h%CBH% x10 y170 checked%debug_mode% backgroundtrans vdebug_mode
	gui, add, text, x+3 yp backgroundtrans, % "debug mode (experimental)"

;	// change 64bit mode
	gui, add, checkbox, w%CBW% h%CBH% x10 y70 checked%win64% backgroundtrans vwin64
	gui, add, text, x+3 yp backgroundtrans, % T.64BIT_MODE
	
;	// hide loading screen	
	gui, add, checkbox, w%CBW% h%CBH% x10 y90 checked%hide_loading_screen% backgroundtrans vhide_loading_screen
	gui, add, text, x+3 yp backgroundtrans, % T.HIDE_LOADING_SCREEN

;	// fullscreen mode
	Gui, Font, s7 cD8D8D8, Verdana
	gui, add, checkbox, x400 y200 checked%vg_fullscreen_mode% backgroundtrans w%CBW% h%CBH% vvg_fullscreen_mode
	gui, add, text, x+3 yp backgroundtrans, % T.FULLSCREEN_MODE

;	// vsync
	Gui, Font, s7 cD8D8D8, Verdana
	gui, add, checkbox, x520 y200 checked%vg_vertical_sync% backgroundtrans w%CBW% h%CBH% vvg_vertical_sync
	gui, add, text, x+3 yp backgroundtrans, % T.VSYNC
	
;	// cl_crafting_show_min_level
	Gui, Font, s7 cD8D8D8, Verdana
	gui, add, checkbox, x400 y130 checked%cl_crafting_show_min_level% backgroundtrans w%CBW% h%CBH% vcl_crafting_show_min_level
	gui, add, text, x+3 yp backgroundtrans, % "cl_crafting_show_min_level (experimental)"
	
;	// server time
	Gui, Font, s7 cD8D8D8, Verdana
	gui, add, checkbox, x400 y150 checked%dbg_ignore_server_time% backgroundtrans w%CBW% h%CBH% vdbg_ignore_server_time
	gui, add, text, x+3 yp backgroundtrans, % "custom server time"
	gui, add, dropdownlist, x550 y150 w50 vserver_time AltSubmit, morning|afternoon|evening|night

;	// weather
	Gui, Font, s7 cD8D8D8, Verdana
	gui, add, text, x420 y170 backgroundtrans, % "weather (experimental)"
	gui, add, dropdownlist, x550 y170 w50 vweather AltSubmit, clear|rainy|storm

;	// fake net lag
	gui, add, text, x10 y200 backgroundtrans, % T.NET_FAKE_LAG " (ms)"
	gui, add, edit, x150 y200 w60 h15 -multi vnet_fake_lag, %net_fake_lag%,
	
;	// run as windows user	
	gui, add, checkbox, x11 y257 checked%runas% w%CBW% h%CBH% grunasGuiToggled vrunas
	gui, add, text, x+3 y257 backgroundtrans, % T.RUN_AS ":"
	
	Gui, Font, s7 c000000, Verdana
	gui, add, edit, x11 y275 w85 h18 -multi vrunas_name, %runas_name%
	Gui, Font, s7 cD8D8D8, Verdana
	gui, add, text, x18 y295 backgroundtrans vgui_runas_name_text, % "Windows " T.USER
	Gui, Font, s7 c000000, Verdana
	gui, add, edit, x109 y275 w85 h18 -multi vrunas_pw, %runas_pw%
	Gui, Font, s7 cD8D8D8, Verdana
	gui, add, text, x118 y295 backgroundtrans vgui_runas_pw_text, % "Win " T.PASSWORD
	Gui, Font, s6 cD8D8D8, Verdana
	gui, add, text, x80 y310 backgroundtrans vgui_runas_required_text, % "(" T.REQUIRED ")"
	Gui, Font, s7 cD8D8D8, Verdana
	
	gosub, runasGuiToggled

	
	Gui, Font, s7 c000000, Verdana
	gui, add, dropdownlist, x256 y215 w45 vlanguage glanguage_changed, eng|deu|spa
	gosub, updateLanguageList



	Gui, Font, s13 bold cD8D8D8, Verdana
	gui, add, text, x620 backgroundtrans y4 gguiclose, X

	Gui, Margin , 0, 0
	Gui -Caption
	if(PosGuiX="" || PosGuiX<0)
		PosGuiX = center
	if(PosGuiY="" || PosGuiY<0)
		PosGuiY = center
	gui, show, w646 h331 x%PosGuiX% y%PosGuiY%, % T.WINDOW_TITLE " v" rs_version_release

	WinGet, GuiID, ID, A

return

	graphic_settings:
refererlist =
	for i,referer in referers {
		refererlist .= "|" referer.name
	}
	placeholder := "   "
	gui, 1:+disabled
	Gui, 2:Font, s8 c000000, Verdana
	gui, 2:add, text, x+40 y+6, % "under development"
	gui, 2:add, button, g2guiok x235, Ok
	gui, 2:add, button, g2guicancel x180 yp+0 xp+38, Cancel
	gui, 2:show	
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

language_changed:
reload

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
updateLanguageList:
	guicontrol, 1:choose, language, %language%
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
	
	fileselectfile, shortcut, S18, % shortcut_last "\" user.name " " server.name " Login", % T.CHOOSE_LINK_DESTINATION_FOR " " user.name " " server.name
	ifnotinstring, shortcut, \
		return
	
	params := """" user.name """ " user.pw_hashed " " user.referer.token " " server.name " " runas " """ runas_name """ """ runas_pw """"
	if(a_iscompiled) {
		exe = "%A_ScriptFullPath%"
		filecreateshortcut, %exe%, %shortcut%.lnk, %a_workingDir%,% params,, %APPDATA%\icon.ico
	} else {
		script = "%A_ScriptFullPath%"
		filecreateshortcut,"%a_ahkpath%", %shortcut%.lnk, %a_workingDir%,% script " " params,, %APPDATA%\icon.ico
	}
	
	if(errorlevel) {
		msgbox, % T.CREATE_LINK_FAILED
	} else {
		wat :=  user.name " " user.pw_hashed " " user.referer.name " " server.name
		if(runas==1)
			wat .= " " runas_name " " runas_pw
		msgbox, % T.CREATE_LINK_SUCCESS_FOR ":`n" wat
	}
	
	shortcut_last := shortcut
	
return

; ////////////////////////


accounts_edit:
	refererlist =
	for i,referer in referers {
		refererlist .= "|" referer.name
	}
	placeholder := "   "
	gui, 1:+disabled
	Gui, 2:Font, s8 c000000, Verdana
	gui, 2:add, text, x+40 y+6, % T.NAME "`t`t`t" T.PASSWORD "`t`t`t" T.PUBLISHER "`t`t" T.COMMENT
	if(users.Length()==0)
		users.push(new User())
	for i,user in users {
		y := 0 + a_index * 28
		Gui, 2:Font, s8 c000000, Verdana
		gui, 2:add, edit, -multi r1 x20 y%y% w130 vname%a_index%, % user.name
		Gui, 2:Font, s8 c9B0000, Verdana
		gui, 2:add, edit, -multi r1 x160 y%y% w130 vpw%a_index% password, %placeholder%
		Gui, 2:Font, s8 c000000, Verdana
		gui, 2:add, dropdownlist, x300 y%y% w100 vreferer%a_index% altsubmit
		guicontrol, 2:, referer%a_index%, %refererlist%
		try 
			referer := referer_by_token(user.referer.token)
		catch {
			referer := referers[1]
		}
		guicontrol, 2:choose, referer%a_index%, % referer.name
		gui, 2:add, edit, -multi r1 x410 y%y% w130 vcomment%a_index%, % user.comment
	}
	gui, 2:add, button, ggui2_add x20,+
	gui, 2:add, button, g2guiok x235, Ok
	gui, 2:add, button, g2guicancel x180 yp+0 xp+38, Cancel
	gui, 2:show	
return

gui2_add:
	gosub 2guiok
	users.push(new User())
	gosub accounts_edit
return

2guiok:
	gui, 2:submit, nohide
	; Update users:
	amnt := users.Length()
	new_users := Array()
	loop, % amnt
	{
		if(empty(name%a_index%) || empty(referer%a_index%))
			continue
		if(pw%a_index% == placeholder) {
			; no (new) password entered: use new values, but old pw hash
			new_users.push(new User(name%a_index%, comment%a_index%, referers[referer%a_index%], users[a_index].pw_hashed))
		} else {
			; also override pw: generate new pw hash
			new_users.push(new User(name%a_index%, comment%a_index%, referers[referer%a_index%], , pw%a_index%))
		}
	}
	users := new_users
	; apply users to gui1:
	goSub updateUserlist
	gosub 2guiclose
return

2guiclose:
2guicancel:	
	gui, 1:-disabled
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
	run_user := users[selected_user]
	run_server := servers[selected_server]
	run_runas := runas
	run_runas_name := runas_name
	run_runas_pw := runas_pw
return

run:	
	live = %regnum_path%LiveServer\
	test = %regnum_path%TestServer\

	;;;;;;;; USER INPUT VALIDATION

	if(empty(run_user.name) || empty(run_user.pw_hashed)) {
		msgbox % T.NO_ACCOUNT_CHOSEN
		return
	}

	if(empty(width) || empty(height)){
		msgbox, % T.CHOOSE_RESOLUTION
		return
	}

	;;;;;;;; CHECK / DOWNLOAD / UPDATE LIVESERVER

	gui, 1:+disabled
	gosub updateGamefiles
	gui, 1:-disabled

	;;;;;;;; CHECK AMUN

	if(run_server.name == "Amun") {
		ifnotexist, %test%ROClientGame.exe
		{
			msgbox, % T.TEST_GAME_MISSING
			return
		}
	}

	;;;;;;;; GAME.CFG

if(weather == 1) 
   env_weather := "clear" 
else if (weather == 2)
   env_weather := "rainy" 
else if (weather == 3)
   env_weather := "snow"

	gamecfg := regnum_path "game.cfg"
	if(!FileExist(gamecfg)) {
		FileAppend, [Regnum Config File], %gamecfg% ; somehow fixes weird iniwrite behaviour
		iniwrite, .., %gamecfg%, client, cl_sdb_path ; would otherwise wrongly be set to "." afterwards, when the file is being filled up by the game itself (as apposed to the one included in the installers where it is ".."). For compatibility's sake, set it to ".." here.)
	}

	iniwrite,% run_server.ip,%gamecfg%,server,sv_game_server_host
	iniwrite,% run_server.port,%gamecfg%,server,sv_game_server_tcp_port
	iniwrite,% run_server.retr,%gamecfg%,server,sv_retriever_host
	iniwrite,% run_user.referer.token,%gamecfg%,client,cl_referer
	iniwrite,% ! hide_loading_screen,%gamecfg%,client,cl_show_loading_screen
	iniwrite,% net_fake_lag,%gamecfg%,network,net_fake_lag
	iniwrite,% language,%gamecfg%,client,cl_language
	iniwrite,% cl_crafting_show_min_level,%gamecfg%,client,cl_crafting_show_min_level
	iniwrite,% width,%gamecfg%,video_graphics,vg_screen_width
	iniwrite,% height,%gamecfg%,video_graphics,vg_screen_height
	iniwrite,% vg_fullscreen_mode,%gamecfg%,video_graphics,vg_fullscreen_mode
	iniwrite,% dbg_ignore_server_time,%gamecfg%,debug,dbg_ignore_server_time
	iniwrite,% env_weather,%gamecfg%,general,env_weather
	iniwrite,% env_time_of_day,%gamecfg%,general,env_time_of_day

if(dbg_ignore_server_time == 1)  {
	if(server_time == 1) 
	   env_time_of_day := "8" 
	else if (server_time == 2)
	   env_time_of_day := "13" 
	else if (server_time == 3)
	   env_time_of_day := "18"
	else if (server_time == 4)
	   env_time_of_day := "1"
	}

if(screenshot_quality)  {
 		iniwrite, 100, %gamecfg%, video_graphics, vg_screenshot_quality
		iniwrite, png, %gamecfg%, video_graphics, vg_screenshot_format
	}
else {
 		iniwrite, 80, %gamecfg%, video_graphics, vg_screenshot_quality
		iniwrite, jpg, %gamecfg%, video_graphics, vg_screenshot_format
	}

if(screenshot_autosave)  {
 		iniwrite, 1, %gamecfg%, video_graphics, vg_screenshot_autotag
	}
else {
 		iniwrite, 0, %gamecfg%, video_graphics, vg_screenshot_autotag

	}

if(debug_mode)  {
 		iniwrite, 1, %gamecfg%, debug, dbg_action_system
    	iniwrite, 1, %gamecfg%, debug, dbg_central_timer
	    iniwrite, 1, %gamecfg%, debug, dbg_debug_movement_events
	    iniwrite, 1, %gamecfg%, debug, dbg_debug_positions
 		iniwrite, 1, %gamecfg%, debug, dbg_enable_cycle_debuggers
    	iniwrite, 1, %gamecfg%, debug, dbg_entity_system
	    iniwrite, 1, %gamecfg%, debug, dbg_lua_call_debug
	    iniwrite, 1, %gamecfg%, debug, dbg_render_paths
	    iniwrite, 1, %gamecfg%, debug, dbg_resource_manager_output
	    iniwrite, 1, %gamecfg%, debug, dbg_terrain_manager
	}
else {
 		iniwrite, 0, %gamecfg%, debug, dbg_action_system
    	iniwrite, 0, %gamecfg%, debug, dbg_central_timer
	    iniwrite, 0, %gamecfg%, debug, dbg_debug_movement_events
	    iniwrite, 0, %gamecfg%, debug, dbg_debug_positions
 		iniwrite, 0, %gamecfg%, debug, dbg_enable_cycle_debuggers
    	iniwrite, 0, %gamecfg%, debug, dbg_entity_system
	    iniwrite, 0, %gamecfg%, debug, dbg_lua_call_debug
	    iniwrite, 0, %gamecfg%, debug, dbg_render_paths
	    iniwrite, 0, %gamecfg%, debug, dbg_resource_manager_output
	    iniwrite, 0, %gamecfg%, debug, dbg_terrain_manager
	}

	;;;;;;;; SPLASHES

	if(skip_logo==1) {
		filedelete, %live%splash.ngz
		filedelete, %live%splash_ngd.ogg
		filedelete, %live%splash_gmg.png
		filedelete, %live%splash.ngz
		filedelete, %live%splash_ngd.ogg
		filedelete, %live%splash_gmg.png
	}

	;;;;;;;; REMOVE WINDOW BORDER OPTION

	if(hide_window_border)
		settimer, removeRegnumWindowBorder, -1000

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
	 
	if(run_server.name == "Amun") {
		runwait, % """" test "ROClientGame.exe" """" " " run_user.name " " run_user.pw_hashed, %test%, UseErrorLevel
	}
	else
	{
		runwait, % """" live "ROClientGame.exe" """" " " run_user.name " " run_user.pw_hashed, %live%, UseErrorLevel
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
			ifinstring, connection_error, % "not found"
			{
				msgbox % T.CONNECTION_ERROR_USER_NOT_FOUND
			}
			else ifinstring, connection_error, % "is disabled"
			{
				msgbox % T.CONNECTION_ERROR_USER_IS_DISABLED
			}
			else ifinstring, connection_error, % "already logged in"
			{
				msgbox  % T.CONNECTION_ERROR_USER_ALREADY_LOGGED_IN
			}
			else 
				msgbox % "Regnum connection error: `n" connection_error
		}
	}
	log=

return

; //////

removeRegnumWindowBorder:
	WinWaitActive, ahk_class Regnum,,3
	WinSet, style, -0xC00000, ahk_class Regnum
return
; //////

checkLanguage:
	while(empty(language)) {
		InputBox, language, Language - Sprache - Idioma, Please select a language - Bitte wähle eine Sprache - Por favor elija un idioma.`n`neng deu spa,,,,,,,, deu
		if(RegExMatch(language, "i)de|ger"))
			language = deu
		else if(RegExMatch(language, "i)en|usa|gb"))
			language = eng
		else if(RegExMatch(language, "i)es|sp|ar"))
			language = spa
		else {
			msgbox, Failed to detect language.`n`nKonnte Sprache nicht erkennen.`n`nNo entendió el lenguaje.
			language =
		}
	}
return

setTranslations:
translations := []
translations["SCREENSHOT_QUALITY"] := { deu: "Screenshots in höchster Qualität"
	, eng: "High Quality Screenshots"
	, spa: "High Quality Screenshots" }
translations["SCREENSHOT_AUTOSAVE"] := { deu: "Screenshots automatisch speichern"
	, eng: "Auto-Save Screenshots"
	, spa: "Auto-Save Screenshots" }
translations["WEATHER_CLEAR"] := { deu: "Klar"
	, eng: "Clear"
	, spa: "Clear" }
translations["WEATHER_RAINY"] := { deu: "Regnerisch"
	, eng: "Rainy"
	, spa: "Rainy" }
translations["WEATHER_CLEAR"] := { deu: "Schnee"
	, eng: "Snow"
	, spa: "Snow" }
translations["WINDOW_TITLE"] := { deu: "RegnumStarter"
	, eng: "RegnumStarter"
	, spa: "RegnumStarter" }
translations["CHECKING_UPDATES"] := { deu: "Überprüfe auf neue RegnumStarter Updates..."
	, eng: "Checking for RegnumStarter updates..."
	, spa: "Comprobando actualizaciones de RegnumStarter" }
translations["SERVERS_PUBLISHERS_UPDATED"] := { deu: "Liste der Server und Publisher wurde erfolgreich aktualisiert."
	, eng: "List of servers and publishers updated successfully."
	, spa: "Lista de servidores y editores actualizados con éxito." }
translations["NEW_UPDATE_DOWNLOADED"] := { deu: "Ein neues Update für den RegnumStarter wurde automatisch heruntergeladen und wird jetzt als RegnumStarter.exe bzw. RegnumStarter.ahk die aktuelle Version ersetzen. Änderungen:"
	, eng: "A new Update has been downloaded automatically and will now replace the current one as RegnumStarter.exe / RegnumStarter.ahk. Changelog:"
	, spa: "Una nueva actualización se ha descargado automáticamente y ahora reemplazará la actual como RegnumStarter.exe / RegnumStarter.ahk. Registro de cambios:" }
translations["AUTO_UPDATE_FAILED"] := { deu: "Das neue Update für den RegnumStarter konnte nicht automatisch heruntergeladen werden! Du kannst die neue Version aber manuell herunterladen. Hier ist der Changelog:"
	, eng: "Error when trying to download and apply the auto-update for RegnumStarter! You can still download it manually. This is the changelog:"
	, spa: "¡Error al intentar descargar y aplicar la actualización automática para RegnumStarter! Todavía puedes descargarlo manualmente. Este es el registro de cambios:" }
translations["CHECKING_GAME_UPDATES"] := { deu: "Checke Spielversion..."
	, eng: "Checking Game Version..."
	, spa: "Revisando la versión del juego ..." }
translations["NOTICED_NEW_UPDATE"] := { deu: "Neues Regnum Update erkannt: Der RegnumStarter wird jetzt die Spieldateien aktualisieren."
	, eng: "New Regnum Update: RegnumStarter will now update the game files."
	, spa: "Nueva actualización de Regnum: RegnumStarter ahora actualizará los archivos del juego." }
translations["FAILED"] := { deu: "fehlgeschlagen"
	, eng: "failed"
	, spa: "ha fallado" }
translations["UPDATING_FINISHED"] := { deu: "Updateprozess abgeschlossen."
	, eng: "Update completed."
	, spa: "Actualización completada." }
translations["EMPTY"] := { deu: "leer"
	, eng: "empty"
	, spa: "vacío" }
translations["LOGIN"] := { deu: "Login"
	, eng: "Login"
	, spa: "Iniciar sesión" }
translations["MANAGE_ACCOUNTS"] := { deu: "Accounts verwalten"
	, eng: "Manage Accounts"
	, spa: "Cuentas de administración" }
translations["64BIT_MODE"] := { deu: "64bit-Client starten (experimentell)"
	, eng: "start 64bit-Client (experimental)"
	, spa: "start 64bit-Client (experimental)" }
translations["PUBLISHER"] := { deu: "Publisher"
	, eng: "Publisher"
	, agt: "hzi"
	, spa: "Referente" }
translations["CREATE_SHORTCUT"] := { deu: "Direktlink erstellen"
	, eng: "Create Shortcut"
	, spa: "Crear acceso directo" }
translations["DELETE_SPLASH"] := { deu: "NGD-Intro ausblenden"
	, eng: "Hide NGD-Intro"
	, spa: "Ocultar NGD-Intro" }
translations["HIDE_LOADING_SCREEN"] := { deu: "Ladescreen ausblenden"
	, eng: "Hide Loading Screen"
	, spa: "Ocultar pantalla de carga" }
translations["HIDE_WINDOW_BORDER"] := { deu: "Fensterrahmen ausblenden"
	, eng: "Hide window border"
	, spa: "Ocultar el borde de la ventana" }
translations["WINDOW_RESOLUTION"] := { deu: "Fenster-Auflösung"
	, eng: "Screen Resolution"
	, spa: "Resolución de la pantalla" }
translations["REGNUM_PATH"] := { deu: "Spiel-Ordner"
	, eng: "Game Folder"
	, spa: "Carpeta de juego" }
translations["FULLSCREEN_MODE"] := { deu: "Vollbildmodus"
	, eng: "Fullscreen mode"
	, spa: "Fullscreen mode" }
translations["VSYNC"] := { deu: "vSync aktivieren"
	, eng: "Enable vSync"
	, spa: "Enable vSync" }
translations["CHANGE"] := { deu: "ändern"
	, eng: "change"
	, spa: "cambio" }
translations["RUN_AS"] := { deu: "Als anderer Win-Nutzer ausführen"
	, eng: "Run as other windows user"
	, spa: "ejecutar como otro usuario de Windows" }
translations["USER"] := { deu: "Nutzer"
	, eng: "User"
	, spa: "Usuario" }
translations["PASSWORD"] := { deu: "Passwort"
	, eng: "Password"
	, spa: "Contraseña" }
translations["REQUIRED"] := { deu: "erforderlich"
	, eng: "required"
	, spa: "necesario" }
translations["NET_FAKE_LAG"] := { deu: "Künstliche Latenz"
	, eng: "Emulate latency"
	, spa: "Emulate latency" }
translations["SELECT_PATH"] := { deu: "Der Speicherort für die Spieldateien wurde nicht korrekt konfiguriert!"
	, eng: "Path to Game Installation has not been configured!"
	, spa: "Ruta de instalación del juego no se ha configurado!" }
translations["CHOOSE_LINK_DESTINATION_FOR"] := { deu: "Wähle den Speicherort für die Verknüpfung für aus"
	, eng: "Select where to create the Shortcut"
	, spa: "Seleccione dónde crear el atajo" }
translations["CREATE_LINK_FAILED"] := { deu: "Erstellung der Verknüpfung war nicht erfolgreich."
	, eng: "Couldn't create shortcut."
	, spa: "No se pudo crear el acceso directo." }
translations["CREATE_LINK_SUCCESS_FOR"] := { deu: "Erstellung des Direktlinks erfolgreich für"
	, eng: "Creation of direct link successfull for"
	, spa: "Creación de enlace directo exitoso para" }
translations["NAME"] := { deu: "Name"
	, eng: "Name"
	, spa: "Nombre" }
translations["COMMENT"] := { deu: "Notiz"
	, eng: "Note"
	, spa: "Nota" }
translations["PATH_INVALID"] := { deu: "Regnum-Ordnerpfad ungültig!"
	, eng: "Invalid Regnum-Path!"
	, spa: "Ruta de registro no válida!" }
translations["NO_CFG_FOUND"] := { deu: "keine game.cfg gefunden"
	, eng: "game.cfg not found"
	, spa: "game.cfg no encontrado" }
translations["CFG_TOO_SMALL"] := { deu: "game.cfg gefunden, aber kleiner als 0.5 kB"
	, eng: "game.cfg was found, but it's smaller than 0.5 kB"
	, spa: "Se encontró game.cfg, pero es más pequeño que 0.5 kB" }
translations["CHOOSE_RESOLUTION"] := { deu: "Bitte wähle eine Bildschirm-Auflösung!"
	, eng: "Please choose a screen resolution!"
	, spa: "Por favor, elija una resolución de pantalla!" }
translations["NO_SUCH_SERVER"] := { deu: "Server nicht vorhanden"
	, eng: "Server not found"
	, spa: "Servidor no encontrado" }
translations["NO_SUCH_PUBLISHER"] := { deu: "Publisher nicht vorhanden"
	, eng: "Publisher not found"
	, spa: "Editor no encontrado" }
translations["NO_ACCOUNT_CHOSEN"] := { deu: "Du hast keinen Account ausgewählt! Wähle zuerst 'Accounts verwalten' aus!"
	, eng: "You didn't select any account! Go to 'Manage Accounts' first!"
	, spa: "¡No seleccionaste ninguna cuenta! Vaya a 'Administrar cuentas' primero!" }
translations["TEST_GAME_MISSING"] := { deu: "TestServer\ROClientGame.exe fehlt (Amun-Integration ist experimental)"
	, eng: "TestServer\ROClientGame.exe missing (Amun-Integration is experimental)"
	, spa: "Falta TestServer\ROClientGame.exe (Amun-Integration es experimental)" }
translations["LIVE_GAME_MISSING"] := { deu: "Keine Spieldaten im angegeben Ordner gefunden"
	, eng: "No game files found in the specified folder"
	, spa: "No se encontraron archivos del juego en la carpeta especificada" }
translations["DOWNLOAD_LIVE_GAME_NOW"] := { deu: "Soll das Spiel jetzt dorthin heruntergeladen werden? Das dauert nicht lange.`n`nWenn die Logindaten stimmen, wird das Spiel danach starten. Dann werden lange Zeit Resourcen heruntergeladen werden. Das ist ganz normal: Alle Texturen, die normalerweise im Installer enthalten sind, müssen vom Spiel noch nachgeladen werden, sobald es gestartet ist."
	, eng: "Shall we download the game to this folder now? This doesn't take long.`n`nIf the login succeeds, Regnum will start downloading all game files which may take a long time. This is totally normal: All textures, which are normally included with the installer, need to be downloaded, once it has started."
	, spa: "¿Descarguemos el juego a esta carpeta ahora? Esto no lleva mucho tiempo.`n`nSi el inicio de sesión se realiza correctamente, Regnum comenzará a descargar todos los archivos del juego, lo que puede llevar algún tiempo. Esto es totalmente normal: todas las texturas, que normalmente se incluyen con el instalador, deben descargarse." }
translations["64_BIT_CHANGED"] := { deu: "64-bit-Modus wurde geändert. Deshalb werden jetzt ein paar Dateien aktualisiert. Fortfahren?"
	, eng: "64-bit mode was changed. Thus, some files will be updated. Continue?"
	, spa: "Se cambió el 64-bits-modo. Así, algunos archivos serán actualizados. ¿Continuar?" }
translations["EMPTY_WINDOWS_CREDENTIALS"] := { deu: "Windowsnutzer-Daten müssen deaktiviert oder ausgefüllt sein!"
	, eng: "Please fill out your windows login details or disable the usage of another windows user."
	, spa: "Complete los detalles de inicio de sesión de Windows o deshabilite el uso de otro usuario de Windows." }
translations["RUN_ERROR"] := { deu: "Konnte ROClientGame.exe nicht starten! Falsche Win-Nutzer-Daten oder fehlende Berechtigung?"
	, eng: "Couldn't start ROClientGame.exe! Wrong windows login data or missing permissions?"
	, spa: "No se pudo iniciar ROClientGame.exe! Datos de inicio de sesión incorrectos de Windows o permisos perdidos" }
translations["CONNECTION_ERROR_USER_NOT_FOUND"] := { deu: "Logindaten falsch:`nFalschen Username, falsches Passwort oder falschen Publisher für diesen Account angegeben."
	, eng: "Wrong credentials:`nWrong username, wrong password or wrong publisher configured for this account."
	, spa: "Credenciales incorrectas: nombre de usuario `nWrong, contraseña incorrecta o editor incorrecto configurado para esta cuenta." }
translations["CONNECTION_ERROR_USER_IS_DISABLED"] := { deu: "Accountdaten korrekt, aber der Account ist entweder`n`n1. ...nicht autorisiert: Hierfür bitte einmalig den normalen, offiziellen Launcher benutzen (Spiel betreten nicht notwendig, nur Autorisierung). Oder`n`n2. ...gebannt" ; todo right?
	, eng: "Credentials are correct, but the account is either`n`n1. ...not authorized. To solve this, please for once use the normal, official Regnum Launcher (no need to actually enter the game, just authorize it). Or`n`n2. ...banned"
	, spa: "Las credenciales son correctas, pero la cuenta es o bien `n`n1. ...no autorizado. Para resolver esto, por favor, por una vez, utilice el Regnum Launcher normal y oficial (no es necesario que ingrese al juego, solo autorícelo). O`n`n2. ... prohibido" }
translations["CONNECTION_ERROR_USER_ALREADY_LOGGED_IN"] := { deu: "Account bereits eingeloggt!`n(Zwischen zwei Logins mit demselben Account müssen mindestens 5 Sekunden vergangen sein)"
	, eng: "Account already logged in!`n(Between two logins with the same account there need to have passed 5 seconds at minimum (login cooldown))"
	, spa: "La cuenta ya ha iniciado sesión. `n (Entre dos inicios de sesión con la misma cuenta debe haber pasado 5 segundos como mínimo (tiempo de reutilización de inicio de sesión))" }
translations["INVALID_SERVER_CONFIG"] := { deu: "serverConfig.txt enthält nicht lesbare Daten. Vermutlich ist dies dein erster Programmstart und du hast keine Internetverbindung oder der cor-forum.de - Server ist offline / falsch konfiguriert. Bitte versuche es später noch einmal. Bitte melde uns diese Störung auch."
	, eng: "serverConfig.txt contains invalid data. This is probably your first Quickstarter run and your internet connection or the cor-forum.de is offline / badly configured. Please try again later. Please also contact us if this problem persists."
	, spa: "serverConfig.txt contiene datos inválidos. Esta es probablemente la primera vez que ejecuta Quickstarter y su conexión a Internet o cor-forum.de está fuera de línea / mal configurada. Por favor, inténtelo de nuevo más tarde. Por favor contáctenos también si este problema persiste." }
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
	hModule := DllCall("LoadLibrary", "Str", "advapi32.dll", "Ptr")
	, VarSetCapacity(MD5_CTX, 104, 0), DllCall("advapi32\MD5Init", "Ptr", &MD5_CTX)
	, DllCall("advapi32\MD5Update", "Ptr", &MD5_CTX, "AStr", string, "UInt", StrLen(string))
	, DllCall("advapi32\MD5Final", "Ptr", &MD5_CTX)
	loop, 16
		o .= Format("{:02" (case ? "X" : "x") "}", NumGet(MD5_CTX, 87 + A_Index, "UChar"))
	DllCall("FreeLibrary", "Ptr", hModule)
	StringLower, o,o
	return o
} ;https://autohotkey.com/boards/viewtopic.php?f=6&t=21




































