#include <Array.au3>
#include "_Constants.au3"
#include "_Runes_and_Insignias.au3"
#include "PackMan_GUI.au3"
#include "GWA2.au3"

;~ Pack Manager v1.5.1
;~ Authors: Air.Fox/Logicdoor


Global Const $USE_PACK_GUI		= True	; True if using as standalone pack manager, False if using with another bot
Global Const $STORE_GOLDS		= False	; Should unid golds be stored in chest
Global Const $SALVAGE_TROPHY	= True	; Should trophy items be salvaged
Global Const $FREE_SLOTS		= 5		; Will clean inventory when remaining slots < $FREE_SLOTS
Global $USE_BAGS				= 3		; [1..4] How many of your inventory bags will be used (stuff in there will be sold!)

Global Const $MAP_ID_BALTH_TEMPLE = 248	; using the Merchant and Rune Trader of GToB

Global Enum $DEST_STORAGE, $DEST_INV
Global Enum $KIT_BASIC_SALV, $KIT_EXPERT_SALV, $KIT_ID
Global Enum $TYPE_COMMON_MAT, $TYPE_RARE_MAT, $TYPE_RUNE

Global $STORAGE_FULL		= False	; for internal use
Global $CANCEL_PRESSED		= False	; for internal use

;~ Model_IDs of items with lame common salvage materials
Global Const $DONT_SALVAGE_ARR[16] = [ _
	177		, _ ; Earth Scroll
	178		, _ ; Earth Scroll
	328		, _ ; Wooden Buckler
	330		, _ ; Crude Shield
	348		, _ ; Inscribed Staff
	608		, _ ; Fire Staff
	735		, _ ; Bo Staff
	736		, _ ; Dragon Staff
	1775	, _ ; Spiked Club
	1777	, _ ; Ivory Hammer
	1782	, _ ; Granite Hammer
	1878	, _ ; Goldleaf Defender
	1909	, _ ; Inscribed Staff
	1915	, _ ; Jeweled Staff
	2198	, _ ; Militia Shield
	2274	  _ ; Ruby Maul
]


If $USE_PACK_GUI Then
	PackManGUI()
	While 1
		Sleep(1000)
	WEnd
EndIf


Func RndPingSleep()
	While GetPing() == 0
		Sleep(50)
	WEnd
	RndSleep(GetPing() * 6)
EndFunc

Func FullClearAtGToB()
	If CountFreeSlots($USE_BAGS) > $FREE_SLOTS Then Return
	Out("Cleaning Inventory")
	If GetMapID() <> $MAP_ID_BALTH_TEMPLE Then TravelTo($MAP_ID_BALTH_TEMPLE)
	RndSleep(1000)
	If GetGoldCharacter() > 40000 Then DepositGold()
	If $STORE_GOLDS And Not $STORAGE_FULL Then MoveUnidGolds($DEST_STORAGE)
	GoToNPC(GetNearestNPCToCoords(-4861, -7441))	; Ai Tei [Merchant]
	RndSleep(1000)
	ProcessAllBags()
	MoveTo(-4700, -7250)	; so you don't get stuck at Merchant
	GoToNPC(GetNearestNPCToCoords(-4822, -7730))	; Rune Trader
	RndSleep(1000)
	TraderSellAllByType($TYPE_RUNE)
	RndSleep(1000)
	QuitOnFullInventory()
EndFunc	;==> FullClearAtGToB

;~ Do two passes to clear space before salvaging runes,
;~ and then clean up after runes have been salvaged
Func ProcessAllBags()
	IdentifyAllBags()
	RndSleep(GetPing())
	SalvageStoreSell()
	RndSleep(GetPing())
	SalvageAllRunes()
	RndSleep(GetPing())
	SalvageStoreSell()
EndFunc	;==> ProcessAllBags

Func SalvageStoreSell()
	SalvageAllMats()
	RndSleep(1000)
	SmartStoreAllItems()
	RndSleep(1000)
	SellAllItems()
EndFunc	;==> SalvageStoreSell

