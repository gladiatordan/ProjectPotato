
#include <ButtonConstants.au3>
#include <ComboConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <ScrollBarsConstants.au3>
#include <Misc.au3>
#include <EditConstants.au3>
#include <GuiEdit.au3>
#include "include\API_Include.au3"
#include "include\Potato_JadeSalvSell.au3"
#NoTrayIcon

#Region Constants
; === Maps ===
Global Const $MAP_ID_MarketPlace = 303
Global Const $MAP_ID_WajjunBazar = 239


Global Const $SkillBarTemplate = "OwFTUZ/8Z6A6ukuIuc7TxJgpBCA"

#EndRegion Constants

#Region Declarations
Opt("GUIOnEventMode", True)
Opt("GUICloseOnESC", False)
Global $Mode = 0
Global $Runs = 0
Global $Fails = 0
Global $BotRunning = False
Global $BotInitialized = False
Global $TotalSeconds = 0
Global $Seconds = 0
Global $Minutes = 0
Global $Hours = 0
Global $MerchOpened = False
Global $HWND
Global $Platinum_Made_After_Merch_And_Kits = 0
Global $Platinum_Made_Over_All = 0
#EndRegion Declarations

#Region GUI
$Gui = GUICreate("JadeBros [db]", 349, 174, -1, -1)
$CharInput = GUICtrlCreateCombo("", 6, 6, 103, 25, BitOR($CBS_DROPDOWN, $CBS_AUTOHSCROLL))
GUICtrlSetData(-1, GetLoggedCharNames())
$StartButton = GUICtrlCreateButton("Start", 5, 146, 105, 23)
GUICtrlSetOnEvent(-1, "GuiButtonHandler")
$ProcessInventory = GUICtrlCreateButton("Process Inventory", 115, 146, 176, 23)
GUICtrlSetOnEvent(-1, "SellIfNeeded")
$nmButton = GUICtrlCreateRadio("NM", 115, 4, 40, 25)
GUICtrlSetState(-1, $GUI_CHECKED)
$hmButton = GUICtrlCreateRadio("HM", 115, 24, 40, 25)
GUICtrlSetState(-1, $GUI_UNCHECKED)
$RunsLabel = GUICtrlCreateLabel("Runs:", 6, 31, 31, 17)
$RunsCount = GUICtrlCreateLabel("-", 34, 31, 75, 17, $SS_RIGHT)
$FailsLabel = GUICtrlCreateLabel("Fails:", 6, 50, 31, 17)
$FailsCount = GUICtrlCreateLabel("-", 30, 50, 79, 17, $SS_RIGHT)
$DropsLabel = GUICtrlCreateLabel("Gold: ", 6, 69, 30, 17)
$DropsCount = GUICtrlCreateLabel("-", 59, 69, 50, 17, $SS_RIGHT)
$AvgTimeLabel = GUICtrlCreateLabel("Average time:", 6, 88, 65, 17)
$AvgTimeCount = GUICtrlCreateLabel("-", 71, 88, 38, 17, $SS_RIGHT)
$TotTimeLabel = GUICtrlCreateLabel("Total time:", 6, 107, 49, 17)
$TotTimeCount = GUICtrlCreateLabel("-", 55, 107, 54, 17, $SS_RIGHT)
$StatusLabel = GUICtrlCreateEdit("", 155, 6, 176, 139, 2097220)
GUICtrlSetColor(-1, 0x45CEA2)
GUICtrlSetBkColor(-1, 0x000000)
$RenderingBox = GUICtrlCreateCheckbox("Disable Rendering", 6, 124, 103, 17)
GUICtrlSetOnEvent(-1, "ToggleRendering")
GUICtrlSetState($RenderingBox, $GUI_DISABLE)
GUISetOnEvent($GUI_EVENT_CLOSE, "_exit")
GUISetState(@SW_SHOW)
#EndRegion GUI

#Region Loops
Out("Ready.")
While Not $BotRunning
	Sleep(500)
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
		GUICtrlSetState($nmButton, $GUI_ENABLE)
		GUICtrlSetState($hmButton, $GUI_ENABLE)
		$Mode = 0
		While Not $BotRunning
			Sleep(500)
		WEnd
		AdlibRegister("TimeUpdater", 1000)
	EndIf
	MainLoop()
