#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>

; Pack Manager v1.5.1
; by Air.Fox


Global $store_init_btn, $store_status, $store_name, $store_gold, $store_xunlai
Global $store_bags1, $store_bags2, $store_bags3, $store_bags4
Global $store_store_golds, $store_get_golds, $store_id_all, $store_sell_all
Global $store_salvage_runes, $store_salvage_all, $store_withdraw, $store_deposit
Global $store_sell_runes, $store_sell_common, $store_smart_store, $store_sell_rare

Global $store_buttons = StringSplit("$store_init_btn," & _
		"$store_bags1,$store_bags2,$store_bags3,$store_bags4," & _
		"$store_store_golds,$store_get_golds,$store_id_all,$store_sell_all," & _
		"$store_salvage_runes,$store_salvage_all,$store_withdraw,$store_deposit," & _
		"$store_sell_runes,$store_sell_common,$store_smart_store,$store_sell_rare", _
		",")

Global $store_initialized	= False

Func PackManGUI()
	Opt("GUIOnEventMode", 1)
	GUICreate("PackMan", 220, 335, -1, -1, -1)
	GUISetFont(9, 500, 0, "Arial")

	$store_init_btn = GUICtrlCreateButton("Init", 180, 10, 30, 30)
	$store_name = GUICtrlCreateLabel("Name: ", 10, 10, 160, 15)
	$store_gold = GUICtrlCreateLabel("Gold: ", 10, 25, 75, 15)
	$store_xunlai = GUICtrlCreateLabel("Xunlai: ", 90, 25, 90, 15)
	
	GUICtrlCreateLabel("Use Bags: ", 10, 48, 65, 20)
    $store_bags1 = GUICtrlCreateRadio("1", 87, 45, 30, 20)
    $store_bags2 = GUICtrlCreateRadio("2", 120, 45, 30, 20)
    $store_bags3 = GUICtrlCreateRadio("3", 151, 45, 30, 20)
    $store_bags4 = GUICtrlCreateRadio("4", 182, 45, 30, 20)
    GUICtrlSetState($store_bags3, $GUI_CHECKED)

	$store_store_golds = GUICtrlCreateButton("Store Golds", 10, 75, 95, 30)
	$store_get_golds = GUICtrlCreateButton("Get Golds", 115, 75, 95, 30)
	$store_id_all = GUICtrlCreateButton("Identify All", 10, 115, 95, 30)
	$store_sell_all = GUICtrlCreateButton("Sell All", 115, 115, 95, 30)
	
	$store_salvage_runes = GUICtrlCreateButton("Salvage Runes", 10, 155, 95, 30)
	$store_salvage_all = GUICtrlCreateButton("Salvage Mats", 115, 155, 95, 30)
	
	$store_sell_runes = GUICtrlCreateButton("Sell Runes", 10, 195, 95, 30)
	$store_sell_common = GUICtrlCreateButton("Sell Mats", 115, 195, 95, 30)
	
	$store_smart_store = GUICtrlCreateButton("Smart Store", 10, 235, 95, 30)
	$store_sell_rare = GUICtrlCreateButton("Sell Rare Mats", 115, 235, 95, 30)
	
	$store_deposit = GUICtrlCreateButton("Deposit Max", 10, 275, 95, 30)
	$store_withdraw = GUICtrlCreateButton("Withdraw Max", 115, 275, 95, 30)
	
	$store_status = GUICtrlCreateLabel("[" & @HOUR & ":" & @MIN & "] waiting to init", 10, 315, 200, 20)
	
	StoreButtonHandlers()
	StoreToggleButtons($GUI_DISABLE)

	GUISetOnEvent($GUI_EVENT_CLOSE, "StoreGUIHandler")
	GUISetState(@SW_SHOW)
EndFunc

Func StoreGUIHandler()
	Switch (@GUI_CtrlId)
		Case $GUI_EVENT_CLOSE
			Exit
		Case $store_bags1, $store_bags2, $store_bags3, $store_bags4
			StoreUpdateNumBags()
		Case $store_store_golds
			StoreDepositUnidGolds()
		Case $store_get_golds
			StoreWithdrawUnidGolds()
		Case $store_id_all
			StoreIdentifyAllBags()
		Case $store_sell_all
			StoreSellAllItems()
		Case $store_salvage_runes
			StoreSalvageAllRunes()
		Case $store_salvage_all
			StoreSalvageAllItems()
		Case $store_sell_runes
			StoreSellAllRunes()
		Case $store_sell_common
			StoreSellAllCommonMats()
		Case $store_smart_store
			StoreSmartStoreAllItems()
		Case $store_sell_rare
			StoreSellAllRareMats()
		Case $store_withdraw
			StoreWithdrawGold()
		Case $store_deposit
			StoreDepositGold()
		Case $store_init_btn
			StoreInitRefresh()
	EndSwitch
EndFunc

Func StoreUpdateNumBags()
	If BitAND(GUICtrlRead($store_bags1), $GUI_CHECKED) Then $USE_BAGS = 1
	If BitAND(GUICtrlRead($store_bags2), $GUI_CHECKED) Then $USE_BAGS = 2
	If BitAND(GUICtrlRead($store_bags3), $GUI_CHECKED) Then $USE_BAGS = 3
	If BitAND(GUICtrlRead($store_bags4), $GUI_CHECKED) Then $USE_BAGS = 4
	StoreOut("using bags: " & $USE_BAGS)
EndFunc