Func IdentifyAllBags($id_golds = (Not $STORE_GOLDS))
	Local $timer
	For $bag = 1 To $USE_BAGS
		If $CANCEL_PRESSED Then Return
		If Not CustomIdentifyBag($bag, False, $id_golds) Then
			$timer = TimerInit()
			CheckAvailableKit($KIT_ID)
			Do
				Sleep(50)
			Until CustomFindKit($KIT_ID) Or TimerDiff($timer) > 5000
			CustomIdentifyBag($bag, False, $id_golds)
		EndIf
	Next
EndFunc	;==> IdentifyAllBags

Func SellAllItems()
	Local $item, $timer
	For $bag = 1 To $USE_BAGS
		For $slot = 1 To DllStructGetData(GetBag($bag), 'Slots')
			If $CANCEL_PRESSED Then Return
			$item = GetItemBySlot($bag, $slot)
			If CanSell($item) Then
				$timer = TimerInit()
				SellItem($item)
				Do
					Sleep(50)
					$item = GetItemBySlot($bag, $slot)
				Until DllStructGetData($item, 'ID') == 0 Or TimerDiff($timer) > 5000
			EndIf
		Next
	Next
EndFunc	;==> SellAllItems

;~ Buys kit if not finds one.
;~ Must be one of $KIT_ID, $KIT_BASIC_SALV, $KIT_EXPERT_SALV
Func CheckAvailableKit($kit_type)
	Local $kit, $index, $cost = 100
	Switch $kit_type
		Case $KIT_ID
			$index = 5
		Case $KIT_BASIC_SALV
			$index = 2
		Case $KIT_EXPERT_SALV
			$index = 3
			$cost = 400
	EndSwitch
	$kit = CustomFindKit($kit_type)
	If Not $kit Then
		If GetMapLoading() <> 0 Then Return False
		If GetGoldCharacter() < $cost Then WithdrawGold($cost)
		BuyItem($index, 1, $cost)
		RndSleep(1000)
		$kit = CustomFindKit($kit_type)
	EndIf
	Return $kit
EndFunc	;==> CheckAvailableKit

Func SalvageAllMats($kit_type = $KIT_BASIC_SALV)
	Local $item
	For $bag = 1 To $USE_BAGS
		For $slot = 1 To DllStructGetData(GetBag($bag), 'Slots')
			$item = GetItemBySlot($bag, $slot)
			If CanSalvage($item) Then
				While DllStructGetData($item, 'Type') <> $TYPE_MATERIAL_AND_ZCOINS
					If $CANCEL_PRESSED Then Return
					If Not SalvageItemMats($item, $kit_type) Then Return False
					$item = GetItemBySlot($bag, $slot)
					If DllStructGetData($item, 'ID') == 0 Then ExitLoop
				WEnd
			EndIf
		Next
	Next
	Return True
EndFunc	;==> SalvageAllMats

Func SalvageItemMats($item, $kit_type = $KIT_BASIC_SALV)
	Local $item_ID, $quantity, $timer = TimerInit()
	Local $success = False
	If Not CheckAvailableKit($kit_type) Then Return False
	$item_ID = DllStructGetData($item, 'ID')
	$quantity = DllStructGetData($item, 'Quantity')
	CustomStartSalvage($item, $kit_type)
	If GetRarity($item) <> $RARITY_WHITE Then
		Sleep(GetPing())
		SalvageMaterials()
	EndIf
	While Not $success And TimerDiff($timer) < 5000
		Sleep(50)
		$item = GetBagItemByItemID($item_ID)
		If DllStructGetData($item, 'ID') == 0 Then $success = True
		If DllStructGetData($item, 'Quantity') < $quantity Then $success = True
	WEnd
	Sleep(GetPing())
	Return $success
EndFunc	;==> SalvageItemMats

Func SalvageAllRunes()
	For $bag = 1 To $USE_BAGS
		For $slot = 1 To DllStructGetData(GetBag($bag), 'Slots')
			If $CANCEL_PRESSED Then Return
			SalvageItemRunes(GetItemBySlot($bag, $slot))
		Next
	Next
EndFunc	;==> SalvageAllRunes

