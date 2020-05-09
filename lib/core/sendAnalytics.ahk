sendAnalytics:
	; synchronously, blocks UI, cannot set timeout, messy when no internet connection
	; urldownloadtofile, *0 %BASE_URL%serverConfig.txt?disablecache=%A_TickCount%, %APPDATA%/serverConfig.txt
	; asynchronous (XHR), see https://www.autohotkey.com/docs/commands/URLDownloadToFile.htm#XHR:
	SendAnalytics := ComObjCreate("Msxml2.XMLHTTP")
	SendAnalytics.open("GET", BASE_URL "track.php", true)
	SendAnalytics.send()
return