WEnd
#EndRegion Loops

#Region Essential Functions
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
			If Initialize($CharName, True) = False Then
				MsgBox(0, "Error", "Could not find a Guild Wars client with a character named '" & $CharName & "'")
				Exit
			EndIf
		EndIf
		$HWND = GetWindowHandle()
		GUICtrlSetState($RenderingBox, $GUI_ENABLE)
		GUICtrlSetState($CharInput, $GUI_DISABLE)
		If GUICtrlRead($nmButton) = $GUI_CHECKED Then
			Out("Normal Mode Selected")
			$Mode = 0
		Else
			Out("Hard Mode Selected")
			$Mode = 1
		EndIf
		GUICtrlSetState($nmButton, $GUI_DISABLE)
		GUICtrlSetState($hmButton, $GUI_DISABLE)
		Local $CharName = GetCharname()
		GUICtrlSetData($CharInput, $CharName, $CharName)
		GUICtrlSetData($StartButton, "Pause")
		WinSetTitle($Gui, "", "" & $CharName)
		$BotRunning = True
		$BotInitialized = True
		SetMaxMemory()
	EndIf
EndFunc   ;==>GuiButtonHandler

;==> Description: Manages inventory, ensures HM.
Func Setup()
	If CountEmptySlots() <= 5 Then SellIfNeeded()
	If GetMapID() <> $MAP_ID_MarketPlace Then
		Out("Travelling to Marketplace.")
		RndTravel($MAP_ID_MarketPlace)
	EndIf
	Out("Loading skillbar.")
	LoadSkillTemplate($SkillBarTemplate)
	LeaveGroup()
	If $Mode = 0 Then
		Out("Switching mode to Normal Mode")
	Else
		Out("Switching mode to Hard Mode")
	EndIf
	SwitchMode($Mode)
	RndSleep(500)
	SetUpFastWay()
EndFunc   ;==>Setup

;==> Description: Sets up fast resign.
Func SetUpFastWay()
	MoveTo(11981, 15694)
	Move(11335, 15109)
	WaitMapLoading($MAP_ID_WajjunBazar)
	Move(11771,15538)
	WaitMapLoading($MAP_ID_MarketPlace)
	RndSleep(500)
	Return True
EndFunc   ;==>SetUpFastWay

;==> Description: Manages inventory, begins farm loop.
Func MainLoop()
	If CountEmptySlots() <= 5 Then SellIfNeeded()
	If GetMapID() == $MAP_ID_MarketPlace Then
		Zone_Fast_Way()
	Else
		Setup()
		Zone_Fast_Way()
	EndIf
	MainJadeBro()
	Pickuploot()
	If GetIsDead(-2) Then
		$Fails += 1
		Out("I'm dead.")
		GUICtrlSetData($FailsCount, $Fails)
	Else
		$Runs += 1
		Out("Completed in " & GetTime() & ".")
		GUICtrlSetData($RunsCount, $Runs)
		GUICtrlSetData($AvgTimeCount, AvgTime())
	EndIf
	If GUICtrlRead($RenderingBox) == $GUI_CHECKED Then ClearMemory()
	Out("Returning to Town")
	Resign()
	RndSleep(5000)
	ReturnToOutpost()
	WaitMapLoading($MAP_ID_MarketPlace)
	PurgeHook()
EndFunc   ;==>MainLoop

;==> Description: Manages rendering of client.
Func PurgeHook()
Out("Purging engine hook")
If GUICtrlRead($RenderingBox)  == $GUI_CHECKED then
;clearMemory()
enableRendering()
winSetState(getWindowHandle(), "", @SW_SHOW)
sleep(1000)
disableRendering()
winSetState(getWindowHandle(), "", @SW_HIDE)
endIf
EndFunc   ;==> prevent memory leak

;==> Description: Post-resign zone into explorable.
Func Zone_Fast_Way()
	Out("Zoning.")
	Move(11335, 15109)
	WaitMapLoading($MAP_ID_WajjunBazar)
	Return True
EndFunc   ;==>Zone_Fast_Way

