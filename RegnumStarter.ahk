#persistent ; keep the script running
#singleinstance Force ; starting the application again will close any existing version of it

APPDATA := A_AppData "\RegnumStarter" ; set the APPDATA folder
global APPDATA

BASE_URL = https://cor-forum.de/regnum/schnellstarter/

rs_version_release = 5.2.2-1

SetWorkingDir, %A_ScriptDir%
OnError("ErrorFunc")
gosub, checkAppdata
gosub, readUserConfig
;gosub, checkLanguage
gosub, setTranslations
try menu, tray, icon, %APPDATA%/rsicon.ico
coordmode,mouse,screen
gosub, readServerConfig ; servers and referers
goSub, readUsers
iniread, server_version, %APPDATA%/serverConfig.txt, version, version, -1
iniread, rs_version, %APPDATA%/serverConfig.txt, version, rs_version, -1
iniread, rs_news_version, %APPDATA%/serverConfig.txt, version, rs_news_version, -1
iniread, rs_changelog_version, %APPDATA%/serverConfig.txt, version, rs_changelog_version, -1
iniread, autopatch_server, %APPDATA%/serverConfig.txt, general, autopatch_server
gosub, gui_main

#Include %A_ScriptDir%\lib\core\sendAnalytics.ahk

;	// INC_SCR remove window border
#Include %A_ScriptDir%\lib\removeRegnumWindowBorder.ahk

;	// INC_SCR try to automatically detect the language
;#Include %A_ScriptDir%\locales\checkLanguage.ahk

;	// INC_SCR include translations snippet
#Include %A_ScriptDir%\locales\translations.ahk

;	// RegnumStarter is running from shortcut
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
	;SetTimer, ExitAfterQuicklaunch, 3
}

ExitAfterQuicklaunch(){
	Global
ExitApp
Return
}

;	// RegnumStarter Update Check ToolTip
ToolTip, % T.CHECKING_UPDATES
SetTimer, updateServerConfig, -10
SetTimer, sendAnalyticsOnStart, -10


ToolTip
OnExit, ExitSub

return
; // checkAppdata function

#Include %A_ScriptDir%\lib\core\checkAppdata.ahk

updateServerConfig:
	ToolTip, % T.CHECKING_UPDATES
	; synchronously, blocks UI, cannot set timeout, messy when no internet connection
	; urldownloadtofile, *0 %BASE_URL%serverConfig.txt?disablecache=%A_TickCount%, %APPDATA%/serverConfig.txt
	; asynchronous (XHR), see https://www.autohotkey.com/docs/commands/URLDownloadToFile.htm#XHR:
	serverConfigReq := ComObjCreate("Msxml2.XMLHTTP")
	serverConfigReq.open("GET", BASE_URL "serverConfig.txt?disablecache=" A_TickCount, true)
	serverConfigReq.onreadystatechange := Func("updateServerConfigCallback")
	serverConfigReq.send()
return

