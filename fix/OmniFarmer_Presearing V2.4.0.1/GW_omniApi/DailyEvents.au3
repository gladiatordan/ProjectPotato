;Original JavaScript : Rheek
;Ported to autoit (proof of concept for PvP events) : Vekk
;Adapted to Nick Presearing : DeeperBlue

Global Const $NICK_SANDFORD_ITEMS = ["Grawl Necklace", "Baked Husk", "Skeletal Limb", "Unnatural Seed", "Enchanted Lodestone", "Skale Fin", "Icy Lodestone", "Gargoyle Skull", "Dull Carapace", "Baked Husk", "Red Iris Flower",  "Spider Leg", "Skeletal Limb", "Charr Carving", "Enchanted Lodestone", "Grawl Necklace", "Icy Lodestone", "Worn Belt", "Gargoyle Skull", "Unnatural Seed", "Skale Fin", "Red Iris Flower",  "Enchanted Lodestone", "Skeletal Limb", "Charr Carving", "Spider Leg", "Baked Husk", "Gargoyle Skull", "Unnatural Seed", "Icy Lodestone", "Grawl Necklace", "Enchanted Lodestone", "Worn Belt", "Dull Carapace", "Spider Leg", "Gargoyle Skull", "Icy Lodestone", "Unnatural Seed", "Worn Belt", "Grawl Necklace", "Baked Husk", "Skeletal Limb", "Red Iris Flower",  "Charr Carving", "Skale Fin", "Dull Carapace", "Enchanted Lodestone", "Charr Carving", "Spider Leg", "Red Iris Flower",  "Worn Belt", "Dull Carapace"]
Global Const $NICK_SANDFORD_ITEMSID = [432, 433, 430, 428, 431, 429, 424, 426, 425, 433, 2994, 422, 430, 423, 431, 432, 424, 427, 426, 428, 429, 2994, 431, 430, 423, 422, 433, 426, 428, 424, 432, 431, 427, 425, 422, 426, 424, 428, 427, 432, 433, 430, 2994, 423, 429, 425, 431, 423, 422, 2994, 427, 425]

#Region Nicholas Sandford (Presearing)
Func CurrentNickPreID() ;Returns Current Nick Pre ID (used by other functions to point in the arrays)
	Local $idx = Floor(Mod(((_GetUnixTime()) - 1239260400) / 86400, 52))
	Return $idx
EndFunc

Func CurrentNickPreItem_Name() ;Returns Current Nick Pre item name
	;logFile("Nick Pre Item is : " & $NICK_SANDFORD_ITEMS[CurrentNickPreID()])
	Return $NICK_SANDFORD_ITEMS[CurrentNickPreID()]
EndFunc

Func CurrentNickPreItem_ID() ;Returns Current Nick Pre item modelID
	Return $NICK_SANDFORD_ITEMSID[CurrentNickPreID()]
EndFunc
#EndRegion Nicholas Sandford (Presearing)

#Region Core functions
; Get timestamp for input datetime (or current datetime).
Func _GetUnixTime($sDate = 0) ;Date Format: 2013/01/01 00:00:00 ~ Year/Mo/Da Hr:Mi:Se

	Local $aSysTimeInfo = _Date_Time_GetTimeZoneInformation()
	Local $utcTime = ""

	If Not $sDate Then $sDate = _NowCalc()

	If Int(StringLeft($sDate, 4)) < 1970 Then Return ""

	If $aSysTimeInfo[0] = 2 Then ; if daylight saving time is active
		$utcTime = _DateAdd('n', $aSysTimeInfo[1] + $aSysTimeInfo[7], $sDate) ; account for time zone and daylight saving time
	Else
		$utcTime = _DateAdd('n', $aSysTimeInfo[1], $sDate) ; account for time zone
	EndIf

	Return _DateDiff('s', "1970/01/01 00:00:00", $utcTime)
EndFunc   ;==>_GetUnixTime
#EndRegion Core functions