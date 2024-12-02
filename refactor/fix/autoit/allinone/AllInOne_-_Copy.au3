#Region About
;~ Thanks for GWA2
;~ This was tested with:
;~ 		Full Windwalker Insignias
;~ 		+4 Earth Prayers
;~ 		+1 Scythe Mastery
;~ 		+1 Mysticism
;~ 		490 Health
;~ 		25 Energy (with scythe equipped, 40 with staff)
;~		Kebob: 	Ogek8Np5Kzmj59brdbu731L7FBC		-	Koss Builds: OQkiUxm8sjJxsYAAAAAAAAAA or OQkiUhm8wWIxsYAAAAAAAAAA or OQkiUxm8wjJxsYAAAAAAAAAA
;~		Soup: 	Ogek8Np5Kzmk513GBWzlqIuz+F7F
;~		Salad: 	Ogakgwp5ayOERD3HAAAAAA71dpqI
;~ Averages are included into the calculator by Statistics over atleast 10.000 Runs!
;~
;~ Func HowToUseThisProgram()
;~ 		Start Guild Wars
;~ 		Log onto your dervish
;~ 		Equip a scythe in slot $WEAPON_SLOT_SCYTHE and a swort/spear/axe - shield in slot $WEAPON_SLOT_SHIELD
;~ 		Run the bot
;~ 		If one instance of Guild Wars is open Then
;~ 			Select farmsettings
;~ 			Click Start
;~ 		ElseIf multiple instances of Guild Wars are open Then
;~      	Select the character you want from the dropdown menu
;~ 			Select farmsettings
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
#NoTrayIcon

#Region Declarations
Opt("GUIOnEventMode", True)
Opt("GUICloseOnESC", False)
Global Const $WEAPON_SLOT_SCYTHE = 1
Global Const $WEAPON_SLOT_SHIELD = 2
Global $Hero_Koss = 6
Global $hostarget
Global $updatemode = true
Global $updatemodeswitch
Global $KilledIboga = 0
Global $hh
Global $mm
Global $hhh = 0
Global $mmm = 0
Global $KebobRuns = 0
Global $KebobFails = 0
Global $KebobDrops = 0
Global $SoupRuns = 0
Global $SoupFails = 0
Global $SoupDrops = 0
Global $SaladRuns = 0
Global $SaladFails = 0
Global $SaladDrops = 0
Global $BotRunning = False
Global $BotInitialized = False
Global $KebobTotalSeconds = 0
Global $SaladTotalSeconds = 0
Global $SoupTotalSeconds = 0
Global $Seconds = 0
Global $TotalTime = 0
Global $Minutes = 0
Global $Hours = 0
Global $MerchOpened = False
Global $HWND
Global $FarmMode = 0 ; 1=Kebob 2=Salad 3=Soup
Global $timereset = False
Global $FarmNextItem = True
Global $FarmNextItem2 = True

Global $SKILLID_Sand_Shards = 1510
Global $SKILLID_VOS = 1759
Global $SKILLID_Staggering_Force = 1498
Global $SKILLID_Eremites_Attack = 1485
Global $SKILLID_Intimidating_Aura = 1531
Global $SKILLID_Armor_of_Sanctity = 1515
Global $SKILLID_Mystic_Regeneration = 1516
Global $SKILLID_HoS = 1555
Global $SKILLID_Charge = 364
Global $SKILLID_BraceYourself = 1572
Global $SKILLID_BladeturnRefrain = 1580

;Item Types
Global Const $ITEMTYPE_SALVAGE = 0
Global Const $ITEMTYPE_AXE = 2
Global Const $ITEMTYPE_BAG = 3
Global Const $ITEMTYPE_BOOTS = 4
Global Const $ITEMTYPE_BOW = 5
Global Const $ITEMTYPE_CHESTPIECE = 7
Global Const $ITEMTYPE_UPGRADE = 8
Global Const $ITEMTYPE_USABLE = 9
Global Const $ITEMTYPE_DYE = 10
Global Const $ITEMTYPE_MATERIAL = 11
Global Const $ITEMTYPE_OFFHAND = 12
Global Const $ITEMTYPE_GLOVES = 13
Global Const $ITEMTYPE_HAMMER = 15
Global Const $ITEMTYPE_HEADPIECE = 16
Global Const $ITEMTYPE_CANDYCANESHARD = 17
Global Const $ITEMTYPE_KEY = 18
Global Const $ITEMTYPE_LEGGINGS = 19
Global Const $ITEMTYPE_GOLD = 20
Global Const $ITEMTYPE_QUESTITEM = 21
Global Const $ITEMTYPE_WAND = 22
Global Const $ITEMTYPE_SHIELD = 24
Global Const $ITEMTYPE_STAFF = 26
Global Const $ITEMTYPE_SWORD = 27
Global Const $ITEMTYPE_KIT = 29
Global Const $ITEMTYPE_TROPHY = 30
Global Const $ITEMTYPE_SCROLL = 31
Global Const $ITEMTYPE_DAGGERS = 32
Global Const $ITEMTYPE_MINIPET = 34
Global Const $ITEMTYPE_SCYTHE = 35
Global Const $ITEMTYPE_SPEAR = 36
Global Const $ITEMTYPE_COSTUME = 44
Global Const $ITEMTYPE_COSTUME_HEADPIECE = 45

;Rarity
Global Const $Rarity_white = 2621
Global Const $Rarity_blue = 2623
Global Const $Rarity_purple = 2626
Global Const $Rarity_gold = 2624
Global Const $Rarity_green = 2627

;Mob IDs
Global Const $AGENTID_Iboga = 4388
Global Const $AGENTID_SteelfangDrake = 4918

#EndRegion Declarations

#Region GUI
$Gui = GUICreate("NF PCons", 506, 480, -1, -1)

;~ settings
$gSettings = GUICtrlCreateGroup("Settings", 5, 2, 190, 70)
$CharInput = GUICtrlCreateCombo("", 15, 20, 170, 25, BitOR($CBS_DROPDOWN, $CBS_AUTOHSCROLL))
   GUICtrlSetData(-1, GetLoggedCharNames())
$RenderingBox = GUICtrlCreateCheckbox("Disable Rendering", 15, 45)
   GUICtrlSetOnEvent(-1, "ToggleRendering")
   GUICtrlSetState($RenderingBox, $GUI_DISABLE)
$cbxOnTop = GUICtrlCreateCheckbox("On Top", 132, 45)
   GUICtrlSetOnEvent(-1, "ToogleOnTop")

;~ Item
$FarmSettings = GUICtrlCreateGroup("Item", 205, 2, 105, 120)
$FarmKebob = GUICtrlCreateRadio("Drake Kabob", 215, 20)
$FarmSalad = GUICtrlCreateRadio("Pahnai Salad", 215, 44)
$FarmSoup = GUICtrlCreateRadio("Skalefin Soup", 215, 68)
$FarmAll = GUICtrlCreateRadio("Farm All", 215, 92)

;~ Precast and Farm All Mode Settings
$precastettings = GUICtrlCreateGroup("Farm All Setup and calculator", 320, 2, 180, 120)
$KebobLabel = GUICtrlCreateLabel("Drake Kabob:", 330, 24)
$KebobCount = GUICtrlCreateInput("", 430, 20, 60, 20, $SS_RIGHT)
$SaladLabel = GUICtrlCreateLabel("Pahnai Salad:", 330, 48)
$SaladCount = GUICtrlCreateInput("", 430, 45, 60, 20, $SS_RIGHT)
$SoupLabel = GUICtrlCreateLabel("Skalefin Soup:", 330, 72)
$SoupCount = GUICtrlCreateInput("", 430, 70, 60, 20, $SS_RIGHT)
$sumLabel = GUICtrlCreateLabel("Estimated Time:", 330, 96)
$sumCount = GUICtrlCreateLabel("-", 410, 96, 80, 17, $SS_RIGHT)

;~ start-button
$StartButton = GUICtrlCreateButton("Start", 15, 250, 170, 23)
   GUICtrlSetOnEvent(-1, "GuiButtonHandler")

;~ Farm-settings
$FarmSetup = GUICtrlCreateGroup("Farm Setup", 204, 127, 296, 155)
$collectSkaleClaws = GUICtrlCreateCheckbox("Collect Skale Claws", 214, 142)
$collectSkaleTeeth = GUICtrlCreateCheckbox("Collect Skale Teeth", 214, 162)
$collectSentientSeeds = GUICtrlCreateCheckbox("Collect Sentient Seeds", 214, 182)
$collectSentientRoots = GUICtrlCreateCheckbox("Collect Sentient Roots", 214, 202)
$collectInsectAppendages = GUICtrlCreateCheckbox("Collect Insect Appendages", 214, 222)
$collectScales = GUICtrlCreateCheckbox("Collect Scales", 374, 142)
$collectGoldies = GUICtrlCreateCheckbox("Collect Goldies", 374, 162)
$collectMoney = GUICtrlCreateCheckbox("Collect Money", 374, 182)
$collectRunes = GUICtrlCreateCheckbox("Collect Runes", 374, 202)
$collectKeys = GUICtrlCreateCheckbox("Collect Keys", 374, 222)

$FarmButton = GUICtrlCreateButton("(Un)Select All", 214, 250, 274, 23)
   GUICtrlSetOnEvent(-1, "FarmSetupButton")

GUICtrlSetState($collectSkaleClaws, $GUI_CHECKED)
GUICtrlSetState($collectSkaleTeeth, $GUI_CHECKED)
GUICtrlSetState($collectSentientSeeds, $GUI_CHECKED)
GUICtrlSetState($collectSentientRoots, $GUI_CHECKED)
GUICtrlSetState($collectInsectAppendages, $GUI_CHECKED)
GUICtrlSetState($collectScales, $GUI_CHECKED)
GUICtrlSetState($collectGoldies, $GUI_CHECKED)
GUICtrlSetState($collectMoney, $GUI_CHECKED)
GUICtrlSetState($collectRunes, $GUI_CHECKED)
GUICtrlSetState($collectKeys, $GUI_CHECKED)

;~ statistics
GUICtrlCreateGroup("Statistics", 5, 285, 495, 185)

GUICtrlCreateGroup("Drake Kebob", 11, 305, 158, 130)
$KebobRunsLabel = GUICtrlCreateLabel("Runs:", 20, 330, 31, 17)
$KebobRunsCount = GUICtrlCreateLabel("0", 85, 330, 75, 17, $SS_RIGHT)
$KebobFailsLabel = GUICtrlCreateLabel("Fails:", 20, 350, 31, 17)
$KebobFailsCount = GUICtrlCreateLabel("0", 81, 350, 79, 17, $SS_RIGHT)
$KebobDropsLabel = GUICtrlCreateLabel("Kebobs:", 20, 370, 31, 17)
$KebobDropsCount = GUICtrlCreateLabel("0", 133, 370, 27, 17, $SS_RIGHT)
$KebobAvgTimeLabel = GUICtrlCreateLabel("Average time:", 20, 390, 65, 17)
$KebobAvgTimeCount = GUICtrlCreateLabel("-", 121, 390, 38, 17, $SS_RIGHT)
$KebobTotTimeLabel = GUICtrlCreateLabel("Total time:", 20, 410, 49, 17)
$KebobTotTimeCount = GUICtrlCreateLabel("-", 105, 410, 54, 17, $SS_RIGHT)

