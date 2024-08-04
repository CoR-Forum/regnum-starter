removeRegnumWindowBorder:
	WinWaitActive, ahk_class Regnum,,3
	WinSet, style, -0xC00000, ahk_class Regnum
return
