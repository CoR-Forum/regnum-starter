sendAnalytics:
sendAnalytics := ComObjCreate("Msxml2.XMLHTTP")
	sendAnalytics.open("GET", BASE_URL "track.php", true)
	sendAnalytics.send()
return
