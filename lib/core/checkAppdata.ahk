checkAppdata:
	filedelete, %APPDATA%/RegnumNews.txt ; delete Regnum News file on close so it re-downloads the new file

;	function to delete tmp files of the regnumStarter on ExitApp
	if(rs_delete_tmp_files==1) {
		filedelete, %APPDATA%\*.png
	}

	if(!fileexist(APPDATA)) {
		FileCreateDir, %APPDATA%
		if(errorlevel) {
			msgbox, % "Couldn't create " APPDATA " folder. Can't startup [" errorlevel "]"
			exitapp
		}
		; this function moves the files from data directory to appdata if you update from RegnumStarter v2.0 to v2.1 or above
		if(FileExist("data") == "D") {
			FileCopy, data\*, %APPDATA%
		}
	}
	for k,v in ["icon.png", "logo_cor.png", "logo_discord.png", "logo_forum.png", "logo_wiki.png", "bg_main.png", "bg_settings.png","RegnumNews.txt", "btn_play.png","btn_blue_70px.png","btn_blue_90px.png","btn_blue_134px.png","btn_blue_158px.png","btn_green_70px.png","btn_green_90px.png","btn_green_162px.png","btn_red_70px.png","btn_red_90px.png","circle-on.png","circle-off.png"] { ; files needed for the RegnumStarter to work
		if(!FileExist(APPDATA "/" v)) {
			tooltip, Downloading %v%...
			UrlDownloadToFile, %BASE_URL%%v%, %APPDATA%/%v%
			if(errorlevel) { ; note: no error will be detected when response is an error message like 404
				; who cares
			}
		}
	}
return

;	function to clear unused data from %APPDATA%
clearAppdata:
		filedelete, %APPDATA%/bg1.png
		filedelete, %APPDATA%/bg2.png
		filedelete, %APPDATA%/bckg.png
		filedelete, %APPDATA%/background.png
return