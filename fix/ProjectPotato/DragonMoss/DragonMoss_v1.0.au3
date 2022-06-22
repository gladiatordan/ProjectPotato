#region Includes
#include "GWA2.au3"
#include <ButtonConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <GuiEdit.au3>
#include <ScrollBarsConstants.au3>
#include <Date.au3>
#endregion Includes
#region GUI

; Create GUI

Opt("GUIOnEventMode", True)

$GUI = GUICreate("Dragon Moss v1.2", 251, 256, 192, 124)
$txtName = GUICtrlCreateCombo("", 8, 8, 145, 25)
GUICtrlSetData(-1, GetLoggedCharNames())
$bStart = GUICtrlCreateButton("Start", 176, 8, 67, 49)
$lblRuns = GUICtrlCreateLabel("Runs: ", 8, 40, 76, 17)
$lblFails = GUICtrlCreateLabel("Fails: ", 104, 40, 68, 17)
Global $Out = GUICtrlCreateEdit("", 8, 64, 233, 185)

GUISetState(@SW_SHOW)
GUICtrlSetOnEvent($bStart, "EventHandler")
GUISetOnEvent($GUI_EVENT_CLOSE, "EventHandler")
#endregion GUI
#region Globals

; Define variables to be used throughout the script

Global $g_hTimer, $g_iSecs, $g_iMins, $g_iHour, $g_sTime

Global $Template = "OgcSc5PT8I6MHQsSpG3l4OCH"
Global $bRunning = False
Global $bInitialized = False
Global $bCanContinue = True
; Global $GWPID = -1
Global $eRendering = True ; Dont recommend turning this off atm

Global $Runs = 0
Global $Fails = 0
Global $FirstRun = True

; Map ID's

Global $Shrine = 349
Global $Thicket = 195

; Skillbar locations

Global Const $DP = 1
Global Const $SF = 2
Global Const $SOD = 3
Global Const $ZH = 4
Global Const $DG = 5
Global Const $DS = 6
Global Const $DC = 7
Global Const $WS = 8

#endregion Globals
#region Initialize
Do
   Sleep(100)
Until $bInitialized

; Handle to keep the script looping and manage inventory

While 1
   If $bRunning = True Then
	  If $eRendering = False Then
		 Out("Rendering Disabled")
		 DisableRendering()
		 WinSetState(GetWindowHandle(), "", @SW_HIDE)
		 Out("Clearing Memory")
	     ClearMemory()
	  EndIf
	  If GetMapID() <> $Shrine Then
		 Out("Not in town")
		 Out("Travelling now")
		 TravelTo($Shrine)
	  EndIf
	  SetupHandle()
	  If CountFreeSlots() < 5 Then
		  Out("Inventory Full..")
		  Out("Going to Merchant")
		 Merchant()
	  EndIf
	  If GetGoldCharacter() > 90000 Then
		 If GetGoldStorage() < 900000 Then
			DepositGold(GetGoldCharacter())
		 Else
			GoToMerchantBuyLockpicks()
		 EndIf
	  EndIf
      $bCanContinue = True
	  GUICtrlSetData($lblRuns, "Runs: " & $Runs)
	  GUICtrlSetData($lblFails, "Fails: " & $Fails)
   EndIf
   WEnd

   ; Typical event handler to pass Initialize

   Func EventHandler()
	Switch @GUI_CtrlId
		Case $GUI_EVENT_CLOSE
			Exit
		Case $bStart
			If $bRunning = True Then
				GUICtrlSetData($bStart, "Will pause after this run")
				GUICtrlSetState($bStart, $GUI_DISABLE)
				$bRunning = False
			ElseIf $bInitialized Then
				GUICtrlSetData($bStart, "Pause")
				$bRunning = True
			Else
				$bRunning = True
				GUICtrlSetData($bStart, "Initializing...")
				GUICtrlSetState($bStart, $GUI_DISABLE)
				GUICtrlSetState($txtName, $GUI_DISABLE)