;==> Description: Randomly navigates to one of all districts upon startup.
Func RndTravel($aMapID)
	If GetMapLoading() == 2 Then Disconnected()
	   Local $UseDistricts =9 ; 7=eu-only, 8=eu+int, 11=all(excluding America)
		; Region/Language order: eu-en, eu-fr, eu-ge, eu-it, eu-sp, eu-po, eu-ru, us-en, int, asia-ko, asia-ch, asia-ja
		;~    Local $Region[11] = [2, 2, 2, 2, 2, 2, 2, -2, 1, 3, 4]
		;~    Local $Language[11] = [0, 2, 3, 4, 5, 9, 10, 0, 0, 0, 0]
		Local $Region[11] = [0, -2, 1, 3, 4]
		Local $Language[11] = [0, 0, 0, 0, 0]
	    Local $Random = Random(0, $UseDistricts - 1, 1)
	;   MoveMap($aMapID, $Region[$Random], 0, $Language[$Random])
	TravelTo($aMapID)
	;   WaitMapLoading($aMapID)
EndFunc   ;==>RndTravel

;==> Description: Fetches run time.
Func GetTime()
	Local $Time = GetInstanceUpTime()
	Local $Seconds = Floor($Time / 1000)
	Local $Minutes = Floor($Seconds / 60)
	Local $Hours = Floor($Minutes / 60)
	Local $Second = $Seconds - $Minutes * 60
	Local $Minute = $Minutes - $Hours * 60
	If $Hours = 0 Then
		If $Second < 10 Then $InstTime = $Minute & ':0' & $Second
		If $Second >= 10 Then $InstTime = $Minute & ':' & $Second
	ElseIf $Hours <> 0 Then
		If $Minutes < 10 Then
			If $Second < 10 Then $InstTime = $Hours & ':0' & $Minute & ':0' & $Second
			If $Second >= 10 Then $InstTime = $Hours & ':0' & $Minute & ':' & $Second
		ElseIf $Minutes >= 10 Then
			If $Second < 10 Then $InstTime = $Hours & ':' & $Minute & ':0' & $Second
			If $Second >= 10 Then $InstTime = $Hours & ':' & $Minute & ':' & $Second
		EndIf
	EndIf
	Return $InstTime
EndFunc   ;==>GetTime

;==> Description: Calculates average run time.
Func AvgTime()
	Local $Time = GetInstanceUpTime()
	Local $Seconds = Floor($Time / 1000)
	$TotalSeconds += $Seconds
	Local $AvgSeconds = Floor($TotalSeconds / $Runs)
	Local $Minutes = Floor($AvgSeconds / 60)
	Local $Hours = Floor($Minutes / 60)
	Local $Second = $AvgSeconds - $Minutes * 60
	Local $Minute = $Minutes - $Hours * 60
	If $Hours = 0 Then
		If $Second < 10 Then $AvgTime = $Minute & ':0' & $Second
		If $Second >= 10 Then $AvgTime = $Minute & ':' & $Second
	ElseIf $Hours <> 0 Then
		If $Minutes < 10 Then
			If $Second < 10 Then $AvgTime = $Hours & ':0' & $Minute & ':0' & $Second
			If $Second >= 10 Then $AvgTime = $Hours & ':0' & $Minute & ':' & $Second
		ElseIf $Minutes >= 10 Then
			If $Second < 10 Then $AvgTime = $Hours & ':' & $Minute & ':0' & $Second
			If $Second >= 10 Then $AvgTime = $Hours & ':' & $Minute & ':' & $Second
		EndIf
	EndIf
	Return $AvgTime
EndFunc   ;==>AvgTime

;==> Description: Uptimes time for run statistics.
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
EndFunc   ;==>TimeUpdater

;==> Description: Toggles rendering of client.
Func ToggleRendering()
	If GUICtrlRead($RenderingBox) == $GUI_UNCHECKED Then
		EnableRendering()
		WinSetState($HWND, "", @SW_SHOW)
	Else
		DisableRendering()
		WinSetState($HWND, "", @SW_HIDE)
	EndIf
	Return True
EndFunc   ;==>ToggleRendering

