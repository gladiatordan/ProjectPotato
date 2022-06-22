#NoTrayIcon
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=..\..\..\..\..\..\Black Shield Armory\AR Lower Art\Mini Mushroom.ico
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#Region About
;~ Created by lolsweg4201
;~ Updated by RiflemanX
;~ Thanks for GWA2
;~ This was tested with:
;~ 		Full Windwalker Insignias
;~ 		+4 Earth Prayers
;~ 		+1 Scythe Mastery
;~ 		+1 Mysticism
;~ 		490 Health
;~ 		25 Energy (with scythe equipped, 40 with staff)
;~		This build: OgejkmrMbSmXfbaXNXTQ3lEYsXA
;~
;~ Func HowToUseThisProgram()
;~ 		Start Guild Wars
;~ 		Log onto your dervish
;~ 		Equip a scythe in slot $WEAPON_SLOT_SCYTHE and a staff in slot $WEAPON_SLOT_STAFF Or Comment out/delete changeweaponset() in the code
;~ 		Run the bot
;~ 		If one instance of Guild Wars is open Then
;~    		Click Start
;~ 		ElseIf multiple instances of Guild Wars are open Then
;~      	Select the character you want from the dropdown menu
;~ 			Click Start
;~ 		EndIf
;~ EndFunc
#EndRegion About

#include <ButtonConstants.au3>
#include <GWA2.au3>
#include <ComboConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <ScrollBarsConstants.au3>
#include <Misc.au3>
#include <EditConstants.au3>
#include <GuiEdit.au3>

AutoItSetOption("TrayIconDebug", 1)
Opt("GUIOnEventMode", True)
Opt("GUICloseOnESC", False)


#Region Declarations
Global Const $WEAPON_SLOT_SCYTHE = 1
Global Const $WEAPON_SLOT_STAFF = 2
Global Const $Map_ID_Seitung_Harbor = 250
Global Const $Map_ID_Jaya_Bluffs = 1232
Global $TotalRuns = 0
Global $iTotalRuns = 0
Global $Runs =   0
Global $Fails =  0
Global $Drops =  0
Global $Goldz =  0
Global $Bonez =  0
Global $Crests = 0
Global $FeatherCount = 0
Global $Bone_Count =   0
Global $Crest_Count =  0
Global $Dust_Count =   0
Global $Rendering = True
Global $BotRunning = False
Global $BotInitialized = False
Global $TotalSeconds = 0
Global $Seconds = 0
Global $Minutes = 0
Global $Hours = 0
Global $MerchOpened = False
Global $HWND
Global $1Item
Global $Stolen_Supplies = 840
#EndRegion Declarations1

#Region Attributes
Global $FastCasting = 0
Global $IllusionMagic = 1
Global $DominationMagic = 2
Global $InspirationMagic = 3
Global $BloodMagic = 4
Global $DeathMagic = 5
Global $SoulReaping = 6
Global $Curses = 7
Global $AirMagic = 8
Global $EarthMagic = 9
Global $FireMagic = 10
Global $WaterMagic = 11
Global $EnergyStorage = 12
Global $HealingPrayers = 13
Global $SmitingPrayers = 14
Global $ProtectionPrayers = 15
Global $DivineFavor = 16
Global $Strength = 17
Global $AxeMastery = 18
Global $HammerMastery = 19
Global $Swordsmanship = 20
Global $Tactics = 21
Global $BeastMastery = 22
Global $Expertise = 23
Global $WildernessSurivival = 24
Global $Marksmanship = 25
Global $DaggerMastery = 29
Global $DeadlyArts = 30
Global $ShadowArts = 31
Global $Communing = 32
Global $RestorationMagic = 33
Global $ChannelingMagic = 34
Global $CriticalStrikes = 35
Global $SpawningPower = 36
Global $Spearmastery = 37
Global $Command = 38
Global $Motivation = 39
Global $Leadership = 40
Global $ScytheMastery = 41
Global $WindPrayers = 42
Global $EarthPrayers = 43
Global $Mysticism  = 44
#EndRegion Attributes

;~~ MATERIALS ~~
Global $ITEM_ID_TANNED_HIDE = 940
Global $ITEM_ID_MONSTERSEYE = 931
Global $ITEM_ID_MONSTERCLAW = 923
Global $ITEM_ID_MONSTERFANG = 932
Global $ITEM_ID_FEATHERS = 	  933
Global $ITEM_ID_IRON = 		  948
Global $ITEM_ID_DUST = 		  929
Global $ITEM_ID_GRANITE = 	  955
Global $Item_ID_WOOD = 		  946
Global $ITEM_ID_BONE = 		  921
Global $ITEM_ID_COTH =		  925
Global $ITEM_ID_FIBER = 	  934
Global $ITEM_ID_CHITIN =	  954
Global $ITEM_ID_SCALE =  	  953
Global $ITEM_ID_CRESTS =  	  835

;RARITY
Global Const $RARITY_GOLD =   2624
Global Const $RARITY_GREEN =  2627
Global Const $RARITY_PURPLE = 2626
Global Const $RARITY_BLUE =   2623
Global Const $RARITY_WHITE =  2621

#Region GUI
$Gui = GUICreate("DB Feathers", 310, 310, -1, -1)
$CharInput = GUICtrlCreateCombo("", 7, 6, 109, 25, BitOR($CBS_DROPDOWN, $CBS_AUTOHSCROLL))
GUICtrlSetData(-1, GetLoggedCharNames())
$StartButton = GUICtrlCreateButton("Start", 130, 260, 170, 35)
GUICtrlSetOnEvent(-1, "GuiButtonHandler")
$RunsLabel = GUICtrlCreateLabel("Runs:", 10, 45, 31, 17)
$RunsCount = GUICtrlCreateLabel("0", 34, 45, 75, 17, $SS_RIGHT)
$FailsLabel = GUICtrlCreateLabel("Fails:", 10, 60, 31, 17)
$FailsCount = GUICtrlCreateLabel("0", 30, 60, 79, 17, $SS_RIGHT)
GUICtrlCreateLabel("Success %:", 10, 75, 85, 15)
;GUICtrlCreateLabel("%", 82, 90, 15, 15)
GUICtrlCreateGroup("Stats", 5, 30, 109, 95, BitOr(1, $BS_CENTER))
$gui_lbl_SuccRate = GUICtrlCreateLabel("0", 82, 75, 27, 17, $SS_RIGHT)
$AvgTimeLabel = GUICtrlCreateLabel("Avg Time:", 10, 90, 100, 17)
$AvgTimeCount = GUICtrlCreateLabel("0", 71, 90, 38, 17, $SS_RIGHT)
$TotTimeLabel = GUICtrlCreateLabel("Total Time:", 10, 105, 110, 17)
$TotTimeCount = GUICtrlCreateLabel("00.00.00", 65, 105, 45, 17, $SS_RIGHT)

GUICtrlCreateGroup("Loot", 5, 135, 109, 80, BitOr(1, $BS_CENTER))
$DropsLabel   = GUICtrlCreateLabel("Feathers:",   10, 150, 76, 17)
$DropsCount   = GUICtrlCreateLabel("0",           80, 150, 27, 17, $SS_RIGHT)
$CrestsLabel  = GUICtrlCreateLabel("Crests:",     10, 165, 76, 17)
$CrestCount   = GUICtrlCreateLabel("0",           80, 165, 27, 17, $SS_RIGHT)
$BonesLabel   = GUICtrlCreateLabel("Bones:",      10, 180, 76, 17)
$BonesCount   = GUICtrlCreateLabel("0",           80, 180, 27, 17, $SS_RIGHT)
$GoldLabel    = GUICtrlCreateLabel("Gold Items:", 10, 195, 76, 17)
$GoldsCount   = GUICtrlCreateLabel("0",           80, 195, 27, 17, $SS_RIGHT)



