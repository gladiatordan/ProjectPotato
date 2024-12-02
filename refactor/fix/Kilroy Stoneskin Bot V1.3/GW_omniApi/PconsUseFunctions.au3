Func UsePcons($ModelID) ;Detects in bag and use Pcons by modelID, Returns True when used, and returns False if not found	
	For $bag = 1 To 4
		For $slot = 1 To DllStructGetData(GetBag($bag), 'Slots')
			Local $item = GetItemBySlot($bag, $slot)
			If DllStructGetData($item, 'ModelID') == $ModelID Then
				UseItem($item)
				RndSleep(500)
				Return True
			EndIf
		Next
	Next
	Return False
EndFunc

#Region CheckAndUse sub-functions
#cs 
	$intSilence = 0 to not silence, $intSilence = 3 to both 1 & 2
	If (GetEffectTimeRemaining() < 5000) Then
		UsePcons()
		logFile("Using Drake Kabob.") <<--- $intSilence 1
	Else
		logFile("Already under Drake Kabob.") <<--- $intSilence 2
	EndIf
#ce
				
Func CheckAndUse_SweetPcons($intSilence = 0)
	If (GetEffectTimeRemaining($Drake_Skin) < 5000) Then
		UsePcons($ITEM_ID_Drake_Kabob)
		If Not (($intSilence == 1) OR ($intSilence == 3)) Then logFile("Using Drake Kabob.")
	Else
		If Not (($intSilence == 2) OR ($intSilence == 3)) Then logFile("Already under Drake Kabob.")
	EndIf
	If (GetEffectTimeRemaining($Skale_Vigor) < 5000) Then
		UsePcons($ITEM_ID_Bowl_of_Skalefin_Soup)
		If Not (($intSilence == 1) OR ($intSilence == 3)) Then logFile("Using Bowl of Skalefin Soup.")
	Else
		If Not (($intSilence == 2) OR ($intSilence == 3)) Then logFile("Already under Bowl of Skalefin Soup.")
	EndIf
	If (GetEffectTimeRemaining($Pahnai_Salad_item_effect) < 5000) Then
		UsePcons($ITEM_ID_Pahnai_Salad)
		If Not (($intSilence == 1) OR ($intSilence == 3)) Then logFile("Using Pahnai Salad.")
	Else
		If Not (($intSilence == 2) OR ($intSilence == 3)) Then logFile("Already under Pahnai Salad.")
	EndIf
	If (GetEffectTimeRemaining($Birthday_Cupcake_skill) < 5000) Then
		UsePcons($ITEM_ID_Birthday_Cupcake)
		If Not (($intSilence == 1) OR ($intSilence == 3)) Then logFile("Using Cupcake.")
	Else
		If Not (($intSilence == 2) OR ($intSilence == 3)) Then logFile("Already under Cupcake.")
	EndIf
	If (GetEffectTimeRemaining($Golden_Egg_item_effect) < 5000) Then
		UsePcons($ITEM_ID_Golden_Egg)
		If Not (($intSilence == 1) OR ($intSilence == 3)) Then logFile("Using Golden Egg.")
	Else
		If Not (($intSilence == 2) OR ($intSilence == 3)) Then logFile("Already under Golden Egg.")
	EndIf
	If (GetEffectTimeRemaining($Candy_Apple_skill) < 5000) Then
		UsePcons($ITEM_ID_Candy_Apple)
		If Not (($intSilence == 1) OR ($intSilence == 3)) Then logFile("Using Candy Apple.")
	Else
		If Not (($intSilence == 2) OR ($intSilence == 3)) Then logFile("Already under Candy Apple.")
	EndIf
	If (GetEffectTimeRemaining($Candy_Corn_skill) < 5000) Then
		UsePcons($ITEM_ID_Candy_Corn)
		If Not (($intSilence == 1) OR ($intSilence == 3)) Then logFile("Using Candy Corn.")
	Else
		If Not (($intSilence == 2) OR ($intSilence == 3)) Then logFile("Already under Candy Corn.")
	EndIf
	If (GetEffectTimeRemaining($Pie_Induced_Ecstasy) < 5000) Then
		UsePcons($ITEM_ID_Slice_of_Pumpkin_Pie)
		If Not (($intSilence == 1) OR ($intSilence == 3)) Then logFile("Using Slice of Pumpkin Pie.")
	Else
		If Not (($intSilence == 2) OR ($intSilence == 3)) Then logFile("Already under Slice of Pumpkin Pie.")
	EndIf
	If (GetEffectTimeRemaining($Well_Supplied) < 5000) Then
		UsePcons($ITEM_ID_War_Supplies)
		If Not (($intSilence == 1) OR ($intSilence == 3)) Then logFile("Using War Supplies.")
	Else
		If Not (($intSilence == 2) OR ($intSilence == 3)) Then logFile("Already under War Supplies.")
	EndIf