GUICtrlCreateGroup("Pahnai Salad", 174, 305, 158, 130)
$SaladRunsLabel = GUICtrlCreateLabel("Runs:", 183, 330, 31, 17)
$SaladRunsCount = GUICtrlCreateLabel("0", 248, 330, 75, 17, $SS_RIGHT)
$SaladFailsLabel = GUICtrlCreateLabel("Fails:", 183, 350, 31, 17)
$SaladFailsCount = GUICtrlCreateLabel("0", 244, 350, 79, 17, $SS_RIGHT)
$SaladDropsLabel = GUICtrlCreateLabel("Salads:", 183, 370, 31, 17)
$SaladDropsCount = GUICtrlCreateLabel("0", 296, 370, 27, 17, $SS_RIGHT)
$SaladAvgTimeLabel = GUICtrlCreateLabel("Average time:", 183, 390, 65, 17)
$SaladAvgTimeCount = GUICtrlCreateLabel("-", 284, 390, 38, 17, $SS_RIGHT)
$SaladTotTimeLabel = GUICtrlCreateLabel("Total time:", 183, 410, 49, 17)
$SaladTotTimeCount = GUICtrlCreateLabel("-", 268, 410, 54, 17, $SS_RIGHT)

GUICtrlCreateGroup("Skalefin Soup", 337, 305, 158, 130)
$SoupRunsLabel = GUICtrlCreateLabel("Runs:", 346, 330, 31, 17)
$SoupRunsCount = GUICtrlCreateLabel("0", 411, 330, 75, 17, $SS_RIGHT)
$SoupFailsLabel = GUICtrlCreateLabel("Fails:", 346, 350, 31, 17)
$SoupFailsCount = GUICtrlCreateLabel("0", 407, 350, 79, 17, $SS_RIGHT)
$SoupDropsLabel = GUICtrlCreateLabel("Soups:", 346, 370, 31, 17)
$SoupDropsCount = GUICtrlCreateLabel("0", 459, 370, 27, 17, $SS_RIGHT)
$SoupAvgTimeLabel = GUICtrlCreateLabel("Average time:", 346, 390, 65, 17)
$SoupAvgTimeCount = GUICtrlCreateLabel("-", 447, 390, 38, 17, $SS_RIGHT)
$SoupTotTimeLabel = GUICtrlCreateLabel("Total time:", 346, 410, 49, 17)
$SoupTotTimeCount = GUICtrlCreateLabel("-", 431, 410, 54, 17, $SS_RIGHT)

$TotalTimeLabel = GUICtrlCreateLabel("Total Time:", 13, 445)
$TotalTimeCount = GUICtrlCreateLabel("-", 90, 445, 54, 17, $SS_RIGHT)

;~ debugging
GUICtrlCreateGroup("", 5, 69, 190, 213)
$StatusLabel = GUICtrlCreateEdit("", 5, 75, 190, 170, 2097220)

GUISetOnEvent($GUI_EVENT_CLOSE, "_exit")
GUISetState(@SW_SHOW)
#EndRegion GUI

#Region Loops
Out("Ready.")
While Not $BotRunning
   CalcTime()
   Sleep(100)
   If _IsChecked($FarmAll) OR _IsChecked($FarmSoup) OR _IsChecked($FarmSalad) OR _IsChecked($FarmKebob) Then
	  If $updatemode Then
		 If _IsChecked($FarmKebob) OR $FarmMode = 1 Then
			Out("Farm Kebob Mode selected Farms only Kebobs without any limits")
			$updatemodeswitch = 1
		 ElseIf _IsChecked($FarmSoup) OR $FarmMode = 3 Then
			Out("Farm All Soup selected Farms only Soups without any limits")
			$updatemodeswitch = 2
		 ElseIf _IsChecked($FarmSalad) OR $FarmMode = 2 Then
			Out("Farm All Salad selected Farms only Salads without any limits")
			$updatemodeswitch = 3
		 ElseIf _IsChecked($FarmAll) Then
			Out("Farm All Mode selected Farms all type of PCons until the goal is reached")
			$updatemodeswitch = 4
		 EndIf
		 $updatemode = false
	  EndIf
	  Switch $updatemodeswitch
			Case 1
			   If NOT _IsChecked($FarmKebob) Then
				  $updatemode = true
				  Out("-:-:-:-:-:- Update -:-:-:-:-:-")
			   EndIf
			Case 2
			   If NOT _IsChecked($FarmSoup) Then
				  $updatemode = true
				  Out("-:-:-:-:-:- Update -:-:-:-:-:-")
			   EndIf
			Case 3
			   If NOT _IsChecked($FarmSalad) Then
				  $updatemode = true
				  Out("-:-:-:-:-:- Update -:-:-:-:-:-")
			   EndIf
			Case 4
			   If NOT _IsChecked($FarmAll) Then
				  $updatemode = true
				  Out("-:-:-:-:-:- Update -:-:-:-:-:-")
			   EndIf
		 EndSwitch
   EndIF
WEnd

AdlibRegister("TimeUpdater", 1000)

While 1
   While (CountSlots() > 4)
	  If Not $BotRunning Then
		 Out("Bot is paused.")
		 GUICtrlSetState($StartButton, $GUI_ENABLE)
		 GUICtrlSetData($StartButton, "Start")
		 GUICtrlSetOnEvent($StartButton, "GuiButtonHandler")
		 While Not $BotRunning
			Sleep(500)
		 WEnd
	  EndIf
	  MainLoop()
   WEnd

   If (CountSlots() < 5) Then
	  If Not $BotRunning Then
		 Out("Bot is paused.")
		 GUICtrlSetState($StartButton, $GUI_ENABLE)
		 GUICtrlSetData($StartButton, "Start")
		 GUICtrlSetOnEvent($StartButton, "GuiButtonHandler")
		 While Not $BotRunning
			Sleep(500)
		 WEnd
	  EndIf
	  Inventory()
   EndIf
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
	  If NOT _IsChecked($FarmKebob) AND NOT _IsChecked($FarmSoup) AND NOT _IsChecked($FarmSalad) AND NOT _IsChecked($FarmAll) Then
		 MsgBox(0, "Error", "Select a farm mode.")
		 Return
	  EndIf

;~ 	  Disable Shit
	  GUICtrlSetState($FarmKebob, $GUI_DISABLE)
	  GUICtrlSetState($FarmSoup, $GUI_DISABLE)
	  GUICtrlSetState($FarmSalad, $GUI_DISABLE)
	  GUICtrlSetState($FarmAll, $GUI_DISABLE)
      GUICtrlSetState($KebobCount, $GUI_DISABLE)
	  GUICtrlSetState($SoupCount, $GUI_DISABLE)
	  GUICtrlSetState($SaladCount, $GUI_DISABLE)

	  Out("Initializing...")
	  Local $CharName = GUICtrlRead($CharInput)
	  If $CharName == "" Then
		 If Initialize(ProcessExists("gw.exe")) = False Then
			   MsgBox(0, "Error", "Guild Wars is not running.")
			   Exit
		 EndIf
	  Else
		 If Initialize($CharName) = False Then
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
	  WinSetTitle($Gui, "", "NF PCons - " & $charname)
	  $BotRunning = True
	  $BotInitialized = True
	  SetMaxMemory()
   EndIf
EndFunc

Func FarmSetupButton()
   If _IsChecked($collectSkaleClaws) AND _IsChecked($collectSentientSeeds) AND _IsChecked($collectSentientRoots) AND _IsChecked($collectKeys) AND _IsChecked($collectInsectAppendages) AND _IsChecked($collectScales) AND _IsChecked($collectGoldies) AND _IsChecked($collectMoney) AND _IsChecked($collectRunes) Then
	  GUICtrlSetState($collectSkaleTeeth, $GUI_UNCHECKED)
	  GUICtrlSetState($collectSentientSeeds, $GUI_UNCHECKED)
	  GUICtrlSetState($collectSkaleClaws, $GUI_UNCHECKED)
	  GUICtrlSetState($collectSentientRoots, $GUI_UNCHECKED)
	  GUICtrlSetState($collectInsectAppendages, $GUI_UNCHECKED)
	  GUICtrlSetState($collectScales, $GUI_UNCHECKED)
	  GUICtrlSetState($collectGoldies, $GUI_UNCHECKED)
	  GUICtrlSetState($collectMoney, $GUI_UNCHECKED)
	  GUICtrlSetState($collectRunes, $GUI_UNCHECKED)
	  GUICtrlSetState($collectKeys, $GUI_UNCHECKED)
   Else
	  GUICtrlSetState($collectSkaleTeeth, $GUI_CHECKED)
	  GUICtrlSetState($collectSkaleClaws, $GUI_CHECKED)
	  GUICtrlSetState($collectSentientSeeds, $GUI_CHECKED)
	  GUICtrlSetState($collectSentientRoots, $GUI_CHECKED)
	  GUICtrlSetState($collectInsectAppendages, $GUI_CHECKED)
	  GUICtrlSetState($collectScales, $GUI_CHECKED)
	  GUICtrlSetState($collectGoldies, $GUI_CHECKED)
	  GUICtrlSetState($collectMoney, $GUI_CHECKED)
	  GUICtrlSetState($collectRunes, $GUI_CHECKED)
	  GUICtrlSetState($collectKeys, $GUI_CHECKED)
   EndIf
EndFunc

Func ToogleOnTop()
   If _IsChecked($cbxOnTop) Then
	  WinSetOnTop($GUI, "", $WINDOWS_ONTOP)
   Else
	  WinSetOnTop($GUI, "", $WINDOWS_NOONTOP)
   EndIf
   Return True
EndFunc

Func CalcTime()
   $hh = Floor((GUICtrlRead($KebobCount) / 0.314 + GUICtrlRead($SaladCount) / 0.221 + GUICtrlRead($SoupCount) / 0.20) / 60)
   $mm = Round((GUICtrlRead($KebobCount) / 0.314 + GUICtrlRead($SaladCount) / 0.221 + GUICtrlRead($SoupCount) / 0.20) - $hh * 60, 0)
   GUICtrlSetData($sumCount, $hh & " h   " & $mm & " min")
EndFunc

Func SetUp()
	SetUpFastWay()
EndFunc

Func SetUpFastWay()
   If _IsChecked($FarmKebob) OR $FarmMode = 1 OR $FarmMode = 1 Then
	  Out("Setting up resign")
	  Zone()
	  Move(-15460, 9366)
	  WaitMapLoading(425)
	  RndSleep(500)
	  Return True
   EndIf
   If _IsChecked($FarmSoup) OR $FarmMode = 3 Then
	  Out("Setting up resign")
	  Zone()
	  UseSkillEx(5, -2)
	  MoveTo(20107, 11149)
	  MoveTo(20236, 9738)
	  Move(20407, 9064)
	  WaitMapLoading(491)
	  RndSleep(500)
	  Return True
   EndIf
   If _IsChecked($FarmSalad) OR $FarmMode = 2 Then
	  Out("Setting up resign")
	  Zone()
	  UseSkillEx(8, -2)
	  Move(18403, -1805)
	  WaitMapLoading(449)
	  RndSleep(500)
	  Return True
   EndIf
EndFunc

