Func IsPerfectShield($aItem) ; Need to add -5(20%)
    Local $ModStruct = GetModStruct($aItem)
    ; Universal mods
    Local $Plus30 = StringInStr($ModStruct, "1E4823", 0, 1) ; Mod struct for +30 (shield only?)
    Local $Minus3Hex = StringInStr($ModStruct, "3009820", 0, 1) ; Mod struct for -3wHex (shield only?)
    Local $Minus2Stance = StringInStr($ModStruct, "200A820", 0, 1) ; Mod Struct for -2Stance
#include "GWA2_Headers.au3"
    Local $Minus2Ench = StringInStr($ModStruct, "2008820", 0, 1) ; Mod struct for -2Ench
    Local $Plus45Stance = StringInStr($ModStruct, "02D8823", 0, 1) ; For +45Stance
    Local $Plus45Ench = StringInStr($ModStruct, "02D6823", 0, 1) ; Mod struct for +40ench
    Local $Plus44Ench = StringInStr($ModStruct, "02C6823", 0, 1) ; For +44/+10Demons
    Local $Minus520 = StringInStr($ModStruct, "5147820", 0, 1) ; For -5(20%)
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
 Func IsPerfectCaster($aItem)
    Local $ModStruct = GetModStruct($aItem)
    Local $A = GetItemAttribute($aItem)
    ; Universal mods
    Local $PlusFive = StringInStr($ModStruct, "5320823", 0, 1) ; Mod struct for +5^50
    Local $PlusFiveEnch = StringInStr($ModStruct, "500F822", 0, 1)
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
 Func IsRareRune($aItem)
    Local $ModStruct = GetModStruct($aItem)
    Local $SupVigor = StringInStr($ModStruct, "C202EA27", 0, 1) ; Mod struct for Sup vigor rune
    Local $WindWalker = StringInStr($ModStruct, "040430A5060518A7", 0, 1) ; Windwalker insig
    Local $MinorMyst = StringInStr($ModStruct, "05033025012CE821", 0, 1) ; Minor Mysticism
    Local $SupEarthPrayers = StringInStr($ModStruct, "32BE82109033025", 0, 1) ; Sup earth prayers
    Local $Prodigy = StringInStr($ModStruct, "C60330A5000528A7", 0, 1) ; Prodigy insig
    Local $SupDom = StringInStr($ModStruct, "30250302E821770", 0, 1) ; Superior Domination
    Local $Shamans = StringInStr($ModStruct, "080430A50005F8A", 0, 1) ; Shamans insig

    If $SupVigor > 0 Or $WindWalker > 0 Or $MinorMyst > 0 Or $SupEarthPrayers > 0 Or $Prodigy > 0 Or $SupDom > 0 Or $Shamans > 0 Then
       Return True
    Else
       Return False
    EndIf
 EndFunc
Func IsRareMaterial($aItem)
   Local $M = DllStructGetData($aItem, "ModelID")

   Switch $M
   Case 937, 938, 935, 931, 932, 936, 930
      Return True ; Rare Mats
   EndSwitch
   Return False
EndFunc
 Func IsSpecialItem($aItem)
    Local $ModelID = DllStructGetData($aItem, "ModelID")
    Local $ExtraID = DllStructGetData($aItem, "ExtraID")

    Switch $ModelID
    Case 5656, 18345, 21491, 37765, 21833, 28433, 28434
       Return True ; Special - ToT etc
    Case 22751
       Return True ; Lockpicks
    Case 27047
       Return True ; Glacial Stones
    Case 21796, 21797, 21798, 21799, 21800, 21801, 21802, 21803, 21804, 21805, 21786, 21787, 21788, 21789, 21790, 21791, 21792, 21793, 21794, 21795
       Return True ; All Tomes
    Case 146
       If $ExtraID = 10 Or $ExtraID = 12 Then
          Return True ; Black & White Dye
       Else
          Return False
       EndIf
    Case 24353, 24354
       Return True ; Chalice & Rin Relics
    Case 27052
       Return True ; Superb Charr Carving
    Case 522
       Return True ; Dark Remains
    Case 3746, 22280
       Return True ; Underworld & FOW Scroll
    Case 819
       Return True ; Dragon Root
    Case 35121
       Return True ; War supplies
    Case 36985
       Return True ; Commendations
    EndSwitch
    Return False
 EndFunc
 Func IsPcon($aItem)
    Local $ModelID = DllStructGetData($aItem, "ModelID")

    Switch $ModelID
    Case 910, 2513, 5585, 6049, 6366, 6367, 6375, 15477, 19171, 19172, 19173, 22190, 24593, 28435, 30855, 31145, 31146, 35124, 36682
       Return True ; Alcohol
    Case 6376, 21809, 21810, 21813, 36683
       Return True ; Party
    Case 21492, 21812, 22269, 22644, 22752, 28436
       Return True ; Sweets
    Case 6370, 21488, 21489, 22191, 26784, 28433
       Return True ; DP Removal
    Case 15837, 21490, 30648, 31020
       Return True ; Tonic
    EndSwitch
    Return False
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
Func GetItemMaxDmg($aItem)
    If Not IsDllStruct($aItem) Then $aItem = GetItemByItemID($aItem)
    Local $lModString = GetModStruct($aItem)
    Local $lPos = StringInStr($lModString, "A8A7") ; Weapon Damage
    If $lPos = 0 Then $lPos = StringInStr($lModString, "C867") ; Energy (focus)
    If $lPos = 0 Then $lPos = StringInStr($lModString, "B8A7") ; Armor (shield)
    If $lPos = 0 Then Return 0
    Return Int("0x" & StringMid($lModString, $lPos - 2, 2))
 EndFunc


