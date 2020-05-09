checkAppdata:
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
	for k,v in ["icon.png", "logo_cor.png", "logo_discord.png", "logo_forum.png", "bg1.png", "RegnumNews.txt"] { ; files needed for the RegnumStarter to work
		if(!FileExist(APPDATA "/" v)) {
			tooltip, Downloading %v%...
			UrlDownloadToFile, %BASE_URL%%v%, %APPDATA%/%v%
			if(errorlevel) { ; note: no error will be detected when response is an error message like 404
				; who cares
			}
		}
	}
return