;~ 				WinSetTitle($GUI, "", GUICtrlRead($txtName))
				If GUICtrlRead($txtName) = "" Then
					If Initialize(ProcessExists("gw.exe"), True, True, False) = False Then
						MsgBox(0, "Error", "Guild Wars it not running.")
						Exit
					EndIf
				Else
					If Initialize(GUICtrlRead($txtName), True, True, False) = False Then
						MsgBox(0, "Error", "Can't find a Guild Wars client with that character name.")
						Exit
					EndIf
				EndIf
				GUICtrlSetData($bStart, "Pause")
				GUICtrlSetState($bStart, $GUI_ENABLE)
				WinSetTitle($GUI, "", GetCharname() & " - DMoss v1.0")
				$bInitialized = True
				; $GWPID = $mGWHwnd
			EndIf
	EndSwitch
EndFunc
#endregion Initialize
#region Main
Func SetupHandle()
    Local $lTimer
    Local $lTime
	;If $FirstRun = True Then
	  ; SetupFirstRun()
	;EndIf
	GoOutside()
    Out("Begin Run #" & $Runs)
	$lTimer = TimerInit()
    Main()
	If $bCanContinue Then
		Out("Mobs dead")
	Else
		Out("Died at mobs")
	EndIf
	If $bCanContinue Then PickUpLoot()

	If $bCanContinue Then
		$Runs += 1
	Else
		$Fails += 1
		$Runs += 1
    EndIf
    Out("Finished Run")
    $lTime = _TicksToTime(Int(TimerDiff($lTimer)), $g_iHour, $g_iMins, $g_iSecs)
    $g_sTime = StringFormat("%02i:%02i:%02i", $g_iHour, $g_iMins, $g_iSecs)
    Out("Took " & $g_sTime & " minutes")

	Resign()

	Sleep(5000)

	ReturnToOutpost()
	Do
	   Sleep(50)
	Until WaitMapLoading($Shrine)
 EndFunc

 Func Merchant()
	GoToMerchant()
	Ident(1)
	Ident(2)
	Sell(1)
	Sell(2)
 EndFunc

Func GoToMerchantBuyLockpicks()
   Local $lMerchant = GetAgentByName("Linsle [Merchant]")
   GoToNPC($lMerchant)
   BuyItem(11, 60, 1500)
EndFunc

Func GoToMerchant()
	Local $lMerchant = GetAgentByName("Linsle [Merchant]")
	GoToNPC($lMerchant)
 EndFunc
 #endregion
 #region main
 Func SetupFirstRun()
	SwitchMode(1)
    Do
	   Move(-11172, -23105)
	   RndSleep(100)
	Until WaitMapLoading($Thicket)

	ReverseDirection()
	Sleep(500)
	ToggleAutoRun()
	Do
	   Sleep(500)
    Until WaitMapLoading($Shrine)

	$FirstRun = False
 EndFunc
 Func GoOutside()
	Move(-11172, -23105)
	Do
	   Sleep(50)
    Until WaitMapLoading($Thicket)
 EndFunc
 Func Main()
	If Not $eRendering Then ClearMemory()
	Out("Moving to Moss")
	UseSkillEx($DS, -2)
	UseSkillEx($ZH, -2)
	MoveTo(-8498, 18548)
	MoveTo(-6858, 17713)
	Do
		Move(-5348, 16085)
		Sleep(100)
	Until GetNumberOfFoesInRangeOfAgent(-2, 1300) > 0
	Out("Casting Enchants")
	UseSkillEx($DP, -2)
	UseSkillEx($SF, -2)
	UseSkillEx($SOD, -2)
	Out("Aggroing Moss")
	UseSkillEx($DG, -2)
	MoveTo(-5234, 15574)
	Out("Balling Moss")
	MoveTo(-6131, 17952)
	TolSleep(450)
	MoveTo(-6570, 18493)
	TolSleep(500)
	UseSkillEx($DS, -2)
	UseSkillEx($ZH, -2)
    Out("Getting Target")
    For $i = 0 To 6
	   TargetNextEnemy()
	   Sleep(50)
    Next
	UseSkillEx($DC, -1)
    Out("Killing Moss")
	UseSkillEx($WS, -2)
	Do
	   Sleep(500)
       If IsRecharged($SF) Then UseSkillEx($SF, -2)
	Until GetNumberOfFoesInRangeOfAgent(-2, 200) < 3 Or GetIsDead(-2)
	Sleep(1500)

	If Not GetIsDead(-2) Then
	   $bCanContinue = True
	Else
	   $bCanContinue = False
	EndIf
 EndFunc
 #EndRegion
 #region other
