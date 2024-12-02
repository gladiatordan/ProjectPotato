#Region Variables
Global $MyPlayerNumber
Global Enum $DIFFICULTY_NORMAL, $DIFFICULTY_HARD
Global Enum $INSTANCETYPE_OUTPOST, $INSTANCETYPE_EXPLORABLE, $INSTANCETYPE_LOADING
Global Enum $PROF_NONE, $PROF_WARRIOR, $PROF_RANGER, $PROF_MONK, $PROF_NECROMANCER, $PROF_MESMER, $PROF_ELEMENTALIST, $PROF_ASSASSIN, $PROF_RITUALIST, $PROF_PARAGON, $PROF_DERVISH
Global Enum $ComboReq_FollowsDual = 1, $ComboReq_FollowsLead, $ComboReq_FollowsOffhand = 4
Global $mSelf
Global $GoPlayer = 0
Global $MyMaxHP
Global Const $Null = 0
Global $AOEDanger = False
Global $AOEDangerRange = 0
Global $AOEDangerXLocation
Global $AOEDangerYLocation
Global $AOEDangerDuration
Global $AOEDangerTimer
Global $mSelfID
Global $mLowestAlly
Global $mLowestAllyHP
Global $mLowestAllyDist
Global $mHighestAlly
Global $mHighestAllyHP
Global $mLowestOtherAlly
Global $mLowestOtherAllyHP
Global $mLowestOtherAllyDist
Global $mHighestOtherAlly
Global $mHighestOtherAllyHP
Global $SpeedBoostTarget
Global $mLowestEnemy
Global $mLowestEnemyHP
Global $mClosestEnemy
Global $mClosestEnemyDist
Global $mBestShrineTarget
Global $mAlliesInRangeOfShrine
Global $mClosestAlly
Global $mClosestAllyDist
Global $mClosestOtherAlly
Global $mClosestOtherAllyDist
Global $mClosestFriendlyQuarry
Global $mClosestFriendlyQuarryDist
Global $mClosestCarrier
Global $mClosestCarrierDist
Global $mAverageTeamHP
Global $mAverageTeamLocationX
Global $mAverageTeamLocationY
Global $TotalAlliesOnMap
Global $NumberOfFoesInAttackRange = 0
Global $NumberOfDeadFoes = 0
Global $NumberOfFoesInSpellRange = 0
Global $NumPlayersInCloseRange = 0
Global $NumAlliesInCloseRange = 0
Global $NumPlayersOnMap = 0
Global $NearestShrineTarget = 0
Global $NearestShrineDist
Global $LeastAttackedShrine = 0
Global $LeastAttackedShrineDist
Global $NearestQuarryTarget = 0
Global $NearestQuarryDist
Global $BestAOETarget
Global $HexedAlly
Global $ConditionedAlly
Global $EnemyHexed
Global $EnemyNonHexed
Global $EnemyConditioned
Global $EnemyNonConditioned
Global $EnemyHealer
Global $EnemyAttacker = 0
Global $ClostestX[1]
Global $ClostestY[1]
Global $mTeam[1] ;Array of living members
Global $mTeamOthers[1] ;Array of living members other than self
Global $mTeamDead[1] ;Array of dead teammates
Global $mEnemies[1] ;Array of living enemy team
Global $mEnemiesRange[1] ;Array of living enemy team in range of waypoint
Global $mEnemiesSpellRange[1] ;Array of living enemy team in spell range
Global $mEnemyCorpesSpellRange[1] ;Array of dead enemy team in spell range
Global $mSpirits[1] ;Array of your spirits
Global $mPets[1] ;Array of your/your hero's pets
Global $mMinions[1] ;Array of your minions
Global Const $BoneHorrorID = 2198
Global $mDazed = False
Global $mBlind = False
Global $mSkillHardCounter = False
Global $mSkillSoftCounter = 0
Global $mAttackHardCounter = False
Global $mAttackSoftCounter = 0
Global $mAllySpellHardCounter = False
Global $mEnemySpellHardCounter = False
Global $mSpellSoftCounter = 0
Global $mBlocking = False
Global $mCastTime = -1
Global $mLastTarget = 0
Global $mMinipet = True
Global $boolRun = False
Global $Goldz = False
Global $boolIDSell = True
Global $boolPickAll = True
Global $intFaction = 0
Global $intTitle = 0
Global $intPrevious = -1
Global $intStarted = -1
Global $intCash = -1
Global $intGold = 0
Global $intRuns = 0
Global $grog = 30855
Global $golds = 2511
Global $gstones = 27047
Global $tots = 28434
Global $Resigned = False
Global $SavedLeader
Global $SavedLeaderID
Global $NumberInParty
Global $InOutpostCounter = 0
Global $GotBounty = False
Global $Defending = False
Global $CurrentMapID = 0
Global $UpdateText
Global $FirstRun = True
Global $GWPID = -1
Global $UseEverlastingTonic = False
Global $HurtTimer = TimerInit()
Global $RestTimer
Global $CurrentHP = 1000
Global $NeedToChangeMap = False
Global $Resting = False
Global $Pink = 9
Global $InAttackRange = False
Global Const $Sunday = "Sunday"
Global Const $Monday = "Monday"
Global Const $Tuesday = "Tuesday"
Global Const $Wednesday = "Wednesday"
Global Const $Thursday = "Thursday"
Global Const $Friday = "Friday"
Global Const $Saturday = "Saturday"
Global $mTempStorage[1][2] = [[0, 0]]
Global $SlotFull[5][25]
Global $NewSlot
Global $mFoundMerch = False
Global $mFoundChest = False
Global $aMerchName = "Merchant"
Global Const $SaveGolds = False ;Save gold items.
Global Const $Bags = 4
Global Const $Ectoplasm = 930
Global Const $ObsidianShards = 945
Global Const $Ruby = 937
Global Const $Sapphire = 938
Global Const $DiessaChalice = 24353
Global Const $GoldenRinRelics = 24354
Global Const $Lockpicks = 22751
Global Const $SuperbCharrCarving = 27052
Global Const $DarkRemains = 522
Global Const $UmbralSkeletalLimbs = 525
Global Const $Scroll_Underworld = 3746
Global Const $Scroll_FOW = 22280
Global Const $MAT_Bone = 921
Global Const $MAT_Dust = 929
Global Const $MAT_Iron = 948
Global Const $MAT_TannedHides = 940
Global Const $MAT_Scales = 953
Global Const $MAT_Chitin = 954
Global Const $MAT_Cloth = 925
Global Const $MAT_Wood = 946
Global Const $MAT_Granite = 955
Global Const $MAT_Fiber = 934
Global Const $MAT_Feathers = 933
Global Const $CON_EssenceOfCelerity = 24859
Global Const $CON_GrailOfMight = 24861
Global Const $CON_ArmorOfSalvation = 24860

Global Const $ENEMY = 0x3