Func Zone_Fast_Way()
   If _IsChecked($FarmKebob) OR $FarmMode = 1 Then
	  Out("Zoning.")
	  Move(-15300, 9000)
	  WaitMapLoading(384)
	  RndSleep(500)
	  Return True
   EndIf
   If _IsChecked($FarmSoup) OR $FarmMode = 3 Then
	  Out("Zoning.")
	  MoveTo(-2328, -1018)
	  Move(-2800, -1030)
	  WaitMapLoading(481)
	  RndSleep(500)
	  Return True
   EndIf
   If _IsChecked($FarmSalad) OR $FarmMode = 2 Then
	  Out("Zoning.")
	  Move(-9300, 16850)
	  WaitMapLoading(430)
	  RndSleep(500)
	  Return True
   EndIf
EndFunc

Func Zone()
   If GetMapLoading() == 2 Then Disconnected()
;~    ----------------------------------------------------------------------------------------------
If _IsChecked($FarmKebob) OR $FarmMode = 1 Then
   Local $Me = GetAgentByID(-2)
   Local $X = DllStructGetData($Me, 'X')
   Local $Y = DllStructGetData($Me, 'Y')
   If ComputeDistance($X, $Y, -14851, 10767) < 750 Then
	  MoveTo(-15480, 11138)
	  MoveTo(-16009, 10219)
	  Move(-15300, 9000)
	  WaitMapLoading(384)
	  Return
   EndIf
   If ComputeDistance($X, $Y, -15410, 12097) < 750 Then
	  MoveTo(-15480, 11138)
	  MoveTo(-16009, 10219)
	  Move(-15300, 9000)
	  WaitMapLoading(384)
	  Return
   EndIf
   If ComputeDistance($X, $Y, -15753, 9831) < 750 Then
	  Move(-15300, 9000)
	  WaitMapLoading(384)
	  Return
   EndIf
   If ComputeDistance($X, $Y, -15950, 10325) < 750 Then
	  Move(-15300, 9000)
	  WaitMapLoading(384)
	  Return
   EndIf
   MoveTo(-16009, 10219)
   Move(-15300, 9000)
   WaitMapLoading(384)
   Return
EndIf
;~    ----------------------------------------------------------------------------------------------
If _IsChecked($FarmSoup) OR $FarmMode = 3 Then
   If GetMapLoading() == 2 Then Disconnected()
   Local $Me = GetAgentByID(-2)
   Local $X = DllStructGetData($Me, 'X')
   Local $Y = DllStructGetData($Me, 'Y')
   If ComputeDistance($X, $Y, -1449, -929) < 750 Then
	  MoveTo(-2328, -1018)
	  Move(-2800, -1030)
	  WaitMapLoading(481)
	  Return
   EndIf
   MoveTo(828, 21)
   MoveTo(-93, 29)
   MoveTo(-1867, -1010)
   MoveTo(-2328, -1018)
   Move(-2800, -1030)
   WaitMapLoading(481)
EndIf
;~    ----------------------------------------------------------------------------------------------
If _IsChecked($FarmSalad) OR $FarmMode = 2 Then
   If GetMapLoading() == 2 Then Disconnected()
   Local $Me = GetAgentByID(-2)
   Local $X = DllStructGetData($Me, 'X')
   Local $Y = DllStructGetData($Me, 'Y')
   If ComputeDistance($X, $Y, -9167, 13288) < 750 Then
	  MoveTo(-8296, 13573)
	  MoveTo(-9210, 16369)
	  Move(-9300, 16850)
	  WaitMapLoading(430)
	  Return
   EndIf
   If ComputeDistance($X, $Y, -9165, 10969) < 750 Then
	  MoveTo(-8296, 13573)
	  MoveTo(-9210, 16369)
	  Move(-9300, 16850)
	  WaitMapLoading(430)
	  Return
   EndIf
   If ComputeDistance($X, $Y, -8265, 9489) < 750 Then
	  MoveTo(-8296, 13573)
	  MoveTo(-9210, 16369)
	  Move(-9300, 16850)
	  WaitMapLoading(430)
	  Return
   EndIf
   If ComputeDistance($X, $Y, -8196, 14153) < 750 Then
	  MoveTo(-9210, 16369)
	  Move(-9300, 16850)
	  WaitMapLoading(430)
	  Return
   EndIf
   MoveTo(-8316, 12136)
   MoveTo(-8296, 13573)
   MoveTo(-9210, 16369)
   Move(-9300, 16850)
   WaitMapLoading(430)
EndIf
;~    ----------------------------------------------------------------------------------------------
EndFunc

Func MainLoop()
   If _IsChecked($FarmKebob) OR $FarmMode = 1 Then
	  FarmKebobLoop()
   EndIf
   If _IsChecked($FarmSoup) OR $FarmMode = 3 Then
	  FarmSoupLoop()
   EndIf
   If _IsChecked($FarmSalad) OR $FarmMode = 2 Then
	  FarmSaladLoop()
   EndIf
   If _IsChecked($FarmAll) Then
	  FarmAllLoop()
   EndIf
EndFunc

#Region KebobFarmer
Func FarmKebobLoop()
   If GetMapID() == 425 Then
	  ChangeWeaponSet($WEAPON_SLOT_SHIELD)
	  Zone_Fast_Way()
   Else
	  Setup()
	  Zone_Fast_Way()
   EndIf
   Out("Running to Drakes.")
   $hostarget = -2
   KebobMoveRun(-14601, 8152)
   KebobMoveRun(-13818, 8380)
   $Me     = GetAgentPtr(-2)
   $MeID     = MemoryRead($Me + 44, 'long')
;~ Give Speedboost and kill Koss
   SendPacket(0x14, 0x1f, GetHeroId(1), $SKILLID_Charge, 0,$MeID); Use Charge
   SendPacket(0x14, 0x1f, GetHeroId(1), $SKILLID_BraceYourself, 0,$MeID); Use Brace Yourself
   SendPacket(0x14, 0x1f, GetHeroId(1), $SKILLID_BladeturnRefrain, 0,$MeID); Use Bladeturn Refrain
   KillKoss()

;~ Moveto farming spot
   KebobMoveRun(-12619, 9609)
   KebobMoveRun(-11893, 10517)
   KebobMoveRun(-10873, 10792)
   Kebobfirstcasting()
   KebobMoveRun(-10311, 10672)
   KebobMoveRun(-9961, 10971)
   KebobMoveRun(-9646, 11303)
   KebobMoveRun(-8922, 11625)
   $hostarget = GetCurrentTargetID()
   Sleep(Random(300,400))
   $iii = 0
   Do
	  Sleep(50)
	  $iii += 1
   Until (GetDistance(GetAgentByID(-2), $hostarget) < 900) OR (GetIsDead(-2)) OR ($iii >= 600)
   If IsRecharged(8) Then UseSkillEx(8, $hostarget)
   KebobMoveRun(-8237, 11510)
   Sleep(1000)

   Kebobsettling()
   KebobKill()

;~ Statistics
   If GetIsDead(-2) Then
	  $KebobFails += 1
	  Out("I'm dead.")
	  GUICtrlSetData($KebobFailsCount, $KebobFails)
   Else
	  $KebobRuns += 1
	  Out("Completed in " & GetTime() & ".")
	  GUICtrlSetData($KebobRunsCount, $KebobRuns)
	  GUICtrlSetData($KebobAvgTimeCount, KebobAvgTime())
   EndIf

   If GUICtrlRead($RenderingBox) == $GUI_CHECKED Then ClearMemory()
   Out("Returning to Rilohn.")

   Resign()
   RndSleep(5000)
   ReturnToOutpost()
   WaitMapLoading(425)
   RndSleep(500)
EndFunc

Func Kebobfirstcasting()
   If GetIsDead(-2) Then Return
   TargetNearestEnemy()
   If GetDistance(GetAgentByID(-2), GetAgentByID(-1)) <= 1450 Then KebobMoveRun(-10552, 10867)
   TargetNearestEnemy()
   If IsRecharged(5) Then UseSkillEx(5, -2)
   If IsRecharged(7) Then UseSkillEx(7, -2)
   If IsRecharged(1) Then UseSkillEx(1, -2)
EndFunc

Func Kebobsettling()
   Local $ii=0
   If GetIsDead(-2) Then Return
   Out("Waiting for settle.")
   SendChat("stuck", "/")
   KebobWaitForSettle(1250, 210)
   Out("Settled!")
   If KebobGetNumberOfFoesInRangeOfAgent(-2, 900) <= 7 Then
	  If IsRecharged(6) Then UseSkillEx(6, -2)
	  Out("Waiting for Group 2.")
	  Do
		 $ii += 1
		 If GetIsDead(-2) Then ExitLoop
		 If GetEffectTimeRemaining($SKILLID_Intimidating_Aura) <= 0 Then UseSkillEx(5, -2)
		 If GetEffectTimeRemaining($SKILLID_Mystic_Regeneration) <= 0 Then UseSkillEx(7, -2)
		 If GetEffectTimeRemaining($SKILLID_Sand_Shards) <= 0 And IsRecharged(1) Then UseSkillEx(1, -2)
		 Sleep(100)
	  Until KebobGetNumberOfFoesInRangeOfAgent(-2, 210) > 7 OR $ii > 3000 ;5min
	  Out("Group 2 settled!")
	  If GetEffectTimeRemaining($SKILLID_Armor_of_Sanctity) <= 0 Then UseSkillEx(6, -2)
   EndIf
   Sleep(500)
EndFunc

Func DisableHeroSkills()
	For $i = 1 to 8
		DisableHeroSkillSlot(1, $i)
	Next
EndFunc

Func KillKoss()
   If GetMapID() <> 384 Then Return
   CommandHero(1, -16749, 5382)
   Sleep(Random(150, 350))
EndFunc

Func KebobMoveRun($DestX, $DestY)
   If GetMapLoading() == 2 Then Disconnected()
   If GetIsDead(-2) Then Return
   Local $Me, $Angle
   Local $Blocked = 0
   Move($DestX, $DestY)
   Do
	  If GetMapLoading() == 2 Then Disconnected()
	  $Me = GetAgentByID(-2)
	  If GetIsDead(-2) Then Return
	  If (DllStructGetData($Me, 'MoveX') == 0 Or DllStructGetData($Me, 'MoveY') == 0) AND NOT GetIsKnocked(-2) Then
		 $Blocked += 1
		 If $Blocked <= 5 Then
			Move($DestX, $DestY)
		 ElseIf $Blocked > 5 AND $Blocked <= 6 Then
			$Me = GetAgentByID(-2)
			$X = Round(DllStructGetData($Me, 'X'), 2)
			$Y = Round(DllStructGetData($Me, 'Y'), 2)
			Out("Blocked at Position: " & $X & ":" & $Y & ". Try to unstuck.")
			$Angle += 35
			Move(DllStructGetData($Me, 'X')+300*sin($Angle), DllStructGetData($Me, 'Y')+300*cos($Angle))
			Sleep(2000)
			Move($DestX, $DestY)
		 ElseIf $Blocked > 6 AND $Blocked <= 20 Then
			Sleep(Random(2400,2600))
			If IsRecharged(8) Then UseSkillEx(8, $hostarget)
			Move($DestX, $DestY)
		 Else
			Out("To much stucked, resign.")
			Resign()
			Sleep(2000)
			ExitLoop
		 EndIf
	  EndIF
	  If GetIsKnocked(-2) Then
		 Out("Knocked...")
		 Do
			If GetIsDead(-2) Then ExitLoop
			Sleep(100)
		 Until NOT GetIsKnocked(-2)
	  EndIf
	  RndSleep(250)
   Until ComputeDistance(DllStructGetData($Me, 'X'), DllStructGetData($Me, 'Y'), $DestX, $DestY) < 250
