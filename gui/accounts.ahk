AccountsGuiAdd:
	gosub AccountsGuiOk
	users.push(new User())
	gosub Accounts
return

AccountsGuiOk:
	gui, 5:submit, nohide
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
	gosub AccountsGuiClose
return

AccountsGuiClose:
AccountsGuiCancel:
	gui, 1:-disabled
	gui, 5:destroy
	winactivate, ahk_id %GUIID%
return

Accounts:
    Gui, 5: -DPIScale
	SysGet, CBW, 71
	SysGet, CBH, 72
	cbw -= 2
	cbh  -= 2

	Gui, 5:+LastFound

	Gui, 1:+disabled ; disable main GUI
	Gui, 5:-SysMenu
	Gui, 5:-Caption

;	// Window title
	Gui, 5:Font, s11 bold cD8D8D8, Verdana
	Gui, 5:add, text, x240 center y6 w140 h25 backgroundtrans, settings
	Gui, 5:Font, s7 cD8D8D8, Verdana
  	Gui, 5:Add, Picture, x0 y0, %APPDATA%\bg_settings.png
	Gui, 5:Font, s8  normal cD8D8D8, Verdana

;	// close button
	Gui, 5:Font, s12 cD8D8D8, Verdana
	gui, 5:add, text, x533 backgroundtrans y4 gAccountsGuiCancel
    Gui, 5:Font, s7 cD8D8D8, Verdana
	Gui, 5:Add, Picture, gAccountsGuiCancel x340 y305  backgroundtrans, %APPDATA%\btn_red_90px.png
	Gui, 5:add, Text, xp+10 yp+5 backgroundtrans, % T.UI_CANCEL
	;Gui, 4:Add, Picture, gSettingsGuiSave xp+130 y310 backgroundtrans, %APPDATA%\button-blue-small.png
	;Gui, 4:add, Text, xp+40 yp+5 backgroundtrans, % T.UI_SAVE
	Gui, 5:Add, Picture, gAccountsGuiOk xp+85 y305 backgroundtrans, %APPDATA%\btn_green_90px.png
	Gui, 5:add, Text, xp+10 yp+5 backgroundtrans, % T.UI_SAVE
	Gui, 5:Font, s9 bold cD8D8D8, Verdana
    

    refererlist =
	for i,referer in referers {
		refererlist .= "|" referer.name
	}
	placeholder := "   "
	    Gui, 5:Font, normal s7 cD8D8D8, Verdana

	gui, 5:add, text, x30 y32 backgroundtrans, % T.PASSWORD_ENCRYPTION_INFO
	Gui, 5:Font, bold s8 cD8D8D8, Verdana
Gui, 5:add, Text, x70 y50 backgroundtrans, % T.NAME
Gui, 5:add, Text, x+70 yp backgroundtrans, % T.PASSWORD
Gui, 5:add, Text, x+60 yp backgroundtrans, % T.PUBLISHER
Gui, 5:add, Text, x+70 yp backgroundtrans, % T.COMMENT
	if(users.Length()==0)
		users.push(new User())
	for i,user in users {
		y := 40 + a_index * 28
		Gui, 5:Font, normal s8 c000000, Verdana
		gui, 5:add, edit, -multi r1 x40 y%y% w130 vname%a_index%, % user.name
		Gui, 5:Font, s8 c9B0000, Verdana
		gui, 5:add, edit, -multi r1 x+5 y%y% w100 vpw%a_index% password, %placeholder%
		Gui, 5:Font, s8 c000000, Verdana
		gui, 5:add, dropdownlist, x+5 y%y% w100 vreferer%a_index% altsubmit
		guicontrol, 5:, referer%a_index%, %refererlist%
		try
			referer := referer_by_token(user.referer.token)
		catch {
			referer := referers[1]
		}
		guicontrol, 5:choose, referer%a_index%, % referer.name
		gui, 5:add, edit, -multi r1 x+5 y%y% w130 vcomment%a_index%, % user.comment
	}
    	Gui, 5:Font, s7 normal cD8D8D8, Verdana
	Gui, 5:Add, Picture, gAccountsGuiAdd x45 y+10 backgroundtrans, %APPDATA%\btn_blue_70px.png
    Gui, 5:Add, Text , xp+10 yp+5 backgroundtrans, add new
Gui, 5:Show, w550 h336 x%GuiX% y%GuiY%, settings
;WinGet, GuiID, ID, A
return