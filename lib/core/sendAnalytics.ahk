ANALYTICS_URL = https://analytics.treudler.net/matomo.php?idsite=8&rec=8&uid=%A_ComputerName%
ANALYTICS_PARAMETER_START = &action_name=RegnumStarter_Start

sendAnalyticsOnStart:
sendAnalytics := ComObjCreate("Msxml2.XMLHTTP")
	sendAnalytics.open("GET", ANALYTICS_URL ANALYTICS_PARAMETER_START, true)
	sendAnalytics.send()
return

sendAnalyticsOnLogin:

if(selected_server == 1){
   analytics_selected_server := "Ra"
}
if(selected_server == 2){
   analytics_selected_server := "Valhalla"
}
if(selected_server == 3){
   analytics_selected_server := "Amun"
}

ANALYTICS_PARAMETER_LOGIN = &action_name=RegnumStarter_RegnumLogin
ANALYTICS_PARAMETER_SERVER = _%analytics_selected_server%

sendAnalytics := ComObjCreate("Msxml2.XMLHTTP")
	sendAnalytics.open("GET", ANALYTICS_URL ANALYTICS_PARAMETER_LOGIN ANALYTICS_PARAMETER_SERVER, true)
	sendAnalytics.send()
return