EndFunc

Func KebobKill()
   If GetMapLoading() == 2 Then Disconnected()
   If GetIsDead(-2) Then Return
   ChangeWeaponSet($WEAPON_SLOT_SCYTHE)
   If IsRecharged(6) Then UseSkillEx(6, -2)
   If IsRecharged(2) Then UseSkillEx(2, -2)
   If IsRecharged(3) Then UseSkillEx(3, -2)
   TargetNearestEnemy()
   If IsRecharged(4) Then UseSkillEx(4, -1)
   If IsRecharged(1) Then UseSkillEx(1, -2)
   While KebobGetNumberOfFoesInRangeOfAgent() > 0
	  If GetMapLoading() == 2 Then Disconnected()
	  If GetIsDead(-2) Then Return
	  TargetNearestEnemy()
	  If GetEffectTimeRemaining($SKILLID_Intimidating_Aura) <= 0 Then UseSkillEx(5, -2)
	  If GetEffectTimeRemaining($SKILLID_Armor_of_Sanctity) <= 0 Then UseSkillEx(6, -2)
	  If GetEffectTimeRemaining($SKILLID_Mystic_Regeneration) <= 0 Then UseSkillEx(7, -2)
	  If GetEffectTimeRemaining($SKILLID_Sand_Shards) <= 0 And KebobGetNumberOfFoesInRangeOfAgent(-2,300) > 1 Then UseSkillEx(1, -2)
	  If GetEffectTimeRemaining($SKILLID_VOS) <= 0 Then UseSkillEx(2, -2)
	  Sleep(100)
	  Attack(-1)
	  If IsRecharged(3) AND IsRecharged(4) AND GetEnergy(-2) >= 9 Then
		 If IsRecharged(3) Then UseSkillEx(3, -2)
		 TargetNearestEnemy()
		 If IsRecharged(4) Then UseSkillEx(4, -1)
	  EndIf
   WEnd
   ChangeWeaponSet($WEAPON_SLOT_SHIELD)
   KebobPickUpLoot()
EndFunc

Func KebobWaitForSettle($FarRange,$CloseRange,$Timeout = 10000)
   If GetMapLoading() == 2 Then Disconnected()
   Local $Target
   Local $Deadlock = TimerInit()
   Do
	  If GetMapLoading() == 2 Then Disconnected()
	  If GetIsDead(-2) Then Return
	  If DllStructGetData(GetAgentByID(-2), "HP") < 0.4 Then Return
	  If GetEffectTimeRemaining($SKILLID_Intimidating_Aura) <= 0 Then UseSkillEx(5, -2)
	  If GetEffectTimeRemaining($SKILLID_Mystic_Regeneration) <= 0 Then UseSkillEx(7, -2)
	  Sleep(50)
	  $Target = KebobGetFarthestEnemyToAgent(-2,$FarRange)
   Until KebobGetNumberOfFoesInRangeOfAgent(-2,900) > 0 Or (TimerDiff($Deadlock) > $Timeout)
   Local $Deadlock = TimerInit()
   Do
	  If GetMapLoading() == 2 Then Disconnected()
	  If GetIsDead(-2) Then Return
	  If DllStructGetData(GetAgentByID(-2), "HP") < 0.4 Then Return
	  If GetEffectTimeRemaining($SKILLID_Intimidating_Aura) <= 0 Then UseSkillEx(5, -2)
	  If GetEffectTimeRemaining($SKILLID_Mystic_Regeneration) <= 0 Then UseSkillEx(7, -2)
	  Sleep(50)
	  $Target = KebobGetFarthestEnemyToAgent(-2,$FarRange)
   Until (GetDistance(-2, $Target) < $CloseRange) Or (TimerDiff($Deadlock) > $Timeout)
EndFunc

Func KebobGetFarthestEnemyToAgent($aAgent = -2, $aDistance = 1250)
   If GetMapLoading() == 2 Then Disconnected()
   Local $lFarthestAgent, $lFarthestDistance = 0
   Local $lDistance, $lAgent, $lAgentArray = GetAgentArray(0xDB)
   If Not IsDllStruct($aAgent) Then $aAgent = GetAgentByID($aAgent)
   For $i = 1 To $lAgentArray[0]
	  $lAgent = $lAgentArray[$i]
	  If DllStructGetData($lAgent, 'HP') <= 0 Then ContinueLoop
	  If DllStructGetData($lAgent, 'Allegiance') <> 3 Then ContinueLoop
	  $lDistance = GetDistance($lAgent)
	  If $lDistance > $lFarthestDistance And $lDistance < $aDistance Then
		 $lFarthestAgent = $lAgent
		 $lFarthestDistance = $lDistance
	  EndIf
   Next
   Return $lFarthestAgent
EndFunc

Func KebobGetNumberOfFoesInRangeOfAgent($aAgent = -2, $aRange = 1250)
   If GetMapLoading() == 2 Then Disconnected()
   Local $lAgent, $lDistance
   Local $lCount = 0, $lAgentArray = GetAgentArray(0xDB)
   If Not IsDllStruct($aAgent) Then $aAgent = GetAgentByID($aAgent)
   For $i = 1 To $lAgentArray[0]
	  $lAgent = $lAgentArray[$i]
	  If DllStructGetData($lAgent, 'HP') <= 0 Then ContinueLoop
	  If DllStructGetData($lAgent, 'Allegiance') <> 3 Then ContinueLoop
	  If GetDistance($lAgent) > $aRange Then ContinueLoop
	  $lCount += 1
   Next
   Return $lCount
EndFunc

Func KebobPickUpLoot()
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
			   Sleep(3)
			   $lItemExists = IsDllStruct(GetAgentByID($i))
			Until Not $lItemExists Or TimerDiff($lBlockedTimer) > Random(5000, 7500, 1)
			If $lItemExists Then $lBlockedCount += 1
		 Until Not $lItemExists Or $lBlockedCount > 5
	  EndIf
   Next
EndFunc
#EndRegion KebobFarmer

#Region SoupFamer
Func FarmSoupLoop()

   If GetMapID() == 491 Then
	  ChangeWeaponSet($WEAPON_SLOT_SHIELD)
	  Zone_Fast_Way()
   Else
	  Setup()
	  Zone_Fast_Way()
   EndIf

   UseSkillEx(1, -2)
   UseSkillEx(7, -2)
   UseSkillEx(5, -2)
   Out("Running to Group 1")

   TargetNearestEnemy()
   Sleep(200)
   $FirstEnemy = GetAgentByID(-1)
   UseSkillEx(6, $FirstEnemy)
   SoupKill()				  ;gruppe 1 tot
   Out("Running to Group 2")
   SoupMoveRun(16103, 13203)
   SoupMoveRun(14753, 13457)
   SoupMoveRun(13167, 13228) ;ende brücke
   SoupMoveRun(12789, 13557)
   SoupMoveRun(12658, 13980)
   SoupMoveRun(12010, 14136)
   SoupMoveRun(11743, 14553)
   SoupMoveRun(11142, 14730)
   SoupMoveKill(11142, 14730) ;gruppe 2 tot
   Out("Running to Group 3")
   SoupMoveKill(10715, 17440)
   SoupMoveKill(10307, 18717)
   SoupMoveKill(8903, 19227) ;gruppe 3 tot
   Out("Running to Group 4")
   SoupMoveRun(7358, 18528)
   SoupMoveRun(5709, 16922)
   SoupMoveRun(4709, 16707)
   SoupMoveRun(4664, 16653)
   SoupMoveRun(3462, 16906)
   SoupMoveRun(3042, 16926)
   SoupMoveRun(1717, 16438)
   SoupMoveKill(843, 15763) ;gruppe 4 tot
   Out("Running to HotSpot")
   SoupMoveRun(1271, 13934)
   SoupMoveRun(2003, 14201)
   Out("Killing HotSpot")
   SoupKill2()

   If GetIsDead(-2) Then
	  $SoupFails += 1
	  Out("I'm dead.")
	  GUICtrlSetData($SoupFailsCount,$SoupFails)
   Else
	  $SoupRuns += 1
	  Out("Completed in " & GetTime() & ".")
	  GUICtrlSetData($SoupRunsCount,$SoupRuns)
	  GUICtrlSetData($SoupAvgTimeCount,SoupAvgTime())
   EndIf

   If GUICtrlRead($RenderingBox) == $GUI_CHECKED Then ClearMemory()
   Out("Returning to Jokanur.")

   Resign()
   RndSleep(5000)
   ReturnToOutpost()
   WaitMapLoading(491)
   RndSleep(500)
EndFunc

Func SoupMoveRun($DestX, $DestY)
   If GetMapLoading() == 2 Then Disconnected()
   If GetIsDead(-2) Then Return
   Local $Me, $Angle
   Local $Blocked = 0
   If GetEffectTimeRemaining(2218) <= 0 Then UseSkillEx(5, -2)
   Move($DestX, $DestY)
   Do
	  If GetMapLoading() == 2 Then Disconnected()
	  $Me = GetAgentByID(-2)
	  If GetIsDead(-2) Then Return
	  If GetEffectTimeRemaining(2218) <= 0 Then UseSkillEx(5, -2)
	  If (DllStructGetData($Me, 'MoveX') == 0 Or DllStructGetData($Me, 'MoveY') == 0) Then
		 $Blocked += 1
		 If $Blocked <= 5 Then
			Move($DestX, $DestY)
		 ElseIf $Blocked > 5 AND $Blocked <= 10 Then
			$Me = GetAgentByID(-2)
			$X = Round(DllStructGetData($Me, 'X'), 2)
			$Y = Round(DllStructGetData($Me, 'Y'), 2)
			Out("Blocked at Position: " & $X & ":" & $Y & ". Try to unstuck.")
			$Angle += 35
			Move(DllStructGetData($Me, 'X')+300*sin($Angle), DllStructGetData($Me, 'Y')+300*cos($Angle))
			Sleep(2000)
			Move($DestX, $DestY)
		 ElseIf $Blocked > 10 AND $Blocked <= 11 Then
			$Me = GetAgentByID(-2)
			$X = Round(DllStructGetData($Me, 'X'), 2)
			$Y = Round(DllStructGetData($Me, 'Y'), 2)
			Out("Blocked at Position: " & $X & ":" & $Y & ". Kill me free.")
			TargetNearestEnemy()
			If IsRecharged(1) Then UseSkillEx(1, -2)
			If IsRecharged(2) Then UseSkillEx(2, -2)
			If IsRecharged(3) Then UseSkillEx(3, -2)
			If IsRecharged(4) Then UseSkillEx(4, -1)
			Sleep(2000)
			Move($DestX, $DestY)
		 Else
			Out("To much stucked, resign.")
			Resign()
			Sleep(2000)
			ExitLoop
		 EndIf
	  EndIF
	  RndSleep(250)
   Until ComputeDistance(DllStructGetData($Me, 'X'), DllStructGetData($Me, 'Y'), $DestX, $DestY) < 250
EndFunc