Func SalvageItemRunes($item)
	Local $item_ID = DllStructGetData($item, 'ID')
	Local $rune_index = GetValuableRuneIndex($item)
	If $rune_index > -1 Then
		Local $timer = TimerInit()
		Do
			CheckAvailableKit($KIT_EXPERT_SALV)
			CustomStartSalvage($item, $KIT_EXPERT_SALV)
			RndPingSleep()
			SalvageMod($rune_index)
			RndPingSleep()
			$rune_index = GetValuableRuneIndex(GetBagItemByItemID($item_ID))
		Until $rune_index == -1 Or TimerDiff($timer) > 5000
	EndIf
EndFunc	;==> SalvageItemRunes

;~ Allows $TYPE_COMMON_MAT / $TYPE_RARE_MAT / $TYPE_RUNE
Func TraderSellAllByType($item_type)
	Local $item, $model_ID, $timer
	For $bag = 1 To $USE_BAGS
		For $slot = 1 To DllStructGetData(GetBag($bag), 'Slots')
			$item = GetItemBySlot($bag, $slot)
			$model_ID = DllStructGetData($item, 'ModelID')
			Switch $item_type
				Case $TYPE_COMMON_MAT
					If _ArraySearch($COMMON_MATS_ARR, $model_ID) < 0 Then ContinueLoop
				Case $TYPE_RARE_MAT
					If _ArraySearch($RARE_MATS_ARR, $model_ID) < 0 Then ContinueLoop
				Case $TYPE_RUNE
					If DllStructGetData($item, 'Type') <> $TYPE_RUNE_AND_MOD Then ContinueLoop
				Case Else
					Return False	; incorrect $item_type provided
			EndSwitch
			If Not TraderSellStackOfItem($item) Then Return False
		Next
	Next
	Return True
EndFunc	;==> TraderSellAllByType

;~ Sells up to whole stack of given item
Func TraderSellStackOfItem($item)
	Local $model_ID, $sell_limit, $quantity
	$model_ID = DllStructGetData($item, 'ModelID')
	$sell_limit = _ArraySearch($COMMON_MATS_ARR, $model_ID) > -1 ? 10 : 1
	$quantity = DllStructGetData($item, 'Quantity')
	While $quantity >= $sell_limit
		$timer = TimerInit()
		If GetGoldCharacter() > 40000 Then DepositGold()
		TraderRequestSell($item)
		TraderSell()
		Do
			RndSleep(50)
			$item = GetBagItemByItemID(DllStructGetData($item, 'ID'))
			If TimerDiff($timer) > 5000 Or $CANCEL_PRESSED Then Return False
		Until DllStructGetData($item, 'Quantity') < $quantity
		$quantity = DllStructGetData($item, 'Quantity')
	WEnd
	Return True
EndFunc	;==> TraderSellStackOfItem

;~ Moves all Golds except salvageable armors, destination = $DEST_STORAGE / $DEST_INV
Func MoveUnidGolds($destination = $DEST_STORAGE)
	Local $item, $num_stored = 0
	Local $start = $destination == $DEST_STORAGE ? 1 : 8
	Local $end = $destination == $DEST_STORAGE ? $USE_BAGS : 12
	For $bag = $start To $end
		For $slot = 1 To DllStructGetData(GetBag($bag), 'Slots')
			If $STORAGE_FULL Or $CANCEL_PRESSED Then Return $num_stored
			$item = GetItemBySlot($bag, $slot)
			If DllStructGetData($item, 'ID') == 0 Then ContinueLoop
			If DllStructGetData($item, 'Type') == $TYPE_SALVAGE Then ContinueLoop
			If ItemIsSpecialType($item) Or GetIsIDed($item) Then ContinueLoop
			If GetRarity($item) == $RARITY_GOLD Then
				If $destination == $DEST_STORAGE And MoveToStorage($item) Then $num_stored += 1
				If $destination == $DEST_INV And MoveFromStorage($item) Then $num_stored += 1
			EndIf
		Next
	Next
	Return $num_stored
EndFunc	;==> MoveUnidGolds