;==> Description: Displays message for user.
Func Out($msg)
	GUICtrlSetData($StatusLabel, GUICtrlRead($StatusLabel) & "[" & @HOUR & ":" & @MIN & "]" & " " & $msg & @CRLF)
	_GUICtrlEdit_Scroll($StatusLabel, $SB_SCROLLCARET)
	_GUICtrlEdit_Scroll($StatusLabel, $SB_LINEUP)
EndFunc   ;==>Out

;==> Description: Exits the application.
Func _exit()
	If GUICtrlRead($RenderingBox) == $GUI_CHECKED Then
		EnableRendering()
		WinSetState($HWND, "", @SW_SHOW)
		Sleep(500)
	EndIf
	Exit
EndFunc   ;==>_exit

; ;==> Description: Use a skill and wait for it to be used.
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

; ;==> Description: Returns is a skill is recharged.
; Func IsRecharged($lSkill)
;     Return GetSkillBarSkillRecharge($lSkill) == 0
; EndFunc   ;==>IsRecharged

Func RunTo($aX, $aY)
   Local $Blocked = 0
   Move($aX, $aY, 50)
Do
	$dead = deathCheck()
			Sleep(250)
			$lMe = GetAgentByID(-2)

			If GetMapLoading() == 2 Then
			   Disconnected()
			   Return False
			EndIf
			If GetSkillBarSkillRecharge(2) = 0 Then
			   UseSkill(7,-2)
			   PingSleep(500)
			EndIf
			If GetSkillBarSkillRecharge(8) = 0 Then
			   If $Mode = 1 Then
			   	  UseSkill(8,-2)
			   	  PingSleep(100)
			   EndIf
			EndIf
			If GetIsMoving($lMe) = False Then
			   $Blocked += 1
			   Move($aX, $aY, 75)
			EndIf
			If $Blocked > 6 Then
			   If GetSkillBarSkillRecharge(7) = 0 Then
				  UseSkill(7,-2)
				  PingSleep(250)
			   EndIf
			Move($aX, $aY, 75)
			$Blocked = 0
			EndIf
Until GetMapID() <> 239 Or ComputeDistance(DllStructGetData($lMe, 'X'), DllStructGetData($lMe, 'Y'), $aX, $aY) <= 100 or $dead

EndFunc

Func FightEnemies()
		 TargetNearestEnemy()
		 Do
			checkTarget()
			stanceUpkeep()
			enchantmentUpkeep()
			$jade_count = GetNumberOfFoesInRangeOfAgent2(-2)
			$dead = deathCheck()
			If GetMapLoading() == 2 Then
			   Disconnected()
			   Return False
			EndIf
			Sleep(250)
		 Until $dead  or $jade_count = 0

EndFunc

Func AggroGroup($aX, $aY, $aFoes = 5)
   Local $Blocked = 0
   Move($aX, $aY, 50)
   Do
	  Sleep(250)
	  $lMe = GetAgentByID(-2)
	  If DllStructGetData($lMe, 'HP') <= 0 Then ExitLoop
	  If GetMapLoading() == 2 Then
		 Disconnected()
		 Return False
	  EndIf
	  If GetSkillBarSkillRecharge(2) = 0 Then
		 UseSkill(7,-2)
		 PingSleep(500)
	  EndIf
	  If GetSkillBarSkillRecharge(8) = 0 Then
	  	 If $Mode = 1 Then
		 	UseSkill(8,-2)
		 	PingSleep(50)
	 	 EndIf
	  EndIf
	  If GetIsMoving($lMe) = False Then
		 $Blocked += 1
		 Move($aX, $aY, 75)
	  EndIf
	  If $Blocked > 6 Then
		 If GetSkillBarSkillRecharge(7) = 0 Then
			UseSkill(7,-2)
			PingSleep(250)
		 EndIf
		 Move($aX, $aY, 75)
		 $Blocked = 0
	  EndIf
   Until GetNumberOfFoesInRangeOfAgent2(-2, 1000) >= $aFoes  Or GetMapID() <> 239 Or ComputeDistance(DllStructGetData($lMe, 'X'), DllStructGetData($lMe, 'Y'), $aX, $aY) < 250

EndFunc