Func SoupMoveKill($DestX, $DestY)
   If GetMapLoading() == 2 Then Disconnected()
   If GetIsDead(-2) Then Return
   Local $Me, $Angle
   Local $Blocked = 0
   Move($DestX, $DestY)
   Do
	  If GetMapLoading() == 2 Then Disconnected()
	  If IsRecharged(5) Then UseSkillEx(5, -2)
	  If DllStructGetData($Me, "HP") < 0.8 Then
		 If GetEffectTimeRemaining(1516) <= 0 Then UseSkillEx(8, -2)
		 If GetEffectTimeRemaining(1531) <= 0 Then UseSkillEx(7, -2)
		 If GetEffectTimeRemaining(1510) <= 0 AND IsRecharged(1) Then UseSkillEx(1, -2)
	  EndIf
	  TargetNearestEnemy()
	  $Me = GetAgentByID(-2)
	  If GetIsDead(-2) Then Return
	  If SoupGetNumberOfFoesInRangeOfAgent(-2, 1200) > 1 Then SoupKill()
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

Func SoupKill()
   Local $jumptarget
   If GetMapLoading() == 2 Then Disconnected()
   If GetIsDead(-2) Then Return
   If GetEffectTimeRemaining(1516) <= 0 Then UseSkillEx(8, -2)
   If GetEffectTimeRemaining(1531) <= 0 Then UseSkillEx(7, -2)
   If GetEffectTimeRemaining(1510) <= 0 AND IsRecharged(1) Then UseSkillEx(1, -2)
   If IsRecharged(5) Then UseSkillEx(5, -2)

   TargetNearestEnemy()
   If NonMeleeInRange(-2, 1500) > 0 Then
	  Do
		 TargetNextEnemy()
		 $TargetAgent = GetAgentByID(-1)
		 Sleep(100)
	  Until DllStructGetData($TargetAgent, "PlayerNumber") = 4367 OR DllStructGetData($TargetAgent, "PlayerNumber") = 4379 OR DllStructGetData($TargetAgent, "PlayerNumber") = 4377
	  Sleep(500)
	  If IsRecharged(6) Then UseSkillEx(6, $TargetAgent)
	  ChangeTarget($TargetAgent)
   EndIf
   SoupWaitForSettle(1000, 210)
   ChangeWeaponSet($WEAPON_SLOT_SCYTHE)
   TargetNearestEnemy()
   If IsRecharged(2) Then UseSkillEx(2, -2)
   If IsRecharged(3) Then UseSkillEx(3, -2)
   If IsRecharged(4) Then UseSkillEx(4, -1)

   RndSleep(200)
   SoupPickUpLoot()

   While SoupGetNumberOfFoesInRangeOfAgent(-2, 1250) > 0
	  If GetMapLoading() == 2 Then Disconnected()
	  If GetIsDead(-2) Then Return
	  TargetNearestEnemy()
	  If GetEffectTimeRemaining(1516) <= 0 Then UseSkillEx(8, -2)
	  If GetEffectTimeRemaining(1531) <= 0 Then UseSkillEx(7, -2)
	  If GetEffectTimeRemaining(1510) <= 0 AND IsRecharged(1) AND SoupGetNumberOfFoesInRangeOfAgent(-2,300) > 1 Then UseSkillEx(1, -2)
	  If GetEffectTimeRemaining(1759) <= 0 Then UseSkillEx(2, -2)
	  Sleep(100)
	  If IsRecharged(3) Then
		 If IsRecharged(3) Then UseSkillEx(3, -2)
		 If IsRecharged(4) Then UseSkillEx(4, -1)
	  Else
		 Attack(-1)
	  EndIf

	  RndSleep(200)
	  SoupPickUpLoot()
   WEnd
   RndSleep(200)
   SoupPickUpLoot()
   RndSleep(200)
   ChangeWeaponSet($WEAPON_SLOT_SHIELD)
EndFunc

Func SoupKill2()
   If GetMapLoading() == 2 Then Disconnected()
   If GetIsDead(-2) Then Return
   If GetEffectTimeRemaining(1516) <= 0 Then UseSkillEx(8, -2)
   If GetEffectTimeRemaining(1531) <= 0 Then UseSkillEx(7, -2)
   If GetEffectTimeRemaining(1510) <= 0 AND IsRecharged(1) Then UseSkillEx(1, -2)
   If IsRecharged(5) Then UseSkillEx(5, -2)

   ChangeWeaponSet($WEAPON_SLOT_SCYTHE)
   TargetNearestEnemy()
   If IsRecharged(2) Then UseSkillEx(2, -2)
   If IsRecharged(6) Then UseSkillEx(6, -1)
   If IsRecharged(3) And IsRecharged(4) Then
	  UseSkillEx(3, -2)
	  UseSkillEx(4, -1)
   EndIf

   While SoupGetNumberOfFoesInRangeOfAgent(-2, 1250) > 0
	  If GetMapLoading() == 2 Then Disconnected()
	  If GetIsDead(-2) Then Return
	  TargetNearestEnemy()
	  If GetEffectTimeRemaining(1516) <= 0 Then UseSkillEx(8, -2)
	  If GetEffectTimeRemaining(1531) <= 0 Then UseSkillEx(7, -2)
	  If GetEffectTimeRemaining(1510) <= 0 AND IsRecharged(1) AND SoupGetNumberOfFoesInRangeOfAgent(-2,300) > 1 Then UseSkillEx(1, -2)
	  If GetEffectTimeRemaining(1759) <= 0 Then UseSkillEx(2, -2)
	  Sleep(100)

	  If IsRecharged(3) And IsRecharged(4) Then
		 UseSkillEx(3, -2)
		 UseSkillEx(4, -1)
	  Else
		 Attack(-1)
	  EndIf
   WEnd

   RndSleep(200)
   SoupPickUpLoot()
   RndSleep(200)
   ChangeWeaponSet($WEAPON_SLOT_SHIELD)
EndFunc

Func SoupWaitForSettle($FarRange,$CloseRange,$Timeout = 10000)
   If GetMapLoading() == 2 Then Disconnected()
   Local $Target
   Local $Deadlock = TimerInit()
   Do
	  If GetMapLoading() == 2 Then Disconnected()
	  If GetIsDead(-2) Then Return
	  If DllStructGetData(GetAgentByID(-2), "HP") < 0.4 Then Return
	  If GetEffectTimeRemaining(1516) <= 0 Then UseSkillEx(8, -2)
	  If GetEffectTimeRemaining(1531) <= 0 Then UseSkillEx(7, -2)
	  If GetEffectTimeRemaining(1510) <= 0 AND IsRecharged(1) Then UseSkillEx(1, -2)
	  Sleep(50)
	  $Target = SoupGetFarthestEnemyToAgent(-2,$FarRange)
   Until SoupGetNumberOfFoesInRangeOfAgent(-2,900) > 0 Or (TimerDiff($Deadlock) > $Timeout)
   Local $Deadlock = TimerInit()
   Do
	  If GetMapLoading() == 2 Then Disconnected()
	  If GetIsDead(-2) Then Return
	  If DllStructGetData(GetAgentByID(-2), "HP") < 0.4 Then Return
	  If GetEffectTimeRemaining(1516) <= 0 Then UseSkillEx(8, -2)
	  If GetEffectTimeRemaining(1531) <= 0 Then UseSkillEx(7, -2)
	  If GetEffectTimeRemaining(1510) <= 0 AND IsRecharged(1) Then UseSkillEx(1, -2)
	  Sleep(50)
	  $Target = SoupGetFarthestEnemyToAgent(-2,$FarRange)
   Until (GetDistance(-2, $Target) < $CloseRange) Or (TimerDiff($Deadlock) > $Timeout)
EndFunc

Func SoupGetFarthestEnemyToAgent($aAgent = -2, $aDistance = 1250)
   If GetMapLoading() == 2 Then Disconnected()
   Local $lFarthestAgent, $lFarthestDistance = 0
   Local $lDistance, $lAgent, $lAgentArray = GetAgentArray(0xDB)
   If Not IsDllStruct($aAgent) Then $aAgent = GetAgentByID($aAgent)
   For $i = 1 To $lAgentArray[0]
	  $lAgent = $lAgentArray[$i]
	  If DllStructGetData($lAgent, 'Allegiance') <> 3 Then ContinueLoop
	  If DllStructGetData($lAgent, 'HP') <= 0 Then ContinueLoop
	  If DllStructGetData($lAgent, 'PlayerNumber') == 4367 Then ContinueLoop	;Frost
	  If DllStructGetData($lAgent, 'PlayerNumber') == 4377 Then ContinueLoop	;Wurm
	  If DllStructGetData($lAgent, 'PlayerNumber') == 4379 Then ContinueLoop	;Beute
	  $lDistance = GetDistance($lAgent)
	  If $lDistance > $lFarthestDistance And $lDistance < $aDistance Then
		 $lFarthestAgent = $lAgent
		 $lFarthestDistance = $lDistance
	  EndIf
   Next
   Return $lFarthestAgent
EndFunc

Func SoupGetNumberOfFoesInRangeOfAgent($aAgent = -2, $aRange = 1250)
   If GetMapLoading() == 2 Then Disconnected()
   Local $lAgent, $lDistance
   Local $lCount = 0, $lAgentArray = GetAgentArray(0xDB)
   If Not IsDllStruct($aAgent) Then $aAgent = GetAgentByID($aAgent)
   For $i = 1 To $lAgentArray[0]
	  $lAgent = $lAgentArray[$i]
	  If DllStructGetData($lAgent, 'Allegiance') <> 3 Then ContinueLoop
	  If DllStructGetData($lAgent, 'HP') <= 0 Then ContinueLoop
	  $lDistance = GetDistance($lAgent)
	  If $lDistance > $aRange Then ContinueLoop
	  $lCount += 1
   Next
   Return $lCount
EndFunc

Func NonMeleeInRange($aAgent = -2, $aRange = 1350)
   If GetMapLoading() == 2 Then Disconnected()
   Local $lAgent, $lDistance
   Local $lCount = 0, $lAgentArray = GetAgentArray(0xDB)
   If Not IsDllStruct($aAgent) Then $aAgent = GetAgentByID($aAgent)
   For $i = 1 To $lAgentArray[0]
	  $lAgent = $lAgentArray[$i]
	  If DllStructGetData($lAgent, 'Allegiance') <> 3 Then ContinueLoop
	  If DllStructGetData($lAgent, 'HP') <= 0 Then ContinueLoop
	  $lDistance = GetDistance($lAgent)
	  If $lDistance > $aRange Then ContinueLoop
	  If DllStructGetData($lAgent, 'PlayerNumber') == 4367 Then $lCount += 1	;Frost
	  If DllStructGetData($lAgent, 'PlayerNumber') == 4377 Then $lCount += 1	;Wurm
	  If DllStructGetData($lAgent, 'PlayerNumber') == 4379 Then $lCount += 1	;Beute
   Next
   Return $lCount
EndFunc

Func SoupPickUpLoot()
   If GetMapLoading() == 2 Then Disconnected()
   If GetIsDead(-2) Then Return
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
			If IsRecharged(5) Then UseSkillEx(5, -2)
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
#EndRegion SoupFarmer