$StatusLabel  = GUICtrlCreateEdit("", 125, 6, 178, 130, 2097220)
$PickupGolds  = GUICtrlCreateCheckbox("Pickup All Golds", 125, 145, 110, 17)
$Purge_Hook   = GUICtrlCreateCheckbox("Purge Hook", 125, 160, 80, 17)
$VersionLabel = GUICtrlCreateLabel("v2.5", 264, 150, 31, 17)

GUICtrlCreateGroup("Totals", 5, 225, 109, 80, BitOr(1, $BS_CENTER))
$Total_Feathers  = GUICtrlCreateLabel("Feathers:",  	10, 240, 76, 17)
$FeatherCount	 = GUICtrlCreateLabel("0", 		    	80, 240, 27, 17, $SS_RIGHT)
$Total_Crests 	 = GUICtrlCreateLabel("Crests:",		10, 255, 76, 17)
$Crest_Count	 = GUICtrlCreateLabel("0",			    80, 255, 27, 17, $SS_RIGHT)
$TotalBone		 = GUICtrlCreateLabel("Bones:",			10, 270, 76, 17)
$Bone_Count 	 = GUICtrlCreateLabel("0",		     	80, 270, 27, 17, $SS_RIGHT)
$Total_Dust 	 = GUICtrlCreateLabel("Dust:",			10, 285, 76, 17)
$Dust_Count	 	 = GUICtrlCreateLabel("0",			   	80, 285, 27, 17, $SS_RIGHT)

$CBX_Axes     = GUICtrlCreateCheckbox("Pick Up Axes",     125, 175, 103, 17)
$CBX_Kamas    = GUICtrlCreateCheckbox("Pick Up Kamas",    125, 190, 103, 17)
$CBX_Swords   = GUICtrlCreateCheckbox("Pick Up Swords",   125, 205, 103, 17)
$CBX_RareMats = GUICtrlCreateCheckbox("Pick Up Rare Mats",125, 220, 110, 17)

GUICtrlSetState($CBX_RareMats, $GUI_CHECKED)
GUICtrlSetState($Purge_Hook, $GUI_CHECKED)

$RenderingBox = GUICtrlCreateCheckbox("Disable Rendering", 125, 235, 103, 17)
GUICtrlSetOnEvent(-1, "ToggleRendering")
GUICtrlSetState($RenderingBox, $GUI_DISABLE)
GUISetOnEvent($GUI_EVENT_CLOSE, "_exit")
GUISetState(@SW_SHOW)
#EndRegion GUI

#Region Loops
Out("Derv Feather Farmer")
Out("Version 2.4")
While Not $BotRunning
   Sleep(100)
WEnd

AdlibRegister("TimeUpdater", 1000)
Setup()

While 1
   If Not $BotRunning Then
	  AdlibUnRegister("TimeUpdater")
	  Out("Bot is paused.")
	  GUICtrlSetState($StartButton, $GUI_ENABLE)
	  GUICtrlSetData($StartButton, "Start")
	  GUICtrlSetOnEvent($StartButton, "GuiButtonHandler")
	  While Not $BotRunning
		 Sleep(500)
	  WEnd
	  AdlibRegister("TimeUpdater", 1000)
   EndIf
   MainLoop()
WEnd
#EndRegion Loops

#Region Functions
Func GuiButtonHandler()
   If $BotRunning Then
	  Out("Will pause after this run.")
	  GUICtrlSetData($StartButton, "force pause NOW")
	  GUICtrlSetOnEvent($StartButton, "Resign")
	  ;GUICtrlSetState($StartButton, $GUI_DISABLE)
	  $BotRunning = False
   ElseIf $BotInitialized Then
	  GUICtrlSetData($StartButton, "Pause")
	  $BotRunning = True
   Else
	  Out("Initializing...")
	  Local $CharName = GUICtrlRead($CharInput)
	  If $CharName == "" Then
		 If Initialize(ProcessExists("gw.exe"), True, True) = False Then
			   MsgBox(0, "Error", "Guild Wars is not running.")
			   Exit
		 EndIf
	  Else
		 If Initialize($CharName, True, True) = False Then
			   MsgBox(0, "Error", "Could not find a Guild Wars client with a character named '" & $CharName & "'")
			   Exit
		 EndIf
	  EndIf
	  $HWND = GetWindowHandle()
	  GUICtrlSetState($RenderingBox, $GUI_ENABLE)
	  GUICtrlSetState($CharInput, $GUI_DISABLE)
	  Local $charname = GetCharname()
	  GUICtrlSetData($CharInput, $charname, $charname)
	  GUICtrlSetData($StartButton, "Pause")
	  GUICtrlSetData($FeatherCount, GetItemCount($ITEM_ID_FEATHERS))
	  GUICtrlSetData($Crest_Count, GetItemCount($ITEM_ID_CRESTS))
	  GUICtrlSetData($Bone_Count, GetItemCount($ITEM_ID_BONE))
	  GUICtrlSetData($Dust_Count, GetItemCount($ITEM_ID_DUST))
	  WinSetTitle($Gui, "", "Derv Feather Farmer")
	  $BotRunning = True
	  $BotInitialized = True
	  SetMaxMemory()
   EndIf
EndFunc

Func Setup()
   If GetMapID() <> 250 Then
	  Out("Travelling to Seitung.")
	  RndTravel(250)
   EndIf
   ; Out("Loading skillbar.")
   ; LoadSkillTemplate("OgejkmrMbSmXfbaXNXTQ3l7XsXA") ;NEED
   LeaveGroup()
   SwitchMode(0)
   ChangeWeaponSet($WEAPON_SLOT_STAFF)
   Sleep(GetPing())
   ; SetUpFastWay()
   PrepResignFeather()
EndFunc

Func SetUpFastWay()
	Out("Setting up resign")
	Zone()
	Move(10970, -13360)
	WaitMapLoading(250)
	RndSleep(500)
	Return True
EndFunc

Func MainLoop()
	GUICtrlSetData($FeatherCount, GetItemCount($ITEM_ID_FEATHERS))
	GUICtrlSetData($Crest_Count, GetItemCount($ITEM_ID_CRESTS))
	GUICtrlSetData($Bone_Count, GetItemCount($ITEM_ID_BONE))
	GUICtrlSetData($Dust_Count, GetItemCount($ITEM_ID_DUST))
   ;$MapTimer1 = TimerInit
   If GetMapID() == 250 Then
	  ChangeWeaponSet($WEAPON_SLOT_STAFF)
	  Zone_Fast_Way()
   Else
	  Setup()
	  Zone_Fast_Way()
   EndIf

   Out("Running to Sensali")
   If GetChecked($Purge_Hook) Then 
   	PurgeHook()
   EndIf
   Sleep(500)

  ; If GetChecked ($Purge_Hook) Then
	;   EnableRendering()
	 ;  PingSleep(500)
	  ; DisableRendering()
	   ;PingSleep(500)
   ;EndIf

   Sleep(500)
   MoveRun(7588, -10609)
   Out("CP-1")
   MoveRun(4178, -11010)
   Out("CP-2")
   MoveRun(4178, -11010)   ;<-------------Possible stuck Point, Solution:  (001354.349121, -07128.300781)
   Out("CP-3")

   MoveRun(3499, -9734)
   Out("CP-4")

   MoveRun(2849, -9784)
   Out("CP-5")

   MoveRun(1706, -6820)
   Out("CP-5")                ;<----------------Should  resolve stuck points, testing ongoing
   ;MoveRun(1106, -6926) stuck position

   MoveRun(-472, -4342)
   Out("CP-6")
   Out("Farming Sensali.")
  ; If TimerDiff($MapTimer1) > (120000) Then
	;   Out("Times up!")
	 ;  Return
  ; EndIf
   MoveKill(-1536, -1686)
   MoveKill(586, -76)
   MoveKill(-1556, 2786)
   MoveKill(-2229, -815)
   MoveKill(-5247, -3290)
   MoveKill(-6994, -2273)
   MoveKill(-5042, -6638)
   MoveKill(-11040, -8577)
   MoveKill(-10232, -3820)
   If GetChecked ($Purge_Hook) Then
		PurgeHook()
   EndIf
   ; If TimerDiff($MapTimer1) > (600000) Then
	   ;Out("Times up!")
	   ;Return
   ;EndIf
   $iTotalRuns += 1
   If GetIsDead(-2) Then
	  $Fails += 1
	  Out("I'm dead.")
	  GUICtrlSetData($FailsCount,$Fails)
   Else
	  $iTotalRunz = ($Runs + $Fails)
	  $Runs += 1
	  Out("Completed in " & GetTime() & ".")
	  GUICtrlSetData($RunsCount,$Runs)
	  GUICtrlSetData($AvgTimeCount,AvgTime())
	  GUICtrlSetData($gui_lbl_SuccRate, Round($Runs / $iTotalRuns * 100, 2))
	  ;GUICtrlSetData($gui_lbl_SuccRate, Round($RunsCount / $TotalRuns, 2))
   EndIf
   If GUICtrlRead($RenderingBox) == $GUI_CHECKED Then ClearMemory()
   Out("Returning to Seitung.")
   ;RndTravel(250)
      ;If GetItemCountByID(835) >= 50 Then
	  ;Out("Salvaging crests.")
	  ;SalvageStuff()
	  ;GUICtrlSetData($DropsCount,GetItemCountByID(933))
   ;EndIf
   Resign()
   RndSleep(5000)
   ReturnToOutpost()
   WaitMapLoading(250)
   RndSleep(500)