Func checkTarget()
   TargetNearestEnemy()
   Local $lMe = GetAgentByID(-2)
   Local $lTarget = GetAgentByID(-1)
   If ComputeDistance(DllStructGetData($lMe, 'X'), DllStructGetData($lMe, 'Y'), DllStructGetData($lTarget, 'X'), DllStructGetData($lTarget, 'Y')) < 1250 then
	  Attack($lTarget)
   EndIf
EndFunc

Func stanceUpkeep()
   if GetSkillbarSkillRecharge(3) = 0 and GetEnergy(-2) > 5 then
	  useSkill(3, -2)
	  PingSleep()
   endif
   if GetSkillbarSkillRecharge(5) = 0 and GetSkillbarSkillAdrenaline(6) >= 150 and GetEnergy(-2) > 10 And GetEffectTimeRemaining(GetEffect(372)) <= 4000 then
	  useSkill(5, -1)
	  PingSleep(1000)
	  useSkill(6, -2)
	  PingSleep()
	  useSkill(3, -2)
	  PingSleep()
   endif
   if GetSkillbarSkillRecharge(7) = 0 and GetEnergy(-2) > 5 then
	  useSkill(7, -1)
	  PingSleep(250)
   endif
   Return
endfunc

Func enchantmentUpkeep()

	if GetSkillbarSkillRecharge(2) = 0 then
		useSkill(2, -2)
		PingSleep(250)
		return
	endif
	if GetSkillbarSkillRecharge(1) = 0 and GetEffectTimeRemaining(GetEffect(1031)) <= 2500 then
		useSkill(1, -2)
		PingSleep(1000)
		return
	endif

	if GetSkillbarSkillRecharge(4) = 0 and GetEffectTimeRemaining(GetEffect(2417)) <= 0 then
		useSkill(4, -2)
		PingSleep(1000)
		return
	endif
endfunc

Func deathCheck()
	if GetIsDead(-2) then
		return true
	else
		return false
	endif
endfunc

Func PingSleep($msExtra = 0)
	$ping = GetPing()
	Sleep($ping + $msExtra)
EndFunc   ;==>PingSleep
#EndRegion

#Region Item Functions

;==> Description: Checks if item picked up is a rare skin
Func isRare($lItem)
   Switch DllStructGetData($lItem, 'ModelID')
   case 735 ; bo staff
	  Return True
   case 736 ; dragon staff
	  Return True
   case 737 ; broadsword
	  Return True
   case 741 ; jitte
	  Return True
   case 742 ; katana
	  Return True
   EndSwitch
EndFunc	;==>isRare

Func GetItemCountByID($ID)
	If GetMapLoading() == 2 Then Disconnected()
	Local $Item
	Local $Quantity = 0
	For $Bag = 1 To 4
		For $Slot = 1 To DllStructGetData(GetBag($Bag), 'Slots')
			$Item = GetItemBySlot($Bag, $Slot)
			If DllStructGetData($Item, 'ModelID') = $ID Then
				$Quantity += DllStructGetData($Item, 'Quantity')
			EndIf
		Next
	Next
	Return $Quantity
EndFunc   ;==>GetItemCountByID

;==> Description: Picks up loot.
Func PickUpLoot()
	If GetMapLoading() == 2 Then Disconnected()
	Local $lMe, $lAgent, $lItem
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
				;If $lBlockedCount > 2 Then UseSkillEx(6,-2)
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
EndFunc   ;==>PickUpLoot

;==> Description: Checks if item is worthy of being picked up.
Func CanPickUp($lItem)
    If GetMapLoading() == 2 Then Disconnected()
	Local $Quantity
	Local $ModelID = DllStructGetData($lItem, 'ModelID')
	Local $ExtraID = DllStructGetData($lItem, 'ExtraID')
	Local $lType = DllStructGetData($lItem, 'Type')
	Local $lRarity = GetRarity($lItem)

    If $lRarity = 2621 Then Return True ;white
    If $lRarity = 2623 Then Return True ;blue
    If $lRarity = 2626 Then Return True ;purple
    If $lRarity = 2624 Then Return True ;gold
	If $ModelID == 22751 Then Return True ; Lockpick
    If $ModelID == 21833 Then Return True ; lunar tokens
	If $ModelID == 2511 And GetGoldCharacter() < 99000 Then Return True ;2511 = Gold Coins