updateServerConfigCallback() {
	global
	if (serverConfigReq.readyState != 4)
		return
	if (serverConfigReq.status != 200 || serverConfigReq.responseText == "") {
		msgbox % T.INVALID_SERVER_CONFIG
		return
	}
	tooltip, Writing Configuration...
	fileDelete, %APPDATA%/serverConfig.txt
	fileAppend, % serverConfigReq.responseText, %APPDATA%/serverConfig.txt
	iniread, rs_version_new, %APPDATA%/serverConfig.txt, version, rs_version, -1 ; in versions < 2.1, this was program_version
	tooltip
	; main program update?
	if(rs_version > -1 && rs_version_new > rs_version) { ; is not first program start and update
		iniread, rs_update_info, %APPDATA%/serverConfig.txt, version, rs_update_info, -1
		for k,f in [ "RegnumStarter.exe"] {
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
			Del RegnumStarter.exe
			Rename RegnumStarter.exe_new RegnumStarter.exe
			%A_ScriptFullPath%
			Del `%0
			)
		filedelete, update.bat
		fileAppend, %updateBat%, update.bat
		if(errorlevel)
			gosub autoUpdateFailed
		msgbox, ,RegnumStarter - Update, % T.NEW_UPDATE_DOWNLOADED "`n`n" rs_update_info
		run, update.bat,, ;hide
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
	; otherwise, news update?
	iniread, rs_news_version_new, %APPDATA%/serverConfig.txt, version, rs_news_version, -1
	if(rs_news_version_new == -1) {
		msgbox, % T.INVALID_SERVER_CONFIG
		exitapp
	}
	;if(rs_news_version_new > rs_news_version) {
;		Tooltip, moin
		;urldownloadtofile, %BASE_URL%/ronews.txt, %APPDATA%/ronews.txt
;		if(rs_news_version > -1)
;			msgbox, ,RegnumStarter - News Update, News Updated!
;		reload
;	}
}

autoUpdateFailed:
	msgbox % errorlevel " " T.AUTO_UPDATE_FAILED "`n`n" update_info
	tooltip
	fc=
	filedelete updateBat
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
		necessaryLiveFiles := ["ROClientGame.exe", "shaders.ngz", "scripts.ngz", "openal.dll"] ; minimally necessary files inside liveserver folder for the game to start. more or less coincidentally, these are also the ones that need to be downloaded when 32/64 mode changed (according to the normal launcher workflow, did not check if this is optimizable)
		if(win64)
			necessaryLiveFiles.Push("steam_api64.dll") ; the only file with a different name in 64 bit mode...
		else
			necessaryLiveFiles.Push("steam_api.dll")
			;unnecessaryLiveFiles := [ "current_build", "dbghelp.dll", "libbz2.dll", "libjpeg62.dll", "libpng13.dll", "libtheora.dll", "libzip.dll", "ngdlogo.png", "ogg.dll", "readme.txt", "resources", "splash_ngd.ogg", "steamclient.dll", "Steam.dll", "tier0_s.dll", "vorbis.dll", "vorbisfile.dll", "vstdlib_s.dll", "zlib1.dll" ] ; all the waste the normal launcher downloads but is actually not needed
		for k,file in necessaryLiveFiles {
			if(!patchLiveGamefile(file)) {
				FileDelete, %live%ROClientGame.exe ; so downloadAll will surely be true next time
				goto exitThread
			}
		}
		IniWrite, %win64%, %launcherini%, build, win64
		msgbox
		gosub startGame
	} else {
		;; Check if update available, then download and overwrite those files that might contain changes
		;tooltip, % T.CHECKING_GAME_UPDATES
;
		;; Async: Will start game afterwards
		;add := win64 ? "64" : ""
		;gameHeadUrl := autopatch_server "/autopatch/autopatch_files" add "_rgn/ROClientGame.exe?nocache&disablecache=" A_TickCount
		;gameHeadReq := ComObjCreate("Msxml2.XMLHTTP")
		;;gameHeadReq.setTimeouts(5000, 5000, 1000, 1000)
		;RunWait, gameHeadReq.open("GET", gameHeadUrl, true), 1000
		;gameHeadReq.onreadystatechange := Func("updateGamefilesCallback")
		;gameHeadReq.send()
		gosub startGame
		gui, 1:-disabled
	}
return

updateGamefilesCallback() {
	global
	if (gameHeadReq.readyState != 4) {
		return
	}
	if (gameHeadReq.status != 200) {
		msgbox % "Could not check for new Regnum Update. " gameHeadReq.status
		; gosub startGame ; Continue anyway (disabled)
		gui, 1:-disabled
		tooltip
		return
	}
	gameReqETag := gameHeadReq.getResponseHeader("ETag")
	gameReqETag := RegExReplace(gameReqETag, "\W", "")
	regnumUpdateDetected := game_etag != gameReqETag
	if(regnumUpdateDetected) {
		msgbox, 1, Regnum Update, % T.NOTICED_NEW_UPDATE
		IfMsgBox, Cancel
		{
			gui, 1:-disabled
			tooltip
			return
		}
		for k,file in ["ROClientGame.exe", "shaders.ngz", "scripts.ngz"]
			patchLiveGamefile(file)
		game_etag := gameReqETag
		msgbox, % T.UPDATING_FINISHED
	}
	tooltip
	gui, 1:-disabled
	gosub startGame
}

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
		, language: "eng"
		, rs_delete_tmp_files: 0
		, rs_close_on_login: 0
		, selected_user: 1
		, selected_server: 1
		, skip_logo: 1
		, win64: 0
		, hide_loading_screen: 0
		, game_etag: -1
		, net_fake_lag: 0
		, width: 1366
		, height: 768
		, ingame_log: 1
		, vg_fullscreen_mode: 0
		, vg_vertical_sync: 1
		, reg_vg_gui_skin: 1
		, screenshot_quality: 1
		, screenshot_autosave: 1
		, cl_update_all_resources: 0
		, cl_crafting_show_min_level: 0
		, cl_show_subclass_on_players: 0
		, cl_show_hidden_armors: 0
		, cl_invert_selection_priority: 0
		, cl_disable_terrain_loading: 0
		, cl_terrain_load_radius: 4
		, dbg_ignore_server_time: 0
		, env_weather: "clear"
		, debug_mode: 0
		, hide_window_border:0
		, regnum_path: "C:\Games\NGD Studios\Champions of Regnum\"
		, runas: 0
		, runas_name: a_space
		, runas_pw: a_space
		;, PosGuiX: -1
		;, PosGuiY: -1
		, close_on_run: 1
		, shortcut_last: a_space }
	for k,default in configEntries {
		%k% := config_read(k, default)
	}
return
writeUserConfig:
	if(selected_server=="")
		selected_server := 1
	if(reg_vg_gui_skin=="")
		reg_vg_gui_skin := 1
	if(cl_terrain_load_radius=="")
		cl_terrain_load_radius := 4
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
goSub clearAppdata
goSub clearTmpAppdata
exitapp

writeAllConfigs:
	gui,submit,nohide
	goSub writeUsers
	goSub writeUserConfig
return

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

#Include %A_ScriptDir%\gui\gui_main.ahk

#Include %A_ScriptDir%\gui\settings.ahk

#Include %A_ScriptDir%\gui\accounts.ahk

#Include %A_ScriptDir%\gui\notes.ahk

#Include %A_ScriptDir%\gui\gui7_changelogs.ahk

; //////
updateUserlist:
		userlist := ""
		for i,user in users {
			userlist .= "|" user.name
			if(user.comment)
				userlist .= " (" user.comment ")"
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

;	// load ShortcutCreate


login:
	gosub setupParams
	goSub writeUserConfig
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

; // User request; validate and maybe proceed to startGame
run:
	;	// game path for live and test server
	live = %regnum_path%LiveServer\
	test = %regnum_path%TestServer\
	SetTimer, sendAnalyticsOnLogin, -10

;	// USER INPUT VALIDATION

	if(empty(run_user.name) || empty(run_user.pw_hashed)) {
		msgbox % T.NO_ACCOUNT_CHOSEN
		return
	}

	if(empty(width) || empty(height)){
		msgbox, % T.CHOOSE_RESOLUTION
		return
	}

;	// check if amun has been selected

	if(run_server.name == "Amun") {
		ifnotexist, %test%ROClientGame.exe
		{
			msgbox, % T.TEST_GAME_MISSING
			return
		}
	}



	;;;;;;;; GAME.CFG

;	// set weather (these values seem to be wrong at all)
if(weather == 1)
   env_weather := "clear"
else if (weather == 2)
   env_weather := "rainy"
else if (weather == 3)
   env_weather := "snow" // existing
else if (weather == 4)
   env_weather := "thunder" // ?



;	// ??
	gamecfg := regnum_path "game.cfg"
	if(!FileExist(gamecfg)) {
		FileAppend, [Regnum Config File], %gamecfg% ; somehow fixes weird iniwrite behaviour
		iniwrite, .., %gamecfg%, client, cl_sdb_path ; would otherwise wrongly be set to "." afterwards, when the file is being filled up by the game itself (as apposed to the one included in the installers where it is ".."). For compatibility's sake, set it to ".." here.)
	}
if(reg_vg_gui_skin == 1){
   vg_gui_skin := "regnum_default"
}
if(reg_vg_gui_skin == 2){
   vg_gui_skin := "regnum_loadingscreen"
}
if(reg_vg_gui_skin == 3){
   vg_gui_skin := "regnum_mainmenu"
}
if(reg_vg_gui_skin == 4){
   vg_gui_skin := "regnum_mainmenuv2"
}
if(reg_vg_gui_skin == 5){
   vg_gui_skin := "test"
}
if(reg_vg_gui_skin == 6){
   vg_gui_skin := "default"
}
;	// write to regnum game.cfg
	iniwrite,% run_server.ip,%gamecfg%,server,sv_game_server_host
	iniwrite,% run_server.port,%gamecfg%,server,sv_game_server_tcp_port
	iniwrite,% run_server.retr,%gamecfg%,server,sv_retriever_host
	iniwrite,% run_user.referer.token,%gamecfg%,client,cl_referer
	iniwrite,% ! hide_loading_screen,%gamecfg%,client,cl_show_loading_screen
	iniwrite,% net_fake_lag,%gamecfg%,network,net_fake_lag
	iniwrite,% language,%gamecfg%,client,cl_language
	iniwrite,% cl_invert_selection_priority,%gamecfg%,client,cl_invert_selection_priority
	iniwrite,% cl_crafting_show_min_level,%gamecfg%,client,cl_crafting_show_min_level
	iniwrite,% cl_show_subclass_on_players,%gamecfg%,client,cl_show_subclass_on_players
	iniwrite,% cl_disable_terrain_loading,%gamecfg%,client,cl_disable_terrain_loading
	iniwrite,% cl_terrain_load_radius,%gamecfg%,client,cl_terrain_load_radius
	iniwrite,% width,%gamecfg%,video_graphics,vg_screen_width
	iniwrite,% height,%gamecfg%,video_graphics,vg_screen_height
	iniwrite,% vg_fullscreen_mode,%gamecfg%,video_graphics,vg_fullscreen_mode
	iniwrite,% vg_vertical_sync,%gamecfg%,video_graphics,vg_vertical_sync
	iniwrite,% vg_gui_skin,%gamecfg%,video_graphics,vg_gui_skin
	iniwrite,% dbg_ignore_server_time,%gamecfg%,debug,dbg_ignore_server_time
	iniwrite,% env_weather,%gamecfg%,general,env_weather
	iniwrite,% env_time_of_day,%gamecfg%,general,env_time_of_day
	iniwrite,% cl_update_all_resources,%gamecfg%,client,cl_update_all_resources

;	// set time env in HOURS (24h)
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



;	// set screenshot quality to 100 percent and save as png. default is jpg and 80 percent.
if(screenshot_quality)  {
 		iniwrite, 100, %gamecfg%, video_graphics, vg_screenshot_quality
		iniwrite, png, %gamecfg%, video_graphics, vg_screenshot_format
	}
else {
 		iniwrite, 80, %gamecfg%, video_graphics, vg_screenshot_quality
		iniwrite, jpg, %gamecfg%, video_graphics, vg_screenshot_format
	}

;	// auto-save screenshots. this won't show the window where you can name a screenshot or delete it.
if(screenshot_autosave)  {
 		iniwrite, 1, %gamecfg%, video_graphics, vg_screenshot_autotag
	}
else {
 		iniwrite, 0, %gamecfg%, video_graphics, vg_screenshot_autotag

	}

;	// write game config for combat log settings

if(ingame_log)  {
 		iniwrite, 1, %gamecfg%, debug, cl_combat_log_colored_names
    	iniwrite, 1, %gamecfg%, debug, cl_combat_log_constant_damage
	    iniwrite, 1, %gamecfg%, debug, cl_combat_log_power_level
	    iniwrite, 1, %gamecfg%, debug, cl_combat_log_small
	}
else {
 		iniwrite, 0, %gamecfg%, debug, cl_combat_log_colored_names
    	iniwrite, 0, %gamecfg%, debug, cl_combat_log_constant_damage
	    iniwrite, 0, %gamecfg%, debug, cl_combat_log_power_level
	    iniwrite, 0, %gamecfg%, debug, cl_combat_log_small
	}

;	// write game config for debug settings

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

;	// remove NGE intro

	if(skip_logo) {
		filedelete, %live%splash.ngz
		filedelete, %live%splash_ngd.ogg
		filedelete, %live%splash_nge.png
		filedelete, %live%splash.ngz
		filedelete, %live%splash_nge.ogg
	}
	else{
			for k,v in ["splash_nge.ogg","splash_nge.png"] {
		if(!FileExist(LIVE "/" v)) {
			tooltip, Downloading NGE Splash
			UrlDownloadToFile, %BASE_URL%%v%, %live%/%v%
			;tooltip ; fix to remove the tooltip
			if(errorlevel) { ; note: no error will be detected when response is an error message like 404
				; who cares
			}

		}
	}
	}


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

	;	// CHECK / DOWNLOAD / UPDATE LIVESERVER (async)

	gui, 1:+disabled
	gosub updateGamefiles ; either terminates or goes to startGame
return

; // The game will now start
startGame:
gui, 1:-disabled
	;;;;;;;; REMOVE WINDOW BORDER OPTION

	if(hide_window_border)
		settimer, removeRegnumWindowBorder, -1000
;	// run the regnum client

	if(run_server.name == "Amun") {
		runwait, % """" test "ROClientGame.exe" """" " " run_user.name " " run_user.pw_hashed, %test%, UseErrorLevel
	}
	else
	{
		runwait, % """" live "ROClientGame.exe" """" " " run_user.name " " run_user.pw_hashed, %live%, UseErrorLevel
	}
	if(rs_close_on_login == 1){
		SetTimer, guiClose, -1000
		;gguiClose,
	}
	if(errorlevel == "ERROR") {
		msgbox, % T.RUN_ERROR
		return
	}


;	// prompt log.txt connection error

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



;	// make gui moveable
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
if LButtonState = U		;	// Button has been released, so drag is complete.
{
    wingetpos, OL_Ecke_GuiX, OL_Ecke_GuiY,,,, A
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
SetWinDelay, -1		;	// Makes the below move faster/smoother.
WinMove, ahk_id %GuiID%,, %GuiX%, %GuiY%
errorlevel := errorlevel_safe
return

DiscordLink:
Run https://discord.gg/CbYETYc
return

ForumLink:
Run https://cor-forum.de
return

WikiLink:
Run https://regnum.wiki
return

OpenScreenshotsFolder:
Run, explore %regnum_path%\LiveServer\screenshots
return

;	// md5 function to securly save account passwords in users.txt
#Include %A_ScriptDir%\lib\md5.ahk

#Include %A_ScriptDir%\lib\SimplePing.ahk