Func IsNiceMod($aItem)
    Local $ModStruct = GetModStruct($aItem)
    Local $t         = DllStructGetData($aItem, "Type")

    Local $ArmorAlways = StringInStr($ModStruct, "05000821", 0 ,1) ; Armor +5
        If $ArmorAlways > 0 And ($t = 36) Then ; 26 is Staff Head or Wrapping
            Return True
            Return False
        EndIf

    Local $FuriousPrefix = StringInStr($ModStruct, "0A00B823", 0 ,1) ; Axe haft, Dagger Tang, Hammer Haft, Scythe Snathe, Spearhead, Sword Hilt
        If $FuriousPrefix > 0 And ($t = 36) Then
            Return True
            Return False
    EndIf

    Local $HealthAlways = StringInStr($ModStruct, "001E4823", 0 ,1) ; +30 Health
        If $HealthAlways > 0 And ($t = 24 Or $t = 27 Or $t = 36) Then ; 12 is focus core, 26 can be Staff Head or Wrap
            Return True
            Return False
        EndIf

    Local $ofEnchanting = StringInStr($ModStruct, "1400B822", 0 ,1) ; +20% Enchantment Duration
        If $ofEnchanting > 0 And ($t = 26 Or $t = 36) Then ; 26 is Staff Wrapping
            Return True
            Return False
        EndIf


    ; ; +10 armor vs type
    ; Local $NotTheFace = StringInStr($ModStruct, "0A0018A1", 0 ,1) ; Armor +10 (vs Blunt damage)
    ;     If $NotTheFace > 0 Then
    ;         Return True
    ;         Return False
    ; EndIf
    ; Local $LeafOnTheWind = StringInStr($ModStruct, "0A0318A1", 0 ,1) ; Armor +10 (vs Cold damage)
    ;     If $LeafOnTheWind > 0 Then
    ;         Return True
    ;         Return False
    ;     EndIf
    ; Local $LikeARollingStone = StringInStr($ModStruct, "0A0B18A1", 0 ,1) ; Armor +10 (vs Earth damage)
    ;     If $LikeARollingStone > 0 Then
    ;         Return True
    ;         Return False
    ;     EndIf
    ; Local $SleepNowInTheFire = StringInStr($ModStruct, "0A0518A1", 0 ,1) ; Armor +10 (vs Fire damage)
    ;     If $SleepNowInTheFire > 0 Then
    ;         Return True
    ;         Return False
    ;     EndIf
    ; Local $RidersOnTheStorm = StringInStr($ModStruct, "0A0418A1", 0 ,1) ; Armor +10 (vs Lightning damage)
    ;     If $RidersOnTheStorm > 0 Then
    ;         Return True
    ;         Return False
    ;     EndIf
    ; Local $ThroughThickAndThin = StringInStr($ModStruct, "0A0118A1", 0 ,1) ; Armor +10 (vs Piercing damage)
    ;     If $ThroughThickAndThin > 0 Then
    ;         Return True
    ;         Return False
    ;     EndIf
    ; Local $TheRiddleOfSteel = StringInStr($ModStruct, "0A0218A1", 0 ,1) ; Armor +10 (vs Slashing damage)
    ;     If $TheRiddleOfSteel > 0 Then
    ;         Return True
    ;         Return False
    ;     EndIf


    ; reduce blind dazed cripple -33%
    ; Local $ICanSeeClearlyNow = StringInStr($ModStruct, "00015828", 0 ,1) ; Reduces Blind duration on you by 20%
    ;     If $ICanSeeClearlyNow > 0 Then
    ;         Return True
    ;         Return False
    ;     EndIf
    ; Local $SwiftAsTheWind = StringInStr($ModStruct, "00035828", 0 ,1) ; Reduces Crippled duration on you by 20%
    ;     If $SwiftAsTheWind > 0 Then
    ;         Return True
    ;         Return False
    ;     EndIf
    ; Local $SoundnessOfMind = StringInStr($ModStruct, "00075828", 0 ,1) ; Reduces Dazed duration on you by 20%
    ;     If $SoundnessOfMind > 0 Then
    ;         Return True
    ;         Return False
    ;     EndIf


    ; 40/40 mods
    Local $HCT20 = StringInStr($ModStruct, "00140828", 0 ,1) ; Halves casting time of spells of item's attribute (Chance: 20%)
        If $HCT20 > 0 And ($t = 12 Or $t = 22 Or $t = 26) Then; 12 is Focus core of aptitude, 22 is Inscription Aptitude Not Attitude, 26 is Inscription or Adept Staff head
            Return True
            Return False
        EndIf

    Local $HSR20 = StringInStr($ModStruct, "00142828", 0, 1) ; Halves skill recharge of spells (Chance: 20%)
        If $HSR20 > 0 And ($t = 12 Or $t = 22) Then ; 12 is Forget Me Not, 22 is Wand Wrapping of Memory
            Return True
            Return False
        EndIf

    Return False

EndFunc



; Axe (Type 2)
; Bow (Type 5)
; Runes (Type 8)
; Offhand (Type 12)
; Hammer (Type 15)
; Wand (Type 22)
; Shield (Type 24)
; Staff (Type 26)
; Sword (Type 27)
; Dagger  (Type 32)
; Scythe (Type 35)
; Spear (Type 36)
