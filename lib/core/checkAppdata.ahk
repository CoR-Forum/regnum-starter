checkAppdata:
tooltip, Updating news...
	 ; delete Regnum News file on close so it re-downloads the new file
;	function to delete tmp files of the regnumStarter on ExitApp
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

	for k,v in ["ronews.txt", "icon.png", "logo_cor.png", "logo_discord.png", "logo_forum.png", "logo_wiki.png", "bg_main_v5_0_1.png", "bg_settings.png", "btn_play.png","btn_blue_70px.png","btn_blue_90px.png","btn_blue_134px.png","btn_blue_158px.png","btn_green_70px.png","btn_green_90px.png","btn_green_162px.png","btn_red_70px.png","btn_red_90px.png","circle-on.png","circle-off.png"] { ; files needed for the RegnumStarter to work
		if(!FileExist(APPDATA "/" v)) {
			tooltip, Downloading %v%... 
			UrlDownloadToFile, %BASE_URL%%v%, %APPDATA%/%v%
			;tooltip ; fix to remove the tooltip
			if(errorlevel) { ; note: no error will be detected when response is an error message like 404
				; who cares
			}
		}
	}
gosub, updateServerConfig
return

;	function to clear unused data from %APPDATA%
clearAppdata:
		filedelete, %APPDATA%/ronews.txt
		filedelete, %APPDATA%/bg1.png
		filedelete, %APPDATA%/bg2.png
		filedelete, %APPDATA%/bckg.png
		filedelete, %APPDATA%/background.png
		filedelete, %APPDATA%/bg_main.png
return

clearTmpAppdata:
	if(rs_delete_tmp_files==1)
		filedelete, %APPDATA%\*.png
		filedelete, %APPDATA%/ronews.txt
		filedelete, %APPDATA%/RegnumNews.txt
return