#Region SaladFarmer
Func FarmSaladLoop()
   If GetMapID() == 449 Then
	  ChangeWeaponSet($WEAPON_SLOT_SHIELD)
	  Zone_Fast_Way()
   Else
	  Setup()
	  Zone_Fast_Way()
   EndIf

   Local $AmountOfIbogaInRange

   UseSkill(7, -2)
   Sleep(Random(1010,1030))
   UseSkill(8, -2)

   $i=1
   Out("Running to " & $i & "st Iboga.")
   KillNextIboga()
   $i += 1
   Out("Running to " & $i & "nd Iboga.")
   KillNextIboga()
   $i += 1
   SaladMoveRun(12803, 3328)
   Out("Running to " & $i & "rd Iboga.")
   KillNextIboga()
   $i += 1
   SaladMoveRun(13827, 5193)
   Out("Running to " & $i & "th Iboga.")
   KillNextIboga()
   $i += 1
   Out("Running to " & $i & "th Iboga.")
   KillNextIboga()
   $i += 1

   Out("Running to Iboga-HotSpot")
   SaladMoveRun(14988, 9298)
   SaladMoveRun(14856, 10493)
   SaladMoveRun(14443, 11181)
   SaladMoveRun(12120, 12457)
   Out("Arrived at Iboga-HotSpot")

   Do
	  Out("Running to " & $i & "th Iboga.")
	  KillNextIboga()
	  $i += 1
	  $AmountOfIbogaInRange = GetIbogaInRange(-2 , 4900)
	  If GetEffectTimeRemaining(2218) <= 0 Then UseSkillEx(8, -2)
   Until $AmountOfIbogaInRange <= 0 OR $i >= 25


   If $i < 25 Then $KilledIboga = $KilledIboga + $i - 1

;~ Statistics
   If GetIsDead(-2) Then
	  $SaladFails += 1
	  Out("I'm dead.")
	  GUICtrlSetData($SaladFailsCount,$SaladFails)
   Else
	  $SaladRuns += 1
	  Out("Completed in " & GetTime() & ".")
	  GUICtrlSetData($SaladRunsCount,$SaladRuns)
	  GUICtrlSetData($SaladAvgTimeCount,SaladAvgTime())
   EndIf

   If GUICtrlRead($RenderingBox) == $GUI_CHECKED Then ClearMemory()
   Out("Returning to Kamadan.")

   Resign()
   RndSleep(5000)
   ReturnToOutpost()
   WaitMapLoading(449)
   RndSleep(500)
EndFunc

Func KillNextIboga()
	If GetMapLoading() == 2 Then Disconnected()
	If GetIsDead(-2) Then Return
	If GetIbogaInRange(-2, 4500) <= 0 Then Return

	Local $NextIboga
	Local $NextIbogaX
	Local $NextIbogaY
	Local $Me
	Local $TotalIboga
	Local $ActualIboga
	Local $z

	If DllStructGetData(GetAgentByID(-2), "HP") < 0.3 Then UseSkillEx(8, -2)

	TargetNearestEnemy()
    $NextIboga = GetAgentByID(-1)

	If NOT DllStructGetData($NextIboga, "PlayerNumber") = $AGENTID_Iboga Then
		Do
			$NextIboga = GetAgentByID(-1)
			Sleep(100)
			TargetNextEnemy()
		Until DllStructGetData($NextIboga, "PlayerNumber") = $AGENTID_Iboga
		ChangeTarget($NextIboga)
    EndIf


	Local $NextIbogaX = DllStructGetData($NextIboga, "X")
	Local $NextIbogaY = DllStructGetData($NextIboga, "Y")

    Move($NextIbogaX, $NextIbogaY)
	Do
			If GetMapLoading() == 2 Then Disconnected()
			If GetIsDead(-2) Then Return
			$Me = GetAgentByID(-2)
			If DllStructGetData($Me, 'MoveX') == 0 Or DllStructGetData($Me, 'MoveY') == 0 Then Move($NextIbogaX, $NextIbogaY)
			RndSleep(100)
	Until ComputeDistance(DllStructGetData($Me, 'X'), DllStructGetData($Me, 'Y'), $NextIbogaX, $NextIbogaY) < 1200

	If IsRecharged(1) Then
			UseSkillEx(1, $NextIboga)
	Else
			Local $NextIbogaX = DllStructGetData($NextIboga, "X")
			Local $NextIbogaY = DllStructGetData($NextIboga, "Y")

			 Move($NextIbogaX, $NextIbogaY)
			Do
					If GetMapLoading() == 2 Then Disconnected()
					If GetIsDead(-2) Then Return
					$Me = GetAgentByID(-2)
					If DllStructGetData($Me, 'MoveX') == 0 Or DllStructGetData($Me, 'MoveY') == 0 Then Move($NextIbogaX, $NextIbogaY)
					RndSleep(100)
			Until ComputeDistance(DllStructGetData($Me, 'X'), DllStructGetData($Me, 'Y'), $NextIbogaX, $NextIbogaY) < 600

			If IsRecharged(1) Then
					UseSkillEx(1, $NextIboga)
			Else
					ChangeWeaponSet($WEAPON_SLOT_SCYTHE)
					$TotalIboga = GetIbogaInRange(-2, 300)
					If DllStructGetData(GetSkillBar(), 'AdrenalineA2') >= 150 Then
							UseSkillEx(2, $NextIboga)
							Do
							   Sleep(50)
							   $ActualIboga = GetIbogaInRange(-2, 300)
							   $z += 1
						    Until $ActualIboga = $TotalIboga - 1 OR $z >= 40
					Else
							Attack($NextIboga)
							Do
							   Sleep(50)
							   $ActualIboga = GetIbogaInRange(-2, 300)
							   $z += 1
						    Until $ActualIboga = $TotalIboga - 1 OR $z >= 40
					EndIf
			EndIf
	EndIf
	ChangeWeaponSet($WEAPON_SLOT_SHIELD)
	Sleep(Random(240, 250))
    SaladPickUpLoot()
	Sleep(300)
EndFunc

Func GetIbogaInRange($aAgent = -2, $aRange = 4500)
	If GetMapLoading() == 2 Then Disconnected()
	Local $lAgent, $lDistance
	Local $lCount = 0, $lAgentArray = GetAgentArray(0xDB)
	If Not IsDllStruct($aAgent) Then $aAgent = GetAgentByID($aAgent)
	For $i = 1 To $lAgentArray[0]
		$lAgent = $lAgentArray[$i]
		If DllStructGetData($lAgent, 'Allegiance') <> 3 Then ContinueLoop
		If DllStructGetData($lAgent, 'HP') <= 0 Then ContinueLoop
		$lDistance = GetDistance($lAgent)
		If $lDistance > $aRange Then ContinueLoop
		If DllStructGetData($lAgent, 'PlayerNumber') == $AGENTID_Iboga Then $lCount += 1	;Ibogas = 4388
	Next
	Return $lCount
EndFunc

Func SaladMoveRun($DestX, $DestY)
   If GetMapLoading() == 2 Then Disconnected()
   If GetIsDead(-2) Then Return
   Local $Me, $Angle
   Local $Blocked = 0
   Move($DestX, $DestY)
   Do
	  If GetMapLoading() == 2 Then Disconnected()
	  $Me = GetAgentByID(-2)
	  If GetIsDead(-2) Then Return
	  If (DllStructGetData($Me, 'MoveX') == 0 Or DllStructGetData($Me, 'MoveY') == 0) Then
		 $Blocked += 1
		 If $Blocked <= 5 Then
			Move($DestX, $DestY)
		 ElseIf $Blocked > 5 AND $Blocked <= 10 Then
			$Me = GetAgentByID(-2)
			$X = Round(DllStructGetData($Me, 'X'), 2)
			$Y = Round(DllStructGetData($Me, 'Y'), 2)
			Out("Blocked at Position: " & $X & ":" & $Y & ". Try to unstuck.")
			$Angle += 35
			Move(DllStructGetData($Me, 'X')+300*sin($Angle), DllStructGetData($Me, 'Y')+300*cos($Angle))
			Sleep(2000)
			Move($DestX, $DestY)
		 ElseIf $Blocked > 10 AND $Blocked <= 11 Then
			$Me = GetAgentByID(-2)
			$X = Round(DllStructGetData($Me, 'X'), 2)
			$Y = Round(DllStructGetData($Me, 'Y'), 2)
			Out("Blocked at Position: " & $X & ":" & $Y & ". Kill me free.")
			TargetNearestEnemy()
			If IsRecharged(1) Then UseSkillEx(1, -1)
			Sleep(2000)
			Move($DestX, $DestY)
		 Else
			Out("To much stucked, resign.")
			Resign()
			Sleep(2000)
			ExitLoop
		 EndIf
	  EndIF
	  RndSleep(250)
   Until ComputeDistance(DllStructGetData($Me, 'X'), DllStructGetData($Me, 'Y'), $DestX, $DestY) < 250
EndFunc

Func SaladPickUpLoot()
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
#EndRegion SaladFarmer

#Region FarmAllMode
Func FarmAllLoop()
   If $KebobDrops < GUICtrlRead($KebobCount) Then
	  $FarmMode = 1
   Else
	  If $FarmNextItem Then
		 Out("Drake Kebob finished!")
		 $timereset = True
		 $FarmNextItem = False
	  EndIf
	  If $SaladDrops * 2 < GUICtrlRead($SaladCount) * 2 Then
		 $FarmMode = 2
	  Else
		 If $FarmNextItem2 Then
			Out("Pahnai Salad finished!")
			$timereset = True
			$FarmNextItem2 = False
		 EndIf
		 If $SoupDrops * 2 < GUICtrlRead($SoupCount) * 2 Then
			$FarmMode = 3
		 Else
			Out("Skalefin Soup finished!")
			$BotRunning = False
			Out("Total Job Finished!")
		 EndIf
	  EndIf
   EndIf

;~    Do
;~ 	  $FarmMode = 1
;~    Until GUICtrlRead($KebobDropsCount) >= GUICtrlRead($KebobCount) OR CountSlots() < 5
;~    If CountSlots() < 5 Then Return
;~
;~    Do
;~ 	  $FarmMode = 2
;~    Until GUICtrlRead($SaladDropsCount) >= GUICtrlRead($SaladCount) OR CountSlots() < 5
;~    If CountSlots() < 5 Then Return
;~
;~    Do
;~ 	  $FarmMode = 3
;~    Until GUICtrlRead($SoupDropsCount) >= GUICtrlRead($SoupCount) OR CountSlots() < 5
;~    If CountSlots() < 5 Then Return

;~    $BotRunning = False
EndFunc
#EndRegion FarmAllMode

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

Func Inventory()
   If _IsChecked($FarmKebob) OR $FarmMode = 1 Then
	  If GetMapID() <> 425 Then Return
	  Local $aMerchName = "Ashnod"
	  Local $lMerch = GetAgentByName($aMerchName)
	  If IsDllStruct($lMerch)Then
		 Out("Going to " & $aMerchName)
		 GoToNPC($lMerch)
		 RndSleep(Random(3000, 4200))
	  EndIf
   ElseIf _IsChecked($FarmSoup) OR $FarmMode = 3 Then
	  If GetMapID() <> 491 Then Return
	  Sleep(Random(400,600))
	  MoveTo(-36, 16)
	  MoveTo(848, 38)
	  MoveTo(2187, 1636)
	  MoveTo(3091, 2064)
	  Local $aMerchName = "Lokai"
	  Local $lMerch = GetAgentByName($aMerchName)
	  If IsDllStruct($lMerch)Then
		 Out("Going to " & $aMerchName)
		 GoToNPC($lMerch)
		 RndSleep(Random(3000, 4200))
	  EndIf
   ElseIf _IsChecked($FarmSalad) OR $FarmMode = 2 Then
	  If GetMapID() <> 449 Then Return
	  Sleep(Random(400,600))
	  MoveTo(-10469, 15806)
	  Local $aMerchName = "Shatam"
	  Local $lMerch = GetAgentByName($aMerchName)
	  If IsDllStruct($lMerch)Then
		 Out("Going to " & $aMerchName)
		 GoToNPC($lMerch)
		 RndSleep(Random(3000, 4200))
	  EndIf
   Else
	  Return
   EndIf