EndFunc

Func Zone_Fast_Way()
   Out("Zoning.")
   Move(16690, 17630)
   WaitMapLoading(196)
   RndSleep(500)
   Return True
EndFunc

Func Zone()
   If GetMapLoading() == 2 Then Disconnected()
   Local $Me = GetAgentByID(-2)
   Local $X = DllStructGetData($Me, 'X')
   Local $Y = DllStructGetData($Me, 'Y')
   If ComputeDistance($X, $Y, 18383, 11202) < 750 Then
	  MoveTo(18127, 11740)
	  MoveTo(19196, 13149)
	  MoveTo(17288, 17243)
	  Move(16800, 17550)
	  WaitMapLoading(196)
	  Return
   EndIf
   If ComputeDistance($X, $Y, 18786, 9415) < 750 Then
	  MoveTo(20556, 11582)
	  MoveTo(19196, 13149)
	  MoveTo(17288, 17243)
	  Move(16800, 17550)
	  WaitMapLoading(196)
	  Return
   EndIf
   If ComputeDistance($X, $Y, 16669, 11862) < 750 Then
	  MoveTo(17912, 13531)
	  MoveTo(19196, 13149)
	  MoveTo(17288, 17243)
	  Move(16800, 17550)
	  WaitMapLoading(196)
	  Return
   EndIf
   MoveTo(19196, 13149)
   MoveTo(17288, 17243)
   Move(16800, 17550)
   WaitMapLoading(196)
EndFunc

Func MoveRun($DestX, $DestY)
   If GetMapLoading() == 2 Then Disconnected()
   If GetIsDead(-2) Then Return
   StuckTimer()
   Local $Me
   Move($DestX, $DestY)
   Do
	  If GetMapLoading() == 2 Then Disconnected()
	  If IsRecharged(6) Then UseSkillEx(6)
	  If IsRecharged(5) Then UseSkillEx(5)
	  $Me = GetAgentByID(-2)
	  If DllStructGetData($Me, "HP") < 0.95 Then
		 If GetEffectTimeRemaining(1516) <= 0 Then UseSkillEx(8)
	  EndIf
	  If GetIsDead(-2) Then Return
	  If DllStructGetData($Me, 'MoveX') == 0 Or DllStructGetData($Me, 'MoveY') == 0 Then Move($DestX, $DestY)
	  RndSleep(250)
   Until ComputeDistance(DllStructGetData($Me, 'X'), DllStructGetData($Me, 'Y'), $DestX, $DestY) < 250
EndFunc

Func MoveKill($DestX, $DestY)
   If GetMapLoading() == 2 Then Disconnected()
   If GetIsDead(-2) Then Return
   Local $Me, $Angle
   Local $Blocked = 0
   Move($DestX, $DestY)
   Do
	  If GetMapLoading() == 2 Then Disconnected()
	  SendChat('stuck', '/')
	  If IsRecharged(6) Then UseSkillEx(6)
	  If IsRecharged(5) Then UseSkillEx(5)
	  If DllStructGetData($Me, "HP") < 0.95 Then
		 If GetEffectTimeRemaining(1516) <= 0 Then UseSkillEx(8)
		 If GetEffectTimeRemaining(1540) <= 0 Then UseSkillEx(7)
	  EndIf
	  TargetNearestEnemy()
	  $Me = GetAgentByID(-2)
	  If GetIsDead(-2) Then Return
	  If GetNumberOfFoesInRangeOfAgent(-2, 1200) > 1 Then Kill()
	  If DllStructGetData($Me, 'MoveX') == 0 Or DllStructGetData($Me, 'MoveY') == 0 Then
		 $Blocked += 1
		 If $Blocked <= 5 Then
			Move($DestX, $DestY)
		 Else
			$Me = GetAgentByID(-2)
			$Angle += 40
			Move(DllStructGetData($Me, 'X')+300*sin($Angle), DllStructGetData($Me, 'Y')+300*cos($Angle))
			Sleep(2000)
			Move($DestX, $DestY)
		 EndIf
	  EndIF
	  RndSleep(250)
   Until ComputeDistance(DllStructGetData($Me, 'X'), DllStructGetData($Me, 'Y'), $DestX, $DestY) < 250
EndFunc

Func Kill()
   ChangeWeaponSet($WEAPON_SLOT_SCYTHE)
   If GetMapLoading() == 2 Then Disconnected()
   If GetIsDead(-2) Then Return
   If GetEffectTimeRemaining(1516) <= 0 Then UseSkillEx(8,-2)
   If GetEffectTimeRemaining(1540) <= 0 Then UseSkillEx(7,-2)
   If GetEffectTimeRemaining(1510) <= 0 Then UseSkillEx(1,-2)
   TargetNearestEnemy()
   WaitForSettle(800, 210)
   If IsRecharged(2) Then UseSkillEx(2,-2)
   If GetEnergy(-2) >= 10 Then
	  UseSkillEx(3,-2)
	  UseSkillEx(4,-1)
   EndIf
   While GetNumberOfFoesInRangeOfAgent(-2,900) > 0
	  If GetMapLoading() == 2 Then Disconnected()
	  If GetIsDead(-2) Then Return
	  TargetNearestEnemy()
	  If GetEffectTimeRemaining(1516) <= 0 Then UseSkillEx(8,-2)
	  If GetEffectTimeRemaining(1540) <= 0 Then UseSkillEx(7,-2)
	  If GetEffectTimeRemaining(1510) <= 0 And GetNumberOfFoesInRangeOfAgent(-2,300) > 1 Then UseSkillEx(1,-2)
	  If GetEffectTimeRemaining(1759) <= 0 Then UseSkillEx(2,-2)
	  Sleep(100)
	  Attack(-1)
   WEnd
   RndSleep(200)
   ChangeWeaponSet($WEAPON_SLOT_STAFF)
   PickUpLoot()
   EndFunc

