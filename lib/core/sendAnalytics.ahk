sendAnalytics:
sendAnalytics := ComObjCreate("Msxml2.XMLHTTP")
	sendAnalytics.open("GET", ANALYTICS_URL "", true)
	sendAnalytics.send()
return
