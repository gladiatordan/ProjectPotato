#Region About
#cs
##################################
#                                #
#      Kilroy Stoneskin Bot      #
#                          	     #
#            Updated             #
#         by DeeperBlue          #
#         February 2019          #
#                                #
##################################

Changelog V1.1 (February the 21th 2019) by DeeperBlue :
	- GUI Update :
		- Resized interface window
		INIT
		- Character selector is not an input.
		- Added a refresh button to refresh characters' list if needed.
		- Added an Actions Selector
        DIFFICULTY
        - Added difficulty radios (Normal & Hard mode)
		SETTINGS
		- Added a checkbox to make the bot set player's status as offline.
		- Added a checkbox to toggle scroll usage.
		- Added a radio to check all settings at once
		AUTHORIZEDBAGS
		- Added checkboxes to make user decide which bag is authorized for the bot to interact with.
		- Added a radio to check all bags at once
		COUNTERs & TIMERs
		- Added a Runs (success) counter
		- Added a Fails counter
		ITEMS
		- Added a grid of checkboxes in which user can choose what to do for each item based on it's rarity
			- Pickup
			- Identification
			- Sell
		- Added radios to make user able to check all checkboxes per collum or line
		- Added a radio to check all items' checkboxes
	
	- Functions update :
		- Added GUI handeling functions to activate/deactivate some parts of the GUI based on selected options
		- Updated the bot to make it use a newer and working GWA2
		- Made the bot use GW_omniAPI
		- Added/Rewrote most of the code
        
Changelog V1.2 (February the 23th 2019) by DeeperBlue : 
    - GUI Update :
        - Added Checkboxes for the user to choose which other dyes he wants the bot to pickup and keep.
    - Bot won't sell items that he was not supposed to sell.
    - Added a function to count and prints number of dyes based on what have been selected on GUI.

Changelog V1.2.1 (February the 23th 2019) by DeeperBlue : 
    - GUI Update :
        - Added a pink dye checkbox
    - Added pink dye related functions
    - Added Pink dye declaration in Addons.au3

Changelog V1.3 (March the 2nd 2019) by DeeperBlue :
    - Added some checks to prevent a bug that made the bot going to Norrhart Domain and getting killed.
    - Added a check to make sure to be in the Fornis Lair befor starting to farm.
    
