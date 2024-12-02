Global $theGH = 179
Func inGH()
   Local $array_GH[16] = [4, 5, 6, 52, 176, 177, 178, 179, 275, 276, 359, 360, 529, 530, 537, 538]
   Local $lInGH = False
   Local $lMapID = GetMapID()
   For $i = 0 To 15
	  If $lMapID = $array_GH[$i] Then
		 $lInGH = True
		 ExitLoop
	  EndIf
   Next
   Return $lInGH
EndFunc

Func SellIfNeeded()
;~ Local $aSlotsNeeded = 5
;~ 	If CountEmptySlots() <= $aSlotsNeeded Then
	Out("Managing inventory")
		Sleep(500)
		If Not inGH() Then
		TravelGH()
		EndIf
		WaitMapLoading($theGH)
		If HaveDyes() Then
			Out("Selling Dyes")
			GoToMerchant("Dye Trader")
			DoForEachItem("SellDye")
		EndIf
		If HaveUnidentifiedItems() Then
			Out("Identifying")
			DoForEachItem("Identify")
		EndIf
		If HaveMods() Then
			Out("Processing Mods")
			DoForEachItem("SalvageAndProcessMod")
		EndIf
		If HaveItemsToSalvage() Then
			Out("Salvaging")
			DoForEachItem("Salvage")
		EndIf
		If HaveItemsToStore() Then
			Out("Storing")
			DoForEachItem("Store")
		EndIf
		If HaveRareMaterials() Then
			Out("Selling Rare Materials")
			GoToMerchant("Rare Material Trader")
			DoForEachItem("SellRareMaterial")
		EndIf
		If HaveMaterials() Then
			Out("Selling Materials")
			GoToMerchant("Material Trader")
			DoForEachItem("SellMaterial")
		EndIf
		If HaveItemsToSell() Then
			Out("Selling Items")
			GoToMerchant()
			DoForEachItem("SellItemWithChecks")
		EndIf
		BuyKits(3, 1)

		Update_Plat_Counter()
		DepositGold(GetGoldCharacter())

		Setup()

		;$PREPARED = False
		Return True
	Return False
EndFunc

Func CountEmptySlots()
	Local $emptySlots = 0
	For $bagNumber = 1 To 4
		Local $bag = GetBag($bagNumber)
		$emptySlots += DllStructGetData($bag, "Slots") - DllStructGetData($bag, "ItemsCount")
	Next
	Return $emptySlots
EndFunc