Func WaitForSettle($FarRange,$CloseRange,$Timeout = 10000)
   If GetMapLoading() == 2 Then Disconnected()
   Local $Target
   Local $Deadlock = TimerInit()
   SendChat('stuck', '/')
   Do
	  If GetMapLoading() == 2 Then Disconnected()
	  If GetIsDead(-2) Then Return
	  If DllStructGetData(GetAgentByID(-2), "HP") < 0.4 Then Return
	  If GetEffectTimeRemaining(1516) <= 0 Then UseSkillEx(8,-2)
	  If GetEffectTimeRemaining(1540) <= 0 Then UseSkillEx(7,-2)
	  If GetEffectTimeRemaining(1510) <= 0 Then UseSkillEx(1,-2)
	  Sleep(50)
	  $Target = GetFarthestEnemyToAgent(-2,$FarRange)
   Until GetNumberOfFoesInRangeOfAgent(-2,900) > 0 Or (TimerDiff($Deadlock) > $Timeout)
   Local $Deadlock = TimerInit()
   Do
	  If GetMapLoading() == 2 Then Disconnected()
	  If GetIsDead(-2) Then Return
	  If DllStructGetData(GetAgentByID(-2), "HP") < 0.4 Then Return
	  If GetEffectTimeRemaining(1516) <= 0 Then UseSkillEx(8,-2)
	  If GetEffectTimeRemaining(1540) <= 0 Then UseSkillEx(7,-2)
	  If GetEffectTimeRemaining(1510) <= 0 Then UseSkillEx(1,-2)
	  Sleep(50)
	  $Target = GetFarthestEnemyToAgent(-2,$FarRange)
   Until (GetDistance(-2, $Target) < $CloseRange) Or (TimerDiff($Deadlock) > $Timeout)
EndFunc

Func GetFarthestEnemyToAgent($aAgent = -2, $aDistance = 1250)
   If GetMapLoading() == 2 Then Disconnected()
   Local $lFarthestAgent, $lFarthestDistance = 0
   Local $lDistance, $lAgent, $lAgentArray = GetAgentArray(0xDB)
   If Not IsDllStruct($aAgent) Then $aAgent = GetAgentByID($aAgent)
   For $i = 1 To $lAgentArray[0]
	  $lAgent = $lAgentArray[$i]
	  If BitAND(DllStructGetData($lAgent, 'typemap'), 262144) Then ContinueLoop
	  If DllStructGetData($lAgent, 'Allegiance') <> 3 Then ContinueLoop
	  If DllStructGetData($lAgent, 'HP') <= 0 Then ContinueLoop
	  If BitAND(DllStructGetData($lAgent, 'Effects'), 0x0010) > 0 Then ContinueLoop
	  $lDistance = GetDistance($lAgent)
	  If $lDistance > $lFarthestDistance And $lDistance < $aDistance Then
		 $lFarthestAgent = $lAgent
		 $lFarthestDistance = $lDistance
	  EndIf
   Next
   Return $lFarthestAgent
EndFunc


;Located in GWA2

; Func GetNumberOfFoesInRangeOfAgent($aAgent = -2, $aRange = 1250)
;    If GetMapLoading() == 2 Then Disconnected()
;    Local $lAgent, $lDistance
;    Local $lCount = 0, $lAgentArray = GetAgentArray(0xDB)
;    If Not IsDllStruct($aAgent) Then $aAgent = GetAgentByID($aAgent)
;    For $i = 1 To $lAgentArray[0]
; 	  $lAgent = $lAgentArray[$i]
; 	  If BitAND(DllStructGetData($lAgent, 'typemap'), 262144) Then ContinueLoop
; 	  If DllStructGetData($lAgent, 'Allegiance') <> 3 Then ContinueLoop
; 	  If DllStructGetData($lAgent, 'HP') <= 0 Then ContinueLoop
; 	  If BitAND(DllStructGetData($lAgent, 'Effects'), 0x0010) > 0 Then ContinueLoop
; 	  If StringLeft(GetAgentName($lAgent), 7) <> "Sensali" Then ContinueLoop
; 	  $lDistance = GetDistance($lAgent)
; 	  If $lDistance > $aRange Then ContinueLoop
; 	  $lCount += 1
;    Next
;    Return $lCount
; EndFunc


Func GetItemCountByID($ID)
   If GetMapLoading() == 2 Then Disconnected()
   Local $Item
   Local $Quantity = 0
   For $Bag = 1 to 4
	  For $Slot = 1 to DllStructGetData(GetBag($Bag), 'Slots')
		 $Item = GetItemBySlot($Bag,$Slot)
		 If DllStructGetData($Item,'ModelID') = $ID Then
			$Quantity += DllStructGetData($Item, 'Quantity')
		 EndIf
	  Next
   Next
   Return $Quantity
EndFunc

;Located in GWA2

Func PickUpLoot()
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
			If $lBlockedCount > 2 Then UseSkillEx(6,-2)
			PickUpItem($lItem)
			Sleep(GetPing())
			Do
			   Sleep(100)
			   $lMe = GetAgentByID(-2)
			Until DllStructGetData($lMe, 'MoveX') == 0 And DllStructGetData($lMe, 'MoveY') == 0
			$lBlockedTimer = TimerInit()
			Do
			   Sleep(250)
			   $lItemExists = IsDllStruct(GetAgentByID($i))
			Until Not $lItemExists Or TimerDiff($lBlockedTimer) > Random(5000, 7500, 1)
			If $lItemExists Then $lBlockedCount += 1
		 Until Not $lItemExists Or $lBlockedCount > 5
	  EndIf
   Next
EndFunc


Func CanPickUp($lItem)
   If GetMapLoading() == 2 Then Disconnected()
   Local $rarity = GetRarity($lItem)
   Local $Quantity
   Local $ModelID = DllStructGetData($lItem, 'ModelID')
   Local $ExtraID = DllStructGetData($lItem, 'ExtraID')
   If $ModelID = 146 And ($ExtraID = 10 Or $ExtraID = 12) Then Return True
   If $ModelID = 931 Or $ModelID = 932 Then	;931=Monstrous Eye	;932=Monstrous Fang
	  Return True
   EndIf
      If $ModelID = 923 Then	;931=Monstrous Claw
	  Return True
   EndIf

Global $ITEM_ID_MONSTERSEYE = 931
Global $ITEM_ID_MONSTERCLAW = 923
Global $ITEM_ID_MONSTERFANG = 932
Global $Kamas = 763


; Rare Shields
   ; If $Rarity = $RARITY_GOLD         Then Return True
   ; If IsQ8MaxItem($lItem)			 Then Return True
   ; If IsQArmourShield($lItem, 8, 16) Then Return True
   ; If IsQArmourShield($lItem, 7, 15) Then Return True
   ; If IsQArmourShield($lItem, 6, 14) Then Return True
   ; If IsQArmourShield($lItem, 5, 13) Then Return True
   If $Rarity == $RARITY_GREEN		 Then Return False
   If $Rarity == $RARITY_PURPLE 	 Then Return False
   If $Rarity == $RARITY_BLUE 		 Then Return False


	If GuiCtrlRead($CBX_RareMats) and $ModelID = 923 Then  ;Monster Claw
		Out("Found Monster Claw!")
		Return True
	EndIf

	If GuiCtrlRead($CBX_RareMats) and $ModelID = 931 Then ;Monster Eye
		Out("Found Monster Eye!")
		Return True
	EndIf

	If GuiCtrlRead($CBX_RareMats) and $ModelID = 932 Then ;Monster Fang
		Out("Found Monster Fang!")
		Return True
	EndIf

	;If GetChecked ($CBX_Kamas) and $ModelID = 762 Then
		;Return True
	;EndIf


	If GuiCtrlRead($CBX_Kamas) = $GUI_CHECKED And $rarity = 2624 and $ModelID = 762 Then ;762 = Kamas
	 Out("Picking up Gold Kamas")
	 $Goldz += DllStructGetData($lItem, 'Quantity')
	 GUICtrlSetData($GoldsCount,$Goldz)
	 Return True
   EndIf