EndFunc

Func CheckAndUse_Fortune($intSilence = 0)
	Local $Bool_FortuneStop = False
	Local $Fortune_ModelID = 29424
	Local $Fortune_Used = 0

	While Not $Bool_FortuneStop
        If Not _HasEffect($Lunar_Blessing) Then
            If Not UsePcons($Fortune_ModelID) Then 
                $Fortune_ModelID += 1
            Else
                $Fortune_Used += 1
            EndIf
            If ($Fortune_ModelID > 29435) Then 
                $Bool_FortuneStop = True
                If ($Fortune_Used == 0) Then $Fortune_Used = -1
            EndIf
            logFile($Fortune_ModelID)
        Else
            $Bool_FortuneStop = True
        EndIf
	Wend
	
	If ($Fortune_Used <> -1) Then
		If Not (($intSilence == 1) OR ($intSilence == 3)) Then logFile("Fortunes used :" & $Fortune_Used)
	Else
		If Not (($intSilence == 2) OR ($intSilence == 3)) Then logFile("Already under War Supplies.")
	EndIf
EndFunc

Func CheckAndUse_RockCandy($intSilence = 0)
	If (GetEffectTimeRemaining($Blue_Rock_Candy_Rush) < 5000) Then
		UsePcons($ITEM_ID_Blue_Rock_Candy)
		If Not (($intSilence == 1) OR ($intSilence == 3)) Then logFile("Using Blue Rock Candy.")
	Else
		If Not (($intSilence == 2) OR ($intSilence == 3)) Then logFile("Already under Blue Rock Candy.")
	EndIf
	If (GetEffectTimeRemaining($Green_Rock_Candy_Rush) < 5000) Then
		UsePcons($ITEM_ID_Green_Rock_Candy)
		If Not (($intSilence == 1) OR ($intSilence == 3)) Then logFile("Using Green Rock Candy.")
	Else
		If Not (($intSilence == 2) OR ($intSilence == 3)) Then logFile("Already under Green Rock Candy.")
	EndIf
	If (GetEffectTimeRemaining($Red_Rock_Candy_Rush) < 5000) Then
		UsePcons($ITEM_ID_Red_Rock_Candy)
		If Not (($intSilence == 1) OR ($intSilence == 3)) Then logFile("Using Red Rock Candy.")
	Else
		If Not (($intSilence == 2) OR ($intSilence == 3)) Then logFile("Already under Red Rock Candy.")
	EndIf
EndFunc