Func CanPickUp($aItem)
   Local $Q = DllStructGetData($aItem, "Quantity")
   Local $IsSpecial = IsSpecialItem($aItem)
   Local $Rarity = GetRarity($aItem)
   Local $Pcon = IsPcon($aItem)
   Local $Material = IsRareMaterial($aItem)

   Switch $IsSpecial
   Case True
	  Return True ; Is special item (Ecto, TOT, etc)
   EndSwitch

   Switch $Rarity
   Case 2624
	  Return True ; Gold items
   EndSwitch

   Switch $Pcon
   Case True
	  Return True ; Is a Pcon
   EndSwitch

   Switch $Material
   Case True
	  Return True ; Is rare material
   EndSwitch
	If $Q > 50 Then
	   Return True
	Else
	   Return False
	EndIf
	Return False
 EndFunc
 Func CanSell($aItem)
 ;  Local $RareSkin = IsRareSkin($aItem)
   Local $Pcon = IsPcon($aItem)
   Local $Material = IsRareMaterial($aItem)
   Local $IsSpecial = IsSpecialItem($aItem)
   Local $IsCaster = IsPerfectCaster($aItem)
   Local $IsStaff = IsPerfectStaff($aItem)
   Local $IsShield = IsPerfectShield($aItem)
   Local $IsRune = IsRareRune($aItem)
   Local $IsReq8 = IsReq8Max($aItem)
   Local $Type = DllStructGetData($aItem, "Type")

   Switch $IsSpecial
   Case True
	  Return False ; Is special item (Ecto, TOT, etc)
   EndSwitch

   Switch $Pcon
   Case True
	  Return False ; Is a Pcon
   EndSwitch

   Switch $Material
   Case True
	  Return False ; Is rare material
   EndSwitch

   Switch $IsShield
   Case True
	  Return False ; Is perfect shield
   EndSwitch

   Switch $IsReq8
   Case True
	  Return False ; Is req8 max
   EndSwitch

   Switch $Type
   Case 12 ; Offhands
	  If $IsCaster = True Then
		 Return False ; Is perfect offhand
	  Else
		 Return True
	  EndIf
   Case 22 ; Wands
	  If $IsCaster = True Then
		 Return False ; Is perfect wand
	  Else
		 Return True
	  EndIf
   Case 26 ; Staves
	  If $IsStaff = True Then
		 Return False ; Is perfect Staff
	  Else
		 Return True
	  EndIf
   EndSwitch

   Switch $IsRune
   Case True
	  Return False
   EndSwitch

   ;Switch $RareSkin
   ;Case True
;	  Return False
   ;EndSwitch

   Return True
 EndFunc
Func CanID($aItem)
   Return True
EndFunc
  Func CanSalvage($aItem) ; Doesnt work
	Local $M = DllStructGetData($aItem, "ModelID")
	Local $R = GetRarity($aItem)

	Switch $M
	Case 934
	  If $R = 2624 Then
	     Return True
	  Else
		 Return False
	  EndIf
	EndSwitch
	Return False
 EndFunc
#endregion other


Func Out($aString)
	ConsoleWrite(@HOUR & ":" & @MIN & " - " & $aString & @CRLF)
	GUICtrlSetData($Out, GUICtrlRead($Out) & @HOUR & ":" & @MIN & " - " & $aString & @CRLF)
	_GUICtrlEdit_Scroll($Out, $SB_SCROLLCARET)
	_GUICtrlEdit_Scroll($Out, $SB_LINEUP)
EndFunc

;==> Pick up the loot.
Func PickUpLoot()
	Local $lMe
	Local $lBlockedTimer
	Local $lBlockedCount = 0
	Local $lItemExists = True
	Local $Distance

	For $i = 1 To GetMaxAgents()
		If GetIsDead(-2) Then Return False
		$lAgent = GetAgentByID($i)
		If Not GetIsMovable($lAgent) Then ContinueLoop
		$lDistance = GetDistance($lAgent)
		If $lDistance > 2000 Then ContinueLoop
		$lItem = GetItemByAgentID($i)
		If CanPickup($lItem) Then
			Do
				If GetDistance($lAgent) > 150 Then Move(DllStructGetData($lAgent, 'X'), DllStructGetData($lAgent, 'Y'), 100)
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
				Until Not $lItemExists Or TimerDiff($lBlockedTimer) > Random(500, 1000, 1)
				If $lItemExists Then $lBlockedCount += 1
			Until Not $lItemExists Or $lBlockedCount > 5
		EndIf
	Next
EndFunc