;===========Skills Stuff============;
Global $GetSkillBar = False
Global $mSkillTimer = TimerInit()
Global $mSkillbarCache[9] = [False]
Global $mSkillbarCacheStruct[9] = [False]
Global $mSkillbarCacheEnergyReq[9] = [False]
Global $mEffects
Global $mSkillbar
Global $mEnergy
Global $IsHealingSpell[9] = [False]
Global $IsCorpseSpell[9] = [False]
Global $IsHealingOtherAllySpell[9] = [False]
Global $IsSpeedBoostSkill[9] = [False]
Global $IsSpiritSpell[9] = [False]
Global $IsHexRemover[9] = [False]
Global $IsConditionRemover[9] = [False]
Global $IsAOESpell[9] = [False]
Global $IsGeneralAttackSpell[9] = [False]
Global $IsInterruptSpell[9] = [False]
Global $IsYMLAD[9] = [False]
Global $YMLADSlot = 0
Global $IsRezSpell[9] = [False]
Global $IsSummonSpell[9] = [False]
Global $IsSoulTwistingSpell[9] = [False]
Global $IsSelfCastingSpell[9] = [False]
Global $IsWeaponSpell[9] = [False]
Global $SkillDamageAmount[9] = [False]
Global $SkillAdrenalineReq[9] = [False]
Global $SkillComboFollowsDual[9] = [False]
Global $SkillComboFollowsLead[9] = [False]
Global $SkillComboFollowsOffhand[9] = [False]
Global $IsHealerPrimary = False
Global $Skill_FAILED = 0
Global $EnemyCaster = 0
Global $EnemyCasterTimer
Global $EnemyCasterSkillTime
Global $EnemyCasterActivationTime = 0
Global $lMyProfession
Global $lAttrPrimary
Global $SkillTYP
Global $YMLADTimer = 5000

Const $MK_LBUTTON = 0x0001
Const $MK_RBUTTON = 0x0002
#EndRegion Variables

#Region CASTING SmartCast Functions
#Region SmartCast Function

Func SmartCast() ;Choose the appropriate skill to cast at the moment
	#Region Variables
	Local $Me = GetAgentByID(-2)
	If GetIsDead($Me) Then Return False
	;If GetMapLoading() <> $INSTANCETYPE_EXPLORABLE Then Return False
	If Not $mSkillbarCache[0] Then
		$mSkillbar = GetSkillbar()
		Sleep(200)
		CacheSkillbar()
	EndIf

	Local $SkillIsRecharged[9] = [False]
	#EndRegion Variables

	; Skill usage
	For $i = 1 To 8
		If $Skill_FAILED == $i Then
			$Skill_FAILED = 0
			ContinueLoop
		EndIf

		;; Check Recharge and Energy
		If $SkillAdrenalineReq[$i] == 0 Then
			If GetSkillbarSkillRecharge($i) <> 0 Or Not CanUseSkill($i, $mSkillbarCacheEnergyReq[$i]) Then ContinueLoop
		EndIf
		;; Check Adrenaline
		If $SkillAdrenalineReq[$i] > GetSkillbarSkillAdrenaline($i) Then ContinueLoop

		If $IsInterruptSpell[$i] Then
			If $EnemyCaster <> 0 Then ; Interrupt
				UseSkillEx($i, $EnemyCaster)
				Return
			EndIf
		EndIf

		If $IsHealingSpell[0] Then
			If $IsHealingSpell[$i] And Not $IsHealingOtherAllySpell[$i] Then
				If $mLowestAllyHP < 0.75 And HasEffect($mSkillbarCacheStruct[$i]) == False Then
					If $IsWeaponSpell[$i] == True Then
						If $NumberOfFoesInAttackRange > 0 And GetHasWeaponSpell($mLowestAlly) == False Then
							UseSkillEx($i, $mLowestAlly)
							Return
						EndIf
					Else
						If TargetEnemySkill($mSkillbarCacheStruct[$i]) Then
							If $mLowestEnemy <> 0 Then
								UseSkillEx($i, $mLowestEnemy)
								Return
							EndIf
						Else
							UseSkillEx($i, $mLowestAlly)
							Return
						EndIf
					EndIf
				EndIf
			EndIf
			If $IsHealingSpell[$i] And $IsHealingOtherAllySpell[$i] Then
				If $mLowestOtherAllyHP < 0.75 Then
					If $IsWeaponSpell[$i] == True Then
						If $NumberOfFoesInAttackRange > 0 And GetHasWeaponSpell($mLowestOtherAlly) == False Then
							UseSkillEx($i, $mLowestOtherAlly)
							Return
						EndIf
					Else
						UseSkillEx($i, $mLowestOtherAlly)
						Return
					EndIf
				EndIf
			EndIf
			If $mSkillbarCache[$i] == $Protective_Was_Kaolai Then
				If HasEffect($Protective_Was_Kaolai) == False Then
					UseSkillEx($i, $Me)
					Return
				EndIf
			EndIf
		EndIf

		If $IsSpeedBoostSkill[0] Then
			If $IsSpeedBoostSkill[$i] Then
				If $SpeedBoostTarget <> 0 Then
					UseSkillEx($i, $SpeedBoostTarget)
					Return
				EndIf
			EndIf
		EndIf

		If $IsSoulTwistingSpell[$i] Then
			If HasEffect($Soul_Twisting) == False Then
				UseSkillEx($i, $Me)
				Return
			EndIf
		EndIf

		If $NumberOfFoesInAttackRange > 0 Then
			If $IsAOESpell[$i] Then
				If $mSkillbarCache[$i] == $Signet_of_Clumsiness Then
					If $EnemyAttacker <> 0 Then
						UseSkillEx($i, $EnemyAttacker)
						Return
					EndIf
				Else
					If $BestAOETarget <> 0 Then
						UseSkillEx($i, $BestAOETarget)
						Return
					EndIf
					If $EnemyHealer <> 0 Then
						UseSkillEx($i, $EnemyHealer)
						Return
					EndIf
					If $mLowestEnemy <> 0 And $NearestShrineDist >= 1400 And $NearestQuarryDist >= 1400 Then
						UseSkillEx($i, $mLowestEnemy)
						Return
					EndIf
					If $mLowestEnemy <> 0 And $NumberOfFoesInAttackRange == 1 Then
						UseSkillEx($i, $mLowestEnemy)
						Return
					EndIf
				EndIf
			EndIf
		EndIf

		If $IsCorpseSpell[0] Then
			If $IsCorpseSpell[$i] And $NumberOfDeadFoes > 0 Then
				UseSkillEx($i)
				Return
			Else
				ContinueLoop
			EndIf
		EndIf

		If $NumberOfFoesInAttackRange > 0 Then
			If $IsSpiritSpell[0] Then
				If $IsSoulTwistingSpell[0] And $IsSpiritSpell[$i] Then
					If HasEffect($Soul_Twisting) == True And HasEffect($mSkillbarCache[$i]) == False Then
						UseSkillEx($i, $Me)
						Return
					EndIf
				EndIf
				If Not $IsSoulTwistingSpell[0] And $IsSpiritSpell[$i] Then
					UseSkillEx($i, $Me)
					Return
				EndIf
			EndIf

			If $IsConditionRemover[$i] Then
				If $ConditionedAlly <> 0 Then
					UseSkillEx($i, $ConditionedAlly)
					Return
				EndIf
			EndIf

			If $IsHexRemover[$i] Then
				If $HexedAlly <> 0 Then
					UseSkillEx($i, $HexedAlly)
					Return
				EndIf
			EndIf

			If $IsGeneralAttackSpell[$i] Then