;~ --------------------------------------------------------------------------------
   Out("Identifying")
   Ident(1)
   Ident(2)
   Ident(3)
;~ Ident(4)

   Out("Selling")
   Sell(1)
   Sell(2)
   Sell(3)
;~ Sell(4)

   If GetGoldCharacter() > 90000 Then
	  Out("Depositing Gold")
	  DepositGold()
   EndIf
   Sleep(GetPing()+1000)
;~ --------------------------------------------------------------------------------
   If _IsChecked($FarmKebob) OR $FarmMode = 1 Then
	  MoveTo(-15480, 11138)
	  MoveTo(-16009, 10219)
   ElseIf _IsChecked($FarmSoup) OR $FarmMode = 3 Then
	  MoveTo(3091, 2064)
	  MoveTo(2187, 1636)
	  MoveTo(848, 38)
	  MoveTo(-36, 16)
	  MoveTo(-1449, -929)
   ElseIf _IsChecked($FarmSalad) OR $FarmMode = 2 Then
	  MoveTo(-9196, 15878)
	  MoveTo(-9249, 16622)
   Else
	  Return
   EndIf
   Sleep(GetPing()+1000)

EndFunc

Func CanPickUp($lItem)
   If GetMapLoading() == 2 Then Disconnected()
   Local $Quantity
   Local $ModelID = DllStructGetData($lItem, 'ModelID')
   Local $ExtraID = DllStructGetData($lItem, 'ExtraID')
   Local $Type = DllStructGetData($lItem, 'Type')
   Local $rarity = GetRarity($lItem)
   Local $req = GetItemReq($lItem)

	Local $Requirement = GetItemReq($lItem)
	Local $ModStruct = GetModStruct($lItem)

   	Local $6to13DMG = StringInStr($ModStruct, "060DA8A7")
	Local $13to25DMG = StringInStr($ModStruct, "0D19A8A7")
	Local $14to25DMG = StringInStr($ModStruct, "0E18A8A7")
	Local $7to14DMG = StringInStr($ModStruct, "070EA8A7")
	Local $7to15DMG = StringInStr($ModStruct, "070FA8A7")
	Local $9to41DMG = StringInStr($ModStruct,"0929A8A7")
	Local $8to17DMG = StringInStr($ModStruct, "081188A4") ;8-17
	Local $8to16DMG = StringInStr($ModStruct, "081088A4") ;8-16

	If $type = $ITEMTYPE_SCYTHE and $9to41DMG and $requirement = 8 and $rarity <> $Rarity_white Then ; req 8 scythe
		Return True
	EndIf

	If $type = $ITEMTYPE_SCYTHE and $8to17DMG  and $requirement = 0 and $rarity <> $Rarity_white Then ; req 8 scythe
		Return True
	EndIf

	If $type = $ITEMTYPE_SCYTHE and $8to16DMG  and $requirement = 0 and $rarity <> $Rarity_white Then ; req 8 scythe
		Return True
	EndIf

	If $type == $ITEMTYPE_DAGGERS and $6to13DMG and $requirement = 5 and $rarity <> $Rarity_white Then ; req 5 daggers
		Return True
	EndIf

	If $type == $ITEMTYPE_DAGGERS and $7to14DMG and $requirement = 6 and $rarity <> $Rarity_white Then ; req 6 daggers
		Return True
	EndIf

	If $type == $ITEMTYPE_BOW and $13to25DMG and $requirement = 6 and $rarity <> $Rarity_white Then ; req 6 bows ether
		Return True
	EndIf

	If $type == $ITEMTYPE_BOW and $14to25DMG and $requirement = 6 and $rarity <> $Rarity_white Then ; req 6 bows ether
		Return True
	EndIf






   If _IsChecked($FarmKebob) OR $FarmMode = 1 Then
	  If $ModelID = 19185 Then
		 $KebobDrops += DllStructGetData($lItem, 'Quantity')
		 GUICtrlSetData($KebobDropsCount,$KebobDrops)
		 Return True
	  EndIf
   ElseIf _IsChecked($FarmSoup) OR $FarmMode = 3 Then
	  If $ModelID = 19184 Then ; SkaleFins
		 $SoupDrops += DllStructGetData($lItem, 'Quantity')
		 GUICtrlSetData($SoupDropsCount,Round($SoupDrops / 2, 1))
		 Return True
	  EndIf
   ElseIf _IsChecked($FarmSalad) OR $FarmMode = 2 Then
	  If $ModelID = 19183 Then
		 $SaladDrops += DllStructGetData($lItem, 'Quantity')
		 GUICtrlSetData($SaladDropsCount,Round($SaladDrops / 2, 1))
		 Return True
	  EndIf
   EndIf

;~    General Drops
   If $ModelID = 146 AND ($ExtraID = 10 Or $ExtraID = 12) Then Return True ;dyes
   If $ModelID = 835 Or $ModelID = 28434 Then Return True	;ToTs    ;WHAT IS 835??????????
   If $ModelID = 30855 Then Return True ;Grog
   If $ModelID = 22191 Or $ModelID = 22190 Then Return True ; Shamrock Ales and Four-Leav Clover

;~	  Event Drops
   If $ModelID = 22269 Then Return True ; CUPCAKES
   If $ModelID = 22752 Then Return True ; EGGS
   If $ModelID = 28436 Then Return True ; PIE
   If $ModelID = 26784 Then Return True ; HONEYCOMB
   If $ModelID = 21833 Then Return True ; LUNARS
   If $ModelID = 22191 Then Return True ; CLOVER
   If $ModelID = 28434 Then Return True ; TOTS
   If $ModelID = 36683 Then Return True ; BEACONS
   If $ModelID = 36681 Then Return True ; CAKES
   If $ModelID = 36682 Then Return True ; ICED TEAS
   If $ModelID = 28435 Then Return True ; CIDER


   If _IsChecked($collectKeys) Then
	  If $ModelID = 15557 Then Return True ;Istan Key
	  If $ModelID = 15559 Then Return True ;Kournan_Key
   EndIf
   If _IsChecked($collectMoney) AND $ModelID = 2511 AND GetGoldCharacter() < 99000 Then Return True	; Gold Coins

   If _IsChecked($collectScales) AND $ModelID = 953 Then Return True ; Scales

;~    KebobDrops
   If $ModelID = 921 Then Return True ;921 = Bones

;~    SoupDrops
   If _IsChecked($collectSentientSeeds) AND $ModelID = 1601 Then Return True ;Samenkörner
   If _IsChecked($collectSkaleTeeth) AND $ModelID = 1603 Then Return True ;Zähne
   If _IsChecked($collectSkaleClaws) AND $ModelID = 1604 Then Return True ;Klauen
   If _IsChecked($collectInsectAppendages) AND $ModelID = 1597 Then Return True ;InsektenKörper

;~ 	  SaladDrops
   If _IsChecked($collectSentientSeeds) AND $ModelID = 1600 Then Return True ;1600 = Roots

   If CountFreeSlots() < 4 Then Return False

   If $rarity == 2623 Or $rarity == 2626 Then
;~ 	  Runes
	  If $ModelID == 1264 OR $ModelID == 1483 Then ;blue/purple half digested Armor and blue/purple half digested Boots
		 If _IsChecked($collectRunes) Then
			Return True
		 Else
			Return False
		 EndIf
	  EndIf
   EndIf

   If _IsChecked($collectGoldies) AND $rarity = 2624 Then Return True ;golden Items

   Return False
EndFunc


Func Sell($BAGINDEX)
	Local $AITEM
	Local $BAG = GETBAG($BAGINDEX)
	Local $NUMOFSLOTS = DllStructGetData($BAG, "slots")
	For $I = 1 To $NUMOFSLOTS
		Out("Selling item: " & $BAGINDEX & ", " & $I)
		$AITEM = GETITEMBYSLOT($BAGINDEX, $I)
		If DllStructGetData($AITEM, "ID") = 0 Then ContinueLoop
		If CANSELL($AITEM) Then
			SELLITEM($AITEM)
		EndIf
		Sleep(GetPing()+250)
	Next
EndFunc

 Func CanSell($aItem)
	Local $LMODELID = DllStructGetData($aitem, "ModelID")
	Local $LRARITY = GetRarity($aitem)
	Local $ModStruct = GetModStruct($aitem)

;~ 	Runes
	Local $WindWalker = StringInStr($ModStruct, "02020824", 0, 1)
	Local $Centurion = StringInStr($ModStruct, "07020824", 0, 1)
	Local $Survivor = StringInStr($ModStruct, "0005D826", 0, 1)
	Local $MinorVigor = StringInStr($ModStruct, "C202E827", 0, 1)
	Local $MajorVigor = StringInStr($ModStruct, "C202E927", 0, 1)
	Local $Vitae = StringInStr($ModStruct, "000A4823", 0, 1)
	Local $Blessed = StringInStr($ModStruct, "E9010824", 0, 1)
	Local $MinorSoulReaping = StringInStr($ModStruct, "0106E821", 0, 1)
	Local $MinorFastCasting = StringInStr($ModStruct, "0100E821", 0, 1)
	Local $MinorInspiration = StringInStr($ModStruct, "0103E821", 0, 1)
	Local $MinorSpawning = StringInStr($ModStruct, "0124E821", 0, 1)
	Local $Shaman = StringInStr($ModStruct, "04020824", 0, 1)
	Local $MinorEnergyStorage = StringInStr($ModStruct, "010CE821", 0, 1)
	Local $MinorDivine = StringInStr($ModStruct, "0110E821", 0, 1)

	Local $Requirement = GetItemReq($aItem)
   	Local $rarity = GetRarity($aItem)
   	Local $6to13DMG = StringInStr($ModStruct, "060DA8A7")
	Local $13to25DMG = StringInStr($ModStruct, "0D19A8A7")
	Local $14to25DMG = StringInStr($ModStruct, "0E18A8A7")
	Local $7to14DMG = StringInStr($ModStruct, "070EA8A7")
	Local $7to15DMG = StringInStr($ModStruct, "070FA8A7")
	Local $9to41DMG = StringInStr($ModStruct,"0929A8A7")
	Local $8to17DMG = StringInStr($ModStruct, "081188A4") ;8-17
	Local $8to16DMG = StringInStr($ModStruct, "081088A4") ;8-16

	If $type = $ITEMTYPE_SCYTHE and $9to41DMG and $requirement = 8 and $rarity <> $Rarity_white Then ; req 8 scythe
		Return False
	EndIf

	If $type = $ITEMTYPE_SCYTHE and $8to17DMG  and $requirement = 0 and $rarity <> $Rarity_white Then ; req 8 scythe
		Return False
	EndIf

	If $type = $ITEMTYPE_SCYTHE and $8to16DMG  and $requirement = 0 and $rarity <> $Rarity_white Then ; req 8 scythe
		Return False
	EndIf

	If $type == $ITEMTYPE_DAGGERS and $6to13DMG and $requirement = 5 and $rarity <> $Rarity_white Then ; req 5 daggers
		Return False
	EndIf

	If $type == $ITEMTYPE_DAGGERS and $7to14DMG and $requirement = 6 and $rarity <> $Rarity_white Then ; req 6 daggers
		Return False
	EndIf

	If $type == $ITEMTYPE_BOW and $13to25DMG and $requirement = 6 and $rarity <> $Rarity_white Then ; req 6 bows ether
		Return False
	EndIf

	If $type == $ITEMTYPE_BOW and $14to25DMG and $requirement = 6 and $rarity <> $Rarity_white Then ; req 6 bows ether
		Return False
	EndIf


   If $LMODELID == 146 Then
	  Switch DllStructGetData($aitem, "ExtraID")
		 Case 10, 12
			Return False
		 Case Else
			Return True
	  EndSwitch
   EndIf

   If $lModelID == 19184 OR $lModelID == 17061 Then Return False ;Dont sell Fins or Soup
   If $lModelID == 19185 OR $lModelID == 17060 Then Return False ;Dont sell Kebob or Flesh
   If $lModelID == 19183 OR $lModelID == 17062 Then Return False ;Dont sell Petals or Salad

   If $lModelID == 1604 OR $lModelID == 1603 OR $lModelID == 1597 OR $lModelID == 1601 OR $lModelID == 15557 Then Return False ;dont sell skale-trophies and insekt-bodies
   If $lModelID == 1600 Then Return False ;dont sell roots

   If $lModelID == 953 OR $lModelID == 921 Then Return False ;Dont sell bones or scales

   If $lModelID == 2989 OR $lModelID == 5899 Then Return False ;Dont sell ident-kits
   If $lModelID == 15559 OR $lModelID == 15557 Then Return False ;Dot sell keys

   If $lModelID == 22191 Or $lModelID == 22190 Then Return False ;Shamrock Ales and Four-Leav Clover