;~ Stores all items, adding to existing stacks in storage if possible
Func SmartStoreAllItems()
	Local $item, $type
	For $bag = 1 To $USE_BAGS
		For $slot = 1 To DllStructGetData(GetBag($bag), 'Slots')
			If $STORAGE_FULL Or $CANCEL_PRESSED Then Return False
			$item = GetItemBySlot($bag, $slot)
			If DllStructGetData($item, 'ID') == 0 Then ContinueLoop
			If DllStructGetData($item, 'Quantity') == 250 Then
				If Not MoveToStorage($item) Then Return False
				ContinueLoop
			EndIf
			$type = DllStructGetData($item, 'Type')
			Switch $type
				Case $TYPE_USABLE, $TYPE_DYE, $TYPE_MATERIAL_AND_ZCOINS, $TYPE_TROPHY
					If Not SmartStoreItem($item, $type) Then Return False
				Case Else
					ContinueLoop
			EndSwitch
		Next
	Next
	Return True
EndFunc	;==> SmartStoreAllItems

;~ Stores item, adding to existing stack in storage if possible
Func SmartStoreItem($bag_item, $type)
	Local $item_ID, $model_ID, $dest_bag, $dest_slot, $chest_item
	$item_ID = DllStructGetData($bag_item, 'ID')
	$model_ID = DllStructGetData($bag_item, 'ModelID')
	
	If $type == $TYPE_MATERIAL_AND_ZCOINS Then
		$dest_bag = 6
		$dest_slot = $MATERIAL_STORAGE[$model_ID]
	Else
		Local $extra_ID = DllStructGetData($bag_item, 'ExtraId')
		Local $result = FindBestStorageSlotForModelID($model_ID, 8, 12, $extra_ID)
		If Not $result[0] Then Return False
		$dest_bag = $result[0]
		$dest_slot = $result[1]
	EndIf
	$chest_item = GetItemBySlot($dest_bag, $dest_slot)
	If DllStructGetData($chest_item, 'Quantity') == 250 Then MoveToStorage($chest_item)
	If Not MoveItemAndWait($bag_item, $dest_bag, $dest_slot) Then Return False
	
	$bag_item = GetBagItemByItemID($item_ID)
	If DllStructGetData($bag_item, 'Quantity') > 0 Then
		If Not MoveToStorage(GetItemBySlot($dest_bag, $dest_slot)) Then Return False
		If Not MoveItemAndWait($bag_item, $dest_bag, $dest_slot) Then Return False
	EndIf
	Return True
EndFunc	;==> SmartStoreItem

;~ Searches storage for incomplete stack for given $model_ID
;~ Returns either location of stack, or empty slot if stack not found
;~ If moving dyes need to provide ExtraID as well
Func FindBestStorageSlotForModelID($model_ID, $start_bag, $end_bag, $extra_ID = 0)
	Local $item, $chest_model_ID, $quantity, $good_slot[2]
	For $bag = $end_bag To $start_bag Step -1
		For $slot = DllStructGetData(GetBag($bag), 'Slots') To 1 Step -1
			$item = GetItemBySlot($bag, $slot)
			$chest_model_ID = DllStructGetData($item, 'ModelID')
			If Not $chest_model_ID Or $chest_model_ID == $model_ID Then
				If $chest_model_ID == 146 Then	; To not move different dyes to same slot
					If DllStructGetData($item, 'ExtraId') <> $extra_ID Then ContinueLoop
				EndIf
				$good_slot[0] = $bag
				$good_slot[1] = $slot
				If Not $chest_model_ID Then ContinueLoop
				If DllStructGetData($item, 'Quantity') < 250 Then Return $good_slot
			EndIf
		Next
	Next
	Return $good_slot
EndFunc	;==> FindBestStorageSlotForModelID

Func MoveToStorage($item)
	Return FindSlotAndMove($item, 8, 12)
EndFunc	;==> MoveToStorage

Func MoveFromStorage($item)
	Return FindSlotAndMove($item, 1, $USE_BAGS)
EndFunc	;==> MoveFromStorage

;~ Finds slot for item in $start_bag to $end_bag
Func FindSlotAndMove($item, $start_bag, $end_bag)
	Local $slot
	For $bag = $start_bag To $end_bag
		$slot = FindEmptySlot($bag)
		If $slot <> 0 Then Return MoveItemAndWait($item, $bag, $slot)
		If $bag == 12 Then $STORAGE_FULL = True
	Next
	Return False
EndFunc	;==> FindSlotAndMove