;~ 				If $EnemyHealer <> 0 Then
;~ 					UseSkillEx($i, $EnemyHealer)
;~ 					Return
;~ 				EndIf
;~ 				$IsAntiMeleeSkill = IsAntiMeleeSkill($mSkillbarCache[$i])
;~ 				$IsHexingSpell = IsHexSpell($mSkillbarCacheStruct[$i])
;~ 				$IsConditioningSpell = IsConditionSpell($mSkillbarCacheStruct[$i])
;~ 				If $IsAntiMeleeSkill And $EnemyAttacker <> 0 Then
;~ 					UseSkillEx($i, $EnemyAttacker)
;~ 					Return
;~ 				EndIf
;~ 				If $IsHexingSpell And Not $IsConditioningSpell And Not $IsAntiMeleeSkill And $EnemyNonHexed <> 0 Then
;~ 					UseSkillEx($i, $EnemyNonHexed)
;~ 					Return
;~ 				EndIf
;~ 				If $IsConditioningSpell And Not $IsHexingSpell And Not $IsAntiMeleeSkill And $EnemyConditioned <> 0 Then
;~ 					UseSkillEx($i, $EnemyConditioned)
;~ 					Return
;~ 				EndIf
;~ 				If $IsConditioningSpell And $EnemyNonConditioned <> 0 Then
;~ 					UseSkillEx($i, $EnemyNonConditioned)
;~ 					Return
;~ 				EndIf
;~ 				If $IsHexingSpell And $EnemyNonHexed <> 0 Then
;~ 					UseSkillEx($i, $EnemyNonHexed)
;~ 					Return
;~ 				EndIf
				If GetIsCasterProfession() Then
					If $mLowestEnemy <> 0 Then
						UseSkillEx($i, $mLowestEnemy)
						Return
					EndIf
					If $mClosestEnemy <> 0 Then
						UseSkillEx($i, $mClosestEnemy)
						Return
					EndIf
				Else
					If $mClosestEnemy <> 0 Then
						UseSkillEx($i, $mClosestEnemy)
						Return
					EndIf
				EndIf
			EndIf

			If $IsSelfCastingSpell[$i] Then
				If HasEffect($mSkillbarCacheStruct[$i]) == False Then
					UseSkillEx($i)
					Return
				EndIf
			EndIf
		EndIf

	Next
	Return False

EndFunc   ;==>SmartCast
#EndRegion SmartCast Function

#Region Healer stuff
Func GetIsHealer($Agent)
	If DllStructGetData($Agent, 'Primary') == $Ritualist Or DllStructGetData($Agent, 'Secondary') == $Ritualist Then Return True
	If DllStructGetData($Agent, 'Primary') == $Monk Or DllStructGetData($Agent, 'Secondary') == $Monk Then Return True
	Return False
EndFunc   ;==>GetIsHealer

Func IsMonk($Agent)
	If DllStructGetData($Agent, 'Primary') == $Monk Or DllStructGetData($Agent, 'Secondary') == $Monk Then Return True
	Return False
EndFunc   ;==>IsMonk

Func IsEMo($Agent)
	If DllStructGetData($Agent, 'Primary') == $Elementalist And DllStructGetData($Agent, 'Secondary') == $Monk Then
		Return True
	Else
		Return False
	EndIf
EndFunc   ;==>IsEMo

;~ Returns true if agent uses a martial weapon
Func GetIsMartial($aAgent)
	Switch DllStructGetData($aAgent, 'Profession')
		Case 0
			Switch DllStructGetData($aAgent, 'WeaponType')
				Case 1 To 7
					Return True
				Case Else
					Return False
			EndSwitch
		Case 1, 2, 7, 9, 10
			Return True
		Case Else
			Return False
	EndSwitch
EndFunc   ;==>GetIsMartial
#EndRegion Healer stuff

#Region Type
Func IsHexSpell($Skill)
	If DllStructGetData($Skill, 'Type') == $SKILLTYPE_Hex Then Return True
	Return False
EndFunc   ;==>IsHexSpell

Func IsConditionSpell($Skill)
	If DllStructGetData($Skill, 'Type') == $SKILLTYPE_Condition Then Return True
	Return False
EndFunc   ;==>IsConditionSpell

Func IsEnchantmentSkill($Skill)
	If DllStructGetData($Skill, 'Type') == $SKILLTYPE_Enchantment Then Return True
	Return False
EndFunc   ;==>IsEnchantmentSkill

Func IsAttackSkill($Skill)
	If DllStructGetData($Skill, 'Type') == $SKILLTYPE_Attack Then Return True
	Return False
EndFunc   ;==>IsAttackSkill
#EndRegion Type

Func AttackComboFollowsDual($Skill)
	If Not IsDllStruct($Skill) Then $Skill = GetSkillByID($Skill)
	If DllStructGetData($Skill, 'ComboReq') == $ComboReq_FollowsDual Then Return True
	Return False
EndFunc   ;==>AttackComboFollowsDual

Func AttackComboFollowsLead($Skill)
	If Not IsDllStruct($Skill) Then $Skill = GetSkillByID($Skill)
	If DllStructGetData($Skill, 'ComboReq') == $ComboReq_FollowsLead Then Return True
	Return False
EndFunc   ;==>AttackComboFollowsLead

Func AttackComboFollowsOffhand($Skill)
	If Not IsDllStruct($Skill) Then $Skill = GetSkillByID($Skill)
	If DllStructGetData($Skill, 'ComboReq') == $ComboReq_FollowsOffhand Then Return True
	Return False
EndFunc   ;==>AttackComboFollowsOffhand

#Region Effect1
Func CausesBleedingSkill($Skill)
	If BitAND(DllStructGetData($Skill, 'Effect1'), 1) Then
		Return True
	Else
		Return False
	EndIf
EndFunc   ;==>CausesBleedingSkill

Func CausesBlindSkill($Skill)
	If BitAND(DllStructGetData($Skill, 'Effect1'), 2) Then
		Return True
	Else
		Return False
	EndIf
EndFunc   ;==>CausesBlindSkill

Func CausesBurningSkill($Skill)
	If BitAND(DllStructGetData($Skill, 'Effect1'), 4) Then
		Return True
	Else
		Return False
	EndIf
EndFunc   ;==>CausesBurningSkill

