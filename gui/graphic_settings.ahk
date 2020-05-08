graphic_settings:
	Gui, 1:+disabled
	Gui, 3:-SysMenu
	Gui, 3:Show, w400 h300, % T.GRAPHIC_SETTINGS_WINDOW_TITLE
	Gui, 3:Font, s8 c000000, Verdana
	Gui, 3:Add, Tab2, x0 y0 w400 h20 Border, RegnumStarter|Hackz|Game|Sound|Graphics|Controls




	;	// hide window boarder
	gui, 3:Tab, 2
		gui, 3:add, checkbox, x20 x20 checked%hide_window_border% backgroundtrans w%CBW% h%CBH% vhide_window_border
		gui, 3:add, text, x+3 yp, % T.HIDE_WINDOW_BORDER

gui, 3:Tab, 1
	gui, 3:add, button, gGraphicSettingsGuiCancel x180 y275, % T.GRAPHIC_SETTINGS_CANCEL
	gui, 3:add, button, gGraphicSettingsGuiSave x255 y275, % T.GRAPHIC_SETTINGS_SAVE
	gui, 3:add, button, gGraphicSettingsGuiOk x330 y275, % T.GRAPHIC_SETTINGS_SAVE_CLOSE
	gui, 3:show

gui, 3:Tab, 2
	gui, 3:add, button, gGraphicSettingsGuiCancel x180 y275, % T.GRAPHIC_SETTINGS_CANCEL
	gui, 3:add, button, gGraphicSettingsGuiSave x255 y275, % T.GRAPHIC_SETTINGS_SAVE
	gui, 3:add, button, gGraphicSettingsGuiOk x330 y275, % T.GRAPHIC_SETTINGS_SAVE_CLOSE
	gui, 3:show

gui, 3:Tab, 3
	gui, 3:add, button, gGraphicSettingsGuiCancel x180 y275, % T.GRAPHIC_SETTINGS_CANCEL
	gui, 3:add, button, gGraphicSettingsGuiSave x255 y275, % T.GRAPHIC_SETTINGS_SAVE
	gui, 3:add, button, gGraphicSettingsGuiOk x330 y275, % T.GRAPHIC_SETTINGS_SAVE_CLOSE
	gui, 3:show

gui, 3:Tab, 4
	gui, 3:add, button, gGraphicSettingsGuiCancel x180 y275, % T.GRAPHIC_SETTINGS_CANCEL
	gui, 3:add, button, gGraphicSettingsGuiSave x255 y275, % T.GRAPHIC_SETTINGS_SAVE
	gui, 3:add, button, gGraphicSettingsGuiOk x330 y275, % T.GRAPHIC_SETTINGS_SAVE_CLOSE
	gui, 3:show

gui, 3:Tab, 5
	gui, 3:add, button, gGraphicSettingsGuiCancel x180 y275, % T.GRAPHIC_SETTINGS_CANCEL
	gui, 3:add, button, gGraphicSettingsGuiSave x255 y275, % T.GRAPHIC_SETTINGS_SAVE
	gui, 3:add, button, gGraphicSettingsGuiOk x330 y275, % T.GRAPHIC_SETTINGS_SAVE_CLOSE
	gui, 3:show

gui, 3:Tab, 6
	gui, 3:add, button, gGraphicSettingsGuiCancel x180 y275, % T.GRAPHIC_SETTINGS_CANCEL
	gui, 3:add, button, gGraphicSettingsGuiSave x255 y275, % T.GRAPHIC_SETTINGS_SAVE
	gui, 3:add, button, gGraphicSettingsGuiOk x330 y275, % T.GRAPHIC_SETTINGS_SAVE_CLOSE
	gui, 3:show