;~ Searches for empty slot in $bag
Func FindEmptySlot($bag)
	For $slot = 1 To DllStructGetData(GetBag($bag), 'Slots')
		If DllStructGetData(GetItemBySlot($bag, $slot), 'ID') == 0 Then Return $slot
	Next
	Return 0
EndFunc	;==> FindEmptySlot

;~ Waits for item to finish moving
Func MoveItemAndWait($item, $bag, $slot)
	Local $dest_item = GetItemBySlot($bag, $slot)
	Local $dest_qty = DllStructGetData($dest_item, 'Quantity')
	If $dest_qty == 250 Then Return False
	MoveItem($item, $bag, $slot)
	Do
		RndSleep(50)
		$dest_item = GetItemBySlot($bag, $slot)
	Until DllStructGetData($dest_item, 'Quantity') > $dest_qty
	Return True
EndFunc	;==> MoveItemAndWait

Func CanSalvage($item)
	If DllStructGetData($item, 'Value') == 0 Then Return False
	If GetRarity($item) == $RARITY_GREEN Then Return False
	If GetRarity($item) <> $RARITY_WHITE And Not GetIsIDed($item) Then Return False
	; almost all bows salvage to wood, so just exclude the lot
	If DllStructGetData($item, 'Type') == $TYPE_BOW Then Return False
	If ItemIsSpecialType($item) Then Return False
	If GetValuableRuneIndex($item) > -1 Then Return False
	Local $model_ID = DllStructGetData($item, "ModelID")
	If _ArraySearch($DONT_SALVAGE_ARR, $model_ID) > -1 Then Return False
	Return True
EndFunc	;==> CanSalvage

Func CanSell($item)
	If DllStructGetData($item, 'Value') == 0 Then Return False
	If GetRarity($item) == $RARITY_GREEN Then Return False
	If GetRarity($item) <> $RARITY_WHITE And Not GetIsIDed($item) Then Return False
	Switch DllStructGetData($item, "ModelID")
		; specific modelID blacklist
		Case -1
			Return False
		; specific modelID whitelist
		Case $MODEL_ID_BONES, $MODEL_ID_CLOTH, $MODEL_ID_SILK, $MODEL_ID_WOOD, _
				$MODEL_ID_TANNED_HIDES, $MODEL_ID_CHITIN, $MODEL_ID_GRANITE
			Return True
	EndSwitch
	If GetValuableRuneIndex($item) > -1 Then Return False
	If ItemIsSpecialType($item) Then Return False
	Return True
EndFunc	;==> CanSell

Func ItemIsSpecialType($item)
	Switch DllStructGetData($item, 'Type')
		Case $TYPE_TROPHY, $TYPE_TROPHY_2
			Return Not $SALVAGE_TROPHY
		Case $TYPE_BAG, $TYPE_BUNDLE , $TYPE_RUNE_AND_MOD, $TYPE_USABLE, _
				$TYPE_DYE, $TYPE_CELESTIAL_SIGIL, $TYPE_MATERIAL_AND_ZCOINS, _
				$TYPE_KEY, $TYPE_QUEST_ITEM, $TYPE_KIT, $TYPE_SCROLL, _
				$TYPE_PRESENT, $TYPE_MINIPET, $TYPE_BOOKS
			Return True
	EndSwitch
	Return False
EndFunc	;==> ItemIsSpecialType

;~ Searches _Runes_and_Insignias.au3 for runes + insignias that should be kept
Func GetValuableRuneIndex($item)
	If DllStructGetData($item, 'Type') <> $TYPE_SALVAGE Then Return -1
	Local $modstruct = GetModStruct($item)
	For $i = (UBound($ARRAY_RUNES) - 1) To 0 Step -1
		If $ARRAY_RUNES[$i][4] Then	; this rune 'Salvage indicator' == 1
			If StringInStr($modstruct, $ARRAY_RUNES[$i][3]) Then ; modstruct contains rune
				Return $ARRAY_RUNES[$i][2] ; index of either rune or insignia
			EndIf
		EndIf
	Next
	Return -1
EndFunc	;==> GetValuableRuneIndex