Func CausesCrippleSkill($Skill)
	If BitAND(DllStructGetData($Skill, 'Effect1'), 8) Then
		Return True
	Else
		Return False
	EndIf
EndFunc   ;==>CausesCrippleSkill

Func CausesDeepWoundSkill($Skill)
	If BitAND(DllStructGetData($Skill, 'Effect1'), 16) Then
		Return True
	Else
		Return False
	EndIf
EndFunc   ;==>CausesDeepWoundSkill

Func CausesKnockdownSkill($Skill)
	If BitAND(DllStructGetData($Skill, 'Effect1'), 128) Then
		Return True
	Else
		Return False
	EndIf
EndFunc   ;==>CausesKnockdownSkill
#EndRegion Effect1

#Region Special
Func IsEliteSkill($Skill)
	If BitAND(DllStructGetData($Skill, 'Special'), 4) Then
		Return True
	Else
		Return False
	EndIf
EndFunc   ;==>IsEliteSkill

Func IsSpiritSkill($Skill) ; Spirits (Binding Rituals)
	Switch DllStructGetData($Skill, 'ID')
		Case $Signet_of_Spirits
			Return True
		Case $Agony
			Return True
		Case $Anguish
			Return True
		Case $Bloodsong
			Return True
		Case $Call_to_the_Spirit_Realm
			Return True
		Case $Destruction
			Return True
		Case $Disenchantment
			Return True
		Case $Displacement
			Return True
		Case $Dissonance
			Return True
		Case $Earthbind
			Return True
		Case $Empowerment
			Return True
		Case $Gaze_of_Fury
			Return True
		Case $Life
			Return True
		Case $Jack_Frost
			Return True
		Case $Pain
			Return True
		Case $Preservation
			Return True
		Case $Recovery
			Return True
		Case $Recuperation
			Return True
		Case $Rejuvenation
			Return True
		Case $Restoration
			Return True
		Case $Shadowsong
			Return True
		Case $Shelter
			Return True
		Case $Soothing
			Return True
		Case $Union
			Return True
		Case $Vampirism
			Return True
		Case $Wanderlust
			Return True
		Case Else
			Return False
	EndSwitch
EndFunc   ;==>IsSpiritSkill

Func IsPvESkill($Skill)
	If BitAND(DllStructGetData($Skill, 'Special'), 524288) Then
		Return True
	Else
		Return False
	EndIf
EndFunc   ;==>IsPvESkill
#EndRegion Special

#Region Effect2
Func IsHealSkill($Skill)
	If IsResSkill($Skill) == True Then Return False
	If BitAND(DllStructGetData($Skill, 'Effect1'), 4096) Then Return True
	If BitAND(DllStructGetData($Skill, 'Effect2'), 2) Then Return True
	If BitAND(DllStructGetData($Skill, 'Effect2'), 4) Then Return True
	If DllStructGetData($Skill, 'Attribute') == $Restoration_Magic Then Return True
	If DllStructGetData($Skill, 'Attribute') == $Healing_Prayers Then Return True
	If DllStructGetData($Skill, 'Attribute') == $Protection_Prayers Then Return True
	If DllStructGetData($Skill, 'Attribute') == $Divine_Favor Then Return True
	If DllStructGetData($Skill, 'Attribute') == $Blood_Magic Then Return False
	If DllStructGetData($Skill, 'ID') == $Mystic_Regeneration Then Return True
	If DllStructGetData($Skill, 'ID') == $Mystic_Regeneration_PvP Then Return True
	Return False
EndFunc   ;==>IsHealSkill

Func IsSpeedBoost($Skill)
	Switch DllStructGetData($Skill, 'ID')
		Case $Make_Haste
			Return True
		Case $Windborne_Speed
			Return True
		Case $Lead_the_Way
			Return True
		Case $Gust
			Return True
		Case Else
			Return False
	EndSwitch
EndFunc   ;==>IsSpeedBoost


Func IsResSkill($Skill)
	Switch DllStructGetData($Skill, 'ID')
		Case $By_Urals_Hammer
			Return True
		Case $We_Shall_Return
			Return True
		Case $Death_Pact_Signet
			Return True
		Case $Eternal_Aura
			Return True
		Case $Flesh_of_My_Flesh
			Return True
		Case $Junundu_Wail
			Return True
		Case $Light_of_Dwayna
			Return True
		Case $Lively_Was_Naomei
			Return True
		Case $Rebirth
			Return True
		Case $Renew_Life
			Return True
		Case $Restoration
			Return True
		Case $Restore_Life
			Return True
		Case $Resurrect
			Return True
		Case $Resurrection_Chant
			Return True
		Case $Resurrection_Signet
			Return True
		Case $Signet_of_Return
			Return True
		Case $Sunspear_Rebirth_Signet
			Return True
		Case $Unyielding_Aura
			Return True
		Case $Vengeance
			Return True
		Case Else
			Return False
	EndSwitch
EndFunc   ;==>IsResSkill

Func IsHexRemovalSkill($Skill)
	If BitAND(DllStructGetData($Skill, 'Effect2'), 2048) Then
		Return True
	Else
		Return False
	EndIf
EndFunc   ;==>IsHexRemovalSkill

Func IsConditionRemovalSkill($Skill)
	Switch DllStructGetData($Skill, 'ID')
		Case $Dismiss_Condition
			Return True
		Case $Mend_Condition
			Return True
		Case $Mend_Ailment
			Return True
		Case $Restore_Condition
			Return True
		Case $Mending_Touch
			Return True
		Case $Purge_Conditions
			Return True
		Case $Purge_Signet
			Return True
		Case Else
			Return False
	EndSwitch
EndFunc   ;==>IsConditionRemovalSkill
#EndRegion Effect2

#Region Target
Func TargetSelfSkill($Skill)
	If DllStructGetData($Skill, 'Target') = 0 Then Return True
	Return False
EndFunc   ;==>TargetSelfSkill

Func TargetSpiritSkill($Skill) ; Conditions, Charm Animal, Putrid Explosion, Spirit Targetting
	If DllStructGetData($Skill, 'Target') = 1 Then Return True
	Return False
EndFunc   ;==>TargetSpiritSkill

Func TargetAllySkill($Skill)
	If DllStructGetData($Skill, 'Target') = 3 Then Return True
	Return False
EndFunc   ;==>TargetAllySkill

Func TargetOtherAllySkill($Skill)
	If DllStructGetData($Skill, 'Target') = 4 Then Return True
	Return False
EndFunc   ;==>TargetOtherAllySkill

Func TargetEnemySkill($Skill)
	If DllStructGetData($Skill, 'Target') = 5 Then Return True
	Return False
EndFunc   ;==>TargetEnemySkill

Func TargetDeadAllySkill($Skill)
	If DllStructGetData($Skill, 'Target') = 6 Then Return True
	Return False
EndFunc   ;==>TargetDeadAllySkill

Func TargetMinionSkill($Skill)
	If DllStructGetData($Skill, 'Target') = 14 Then Return True
	Return False