#CS
	;If GetChecked ($CBX_Swords) and $ModelID = 797 Then ;797 = Sunqua Swords,
		;Return True
	;EndIf

	If GuiCtrlRead($CBX_Swords) = $GUI_CHECKED And $rarity = 2624 and $ModelID = 762 Then ;797 = Swords
	 Out("Picking up Gold Sword")
	 $Goldz += DllStructGetData($lItem, 'Quantity')
	 GUICtrlSetData($GoldsCount,$Goldz)
	 Return True
   EndIf

	;If GetChecked ($CBX_Axes) and $ModelID = 121 or 122 or 699 or 701 or 707 Then ;121 = Axe Basic), 122 = Cleaver(Basic), 699 = Cleaver(Cool Skin), 701 = Gemstone Axe, 707 = Sickle
		;Return True
	;EndIf

	If GuiCtrlRead($CBX_Axes) = $GUI_CHECKED And $rarity = 2624 and $ModelID = 121 or 122 or 699 or 701 or 707 Then ;797 = Axes
	 Out("Picking up Gold Axe")
	 $Goldz += DllStructGetData($lItem, 'Quantity')
	 GUICtrlSetData($GoldsCount,$Goldz)
	 Return True
    EndIf
#CE

   If $ModelID = 835 Then ;Feather Crests
	  Out("Picking up Feather Crests")
	  $Crests += DllStructGetData($lItem, 'Quantity')
	  GUICtrlSetData($CrestCount,$Crests)
	  Return True
   EndIf
   If $ModelID = 933 Then ;Feathers
	  Out("Picking up Feathers")
	  $Drops += DllStructGetData($lItem, 'Quantity')
	  GUICtrlSetData($DropsCount,$Drops)
	  Return True
   EndIf
   If $ModelID = 921 Then ;Or $ModelID = 28434 Then Return True	;921 = Bones
	 Out("Picking up Bones")
     $Bonez += DllStructGetData($lItem, 'Quantity')
	 GUICtrlSetData($BonesCount,$Bonez)
	 Return True
   EndIf

   If $ModelID = 22752 Then Return True	;22752 = Golden Eggs
   If $ModelID = 22644 Then Return True	;22644 = Chocolate Bunny
   If $ModelID = 22751 Then Return True	;22751 = Lockpicks
   If $ModelID = 30855 Then Return True	;30855 = Grog
   If $ModelID = 840 Then Return True	;840 = Stolen Supplies for Nicholas The Traveler
   If $ModelID == 2511 And GetGoldCharacter() < 99000 Then Return True	;2511 = Gold Coins
   If CountFreeSlots() < 4 Then Return False

   If GuiCtrlRead($PickupGolds) = $GUI_CHECKED And $rarity = 2624 Then ;2624 = Pick Up Golds if checked
	 $Goldz += DllStructGetData($lItem, 'Quantity')
	 GUICtrlSetData($GoldsCount,$Goldz)
	 Return True
   EndIf

   ;If $rarity == 2624 Then Return True	;2624 = golden Items
  ; If $rarity == 2623 Or $rarity == 2626 Then	;2623 = blue Items	;2626 = purple Items
	;  If $ModelID == 921 Or $ModelID == 921 Or $ModelID == 921 Then Return True	;sensali Armor	;sensali Crestguard
  ; EndIf
   ;Return False
EndFunc

Func SalvageStuff()
   If GetMapLoading() == 2 Then Disconnected()
   $MerchOpened = False
   Local $Item
   Local $Quantity
   For $Bag = 1 To 4
	  If GetMapLoading() == 2 Then Disconnected()
	  For $Slot = 1 To DllStructGetData(GetBag($Bag), 'Slots')
		 If GetMapLoading() == 2 Then Disconnected()
		 $Item = GetItemBySlot($Bag, $Slot)
		 If CanSalvage($Item) Then
			$Quantity = DllStructGetData($Item, 'Quantity')
			For $i = 1 To $Quantity
			   If GetMapLoading() == 2 Then Disconnected()
			   If FindCheapSalvageKit() = 0 Then BuySalvageKit()
			   StartSalvage1($Item, True)
			   Do
				  Sleep(10)
			   Until DllStructGetData(GetItemBySlot($Bag, $Slot), 'Quantity') = $Quantity - $i
			   $Item = GetItemBySlot($Bag, $Slot)
			Next
		 EndIf
	  Next
   Next
EndFunc

Func StartSalvage1($aItem, $aCheap = false)
   If GetMapLoading() == 2 Then Disconnected()
   Local $lOffset[4] = [0, 0x18, 0x2C, 0x62C]
   Local $lSalvageSessionID = MemoryReadPtr($mBasePointer, $lOffset)
   If IsDllStruct($aItem) = 0 Then
	  Local $lItemID = $aItem
   Else
	  Local $lItemID = DllStructGetData($aItem, 'ID')
   EndIf
   If $aCheap Then
	  Local $lSalvageKit = FindCheapSalvageKit()
   Else
	  Local $lSalvageKit = FindSalvageKit()
   EndIf
   If $lSalvageKit = 0 Then Return
   DllStructSetData($mSalvage, 2, $lItemID)
   DllStructSetData($mSalvage, 3, $lSalvageKit)
   DllStructSetData($mSalvage, 4, $lSalvageSessionID[1])
   Enqueue($mSalvagePtr, 16)
EndFunc

Func CanSalvage($Item)
   If DllStructGetData($Item, 'ModelID') == 835 Then Return True
   Return False
EndFunc

Func FindCheapSalvageKit()
   If GetMapLoading() == 2 Then Disconnected()
   Local $Item
   Local $Kit = 0
   Local $Uses = 101
   For $Bag = 1 To 16
	  For $Slot = 1 To DllStructGetData(GetBag($Bag), 'Slots')
		 $Item = GetItemBySlot($Bag, $Slot)
		 Switch DllStructGetData($Item, 'ModelID')
			Case 2992
			   If DllStructGetData($Item, 'Value')/2 < $Uses Then
				  $Kit = DllStructGetData($Item, 'ID')
				  $Uses = DllStructGetData($Item, 'Value')/8
			   EndIf
			Case Else
			   ContinueLoop
		 EndSwitch
	  Next
   Next
   Return $Kit
EndFunc

;In GWA2

Func BuySalvageKit()
   WithdrawGold(100)
   GoToMerch()
   RndSleep(500)
   BuyItem(2, 1, 100)
   Sleep(1500)
   If FindCheapSalvageKit() = 0 Then BuySalvageKit()
EndFunc


Func GoToMerch()
   If GetMapLoading() == 2 Then Disconnected()
   If $MerchOpened = False Then
	  Local $Me = GetAgentByID(-2)
	  Local $X = DllStructGetData($Me, 'X')
	  Local $Y = DllStructGetData($Me, 'Y')
	  If ComputeDistance($X, $Y, 18383, 11202) < 750 Then
		 MoveTo(17715, 11773)
		 MoveTo(17174, 12403)
	  EndIf
	  If ComputeDistance($X, $Y, 18786, 9415) < 750 Then
		 MoveTo(17684, 10568)
		 MoveTo(17174, 12403)
	  EndIf
	  If ComputeDistance($X, $Y, 16669, 11862) < 750 Then
		 MoveTo(17174, 12403)
	  EndIf
	  TargetNearestAlly()
	  ActionInteract()
	  $MerchOpened = True
   EndIf
EndFunc

Func GetTime()
   Local $Time = GetInstanceUpTime()
   Local $Seconds = Floor($Time/1000)
   Local $Minutes = Floor($Seconds/60)
   Local $Hours = Floor($Minutes/60)
   Local $Second = $Seconds - $Minutes*60
   Local $Minute = $Minutes - $Hours*60
   If $Hours = 0 Then
	  If $Second < 10 Then $InstTime = $Minute&':0'&$Second
	  If $Second >= 10 Then $InstTime = $Minute&':'&$Second
   ElseIf $Hours <> 0 Then
	  If $Minutes < 10 Then
		 If $Second < 10 Then $InstTime = $Hours&':0'&$Minute&':0'&$Second
		 If $Second >= 10 Then $InstTime = $Hours&':0'&$Minute&':'&$Second
	  ElseIf $Minutes >= 10 Then
		 If $Second < 10 Then $InstTime = $Hours&':'&$Minute&':0'&$Second
		 If $Second >= 10 Then $InstTime = $Hours&':'&$Minute&':'&$Second
	  EndIf
   EndIf
   Return $InstTime
EndFunc