Func CheckAndUse_MoralCons($intSilence = 0)
	Local $Cons_type = 0

	Local $Bool_DPRemoval_present = True
	Local $Bool_MoralUpgrade_present = True
	
	Local $DPRemoval_Used = 0
	Local $MoralUpgrade_Used = 0
    
	If (GetMorale(0) == 10) Then
		If Not (($intSilence == 2) OR ($intSilence == 3)) Then logFile("Morale is already +10%")
		Return
	EndIf
	
	While ((GetMorale(0) < 10) AND ($Bool_DPRemoval_present OR $Bool_MoralUpgrade_present))
        If ((GetMorale(0) < 0) AND $Bool_DPRemoval_present) Then
			If UsePcons($ITEM_ID_Peppermint_CC) Then
				$DPRemoval_Used += 1
			ElseIf UsePcons($ITEM_ID_Wintergreen_CC) Then
				$DPRemoval_Used += 1
			ElseIf UsePcons($ITEM_ID_Four_Leaf_Clover) Then
				$DPRemoval_Used += 1
            ElseIf UsePcons($ITEM_ID_Refined_Jelly) Then
                $DPRemoval_Used += 1
            ElseIf UsePcons($Item_ID_Shining_Blade_Ration) Then
                $DPRemoval_Used += 1
            ElseIf UsePcons($ITEM_ID_Oath_of_Purity) Then
                $DPRemoval_Used += 1
			Else
				$Bool_DPRemoval_present = False
			EndIf
		ElseIf ($Bool_MoralUpgrade_present) Then
			If UsePcons($ITEM_ID_Rainbow_CC) Then
				$MoralUpgrade_Used += 1
			ElseIf UsePcons($ITEM_ID_Honeycomb) Then
				$MoralUpgrade_Used += 1
            ElseIf UsePcons($ITEM_ID_Pumpkin_Cookie) Then
                $MoralUpgrade_Used += 1
            ElseIf UsePcons($ITEM_ID_Elixir_of_Valor) Then
                $MoralUpgrade_Used += 1
            ElseIf UsePcons($ITEM_ID_Seal_of_the_Dragon_Empire) Then
                $MoralUpgrade_Used += 1
			ElseIf UsePcons($ITEM_ID_Powerstone_of_Courage) Then
				$MoralUpgrade_Used += 1
			Else
				$Bool_MoralUpgrade_present = False
			EndIf
		EndIf
	Wend
	
	If ($DPRemoval_Used > 0) Then
		If Not (($intSilence == 1) OR ($intSilence == 3)) Then logFile("DP Remover used: " & $DPRemoval_Used)
	EndIf
    If ($MoralUpgrade_Used > 0) Then
        If Not (($intSilence == 1) OR ($intSilence == 3)) Then logFile("Moral upgrader used: "  & $MoralUpgrade_Used)
	EndIf
EndFunc
    
Func CheckAndUse_Conset($intSilence = 0)
	CheckAndUse_ArmorOfSalvation($intSilence)
	CheckAndUse_EssenceOfCelerity($intSilence)
	CheckAndUse_GrailOfMight($intSilence)
EndFunc

Func CheckAndUse_ArmorOfSalvation($intSilence = 0) ;Check and use Armor of Salvation
	If (GetEffectTimeRemaining($Armor_of_Salvation_item_effect) < 5000) Then
		UsePcons($ITEM_ID_Armor_of_Salvation)
		If Not (($intSilence == 1) OR ($intSilence == 3)) Then logFile("Using Armor of Salvation.")
	Else
		If Not (($intSilence == 2) OR ($intSilence == 3)) Then logFile("Already under Armor of Salvation.")
	EndIf
EndFunc

Func CheckAndUse_EssenceOfCelerity($intSilence = 0) ;Check and use Essence of celerity
	If (GetEffectTimeRemaining($Essence_of_Celerity_item_effect) < 5000) Then
		UsePcons($ITEM_ID_Essence_of_Celerity)
		If Not (($intSilence == 1) OR ($intSilence == 3)) Then logFile("Using Essence of Celerity.")
	Else
		If Not (($intSilence == 2) OR ($intSilence == 3)) Then logFile("Already under Essence of Celerity.")
	EndIf
EndFunc

Func CheckAndUse_GrailOfMight($intSilence = 0) ;Check and use Grail of Might
	If (GetEffectTimeRemaining($Grail_of_Might_item_effect) < 5000) Then
		UsePcons($ITEM_ID_Grail_of_Might)
		If Not (($intSilence == 1) OR ($intSilence == 3)) Then logFile("Using Grail of Might.")
	Else
		If Not (($intSilence == 2) OR ($intSilence == 3)) Then logFile("Already under Grail of Might.")
	EndIf
EndFunc
				#EndRegion