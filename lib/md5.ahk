md5(string)		;	// by SKAN | rewritten by jNizM
{
	hModule := DllCall("LoadLibrary", "Str", "advapi32.dll", "Ptr")
	, VarSetCapacity(MD5_CTX, 104, 0), DllCall("advapi32\MD5Init", "Ptr", &MD5_CTX)
	, DllCall("advapi32\MD5Update", "Ptr", &MD5_CTX, "AStr", string, "UInt", StrLen(string))
	, DllCall("advapi32\MD5Final", "Ptr", &MD5_CTX)
	loop, 16
		o .= Format("{:02" (case ? "X" : "x") "}", NumGet(MD5_CTX, 87 + A_Index, "UChar"))
	DllCall("FreeLibrary", "Ptr", hModule)
	StringLower, o,o
	return o
}	;	// https://autohotkey.com/boards/viewtopic.php?f=6&t=21