Func AvgTime()
   Local $Time = GetInstanceUpTime()
   Local $Seconds = Floor($Time/1000)
   $TotalSeconds += $Seconds
   Local $AvgSeconds = Floor($TotalSeconds/$Runs)
   Local $Minutes = Floor($AvgSeconds/60)
   Local $Hours = Floor($Minutes/60)
   Local $Second = $AvgSeconds - $Minutes*60
   Local $Minute = $Minutes - $Hours*60
   If $Hours = 0 Then
	  If $Second < 10 Then $AvgTime = $Minute&':0'&$Second
	  If $Second >= 10 Then $AvgTime = $Minute&':'&$Second
   ElseIf $Hours <> 0 Then
	  If $Minutes < 10 Then
		 If $Second < 10 Then $AvgTime = $Hours&':0'&$Minute&':0'&$Second
		 If $Second >= 10 Then $AvgTime = $Hours&':0'&$Minute&':'&$Second
	  ElseIf $Minutes >= 10 Then
		 If $Second < 10 Then $AvgTime = $Hours&':'&$Minute&':0'&$Second
		 If $Second >= 10 Then $AvgTime = $Hours&':'&$Minute&':'&$Second
	  EndIf
   EndIf
   Return $AvgTime
EndFunc

Func TimeUpdater()
	$Seconds += 1
	If $Seconds = 60 Then
		$Minutes += 1
		$Seconds = $Seconds - 60
	EndIf
	If $Minutes = 60 Then
		$Hours += 1
		$Minutes = $Minutes - 60
	EndIf
	If $Seconds < 10 Then
		$L_Sec = "0" & $Seconds
	Else
		$L_Sec = $Seconds
	EndIf
	If $Minutes < 10 Then
		$L_Min = "0" & $Minutes
	Else
		$L_Min = $Minutes
	EndIf
	If $Hours < 10 Then
		$L_Hour = "0" & $Hours
	Else
		$L_Hour = $Hours
	EndIf
	GUICtrlSetData($TotTimeCount, $L_Hour & ":" & $L_Min & ":" & $L_Sec)
EndFunc

Func Out($msg)
   GUICtrlSetData($StatusLabel, GUICtrlRead($StatusLabel) & $msg & @CRLF)
   _GUICtrlEdit_Scroll($StatusLabel, $SB_SCROLLCARET)
   _GUICtrlEdit_Scroll($StatusLabel, $SB_LINEUP)
EndFunc

Func Out2($msg) ;Original with timestamp
   GUICtrlSetData($StatusLabel, GUICtrlRead($StatusLabel) & "[" & @HOUR & ":" & @MIN & "]" & " " & $msg & @CRLF)
   _GUICtrlEdit_Scroll($StatusLabel, $SB_SCROLLCARET)
   _GUICtrlEdit_Scroll($StatusLabel, $SB_LINEUP)
EndFunc

Func _exit()
   If GUICtrlRead($RenderingBox) == $GUI_CHECKED Then
	  EnableRendering()
	  WinSetState($HWND, "", @SW_SHOW)
	  Sleep(500)
   EndIf
   Exit
EndFunc

Func Checkmap()
	If GetMapID() <> $Map_ID_Seitung_Harbor Then
		PingSleep(200)
		RndTravel($Map_ID_Seitung_Harbor)
		WaitMapLoading($Map_ID_Seitung_Harbor)
		PingSleep(50)
	EndIf
EndFunc

Func PingSleep($msExtra = 0)
	$ping = GetPing()
	Sleep($ping + $msExtra)
EndFunc   ;==>PingSleep

Func MoveAway($start,$target)
	$xdiff = DllStructGetData($start,"X")-DllStructGetData($target,"X")
	$ydiff = DllStructGetData($start,"Y")-DllStructGetData($target,"Y")
	MoveTo(DllStructGetData($start,"X")+Random()*$xdiff,DllStructGetData($start,"Y")+Random()*$ydiff)
EndFunc

Func StuckTimer()
   Local $MapTimer1 = TimerInit
   If $MapTimer1 > 10000 Then Return   ;10 second test
   ;Out("Map Timer Initialized") ;Timer set to restart farm if longer than 10 min
   ;Out("Set to restart in 20s")
   ;Out("Timer Test")

   ;$MapTimer2 = TimerDiff($MapTimer1)
   ;If $MapTimer2 > 30000 Then Return  ;20 second test
	   ;Out("Greater Than 30s")
   ;EndIf
EndFunc

Func GetChecked($GUICtrl)
	Return (GUICtrlRead($GUICtrl)==$GUI_Checked)
EndFunc

;Located in GWA2
#CS
Func ToggleRendering()
   If GUICtrlRead($RenderingBox) == $GUI_UNCHECKED Then
	  EnableRendering()
	  WinSetState($HWND, "", @SW_SHOW)
   Else
	  DisableRendering()
	  WinSetState($HWND, "", @SW_HIDE)
   EndIf
   Return True
EndFunc
#CE

Func PurgeHook()
	Out("Purging Engine Hook")
	Sleep(Random(2000, 2500))
	ToggleRendering()
	Sleep(Random(2000, 2500))
	ClearMemory()
	Sleep(Random(2000, 2500))
	ToggleRendering()
EndFunc

Func PurgeHook2()
	Out("Purging Engine Hook")
	ToggleRendering()
	Sleep(Random(2000,2500))
	ToggleRendering()
EndFunc   ;==>_PurgeHook

;~ Description: Toggle rendering and also hide or show the gw window
Func ToggleRendering2()
	If $RenderingEnabled Then
		DisableRendering()
		WinSetState(GetWindowHandle(), "", @SW_HIDE)
		$RenderingEnabled = False
	Else
		EnableRendering()
		WinSetState(GetWindowHandle(), "", @SW_SHOW)
		$RenderingEnabled = True
	EndIf
EndFunc   ;==>ToggleRendering

Func ToggleRendering3()
	$RenderingEnabled = Not $RenderingEnabled
	If $RenderingEnabled Then
		EnableRendering()
		WinSetState(GetWindowHandle(), "", @SW_SHOW)
	Else
		DisableRendering()
		WinSetState(GetWindowHandle(), "", @SW_HIDE)
		ClearMemory()
	EndIf
EndFunc   ;==>ToggleRendering

;Located in GWA2
;Func _PurgeHook()
	;ToggleRendering3()
	;Sleep(Random(2000,2500))
	;ToggleRendering3()
;EndFunc   ;==>_PurgeHook

Func GetItemCount($iModelID, $iMaxBag = 16)  ;<--------SET TO COUNT INVENTORY CHEST ALSO.  CHANGE TO "1 TO 4" TO COUNT ONLY PERSONAL INVENTORY.
	Local $iItemCount
	local $aBag, $aItem

	For $i = 1 To $iMaxBag
		$aBag = GetBag($i)
		For $j = 1 To DllStructGetData($aBag, "Slots")
			$aItem = GetItemBySlot($aBag, $j)
			If DllStructGetData($aItem, "ModelID") = $iModelID Then
				$iItemCount += DllStructGetData($aItem, "Quantity")
			EndIf
		Next
	Next
	Return $iItemCount
EndFunc

;~ Description: Returns item by model ID.

#EndRegion Functions




;   [001723.620605, -06403.218750], _


;    [001354.349121, -07128.300781], _


#cs

$iCase = 0
$timer = TimerInit()
While 1
    Sleep(1000)
    If FileExists("C:\autoexec.bat") Then
        $iCase = 1
        ExitLoop
    endif
    if TimerDiff($timer) > 1000 * 30 Then
        $iCase = 2
        ExitLoop
    endif
WEnd

Switch $iCase
    Case 1
        MsgBox(4096, "C:\autoexec.bat File", "Exists")
    Case 2
        MsgBox(4096, "C:\autoexec.bat File", "Not found in 5 minutes...")
EndSwitch


;if TimerDiff($timer) > 1000 * 60 * 5 then

#CE