EndFunc   ;==>TargetMinionSkill

Func TargetGroundSkill($Skill) ; some AoE spells
	If DllStructGetData($Skill, 'Target') = 16 Then Return True
	Return False
EndFunc   ;==>TargetGroundSkill
#EndRegion Target

#Region Skill INFO
Func SkillDamageAmount($Skill)
	Return DllStructGetData($Skill, 'Scale15')
EndFunc   ;==>SkillDamageAmount

Func SkillAOERange($Skill)
	Return DllStructGetData($Skill, 'AoERange')
EndFunc   ;==>SkillAOERange

Func SkillRecharge($Skill)
	Return DllStructGetData($Skill, 'Recharge')
EndFunc   ;==>SkillRecharge

Func SkillActivation($Skill)
	Return DllStructGetData($Skill, 'Activation')
EndFunc   ;==>SkillActivation

Func SkillAttribute($Skill)
	Return DllStructGetData($Skill, 'Attribute')
EndFunc   ;==>SkillAttribute
#EndRegion Skill INFO

#Region Skill Requirements
Func SkillRequiresBleeding($Skill)
	If BitAND(DllStructGetData($Skill, 'Condition'), 1) Then
		Return True
	Else
		Return False
	EndIf
EndFunc   ;==>SkillRequiresBleeding

Func SkillRequiresBurning($Skill)
	If BitAND(DllStructGetData($Skill, 'Condition'), 4) Then
		Return True
	Else
		Return False
	EndIf
EndFunc   ;==>SkillRequiresBurning

Func SkillRequiresCripple($Skill)
	If BitAND(DllStructGetData($Skill, 'Condition'), 8) Then
		Return True
	Else
		Return False
	EndIf
EndFunc   ;==>SkillRequiresCripple

Func SkillRequiresDeepWound($Skill)
	If BitAND(DllStructGetData($Skill, 'Condition'), 16) Then
		Return True
	Else
		Return False
	EndIf
EndFunc   ;==>SkillRequiresDeepWound

Func SkillRequiresEarthHex($Skill)
	If BitAND(DllStructGetData($Skill, 'Condition'), 64) Then
		Return True
	Else
		Return False
	EndIf
EndFunc   ;==>SkillRequiresEarthHex

Func SkillRequiresKnockDown($Skill)
	If BitAND(DllStructGetData($Skill, 'Condition'), 128) Then
		Return True
	Else
		Return False
	EndIf
EndFunc   ;==>SkillRequiresKnockDown

Func SkillRequiresWeakness($Skill)
	If BitAND(DllStructGetData($Skill, 'Condition'), 1024) Then
		Return True
	Else
		Return False
	EndIf
EndFunc   ;==>SkillRequiresWeakness

Func SkillRequiresWaterHex($Skill)
	If BitAND(DllStructGetData($Skill, 'Condition'), 2048) Then
		Return True
	Else
		Return False
	EndIf
EndFunc   ;==>SkillRequiresWaterHex

Func IsCorpseSkill($Skill)
	Switch DllStructGetData($Skill, 'ID')
		Case $Aura_of_the_Lich, $Animate_Bone_Fiend, $Animate_Bone_Horror, $Animate_Bone_Minions
			Return True
		Case $Animate_Flesh_Golem, $Animate_Shambling_Horror, $Animate_Vampiric_Horror
			Return True
		Case $Consume_Corpse, $Necrotic_Traversal, $Putrid_Explosion, $Soul_Feast, $Well_of_Blood
			Return True
		Case $Well_of_Darkness, $Well_of_Power, $Well_of_Ruin, $Well_of_Silence, $Well_of_Suffering
			Return True
		Case $Well_of_the_Profane, $Well_of_Weariness, $Junundu_Feast, $Siege_Devourer_Feast
			Return True
		Case Else
			Return False
	EndSwitch
	Return False
EndFunc   ;==>IsCorpseSkill

Func IsInterruptSkill($Skill)
	Switch DllStructGetData($Skill, 'ID')
		Case $You_Move_Like_a_Dwarf
			Return True
		Case $Disarm
			Return True
		Case $Disrupting_Chop
			Return True
		Case $Distracting_Blow
			Return True
		Case $Distracting_Shot
			Return True
		Case $Distracting_Strike
			Return True
		Case $Savage_Slash
			Return True
		Case $Skull_Crack
			Return True
		Case $Disrupting_Shot
			Return True
		Case $Magebane_Shot
			Return True
		Case $Punishing_Shot
			Return True
		Case $Savage_Shot
			Return True
		Case $Leech_Signet
			Return True
		Case $Psychic_Instability
			Return True
		Case $Psychic_Instability_PVP
			Return True
		Case $Simple_Thievery
			Return True
		Case $Thunderclap
			Return True
		Case $Disrupting_Stab
			Return True
		Case $Exhausting_Assault
			Return True
		Case $Lyssas_Assault
			Return True
		Case $Lyssas_Haste
			Return True
		Case $Disrupting_Lunge
			Return True
		Case $Complicate
			Return True
		Case $Cry_of_Frustration
			Return True
		Case $Psychic_Distraction
			Return True
		Case $Tease
			Return True
		Case $Web_of_Disruption
			Return True
		Case $Disrupting_Dagger
			Return True
		Case $Signet_of_Disruption
			Return True
		Case $Signet_of_Distraction
			Return True
		Case $Temple_Strike
			Return True
		Case $Power_Block
			Return True
		Case $Power_Drain
			Return True
		Case $Power_Flux
			Return True
		Case $Power_Leak
			Return True
		Case $Power_Leech
			Return True
		Case $Power_Lock
			Return True
		Case $Power_Return
			Return True
		Case $Power_Spike
			Return True
		Case Else
			Return False
	EndSwitch
EndFunc   ;==>IsInterruptSkill

Func IsWeaponSpell($SkillID)
	Switch $SkillID
		Case $Brutal_Weapon
			Return True
		Case $Ghostly_Weapon
			Return True
		Case $Great_Dwarf_Weapon
			Return True
		Case $Guided_Weapon
			Return True
		Case $Nightmare_Weapon
			Return True
		Case $Resilient_Weapon
			Return True
		Case $Spirit_Light_Weapon
			Return True
		Case $Splinter_Weapon
			Return True
		Case $Sundering_Weapon
			Return True
		Case $Vengeful_Weapon
			Return True
		Case $Vital_Weapon
			Return True
		Case $Wailing_Weapon
			Return True
		Case $Warmongers_Weapon
			Return True
		Case $Weapon_of_Aggression
			Return True
		Case $Weapon_of_Fury
			Return True
		Case $Weapon_of_Quickening
			Return True
		Case $Weapon_of_Remedy
			Return True
		Case $Weapon_of_Renewal
			Return True
		Case $Weapon_of_Shadow
			Return True
		Case $Weapon_of_Warding
			Return True
		Case $Xinraes_Weapon
			Return True
		Case Else
			Return False
	EndSwitch