EndFunc   ;==>CanPickUp
 #EndRegion

;==> Description: Main loop.
Func MainJadeBro()

 ; start the run

		 ; dwarven stability
		 UseSkill(2, -2)
		 Sleep(250)

		 ; shroud of distress
		 UseSkill(1, -2)
		 Sleep(1750)

		 ; dark escape
		 If $Mode = 1 Then
		 	UseSkill(8, -2)
	 	 EndIf

		 ; move past first group
		 Out("Moving to the first group.")
		 AggroGroup(8719, 13745, 1)


		 ; move to second group
		 Out("Moving to the second group.")
		 AggroGroup(5800, 14303, 4)


		 if GetNumberOfFoesInRangeOfAgent2(-2) < 4 then
			; move back to first group
			Out("Re-aggroing first group")
			AggroGroup(8719, 13745, 5)
			AggroGroup(5800, 14303, 4)
		 endif

		 ; move to wall
		 Out("Moving to the wall.")
		 RunTo(6879, 15364)
		 Out("Moving to the corner.")
		 RunTo(7582, 15842)

		 useSkill(4, -2)
		 PingSleep(1250)
		 Out("Killing Jades.")
		 FightEnemies()
		 Out("Picking up loot drops.")
		 PingSleep(500)

EndFunc

#Region Targeting Functions
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
EndFunc   ;==>GetFarthestEnemyToAgent

; Func GetNumberOfFoesInRangeOfAgent($aAgent = -2, $aRange = 1250)
; 	If GetMapLoading() == 2 Then Disconnected()
; 	Local $lAgent, $lDistance
; 	Local $lCount = 0, $lAgentArray = GetAgentArray(0xDB)
; 	If Not IsDllStruct($aAgent) Then $aAgent = GetAgentByID($aAgent)
; 	For $i = 1 To $lAgentArray[0]
; 		$lAgent = $lAgentArray[$i]
; 		If BitAND(DllStructGetData($lAgent, 'typemap'), 262144) Then
; 			If StringLeft(GetAgentName($lAgent), 7) <> "Servant" Then ContinueLoop
; 		EndIf
; 		If DllStructGetData($lAgent, 'Allegiance') <> 3 Then ContinueLoop
; 		If DllStructGetData($lAgent, 'HP') <= 0 Then ContinueLoop
; 		If BitAND(DllStructGetData($lAgent, 'Effects'), 0x0010) > 0 Then ContinueLoop
; 		;If StringLeft(GetAgentName($lAgent), 7) <> "Sensali" Then ContinueLoop
; 		$lDistance = GetDistance($lAgent)
; 		If $lDistance > $aRange Then ContinueLoop
; 		$lCount += 1
; 	Next
; 	Return $lCount
; EndFunc   ;==>GetNumberOfFoesInRangeOfAgent

Func GetNumberOfFoesInRangeOfAgent2($aAgent = -2, $fMaxDistance = 1012)
   Local $lDistance, $lCount = 0
   Local $lAgentArray = GetAgentArray(0xDB)

   If IsDllStruct($aAgent) = 0 Then $aAgent = GetAgentByID($aAgent)

   For $i = 1 To $lAgentArray[0]
	  If DllStructGetData($lAgentArray[$i], "Allegiance") <> 0x3 Then ContinueLoop
	  If DllStructGetData($lAgentArray[$i], "HP") <= 0 Then ContinueLoop
	  $lDistance = GetDistance($lAgentArray[$i], $aAgent)
	  If $lDistance < $fMaxDistance Then
		 $lCount += 1
		 ;ConsoleWrite("Counts: " &$lCount & @CRLF)
	  EndIf
   Next
   Return $lCount
EndFunc   ;==>GetNumberOfFoesInRangeOfAgent2

Func Update_Plat_Counter()
	$Platinum_Made_After_Merch_And_Kits = GetGoldCharacter()
	$Platinum_Made_Over_All = $Platinum_Made_After_Merch_And_Kits + $Platinum_Made_Over_All
	GUICtrlSetData($DropsCount,$Platinum_Made_Over_All)
EndFunc
#EndRegion