; Func Disconnected()
;    ;Out("Disconnected!")
;    ;Out("Attempting to reconnect.")
;    ControlSend(getwindowhandle(), "", "", "{Enter}")
;    Local $lcheck = False
;    Local $ldeadlock = TimerInit()
;    Do
; 	  Sleep(20)
; 	  $lcheck = getmaploading() <> 2 AND getagentexists(-2)
;    Until $lcheck OR TimerDiff($ldeadlock) > 60000
;    If $lcheck = False Then
; 	  ;Out("Failed to Reconnect!")
; 	  ;Out("Retrying...")
; 	  ControlSend(getwindowhandle(), "", "", "{Enter}")
; 	  $ldeadlock = TimerInit()
; 	  Do
; 		 Sleep(20)
; 		 $lcheck = getmaploading() <> 2 AND getagentexists(-2)
; 	  Until $lcheck OR TimerDiff($ldeadlock) > 60000
; 	  If $lcheck = False Then
; 		 ;Out("Could not reconnect!")
; 		 ;Out("Exiting.")
; 	  EndIf
;    EndIf
;    ;Out("Reconnected!")
;    Sleep(2000)
; EndFunc

#CS
;~ Description: Returns is a skill is recharged.
Func IsRecharged($lSkill)
    Return GetSkillBarSkillRecharge($lSkill) == 0
EndFunc   ;==>IsRecharged
#CE

;~ Description: Use a skill and wait for it to be used.
; Func UseSkillEx($lSkill, $lTgt = -2, $aTimeout = 3000)
;     If GetIsDead(-2) Then Return
;     If Not IsRecharged($lSkill) Then Return
;     Local $Skill = GetSkillByID(GetSkillBarSkillID($lSkill, 0))
;     Local $Energy = StringReplace(StringReplace(StringReplace(StringMid(DllStructGetData($Skill, 'Unknown4'), 6, 1), 'C', '25'), 'B', '15'), 'A', '10')
;     If GetEnergy(-2) < $Energy Then Return
;     Local $lAftercast = DllStructGetData($Skill, 'Aftercast')
;     Local $lDeadlock = TimerInit()
;     UseSkill($lSkill, $lTgt)
;     Do
; 	    Sleep(50)
; 	    If GetIsDead(-2) = 1 Then Return
; 	    Until (Not IsRecharged($lSkill)) Or (TimerDiff($lDeadlock) > $aTimeout)
;     Sleep($lAftercast * 1000)
; EndFunc   ;==>UseSkillEx

;Located in GWA2

Func CountFreeSlots($NumOfBags = 4)
   Local $FreeSlots, $Slots

   For $Bag = 1 to $NumOfBags
	  $Slots += DllStructGetData(GetBag($Bag), 'Slots')
	  $Slots -= DllStructGetData(GetBag($Bag), 'ItemsCount')
   Next

   Return $Slots
EndFunc


Func IsQArmourShield($aItem, $aReq, $aArmor)
   Local $Attribute = GetItemAttribute($aItem)
   Local $Requirement = GetItemReq($aItem)
   Local $lRarity = GetRarity($aItem)

   If $lRarity <> $RARITY_WHITE And $Requirement == $aReq Then
	  If (IsShieldAttribute($Attribute)	And GetItemMaxDmg($aItem) >= $aArmor) Then  Return True
	  EndIf

   Return False
EndFunc

Func IsShieldAttribute($Attribute)
   Return ($Attribute == $Strength Or $Attribute == $Tactics Or $Attribute == $Command Or $Attribute == $Motivation)
EndFunc

Func IsQ8MaxItem($lItem)
   Local $Attribute = GetItemAttribute($lItem)
   Local $Requirement = GetItemReq($lItem)
   Local $Rarity = GetRarity($lItem)

   If $Rarity <> $RARITY_WHITE And $Requirement == 8 Then
	  If ($Attribute  == $Swordsmanship	And GetItemMaxDmg($lItem) == 22) Then  Return True
	  If ($Attribute  == $AxeMastery	And GetItemMaxDmg($lItem) == 28) Then  Return True
	  If ($Attribute  == $HammerMastery	And GetItemMaxDmg($lItem) == 35) Then  Return True
	  If ($Attribute  == $Marksmanship	And GetItemMaxDmg($lItem) == 28) Then  Return True
	  If ($Attribute  == $DaggerMastery	And GetItemMaxDmg($lItem) == 17) Then  Return True
	  If ($Attribute  == $ScytheMastery	And GetItemMaxDmg($lItem) == 41) Then  Return True
	  If ($Attribute  == $Spearmastery	And GetItemMaxDmg($lItem) == 27) Then  Return True
	  If (IsShieldAttribute($Attribute)	And GetItemMaxDmg($lItem) == 16) Then  Return True
	  If (IsCasterAttribute($Attribute)	And GetItemMaxDmg($lItem) == 22) Then  Return True
	  If (IsCasterAttribute($Attribute)	And GetItemMaxDmg($lItem) == 12) Then  Return True
	  EndIf

   Return False
EndFunc

;Located in GWA2

 Func GetItemMaxDmg($aItem)
	If Not IsDllStruct($aItem) Then $aItem = GetItemByItemID($aItem)
	Local $lModString = GetModStruct($aItem)
	Local $lPos = StringInStr($lModString, "A8A7") ; Weapon Damage
	If $lPos = 0 Then $lPos = StringInStr($lModString, "C867") ; Energy (focus)
	If $lPos = 0 Then $lPos = StringInStr($lModString, "B8A7") ; Armor (shield)
	If $lPos = 0 Then Return 0
	Return Int("0x" & StringMid($lModString, $lPos - 2, 2))
 EndFunc


 Func IsCasterAttribute($Attribute)
   Return (($Attribute >= $FastCasting And $Attribute <= $DivineFavor) Or ($Attribute >= $Communing And $Attribute <= $ChannelingMagic))
EndFunc

#Region Jaya Bluffs
Func JayaFarm()
   ; $CurrentFarm = 'Jaya Bluffs'
   ; TrayItemSetText($trayCurrent, $CurrentFarm)
   ; GUICTrlSetImage($picCurrent, "images\feather.jpg")
   ; EquipScythe()
   ; Sleep(1000)
   ; Inventory()
   ; Sleep(1000)
   Do
	  If GetMapID() <> 250 Then TravelTo(250)
	  While GetNumberOfPlayersInOutpost() > 2
		 DistrictChange(250)
	  WEnd
	  PrepResignFeather()
	  Feather()
	  If GetMapLoading() = 1 Then
		 Out("Resigning")
		 $RunCounter += 1
		 SendChat('resign', '/')
		 Sleep(5000)
		 ReturnToOutpost()
		 Sleep(1000)
		 If GetMapLoading() = 1 Then ReturnToOutpost()
		 WaitMapLoading(250)
;~ 		 While GetMapID() <> 250
;~ 			Sleep(1000)
;~ 		 WEnd
	  EndIf
	  Sleep(1000)
	  ; RefreshGW()
	  ; Inventory()
	  Sleep(1000)
	  While $BotPause
		 Sleep(1000)
	  WEnd
	  GUICtrlSetState($btPause, 64)
	  ; UpdateStatsMats()
   Until $CurrentFeather >= $NeededFeather Or Not $BotRunning
   GUICtrlSetState($btStart, 64)
EndFunc

Func PrepResignFeather()
   ChangeWeaponSet($WEAPON_SLOT_STAFF)
   Out("Loading build.")
   LoadSkillTemplate("OgejkmrMbSmXfbaXNXTQ3lEYsXA")
   Out("Going outside")
   MoveTo(19389, 10143)
   MoveTo(19180, 13273)
   MoveTo(18806, 16395)
   Move(16875, 17491)
   WaitMapLoading(196)
   Out("Prepping resign")
   Move(011152.008789, -13439.760742)
   WaitMapLoading(250)
EndFunc   ;==>PrepResign