EndFunc   ;==>IsWeaponSpell

Func SkillRequiresCondition($SkillID)
	Switch $SkillID
		Case $Victory_is_Mine
			Return True
		Case $Yeti_Smash
			Return True
		Case $Pestilence
			Return True
		Case $Scavenger_Strike
			Return True
		Case $Scavengers_Focus
			Return True
		Case $Discord
			Return True
;~ 			Case $Necrosis
;~ 				Return True
		Case $Oppressive_Gaze
			Return True
		Case $Signet_of_Corruption
			Return True
		Case $Vile_Miasma
			Return True
		Case $Virulence
			Return True
		Case $Epidemic
			Return True
		Case $Extend_Conditions
			Return True
		Case $Fevered_Dreams
			Return True
		Case $Fragility
			Return True
		Case $Hypochondria
			Return True
		Case $Crystal_Wave
			Return True
		Case $Iron_Palm
			Return True
		Case $Malicious_Strike
			Return True
		Case $Sadists_Signet
			Return True
		Case $Seeping_Wound
			Return True
		Case $Signet_of_Deadly_Corruption
			Return True
		Case $Signet_of_Malice
			Return True
		Case $Disrupting_Throw
			Return True
		Case $Spear_of_Fury
			Return True
		Case $Stunning_Strike
			Return True
		Case $Armor_of_Sanctity
			Return True
		Case $Reap_Impurities
			Return True
		Case Else
			Return False
	EndSwitch
EndFunc   ;==>SkillRequiresCondition

Func SkillRequiresHex($SkillID)
	Switch $SkillID
		Case $Convert_Hexes
			Return True
		Case $Cure_Hex
			Return True
		Case $Divert_Hexes
			Return True
		Case $Reverse_Hex
			Return True
		Case $Smite_Hex
			Return True
		Case $Discord
			Return True
		Case $Necrosis
			Return True
		Case $Drain_Delusions
			Return True
		Case $Hex_Eater_Signet
			Return True
		Case $Hex_Eater_Vortex
			Return True
		Case $Inspired_Hex
			Return True
		Case $Revealed_Hex
			Return True
		Case $Shatter_Delusions
			Return True
		Case $Shatter_Hex
			Return True
		Case Else
			Return False
	EndSwitch
EndFunc   ;==>SkillRequiresHex

Func IsSummonSkill($SkillID)
	Switch $SkillID
		Case $Summon_Ice_Imp
			Return True
		Case $Summon_Mursaat
			Return True
		Case $Summon_Naga_Shaman
			Return True
		Case $Summon_Ruby_Djinn
			Return True
		Case Else
			Return False
	EndSwitch
EndFunc   ;==>IsSummonSkill

Func IsAntiMeleeSkill($SkillID)
	Switch $SkillID
		Case $Spear_of_Light
			Return True
		Case $Smite
			Return True
		Case $Castigation_Signet
			Return True
		Case $Bane_Signet
			Return True
		Case $Signet_of_Clumsiness
			Return True
		Case $Signet_of_Judgment
			Return True
		Case $Ineptitude
			Return True
		Case $Clumsiness
			Return True
		Case $Wandering_Eye
			Return True
		Case Else
			Return False
	EndSwitch
EndFunc   ;==>IsAntiMeleeSkill
#EndRegion Skill Requirements

#Region Skill Funcs
Func UseSkillByID($SkillID, $Agent)
	$lSkillbar = GetSkillbar()
	For $i = 1 To 8
		If DllStructGetData($lSkillbar, 'Id' & $i) = $SkillID Then
			UseSkillEx($i, $Agent)
			Return
		EndIf
	Next
EndFunc   ;==>UseSkillByID

Func UseBurningSpeed()
	$lSkillbar = GetSkillbar()
	For $i = 1 To 8
		$LoopSkill = DllStructGetData($lSkillbar, 'Id' & $i)
		If $LoopSkill = $Burning_Speed Then
			UseSkill($i, -2)
			Return
		EndIf
	Next
EndFunc   ;==>UseBurningSpeed

Func DropAllBonds()
	DropBuff($Life_Attunement, -2)
	DropBuff($Balthazars_Spirit, -2)
	For $i = 1 To GetBuffCount()
		DropBuff($Protective_Bond, DllStructGetData(GetBuffByIndex($i), 'TargetId'))
	Next
EndFunc   ;==>DropAllBonds
#EndRegion Skill Funcs
#EndRegion CASTING SmartCast Functions

#Region Other Functions

; Returns agent of requested player number in party
Func GetPlayerByPlayerNumber($PlayerNumber)
	Local $lReturnArray[1] = [0]
	Local $lAgentArray = GetAgentArray(0xDB)
	For $i = 1 To $lAgentArray[0]
		If DllStructGetData($lAgentArray[$i], 'Allegiance') == 1 Then
			If BitAND(DllStructGetData($lAgentArray[$i], 'TypeMap'), 131072) Then
				If DllStructGetData($lAgentArray[$i], 'PlayerNumber') == $PlayerNumber Then
					Return $lAgentArray[$i]
				EndIf
			EndIf
		EndIf
	Next
	Return 0
EndFunc   ;==>GetPlayerByPlayerNumber

;~ Description: Returns the ID of an agent.
Func GetAgentID($aAgent)
	If IsDllStruct($aAgent) = 0 Then
		Local $lAgentID = ConvertID($aAgent)
		If $lAgentID = 0 Then Return ''
	Else
		Local $lAgentID = DllStructGetData($aAgent, 'ID')
	EndIf
	Return $lAgentID
EndFunc   ;==>GetAgentID

; Finds NPC nearest given coords and talks to him/her
Func GoToNPCNearestCoords($x, $y)
	Local $guy, $Me
	Do
		RndSleep(250)
		$guy = GetNearestNPCToCoords($x, $y)
	Until DllStructGetData($guy, 'Id') <> 0
	ChangeTarget($guy)
	RndSleep(250)
	GoNPC($guy)
	RndSleep(250)
	Do
		RndSleep(500)
		Move(DllStructGetData($guy, 'X'), DllStructGetData($guy, 'Y'), 40)
		RndSleep(500)
		GoNPC($guy)
		RndSleep(250)
		$Me = GetAgentByID(-2)
	Until ComputeDistance(DllStructGetData($Me, 'X'), DllStructGetData($Me, 'Y'), DllStructGetData($guy, 'X'), DllStructGetData($guy, 'Y')) < 250
	RndSleep(1000)
EndFunc   ;==>GoToNPCNearestCoords

; Checks if skill given (by number in bar) is recharged. Returns True if recharged, otherwise False.
;~ Use skill with death check and auto max attributes