Func StoreWithdrawUnidGolds()
	StoreOut("moving unids to inventory...")
	SetupCancel()
	Local $output = "unids moved: " & MoveUnidGolds($DEST_INV)
	If CountFreeSlots($USE_BAGS) == 0 Then $output = $output & ". bags full."
	StoreOut($output)
	RemoveCancel()
EndFunc

Func StoreDepositUnidGolds()
	StoreOut("moving unids to storage...")
	SetupCancel()
	$STORAGE_FULL = False
	Local $output = "unids stored: " & MoveUnidGolds($DEST_STORAGE)
	If $STORAGE_FULL Then $output = $output & ". storage full."
	StoreOut($output)
	RemoveCancel()
EndFunc

Func StoreIdentifyAllBags()
	StoreOut("identifying all items...")
	SetupCancel()
	IdentifyAllBags()
	RemoveCancel()
	Sleep(250)
	GUICtrlSetData($store_gold, "Gold: " & GetGoldCharacter())
	GUICtrlSetData($store_xunlai, "Xunlai: " & GetGoldStorage())
	StoreOut("items identified.")
EndFunc

Func StoreSellAllItems()
	StoreOut("selling all items...")
	SetupCancel()
	SellAllItems()
	RemoveCancel()
	Sleep(250)
	GUICtrlSetData($store_gold, "Gold: " & GetGoldCharacter())
	GUICtrlSetData($store_xunlai, "Xunlai: " & GetGoldStorage())
	StoreOut("items sold.")
EndFunc

Func StoreSalvageAllRunes()
	StoreOut("salvaging valuable runes...")
	SetupCancel()
	SalvageAllRunes()
	RemoveCancel()
	StoreOut("valuable runes salvaged.")
EndFunc

Func StoreSalvageAllItems()
	StoreOut("salvaging for materials...")
	SetupCancel()
	If SalvageAllMats() Then
		StoreOut("items salvaged for mats.")
	Else
		StoreOut("salvage fail, check kits.")
	EndIf
	RemoveCancel()
EndFunc

Func StoreSellAllRunes()
	StoreOut("selling all runes...")
	SetupCancel()
	If TraderSellAllByType($TYPE_RUNE) Then
		StoreOut("all runes sold.")
	Else
		StoreOut("timeout. wrong trader?")
	EndIf
	RemoveCancel()
EndFunc

Func StoreSellAllCommonMats()
	StoreOut("selling all common mats...")
	SetupCancel()
	If TraderSellAllByType($TYPE_COMMON_MAT) Then
		StoreOut("all common mats sold.")
	Else
		StoreOut("timeout. wrong trader?")
	EndIf
	RemoveCancel()
EndFunc

Func StoreSmartStoreAllItems()
	StoreOut("storing all items...")
	SetupCancel()
	If SmartStoreAllItems() Then
		StoreOut("all items stored.")
	Else
		StoreOut("fail. storage full?")
	EndIf
	RemoveCancel()
EndFunc

Func StoreSellAllRareMats()
	StoreOut("selling all rare mats...")
	SetupCancel()
	If TraderSellAllByType($TYPE_RARE_MAT) Then
		StoreOut("all rare mats sold.")
	Else
		StoreOut("timeout. wrong trader?")
	EndIf
	RemoveCancel()
EndFunc

Func StoreWithdrawGold($amount = 0)
	If $amount == 0 Then StoreOut("withdraw max")
	If $amount >  0 Then StoreOut("withdraw " & $amount)
	WithdrawGold($amount)
	Sleep(250)
	GUICtrlSetData($store_gold, "Gold: " & GetGoldCharacter())
	GUICtrlSetData($store_xunlai, "Xunlai: " & GetGoldStorage())
EndFunc

Func StoreDepositGold()
	StoreOut("deposit max")
	DepositGold()
	Sleep(250)
	GUICtrlSetData($store_gold, "Gold: " & GetGoldCharacter())
	GUICtrlSetData($store_xunlai, "Xunlai: " & GetGoldStorage())
EndFunc

Func StoreInitRefresh()
	If Not $store_initialized Then
		If Not Initialize(ProcessExists("gw.exe")) Then
			MsgBox(0, "Error", "Guild Wars it not running.")
			Exit
		EndIf
		$store_initialized = True
		GUICtrlSetData($store_init_btn, "O")
		StoreOut("initialization complete.")
		StoreToggleButtons($GUI_ENABLE)
	Else
		StoreOut("refresh complete.")
	EndIf
	GUICtrlSetData($store_name, "Name: " & GetCharname())
	GUICtrlSetData($store_gold, "Gold: " & GetGoldCharacter())
	GUICtrlSetData($store_xunlai, "Xunlai: " & GetGoldStorage())
EndFunc

Func StoreOut($text)
	GUICtrlSetData($store_status, "[" & @HOUR & ":" & @MIN & "]  " & $text)
EndFunc

Func StoreToggleButtons($state)
    For $i = 2 To $store_buttons[0]
        GUICtrlSetState(Execute($store_buttons[$i]), $state)
    Next
EndFunc

Func StoreButtonHandlers()
    For $i = 1 To $store_buttons[0]
        GUICtrlSetOnEvent(Execute($store_buttons[$i]), "StoreGUIHandler")
    Next
EndFunc

Func SetupCancel()
	StoreToggleButtons($GUI_DISABLE)
	HotKeySet("{ESC}", "ActivateCancel")
EndFunc

Func RemoveCancel()
	HotKeySet("{ESC}")
	$CANCEL_PRESSED = False
	StoreToggleButtons($GUI_ENABLE)
EndFunc

Func ActivateCancel()
	$CANCEL_PRESSED = True
	StoreOut("action cancelled.")
	Sleep(1000)
EndFunc