Func GetItemsInInventory()
	Local $itemArray[0]
	For $BagNumber = 1 To 4
		For $SlotNumber = 1 To DllStructGetData(GetBag($BagNumber), "Slots")
			Local $item = GetItemBySlot($BagNumber, $SlotNumber)
			;out(DllStructGetData($item)
			If DllStructGetData($item, "Id") == 0 Then ContinueLoop
			Redim $itemArray[UBound($itemArray) + 1]
			$itemArray[UBound($itemArray) - 1] = $item
		Next
	Next
	Return $itemArray
EndFunc

Func DoForEachItem($aFunction)
	For $item In GetItemsInInventory()
		Call($aFunction, $item)
	Next
EndFunc

Func HaveDyes()
	For $item In GetItemsInInventory()
		If DllStructGetData($item, "Type") == $TYPE_DYE And KeepItem($item) == False Then Return True
	Next
	Return False
EndFunc

Func SellDye($aItem)
	If DllStructGetData($aItem, "Type") <> $TYPE_DYE Then Return
	If KeepItem($aItem) Then Return
	Local $Quantity = DllStructGetData($aItem, "Quantity")
	For $i = 1 To $Quantity
		SellToVendor($aItem)
	Next
EndFunc

Func HaveUnidentifiedItems()
	For $item In GetItemsInInventory()
		If GetRarity($item) <> $RARITY_WHITE And GetIsIDed($item) == False Then Return True
		If GetRarity($item) <> $RARITY_BLUE And GetIsIDed($item) == False Then Return True
	    If GetRarity($item) <> $RARITY_PURPLE And GetIsIDed($item) == False Then Return True
        If GetRarity($item) <> $RARITY_GOLD And GetIsIDed($item) == False Then Return True
	Next
	Return False
EndFunc

Func Identify($aItem)
	If CanIdentify($aItem) == False Then Return False
	If GetRarity($aItem) == $RARITY_WHITE Then Return True
	If GetIsIDed($aItem) Then Return True
	If Not FindIDKit() Then
		If GetMapId() <> $theGH Then Return False
		If WithdrawGoldIfNeeded(100) == False Then Return False
		GoToMerchant()
		Do
			BuyIDKit()
			Sleep(500)
		Until FindIDKit()
	EndIf
	IdentifyItem($aItem)
	Return True
EndFunc

Func CanIdentify($aItem)
	Local $type = DllStructGetData($aItem, "Type")
	If $type == $TYPE_BAG Or _
		$type == $TYPE_BOOTS Or _
		$type == $TYPE_CHESTPIECE Or _
		$type == $TYPE_RUNE_AND_MOD Or _
		$type == $TYPE_USABLE Or _
		$type == $TYPE_DYE Or _
		$type == $TYPE_MATERIAL_AND_ZCOINS Or _
		$type == $TYPE_GLOVES Or _
		$type == $TYPE_HEADPIECE Or _
		$type == $TYPE_KEY Or _
		$type == $TYPE_LEGGINGS Or _
		$type == $TYPE_GOLD_COINS Or _
		$type == $TYPE_QUEST_ITEM Or _
		$type == $TYPE_KIT Or _
		$type == $TYPE_TROPHY Or _
		$type == $TYPE_SCROLL Or _
		$type == $TYPE_MINIPET Or _
		$type == $TYPE_COSTUME_BODY Or _
		$type == $TYPE_COSTUME_HEADPIECE Then
		Return False
	EndIf
	Return True
EndFunc

Func HaveMods()
	For $item In GetItemsInInventory()
		If ProcessUpgrade($item)[0] Then Return True
	Next
	Return False
EndFunc

Func SalvageAndProcessMod($aItem)
	Local $processUpgrade = ProcessUpgrade($aItem)
	Local $modToSalvage = @extended
	If $processUpgrade[0] == False Then Return
	While $processUpgrade[0]
		If Not FindExpertSalvageKit() Then
			If GetMapId() <> $theGH Then Return False
			If WithdrawGoldIfNeeded(400) == False Then Return False
			GoToMerchant()
			Do
				BuyExpertSalvageKit()
				Sleep(500)
			Until FindExpertSalvageKit()
		EndIf

		StartSalvage($aItem, True)
		Sleep(1000)
		SalvageMod($processUpgrade[1])
		Sleep(1000)

		If DllStructGetData($aItem, "Type") == $TYPE_SALVAGE Then
			GoToMerchant("Rune Trader")
			DoForEachItem("SellRune")
		EndIf
		DoForEachItem("StoreUpgrade")
		$aItem = GetItemByItemID(DllStructGetData($aItem, "Id"))
		$processUpgrade = ProcessUpgrade($aItem)
		$modToSalvage = @extended
	WEnd
EndFunc

Func ProcessUpgrade($aItem)
   Local $result[2] = [False, -1]
    Local $itemType = DllStructGetData($aItem, "Type")
    If KeepItem($aItem) Then Return $result
    If DllStructGetData($aItem, "Bag") == "0x00000000" Then Return $result
    local $modStruct = getModStruct($aItem)
	If (StringInStr($modStruct, $insignia_sentinels) Or _
		StringInStr($modStruct, $insignia_prodigys) Or _
		StringInStr($modStruct, $insignia_nightstalkers) Or _
		StringInStr($modStruct, $insignia_shamans) Or _
		StringInStr($modStruct, $insignia_windwalker) Or _
		StringInStr($modStruct, $insignia_centurions) Or _
		StringInStr($modStruct, $insignia_survivor) Or _
		StringInStr($modStruct, $insignia_radiant) Or _
		StringInStr($modStruct, $insignia_blessed)) And ($itemType == $TYPE_SALVAGE or $itemType == $TYPE_RUNE_AND_MOD) Then
		$result[0] = True
		$result[1] = 0
	EndIf
	If (StringInStr($modStruct, $rune_minor_strength) Or _
	    StringInStr($modStruct, $rune_minor_swordmanship) Or _
		StringInStr($modStruct, $rune_minor_expertise) Or _
		StringInStr($modStruct, $rune_minor_marksmanship) Or _
		StringInStr($modStruct, $rune_minor_divineFavor) Or _
		StringInStr($modStruct, $rune_minor_healingPrayers) Or _
		StringInStr($modStruct, $rune_minor_deathMagic) Or _
		StringInStr($modStruct, $rune_minor_soulReaping) Or _
		StringInStr($modStruct, $rune_superior_deathMagic) Or _
		StringInStr($modStruct, $rune_minor_fastCasting) Or _
		StringInStr($modStruct, $rune_minor_dominationMagic) Or _
		StringInStr($modStruct, $rune_minor_illusionMagic) Or _
		StringInStr($modStruct, $rune_superior_dominationMagic) Or _
		StringInStr($modStruct, $rune_minor_energyStorage) Or _
		StringInStr($modStruct, $rune_minor_Spawning) Or _
		StringInStr($modStruct, $rune_minor_mysticism) Or _
		StringInStr($modStruct, $rune_minor_scytheMastery) Or _
		StringInStr($modStruct, $rune_superior_earthPrayers) Or _
		StringInStr($modStruct, $rune_minor_leadership) Or _
		StringInStr($modStruct, $rune_minor_vigor) Or _
		StringInStr($modStruct, $rune_vitae) Or _
		StringInStr($modStruct, $rune_attunement) Or _
		StringInStr($modStruct, $rune_major_vigor) Or _
		StringInStr($modStruct, $rune_superior_vigor)) And ($itemType == $TYPE_SALVAGE or $itemType == $TYPE_RUNE_AND_MOD) Then
		$result[0] = True
		$result[1] = 1
	EndIf
	If StringInStr($modStruct, "00142828") <> 0 And $itemType == $itemType_offHand Then ;Forget Me Not
		$result[0] = True
		$result[1] = 2
	EndIf
	Return $result
EndFunc

Func SellRune($aItem)
	If DllStructGetData($aItem, "Type") <> $TYPE_RUNE_AND_MOD Then Return
	If KeepItem($aItem) Then Return
	GoToMerchant("Rune Trader")
	Local $Quantity = DllStructGetData($aItem, "Quantity")
	For $i = 1 To $Quantity
		SellToVendor($aItem)
	Next
EndFunc

Func StoreUpgrade($aItem)
	Local $storageNumber
	Local $slotNumber
	If DllStructGetData($aItem, "Type") == $TYPE_RUNE_AND_MOD And FindEmptyStorageSlot($storageNumber, $slotNumber) Then
		MoveItem($aItem, $storageNumber, $slotNumber)
		Do
			Sleep(10)
		Until DllStructGetData(GetItemBySlot($storageNumber, $slotNumber), "Id") <> 0
	EndIf
EndFunc

Func HaveItemsToSalvage()
	Out("Have items to salvage")
	For $item In GetItemsInInventory()
		Out("Ingetitems")
		If CanSalvage($item) Then Return True
	Next
	Return False
EndFunc

Func Salvage($aItem)
	If CanSalvage($aItem) == False Then Return False
	For $i = 1 To DllStructGetData($aItem, "Quantity")
		If Not FindSalvageKit() Then
			If GetMapId() <> $theGH Then Return False
			If WithdrawGoldIfNeeded(100) == False Then Return False
			GoToMerchant()
			Do
				BuySalvageKit()
				Sleep(500)
			Until FindSalvageKit()
		EndIf
		Local $kit = GetItemByItemId(FindSalvageKit())
		If GetRarity($aItem) == $RARITY_WHITE Then
			StartSalvage($aItem)
		Else
			Identify($aItem)
			If GetIsIDed($aItem) == False Then Return FALSE
			StartSalvage($aItem)
			Sleep(1000)
			SalvageMaterials()
		EndIf
		Local $kitAfter = GetItemByItemId(FindSalvageKit())
		Do
			Sleep(10)
			$kitAfter = GetItemByItemId(FindSalvageKit())
		Until DllStructGetData($kit, "Value") <> DllStructGetData($kitAfter, "Value") Or DllStructGetData($kit, "Id") <> DllStructGetData($kitAfter, "Id")
	Next
	Return True
EndFunc

Func CanSalvage($aItem)
;	Out(DllStructGetData($aItem))
	Local $modelId = DllStructGetData($aItem, "ModelId")
	If $modelId == 928 Then Return True
    If $modelId == 21833 Then Return False
	If DllStructGetData($aItem, "type") == $TYPE_RUNE_AND_MOD Then Return
    If KeepItem($aItem) Then Return False
    If ProcessUpgrade($aItem)[0] Then Return False
    Local $type = DllStructGetData($aItem, "Type")
    If $type == $TYPE_BAG Or _
        $type == $TYPE_CHESTPIECE Or _
        $type == $TYPE_UPGRADE Or _
        $type == $TYPE_USABLE Or _
        $type == $TYPE_DYE Or _
        $type == $TYPE_MATERIAL_AND_ZCOINS Or _
        $type == $TYPE_GLOVES Or _
        $type == $TYPE_HEADPIECE Or _
        $type == $TYPE_CANDYCANESHARD Or _
        $type == $TYPE_KEY Or _
        $type == $TYPE_LEGGINGS Or _
        $type == $TYPE_QUEST_ITEM Or _
        $type == $TYPE_KIT Or _
        $type == $TYPE_SCROLL Or _
        $type == $TYPE_MINIPET Or _
        $type == $TYPE_COSTUME Or _
        $type == $TYPE_COSTUME_HEADPIECE Then
        Return False
    EndIf
    Return True
EndFunc
Func HaveItemsToStore()
	For $item In GetItemsInInventory()
		If KeepItem($item) Then Return True
	Next
	Return False
EndFunc

Func Store($aItem)
	Local $storageNumber
	Local $slotNumber
	If KeepItem($aItem, True) And FindEmptyStorageSlot($storageNumber, $slotNumber) Then
		MoveItem($aItem, $storageNumber, $slotNumber)
		Do
			Sleep(10)
		Until DllStructGetData(GetItemBySlot($storageNumber, $slotNumber), "Id") <> 0
	EndIf
EndFunc

Func HaveRareMaterials()
	For $item In GetItemsInInventory()
		If DllStructGetData($item, "Type") == $TYPE_MATERIAL_AND_ZCOINS And GetIsRareMaterial($item) And KeepItem($item) == False Then Return True
	Next
	Return False
EndFunc

Func SellRareMaterial($aItem)
	If DllStructGetData($aItem, "Type") <> $TYPE_MATERIAL_AND_ZCOINS Or GetIsRareMaterial($aItem) == False Then Return
	If KeepItem($aItem) Then Return
	Local $Quantity = DllStructGetData($aItem, "Quantity")
	For $i = 1 To $Quantity
		SellToVendor($aItem)
	Next
EndFunc

Func HaveMaterials()
	For $item In GetItemsInInventory()
		If DllStructGetData($item, "Type") == $TYPE_MATERIAL_AND_ZCOINS And GetIsCommonMaterial($item) And KeepItem($item) == False Then Return True
	Next
	Return False
EndFunc

Func SellMaterial($aItem)
	If DllStructGetData($aItem, "Type") <> $TYPE_MATERIAL_AND_ZCOINS Or GetIsCommonMaterial($aItem) == False Then Return
	If KeepItem($aItem) Then Return
	Local $Quantity = DllStructGetData($aItem, "Quantity")
	For $i = 1 To Floor($Quantity / 10)
		SellToVendor($aItem)
	Next
EndFunc

Func HaveItemsToSell()
	For $item In GetItemsInInventory()
		If KeepItem($item) == False Then Return True
	Next
	Return False
EndFunc

Func SellItemWithChecks($aItem)
    If KeepItem($aItem) Then Return False
    If ProcessUpgrade($aItem)[0] Then Return False
    Local $SellPrice = DllStructGetData($aItem, "Value") * DllStructGetData($aItem, "Quantity")
    If $SellPrice > 100000 Or $Sellprice == 0 Then Return
    Local $gold = GetGoldCharacter()
	If $gold > 90000 Then
		DepositGold($Gold)
	EndIf
    If DepositGoldIfNeeded($SellPrice) == False Then Return
    SellItem($aItem)
    Local $deadLock = TimerInit()
    Do
        Sleep(10)
    Until GetGoldCharacter() <> $gold Or TimerDiff($deadLock) > 3000
EndFunc

Func SellToVendor($aItem)
	Local $gold = GetGoldCharacter()
	If $gold > 90000 Then
		DepositGold($Gold)
	EndIf
	If TraderRequestSell($aItem) == False Then Return
	If DepositGoldIfNeeded(GetTraderCostValue()) == False Then Return
	TraderSell()
	Do
		Sleep(10)
	Until GetGoldCharacter() <> $gold
	Sleep(100)
EndFunc

Func DepositGoldIfNeeded($aAmount)
	Local $amountOverLimit = $aAmount + GetGoldCharacter() - 100000
	If GetGoldStorage() + $amountOverLimit > 1000000 Then Return False
	If $amountOverLimit < 0 Then Return True
	DepositGold($amountOverLimit)
	Do
		Sleep(10)
	Until $aAmount + GetGoldCharacter() <= 100000
	Return True
EndFunc

Func WithdrawGoldIfNeeded($aAmount)
	Local $amountUnderLimit = $aAmount - GetGoldCharacter()
	If GetGoldStorage() < $amountUnderLimit Then Return False
	If $amountUnderLimit < 0 Then Return True
	WithdrawGold($amountUnderLimit)
	Do
		Sleep(10)
	Until GetGoldCharacter() >= $aAmount
	Return True
EndFunc

Func findEmptyStorageSlot(ByRef $aStorageNumber, byref $aSlotNumber)
	For $aStorageNumber = 8 To 16
		For $aSlotNumber = 1 To DllStructGetData(GetBag($aStorageNumber), "Slots")
			Local $item = GetItemBySlot($aStorageNumber, $aSlotNumber)
			If DllStructGetData($item, "Id") == 0 Then Return True
		Next
	Next
	Return False
EndFunc

Func KeepItem($aItem, $aStore = false)
;	If CustomKeepItem($aItem, $aStore) Then Return True
	Local $modelId = DllStructGetData($aItem, "ModelId")
	Local $type = DllStructGetData($aItem, "Type")
	Local $extraId = DllStructGetData($aItem, "ExtraId")
	Local $quantity = DllStructGetData($aItem, "Quantity")
	Local $rarity = GetRarity($aItem)
	Local $Requirement = GetItemReq($aItem)
	Local $modStruct = GetModStruct($aItem)
	Local $6to13DMG = StringInStr($ModStruct, "060DA8A7")
	Local $13to25DMG = StringInStr($ModStruct, "0D19A8A7")
	Local $14to25DMG = StringInStr($ModStruct, "0E18A8A7")
	Local $IsCaster = IsPerfectCaster($aItem)
	Local $IsStaff = IsPerfectStaff($aItem)
    Local $IsShield = IsPerfectShield($aItem)
    Local $IsReq8 = IsReq8Max($aItem)
	If $rarity = $Rarity_gold Then Return True

	Switch $IsShield
    Case True
	  Return True ; Is perfect shield
   EndSwitch

   Switch $IsReq8
   Case True
	  Return True ; Is req8 max
   EndSwitch

   Switch $type
   Case 12 ; Offhands
	  If $IsCaster = True Then
		 Return True ; Is perfect offhand
	  Else
		 Return False
	  EndIf
   Case 22 ; Wands
	  If $IsCaster = True Then
		 Return True ; Is perfect wand
	  Else
		 Return False
	  EndIf
   Case 26 ; staves
	  If $IsStaff = True Then
		 Return True ; Is perfect staff
	  Else
		 Return False
	  EndIf
   EndSwitch

    If $ModelID = 146 And ($ExtraID = 10 Or $ExtraID = 12) Then ; white/black dyes
	   Return True
	EndIf

	If $type == $TYPE_RUNE_AND_MOD and StringInStr($modStruct, $rune_superior_vigor) Then ; superior vigors
	   Return True
	EndIf

	If $type == $TYPE_DAGGERS and $6to13DMG and $requirement = 5 and $rarity <> $Rarity_white Then ; req 5 daggers
		Return True
	EndIf

	If $type == $TYPE_BOW and $13to25DMG and $requirement = 6 and $rarity <> $Rarity_white Then ; req 6 bows ether
		Return True
	EndIf

	If $type == $TYPE_BOW and $14to25DMG and $requirement = 6 and $rarity <> $Rarity_white Then ; req 6 bows ether
		Return True
	EndIf

	If $modelId == $MODEL_ID_UWSCROLL Or $modelId == $MODEL_ID_FOWSCROLL Or $modelId == $MODEL_ID_LOCKPICK Or $type == $TYPE_USABLE Then
		If $aStore Then Return $quantity == 250
		Return True
    EndIf

    If $type == $TYPE_MATERIAL_AND_ZCOINS And ($modelId == $MODEL_ID_IRON ) Then
        If $aStore Then Return $quantity == 250
        Return True
    EndIf

    If $type == $TYPE_MATERIAL_AND_ZCOINS And ($modelId == $MODEL_ID_DUST ) Then
        If $aStore Then Return $quantity == 250
        Return True
    EndIf

    If $modelId == 809 Then
	   If $aStore Then Return $quantity == 250
		  Return True ;keeps jade bracelets
    EndIf

    If $type == $TYPE_MATERIAL_AND_ZCOINS And ($modelId == $MODEL_ID_JADEITE_SHARD ) Then
	   If $aStore Then Return $quantity == 250
		  Return True ; keeps jadeite shards
    EndIf

	If $type == $TYPE_KIT Then
		If $aStore Then Return False
		Return True
	EndIf
	If $type == $TYPE_MINIPET Then Return True
	Return False
EndFunc

Func BuyKits($aIdentificationKitsToBuy, $aSalvageKitsToBuy)
	Local $identificationKits = 0
	Local $salvageKits = 0
	For $item In GetItemsInInventory()
		If DllStructGetData($item, "Id") == 0 Or DllStructGetData($item, "Type") <> $ITEMTYPE_KIT Then ContinueLoop
		Switch DllStructGetData($item, "ModelId")
			Case $KIT_IDENTIFICATION
				$identificationKits += 1
			Case $KIT_SALVAGE
				$salvageKits += 1
		EndSwitch
	Next
	WithdrawGoldIfNeeded(($aIdentificationKitsToBuy - $identificationKits + $aSalvageKitsToBuy - $salvageKits) * 100)
	If $aIdentificationKitsToBuy - $identificationKits > 0 Then
		BuyIDKit($aIdentificationKitsToBuy - $identificationKits)
		sleep(250)
	EndIf
	If $aSalvageKitsToBuy - $salvageKits > 0 Then
		BuySalvageKit($aSalvageKitsToBuy - $salvageKits)
		sleep(250)
	EndIf
EndFunc

Func GoToMerchant($aMerchant = "Merchant")
	Switch $aMerchant
		Case "Merchant"
			GoToNpcAtCoordinates(-4071, -1134)
		Case "Dye Trader"
			GoToNpcAtCoordinates(-4434, -3760)
		Case "Rune Trader"
			GoToNpcAtCoordinates(-3729, -2403)
		Case "Material Trader"
			GoToNpcAtCoordinates(-3597, -2352)
		Case "Rare Material Trader"
			GoToNpcAtCoordinates(-3428, -1590)
	EndSwitch
EndFunc

Func GoToNpcAtCoordinates($aX, $aY)
	Local $npc = GetNearestNPCToCoords($aX, $aY)
	GoToNPC($npc)
EndFunc


Func GetItemMaxDmg($aItem)
	If Not IsDllStruct($aItem) Then $aItem = GetItemByItemID($aItem)
	Local $lModString = GetModStruct($aItem)
	Local $lPos = StringInStr($lModString, "A8A7") ; Weapon Damage
	If $lPos = 0 Then $lPos = StringInStr($lModString, "C867") ; Energy (focus)
	If $lPos = 0 Then $lPos = StringInStr($lModString, "B8A7") ; Armor (shield)
	If $lPos = 0 Then Return 0
	Return Int("0x" & StringMid($lModString, $lPos - 2, 2))
EndFunc

Func IsReq8Max($aItem)
	Local $Req = GetItemReq($aItem)
	Local $Attribute = GetItemAttribute($aItem)
	Local $Rarity = GetRarity($aItem)
	Local $Dmg = GetItemMaxDmg($aItem)

    Switch $Rarity
    Case 2624
	   If $Req = 8 Then
		  If $Attribute = 20 Or $Attribute = 21 Or $Attribute = 17 Then
			 If $Dmg = 22 Or $Dmg = 16 Then
				Return True
			 EndIf
		  EndIf
	   EndIf
    Case 2623
	   If $Req = 8 Then
		  If $Attribute = 20 Or $Attribute = 21 Or $Attribute = 17 Then
			 If $Dmg = 22 Or $Dmg = 16 Then
				Return True
			 EndIf
		  EndIf
	   EndIf
    Case 2626
	   If $Req = 8 Then
		  If $Attribute = 20 Or $Attribute = 21 Or $Attribute = 17 Then
			 If $Dmg = 22 Or $Dmg = 16 Then
				Return True
			 EndIf
		  EndIf
	   EndIf
	EndSwitch
	Return False
EndFunc

Func IsPerfectCaster($aItem)
	Local $ModStruct = GetModStruct($aItem)
	Local $A = GetItemAttribute($aItem)
    ; Universal mods
    Local $PlusFive = StringInStr($ModStruct, "5320823", 0, 1) ; Mod struct for +5^50
	Local $PlusFiveEnch = StringInStr($ModStruct, "500F822", 0, 1) ; Mod struct for +5wE
	Local $10Cast = StringInStr($ModStruct, "A0822", 0, 1) ; Mod struct for 10% cast
	Local $10Recharge = StringInStr($ModStruct, "AA823", 0, 1) ; Mod struct for 10% recharge
	; Ele mods
	Local $Fire20Casting = StringInStr($ModStruct, "0A141822", 0, 1) ; Mod struct for 20% fire
	Local $Fire20Recharge = StringInStr($ModStruct, "0A149823", 0, 1)
	Local $Water20Casting = StringInStr($ModStruct, "0B141822", 0, 1) ; Mod struct for 20% water
	Local $Water20Recharge = StringInStr($ModStruct, "0B149823", 0, 1)
	Local $Air20Casting = StringInStr($ModStruct, "08141822", 0, 1) ; Mod struct for 20% air
	Local $Air20Recharge = StringInStr($ModStruct, "08149823", 0, 1)
	Local $Earth20Casting = StringInStr($ModStruct, "09141822", 0, 1)
	Local $Earth20Recharge = StringInStr($ModStruct, "09149823", 0, 1)
	Local $Energy20Casting = StringInStr($ModStruct, "0C141822", 0, 1)
	Local $Energy20Recharge = StringInStr($ModStruct, "0C149823", 0, 1)
	; Monk mods
	Local $Smiting20Casting = StringInStr($ModStruct, "0E141822", 0, 1) ; Mod struct for 20% smite
	Local $Smiting20Recharge = StringInStr($ModStruct, "0E149823", 0, 1)
	Local $Divine20Casting = StringInStr($ModStruct, "10141822", 0, 1) ; Mod struct for 20% divine
	Local $Divine20Recharge = StringInStr($ModStruct, "10149823", 0, 1)
	Local $Healing20Casting = StringInStr($ModStruct, "0D141822", 0, 1) ; Mod struct for 20% healing
	Local $Healing20Recharge = StringInStr($ModStruct, "0D149823", 0, 1)
	Local $Protection20Casting = StringInStr($ModStruct, "0F141822", 0, 1) ; Mod struct for 20% protection
	Local $Protection20Recharge = StringInStr($ModStruct, "0F149823", 0, 1)
	; Rit mods
	Local $Channeling20Casting = StringInStr($ModStruct, "22141822", 0, 1) ; Mod struct for 20% channeling
	Local $Channeling20Recharge = StringInStr($ModStruct, "22149823", 0, 1)
	Local $Restoration20Casting = StringInStr($ModStruct, "21141822", 0, 1)
	Local $Restoration20Recharge = StringInStr($ModStruct, "21149823", 0, 1)
	; Mes mods
	Local $Domination20Casting = StringInStr($ModStruct, "02141822", 0, 1) ; Mod struct for 20% domination
    Local $Domination20Recharge = StringInStr($ModStruct, "02149823", 0, 1) ; Mod struct for 20% domination recharge
	; Necro mods
    Local $Death20Casting = StringInStr($ModStruct, "05141822", 0, 1) ; Mod struct for 20% death
	Local $Death20Recharge = StringInStr($ModStruct, "05149823", 0, 1)
    Local $Blood20Recharge = StringInStr($ModStruct, "04149823", 0, 1)
	Local $Blood20Casting = StringInStr($ModStruct, "04141822", 0, 1)

	Switch $A
    Case 2 ; Domination
	   If $PlusFive > 0 Or $PlusFiveEnch > 0 Then
		  If $Domination20Casting > 0 Or $Domination20Recharge > 0 Then
		     Return True
		  EndIf
	   EndIf
	   If $Domination20Recharge > 0 Or $Domination20Casting > 0 Then
		  If $10Cast > 0 Or $10Recharge > 0 Then
		     Return True
		  EndIf
	   EndIf
	   If $Domination20Recharge > 0 Then
		  If $Domination20Casting > 0 Then
		     Return True
		  EndIf
	   EndIf
	   Return False
    Case 4 ; Blood
	   If $PlusFive > 0 Or $PlusFiveEnch > 0 Then
		  If $Blood20Casting > 0 Or $Blood20Recharge > 0 Then
		     Return True
		  EndIf
	   EndIf
	   If $Blood20Recharge > 0 Or $Blood20Casting > 0 Then
		  If $10Cast > 0 Or $10Recharge > 0 Then
		     Return True
		  EndIf
	   EndIf
	   If $Blood20Recharge > 0 Then
		  If $Blood20Casting > 0 Then
		     Return True
		  EndIf
	   EndIf
	   Return False
    Case 5 ; Death
	   If $PlusFive > 0 Or $PlusFiveEnch > 0 Then
		  If $Death20Casting > 0 Or $Death20Recharge > 0 Then
		     Return True
		  EndIf
	   EndIf
	   If $Death20Recharge > 0 Or $Death20Casting > 0 Then
		  If $10Cast > 0 Or $10Recharge > 0 Then
		     Return True
		  EndIf
	   EndIf
	   If $Death20Recharge > 0 Then
		  If $Death20Casting > 0 Then
		     Return True
		  EndIf
	   EndIf
	   Return False
    Case 8 ; Air
	   If $PlusFive > 0 Or $PlusFiveEnch > 0 Then
		  If $Air20Casting > 0 Or $Air20Recharge > 0 Then
		     Return True
		  EndIf
	   EndIf
	   If $Air20Recharge > 0 Or $Air20Casting > 0 Then
		  If $10Cast > 0 Or $10Recharge > 0 Then
		     Return True
		  EndIf
	   EndIf
	   If $Air20Recharge > 0 Then
		  If $Air20Casting > 0 Then
		     Return True
		  EndIf
	   EndIf
	   Return False
    Case 9 ; Earth
	   If $PlusFive > 0 Or $PlusFiveEnch > 0 Then
		  If $Earth20Casting > 0 Or $Earth20Recharge > 0 Then
		     Return True
		  EndIf
	   EndIf
	   If $Earth20Recharge > 0 Or $Earth20Casting > 0 Then
		  If $10Cast > 0 Or $10Recharge > 0 Then
		     Return True
		  EndIf
	   EndIf
	   If $Earth20Recharge > 0 Then
		  If $Earth20Casting > 0 Then
		     Return True
		  EndIf
	   EndIf
       Return False
    Case 10 ; Fire
	   If $PlusFive > 0 Or $PlusFiveEnch > 0 Then
		  If $Fire20Casting > 0 Or $Fire20Recharge > 0 Then
		     Return True
		  EndIf
	   EndIf
	   If $Fire20Recharge > 0 Or $Fire20Casting > 0 Then
		  If $10Cast > 0 Or $10Recharge > 0 Then
		     Return True
		  EndIf
	   EndIf
	   If $Fire20Recharge > 0 Then
		  If $Fire20Casting > 0 Then
		     Return True
		  EndIf
	   EndIf
       Return False
    Case 11 ; Water
	   If $PlusFive > 0 Or $PlusFiveEnch > 0 Then
		  If $Water20Casting > 0 Or $Water20Recharge > 0 Then
		     Return True
		  EndIf
	   EndIf
	   If $Water20Recharge > 0 Or $Water20Casting > 0 Then
		  If $10Cast > 0 Or $10Recharge > 0 Then
		     Return True
		  EndIf
	   EndIf
	   If $Water20Recharge > 0 Then
		  If $Water20Casting > 0 Then
		     Return True
		  EndIf
	   EndIf
	   Return False
    Case 12 ; Energy Storage
	   If $PlusFive > 0 Or $PlusFiveEnch > 0 Then
		  If $Energy20Casting > 0 Or $Energy20Recharge > 0 Or $Water20Casting > 0 Or $Water20Recharge > 0 Or $Fire20Casting > 0 Or $Fire20Recharge > 0 Or $Earth20Casting > 0 Or $Earth20Recharge > 0 Or $Air20Casting > 0 Or $Air20Recharge > 0 Then
		     Return True
		  EndIf
	   EndIf
	   If $Energy20Recharge > 0 Or $Energy20Casting > 0 Then
		  If $10Cast > 0 Or $10Recharge > 0 Or $Water20Casting > 0 Or $Water20Recharge > 0 Or $Fire20Casting > 0 Or $Fire20Recharge > 0 Or $Earth20Casting > 0 Or $Earth20Recharge > 0 Or $Air20Casting > 0 Or $Air20Recharge > 0 Then
		     Return True
		  EndIf
       EndIf
	   If $Energy20Recharge > 0 Then
		  If $Energy20Casting > 0 Then
		     Return True
		  EndIf
	   EndIf
	   If $10Cast > 0 Or $10Recharge > 0 Then
		  If $Water20Casting > 0 Or $Water20Recharge > 0 Or $Fire20Casting > 0 Or $Fire20Recharge > 0 Or $Earth20Casting > 0 Or $Earth20Recharge > 0 Or $Air20Casting > 0 Or $Air20Recharge > 0 Then
		     Return True
		  EndIf
	   EndIf
	   Return False
    Case 13 ; Healing
	   If $PlusFive > 0 Or $PlusFiveEnch > 0 Then
		  If $Healing20Casting > 0 Or $Healing20Recharge > 0 Then
		     Return True
		  EndIf
	   EndIf
	   If $Healing20Recharge > 0 Or $Healing20Casting > 0 Then
		  If $10Cast > 0 Or $10Recharge > 0 Then
		     Return True
		  EndIf
	   EndIf
	   If $Healing20Recharge > 0 Then
		  If $Healing20Casting > 0 Then
		     Return True
		  EndIf
	   EndIf
	   Return False
    Case 14 ; Smiting
	   If $PlusFive > 0 Or $PlusFiveEnch > 0 Then
		  If $Smiting20Casting > 0 Or $Smiting20Recharge > 0 Then
		     Return True
		  EndIf
	   EndIf
	   If $Smiting20Recharge > 0 Or $Smiting20Casting > 0 Then
		  If $10Cast > 0 Or $10Recharge > 0 Then
		     Return True
		  EndIf
	   EndIf
	   If $Smiting20Recharge > 0 Then
		  If $Smiting20Casting > 0 Then
		     Return True
		  EndIf
	   EndIf
	   Return False
    Case 15 ; Protection
	   If $PlusFive > 0 Or $PlusFiveEnch > 0 Then
		  If $Protection20Casting > 0 Or $Protection20Recharge > 0 Then
		     Return True
		  EndIf
	   EndIf
	   If $Protection20Recharge > 0 Or $Protection20Casting > 0 Then
		  If $10Cast > 0 Or $10Recharge > 0 Then
		     Return True
		  EndIf
	   EndIf
	   If $Protection20Recharge > 0 Then
		  If $Protection20Casting > 0 Then
		     Return True
		  EndIf
	   EndIf
	   Return False
    Case 16 ; Divine
	   If $PlusFive > 0 Or $PlusFiveEnch > 0 Then
		  If $Divine20Casting > 0 Or $Divine20Recharge > 0 Or $Healing20Casting > 0 Or $Healing20Recharge > 0 Or $Smiting20Casting > 0 Or $Smiting20Recharge > 0 Or $Protection20Casting > 0 Or $Protection20Recharge > 0 Then
		     Return True
		  EndIf
	   EndIf
	   If $Divine20Recharge > 0 Or $Divine20Casting > 0 Then
		  If $10Cast > 0 Or $10Recharge > 0 Or $Healing20Casting > 0 Or $Healing20Recharge > 0 Or $Smiting20Casting > 0 Or $Smiting20Recharge > 0 Or $Protection20Casting > 0 Or $Protection20Recharge > 0 Then
		     Return True
		  EndIf
	   EndIf
	   If $Divine20Recharge > 0 Then
		  If $Divine20Casting > 0 Then
		     Return True
		  EndIf
	   EndIf
	   If $10Cast > 0 Or $10Recharge > 0 Then
		  If $Healing20Casting > 0 Or $Healing20Recharge > 0 Or $Smiting20Casting > 0 Or $Smiting20Recharge > 0 Or $Protection20Casting > 0 Or $Protection20Recharge > 0 Then
		     Return True
		  EndIf
	   EndIf
	   Return False
	Case 33 ; Restoration
	   If $PlusFive > 0 Or $PlusFiveEnch > 0 Then
		  If $Restoration20Casting > 0 Or $Restoration20Recharge > 0 Then
		     Return True
		  EndIf
	   EndIf
	   If $Restoration20Recharge > 0 Or $Restoration20Casting > 0 Then
		  If $10Cast > 0 Or $10Recharge > 0 Then
		     Return True
		  EndIf
	   EndIf
	   If $Restoration20Recharge > 0 Then
		  If $Restoration20Casting > 0 Then
		     Return True
		  EndIf
	   EndIf
	   Return False
    Case 34 ; Channeling
	   If $PlusFive > 0 Or $PlusFiveEnch > 0 Then
		  If $Channeling20Casting > 0 Or $Channeling20Recharge > 0 Then
		     Return True
		  EndIf
	   EndIf
	   If $Channeling20Recharge > 0 Or $Channeling20Casting > 0 Then
		  If $10Cast > 0 Or $10Recharge > 0 Then
		     Return True
		  EndIf
	   EndIf
	   If $Channeling20Recharge > 0 Then
		  If $Channeling20Casting > 0 Then
		     Return True
		  EndIf
	   EndIf
	   Return False
    EndSwitch
    Return False
EndFunc

 Func IsPerfectShield($aItem) ;
    Local $ModStruct = GetModStruct($aItem)
	; Universal mods
    Local $Plus30 = StringInStr($ModStruct, "1E4823", 0, 1) ; Mod struct for +30 (shield only?)
	Local $Minus3Hex = StringInStr($ModStruct, "3009820", 0, 1) ; Mod struct for -3wHex (shield only?)
	Local $Minus2Stance = StringInStr($ModStruct, "200A820", 0, 1) ; Mod Struct for -2Stance
	Local $Minus2Ench = StringInStr($ModStruct, "2008820", 0, 1) ; Mod struct for -2Ench
	Local $Plus45Stance = StringInStr($ModStruct, "02D8823", 0, 1) ; For +45Stance
	Local $Plus45Ench = StringInStr($ModStruct, "02D6823", 0, 1) ; Mod struct for +40ench
	Local $Plus44Ench = StringInStr($ModStruct, "02C6823", 0, 1) ; For +44/+10Demons
	Local $Minus520 = StringInStr($ModStruct, "5147820", 0, 1) ; For -5(20%)
	Local $Plus60 = StringInStr($modStruct, "03C7823", 0, 1); +60wh
	; +1 20% Mods
	Local $PlusDomination = StringInStr($ModStruct, "0218240", 0, 1) ; +1 Dom 20%
	Local $PlusDivine = StringInStr($ModStruct, "1018240", 0, 1) ; +1 Divine 20%
	Local $PlusSmite = StringInStr($ModStruct, "0E18240", 0, 1) ; +1 Smite 20%
	Local $PlusHealing = StringInStr($ModStruct, "0D18240", 0, 1) ; +1 Heal 20%
	Local $PlusProt = StringInStr($ModStruct, "0F18240", 0, 1) ; +1 Prot 20%
	Local $PlusFire = StringInStr($ModStruct, "0A18240", 0, 1) ; +1 Fire 20%
	Local $PlusWater = StringInStr($ModStruct, "0B18240", 0, 1) ; +1 Water 20%
	Local $PlusAir = StringInStr($ModStruct, "0818240", 0, 1) ; +1 Air 20%
	Local $PlusEarth = StringInStr($ModStruct, "0918240", 0, 1) ; +1 Earth 20%
	Local $PlusDeath = StringInStr($ModStruct, "0518240", 0, 1) ; +1 Death 20%
	Local $PlusBlood = StringInStr($ModStruct, "0418240", 0, 1) ; +1 Blood 20%
	; +10vs Mods
	Local $PlusDemons = StringInStr($ModStruct, "A0848210", 0, 1) ; +10vs Demons
	Local $PlusPiercing = StringInStr($ModStruct, "A0118210", 0, 1) ; +10vs Piercing
    Local $PlusDragons = StringInStr($ModStruct, "A0948210", 0, 1) ; +10vs Dragons
	Local $PlusLightning = StringInStr($ModStruct, "A0418210", 0, 1) ; +10vs Lightning
	Local $PlusVsEarth = StringInStr($ModStruct, "A0B18210", 0, 1) ; +10vs Earth
	Local $PlusPlants = StringInStr($ModStruct, "A0348210", 0, 1) ; +10vs Plants
	Local $PlusCold = StringInStr($ModStruct, "A0318210", 0, 1) ; +10 vs Cold
	Local $PlusUndead = StringInStr($ModStruct, "A0048210", 0, 1) ; +10vs Undead
	Local $PlusSlashing = StringInStr($ModStruct, "A0218210", 0, 1) ; +10vs Slashing
    Local $PlusTengu = StringInStr($ModStruct, "A0748210", 0, 1) ; +10vs Tengu
	Local $PlusVsFire = StringInStr($ModStruct, "A0518210", 0, 1) ; +10vs Fire

    If $Plus30 > 0 Then
	   If $PlusDemons > 0 Or $PlusPiercing > 0 Or $PlusDragons > 0 Or $PlusLightning > 0 Or $PlusVsEarth > 0 Or $PlusPlants > 0 Or $PlusCold > 0 Or $PlusUndead > 0 Or $PlusSlashing > 0 Or $PlusTengu > 0 Or $PlusVsFire > 0 Then
	      Return True
	   ElseIf $PlusDomination > 0 Or $PlusDivine > 0 Or $PlusSmite > 0 Or $PlusHealing > 0 Or $PlusProt > 0 Or $PlusFire > 0 Or $PlusWater > 0 Or $PlusAir > 0 Or $PlusEarth > 0 Or $PlusDeath > 0 Or $PlusBlood > 0 Then
		  Return True
	   ElseIf $Minus2Stance > 0 Or $Minus2Ench > 0 Or $Minus520 > 0 Or $Minus3Hex > 0 Then
		  Return True
	   Else
		  Return False
	   EndIf
	EndIf
	If $Plus60 > 0 Then
       If $PlusDemons > 0 Or $PlusPiercing > 0 Or $PlusDragons > 0 Or $PlusLightning > 0 Or $PlusVsEarth > 0 Or $PlusPlants > 0 Or $PlusCold > 0 Or $PlusUndead > 0 Or $PlusSlashing > 0 Or $PlusTengu > 0 Or $PlusVsFire > 0 Then
          Return True
       ElseIf $PlusDomination > 0 Or $PlusDivine > 0 Or $PlusSmite > 0 Or $PlusHealing > 0 Or $PlusProt > 0 Or $PlusFire > 0 Or $PlusWater > 0 Or $PlusAir > 0 Or $PlusEarth > 0 Or $PlusDeath > 0 Or $PlusBlood > 0 Then
          Return True
       ElseIf $Minus2Stance > 0 Or $Minus2Ench > 0 Or $Minus520 > 0 Or $Minus3Hex > 0 Then
          Return True
       Else
          Return False
       EndIf
    EndIf
    If $Plus45Ench > 0 Then
	   If $PlusDemons > 0 Or $PlusPiercing > 0 Or $PlusDragons > 0 Or $PlusLightning > 0 Or $PlusVsEarth > 0 Or $PlusPlants > 0 Or $PlusCold > 0 Or $PlusUndead > 0 Or $PlusSlashing > 0 Or $PlusTengu > 0 Or $PlusVsFire > 0 Then
	      Return True
	   ElseIf $Minus2Ench > 0 Then
		  Return True
	   ElseIf $PlusDomination > 0 Or $PlusDivine > 0 Or $PlusSmite > 0 Or $PlusHealing > 0 Or $PlusProt > 0 Or $PlusFire > 0 Or $PlusWater > 0 Or $PlusAir > 0 Or $PlusEarth > 0 Or $PlusDeath > 0 Or $PlusBlood > 0 Then
		  Return True
	   Else
		  Return False
	   EndIf
	EndIf
	If $Minus2Ench > 0 Then
	   If $PlusDemons > 0 Or $PlusPiercing > 0 Or $PlusDragons > 0 Or $PlusLightning > 0 Or $PlusVsEarth > 0 Or $PlusPlants > 0 Or $PlusCold > 0 Or $PlusUndead > 0 Or $PlusSlashing > 0 Or $PlusTengu > 0 Or $PlusVsFire > 0 Then
		  Return True
	   EndIf
	EndIf
    If $Plus44Ench > 0 Then
	   If $PlusDemons > 0 Then
	      Return True
	   EndIf
	EndIf
    If $Plus45Stance > 0 Then
	   If $Minus2Stance > 0 Then
	      Return True
	   EndIf
	EndIf
	Return False
 EndFunc

  Func IsPerfectStaff($aItem)
    Local $ModStruct = GetModStruct($aItem)
    Local $A = GetItemAttribute($aItem)
    ; Ele mods
    Local $Fire20Casting = StringInStr($ModStruct, "0A141822", 0, 1) ; Mod struct for 20% fire
    Local $Water20Casting = StringInStr($ModStruct, "0B141822", 0, 1) ; Mod struct for 20% water
    Local $Air20Casting = StringInStr($ModStruct, "08141822", 0, 1) ; Mod struct for 20% air
    Local $Earth20Casting = StringInStr($ModStruct, "09141822", 0, 1)
    Local $Energy20Casting = StringInStr($ModStruct, "0C141822", 0, 1)
    ; Monk mods
    Local $Smite20Casting = StringInStr($ModStruct, "0E141822", 0, 1) ; Mod struct for 20% smite
    Local $Divine20Casting = StringInStr($ModStruct, "10141822", 0, 1) ; Mod struct for 20% divine
    Local $Healing20Casting = StringInStr($ModStruct, "0D141822", 0, 1) ; Mod struct for 20% healing
    Local $Protection20Casting = StringInStr($ModStruct, "0F141822", 0, 1) ; Mod struct for 20% protection
    ; Rit mods
    Local $Channeling20Casting = StringInStr($ModStruct, "22141822", 0, 1) ; Mod struct for 20% channeling
    Local $Restoration20Casting = StringInStr($ModStruct, "21141822", 0, 1)
    ; Mes mods
    Local $Domination20Casting = StringInStr($ModStruct, "02141822", 0, 1) ; Mod struct for 20% domination
    ; Necro mods
    Local $Death20Casting = StringInStr($ModStruct, "05141822", 0, 1) ; Mod struct for 20% death
    Local $Blood20Casting = StringInStr($ModStruct, "04141822", 0, 1)

    Switch $A
    Case 2 ; Domination
       If $Domination20Casting > 0 Then
          Return True
       Else
          Return False
       EndIf
    Case 4 ; Blood
       If $Blood20Casting > 0 Then
          Return True
       Else
          Return False
       EndIf
    Case 5 ; Death
       If $Death20Casting > 0 Then
          Return True
       Else
          Return False
       EndIf
    Case 8 ; Air
       If $Air20Casting > 0 Then
          Return True
       Else
          Return False
       EndIf
    Case 9 ; Earth
       If $Earth20Casting > 0 Then
          Return True
       Else
          Return False
       EndIf
    Case 10 ; Fire
       If $Fire20Casting > 0 Then
          Return True
       Else
          Return False
       EndIf
    Case 11 ; Water
       If $Water20Casting > 0 Then
          Return True
       Else
          Return False
       EndIf
    Case 12 ; Energy Storage
       If $Air20Casting > 0 Or $Earth20Casting > 0 Or $Fire20Casting > 0 Or $Water20Casting > 0 Then
          Return True
       Else
          Return False
       EndIf
    Case 13 ; Healing
       If $Healing20Casting > 0 Then
          Return True
       Else
          Return False
       EndIf
    Case 14 ; Smiting
       If $Smite20Casting > 0 Then
          Return True
       Else
          Return False
       EndIf
    Case 15 ; Protection
       If $Protection20Casting > 0 Then
          Return True
       Else
          Return False
       EndIf
    Case 16 ; Divine
       If $Healing20Casting > 0 Or $Protection20Casting > 0 Or $Divine20Casting > 0 Then
          Return True
       Else
          Return False
       EndIf
    Case 33 ; Restoration
       If $Restoration20Casting > 0 Then
          Return True
       Else
          Return False
       EndIf
    Case 34 ; Channeling
       If $Channeling20Casting > 0 Then
          Return True
       Else
          Return False
       EndIf
    EndSwitch
    Return False
 EndFunc