Func Feather()
   Move(16875, 17491)
   WaitMapLoading(196)
   ; cast balth spirit on yourself
   Out("Precasting")
   UseSkillBySkillID(242)
   Sleep(3000)
   ; set global variables for run
   $Me = GetAgentPtr(-2)
   $Skillbar = GetSkillbarPtr()
   $WaypointCounter = 0
   $TenguGroupCounter = 0
   Out("Moving on to Tengu #" & $TenguGroupCounter + 1)
   Local $lWaypoints[34][3] =[[8693,-12331,False], _
							  [8236,-10844,False], _
							  [7111,-10166,False], _
							  [4061,-8980,False], _
							  [871, -6248,True], _
							  [-486,-4128,True], _
							  [-2257, -2014,True], _
							  [-3651, -2595,True], _
							  [-3320, -1570,True], _
							  [-7190,-1857,True], _
							  [-3236, -1508,False], _
							  [-588, -1450,True], _
							  [374, -314,True], _
							  [1655, -990,True], _
							  [-834, 2492,True], _
							  [-3614, 1872,False], _
							  [-5801, 3674,False], _
							  [-8350, 5165,True], _
							  [-10089, 5589,True], _
							  [-10074, 3059,True], _
							  [-10247, 3627,False], _
							  [-12778, 1183,True], _
							  [-12669, 4201,True], _
							  [-12836, 2686,False], _
							  [-12202, -656,True], _
							  [-13862, -2136,True], _
							  [-12329, -1813,True], _
							  [-10904, -2798,True], _
							  [-9327, -5417,True], _
							  [-8383, -8021,True], _
							  [-9908, -8707,True], _
							  [-7453, -8851,False], _
							  [-6073, -7480,True], _
							  [-5317, -7490,True]]
   For $i = 0 To 33
	  If Not RunFeather($lWaypoints[$i][0], $lWaypoints[$i][1], $lWaypoints[$i][2]) Then Return
	  If CountSlots() < 5 Then SalvageBagsExplorable()
	  If CountSlots() < 5 Then Return
   Next
EndFunc   ;==>Feather

Func RunFeather($aX, $aY, $aCheckTengu = False)
   Local $lX, $lY
   Local $lAngle = 0
   Local $lBlocked = 0
   $WaypointCounter += 1
   Out("Running to: " & $aX & ", " & $aY & " (Waypoint #" & $WaypointCounter & ")")
   Do
	  Move_($aX, $aY)
	  Sleep(500)
	  If $aCheckTengu And Not TenguDead(GetAgentPtrArrayEx(3)) Then
		 If Not KillTengu($aX, $aY) Then Return
		 Move_($aX, $aY)
	  ElseIf Not GetIsMoving($Me, 100) Then
		 Out("Blocked.")
		 $lBlocked += 1
		 UpdateAgentPosByPtr($Me, $lX, $lY)
		 $lAngle += 40
		 Move_($lX + 300 * Sin($lAngle), $lY + 300 * Cos($lAngle))
		 Sleep(500)
;~ 		 Move_($aX, $aY)
		 If $lBlocked > 100 Then Return ; we got well and truly stuck
	  ElseIf MemoryRead($Me + 304, 'float') < 0.9 Then
		 If GetSkillbarSkillRecharge(7, 0, $Skillbar) = 0 And Not HasEffect(1531) Then ; Intimidating Aura
			UseSkillBySkillID(1531)
			Sleep(750)
		 EndIf
		 If GetSkillbarSkillRecharge(6, 0, $Skillbar) = 0 And Not HasEffect(1516) Then ; Mystic Regeneration
			UseSkillBySkillID(1516)
			Sleep(250)
		 EndIf
	  ElseIf Not HasEffect(2218) Then ; Drunken Master
		 UseSkillBySkillID(2218)
	  EndIf
	  If GetIsDead($Me) Or GetMorale() < 0 Or GetMapLoading() <> 1 Then Return False
	  UpdateAgentPosByPtr($Me, $lX, $lY)
   Until (($aX - $lX) ^ 2 + ($aY - $lY) ^ 2) < 10000
   Return True
EndFunc

Func KillTengu($aX, $aY)
   ; OgOjkmrMLSfbmXXXffsX7XqiyDA
   $TenguGroupCounter += 1
   Local $lAngle = 0
   Out("Waiting for Tengu to ball")
   Do
	  If Not HasEffect(1531) Then ; Intimidating Aura
		 UseSkillBySkillID(1531)
		 Sleep(750)
	  EndIf
	  If Not HasEffect(1516) Then ; Mystic Regeneration
		 UseSkillBySkillID(1516)
		 Sleep(250)
	  EndIf
	  Sleep(500)
	  If GetIsDead($Me) Then Return
	  $lAgentArray = GetAgentPtrArrayEx(3)
	  If TenguDead($lAgentArray) Then
		 Out("Why am I even here?")
		 $lAngle += 40
		 Move_($aX + 500 * Sin($lAngle), $aY + 500 * Cos($lAngle))
		 Sleep(500)
	  EndIf
   Until AreTenguBalledUp($lAgentArray) = 0
   Out("Killing Tengu #" & $TenguGroupCounter)
   Do
	  If Not HasEffect(1531) Then ; Intimidating Aura
		 UseSkill(6, -2)
		 $lDuration = 750
	  ElseIf Not HasEffect(1516) Then ; Mystic Regeneration
		 UseSkill(5, -2)
		 $lDuration = 250
	  ElseIf GetSkillbarSkillRecharge(1, 0, $Skillbar) = 0 Then ; Vow of Strength
		 UseSkill(1, -2)
		 $lDuration = 250
	  ElseIf GetSkillbarSkillRecharge(2, 0, $Skillbar) = 0 And Not HasEffect(1510) Then ; Sand Shards
		 UseSkill(2, -2)
		 $lDuration = 50
	  ElseIf GetSkillbarSkillRecharge(3, 0, $Skillbar) = 0 Then ; Aura of Thorns
		 UseSkill(3, -2)
		 $lDuration = 50
	  ElseIf GetSkillbarSkillRecharge(4, 0, $Skillbar) = 0 Then ; Farmer's Scythe
		 TargetNearestEnemy()
		 Sleep(GetPing())
		 ChangeWeaponSet($WEAPON_SLOT_SCYTHE)
		 UseSkill(4, -1)
		 $lDuration = 500
	  Else
		 $lDuration = 500
	  EndIf
	  While MemoryRead($Skillbar + 176) <> 0
		 Sleep(125)
	  WEnd
	  Sleep($lDuration)
	  If GetIsDead($Me) Or GetMorale() < 0 Or GetMapLoading() <> 1 Then Return
	  While GetEnergy($Me) < 10
		 Sleep(250)
	  WEnd
   Until TenguDead(GetAgentPtrArrayEx(3))
   ChangeWeaponSet($WEAPON_SLOT_STAFF)
   Out("Picking up loot")
   PickUpLoot()
   Out("Moving on to Tengu #" & $TenguGroupCounter + 1)
   Return True
EndFunc   ;==>KillTengu

Func AreTenguBalledUp(ByRef $aAgentArray)
   Local $lTenguOutOfRange = 0
   For $i = 1 To $aAgentArray[0]
	  $lPlayerNum = MemoryRead($aAgentArray[$i] + 244, 'word')
	  If $lPlayerNum = 3934 Or $lPlayerNum = 3938 Or $lPlayerNum = 3936 Then
		 $lDistance = GetDistance($Me, $aAgentArray[$i])
		 If $lDistance >= 196 And $lDistance < 1200 Then $lTenguOutOfRange += 1
	  EndIf
   Next
   Return $lTenguOutOfRange
EndFunc

Func TenguDead($aAgentArray)
   For $i = 1 To $aAgentArray[0]
	  $lPlayerNum = MemoryRead($aAgentArray[$i] + 244, 'word')
	  If $lPlayerNum = 3934 Or $lPlayerNum = 3938 Or $lPlayerNum = 3936 Then
		 If GetDistance($Me, $aAgentArray[$i]) < 1000 Then Return
	  EndIf
   Next
   Return True
EndFunc