;~ Same as in GWA2 except allows kit_type $KIT_BASIC_SALV / $KIT_EXPERT_SALV
Func CustomStartSalvage($item, $kit_type = $KIT_EXPERT_SALV)
	Local $lOffset[4] = [0, 0x18, 0x2C, 0x690]
	Local $lSalvageSessionID = MemoryReadPtr($mBasePointer, $lOffset)
	Local $lItemID = IsDllStruct($item) == 0 ? $item : DllStructGetData($item, 'ID')
	Local $lSalvageKit = CustomFindKit($kit_type)
	If $lSalvageKit == 0 Then Return
	DllStructSetData($mSalvage, 2, $lItemID)
	DllStructSetData($mSalvage, 3, $lSalvageKit)
	DllStructSetData($mSalvage, 4, $lSalvageSessionID[1])
	Enqueue($mSalvagePtr, 16)
EndFunc	;==> CustomStartSalvage

;~ Searches for $KIT_ID, $KIT_BASIC_SALV, $KIT_EXPERT_SALV
;~ Searches chest only if current location is outpost
Func CustomFindKit($kit_type)
	Local $item
	For $i = 1 To GetMapLoading() == 0 ? 16 : 4
		For $j = 1 To DllStructGetData(GetBag($i), 'Slots')
			$item = GetItemBySlot($i, $j)
			Switch DllStructGetData($item, 'ModelID')
				Case 2989, 5899
					If $kit_type == $KIT_ID Then Return DllStructGetData($item, 'ID')
				Case 2993, 2992
					If $kit_type == $KIT_BASIC_SALV Then Return DllStructGetData($item, 'ID')
				Case 2991, 5900
					If $kit_type == $KIT_EXPERT_SALV Then Return DllStructGetData($item, 'ID')
			EndSwitch
		Next
	Next
	Return 0
EndFunc	;==> CustomFindKit
 
;~ Identifies all items in a bag.
Func CustomIdentifyBag($bag, $id_whites = False, $id_golds = True)
	Local $item, $item_id
	For $slot = 1 To DllStructGetData(GetBag($bag), 'Slots')
		$item = GetItemBySlot($bag, $slot)
		$item_id = DllStructGetData($item, 'ID')
		If $item_id == 0 Or GetIsIDed($item_id) Then ContinueLoop
		Switch GetRarity($item)
			Case $RARITY_WHITE
				If Not $id_whites Then ContinueLoop
			Case $RARITY_GOLD
				; gold armor should always be identified for possible runes
				If DllStructGetData($item, 'Type') <> $TYPE_SALVAGE Then
					If Not $id_golds Then ContinueLoop
				EndIf
		EndSwitch
		If Not CustomIdentifyItem($item_id) Then Return False
	Next
	Return True
EndFunc	;==> CustomIdentifyBag

Func CustomIdentifyItem($item_id)
	Local $id_kit = CustomFindKit($KIT_ID)
	If Not $id_kit Then Return False
	SendPacket(0xC, $HEADER_ITEM_ID, $id_kit, $item_id)
	Local $timer = TimerInit()
	While Not GetIsIDed($item_id)
		Sleep(20)
		If TimerDiff($timer) > 5000 Then Return False
	Wend 
	Return True
EndFunc	;==> CustomIdentifyItem

;~ Searches bags for item with matching $item_ID
;~ Use the more efficient GetItemByItemID() if searching bags + storage
Func GetBagItemByItemID($item_ID)
	Local $item
	For $bag = 1 To 4
		For $slot = 1 To DllStructGetData(GetBag($bag), 'Slots')
			$item = GetItemBySlot($bag, $slot)
			If DllStructGetData($item, 'ID') == $item_ID Then Return $item
		Next
	Next
	Return 0
EndFunc	;==> GetBagItemByItemID

Func CountFreeSlots($NumOfBags = 4)
	Local $Slots = 0
	For $Bag = 1 To $NumOfBags
		$Slots += DllStructGetData(GetBag($Bag), 'Slots')
		$Slots -= DllStructGetData(GetBag($Bag), 'ItemsCount')
	Next
	Return $Slots
EndFunc	;==> CountFreeSlots

Func QuitOnFullInventory()
	If CountFreeSlots($USE_BAGS) < 5 Then
		Out("Reach capacity, stop farm.")
		WinClose(GetWindowHandle())
		$BotRunning = False
	EndIf
EndFunc	;==> QuitOnFullInventory
