checkLanguage:
	while(empty(language)) {
		InputBox, language, Language - Sprache - Idioma, Please select a language (eng)`n`nBitte wähle eine Sprache (deu)`n`nPor favor elija un idioma (spa)`n`neng deu spa,,,,,,,,deu
		if(RegExMatch(language, "i)de|ger"))
			language = deu
		else if(RegExMatch(language, "i)en|usa|gb"))
			language = eng
		else if(RegExMatch(language, "i)es|sp|ar"))
			language = spa
		else {
			msgbox, Failed to detect language.`n`nKonnte Sprache nicht erkennen.`n`nNo entendió el lenguaje.
			language =
					}
	}
return
