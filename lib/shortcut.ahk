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
		filecreateshortcut, %exe%, %shortcut%.lnk, %a_workingDir%,% params,, %APPDATA%\icon.png
	} else {
		script = "%A_ScriptFullPath%"
		filecreateshortcut,"%a_ahkpath%", %shortcut%.lnk, %a_workingDir%,% script " " params,, %APPDATA%\icon.png
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