;~    dont sell nice runes and q-zore weapons
   Switch $LRARITY
   Case 2626, 2623
		 If ($WindWalker > 0) Or ($Centurion > 0) Or ($Blessed > 0) Or ($Survivor > 0) Then
			Return False
		 ElseIf ($MinorVigor > 0) Or ($MajorVigor > 0) Or ($Vitae > 0) Then
			Return False
		 ElseIf ($MinorSoulReaping > 0) Or ($MinorFastCasting > 0) Or ($MinorInspiration > 0) Then
			Return False
		 ElseIf ($MinorSpawning > 0) Or ($Shaman > 0) Or ($MinorEnergyStorage > 0) Then
			Return False
		 ElseIf ($MinorDivine > 0) Then
			Return False
		 Else
			Return True
		 EndIf
	  Case Else ; $Rarity_White
		 Return True
	Endswitch

	Return True
EndFunc   ;==>CanSell

Func Ident($BAGINDEX)
	Local $bag
	Local $I
	Local $AITEM
	$BAG = GETBAG($BAGINDEX)
	For $I = 1 To DllStructGetData($BAG, "slots")
		If FINDIDKIT() = 0 Then
			If GETGOLDCHARACTER() < 500 And GETGOLDSTORAGE() > 499 Then
				WITHDRAWGOLD(500)
				Sleep(GetPing()+500)
			EndIf
			Local $J = 0
			Do
			    If _IsChecked($FarmKebob) OR $FarmMode = 1 Then
				   Local $aMerchName = "Ashnod"
				   Local $lMerch = GetAgentByName($aMerchName)
				   GoNPC($lMerch)
				  BuyItem(6, 1, 500)
			    ElseIf _IsChecked($FarmSoup) OR $FarmMode = 3 Then
				   Local $aMerchName = "Lokai"
				   Local $lMerch = GetAgentByName($aMerchName)
				   GoNPC($lMerch)
				   BuyItem(4, 1, 100)
			    ElseIf _IsChecked($FarmSalad) OR $FarmMode = 2 Then
				   Local $aMerchName = "Shatam"
				   Local $lMerch = GetAgentByName($aMerchName)
				   GoNPC($lMerch)
				   BuyItem(3, 1, 100)
			    EndIf
				Sleep(GetPing()+500)
				$J = $J + 1
			Until FINDIDKIT() <> 0 Or $J = 3
			If $J = 3 Then ExitLoop
			Sleep(GetPing()+500)
		EndIf
		$AITEM = GETITEMBYSLOT($BAGINDEX, $I)
		If DllStructGetData($AITEM, "ID") = 0 Then ContinueLoop
		IDENTIFYITEM($AITEM)
		Sleep(GetPing()+500)
	Next
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

; Uses a skill
; It will not use if I am dead, if the skill is not recharged, or if I don't have enough energy for it
; It will sleep until the skill is cast, then it will wait for aftercast.
Func UseSkillEx($lSkill, $lTgt = -2, $aTimeout = 3000)
    If GetIsDead(-2) Then Return
    If Not IsRecharged($lSkill) Then Return
    Local $Skill = GetSkillByID(GetSkillBarSkillID($lSkill, 0))
    Local $Energy = StringReplace(StringReplace(StringReplace(StringMid(DllStructGetData($Skill, 'Unknown4'), 6, 1), 'C', '25'), 'B', '15'), 'A', '10')
    If GetEnergy(-2) < $Energy Then Return
    Local $lAftercast = DllStructGetData($Skill, 'Aftercast')
    Local $lDeadlock = TimerInit()
    UseSkill($lSkill, $lTgt)
    Do
	    Sleep(50)
	    If GetIsDead(-2) = 1 Then Return
	    Until (Not IsRecharged($lSkill)) Or (TimerDiff($lDeadlock) > $aTimeout)
    Sleep($lAftercast * 1000)
EndFunc   ;==>UseSkillEx

; Checks if skill given (by number in bar) is recharged. Returns True if recharged, otherwise False.


Func CountSlots()
	Local $bag
	Local $temp = 0
	$bag = GetBag(1)
	$temp += DllStructGetData($bag, 'Slots') - DllStructGetData($bag, 'ItemsCount')
	$bag = GetBag(2)
	$temp += DllStructGetData($bag, 'Slots') - DllStructGetData($bag, 'ItemsCount')
	$bag = GetBag(3)
	$temp += DllStructGetData($bag, 'Slots') - DllStructGetData($bag, 'ItemsCount')
	$bag = GetBag(4)
	$temp += DllStructGetData($bag, 'Slots') - DllStructGetData($bag, 'ItemsCount')
	Return $temp
EndFunc ; Counts open slots in your Imventory

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

Func RndTravel($aMapID)
   If GetMapLoading() == 2 Then Disconnected()
   TravelTo($aMapID)
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

Func CountFreeSlots($NumOfBags = 4)
   Local $FreeSlots, $Slots

   For $Bag = 1 to $NumOfBags
	  $Slots += DllStructGetData(GetBag($Bag), 'Slots')
	  $Slots -= DllStructGetData(GetBag($Bag), 'ItemsCount')
   Next

   Return $Slots
EndFunc

Func KebobAvgTime()
   Local $Time = GetInstanceUpTime()
   Local $Seconds = Floor($Time/1000)
   $KebobTotalSeconds += $Seconds
   Local $AvgSeconds = Floor($KebobTotalSeconds/$KebobRuns)
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

Func SoupAvgTime()
   Local $Time = GetInstanceUpTime()
   Local $Seconds = Floor($Time/1000)
   $SoupTotalSeconds += $Seconds
   Local $AvgSeconds = Floor($SoupTotalSeconds/$SoupRuns)
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

Func SaladAvgTime()
   Local $Time = GetInstanceUpTime()
   Local $Seconds = Floor($Time/1000)
   $SaladTotalSeconds += $Seconds
   Local $AvgSeconds = Floor($SaladTotalSeconds/$SaladRuns)
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
    Local $aOldTime
    Local $aOldTime2

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

    If _IsChecked($FarmAll) Then
	  If $BotRunning Then GUICtrlSetData($TotalTimeCount, $L_Hour & ":" & $L_Min & ":" & $L_Sec)

	  If _IsChecked($FarmKebob) OR $FarmMode = 1 Then
		 GUICtrlSetData($KebobTotTimeCount, $L_Hour & ":" & $L_Min & ":" & $L_Sec)
	  EndIf

	  If _IsChecked($FarmSalad) OR $FarmMode = 2 Then
		 $aOldTime = StringSplit(GUICtrlRead($KebobTotTimeCount), ":")
		 $L_Hour -= $aOldTime[1]
		 $L_Min -= $aOldTime[2]
		 $L_Sec -= $aOldTime[3]
		 If $L_Sec < 0 Then
			$L_Min -= 1
			$L_Sec = $L_Sec + 60
		 EndIf
		 If $L_Min < 0 Then
			$L_Hour -= 1
			$L_Min = $L_Min + 60
		 EndIf
		 If $L_Sec < 10 Then $L_Sec = "0" & $L_Sec
		 If $L_Min < 10 Then $L_Min = "0" & $L_Min
		 If $L_Hour < 10 Then $L_Hour = "0" & $L_Hour
		 GUICtrlSetData($SaladTotTimeCount, $L_Hour & ":" & $L_Min & ":" & $L_Sec)
	  EndIf

	  If _IsChecked($FarmSoup) OR $FarmMode = 3 Then
		 $aOldTime = StringSplit(GUICtrlRead($KebobTotTimeCount), ":")
		 $aOldTime2 = StringSplit(GUICtrlRead($SaladTotTimeCount), ":")
		 $L_Hour -= $aOldTime2[1] - $aOldTime[1]
		 $L_Min -= $aOldTime2[2] - $aOldTime[2]
		 $L_Sec -= $aOldTime2[3] - $aOldTime[3]
		 If $L_Sec < 0 Then
			$L_Min -= 1
			$L_Sec = $L_Sec + 60
		 EndIf
		 If $L_Min < 0 Then
			$L_Hour -= 1
			$L_Min = $L_Min + 60
		 EndIf
		 If $L_Sec < 10 Then $L_Sec = "0" & $L_Sec
		 If $L_Min < 10 Then $L_Min = "0" & $L_Min
		 If $L_Hour < 10 Then $L_Hour = "0" & $L_Hour
		 If $BotRunning Then GUICtrlSetData($SoupTotTimeCount, $L_Hour & ":" & $L_Min & ":" & $L_Sec)
	  EndIf
   Else
	  If _IsChecked($FarmKebob) OR $FarmMode = 1 Then GUICtrlSetData($KebobTotTimeCount, $L_Hour & ":" & $L_Min & ":" & $L_Sec)
	  If _IsChecked($FarmSalad) OR $FarmMode = 2 Then GUICtrlSetData($SaladTotTimeCount, $L_Hour & ":" & $L_Min & ":" & $L_Sec)
	  If _IsChecked($FarmSoup) OR $FarmMode = 3 Then GUICtrlSetData($SoupTotTimeCount, $L_Hour & ":" & $L_Min & ":" & $L_Sec)
   EndIf

EndFunc

Func _IsChecked($idControlID)
    Return BitAND(GUICtrlRead($idControlID), $GUI_CHECKED) = $GUI_CHECKED
EndFunc   ;==>_IsChecked


Func Out($msg)
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
#EndRegion Functions