Func CanUseSkill($aSkillSlot, $aEnergy = 0, $aSoftCounter = 0)
	If $mSkillSoftCounter > $aSoftCounter Then Return False
	If $mEnergy < $aEnergy Then Return False
	Local $lSkill = $mSkillbarCacheStruct[$aSkillSlot]
	If DllStructGetData($mSkillbar, 'Recharge' & $aSkillSlot) == 0 Then
		If DllStructGetData($mSkillbar, 'AdrenalineA' & $aSkillSlot) < DllStructGetData($lSkill, 'Adrenaline') Then Return False
		Switch DllStructGetData($lSkill, 'Type')
			Case 15, 20, 3

			Case 7, 10, 12, 16, 19, 21, 22, 26, 27, 28

			Case 14
				If $mBlind Then Return False
				If $mAttackHardCounter Then Return False
				If $mAttackSoftCounter > $aSoftCounter Then Return False
			Case 4, 5, 6, 9, 11, 24, 25
				If $mSpellSoftCounter > $aSoftCounter Then Return False
				If $mDazed Then
					If DllStructGetData($lSkill, 'Activation') > .25 Then Return False
				EndIf
				Switch DllStructGetData($lSkill, 'Target')
					Case 3, 4
						If $mAllySpellHardCounter Then Return False
					Case 5, 16
						If $mEnemySpellHardCounter Then Return False
					Case Else
				EndSwitch
		EndSwitch
		Return True
	EndIf
	Return False
EndFunc   ;==>CanUseSkill

Func CacheSkillbar()
	Local $HealSkillCounter = 0
	If Not $mSkillbarCache[0] Then
		For $i = 1 To 8
			$mSkillbarCache[$i] = DllStructGetData($mSkillbar, 'Id' & $i)
			$mSkillbarCacheStruct[$i] = GetSkillByID($mSkillbarCache[$i])

			If DllStructGetData($mSkillbarCacheStruct[$i], 'Adrenaline') > 0 Then
				$SkillAdrenalineReq[$i] = DllStructGetData($mSkillbarCacheStruct[$i], 'Adrenaline')
				$SkillAdrenalineReq[0] = True
				$mSkillbarCacheEnergyReq[$i] = 0
				WriteChat("Skill " & $i & " requires " & DllStructGetData($mSkillbarCacheStruct[$i], 'Adrenaline') & " Adrenaline.", "Skills")
			Else
				$SkillAdrenalineReq[$i] = 0
				Switch DllStructGetData($mSkillbarCacheStruct[$i], 'EnergyCost')
					Case 0
						$mSkillbarCacheEnergyReq[$i] = 0
					Case 1
						$mSkillbarCacheEnergyReq[$i] = 1
					Case 5
						$mSkillbarCacheEnergyReq[$i] = 5
					Case 10
						$mSkillbarCacheEnergyReq[$i] = 10
					Case 11
						$mSkillbarCacheEnergyReq[$i] = 15
					Case 12
						$mSkillbarCacheEnergyReq[$i] = 25
				EndSwitch

;~ 				Update("Skill " & $i & " requires " & $mSkillbarCacheEnergyReq[$i] & " energy.")
			EndIf

			$SkillDamageAmount[$i] = SkillDamageAmount($mSkillbarCacheStruct[$i])

			If IsCorpseSkill($mSkillbarCacheStruct[$i]) == True Then
				$IsCorpseSpell[$i] = True
				$IsCorpseSpell[0] = True
			EndIf
			If IsHealSkill($mSkillbarCacheStruct[$i]) And Not IsSpiritSkill($mSkillbarCacheStruct[$i]) And Not IsResSkill($mSkillbarCacheStruct[$i]) And Not IsHexRemovalSkill($mSkillbarCacheStruct[$i]) And IsConditionRemovalSkill($mSkillbarCacheStruct[$i]) == False And Not TargetOtherAllySkill($mSkillbarCacheStruct[$i]) Then
				$IsHealingSpell[$i] = True
				$IsHealingSpell[0] = True
				WriteChat("Skill " & $i & " heals ally for " & $SkillDamageAmount[$i] & ", Attribute: " & $ATTR_NAME[DllStructGetData($mSkillbarCacheStruct[$i], 'Attribute')] & ".", $mSkillbarCacheEnergyReq[$i] & " energy.")
				$HealSkillCounter += 1
			EndIf
			If TargetOtherAllySkill($mSkillbarCacheStruct[$i]) == True And IsSpeedBoost($mSkillbarCacheStruct[$i]) == False And IsResSkill($mSkillbarCacheStruct[$i]) == False And IsHexRemovalSkill($mSkillbarCacheStruct[$i]) == False And IsConditionRemovalSkill($mSkillbarCacheStruct[$i]) == False Then
				$IsHealingOtherAllySpell[$i] = True
				$IsHealingOtherAllySpell[0] = True
				WriteChat("Skill " & $i & " heals other ally for " & $SkillDamageAmount[$i] & ", Attribute: " & $ATTR_NAME[DllStructGetData($mSkillbarCacheStruct[$i], 'Attribute')] & ".", $mSkillbarCacheEnergyReq[$i] & " energy.")
				$HealSkillCounter += 1
			EndIf
			If IsSpeedBoost($mSkillbarCacheStruct[$i]) == True Then
				$IsSpeedBoostSkill[$i] = True
				$IsSpeedBoostSkill[0] = True
				WriteChat("Skill " & $i & " is other ally speed boost, Attribute: " & $ATTR_NAME[DllStructGetData($mSkillbarCacheStruct[$i], 'Attribute')] & ".", $mSkillbarCacheEnergyReq[$i] & " energy.")
				$HealSkillCounter += 1
			EndIf
			If IsSpiritSkill($mSkillbarCacheStruct[$i]) == True Then
				$IsSpiritSpell[$i] = True
				$IsSpiritSpell[0] = True
				WriteChat("Skill " & $i & " is a Spirit Skill, Attribute: " & $ATTR_NAME[DllStructGetData($mSkillbarCacheStruct[$i], 'Attribute')] & ".", $mSkillbarCacheEnergyReq[$i] & " energy.")
			EndIf
			If IsHexRemovalSkill($mSkillbarCacheStruct[$i]) == True Then
				$IsHexRemover[$i] = True
				$IsHexRemover[0] = True
				WriteChat("Skill " & $i & " is a Hex Remover, Attribute: " & $ATTR_NAME[DllStructGetData($mSkillbarCacheStruct[$i], 'Attribute')] & ".", $mSkillbarCacheEnergyReq[$i] & " energy.")
			EndIf
			If IsConditionRemovalSkill($mSkillbarCacheStruct[$i]) == True Then
				$IsConditionRemover[$i] = True
				$IsConditionRemover[0] = True
				WriteChat("Skill " & $i & " is a Condition Remover, Attribute: " & $ATTR_NAME[DllStructGetData($mSkillbarCacheStruct[$i], 'Attribute')] & ".", $mSkillbarCacheEnergyReq[$i] & " energy.")
				$HealSkillCounter += 1
			EndIf
			If SkillAOERange($mSkillbarCacheStruct[$i]) > 0 Or $mSkillbarCache[$i] == $Deaths_Charge And IsInterruptSkill($mSkillbarCacheStruct[$i]) == False Then
				If TargetEnemySkill($mSkillbarCacheStruct[$i]) == True Or TargetGroundSkill($mSkillbarCacheStruct[$i]) == True Then
					$IsAOESpell[$i] = True
					$IsAOESpell[0] = True
					WriteChat("Skill " & $i & " does AOE damage of " & $SkillDamageAmount[$i] & ", Attribute: " & $ATTR_NAME[DllStructGetData($mSkillbarCacheStruct[$i], 'Attribute')] & ".", $mSkillbarCacheEnergyReq[$i] & " energy.")
				EndIf
			EndIf
			If SkillAOERange($mSkillbarCacheStruct[$i]) <= 0 And TargetEnemySkill($mSkillbarCacheStruct[$i]) == True And IsInterruptSkill($mSkillbarCacheStruct[$i]) == False And IsHealSkill($mSkillbarCacheStruct[$i]) == False Then
				$IsGeneralAttackSpell[$i] = True
				$IsGeneralAttackSpell[0] = True
				;WriteChat("Skill " & $i & " Vs. enemies for " & $SkillDamageAmount[$i] & " damage, Attribute: " & $ATTR_NAME[DllStructGetData($mSkillbarCacheStruct[$i], 'Attribute')] & ".", $mSkillbarCacheEnergyReq[$i] & " energy.")
			EndIf
			If IsInterruptSkill($mSkillbarCacheStruct[$i]) == True Then
				$IsInterruptSpell[$i] = True
				$IsInterruptSpell[0] = True
				WriteChat("Skill " & $i & " is an Interrupt Skill, Attribute: " & $ATTR_NAME[DllStructGetData($mSkillbarCacheStruct[$i], 'Attribute')] & ".", $mSkillbarCacheEnergyReq[$i] & " energy.")
			EndIf
			If $mSkillbarCache[$i] == $You_Move_Like_a_Dwarf Then
				$IsYMLAD[$i] = True
				$IsYMLAD[0] = True
				$YMLADSlot = $i
				WriteChat("Skill " & $i & " is YMLAD!")
			EndIf
			If $mSkillbarCache[$i] == $Soul_Twisting Then
				$IsSoulTwistingSpell[$i] = True
				$IsSoulTwistingSpell[0] = True
