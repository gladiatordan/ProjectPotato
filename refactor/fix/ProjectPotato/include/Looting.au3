#Region Looting
Func CanPickUp($lItem)
	If GetMapLoading() == 2 Then Disconnected()
	Local $Quantity
	Local $ModelID = DllStructGetData($lItem, 'ModelID')
	Local $ExtraID = DllStructGetData($lItem, 'ExtraID')
	Local $Type = DllStructGetData($lItem, 'Type')
	Local $Rarity = GetRarity($lItem)
	Local $Requirement = GetItemReq($lItem)
	Local $ModStruct = GetModStruct($lItem)
	
	If IsGeneralItem($ModelID) Then 
		Return True
	EndIf
	If IsEventItem($ModelID) Then 
		Return True
	EndIf
	If IsDye($ModelID, $ExtraID) Then
		Return True
	EndIf
	If IsRegularTome($ModelID) Then
		Return True
	EndIf
	If IsEliteTome($ModelID) Then
		Return True
	EndIf
Return False
EndFunc

Func Loot()
	If GetMapLoading() == 2 Then Disconnected()
	Local $lMe
	Local $lBlockedTimer
	Local $lBlockedCount = 0
	Local $lItemExists = True
	For $i = 1 To GetMaxAgents()
		If GetMapLoading() == 2 Then Disconnected()
		$lMe = GetAgentByID(-2)
		If DllStructGetData($lMe, 'HP') <= 0.0 Then Return
		$lAgent = GetAgentByID($i)
		If Not GetIsMovable($lAgent) Then ContinueLoop
		If Not GetCanPickUp($lAgent) Then ContinueLoop
		$lItem = GetItemByAgentID($i)
		If CanPickUp($lItem) Then
			Do
				If GetMapLoading() == 2 Then Disconnected()
				PickUpItem($lItem)
				Sleep(GetPing())
				Do
					Sleep(100)
					$lMe = GetAgentByID(-2)
				Until DllStructGetData($lMe, 'MoveX') == 0 And DllStructGetData($lMe, 'MoveY') == 0
				$lBlockedTimer = TimerInit()
				Do
					Sleep(3)
					$lItemExists = IsDllStruct(GetAgentByID($i))
				Until Not $lItemExists Or TimerDiff($lBlockedTimer) > Random(5000, 7500, 1)
				If $lItemExists Then $lBlockedCount += 1
			Until Not $lItemExists Or $lBlockedCount > 5
		EndIf
	Next
EndFunc

Func IsGeneralItem($lModel)
	Switch $lModel
		Case $MODEL_ID_GOLD_COINS
			If GetGoldCharacter() < 99000 Then 
				Return True
			EndIf
		Case $MODEL_ID_LOCKPICK
			Return True
		Case $MODEL_ID_GLACIAL_STONES
			Return True
	EndSwitch
	Return False
EndFunc

Func IsDye($lModel, $lExtra)
	Switch $lModel
		Case $MODEL_ID_DYE
			Switch $lExtra
				Case $EXTRA_ID_BLACK
					Return True
				Case $EXTRA_ID_WHITE
					Return True
			EndSwitch
	EndSwitch
	Return False
EndFunc

Func IsEliteTome($lModel)
	Switch $lModel
		Case $MODEL_ID_TOME_E_SIN
			Return True
		Case $MODEL_ID_TOME_E_MES
			Return True
		Case $MODEL_ID_TOME_E_NEC
			Return True
		Case $MODEL_ID_TOME_E_ELE
			Return True
		Case $MODEL_ID_TOME_E_MONK
			Return True
		Case $MODEL_ID_TOME_E_WAR
			Return True
		Case $MODEL_ID_TOME_E_RANGER
			Return True
		Case $MODEL_ID_TOME_E_DERV
			Return True
		Case $MODEL_ID_TOME_E_RIT
			Return True
		Case $MODEL_ID_TOME_E_PARA
			Return True
	EndSwitch
	Return False
EndFunc

Func IsRegularTome($lModel)
	Switch $lModel
		Case $MODEL_ID_TOME_R_SIN
			Return True
		Case $MODEL_ID_TOME_R_MES
			Return False
		Case $MODEL_ID_TOME_R_NEC
			Return True
		Case $MODEL_ID_TOME_R_ELE
			Return True
		Case $MODEL_ID_TOME_R_MONK
			Return True
		Case $MODEL_ID_TOME_R_WAR
			Return True
		Case $MODEL_ID_TOME_R_RANGER
			Return True
		Case $MODEL_ID_TOME_R_DERV
			Return True
		Case $MODEL_ID_TOME_R_RIT
			Return True
		Case $MODEL_ID_TOME_R_PARA
			Return True
	EndSwitch
	Return False
EndFunc

Func IsEventItem($lModel)
	If GetMapLoading() == 2 Then Disconnected()
	Switch $lModel
		Case $MODEL_ID_TOTS
			Return True
		Case $MODEL_ID_GOLDEN_EGGS
			Return True
		Case $MODEL_ID_CUPCAKES
			Return True
		Case $MODEL_ID_PIE
			Return True
		Case $MODEL_ID_SHAMROCK_ALE
			Return True
		Case $MODEL_ID_CIDER
			Return True
		Case $MODEL_ID_LUNAR_TOKEN
			Return True
		Case $MODEL_ID_HUNTERS_ALE
			Return True
		Case $MODEL_ID_EGGNOGG
			Return False
		Case $MODEL_ID_DELICIOUS_CAKE
			Return True
		Case $MODEL_ID_ICED_TEA
			Return True
		Case $MODEL_ID_PARTY_BEACON
			Return True
		Case $MODEL_ID_CANDYCANE_SHARDS
			Return True
	EndSwitch
	Return False
EndFunc