#TODO : 
    - Store items
    - salvage the more pricy runes from blue armors
    - It consumed the scrolls when the option was enable, but it doesn`t work to me anymore
#ce
#EndRegion About

#Region Include
#include "GW_omniApi.au3"
#EndRegion Include

#Region Global Const Declarations
; === Maps ===
Global Const $MAP_ID_GUUNAR = 644
Global Const $MAP_ID_FORNISINSTANCE = 704

; === Quests ===
Global Const $FORNIS_QUEST = 856

; === Dialogs ===
Global Const $FIRST_DIALOG = 0x00000085

; === Skills ===
Global Const $maxAllowdEnergy = 120

; === Skill Cost ===
Global Const $intAdrenaline[7] = [0, 0, 0, 100, 250, 175, 0]
#EndRegion Global Declarations

#Region Declarations
Global $Runs = 0
Global $Fails = 0
Global $Drops = 0
Global $BotRunning = False
Global $BotInitialized = False
Global $TotalSeconds = 0
Global $Seconds = 0
Global $Minutes = 0
Global $Hours = 0
Global $MerchOpened = False
Global $HWND

Global $OutpostRegion
#EndRegion Declarations


#Region GUI
Opt("GUIOnEventMode", True)
Opt("GUICloseOnESC", False)

$JobsList = "Level 20|Survivor Title|Farm"

$Gui = GUICreate("Kilroy Stonekin", 416, 451, -1, -1)

GUICtrlCreateGroup("Select a Character", 10, 5, 170, 43)
    $CharInput = GUICtrlCreateCombo("", 20, 20, 129, 21, $CBS_DROPDOWNLIST)
		GUICtrlSetData(-1, GetLoggedCharNames())
		GUICtrlSetOnEvent(-1, "GuiCharSelectorToJobHandler")
	$iRefresh = GUICtrlCreateButton("", 152, 19, 22.8, 22.8, $BS_ICON)
        GUICtrlSetImage($iRefresh, "shell32.dll", -239, 0)
        GUICtrlSetOnEvent(-1, "RefreshInterface")
   
GUICtrlCreateGroup("Actions", 10, 50, 170, 43) ; Actions the bot can do selectors
	$JobToDo = GUICtrlCreateCombo("Job to do", 20, 65, 129, 21, $CBS_DROPDOWNLIST)
    GUICtrlSetData(-1, $JobsList)
	GUICtrlSetOnEvent(-1, "GuiActionsHandler")
   
$StartButton = GUICtrlCreateButton("Start", 15, 97, 157.8, 21)
   GUICtrlSetOnEvent(-1, "GuiButtonHandler")
$RenderingBox = GUICtrlCreateCheckbox("Disable Rendering", 35, 120, 110, 17)
   GUICtrlSetOnEvent(-1, "ToggleRendering")

GUICtrlCreateGroup("Difficulty", 10, 145, 170, 52) ;Option
	$NormalMode = GUICtrlCreateRadio("Normal",20, 160, 135, 15)
        GUICtrlSetOnEvent(-1, "RadiosModeHandler")
	$HardMode = GUICtrlCreateRadio("Hard", 20, 175, 80, 15)
        GUICtrlSetOnEvent(-1, "RadiosModeHandler")
   
GUICtrlCreateGroup("Settings", 10, 200, 170, 52) ;Option
    $RadioSetting = GUICtrlCreateRadio("",165, 207, 10, 17)
        GUICtrlSetOnEvent(-1, "RadiosHandler")
	$Status = GUICtrlCreateCheckbox("Set player status : Offline",20, 215, 135, 15)
	$UseScroll = GUICtrlCreateCheckbox("Use scroll", 20, 230, 80, 15)

GUICtrlCreateGroup("Authorized bags", 10, 255, 170, 82) ;Selling bag function (not checked = ignore bag)
	$RadioAuthBags = GUICtrlCreateRadio("",165, 262, 10, 17)
        GUICtrlSetOnEvent(-1, "RadiosHandler")
    $AuthBag1 = GUICtrlCreateCheckbox("Bag 1 (20 slots)", 20, 270, 130, 15)
	$AuthBag2 = GUICtrlCreateCheckbox("Bag 2 (5/10 slots)", 20, 285, 150, 15)
	$AuthBag3 = GUICtrlCreateCheckbox("Bag 3 (10/15 slots)", 20, 300, 150, 15)
	$AuthBag4 = GUICtrlCreateCheckbox("Bag 4 (10/15 slots)", 20, 315, 150, 15)

GUICtrlCreateGroup("", 10, 340, 170, 100)
	$RunsLabel = GUICtrlCreateLabel("Runs:", 20, 355, 31, 20)
	$RunsCount = GUICtrlCreateLabel("0", 95, 355, 50, 20, $SS_RIGHT)
	$FailsLabel = GUICtrlCreateLabel("Fails:", 20, 375, 31, 20)
	$FailsCount = GUICtrlCreateLabel("0", 95, 375, 50, 20, $SS_RIGHT)
	$AvgTimeLabel = GUICtrlCreateLabel("Average time:", 20, 395, 100, 20)
	$AvgTimeCount = GUICtrlCreateLabel("-", 89, 395, 54, 20, $SS_RIGHT)
	$TotTimeLabel = GUICtrlCreateLabel("Total time:", 20, 415, 49, 20)
	$TotTimeCount = GUICtrlCreateLabel("-", 89, 415, 54, 20, $SS_RIGHT)
    
	#Region GUI items
GUICtrlCreateGroup("Items", 190, 290, 215, 150)
    $RadioItemsAll = GUICtrlCreateRadio("Check All",200, 315, 80, 17)
        GUICtrlSetOnEvent(-1, "RadiosHandler")
	GUICtrlCreateGroup("", 195, 327, 206, 28) ;White line
		$RadioWhite = GUICtrlCreateRadio("Rarity : White", 200, 335, 80, 15)
			GUICtrlSetOnEvent(-1, "RadiosHandler")
    GUICtrlCreateGroup("", 195, 347, 206, 28) ;Blue line
		$RadioBlue = GUICtrlCreateRadio("Rarity : Blue", 200, 355, 80, 15)
			GUICtrlSetOnEvent(-1, "RadiosHandler")
	GUICtrlCreateGroup("", 195, 367, 206, 28) ;Purple line	
		$RadioPurple = GUICtrlCreateRadio("Rarity : Purple", 200, 375, 80, 15)
			GUICtrlSetOnEvent(-1, "RadiosHandler")
	GUICtrlCreateGroup("", 195, 387, 206, 28) ;Gold line	
		$RadioGold = GUICtrlCreateRadio("Rarity : Gold", 200, 395, 80, 15)
			GUICtrlSetOnEvent(-1, "RadiosHandler")
	GUICtrlCreateGroup("", 195, 407, 206, 28) ;Green line	
		$RadioGreen = GUICtrlCreateRadio("Rarity : Green", 200, 415, 80, 15)
			GUICtrlSetOnEvent(-1, "RadiosHandler")
	
	GUICtrlCreateGroup("Pickup", 285, 300, 45, 135)
		$RadioPickup = GUICtrlCreateRadio("",302, 315, 10, 17)
			GUICtrlSetOnEvent(-1, "RadiosHandler")
		$PickWhite = GUICtrlCreateCheckbox("", 301, 335, 20, 15)
		$PickBlue = GUICtrlCreateCheckbox("", 301, 355, 20, 15)
		$PickPurple = GUICtrlCreateCheckbox("", 301, 375, 20, 15)
		$PickGold = GUICtrlCreateCheckbox("", 301, 395, 20, 15)
		$PickGreen = GUICtrlCreateCheckbox("", 301, 415, 20, 15)
	
	GUICtrlCreateGroup("Ident", 329, 300, 38, 135)
		$RadioIdentItems = GUICtrlCreateRadio("",343, 315, 10, 17)
			GUICtrlSetOnEvent(-1, "RadiosHandler")
		;$IdentWhite = GUICtrlCreateCheckbox("", 342, 335, 20, 15) ;White items don't need be identified
		$IdentBlue = GUICtrlCreateCheckbox("", 342, 355, 20, 15)
		$IdentPurple = GUICtrlCreateCheckbox("", 342, 375, 20, 15)
		$IdentGold = GUICtrlCreateCheckbox("", 342, 395, 20, 15)
		;$IdentGreen = GUICtrlCreateCheckbox("", 342, 415, 20, 15) ;Green items don't need to be identified
	
	GUICtrlCreateGroup("Sell", 366, 300, 35, 135)
		$RadioSellItems = GUICtrlCreateRadio("",378, 315, 10, 17)
			GUICtrlSetOnEvent(-1, "RadiosHandler")
		$SellWhite = GUICtrlCreateCheckbox("", 377, 335, 20, 15)
		$SellBlue = GUICtrlCreateCheckbox("", 377, 355, 20, 15)
		$SellPurple = GUICtrlCreateCheckbox("", 377, 375, 20, 15)
		$SellGold = GUICtrlCreateCheckbox("", 377, 395, 20, 15)
		$SellGreen = GUICtrlCreateCheckbox("", 377, 415, 20, 15)
	#EndRegion GUI items

GUICtrlCreateGroup("Pickup dyes", 190, 217, 215, 70)
    $RadioPickupDye = GUICtrlCreateRadio("",390, 224, 10, 17)
        GUICtrlSetOnEvent(-1, "RadiosHandler")
    $PickDye_Blue = GUICtrlCreateCheckbox("Blue", 200, 232, 55, 15)	
    $PickDye_Green = GUICtrlCreateCheckbox("Green", 200, 247, 55, 15)	
    $PickDye_Purple = GUICtrlCreateCheckbox("Purple", 200, 262, 55, 15)	
    $PickDye_Red = GUICtrlCreateCheckbox("Red", 255, 232, 55, 15)	
    $PickDye_Yellow = GUICtrlCreateCheckbox("Yellow", 255, 247, 55, 15)	
    $PickDye_Brown = GUICtrlCreateCheckbox("Brown", 255, 262, 55, 15)	
    $PickDye_Orange = GUICtrlCreateCheckbox("Orange", 310, 232, 55, 15)	
    $PickDye_Silver = GUICtrlCreateCheckbox("Silver", 310, 247, 55, 15)
    $PickDye_Pink = GUICtrlCreateCheckbox("Pink", 310, 262, 55, 15)
    
$StatusLabel = GUICtrlCreateEdit("", 190, 11, 215, 197, BitOR(0x0040, 0x0080, 0x1000, 0x00200000))
    GUICtrlSetFont($StatusLabel, 9, 400, 0, "Arial")
    GUICtrlSetColor($StatusLabel, 65280)
    GUICtrlSetBkColor($StatusLabel, 0)
   
    #Region Disable GUI
        DeactivateAllGUI()
        RadiosModeHandler()
    #EndRegion Disable GUI
  
GUISetOnEvent($GUI_EVENT_CLOSE, "_exit")
GUISetState(@SW_SHOW)
#EndRegion GUI

#Region Loops
Out("Version 1.3 03/19")
Out("Ready to start.")
While Not $BotRunning
   Sleep(500)
WEnd

AdlibRegister("TimeUpdater", 1000)

OfflineMod()
Setup()
While 1
	If Not $BotRunning Then
        AdlibUnRegister("TimeUpdater")
        AdlibUnRegister("CrashCheck")
        Out("Bot is paused.")
        GUICtrlSetState($StartButton, $GUI_ENABLE)
        GUICtrlSetData($StartButton, "Start")
        GUICtrlSetOnEvent($StartButton, "GuiButtonHandler")
        
        ActivateAllGUI()
        While Not $BotRunning
            Sleep(500)
        WEnd
        AdlibRegister("TimeUpdater", 1000)
    EndIf
	
	
    
    If (GetJobID() == 1) Then ;Lvl 20
        LvlStop()
        MainLoop()
    ElseIf (GetJobID() == 2) Then ;Survivor
        Survivor_Display()
        MainLoop()
    ElseIf (GetJobID() == 3) Then ;Farm
        MainLoop()
    EndIf
WEnd

Func MainLoop()
    DeactivateAllGUI(0)
    Sleep(100)
    If $BotRunning Then
        CountFreeSpace()
        AdlibRegister ("CrashCheck",500)
        TakeQuest()
		$OutpostRegion = GetRegion()
        If RunQuest() Then
            GoToTown()
            Out("Energy was too high, run aborted")
            $Fails += 1
            GUICtrlSetData($FailsCount,$Fails)
            RndSleep(3000)
        EndIf

        If GetIsDead(-2) Then
            $Fails += 1
            Out("I'm dead.")
            GUICtrlSetData($FailsCount,$Fails)
        Else
            $Runs += 1
            Out("Completed in " & GetTime() & ".")
            GUICtrlSetData($RunsCount,$Runs)
            GUICtrlSetData($AvgTimeCount,AvgTime())
        EndIf
    EndIf
EndFunc
#EndRegion Loops

#Region GUI handeling Functions
	#Region GUI base function
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
	  Local $charname = GetCharname()
	  GUICtrlSetData($CharInput, $charname, $charname)
	  GUICtrlSetData($StartButton, "Pause")
	  WinSetTitle($Gui, "", "Kilroy Stonekin - " & $charname)
	  $BotRunning = True
	  $BotInitialized = True
	  SetMaxMemory()
   EndIf
EndFunc

Func GuiStartHandler() ;Handle Start/Stop toggling based on character selection (preventing user from starting bot befor choosing a character)
    If (GUICtrlRead($CharInput, "") <> "") Then 
        GUICtrlSetState($StartButton, $GUI_ENABLE)
    Else
        GUICtrlSetState($StartButton, $GUI_DISABLE)
	EndIf
EndFunc

Func GuiCharSelectorToJobHandler() ;Handle Job selector toggling based on character selection
	If (GUICtrlRead($CharInput, "") <> "") Then 
        GUICtrlSetState($JobToDo, $GUI_ENABLE)
    Else
        GUICtrlSetState($JobToDo, $GUI_DISABLE)
	EndIf
EndFunc

Func GuiActionsHandler() ;Keeps the user from getting both selector with a selected value
	If (GUICtrlRead($JobToDo, "") == "Job to do")  Then
		GuiStartHandler()
        
        GUICtrlSetState($NormalMode, $GUI_UNCHECKED)
        GUICtrlSetState($NormalMode, $GUI_DISABLE)
        GUICtrlSetState($HardMode, $GUI_UNCHECKED)
        GUICtrlSetState($HardMode, $GUI_DISABLE)
        
        GUICtrlSetState($Status, $GUI_UNCHECKED)
        GUICtrlSetState($Status, $GUI_DISABLE)
        GUICtrlSetState($UseScroll, $GUI_UNCHECKED)
        GUICtrlSetState($UseScroll, $GUI_DISABLE)
        GUICtrlSetState($RadioSetting, $GUI_UNCHECKED)
        GUICtrlSetState($RadioSetting, $GUI_DISABLE)
        
        GUICtrlSetState($AuthBag1, $GUI_UNCHECKED)
        GUICtrlSetState($AuthBag1, $GUI_DISABLE)
        GUICtrlSetState($AuthBag2, $GUI_UNCHECKED)
        GUICtrlSetState($AuthBag2, $GUI_DISABLE)
        GUICtrlSetState($AuthBag3, $GUI_UNCHECKED)
        GUICtrlSetState($AuthBag3, $GUI_DISABLE)
        GUICtrlSetState($AuthBag4, $GUI_UNCHECKED)
        GUICtrlSetState($AuthBag4, $GUI_DISABLE)
        GUICtrlSetState($RadioAuthBags, $GUI_UNCHECKED)
        GUICtrlSetState($RadioAuthBags, $GUI_DISABLE)
        
        GUICtrlSetState($RadioItemsAll, $GUI_UNCHECKED)
        GUICtrlSetState($RadioItemsAll, $GUI_DISABLE)
        GUICtrlSetState($RadioWhite, $GUI_UNCHECKED)
        GUICtrlSetState($RadioWhite, $GUI_DISABLE)
        GUICtrlSetState($RadioBlue, $GUI_UNCHECKED)
        GUICtrlSetState($RadioBlue, $GUI_DISABLE)
        GUICtrlSetState($RadioPurple, $GUI_UNCHECKED)
        GUICtrlSetState($RadioPurple, $GUI_DISABLE)
        GUICtrlSetState($RadioGold, $GUI_UNCHECKED)
        GUICtrlSetState($RadioGold, $GUI_DISABLE)
        GUICtrlSetState($RadioGreen, $GUI_UNCHECKED)
        GUICtrlSetState($RadioGreen, $GUI_DISABLE)
        
        GUICtrlSetState($PickWhite, $GUI_UNCHECKED)
        GUICtrlSetState($PickWhite, $GUI_DISABLE)
        GUICtrlSetState($PickBlue, $GUI_UNCHECKED)
        GUICtrlSetState($PickBlue, $GUI_DISABLE)
        GUICtrlSetState($PickPurple, $GUI_UNCHECKED)
        GUICtrlSetState($PickPurple, $GUI_DISABLE)
        GUICtrlSetState($PickGold, $GUI_UNCHECKED)
        GUICtrlSetState($PickGold, $GUI_DISABLE)
        GUICtrlSetState($PickGreen, $GUI_UNCHECKED)
        GUICtrlSetState($PickGreen, $GUI_DISABLE)
        GUICtrlSetState($RadioPickup, $GUI_UNCHECKED)
        GUICtrlSetState($RadioPickup, $GUI_DISABLE)
        
        ;GUICtrlSetState($IdentWhite, $GUI_UNCHECKED)
        ;GUICtrlSetState($IdentWhite, $GUI_DISABLE)
        GUICtrlSetState($IdentBlue, $GUI_UNCHECKED)
        GUICtrlSetState($IdentBlue, $GUI_DISABLE)
        GUICtrlSetState($IdentPurple, $GUI_UNCHECKED)
        GUICtrlSetState($IdentPurple, $GUI_DISABLE)
        GUICtrlSetState($IdentGold, $GUI_UNCHECKED)
        GUICtrlSetState($IdentGold, $GUI_DISABLE)
        ;GUICtrlSetState($IdentGreen, $GUI_UNCHECKED)
        ;GUICtrlSetState($IdentGreen, $GUI_DISABLE)
        GUICtrlSetState($RadioIdentItems, $GUI_UNCHECKED)
        GUICtrlSetState($RadioIdentItems, $GUI_DISABLE)
        
        GUICtrlSetState($SellWhite, $GUI_UNCHECKED)
        GUICtrlSetState($SellWhite, $GUI_DISABLE)
        GUICtrlSetState($SellBlue, $GUI_UNCHECKED)
        GUICtrlSetState($SellBlue, $GUI_DISABLE)
        GUICtrlSetState($SellPurple, $GUI_UNCHECKED)
        GUICtrlSetState($SellPurple, $GUI_DISABLE)
        GUICtrlSetState($SellGold, $GUI_UNCHECKED)
        GUICtrlSetState($SellGold, $GUI_DISABLE)
        GUICtrlSetState($SellGreen, $GUI_UNCHECKED)
        GUICtrlSetState($SellGreen, $GUI_DISABLE)
        GUICtrlSetState($RadioSellItems, $GUI_UNCHECKED)
        GUICtrlSetState($RadioSellItems, $GUI_DISABLE)
        
        GUICtrlSetState($PickDye_Blue, $GUI_UNCHECKED)
        GUICtrlSetState($PickDye_Blue, $GUI_DISABLE)
		GUICtrlSetState($PickDye_Green, $GUI_UNCHECKED)
        GUICtrlSetState($PickDye_Green, $GUI_DISABLE)
		GUICtrlSetState($PickDye_Purple, $GUI_UNCHECKED)
        GUICtrlSetState($PickDye_Purple, $GUI_DISABLE)
		GUICtrlSetState($PickDye_Red, $GUI_UNCHECKED)
        GUICtrlSetState($PickDye_Red, $GUI_DISABLE)
		GUICtrlSetState($PickDye_Yellow, $GUI_UNCHECKED)
        GUICtrlSetState($PickDye_Yellow, $GUI_DISABLE)
		GUICtrlSetState($PickDye_Brown, $GUI_UNCHECKED)
        GUICtrlSetState($PickDye_Brown, $GUI_DISABLE)
		GUICtrlSetState($PickDye_Orange, $GUI_UNCHECKED)
        GUICtrlSetState($PickDye_Orange, $GUI_DISABLE)
		GUICtrlSetState($PickDye_Silver, $GUI_UNCHECKED)
        GUICtrlSetState($PickDye_Silver, $GUI_DISABLE)
        GUICtrlSetState($PickDye_Pink, $GUI_UNCHECKED)
        GUICtrlSetState($PickDye_Pink, $GUI_DISABLE)
		GUICtrlSetState($RadioPickupDye, $GUI_UNCHECKED)
        GUICtrlSetState($RadioPickupDye, $GUI_DISABLE)
	Else
		GuiStartHandler()
		
        GUICtrlSetState($NormalMode, $GUI_ENABLE)
        GUICtrlSetState($HardMode, $GUI_ENABLE)
        
        GUICtrlSetState($Status, $GUI_ENABLE)
        GUICtrlSetState($UseScroll, $GUI_ENABLE)
        GUICtrlSetState($RadioSetting, $GUI_ENABLE)
        
        GUICtrlSetState($AuthBag1, $GUI_ENABLE)
        GUICtrlSetState($AuthBag2, $GUI_ENABLE)
        GUICtrlSetState($AuthBag3, $GUI_ENABLE)
        GUICtrlSetState($AuthBag4, $GUI_ENABLE)
        GUICtrlSetState($RadioAuthBags, $GUI_ENABLE)
        
        GUICtrlSetState($RadioItemsAll, $GUI_ENABLE)
        GUICtrlSetState($RadioWhite, $GUI_ENABLE)
        GUICtrlSetState($RadioBlue, $GUI_ENABLE)
        GUICtrlSetState($RadioPurple, $GUI_ENABLE)
        GUICtrlSetState($RadioGold, $GUI_ENABLE)
        GUICtrlSetState($RadioGreen, $GUI_ENABLE)
        
        GUICtrlSetState($PickWhite, $GUI_ENABLE)
        GUICtrlSetState($PickBlue, $GUI_ENABLE)
        GUICtrlSetState($PickPurple, $GUI_ENABLE)
        GUICtrlSetState($PickGold, $GUI_ENABLE)
        GUICtrlSetState($PickGreen, $GUI_ENABLE)
        GUICtrlSetState($RadioPickup, $GUI_ENABLE)
        
        ;GUICtrlSetState($IdentWhite, $GUI_ENABLE)
        GUICtrlSetState($IdentBlue, $GUI_ENABLE)
        GUICtrlSetState($IdentPurple, $GUI_ENABLE)
        GUICtrlSetState($IdentGold, $GUI_ENABLE)
        ;GUICtrlSetState($IdentGreen, $GUI_ENABLE)
        GUICtrlSetState($RadioIdentItems, $GUI_ENABLE)
        
        GUICtrlSetState($SellWhite, $GUI_ENABLE)
        GUICtrlSetState($SellBlue, $GUI_ENABLE)
        GUICtrlSetState($SellPurple, $GUI_ENABLE)
        GUICtrlSetState($SellGold, $GUI_ENABLE)
        GUICtrlSetState($SellGreen, $GUI_ENABLE)
        GUICtrlSetState($RadioSellItems, $GUI_ENABLE)
        
        GUICtrlSetState($PickDye_Blue, $GUI_ENABLE)
        GUICtrlSetState($PickDye_Green, $GUI_ENABLE)
        GUICtrlSetState($PickDye_Purple, $GUI_ENABLE)
        GUICtrlSetState($PickDye_Red, $GUI_ENABLE)
        GUICtrlSetState($PickDye_Yellow, $GUI_ENABLE)
        GUICtrlSetState($PickDye_Brown, $GUI_ENABLE)
        GUICtrlSetState($PickDye_Orange, $GUI_ENABLE)
        GUICtrlSetState($PickDye_Silver, $GUI_ENABLE)
        GUICtrlSetState($PickDye_Pink, $GUI_ENABLE)
        GUICtrlSetState($RadioPickupDye, $GUI_ENABLE)
	EndIf
EndFunc

Func RadiosModeHandler() ;Handle mode radios
    If ((GUICtrlRead($NormalMode) == $GUI_UNCHECKED) AND (GUICtrlRead($HardMode) == $GUI_UNCHECKED)) Then
        GUICtrlSetState($NormalMode, $GUI_CHECKED)
    EndIf
EndFunc

Func RadiosHandler() ;Handle radios that check all checkboxes
    If (GUICtrlRead($RadioSetting) == $GUI_CHECKED) Then
		GUICtrlSetState($Status, $GUI_CHECKED)
		GUICtrlSetState($UseScroll, $GUI_CHECKED)
        
		GUICtrlSetState($RadioSetting, $GUI_UNCHECKED) 
    EndIf

    If (GUICtrlRead($RadioAuthBags) == $GUI_CHECKED) Then
		GUICtrlSetState($AuthBag1, $GUI_CHECKED)
		GUICtrlSetState($AuthBag2, $GUI_CHECKED)
		GUICtrlSetState($AuthBag3, $GUI_CHECKED)
		GUICtrlSetState($AuthBag4, $GUI_CHECKED)
        
		GUICtrlSetState($RadioAuthBags, $GUI_UNCHECKED)
    EndIf
	
	If (GUICtrlRead($RadioWhite) == $GUI_CHECKED) Then 
		GUICtrlSetState($PickWhite, $GUI_CHECKED)
		;GUICtrlSetState($IdentWhite, $GUI_CHECKED)
		GUICtrlSetState($SellWhite, $GUI_CHECKED)
		
		GUICtrlSetState($RadioWhite, $GUI_UNCHECKED)
	EndIf
	If (GUICtrlRead($RadioBlue) == $GUI_CHECKED) Then
		GUICtrlSetState($PickBlue, $GUI_CHECKED)
		GUICtrlSetState($IdentBlue, $GUI_CHECKED)
		GUICtrlSetState($SellBlue, $GUI_CHECKED)
		
		GUICtrlSetState($RadioBlue, $GUI_UNCHECKED)
	EndIf
	If (GUICtrlRead($RadioPurple) == $GUI_CHECKED) Then
		GUICtrlSetState($PickPurple, $GUI_CHECKED)
		GUICtrlSetState($IdentPurple, $GUI_CHECKED)
		GUICtrlSetState($SellPurple, $GUI_CHECKED)
		
		GUICtrlSetState($RadioPurple, $GUI_UNCHECKED)
	EndIf
	If (GUICtrlRead($RadioGold) == $GUI_CHECKED) Then
		GUICtrlSetState($PickGold, $GUI_CHECKED)
		GUICtrlSetState($IdentGold, $GUI_CHECKED)
		GUICtrlSetState($SellGold, $GUI_CHECKED)
		
		GUICtrlSetState($RadioGold, $GUI_UNCHECKED)
	EndIf
	If (GUICtrlRead($RadioGreen) == $GUI_CHECKED) Then
		GUICtrlSetState($PickGreen, $GUI_CHECKED)
		;GUICtrlSetState($IdentGreen, $GUI_CHECKED)
		GUICtrlSetState($SellGreen, $GUI_CHECKED)
		
		GUICtrlSetState($RadioGreen, $GUI_UNCHECKED)
	EndIf
	
	If (GUICtrlRead($RadioItemsAll) == $GUI_CHECKED) Then
		GUICtrlSetState($RadioPickup, $GUI_CHECKED)
		GUICtrlSetState($RadioIdentItems, $GUI_CHECKED)
		GUICtrlSetState($RadioSellItems, $GUI_CHECKED)
		
		GUICtrlSetState($RadioItemsAll, $GUI_UNCHECKED)
	EndIf
	If (GUICtrlRead($RadioPickup) == $GUI_CHECKED) Then
		GUICtrlSetState($PickWhite, $GUI_CHECKED)
		GUICtrlSetState($PickBlue, $GUI_CHECKED)
		GUICtrlSetState($PickPurple, $GUI_CHECKED)
		GUICtrlSetState($PickGold, $GUI_CHECKED)
		GUICtrlSetState($PickGreen, $GUI_CHECKED)
        
		GUICtrlSetState($RadioPickup, $GUI_UNCHECKED)
	EndIf
	If (GUICtrlRead($RadioIdentItems) == $GUI_CHECKED) Then
		;GUICtrlSetState($IdentWhite, $GUI_CHECKED)
		GUICtrlSetState($IdentBlue, $GUI_CHECKED)
		GUICtrlSetState($IdentPurple, $GUI_CHECKED)
		GUICtrlSetState($IdentGold, $GUI_CHECKED)
		;GUICtrlSetState($IdentGreen, $GUI_CHECKED)
        
		GUICtrlSetState($RadioIdentItems, $GUI_UNCHECKED)
	EndIf
	If (GUICtrlRead($RadioSellItems) == $GUI_CHECKED) Then
		GUICtrlSetState($SellWhite, $GUI_CHECKED)
		GUICtrlSetState($SellBlue, $GUI_CHECKED)
		GUICtrlSetState($SellPurple, $GUI_CHECKED)
		GUICtrlSetState($SellGold, $GUI_CHECKED)
		GUICtrlSetState($SellGreen, $GUI_CHECKED)
        
		GUICtrlSetState($RadioSellItems, $GUI_UNCHECKED)
	EndIf
    If (GUICtrlRead($RadioPickupDye) == $GUI_CHECKED) Then
		GUICtrlSetState($PickDye_Green, $GUI_CHECKED)
		GUICtrlSetState($PickDye_Purple, $GUI_CHECKED)
		GUICtrlSetState($PickDye_Red, $GUI_CHECKED)
		GUICtrlSetState($PickDye_Yellow, $GUI_CHECKED)
		GUICtrlSetState($PickDye_Brown, $GUI_CHECKED)
		GUICtrlSetState($PickDye_Orange, $GUI_CHECKED)
		GUICtrlSetState($PickDye_Silver, $GUI_CHECKED)
        GUICtrlSetState($PickDye_Pink, $GUI_CHECKED)
		GUICtrlSetState($RadioPickupDye, $GUI_CHECKED)
	EndIf
EndFunc

Func RefreshInterface()
    Local $CharName[1]
	Local $lWinList = ProcessList("gw.exe")
    
    Switch $lWinList[0][0]
		Case 0
            MsgBox(16, "PreFarmer_Bot", "Please open Guild Wars and log into a character before running this program.")
            Exit
        Case Else
            For $i = 1 To $lWinList[0][0]
                MemoryOpen($lWinList[$i][1])
                $lOpenProcess = DllCall($mKernelHandle, 'int', 'OpenProcess', 'int', 0x1F0FFF, 'int', 1, 'int', $lWinList[$i][1])
                $GWHandle = $lOpenProcess[0]
                If $GWHandle Then
                    $CharacterName = ScanForCharname()
                    If IsString($CharacterName) Then
                        ReDim $CharName[UBound($CharName) + 1]
                        $CharName[$i] = $CharacterName
                    EndIf
                EndIf
                $GWHandle = 0
            Next
            GUICtrlSetData($CharInput, _ArrayToString($CharName, "|"), $CharName[1])	
    EndSwitch
EndFunc

Func ActivateAllGUI() ;Activate selectors and checkboxes (except Start/Pause button and Rendering checkbox)
	;Selectors
	GUICtrlSetState($JobToDo, $GUI_ENABLE)
	
	GUICtrlSetState($StartButton, $GUI_ENABLE)
	GUICtrlSetState($RenderingBox, $GUI_ENABLE)
	;Checkboxes	
    GUICtrlSetState($NormalMode, $GUI_ENABLE)
    GUICtrlSetState($HardMode, $GUI_ENABLE)
    
    GUICtrlSetState($Status, $GUI_ENABLE)
    GUICtrlSetState($UseScroll, $GUI_ENABLE)
    GUICtrlSetState($RadioSetting, $GUI_ENABLE)
     
    GUICtrlSetState($AuthBag1, $GUI_ENABLE)
    GUICtrlSetState($AuthBag2, $GUI_ENABLE)
    GUICtrlSetState($AuthBag3, $GUI_ENABLE)
    GUICtrlSetState($AuthBag4, $GUI_ENABLE)
    GUICtrlSetState($RadioAuthBags, $GUI_ENABLE)
        
    GUICtrlSetState($RadioItemsAll, $GUI_ENABLE)
    GUICtrlSetState($RadioWhite, $GUI_ENABLE)
    GUICtrlSetState($RadioBlue, $GUI_ENABLE)
    GUICtrlSetState($RadioPurple, $GUI_ENABLE)
    GUICtrlSetState($RadioGold, $GUI_ENABLE)
    GUICtrlSetState($RadioGreen, $GUI_ENABLE)
        
    GUICtrlSetState($PickWhite, $GUI_ENABLE)
    GUICtrlSetState($PickBlue, $GUI_ENABLE)
    GUICtrlSetState($PickPurple, $GUI_ENABLE)
    GUICtrlSetState($PickGold, $GUI_ENABLE)
    GUICtrlSetState($PickGreen, $GUI_ENABLE)
    GUICtrlSetState($RadioPickup, $GUI_ENABLE)
        
    ;GUICtrlSetState($IdentWhite, $GUI_ENABLE)
    GUICtrlSetState($IdentBlue, $GUI_ENABLE)
    GUICtrlSetState($IdentPurple, $GUI_ENABLE)
    GUICtrlSetState($IdentGold, $GUI_ENABLE)
    ;GUICtrlSetState($IdentGreen, $GUI_ENABLE)
    GUICtrlSetState($RadioIdentItems, $GUI_ENABLE)
        
    GUICtrlSetState($SellWhite, $GUI_ENABLE)
    GUICtrlSetState($SellBlue, $GUI_ENABLE)
    GUICtrlSetState($SellPurple, $GUI_ENABLE)
    GUICtrlSetState($SellGold, $GUI_ENABLE)
    GUICtrlSetState($SellGreen, $GUI_ENABLE)
    GUICtrlSetState($RadioSellItems, $GUI_ENABLE)
    
    GUICtrlSetState($PickDye_Blue, $GUI_ENABLE)
    GUICtrlSetState($PickDye_Green, $GUI_ENABLE)
    GUICtrlSetState($PickDye_Purple, $GUI_ENABLE)
    GUICtrlSetState($PickDye_Red, $GUI_ENABLE)
    GUICtrlSetState($PickDye_Yellow, $GUI_ENABLE)
    GUICtrlSetState($PickDye_Brown, $GUI_ENABLE)
    GUICtrlSetState($PickDye_Orange, $GUI_ENABLE)
    GUICtrlSetState($PickDye_Silver, $GUI_ENABLE)
    GUICtrlSetState($PickDye_Pink, $GUI_ENABLE)
    GUICtrlSetState($RadioPickupDye, $GUI_ENABLE)
EndFunc

Func DeactivateAllGUI($Selectors = 1) ;Deactivate selectors and checkboxes (except Start/Pause button and Rendering checkbox)
;~ Pass $Selectors as 0 to make it not deactivate selectors
	
    If $Selectors Then
		GUICtrlSetState($JobToDo, $GUI_DISABLE)
		GUICtrlSetState($StartButton, $GUI_DISABLE)
		GUICtrlSetState($RenderingBox, $GUI_DISABLE)
    EndIf
    
    GUICtrlSetState($NormalMode, $GUI_DISABLE)
    GUICtrlSetState($HardMode, $GUI_DISABLE)
    
	GUICtrlSetState($Status, $GUI_DISABLE)
	GUICtrlSetState($UseScroll, $GUI_DISABLE)
    GUICtrlSetState($RadioSetting, $GUI_DISABLE)
     
    GUICtrlSetState($AuthBag1, $GUI_DISABLE)
    GUICtrlSetState($AuthBag2, $GUI_DISABLE)
    GUICtrlSetState($AuthBag3, $GUI_DISABLE)
    GUICtrlSetState($AuthBag4, $GUI_DISABLE)
    GUICtrlSetState($RadioAuthBags, $GUI_DISABLE)
        
    GUICtrlSetState($RadioItemsAll, $GUI_DISABLE)
    GUICtrlSetState($RadioWhite, $GUI_DISABLE)
    GUICtrlSetState($RadioBlue, $GUI_DISABLE)
    GUICtrlSetState($RadioPurple, $GUI_DISABLE)
    GUICtrlSetState($RadioGold, $GUI_DISABLE)
    GUICtrlSetState($RadioGreen, $GUI_DISABLE)
        
    GUICtrlSetState($PickWhite, $GUI_DISABLE)
    GUICtrlSetState($PickBlue, $GUI_DISABLE)
    GUICtrlSetState($PickPurple, $GUI_DISABLE)
    GUICtrlSetState($PickGold, $GUI_DISABLE)
    GUICtrlSetState($PickGreen, $GUI_DISABLE)
    GUICtrlSetState($RadioPickup, $GUI_DISABLE)
        
    ;GUICtrlSetState($IdentWhite, $GUI_DISABLE)
    GUICtrlSetState($IdentBlue, $GUI_DISABLE)
    GUICtrlSetState($IdentPurple, $GUI_DISABLE)
    GUICtrlSetState($IdentGold, $GUI_DISABLE)
    ;GUICtrlSetState($IdentGreen, $GUI_DISABLE)
    GUICtrlSetState($RadioIdentItems, $GUI_DISABLE)
        
    GUICtrlSetState($SellWhite, $GUI_DISABLE)
    GUICtrlSetState($SellBlue, $GUI_DISABLE)
    GUICtrlSetState($SellPurple, $GUI_DISABLE)
    GUICtrlSetState($SellGold, $GUI_DISABLE)
    GUICtrlSetState($SellGreen, $GUI_DISABLE)
    GUICtrlSetState($RadioSellItems, $GUI_DISABLE)
    
    GUICtrlSetState($PickDye_Blue, $GUI_DISABLE)
    GUICtrlSetState($PickDye_Green, $GUI_DISABLE)
    GUICtrlSetState($PickDye_Purple, $GUI_DISABLE)
    GUICtrlSetState($PickDye_Red, $GUI_DISABLE)
    GUICtrlSetState($PickDye_Yellow, $GUI_DISABLE)
    GUICtrlSetState($PickDye_Brown, $GUI_DISABLE)
    GUICtrlSetState($PickDye_Orange, $GUI_DISABLE)
    GUICtrlSetState($PickDye_Silver, $GUI_DISABLE)
    GUICtrlSetState($PickDye_Pink, $GUI_DISABLE)
    GUICtrlSetState($RadioPickupDye, $GUI_DISABLE)
EndFunc

Func _exit() ;Enables Rendering and close the bot
   If GUICtrlRead($RenderingBox) == $GUI_CHECKED Then
	  EnableRendering()
	  WinSetState($HWND, "", @SW_SHOW)
	  Sleep(500)
   EndIf
   Exit
EndFunc

Func Out($msg)
   GUICtrlSetData($StatusLabel, GUICtrlRead($StatusLabel) & "[" & @HOUR & ":" & @MIN & "]" & " " & $msg & @CRLF)
   _GUICtrlEdit_Scroll($StatusLabel, $SB_SCROLLCARET)
   _GUICtrlEdit_Scroll($StatusLabel, $SB_LINEUP)
EndFunc
	#EndRegion GUI base function
	
	#Region GUI Enhancement
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
	#EndRegion GUI Enhancement
#EndRegion GUI handeling Functions

#Region Bot init Functions
Func OfflineMod() ;Put the player offline (Not working at the moment : it's put you as disconnected for the server which ask you to reconnect)
    If (GUICtrlRead($Status) = $GUI_CHECKED) Then
        Out("Playing offline.")
        SetPlayerStatus(0)
    Else
        Out("Playing online.")
    EndIf
EndFunc

	#Region IDs Functions
Func GetJobID() ; Returns the $JobID based on what have been selected on jobs' selector
	Local $JobID = 0
	
	If (GUICtrlRead($JobToDo, "") == "Level 20") Then
		$JobID = 1
	ElseIf (GUICtrlRead($JobToDo, "") == "Survivor Title") Then
		$JobID = 2
	ElseIf (GUICtrlRead($JobToDo, "") == "Farm") Then
		$JobID = 3
	EndIf
	
	Return $JobID
EndFunc
	#EndRegion IDs Functions
    
    #Region Side Init Functions
Func CrashCheck()
	If WinExists("Gw.exe") Then
		Out("Crashed")
		$GWPath = _ProcessGetLocation(ProcessExists("gw.exe"))
		MemoryClose()
		ProcessClose("gw.exe")
		RndSleep(250)
		;Run($GWPath & " -password " & GUICtrlRead($txtPW))
		WinWait("Guild Wars")
		Sleep(2000)
		Global $mLabels[1][2]
		Initialize(ProcessExists("gw.exe"))
		Do
			ControlSend("[CLASS:ArenaNet_Dx_Window_Class]","","","y") ;Send "y" to accept reconnect if you've dced outside. It won't reconnect if you dc'ed in an outpost
			RndSleep(500)
			$me = GetAgentByID(-2)
		Until DllStructGetData($me, 'X') <> 0 Or DllStructGetData($me, 'Y') <> 0
		RndSleep(3000)
		GoToTown()
		MsgBox(0,"Error","Crashed please restart")
		_exit()
	EndIf
EndFunc

Func _ProcessGetLocation($iPID)
    Local $aProc = DllCall('kernel32.dll', 'hwnd', 'OpenProcess', 'int', BitOR(0x0400, 0x0010), 'int', 0, 'int', $iPID)
    If $aProc[0] = 0 Then Return SetError(1, 0, '')
    Local $vStruct = DllStructCreate('int[1024]')
    DllCall('psapi.dll', 'int', 'EnumProcessModules', 'hwnd', $aProc[0], 'ptr', DllStructGetPtr($vStruct), 'int', DllStructGetSize($vStruct), 'int_ptr', 0)
    Local $aReturn = DllCall('psapi.dll', 'int', 'GetModuleFileNameEx', 'hwnd', $aProc[0], 'int', DllStructGetData($vStruct, 1), 'str', '', 'int', 2048)
    If StringLen($aReturn[3]) = 0 Then Return SetError(2, 0, '')
    Return $aReturn[3]
EndFunc
    #EndRegion Side Init Functions
#EndRegion Bot init Functions

#Region Actions
    #Region Travel Map
Func Setup()
   If GetMapID() <> $MAP_ID_GUUNAR Then
	  Out("Travelling to Guunar.")
	  GoToTown()
   EndIf
   LeaveGroup()
   If (GUICtrlRead($NormalMode) == $GUI_CHECKED) Then SwitchMode(0)
   If (GUICtrlRead($HardMode) == $GUI_CHECKED) Then SwitchMode(1)
   RndSleep(500)
EndFunc

Func GoToTown()
	RndTravel($MAP_ID_GUUNAR)
	RndSleep(1000)
	$OutpostRegion = GetRegion()
EndFunc
    #EndRegion Travel Map
    
    #Region Farms
Func TakeQuest()
	Do
		Out("Taking quest")
		GoNearestNPCToCoords(17320, -4900)
		RndSleep(250)
		AcceptQuest($FORNIS_QUEST)
		RndSleep(1000)
		GoNPC(GetNearestNPCToCoords(17320, -4900))
		RndSleep(1000)
		Dialog($FIRST_DIALOG)
		WaitForLoad()
		RndSleep(250)
        If (GetMapID() == 548) Then
            GoToTown()
            WaitForLoad()
        EndIf
	Until GetMapID() = $MAP_ID_FORNISINSTANCE
EndFunc

Func RunQuest()
    Sleep(5000)
    If (GetMapID() == 548) Then ;Norrhart
        GoToTown()
        WaitForLoad()
        Return
    EndIf
    If (GetMapID() == 644) Then ;Gunnar
        GoToTown()
        WaitForLoad()
        TakeQuest()
    EndIf
    
	; UseScroll()
	RndSleep(1500)
	If AggroMoveToEx(-11040, -16400) Then Return 1
	If AggroMoveToEx(-3585, -15915) Then Return 1
	If AggroMoveToEx(-1081, -14387) Then Return 1
	If AggroMoveToEx(3788, -16406) Then Return 1
    
    If (GetMapID() == 548) Then
        GoToTown()
        WaitForLoad()
        Return
    EndIf
    
	MoveTo(5724,-15148)
	MoveTo(5053,-15835)
    
    If (GetMapID() == 548) Then
        GoToTown()
        WaitForLoad()
        Return
    EndIf
    
	Do
		RndSleep(300)
		GetNearestEnemyToAgent(-2)
		$distance = @extended
	Until $distance < 700
	If AggroMoveToEx(8913, -16174) Then Return 1
	If AggroMoveToEx(12900, -16065) Then Return 1

	Out("Opening final chest")
	RndSleep(100)
	$agent = GetNearestSignpostToCoords(13275,-16039)
	ChangeTarget($agent)
	MoveTo(DllStructGetData($agent, 'X'),DllStructGetData($agent, 'Y'))
	RndSleep(500)
	GoSignpost($agent)
	RndSleep(2000)
	Out("Picking up ale")
	CheckAndPickUp()
	RndSleep(2000)
	GoToTown()
	Out("Accepting quest reward")
	$count = 0
	Do
		GoNearestNPCToCoords(17320, -4900)
		RndSleep(1000)
		;Dialog(0x00835807)
		QuestReward($FORNIS_QUEST)
		RndSleep(500)
		$count+=1
	Until GetQuestByID($FORNIS_QUEST) = 0 or $count>5
	RndSleep(500)
	
	$OutpostRegion = ChangeRegion($OutpostRegion)
	RndSleep(1000)
EndFunc

Func Fight($z, $s = "enemies")
	Out("Fighting " & $s & "!")
	RndSleep(500)
	$target = 0
	$distance = 99999999
	Do
		RndSleep(250)
		$enemyId = GetNearestEnemyToAgent(-2)
	Until $enemyId <> 0
	$skillbar = GetSkillbar()
	$bar = 7
	$skillId = DllStructGetData($skillbar, 'Id7')
	If $skillId = 0 Then $bar = 6
	Do
		$skillbar = GetSkillbar()
		$skillRecharge = DllStructGetData($skillbar, 'Recharge8')
		If $skillRecharge = 0 Or GetEnergy() = 0 Then
			Out("Standing back up!")
			Do
				$skillbar = GetSkillbar()
				$Me = GetAgentByID()
				$maxEnergy = DllStructGetData($Me, 'MaxEnergy')
				If $maxEnergy > $maxAllowdEnergy Then Return 1
				If $maxEnergy <> GetEnergy() Then UseSkill(8,$Me)
				$skillRecharge = DllStructGetData($skillbar, 'Recharge8')
				RndSleep(50)
			Until $skillRecharge <> 0
			Out("Fighting " & $s & "!")
		EndIf

		; Update to priority attack Ettins
		$ettinID = GetNearestEttin()
		If $ettinID <> 0 Then
			$Me = GetAgentByID(-2)
			$ettinDistance = ComputeDistance(DllStructGetData($Me, 'X'),DllStructGetData($Me, 'Y'),DllStructGetData($ettinID, 'X'),DllStructGetData($ettinID, 'Y'))
			If $ettinDistance < $z Then
				$target = $ettinID
				$distance = $ettinDistance
			EndIf
		EndIf

		$dead = false
		$target = GetAgentByID(DllStructGetData($target, 'Id'))
		If (DllStructGetData($target, 'HP') < 0.005) Then
			$dead = true
		EndIf
		If DllStructGetData($target, 'Id') = 0 OR $distance > $z OR $dead Then
			$target = GetLowestEnemyToAgent(-2)
			$distance = @extended
			;ConsoleWrite("New target: " & DllStructGetData($target, 'Id') & " distance= " & $distance & " dead=" & $dead  & @CRLF)
		EndIf
		; Update to fight Lt. Maghma last
		If GetAgentName($target) = "Lieutenant Mahgma" Then
			$possibleTarget = GetLowestEnemyToAgentExcludingMaghma()
			$targetDistance = @extended
			If $targetDistance<$z Then
				$target = $possibleTarget
				$distance = $targetDistance
			EndIf
		EndIf

		; Update to use blocking skills
		$block = 0
		$skillbar = GetSkillbar()
		$skillRecharge = DllStructGetData($skillbar, 'Recharge1')
		If $skillRecharge = 0 Then $block = 1

		$useSkill = -1
		For $i = $bar To 2 Step -1
			$recharged = DllStructGetData($skillbar, 'Recharge'& $i)
			$strikes = DllStructGetData($skillbar, 'AdrenalineB'& $i)
			If $recharged = 0 AND $intAdrenaline[$i-1] <= $strikes Then
				$useSkill = $i
				ExitLoop
			EndIf
		Next

		If ($useSkill <> -1 OR $block) AND $target <> 0 AND $distance < $z Then
			Out("Changing target")
			ChangeTarget($target)
			RndSleep(150)
			If $dead = True Then
				If DllStructGetData(GetSkillbar(), 'Recharge8') = 0 Or GetEnergy() = 0 Then ContinueLoop
				Out("Attacking target")
				Attack($target)
			EndIf
			RndSleep(150)
			If $block Then
				If DllStructGetData(GetSkillbar(), 'Recharge8') = 0 Or GetEnergy() = 0 Then ContinueLoop
				UseSkill(1,$target)
				RndSleep(500)
			EndIf
			$skillbar = GetSkillbar()
			If DllStructGetData($skillbar, 'Recharge8') = 0 Or GetEnergy() = 0 Then ContinueLoop
			UseSkill($useSkill,$target)
		EndIf
		RndSleep(500)
		;ConsoleWrite($target & " " & $distance & @CRLF)
	Until DllStructGetData($target, 'Id') = 0 OR $distance > $z

	Out("Picking up items")
	CheckAndPickUp()
	Return 0
EndFunc
    #EndRegion Farms

    #Region Player Stats Functions
Func GetLevel() ;Return player's level

	Local $myXP = GetExperience()

	Select
		Case $myXP < 2000
			Return 1
		Case $myXP >= 2000 And $myXP < 4600
			Return 2
		Case $myXP >= 4600 And $myXP < 7800
			Return 3
		Case $myXP >= 7800 And $myXP < 11600
			Return 4
		Case $myXP >= 11600 And $myXP < 16000
			Return 5
		Case $myXP >= 16000 And $myXP < 21000
			Return 6
		Case $myXP >= 21000 And $myXP < 26600
			Return 7
		Case $myXP >= 26600 And $myXP < 32800
			Return 8
		Case $myXP >= 32800 And $myXP < 39600
			Return 9
		Case $myXP >= 39600 And $myXP < 47000
			Return 10
		Case $myXP >= 47000 And $myXP < 55000
			Return 11
		Case $myXP >= 55000 And $myXP < 63600
			Return 12
		Case $myXP >= 63600 And $myXP < 72800
			Return 13
		Case $myXP >= 72800 And $myXP < 82600
			Return 14
		Case $myXP >= 82600 And $myXP < 93000
			Return 15
		Case $myXP >= 93000 And $myXP < 104000
			Return 16
		Case $myXP >= 104000 And $myXP < 115600
			Return 17
		Case $myXP >= 115600 And $myXP < 127800
			Return 18
		Case $myXP >= 127800 And $myXP < 140600
			Return 19
		Case $myXP >= 140600
			Return 20
	EndSelect
EndFunc

Func LvlCount() ;Prints player's level in Status console
	  Local $lvl = GetLevel()
	  Out ("Level:" & $lvl)
EndFunc

Func LvlStop() ;Check if lvl20 stop is selected and stop bot at lvl20
    Local $myLVL = GetLevel()
   
    If ((GetJobID() == 1) AND ($myLVL >= 20)) Then
        Sleep(500)
        Out("Stopped at level 20")
        $BotRunning = False
    EndIf
EndFunc
    #EndRegion Player Stats Functions
    
    #Region Survivor
Func Survivor_Status() ;Checks if the bot has to do the survivor title (Return True or False)
    If (GetJobID() == 2) Then 
        Return True
    Else
        Return False
    EndIf
EndFunc
        
Func Survivor_Display() ;Checks for Survivor Title advancement
    Local $XpToMaxTitle = 1337500
    Local $Error = 0
    
    If (Survivor_Status()) Then
        $XpToMaxTitle -= GetSurvivorTitle()
        Out("Xp pts remaining to max title: " & $XpToMaxTitle)
        If (GetSurvivorTitle() < 140600) Then Out("Survivor title rank 0.")
        ElseIf ((GetSurvivorTitle() >= 140600) AND (GetSurvivorTitle() < 587500)) Then Out("Survivor title rank 1.")
        ElseIf ((GetSurvivorTitle() >= 587500) AND (GetSurvivorTitle() < 1337500 )) Then Out("Survivor title rank 2.")
        ElseIf (GetSurvivorTitle() >= 1337500 ) Then 
            Out("Survivor title rank 3.")
            $BotRunning = False
        Else
            $Error = 1
            Out("ERROR : Unable to get player's Survivor title.")
    EndIf
    
    Return $Error
EndFunc
    #EndRegion Survivor
#EndRegion Actions

#Region Extra Functions
	#Region Map interaction Functions
Func ChangeRegion($firstRegion) ;Change region in outpost
;~ You have to pass the initial region as argument
	Local $aMapID = GetMapID()
	Local $nextRegion
	
	If Not GetIsExplorableArea() Then
		If ($firstRegion <> GetRegion()) Then $firstRegion = GetRegion()
		Do
			RndTravel($aMapID)
			$nextRegion = GetRegion()
		Until ($firstRegion <> $nextRegion)
		Return $nextRegion 
	Else
		Out("Player must be in an outpost to change region.")
	EndIf
EndFunc   ;==>ChangeRegion

Func RndTravel($aMapID) ;Travel to a random region in the outpost
	Local $UseDistricts = 11 ; 7=eu-only, 8=eu+int, 11=all(excluding America)
	; Region/Language order: eu-en, eu-fr, eu-ge, eu-it, eu-sp, eu-po, eu-ru, us-en, int, asia-ko, asia-ch, asia-ja
	Local $Region[11] = [2, 2, 2, 2, 2, 2, 2, -2, 1, 3, 4]
	Local $Language[11] = [0, 2, 3, 4, 5, 9, 10, 0, 0, 0, 0]
	Local $Random = Random(0, $UseDistricts - 1, 1)
	MoveMap($aMapID, $Region[$Random], 0, $Language[$Random])
	WaitMapLoading($aMapID)
EndFunc   ;==>RndTravel

Func WaitForLoad() ;Waits while the player is loading a map
	InitMapLoad()
	$deadlock = 0
	Do
		Sleep(100)
		$deadlock += 100
		$load = GetMapLoading()
		$lMe = GetAgentByID(-2)

	Until $load = 2 And DllStructGetData($lMe, 'X') = 0 And DllStructGetData($lMe, 'Y') = 0 Or $deadlock > 10000
	$deadlock = 0
	Do
		Sleep(100)
		$deadlock += 100
		$deadlock += 100
		$load = GetMapLoading()
		$lMe = GetAgentByID(-2)

	Until $load <> 2 And DllStructGetData($lMe, 'X') <> 0 And DllStructGetData($lMe, 'Y') <> 0 Or $deadlock > 30000

	rndslp(3000)
EndFunc   ;==>WaitForLoad

Func AggroMoveToEx($x, $y, $s = "enemies", $z = 2000)
	Out("Hunting " & $s)

	Move($x, $y)

	$iBlocked = 0
	$cbType = "float"
	Local $coords[2]
	$Me = GetAgentByID()
	$coords[0] = DllStructGetData($Me, 'X')
	$coords[1] = DllStructGetData($Me, 'Y')
	Do
		RndSleep(250)
		$oldCoords = $coords

		$enemy_target = GetLowestEnemyToAgent(-2)
		$Me = GetAgentByID()
		$distance = ComputeDistance(DllStructGetData($Me, 'X'), DllStructGetData($Me, 'Y'), DllStructGetData($enemy_target, 'X'), DllStructGetData($enemy_target, 'Y'))
		If (($distance < $z) AND ($enemy_target <> 0)) Then
			If Fight($z, $s) Then Return 1
			Out("Hunting " & $s)
		EndIf
		$Me = GetAgentByID()
		$coords[0] = DllStructGetData($Me, 'X')
		$coords[1] = DllStructGetData($Me, 'Y')
		If (($oldCoords[0] = $coords[0]) AND ($oldCoords[1] = $coords[1])) Then
			$iBlocked += 1
			MoveTo($coords[0], $coords[1], 1500)
			RndSleep(1500)
			MoveTo($x, $y)
		EndIf
	Until ComputeDistance($coords[0], $coords[1], $x, $y) < 250 OR $iBlocked > 20
	;ConsoleWrite("Reached destination: " & $x & "," & $y & @CRLF)
EndFunc
	#EndRegion Map interaction Functions
	
	#Region Chat Functions
Func Update($aText, $aFlag = 0)  ;~ Description: Writes text to chat.
;~    Out($text)
   TraySetToolTip(GetCharname() & @CRLF & $aText)
   $OldGuiText = $aText
   WriteChat($aText, $aFlag)
   ConsoleWrite($aText & @CRLF)
   $RestTimer = TimerInit()
EndFunc   ;==>Update
	#EndRegion Chat Functions
#EndRegion Extra Functions

#Region Actions

	#Region Side Functions
		#Region Player's Inventory handeling Functions
Func IDAndSell() ;Go to merchant, ident and sell
	Out("Cleaning inventory")
	MoveTo(17967, -7522)
	GoNearestNPCToCoords(17800, -7600)
    
    IdentItemToMerchant()

	SellItemToMerchant()
EndFunc

			#Region Count/Items Functions
Func CountSlots() ;Returns the number of slots remaining in the authorized bags (if no authorized bag, returns -1)
	Local $bag
	Local $temp = 0
	
	If (GUICtrlRead($AuthBag1) == $GUI_CHECKED) Then
		$bag = GetBag(1)
		$temp += DllStructGetData($bag, 'slots') - DllStructGetData($bag, 'ItemsCount')
	EndIf
	If (GUICtrlRead($AuthBag2) == $GUI_CHECKED) Then
		$bag = GetBag(2)
		$temp += DllStructGetData($bag, 'slots') - DllStructGetData($bag, 'ItemsCount')
	EndIf
	If (GUICtrlRead($AuthBag3) == $GUI_CHECKED) Then
		$bag = GetBag(3)
		$temp += DllStructGetData($bag, 'slots') - DllStructGetData($bag, 'ItemsCount')
	EndIf
	If (GUICtrlRead($AuthBag4) == $GUI_CHECKED) Then
		$bag = GetBag(4)
		$temp += DllStructGetData($bag, 'slots') - DllStructGetData($bag, 'ItemsCount')
	EndIf
	If ((GUICtrlRead($AuthBag1) == $GUI_UNCHECKED) AND (GUICtrlRead($AuthBag2) == $GUI_UNCHECKED) AND (GUICtrlRead($AuthBag3) == $GUI_UNCHECKED) AND (GUICtrlRead($AuthBag4) == $GUI_UNCHECKED)) Then ;If no bags authorized, return -1 (the bot is never gonna be marked as full and won't go to merchant)
		$temp = -1
	EndIf
	Return $temp
EndFunc   ;==>CountSlots

Func CheckIfInventoryIsFull() ;Returns True if not slot remaining, Else return False
	If ((CountSlots() <= 3) AND (CountSlots() >= 0)) Then
		Return True
	Else
		Return False
	EndIf
EndFunc   ;==>CheckIfInventoryIsFull

Func CountFreeSpace()
	If CountSlots() < 18 Then
		IDAndSell()
	Else
		Return False
	EndIf

	$gold = GetGoldCharacter()
	If $gold > 75000 Then DepositGold()
EndFunc

Func GetDyeCount($Dye_color = -1) ;Counts Dyes in player's inventory based on dye's color (pass $DYE_X X being dye's color as argument)
;~ GetDyeCount(-1) or GetDyeCount() returns number of dyes in bag no matter the color
	Local $DyeCount
	Local $aBag
	Local $aItem
	Local $i
	For $i = 1 To 4
		$aBag = GetBag($i)
		For $j = 1 To DllStructGetData($aBag, "Slots")
			$aItem = GetItemBySlot($aBag, $j)
			If DllStructGetData($aItem, "ModelID") == 146 Then
				If DllStructGetData($aitem, "ExtraID") == $Dye_color Then
					$DyeCount += DllStructGetData($aItem, "Quantity")
				EndIf
				If ($Dye_color == -1) Then 
					$DyeCount += DllStructGetData($aItem, "Quantity")
				EndIf
			Else
				ContinueLoop
			EndIf
		Next
	Next
	Return $DyeCount
EndFunc 

Func CountAndLogDyes() ;Counts dyes and prints the number of dyes in console based on selected dyes
	Local $DyeCount
	
	If (GUICtrlRead($PickDye_Blue) = $GUI_CHECKED) Then
		$DyeCount = GetDyeCount($DYE_Blue)
		If ($DyeCount > 0) Then
			logFile("Blue dye: " & $DyeCount)
		EndIf
	EndIf
	If (GUICtrlRead($PickDye_Green) = $GUI_CHECKED) Then
		$DyeCount = GetDyeCount($DYE_Green)
		If ($DyeCount > 0) Then
			logFile("Green dye: " & $DyeCount)
		EndIf
	EndIf
	If (GUICtrlRead($PickDye_Purple) = $GUI_CHECKED) Then
		$DyeCount = GetDyeCount($DYE_Purple)
		If ($DyeCount > 0) Then
			logFile("Purple dye: " & $DyeCount)
		EndIf
	EndIf
	If (GUICtrlRead($PickDye_Red) = $GUI_CHECKED) Then
		$DyeCount = GetDyeCount($DYE_Red)
		If ($DyeCount > 0) Then
			logFile("Red dye: " & $DyeCount)
		EndIf
	EndIf
	If (GUICtrlRead($PickDye_Yellow) = $GUI_CHECKED) Then
		$DyeCount = GetDyeCount($DYE_Yellow)
		If ($DyeCount > 0) Then
			logFile("Yellow dye: " & $DyeCount)
		EndIf
	EndIf
	If (GUICtrlRead($PickDye_Brown) = $GUI_CHECKED) Then
		$DyeCount = GetDyeCount($DYE_Brown)
		If ($DyeCount > 0) Then
			logFile("Brown dye: " & $DyeCount)
		EndIf
	EndIf
	If (GUICtrlRead($PickDye_Orange) = $GUI_CHECKED) Then
		$DyeCount = GetDyeCount($DYE_Orange)
		If ($DyeCount > 0) Then
			logFile("Orange dye: " & $DyeCount)
		EndIf
	EndIf
	If (GUICtrlRead($PickDye_Silver) = $GUI_CHECKED) Then
		$DyeCount = GetDyeCount($DYE_Silver)
		If ($DyeCount > 0) Then
			logFile("Silver dye: " & $DyeCount)
		EndIf
	EndIf
    If (GUICtrlRead($PickDye_Pink) = $GUI_CHECKED) Then
		$DyeCount = GetDyeCount($DYE_Pink)
		If ($DyeCount > 0) Then
			logFile("Pink dye: " & $DyeCount)
		EndIf
	EndIf
	If True Then ;White dye
		$DyeCount = GetDyeCount($DYE_White)
		If ($DyeCount > 0) Then
			logFile("White dye: " & $DyeCount)
		EndIf
	EndIf
	If True Then ;Black dye
		$DyeCount = GetDyeCount($DYE_Black)
		If ($DyeCount > 0) Then
			logFile("Black dye: " & $DyeCount)
		EndIf
	EndIf
EndFunc

Func IsKeepedDye($Dye_color) ;Returns 1 if this dye is checked as pickup in Gui
	If ((GUICtrlRead($PickDye_Blue) = $GUI_CHECKED) AND ($Dye_color == $DYE_Blue)) Then
		Return True
	EndIf
	If ((GUICtrlRead($PickDye_Green) = $GUI_CHECKED) AND ($Dye_color == $DYE_Green)) Then
		Return True
	EndIf
	If ((GUICtrlRead($PickDye_Purple) = $GUI_CHECKED) AND ($Dye_color == $DYE_Purple)) Then
		Return True
	EndIf
	If ((GUICtrlRead($PickDye_Red) = $GUI_CHECKED) AND ($Dye_color == $DYE_Red)) Then
		Return True
	EndIf
	If ((GUICtrlRead($PickDye_Yellow) = $GUI_CHECKED) AND ($Dye_color == $DYE_Yellow)) Then
		Return True
	EndIf
	If ((GUICtrlRead($PickDye_Brown) = $GUI_CHECKED) AND ($Dye_color == $DYE_Brown)) Then
		Return True
	EndIf
	If ((GUICtrlRead($PickDye_Orange) = $GUI_CHECKED) AND ($Dye_color == $DYE_Orange)) Then
		Return True
	EndIf
	If ((GUICtrlRead($PickDye_Silver) = $GUI_CHECKED) AND ($Dye_color == $DYE_Silver)) Then
		Return True
	EndIf
    If ((GUICtrlRead($PickDye_Pink) = $GUI_CHECKED) AND ($Dye_color == $DYE_Pink)) Then
		Return True
	EndIf
	If ($Dye_color == $DYE_White) Then ;White dye
		Return True
	EndIf
	If ($Dye_color == $DYE_Black) Then ;Black dye
		Return True
	EndIf
    
    Return False
EndFunc
			#EndRegion Count/Items Functions
			
			#Region Sell Functions
Func CanSell($aitem) ;Lists the unauthorized items to be sold and check if the item input can be sold
	Local $m = DllStructGetData($aitem, 'ModelID')
	Local $i = DllStructGetData($aitem, 'extraId')
    Local $lItemID = DllStructGetData($aItem, 'ID')
	Local $iRarity = GetRarity($lItemID)
    
    If ($m = 0) Then
        If (GetRarity($lItemID) == $RARITY_White) Then
            Return True
        Else
            Return False
        EndIf
	ElseIf (($m > 21785) And ($m < 21806)) Then ;Elite/Normal Tomes
		Return False
	ElseIf ($m = 146) Then ;Dyes
		If IsKeepedDye($i) Then ;Black & White
			Return False
		Else
			Return True
		EndIf
	ElseIf ($m = 22751) Then ;Lockpicks
		Return False
	ElseIf (($m = 2991) OR ($m = 2992) OR ($m = 2989) OR ($m = 5899)) Then ;ID/Salvage
		Return False
	ElseIf (($m = $ITEM_ID_Dwarven_Ale) OR ($m = $ITEM_ID_Aged_Dwarven_Ale)) Then ;Dwarven Ale/Aged Dwarven Ale
		Return False
	ElseIf (($m = 5594) OR ($m = 5595) OR ($m = 5611) OR ($m = 5853) OR ($m = 5975) OR ($m = 5976) OR ($m = 21233)) Then ;Scrolls
		Return False
	ElseIf (($iRarity == $RARITY_White) AND (GUICtrlRead($SellWhite) == $GUI_CHECKED)) Then
		Return True
	ElseIf (($iRarity == $RARITY_Blue) AND (GUICtrlRead($SellBlue) == $GUI_CHECKED)) Then
		Return True
	ElseIf (($iRarity == $RARITY_Purple) AND (GUICtrlRead($SellPurple) == $GUI_CHECKED)) Then
		Return True
	ElseIf (($iRarity == $RARITY_Gold) AND (GUICtrlRead($SellGold) == $GUI_CHECKED)) Then
		Return True
	ElseIf (($iRarity == $RARITY_Green) AND (GUICtrlRead($SellGreen) == $GUI_CHECKED)) Then
		Return True
	Else
		Return False
	EndIf
EndFunc   ;==>CanSell

Func Sell($bagIndex) ;Sell all authorized items in a bag
	$bag = GetBag($bagIndex)
	$numOfSlots = DllStructGetData($bag, 'slots')
	
	For $i = 1 To $numOfSlots
 		
		$aitem = GetItemBySlot($bagIndex, $i)
		If DllStructGetData($aitem, 'ID') = 0 Then ContinueLoop
		If CanSell($aitem) Then
            Out("Selling item " & $i & "in bag " & $bagIndex)
			SellItem($aitem)
		EndIf
		RndSleep(250)
	Next
EndFunc   ;==>Sell

Func SellItemToMerchant() ;Sell authorized items in authorized bags
	If (GUICtrlRead($AuthBag1) == $GUI_CHECKED) Then ;Check if bag1 is authorized to be sold
		Sell(1)
	EndIf
	If (GUICtrlRead($AuthBag2) == $GUI_CHECKED) Then ;Check if bag2 is authorized to be sold
		Sell(2)
	EndIf
	If (GUICtrlRead($AuthBag3) == $GUI_CHECKED) Then ;Check if bag3 is authorized to be sold
		Sell(3)
	EndIf
	If (GUICtrlRead($AuthBag4) == $GUI_CHECKED) Then ;Check if bag4 is authorized to be sold
		Sell(4)
	EndIf
EndFunc
			#EndRegion Sell Functions
			
			#Region Identification Function			
Func CheckAndIdent($bagIndex) ;Check if the player has an IDKit, if not go buy one, then Identify unID (blue, purple, gold) items in a bag
	If (FindIDKit() == 0) Then
		If (GetGoldCharacter() >= 100) Then 
            BuyIDKit()
        ElseIf (GetGoldStorage() >= 100) Then
            WithdrawGold(100)
            BuyIDKit()
        EndIf
		RndSleep(500)
	Else
		IdentifyBag_Kilroy($bagIndex)
	EndIf
EndFunc   ;==>IDENT 

Func CanIdent($aitem) ;Lists the unauthorized items to be sold and check if the item input can be sold
    Local $lItemID = DllStructGetData($aItem, 'ID')
    Local $iRarity = GetRarity($lItemID)
    
	If ($iRarity == $RARITY_White) Then
		Return False
	ElseIf (($iRarity == $RARITY_Blue) AND (GUICtrlRead($IdentBlue) == $GUI_CHECKED)) Then
		Return True
	ElseIf (($iRarity == $RARITY_Purple) AND (GUICtrlRead($IdentPurple) == $GUI_CHECKED)) Then
		Return True
	ElseIf (($iRarity == $RARITY_Gold) AND (GUICtrlRead($IdentGold) == $GUI_CHECKED)) Then
		Return True
	ElseIf ($iRarity == $RARITY_Green) Then
		Return False
	Else
		Return False
	EndIf
EndFunc   ;==>CanSell

Func IdentifyBag_Kilroy($aBag) ;Identifies all authorized items in a bag.
	Local $aItem
	If Not IsDllStruct($aBag) Then $aBag = GetBag($aBag)
    
	For $i = 1 To DllStructGetData($aBag, 'Slots')
		$aItem = GetItemBySlot($aBag, $i)
		If DllStructGetData($aItem, 'ID') = 0 Then ContinueLoop
		If CanIdent($aItem) Then IdentifyItem($aItem)		
		Sleep(GetPing())
	Next
EndFunc   ;==>IdentifyBag

Func IdentItemToMerchant() ;Ident items in authorized bags	
	If (GUICtrlRead($AuthBag1) == $GUI_CHECKED) Then ;Check if bag1 is authorized to be sold
		CheckAndIdent(1)
	EndIf
	If (GUICtrlRead($AuthBag2) == $GUI_CHECKED) Then ;Check if bag2 is authorized to be sold
		CheckAndIdent(2)
	EndIf
	If (GUICtrlRead($AuthBag3) == $GUI_CHECKED) Then ;Check if bag3 is authorized to be sold
		CheckAndIdent(3)
	EndIf
	If (GUICtrlRead($AuthBag4) == $GUI_CHECKED) Then ;Check if bag4 is authorized to be sold
		CheckAndIdent(4)
	EndIf
EndFunc	
			#EndRegion Identification Function
            
            #Region Environnement Interactions Functions
Func CheckAndPickUp() ;Check number of slots remaining and pickup item  
    If CheckIfInventoryIsFull() Then 
        Return
    Else
        PickUpLoot()
    EndIf
EndFunc

Func PickUpLoot()
	Local $lMe
	Local $lBlockedTimer
	Local $lBlockedCount = 0
	Local $lItemExists = True
    
	For $i = 1 To GetMaxAgents()
		$lAgent = GetAgentByID($i)
		If (CountSlots()=0) Then Return False
		If Not (GetIsMovable($lAgent)) Then ContinueLoop
		If Not (GetCanPickUp($lAgent)) Then ContinueLoop
		$lItem = GetItemByAgentID($i)
		If (CanPickup($lItem)) Then
			Do
				If (GetDistance($lItem) > 150) Then Move(DllStructGetData($lItem, 'X'), DllStructGetData($lItem, 'Y'))
				PickUpItem($lItem)
				Sleep(GetPing())
				Do
					If (GetIsDead(-2)) Then Return False
					Sleep(100)
					$lMe = GetAgentByID(-2)
				Until ((DllStructGetData($lMe, 'MoveX') == 0) AND (DllStructGetData($lMe, 'MoveY') == 0))
				$lBlockedTimer = TimerInit()
				Do
					If (GetIsDead(-2)) Then Return False
					Sleep(3)
					$lItemExists = IsDllStruct(GetAgentByID($i))
				Until Not ($lItemExists) OR (TimerDiff($lBlockedTimer) > Random(5000, 7500, 1))
				If $lItemExists Then $lBlockedCount += 1
			Until Not $lItemExists OR $lBlockedCount > 5
		EndIf
	Next
EndFunc   ;==>PickUpLoot

Func CanPickUp($aitem)
	Local $m = DllStructGetData($aitem, 'ModelID')
	Local $lItemID = DllStructGetData($aItem, 'ID')
    Local $i = DllStructGetData($aitem, 'extraId')
    Local $iRarity = GetRarity($lItemID)
    
    If (($m == 2510) OR ($m == 2511)) Then ;If is Golds coins
        Return True
	ElseIf (($m > 21785) And ($m < 21806)) Then ;Elite/Normal Tomes
		Return True
	ElseIf ($m = 146) Then ;Dyes
		If IsKeepedDye($i) Then ;Black & White
			Return True
		Else
			Return False
		EndIf
	ElseIf ($m = 22751) Then ;Lockpicks
		Return True
	ElseIf (($m = 2991) OR ($m = 2992) OR ($m = 2989) OR ($m = 5899)) Then ;ID/Salvage
		Return True
    ElseIf ($m = 27044) Then 
        Return True
    ElseIf CheckArrayPscon($m)Then ; If is a Pcons or event item
		Return True
	ElseIf (($iRarity == $RARITY_Green) AND (GUICtrlRead($PickGreen) == $GUI_CHECKED)) Then
		Return True
    ElseIf (($iRarity = $RARITY_Gold) AND (GUICtrlRead($PickGold) == $GUI_CHECKED)) Then
		Return True
	ElseIf (($iRarity == $RARITY_Purple) AND (GUICtrlRead($PickPurple) == $GUI_CHECKED)) Then
		Return True
	ElseIf (($iRarity == $RARITY_Blue) AND (GUICtrlRead($PickBlue) == $GUI_CHECKED)) Then
		Return True
	ElseIf (($iRarity == $RARITY_White) AND (GUICtrlRead($PickWhite) == $GUI_CHECKED)) Then
		Return True
    ElseIf (($iRarity == $RARITY_White) AND $m == )
	Else
		Return False
	EndIf
EndFunc   ;==>CanPickUp

Func CheckArrayPscon($lModelID)
	For $p = 0 To (UBound($Array_pscon) -1)
		If ($lModelID == $Array_pscon[$p]) Then Return True
	Next
EndFunc
            #EndRegion Environnement Interactions Functions
        #EndRegion Player's Inventory handeling Functions

    #Region Player & Mobs Interactions Functions
Func GetNearestEttin()
	Local $lNearestAgent = 0, $lNearestDistance = 100000000
	Local $lDistance, $lAgentToCompare
	Local $aAgent = GetAgentByID(-2)

	For $i = 1 To GetMaxAgents()
		$lAgentToCompare = GetAgentByID($i)
		If DllStructGetData($lAgentToCompare, 'HP') < 0.005 Or DllStructGetData($lAgentToCompare, 'Allegiance') <> 0x3 Or DllStructGetData($lAgentToCompare, 'Type') <> 0xDB Or GetAgentName($lAgentToCompare) <> "Enslaved Ettin" Then ContinueLoop

		$lDistance = (DllStructGetData($aAgent, 'X') - DllStructGetData($lAgentToCompare, 'X')) ^ 2 + (DllStructGetData($aAgent, 'Y') - DllStructGetData($lAgentToCompare, 'Y')) ^ 2
		If  $lDistance < $lNearestDistance Then
			$lNearestAgent = $lAgentToCompare
			$lNearestDistance = $lDistance
		EndIf
	Next
	Return $lNearestAgent
EndFunc   ;==>GetNearestEttin

Func GetLowestEnemyToAgent($aAgent)
	Local $lNearestAgent = 0, $lNearestDistance = 100000000
	Local $lDistance, $lAgentToCompare
	Local $lLowestHP = 100,$lHP

	If IsDllStruct($aAgent) = 0 Then $aAgent = GetAgentByID($aAgent)

	For $i = 1 To GetMaxAgents()
		$lAgentToCompare = GetAgentByID($i)
		$lHP = DllStructGetData($lAgentToCompare, 'HP')
		If $lHP < 0.005 Or DllStructGetData($lAgentToCompare, 'Allegiance') <> 0x3 Or DllStructGetData($lAgentToCompare, 'Type') <> 0xDB Then ContinueLoop

		$lDistance = (DllStructGetData($aAgent, 'X') - DllStructGetData($lAgentToCompare, 'X')) ^ 2 + (DllStructGetData($aAgent, 'Y') - DllStructGetData($lAgentToCompare, 'Y')) ^ 2
		If $lHP<$lLowestHP Or ($lHP=$lLowestHP And $lDistance < $lNearestDistance ) Then
			$lNearestAgent = $lAgentToCompare
			$lNearestDistance = $lDistance
			$lLowestHP = $lHP
		EndIf
	Next

	SetExtended(Sqrt($lNearestDistance)) ;this could be used to retrieve the distance also
	Return $lNearestAgent
EndFunc   ;==>GetLowestEnemyToAgent

Func GetLowestEnemyToAgentExcludingMaghma()
	Local $lNearestAgent = 0, $lNearestDistance = 100000000
	Local $lDistance, $lAgentToCompare
	Local $lLowestHP = 100,$lHP
	Local $aAgent = GetAgentByID(-2)

	For $i = 1 To GetMaxAgents()
		$lAgentToCompare = GetAgentByID($i)
		If DllStructGetData($lAgentToCompare, 'HP') < 0.005 Or DllStructGetData($lAgentToCompare, 'Allegiance') <> 0x3 Or DllStructGetData($lAgentToCompare, 'Type') <> 0xDB Or GetAgentName($lAgentToCompare) = "Lieutenant Mahgma" Then ContinueLoop

		$lDistance = (DllStructGetData($aAgent, 'X') - DllStructGetData($lAgentToCompare, 'X')) ^ 2 + (DllStructGetData($aAgent, 'Y') - DllStructGetData($lAgentToCompare, 'Y')) ^ 2
		If $lHP<$lLowestHP Or ($lHP=$lLowestHP And $lDistance < $lNearestDistance ) Then
			$lNearestAgent = $lAgentToCompare
			$lNearestDistance = $lDistance
			$lLowestHP = $lHP
		EndIf
	Next

	SetExtended(Sqrt($lNearestDistance)) ;this could be used to retrieve the distance also
	Return $lNearestAgent
EndFunc   ;==>GetLowestEnemyToAgentExcludingMaghma
    #EndRegion Player & Mobs Interactions Functions
        
        #Region Consumables Functions
Func UseScroll() ;Uses scroll if in inventory based on GUI checkbox
	If (GUICtrlRead($UseScroll) = $GUI_CHECKED) Then
		$item = GetItemByModelID(21233)
		If (DllStructGetData($item, 'Bag') <> 0) Then
			Out("Using Lightbringer Scroll")
			UseItem($item)
			Return
		EndIf
		$item = GetItemByModelID(5595)
		If (DllStructGetData($item, 'Bag') <> 0) Then
			Out("Using Berserkers Insight")
			UseItem($item)
			Return
		EndIf
		$item = GetItemByModelID(5611)
		If (DllStructGetData($item, 'Bag') <> 0) Then
			Out("Using Slayers Insight")
			UseItem($item)
			Return
		EndIf
		$item = GetItemByModelID(5594)
		If (DllStructGetData($item, 'Bag') <> 0) Then
			Out("Using Heros Insight")
			UseItem($item)
			Return
		EndIf
		$item = GetItemByModelID(5975)
		If (DllStructGetData($item, 'Bag') <> 0) Then
			Out("Using Rampagers Insight")
			UseItem($item)
			Return
		EndIf
		$item = GetItemByModelID(5976)
		If (DllStructGetData($item, 'Bag') <> 0) Then
			Out("Using Hunters Insight")
			UseItem($item)
			Return
		EndIf
		$item = GetItemByModelID(5853)
		If (DllStructGetData($item, 'Bag') <> 0) Then
			Out("Using Adventurers Insight")
			UseItem($item)
			Return
		EndIf
		Out("No scrolls found")
	EndIf
EndFunc
        #EndRegion Consumables Functions
    #EndRegion Side Functions
#EndRegion Actions