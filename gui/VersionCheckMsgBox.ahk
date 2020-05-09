;	// RegnumStarter Version Check MsgBox

SetTimer, HideButton1, -50 ; set a timer after which the button will be hidden

MsgBox,,% T.CHECKING_UPDATES_HEADER, % T.CHECKING_UPDATES
settimer, updateServerConfig, -10 ; blauhirn: todo .. ? - do not block the gui
return

;	// class to hide the button
HideButton1:
control, hide,, button1, ahk_class #32770
return
;	//

MsgBox

OnExit, ExitSub

return