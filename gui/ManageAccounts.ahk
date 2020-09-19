ManageAccounts:
	refererlist =
	for i,referer in referers {
		refererlist .= "|" referer.name
	}
	placeholder := "   "
	gui, 1:+disabled
	Gui, 2:Font, s8 c000000, Verdana
	gui, 2:add, text, x+40 y+6, % T.NAME "`t`t`t" T.PASSWORD "`t`t" T.PUBLISHER "`t`t" T.COMMENT
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
	gui, 2:add, button, ggui2_add x20,Add new account
	gui, 2:add, text, ggui2_add x30, % T.PASSWORD_ENCRYPTION_INFO
	gui, 2:add, button, g2guiok x235, Ok
	gui, 2:add, button, g2guicancel x180 yp+0 xp+38, Cancel
	gui, 2:show
return

gui2_add:
	gosub 2guiok
	users.push(new User())
	gosub ManageAccounts
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
