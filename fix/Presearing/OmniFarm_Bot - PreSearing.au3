#Region About
;~      Autor Rusco95/Koala95
#cs
#################################
#                               #
#     PreSearing_Bot Farm       #
#                               #
#            Updated            #
#         by DeeperBlue         #
#         January 2019          #
#                               #
#################################

Changelog V2.4.0 (August the 04th 2019) by DeeperBlue :
    - GUI Update :
		- Added a custom build tab.
			- Added a custom build template input field.
			- Added a build info group to define each skill's type.
			- Added a save build & a Second overwrite option.
		- Main GUI displays the current item Nicholas Sandford is asking for.
	- Ini files update :
		- Added CustomBuild ini files to save/load custom build parameters.
	- Added an auto-erasing of the Bot_Main/Second.ini file when existing the bot (to prevent the ini files keeping char name, position, etc...)
	- Added functions to detect and load the custom build insteed of the presets.
	- Added a new cast engine to handle custom builds.
	- Added PreSearing items IDs to Global_Items2.au3
	- Added DailyEvents.au3 GW_omniApi.
	- Added functions to be able to know what item Nicholas Sandford is currently asking this day.
	- Go Trade Nicholas Sandford option now only requires to have enough (>25) of the currently asked item insteed of every farmable items.
	- Cleaned the code a bit.
    - In Charrs farms : Pull mob function should be a bit more efficient.

#TODO :
	- Custom builds related function (used by the bot in job/build loading)
			- Custom_CastSkillFromBuild : Will be buggy if necro summoning skills are used (don't know when to use it)
	- Write a read-me for the custom build tab (#Skill types)
	- Add AoE on self skill type

	- Fix the pullmobs function to pull charrs group backward.

	NT- Recognize Nick's day
    - Safe-mod
		- Stop after XX time.
		- Random actions.
		- Portals zoning.
		- Random paths based on polygone in town.
	- Adding a .ini file to log character's pos, checkpoint, to then make it able to communicate with a second bot in the party.

	- Adding KillMobs/GetNumberOfFoesInRangeOfAgent to PickUpLoot function to make it fight back even when picking up loot

	- Charr farm is not efficient enough.
    - Adding GroundLevel
            Local $lAgent = GetAgentPtr(-2)
            Local $lGround = MemoryRead($lAgent + 0x7C, 'long')
            MsgBox(0, "Ground-Level", "Ground-Level = " & $lGround)

    - Pet's life recognition and revive it when dead

    - Pulling charrs backward when picking a group
        - Not based on hard-coded coord --> use charr target array and player's position to decide to make ComputeDistance rise
        - PullMobs() function to add in Killmob/FarmRoute or somthing


    - Machine-learning based Charr farm

	Excluding mob by name -->	For $i = 1 To GetMaxAgents()
		$lAgentToCompare = GetAgentByID($i)
		If DllStructGetData($lAgentToCompare, 'HP') < 0.005 Or DllStructGetData($lAgentToCompare, 'Allegiance') <> 0x3 Or DllStructGetData($lAgentToCompare, 'Type') <> 0xDB Or GetAgentName($lAgentToCompare) = "Lieutenant Mahgma" Then ContinueLoop
	- Detection is working but the KillMob/AutonomousCasting have to know what must be the target
        --> Based on PlayerNumber or smthg
        --> Return the PlayerNumber's from target for killmob to use or ...

	- Recognize active LDoA2 quest
    - LDoA2 for any quests.

    - Only load build at start and level up.


    -- I noticed that when I have the "sweets" checkbox marked that the bot will only use a golden egg
    if it has both cupcakes AND golden eggs in the inven. If it has only golden eggs,
    it won't use a golden egg. I looked into the code briefly,
    but couldn't find what was causing this to happen.
    Edit: There's some sort of glitch with using morale-boosting items.
    After completing several runs, the bot was just sitting in the outpost attempting
    to use a pumpkin cookie repeatedly. --
    -- Some issues for charr farming:
    1) When you kill any charr group bot goes to pick up and sometimes aggroing other 1-2-3 groups. Is it possible to check if enemies in range while going to pick up and to pick up only after killing all enemies in range?
    2) Is it possible to use glyph of lesser energy and fire storm on recharge?
    Sometimes when summon is dead and you fight 2-3 mobs bot is only healing himself and dont attack enemies, firestorm will be very usefull in this situation!
    2) Is it possible to wipe and relog to map from shrine after killing 4 bosses?
    Firstly you will keep 10% morale everytime, and secondly its faster
    3) Is it possible to pick up only blue armors (but no other blues)? --
#ce

#EndRegion About

#Region Include
#include "GW_omniApi.au3"
#EndRegion Include

#Region Declarations
Global $updated = 1
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
Global $BoolNicholas = 0
Global $CharrCheckPoint
#EndRegion Declarations

#Region GUI
Opt("GUIOnEventMode", True)
Opt("GUICloseOnESC", False)

Local $X_GUI, $Y_GUI

; Dull carapace, Baked husk, Charr carving, Enchanted lodestone, Gargoyle Skull, Grawl Necklace
; Icy lodestone, Red Iris flower, Skale fin, Skeletal limb, Spider leg, Unnatural seed, Worn Belt
$JobsList = "LDoA 2-10|LDoA 11-20|Worn belt|Dull carapace|Baked husk|Charr carving|Enchanted lodestone|Gargoyle skull|Grawl necklace|Icy lodestone|Red Iris flower|Skale fin|Skeletal limb|Spider leg|Unnatural seed|All items 26|All items 250|Charrs Boss"
$RunTownList = "Ashford Abbey|Foibles Fair|Fort Ranik|The Barradin Estate|All Outposts"

$SkillTypeList = "Heal|Damage|Heal&Damage|Buff|Pet Heal" ;Need to add self-targeted AoE for monk skill

$Gui = GUICreate("Pre Farmer", 431, 274, -1, -1)


$GUISTATS = GUICtrlCreateTab(0, 0, 431, 274)

    #Region GUI Main
GUICtrlCreateTabItem("Main")

$X_GUI = 10
$Y_GUI = 25

GUICtrlCreateGroup("Select a Character", $X_GUI, $Y_GUI, 170, 43)
    $CharInput = GUICtrlCreateCombo("", $X_GUI+10, $Y_GUI+15, 129, 21, $CBS_DROPDOWNLIST)
        GUICtrlSetData(-1, GetLoggedCharNames())
        GUICtrlSetOnEvent(-1, "GuiStartHandler")
    $iRefresh = GUICtrlCreateButton("", $X_GUI+142, $Y_GUI+14, 22.8, 22.8, $BS_ICON)
        GUICtrlSetImage($iRefresh, "shell32.dll", -239, 0)
        GUICtrlSetOnEvent(-1, "RefreshInterface")

$Y_GUI = 70

GUICtrlCreateGroup("Actions", $X_GUI, $Y_GUI, 170, 68) ; Actions the bot can do selectors
	$RunToDo = GUICtrlCreateCombo("Run to town to do", $X_GUI+10, $Y_GUI+15, 129, 21, $CBS_DROPDOWNLIST)
    GUICtrlSetData(-1, $RunTownList)
	GUICtrlSetOnEvent(-1, "GuiActionsHandler")
    $JobToDo = GUICtrlCreateCombo("Job to do", $X_GUI+10, $Y_GUI+40, 129, 21, $CBS_DROPDOWNLIST)
    GUICtrlSetData(-1, $JobsList)
	GUICtrlSetOnEvent(-1, "GuiActionsHandler")

$X_GUI = 15
$Y_GUI = 142

$StartButton = GUICtrlCreateButton("Start", $X_GUI, $Y_GUI, 157.8, 21)
    GUICtrlSetOnEvent(-1, "GuiButtonHandler")
$RenderingBox = GUICtrlCreateCheckbox("Disable Rendering", $X_GUI+20, $Y_GUI+23, 110, 17)
   GUICtrlSetOnEvent(-1, "ToggleRendering")

$X_GUI = 10
$Y_GUI = 180

GUICtrlCreateGroup("", $X_GUI, $Y_GUI, 170, 60)
	$RunsLabel = GUICtrlCreateLabel("Runs:", $X_GUI+10, $Y_GUI+10, 31, 20)
	$RunsCount = GUICtrlCreateLabel("0", $X_GUI+65, $Y_GUI+10, 50, 20, $SS_RIGHT)
	$FailsLabel = GUICtrlCreateLabel("Fails:", $X_GUI+10, $Y_GUI+25, 31, 20)
	$FailsCount = GUICtrlCreateLabel("0", $X_GUI+65, $Y_GUI+25, 50, 20, $SS_RIGHT)
	$TotTimeLabel = GUICtrlCreateLabel("Total time:", $X_GUI+10, $Y_GUI+40, 49, 20)
	$TotTimeCount = GUICtrlCreateLabel("-", $X_GUI+59, $Y_GUI+40, 54, 20, $SS_RIGHT)

$Y_GUI = 240
	GUICtrlCreateLabel("", $X_GUI, $Y_GUI+3, 170, 19, $SS_CENTER)
		GUICtrlSetBkColor(-1, 12632256)
	GUICtrlCreateLabel("Nick's item: "&CurrentNickPreItem_Name(), $X_GUI, $Y_GUI+5, 170, 19, $SS_CENTER)
		GUICtrlSetColor(-1, 13369344)
		GUICtrlSetFont(-1,8.5,$FW_SEMIBOLD)

$StatusLabel = GUICtrlCreateEdit("", 185, 31, 235, 232, BitOR(0x0040, 0x0080, 0x1000, 0x00200000))
    GUICtrlSetFont($StatusLabel, 9, 400, 0, "Arial")
    GUICtrlSetColor($StatusLabel, 65280)
    GUICtrlSetBkColor($StatusLabel, 0)

    #EndRegion GUI Main

    #Region GUI Options
GUICtrlCreateTabItem("Options")

$Y_GUI = 25

GUICtrlCreateGroup("Settings", $X_GUI, $Y_GUI, 170, 130) ;Option
    $RadioSetting = GUICtrlCreateRadio("",$X_GUI+155, $Y_GUI+7, 10, 17)
        GUICtrlSetOnEvent(-1, "RadiosHandler")
	$Status = GUICtrlCreateCheckbox("Set player status : Offline",$X_GUI+10, $Y_GUI+20, 135, 15)
	$Stone = GUICtrlCreateCheckbox("Use igneous stone",$X_GUI+10, $Y_GUI+37, 150, 15)
    $GoNicholas = GUICtrlCreateCheckbox("Go trade Nicholas Sandford",$X_GUI+10, $Y_GUI+54, 150, 15)
    $DontSellPurple = GUICtrlCreateCheckbox("Don't sell Purple Items",$X_GUI+10, $Y_GUI+71, 150, 15)
    $Lvl19 = GUICtrlCreateCheckbox("LDoA stops level 19",$X_GUI+10, $Y_GUI+88, 150, 15)
        GUICtrlSetOnEvent(-1, "SurvivorHandler")
    $Survivor = GUICtrlCreateCheckbox("Do Survivor Title",$X_GUI+10, $Y_GUI+105, 150, 15)
        GUICtrlSetOnEvent(-1, "SurvivorHandler")

$Y_GUI = 155

GUICtrlCreateGroup("Use Pcons", $X_GUI, $Y_GUI, 170, 62) ;Option
    $RadioPcons = GUICtrlCreateRadio("",$X_GUI+155, $Y_GUI+7, 10, 17)
        GUICtrlSetOnEvent(-1, "RadiosHandler")
    $UsePcons_Sweets = GUICtrlCreateCheckbox("Sweets (cupcake/corn/...)",$X_GUI+10, $Y_GUI+20, 142, 15)
    $UsePcons_Moral = GUICtrlCreateCheckbox("Morale",$X_GUI+10, $Y_GUI+37, 150, 15)

$X_GUI = 185
$Y_GUI = 25

GUICtrlCreateGroup("Pickup dyes", $X_GUI, $Y_GUI, 235, 79)
    $RadioPickupDye = GUICtrlCreateRadio("",$X_GUI+220, $Y_GUI+7, 10, 17)
        GUICtrlSetOnEvent(-1, "RadiosHandler")
    $PickDye_Blue = GUICtrlCreateCheckbox("Blue", $X_GUI+10, $Y_GUI+20, 55, 15)
    $PickDye_Green = GUICtrlCreateCheckbox("Green", $X_GUI+10, $Y_GUI+37, 55, 15)
    $PickDye_Purple = GUICtrlCreateCheckbox("Purple", $X_GUI+10, $Y_GUI+54, 55, 15)
    $PickDye_Red = GUICtrlCreateCheckbox("Red", $X_GUI+87, $Y_GUI+20, 55, 15)
    $PickDye_Yellow = GUICtrlCreateCheckbox("Yellow", $X_GUI+87, $Y_GUI+37, 55, 15)
    $PickDye_Brown = GUICtrlCreateCheckbox("Brown", $X_GUI+87, $Y_GUI+54, 55, 15)
    $PickDye_Orange = GUICtrlCreateCheckbox("Orange", $X_GUI+164, $Y_GUI+20, 55, 15)
    $PickDye_Silver = GUICtrlCreateCheckbox("Silver", $X_GUI+164, $Y_GUI+37, 55, 15)
    $PickDye_Pink = GUICtrlCreateCheckbox("Pink", $X_GUI+164, $Y_GUI+54, 55, 15)

$Y_GUI = 104

GUICtrlCreateGroup("Sell bags", $X_GUI, $Y_GUI, 120, 113) ;Selling bag function (not checked = ignore bag)
	$RadioSellBags = GUICtrlCreateRadio("",$X_GUI+105, $Y_GUI+7, 10, 17)
        GUICtrlSetOnEvent(-1, "RadiosHandler")
    $SellBag1 = GUICtrlCreateCheckbox("Bag 1 (20 slots)", $X_GUI+10, $Y_GUI+20, 90, 15)
	$SellBag2 = GUICtrlCreateCheckbox("Bag 2 (5 slots)", $X_GUI+10, $Y_GUI+42.7, 90, 15)
	$SellBag3 = GUICtrlCreateCheckbox("Bag 3 (10 slots)", $X_GUI+10, $Y_GUI+65.4, 90, 15)
	$SellBag4 = GUICtrlCreateCheckbox("Bag 4 (10 slots)", $X_GUI+10, $Y_GUI+88, 90, 15)

$X_GUI = 310

GUICtrlCreateGroup("Pickup item", $X_GUI, $Y_GUI, 110, 113)
    $RadioPickup = GUICtrlCreateRadio("",$X_GUI+95, $Y_GUI+7, 10, 17)
        GUICtrlSetOnEvent(-1, "RadiosHandler")
    $PickWhite = GUICtrlCreateCheckbox("Rarity : White", $X_GUI+10, $Y_GUI+20, 85, 15)
    $PickBlue = GUICtrlCreateCheckbox("Rarity : Blue", $X_GUI+10, $Y_GUI+37, 90, 15)
    $PickPurple = GUICtrlCreateCheckbox("Rarity : Purple", $X_GUI+10, $Y_GUI+54, 90, 15)
    $PickGold = GUICtrlCreateCheckbox("Rarity : Gold", $X_GUI+10, $Y_GUI+71, 90, 15)
    $PickGreen = GUICtrlCreateCheckbox("Rarity : Green", $X_GUI+10, $Y_GUI+88, 90, 15)

$X_GUI = 10
$Y_GUI = 218

GUICtrlCreateGroup("Save configs", $X_GUI, $Y_GUI, 410, 45)
    $OverwriteSecond_Checkbox = GUICtrlCreateCheckbox("Overwrite Second config", $X_GUI+10, $Y_GUI+20, 145, 15)
    $ConfigSaveMain_Button = GUICtrlCreateButton("Save configs", $X_GUI+185, $Y_GUI+12, 215, 27)
        GUICtrlSetOnEvent(-1, "SaveConfigIni_Main")
    #EndRegion GUI Options

	#Region GUI Custom build
GUICtrlCreateTabItem("Custom build")

	$X_GUI = 10
	$Y_GUI = 25

	GUICtrlCreateGroup("Custom buid's template",$X_GUI, $Y_GUI, 411, 43)
		$CustomBuild_Template = GUICtrlCreateInput("",$X_GUI+10, $Y_GUI+15, 391, 21)

	$Y_GUI = 86.5
	GUICtrlCreateGroup("Build's info", $X_GUI, $Y_GUI, 411, 110)
		GUICtrlCreateGroup("Skill 1", $X_GUI+10, $Y_GUI+15, 90, 43)
			$Custom_Skill_1_Type = GUICtrlCreateCombo("Void", $X_GUI+15, $Y_GUI+30, 80, 15, $CBS_DROPDOWNLIST)
				GUICtrlSetData(-1, $SkillTypeList)
		GUICtrlCreateGroup("Skill 2", $X_GUI+110, $Y_GUI+15, 90, 43)
			$Custom_Skill_2_Type = GUICtrlCreateCombo("Void", $X_GUI+115, $Y_GUI+30, 80, 15, $CBS_DROPDOWNLIST)
				GUICtrlSetData(-1, $SkillTypeList)
		GUICtrlCreateGroup("Skill 3", $X_GUI+210, $Y_GUI+15, 90, 43)
			$Custom_Skill_3_Type = GUICtrlCreateCombo("Void", $X_GUI+215, $Y_GUI+30, 80, 15, $CBS_DROPDOWNLIST)
				GUICtrlSetData(-1, $SkillTypeList)
		GUICtrlCreateGroup("Skill 4", $X_GUI+310, $Y_GUI+15, 90, 43)
			$Custom_Skill_4_Type = GUICtrlCreateCombo("Void", $X_GUI+315, $Y_GUI+30, 80, 15, $CBS_DROPDOWNLIST)
				GUICtrlSetData(-1, $SkillTypeList)
		GUICtrlCreateGroup("Skill 5", $X_GUI+10, $Y_GUI+60, 90, 43)
			$Custom_Skill_5_Type = GUICtrlCreateCombo("Void", $X_GUI+15, $Y_GUI+75, 80, 15, $CBS_DROPDOWNLIST)
				GUICtrlSetData(-1, $SkillTypeList)
		GUICtrlCreateGroup("Skill 6", $X_GUI+110, $Y_GUI+60, 90, 43)
			$Custom_Skill_6_Type = GUICtrlCreateCombo("Void", $X_GUI+115, $Y_GUI+75, 80, 15, $CBS_DROPDOWNLIST)
				GUICtrlSetData(-1, $SkillTypeList)
		GUICtrlCreateGroup("Skill 7", $X_GUI+210, $Y_GUI+60, 90, 43)
			$Custom_Skill_7_Type = GUICtrlCreateCombo("Void", $X_GUI+215, $Y_GUI+75, 80, 15, $CBS_DROPDOWNLIST)
				GUICtrlSetData(-1, $SkillTypeList)
		GUICtrlCreateGroup("Skill 8", $X_GUI+310, $Y_GUI+60, 90, 43)
			$Custom_Skill_8_Type = GUICtrlCreateCombo("Void", $X_GUI+315, $Y_GUI+75, 80, 15, $CBS_DROPDOWNLIST)
				GUICtrlSetData(-1, $SkillTypeList)

	$Y_GUI = 218
	GUICtrlCreateGroup("Save custom build", $X_GUI, $Y_GUI, 410, 45)
		$OverwriteSecond_Build_Checkbox = GUICtrlCreateCheckbox("Overwrite Second build", $X_GUI+10, $Y_GUI+20, 145, 15)
		$BuildSaveMain_Button = GUICtrlCreateButton("Save custom build", $X_GUI+185, $Y_GUI+12, 215, 27)
			GUICtrlSetOnEvent(-1, "SaveBuildIni_Main")
	#EndRegion GUI Custom build

#cs
	#Region GUI Safe mod
GUICtrlCreateTabItem("Safe mod")

	$X_GUI = 10
	$Y_GUI = 25



	$Y_GUI = 218
	GUICtrlCreateGroup("Save Safe mod params", $X_GUI, $Y_GUI, 410, 45)
		$OverwriteSecond_SafeMod_Checkbox = GUICtrlCreateCheckbox("Overwrite Second Safe mod params", $X_GUI+10, $Y_GUI+20, 145, 15)
		$SafeMod_SaveMain_Button = GUICtrlCreateButton("Save Safe mod params", $X_GUI+185, $Y_GUI+12, 215, 27)
			;GUICtrlSetOnEvent(-1, "SaveBuildIni_Main") ;MUST BE CHANGED
	#EndRegion GUI Safe mod
#ce

    #Region GUI Progression
GUICtrlCreateTabItem("Progression")

	$X_GUI = 75.5
	$Y_GUI = 47.34

	;Inventory fullness
	GUICtrlCreateGroup("Inventory fullness", $X_GUI, $Y_GUI, 280, 70, BITOR($GUI_SS_DEFAULT_GROUP, $BS_CENTER))
		GUICtrlSetFont(-1, 11, 700, 0) ;Bold
	GUICtrlCreateLabel("Occupied slots:", $X_GUI+12, $Y_GUI+15, 260, 17, BITOR($SS_CENTER, $SS_CENTERIMAGE))
	$Inventory_Fullness_Bar = GUICtrlCreateProgress($X_GUI+10, $Y_GUI+30, 260, 20) ;Updated Progress Bar
	$Inventory_Fullness = GUICtrlCreateLabel("0", $X_GUI+112, $Y_GUI+50, 60, 18) ;Updated Title Label
		GUICtrlSetFont(-1, 11, 500, 0)
	GUICtrlCreateLabel("/", $X_GUI+136, $Y_GUI+50, 10, 18) ;Updated Const Label
		GUICtrlSetFont(-1, 11, 500, 0)
	$Inventory_Fullness_MaxSlotsCount = GUICtrlCreateLabel("0", $X_GUI+150, $Y_GUI+50, 80, 18)
		GUICtrlSetFont(-1, 11, 500, 0)

	$Y_GUI = 168.66

	;Survivor Rank Progress
	GUICtrlCreateGroup("Survivor Progress", $X_GUI, $Y_GUI, 280, 70, BITOR($GUI_SS_DEFAULT_GROUP, $BS_CENTER))
		GUICtrlSetFont(-1, 11, 700, 0) ;Bold
	$Surv_Progress_Rank = GUICtrlCreateLabel("Rank: " & 0, $X_GUI+12, $Y_GUI+15, 260, 17, BITOR($SS_CENTER, $SS_CENTERIMAGE))
	$Progress_Bar_Survivor = GUICtrlCreateProgress($X_GUI+10, $Y_GUI+30, 260, 20) ;Updated Progress Bar
	$Surv_Progress = GUICtrlCreateLabel("0", $X_GUI+70, $Y_GUI+50, 60, 18) ;Updated Title Label
		GUICtrlSetFont(-1, 11, 500, 0)
	GUICtrlCreateLabel("/", $X_GUI+136, $Y_GUI+50, 10, 18) ;Updated Const Label
		GUICtrlSetFont(-1, 11, 500, 0)
	GUICtrlCreateLabel("1337500", $X_GUI+150, $Y_GUI+50, 80, 18)
		GUICtrlSetFont(-1, 11, 500, 0)
    #EndRegion GUI Progression

    #Region DisableGUI
        GUICtrlSetState($StartButton, $GUI_DISABLE)
        GUICtrlSetState($RenderingBox, $GUI_DISABLE)

        IniFilesPresent()

        DeactivateAllGUI()
    #EndRegion DisableGUI

GUISetOnEvent($GUI_EVENT_CLOSE, "_exit")
GUISetState(@SW_SHOW)
#EndRegion GUI

#Region Loops
logFile("Version 2.4.0 08/19")
logFile("Ready to start.")

While Not $BotRunning
   Sleep(500)
WEnd

AdlibRegister("TimeUpdater", 1000)
While 1
	Local $Error
	Local $OutpostID

	$Error = 0

	If Not $BotRunning Then
		AdlibUnRegister("TimeUpdater")
		logFile("Bot is paused.")
		GUICtrlSetState($StartButton, $GUI_ENABLE)
		GUICtrlSetData($StartButton, "Start")
		GUICtrlSetOnEvent($StartButton, "GuiButtonHandler")

		ActivateAllGUI()
		While Not $BotRunning
			Sleep(500)
		WEnd
		AdlibRegister("TimeUpdater", 1000)
	EndIf

    OfflineMod()

	$Error = DoActions()

	If ($Error == 0) Then ;No error
		If GetIsDead(-2) Then
			$Fails += 1
			logFile("Run failed: Dead.")
			GUICtrlSetData($FailsCount,$Fails)
		Else
			$Runs += 1
			logFile("Run completed in " & GetTime() & ".")
			GUICtrlSetData($RunsCount, $Runs)
		EndIf
		ResignAndReturn()
	;	$OutpostID = GetJobId()
	;	Farm_GoStartingOutpost($OutpostID)
	EndIf

WEnd
#EndRegion Loops

#Region GUI handeling Functions
	#Region GUI base function
Func GuiButtonHandler() ;Handle the bot's start/pause
    If $BotRunning Then
        logFile("Will pause after this run.")
        GUICtrlSetData($StartButton, "Force Pause")
        GUICtrlSetOnEvent($StartButton, "ResignAndReturn")
        $BotRunning = False
    ElseIf $BotInitialized Then
        GUICtrlSetData($StartButton, "Pause")
        $BotRunning = True
    Else
        logFile("Initializing...")
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
        MemoryWrite($mEnsureEnglish, 1) ; EnsureEnglish(True)
        GUICtrlSetState($RenderingBox, $GUI_ENABLE)
        GUICtrlSetState($CharInput, $GUI_DISABLE)
        Local $charname = GetCharname()
        GUICtrlSetData($CharInput, $charname, $charname)
        GUICtrlSetData($StartButton, "Pause")
        WinSetTitle($Gui, "", "Pre Farmer - " & $charname)
        $BotRunning = True
        $BotInitialized = True
        SetMaxMemory()
   EndIf
EndFunc

Func GuiStartHandler() ;Handle Start/Stop toggling based on character selection (preventing user from starting bot befor choosing a character)
    If (GUICtrlRead($CharInput, "") <> "") Then
        GUICtrlSetState($RunToDo, $GUI_ENABLE)
		GUICtrlSetState($JobToDo, $GUI_ENABLE)
        GUICtrlSetState($StartButton, $GUI_ENABLE)
    Else
		GUICtrlSetState($RunToDo, $GUI_DISABLE)
		GUICtrlSetState($JobToDo, $GUI_DISABLE)
        GUICtrlSetState($StartButton, $GUI_DISABLE)
	EndIf
EndFunc

Func GuiActionsHandler() ;Keeps the user from getting both selector with a selected value
	GUICtrlSetState($Survivor, $GUI_DISABLE)
    GUICtrlSetState($Lvl19, $GUI_DISABLE)

    If ((GUICtrlRead($RunToDo, "") <> "Run to town to do") AND (GUICtrlRead($JobToDo, "") == "Job to do"))  Then
		GUICtrlSetState($JobToDo, $GUI_DISABLE)

        GUICtrlSetState($Status, $GUI_UNCHECKED)
        GUICtrlSetState($Status, $GUI_DISABLE)
        GUICtrlSetState($Stone, $GUI_UNCHECKED)
        GUICtrlSetState($Stone, $GUI_DISABLE)
        GUICtrlSetState($GoNicholas, $GUI_UNCHECKED)
        GUICtrlSetState($GoNicholas, $GUI_DISABLE)
        GUICtrlSetState($DontSellPurple, $GUI_UNCHECKED)
        GUICtrlSetState($DontSellPurple, $GUI_DISABLE)
        GUICtrlSetState($Lvl19, $GUI_UNCHECKED)
        GUICtrlSetState($Lvl19, $GUI_DISABLE)
        GUICtrlSetState($Survivor, $GUI_UNCHECKED)
        GUICtrlSetState($Survivor, $GUI_DISABLE)
        GUICtrlSetState($RadioSetting, $GUI_UNCHECKED)
        GUICtrlSetState($RadioSetting, $GUI_DISABLE)

        GUICtrlSetState($UsePcons_Sweets, $GUI_UNCHECKED)
        GUICtrlSetState($UsePcons_Sweets, $GUI_DISABLE)
        GUICtrlSetState($UsePcons_Moral, $GUI_UNCHECKED)
        GUICtrlSetState($UsePcons_Moral, $GUI_DISABLE)
		GUICtrlSetState($RadioPcons, $GUI_UNCHECKED)
		GUICtrlSetState($RadioPcons, $GUI_DISABLE)

        GUICtrlSetState($SellBag1, $GUI_UNCHECKED)
        GUICtrlSetState($SellBag1, $GUI_DISABLE)
        GUICtrlSetState($SellBag2, $GUI_UNCHECKED)
        GUICtrlSetState($SellBag2, $GUI_DISABLE)
        GUICtrlSetState($SellBag3, $GUI_UNCHECKED)
        GUICtrlSetState($SellBag3, $GUI_DISABLE)
        GUICtrlSetState($SellBag4, $GUI_UNCHECKED)
        GUICtrlSetState($SellBag4, $GUI_DISABLE)
        GUICtrlSetState($RadioSellBags, $GUI_UNCHECKED)
        GUICtrlSetState($RadioSellBags, $GUI_DISABLE)

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

        GUICtrlSetState($OverwriteSecond_Checkbox, $GUI_UNCHECKED)
        GUICtrlSetState($OverwriteSecond_Checkbox, $GUI_DISABLE)
        GUICtrlSetState($ConfigSaveMain_Button, $GUI_DISABLE)

		GUICtrlSetData($CustomBuild_Template, "")
		GUICtrlSetState($CustomBuild_Template, $GUI_DISABLE)
		GUICtrlSetData($Custom_Skill_1_Type, "Void")
		GUICtrlSetState($Custom_Skill_1_Type, $GUI_DISABLE)
		GUICtrlSetData($Custom_Skill_2_Type, "Void")
		GUICtrlSetState($Custom_Skill_2_Type, $GUI_DISABLE)
		GUICtrlSetData($Custom_Skill_3_Type, "Void")
		GUICtrlSetState($Custom_Skill_3_Type, $GUI_DISABLE)
		GUICtrlSetData($Custom_Skill_4_Type, "Void")
		GUICtrlSetState($Custom_Skill_4_Type, $GUI_DISABLE)
		GUICtrlSetData($Custom_Skill_5_Type, "Void")
		GUICtrlSetState($Custom_Skill_5_Type, $GUI_DISABLE)
		GUICtrlSetData($Custom_Skill_6_Type, "Void")
		GUICtrlSetState($Custom_Skill_6_Type, $GUI_DISABLE)
		GUICtrlSetData($Custom_Skill_7_Type, "Void")
		GUICtrlSetState($Custom_Skill_7_Type, $GUI_DISABLE)
		GUICtrlSetData($Custom_Skill_8_Type, "Void")
		GUICtrlSetState($Custom_Skill_8_Type, $GUI_DISABLE)

		GUICtrlSetState($OverwriteSecond_Build_Checkbox, $GUI_UNCHECKED)
		GUICtrlSetState($OverwriteSecond_Build_Checkbox, $GUI_DISABLE)
		GUICtrlSetState($BuildSaveMain_Button, $GUI_DISABLE)
	ElseIf ((GUICtrlRead($JobToDo, "") <> "Job to do") AND (GUICtrlRead($RunToDo, "") == "Run to town to do")) Then
		GUICtrlSetState($RunToDo, $GUI_DISABLE)

        GUICtrlSetState($Status, $GUI_ENABLE)
        GUICtrlSetState($Stone, $GUI_ENABLE)
        GUICtrlSetState($GoNicholas, $GUI_ENABLE)
        GUICtrlSetState($DontSellPurple, $GUI_ENABLE)
        SurvivorHandler()
        GUICtrlSetState($RadioSetting, $GUI_ENABLE)

        GUICtrlSetState($UsePcons_Sweets, $GUI_ENABLE)
        GUICtrlSetState($UsePcons_Moral, $GUI_ENABLE)
		GUICtrlSetState($RadioPcons, $GUI_ENABLE)

        GUICtrlSetState($SellBag1, $GUI_ENABLE)
        GUICtrlSetState($SellBag2, $GUI_ENABLE)
        GUICtrlSetState($SellBag3, $GUI_ENABLE)
        GUICtrlSetState($SellBag4, $GUI_ENABLE)
        GUICtrlSetState($RadioSellBags, $GUI_ENABLE)

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

        GUICtrlSetState($PickWhite, $GUI_ENABLE)
        GUICtrlSetState($PickBlue, $GUI_ENABLE)
        GUICtrlSetState($PickPurple, $GUI_ENABLE)
        GUICtrlSetState($PickGold, $GUI_ENABLE)
        GUICtrlSetState($PickGreen, $GUI_ENABLE)
        GUICtrlSetState($RadioPickup, $GUI_ENABLE)

        GUICtrlSetState($OverwriteSecond_Checkbox, $GUI_ENABLE)
        GUICtrlSetState($ConfigSaveMain_Button, $GUI_ENABLE)

		GUICtrlSetState($CustomBuild_Template, $GUI_ENABLE)
		GUICtrlSetState($Custom_Skill_1_Type, $GUI_ENABLE)
		GUICtrlSetState($Custom_Skill_2_Type, $GUI_ENABLE)
		GUICtrlSetState($Custom_Skill_3_Type, $GUI_ENABLE)
		GUICtrlSetState($Custom_Skill_4_Type, $GUI_ENABLE)
		GUICtrlSetState($Custom_Skill_5_Type, $GUI_ENABLE)
		GUICtrlSetState($Custom_Skill_6_Type, $GUI_ENABLE)
		GUICtrlSetState($Custom_Skill_7_Type, $GUI_ENABLE)
		GUICtrlSetState($Custom_Skill_8_Type, $GUI_ENABLE)

		GUICtrlSetState($OverwriteSecond_Build_Checkbox, $GUI_ENABLE)
		GUICtrlSetState($BuildSaveMain_Button, $GUI_ENABLE)

        ConfigIni_Checkbox(1)
		CustomBuildIni(1)
	Else
		GUICtrlSetState($RunToDo, $GUI_ENABLE)
		GUICtrlSetState($JobToDo, $GUI_ENABLE)

        GUICtrlSetState($Status, $GUI_UNCHECKED)
        GUICtrlSetState($Status, $GUI_DISABLE)
        GUICtrlSetState($Stone, $GUI_UNCHECKED)
        GUICtrlSetState($Stone, $GUI_DISABLE)
        GUICtrlSetState($GoNicholas, $GUI_UNCHECKED)
        GUICtrlSetState($GoNicholas, $GUI_DISABLE)
        GUICtrlSetState($DontSellPurple, $GUI_UNCHECKED)
        GUICtrlSetState($DontSellPurple, $GUI_DISABLE)
        GUICtrlSetState($Lvl19, $GUI_UNCHECKED)
        GUICtrlSetState($Lvl19, $GUI_DISABLE)
        GUICtrlSetState($Survivor, $GUI_UNCHECKED)
        GUICtrlSetState($Survivor, $GUI_DISABLE)
        GUICtrlSetState($RadioSetting, $GUI_UNCHECKED)
        GUICtrlSetState($RadioSetting, $GUI_DISABLE)

        GUICtrlSetState($UsePcons_Sweets, $GUI_UNCHECKED)
        GUICtrlSetState($UsePcons_Sweets, $GUI_DISABLE)
        GUICtrlSetState($UsePcons_Moral, $GUI_UNCHECKED)
        GUICtrlSetState($UsePcons_Moral, $GUI_DISABLE)
        GUICtrlSetState($RadioPcons, $GUI_UNCHECKED)
        GUICtrlSetState($RadioPcons, $GUI_DISABLE)

        GUICtrlSetState($SellBag1, $GUI_UNCHECKED)
        GUICtrlSetState($SellBag1, $GUI_DISABLE)
        GUICtrlSetState($SellBag2, $GUI_UNCHECKED)
        GUICtrlSetState($SellBag2, $GUI_DISABLE)
        GUICtrlSetState($SellBag3, $GUI_UNCHECKED)
        GUICtrlSetState($SellBag3, $GUI_DISABLE)
        GUICtrlSetState($SellBag4, $GUI_UNCHECKED)
        GUICtrlSetState($SellBag4, $GUI_DISABLE)
        GUICtrlSetState($RadioSellBags, $GUI_UNCHECKED)
        GUICtrlSetState($RadioSellBags, $GUI_DISABLE)

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

        GUICtrlSetState($OverwriteSecond_Checkbox, $GUI_UNCHECKED)
        GUICtrlSetState($OverwriteSecond_Checkbox, $GUI_DISABLE)
        GUICtrlSetState($ConfigSaveMain_Button, $GUI_UNCHECKED)
        GUICtrlSetState($ConfigSaveMain_Button, $GUI_DISABLE)

		GUICtrlSetData($CustomBuild_Template, "")
		GUICtrlSetState($CustomBuild_Template, $GUI_DISABLE)
		GUICtrlSetData($Custom_Skill_1_Type, "Void")
		GUICtrlSetState($Custom_Skill_1_Type, $GUI_DISABLE)
		GUICtrlSetData($Custom_Skill_2_Type, "Void")
		GUICtrlSetState($Custom_Skill_2_Type, $GUI_DISABLE)
		GUICtrlSetData($Custom_Skill_3_Type, "Void")
		GUICtrlSetState($Custom_Skill_3_Type, $GUI_DISABLE)
		GUICtrlSetData($Custom_Skill_4_Type, "Void")
		GUICtrlSetState($Custom_Skill_4_Type, $GUI_DISABLE)
		GUICtrlSetData($Custom_Skill_5_Type, "Void")
		GUICtrlSetState($Custom_Skill_5_Type, $GUI_DISABLE)
		GUICtrlSetData($Custom_Skill_6_Type, "Void")
		GUICtrlSetState($Custom_Skill_6_Type, $GUI_DISABLE)
		GUICtrlSetData($Custom_Skill_7_Type, "Void")
		GUICtrlSetState($Custom_Skill_7_Type, $GUI_DISABLE)
		GUICtrlSetData($Custom_Skill_8_Type, "Void")
		GUICtrlSetState($Custom_Skill_8_Type, $GUI_DISABLE)

		GUICtrlSetState($OverwriteSecond_Build_Checkbox, $GUI_UNCHECKED)
		GUICtrlSetState($OverwriteSecond_Build_Checkbox, $GUI_DISABLE)
		GUICtrlSetState($BuildSaveMain_Button, $GUI_DISABLE)
	EndIf
EndFunc

Func RadiosHandler() ;Handle radios that check all checkboxes
    If (GUICtrlRead($RadioSetting) == $GUI_CHECKED) Then
		GUICtrlSetState($Status, $GUI_CHECKED)
		GUICtrlSetState($Stone, $GUI_CHECKED)
	;	GUICtrlSetState($Lvl19, $GUI_CHECKED)
		GUICtrlSetState($GoNicholas, $GUI_CHECKED)
		GUICtrlSetState($DontSellPurple, $GUI_CHECKED)
    ;    GUICtrlSetState($Survivor, $GUI_CHECKED)

		GUICtrlSetState($RadioSetting, $GUI_UNCHECKED)
    EndIf
    If (GUICtrlRead($RadioPcons) == $GUI_CHECKED) Then
        GUICtrlSetState($UsePcons_Sweets, $GUI_CHECKED)
        GUICtrlSetState($UsePcons_Moral, $GUI_CHECKED)

        GUICtrlSetState($RadioPcons, $GUI_UNCHECKED)
    EndIf
    If (GUICtrlRead($RadioSellBags) == $GUI_CHECKED) Then
		GUICtrlSetState($SellBag1, $GUI_CHECKED)
		GUICtrlSetState($SellBag2, $GUI_CHECKED)
		GUICtrlSetState($SellBag3, $GUI_CHECKED)
		GUICtrlSetState($SellBag4, $GUI_CHECKED)

		GUICtrlSetState($RadioSellBags, $GUI_UNCHECKED)
    EndIf
	If (GUICtrlRead($RadioPickupDye) == $GUI_CHECKED) Then
		GUICtrlSetState($PickDye_Blue, $GUI_CHECKED)
		GUICtrlSetState($PickDye_Green, $GUI_CHECKED)
		GUICtrlSetState($PickDye_Purple, $GUI_CHECKED)
		GUICtrlSetState($PickDye_Red, $GUI_CHECKED)
		GUICtrlSetState($PickDye_Yellow, $GUI_CHECKED)
		GUICtrlSetState($PickDye_Brown, $GUI_CHECKED)
		GUICtrlSetState($PickDye_Orange, $GUI_CHECKED)
		GUICtrlSetState($PickDye_Silver, $GUI_CHECKED)
		GUICtrlSetState($PickDye_Pink, $GUI_CHECKED)

		GUICtrlSetState($RadioPickupDye, $GUI_UNCHECKED)
	EndIf
    If (GUICtrlRead($RadioPickup) == $GUI_CHECKED) Then
		GUICtrlSetState($PickWhite, $GUI_CHECKED)
		GUICtrlSetState($PickBlue, $GUI_CHECKED)
		GUICtrlSetState($PickPurple, $GUI_CHECKED)
		GUICtrlSetState($PickGold, $GUI_CHECKED)
		GUICtrlSetState($PickGreen, $GUI_CHECKED)

		GUICtrlSetState($RadioPickup, $GUI_UNCHECKED)
    EndIf
EndFunc

Func SurvivorHandler() ;Handle Lvl19/Survivor title checkboxes
    If (GUICtrlRead($JobToDo, "") == "LDoA 2-10") Then
        GUICtrlSetState($Survivor, $GUI_ENABLE)
        GUICtrlSetState($Lvl19, $GUI_UNCHECKED)
        GUICtrlSetState($Lvl19, $GUI_DISABLE)
    ElseIf (GUICtrlRead($JobToDo, "") == "LDoA 11-20") Then
        If ((GUICtrlRead($Lvl19) = $GUI_CHECKED) AND (GUICtrlRead($Survivor) = $GUI_UNCHECKED)) Then
            GUICtrlSetState($Lvl19, $GUI_ENABLE)
            GUICtrlSetState($Survivor, $GUI_UNCHECKED)
            GUICtrlSetState($Survivor, $GUI_DISABLE)
        ElseIf ((GUICtrlRead($Survivor) = $GUI_CHECKED) AND (GUICtrlRead($Lvl19) = $GUI_UNCHECKED)) Then
            GUICtrlSetState($Survivor, $GUI_ENABLE)
            GUICtrlSetState($Lvl19, $GUI_UNCHECKED)
            GUICtrlSetState($Lvl19, $GUI_DISABLE)
        ElseIf ((GUICtrlRead($Survivor) = $GUI_UNCHECKED) AND (GUICtrlRead($Lvl19) = $GUI_UNCHECKED)) Then
            GUICtrlSetState($Survivor, $GUI_ENABLE)
            GUICtrlSetState($Lvl19, $GUI_ENABLE)
        EndIf
    Else
        GUICtrlSetState($Lvl19, $GUI_UNCHECKED)
        GUICtrlSetState($Lvl19, $GUI_DISABLE)
        GUICtrlSetState($Survivor, $GUI_UNCHECKED)
        GUICtrlSetState($Survivor, $GUI_DISABLE)
    EndIf
EndFunc

Func _exit() ;Enables Rendering and close the bot
   If GUICtrlRead($RenderingBox) == $GUI_CHECKED Then
	  EnableRendering()
	  WinSetState($HWND, "", @SW_SHOW)
	  Sleep(500)
   EndIf
   ClearIni(1)
   Exit
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
	GUICtrlSetState($RunToDo, $GUI_ENABLE)
	GUICtrlSetState($JobToDo, $GUI_ENABLE)
	;Checkboxes
    GUICtrlSetState($RadioSetting, $GUI_ENABLE)
	GUICtrlSetState($Status, $GUI_ENABLE)
	GUICtrlSetState($Stone, $GUI_ENABLE)
    GUICtrlSetState($GoNicholas, $GUI_ENABLE)
    GUICtrlSetState($DontSellPurple, $GUI_ENABLE)
    GUICtrlSetState($Lvl19, $GUI_ENABLE)
    GUICtrlSetState($Survivor, $GUI_ENABLE)

    GUICtrlSetState($UsePcons_Sweets, $GUI_ENABLE)
    GUICtrlSetState($UsePcons_Moral, $GUI_ENABLE)
	GUICtrlSetState($RadioPcons, $GUI_ENABLE)

    GUICtrlSetState($RadioSellBags, $GUI_ENABLE)
	GUICtrlSetState($SellBag1, $GUI_ENABLE)
	GUICtrlSetState($SellBag2, $GUI_ENABLE)
	GUICtrlSetState($SellBag3, $GUI_ENABLE)
	GUICtrlSetState($SellBag4, $GUI_ENABLE)

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

    GUICtrlSetState($RadioPickup, $GUI_ENABLE)
    GUICtrlSetState($PickWhite, $GUI_ENABLE)
    GUICtrlSetState($PickBlue, $GUI_ENABLE)
    GUICtrlSetState($PickPurple, $GUI_ENABLE)
    GUICtrlSetState($PickGold, $GUI_ENABLE)
    GUICtrlSetState($PickGreen, $GUI_ENABLE)

    GUICtrlSetState($OverwriteSecond_Checkbox, $GUI_ENABLE)
    GUICtrlSetState($ConfigSaveMain_Button, $GUI_ENABLE)

	GUICtrlSetState($CustomBuild_Template, $GUI_ENABLE)
	GUICtrlSetState($Custom_Skill_1_Type, $GUI_ENABLE)
	GUICtrlSetState($Custom_Skill_2_Type, $GUI_ENABLE)
	GUICtrlSetState($Custom_Skill_3_Type, $GUI_ENABLE)
	GUICtrlSetState($Custom_Skill_4_Type, $GUI_ENABLE)
	GUICtrlSetState($Custom_Skill_5_Type, $GUI_ENABLE)
	GUICtrlSetState($Custom_Skill_6_Type, $GUI_ENABLE)
	GUICtrlSetState($Custom_Skill_7_Type, $GUI_ENABLE)
	GUICtrlSetState($Custom_Skill_8_Type, $GUI_ENABLE)

	GUICtrlSetState($OverwriteSecond_Build_Checkbox, $GUI_ENABLE)
	GUICtrlSetState($BuildSaveMain_Button, $GUI_ENABLE)
EndFunc

Func DeactivateAllGUI() ;Deactivate selectors and checkboxes (except Start/Pause button and Rendering checkbox)
	;Selectors
	GUICtrlSetState($RunToDo, $GUI_DISABLE)
	GUICtrlSetState($JobToDo, $GUI_DISABLE)
	;Checkboxes
    GUICtrlSetState($RadioSetting, $GUI_DISABLE)
	GUICtrlSetState($Status, $GUI_DISABLE)
	GUICtrlSetState($Stone, $GUI_DISABLE)
    GUICtrlSetState($GoNicholas, $GUI_DISABLE)
    GUICtrlSetState($DontSellPurple, $GUI_DISABLE)
    GUICtrlSetState($Lvl19, $GUI_DISABLE)
    GUICtrlSetState($Survivor, $GUI_DISABLE)

    GUICtrlSetState($UsePcons_Sweets, $GUI_DISABLE)
    GUICtrlSetState($UsePcons_Moral, $GUI_DISABLE)
	GUICtrlSetState($RadioPcons, $GUI_DISABLE)

    GUICtrlSetState($RadioSellBags, $GUI_DISABLE)
	GUICtrlSetState($SellBag1, $GUI_DISABLE)
	GUICtrlSetState($SellBag2, $GUI_DISABLE)
	GUICtrlSetState($SellBag3, $GUI_DISABLE)
	GUICtrlSetState($SellBag4, $GUI_DISABLE)

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

    GUICtrlSetState($RadioPickup, $GUI_DISABLE)
    GUICtrlSetState($PickWhite, $GUI_DISABLE)
    GUICtrlSetState($PickBlue, $GUI_DISABLE)
    GUICtrlSetState($PickPurple, $GUI_DISABLE)
    GUICtrlSetState($PickGold, $GUI_DISABLE)
    GUICtrlSetState($PickGreen, $GUI_DISABLE)

    GUICtrlSetState($OverwriteSecond_Checkbox, $GUI_DISABLE)
    GUICtrlSetState($ConfigSaveMain_Button, $GUI_DISABLE)

	GUICtrlSetState($CustomBuild_Template, $GUI_DISABLE)
	GUICtrlSetState($Custom_Skill_1_Type, $GUI_DISABLE)
	GUICtrlSetState($Custom_Skill_2_Type, $GUI_DISABLE)
	GUICtrlSetState($Custom_Skill_3_Type, $GUI_DISABLE)
	GUICtrlSetState($Custom_Skill_4_Type, $GUI_DISABLE)
	GUICtrlSetState($Custom_Skill_5_Type, $GUI_DISABLE)
	GUICtrlSetState($Custom_Skill_6_Type, $GUI_DISABLE)
	GUICtrlSetState($Custom_Skill_7_Type, $GUI_DISABLE)
	GUICtrlSetState($Custom_Skill_8_Type, $GUI_DISABLE)

	GUICtrlSetState($OverwriteSecond_Build_Checkbox, $GUI_DISABLE)
	GUICtrlSetState($BuildSaveMain_Button, $GUI_DISABLE)
EndFunc

Func logFile($msg) ;Prints message in the Status console
    GUICtrlSetData($StatusLabel, GUICtrlRead($StatusLabel) & "[" & @HOUR & ":" & @MIN & "]" & " " & $msg & @CRLF)
   _GUICtrlEdit_Scroll($StatusLabel, $SB_SCROLLCARET)
   _GUICtrlEdit_Scroll($StatusLabel, $SB_LINEUP)
EndFunc
	#EndRegion GUI base function

	#Region GUI Enhancement
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
	#EndRegion GUI Enhancement

	#Region Progress
		#Region Inventory fullness
Func InventoryFullness_Display() ;Updates the inventory fullness progression bar in GUI
	Local $UsedSlots = 0
	Local $MaxSlots = 0
	Local $Inventory_Bar_X = 0
	Local $bag

	If (GUICtrlRead($SellBag1) == $GUI_CHECKED) Then
		$bag = GetBag(1)
		$MaxSlots += DllStructGetData($bag, 'slots')
	EndIf
	If (GUICtrlRead($SellBag2) == $GUI_CHECKED) Then
		$bag = GetBag(2)
		$MaxSlots += DllStructGetData($bag, 'slots')
	EndIf
	If (GUICtrlRead($SellBag3) == $GUI_CHECKED) Then
		$bag = GetBag(3)
		$MaxSlots += DllStructGetData($bag, 'slots')
	EndIf
	If (GUICtrlRead($SellBag4) == $GUI_CHECKED) Then
		$bag = GetBag(4)
		$MaxSlots += DllStructGetData($bag, 'slots')
	EndIf

	If ($MaxSlots <> 0) Then
		$UsedSlots = $MaxSlots - CountSlots()
		$Inventory_Bar_X = ($UsedSlots / $MaxSlots) * 100
	Else
		$Inventory_Bar_X = 1
	EndIf

	GuiCtrlSetData($Inventory_Fullness_Bar, $Inventory_Bar_X)
	GuiCtrlSetData($Inventory_Fullness, $UsedSlots)
	GuiCtrlSetData($Inventory_Fullness_MaxSlotsCount, $MaxSlots)
EndFunc
		#EndRegion Inventory fullness

		#Region Survivor
Func Get_Survivor_Rank() ;Returns the title's rank or -1 as error
    Local $XpToMaxTitle = 1337500
    Local $SurvivorTitleRank = 0

    ;If (LDoASurvivor_Status()) Then
        $XpToMaxTitle -= GetSurvivorTitle()
        ;logFile("Xp pts remaining to max title: " & $XpToMaxTitle)
        If ((GetSurvivorTitle() >= 0) AND (GetSurvivorTitle() < 140600)) Then
			;logFile("Survivor title rank 0.")
			$SurvivorTitleRank = 0
        ElseIf ((GetSurvivorTitle() >= 140600) AND (GetSurvivorTitle() < 587500)) Then
			;logFile("Survivor title rank 1.")
			$SurvivorTitleRank = 1
        ElseIf ((GetSurvivorTitle() >= 587500) AND (GetSurvivorTitle() < 1337500 )) Then
			;logFile("Survivor title rank 2.")
			$SurvivorTitleRank = 2
        ElseIf (GetSurvivorTitle() >= 1337500 ) Then
			;logFile("Survivor title rank 3.")
			$SurvivorTitleRank = 3
        Else
            logFile("ERROR : Unable to get player's Survivor title.")
			Return -1
		EndIf
	;EndIf

    Return $SurvivorTitleRank
EndFunc

Func LDoASurvivor_Display() ;Updates the survivor progression bar in GUI
    Local $SurvivorProgress = GetSurvivorTitle()
	Local $SurvivorRank = Get_Survivor_Rank()
	Local $Progress_Bar_Survivor_X = (GetSurvivorTitle() / 1337500) * 100

	GuiCtrlSetData($Surv_Progress, $SurvivorProgress)
	GuiCtrlSetData($Progress_Bar_Survivor, $Progress_Bar_Survivor_X)
	GuiCtrlSetData($Surv_Progress_Rank, "Rank: " & $SurvivorRank)
EndFunc
		#EndRegion Survivor
	#EndRegion Progress
#EndRegion GUI handeling Functions

#Region Bot init Functions
Func OfflineMod() ;Put the player offline (Not working at the moment : it's put you as disconnected for the server which ask you to reconnect)
    If (GUICtrlRead($Status) = $GUI_CHECKED) Then
        logFile("Playing offline.")
        SetPlayerStatus(0)
    Else
        logFile("Playing online.")
    EndIf
EndFunc

	#Region IDs Functions
Func GetRunTownID() ;Return the $RunID based on what the user has selected
	Local $RunID = 0

	If GUICtrlRead($RunToDo, "") == "Ashford Abbey" Then
		$RunID = 1
    ElseIf GUICtrlRead($RunToDo, "") == "Foibles Fair" Then ;Run to Ashford then to Foible's Fair
		$RunID = 2
	ElseIf GUICtrlRead($RunToDo, "") == "Fort Ranik" Then
		$RunID = 3
	ElseIf GUICtrlRead($RunToDo, "") == "The Barradin Estate" Then
		$RunID = 4
	ElseIf GUICtrlRead($RunToDo, "") == "All Outposts" Then
		$RunID = 5
	EndIf

	Return $RunID
EndFunc

Func GetJobId() ;Return the $JobID based on what the user has selected
    Local $JobID = 0

    If GUICtrlRead($JobToDo, "") == "LDoA 2-10" Then
		$JobID = 1
    ElseIf GUICtrlRead($JobToDo, "") == "LDoA 11-20" Then
		$JobID = 2
    ElseIf GUICtrlRead($JobToDo, "") == "Worn belt" Then
		$JobID = 3
    ElseIf GUICtrlRead($JobToDo, "") == "Dull carapace" Then
		$JobID = 4
    ElseIf GUICtrlRead($JobToDo, "") == "Baked husk" Then
		$JobID = 5
    ElseIf GUICtrlRead($JobToDo, "") == "Charr carving" Then
		$JobID = 6
    ElseIf GUICtrlRead($JobToDo, "") == "Enchanted lodestone" Then
		$JobID = 7
    ElseIf GUICtrlRead($JobToDo, "") == "Gargoyle skull" Then
		$JobID = 8
    ElseIf GUICtrlRead($JobToDo, "") == "Grawl necklace" Then
		$JobID = 9
    ElseIf GUICtrlRead($JobToDo, "") == "Icy lodestone" Then
		$JobID = 10
    ElseIf GUICtrlRead($JobToDo, "") == "Red Iris flower" Then
		$JobID = 11
    ElseIf GUICtrlRead($JobToDo, "") == "Skale fin" Then
		$JobID = 12
    ElseIf GUICtrlRead($JobToDo, "") == "Skeletal limb" Then
		$JobID = 13
    ElseIf GUICtrlRead($JobToDo, "") == "Spider leg" Then
		$JobID = 14
    ElseIf GUICtrlRead($JobToDo, "") == "Unnatural seed" Then
		$JobID = 15
	ElseIf GUICtrlRead($JobToDo, "") == "All items 26" Then
		$JobID = 16
	ElseIf GUICtrlRead($JobToDo, "") == "All items 250" Then
		$JobID = 17
	ElseIf GUICtrlRead($JobToDo, "") == "Charrs Boss" Then
		$JobID = 18
	EndIf

    Return $JobID
EndFunc

Func GetStartMapByJobID($JobType,$JobID) ;Return the $MapID of the starting outpost based on $RunID ($JobType = 0) or $JobID ($JobType = 1)
    If ($JobType == 0) Then ;Is a run
        Switch $JobID
			Case 1,3,4 ;To Ashford Abbey, Fort Ranik, The Barradin Estate
				Return 148 ;Ascalon City
			Case 2 ;To Foible's Fair
				Return 164 ;Ashford Abbey
			Case Else
				Return 0
		EndSwitch
    ElseIf ($JobType == 1) Then ;Is a farm
        Switch $JobID
            Case 3,5,11,13 ;Worn Belt, Baked Husk, Red Iris Flowers, Skeletal Limb
                Return 164 ;Ashford Abbey
            Case 1,4,6,18 ;LDoA(2-10), Dull Carapace, Charr carvings, Charrs boss
                Return 148 ;Ascalon City
            Case 9,12,14,15 ;Grawl Necklace, Skale Fin, Spider Leg, Unnatural Seed
                Return 166 ;Fort Ranik
            Case 2,10 ;LDoA(11-20), Ice Lodestone
                Return 165 ;Foible's Fair
            Case 7,8 ;Enchanted Lodestone, Gargoyle Skull
                Return 163 ;The Barradin Estate
            Case Else
                Return 0
        EndSwitch
    Else
        Return 0
    EndIf
EndFunc
	#EndRegion

	#Region ActionToDo Functions
Func DoActions() ;Used just after starting - Check what the player selected, de-activate selectors and checkboxes
	Local $Error

	$Error = 0

	If ((GUICtrlRead($RunToDo, "") <> "Run to town to do") AND (GUICtrlRead($JobToDo, "") == "Job to do")) Then
		DeactivateAllGUI()
        DoRunTown()
	ElseIf ((GUICtrlRead($JobToDo, "") <> "Job to do") AND (GUICtrlRead($RunToDo, "") == "Run to town to do")) Then
        DeactivateAllGUI()
        DoNicholas()
		DoJob()
        Farm_GoStartingOutpost(GetJobId())
	ElseIf ((GUICtrlRead($JobToDo, "") == "Job to do") AND (GUICtrlRead($RunToDo, "") == "Run to town to do")) Then
		logFile("ERROR : You must choose an action to do befor starting.")
		$BotRunning = False
		Return 1
	ElseIf ((GUICtrlRead($JobToDo, "") <> "Job to do") AND (GUICtrlRead($RunToDo, "") <> "Run to town to do")) Then
		logFile("ERROR : You must choose only one action.")
		$BotRunning = False
		Return 2
	Else
		MsgBox(16, "PreFarmer_Bot", "Unknown error occured at Starting.")
		_exit()
	EndIf
EndFunc

Func DoRunTown() ;Call Run init functions based on $RunID
	Local $RunID = 0
    $RunID = GetRunTownID()

	If (($RunID == 1) OR ($RunID == 3) OR ($RunID == 4)) Then
		InitializeRun($RunID)
    ElseIf ($RunID == 2) Then ;Run to Ashford then to Foible's Fair from Ashford
        InitializeRun(1)
        InitializeRun(2)
	ElseIf ($RunID == 5) Then ;Run all
        InitializeRun(1)
		InitializeRun(2)
		InitializeRun(3)
		InitializeRun(4)
	Else
		MsgBox(16, "PreFarmer_Bot", "Unable to get the RunID.")
        _exit()
	EndIf
    $BotRunning = False
EndFunc

Func DoJob() ;Call LDoA/Farm init functions based on $JobID
    Local $JobID = 0
	Local $TempID = 3
    Local $Error = 0

    $JobID = GetJobId()
    InventoryFullness_Display()

    If ($JobID == 1) Then ;LDoA 2-10
        LDoA1()
        Return
	ElseIf ($JobID == 2) Then ;LDoA 11-20
        $Error = BuildForProfession()

        If ($Error <> 0) Then Return $Error
        LvlCount()
		If Not LvlStop() Then LDoA2()
	    Return
	ElseIf ((($JobID >= 3) AND ($JobID <=15)) OR ($JobID == 18)) Then ;Farms
        $Error = BuildForProfession()
        If ($Error <> 0) Then Return $Error
		Count($JobID)
		InitializeFarm($JobID)
        If (($JobID == 6) OR ($JobID == 8)) Then
            While (Not CheckIfInventoryIsFull()) AND $BotRunning
				If ($JobID == 6) Then CharrsCarvingFarm()
                If ($JobID == 8) Then MergoylsFarm()
            WEnd
        EndIf
	    Return
	ElseIf ($JobID == 16) Then ;All items 26
		While ($TempID <= 15)
			Do
                $Error = BuildForProfession()
                If ($Error <> 0) Then Return $Error
				Count($TempID)
				InitializeFarm($TempID)
                If (($TempID == 6) OR ($TempID == 8)) Then
                    While (Not CheckIfInventoryIsFull()) AND $BotRunning
                        If ($TempID == 6) Then CharrsCarvingFarm()
						If ($TempID == 8) Then MergoylsFarm()
                    WEnd
                EndIf
                ResignAndReturn()
                If Not $BotRunning Then Return
			Until (GetFarmItemCount(GetItemModelByFarm($TempID)) >= 26)
			$TempID += 1
		WEnd
		Return
	ElseIf ($JobID == 17) Then ;All items 250
		While ($TempID <= 15)
			Do
                $Error = BuildForProfession()
                If ($Error <> 0) Then Return $Error
				Count($TempID)
				InitializeFarm($TempID)
                If (($TempID == 6) OR ($TempID == 8)) Then
                    While (Not CheckIfInventoryIsFull()) AND $BotRunning
                        If ($TempID == 6) Then CharrsCarvingFarm()
						If ($TempID == 8) Then MergoylsFarm()
                    WEnd
                EndIf
                ResignAndReturn()
                If Not $BotRunning Then Return
			Until (GetFarmItemCount(GetItemModelByFarm($TempID)) >= 250)
			$TempID += 1
		WEnd
		Return
    Else
        MsgBox(16, "PreFarmer_Bot", "Unable to get the JobID.")
        _exit()
    EndIf

EndFunc   ;==>DoJob
	#EndRegion

	#Region Actions Init Functions
Func InitializeFarm($FarmID)
	Farm_GoStartingOutpost($FarmID)
    Farm_GoOutpostPortal($FarmID)
	If Not ($FarmID == 11) Then
		FarmingRouteAndKill($FarmID)
	Else
		FlowerRun()
	EndIf
EndFunc

Func InitializeRun($RunID)
	Run_GoStartingOutpost($RunID)
	Run_GoOutpostPortal($RunID)
	RunningRoute($RunID)
EndFunc
	#EndRegion
#EndRegion

#Region Actions
	#Region Runs
Func Run_GoStartingOutpost($RunID)
    Local $MapID

    If $RunID == 0 Then
		logFile("Error")
    ElseIf (($RunID == 1) OR ($RunID == 3) OR ($RunID == 4)) Then ;AscalonC --> Ashford & AscalonC --> FortRanik & AscalonC --> BarradinEstate
        $MapID = GetStartMapByJobID(0,$RunID)
        If GetMapID() <> $MapID Then ;Ascalon City
			logFile("Moving to Ascalon City.")
			Do
				RndTravel($MapID)
				rndslp(500)
			Until GetMapID() = $MapID
		EndIf
    ElseIf ($RunID == 2) Then ;Ashford --> FoiblesFair
        $MapID = GetStartMapByJobID(0,$RunID)
        If GetMapID() <> $MapID Then ;Ashford Abbey
			logFile("Moving to Ashford Abbey.")
			Do
				RndTravel($MapID)
				rndslp(500)
			Until GetMapID() = $MapID
		EndIf
    EndIf
EndFunc

Func Run_GoOutpostPortal($RunID)
    Local $lAgent = GetAgentByID(-2)
	Local $MyPosX = DllStructGetData($lAgent, 'X')
	Local $MyPosY = DllStructGetData($lAgent, 'Y')

	If ($RunID == 0) Then
		logFile("Error")
    ElseIf (($RunID == 1) OR ($RunID == 3) OR ($RunID == 4)) Then ;Ascalon City to portal
		RndSleep(250)
		logFile("Going out")
		If (($MyPosX < 9800) AND ($MyPosX > 9300) AND ($MyPosY < 5000) AND ($MyPosY > 4500)) Then
		;Pos A : Main Road
			MoveTo(8192, 5997)
			Move(6602, 4485)
		ElseIf (($MyPosX < 10000) AND ($MyPosX > 9400) AND ($MyPosY < 8200) AND ($MyPosY > 7700)) Then
		;Pos B : Upstairs
			MoveTo(8460, 6380)
			Move(6602, 4485)
		ElseIf (($MyPosX < 7900) AND ($MyPosX > 7600) AND ($MyPosy < 6000) AND ($MyPosY > 5600)) Then
		;Pos C : When re-entering from portal
			Move(7321, 5248)
		Else
			MoveTo(8046,6047)
			Move(6602, 4485)
		EndIf
		WaitForLoad()
    ElseIf ($RunID == 2) Then ;Ashford Abbey to fields and village
        RndSleep(250)
        logFile("Going out")
        If (($MyPosX < -12000) AND ($MyPosX > -13000) AND ($MyPosY < -7500) AND ($MyPosY > -8700)) Then
        ;Pos A : Near Mhenlo
            MoveTo(-11628, -7178)
            MoveTo(-11560, -6273)
            Move(-11001, -6233)
        ElseIf (($MyPosX < -11500) AND ($MyPosX > -12500) AND ($MyPosY < -5300) AND ($MyPosY > -5900)) Then
        ;Pos B : Near Portal
            MoveTo(-11626, -6231)
            Move(-11001, -6233)
        ElseIf (($MyPosX < -12500) AND ($MyPosX > -13200) AND ($MyPosY < -7500) AND ($MyPosY > -8000)) Then
        ;Pos C : Near Catacombs portal
            MoveTo(-12588, -6290)
            Move(-11001, -6233)
        ElseIf (($MyPosX < -11500) AND ($MyPosX > -11600) AND ($MyPosY < -6100) AND ($MyPosY > -6300)) Then
        ;Pos D : When re-entering portal
            Move(-11001, -6233)
        Else
            MoveTo(-12243, -6161)
            MoveTo(-11889, -6248)
            MoveTo(-11447, -6229)
            Move(-11005, -6210)
        EndIf
        WaitForLoad()
    EndIf
EndFunc

Func RunningRoute($RunID)
    Local $MapID

    $MapID = 0

	If ($RunID == 0) Then
		logFile("ERROR : Can not find $RunID.")
        $BotRunning = False
	ElseIf ($RunID == 1) Then ;Run to Ashford Abbey from Ascalon City
		logFile("Running to Ashford Abbey.")
		MoveTo(6000,3172)
        MoveTo(4345,413)
        MoveTo(1665,-3587)
        MoveTo(0,-5360)
        MoveTo(-2500,-6337)
        MoveTo(-3908,-6971)
        MoveTo(-5919,-6860)
        MoveTo(-8193,-6325)
        MoveTo(-10800,-6213)
		If GetIsDead(-2) Then Return
        Move(-11250,-6200)
        WaitMapLoading(164)
        $MapID = GetMapID()
        If ($MapID == 164) Then
            logFile("Arrived at Ashford Abbey.")
        EndIf
	ElseIf ($RunID == 2) Then ;Run to Foible's Fair from Ashford Abbey
        logFile("Running to Wizard's Folly.")
		MoveTo(-11081,-7924)
        MoveTo(-11429,-9657)
        MoveTo(-11708,-11038)
        MoveTo(-12085,-12690)
        MoveTo(-12521,-14480)
        MoveTo(-12944,-15820)
        MoveTo(-12250,-17199)
        MoveTo(-11552,-18787)
        MoveTo(-10713,-19145)
        MoveTo(-12617,-20123)
		If GetIsDead(-2) Then Return
        Move(-14000,-20200)
        WaitMapLoading(161)
        $MapID = GetMapID()
        If ($MapID == 161) Then
            logFile("Arrived at Wizard's Folly.")
        EndIf
        logFile("Running to Foible's Fair.")
        MoveTo(8468,17712)
        MoveTo(8270,16493)
        MoveTo(7072,15513)
        MoveTo(6032,15367)
        MoveTo(5011,13406)
        MoveTo(3456,11111)
        MoveTo(2522,9896)
        MoveTo(1748,7755)
        MoveTo(1109,6779)
        MoveTo(620,7311)
		If GetIsDead(-2) Then Return
        Move(300,7700)
        WaitMapLoading(165)
        $MapID = GetMapID()
        If ($MapID == 165) Then
            logFile("Arrived at Foible's Fair.")
        EndIf
    ElseIf ($RunID == 3) Then ;Run to Fort Ranik from Ascalon City
        logFile("Running to Regent Valley.")
		MoveTo(6002,2568)
        MoveTo(5479,655)
        MoveTo(5435,-1486)
        MoveTo(5900,-3333)
        MoveTo(7062,-5208)
        MoveTo(8249,-7551)
        MoveTo(9327,-8769)
        MoveTo(9527,-9839)
        MoveTo(9627,-11272)
        MoveTo(9181,-12522)
        MoveTo(9336,-13162)
        MoveTo(7586,-14406)
        MoveTo(6261,-15311)
        MoveTo(5408,-16356)
        MoveTo(4219,-17012)
        MoveTo(4009,-19226)
        MoveTo(4157,-19693)
		If GetIsDead(-2) Then Return
        Move(4300,-19900)
        WaitMapLoading(162)
        $MapID = GetMapID()
        If ($MapID == 162) Then
            logFile("Arrived at Regent Valley.")
        EndIf
        logFile("Running to Fort Ranik.")
        MoveTo(-14552,15990)
        MoveTo(-13824,14783)
        MoveTo(-12054,14465)
        MoveTo(-10826,13151)
        MoveTo(-9043,11752)
        MoveTo(-6701,10264)
        MoveTo(-3927,8904)
        MoveTo(-2099,7864)
        MoveTo(91,6563)
        MoveTo(899,6259)
        MoveTo(3066,6269)
        MoveTo(4548,5354)
        MoveTo(5943,5528)
        MoveTo(6868,5023)
        MoveTo(7717,3908)
        MoveTo(8760,2667)
        MoveTo(10875,2703)
        MoveTo(12456,2593)
        MoveTo(14964,1196)
        MoveTo(18830,1523)
        MoveTo(19224,2164)
        MoveTo(22044,3655)
        MoveTo(22535,4732)
        MoveTo(22610,6887)
		If GetIsDead(-2) Then Return
        Move(22600,7250)
        WaitMapLoading(166)
        $MapID = GetMapID()
        If ($MapID == 166) Then
            logFile("Arrived at Fort Ranik.")
        EndIf
    ElseIf ($RunID == 4) Then ;Run to The Barradin Estate from Ascalon City
        logFile("Running to Green Hills County.")
		MoveTo(4343,5631)
        MoveTo(2300,6670)
        MoveTo(-337,7103)
        MoveTo(-3468,9849)
        MoveTo(-4531,11453)
        MoveTo(-7478,11814)
        MoveTo(-8767,10876)
        MoveTo(-9144,8252)
        MoveTo(-11047,7611)
        MoveTo(-12431,8422)
        MoveTo(-13356,10012)
		If GetIsDead(-2) Then Return
        Move(-14650,10030)
        WaitMapLoading(160)
        $MapID = GetMapID()
        If ($MapID == 160) Then
            logFile("Arrived at Green Hills County.")
        EndIf
        logFile("Running to the Barradin Estate.")
        MoveTo(21175,13361)
        MoveTo(20466,13785)
        MoveTo(19368,13238)
        MoveTo(18748,12590)
        MoveTo(17284,11856)
        MoveTo(15319,8789)
        MoveTo(14090,6254)
        MoveTo(12757,4515)
        MoveTo(12281,3138)
        MoveTo(11284,3041)
        MoveTo(10567,3221)
        MoveTo(10046,1045)
        MoveTo(11911,-683)
        MoveTo(11343,-2455)
        MoveTo(7948,-3225)
        MoveTo(6000,-4012)
        MoveTo(3000,-3143)
        MoveTo(661,-3136)
        MoveTo(-168,-3384)
        MoveTo(-731,-2105)
        MoveTo(-2003,-2064)
        MoveTo(-3390,-392)
        MoveTo(-6184,-206)
        MoveTo(-7780,-178)
        MoveTo(-7890,879)
        MoveTo(-7910,1415)
        MoveTo(-7531,1424)
		If GetIsDead(-2) Then Return
        Move(-7200,1427)
        WaitMapLoading(163)
        $MapID = GetMapID()
        If ($MapID == 163) Then
            logFile("Arrived at the Barradin Estate.")
        EndIf
    EndIf
EndFunc
	#EndRegion

	#Region LDoA
Func LDoA1()
    Local $BoolQuestComplete = False
	Local $MapID = GetStartMapByJobID(1,1)

    If GetMapID() <> $MapID Then
        logFile("Moving to Outpost")
        Do
            RndTravel($MapID)
            rndslp(500)
        Until GetMapID() = $MapID
    EndIf
    PingSleep(200)
    logFile("Going outside")
    RandomPath(7428, 5870, 7000, 5350, 50, 1, 4, -1)
    WaitForLoad()

    CheckAndUseStone()

    MoveTo(6220, 4470, 30)
    PingSleep(200)
    logFile("Going to the gate")
    PingSleep(200)
    MoveTo(3180, 6468, 30)
    PingSleep(200)
    MoveTo(360, 6575, 30)
    PingSleep(200)
    MoveTo(-3140, 9610, 30)
    PingSleep(700)
    MoveTo(-3640, 10930, 30)
    PingSleep(700)
    MoveTo(-4876, 11496, 30)
    MoveTo(-4300, 11000, 30)
	If GetIsDead(-2) Then Return
    logFile("Waiting for Rurik to kill mobs")
    PingSleep(3000)
	If GetIsDead(-2) Then Return
    $BoolQuestComplete = Not _LDoACheck_QuestCompleted()
    If $BoolQuestComplete Then
        Do
            PingSleep(200)
            If GetIsDead(-2) Then Return
        Until GetNumberOfFoesInRangeOfAgent(-2, 2000) = 1
        _LDoACheck_QuestCompleted()
    EndIf
    PingSleep(200)
EndFunc

Func LDoA2()
	Local $MapID = GetStartMapByJobID(1,2)

    AdlibUnRegister("LDoASurvivor_LowHealth")

    If GetMapID() <> $MapID Then
        logFile("Moving to Outpost")
        If (GetMapID() == 161) Then
            ;ResignAndReturn()
			RndTravel($MapID)
				rndslp(500)
            WaitMapLoading($MapID)
        Else
            Do
                RndTravel($MapID)
                rndslp(500)
            Until GetMapID() = $MapID
        EndIf
    EndIf

    If (LDoASurvivor_Status()) Then LDoASurvivor_Display()

    RandomPath(260, 8120, 630, 7270, 30, 1, 4, -1)
    logFile("Going Out")
    WaitMapLoading(161)

    If (LDoASurvivor_Status()) Then AdlibRegister("LDoASurvivor_LowHealth", 1000)
	CheckAndUseStone()
    logFile("Going To Bandits")
    MoveTo(1826, 6753)
	MoveTo(2335, 5801)
	TargetNearestEnemy()
	Attack(-1)
	KillMobs()
    MoveTo(2580, 4250, 30)
	TargetNearestEnemy()
	Attack(-1)
	MoveTo(2455, 5320, 30)
	Sleep(200)
	MoveTo(2530, 4826)
	If GetIsDead(-2) Then Return
	logFile("Killing")
    KillMobs()
EndFunc

        #Region Survivor LDoA
Func LDoASurvivor_Status() ;Checks if the bot has to do the survivor title (Return True or False)
    If (GUICtrlRead($Survivor) == $GUI_CHECKED) Then
        Return True
    Else
        Return False
    EndIf
EndFunc

Func LDoASurvivor_LowHealth() ;Checks for low health and cancel run if in danger
    Local $HealthHP

    $HealthHP = ((GetHealth(-2)) * 100/(DllStructGetData(GetAgentByID(-2), 'MaxHP')))

    If ($HealthHP < 30) Then
        logFile("Danger detected : Re-trying.")
        AdlibUnRegister("LDoASurvivor_LowHealth")
        LDoA2()
    EndIf
EndFunc
            #Region LDoA Skill management
Func LDoA_BuildForProfession($Primary, $Secondary, $Level) ;Loads a special LDoA build Return True if done, else return false
    If($Primary == 1) Then ;W
        If($Secondary == 3) Then ;W/Mo
            Switch $Level
                Case 10
                    LoadSkillTemplate("OQMV0IH9I5UnIAgclzUp3jfoEA")
                Case 11
                    LoadSkillTemplate("OQMV0IH9IZVpIAgclzUp3jfoEA")
                Case 12
                    LoadSkillTemplate("OQMV0KH9KZVpIAgclzUp3jfoEA")
                Case 13
                    LoadSkillTemplate("OQMV0KX9KZVrIAgclzUp3jfoEA")
                Case 14
                    LoadSkillTemplate("OQMV0Mn9MZVnIAgclzUp3jfoEA")
                Case 15
                    LoadSkillTemplate("OQMV0Mn9MpVpIAgclzUp3jfoEA")
                Case 16
                    LoadSkillTemplate("OQMV0Mn9MJWpIAgclzUp3jfoEA")
                Case 17
                    LoadSkillTemplate("OQMV0On9OJWpIAgclzUp3jfoEA")
                Case 18
                    LoadSkillTemplate("OQMV0Q39OJWpIAgclzUp3jfoEA")
                Case 19
                    LoadSkillTemplate("OQMV0Q39OZWpIAgclzUp3jfoEA")
                Case 20
                    LoadSkillTemplate("OQMV0QH+QZWpIAgclzUp3jfoEA")
            EndSwitch
            Return True
        EndIf
    ElseIf($Primary == 2) Then ;R
        If($Secondary == 3) Then ;R/Mo
            Switch $Level
                Case 10
                    LoadSkillTemplate("OgMU0IH9ocFgMjrcm0Wx8DlA")
                Case 11
                    LoadSkillTemplate("OgMU0KX9ocFgMjrcm0Wx8DlA")
                Case 12
                    LoadSkillTemplate("OgMU0KX9m8FgMjrcm0Wx8DlA")
                Case 13
                    LoadSkillTemplate("OgMU0MX9o8FgMjrcm0Wx8DlA")
                Case 14
                    LoadSkillTemplate("OgMU0Mn9q8FgMjrcm0Wx8DlA")
                Case 15
                    LoadSkillTemplate("OgMU0Mn9qMGgMjrcm0Wx8DlA")
                Case 16
                    LoadSkillTemplate("OgMU0Mn9qcGgMjrcm0Wx8DlA")
                Case 17
                    LoadSkillTemplate("OgMU0On9ucGgMjrcm0Wx8DlA")
                Case 18
                    LoadSkillTemplate("OgMU0On9wcGgMjrcm0Wx8DlA")
                Case 19
                    LoadSkillTemplate("OgMV0Q39wrkzAkZclzk2KmfoEA")
                Case 20
                    LoadSkillTemplate("OgMU0QH+ycGgMjrcm0Wx8DlA")
            EndSwitch
            Return True
        EndIf
    ElseIf($Primary == 3) Then ;Mo
		If (($Secondary == 0) OR ($Secondary == 1) OR ($Secondary == 4) OR ($Secondary == 5)) Then ;Mo only
            Switch $Level
				Case 10
                    LoadSkillTemplate("OwAD0lXfFgMjrcm3jfoEAA")
                Case 11
                    LoadSkillTemplate("OwAU0KX9MoEgMjrcm3jfoEAA")
                Case 12
                    LoadSkillTemplate("OwAU0Mn9MYEgMjrcm3jfoEAA")
                Case 13
                    LoadSkillTemplate("OwAU0Mn9OoEgMjrcm3jfoEAA")
                Case 14
                    LoadSkillTemplate("OwAU0O39OYEgMjrcm3jfoEAA")
                Case 15
                    LoadSkillTemplate("OwAU0O39QYEgMjrcm3jfoEAA")
                Case 16
                    LoadSkillTemplate("OwAU0OH+Q4EgMjrcm3jfoEAA")
                Case 17
                    LoadSkillTemplate("OwAU0SH+QoEgMjrcm3jfoEAA")
                Case 18
                    LoadSkillTemplate("OwAU0SH+S4EgMjrcm3jfoEAA")
                Case 19
                    LoadSkillTemplate("OwAU0SX+SIFgMjrcm3jfoEAA")
                Case 20
                    LoadSkillTemplate("OwAD0prvGgMjrcm3jfoEAA")
            EndSwitch
            Return True
        ElseIf($Secondary == 2) Then ;Mo/R
            Switch $Level
                Case 10
                    LoadSkillTemplate("OwID0lXfFgMjrcm3jfok2A")
                Case 11
                    LoadSkillTemplate("OwIV0KX9MoYjAkZclz8e8Dl0GA")
                Case 12
                    LoadSkillTemplate("OwIV0Mn9MYYjAkZclz8e8Dl0GA")
                Case 13
                    LoadSkillTemplate("OwIV0Mn9OoYjAkZclz8e8Dl0GA")
                Case 14
                    LoadSkillTemplate("OwIU0O39OYEgMjrcm3jfok2A")
                Case 15
                    LoadSkillTemplate("OwIV0O39QYgjAkZclz8e8Dl0GA")
                Case 16
                    LoadSkillTemplate("OwIV0OH+Q4YjAkZclz8e8Dl0GA")
                Case 17
                    LoadSkillTemplate("OwIU0SH+QoEgMjrcm3jfok2A")
                Case 18
                    LoadSkillTemplate("OwIV0SH+S4YjAkZclz8e8Dl0GA")
                Case 19
                    LoadSkillTemplate("OwIV0SX+SIZjAkZclz8e8Dl0GA")
                Case 20
                    LoadSkillTemplate("OwID0prvGgMjrcm3jfok2A")
            EndSwitch
            Return True
        ElseIf($Secondary == 6) Then ;Mo/El
            Switch $Level
                Case 10
                    LoadSkillTemplate("OwYD0lXfFgMjrcm3jfosYA")
                Case 11
                    LoadSkillTemplate("OwYVokW5qnBjAkZclz8e8DlFDA")
                Case 12
                    LoadSkillTemplate("OwYEoRbu9WAyMuyZeP+hyiB")
                Case 13
                    LoadSkillTemplate("OwYVoom5snBjAkZclz8e8DlFDA")
                Case 14
                    LoadSkillTemplate("OwYVosm5snBjAkZclz8e8DlFDA")
                Case 15
                    LoadSkillTemplate("OwYVoum5snBlAkZclz8e8DlFDA")
                Case 16
                    LoadSkillTemplate("OwYVoum5sHClAkZclz8e8DlFDA")
                Case 17
                    LoadSkillTemplate("OwYVouG6sHCjAkZclz8e8DlFDA")
                Case 18
                    LoadSkillTemplate("OwYVouG6wHCjAkZclz8e8DlFDA")
                Case 19
                    LoadSkillTemplate("OwYVowG6wHCnAkZclz8e8DlFDA")
                Case 20
                    LoadSkillTemplate("OwYEoYnO+ZAyMuyZeP+hyiB")
            EndSwitch
            Return True
        EndIf
    ElseIf($Primary == 4) Then ;N
        If($Secondary == 3) Then ;N/Mo
            Switch $Level
                Case 10
                    LoadSkillTemplate("OANEQUXO9UAyMuyZmp7xPUC")
                Case 11
                    LoadSkillTemplate("OANEQUXe9VAyMuyZmp7xPUC")
                Case 12
                    LoadSkillTemplate("OANFQkJd51bBIz4KnZmuH/QJ")
                Case 13
                    LoadSkillTemplate("OANFQkFt52bBIz4KnZmuH/QJ")
                Case 14
                    LoadSkillTemplate("OANEQVfu9WAyMuyZmp7xPUC")
                Case 15
                    LoadSkillTemplate("OANFQlJ952fBIz4KnZmuH/QJ")
                Case 16
                    LoadSkillTemplate("OANFQlF954fBIz4KnZmuH/QJ")
                Case 17
                    LoadSkillTemplate("OANFQnJ954fBIz4KnZmuH/QJ")
                Case 18
                    LoadSkillTemplate("OANEQXjO+YAyMuyZmp7xPUC")
                Case 19
                    LoadSkillTemplate("OANFQnJN65jBIz4KnZmuH/QJ")
                Case 20
                    LoadSkillTemplate("OANEQYne+YAyMuyZmp7xPUC")
            EndSwitch
            Return True
        EndIf
    ElseIf($Primary == 5) Then ;Mes
        If($Secondary == 3) Then ;Mes/Mo
            Switch $Level
                Case 10
                    LoadSkillTemplate("OQNEMUTO9VASUkxVOz7xPUC")
                Case 11
                    LoadSkillTemplate("OQNEMUXe9VASUkxVOz7xPUC")
                Case 12
                    LoadSkillTemplate("OQNFAyQt51XBIRRGX5MvH/QJ")
                Case 13
                    LoadSkillTemplate("OQNFAxQt51fBIRRGX5MvH/QJ")
                Case 14
                    LoadSkillTemplate("OQNEMVbu9XASUkxVOz7xPUC")
                Case 15
                    LoadSkillTemplate("OQNFAyUt53fBIRRGX5MvH/QJ")
                Case 16
                    LoadSkillTemplate("OQNFAxUN63fBIRRGX5MvH/QJ")
                Case 17
                    LoadSkillTemplate("OQNFAxYN63jBIRRGX5MvH/QJ")
                Case 18
                    LoadSkillTemplate("OQNFAyUN64nBIRRGX5MvH/QJ")
                Case 19
                    LoadSkillTemplate("OQNFAxYN65nBIRRGX5MvH/QJ")
                Case 20
                    LoadSkillTemplate("OQNEMYje+ZASUkxVOz7xPUC")
            EndSwitch
            Return True
        EndIf
    ElseIf($Primary == 6) Then ;El
        If($Secondary == 3) Then ;El/Mo
            Switch $Level
                Case 10
                    LoadSkillTemplate("OgNEoEXN9UQLkByMuyZWMhB")
                Case 11
                    LoadSkillTemplate("OgNEoEXd9VQLkByMuyZWMhB")
                Case 12
                    LoadSkillTemplate("OgNEoETd9XQLkByMuyZWMhB")
                Case 13
                    LoadSkillTemplate("OgNEoFTt9XQLkByMuyZWMhB")
                Case 14
                    LoadSkillTemplate("OgNEoGXt9XQLkByMuyZWMhB")
                Case 15
                    LoadSkillTemplate("OgNEoGX99XQLkByMuyZWMhB")
                Case 16
                    LoadSkillTemplate("OgNEoHb99XQLkByMuyZWMhB")
                Case 17
                    LoadSkillTemplate("OgNEoIf99XQLkByMuyZWMhB")
                Case 18
                    LoadSkillTemplate("OgNEoIj99YQLkByMuyZWMhB")
                Case 19
                    LoadSkillTemplate("OgNEoJj99YQLkByMuyZWMhB")
                Case 20
                    LoadSkillTemplate("OgNEoJnN+YQLkByMuyZWMhB")
            EndSwitch
            Return True
        EndIf
    EndIf

    Return False
EndFunc

Func LDoA_CastSkillFromBuild($Primary, $Secondary, $type = 1) ;Cast a skill for LDoA Special builds Retruns True if done, else returns False
    Local $lAgentMe = GetMyID()
    Local $SkillToCast = 1

    If($Primary == 1) Then ;W
        If($Secondary == 3) Then ;W/Mo
            If ($type == 2) Then ($type = 1)
            If ($type == 0) Then
                $SkillToCast = Random(1,4,1)
                Switch $SkillToCast
                    Case 1 ;Healing Signet (W tactic : cost 0, CTime 2s, cd 4s)
                        CastSkill($SkillToCast, -2)
                    Case 2 ;Healing Breeze (Mo Heal : cost 10nrg, CTime 1s, cd 5s)
                        If ((GetEffectTimeRemaining($Healing_Breeze) < 1000) OR Not (_HasEffect($Healing_Breeze))) Then
                            If (GetEnergy($lAgentMe) >= 10) Then CastSkill($SkillToCast, -2)
                        EndIf
                    Case 3 ;Shielding Hands (Mo Prot : cost 5nrg, CTime 1/4s, cd 15s)
                        If ((GetEffectTimeRemaining($Shielding_Hands) < 250) OR Not (_HasEffect($Shielding_Hands))) Then
                            If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast, -2)
                        EndIf
                    Case 4 ;Reversal of Fortune (Mo Prot : cost 5nrg, CTime 1/4s, cd 2s)
                        If ((GetEffectTimeRemaining($Reversal_of_Fortune) < 250) OR Not (_HasEffect($Reversal_of_Fortune))) Then
                            If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast, -2)
                        EndIf
                EndSwitch
            ElseIf ($type == 1) Then
                $SkillToCast = Random(5,8,1)
                TargetNearestEnemy()
                Attack(-1)
                Switch $SkillToCast
                    Case 5,6
                    ;5: Cyclone Axe (W Axe : cost 5nrg, CTime 0, cd 4s)
                    ;6: Symbol of Warth (Mo smit : cost 5nrg, CTime 2s, cd 30s)
                        If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast,-1,$Adjacent)
                    Case 7 ;Banish (Mo smit : cost 5nrg, CTime 1s, cd 10s)
                        If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast,-1)
                    Case 8 ;Bane Signet (Mo smit : cost 0, CTime 1s, cd 20s)
                        CastSkill($SkillToCast,-1)
                EndSwitch
            EndIf
            Return True
        EndIf
    ElseIf($Primary == 2) Then ;R
		If($Secondary == 3) Then ;R/Mo
            If ($type == 2) Then ($type = 1)
            If ($type == 0) Then
                $SkillToCast = Random(1,4,1)
                Switch $SkillToCast
                    Case 1 ;Healing Signet (W tactic : cost 0, CTime 2s, cd 4s)
                        If ((GetEffectTimeRemaining($Healing_Breeze) < 1000) OR Not (_HasEffect($Healing_Breeze))) Then
                            If (GetEnergy($lAgentMe) >= 10) Then CastSkill($SkillToCast, -2)
                        EndIf
                    Case 2 ;Orison of Healing (Mo Healing : cost 5nrg, CTime 1s, cd 2s)
                        If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast, -2)
                    Case 3 ;Shielding Hands (Mo Prot : cost 5nrg, CTime 1/4s, cd 15s)
                        If ((GetEffectTimeRemaining($Shielding_Hands) < 250) OR Not (_HasEffect($Shielding_Hands))) Then
                            If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast, -2)
                        EndIf
                    Case 4 ;Reversal of Fortune (Mo Prot : cost 5nrg, CTime 1/4s, cd 2s)
                        If ((GetEffectTimeRemaining($Reversal_of_Fortune) < 250) OR Not (_HasEffect($Reversal_of_Fortune))) Then
                            If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast, -2)
                        EndIf
                EndSwitch
            ElseIf ($type == 1) Then
                $SkillToCast = Random(6,8,1)
                TargetNearestEnemy()
                Attack(-1)
                Switch $SkillToCast
                    Case 6 ;Power Shot (R marksmanship : cost 10nrg, CTime 0, cd 3s)
                        If (GetEnergy($lAgentMe) >= 10) Then CastSkill($SkillToCast, -1)
                    Case 7 ;Banish (Mo smit : cost 5nrg, CTime 1s, cd 10s)
                        If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast, -1)
                    Case 8 ;Bane Signet (Mo smit : cost 0, CTime 1s, cd 20s)
                        CastSkill($SkillToCast, -1)
                EndSwitch
            ElseIf ($type == 3) Then
                $SkillToCast = 5 ;Comfort Animal (Beast mastery : cost 5nrg, CTime 1s, cd 1s)
                If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast)
            EndIf
            Return True
        EndIf
    ElseIf($Primary == 3) Then ;Mo
		If (($Secondary == 0) OR ($Secondary == 1) OR ($Secondary == 4) OR ($Secondary == 5)) Then ;Mo only
			If ($type == 2) Then ($type = 1)
            If ($type == 0) Then
                $SkillToCast = Random(1,4,1)
                Switch $SkillToCast
                    Case 1 ;Healing Breeze (Mo Heal : cost 10nrg, CTime 1s, cd 5s)
                        If ((GetEffectTimeRemaining($Healing_Breeze) < 1000) OR Not (_HasEffect($Healing_Breeze))) Then
                            If (GetEnergy($lAgentMe) >= 10) Then CastSkill($SkillToCast, -2)
                        EndIf
                    Case 2 ;Orison of Healing (Mo Healing : cost 5nrg, CTime 1s, cd 2s)
                        If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast, -2)
                    Case 3 ;Shielding Hands (Mo Prot : cost 5nrg, CTime 1/4s, cd 15s)
                        If ((GetEffectTimeRemaining($Shielding_Hands) < 250) OR Not (_HasEffect($Shielding_Hands))) Then
                            If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast, -2)
                        EndIf
                    Case 4 ;Reversal of Fortune (Mo Prot : cost 5nrg, CTime 1/4s, cd 2s)
                        If ((GetEffectTimeRemaining($Reversal_of_Fortune) < 250) OR Not (_HasEffect($Reversal_of_Fortune))) Then
                            If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast, -2)
                        EndIf
                EndSwitch
            ElseIf ($type == 1) Then
                $SkillToCast = Random(5,7,1)
                TargetNearestEnemy()
                Attack(-1)
                Switch $SkillToCast
                    Case 5 ;Symbol of Warth (Mo smit : cost 5nrg, CTime 2s, cd 30s)
                        If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast,-1,$Adjacent)
                    Case 6 ;Banish (Mo smit : cost 5nrg, CTime 1s, cd 10s)
                        If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast, -1)
                    Case 7 ;Bane Signet (Mo smit : cost 0, CTime 1s, cd 20s)
                        CastSkill($SkillToCast, -1)
                EndSwitch
            EndIf
            Return True
        ElseIf($Secondary == 2) Then ;Mo/R
            If ($type == 2) Then ($type = 1)
            If ($type == 0) Then
                $SkillToCast = Random(1,4,1)
                Switch $SkillToCast
                    Case 1 ;Healing Breeze (Mo Heal : cost 10nrg, CTime 1s, cd 5s)
                        If ((GetEffectTimeRemaining($Healing_Breeze) < 1000) OR Not (_HasEffect($Healing_Breeze))) Then
                            If (GetEnergy($lAgentMe) >= 10) Then CastSkill($SkillToCast, -2)
                        EndIf
                    Case 2 ;Orison of Healing (Mo Healing : cost 5nrg, CTime 1s, cd 2s)
                        If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast, -2)
                    Case 3 ;Shielding Hands (Mo Prot : cost 5nrg, CTime 1/4s, cd 15s)
                        If ((GetEffectTimeRemaining($Shielding_Hands) < 250) OR Not (_HasEffect($Shielding_Hands))) Then
                            If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast, -2)
                        EndIf
                    Case 4 ;Reversal of Fortune (Mo Prot : cost 5nrg, CTime 1/4s, cd 2s)
                        If ((GetEffectTimeRemaining($Reversal_of_Fortune) < 250) OR Not (_HasEffect($Reversal_of_Fortune))) Then
                            If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast, -2)
                        EndIf
                EndSwitch
            ElseIf ($type == 1) Then
                $SkillToCast = Random(5,7,1)
                TargetNearestEnemy()
                Attack(-1)
                Switch $SkillToCast
                    Case 5 ;Symbol of Warth (Mo smit : cost 5nrg, CTime 2s, cd 30s)
                        If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast,-1,$Adjacent)
                    Case 6 ;Banish (Mo smit : cost 5nrg, CTime 1s, cd 10s)
                        If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast, -1)
                    Case 7 ;Bane Signet (Mo smit : cost 0, CTime 1s, cd 20s)
                        CastSkill($SkillToCast, -1)
                EndSwitch
            ElseIf ($type == 3) Then
                $SkillToCast = 5 ;Comfort Animal (R Beast mastery : cost 5nrg, CTime 1s, cd 1s)
                If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast)
            EndIf
            Return True
        ElseIf($Secondary == 6) Then ;Mo/El
            If ($type == 2) Then ($type = 1)
            If ($type == 0) Then
                $SkillToCast = Random(1,4,1)
                Switch $SkillToCast
                    Case 1 ;Healing Breeze (Mo Heal : cost 10nrg, CTime 1s, cd 5s)
                        If ((GetEffectTimeRemaining($Healing_Breeze) < 1000) OR Not (_HasEffect($Healing_Breeze))) Then
                            If (GetEnergy($lAgentMe) >= 10) Then CastSkill($SkillToCast, -2)
                        EndIf
                    Case 2 ;Orison of Healing (Mo Healing : cost 5nrg, CTime 1s, cd 2s)
                        If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast, -2)
                    Case 3 ;Shielding Hands (Mo Prot : cost 5nrg, CTime 1/4s, cd 15s)
                        If ((GetEffectTimeRemaining($Shielding_Hands) < 250) OR Not (_HasEffect($Shielding_Hands))) Then
                            If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast, -2)
                        EndIf
                    Case 4 ;Reversal of Fortune (Mo Prot : cost 5nrg, CTime 1/4s, cd 2s)
                        If ((GetEffectTimeRemaining($Reversal_of_Fortune) < 250) OR Not (_HasEffect($Reversal_of_Fortune))) Then
                            If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast, -2)
                        EndIf
                EndSwitch
            ElseIf ($type == 1) Then
                $SkillToCast = Random(5,8,1)
                TargetNearestEnemy()
                Attack(-1)
                Switch $SkillToCast
                    Case 5 ;Symbol of Warth (Mo smit : cost 5nrg, CTime 2s, cd 30s)
                        If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast,-1,$Adjacent)
                    Case 6 ;Banish (Mo smit : cost 5nrg, CTime 1s, cd 10s)
                        If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast, -1)
                    Case 7 ;Bane Signet (Mo smit : cost 0, CTime 1s, cd 20s)
                        CastSkill($SkillToCast, -1)
                    Case 8 ;Fire Storm (El Fire magic : cost 10nrg, CTime 2s, cd 20s)
                        If (GetEnergy($lAgentMe) >= 10) Then CastSkill($SkillToCast, -1)
                EndSwitch
            EndIf
            Return True
        EndIf
    ElseIf($Primary == 4) Then ;N
		If($Secondary == 3) Then ;N/Mo
            If ($type == 2) Then ($type = 1)
            If ($type == 0) Then
                $SkillToCast = Random(1,5,1)
                Switch $SkillToCast
                    Case 1 ;Healing Breeze (Mo Heal : cost 10nrg, CTime 1s, cd 5s)
                        If ((GetEffectTimeRemaining($Healing_Breeze) < 1000) OR Not (_HasEffect($Healing_Breeze))) Then
                            If (GetEnergy($lAgentMe) >= 10) Then CastSkill($SkillToCast, -2)
                        EndIf
                    Case 2 ;Orison of Healing (Mo Healing : cost 5nrg, CTime 1s, cd 2s)
                        If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast, -2)
                    Case 3 ;Shielding Hands (Mo Prot : cost 5nrg, CTime 1/4s, cd 15s)
                        If ((GetEffectTimeRemaining($Shielding_Hands) < 250) OR Not (_HasEffect($Shielding_Hands))) Then
                            If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast, -2)
                        EndIf
                    Case 4 ;Reversal of Fortune (Mo Prot : cost 5nrg, CTime 1/4s, cd 2s)
                        If ((GetEffectTimeRemaining($Reversal_of_Fortune) < 250) OR Not (_HasEffect($Reversal_of_Fortune))) Then
                            If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast, -2)
                        EndIf
                    Case 5 ;Vampiric Gaze (N Blood magic : cost 10nrg, CTime 1s, cd 8s)
                        TargetNearestEnemy()
                        Attack(-1)
                        If (GetEnergy($lAgentMe) >= 10) Then CastSkill($SkillToCast, -1)
                EndSwitch
            ElseIf ($type == 1) Then
                $SkillToCast = Random(5,8,1)
                TargetNearestEnemy()
                Attack(-1)
                Switch $SkillToCast
                    Case 5 ;Vampiric Gaze (N Blood magic : cost 10nrg, CTime 1s, cd 8s)
                        If (GetEnergy($lAgentMe) >= 10) Then CastSkill($SkillToCast, -1)
                    Case 6 ;Symbol of Warth (Mo smit : cost 5nrg, CTime 2s, cd 30s)
                        If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast,-1,$Adjacent)
                    Case 7 ;Banish (Mo smit : cost 5nrg, CTime 1s, cd 10s)
                        If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast, -1)
                    Case 8 ;Bane Signet (Mo smit : cost 0, CTime 1s, cd 20s)
                        CastSkill($SkillToCast, -1)
                EndSwitch
            EndIf
            Return True
        EndIf
    ElseIf($Primary == 5) Then ;Mes
        If($Secondary == 3) Then ;Mes/Mo
            If ($type == 2) Then ($type = 1)
            If ($type == 0) Then
                $SkillToCast = Random(1,5,1)
                Switch $SkillToCast
                    Case 1 ;Healing Breeze (Mo Heal : cost 10nrg, CTime 1s, cd 5s)
                        If ((GetEffectTimeRemaining($Healing_Breeze) < 1000) OR Not (_HasEffect($Healing_Breeze))) Then
                            If (GetEnergy($lAgentMe) >= 10) Then CastSkill($SkillToCast, -2)
                        EndIf
                    Case 2 ;Ether Feast (Mes Inspiration Magic : cost 5nrg, CTime 1s, cd 8s)
                        TargetNearestEnemy()
                        Attack(-1)
                        If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast, -1)
                    Case 3 ;Orison of Healing (Mo Healing : cost 5nrg, CTime 1s, cd 2s)
                        If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast, -2)
                    Case 4 ;Shielding Hands (Mo Prot : cost 5nrg, CTime 1/4s, cd 15s)
                        If ((GetEffectTimeRemaining($Shielding_Hands) < 250) OR Not (_HasEffect($Shielding_Hands))) Then
                            If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast, -2)
                        EndIf
                    Case 5 ;Reversal of Fortune (Mo Prot : cost 5nrg, CTime 1/4s, cd 2s)
                        If ((GetEffectTimeRemaining($Reversal_of_Fortune) < 250) OR Not (_HasEffect($Reversal_of_Fortune))) Then
                            If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast, -2)
                        EndIf
                EndSwitch
            ElseIf ($type == 1) Then
                $SkillToCast = Random(6,8,1)
                TargetNearestEnemy()
                Attack(-1)
                Switch $SkillToCast
                    Case 6 ;Symbol of Warth (Mo smit : cost 5nrg, CTime 2s, cd 30s)
                        If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast,-1,$Adjacent)
                    Case 7 ;Banish (Mo smit : cost 5nrg, CTime 1s, cd 10s)
                        If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast, -1)
                    Case 8 ;Bane Signet (Mo smit : cost 0, CTime 1s, cd 20s)
                        CastSkill($SkillToCast, -1)
                EndSwitch
            EndIf
            Return True
        EndIf
    ElseIf($Primary == 6) Then ;El
        If($Secondary == 3) Then ;El/Mo
            If ($type == 0) Then
                $SkillToCast = Random(3,6,1)
                Switch $SkillToCast
                    Case 3 ;Healing Breeze (Mo Heal : cost 10nrg, CTime 1s, cd 5s)
                        If ((GetEffectTimeRemaining($Healing_Breeze) < 1000) OR Not (_HasEffect($Healing_Breeze))) Then
                            If (GetEnergy($lAgentMe) >= 10) Then CastSkill($SkillToCast, -2)
                        EndIf
                    Case 4 ;Orison of Healing (Mo Healing : cost 5nrg, CTime 1s, cd 2s)
                        If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast, -2)
                    Case 5 ;Shielding Hands (Mo Prot : cost 5nrg, CTime 1/4s, cd 15s)
                        If ((GetEffectTimeRemaining($Shielding_Hands) < 250) OR Not (_HasEffect($Shielding_Hands))) Then
                            If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast, -2)
                        EndIf
                    Case 6 ;Reversal of Fortune (Mo Prot : cost 5nrg, CTime 1/4s, cd 2s)
                        If ((GetEffectTimeRemaining($Reversal_of_Fortune) < 250) OR Not (_HasEffect($Reversal_of_Fortune))) Then
                            If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast, -2)
                        EndIf
                EndSwitch
            ElseIf ($type == 1) Then
                $SkillToCast = Random(7,8,1)
                TargetNearestEnemy()
                Attack(-1)
                Switch $SkillToCast
                    Case 7 ;Fire Storm (El Fire magic : cost 10nrg, CTime 2s, cd 20s)
                        If (GetEnergy($lAgentMe) >= 10) Then CastSkill($SkillToCast, -1)
                    Case 8 ;Flare (El Fire Magic : cost 5nrg, CTime 1s, cd 0)
                        If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast, -1)
                EndSwitch
            ElseIf ($type == 2) Then
                $SkillToCast = Random(1,2,1)
                Switch $SkillToCast
                    Case 1 ;Aura of Restoration (El Energy Storage : cost 5nrg, CTime 1/4s, cd 20s)
                        If ((GetEffectTimeRemaining($Aura_of_Restoration) < 250) OR Not (_HasEffect($Aura_of_Restoration))) Then
                            If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast, -2)
                        EndIf
                    Case 2 ;Glyph of Lesser Energy (El Energy Storage : cost 5nrg, CTime 1s, cd 30s)
                        If ((GetEffectTimeRemaining($Glyph_of_Lesser_Energy) < 1000) OR Not (_HasEffect($Glyph_of_Lesser_Energy))) Then
                            If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast, -2)
                        EndIf
                EndSwitch
            EndIf
            Return True
        EndIf
    EndIf

    Return False
EndFunc
            #EndRegion LDoA Skill management
        #EndRegion Survivor LDoA

        #Region LDoA1 - quest management
Func LDoACheck_QuestCompleted() ;Checks if Charr at the Door is completed (Returns True or False) based on number of mobs remaining in explorable zone
    If (GetNumberOfFoesInRangeOfAgent(-2, 2000) < 1) Then
        logFile("All charrs have been killed.")
        LDoA_GoGetQuest()
        Return False
    Else
        Return True
    EndIf
EndFunc

Func _LDoACheck_QuestCompleted() ; Check if "Charr at the Gate"(46) quest is at reward state (Returns True if yes, else returns False)
    Local $lQuestState = DllStructGetData(GetQuestByID(46), 'LogState')

	If (($lQuestState = 35) OR ($lQuestState = 3)) Then ;State Reward
		logFile("All charrs have been killed.")
        LDoA_GoGetQuest()
        Return True
	Else ;Not completed
		Return False
	EndIf
EndFunc

Func LDoA_GoGetQuest() ;In Ascalon City go find the quest
    Local $Rurik
    Local $MapID = GetStartMapByJobID(1,1)

    If GetMapID() <> $MapID Then
        logFile("Moving to Outpost")
        Do
            RndTravel($MapID)
            rndslp(500)
        Until GetMapID() = $MapID
    EndIf

    AbandonQuest(46)
    ;Go to Rurik
    MoveTo(7935,6271)
    MoveTo(7567,6570)
    MoveTo(7620,8955)
    MoveTo(7617,10665)
    MoveTo(5691,10643)
    logFile("Taking quest back.")
    $Rurik = GetNearestNPCToCoords(5625, 10662)
    RNDSLP(1000)
	GoToNPC($Rurik)
    AcceptQuest(46)
    ;Go back in front of portal
    MoveTo(7617,10665)
    MoveTo(7620,8955)
    MoveTo(7567,6570)
    MoveTo(7935,6271)
EndFunc
        #EndRegion
	#EndRegion

	#Region Farms
Func Farm_GoStartingOutpost($FarmID)
    Local $MapID

    If ($FarmID == 0) Then
		logFile("ERROR : $FarmID is null in Farm_GoStartingOutpost function.")
	ElseIf (($FarmID == 3) OR ($FarmID == 5) OR ($FarmID == 13) OR ($FarmID == 11)) Then ;Worn Belt & Baked husk & Skeletal limb & Red Iris Flower
		$MapID = GetStartMapByJobID(1,$FarmID)
        If GetMapID() <> $MapID Then ;Ashford Abbey
			logFile("Moving to Ashford Abbey")
			Do
				RndTravel($MapID)
				rndslp(500)
			Until GetMapID() = $MapID
		EndIf
		If CheckIfInventoryIsFull() Then
			IdentItemToMerchantOmniTown($MapID)
			SellItemToMerchantOmniTown($MapID)
		EndIf
	ElseIf (($FarmID == 4) OR ($FarmID == 6) OR ($FarmID == 1) OR ($FarmID == 18)) Then ;Dull carapace & Charr carving & LDoA1 & Charrs boss
		$MapID = GetStartMapByJobID(1,$FarmID)
        If GetMapID() <> $MapID Then ;Ascalon City
			logFile("Moving to Ascalon City")
			Do
				RndTravel($MapID)
				rndslp(500)
			Until GetMapID() = $MapID
		EndIf
		If CheckIfInventoryIsFull() Then
			IdentItemToMerchantOmniTown($MapID)
			SellItemToMerchantOmniTown($MapID)
		EndIf
    ElseIf (($FarmID == 9) OR ($FarmID == 12) OR ($FarmID == 14) OR ($FarmID == 15)) Then ;Grawl necklace & Skale fin & Spider leg & Unnatural seed
		$MapID = GetStartMapByJobID(1,$FarmID)
        If GetMapID() <> $MapID Then ;Fort Ranik
			logFile("Moving to Fort Ranik")
			Do
				RndTravel($MapID)
				rndslp(500)
			Until GetMapID() = $MapID
		EndIf
		If CheckIfInventoryIsFull() Then
			IdentItemToMerchantOmniTown($MapID)
			SellItemToMerchantOmniTown($MapID)
		EndIf
    ElseIf (($FarmID == 10) OR ($FarmID == 2)) Then ;Icy lodestone & LDoA2
		$MapID = GetStartMapByJobID(1,$FarmID)
        If GetMapID() <> $MapID Then ;Foible's Fair (Place des fous)
			logFile("Moving to Foible's Fair")
			Do
				RndTravel($MapID)
				rndslp(500)
			Until GetMapID() = $MapID
		EndIf
		If CheckIfInventoryIsFull() Then
			IdentItemToMerchantOmniTown($MapID)
			SellItemToMerchantOmniTown($MapID)
		EndIf
    ElseIf (($FarmID == 7) OR ($FarmID == 8)) Then ;Enchanted lodestone & Gargoyle skull
		$MapID = GetStartMapByJobID(1,$FarmID)
        If GetMapID() <> $MapID Then ;The Barradin Estate
			logFile("Moving to the Barradin Estate")
			Do
				RndTravel($MapID)
				rndslp(500)
			Until GetMapID() = $MapID
		EndIf
		If CheckIfInventoryIsFull() Then
			IdentItemToMerchantOmniTown($MapID)
			SellItemToMerchantOmniTown($MapID)
		EndIf
	EndIf
EndFunc

Func Farm_GoOutpostPortal($FarmID)
	Local $lAgent = GetAgentByID(-2)
	Local $MyPosX = DllStructGetData($lAgent, 'X')
	Local $MyPosY = DllStructGetData($lAgent, 'Y')

	If ($FarmID == 0) Then
		logFile("ERROR : $FarmID is null in Farm_GoOutpostPortal.")
	ElseIf (($FarmID == 3) OR ($FarmID == 5) OR ($FarmID == 11)) Then ;Ashford Abbey to fields and village
		RndSleep(250)
		logFile("Going out")
		If (($MyPosX < -12000) AND ($MyPosX > -13000) AND ($MyPosY < -7500) AND ($MyPosY > -8700)) Then
		;Pos A : Near Mhenlo
			MoveTo(-11628, -7178)
			MoveTo(-11560, -6273)
			Move(-11001, -6233)
		ElseIf (($MyPosX < -11500) AND ($MyPosX > -12500) AND ($MyPosY < -5300) AND ($MyPosY > -5900)) Then
		;Pos B : Near Portal
			MoveTo(-11626, -6231)
			Move(-11001, -6233)
		ElseIf (($MyPosX < -12500) AND ($MyPosX > -13200) AND ($MyPosY < -7500) AND ($MyPosY > -8000)) Then
		;Pos C : Near Catacombs portal
			MoveTo(-12588, -6290)
			Move(-11001, -6233)
		ElseIf (($MyPosX < -11500) AND ($MyPosX > -11600) AND ($MyPosY < -6100) AND ($MyPosY > -6300)) Then
		;Pos D : When re-entering portal
			Move(-11001, -6233)
		Else
			MoveTo(-12243, -6161)
			MoveTo(-11889, -6248)
			MoveTo(-11447, -6229)
			Move(-11005, -6210)
		EndIf
		WaitForLoad()
    ElseIf ($FarmID == 13) Then ;Ashford Abbey to catacombs
        RndSleep(250)
		logFile("Going out")
        If (($MyPosX < -12000) AND ($MyPosX > -13000) AND ($MyPosY < -7500) AND ($MyPosY > -8700)) Then
		;Pos A : Near Mhenlo
            MoveTo(-13315,-7088)
            Move(-14000,-7082)
        ElseIf (($MyPosX < -11500) AND ($MyPosX > -12500) AND ($MyPosY < -5300) AND ($MyPosY > -5900)) Then
		;Pos B : Near Portal
            MoveTo(-13315,-7088)
            Move(-14000,-7082)
        ElseIf (($MyPosX < -12500) AND ($MyPosX > -13200) AND ($MyPosY < -7500) AND ($MyPosY > -8000)) Then
		;Pos C : Near Catacombs portal
            MoveTo(-13315,-7088)
            Move(-14000,-7082)
        ElseIf (($MyPosX < -11500) AND ($MyPosX > -11600) AND ($MyPosY < -6100) AND ($MyPosY > -6300)) Then
		;Pos D : When re-entering portal from field and village
            MoveTo(-12593,-6423)
            MoveTo(-13315,-7088)
            Move(-14000,-7082)
        ElseIf (($MyPosX < -12700) AND ($MyPosX > -13300) AND ($MyPosY < -6700) AND ($MyPosY > -7300)) Then
        ;Pos E : When re-entering portal and catacomb
            Move(-14000,-7082)
        Else
            MoveTo(-13315,-7088)
            Move(-14000,-7082)
        EndIf
		WaitForLoad()
	ElseIf (($FarmID == 4) OR ($FarmID == 6) OR ($FarmID == 18)) Then ;Ascalon City to portal
		RndSleep(250)
		logFile("Going out")
		If (($MyPosX < 9800) AND ($MyPosX > 9300) AND ($MyPosY < 5000) AND ($MyPosY > 4500)) Then
		;Pos A : Main Road
			MoveTo(8192, 5997)
			Move(6602, 4485)
		ElseIf (($MyPosX < 10000) AND ($MyPosX > 9400) AND ($MyPosY < 8200) AND ($MyPosY > 7700)) Then
		;Pos B : Upstairs
			MoveTo(8460, 6380)
			Move(6602, 4485)
		ElseIf (($MyPosX < 7900) AND ($MyPosX > 7600) AND ($MyPosy < 6000) AND ($MyPosY > 5600)) Then
		;Pos C : When re-entering from portal
			Move(6602, 4485)
		Else
			MoveTo(8046,6047)
			Move(6602, 4485)
		EndIf
		WaitForLoad()
    ElseIf (($FarmID == 9) OR ($FarmID == 12) OR ($FarmID == 14) OR ($FarmID == 15)) Then ;Fort Ranik to portal
        RndSleep(250)
		logFile("Going out")
        If (($MyPosX < 26000) AND ($MyPosX > 25000) AND ($MyPosY < 15000) AND ($MyPosY > 14000)) Then
        ;Pos A : Bottom part of the Fort
            MoveTo(23712,14024)
            MoveTo(22902,13584)
            MoveTo(22565,9616)
            Move(22614,6849)
        ElseIf (($MyPosX < 24000) AND ($MyPosX > 23000) AND ($MyPosY < 14000) AND ($MyPosY > 13000)) Then
        ;Pos B : West slope
            MoveTo(22902,13584)
            MoveTo(22565,9616)
            Move(22614,6849)
        ElseIf (($MyPosX < 23000) AND ($MyPosX > 22000) AND ($MyPosY < 12000) AND ($MyPosY > 11000)) Then
        ;Pos C : Top-west of the Fort
            MoveTo(23273,11555)
            MoveTo(22565,9616)
            Move(22614,6849)
        ElseIf (($MyPosX < 23000) AND ($MyPosX > 22000) AND ($MyPosY < 11000) AND ($MyPosY > 10000)) Then
        ;Pos D : When re-entering portal
            MoveTo(22565,9616)
            Move(22614,6849)
        Else
        ;#TODO
        EndIf
        WaitForLoad()
    ElseIf ($FarmID == 10) Then ;Foible's Fair
        RndSleep(250)
		logFile("Going out")
        If (($MyPosX < -600) AND ($MyPosX > -1000) AND ($MyPosY < 10000) AND ($MyPosY > 9500)) Then
        ;Pos A : Center in front of portal
            MoveTo(-5,8745)
            Move(633,7270)
        ElseIf (($MyPosX < -400) AND ($MyPosX > -500) AND ($MyPosY < 9200) AND ($MyPosY > 8800)) Then
        ;Pos B : Near portal South-West side
            MoveTo(149,8575)
            Move(633,7270)
        ElseIf (($MyPosX < 400) AND ($MyPosX > 0) AND ($MyPosY < 10200) AND ($MyPosY > 9700)) Then
        ;Pos C : Near portal Nord-East side
            MoveTo(-33,8899)
            Move(633,7270)
        ElseIf (($MyPosX < 400) AND ($MyPosX > 0) AND ($MyPosY < 8700) AND ($MyPosY > 8200)) Then
        ;Pos D : When re-entering portal
            Move(633,7270)
        Else
            MoveTo(149,8575)
            Move(633,7270)
        EndIf
        WaitForLoad()
    ElseIf (($FarmID == 7) OR ($FarmID == 8)) Then ;The Barradin Estate
        RndSleep(250)
		logFile("Going out")
        If (($MyPosX < -6000) AND ($MyPosX > -6400) AND ($MyPosY < 1200) AND ($MyPosY > 800)) Then
        ;Pos A : Estate south-side near wall's pillar
            MoveTo(-6426,1402)
            Move(-7459,1458)
        ElseIf (($MyPosX < -6100) AND ($MyPosX > -6500) AND ($MyPosY < 2000) AND ($MyPosY > 1500)) Then
        ;Pos B : Estate north-side wall's pillar
            MoveTo(-6426,1402)
            Move(-7459,1458)
        ElseIf (($MyPosX < -6700) AND ($MyPosX > -7200) AND ($MyPosY < 1600) AND ($MyPosY > 1200)) Then
        ;Pos C : When re-entering portal
            Move(-7459,1458)
        Else
            MoveTo(-6426,1402)
            Move(-7459,1458)
        EndIf
        WaitForLoad()
	EndIf
EndFunc

Func FarmingRouteAndKill($FarmID)
    Local $MapID
    Local $i

	If ($FarmID == 0) Then
		logFile("ERROR : $FarmID is null in FarmingRouteAndKill function.")
	ElseIf ($FarmID == 3) Then ;Go to Bandits and kill from Ashford Abbey
		logFile("Moving to Bandits farmspot")
		MoveTo(-10203, -6232)
		MoveTo(-9177, -6111)
		MoveTo(-8236, -5490)
		MoveTo(-7341, -4437)
		MoveTo(-6719, -4256)
		MoveTo(-6038, -3717)
		MoveTo(-6144, -2247)
		If GetIsDead(-2) Then Return
		logFile ("Killing Bandits")

        CheckAndUseStone()
        sleep(2000)

        KillMobs()
		CheckAndPickUp()
		sleep(500)

	ElseIf ($FarmID == 4) Then ;Go to Devourer cave and kill from Ascalon city
		logFile("Moving to Devourers' Cave")
		MoveTo(5844,2576)
        MoveTo(4782,971)
        MoveTo(4950,-303)
        MoveTo(5241,-2449)
        MoveTo(6673,-4013)
        MoveTo(7527,-6783)
        MoveTo(8418,-7555)
        MoveTo(9411,-9455)
        MoveTo(9674,-11192)
		If GetIsDead(-2) Then Return
        logFile("Arrived at the entrance of the cave")
        RndSleep(1000)

		logFile("Killing Devourers")
		CheckAndUseStone()
        sleep(2000)

        MoveTo(8254,-11202)
        KillMobs()
		CheckAndPickUp()
		sleep(500)
        MoveTo(7060,-11028)
        KillMobs()
		CheckAndPickUp()
        sleep(500)
        MoveTo(5831,-10692)
        KillMobs()
		CheckAndPickUp()
        sleep(500)
        MoveTo(5719,-9867)
        KillMobs()
		CheckAndPickUp()
        sleep(500)
        MoveTo(5257,-10771)
        KillMobs()
		CheckAndPickUp()
        sleep(500)
        MoveTo(4793,-11134)
        KillMobs()
		CheckAndPickUp()
        sleep(500)
        MoveTo(4105,-12174)
        KillMobs()
		CheckAndPickUp()
        sleep(500)
        MoveTo(3297,-13148)
        KillMobs()
		CheckAndPickUp()
        sleep(500)
        MoveTo(2641,-13433)
        KillMobs()
		CheckAndPickUp()
        sleep(500)
        MoveTo(2670,-14285)
        KillMobs()
		CheckAndPickUp()
        sleep(500)
        MoveTo(3094,-14574)
        MoveTo(3599,-14336)
        KillMobs()
		CheckAndPickUp()
        sleep(500)

        logFile("Cave cleaned.")

	ElseIf ($FarmID == 5) Then ;Go to Worm field and kill from Ashford Abbey
        logFile("Moving to Worm's field.")
		MoveTo(-10030,-4951)

        logFile("Arrived at the field.")
        RndSleep(1000)

		logFile("Killing Worms.")
		CheckAndUseStone()
        sleep(2000)

        KillMobs($FarmID)
        sleep(5000)
        KillMobs($FarmID)
        sleep(5000)
		CheckAndPickUp()
		sleep(500)
        MoveTo(-9679,-3517)
        KillMobs($FarmID)
        sleep(5000)
        KillMobs($FarmID)
        sleep(5000)
		CheckAndPickUp()
        sleep(500)
        MoveTo(-9762,-1527)
        KillMobs($FarmID)
        sleep(5000)
        KillMobs($FarmID)
        sleep(5000)
		CheckAndPickUp()
        sleep(500)

        logFile("Field cleaned.")

    ElseIf ($FarmID == 6) Then ;Go to Charrs and kill from Ascalon city (Charr carvings)
        $MapID = GetMapID()
        $CharrCheckPoint = 0

        logFile("Moving to the charr's door.")
        MoveTo(4479,5628)
        MoveTo(3055,6573)
        MoveTo(479,6772)
        MoveTo(-1226,8742)
        MoveTo(-2196,10619)
        MoveTo(-3244,12300)
        MoveTo(-4480,12730)
        MoveTo(-5508,12787)
        sleep(500)
        LeverOpenDoor()
        sleep(100)
        MoveTo(-5292,12794)
        MoveTo(-4410,12583)
        MoveTo(-3675,12331)
        MoveTo(-3291,12161)
        MoveTo(-3430,11621)
        MoveTo(-3457,11514)
        MoveTo(-4963,11815)
        MoveTo(-5324,11838)
        MoveTo(-5362,12112)
        If GetIsDead(-2) Then Return
        ;MoveToXYZ(-5388,12571,-601)
        logFile("Passing charr's portal.")
        ;MoveXYZ(-5553,13813,-602)
        Move(-5700,14200)

        WaitMapLoading(147)
        $MapID = GetMapID()
        If ($MapID == 147) Then
            logFile("Arrived at charr's map.")
        ElseIf ($MapID == 146) Then
            sleep(5000)
            $MapID = GetMapID()
            If ($MapID == 147) Then
                logFile("Arrived at charr's map.")
            ElseIf ($MapID == 146) Then
                $i = 0
                Do
                    $i += 1
                    logFile("Did not succeed to pass portal : Re-trying.")
                    logFile("Re-try : " & $i)
                    MoveTo(-5515,12489)
                    MoveTo(-5485,11858)
                    MoveTo(-3696,11319)
                    MoveTo(-2948,11454)
                    MoveTo(-3333,12306)
                    MoveTo(-4326,12509)
                    MoveTo(-5465,12791)
                    sleep(500)
                    LeverOpenDoor()
                    sleep(100)
                    MoveTo(-5292,12794)
                    MoveTo(-4410,12583)
                    MoveTo(-3675,12331)
                    MoveTo(-3291,12161)
                    MoveTo(-3430,11621)
                    MoveTo(-3457,11514)
                    MoveTo(-4963,11815)
                    MoveTo(-5324,11838)
                    MoveTo(-5362,12112)
                    If GetIsDead(-2) Then Return
                    ;MoveToXYZ(-5388,12571,-601)
                    logFile("Passing charr's portal.")
                    ;MoveXYZ(-5553,13813,-602)
                    Move(-5700,14200)

                    WaitMapLoading(147)
                    sleep(5000)
                    $MapID = GetMapID()
                Until $MapID == 147
                logFile("Arrived at charr's map.")
            EndIf
        EndIf

        If GetIsDead(-2) Then Return
        $CharrCheckPoint = 1

        logFile("Moving to the first Oakhearts' group.")
        CheckStuck_MoveTo(-12232,-14221)
        CheckStuck_MoveTo(-12953,-12465)
        CheckStuck_MoveTo(-13666,-11333)
        CheckStuck_MoveTo(-13015,-9810)
        logFile("Arrived at the first Oakhearts' group.")
        RndSleep(1000)
        CheckAndUseStone()
        sleep(500)
        logFile("Killing Oakhearts.")
        KillMobs()
        CheckAndPickUp()
        If GetIsDead(-2) Then
            GoBackToCheckpoint($CharrCheckPoint)
        EndIf
        CheckStuck_MoveTo(-13015,-9810)
        $CharrCheckPoint = 2
        sleep(500)

        logFile("Moving to the second Oakhearts' group.")
        CheckStuck_MoveTo(-12504,-8509)
        logFile("Arrived at the second Oakhearts' group.")
        CheckAndUseStone()
        sleep(500)
        logFile("Killing Oakhearts.")
        KillMobs()
        CheckAndPickUp()
        If GetIsDead(-2) Then
            GoBackToCheckpoint($CharrCheckPoint)
        EndIf
        CheckStuck_MoveTo(-12504,-8509)
        $CharrCheckPoint = 3
        sleep(500)

        logFile("Moving to the first charrs' group.")
        CheckStuck_MoveTo(-10480,-6856)
        CheckStuck_MoveTo(-10419,-6376)
        logFile("Arrived at the first charrs' group.")
        CheckAndUseStone()
        sleep(500)
        PullMobs()
        logFile("Killing Charrs.")
        KillMobs()
        CheckAndPickUp()
        If GetIsDead(-2) Then
            GoBackToCheckpoint($CharrCheckPoint)
        EndIf
        CheckStuck_MoveTo(-10419,-6376)
        $CharrCheckPoint = 4
        sleep(500)

        logFile("Moving to the second charrs' group.")
        CheckStuck_MoveTo(-8435,-4969)
        logFile("Arrived at the second charrs' group.")
        CheckAndUseStone()
        sleep(500)
        PullMobs()
        logFile("Killing Charrs.")
        KillMobs()
        CheckAndPickUp()
        If GetIsDead(-2) Then
            GoBackToCheckpoint($CharrCheckPoint)
        EndIf
        CheckStuck_MoveTo(-8435,-4969)
        $CharrCheckPoint = 5
        sleep(500)

        logFile("Charrs Cleaned.")
        $CharrCheckPoint = 0

    ElseIf ($FarmID == 7) Then ;Go to Earth elementaries from Barradin
        logFile("Moving to Earth elemental.")
        MoveTo(-7909,1435)
        MoveTo(-7908,-152)
        MoveTo(-6578,-188)
        MoveTo(-4049,0)
        MoveTo(-2216,216)
        MoveTo(-1507,298)
        MoveTo(556,234)
        MoveTo(2537,-689)
        MoveTo(4026,-2278)
        MoveTo(4889,-3148)
        MoveTo(6823,-4058)
        MoveTo(7577,-3066)
        If GetIsDead(-2) Then Return
        logFile("Arrived at the elementals.")
        RndSleep(1000)
		CheckAndUseStone()
        sleep(2000)

        logFile("Killing Elementals.")
        KillMobs()
		CheckAndPickUp()
		sleep(500)
        MoveTo(9976,-2969)
        MoveTo(11554,-1361)
        MoveTo(11747,-439)
		If GetIsDead(-2) Then Return
        KillMobs()
		CheckAndPickUp()
        sleep(500)
        MoveTo(10205,987)
        KillMobs()
		CheckAndPickUp()
        sleep(500)
        MoveTo(9435,870)
		If GetIsDead(-2) Then Return
        KillMobs()
		CheckAndPickUp()
        sleep(500)

        logFile("Elementals cleaned.")

    ElseIf ($FarmID == 8) Then ;Go to gargoyle catacomb from Barradin
        $MapID = GetMapID()
        logFile("Moving to Catacombs.")
        MoveTo(-7909,1435)
        MoveTo(-7902,2500)
        MoveTo(-5380,5383)
        MoveTo(-5274,6741)
        MoveTo(-5371,8261)
        MoveTo(-4217,8287)
        MoveTo(-3400,9061)
		If GetIsDead(-2) Then Return
        logFile("Entering Catacombs")
        Move(-3150,9350)
        WaitMapLoading(145)

        $MapID = GetMapID()
        If ($MapID <> 145) Then
            sleep(5000)
            $MapID = GetMapID()
            If ($MapID <> 145) Then
                If $BotRunning Then
                    logFile("Can't go to Catacombs.")
                    logFile("Restarting run.")
                    InitializeFarm($FarmID)
                EndIf
            EndIf
        EndIf

        logFile("Arrived in the Catacombs")
        logFile("Moving to mergoyls.")
        MoveTo(-9263,15370)
        MoveTo(-7823,15116)
        MoveTo(-6751,15812)
		If GetIsDead(-2) Then Return

        logFile("Arrived at the mergoyls.")
        RndSleep(1000)
		CheckAndUseStone()
        sleep(2000)

        logFile("Killing mergoyls.")
        KillMobs()
		CheckAndPickUp()
		sleep(500)

        logFile("Mergoyls cleaned.")

    ElseIf ($FarmID == 9) Then ;Go to Grawls from Fort Ranik
        logFile("Moving to grawls.")
        MoveTo(22579,6122)
        MoveTo(22472,5292)
        MoveTo(22523,4150)
        MoveTo(20513,2431)
        MoveTo(19772,1959)
        MoveTo(19503,1128)
        MoveTo(17539,178)
        MoveTo(16864,-75)
        MoveTo(14143,-1771)
        MoveTo(13824,-790)
        MoveTo(13734,-26)
        MoveTo(13265,-447)
        MoveTo(13050,-1657)
        MoveTo(12003,-2512)
        MoveTo(11564,-4662)
        MoveTo(11120,-5113)
        MoveTo(11941,-6631)
        MoveTo(11613,-7449)
        MoveTo(11846,-7790)
        MoveTo(11012,-8273)
        MoveTo(10026,-9740)
        MoveTo(9239,-9718)
        MoveTo(6831,-9436)
        MoveTo(5365,-9789)
        MoveTo(4186,-9077)
        MoveTo(1264,-7615)
        MoveTo(24,-6622)

        If GetIsDead(-2) Then Return
        logFile("Arrived at the grawls.")
        RndSleep(1000)
		CheckAndUseStone()
        sleep(2000)
        logFile("Killing grawls.")
        KillMobs()
		CheckAndPickUp()
		sleep(500)

        logFile("Moving at the next grawls.")
        MoveTo(-191,-7071)
        MoveTo(-2149,-7133)
        MoveTo(-3484,-8362)
        If GetIsDead(-2) Then Return
        logFile("Arrived at the grawls.")
        logFile("Killing grawls.")
        RndSleep(1000)
		CheckAndUseStone()
        sleep(2000)
        KillMobs()
		CheckAndPickUp()
		sleep(500)

        logFile("Moving at the next grawls.")
        MoveTo(-6079,-8080)
        If GetIsDead(-2) Then Return
        logFile("Arrived at the grawls.")
        logFile("Killing grawls.")
        RndSleep(1000)
		CheckAndUseStone()
        sleep(2000)
        KillMobs()
		CheckAndPickUp()
		sleep(500)

        logFile("Grawls cleaned.")

    ElseIf ($FarmID == 10) Then ;Go to Ice elementaries from Foible's Fair
        logFile("Moving to Icy elemental.")
        MoveTo(938,5734)
        MoveTo(1301,5194)
        MoveTo(2596,4513)
        MoveTo(2871,3067)
        MoveTo(2002,2370)
        MoveTo(879,2093)
        MoveTo(-520,3475)
        MoveTo(-1709,4431)
        If GetIsDead(-2) Then Return
        logFile("Arrived at the elementals.")
        RndSleep(1000)
		CheckAndUseStone()
        sleep(2000)

        logFile("Killing Elementals.")
        KillMobs($FarmID)
		CheckAndPickUp()
		sleep(500)
        logFile("Moving at the next elementals.")
        MoveTo(-3158,4957)
        MoveTo(-3954,3677)
        MoveTo(-3722,2546)
        MoveTo(-5463,1429)
        MoveTo(-5897,-586)
        MoveTo(-6197,-1384)
        MoveTo(-6001,-2559)
		If GetIsDead(-2) Then Return
        logFile("Arrived at the elementals.")
        logFile("Killing Elementals.")
        KillMobs($FarmID)
		CheckAndPickUp()
        sleep(500)
        logFile("Moving at the next elementals.")
        MoveTo(-5804,-3647)
        MoveTo(-5828,-4161)
		If GetIsDead(-2) Then Return
        logFile("Arrived at the elementals.")
        logFile("Killing Elementals.")
        KillMobs($FarmID)
		CheckAndPickUp()
        sleep(500)
        logFile("Moving at the next elementals.")
        MoveTo(-5772,-5056)
        MoveTo(-4620,-5856)
		If GetIsDead(-2) Then Return
        logFile("Arrived at the elementals.")
        logFile("Killing Elementals.")
        KillMobs($FarmID)
		CheckAndPickUp()
        sleep(500)
        logFile("Moving at the next elementals.")
        MoveTo(-3977,-7038)
        MoveTo(-4008,-8054)
		If GetIsDead(-2) Then Return
        logFile("Arrived at the elementals.")
        logFile("Killing Elementals.")
        KillMobs($FarmID)
		CheckAndPickUp()
        sleep(500)

        logFile("Elementals cleaned.")

    ElseIf ($FarmID == 12) Then ;Go to Skale and kill from Fort Ranik
        logFile("Moving to Skale.")
        MoveTo(22521,5398)
        MoveTo(22351,4028)
        MoveTo(20751,2283)
        If GetIsDead(-2) Then Return
        logFile("Arrived at the skales.")
        RndSleep(1000)
		CheckAndUseStone()
        sleep(2000)

        logFile("Killing skales.")
        KillMobs()
		CheckAndPickUp()
		sleep(500)
        logFile("Moving at the next skales.")
        MoveTo(19130,2041)
        logFile("Arrived at the skales.")
        logFile("Killing skales.")
        KillMobs()
		CheckAndPickUp()
        sleep(500)
        logFile("Moving at the next skales.")
        MoveTo(17801,2303)
        logFile("Arrived at the skales.")
        logFile("Killing skales.")
        KillMobs()
		CheckAndPickUp()
        sleep(500)
        logFile("Moving at the next skales.")
        MoveTo(16197,2764)
        MoveTo(16240,3391)
		If GetIsDead(-2) Then Return
        logFile("Arrived at the skales.")
        logFile("Killing skales.")
        KillMobs()
		CheckAndPickUp()
        sleep(500)

        logFile("Skale cleaned.")

    ElseIf ($FarmID == 13) Then ;Go to Skeleton (catacombs) and kill from Ashford Abbey
        logFile("Moving to Skeletons.")
        MoveTo(13934,1797)
        MoveTo(13874,919)
        MoveTo(13762,428)
        MoveTo(13818,-428)
        MoveTo(12848,-383)
        MoveTo(11539,-482)
        MoveTo(10920,-389)
        If GetIsDead(-2) Then Return
        logFile("Arrived at the skeletons.")
        RndSleep(1000)
		CheckAndUseStone()
        sleep(2000)

        logFile("Killing skeletons.")
        KillMobs()
		CheckAndPickUp()
		sleep(500)
        logFile("Moving at the next skeletons.")
        MoveTo(10125,663)
        MoveTo(9510,1109)
		If GetIsDead(-2) Then Return
        logFile("Arrived at the skeletons.")
        logFile("Killing skeletons.")
        KillMobs()
		CheckAndPickUp()
        sleep(500)
        logFile("Moving at the next skeletons.")
        MoveTo(8178,1230)
        MoveTo(7552,810)
		If GetIsDead(-2) Then Return
        logFile("Arrived at the skeletons.")
        logFile("Killing skeletons.")
        KillMobs()
		CheckAndPickUp()
        sleep(500)
        logFile("Moving at the next skeletons.")
        MoveTo(7000,288)
        MoveTo(6139,-66)
		If GetIsDead(-2) Then Return
        logFile("Arrived at the skeletons.")
        logFile("Killing skeletons.")
        KillMobs()
		CheckAndPickUp()
        sleep(500)
        logFile("Moving at the next skeletons.")
        MoveTo(5010,-556)
        MoveTo(4353,-904)
		If GetIsDead(-2) Then Return
        logFile("Arrived at the skeletons.")
        logFile("Killing skeletons.")
        KillMobs()
		CheckAndPickUp()
        sleep(500)
        logFile("Moving at the next skeletons.")
        MoveTo(3383,-1300)
        MoveTo(1694,-2004)
		If GetIsDead(-2) Then Return
        logFile("Arrived at the skeletons.")
        logFile("Killing skeletons.")
        KillMobs()
		CheckAndPickUp()
        sleep(500)

        logFile("Skeletons cleaned.")

    ElseIf ($FarmID == 14) Then ;Go to Spiders and kill from Fort Ranik
        logFile("Moving to Spiders.")
        MoveTo(22521,5398)
        MoveTo(22351,4028)
        MoveTo(20751,2283)
        MoveTo(19391,1905)
        MoveTo(18816,-31)
        MoveTo(18340,-1151)
        If GetIsDead(-2) Then Return
        logFile("Arrived at the spiders.")
        RndSleep(3000)
		CheckAndUseStone()
        sleep(2000)

        logFile("Killing spiders.")
        KillMobs($FarmID)
		CheckAndPickUp()
		sleep(500)
        logFile("Moving at the next spiders.")
        MoveTo(18420,-2805)
        logFile("Arrived at the spiders.")
		RndSleep(5000)
        logFile("Killing spiders.")
        KillMobs($FarmID)
		CheckAndPickUp()
        sleep(500)
        logFile("Moving at the next spiders.")
        MoveTo(19295,-4309)
        MoveTo(20355,-6010)
		If GetIsDead(-2) Then Return
        logFile("Arrived at the spiders.")
		RndSleep(5000)
        logFile("Killing spiders.")
        KillMobs($FarmID)
		CheckAndPickUp()
        sleep(500)
        logFile("Moving at the next spiders.")
        MoveTo(20671,-7352)
        MoveTo(20657,-7703)
		If GetIsDead(-2) Then Return
        logFile("Arrived at the spiders.")
		RndSleep(5000)
        logFile("Killing spiders.")
        KillMobs($FarmID)
		CheckAndPickUp()
        sleep(500)
        logFile("Moving at the next spiders.")
        MoveTo(21828,-7137)
        logFile("Arrived at the spiders.")
		RndSleep(5000)
        logFile("Killing spiders.")
        KillMobs($FarmID)
		CheckAndPickUp()
        sleep(500)

        logFile("Spiders cleaned.")

    ElseIf ($FarmID == 15) Then ;Go to Aloes and kill from Fort Ranik
		logFile("Moving to Aloes.")
        MoveTo(22579,6122)
        MoveTo(22472,5292)
        MoveTo(22523,4150)
        MoveTo(20513,2431)
        MoveTo(19772,1959)
        MoveTo(19503,1128)
        MoveTo(18900,-737)
        MoveTo(18302,-3357)
        MoveTo(17343,-3728)
        MoveTo(16414,-4787)
        MoveTo(16044,-5874)
        MoveTo(15698,-6373)
        MoveTo(15606,-8401)
        MoveTo(16167,-9180)
        MoveTo(17134,-10548)
        MoveTo(17319,-11359)
        MoveTo(18223,-11946)

        If GetIsDead(-2) Then Return
        logFile("Arrived at the aloes.")
        RndSleep(1000)
		CheckAndUseStone()
        sleep(2000)
        logFile("Killing aloes.")
        KillMobs($FarmID)
		CheckAndPickUp()
		sleep(500)

        logFile("Moving at the next aloes.")
        MoveTo(19906,-12424)
        logFile("Arrived at the aloes.")
        logFile("Killing aloes.")
        KillMobs($FarmID)
		CheckAndPickUp()
        sleep(500)

        logFile("Moving at the next aloes.")
        MoveTo(20527,-11507)
        MoveTo(21759,-11598)
        MoveTo(21722,-12145)
        logFile("Arrived at the aloes.")
        logFile("Killing aloes.")
        KillMobs($FarmID)
		CheckAndPickUp()
        sleep(500)

        logFile("Aloes cleaned.")
	ElseIf ($FarmID == 18) Then ;Go to Charrs boss and kill from Ascalon City
		$MapID = GetMapID()
        $CharrCheckPoint = 0

        logFile("Moving to the charr's door.")
        MoveTo(4479,5628)
        MoveTo(3055,6573)
        MoveTo(479,6772)
        MoveTo(-1226,8742)
        MoveTo(-2196,10619)
        MoveTo(-3244,12300)
        MoveTo(-4480,12730)
        MoveTo(-5508,12787)
        sleep(500)
        LeverOpenDoor()
        sleep(100)
        MoveTo(-5292,12794)
        MoveTo(-4410,12583)
        MoveTo(-3675,12331)
        MoveTo(-3291,12161)
        MoveTo(-3430,11621)
        MoveTo(-3457,11514)
        MoveTo(-4963,11815)
        MoveTo(-5324,11838)
        MoveTo(-5362,12112)
        If GetIsDead(-2) Then Return
        ;MoveToXYZ(-5388,12571,-601)
        logFile("Passing charr's portal.")
        ;MoveXYZ(-5553,13813,-602)
        Move(-5700,14200)

        WaitMapLoading(147)
        $MapID = GetMapID()
        If ($MapID == 147) Then
            logFile("Arrived at charr's map.")
        ElseIf ($MapID == 146) Then
            sleep(5000)
            $MapID = GetMapID()
            If ($MapID == 147) Then
                logFile("Arrived at charr's map.")
            ElseIf ($MapID == 146) Then
                $i = 0
                Do
                    $i += 1
                    logFile("Did not succeed to pass portal : Re-trying.")
                    logFile("Re-try : " & $i)
                    MoveTo(-5515,12489)
                    MoveTo(-5485,11858)
                    MoveTo(-3696,11319)
                    MoveTo(-2948,11454)
                    MoveTo(-3333,12306)
                    MoveTo(-4326,12509)
                    MoveTo(-5465,12791)
                    sleep(500)
                    LeverOpenDoor()
                    sleep(100)
                    MoveTo(-5292,12794)
                    MoveTo(-4410,12583)
                    MoveTo(-3675,12331)
                    MoveTo(-3291,12161)
                    MoveTo(-3430,11621)
                    MoveTo(-3457,11514)
                    MoveTo(-4963,11815)
                    MoveTo(-5324,11838)
                    MoveTo(-5362,12112)
                    If GetIsDead(-2) Then Return
                    ;MoveToXYZ(-5388,12571,-601)
                    logFile("Passing charr's portal.")
                    ;MoveXYZ(-5553,13813,-602)
                    Move(-5700,14200)

                    WaitMapLoading(147)
                    sleep(5000)
                    $MapID = GetMapID()
                Until $MapID == 147
                logFile("Arrived at charr's map.")
            EndIf
        EndIf

         If GetIsDead(-2) Then Return
        $CharrCheckPoint = 1

        logFile("Moving to the first Oakhearts' group.")
        CheckStuck_MoveTo(-12232,-14221)
        CheckStuck_MoveTo(-12953,-12465)
        CheckStuck_MoveTo(-13666,-11333)
        CheckStuck_MoveTo(-13015,-9810)
        logFile("Arrived at the first Oakhearts' group.")
        RndSleep(1000)
        CheckAndUseStone()
        sleep(500)
        logFile("Killing Oakhearts.")
        KillMobs()
        CheckAndPickUp()
        If GetIsDead(-2) Then
            GoBackToCheckpoint($CharrCheckPoint)
        EndIf
        CheckStuck_MoveTo(-13015,-9810)
        $CharrCheckPoint = 2
        sleep(500)

        logFile("Moving to the second Oakhearts' group.")
        CheckStuck_MoveTo(-12504,-8509)
        logFile("Arrived at the second Oakhearts' group.")
        CheckAndUseStone()
        sleep(500)
        logFile("Killing Oakhearts.")
        KillMobs()
        CheckAndPickUp()
        If GetIsDead(-2) Then
            GoBackToCheckpoint($CharrCheckPoint)
        EndIf
        CheckStuck_MoveTo(-12504,-8509)
        $CharrCheckPoint = 3
        sleep(500)

        logFile("Moving to the first charrs' group.")
        CheckStuck_MoveTo(-10480,-6856)
        CheckStuck_MoveTo(-10419,-6376)
        logFile("Arrived at the first charrs' group.")
        CheckAndUseStone()
        sleep(500)
        PullMobs()
        logFile("Killing Charrs.")
        KillMobs()
        CheckAndPickUp()
        If GetIsDead(-2) Then
            GoBackToCheckpoint($CharrCheckPoint)
        EndIf
        CheckStuck_MoveTo(-10419,-6376)
        $CharrCheckPoint = 4
        sleep(500)

        logFile("Moving to the second charrs' group.")
        CheckStuck_MoveTo(-8435,-4969)
        logFile("Arrived at the second charrs' group.")
        CheckAndUseStone()
        sleep(500)
        PullMobs()
        logFile("Killing Charrs.")
        KillMobs()
		CheckAndPickUp()
        If GetIsDead(-2) Then
            GoBackToCheckpoint($CharrCheckPoint)
        EndIf
        CheckStuck_MoveTo(-8435,-4969)
        $CharrCheckPoint = 5
        sleep(500)

        logFile("Moving to the third charrs' group.")
        CheckStuck_MoveTo(-5352,-4809)
        CheckStuck_MoveTo(-3123,-4386)
        logFile("Arrived at the third charrs' group.")
        CheckAndUseStone()
        sleep(500)
        PullMobs()
        logFile("Killing Charrs.")
        KillMobs()
		CheckAndPickUp()
        If GetIsDead(-2) Then
            GoBackToCheckpoint($CharrCheckPoint)
        EndIf
        CheckStuck_MoveTo(-3123,-4386)
        $CharrCheckPoint = 6
        sleep(500)

        logFile("Moving to the fourth charrs' group.")
        CheckStuck_MoveTo(-2148,-3649)
        logFile("Arrived at the fourth charrs' group.")
        CheckAndUseStone()
        sleep(500)
        PullMobs()
        logFile("Killing Charrs.")
        KillMobs()
        If GetIsDead(-2) Then
            GoBackToCheckpoint($CharrCheckPoint)
        EndIf
        CheckStuck_MoveTo(-2148,-3649)
        $CharrCheckPoint = 7
        sleep(500)

        logFile("Moving to the fifth charrs' group.")
        CheckStuck_MoveTo(-791,-3761)
        CheckStuck_MoveTo(234,-4893)
        CheckStuck_MoveTo(332,-5496)
        logFile("Arrived at the fifth charrs' group.")
        CheckAndUseStone()
        sleep(500)
        PullMobs()
        logFile("Killing Charrs.")
        KillMobs()
        If GetIsDead(-2) Then
            GoBackToCheckpoint($CharrCheckPoint)
        EndIf
        CheckStuck_MoveTo(332,-5496)
        $CharrCheckPoint = 8
        sleep(500)

        logFile("Moving to the sixth charrs' group.")
        CheckStuck_MoveTo(568,-4305) ;Pull
        CheckStuck_MoveTo(441,-4941) ;Go back
        logFile("Arrived at the sixth charrs' group.")
        CheckAndUseStone()
        sleep(500)
        PullMobs()
        logFile("Killing Charrs.")
        KillMobs()
        If GetIsDead(-2) Then
            GoBackToCheckpoint($CharrCheckPoint)
        EndIf
        CheckStuck_MoveTo(568,-4305)
        $CharrCheckPoint = 9
        sleep(500)

        logFile("Moving to the seventh charrs' group.")
        CheckStuck_MoveTo(0,-3436)
        CheckStuck_MoveTo(33,-2740)
        logFile("Arrived at the seventh charrs' group.")
        CheckAndUseStone()
        sleep(500)
        PullMobs()
        logFile("Killing Charrs.")
        KillMobs()
        If GetIsDead(-2) Then
            GoBackToCheckpoint($CharrCheckPoint)
        EndIf
        CheckStuck_MoveTo(33,-2740)
        $CharrCheckPoint = 10
        sleep(500)

        logFile("Moving to the eighth charrs' group.")
        CheckStuck_MoveTo(512,-2724) ;Pull
        CheckStuck_MoveTo(-179,-2748) ;Go Back
        logFile("Arrived at the eighth charrs' group.")
        CheckAndUseStone()
        sleep(500)
        PullMobs()
        logFile("Killing Charrs.")
        KillMobs()
        If GetIsDead(-2) Then
            GoBackToCheckpoint($CharrCheckPoint)
        EndIf
        CheckStuck_MoveTo(512,-2724)
        $CharrCheckPoint = 11
        sleep(500)

        logFile("Moving to the ninth charrs' group.")
        CheckStuck_MoveTo(719,-3126) ;Pull Boss
        CheckStuck_MoveTo(207,-3293) ;go Back
        logFile("Arrived at the ninth charrs' group.")
        CheckAndUseStone()
        sleep(500)
        PullMobs()
        logFile("Killing Charrs.")
        KillMobs()
        If GetIsDead(-2) Then
            GoBackToCheckpoint($CharrCheckPoint)
        EndIf
        CheckStuck_MoveTo(719,-3126)
        $CharrCheckPoint = 12
        sleep(500)

        logFile("Moving to the tenth charrs' group.")
        CheckStuck_MoveTo(719,-3126) ;Pull Boss
        CheckStuck_MoveTo(207,-3293) ;go Back
        logFile("Arrived at the tenth charrs' group.")
        CheckAndUseStone()
        sleep(500)
        PullMobs()
        logFile("Killing Charrs.")
        KillMobs()
        If GetIsDead(-2) Then
            GoBackToCheckpoint($CharrCheckPoint)
        EndIf
        CheckStuck_MoveTo(719,-3126)
        $CharrCheckPoint = 13
        sleep(500)

        logFile("Moving to the eleventh charrs' group.")
        CheckStuck_MoveTo(944,-2564)
        CheckStuck_MoveTo(1576,-2494)
        logFile("Arrived at the eleventh charrs' group.")
        CheckAndUseStone()
        sleep(500)
        PullMobs()
        logFile("Killing Charrs.")
        KillMobs()
        If GetIsDead(-2) Then
            GoBackToCheckpoint($CharrCheckPoint)
        EndIf
        CheckStuck_MoveTo(1576,-2494)
        $CharrCheckPoint = 14
        sleep(500)

        logFile("Moving to the twelfth charrs' group.")
        CheckStuck_MoveTo(1879,-2498)
        CheckStuck_MoveTo(2248,-3332) ;Pull
        CheckStuck_MoveTo(2125, -3151) ;Go Back
        logFile("Arrived at the twelfth charrs' group.")
        CheckAndUseStone()
        sleep(500)
        PullMobs()
        logFile("Killing Charrs.")
        KillMobs()
        CheckAndPickUp()
        If GetIsDead(-2) Then
            GoBackToCheckpoint($CharrCheckPoint)
        EndIf
        CheckStuck_MoveTo(2248,-3332)
        sleep(500)
        CheckAndPickUp()
        sleep(1000)

        logFile("Charrs Cleaned.")
        $CharrCheckPoint = 0
	EndIf
EndFunc

Func MergoylsFarm() ;Mergoyl farm to use after InitializeFarm(8), it makes player just zone out of catacombs and re-enter insteed of teleporting to town
        Local $MapID

        ;Going out of the Catacombs
        $MapID = GetMapID()
        If GetIsDead(-2) Then Return
        MoveTo(-6751,15812)
        MoveTo(-7823,15116)
        MoveTo(-9263,15370)
        MoveTo(-10413,15750)
        Move(-11200,16200)

        WaitMapLoading(160)
        $MapID = GetMapID()
        If ($MapID <> 160) Then
            sleep(5000)
            $MapID = GetMapID()
            If ($MapID <> 160) Then
                If $BotRunning Then
                    logFile("Can't go out of Catacombs.")
                    logFile("Restarting run.")
                    InitializeFarm(8)
                EndIf
            EndIf
        EndIf

        ;Re-entering the Catacombs' portal
        logFile("Entering Catacombs")
        Move(-3150,9350)

        WaitMapLoading(145)
        $MapID = GetMapID()
        If ($MapID <> 145) Then
            sleep(5000)
            $MapID = GetMapID()
            If ($MapID <> 145) Then
                If $BotRunning Then
                    logFile("Can't go to Catacombs.")
                    logFile("Restarting run.")
                    InitializeFarm(8)
                EndIf
            EndIf
        EndIf

        logFile("Arrived in the Catacombs")
        logFile("Moving to mergoyls.")
        MoveTo(-9263,15370)
        MoveTo(-7823,15116)
        MoveTo(-6751,15812)
		If GetIsDead(-2) Then Return

        logFile("Arrived at the mergoyls.")
        RndSleep(1000)
		CheckAndUseStone()
        sleep(2000)

        logFile("Killing mergoyls.")
        KillMobs()
		CheckAndPickUp()
		sleep(500)

        logFile("Mergoyls cleaned.")
EndFunc

Func CharrsCarvingFarm() ;Charr farm to use after InitializeFarm(6), it makes player just zone out of Charrs' map and re-enter insteed of teleporting back to town
	Local $MapID
	$CharrCheckPoint = 0

	$MapID = GetMapID()

	CheckStuck_MoveTo(-8435,-4969)
	CheckStuck_MoveTo(-10419,-6376)
	CheckStuck_MoveTo(-10480,-6856)
	CheckStuck_MoveTo(-12504,-8509)
	CheckStuck_MoveTo(-13015,-9810)
	CheckStuck_MoveTo(-13666,-11333)
	CheckStuck_MoveTo(-12953,-12465)
    CheckStuck_MoveTo(-12232,-14221)
    CheckStuck_MoveTo(-11795,-15572)
    ;MoveXYZ(-11659,-16916,-620)  ;Portal's coords (form into charr's map)
    ;MoveXYZ(-11650,-17500,-610)
    Move(-11650,-17500)

	WaitMapLoading(146)
    $MapID = GetMapID()
    If ($MapID <> 146) Then
        sleep(5000)
        $MapID = GetMapID()
        If ($MapID <> 146) Then
            If $BotRunning Then
                logFile("Can't go out of the Charr's map.")
                logFile("Restarting run.")
                InitializeFarm(6)
            EndIf
        EndIf
    EndIf

    logFile("Re-entering Charr's portal.")

    MoveTo(-5515,12489)
    MoveTo(-5485,11858)
    MoveTo(-3696,11319)
    MoveTo(-2948,11454)
    MoveTo(-3333,12306)
    MoveTo(-4326,12509)
    MoveTo(-5465,12791)
    sleep(500)
    LeverOpenDoor()
    sleep(100)
    MoveTo(-5292,12794)
    MoveTo(-4410,12583)
    MoveTo(-3675,12331)
    MoveTo(-3291,12161)
    MoveTo(-3430,11621)
    MoveTo(-3457,11514)
    MoveTo(-4963,11815)
    MoveTo(-5324,11838)
    MoveTo(-5362,12112)
    If GetIsDead(-2) Then Return
    ;MoveToXYZ(-5388,12571,-601)
    logFile("Passing charr's portal.")
    ;MoveXYZ(-5553,13813,-602)
    Move(-5700,14200)

    WaitMapLoading(147)
    $MapID = GetMapID()
    If ($MapID == 147) Then
        logFile("Arrived at Charr's map.")
    ElseIf ($MapID == 146) Then
        sleep(5000)
        $MapID = GetMapID()
        If ($MapID == 147) Then
            logFile("Arrived at Charr's map.")
        ElseIf ($MapID == 146) Then
            $i = 0
            Do
                $i += 1
                logFile("Did not succeed to pass portal : Re-trying.")
                logFile("Re-try : " & $i)
                MoveTo(-5515,12489)
                MoveTo(-5485,11858)
                MoveTo(-3696,11319)
                MoveTo(-2948,11454)
                MoveTo(-3333,12306)
                MoveTo(-4326,12509)
                MoveTo(-5465,12791)
                sleep(500)
                LeverOpenDoor()
                sleep(100)
                MoveTo(-5292,12794)
                MoveTo(-4410,12583)
                MoveTo(-3675,12331)
                MoveTo(-3291,12161)
                MoveTo(-3430,11621)
                MoveTo(-3457,11514)
                MoveTo(-4963,11815)
                MoveTo(-5324,11838)
                MoveTo(-5362,12112)
                If GetIsDead(-2) Then Return
                ;MoveToXYZ(-5388,12571,-601)
                logFile("Passing charr's portal.")
                ;MoveXYZ(-5553,13813,-602)
                Move(-5700,14200)

                WaitMapLoading(147)
                sleep(5000)
                $MapID = GetMapID()
            Until $MapID == 147
            logFile("Arrived at Charr's map.")
        EndIf
    EndIf

	$CharrCheckPoint = 0

    If GetIsDead(-2) Then Return
    $CharrCheckPoint = 1

    logFile("Moving to the first Oakhearts' group.")
    CheckStuck_MoveTo(-12232,-14221)
    CheckStuck_MoveTo(-12953,-12465)
    CheckStuck_MoveTo(-13666,-11333)
    CheckStuck_MoveTo(-13015,-9810)
    logFile("Arrived at the first Oakhearts' group.")
    RndSleep(1000)
    CheckAndUseStone()
    sleep(500)
    logFile("Killing Oakhearts.")
    KillMobs()
    CheckAndPickUp()
    If GetIsDead(-2) Then
        GoBackToCheckpoint($CharrCheckPoint)
    EndIf
    CheckStuck_MoveTo(-13015,-9810)
    $CharrCheckPoint = 2
    sleep(500)

    logFile("Moving to the second Oakhearts' group.")
    CheckStuck_MoveTo(-12504,-8509)
    logFile("Arrived at the second Oakhearts' group.")
    CheckAndUseStone()
    sleep(500)
    logFile("Killing Oakhearts.")
    KillMobs()
    CheckAndPickUp()
    If GetIsDead(-2) Then
        GoBackToCheckpoint($CharrCheckPoint)
    EndIf
    CheckStuck_MoveTo(-12504,-8509)
    $CharrCheckPoint = 3
    sleep(500)

    logFile("Moving to the first charrs' group.")
    CheckStuck_MoveTo(-10480,-6856)
    CheckStuck_MoveTo(-10419,-6376)
    logFile("Arrived at the first charrs' group.")
    CheckAndUseStone()
    sleep(500)
    logFile("Killing Charrs.")
    KillMobs()
    CheckAndPickUp()
    If GetIsDead(-2) Then
        GoBackToCheckpoint($CharrCheckPoint)
    EndIf
    CheckStuck_MoveTo(-10419,-6376)
    $CharrCheckPoint = 4
    sleep(500)

    logFile("Moving to the second charrs' group.")
    CheckStuck_MoveTo(-8435,-4969)
    logFile("Arrived at the second charrs' group.")
    CheckAndUseStone()
    sleep(500)
    logFile("Killing Charrs.")
    KillMobs()
    CheckAndPickUp()
    If GetIsDead(-2) Then
        GoBackToCheckpoint($CharrCheckPoint)
    EndIf
    CheckStuck_MoveTo(-8435,-4969)
    sleep(500)

	logFile("Charrs Cleaned.")
    $CharrCheckPoint = 0
EndFunc

Func GoBackToCheckpoint($CheckpointID) ;Used to make the player go back to checkpoint after death in Charr farm
    If Not $BotRunning Then Return

    WaitAlive()
    If ($CheckpointID >= 1) Then
        If ($CheckpointID == 1) Then logFile("Moving to the first Oakhearts' group.")
        CheckStuck_MoveTo(-11284,-15753)
        CheckStuck_MoveTo(-11746,-15324)
        CheckStuck_MoveTo(-12232,-14221)
        CheckStuck_MoveTo(-12953,-12465)
        CheckStuck_MoveTo(-13666,-11333)
        CheckStuck_MoveTo(-13015,-9810)
        If ($CheckpointID == 1) Then
            logFile("Arrived at the first Oakhearts' group.")
            CheckAndUseStone()
            sleep(500)
            logFile("Killing Oakhearts.")
            KillMobs()
            CheckAndPickUp()
            sleep(500)
        EndIf
        If GetIsDead(-2) Then GoBackToCheckpoint($CheckpointID)
    EndIf
    If ($CheckpointID >= 2) Then
        If ($CheckpointID == 2) Then logFile("Moving to the second Oakhearts' group.")
        CheckStuck_MoveTo(-12504,-8509)
        If ($CheckpointID == 2) Then
            logFile("Arrived at the second Oakhearts' group.")
            CheckAndUseStone()
            sleep(500)
            logFile("Killing Oakhearts.")
            KillMobs()
            CheckAndPickUp()
        EndIf
        If GetIsDead(-2) Then GoBackToCheckpoint($CheckpointID)
    EndIf
    If ($CheckpointID >= 3) Then
        If ($CheckpointID == 3) Then logFile("Moving to the first charrs' group.")
        CheckStuck_MoveTo(-10480,-6856)
        CheckStuck_MoveTo(-10419,-6376)
        If ($CheckpointID == 3) Then
            logFile("Arrived at the first charrs' group.")
            CheckAndUseStone()
            sleep(500)
            PullMobs()
            logFile("Killing Charrs.")
            KillMobs()
            CheckAndPickUp()
        EndIf
        If GetIsDead(-2) Then GoBackToCheckpoint($CheckpointID)
    EndIf
    If ($CheckpointID >= 4) Then
        If ($CheckpointID == 4) Then logFile("Moving to the second charrs' group.")
        CheckStuck_MoveTo(-8435,-4969)
        If ($CheckpointID == 4) Then
            logFile("Arrived at the second charrs' group.")
            CheckAndUseStone()
            sleep(500)
            PullMobs()
            logFile("Killing Charrs.")
            KillMobs()
            CheckAndPickUp()
        EndIf
        If GetIsDead(-2) Then GoBackToCheckpoint($CheckpointID)
    EndIf
    If ($CheckpointID >= 5) Then
        If ($CheckpointID == 5) Then logFile("Moving to the third charrs' group.")
        CheckStuck_MoveTo(-5352,-4809)
        CheckStuck_MoveTo(-3123,-4386)
        If ($CheckpointID == 5) Then
            logFile("Arrived at the third charrs' group.")
            CheckAndUseStone()
            sleep(500)
            PullMobs()
            logFile("Killing Charrs.")
            KillMobs()
            CheckAndPickUp()
        EndIf
        If GetIsDead(-2) Then GoBackToCheckpoint($CheckpointID)
    EndIf
    If ($CheckpointID >= 6) Then
        If ($CheckpointID == 6) Then logFile("Moving to the fourth charrs' group.")
        CheckStuck_MoveTo(-2148,-3649)
        If ($CheckpointID == 6) Then
            logFile("Arrived at the fourth charrs' group.")
            CheckAndUseStone()
            sleep(500)
            PullMobs()
            logFile("Killing Charrs.")
            KillMobs()
            CheckAndPickUp()
        EndIf
        If GetIsDead(-2) Then GoBackToCheckpoint($CheckpointID)
    EndIf
    If ($CheckpointID >= 7) Then
        If ($CheckpointID == 7) Then logFile("Moving to the fifth charrs' group.")
        CheckStuck_MoveTo(-791,-3761)
        CheckStuck_MoveTo(234,-4893)
        If ($CheckpointID == 7) Then
            CheckStuck_MoveTo(332,-5496)
            logFile("Arrived at the fifth charrs' group.")
            CheckAndUseStone()
            sleep(500)
            PullMobs()
            logFile("Killing Charrs.")
            KillMobs()
            CheckAndPickUp()
        EndIf
        If GetIsDead(-2) Then GoBackToCheckpoint($CheckpointID)
    EndIf
    If ($CheckpointID >= 8) Then
        If ($CheckpointID == 8) Then logFile("Moving to the sixth charrs' group.")
        CheckStuck_MoveTo(568,-4305) ;Pull
        If ($CheckpointID == 8) Then
            CheckStuck_MoveTo(441,-4941) ;Go back
            logFile("Arrived at the sixth charrs' group.")
            CheckAndUseStone()
            sleep(500)
            PullMobs()
            logFile("Killing Charrs.")
            KillMobs()
            CheckAndPickUp()
        EndIf
        If GetIsDead(-2) Then GoBackToCheckpoint($CheckpointID)
    EndIf
    If ($CheckpointID >= 9) Then
        If ($CheckpointID == 9) Then logFile("Moving to the seventh charrs' group.")
        CheckStuck_MoveTo(0,-3436)
        CheckStuck_MoveTo(33,-2740)
        If ($CheckpointID == 9) Then
            logFile("Arrived at the seventh charrs' group.")
            CheckAndUseStone()
            sleep(500)
            PullMobs()
            logFile("Killing Charrs.")
            KillMobs()
            CheckAndPickUp()
        EndIf
        If GetIsDead(-2) Then GoBackToCheckpoint($CheckpointID)
    EndIf
    If ($CheckpointID >= 10) Then
        If ($CheckpointID == 10) Then logFile("Moving to the eighth charrs' group.")
        CheckStuck_MoveTo(512,-2724) ;Pull
        CheckStuck_MoveTo(-179,-2748) ;Go Back
        If ($CheckpointID == 10) Then
            logFile("Arrived at the eighth charrs' group.")
            CheckAndUseStone()
            sleep(500)
            PullMobs()
            logFile("Killing Charrs.")
            KillMobs()
            CheckAndPickUp()
        EndIf
        If GetIsDead(-2) Then GoBackToCheckpoint($CheckpointID)
    EndIf
    If ($CheckpointID >= 11) Then
        If ($CheckpointID == 11) Then logFile("Moving to the ninth charrs' group.")
        CheckStuck_MoveTo(719,-3126) ;Pull Boss
        If ($CheckpointID == 11) Then
            CheckStuck_MoveTo(207,-3293) ;go Back
            logFile("Arrived at the ninth charrs' group.")
            CheckAndUseStone()
            sleep(500)
            PullMobs()
            logFile("Killing Charrs.")
            KillMobs()
            CheckAndPickUp()
        EndIf
        If GetIsDead(-2) Then GoBackToCheckpoint($CheckpointID)
    EndIf
    If ($CheckpointID >= 12) Then
        If ($CheckpointID == 12) Then logFile("Moving to the tenth charrs' group.")
        CheckStuck_MoveTo(719,-3126) ;Pull Boss
        If ($CheckpointID == 12) Then
            CheckStuck_MoveTo(207,-3293) ;go Back
            logFile("Arrived at the tenth charrs' group.")
            CheckAndUseStone()
            sleep(500)
            PullMobs()
            logFile("Killing Charrs.")
            KillMobs()
            CheckAndPickUp()
        EndIf
        If GetIsDead(-2) Then GoBackToCheckpoint($CheckpointID)
    EndIf
    If ($CheckpointID >= 13) Then
        If ($CheckpointID == 13) Then logFile("Moving to the eleventh charrs' group.")
        CheckStuck_MoveTo(944,-2564)
        CheckStuck_MoveTo(1576,-2494)
        If GetIsDead(-2) Then GoBackToCheckpoint($CheckpointID)
        If ($CheckpointID == 13) Then
            logFile("Arrived at the eleventh charrs' group.")
            CheckAndUseStone()
            sleep(500)
            PullMobs()
            logFile("Killing Charrs.")
            KillMobs()
            CheckAndPickUp()
        EndIf
        If GetIsDead(-2) Then GoBackToCheckpoint($CheckpointID)
    EndIf
    If ($CheckpointID >= 14) Then
        If ($CheckpointID == 14) Then logFile("Moving to the twelfth charrs' group.")
        CheckStuck_MoveTo(1879,-2498)
        CheckStuck_MoveTo(2248,-3332) ;Pull
        If ($CheckpointID == 14) Then
            CheckStuck_MoveTo(2125, -3151) ;Go Back
            logFile("Arrived at the twelfth charrs' group.")
            CheckAndUseStone()
            sleep(500)
            PullMobs()
            logFile("Killing Charrs.")
            KillMobs()
            CheckAndPickUp()
        EndIf
        If GetIsDead(-2) Then GoBackToCheckpoint($CheckpointID)
    EndIf
EndFunc

Func Check_atReviveSanctuary() ;Check if the player is near the rez sanctuary : Used in Charrs Farms
    ;coinNE X-10955 Y-15690
    ;coinNW X-11413 Y-15943
    ;coinSW X-11112 Y-16508
    ;coinSE X-10545 Y-16163

    Local $lAgent = GetAgentByID(-2)
	Local $MyPosX = DllStructGetData($lAgent, 'X')
	Local $MyPosY = DllStructGetData($lAgent, 'Y')

    If (($MyPosX < -10545) AND ($MyPosX > -11413) AND ($MyPosY < -15690) AND ($MyPosY > -16508)) Then
        Return True
    Else
        Return False
    EndIf
EndFunc

Func FlowerRun()
	Sleep(2000)
	RndSlp(1600)
	logFile("Starting Flower farm.")
	Move(-11934, -13346, 50)

	Local $tDeadlock = TimerInit()
	Local $Looted = False

	While $Looted = False
		If TimerDiff($tDeadlock) > 45000 Then ExitLoop
		If GetMaxAgents() <> 0 Then
			Local $a = DllStructGetData(GetNearestItemToAgent(-2),'ID')
			Local $aMID = DllStructGetData(GetItemByAgentID($a), 'ModelID')
			If $aMID == 2994 Then	;Item matches
				logFile("Flower found, picking it up.")
				PickUpItem($a)
				$tDeadlock2 = TimerInit()
				Do
					Sleep(500)
					If TimerDiff($tDeadlock2) > 5000 Then ContinueLoop 2
				Until DllStructGetData(GetItemByAgentID($a), 'ID') == 0 ; Or TimerDiff($tDeadlock2) > 15000
				logFile("Flower collected")
				$Looted = True
			EndIf
		EndIf
	WEnd
EndFunc
	#EndRegion

    #Region Nicholas Sandford
Func DoNicholas() ;Do all steps to go and trade nicholas standford
    Local $Nicholas

    If Not $BoolNicholas Then
        If (GUICtrlRead($GoNicholas) = $GUI_CHECKED) Then
            If Count_Enough_DayFarmable(26) Then
                Farm_GoStartingOutpost(12)
                Farm_GoOutpostPortal(12)

                logFile("Moving to Nicholas Sandford.")
                MoveTo(22565,6057)
                MoveTo(22526,4784)
                MoveTo(22112,3572)
                MoveTo(19635,2248)
                MoveTo(17354,2635)
                MoveTo(16107,3183)
                MoveTo(15981,3907)
                MoveTo(16719,5575)
                MoveTo(16869,7479)
                MoveTo(16490,8291)
                MoveTo(17189,8225)
                MoveTo(17323,8744)
                MoveTo(16774,10387)
                MoveTo(15517,10876)
                MoveTo(14512,11195)
                MoveTo(13618,12612)
                MoveTo(14110,14037)
                MoveTo(14687,14697)
                MoveTo(14765,15633)
                MoveTo(15223,15815)
                MoveTo(15197,16410)

                $Nicholas = GetNearestNPCToCoords(15278, 16507)
                RNDSLP(1000)
                GoToNPC($Nicholas)
                Dialog(133)
                RNDSLP(500)
                Dialog(134)
                RNDSLP(1000)

                $BoolNicholas = 1
            EndIf
        EndIf
    EndIf
EndFunc
    #EndRegion

	#Region Side Functions
		#Region Build & Skill Functions
Func BuildForProfession() ;Load a farm build adapted to your profession and your level (10 or above)
    Local $Primary = GetAgentPrimaryProfession(-2)
    Local $Secondary = GetAgentSecondaryProfession(-2)
    Local $Level = GetLevel()

    Local $MapID = GetStartMapByJobID(1,GetJobId())
    Local $FarmID = GetJobId()

    Local $LDoABuildSet = False
	Local $CustomBuildSet = False

	If Not ((GetMapID() == 148) OR (GetMapID() == 164) OR (GetMapID() == 166) OR (GetMapID() == 165) OR (GetMapID() == 163)) Then ;Check if you are in an outpost
        logFile("You are not in an outpost.")
		logFile("Teleporting to the outpost.")
        ResignAndReturn()
        WaitForLoad()
		If (GetMapID() == $MapID) Then
            RndTravel($MapID)
            WaitMapLoading($MapID)
        EndIf
    EndIf

    If (($Level < 10) AND ($FarmID <> 1)) Then
		logFile("ERROR : Get level 10 with LDoA 2-10 befor farming.")
		$BotRunning = False
		Return 3
    ElseIf ($Level >=10) Then
        If($Primary == 0) Then
            MsgBox(16, "PreFarmer_Bot", "Unable to get your primary profession.")
            _exit()
        EndIf

		logFile("Loading build.")

		If (CustomBuild_Status()) Then
			$CustomBuildSet = Custom_BuildForProfession()
			If ($CustomBuildSet) Then
				logFile("Loaded the custom build.")
				Return
			EndIf
		EndIf

        If (LDoASurvivor_Status()) Then
            $LDoABuildSet = LDoA_BuildForProfession($Primary, $Secondary, $Level)
            If ($LDoABuildSet) Then
                logFile("Loaded a special LDoA build.")
                Return
            EndIf
        EndIf

        If($Primary == 1) Then ;W
			If ($Secondary == 0) Then ;W only
				Switch $Level
					Case 10
                        LoadSkillTemplate("OQATED5VrIAAAAAQpQFAAAA")
                    Case 11
                        LoadSkillTemplate("OQATEFJWrIAAAAAQpQFAAAA")
                    Case 12
                        LoadSkillTemplate("OQATEJJWrIAAAAAQpQFAAAA")
                    Case 13
                        LoadSkillTemplate("OQATEHZWtIAAAAAQpQFAAAA")
                    Case 14
                        LoadSkillTemplate("OQATELZWtIAAAAAQpQFAAAA")
                    Case 15
                        LoadSkillTemplate("OQATEJpWtIAAAAAQpQFAAAA")
                    Case 16
                        LoadSkillTemplate("OQATEDpWzIAAAAAQpQFAAAA")
                    Case 17
                        LoadSkillTemplate("OQATELpWzIAAAAAQpQFAAAA")
                    Case 18
                        LoadSkillTemplate("OQATELpW1IAAAAAQpQFAAAA")
                    Case 19
                        LoadSkillTemplate("OQATED5W3IAAAAAQpQFAAAA")
                    Case 20
                        LoadSkillTemplate("OQATEJJX1IAAAAAQpQFAAAA")
                EndSwitch
            ElseIf($Secondary == 2) Then ;W/R
                Switch $Level
                    Case 10
                        LoadSkillTemplate("OQIUItaZF8E+OAAg2KFqAAAA")
                    Case 11
                        LoadSkillTemplate("OQIUIvaZH8E+OAAg2KFqAAAA")
                    Case 12
                        LoadSkillTemplate("OQIUIxaZH8E+OAAg2KFqAAAA")
                    Case 13
                        LoadSkillTemplate("OQIVEDJWPrgnw3BAA0WpQFAAAA")
                    Case 14
                        LoadSkillTemplate("OQIUIzqZJ8E+OAAg2KFqAAAA")
                    Case 15
                        LoadSkillTemplate("OQIVEDZWRrgnw3BAA0WpQFAAAA")
                    Case 16
                        LoadSkillTemplate("OQIVEDZWTrgpw3BAA0WpQFAAAA")
                    Case 17
                        LoadSkillTemplate("OQIVEDZWRLhvw3BAA0WpQFAAAA")
                    Case 18
                        LoadSkillTemplate("OQIVEJZWRbhvw3BAA0WpQFAAAA")
                    Case 19
                        LoadSkillTemplate("OQIVEFZWT7hvw3BAA0WpQFAAAA")
                    Case 20
                        LoadSkillTemplate("OQIUIzaaRMG+OAAg2KFqAAAA")
                EndSwitch
            ElseIf($Secondary == 3) Then ;W/Mo
                Switch $Level
                    Case 10
                        LoadSkillTemplate("OQMU0IHJrKFgMAZEAK9e8DlA")
                    Case 11
                        LoadSkillTemplate("OQMU0KXJrKFgMAZEAK9e8DlA")
                    Case 12
                        LoadSkillTemplate("OQMU0MXJt6EgMAZEAK9e8DlA")
                    Case 13
                        LoadSkillTemplate("OQMV0KnFD5VpAkBIjAQp3jfoEA")
                    Case 14
                        LoadSkillTemplate("OQMU0KXJz6EgMAZEAK9e8DlA")
                    Case 15
                        LoadSkillTemplate("OQMU0KXJzaFgMAZEAK9e8DlA")
                    Case 16
                        LoadSkillTemplate("OQMV0M3FFZWpAkBIjAQp3jfoEA")
                    Case 17
                        LoadSkillTemplate("OQMU0MHKzaFgMAZEAK9e8DlA")
                    Case 18
                        LoadSkillTemplate("OQMU0QHKzaFgMAZEAK9e8DlA")
                    Case 19
                        LoadSkillTemplate("OQMV0QXGDZWtAkBIjAQp3jfoEA")
                    Case 20
                        LoadSkillTemplate("OQMU0QXKzKGgMAZEAK9e8DlA")
                EndSwitch
            ElseIf($Secondary == 4) Then ;W/N
                Switch $Level
                    Case 10
                        LoadSkillTemplate("OQQUQqoIt6EAIAAAAKFqZqNA")
                    Case 11
                        LoadSkillTemplate("OQQUQq4Iv6EAIAAAAKFqZqNA")
                    Case 12
                        LoadSkillTemplate("OQQUQq4Ix6EAIAAAAKFqZqNA")
                    Case 13
                        LoadSkillTemplate("OQQTQMZWnAABAAAQpQNTtBA")
                    Case 14
                        LoadSkillTemplate("OQQUQsIJz6EAIAAAAKFqZqNA")
                    Case 15
                        LoadSkillTemplate("OQQUQuIJz6EAIAAAAKFqZqNA")
                    Case 16
                        LoadSkillTemplate("OQQUQwoIzqFAIAAAAKFqZqNA")
                    Case 17
                        LoadSkillTemplate("OQQUQy4IzqFAIAAAAKFqZqNA")
                    Case 18
                        LoadSkillTemplate("OQQUQy4IzKGAIAAAAKFqZqNA")
                    Case 19
                        LoadSkillTemplate("OQQUQ04IzKGAIAAAAKFqZqNA")
                    Case 20
                        LoadSkillTemplate("OQQTQUpWzAABAAAQpQNTtBA")
                EndSwitch
            ElseIf($Secondary == 5) Then ;W/Mes
                Switch $Level
                    Case 10
                        LoadSkillTemplate("OQUVIkBFDpVpAFBAAAQpQ9DbAA")
                    Case 11
                        LoadSkillTemplate("OQUVImBFD5VpAFBAAAQpQ9DbAA")
                    Case 12
                        LoadSkillTemplate("OQUVIkxEDZWnAFBAAAQpQ9DbAA")
                    Case 13
                        LoadSkillTemplate("OQUVIqRFD5VrAFBAAAQpQ9DbAA")
                    Case 14
                        LoadSkillTemplate("OQUVIkhFFZWpAFBAAAQpQ9DbAA")
                    Case 15
                        LoadSkillTemplate("OQUVImxFFZWpAFBAAAQpQ9DbAA")
                    Case 16
                        LoadSkillTemplate("OQUVIshFFJWvAFBAAAQpQ9DbAA")
                    Case 17
                        LoadSkillTemplate("OQUVIsBGFZWrAFBAAAQpQ9DbAA")
                    Case 18
                        LoadSkillTemplate("OQUVIwBGFZWrAFBAAAQpQ9DbAA")
                    Case 19
                        LoadSkillTemplate("OQUVIwBGFZWvAFBAAAQpQ9DbAA")
                    Case 20
                        LoadSkillTemplate("OQUUIwBKzaGoIAAAAKFqfYDA")
                EndSwitch
            ElseIf($Secondary == 6) Then ;W/El
                Switch $Level
                    Case 10
                        LoadSkillTemplate("OQYUoqoIt6E0KAAAAKFqFTYA")
                    Case 11
                        LoadSkillTemplate("OQYUoq4Iv6E0KAAAAKFqFTYA")
                    Case 12
                        LoadSkillTemplate("OQYUoq4Ix6E0KAAAAKFqFTYA")
                    Case 13
                        LoadSkillTemplate("OQYToMZWngWBAAAQpQtYCDA")
                    Case 14
                        LoadSkillTemplate("OQYUos4IzKF0KAAAAKFqFTYA")
                    Case 15
                        LoadSkillTemplate("OQYUowoIz6E0KAAAAKFqFTYA")
                    Case 16
                        LoadSkillTemplate("OQYUou4Iz6F0KAAAAKFqFTYA")
                    Case 17
                        LoadSkillTemplate("OQYUoy4IzqF0KAAAAKFqFTYA")
                    Case 18
                        LoadSkillTemplate("OQYUoyIJz6F0KAAAAKFqFTYA")
                    Case 19
                        LoadSkillTemplate("OQYUoy4I1KG0KAAAAKFqFTYA")
                    Case 20
                        LoadSkillTemplate("OQYToUpWzgWBAAAQpQtYCDA")
                EndSwitch
            EndIf
        ElseIf($Primary == 2) Then ;R
			If ($Secondary == 0) Then ;R only
				Switch $Level
					Case 10
                        LoadSkillTemplate("OgAUYjbgr8F+GAAg2K+yMGAA")
                    Case 11
                        LoadSkillTemplate("OgAUYjbgrMG+GAAg2K+yMGAA")
                    Case 12
                        LoadSkillTemplate("OgAUYjbgrcG+GAAg2K+yMGAA")
                    Case 13
                        LoadSkillTemplate("OgAUYjLhrcG+GAAg2K+yMGAA")
                    Case 14
                        LoadSkillTemplate("OgAUYjrhrcG+GAAg2K+yMGAA")
                    Case 15
                        LoadSkillTemplate("OgAUYl7hrcG+GAAg2K+yMGAA")
                    Case 16
                        LoadSkillTemplate("OgAUYlrhxcG+GAAg2K+yMGAA")
                    Case 17
                        LoadSkillTemplate("OgAUYjbivcG+GAAg2K+yMGAA")
                    Case 18
                        LoadSkillTemplate("OgAUYnbixcG+GAAg2K+yMGAA")
                    Case 19
                        LoadSkillTemplate("OgATcNMm5w3AAA0WxXmxAAA")
                    Case 20
                        LoadSkillTemplate("OgAUYlrhzMH+GAAg2K+yMGAA")
                EndSwitch
            ElseIf($Secondary == 1) Then ;R/W
                Switch $Level
                    Case 10
                        LoadSkillTemplate("OgEUYj7gp8F+OAAg2K+yMGAA")
                    Case 11
                        LoadSkillTemplate("OgEUYj7gpMG+OAAg2K+yMGAA")
                    Case 12
                        LoadSkillTemplate("OgEUYj7gpcG+OAAg2K+yMGAA")
                    Case 13
                        LoadSkillTemplate("OgEUYjLhrcG+OAAg2K+yMGAA")
                    Case 14
                        LoadSkillTemplate("OgEUYjrhrcG+OAAg2K+yMGAA")
                    Case 15
                        LoadSkillTemplate("OgEUYl7hrcG+OAAg2K+yMGAA")
                    Case 16
                        LoadSkillTemplate("OgEVUJbdNclzw3BAA0WxXmxAAA")
                    Case 17
                        LoadSkillTemplate("OgEUYjbivcG+OAAg2K+yMGAA")
                    Case 18
                        LoadSkillTemplate("OgEUYnbixcG+OAAg2K+yMGAA")
                    Case 19
                        LoadSkillTemplate("OgEVUNrdPMmzw3BAA0WxXmxAAA")
                    Case 20
                        LoadSkillTemplate("OgEVUNrdPcmzw3BAA0WxXmxAAA")
                EndSwitch
            ElseIf($Secondary == 3) Then ;R/Mo
                Switch $Level
                    Case 10
                        LoadSkillTemplate("OgMU0GHhj8F+GkZk2K+y8DlA")
                    Case 11
                        LoadSkillTemplate("OgMU0GHhjMG+GkZk2K+y8DlA")
                    Case 12
                        LoadSkillTemplate("OgMU0GHhjcG+GkZk2K+y8DlA")
                    Case 13
                        LoadSkillTemplate("OgMV0IXdJskxw3gMj0WxXmfoEA")
                    Case 14
                        LoadSkillTemplate("OgMU0KnhjcG+GkZk2K+y8DlA")
                    Case 15
                        LoadSkillTemplate("OgMU0K3hlcG+GkZk2K+y8DlA")
                    Case 16
                        LoadSkillTemplate("OgMW0KnZjbhpcG+GkZk2K+y8DlA")
                    Case 17
                        LoadSkillTemplate("OgMU0O3htcG+GkZk2K+y8DlA")
                    Case 18
                        LoadSkillTemplate("OgMU0QHircG+GkZk2K+y8DlA")
                    Case 19
                        LoadSkillTemplate("OgMW0KXajrhtcG+GkZk2K+y8DlA")
                    Case 20
                        LoadSkillTemplate("OgMW0KXal7hvcG+GkZk2K+y8DlA")
                EndSwitch
            ElseIf($Secondary == 4) Then ;R/N
                Switch $Level
                    Case 10
                        LoadSkillTemplate("OgQUYjbgnMG+GAAg2K+yZqNA")
                    Case 11
                        LoadSkillTemplate("OgQUYj7gpMG+GAAg2K+yZqNA")
                    Case 12
                        LoadSkillTemplate("OgQUYj7gpcG+GAAg2K+yZqNA")
                    Case 13
                        LoadSkillTemplate("OgQUQq7gncG+GAAg2K+yZqNA")
                    Case 14
                        LoadSkillTemplate("OgQUYjrhrcG+GAAg2K+yZqNA")
                    Case 15
                        LoadSkillTemplate("OgQUYlrhtcG+GAAg2K+yZqNA")
                    Case 16
                        LoadSkillTemplate("OgQUQwbhpcG+GAAg2K+yZqNA")
                    Case 17
                        LoadSkillTemplate("OgQUYlLixcG+GAAg2K+yZqNA")
                    Case 18
                        LoadSkillTemplate("OgQUYrLixcG+GAAg2K+yZqNA")
                    Case 19
                        LoadSkillTemplate("OgQVQS7dNMlzw3AAA0WxXOTtBA")
                    Case 20
                        LoadSkillTemplate("OgQVQS7dPclzw3AAA0WxXOTtBA")
                EndSwitch
            ElseIf($Secondary == 5) Then ;R/Mes
                Switch $Level
                    Case 10
                        LoadSkillTemplate("OgUUMobgn8F+GFAg2K+yMGAA")
                    Case 11
                        LoadSkillTemplate("OgUUMobgnMG+GFAg2K+yMGAA")
                    Case 12
                        LoadSkillTemplate("OgUUMobgncG+GFAg2K+yMGAA")
                    Case 13
                        LoadSkillTemplate("OgUUMq7gncG+GFAg2K+yMGAA")
                    Case 14
                        LoadSkillTemplate("OgUUMqLhpcG+GFAg2K+yMGAA")
                    Case 15
                        LoadSkillTemplate("OgUUMqLhtcG+GFAg2K+yMGAA")
                    Case 16
                        LoadSkillTemplate("OgUUMu7gvcG+GFAg2K+yMGAA")
                    Case 17
                        LoadSkillTemplate("OgUUMs7hvcG+GFAg2K+yMGAA")
                    Case 18
                        LoadSkillTemplate("OgUUMy7hrcG+GFAg2K+yMGAA")
                    Case 19
                        LoadSkillTemplate("OgUVMQrdN8lzw3oAA0WxXmxAAA")
                    Case 20
                        LoadSkillTemplate("OgUVMQ7dP8lzw3oAA0WxXmxAAA")
                EndSwitch
            ElseIf($Secondary == 6) Then ;R/El
                Switch $Level
                    Case 10
                        LoadSkillTemplate("OgYVoIbcFskvgW+GA0WxXuYCDA")
                    Case 11
                        LoadSkillTemplate("OgYVoIbcFskxgW+GA0WxXuYCDA")
                    Case 12
                        LoadSkillTemplate("OgYVoIbcFskzgW+GA0WxXuYCDA")
                    Case 13
                        LoadSkillTemplate("OgYVoMbcJ8kxgW+GA0WxXuYCDA")
                    Case 14
                        LoadSkillTemplate("OgYVoOrcFskzgW+GA0WxXuYCDA")
                    Case 15
                        LoadSkillTemplate("OgYVoQrcFskzgW+GA0WxXuYCDA")
                    Case 16
                        LoadSkillTemplate("OgYVoOrcNslxgW+GA0WxXuYCDA")
                    Case 17
                        LoadSkillTemplate("OgYVoSrcFslzgW+GA0WxXuYCDA")
                    Case 18
                        LoadSkillTemplate("OgYVoSbcPclzgW+GA0WxXuYCDA")
                    Case 19
                        LoadSkillTemplate("OgYVoQrdPslzgW+GA0WxXuYCDA")
                    Case 20
                        LoadSkillTemplate("OgYVoQ7dP8lzgW+GA0WxXuYCDA")
                EndSwitch
            EndIf
        ElseIf($Primary == 3) Then ;Mo
			If ($Secondary == 0) Then ;Mo only
				Switch $Level
					Case 10
                        LoadSkillTemplate("OwAT0MnBlAkZEAA4e8DlAAA")
                    Case 11
                        LoadSkillTemplate("OwAT0M3BnAkZEAA4e8DlAAA")
                    Case 12
                        LoadSkillTemplate("OwAC0njBIzIAAw94HKBA")
                    Case 13
                        LoadSkillTemplate("OwAT0MXCnAkZEAA4e8DlAAA")
                    Case 14
                        LoadSkillTemplate("OwAC0onBIzIAAw94HKBA")
                    Case 15
                        LoadSkillTemplate("OwAT0QXCpAkZEAA4e8DlAAA")
                    Case 16
                        LoadSkillTemplate("OwAT0SnCjAkZEAA4e8DlAAA")
                    Case 17
                        LoadSkillTemplate("OwAT0UnClAkZEAA4e8DlAAA")
                    Case 18
                        LoadSkillTemplate("OwAT0U3CjAkZEAA4e8DlAAA")
                    Case 19
                        LoadSkillTemplate("OwAT0W3CjAkZEAA4e8DlAAA")
                    Case 20
                        LoadSkillTemplate("OwAT0W3CrAkZEAA4e8DlAAA")
                EndSwitch
            ElseIf($Secondary == 1) Then ;Mo/W
                Switch $Level
                    Case 10
                        LoadSkillTemplate("OwET0KXJrAkZEAAQp3jfoEA")
                    Case 11
                        LoadSkillTemplate("OwEU0KXBFpFgMjAAAK9e8DlA")
                    Case 12
                        LoadSkillTemplate("OwEU0MnBDpFgMjAAAK9e8DlA")
                    Case 13
                        LoadSkillTemplate("OwEU0MnBF5FgMjAAAK9e8DlA")
                    Case 14
                        LoadSkillTemplate("OwEU0O3BD5FgMjAAAK9e8DlA")
                    Case 15
                        LoadSkillTemplate("OwEU0O3BDJGgMjAAAK9e8DlA")
                    Case 16
                        LoadSkillTemplate("OwEU0MHCFZGgMjAAAK9e8DlA")
                    Case 17
                        LoadSkillTemplate("OwEU0SHCFJGgMjAAAK9e8DlA")
                    Case 18
                        LoadSkillTemplate("OwEU0SXCHJGgMjAAAK9e8DlA")
                    Case 19
                        LoadSkillTemplate("OwEU0UHCHZGgMjAAAK9e8DlA")
                    Case 20
                        LoadSkillTemplate("OwET0UnKzAkZEAAQp3jfoEA")
                EndSwitch
            ElseIf($Secondary == 2) Then ;Mo/R
                Switch $Level
                    Case 10
                        LoadSkillTemplate("OwIT0KXhrw3gMj0+e8DlAAA")
                    Case 11
                        LoadSkillTemplate("OwIU0KnBFcF+GkZk23jfoEAA")
                    Case 12
                        LoadSkillTemplate("OwIU0M3BDcF+GkZk23jfoEAA")
                    Case 13
                        LoadSkillTemplate("OwIU0QnBDcF+GkZk23jfoEAA")
                    Case 14
                        LoadSkillTemplate("OwIU0O3BD8F+GkZk23jfoEAA")
                    Case 15
                        LoadSkillTemplate("OwIU0OHCD8F+GkZk23jfoEAA")
                    Case 16
                        LoadSkillTemplate("OwIV0SHCFbgtw3gMj0+e8DlAAA")
                    Case 17
                        LoadSkillTemplate("OwIU0QXCFMG+GkZk23jfoEAA")
                    Case 18
                        LoadSkillTemplate("OwIU0SXCHMG+GkZk23jfoEAA")
                    Case 19
                        LoadSkillTemplate("OwIV0SXCDrhxw3gMj0+e8DlAAA")
                    Case 20
                        LoadSkillTemplate("OwIV0UXCFrhxw3gMj0+e8DlAAA")
                EndSwitch
            ElseIf($Secondary == 4) Then ;Mo/N
                Switch $Level
                    Case 10
                        LoadSkillTemplate("OwQDQSbuFgMjAAA3jfoMTA")
                    Case 11
                        LoadSkillTemplate("OwQUQom5MoEgMjAAA3jfoMTA")
                    Case 12
                        LoadSkillTemplate("OwQUQom5O4EgMjAAA3jfoMTA")
                    Case 13
                        LoadSkillTemplate("OwQDQUj+FgMjAAA3jfoMTA")
                    Case 14
                        LoadSkillTemplate("OwQUQu25OYEgMjAAA3jfoMTA")
                    Case 15
                        LoadSkillTemplate("OwQUQu25QYEgMjAAA3jfoMTA")
                    Case 16
                        LoadSkillTemplate("OwQDQWr+FgMjAAA3jfoMTA")
                    Case 17
                        LoadSkillTemplate("OwQUQuW6SYEgMjAAA3jfoMTA")
                    Case 18
                        LoadSkillTemplate("OwQUQwW6S4EgMjAAA3jfoMTA")
                    Case 19
                        LoadSkillTemplate("OwQUQym6Q4EgMjAAA3jfoMTA")
                    Case 20
                        LoadSkillTemplate("OwQDQZruGgMjAAA3jfoMTA")
                EndSwitch
            ElseIf($Secondary == 5) Then ;Mo/Mes
                Switch $Level
                    Case 10
                        LoadSkillTemplate("OwUEIxE95VAyMiCAwPU+hNA")
                    Case 11
                        LoadSkillTemplate("OwUVIiB1OXBjAkZEFAgfo8DbAA")
                    Case 12
                        LoadSkillTemplate("OwUEIzQ95WAyMiCAwPU+hNA")
                    Case 13
                        LoadSkillTemplate("OwUVIqB1OnBjAkZEFAgfo8DbAA")
                    Case 14
                        LoadSkillTemplate("OwUVIqB1O3BlAkZEFAgfo8DbAA")
                    Case 15
                        LoadSkillTemplate("OwUVIsR1O3BlAkZEFAgfo8DbAA")
                    Case 16
                        LoadSkillTemplate("OwUWEERNqW6OYEgMjoAA8DlfYDA")
                    Case 17
                        LoadSkillTemplate("OwUVIsR1QXClAkZEFAgfo8DbAA")
                    Case 18
                        LoadSkillTemplate("OwUEI3Ud6ZAyMiCAwPU+hNA")
                    Case 19
                        LoadSkillTemplate("OwUFEicz1pnBIzIKAA/Q5H2A")
                    Case 20
                        LoadSkillTemplate("OwUWEExNum6SYEgMjoAA8DlfYDA")
                EndSwitch
            ElseIf($Secondary == 6) Then ;Mo/El
                Switch $Level
                    Case 10
                        LoadSkillTemplate("OwYDoVXeF0CkZEA8DlFTYA")
                    Case 11
                        LoadSkillTemplate("OwYDoWbOF0CkZEA8DlFTYA")
                    Case 12
                        LoadSkillTemplate("OwYDoWbuF0CkZEA8DlFTYA")
                    Case 13
                        LoadSkillTemplate("OwYUoqG6MYE0CkZEA8DlFTYA")
                    Case 14
                        LoadSkillTemplate("OwYDoXf+F0CkZEA8DlFTYA")
                    Case 15
                        LoadSkillTemplate("OwYDoXfOG0CkZEA8DlFTYA")
                    Case 16
                        LoadSkillTemplate("OwYUosW6QoE0CkZEA8DlFTYA")
                    Case 17
                        LoadSkillTemplate("OwYUowW6QoE0CkZEA8DlFTYA")
                    Case 18
                        LoadSkillTemplate("OwYUoyG6S4E0CkZEA8DlFTYA")
                    Case 19
                        LoadSkillTemplate("OwYUowm6S4E0CkZEA8DlFTYA")
                    Case 20
                        LoadSkillTemplate("OwYDoareG0CkZEA8DlFTYA")
                EndSwitch
            EndIf
        ElseIf($Primary == 4) Then ;N
			If ($Secondary == 0) Then ;N only
				Switch $Level
					Case 10
                        LoadSkillTemplate("OABDQWZmAAAAAAcYbZmG")
                    Case 11
                        LoadSkillTemplate("OABDQXZ2AAAAAAcYbZmG")
                    Case 12
                        LoadSkillTemplate("OABDQXd2AAAAAAcYbZmG")
                    Case 13
                        LoadSkillTemplate("OABDQYhWAAAAAAcYbZmG")
                    Case 14
                        LoadSkillTemplate("OABDQYhGBAAAAAcYbZmG")
                    Case 15
                        LoadSkillTemplate("OABDQZhGBAAAAAcYbZmG")
                    Case 16
                        LoadSkillTemplate("OABDQalWAAAAAAcYbZmG")
                    Case 17
                        LoadSkillTemplate("OABDQapmAAAAAAcYbZmG")
                    Case 18
                        LoadSkillTemplate("OABDQapWBAAAAAcYbZmG")
                    Case 19
                        LoadSkillTemplate("OABDQbtWAAAAAAcYbZmG")
                    Case 20
                        LoadSkillTemplate("OABDQbtWBAAAAAcYbZmG")
                EndSwitch
            ElseIf($Secondary == 1) Then ;N/W
                Switch $Level
                    Case 10
                        LoadSkillTemplate("OAFVQsCZiDVFIAAAAgDbLz0A")
                    Case 11
                        LoadSkillTemplate("OAFVQsSZkDVHIAAAAgDbLz0A")
                    Case 12
                        LoadSkillTemplate("OAFVQsiZkDVJIAAAAgDbLz0A")
                    Case 13
                        LoadSkillTemplate("OAFVQwSZiTVHIAAAAgDbLz0A")
                    Case 14
                        LoadSkillTemplate("OAFVQuyZkDVLIAAAAgDbLz0A")
                    Case 15
                        LoadSkillTemplate("OAFVQuyZmDVNIAAAAgDbLz0A")
                    Case 16
                        LoadSkillTemplate("OAFUQyydu6ABAAAAcYbZmGA")
                    Case 17
                        LoadSkillTemplate("OAFVQyCamDVNIAAAAgDbLz0A")
                    Case 18
                        LoadSkillTemplate("OAFVQySamDVPIAAAAgDbLz0A")
                    Case 19
                        LoadSkillTemplate("OAFVQySaiTWJIAAAAgDbLz0A")
                    Case 20
                        LoadSkillTemplate("OAFVQySakjWJIAAAAgDbLz0A")
                EndSwitch
            ElseIf($Secondary == 2) Then ;N/R
                Switch $Level
                    Case 10,11,12
                        LoadSkillTemplate("OAJUQsSdE8E+GAAg2HqNZKNA")
                    Case 11
                        LoadSkillTemplate("OAJVQsSdEbgrw3AAA0+QtJTpBA")
                    Case 12
                        LoadSkillTemplate("OAJVQuSdGbgrw3AAA0+QtJTpBA")
                    Case 13
                        LoadSkillTemplate("OAJVQuidIbgrw3AAA0+QtJTpBA")
                    Case 14
                        LoadSkillTemplate("OAJVQuydGbgtw3AAA0+QtJTpBA")
                    Case 15
                        LoadSkillTemplate("OAJVQuydGLhtw3AAA0+QtJTpBA")
                    Case 16
                        LoadSkillTemplate("OAJVQwCeK7grw3AAA0+QtJTpBA")
                    Case 17
                        LoadSkillTemplate("OAJWQyCakzYJsF+GAAg2HqNZKNA")
                    Case 18
                        LoadSkillTemplate("OAJWQySakDZJsF+GAAg2HqNZKNA")
                    Case 19
                        LoadSkillTemplate("OAJWQyCaiDaJsF+GAAg2HqNZKNA")
                    Case 20
                        LoadSkillTemplate("OAJWQySaiDaLsF+GAAg2HqNZKNA")
                EndSwitch
            ElseIf($Secondary == 3) Then ;N/Mo
                Switch $Level
                    Case 10
                        LoadSkillTemplate("OANDQVXeFgMjAAAtJT8DlA")
                    Case 11
                        LoadSkillTemplate("OANEQlJd5WAyMCAA0mMxPUC")
                    Case 12
                        LoadSkillTemplate("OANEQmFt5WAyMCAA0mMxPUC")
                    Case 13
                        LoadSkillTemplate("OANEQoFt5VAyMCAA0mMxPUC")
                    Case 14
                        LoadSkillTemplate("OANEQnF95XAyMCAA0mMxPUC")
                    Case 15
                        LoadSkillTemplate("OANEQoF95XAyMCAA0mMxPUC")
                    Case 16
                        LoadSkillTemplate("OANEQpJt5YAyMCAA0mMxPUC")
                    Case 17
                        LoadSkillTemplate("OANEQpJN6YAyMCAA0mMxPUC")
                    Case 18
                        LoadSkillTemplate("OANEQpNN6ZAyMCAA0mMxPUC")
                    Case 19
                        LoadSkillTemplate("OANEQqNd6YAyMCAA0mMxPUC")
                    Case 20
                        LoadSkillTemplate("OANDQanuGgMjAAAtJT8DlA")
                EndSwitch
            ElseIf($Secondary == 5) Then ;N/Mes
                Switch $Level
                    Case 10
                        LoadSkillTemplate("OAVDI1UUBoAAAA0WmfsB")
                    Case 11
                        LoadSkillTemplate("OAVEI1UkZCgCAAAQbZ+xGA")
                    Case 12
                        LoadSkillTemplate("OAVEI1Y0ZBgCAAAQbZ+xGA")
                    Case 13
                        LoadSkillTemplate("OAVEI2Y0ZCgCAAAQbZ+xGA")
                    Case 14
                        LoadSkillTemplate("OAVEI2UUaBgCAAAQbZ+xGA")
                    Case 15
                        LoadSkillTemplate("OAVEI2YUaCgCAAAQbZ+xGA")
                    Case 16
                        LoadSkillTemplate("OAVEI4cEaDgCAAAQbZ+xGA")
                    Case 17
                        LoadSkillTemplate("OAVEI4gUaCgCAAAQbZ+xGA")
                    Case 18
                        LoadSkillTemplate("OAVEI4kUaDgCAAAQbZ+xGA")
                    Case 19
                        LoadSkillTemplate("OAVEI5kUaEgCAAAQbZ+xGA")
                    Case 20
                        LoadSkillTemplate("OAVDI5okCoAAAA0WmfsB")
                EndSwitch
            ElseIf($Secondary == 6) Then ;N/El
                Switch $Level
                    Case 10
                        LoadSkillTemplate("OAZDQmJqB0CAAA0WmFLM")
                    Case 11
                        LoadSkillTemplate("OAZDQmN6B0CAAA0WmFLM")
                    Case 12
                        LoadSkillTemplate("OAZDQnN6B0CAAA0WmFLM")
                    Case 13
                        LoadSkillTemplate("OAZDQoFKC0CAAA0WmFLM")
                    Case 14
                        LoadSkillTemplate("OAZDQoRKC0CAAA0WmFLM")
                    Case 15
                        LoadSkillTemplate("OAZDQoRaC0CAAA0WmFLM")
                    Case 16
                        LoadSkillTemplate("OAZDQqFaC0CAAA0WmFLM")
                    Case 17
                        LoadSkillTemplate("OAZDQpVqC0CAAA0WmFLM")
                    Case 18
                        LoadSkillTemplate("OAZDQqVqC0CAAA0WmFLM")
                    Case 19
                        LoadSkillTemplate("OAZDQrF6C0CAAA0WmFLM")
                    Case 20
                        LoadSkillTemplate("OAZDQrV6C0CAAA0WmFLM")
                EndSwitch
            EndIf
        ElseIf($Primary == 5) Then ;Mes
			If ($Secondary == 0) Then ;Mes only
				Switch $Level
					Case 10
                        LoadSkillTemplate("OQBDAiYjBoAAAAoxHbAA")
                    Case 11
                        LoadSkillTemplate("OQBDAjYzBoAAAAoxHbAA")
                    Case 12
                        LoadSkillTemplate("OQBCI4cAKAAAAa8xGAA")
                    Case 13
                        LoadSkillTemplate("OQBDAhgDCoAAAAoxHbAA")
                    Case 14
                        LoadSkillTemplate("OQBCI4kAKAAAAa8xGAA")
                    Case 15
                        LoadSkillTemplate("OQBDAkgTCoAAAAoxHbAA")
                    Case 16
                        LoadSkillTemplate("OQBDAhoTCoAAAAoxHbAA")
                    Case 17
                        LoadSkillTemplate("OQBDAiojCoAAAAoxHbAA")
                    Case 18
                        LoadSkillTemplate("OQBDAhozCoAAAAoxHbAA")
                    Case 19
                        LoadSkillTemplate("OQBDAhszCoAAAAoxHbAA")
                    Case 20
                        LoadSkillTemplate("OQBDAlszCoAAAAoxHbAA")
                EndSwitch
            ElseIf($Secondary == 1) Then ;Mes/W
                Switch $Level
                    Case 10
                        LoadSkillTemplate("OQFUAIRNoKBoEAAAoxHbAAA")
                    Case 11
                        LoadSkillTemplate("OQFUAIRNqaBoEAAAoxHbAAA")
                    Case 12
                        LoadSkillTemplate("OQFUAGxNsKBoEAAAoxHbAAA")
                    Case 13
                        LoadSkillTemplate("OQFVAsQIshVJAlAAAAN+YDAA")
                    Case 14
                        LoadSkillTemplate("OQFUAIxNwKBoEAAAoxHbAAA")
                    Case 15
                        LoadSkillTemplate("OQFUAGBOwaBoEAAAoxHbAAA")
                    Case 16
                        LoadSkillTemplate("OQFVAuwIwxVJAlAAAAN+YDAA")
                    Case 17
                        LoadSkillTemplate("OQFUAGROyqBoEAAAoxHbAAA")
                    Case 18
                        LoadSkillTemplate("OQFUAIRO0qBoEAAAoxHbAAA")
                    Case 19
                        LoadSkillTemplate("OQFVAuwI0RWJAlAAAAN+YDAA")
                    Case 20
                        LoadSkillTemplate("OQFVAuAJ0hWJAlAAAAN+YDAA")
                EndSwitch
            ElseIf($Secondary == 2) Then ;Mes/R
                Switch $Level
                    Case 10
                        LoadSkillTemplate("OQJUAIBNIcFow3Ag2a4DbAAA")
                    Case 11
                        LoadSkillTemplate("OQJUACxNIcFow3Ag2a4DbAAA")
                    Case 12
                        LoadSkillTemplate("OQJUAEBOIcFow3Ag2a4DbAAA")
                    Case 13
                        LoadSkillTemplate("OQJVAoQIsRhvAF+GA0WDfYDAAA")
                    Case 14
                        LoadSkillTemplate("OQJUAEhOGcFow3Ag2a4DbAAA")
                    Case 15
                        LoadSkillTemplate("OQJUAEhOMMFow3Ag2a4DbAAA")
                    Case 16
                        LoadSkillTemplate("OQJWAuQIuRZJ8Fow3Ag2a4DbAAA")
                    Case 17
                        LoadSkillTemplate("OQJUAGhOSMFow3Ag2a4DbAAA")
                    Case 18
                        LoadSkillTemplate("OQJUAEhOS8Fow3Ag2a4DbAAA")
                    Case 19
                        LoadSkillTemplate("OQJWAuQIyhZP8Fow3Ag2a4DbAAA")
                    Case 20
                        LoadSkillTemplate("OQJWAwQIyxZP8Fow3Ag2a4DbAAA")
                EndSwitch
            ElseIf($Secondary == 3) Then ;Mes/Mo
                Switch $Level
                    Case 10
                        LoadSkillTemplate("OQNDMVXeFgMjoAA8DlfYDA")
                    Case 11
                        LoadSkillTemplate("OQNFAhIT1lbBIzIKAA/Q5H2A")
                    Case 12
                        LoadSkillTemplate("OQNFAhMT1lfBIzIKAA/Q5H2A")
                    Case 13
                        LoadSkillTemplate("OQNFAhQj1mbBIzIKAA/Q5H2A")
                    Case 14
                        LoadSkillTemplate("OQNFAhIT1njBIzIKAA/Q5H2A")
                    Case 15
                        LoadSkillTemplate("OQNFAhIT1nnBIzIKAA/Q5H2A")
                    Case 16
                        LoadSkillTemplate("OQNGAVIiNWb+FgMjoAA8DlfYDA")
                    Case 17
                        LoadSkillTemplate("OQNFAhMj1pnBIzIKAA/Q5H2A")
                    Case 18
                        LoadSkillTemplate("OQNFAhMD2pnBIzIKAA/Q5H2A")
                    Case 19
                        LoadSkillTemplate("OQNGAVMCOWjOGgMjoAA8DlfYDA")
                    Case 20
                        LoadSkillTemplate("OQNGAWMSOWjOGgMjoAA8DlfYDA")
                EndSwitch
            ElseIf($Secondary == 4) Then ;Mes/N
                Switch $Level
                    Case 10
                        LoadSkillTemplate("OQRDI1UUBoAAAA0WmfsB")
                    Case 11
                        LoadSkillTemplate("OQREAiUTRGgCAAAQbZ+xGA")
                    Case 12
                        LoadSkillTemplate("OQREAhUjRHgCAAAQbZ+xGA")
                    Case 13
                        LoadSkillTemplate("OQRFAUEiNGZAKAAAAtl5HbA")
                    Case 14
                        LoadSkillTemplate("OQREAhUjRJgCAAAQbZ+xGA")
                    Case 15
                        LoadSkillTemplate("OQREAiUzRJgCAAAQbZ+xGA")
                    Case 16
                        LoadSkillTemplate("OQRFAWIyNHdAKAAAAtl5HbA")
                    Case 17
                        LoadSkillTemplate("OQREAhcTSJgCAAAQbZ+xGA")
                    Case 18
                        LoadSkillTemplate("OQREAjgTSJgCAAAQbZ+xGA")
                    Case 19
                        LoadSkillTemplate("OQRFAYMCOIhAKAAAAtl5HbA")
                    Case 20
                        LoadSkillTemplate("OQRFAYQCOIlAKAAAAtl5HbA")
                EndSwitch
            ElseIf($Secondary == 6) Then ;Mes/El
                Switch $Level
                    Case 10
                        LoadSkillTemplate("OQZDI1UaB0iCAAUswfsB")
                    Case 11
                        LoadSkillTemplate("OQZEAiUTpGQLKAAQxC/xGA")
                    Case 12
                        LoadSkillTemplate("OQZEAhUzpGQLKAAQxC/xGA")
                    Case 13
                        LoadSkillTemplate("OQZFARIiNnaAtoAAAFL8HbA")
                    Case 14
                        LoadSkillTemplate("OQZEAhczpHQLKAAQxC/xGA")
                    Case 15
                        LoadSkillTemplate("OQZEAhczpIQLKAAQxC/xGA")
                    Case 16
                        LoadSkillTemplate("OQZFARMyNoiAtoAAAFL8HbA")
                    Case 17
                        LoadSkillTemplate("OQZEAhcTqJQLKAAQxC/xGA")
                    Case 18
                        LoadSkillTemplate("OQZEAjgTqJQLKAAQxC/xGA")
                    Case 19
                        LoadSkillTemplate("OQZFASMSOoqAtoAAAFL8HbA")
                    Case 20
                        LoadSkillTemplate("OQZFASISOouAtoAAAFL8HbA")
                EndSwitch
            EndIf
        ElseIf($Primary == 6) Then ;El
			If (($Secondary == 0) OR ($Secondary == 1)) Then ;El only OR El/W
				Switch $Level
					Case 10
                        LoadSkillTemplate("OgBCoGbAtAAAyFLMAAA")
                    Case 11
                        LoadSkillTemplate("OgBCoHbAtAAAyFLMAAA")
                    Case 12
                        LoadSkillTemplate("OgBCoIfAtAAAyFLMAAA")
                    Case 13
                        LoadSkillTemplate("OgBCoIjAtAAAyFLMAAA")
                    Case 14
                        LoadSkillTemplate("OgBCoInAtAAAyFLMAAA")
                    Case 15
                        LoadSkillTemplate("OgBCoInAtAAAyFLMAAA")
                    Case 16
                        LoadSkillTemplate("OgBCoKnAtAAAyFLMAAA")
                    Case 17
                        LoadSkillTemplate("OgBCoKrAtAAAyFLMAAA")
                    Case 18
                        LoadSkillTemplate("OgBCoLrAtAAAyFLMAAA")
                    Case 19
                        LoadSkillTemplate("OgBCoLvAtAAAyFLMAAA")
                    Case 20
                        LoadSkillTemplate("OgBCoLvAtAAAyFLMAAA")
                EndSwitch
            ElseIf($Secondary == 2) Then ;El/R
                Switch $Level
                    Case 10
                        LoadSkillTemplate("OgJToKWhrgW+GZ0uYCDAAAA")
                    Case 11
                        LoadSkillTemplate("OgJToMWhrgW+GZ0uYCDAAAA")
                    Case 12
                        LoadSkillTemplate("OgJToM2hrgW+GZ0uYCDAAAA")
                    Case 13
                        LoadSkillTemplate("OgJToQmhrgW+GZ0uYCDAAAA")
                    Case 14
                        LoadSkillTemplate("OgJToO2hvgW+GZ0uYCDAAAA")
                    Case 15
                        LoadSkillTemplate("OgJToQWipgW+GZ0uYCDAAAA")
                    Case 16
                        LoadSkillTemplate("OgJUoS2ZH8F0y3Ij2FTYAAAA")
                    Case 17
                        LoadSkillTemplate("OgJUoUWaDcF0y3Ij2FTYAAAA")
                    Case 18
                        LoadSkillTemplate("OgJUoUmaFcF0y3Ij2FTYAAAA")
                    Case 19
                        LoadSkillTemplate("OgJUoSWaNMG0y3Ij2FTYAAAA")
                    Case 20
                        LoadSkillTemplate("OgJUoSWaRMG0y3Ij2FTYAAAA")
                EndSwitch
            ElseIf($Secondary == 3) Then ;El/Mo
                Switch $Level
                    Case 10
                        LoadSkillTemplate("OgNEoFTN5UQLQmRkVMhxPUC")
                    Case 11
                        LoadSkillTemplate("OgNEoFTd5VQLQmRkVMhxPUC")
                    Case 12
                        LoadSkillTemplate("OgNEoGTd5VQLQmRkVMhxPUC")
                    Case 13
                        LoadSkillTemplate("OgNEoHXd5VQLQmRkVMhxPUC")
                    Case 14
                        LoadSkillTemplate("OgNEoJPd5VQLQmRkVMhxPUC")
                    Case 15
                        LoadSkillTemplate("OgNEoJXd5VQLQmRkVMhxPUC")
                    Case 16
                        LoadSkillTemplate("OgNEoIfd5XQLQmRkVMhxPUC")
                    Case 17
                        LoadSkillTemplate("OgNEoJb95XQLQmRkVMhxPUC")
                    Case 18
                        LoadSkillTemplate("OgNEoJb95YQLQmRkVMhxPUC")
                    Case 19
                        LoadSkillTemplate("OgNEoJfN6YQLQmRkVMhxPUC")
                    Case 20
                        LoadSkillTemplate("OgNEoJnN6YQLQmRkVMhxPUC")
                EndSwitch
            ElseIf($Secondary == 4) Then ;El/N
                Switch $Level
                    Case 10
                        LoadSkillTemplate("OgRDQlWcB0CAAIXswZ2G")
                    Case 11
                        LoadSkillTemplate("OgRDQlacB0CAAIXswZ2G")
                    Case 12
                        LoadSkillTemplate("OgRDQnacB0CAAIXswZ2G")
                    Case 13
                        LoadSkillTemplate("OgRDQmesB0CAAIXswZ2G")
                    Case 14
                        LoadSkillTemplate("OgRDQne8B0CAAIXswZ2G")
                    Case 15
                        LoadSkillTemplate("OgRDQni8B0CAAIXswZ2G")
                    Case 16
                        LoadSkillTemplate("OgRDQomsB0CAAIXswZ2G")
                    Case 17
                        LoadSkillTemplate("OgRDQnmcC0CAAIXswZ2G")
                    Case 18
                        LoadSkillTemplate("OgRDQomcC0CAAIXswZ2G")
                    Case 19
                        LoadSkillTemplate("OgRDQpmcC0CAAIXswZ2G")
                    Case 20
                        LoadSkillTemplate("OgRDQqqcC0CAAIXswZ2G")
                EndSwitch
            ElseIf($Secondary == 5) Then ;El/Mes
                Switch $Level
                    Case 10 ;45pts - 155rem
                        LoadSkillTemplate("OgVDMlWcB0CAKIXswAAA")
                    Case 11
                        LoadSkillTemplate("OgVDMkecB0CAKIXswAAA")
                    Case 12
                        LoadSkillTemplate("OgVDMmecB0CAKIXswAAA")
                    Case 13 ;75pts - 125rem
                        LoadSkillTemplate("OgVDMniMB0CAKIXswAAA")
                    Case 14
                        LoadSkillTemplate("OgVDMmmcB0CAKIXswAAA")
                    Case 15
                        LoadSkillTemplate("OgVDMlm8B0CAKIXswAAA")
                    Case 16 ;110pts - 90rem
                        LoadSkillTemplate("OgVDMomsB0CAKIXswAAA")
                    Case 17
                        LoadSkillTemplate("OgVDMnmcC0CAKIXswAAA")
                    Case 18
                        LoadSkillTemplate("OgVDMomcC0CAKIXswAAA")
                    Case 19 ;155pts - 45rem
                        LoadSkillTemplate("OgVDMpqMC0CAKIXswAAA")
                    Case 20 ;170pts - 30rem
                        LoadSkillTemplate("OgVDMpqsC0CAKIXswAAA")
                EndSwitch
            EndIf
        EndIf
    Else
        MsgBox(16, "PreFarmer_Bot", "Unable to get your level.")
            _exit()
    EndIf
EndFunc

Func AutonomousCasting() ;Decide which skill to cast a the moment based on player's health and build
    Local $BoolCast
    Local $HealthHP
    $HealthHP = ((GetHealth(-2)) * 100/(DllStructGetData(GetAgentByID(-2), 'MaxHP')))

    If ($HealthHP < 75) Then ;If player's health is under 75%
        CastSkillFromBuild(0)
    Else
        $BoolCast = Random(1,2,1)
        If $BoolCast Then CastSkillFromBuild(1)
        If $BoolCast Then CastSkillFromBuild(2)
    EndIf

	If Check_RangerPet_Dead() Then CastSkillFromBuild(3) ;Revive ranger pet if present and it's dead
EndFunc

Func CastSkillFromBuild($type = 1) ;Cast a skill ($type: 0=Heal 1=Damage 2=Buff 3=HealPet)
    Local $Primary = GetAgentPrimaryProfession(-2)
    Local $Secondary = GetAgentSecondaryProfession(-2)
    Local $SkillToCast = 1
    Local $LDoACast = False
	Local $CustomCast = False
	Local $lAgentMe = GetMyID()

    If($Primary == 0) Then
        MsgBox(16, "PreFarmer_Bot", "Unable to get your primary profession.")
        _exit()
    EndIf

	If (CustomBuild_Status()) Then
		$CustomCast = Custom_CastSkillFromBuild($type)
		If ($CustomCast) Then Return
	EndIf

    If (LDoASurvivor_Status()) Then
        $LDoACast = LDoA_CastSkillFromBuild($Primary, $Secondary, $type)
        If ($LDoACast) Then Return
    EndIf

    If($Primary == 1) Then ;W
		If ($Secondary == 0) Then ; W only
			If ($type == 2) Then ($type = 1)
			If ($type == 0) Then
				$SkillToCast = 1 ;Healing Signet (W tactic : cost 0, CTime 2s, cd 4s)
				CastSkill($SkillToCast, -2)
			ElseIf ($type == 1) Then
				$SkillToCast = Random(5,6,1)
				TargetNearestEnemy()
				Attack(-1)
                Switch $SkillToCast
                    Case 5 ;Cyclone Axe (W Axe : cost 5nrg, CTime 0, cd 4s)
                        If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast,-1,$Adjacent)
                    Case 6 ;Executioner's Strike (W Axe : cost 8adr, CTime 0, cd 0)
                        CastSkill($SkillToCast,-1)
                EndSwitch
			EndIf
        ElseIf($Secondary == 2) Then ;W/R
            If ($type == 2) Then ($type = 1)
            If ($type == 0) Then
                $SkillToCast = Random(1,2,1)
                Switch $SkillToCast
                    Case 1 ;Troll Unguent (R Wilderness Survival : cost 5nrg, CTime 3s, cd 10s)
                        If ((GetEffectTimeRemaining($Troll_Unguent) < 3000) OR Not (_HasEffect($Troll_Unguent))) Then
                            If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast, -2)
                        EndIf
                    Case 2 ;Healing Signet (W tactic : cost 0, CTime 2s, cd 4s)
                        CastSkill($SkillToCast, -2)
                EndSwitch
            ElseIf ($type == 1) Then
                $SkillToCast = Random(5,6,1)
                TargetNearestEnemy()
                Attack(-1)
                Switch $SkillToCast
                    Case 5 ;Cyclone Axe (W Axe : cost 5nrg, CTime 0, cd 4s)
                        If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast,-1,$Adjacent)
                    Case 6 ;Executioner's Strike (W Axe : cost 8adr, CTime 0, cd 0)
                        CastSkill($SkillToCast,-1)
                EndSwitch
            ElseIf ($type == 3) Then
                $SkillToCast = 5 ;Comfort Animal (R Beast mastery : cost 5nrg, CTime 1s, cd 1s)
                If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast)
            EndIf
        ElseIf($Secondary == 3) Then ;W/Mo
            If ($type == 2) Then ($type = 1)
            If ($type == 0) Then
                $SkillToCast = Random(1,3,1)
                Switch $SkillToCast
                    Case 1 ;Healing Breeze (Mo Heal : cost 10nrg, CTime 1s, cd 5s)
                        If ((GetEffectTimeRemaining($Healing_Breeze) < 1000) OR Not (_HasEffect($Healing_Breeze))) Then
                            If (GetEnergy($lAgentMe) >= 10) Then CastSkill($SkillToCast, -2)
                        EndIf
                    Case 2 ;Healing Signet (W tactic : cost 0, CTime 2s, cd 4s)
                        CastSkill($SkillToCast, -2)
                    Case 3 ;Orison of Healing (Mo Healing : cost 5nrg, CTime 1s, cd 2s)
                        If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast, -2)
                EndSwitch
            ElseIf ($type == 1) Then
                $SkillToCast = Random(5,8,1)
                TargetNearestEnemy()
                Attack(-1)
                Switch $SkillToCast
                    Case 5,6
                    ;5: Cyclone Axe (W Axe : cost 5nrg, CTime 0, cd 4s)
                    ;6: Symbol of Warth (Mo smit : cost 5nrg, CTime 2s, cd 30s)
                        If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast,-1,$Adjacent)
                    Case 7 ;Banish (Mo smit : cost 5nrg, CTime 1s, cd 10s)
                        If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast,-1)
                    Case 8 ;Bane Signet (Mo smit : cost 0, CTime 1s, cd 20s)
                        CastSkill($SkillToCast,-1)
                EndSwitch
            EndIf
        ElseIf($Secondary == 4) Then ;W/N
            If ($type == 2) Then ($type = 1)
            If ($type == 0) Then
                $SkillToCast = Random(1,2,1)
                Switch $SkillToCast
                    Case 1 ;Vampiric Gaze (N Blood magic : cost 10nrg, CTime 1s, cd 8s)
                        $SkillToCast = 7
                        TargetNearestEnemy()
                        Attack(-1)
                        If (GetEnergy($lAgentMe) >= 10) Then CastSkill($SkillToCast, -1)
                    Case 2 ;Healing Signet (W tactic : cost 0, CTime 2s, cd 4s)
                        CastSkill($SkillToCast, -2)
                EndSwitch
            ElseIf ($type == 1) Then
                $SkillToCast = Random(5,8,1)
                TargetNearestEnemy()
                Attack(-1)
                Switch $SkillToCast
                    Case 5 ;Cyclone Axe (W Axe : cost 5nrg, CTime 0, cd 4s)
                        If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast,-1,$Adjacent)
                    Case 6 ;Executioner's Strike (W Axe : cost 8adr, CTime 0, cd 0)
                        CastSkill($SkillToCast,-1)
                    Case 7 ;Vampiric Gaze (N Blood Magic : cost 10nrg, CTime 1s, cd 8s)
                        If (GetEnergy($lAgentMe) >= 10) Then CastSkill($SkillToCast, -1)
                    Case 8 ;Life Siphon (N Blood Magic : cost 10nrg, CTime 1s, cd 5s)
                        If (GetEnergy($lAgentMe) >= 10) Then CastSkill($SkillToCast, -1)
                EndSwitch
            EndIf
        ElseIf($Secondary == 5) Then ;W/Mes
            If ($type == 2) Then ($type = 1)
            If ($type == 0) Then
                $SkillToCast = Random(1,2,1)
                Switch $SkillToCast
                    Case 1 ;Ether Feast (Mes Inspiration Magic : cost 5nrg, CTime 1s, cd 8s)
                        TargetNearestEnemy()
                        Attack(-1)
                        If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast, -1)
                    Case 2 ;Healing Signet (W tactic : cost 0, CTime 2s, cd 4s)
                        CastSkill($SkillToCast, -2)
                EndSwitch
            ElseIf ($type == 1) Then
                $SkillToCast = Random(5,7,1)
                TargetNearestEnemy()
                Attack(-1)
                Switch $SkillToCast
                    Case 5 ;Cyclone Axe (W Axe : cost 5nrg, CTime 0, cd 4s)
                        If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast,-1,$Adjacent)
                    Case 6 ;Executioner's Strike (W Axe : cost 8adr, CTime 0, cd 0)
                        CastSkill($SkillToCast,-1)
                    Case 7 ;Conjure Phantasm (Mes Illusion Magic : cost 10nrg, CTime 1s, cd 5s)
                        If (GetEnergy($lAgentMe) >= 10) Then CastSkill($SkillToCast, -1)
                    Case 8 ;Shatter Delusions (Mes Domination Magic : cost 5nrg, CTime 1/4s, cd 6s)
                        If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast, -1)
                EndSwitch
            EndIf
        ElseIf($Secondary == 6) Then ;W/El
            If ($type == 0) Then
                $SkillToCast = 2 ;Healing Signet (W tactic : cost 0, CTime 2s, cd 4s)
                CastSkill($SkillToCast, -2)
            ElseIf ($type == 1) Then
                $SkillToCast = Random(5,8,1)
                TargetNearestEnemy()
                Attack(-1)
                Switch $SkillToCast
                    Case 5 ;Cyclone Axe (W Axe : cost 5nrg, CTime 0, cd 4s)
                        If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast,-1,$Adjacent)
                    Case 6 ;Executioner's Strike (W Axe : cost 8adr, CTime 0, cd 0)
                        CastSkill($SkillToCast,-1)
                    Case 7 ;Fire Storm (El Fire magic : cost 10nrg, CTime 2s, cd 20s)
                        If (GetEnergy($lAgentMe) >= 10) Then CastSkill($SkillToCast, -1)
                    Case 8 ;Flare (El Fire Magic : cost 5nrg, CTime 1s, cd 0)
                        If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast, -1)
                EndSwitch
            ElseIf ($type == 2) Then
                $SkillToCast = 1 ;Aura of Restoration (El Energy Storage : cost 5nrg, CTime 1/4s, cd 20s)
                If ((GetEffectTimeRemaining($Aura_of_Restoration) < 250) OR Not (_HasEffect($Aura_of_Restoration))) Then
                    If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast, -2)
                EndIf
            EndIf
        EndIf
    ElseIf($Primary == 2) Then ;R
		If ($Secondary == 0) Then ;R only
			If ($type == 2) Then ($type = 1)
            If ($type == 0) Then
                $SkillToCast = 1 ;Troll Unguent (R Wilderness Survival : cost 5nrg, CTime 3s, cd 10s)
                If ((GetEffectTimeRemaining($Troll_Unguent) < 3000) OR Not (_HasEffect($Troll_Unguent))) Then
                    If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast, -2)
                EndIf
            ElseIf ($type == 1) Then
                $SkillToCast = Random(5,7,1)
                TargetNearestEnemy()
                Attack(-1)
                Switch $SkillToCast
                    Case 5 ;Power Shot (R marksmanship : cost 10nrg, CTime 0, cd 3s)
                        If (GetEnergy($lAgentMe) >= 10) Then CastSkill($SkillToCast, -1)
                    Case 6 ;Point Blank Shot (R Expertise : cost 5nrg, CTime 0, cd 3s)
                        If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast, -1)
                    Case 7 ;Dual Shot (R none : cost 10nrg, CTime 0, cd 10s)
                        If (GetEnergy($lAgentMe) >= 10) Then CastSkill($SkillToCast, -1)
                EndSwitch
            ElseIf ($type == 3) Then
                $SkillToCast = 4 ;Comfort Animal (R Beast mastery : cost 5nrg, CTime 1s, cd 1s)
                If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast)
            EndIf
        ElseIf($Secondary == 1) Then ;R/W
            If ($type == 2) Then ($type = 1)
            If ($type == 0) Then
                $SkillToCast = Random(1,2,1)
                Switch $SkillToCast
                    Case 1 ;Troll Unguent (R Wilderness Survival : cost 5nrg, CTime 3s, cd 10s)
                        If ((GetEffectTimeRemaining($Troll_Unguent) < 3000) OR Not (_HasEffect($Troll_Unguent))) Then
                            If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast, -2)
                        EndIf
                    Case 2 ;Healing Signet (W tactic : cost 0, CTime 2s, cd 4s)
                        CastSkill($SkillToCast, -2)
                EndSwitch
            ElseIf ($type == 1) Then
                $SkillToCast = Random(5,7,1)
                TargetNearestEnemy()
                Attack(-1)
                Switch $SkillToCast
                    Case 5 ;Power Shot (R marksmanship : cost 10nrg, CTime 0, cd 3s)
                        If (GetEnergy($lAgentMe) >= 10) Then CastSkill($SkillToCast, -1)
                    Case 6 ;Point Blank Shot (R Expertise : cost 5nrg, CTime 0, cd 3s)
                        If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast, -1)
                    Case 7 ;Dual Shot (R none : cost 10nrg, CTime 0, cd 10s)
                        If (GetEnergy($lAgentMe) >= 10) Then CastSkill($SkillToCast, -1)
                EndSwitch
            ElseIf ($type == 3) Then
                $SkillToCast = 4 ;Comfort Animal (R Beast mastery : cost 5nrg, CTime 1s, cd 1s)
                If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast)
            EndIf
        ElseIf($Secondary == 3) Then ;R/Mo
            If ($type == 2) Then ($type = 1)
            If ($type == 0) Then
                $SkillToCast = Random(1,3,1)
                Switch $SkillToCast
                    Case 1 ;Troll Unguent (R Wilderness Survival : cost 5nrg, CTime 3s, cd 10s)
                        If ((GetEffectTimeRemaining($Troll_Unguent) < 3000) OR Not (_HasEffect($Troll_Unguent))) Then
                            If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast, -2)
                        EndIf
                    Case 2 ;Healing Breeze (Mo Heal : cost 10nrg, CTime 1s, cd 5s)
                        If ((GetEffectTimeRemaining($Healing_Breeze) < 1000) OR Not (_HasEffect($Healing_Breeze))) Then
                            If (GetEnergy($lAgentMe) >= 10) Then CastSkill($SkillToCast, -2)
                        EndIf
                    Case 3 ;Orison of Healing (Mo Healing : cost 5nrg, CTime 1s, cd 2s)
                        If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast, -2)
                EndSwitch
            ElseIf ($type == 1) Then
                $SkillToCast = Random(5,8,1)
                TargetNearestEnemy()
                Attack(-1)
                Switch $SkillToCast
                    Case 5 ;Power Shot (R marksmanship : cost 10nrg, CTime 0, cd 3s)
                        If (GetEnergy($lAgentMe) >= 10) Then CastSkill($SkillToCast, -1)
                    Case 6 ;Point Blank Shot (R Expertise : cost 5nrg, CTime 0, cd 3s)
                        If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast, -1)
                    Case 7 ;Banish (Mo smit : cost 5nrg, CTime 1s, cd 10s)
                        If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast,-1)
                    Case 8 ;Bane Signet (Mo smit : cost 0, CTime 1s, cd 20s)
                        CastSkill($SkillToCast,-1)
                EndSwitch
            ElseIf ($type == 3) Then
                $SkillToCast = 4 ;Comfort Animal (R Beast mastery : cost 5nrg, CTime 1s, cd 1s)
                If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast)
            EndIf
        ElseIf($Secondary == 4) Then ;R/N
            If ($type == 2) Then ($type = 1)
            If ($type == 0) Then
                $SkillToCast = Random(1,2,1)
                Switch $SkillToCast
                    Case 1 ;Troll Unguent (R Wilderness Survival : cost 5nrg, CTime 3s, cd 10s)
                        If ((GetEffectTimeRemaining($Troll_Unguent) < 3000) OR Not (_HasEffect($Troll_Unguent))) Then
                            If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast, -2)
                        EndIf
                    Case 2 ;Vampiric Gaze (N Blood magic : cost 10nrg, CTime 1s, cd 8s)
                        $SkillToCast = 7
                        TargetNearestEnemy()
                        Attack(-1)
                        If (GetEnergy($lAgentMe) >= 10) Then CastSkill($SkillToCast, -1)
                EndSwitch
            ElseIf ($type == 1) Then
                $SkillToCast = Random(5,8,1)
                TargetNearestEnemy()
                Attack(-1)
                Switch $SkillToCast
                    Case 5 ;Power Shot (R marksmanship : cost 10nrg, CTime 0, cd 3s)
                        If (GetEnergy($lAgentMe) >= 10) Then CastSkill($SkillToCast, -1)
                    Case 6 ;Point Blank Shot (R Expertise : cost 5nrg, CTime 0, cd 3s)
                        If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast, -1)
                    Case 7 ;Vampiric Gaze (N Blood Magic : cost 10nrg, CTime 1s, cd 8s)
                        If (GetEnergy($lAgentMe) >= 10) Then CastSkill($SkillToCast, -1)
                    Case 8 ;Life Siphon (N Blood Magic : cost 10nrg, CTime 1s, cd 5s)
                        If (GetEnergy($lAgentMe) >= 10) Then CastSkill($SkillToCast, -1)
                EndSwitch
            ElseIf ($type == 3) Then
                $SkillToCast = 4 ;Comfort Animal (R Beast mastery : cost 5nrg, CTime 1s, cd 1s)
                If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast)
            EndIf
        ElseIf($Secondary == 5) Then ;R/Mes
            If ($type == 2) Then ($type = 1)
            If ($type == 0) Then
                $SkillToCast = Random(1,2,1)
                Switch $SkillToCast
                    Case 1 ;Troll Unguent (R Wilderness Survival : cost 5nrg, CTime 3s, cd 10s)
                        If ((GetEffectTimeRemaining($Troll_Unguent) < 3000) OR Not (_HasEffect($Troll_Unguent))) Then
                            If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast, -2)
                        EndIf
                    Case 2 ;Ether Feast (Mes Inspiration Magic : cost 5nrg, CTime 1s, cd 8s)
                        TargetNearestEnemy()
                        Attack(-1)
                        If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast, -1)
                EndSwitch
            ElseIf ($type == 1) Then
                $SkillToCast = Random(5,7,1)
                TargetNearestEnemy()
                Attack(-1)
                Switch $SkillToCast
                    Case 5 ;Power Shot (R marksmanship : cost 10nrg, CTime 0, cd 3s)
                        If (GetEnergy($lAgentMe) >= 10) Then CastSkill($SkillToCast, -1)
                    Case 6 ;Point Blank Shot (R Expertise : cost 5nrg, CTime 0, cd 3s)
                        If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast, -1)
                    Case 7 ;Dual Shot (R none : cost 10nrg, CTime 0, cd 10s)
                        If (GetEnergy($lAgentMe) >= 10) Then CastSkill($SkillToCast, -1)
                EndSwitch
            ElseIf ($type == 3) Then
                $SkillToCast = 4 ;Comfort Animal (R Beast mastery : cost 5nrg, CTime 1s, cd 1s)
                If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast)
            EndIf
        ElseIf($Secondary == 6) Then ;R/El
            If ($type == 0) Then
                $SkillToCast = 2
                If ((GetEffectTimeRemaining($Troll_Unguent) < 3000) OR Not (_HasEffect($Troll_Unguent))) Then
                    If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast, -2)
                EndIf
            ElseIf ($type == 1) Then
                $SkillToCast = Random(5,8,1)
                TargetNearestEnemy()
                Attack(-1)
                Switch $SkillToCast
                    Case 5 ;Power Shot (R marksmanship : cost 10nrg, CTime 0, cd 3s)
                        If (GetEnergy($lAgentMe) >= 10) Then CastSkill($SkillToCast, -1)
                    Case 6 ;Point Blank Shot (R Expertise : cost 5nrg, CTime 0, cd 3s)
                        If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast, -1)
                    Case 7 ;Fire Storm (El Fire magic : cost 10nrg, CTime 2s, cd 20s)
                        If (GetEnergy($lAgentMe) >= 10) Then CastSkill($SkillToCast, -1)
                    Case 8 ;Flare (El Fire Magic : cost 5nrg, CTime 1s, cd 0)
                        If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast, -1)
                EndSwitch
            ElseIf ($type == 2) Then
                $SkillToCast = 1
                If ((GetEffectTimeRemaining($Aura_of_Restoration) < 250) OR Not (_HasEffect($Aura_of_Restoration))) Then
                    If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast, -2)
                EndIf
            ElseIf ($type == 3) Then
                $SkillToCast = 4 ;Comfort Animal (R Beast mastery : cost 5nrg, CTime 1s, cd 1s)
                If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast)
            EndIf
        EndIf
    ElseIf($Primary == 3) Then ;Mo
		If ($Secondary == 0) Then ;Mo only
			If ($type == 2) Then ($type = 1)
            If ($type == 0) Then
                $SkillToCast = Random(1,2,1)
                Switch $SkillToCast
                    Case 1 ;Healing Breeze (Mo Heal : cost 10nrg, CTime 1s, cd 5s)
                        If ((GetEffectTimeRemaining($Healing_Breeze) < 1000) OR Not (_HasEffect($Healing_Breeze))) Then
                            If (GetEnergy($lAgentMe) >= 10) Then CastSkill($SkillToCast, -2)
                        EndIf
                    Case 2 ;Orison of Healing (Mo Healing : cost 5nrg, CTime 1s, cd 2s)
                        If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast, -2)
                EndSwitch
            ElseIf ($type == 1) Then
                $SkillToCast = Random(5,7,1)
                TargetNearestEnemy()
                Attack(-1)
                Switch $SkillToCast
                    Case 5 ;Symbol of Warth (Mo smit : cost 5nrg, CTime 2s, cd 30s)
                        If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast,-1,$Adjacent)
                    Case 6 ;Banish (Mo smit : cost 5nrg, CTime 1s, cd 10s)
                        If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast,-1)
                    Case 7 ;Bane Signet (Mo smit : cost 0, CTime 1s, cd 20s)
                        CastSkill($SkillToCast,-1)
                EndSwitch
            EndIf
        ElseIf($Secondary == 1) Then ;Mo/W
            If ($type == 2) Then ($type = 1)
            If ($type == 0) Then
                $SkillToCast = Random(1,2,1)
                Switch $SkillToCast
                    Case 1 ;Healing Breeze (Mo Heal : cost 10nrg, CTime 1s, cd 5s)
                        If ((GetEffectTimeRemaining($Healing_Breeze) < 1000) OR Not (_HasEffect($Healing_Breeze))) Then
                            If (GetEnergy($lAgentMe) >= 10) Then CastSkill($SkillToCast, -2)
                        EndIf
                    Case 2 ;Orison of Healing (Mo Healing : cost 5nrg, CTime 1s, cd 2s)
                        If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast, -2)
                EndSwitch
            ElseIf ($type == 1) Then
                $SkillToCast = Random(5,8,1)
                TargetNearestEnemy()
                Attack(-1)
                Switch $SkillToCast
                    Case 5 ;Cyclone Axe (W Axe : cost 5nrg, CTime 0, cd 4s)
                        If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast,-1,$Adjacent)
                    Case 6 ;Symbol of Warth (Mo smit : cost 5nrg, CTime 2s, cd 30s)
                        If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast,-1,$Adjacent)
                    Case 7 ;Banish (Mo smit : cost 5nrg, CTime 1s, cd 10s)
                        If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast,-1)
                    Case 8 ;Bane Signet (Mo smit : cost 0, CTime 1s, cd 20s)
                        CastSkill($SkillToCast,-1)
                EndSwitch
            EndIf
        ElseIf($Secondary == 2) Then ;Mo/R
            If ($type == 2) Then ($type = 1)
            If ($type == 0) Then
                $SkillToCast = Random(1,3,1)
                Switch $SkillToCast
                    Case 1 ;Troll Unguent (R Wilderness Survival : cost 5nrg, CTime 3s, cd 10s)
                        If ((GetEffectTimeRemaining($Troll_Unguent) < 3000) OR Not (_HasEffect($Troll_Unguent))) Then
                            If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast, -2)
                        EndIf
                    Case 2 ;Healing Breeze (Mo Heal : cost 10nrg, CTime 1s, cd 5s)
                        If ((GetEffectTimeRemaining($Healing_Breeze) < 1000) OR Not (_HasEffect($Healing_Breeze))) Then
                            If (GetEnergy($lAgentMe) >= 10) Then CastSkill($SkillToCast, -2)
                        EndIf
                    Case 3 ;Orison of Healing (Mo Healing : cost 5nrg, CTime 1s, cd 2s)
                        If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast, -2)
                EndSwitch
            ElseIf ($type == 1) Then
                $SkillToCast = Random(5,7,1)
                TargetNearestEnemy()
                Attack(-1)
                Switch $SkillToCast
                    Case 5 ;Symbol of Warth (Mo smit : cost 5nrg, CTime 2s, cd 30s)
                        If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast,-1,$Adjacent)
                    Case 6 ;Banish (Mo smit : cost 5nrg, CTime 1s, cd 10s)
                        If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast,-1)
                    Case 7 ;Bane Signet (Mo smit : cost 0, CTime 1s, cd 20s)
                        CastSkill($SkillToCast,-1)
                EndSwitch
            ElseIf ($type == 3) Then
                $SkillToCast = 4 ;Comfort Animal (R Beast mastery : cost 5nrg, CTime 1s, cd 1s)
                If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast)
            EndIf
        ElseIf($Secondary == 4) Then ;Mo/N
            If ($type == 2) Then ($type = 1)
            If ($type == 0) Then
                $SkillToCast = Random(1,3,1)
                Switch $SkillToCast
                    Case 1 ;Healing Breeze (Mo Heal : cost 10nrg, CTime 1s, cd 5s)
                        If ((GetEffectTimeRemaining($Healing_Breeze) < 1000) OR Not (_HasEffect($Healing_Breeze))) Then
                            If (GetEnergy($lAgentMe) >= 10) Then CastSkill($SkillToCast, -2)
                        EndIf
                    Case 2 ;Orison of Healing (Mo Healing : cost 5nrg, CTime 1s, cd 2s)
                        If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast, -2)
                    Case 3 ;Vampiric Gaze (N Blood magic : cost 10nrg, CTime 1s, cd 8s)
                        $SkillToCast = 8
                        TargetNearestEnemy()
                        Attack(-1)
                        If (GetEnergy($lAgentMe) >= 10) Then CastSkill($SkillToCast, -1)
                EndSwitch
            ElseIf ($type == 1) Then
                $SkillToCast = Random(5,8,1)
                TargetNearestEnemy()
                Attack(-1)
                Switch $SkillToCast
                    Case 5 ;Symbol of Warth (Mo smit : cost 5nrg, CTime 2s, cd 30s)
                        If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast,-1,$Adjacent)
                    Case 6 ;Banish (Mo smit : cost 5nrg, CTime 1s, cd 10s)
                        If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast,-1)
                    Case 7 ;Bane Signet (Mo smit : cost 0, CTime 1s, cd 20s)
                        CastSkill($SkillToCast,-1)
                    Case 8 ;Vampiric Gaze (N Blood magic : cost 10nrg, CTime 1s, cd 8s)
                        TargetNearestEnemy()
                        Attack(-1)
                        If (GetEnergy($lAgentMe) >= 10) Then CastSkill($SkillToCast, -1)
                EndSwitch
            EndIf
        ElseIf($Secondary == 5) Then ;Mo/Mes
            If ($type == 2) Then ($type = 1)
            If ($type == 0) Then
                $SkillToCast = Random(1,3,1)
                Switch $SkillToCast
                    Case 1 ;Healing Breeze (Mo Heal : cost 10nrg, CTime 1s, cd 5s)
                        If ((GetEffectTimeRemaining($Healing_Breeze) < 1000) OR Not (_HasEffect($Healing_Breeze))) Then
                            If (GetEnergy($lAgentMe) >= 10) Then CastSkill($SkillToCast, -2)
                        EndIf
                    Case 2 ;Orison of Healing (Mo Healing : cost 5nrg, CTime 1s, cd 2s)
                        If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast, -2)
                    Case 3 ;Ether Feast (Mes Inspiration Magic : cost 5nrg, CTime 1s, cd 8s)
                        TargetNearestEnemy()
                        Attack(-1)
                        If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast, -1)
                EndSwitch
            ElseIf ($type == 1) Then
                $SkillToCast = Random(5,7,1)
                TargetNearestEnemy()
                Attack(-1)
                Switch $SkillToCast
                    Case 5 ;Banish (Mo smit : cost 5nrg, CTime 1s, cd 10s)
                        If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast,-1)
                    Case 6 ;Bane Signet (Mo smit : cost 0, CTime 1s, cd 20s)
                        CastSkill($SkillToCast,-1)
                    Case 7
                    ;7: Conjure Phantasm (Mes Illusion Magic : cost 10nrg, CTime 1s, cd 5s)
                    ;8: Shatter Deslusions (Mes Domination Magic : cost 5nrg, CTime 1/4s, cd 6s)
                        If (GetEnergy($lAgentMe) >= 10) Then CastSkill($SkillToCast,-1)
                        If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast+1,-1)
                EndSwitch
            EndIf
        ElseIf($Secondary == 6) Then ;Mo/El
            If ($type == 0) Then
                $SkillToCast = Random(2,3,1)
                Switch $SkillToCast
                    Case 2 ;Healing Breeze (Mo Heal : cost 10nrg, CTime 1s, cd 5s)
                        If ((GetEffectTimeRemaining($Healing_Breeze) < 1000) OR Not (_HasEffect($Healing_Breeze))) Then
                            If (GetEnergy($lAgentMe) >= 10) Then CastSkill($SkillToCast, -2)
                        EndIf
                    Case 3 ;Orison of Healing (Mo Healing : cost 5nrg, CTime 1s, cd 2s)
                        If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast, -2)
                EndSwitch
            ElseIf ($type == 1) Then
                $SkillToCast = Random(5,8,1)
                TargetNearestEnemy()
                Attack(-1)
                Switch $SkillToCast
                    Case 5 ;Banish (Mo smit : cost 5nrg, CTime 1s, cd 10s)
                        If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast,-1)
                    Case 6 ;Bane Signet (Mo smit : cost 0, CTime 1s, cd 20s)
                        CastSkill($SkillToCast,-1)
                    Case 7 ;Fire Storm (El Fire magic : cost 10nrg, CTime 2s, cd 20s)
                        If (GetEnergy($lAgentMe) >= 10) Then CastSkill($SkillToCast, -1)
                    Case 8 ;Flare (El Fire Magic : cost 5nrg, CTime 1s, cd 0)
                        If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast, -1)
                EndSwitch
            ElseIf ($type == 2) Then
                $SkillToCast = 1
                If ((GetEffectTimeRemaining($Aura_of_Restoration) < 250) OR Not (_HasEffect($Aura_of_Restoration))) Then
                    If (GetEnergy($lAgentMe) > 5) Then CastSkill($SkillToCast, -2)
                EndIf
            EndIf
        EndIf
    ElseIf($Primary == 4) Then ;N
		If ($Secondary == 0) Then ;N only
			If ($type == 2) Then ($type = 1)
            If ($type == 0) Then
                $SkillToCast = 7 ;Vampiric Gaze (N Blood magic : cost 10nrg, CTime 1s, cd 8s)
                TargetNearestEnemy()
                Attack(-1)
                If (GetEnergy($lAgentMe) >= 10) Then CastSkill($SkillToCast, -1)
            ElseIf ($type == 1) Then
                $SkillToCast = Random(5,8,1)
                TargetNearestEnemy()
                Attack(-1)
                Switch $SkillToCast
                    Case 5 ;Faintheartedness (N Curse : cost 10nrg, CTime 1s, cd 8s)
                        If (GetEnergy($lAgentMe) >= 10) Then CastSkill($SkillToCast, -1)
                    Case 6 ;Life Siphon (N Blood Magic : cost 10nrg, CTime 1s, cd 5s)
                        If (GetEnergy($lAgentMe) >= 10) Then CastSkill($SkillToCast, -1)
                    Case 7 ;Vampiric Gaze (N Blood Magic : cost 10nrg, CTime 1s, cd 8s)
                        If (GetEnergy($lAgentMe) >= 10) Then CastSkill($SkillToCast, -1)
                    Case 8 ;Deathly Swarm (N Death Magic : cost 10nrg, CTime 2s, cd 6s)
                        If (GetEnergy($lAgentMe) >= 10) Then CastSkill($SkillToCast, -1)
                EndSwitch
            EndIf
        ElseIf($Secondary == 1) Then ;N/W
            If ($type == 2) Then ($type = 1)
            If ($type == 0) Then
                $SkillToCast = Random(1,2,1)
                Switch $SkillToCast
                    Case 1 ;Healing Signet (W tactic : cost 0, CTime 2s, cd 4s)
                        CastSkill($SkillToCast, -2)
                    Case 2 ;Vampiric Gaze (N Blood magic : cost 10nrg, CTime 1s, cd 8s)
                        $SkillToCast = 7
                        TargetNearestEnemy()
                        Attack(-1)
                        If (GetEnergy($lAgentMe) >= 10) Then CastSkill($SkillToCast, -1)
                EndSwitch
            ElseIf ($type == 1) Then
                $SkillToCast = Random(5,8,1)
                TargetNearestEnemy()
                Attack(-1)
                Switch $SkillToCast
                    Case 5 ;Faintheartedness (N Curse : cost 10nrg, CTime 1s, cd 8s)
                        If (GetEnergy($lAgentMe) >= 10) Then CastSkill($SkillToCast, -1)
                    Case 6 ;Life Siphon (N Blood Magic : cost 10nrg, CTime 1s, cd 5s)
                        If (GetEnergy($lAgentMe) >= 10) Then CastSkill($SkillToCast, -1)
                    Case 7 ;Vampiric Gaze (N Blood Magic : cost 10nrg, CTime 1s, cd 8s)
                        If (GetEnergy($lAgentMe) >= 10) Then CastSkill($SkillToCast, -1)
                    Case 8 ;Deathly Swarm (N Death Magic : cost 10nrg, CTime 2s, cd 6s)
                        If (GetEnergy($lAgentMe) >= 10) Then CastSkill($SkillToCast, -1)
                EndSwitch
            EndIf
        ElseIf($Secondary == 2) Then ;N/R
            If ($type == 2) Then ($type = 1)
            If ($type == 0) Then
                $SkillToCast = Random(1,2,1)
                Switch $SkillToCast
                    Case 1 ;Troll Unguent (R Wilderness Survival : cost 5nrg, CTime 3s, cd 10s)
                        If ((GetEffectTimeRemaining($Troll_Unguent) < 3000) OR Not (_HasEffect($Troll_Unguent))) Then
                            If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast, -2)
                        EndIf
                    Case 2 ;Vampiric Gaze (N Blood magic : cost 10nrg, CTime 1s, cd 8s)
                        $SkillToCast = 7
                        TargetNearestEnemy()
                        Attack(-1)
                        If (GetEnergy($lAgentMe) >= 10) Then CastSkill($SkillToCast, -1)
                EndSwitch
            ElseIf ($type == 1) Then
                $SkillToCast = Random(5,8,1)
                TargetNearestEnemy()
                Attack(-1)
                Switch $SkillToCast
                    Case 5 ;Faintheartedness (N Curse : cost 10nrg, CTime 1s, cd 8s)
                        If (GetEnergy($lAgentMe) >= 10) Then CastSkill($SkillToCast, -1)
                    Case 6 ;Life Siphon (N Blood Magic : cost 10nrg, CTime 1s, cd 5s)
                        If (GetEnergy($lAgentMe) >= 10) Then CastSkill($SkillToCast, -1)
                    Case 7 ;Vampiric Gaze (N Blood Magic : cost 10nrg, CTime 1s, cd 8s)
                        If (GetEnergy($lAgentMe) >= 10) Then CastSkill($SkillToCast, -1)
                    Case 8 ;Deathly Swarm (N Death Magic : cost 10nrg, CTime 2s, cd 6s)
                        If (GetEnergy($lAgentMe) >= 10) Then CastSkill($SkillToCast, -1)
                EndSwitch
            ElseIf ($type == 3) Then
                $SkillToCast = 4 ;Comfort Animal (R Beast mastery : cost 5nrg, CTime 1s, cd 1s)
                If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast)
            EndIf
        ElseIf($Secondary == 3) Then ;N/Mo
            If ($type == 2) Then ($type = 1)
            If ($type == 0) Then
                $SkillToCast = Random(1,3,1)
                Switch $SkillToCast
                    Case 1 ;Healing Breeze (Mo Heal : cost 10nrg, CTime 1s, cd 5s)
                        If ((GetEffectTimeRemaining($Healing_Breeze) < 1000) OR Not (_HasEffect($Healing_Breeze))) Then
                            If (GetEnergy($lAgentMe) >= 10) Then CastSkill($SkillToCast, -2)
                        EndIf
                    Case 2 ;Orison of Healing (Mo Healing : cost 5nrg, CTime 1s, cd 2s)
                        If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast, -2)
                    Case 3 ;Vampiric Gaze (N Blood magic : cost 10nrg, CTime 1s, cd 8s)
                        $SkillToCast = 6
                        TargetNearestEnemy()
                        Attack(-1)
                        If (GetEnergy($lAgentMe) >= 10) Then CastSkill($SkillToCast, -1)
                EndSwitch
            ElseIf ($type == 1) Then
                $SkillToCast = Random(5,8,1)
                TargetNearestEnemy()
                Attack(-1)
                Switch $SkillToCast
                    Case 5 ;Life Siphon (N Blood Magic : cost 10nrg, CTime 1s, cd 5s)
                        If (GetEnergy($lAgentMe) >= 10) Then CastSkill($SkillToCast, -1)
                    Case 6 ;Vampiric Gaze (N Blood magic : cost 10nrg, CTime 1s, cd 8s)
                        If (GetEnergy($lAgentMe) >= 10) Then CastSkill($SkillToCast, -1)
                    Case 7 ;Banish (Mo smit : cost 5nrg, CTime 1s, cd 10s)
                        If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast,-1)
                    Case 8 ;Bane Signet (Mo smit : cost 0, CTime 1s, cd 20s)
                        CastSkill($SkillToCast,-1)
                EndSwitch
            EndIf
        ElseIf($Secondary == 5) Then ;N/Mes
            If ($type == 2) Then ($type = 1)
            If ($type == 0) Then
                $SkillToCast = Random(1,2,1)
                Switch $SkillToCast
                    Case 1 ;Ether Feast (Mes Inspiration Magic : cost 5nrg, CTime 1s, cd 8s)
                        TargetNearestEnemy()
                        Attack(-1)
                        If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast, -1)
                    Case 2 ;Vampiric Gaze (N Blood magic : cost 10nrg, CTime 1s, cd 8s)
                        $SkillToCast = 6
                        TargetNearestEnemy()
                        Attack(-1)
                        If (GetEnergy($lAgentMe) >= 10) Then CastSkill($SkillToCast, -1)
                EndSwitch
            ElseIf ($type == 1) Then
                $SkillToCast = Random(5,7,1)
                TargetNearestEnemy()
                Attack(-1)
                Switch $SkillToCast
                    Case 5 ;Life Siphon (N Blood Magic : cost 10nrg, CTime 1s, cd 5s)
                        If (GetEnergy($lAgentMe) >= 10) Then CastSkill($SkillToCast, -1)
                    Case 6 ;Vampiric Gaze (N Blood magic : cost 10nrg, CTime 1s, cd 8s)
                        If (GetEnergy($lAgentMe) >= 10) Then CastSkill($SkillToCast, -1)
                    Case 7
                    ;7: Conjure Phantasm (Mes Illusion Magic : cost 10nrg, CTime 1s, cd 5s)
                    ;8: Shatter Deslusions (Mes Domination Magic : cost 5nrg, CTime 1/4s, cd 6s)
                        If (GetEnergy($lAgentMe) >= 10) Then CastSkill($SkillToCast,-1)
                        If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast+1,-1)
                EndSwitch
            EndIf
        ElseIf($Secondary == 6) Then ;N/El
            If ($type == 0) Then
                $SkillToCast = 6 ;Vampiric Gaze (N Blood magic : cost 10nrg, CTime 1s, cd 8s)
                TargetNearestEnemy()
                Attack(-1)
                If (GetEnergy($lAgentMe) >= 10) Then CastSkill($SkillToCast, -1)
            ElseIf ($type == 1) Then
                $SkillToCast = Random(5,8,1)
                TargetNearestEnemy()
                Attack(-1)
                Switch $SkillToCast
                    Case 5 ;Life Siphon (N Blood Magic : cost 10nrg, CTime 1s, cd 5s)
                        If (GetEnergy($lAgentMe) >= 10) Then CastSkill($SkillToCast, -1)
                    Case 6 ;Vampiric Gaze (N Blood magic : cost 10nrg, CTime 1s, cd 8s)
                        If (GetEnergy($lAgentMe) >= 10) Then CastSkill($SkillToCast, -1)
                    Case 7 ;Fire Storm (El Fire magic : cost 10nrg, CTime 2s, cd 20s)
                        If (GetEnergy($lAgentMe) >= 10) Then CastSkill($SkillToCast, -1)
                    Case 8 ;Flare (El Fire Magic : cost 5nrg, CTime 1s, cd 0)
                        If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast, -1)
                EndSwitch
            ElseIf ($type == 2) Then
                $SkillToCast = 1
                If ((GetEffectTimeRemaining($Aura_of_Restoration) < 250) OR Not (_HasEffect($Aura_of_Restoration))) Then
                    If (GetEnergy($lAgentMe) > 5) Then CastSkill($SkillToCast, -2)
                EndIf
            EndIf
        EndIf
    ElseIf($Primary == 5) Then ;Mes
		If ($Secondary == 0) Then ;Mes only
			If ($type == 2) Then ($type = 1)
            If ($type == 0) Then
                $SkillToCast = 1 ;Ether Feast (Mes Inspiration Magic : cost 5nrg, CTime 1s, cd 8s)
                TargetNearestEnemy()
                Attack(-1)
                If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast, -1)
            ElseIf ($type == 1) Then
                $SkillToCast = Random(5,6,1)
                TargetNearestEnemy()
                Attack(-1)
                Switch $SkillToCast
                    Case 5 ;Empathy (Domination Magic : cost 10nrg, CTime 2s, cd 10s)
                        If (GetEnergy($lAgentMe) >= 10) Then CastSkill($SkillToCast,-1)
                    Case 6
                    ;6: Conjure Phantasm (Mes Illusion Magic : cost 10nrg, CTime 1s, cd 5s)
                    ;7: Shatter Deslusions (Mes Domination Magic : cost 5nrg, CTime 1/4s, cd 6s)
                        If (GetEnergy($lAgentMe) >= 10) Then CastSkill($SkillToCast,-1)
                        If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast+1,-1)
                EndSwitch
            EndIf
        ElseIf($Secondary == 1) Then ;Mes/W
            If ($type == 2) Then ($type = 1)
            If ($type == 0) Then
                $SkillToCast = Random(1,2,1)
                Switch $SkillToCast
                    Case 1 ;Ether Feast (Mes Inspiration Magic : cost 5nrg, CTime 1s, cd 8s)
                        TargetNearestEnemy()
                        Attack(-1)
                        If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast, -1)
                    Case 2 ;Healing Signet (W tactic : cost 0, CTime 2s, cd 4s)
                        CastSkill($SkillToCast, -2)
                EndSwitch
            ElseIf ($type == 1) Then
                $SkillToCast = Random(5,6,1)
                TargetNearestEnemy()
                Attack(-1)
                Switch $SkillToCast
                    Case 5 ;Empathy (Domination Magic : cost 10nrg, CTime 2s, cd 10s)
                        If (GetEnergy($lAgentMe) >= 10) Then CastSkill($SkillToCast,-1)
                    Case 6
                    ;6: Conjure Phantasm (Mes Illusion Magic : cost 10nrg, CTime 1s, cd 5s)
                    ;7: Shatter Deslusions (Mes Domination Magic : cost 5nrg, CTime 1/4s, cd 6s)
                        If (GetEnergy($lAgentMe) >= 10) Then CastSkill($SkillToCast,-1)
                        If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast+1,-1)
                EndSwitch
            EndIf
        ElseIf($Secondary == 2) Then ;Mes/R
            If ($type == 2) Then ($type = 1)
            If ($type == 0) Then
                $SkillToCast = Random(1,2,1)
                Switch $SkillToCast
                    Case 1 ;Ether Feast (Mes Inspiration Magic : cost 5nrg, CTime 1s, cd 8s)
                        TargetNearestEnemy()
                        Attack(-1)
                        If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast, -1)
                    Case 2 ;Troll Unguent (R Wilderness Survival : cost 5nrg, CTime 3s, cd 10s)
                        If ((GetEffectTimeRemaining($Troll_Unguent) < 3000) OR Not (_HasEffect($Troll_Unguent))) Then
                            If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast, -2)
                        EndIf
                EndSwitch
            ElseIf ($type == 1) Then
                $SkillToCast = Random(5,6,1)
                TargetNearestEnemy()
                Attack(-1)
                Switch $SkillToCast
                    Case 5 ;Empathy (Domination Magic : cost 10nrg, CTime 2s, cd 10s)
                        If (GetEnergy($lAgentMe) >= 10) Then CastSkill($SkillToCast,-1)
                    Case 6
                    ;6: Conjure Phantasm (Mes Illusion Magic : cost 10nrg, CTime 1s, cd 5s)
                    ;7: Shatter Deslusions (Mes Domination Magic : cost 5nrg, CTime 1/4s, cd 6s)
                        If (GetEnergy($lAgentMe) >= 10) Then CastSkill($SkillToCast,-1)
                        If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast+1,-1)
                EndSwitch
            ElseIf ($type == 3) Then
                $SkillToCast = 4 ;Comfort Animal (R Beast mastery : cost 5nrg, CTime 1s, cd 1s)
                If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast)
            EndIf
        ElseIf($Secondary == 3) Then ;Mes/Mo
            If ($type == 2) Then ($type = 1)
            If ($type == 0) Then
                $SkillToCast = Random(1,3,1)
                Switch $SkillToCast
                    Case 1 ;Healing Breeze (Mo Heal : cost 10nrg, CTime 1s, cd 5s)
                        If ((GetEffectTimeRemaining($Healing_Breeze) < 1000) OR Not (_HasEffect($Healing_Breeze))) Then
                            If (GetEnergy($lAgentMe) >= 10) Then CastSkill($SkillToCast, -2)
                        EndIf
                    Case 2 ;Orison of Healing (Mo Healing : cost 5nrg, CTime 1s, cd 2s)
                        If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast, -2)
                    Case 3 ;Ether Feast (Mes Inspiration Magic : cost 5nrg, CTime 1s, cd 8s)
                        TargetNearestEnemy()
                        Attack(-1)
                        If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast, -1)
                EndSwitch
            ElseIf ($type == 1) Then
                $SkillToCast = Random(5,7,1)
                TargetNearestEnemy()
                Attack(-1)
                Switch $SkillToCast
                    Case 5 ;Banish (Mo smit : cost 5nrg, CTime 1s, cd 10s)
                        If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast,-1)
                    Case 6 ;Bane Signet (Mo smit : cost 0, CTime 1s, cd 20s)
                        CastSkill($SkillToCast,-1)
                    Case 7
                    ;7: Conjure Phantasm (Mes Illusion Magic : cost 10nrg, CTime 1s, cd 5s)
                    ;8: Shatter Deslusions (Mes Domination Magic : cost 5nrg, CTime 1/4s, cd 6s)
                        If (GetEnergy($lAgentMe) >= 10) Then CastSkill($SkillToCast,-1)
                        If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast+1,-1)
                EndSwitch
            EndIf
        ElseIf($Secondary == 4) Then ;Mes/N
            If ($type == 2) Then ($type = 1)
            If ($type == 0) Then
                $SkillToCast = Random(1,2,1)
                Switch $SkillToCast
                    Case 1 ;Ether Feast (Mes Inspiration Magic : cost 5nrg, CTime 1s, cd 8s)
                        TargetNearestEnemy()
                        Attack(-1)
                        If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast, -1)
                    Case 2 ;Vampiric Gaze (N Blood magic : cost 10nrg, CTime 1s, cd 8s)
                        $SkillToCast = 6
                        TargetNearestEnemy()
                        Attack(-1)
                        If (GetEnergy($lAgentMe) >= 10) Then CastSkill($SkillToCast, -1)
                EndSwitch
            ElseIf ($type == 1) Then
                $SkillToCast = Random(5,7,1)
                TargetNearestEnemy()
                Attack(-1)
                Switch $SkillToCast
                    Case 5 ;Life Siphon (N Blood Magic : cost 10nrg, CTime 1s, cd 5s)
                        If (GetEnergy($lAgentMe) >= 10) Then CastSkill($SkillToCast, -1)
                    Case 6 ;Vampiric Gaze (N Blood magic : cost 10nrg, CTime 1s, cd 8s)
                        If (GetEnergy($lAgentMe) >= 10) Then CastSkill($SkillToCast, -1)
                    Case 7
                    ;7: Conjure Phantasm (Mes Illusion Magic : cost 10nrg, CTime 1s, cd 5s)
                    ;8: Shatter Deslusions (Mes Domination Magic : cost 5nrg, CTime 1/4s, cd 6s)
                        If (GetEnergy($lAgentMe) >= 10) Then CastSkill($SkillToCast,-1)
                        If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast+1,-1)
                EndSwitch
            EndIf
        ElseIf($Secondary == 6) Then ;Mes/El
            If ($type == 0) Then
                $SkillToCast = 2 ;Ether Feast (Mes Inspiration Magic : cost 5nrg, CTime 1s, cd 8s)
                TargetNearestEnemy()
                Attack(-1)
                If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast, -1)
            ElseIf ($type == 1) Then
                $SkillToCast = Random(5,7,1)
                TargetNearestEnemy()
                Attack(-1)
                Switch $SkillToCast
                    Case 5 ;Fire Storm (El Fire magic : cost 10nrg, CTime 2s, cd 20s)
                        If (GetEnergy($lAgentMe) >= 10) Then CastSkill($SkillToCast, -1)
                    Case 6 ;Flare (El Fire Magic : cost 5nrg, CTime 1s, cd 0)
                        If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast, -1)
                    Case 7
                    ;7: Conjure Phantasm (Mes Illusion Magic : cost 10nrg, CTime 1s, cd 5s)
                    ;8: Shatter Deslusions (Mes Domination Magic : cost 5nrg, CTime 1/4s, cd 6s)
                        If (GetEnergy($lAgentMe) >= 10) Then CastSkill($SkillToCast,-1)
                        If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast+1,-1)
                EndSwitch
            ElseIf ($type == 2) Then
                $SkillToCast = 1
                If ((GetEffectTimeRemaining($Aura_of_Restoration) < 250) OR Not (_HasEffect($Aura_of_Restoration))) Then
                    If (GetEnergy($lAgentMe) > 5) Then CastSkill($SkillToCast, -2)
                EndIf
            EndIf
        EndIf
    ElseIf($Primary == 6) Then ;El
		If ($Secondary == 0) Then ;El only
			If ($type == 0) Then ($type = 2)
            If ($type == 2) Then
                $SkillToCast = Random(1,2,1)
                Switch $SkillToCast
                    Case 1 ;Aura of Restoration (El Energy Storage : cost 5nrg, CTime 1/4s, cd 20s)
                        If ((GetEffectTimeRemaining($Aura_of_Restoration) < 250) OR Not (_HasEffect($Aura_of_Restoration))) Then
                            If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast, -2)
                        EndIf
                    Case 2 ;Glyph of Lesser Energy (El Energy Storage : cost 5nrg, CTime 1s, cd 30s)
                        $SkillToCast = 4
                        If ((GetEffectTimeRemaining($Glyph_of_Lesser_Energy) < 1000) OR Not (_HasEffect($Glyph_of_Lesser_Energy))) Then
                            If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast, -2)
                        EndIf
                EndSwitch
            ElseIf ($type == 1) Then
                $SkillToCast = Random(5,6,1)
                TargetNearestEnemy()
                Attack(-1)
                Switch $SkillToCast
                    Case 5 ;Fire Storm (El Fire magic : cost 10nrg, CTime 2s, cd 20s)
                        If (GetEnergy($lAgentMe) >= 10) Then CastSkill($SkillToCast, -1)
                    Case 6 ;Flare (El Fire Magic : cost 5nrg, CTime 1s, cd 0)
                        If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast, -1)
                EndSwitch
            EndIf
        ElseIf($Secondary == 1) Then ;El/W
            If ($type == 0) Then ($type = 2)
            If ($type == 2) Then
                $SkillToCast = Random(1,2,1)
                Switch $SkillToCast
                    Case 1 ;Aura of Restoration (El Energy Storage : cost 5nrg, CTime 1/4s, cd 20s)
                        If ((GetEffectTimeRemaining($Aura_of_Restoration) < 250) OR Not (_HasEffect($Aura_of_Restoration))) Then
                            If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast, -2)
                        EndIf
                    Case 2 ;Glyph of Lesser Energy (El Energy Storage : cost 5nrg, CTime 1s, cd 30s)
                        $SkillToCast = 4
                        If ((GetEffectTimeRemaining($Glyph_of_Lesser_Energy) < 1000) OR Not (_HasEffect($Glyph_of_Lesser_Energy))) Then
                            If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast, -2)
                        EndIf
                EndSwitch
            ElseIf ($type == 1) Then
                $SkillToCast = Random(5,6,1)
                TargetNearestEnemy()
                Attack(-1)
                Switch $SkillToCast
                    Case 5 ;Fire Storm (El Fire magic : cost 10nrg, CTime 2s, cd 20s)
                        If (GetEnergy($lAgentMe) >= 10) Then CastSkill($SkillToCast, -1)
                    Case 6 ;Flare (El Fire Magic : cost 5nrg, CTime 1s, cd 0)
                        If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast, -1)
                EndSwitch
            EndIf
        ElseIf($Secondary == 2) Then ;El/R
            If ($type == 0) Then
                $SkillToCast = 2 ;Troll Unguent (R Wilderness Survival : cost 5nrg, CTime 3s, cd 10s)
                If ((GetEffectTimeRemaining($Troll_Unguent) < 3000) OR Not (_HasEffect($Troll_Unguent))) Then
                    If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast, -2)
                EndIf
            ElseIf ($type == 2) Then
                $SkillToCast = Random(1,2,1)
                Switch $SkillToCast
                    Case 1 ;Aura of Restoration (El Energy Storage : cost 5nrg, CTime 1/4s, cd 20s)
                        If ((GetEffectTimeRemaining($Aura_of_Restoration) < 250) OR Not (_HasEffect($Aura_of_Restoration))) Then
                            If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast, -2)
                        EndIf
                    Case 2 ;Glyph of Lesser Energy (El Energy Storage : cost 5nrg, CTime 1s, cd 30s)
                        $SkillToCast = 4
                        If ((GetEffectTimeRemaining($Glyph_of_Lesser_Energy) < 1000) OR Not (_HasEffect($Glyph_of_Lesser_Energy))) Then
                            If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast, -2)
                        EndIf
                EndSwitch
            ElseIf ($type == 1) Then
                $SkillToCast = Random(5,6,1)
                TargetNearestEnemy()
                Attack(-1)
                Switch $SkillToCast
                    Case 5 ;Fire Storm (El Fire magic : cost 10nrg, CTime 2s, cd 20s)
                        If (GetEnergy($lAgentMe) >= 10) Then CastSkill($SkillToCast, -1)
                    Case 6 ;Flare (El Fire Magic : cost 5nrg, CTime 1s, cd 0)
                        If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast, -1)
                EndSwitch
            ElseIf ($type == 3) Then
                $SkillToCast = 4 ;Comfort Animal (R Beast mastery : cost 5nrg, CTime 1s, cd 1s)
                If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast)
            EndIf
        ElseIf($Secondary == 3) Then ;El/Mo
            If ($type == 0) Then
                $SkillToCast = Random(2,3,1)
                Switch $SkillToCast
                    Case 2 ;Healing Breeze (Mo Heal : cost 10nrg, CTime 1s, cd 5s)
                        If ((GetEffectTimeRemaining($Healing_Breeze) < 1000) OR Not (_HasEffect($Healing_Breeze))) Then
                            If (GetEnergy($lAgentMe) >= 10) Then CastSkill($SkillToCast, -2)
                        EndIf
                    Case 3 ;Orison of Healing (Mo Healing : cost 5nrg, CTime 1s, cd 2s)
                        If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast, -2)
                EndSwitch
            ElseIf ($type == 1) Then
                $SkillToCast = Random(5,8,1)
                TargetNearestEnemy()
                Attack(-1)
                Switch $SkillToCast
                    Case 5 ;Fire Storm (El Fire magic : cost 10nrg, CTime 2s, cd 20s)
                        If (GetEnergy($lAgentMe) >= 10) Then CastSkill($SkillToCast, -1)
                    Case 6 ;Flare (El Fire Magic : cost 5nrg, CTime 1s, cd 0)
                        If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast, -1)
                    Case 7 ;Banish (Mo smit : cost 5nrg, CTime 1s, cd 10s)
                        If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast,-1)
                    Case 8 ;Bane Signet (Mo smit : cost 0, CTime 1s, cd 20s)
                        CastSkill($SkillToCast,-1)
                EndSwitch
            ElseIf ($type == 2) Then
                $SkillToCast = Random(1,2,1)
                Switch $SkillToCast
                    Case 1 ;Aura of Restoration (El Energy Storage : cost 5nrg, CTime 1/4s, cd 20s)
                        If ((GetEffectTimeRemaining($Aura_of_Restoration) < 250) OR Not (_HasEffect($Aura_of_Restoration))) Then
                            If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast, -2)
                        EndIf
                    Case 2 ;Glyph of Lesser Energy (El Energy Storage : cost 5nrg, CTime 1s, cd 30s)
                        $SkillToCast = 4
                        If ((GetEffectTimeRemaining($Glyph_of_Lesser_Energy) < 1000) OR Not (_HasEffect($Glyph_of_Lesser_Energy))) Then
                            If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast, -2)
                        EndIf
                EndSwitch
            EndIf
        ElseIf($Secondary == 4) Then ;El/N
            If ($type == 0) Then
                $SkillToCast = 7 ;Vampiric Gaze (N Blood magic : cost 10nrg, CTime 1s, cd 8s)
                TargetNearestEnemy()
                Attack(-1)
                If (GetEnergy($lAgentMe) >= 10) Then CastSkill($SkillToCast, -1)
            ElseIf ($type == 1) Then
                $SkillToCast = Random(5,8,1)
                TargetNearestEnemy()
                Attack(-1)
                Switch $SkillToCast
                    Case 5 ;Fire Storm (El Fire magic : cost 10nrg, CTime 2s, cd 20s)
                        If (GetEnergy($lAgentMe) >= 10) Then CastSkill($SkillToCast, -1)
                    Case 6 ;Flare (El Fire Magic : cost 5nrg, CTime 1s, cd 0)
                        If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast, -1)
                    Case 7 ;Life Siphon (N Blood Magic : cost 10nrg, CTime 1s, cd 5s)
                        If (GetEnergy($lAgentMe) >= 10) Then CastSkill($SkillToCast, -1)
                    Case 8 ;Vampiric Gaze (N Blood Magic : cost 10nrg, CTime 1s, cd 8s)
                        If (GetEnergy($lAgentMe) >= 10) Then CastSkill($SkillToCast, -1)
                EndSwitch
            ElseIf ($type == 2) Then
                $SkillToCast = Random(1,2,1)
                Switch $SkillToCast
                    Case 1 ;Aura of Restoration (El Energy Storage : cost 5nrg, CTime 1/4s, cd 20s)
                        If ((GetEffectTimeRemaining($Aura_of_Restoration) < 250) OR Not (_HasEffect($Aura_of_Restoration))) Then
                            If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast, -2)
                        EndIf
                    Case 2 ;Glyph of Lesser Energy (El Energy Storage : cost 5nrg, CTime 1s, cd 30s)
                        $SkillToCast = 4
                        If ((GetEffectTimeRemaining($Glyph_of_Lesser_Energy) < 1000) OR Not (_HasEffect($Glyph_of_Lesser_Energy))) Then
                            If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast, -2)
                        EndIf
                EndSwitch
            EndIf
        ElseIf($Secondary == 5) Then ;El/Mes
            If ($type == 0) Then
                $SkillToCast = 3 ;Ether Feast (Mes Inspiration Magic : cost 5nrg, CTime 1s, cd 8s)
                TargetNearestEnemy()
                Attack(-1)
                CastSkill($SkillToCast, -1)
            ElseIf ($type == 1) Then
                $SkillToCast = Random(5,6,1)
                TargetNearestEnemy()
                Attack(-1)
                Switch $SkillToCast
                    Case 5 ;Fire Storm (El Fire magic : cost 10nrg, CTime 2s, cd 20s)
                        If (GetEnergy($lAgentMe) >= 10) Then CastSkill($SkillToCast, -1)
                    Case 6 ;Flare (El Fire Magic : cost 5nrg, CTime 1s, cd 0)
                        If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast, -1)
                EndSwitch
            ElseIf ($type == 2) Then
                $SkillToCast = Random(1,2,1)
                Switch $SkillToCast
                    Case 1 ;Aura of Restoration (El Energy Storage : cost 5nrg, CTime 1/4s, cd 20s)
                        If ((GetEffectTimeRemaining($Aura_of_Restoration) < 250) OR Not (_HasEffect($Aura_of_Restoration))) Then
                            If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast, -2)
                        EndIf
                    Case 2 ;Glyph of Lesser Energy (El Energy Storage : cost 5nrg, CTime 1s, cd 30s)
                        $SkillToCast = 4
                        If ((GetEffectTimeRemaining($Glyph_of_Lesser_Energy) < 1000) OR Not (_HasEffect($Glyph_of_Lesser_Energy))) Then
                            If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast, -2)
                        EndIf
                EndSwitch
            EndIf
        EndIf
    EndIf
Endfunc

Func CastSkill($SkillToCast, $Target, $IsSelfTargetedAoE = 0) ;Cast the skill number $SkillToCast at $Target (-1 on enemy, -2 on player)
;~ If the skill used is a self targeted AoE, you must set $IsSelfTargetedAoE with the Range's of this AoE. if not just don't pass the argument.
;~ $Adjacent = 156, $Nearby = 240, $Area = 312, $Earshot = 1000, $Spell_casting = 1085, $Spirit = 2500, $Compass = 5000
	If IsRecharged($SkillToCast) Then
		If ($IsSelfTargetedAoE == 0) Then
			If GetNumberOfFoesInRangeOfAgent(-2, 1250) > 0 Then
				UseSkillEx($SkillToCast, $Target)
			ElseIf GetNumberOfSpecialFoesInRangeOfAgent(-2, 1250) > 0 Then
				UseSkillEx($SkillToCast, $Target)
			EndIf
		Else
			If GetNumberOfFoesInRangeOfAgent(-2, $IsSelfTargetedAoE) > 0 Then
				UseSkillEx($SkillToCast, $Target)
			ElseIf GetNumberOfSpecialFoesInRangeOfAgent(-2, $IsSelfTargetedAoE) > 0 Then
				UseSkillEx($SkillToCast, $Target)
			EndIf
		EndIf
    EndIf
EndFunc
			#Region Custom build functions
Func CustomBuild_Status() ;Checks if the bot has to do the survivor title (Return True or False)
    If ((GUICtrlRead($CustomBuild_Template, "") == "") OR (GUICtrlRead($CustomBuild_Template, "") == "0")) Then
        Return False
    Else
        Return True
    EndIf
EndFunc

Func Custom_BuildForProfession() ;Load the custom build based on input template
	LoadSkillTemplate(GUICtrlRead($CustomBuild_Template, ""))
	Return True
EndFunc

Func Custom_CastSkillFromBuild($type = 1) ;Cast a skill ($type: 0=Heal 1=Damage 2=Buff 3=HealPet)
	Local $SkillToCast = 1
	Local $lAgentMe = GetMyID()

	Local $Number_HealSkill = FindNumberOfSkill("Heal")
	Local $Number_DMGSkill = FindNumberOfSkill("Damage")
	Local $Number_BuffSkill = FindNumberOfSkill("Buff")
	Local $Number_HealPet = FindNumberOfSkill("Pet Heal")
	Local $Number_DMGHealSkill = FindNumberOfSkill("Heal&Damage")

	If ($Number_HealSkill == 1) Then
		Local $Pos_HealSkill = FindSkillPositions("Heal", $Number_HealSkill)
	ElseIf ($Number_HealSkill >= 2) Then
		Local $Array_HealSkill[$Number_HealSkill] = FindSkillPositions("Heal", $Number_HealSkill)
	EndIf
	If ($Number_DMGSkill == 1) Then
		Local $Pos_DMGSkill = FindSkillPositions("Damage", $Number_DMGSkill)
	ElseIf ($Number_DMGSkill >= 2) Then
		Local $Array_DMGSkill[$Number_DMGSkill] = FindSkillPositions("Damage", $Number_DMGSkill)
	EndIf
	If ($Number_BuffSkill == 1) Then
		Local $Pos_BuffSkill = FindSkillPositions("Buff", $Number_BuffSkill)
	ElseIf ($Number_BuffSkill >= 2) Then
		Local $Array_BuffSkill[$Number_BuffSkill] = FindSkillPositions("Buff", $Number_BuffSkill)
	EndIf
	If ($Number_HealPet > 0) Then Local $HealPet_Pos = FindSkillPositions("Pet Heal", $Number_HealPet)
	If ($Number_DMGHealSkill == 1) Then
		Local $Pos_DMGHealSkill = FindSkillPositions("Heal&Damage", $Number_DMGHealSkill)
	ElseIf ($Number_DMGHealSkill >= 2) Then
		Local $Array_DMGHealSkill[$Number_DMGHealSkill] = FindSkillPositions("Heal&Damage", $Number_DMGHealSkill)
	EndIf

	If ($type == 0) Then ;Heal
		If (($Number_HealSkill == 0) AND ($Number_DMGHealSkill == 0)) Then ;No heal skills
			$type = 1 ;damage
		ElseIf (($Number_HealSkill == 1) AND ($Number_DMGHealSkill == 0)) Then ;Only one self heal
			$SkillToCast = $Pos_HealSkill
			CastSkill($SkillToCast, -2)
		ElseIf (($Number_HealSkill == 0) AND ($Number_DMGHealSkill == 1)) Then ;Only one enemy target heal skill (heal steal)
			$SkillToCast = $Pos_DMGHealSkill
            TargetNearestEnemy()
            Attack(-1)
            CastSkill($SkillToCast, -1)
		ElseIf (($Number_HealSkill >= 2) AND ($Number_DMGHealSkill == 0)) Then ;Only self heal array
			$SkillToCast = $Array_HealSkill[Random(0,$Number_HealSkill-1,1)]
			CastSkill($SkillToCast, -2)
		ElseIf (($Number_HealSkill == 0) AND ($Number_DMGHealSkill >= 2)) Then ;Only ennemy target heal array (heal steal)
			$SkillToCast = $Array_DMGHealSkill[Random(0,$Number_DMGHealSkill-1,1)]
            TargetNearestEnemy()
            Attack(-1)
            CastSkill($SkillToCast, -1)
		ElseIf (($Number_HealSkill >= 2) AND ($Number_DMGHealSkill >= 2)) Then ;Self heal+Enemy target heal array
			$SkillToCast = Random(0,1,1) ;Switch between self(0) and enemy targeted heal(1)
			If ($SkillToCast == 0) Then
				$SkillToCast = $Array_HealSkill[Random(0,$Number_HealSkill-1,1)]
				CastSkill($SkillToCast, -2)
			ElseIf ($SkillToCast == 1) Then
				$SkillToCast = $Array_DMGHealSkill[Random(0,$Number_DMGHealSkill-1,1)]
				TargetNearestEnemy()
				Attack(-1)
				CastSkill($SkillToCast, -1)
			EndIf
		EndIf
	EndIf
    If ($type == 2) Then ;Buff
        If ($Number_BuffSkill == 0) Then
			$type = 1
		ElseIf ($Number_BuffSkill == 1) Then
			$SkillToCast = $Pos_BuffSkill
		ElseIf ($Number_BuffSkill >= 2) Then
			$SkillToCast = $Array_BuffSkill[Random(0,$Number_BuffSkill-1,1)]
			 CastSkill($SkillToCast, -2)
		EndIf
	EndIf
    If ($type == 1) Then ;Damage
		If (($Number_DMGSkill == 0) AND ($Number_DMGHealSkill == 0)) Then ;No damage or damage&heal skills
			TargetNearestEnemy()
            Attack(-1)
		ElseIf (($Number_DMGSkill == 1) AND ($Number_DMGHealSkill == 0)) Then ;Only damage
			$SkillToCast = $Pos_DMGSkill
			TargetNearestEnemy()
            Attack(-1)
			CastSkill($SkillToCast, -1)
		ElseIf (($Number_DMGSkill == 0) AND ($Number_DMGHealSkill == 1)) Then ;Only one damage&heal skill (heal steal)
			$SkillToCast = $Pos_DMGHealSkill
            TargetNearestEnemy()
            Attack(-1)
            CastSkill($SkillToCast, -1)
		ElseIf (($Number_DMGSkill >= 2) AND ($Number_DMGHealSkill == 0)) Then ;Only Damage array
			$SkillToCast = $Array_DMGSkill[Random(0,$Number_DMGSkill-1,1)]
			TargetNearestEnemy()
            Attack(-1)
			CastSkill($SkillToCast, -1)
		ElseIf (($Number_DMGSkill == 0) AND ($Number_DMGHealSkill >= 2)) Then ;Only Dmage&Heal array (heal steal)
			$SkillToCast = $Array_DMGHealSkill[Random(0,$Number_DMGHealSkill-1,1)]
            TargetNearestEnemy()
            Attack(-1)
            CastSkill($SkillToCast, -1)
		ElseIf (($Number_DMGSkill >= 2) AND ($Number_DMGHealSkill >= 2)) Then ;Damage+Damage&Heal array
			$SkillToCast = Random(0,1,1) ;Switch between Damage(0) and Damage&Heal(1) skill
			If ($SkillToCast == 0) Then
				$SkillToCast = $Array_DMGSkill[Random(0,$Number_DMGSkill-1,1)]
				TargetNearestEnemy()
				Attack(-1)
				CastSkill($SkillToCast, -1)
			ElseIf ($SkillToCast == 1) Then
				$SkillToCast = $Array_DMGHealSkill[Random(0,$Number_DMGHealSkill-1,1)]
				TargetNearestEnemy()
				Attack(-1)
				CastSkill($SkillToCast, -1)
			EndIf
		EndIf
	EndIf
    If ($type == 3) Then ;Pet Heal
        $SkillToCast = $HealPet_Pos ;Comfort Animal (R Beast mastery : cost 5nrg, CTime 1s, cd 1s)
        If (GetEnergy($lAgentMe) >= 5) Then CastSkill($SkillToCast)
    EndIf
EndFunc

Func FindNumberOfSkill($TypeString = 0) ;Returns number of skills in custom build based on Skill type string (Heal,Damage,Heal&Damage,Pet Heal)
	Local $NumberOfSkills = 0

	If ($TypeString <> "Heal") AND ($TypeString <> "Damage") AND ($TypeString <> "Heal&Damage") AND ($TypeString <> "Buff") AND ($TypeString <> "Pet Heal") Then
		logFile("ERROR : Wrong $TypeString passed to FindNumberOfSkill function.")
		Return 0
	EndIf

	If (GUICtrlRead($Custom_Skill_1_Type, "") == $TypeString) Then $NumberOfSkills += 1
	If (GUICtrlRead($Custom_Skill_2_Type, "") == $TypeString) Then $NumberOfSkills += 1
	If (GUICtrlRead($Custom_Skill_3_Type, "") == $TypeString) Then $NumberOfSkills += 1
	If (GUICtrlRead($Custom_Skill_4_Type, "") == $TypeString) Then $NumberOfSkills += 1
	If (GUICtrlRead($Custom_Skill_5_Type, "") == $TypeString) Then $NumberOfSkills += 1
	If (GUICtrlRead($Custom_Skill_6_Type, "") == $TypeString) Then $NumberOfSkills += 1
	If (GUICtrlRead($Custom_Skill_7_Type, "") == $TypeString) Then $NumberOfSkills += 1
	If (GUICtrlRead($Custom_Skill_8_Type, "") == $TypeString) Then $NumberOfSkills += 1

	Return $NumberOfSkills
EndFunc

Func FindSkillPositions($TypeString = 0, $NumberOfSkills = 0) ;Returns an array with skills' positions in the hotbar based on the TypeString (Heal,Damage,Buff,Pet Heal, Damage&Heal)
;Needs the $NumberOfSkill to dim the array
;If $NumberOfSkills == 1, returns an integer insteed of an array

	If ($NumberOfSkills <= 0) Then
		LogFile("ERROR : FindSkillPositions can't Dim an array below size 1.")
		Return 0
	EndIf
	If ($TypeString <> "Heal") AND ($TypeString <> "Damage") AND ($TypeString <> "Heal&Damage") AND ($TypeString <> "Buff") AND ($TypeString <> "Pet Heal") Then
		logFile("ERROR : Wrong $TypeString passed to FindSkillPositions function.")
		Return 0
	EndIf

	If ($NumberOfSkills == 1) Then
		Local $PosID = 0
	Else ;$NumberOfSkills >= 2
		Local $PosArray[$NumberOfSkills]
	EndIf
	Local $Pos = 0

	If (GUICtrlRead($Custom_Skill_1_Type, "") == $TypeString) Then
		If (($NumberOfSkills == 1) AND ($PosID == 0)) Then
			$PosID = 1 ;$Pos+1
		Else
			$PosArray[$Pos] = 1 ;$Pos+1
		EndIf
		$Pos += 1
	EndIf
	If (GUICtrlRead($Custom_Skill_2_Type, "") == $TypeString) Then
		If (($NumberOfSkills == 1) AND ($PosID == 0)) Then
			$PosID = 2 ;2
		Else
			$PosArray[$Pos] = 2 ;2
		EndIf
		$Pos += 1
	EndIf
	If (GUICtrlRead($Custom_Skill_3_Type, "") == $TypeString) Then
		If (($NumberOfSkills == 1) AND ($PosID == 0)) Then
			$PosID = 3 ;3
		Else
			$PosArray[$Pos] = 3 ;3
		EndIf
		$Pos += 1
	EndIf
	If (GUICtrlRead($Custom_Skill_4_Type, "") == $TypeString) Then
		If (($NumberOfSkills == 1) AND ($PosID == 0)) Then
			$PosID = 4 ;4
		Else
			$PosArray[$Pos] = 4 ;4
		EndIf
		$Pos += 1
	EndIf
	If (GUICtrlRead($Custom_Skill_5_Type, "") == $TypeString) Then
		If (($NumberOfSkills == 1) AND ($PosID == 0)) Then
			$PosID = 5 ;5
		Else
			$PosArray[$Pos] = 5 ;5
		EndIf
		$Pos += 1
	EndIf
	If (GUICtrlRead($Custom_Skill_6_Type, "") == $TypeString) Then
		If (($NumberOfSkills == 1) AND ($PosID == 0)) Then
			$PosID = 6 ;6
		Else
			$PosArray[$Pos] = 6 ;6
		EndIf
		$Pos += 1
	EndIf
	If (GUICtrlRead($Custom_Skill_7_Type, "") == $TypeString) Then
		If (($NumberOfSkills == 1) AND ($PosID == 0)) Then
			$PosID = 7 ;7
		Else
			$PosArray[$Pos] = 7 ;7
		EndIf
		$Pos += 1
	EndIf
	If (GUICtrlRead($Custom_Skill_8_Type, "") == $TypeString) Then
		If (($NumberOfSkills == 1) AND ($PosID == 0)) Then
			$PosID = 8 ;8
		Else
			$PosArray[$Pos] = 8 ;8
		EndIf
		;$Pos += 1 ;Last in hotbar
	EndIf

	If ($NumberOfSkills == 1) Then
        If ($PosID == 0) Then
            logFile("ERROR : FindSkillPositions can't find skill's position.")
            Return 0
        EndIf
	EndIf

	If ($NumberOfSkills == 1) Then
		Return $PosID
	Else
		Return $PosArray
	EndIf
EndFunc
			#EndRegion Custom build functions
		#EndRegion

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
	  logFile ("Level:" & $lvl)
EndFunc

Func LvlStop() ;Check if lvl19 stop is selected and stop bot at lvl19 (in LDoA2)
   Local $myXP = GetExperience()
   If ((GUICtrlRead($Lvl19) = $GUI_CHECKED) AND ($myXP >= 127800) AND ($myXP < 140600)) Then
	  Sleep(500)
	  logFile("Stopped Level 19")
      $BotRunning = False
      Return True
   EndIf

   Return False
EndFunc
		#EndRegion

		#Region Player & Mobs Interactions Functions
Func UseStone() ;Detect in bag and use summoning stone
    Local $ImpID = 30847
	For $bag = 1 To 4
		For $slot = 1 To DllStructGetData(GetBag($bag), 'Slots')
			Global $item = GetItemBySlot($bag, $slot)
			If DllStructGetData($item, 'ModelID') == $ImpID Then
				UseItem($item)
				RndSleep(500)
				Return
			EndIf
		Next
	Next
EndFunc

Func CheckAndUseStone($boolSilence = 0) ;Check if the user choosed to pop stone and if the character level is between 1 and 19
;Passing $boolSilence = 1 will silence error messages from the function
    Local $Level = GetLevel()

    If (GUICtrlRead($Stone) = $GUI_CHECKED) Then
        If (($Level <= 19) AND ($Level > 0)) Then
            ;logFile("Effect sum :" & _HasEffect($Summoning_Sickness))
            If Not _HasEffect($Summoning_Sickness) Then
                logFile("Popping Stone")
                UseStone()
            Else
                If Not $boolSilence Then logFile("Summoning Debuff preventing bot from using the Stone.")
            EndIf
        ElseIf ($Level == 20) Then
                If Not $boolSilence Then logFile("Level 20 can't pop stone.")
        Else
            If Not $boolSilence Then logFile("Unable to get your level properly.")
            If Not $boolSilence Then logFile("Popping Stone aborted.")
        EndIf
    EndIf
EndFunc

Func GetNumberOfSpecialFoesInRangeOfAgent($aAgent = -2, $aRange = 1250) ;Return the number of Plague Worms around player (used for Baked Husk farm)
	Local $lAgent, $lDistance
	Local $lCount = 0
    Local $lName, $lAddress
	Local $AgentName, $PlayerNumber

	If Not IsDllStruct($aAgent) Then $aAgent = GetAgentByID($aAgent)

	For $i = 1 To GetMaxAgents()

		$lAgent = GetAgentByID($i)

        $PlayerNumber = DllStructGetData($lAgent, 'PlayerNumber')
        If (($PlayerNumber <> 1422) AND ($PlayerNumber <> 1424) AND ($PlayerNumber <> 1435) AND ($PlayerNumber <> 1397) AND ($PlayerNumber <> 1408)) Then
        ;Aloe Husk ;Aloe Seed ;Worm ;Spider ;Ice Elemental
            ContinueLoop
        EndIf

		If DllStructGetData($lAgent, 'Type') <> 0xDB Then ContinueLoop
		If DllStructGetData($lAgent, 'Allegiance') <> 3 Then ContinueLoop
		If DllStructGetData($lAgent, 'HP') <= 0 Then ContinueLoop
		If BitAND(DllStructGetData($lAgent, 'Effects'), 0x0010) > 0 Then ContinueLoop
		$lDistance = GetDistance($lAgent)

		If $lDistance > $aRange Then ContinueLoop
		$lCount += 1
	Next
    ;logFile("MCount: "&$lCount)
	Return $lCount
EndFunc   ;==>GetNumberOfSpecialFoesInRangeOfAgent

Func KillMobs($FarmID = 0) ;Kill the mobs around the player
    If Not $BotRunning Then Return
    If GetIsDead(-2) Then Return

    If (($FarmID == 5) OR ($FarmID == 10) OR ($FarmID == 14) OR ($FarmID == 15)) Then
        While GetNumberOfSpecialFoesInRangeOfAgent(-2, 1250) > 0
            If GetIsDead(-2) Then Return

            CheckAndUseStone(1)

            TargetNearestEnemy()
            Sleep(250)
            ChangeTarget(-1)
            Attack(-1)
            AutonomousCasting()
            Sleep(200)
            ClearTarget()
        Wend
    Else
        While GetNumberOfFoesInRangeOfAgent(-2, 1250) > 0
            If GetIsDead(-2) Then Return

            CheckAndUseStone(1)

            TargetNearestEnemy()
            Sleep(250)
            ChangeTarget(-1)
            Attack(-1)
            AutonomousCasting()
            Sleep(200)
            ClearTarget()
        Wend
    EndIf

    Sleep(100)
EndFunc

Func _PullMobs($PullDistance = 1000) ;Pull mobs back on a straigh line to $PullDistance in pixels based on character's pos and mob's pos
	Local $NearestEnemy
	Local $EnemyPosX, $EnemyPosY

	Local $lAgent = GetAgentByID(GetMyID())
	Local $MyPosX = DllStructGetData($lAgent, 'X')
	Local $MyPosY = DllStructGetData($lAgent, 'Y')

    Local $DistToEnemyX, $DistToEnemyY, $DistToEnemy
    Local $DistToEnemyX_, $DistToEnemyY_
    Local $Ratio

    Local $MyNewPosX, $MyNewPosY

    If ((GetNumberOfSpecialFoesInRangeOfAgent(-2, 1300) > 0) OR (GetNumberOfFoesInRangeOfAgent(-2, 1300) > 0)) Then
        TargetNearestEnemy()
        Attack(-1)
        CastSkillFromBuild(1)
        Sleep(500)
    EndIf

    logFile("Danger: " & GetAgentDanger($lAgent))

	If (GetAgentDanger($lAgent) > 0) Then ;NOT WORKING
        logFile("Danger")
		If ((GetNumberOfSpecialFoesInRangeOfAgent(-2, 1300) > 0) OR (GetNumberOfFoesInRangeOfAgent(-2, 1300) > 0)) Then
			logFile("Enemy")
            TargetNearestEnemy()
			$NearestEnemy = GetCurrentTarget()
			$EnemyPosX = DllStructGetData($NearestEnemy, 'X')
			$EnemyPosY = DllStructGetData($NearestEnemy, 'Y')

            $DistToEnemyX = Abs($MyPosX-$EnemyPosX) ;Distance to enemy on X axis
            $DistToEnemyY = Abs($MyPosY-$EnemyPosY) ;Distance to enemy on Y axis
            $DistToEnemy = GetDistance($lAgent, $NearestEnemy)

            $Ratio = $DistToEnemy / $PullDistance ;Get Distance to enemy ratio to $PullDistance in pixels
            ;Put $PullDistance in pixels divider to go to a 1000px distance from enemy
            $Ratio = 1/$Ratio ;Reverse ratio around 1, permitting the use in defining the new distances to get a total distance of $PullDistance in pixels

            $DistToEnemyX_ = $Ratio * $DistToEnemyX
            $DistToEnemyY_ = $Ratio * $DistToEnemyY

            $MyNewPosX = $MyPosX - $DistToEnemyX_
            $MyNewPosY = $MyPosY - $DistToEnemyY_

            MoveTo($MyNewPosX, $MyNewPosY)
            Return True
		EndIf
    EndIf

    Return False
EndFunc

Func PullMobs($PullDistance = 1000) ;Pull mobs back on a straigh line to $PullDistance in pixels based on character's pos and mob's pos
	Local $NearestEnemy
	Local $EnemyPosX, $EnemyPosY

	Local $lAgent = GetAgentByID(GetMyID())
	Local $MyPosX = DllStructGetData($lAgent, 'X')
	Local $MyPosY = DllStructGetData($lAgent, 'Y')

    Local $DistToEnemyX, $DistToEnemyY, $DistToEnemy
    Local $DistToEnemyX_, $DistToEnemyY_
    Local $Ratio

    Local $MyNewPosX, $MyNewPosY

    If ((GetNumberOfSpecialFoesInRangeOfAgent(-2, 1300) > 0) OR (GetNumberOfFoesInRangeOfAgent(-2, 1300) > 0)) Then
        Local $lDeadlock = TimerInit()
        Do
            TargetNearestEnemy()
            $NearestEnemy = GetCurrentTarget()
            Attack(-1)
            CastSkillFromBuild(1)
            Sleep(3000)
        Until GetDistance($lAgent, $NearestEnemy) < 1000 OR TimerDiff($lDeadlock) > 5000
    EndIf

    ;logFile("Danger: " & GetAgentDanger($lAgent))

	;If (GetAgentDanger($lAgent) > 0) Then
        ;logFile("Danger")
		If ((GetNumberOfSpecialFoesInRangeOfAgent(-2, 1300) > 0) OR (GetNumberOfFoesInRangeOfAgent(-2, 1300) > 0)) Then
			;logFile("Enemy")
            TargetNearestEnemy()
			$NearestEnemy = GetCurrentTarget()
			$EnemyPosX = DllStructGetData($NearestEnemy, 'X')
			$EnemyPosY = DllStructGetData($NearestEnemy, 'Y')

            $DistToEnemyX = Abs($MyPosX-$EnemyPosX) ;Distance to enemy on X axis
            $DistToEnemyY = Abs($MyPosY-$EnemyPosY) ;Distance to enemy on Y axis
            $DistToEnemy = GetDistance($lAgent, $NearestEnemy)

            $Ratio = $DistToEnemy / $PullDistance ;Get Distance to enemy ratio to $PullDistance in pixels
            ;Put $PullDistance in pixels divider to go to a 1000px distance from enemy
            $Ratio = 1/$Ratio ;Reverse ratio around 1, permitting the use in defining the new distances to get a total distance of $PullDistance in pixels

            $DistToEnemyX_ = $Ratio * $DistToEnemyX
            $DistToEnemyY_ = $Ratio * $DistToEnemyY

            $MyNewPosX = $MyPosX - $DistToEnemyX_
            $MyNewPosY = $MyPosY - $DistToEnemyY_

            MoveTo($MyNewPosX, $MyNewPosY)
            Return True
		EndIf
    ;EndIf

    Return False
EndFunc

			#Region Ranger Pet
Func Check_RangerPet_Dead() ;If pet is dead, then Returns True, else Returns False
	If RangerPet_present() Then
		If GetIsDead(GetCurrentTarget()) Then
			Return True
		EndIf
	EndIf

	Return False
EndFunc

Func RangerPet_present() ;Check if a ranger's pet is present in the party Return True if yes, or False if not
;Pet will be targeted if found
	Local $Primary = GetAgentPrimaryProfession(-2)
    Local $Secondary = GetAgentSecondaryProfession(-2)

	Local $Target
	Local $i

	If (($Primary == 2) OR ($Secondary == 2)) Then ;If is a ranger R/... or .../R
		;logFile("Party size: " & GetPartySize())
        If (GetPartySize() > 1) Then ;Check offsets maybe outdated
			TargetSelf()

			For $i = 0 To GetPartySize()
				TargetNextPartyMember()
				$Target = GetCurrentTarget()
				If isRangerPet($Target) Then
					Return True
				EndIf
			Next
		EndIf
	EndIf

	Return False
EndFunc

Func isRangerPet($aAgent) ;Check if Agent is a pet based on the Agent struct Returns True or False
	Local $Allegiance = DllStructGetData($lAgent, 'Allegiance')
    Local $lAgentMID = DllStructGetData($lAgent, 'PlayerNumber')

    If ($Allegiance == 4) Then
        Switch $lAgentMID
            Case 1339 ;Strider (Moa Bird)
                Return True
            Case 1342 ;Wolf
                Return True
            Case 1344 ;Warthog (Pig)
                Return True
            Case 1348 ;Black Bear
                Return True
            Case 1364 ;Melandru's Stalker
                Return True
            Case Else
                Return False
        EndSwitch
    EndIf
EndFunc
			#EndRegion Ranger Pet

            #Region PCons use functions
Func UsePcons_BasedOnGUI() ;Check if the user choosed to use Pcons and if the player is not already under pcons, uses pcons
    If (GUICtrlRead($UsePcons_Sweets) = $GUI_CHECKED) Then CheckAndUse_SweetPcons(2)
    If (GUICtrlRead($UsePcons_Moral) = $GUI_CHECKED) Then CheckAndUse_MoralCons(2)
EndFunc
			#EndRegion
		#EndRegion

		#Region Player's Inventory handeling Functions
			#Region Count/Items Functions
Func CountSlots() ;Returns the number of slots remaining in the authorized bags (if no authorized bag, returns -1)
	Local $bag
	Local $temp = 0

	If (GUICtrlRead($SellBag1) == $GUI_CHECKED) Then
		$bag = GetBag(1)
		$temp += DllStructGetData($bag, 'slots') - DllStructGetData($bag, 'ItemsCount')
	EndIf
	If (GUICtrlRead($SellBag2) == $GUI_CHECKED) Then
		$bag = GetBag(2)
		$temp += DllStructGetData($bag, 'slots') - DllStructGetData($bag, 'ItemsCount')
	EndIf
	If (GUICtrlRead($SellBag3) == $GUI_CHECKED) Then
		$bag = GetBag(3)
		$temp += DllStructGetData($bag, 'slots') - DllStructGetData($bag, 'ItemsCount')
	EndIf
	If (GUICtrlRead($SellBag4) == $GUI_CHECKED) Then
		$bag = GetBag(4)
		$temp += DllStructGetData($bag, 'slots') - DllStructGetData($bag, 'ItemsCount')
	EndIf
	If ((GUICtrlRead($SellBag1) == $GUI_UNCHECKED) AND (GUICtrlRead($SellBag2) == $GUI_UNCHECKED) AND (GUICtrlRead($SellBag3) == $GUI_UNCHECKED) AND (GUICtrlRead($SellBag4) == $GUI_UNCHECKED)) Then ;If no bags authorized, return -1 (the bot is never gonna be marked as full and won't go to merchant)
		$temp = -1
	EndIf
	Return $temp
EndFunc   ;==>CountSlots

Func CheckIfInventoryIsFull() ;Returns True if not slot remaining, Else return False
	InventoryFullness_Display()
	If ((CountSlots() <= 3) AND (CountSlots() >= 0)) Then
		Return True
	Else
		Return False
	EndIf
EndFunc   ;==>CheckIfInventoryIsFull

Func GetFarmItemCount($ModelFarmID) ;Returns the number of an item by modelID in bags
	Local $FarmItem
	Local $aBag
	Local $aItem
	Local $i,$j
	For $i = 1 To 4
		$aBag = GetBag($i)
		For $j = 1 To DllStructGetData($aBag, "Slots")
			$aItem = GetItemBySlot($aBag, $j)
			If DllStructGetData($aItem, "ModelID") == $ModelFarmID Then
;~ 				If DllStructGetData($aitem, "ExtraID") == 10 Then
					$FarmItem += DllStructGetData($aItem, "Quantity")
;~ 				EndIf
			Else
				ContinueLoop
			EndIf
		Next
	Next
	Return $FarmItem
EndFunc

Func GetItemModelByFarm($FarmID) ;Return the modelID of the item the bot is farming in $FarmID
	If ($FarmID == 3) Then
		Return $ITEM_ID_PRE_Worn_Belt ;Worn Belts
	ElseIf ($FarmID == 4) Then
		Return $ITEM_ID_PRE_Dull_Carapace ;Dull Carapaces
	ElseIf ($FarmID == 5) Then
		Return $ITEM_ID_PRE_Baked_Husk ;Baked Husks
	ElseIf ($FarmID == 6) Then
		Return $ITEM_ID_PRE_Charr_Carving ;Charr Carvings
	ElseIf ($FarmID == 7) Then
		Return $ITEM_ID_PRE_Enchanted_Lodestone ;Enchanted Lodestones
	ElseIf ($FarmID == 8) Then
		Return $ITEM_ID_PRE_Gargoyle_Skull ;Gargoyle Skulls
	ElseIf ($FarmID == 9) Then
		Return $ITEM_ID_PRE_Grawl_Necklace ;Grawl Necklaces
	ElseIf ($FarmID == 10) Then
		Return $ITEM_ID_PRE_Icy_Lodestone ;Icy Lodestones
	ElseIf ($FarmID == 11) Then
		Return $ITEM_ID_Red_Iris_Flower ;Red Iris Flowers
	ElseIf ($FarmID == 12) Then
		Return $ITEM_ID_PRE_Skale_Fin ;Skale Fins
	ElseIf ($FarmID == 13) Then
		Return $ITEM_ID_PRE_Skeletal_Limb ;Skeletal Limbs
	ElseIf ($FarmID == 14) Then
		Return $ITEM_ID_PRE_Spider_Leg ;Spider Legs
	ElseIf ($FarmID == 15) Then
		Return $ITEM_ID_PRE_Unnartural_Seed ;Unnatural Seeds
	Else
		logFile("ERROR : Unable to get ModelID because $FarmID is not recognized.")
	EndIf
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

Func Count($FarmID) ;Counts and prints the number of Black dyes and Farmed items in Status console (Does not return a number)
	Local $itemcount

	CountAndLogDyes()
	If ($FarmID == 0) Then
		logFile("Error")
	ElseIf ($FarmID == 3) Then
		$itemcount = GetFarmItemCount($ITEM_ID_PRE_Worn_Belt)
		If ($itemcount > 0) Then
			logFile("Worn belts: " & $itemcount)
		EndIf
	ElseIf ($FarmID == 4) Then
		$itemcount = GetFarmItemCount($ITEM_ID_PRE_Dull_Carapace)
		If ($itemcount > 0) Then
			logFile("Dull carapaces: " & $itemcount)
		EndIf
	ElseIf ($FarmID == 5) Then
		$itemcount = GetFarmItemCount($ITEM_ID_PRE_Baked_Husk)
		If ($itemcount > 0) Then
			logFile("Baked husks: " & $itemcount)
		EndIf
	ElseIf ($FarmID == 6) Then
        $itemcount = GetFarmItemCount($ITEM_ID_PRE_Charr_Carving)
		If ($itemcount > 0) Then
			logFile("Charr carvings: " & $itemcount)
		EndIf
    ElseIf ($FarmID == 7) Then
        $itemcount = GetFarmItemCount($ITEM_ID_PRE_Enchanted_Lodestone)
		If ($itemcount > 0) Then
			logFile("Enchanted lodestone: " & $itemcount)
		EndIf
    ElseIf ($FarmID == 8) Then
        $itemcount = GetFarmItemCount($ITEM_ID_PRE_Gargoyle_Skull)
		If ($itemcount > 0) Then
			logFile("Gargoyle skull: " & $itemcount)
		EndIf
    ElseIf ($FarmID == 9) Then
        $itemcount = GetFarmItemCount($ITEM_ID_PRE_Grawl_Necklace)
		If ($itemcount > 0) Then
			logFile("Grawl necklace: " & $itemcount)
		EndIf
    ElseIf ($FarmID == 10) Then
        $itemcount = GetFarmItemCount($ITEM_ID_PRE_Icy_Lodestone)
		If ($itemcount > 0) Then
			logFile("Icy lodestone: " & $itemcount)
		EndIf
    ElseIf ($FarmID == 11) Then
        $itemcount = GetFarmItemCount($ITEM_ID_Red_Iris_Flower)
		If ($itemcount > 0) Then
			logFile("Red Iris flower: " & $itemcount)
		EndIf
    ElseIf ($FarmID == 12) Then
        $itemcount = GetFarmItemCount($ITEM_ID_PRE_Skale_Fin)
		If ($itemcount > 0) Then
			logFile("Skale fin: " & $itemcount)
		EndIf
    ElseIf ($FarmID == 13) Then
        $itemcount = GetFarmItemCount($ITEM_ID_PRE_Skeletal_Limb)
		If ($itemcount > 0) Then
			logFile("Skeletal limb: " & $itemcount)
		EndIf
    ElseIf ($FarmID == 14) Then
        $itemcount = GetFarmItemCount($ITEM_ID_PRE_Spider_Leg)
		If ($itemcount > 0) Then
			logFile("Spider leg: " & $itemcount)
		EndIf
    ElseIf ($FarmID == 15) Then
        $itemcount = GetFarmItemCount($ITEM_ID_PRE_Unnartural_Seed)
		If ($itemcount > 0) Then
			logFile("Unnatural seed: " & $itemcount)
		EndIf
    EndIf
EndFunc

Func Count_Enough_DayFarmable($ItemNumber) ;Count number of farmable items currently asked by Nicholas. If you have more items than $ItemNumber Returns 1
	Local $ItemCount

	$ItemCount = GetFarmItemCount(CurrentNickPreItem_ID())
	logFile(CurrentNickPreItem_Name()&": "&$ItemCount)

	If($ItemCount >= $ItemNumber) Then
		Return 1
	Else
		Return 0
	EndIf
EndFunc

Func Count_Enough_allFarmable($ItemNumber) ;Count all farmable items required by Nicholas and return 1 if you have $ItemNumber or more of each
	Local $itemcount
    Local $checkitem

    $checkitem = 0

    $itemcount = GetFarmItemCount($ITEM_ID_PRE_Worn_Belt)
    logFile("Worn belts: " & $itemcount)
	If ($itemcount < $ItemNumber) Then
		logFile("Not enough: Worn belts")
	Else
        $checkitem += 1
    EndIf

	$itemcount = GetFarmItemCount($ITEM_ID_PRE_Dull_Carapace)
    logFile("Dull carapaces: " & $itemcount)
	If ($itemcount < $ItemNumber) Then
        logFile("Not enough: Dull carapaces")
	Else
        $checkitem += 1
    EndIf

	$itemcount = GetFarmItemCount($ITEM_ID_PRE_Baked_Husk)
    logFile("Baked husks: " & $itemcount)
	If ($itemcount < $ItemNumber) Then
        logFile("Not enough: Baked husks")
	Else
        $checkitem += 1
    EndIf

    $itemcount = GetFarmItemCount($ITEM_ID_PRE_Charr_Carving)
    logFile("Charr carvings: " & $itemcount)
	If ($itemcount < $ItemNumber) Then
        logFile("Not enough: Charr carvings")
	Else
        $checkitem += 1
    EndIf

    $itemcount = GetFarmItemCount($ITEM_ID_PRE_Enchanted_Lodestone)
    logFile("Enchanted lodestone: " & $itemcount)
	If ($itemcount < $ItemNumber) Then
        logFile("Not enough: Enchanted lodestone")
	Else
        $checkitem += 1
    EndIf

    $itemcount = GetFarmItemCount($ITEM_ID_PRE_Gargoyle_Skull)
    logFile("Gargoyle skull: " & $itemcount)
	If ($itemcount < $ItemNumber) Then
        logFile("Not enough: Gargoyle skull")
	Else
        $checkitem += 1
    EndIf

    $itemcount = GetFarmItemCount($ITEM_ID_PRE_Grawl_Necklace)
    logFile("Grawl necklace: " & $itemcount)
	If ($itemcount < $ItemNumber) Then
        logFile("Not enough: Grawl necklace")
	Else
        $checkitem += 1
    EndIf

    $itemcount = GetFarmItemCount($ITEM_ID_PRE_Icy_Lodestone)
    logFile("Icy lodestone: " & $itemcount)
	If ($itemcount < $ItemNumber) Then
        logFile("Not enough: Icy lodestone")
	Else
        $checkitem += 1
    EndIf

    $itemcount = GetFarmItemCount($ITEM_ID_Red_Iris_Flower)
    logFile("Red Iris flower: " & $itemcount)
	If ($itemcount < $ItemNumber) Then
        logFile("Not enough: Red Iris flower")
	Else
        $checkitem += 1
    EndIf

    $itemcount = GetFarmItemCount($ITEM_ID_PRE_Skale_Fin)
    logFile("Skale fin: " & $itemcount)
	If ($itemcount < $ItemNumber) Then
        logFile("Not enough: Skale fin")
	Else
        $checkitem += 1
    EndIf

    $itemcount = GetFarmItemCount($ITEM_ID_PRE_Skeletal_Limb)
    logFile("Skeletal limb: " & $itemcount)
	If ($itemcount < $ItemNumber) Then
        logFile("Not enough: Skeletal limb")
	Else
        $checkitem += 1
    EndIf

    $itemcount = GetFarmItemCount($ITEM_ID_PRE_Spider_Leg)
    logFile("Spider leg: " & $itemcount)
	If ($itemcount < $ItemNumber) Then
        logFile("Not enough: Spider leg")
	Else
        $checkitem += 1
    EndIf

    $itemcount = GetFarmItemCount($ITEM_ID_PRE_Unnartural_Seed)
	logFile("Unnatural seed: " & $itemcount)
	If ($itemcount < $ItemNumber) Then
        logFile("Not enough: Unnatural seed")
	Else
        $checkitem += 1
    EndIf

    If ($checkitem == 13) Then ;Check if all item counts are above 26
        Return 1
    Else
        Return 0
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
			#EndRegion

			#Region Merchant Functions
Func GoToMerchantOmniTown($MapID = 0) ;Find the merchant in the town based on $MapID
	Local $lAgent = GetAgentByID(-2)
	Local $MyPosX = DllStructGetData($lAgent, 'X')
	Local $MyPosY = DllStructGetData($lAgent, 'Y')

	If ($MapID == 0) Then
		$MapID = 148
		logFile("Unable to find the $MapID.")
		logFile("Teleporting to Ascalon City.")
		RndTravel($MapID)
		WaitMapLoading($MapID)
	EndIf
 	logFile("Going to merchant at " & $MAP_ID[$MapID])
    If ($MapID == 148) Then ;Ascalon City
		If Not (($MyPosX < 8522) AND ($MyPosX > 8322) AND ($MyPosY < 5006) AND ($MyPosY > 4806)) Then ;If not already on spot
			MoveTo(8436, 4819)
			$merchant = GetNearestNPCToCoords(8422, 4906)
			RNDSLP(1000)
			GoToNPC($merchant)
		EndIf
    ElseIf ($MapID == 164) Then ;Ashford Abbey
		If Not (($MyPosX < -11301) AND ($MyPosX > 11501) AND ($MyPosY < -6352) AND ($MyPosY > -6552)) Then ;If not already on spot
			MoveTo(-12569, -6312)
			$merchant = GetNearestNPCToCoords(-11401, -6452)
			RNDSLP(1000)
			GoToNPC($merchant)
		EndIf
    ElseIf ($MapID == 166) Then ;Fort Ranik
		If Not (($MyPosX < 24662) AND ($MyPosX > 24462) AND ($MyPosY < 10417) AND ($MyPosY > 10217)) Then ;If not already on spot
			MoveTo(23000, 11600)
			$merchant = GetNearestNPCToCoords(24562, 10317)
			RNDSLP(1000)
			GoToNPC($merchant)
		EndIf
    ElseIf ($MapID == 165) Then ;Foible's Fair
		If Not (($MyPosX < -470) AND ($MyPosX > -670) AND ($MyPosY < 10266) AND ($MyPosY > 10066)) Then ;If not already on spot
			MoveTo(-570, 10166)
			$merchant = GetNearestNPCToCoords(-973, 10754)
			RNDSLP(1000)
			GoToNPC($merchant)
		EndIf
    ElseIf ($MapID == 163) Then ;The Barradin Estate
		If Not (($MyPosX < -6300) AND ($MyPosX > -6500) AND ($MyPosY < 1518) AND ($MyPosY > 1318)) Then ;If not already on spot
			MoveTo(-6400, 1418)
			$merchant = GetNearestNPCToCoords(-6454, 1195)
			RNDSLP(1000)
			GoToNPC($merchant)
		EndIf
    EndIf
EndFunc
			#EndRegion

			#Region Sell Functions
Func CanSell($aitem) ;Lists the unauthorized items to be sold and check if the item input can be sold
	Local $m = DllStructGetData($aitem, 'ModelID')
	Local $i = DllStructGetData($aitem, 'extraId')
    Local $lItemID = DllStructGetData($aItem, 'ID')

    If (GUICtrlRead($DontSellPurple) == $GUI_CHECKED) Then
        If (GetRarity($lItemID) == $RARITY_Purple) Then Return False ;Purple Item
        ;If (GetRarity($aitem) == $RARITY_Purple) Then Return False ;Purple Item
    EndIf

;    If (($m = 0) AND (GetRarity($aitem) <> $RARITY_White))  Then
    If ($m = 0) Then
        If (GetRarity($lItemID) == $RARITY_White) Then
            Return True
        Else
            Return False
        EndIf
	ElseIf (($m > 21785) And ($m < 21806)) Then ;Elite/Normal Tomes
		Return False
	ElseIf ($m = 146) Then
		If IsKeepedDye($i) Then
			Return False
		Else
			Return True
		 EndIf
	ElseIf ($m = $ITEM_ID_ID_Kit) Then ;ID Kit = 2989
		Return False
    ElseIf ($m = 18721) Then ;Charr salvage kit
		Return False
    ElseIf ($m = 16453) Then ;Charr Bag
		Return False
	ElseIf ($m = $ITEM_ID_PRE_Worn_Belt) Then ;Worn Belt
		Return False
	ElseIf ($m = $ITEM_ID_PRE_Dull_Carapace) Then ;Dull Carapace
		Return False
	ElseIf ($m = $ITEM_ID_PRE_Baked_Husk) Then ;Baked Husk
		Return False
	ElseIf ($m = $ITEM_ID_PRE_Charr_Carving) Then ;Charr Carving
		Return False
	ElseIf ($m = $ITEM_ID_PRE_Enchanted_Lodestone) Then ;Enchanted Lodestone
		Return False
    ElseIf ($m = $ITEM_ID_PRE_Gargoyle_Skull) Then ;Gargoyle Skull
		Return False
    ElseIf ($m = $ITEM_ID_PRE_Grawl_Necklace) Then ;Grawl Necklace
		Return False
    ElseIf ($m = $ITEM_ID_PRE_Icy_Lodestone) Then ;Icy Lodestone
		Return False
    ElseIf ($m = $ITEM_ID_Red_Iris_Flower) Then ;Red Iris flower
		Return False
    ElseIf ($m = $ITEM_ID_PRE_Skale_Fin) Then ;Skale Fin
		Return False
    ElseIf ($m = $ITEM_ID_PRE_Skeletal_Limb) Then ;Skeletal Limb
		Return False
    ElseIf ($m = $ITEM_ID_PRE_Spider_Leg) Then ;Spider Leg
		Return False
    ElseIf ($m = $ITEM_ID_PRE_Unnartural_Seed) Then ;Unnatural Seed
		Return False
	Else
		Return True
	EndIf
EndFunc   ;==>CanSell

Func Sell($bagIndex) ;Sell all authorized items in a bag
	$bag = GetBag($bagIndex)
	$numOfSlots = DllStructGetData($bag, 'slots')
	For $i = 1 To $numOfSlots
		$aitem = GetItemBySlot($bagIndex, $i)
		If DllStructGetData($aitem, 'ID') = 0 Then ContinueLoop
		If CanSell($aitem) Then
            logFile("Selling item " & $i & " in bag " & $bagIndex)
			SellItem($aitem)
		EndIf
		RndSleep(250)
	Next
EndFunc   ;==>Sell

Func SellItemToMerchantOmniTown($MapID = 0) ;Sell authorized items in authorized bags
	GoToMerchantOmniTown($MapID)

	If (GUICtrlRead($SellBag1) == $GUI_CHECKED) Then ;Check if bag1 is authorized to be sold
		Sell(1)
	EndIf
	If (GUICtrlRead($SellBag2) == $GUI_CHECKED) Then ;Check if bag2 is authorized to be sold
		Sell(2)
	EndIf
	If (GUICtrlRead($SellBag3) == $GUI_CHECKED) Then ;Check if bag3 is authorized to be sold
		Sell(3)
	EndIf
	If (GUICtrlRead($SellBag4) == $GUI_CHECKED) Then ;Check if bag4 is authorized to be sold
		Sell(4)
	EndIf
EndFunc
			#EndRegion

			#Region Identification Function
Func FindIDKit_Presearing() ;Returns item ID of ID kit in inventory.
	Local $lItem
	Local $lKit = 0
	Local $lUses = 101
	For $i = 1 To 4
		For $j = 1 To DllStructGetData(GetBag($i), 'Slots')
			$lItem = GetItemBySlot($i, $j)
			Switch DllStructGetData($lItem, 'ModelID')
				Case $ITEM_ID_ID_Kit
					If DllStructGetData($lItem, 'Value') / 2 < $lUses Then
						$lKit = DllStructGetData($lItem, 'ID')
						$lUses = DllStructGetData($lItem, 'Value') / 2
					EndIf
				Case $ITEM_ID_SUP_ID_Kit
					If DllStructGetData($lItem, 'Value') / 2.5 < $lUses Then
						$lKit = DllStructGetData($lItem, 'ID')
						$lUses = DllStructGetData($lItem, 'Value') / 2.5
					EndIf
				Case Else
					ContinueLoop
			EndSwitch
		Next
	Next
	Return $lKit
EndFunc   ;==>FindIDKit

Func CheckAndIdent($bagIndex) ;Check if the player has an IDKit, if not go buy one, then Identify unID (blue, purple, gold) items in a bag
	If (FindIDKit_Presearing() = 0) Then
		If (GetGoldCharacter() >= 100) Then BuyIDKit()
		RndSleep(500)
	Else
		IdentifyBag($bagIndex)
	EndIf
EndFunc   ;==>IDENT

Func IdentItemToMerchantOmniTown($MapID = 0) ;Ident items in authorized bags
	GoToMerchantOmniTown($MapID)

	If (GUICtrlRead($SellBag1) == $GUI_CHECKED) Then ;Check if bag1 is authorized to be sold
		CheckAndIdent(1)
	EndIf
	If (GUICtrlRead($SellBag2) == $GUI_CHECKED) Then ;Check if bag2 is authorized to be sold
		CheckAndIdent(2)
	EndIf
	If (GUICtrlRead($SellBag3) == $GUI_CHECKED) Then ;Check if bag3 is authorized to be sold
		CheckAndIdent(3)
	EndIf
	If (GUICtrlRead($SellBag4) == $GUI_CHECKED) Then ;Check if bag4 is authorized to be sold
		CheckAndIdent(4)
	EndIf
EndFunc
			#EndRegion
		#EndRegion

		#Region Environnement Interactions Functions
Func LeverOpenDoor() ;Use the charr's door lever
    Local $Lever

    $Lever = GetNearestSignpostToCoords(-5508,12787)
    GoSignpost($Lever)
EndFunc

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
	Local $i = DllStructGetData($aitem, 'extraId')
	Local $r = GetRarity($aitem)

    If ($m == 2557) Then Return False ;Beautifull Feather

    If (($m == 2510) OR ($m == 2511)) Then ;If is Golds coins
        Return True
	ElseIf ($m = 146) Then ;Dyes
		If IsKeepedDye($i) Then
			Return True
		Else ;TODO pickup dyes color based on GUI
			Return False
		EndIf
	ElseIf (($m == 425) OR ($m == 433) OR ($m = 423) OR ($m = 431) OR ($m = 426) OR ($m = 432) OR ($m = 424) OR ($m = 429) OR ($m = 430) OR ($m = 422) OR ($m = 428)) Then ;Pickup farmable Nicholas' items
		Return True
    ElseIf ($m = 2994) Then ;Red Iris flower
		Return False
    ElseIf ($m = 427) Then ;Worn Belt
		Return True
    ElseIf ($m = 2552) Then ;Ashford StrongBox
		Return False
    ElseIf ($m = 36681) Then ;Delcious cakes
		Return True
   ;ElseIf (($r == $RARITY_Blue) AND ($m = 0)) Then ;Ash Fiend Armor
		;Return True
    ;ElseIf (($r == $RARITY_Blue) AND ($m = 1)) Then ;Axe Fiend Armor
		;Return True
    ;ElseIf (($r == $RARITY_Blue) AND ($m = 2)) Then ;Flame Wielders Trappings
		;Return True
    ;ElseIf (($r == $RARITY_Blue) AND ($m = 3)) Then ;mindspark garb
		;Return True
    ;ElseIf (($r == $RARITY_Blue) AND ($m = 4)) Then ;shaman garb
		;Return True
    ;ElseIf (($r == $RARITY_Blue) AND ($m = 5)) Then ;Stalker armor
		;Return True
    ElseIf CheckArrayPscon($m)Then ; If is a Pcons or event item
		Return True
	ElseIf (($r == $RARITY_Green) AND (GUICtrlRead($PickGreen) == $GUI_CHECKED)) Then
		Return True
    ElseIf (($r = $RARITY_Gold) AND (GUICtrlRead($PickGold) == $GUI_CHECKED)) Then
		Return True
	ElseIf (($r == $RARITY_Purple) AND (GUICtrlRead($PickPurple) == $GUI_CHECKED)) Then
		Return True
	ElseIf (($r == $RARITY_Blue) AND (GUICtrlRead($PickBlue) == $GUI_CHECKED)) Then
		Return True
	ElseIf (($r == $RARITY_White) AND (GUICtrlRead($PickWhite) == $GUI_CHECKED)) Then
		Return True
	Else
		Return False
	EndIf
EndFunc   ;==>CanPickUp

Func CheckArrayPscon($lModelID)
	For $p = 0 To (UBound($Array_pscon) -1)
		If ($lModelID == $Array_pscon[$p]) Then Return True
	Next
EndFunc
		#EndRegion
	#EndRegion
#EndRegion

#Region Extra Functions
	#Region Map interaction Functions
Func RandomPath($PortalPosX, $PortalPosY, $OutPosX, $OutPosY, $aRandom = 50, $StopsMin = 1, $StopsMax = 5, $NumberOfStops = -1) ; do not change $NumberOfStops

	If $NumberOfStops = -1 Then $NumberOfStops = Random($StopsMin, $StopsMax, 1)

	Local $lAgent = GetAgentByID(-2)
	Local $MyPosX = DllStructGetData($lAgent, 'X')
	Local $MyPosY = DllStructGetData($lAgent, 'Y')
	Local $Distance = ComputeDistance($MyPosX, $MyPosY, $PortalPosX, $PortalPosY)

	If $NumberOfStops = 0 Or $Distance < 200 Then
		MoveTo($PortalPosX, $PortalPosY, (2 * $aRandom)) ; Made this last spot a bit broader
		Move($OutPosX + Random(-$aRandom, $aRandom, 1), $OutPosY + Random(-$aRandom, $aRandom, 1))
	Else
		Local $m = Random(0, 1)
		Local $n = $NumberOfStops - $m
		Local $StepX = (($m * $PortalPosX) + ($n * $MyPosX)) / ($m + $n)
		Local $StepY = (($m * $PortalPosY) + ($n * $MyPosY)) / ($m + $n)

		MoveTo($StepX, $StepY, $aRandom)
		RandomPath($PortalPosX, $PortalPosY, $OutPosX, $OutPosY,  $aRandom, $StopsMin, $StopsMax, $NumberOfStops - 1)
	EndIf
EndFunc

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

Func MoveToXYZ($aX, $aY, $aZ, $aRandom = 50) ;Move to a location and wait until you reach it.
	Local $lBlocked = 0
	Local $lMe
	Local $lMapLoading = GetMapLoading(), $lMapLoadingOld
	Local $lDestX = $aX + Random(-$aRandom, $aRandom)
	Local $lDestY = $aY + Random(-$aRandom, $aRandom)
	Local $lDestZ = $aZ

	MoveXYZ($lDestX, $lDestY, $lDestZ, 0)

	Do
		Sleep(100)
		$lMe = GetAgentByID(-2)

		If DllStructGetData($lMe, 'HP') <= 0 Then ExitLoop

		$lMapLoadingOld = $lMapLoading
		$lMapLoading = GetMapLoading()
		If $lMapLoading <> $lMapLoadingOld Then ExitLoop

		If DllStructGetData($lMe, 'MoveX') == 0 And DllStructGetData($lMe, 'MoveY') == 0 And DllStructGetData($lMe, 'MoveZ') == 0 Then
			$lBlocked += 1
			$lDestX = $aX + Random(-$aRandom, $aRandom)
			$lDestY = $aY + Random(-$aRandom, $aRandom)
			$lDestZ = $aZ
			MoveXYZ($lDestX, $lDestY, $lDestZ, 0)
		EndIf
	Until ComputeDistance(DllStructGetData($lMe, 'X'), DllStructGetData($lMe, 'Y'), $lDestX, $lDestY) < 25 OR ComputeDistance(DllStructGetData($lMe, 'X'), DllStructGetData($lMe, 'Z'), $lDestX, $lDestZ) < 25 OR ComputeDistance(DllStructGetData($lMe, 'Y'), DllStructGetData($lMe, 'Z'), $lDestY, $lDestZ) < 25 OR	$lBlocked > 14
EndFunc   ;==>MoveTo

Func MoveXYZ($aX, $aY, $aZ, $aRandom = 50) ;Move to a location.
	;returns true if successful
	If GetAgentExists(-2) Then
		DllStructSetData($mMove, 2, $aX + Random(-$aRandom, $aRandom))
		DllStructSetData($mMove, 3, $aY + Random(-$aRandom, $aRandom))
		DllStructSetData($mMove, 4, $aZ)
		Enqueue($mMovePtr, 16)
		Return True
	Else
		Return False
	EndIf
EndFunc   ;==>Move

Func CheckStuck_MoveTo($aDestX, $aDestY, $aRandom = 50) ;Checks if you are stuck, tries to unstuck, and moveTo
	If Not $BotRunning Then Return

    Local $Quit = False
    Local $Pulled = False
    Local $lBlocked
	Local $HealthHP
	Local $lAgent = GetAgentByID(-2)
	Local $MyPosX = DllStructGetData($lAgent, 'X')
	Local $MyPosY = DllStructGetData($lAgent, 'Y')

    UsePcons_BasedOnGUI()

    Move($aDestX, $aDestY, $aRandom)

	Do
        $lAgent = GetAgentByID(-2)
		RndSleep(200)
		If GetIsDead($lAgent) Then
            $Quit = True
            Return False
        EndIf

        CheckAndUseStone(1)

		If ((GetNumberOfSpecialFoesInRangeOfAgent(-2, 1250) > 0) OR (GetNumberOfFoesInRangeOfAgent(-2, 1250) > 0)) Then
            ;If ((GetJobId() == 6) OR (GetJobId() == 18)) Then
            ;    If Not $Pulled Then
            ;        $Pulled = PullMobs()
            ;    EndIf
            ;EndIf
            KillMobs()
            CheckAndPickUp()
		EndIf

		$HealthHP = ((GetHealth(-2)) * 100/(DllStructGetData(GetAgentByID(-2), 'MaxHP')))

		While ($HealthHP < 75)
            $lAgent = GetAgentByID(-2)
            If GetIsDead($lAgent) Then
                $Quit = True
                Return False
            EndIf
            If ((GetNumberOfSpecialFoesInRangeOfAgent(-2, 1250) > 0) OR (GetNumberOfFoesInRangeOfAgent(-2, 1250) > 0)) Then
                If ((GetJobId() == 6) OR (GetJobId() == 18)) Then ;Charrs farm
                    If Not $Pulled Then
                        $Pulled = PullMobs()
                    EndIf
                EndIf
                KillMobs()
                CheckAndPickUp()
            Else
                CastSkillFromBuild(0)
            EndIf
            $HealthHP = ((GetHealth(-2)) * 100/(DllStructGetData(GetAgentByID(-2), 'MaxHP')))
        WEnd
		If Not GetIsMoving($lAgent) Then
            $lBlocked += 1
            If ($lBlocked > 5) Then logFile("Blocked: " & $lBlocked)
            Move($aDestX, $aDestY, $aRandom)
            If ($lBlocked > 20) Then
                If ((GetJobId() == 6) OR (GetJobId() == 18)) Then ;Charrs farm
                    If Check_atReviveSanctuary() Then
                        GoBackToCheckpoint($CharrCheckPoint)
                        $Quit = True
                    EndIf
                EndIf
            EndIf
            If ($lBlocked > 100) Then
                If $BotRunning Then
                    logFile("Restarting Action.")
                    DoActions()
                    Return False
                Else
                    Return False
                EndIf
            EndIf
		EndIf
		$MyPosX = DllStructGetData($lAgent, 'X')
		$MyPosY = DllStructGetData($lAgent, 'Y')

        If (ComputeDistance($MyPosX, $MyPosY, $aDestX, $aDestY) < 250) Then $Quit = True
        $lAgent = GetAgentByID(-2)
        If GetIsDead($lAgent) Then $Quit = True
    Until $Quit
EndFunc
	#EndRegion

	#Region Item Functions
Func GetExtraItemInfo($aitem)
    If IsDllStruct($aitem) = 0 Then $aAgent = GetItemByItemID($aitem)
    $lItemExtraPtr = DllStructGetData($aitem, "namestring")

    DllCall($mHandle[0], 'int', 'ReadProcessMemory', 'int', $mHandle[1], 'int', $lItemExtraPtr, 'ptr', $lItemExtraStructPtr, 'int', $lItemExtraStructSize, 'int', '')
    Return $lItemExtraStruct
EndFunc   ;==>GetExtraItemInfo
	#EndRegion

	#Region Chat Functions
Func Update($aText, $aFlag = 0)  ;~ Description: Writes text to chat.
;~    Out($text)
   TraySetToolTip(GetCharname() & @CRLF & $aText)
   $OldGuiText = $aText
   WriteChat($aText, $aFlag)
   ConsoleWrite($aText & @CRLF)
   $RestTimer = TimerInit()
EndFunc   ;==>Update
	#EndRegion
 #EndRegion