;~ 				WriteChat("Skill " & $i & " is Soul Twisting.")
			EndIf
			If IsResSkill($mSkillbarCacheStruct[$i]) == True Then
				$IsRezSpell[$i] = True
				$IsRezSpell[0] = True
				WriteChat("Skill " & $i & " is a Rez, Attribute: " & $ATTR_NAME[DllStructGetData($mSkillbarCacheStruct[$i], 'Attribute')] & ".", $mSkillbarCacheEnergyReq[$i] & " energy.")
			EndIf
			If TargetSelfSkill($mSkillbarCacheStruct[$i]) == True And IsHealSkill($mSkillbarCacheStruct[$i]) == False And IsSpiritSkill($mSkillbarCacheStruct[$i]) == False And IsSummonSkill($mSkillbarCache[$i]) == False And $mSkillbarCache[$i] <> $Soul_Twisting Then
				$IsSelfCastingSpell[$i] = True
				$IsSelfCastingSpell[0] = True
				;WriteChat("Skill " & $i & " is a Self Targeting Skill, Attribute: " & $ATTR_NAME[DllStructGetData($mSkillbarCacheStruct[$i], 'Attribute')] & ".", $mSkillbarCacheEnergyReq[$i] & " energy.")
			EndIf
			If IsWeaponSpell($mSkillbarCache[$i]) == True Then
				$IsWeaponSpell[$i] = True
				$IsWeaponSpell[0] = True
				WriteChat("Skill " & $i & " is a Weapon Skill, Attribute: " & $ATTR_NAME[DllStructGetData($mSkillbarCacheStruct[$i], 'Attribute')] & ".", $mSkillbarCacheEnergyReq[$i] & " energy.")
			EndIf
			If IsSummonSkill($mSkillbarCache[$i]) == True Then
				$IsSummonSpell[$i] = True
				$IsSummonSpell[0] = True
				WriteChat("Skill " & $i & " is a Summon, Attribute: " & $ATTR_NAME[DllStructGetData($mSkillbarCacheStruct[$i], 'Attribute')] & ".", $mSkillbarCacheEnergyReq[$i] & " energy.")
			EndIf
			$lMyProfession = GetHeroProfession(0)
			$lAttrPrimary = GetProfPrimaryAttribute($lMyProfession)
		Next
	EndIf
	WriteChat("Load Complete.", "Skills")

	$mSkillbarCache[0] = True
EndFunc   ;==>CacheSkillbar

;~ Use rez with death check, longer timeout and checks if target is alive
Func UseRezSkillEx($aSkillSlot, $aTarget)
	$tDeadlock = TimerInit()
	ChangeTarget($aTarget)

	UseSkill($aSkillSlot, $aTarget)

	Do
		Sleep(50)
	Until GetSkillbarSkillRecharge($aSkillSlot) <> 0 Or GetIsDead(-1) == False Or TimerDiff($tDeadlock) > 7000
	If GetIsCasting() Then CancelAction()
EndFunc   ;==>UseRezSkillEx

;~ Remove hex with updated check
Func RemoveHexSkillEx($aSkillSlot, $aTarget)
	$tDeadlock = TimerInit()
	ChangeTarget($aTarget)

	UseSkill($aSkillSlot, $aTarget)

	Do
		Sleep(50)
	Until GetSkillbarSkillRecharge($aSkillSlot) <> 0 Or GetHasHex($aTarget) == False Or GetIsDead(-1) == True Or TimerDiff($tDeadlock) > 3500
	If GetIsCasting() Then CancelAction()
EndFunc   ;==>RemoveHexSkillEx

Func SleepSkillRecharge($recharge)
	Sleep($recharge)
EndFunc   ;==>SleepSkillRecharge

;~ Waits until you can reach the internet (www.google.com)
;~ $aTimeout is in milliseconds, default 0 means unlimited
Func WaitForConnectivity($aTimeout = 0)
	Local $lTimer, $lPing = 0, $Wait = 0
	If $aTimeout > 0 Then $lTimer = TimerInit()
	Do
		$lPing = Ping("www.google.com", 5000)
		If $lPing = 0 Then
			Out("Waiting for network connection")
			Sleep(2000)
			$Wait += 1
			If $Wait > 900 Then Return False
		EndIf
	Until $lPing > 0 Or ($aTimeout > 0 And TimerDiff($lTimer) > $aTimeout)
EndFunc   ;==>WaitForConnectivity

; Checks for GW disconnects

Func WaitAlive()
	Out("Waiting to Res")
	Local $lMe
	Do
		Sleep(750)
	Until GetIsDead() == False
EndFunc   ;==>WaitAlive
