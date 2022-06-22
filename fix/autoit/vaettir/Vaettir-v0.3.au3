#cs
#################################
#                               #
#          Vaettir Bot          #
#                               #
#################################
Author: gigi
Modified by;
Pink Musen (v.01), Deroni93 (v.02-3)

#ce

#RequireAdmin
;#include "GWA2_Headers.au3"
#NoTrayIcon
Global Const $Version = "0.3"

#include "GWA2.au3"
#include "GWA2_Modstruct_Items.au3"
#include "Constants.au3"
#include "Looting.au3"
#include <ButtonConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <ScrollBarsConstants.au3>
#include <WindowsConstants.au3>
#include <ComboConstants.au3>
#include <FileConstants.au3>
#include <Date.au3>
#include <GuiEdit.au3>
Opt("GUIOnEventMode", True)
Opt("GUICloseOnESC", False)
; Opt("MustDeclareVars", True)

Global $charName  = ""
Global $ProcessID = ""
Global $cmdmode   = false
Global $timer = TimerInit()

Global $statPlatinum = 0
Global $statExperience = 0
Global $statTitlePoints = 0

If $CmdLine[0] = 0 Then
Else
    $cmdmode = true

    If 1 > UBound($CmdLine)-1 Then exit; element is out of the array bounds
    If 2 > UBound($CmdLine)-1 Then exit;

    $charName  = $CmdLine[1]
    $ProcessID = $CmdLine[2]
    LOGIN($charName, $ProcessID)
EndIf


; ==== Constants ====
;GUISetup()
Global Enum $Difficulty_Normal, $Difficulty_Hard
Global Enum $InstanceType_Outpost, $InstanceType_Explorable, $InstanceType_LOADING
Global Enum $Range_Adjacent=156, $Range_Nearby=240, $Range_Area=312, $Range_Earshot=1000, $Range_Spellcast = 1085, $Range_Spirit = 2500, $Range_Compass = 5000
Global Enum $Range_Adjacent_2=156^2, $Range_Nearby_2=240^2, $Range_Area_2=312^2, $Range_Earshot_2=1000^2, $Range_Spellcast_2=1085^2, $Range_Spirit_2=2500^2, $Range_Compass_2=5000^2
Global Enum $Prof_None, $Prof_Warrior, $Prof_RangeR, $Prof_Monk, $Prof_Necromancer, $Prof_Mesmer, $Prof_Elementalist, $Prof_Assassin, $Prof_Ritualist, $Prof_Paragon, $Prof_Dervish

Global Const $Map_ID_Bjora = 482
Global Const $Map_ID_Jaga = 546
Global Const $Town_ID_Longeye = 650
Global Const $Town_ID_Great_Temple_of_Balthazar = 248

;~ All Weapon mods
Global $Weapon_Mod_Array[25] = [893, 894, 895, 896, 897, 905, 906, 907, 908, 909, 6323, 6331, 15540, 15541, 15542, 15543, 15544, 15551, 15552, 15553, 15554, 15555, 17059, 19122, 19123]

;~ General Items
Global $General_Items_Array[6] = [2989, 2991, 2992, 5899, 5900, 22751]

;~ Alcohol
Global $Alcohol_Array[19] = [910, 2513, 5585, 6049, 6366, 6367, 6375, 15477, 19171, 19172, 19173, 22190, 24593, 28435, 30855, 31145, 31146, 35124, 36682]
Global $OnePoint_Alcohol_Array[11] = [910, 5585, 6049, 6367, 6375, 15477, 19171, 19172, 19173, 22190, 28435]
Global $ThreePoint_Alcohol_Array[7] = [2513, 6366, 24593, 30855, 31145, 31146, 35124]
Global $FiftyPoint_Alcohol_Array[1] = [36682]

;~ Party
Global $Spam_Party_Array[5] = [6376, 21809, 21810, 21813, 36683]

;~ Sweets
Global $Spam_Sweet_Array[6] = [21492, 21812, 22269, 22644, 22752, 28436]

;~ Tonics
Global $Tonic_Party_Array[4] = [15837, 21490, 30648, 31020]

;~ DR Removal
Global $DPRemoval_Sweets[6] = [6370, 21488, 21489, 22191, 26784, 28433]

;~ Special Drops
Global $Special_Drops[7] = [5656, 18345, 21491, 37765, 21833, 28433, 28434]

;~ Stackable Trophies
Global $Stackable_Trophies_Array[1] = [27047]
Global Const $Item_ID_Glacial_Stones = 27047

;~ Materials
Global $All_Materials_Array[36] = [921, 922, 923, 925, 926, 927, 928, 929, 930, 931, 932, 933, 934, 935, 936, 937, 938, 939, 940, 941, 942, 943, 944, 945, 946, 948, 949, 950, 951, 952, 953, 954, 955, 956, 6532, 6533]
Global $Common_Materials_Array[11] = [921, 925, 929, 933, 934, 940, 946, 948, 953, 954, 955]
Global $Rare_Materials_Array[25] = [922, 923, 926, 927, 928, 930, 931, 932, 935, 936, 937, 938, 939, 941, 942, 943, 944, 945, 949, 950, 951, 952, 956, 6532, 6533]

;~ Tomes
Global $All_Tomes_Array[20] = [21796, 21797, 21798, 21799, 21800, 21801, 21802, 21803, 21804, 21805, 21786, 21787, 21788, 21789, 21790, 21791, 21792, 21793, 21794, 21795]


;~ Arrays for the title spamming (Not inside this version of the bot, but at least the arrays are made for you)
Global $ModelsAlcohol[100] = [910, 2513, 5585, 6049, 6366, 6367, 6375, 15477, 19171, 22190, 24593, 28435, 30855, 31145, 31146, 35124, 36682]
Global $ModelSweetOutpost[100] = [15528, 15479, 19170, 21492, 21812, 22644, 31150, 35125, 36681]
Global $ModelsSweetPve[100] = [22269, 22644, 28431, 28432, 28436]
Global $ModelsParty[100] = [6368, 6369, 6376, 21809, 21810, 21813]

Global $Array_pscon[39]=[910, 5585, 6366, 6375, 22190, 24593, 28435, 30855, 31145, 35124, 36682, 6376, 21809, 21810, 21813, 36683, 21492, 21812, 22269, 22644, 22752, 28436,15837, 21490, 30648, 31020, 6370, 21488, 21489, 22191, 26784, 28433, 5656, 18345, 21491, 37765, 21833, 28433, 28434]

#Region Global MatsPic´s And ModelID´Select
Global $Pic_Mats[26][2] = [["Fur Square", 941],["Bolt of Linen", 926],["Bolt of Damask", 927],["Bolt of Silk", 928],["Glob of Ectoplasm", 930],["Steel of Ignot", 949],["Deldrimor Steel Ingot", 950],["Monstrous Claws", 923],["Monstrous Eye", 931],["Monstrous Fangs", 932],["Rubies", 937],["Sapphires", 938],["Diamonds", 935],["Onyx Gemstones", 936],["Lumps of Charcoal", 922],["Obsidian SHard", 945],["Tempered Glass Vial", 939],["Leather Squares", 942],["Elonian Leather Square", 943],["Vial of Ink", 944],["Rolls of Parchment", 951],["Rolls of Vellum", 952],["Spiritwood Planks", 956],["Amber Chunk", 6532],["Jadeite SHard", 6533]]
#EndRegion Global MatsPic´s And ModelID´Select

Global $Array_Store_ModelIDs460[147] = [474, 476, 486, 522, 525, 811, 819, 822, 835, 610, 2994, 19185, 22751, 4629, 24630, 4631, 24632, 27033, 27035, 27044, 27046, 27047, 7052, 5123 _
		, 1796, 21797, 21798, 21799, 21800, 21801, 21802, 21803, 21804, 1805, 910, 2513, 5585, 6049, 6366, 6367, 6375, 15477, 19171, 22190, 24593, 28435, 30855, 31145, 31146, 35124, 36682 _
		, 6376 , 6368 , 6369 , 21809 , 21810, 21813, 29436, 29543, 36683, 4730, 15837, 21490, 22192, 30626, 30630, 30638, 30642, 30646, 30648, 31020, 31141, 31142, 31144, 1172, 15528 _
		, 15479, 19170, 21492, 21812, 22269, 22644, 22752, 28431, 28432, 28436, 1150, 35125, 36681, 3256, 3746, 5594, 5595, 5611, 5853, 5975, 5976, 21233, 22279, 22280, 6370, 21488 _
		, 21489, 22191, 35127, 26784, 28433, 18345, 21491, 28434, 35121, 921, 922, 923, 925, 926, 927, 928, 929, 930, 931, 932, 933, 934, 935, 936, 937, 938, 939, 940, 941, 942, 943 _
		, 944, 945, 946, 948, 949, 950, 951, 952, 953, 954, 955, 956, 6532, 6533]

#EndRegion Global Items

#Region Guild Hall Globals
;~ Prophecies
Global $GH_ID_Warriors_Isle = 4
Global $GH_ID_Hunters_Isle = 5
Global $GH_ID_Wizards_Isle = 6
Global $GH_ID_Burning_Isle = 52
Global $GH_ID_Frozen_Isle = 176
Global $GH_ID_Nomads_Isle = 177
Global $GH_ID_Druids_Isle = 178
Global $GH_ID_Isle_Of_The_Dead = 179
;~ Factions
Global $GH_ID_Isle_Of_Weeping_Stone = 275
Global $GH_ID_Isle_Of_Jade = 276
Global $GH_ID_Imperial_Isle = 359
Global $GH_ID_Isle_Of_Meditation = 360
;~ Nightfall
Global $GH_ID_Uncharted_Isle = 529
Global $GH_ID_Isle_Of_Wurms = 530
Global $GH_ID_Corrupted_Isle = 537
Global $GH_ID_Isle_Of_Solitude = 538

Global $WarriorsIsle = False
Global $HuntersIsle = False
Global $WizardsIsle = False
Global $BurningIsle = False
Global $FrozenIsle = False
Global $NomadsIsle = False
Global $DruidsIsle = False
Global $IsleOfTheDead = False
Global $IsleOfWeepingStone = False
Global $IsleOfJade = False
Global $ImperialIsle = False
Global $IsleOfMeditation = False
Global $UnchartedIsle = False
Global $IsleOfWurms = False
Global $CorruptedIsle = False
Global $IsleOfSolitude = False
#EndRegion Guild Hall Globals

; ================== CONFIGURATION ==================
; True or false to load the list of logged in Characters or not
Global Const $doLoadLoggedChars = True
; ================ END CONFIGURATION ================

; ==== Bot global variables ====
Global $RenderingEnabled = True
Global $PickUpMapPieces = False
Global $PickUpTomes = False
Global $RunCount = 0
Global $FailCount = 0
Global $BotRunning = False
Global $BotInitialized = False
Global $ChatStuckTimer = TimerInit()
Global $Deadlocked = False
Global $CurGold = 0
Global $Bag_SLOTS[18] = [0, 20, 5, 10, 10, 20, 41, 12, 20, 20, 20, 20, 20, 20, 20, 20, 20, 9]

;~ Any pcons you want to use during a run
Global $pconsCupcake_slot[2]
Global $useCupcake = False ; set it on true and he use it

; ==== Build ====
Global Const $SkillBarTemplate = "OwVUI2h5lPP8Id2BkAiAvpLBTAA"
; declare skill numbers to make the code WAY more readable (UseSkill($Skill_ShadowForm ) is better than UseSkill(2))
Global Const $Skill_Paradox = 1
Global Const $Skill_ShadowForm  = 2
Global Const $Skill_Shroud = 3
Global Const $Skill_WayOfPerfection = 4
Global Const $Skill_Heart_of_Shadow = 5
Global Const $Skill_Wastrels_Demise = 6
Global Const $Skill_Arcane_Echo = 7
Global Const $Skill_Channeling = 8
; Store skills energy cost
Global $skillCost[9]
$skillCost[$Skill_Paradox] = 15
$skillCost[$Skill_ShadowForm ] = 5
$skillCost[$Skill_Shroud] = 10
$skillCost[$Skill_WayOfPerfection] = 5
$skillCost[$Skill_Heart_of_Shadow] = 5
$skillCost[$Skill_Wastrels_Demise] = 5
$skillCost[$Skill_Arcane_Echo] = 15
$skillCost[$Skill_Channeling] = 5
;~ Skill IDs
Global Const $Skill_ID_Shroud = 1031
Global Const $Skill_ID_Channeling = 38
Global Const $Skill_ID_Arcane_Echo = 75
Global Const $Skill_ID_Wastrels_Demise = 1335

#Region GUI
Global $MatID, $RareMatsBuy = False, $mFoundChest = False, $mFoundMerch = False, $Bags = 4, $PICKUP_GoldS = False
Global $Select_Mat = "Fur Square|Bolt of Linen|Bolt of Damask|Bolt of Silk|Glob of Ectoplasm|Steel of Ignot|Deldrimor Steel Ingot|Monstrous Claws|Monstrous Eye|Monstrous Fangs|Rubies|Sapphires|Diamonds|Onyx Gemstones|Lumps of Charcoal|Obsidian SHard|Tempered Glass Vial|Leather Squares|Elonian Leather Square|Vial of Ink|Rolls of Parchment|Rolls of Vellum|Spiritwood Planks|Amber Chunk|Jadeite SHard"
Global $LONGEYE = True

Global Const $mainGui 	  = GUICreate("vaettir v" & $Version, 234, 497, 373, 366)
                            GUISetIcon(@ScriptDir & "\Mesmer_Tango.ico")
                            TraySetIcon(@ScriptDir & "\Mesmer_Tango.ico")
					        GUISetOnEvent($GUI_Event_Close, "_exit")
Global $Input
If $doLoadLoggedChars Then
	$Input 				  = GUICtrlCreateCombo($charName, 8, 8, 217, 25)
						    GUICtrlSetData(-1, GetLoggedCharNames())
Else
	$Input 				  = GUICtrlCreateInput("Character name", 8, 8, 217, 25)
EndIf

Global Const $RunsLabel   = GUICtrlCreateLabel("Runs: " & $RunCount, 8, 444, 59, 17)
Global Const $FailsLabel  = GUICtrlCreateLabel("Fails: " & $FailCount, 100, 444, 59, 17)
Global Const $Button      = GUICtrlCreateButton("Start", 8, 409, 219, 31)
						    GUICtrlSetOnEvent($Button, "GuiButtonHandler")
Global $SelectMat         = GUICtrlCreateCombo("Rare Mats", 8, 35, 217, 150, BitOR($CBS_DROPDOWN, $CBS_AUTOHSCROLL))
Global $GUI_Console           = GUICtrlCreateEdit("", 16, 257, 201, 142, BitOR($ES_AUTOVSCROLL, $ES_AUTOHSCROLL, $ES_WANTRETURN, $WS_VSCROLL))
Global Const $Tomes       = GUICtrlCreateCheckbox("Mesmer Tomes", 8,60,100,20)
Global Const $White_Pickup = GUICtrlCreateCheckbox("Pickup Whites", 8,80,100,20)
Global Const $MapPieces   = GUICtrlCreateCheckbox("Map Pieces", 110, 60, 75, 17)
                            GUICtrlSetData($SelectMat, $Select_Mat)
                            GUICtrlSetOnEvent($SelectMat, "START_STOP")

              $Store   = GUICtrlCreateCheckbox   ("Store Golds", 110, 80, 75, 17)
                         GUICtrlSetState($Store, $GUI_Checked)
                         $DisableLooting = GUICtrlCreateCheckbox("Disable Looting", 8, 100, 100, 20)
                         $Group1 = GUICtrlCreateGroup("Norn Title Progression", 16, 128, 201, 41, BitOR($GUI_SS_DEFAULT_GROUP,$BS_CENTER))
                         $lblTitlePoints = GUICtrlCreateLabel("Points: ", 24, 144, 183, 18, $SS_CENTER)
                         GUICtrlCreateGroup("", -99, -99, 1, 1)
                         $Group2 = GUICtrlCreateGroup("Experience Gained", 16, 168, 201, 41, BitOR($GUI_SS_DEFAULT_GROUP,$BS_CENTER))
                         GUICtrlCreateGroup("", -99, -99, 1, 1)
                         $Group3 = GUICtrlCreateGroup("Gross Platinum", 16, 208, 201, 41, BitOR($GUI_SS_DEFAULT_GROUP,$BS_CENTER))
                         GUICtrlCreateGroup("", -99, -99, 1, 1)
                         $lblExperience = GUICtrlCreateLabel("Experience:", 24, 184, 181, 18, $SS_CENTER)
                         $lblPlatinum = GUICtrlCreateLabel("Platinum: ", 24, 224, 185, 18, $SS_CENTER)

Global Const $Goldies   = GUICtrlCreateLabel("Current Gold: " & $CurGold, 8, 464, 180, 17)
GUICtrlSetState($SelectMat, $GUI_Disable) ; Materials buy not fixed in GWA2 yet
GUISetState(@SW_SHOW)
GUISetOnEvent($GUI_Event_Close, "GuiButtonHandler")
#EndRegion GUI
;~ Description: Handles the button presses
Func GuiButtonHandler()
    Switch @GUI_CtrlId
        Case $Button
			If $BotRunning Then
        If GUICtrlRead($Button) == "Paused" Then
          GuiCtrlSetData($Button, "Pause")
          Return ;Cancels existing pause -- for test purposes only
        EndIf
				GUICtrlSetData($Button, "Will pause after this run")
				GUICtrlSetState($Button, $GUI_Disable)
				$BotRunning = False
			ElseIf $BotInitialized Then
				GUICtrlSetData($Button, "Pause")
				$BotRunning = True
			Else
				Out("Initializing")
				Local $CharName = GUICtrlRead($Input)
				If $CharName=="" Then
					If Initialize(ProcessExists("gw.exe"), True, True, False) = 0 Then
           MsgBox(0, "Error", "Guild Wars is not running.")
						_Exit()
					EndIf
                ElseIf $ProcessID and $cmdMode Then
                    $proc_id_int = Number($ProcessID, 2)
                    Out("Initializing in cmd mode via pid " & $proc_id_int)
                    If Initialize($proc_id_int, True, True, False) = 0 Then
                        MsgBox(0, "Error", "Could not Find a ProcessID or somewhat '"&$proc_id_int&"'  "&VarGetType($proc_id_int)&"'")
                        _Exit()
                        If ProcessExists($proc_id_int) Then
                            ProcessClose($proc_id_int)
                        EndIf
                        Exit
                    EndIf
                    SetPlayerStatus(0)
				Else
					If Initialize($CharName, True, True, False) = 0 Then
						MsgBox(0, "Error", "Could not Find a Guild Wars client with a Character named '"&$CharName&"'")
						_Exit()
					EndIf
				EndIf
				EnsureEnglish(True)
				;GUICtrlSetState($Checkbox, $GUI_Enable)
				; GUICtrlSetState($MapPieces, $GUI_Enable)
				GUICtrlSetState($Tomes, $GUI_Enable)
				GUICtrlSetState($Input, $GUI_Disable)
                ;GUICtrlSetState($LOCATION, $GUI_Disable)
				GUICtrlSetData($Button, "Pause")

				WinSetTitle($mainGui, "", GetCharname() & " - vaettir")
				$BotRunning = True
				$BotInitialized = True
			EndIf
        Case $GUI_Event_Close
            ;If Not $Rendering Then ToggleRendering()
            Exit
    EndSwitch
EndFunc


Func START_STOP()

	Switch (@GUI_CtrlId)
		Case $SelectMat
			MatSwitcher()
		 EndSwitch
EndFunc   ;==>START_STOP


Out("Vaettir Bot " & $Version)

If $cmdmode Then
    GUICtrlSendMsg($Button, $BM_CLICK, 0, 0)
    ToggleRendering()
Else
    Out("Waiting for input")
EndIf

While Not $BotRunning
	Sleep(100)
WEnd



While True
    If $BotRunning = True Then
	   MainFarm()
    Else
        Sleep(1000)
        If Random(1, 10, 1) = 1 Then
            UpdateLock()
        EndIf
    EndIf
WEnd

Func MainFarm()

  If CountSlots() < 5 & NOT (GUICtrlRead($DisableLooting) == $GUI_Checked) Then Inventory()

   If GetMapID() <> $Map_ID_JAGA Then
	  $LONGEYE = True
	  MapL()
	  RunThereLongeyes()
	  If (GetIsDead(-2)==True) Then Return
	  EndIf

    $PickUpMapPieces = False
    $statExperience = GetExperience()
    $statTitlePoints = GetNornTitle()

    If GUICtrlRead($Tomes) = 1 Then
        $PickUpTomes = False
    Else
        $PickUpTomes = False
    EndIf


    While (CountSlots() > 4)
        If Not $BotRunning Then
            Out("Bot Paused")
            GUICtrlSetState($Button, $GUI_Enable)
            GUICtrlSetData($Button, "Resume")
            Return
        EndIf

        If $Deadlocked Then
            $Deadlocked = False
            Inventory()
            Return
        EndIf

        CombatLoop()
    WEnd

    If (CountSlots() < 5) & NOT (GUICtrlRead($DisableLooting) == $GUI_Checked) Then
        If Not $BotRunning Then
            Out("Bot Paused")
            GUICtrlSetState($Button, $GUI_Enable)
            GUICtrlSetData($Button, "Resume")
            Return
        EndIf

        Inventory()
    EndIf
EndFunc

Func MapL()
   $CurGold = GetGoldCharacter()
   GUICtrlSetData($Goldies, "Current Gold: " & $CurGold)
;~ Checks if you are already in Longeye's Ledge, if not then you travel to Longeye's Ledge
	If GetMapID() <> $Town_ID_Longeye Then
		Out("Travelling to longeye")
		RndTravel($Town_ID_Longeye)
	EndIf
;~ Hardmode
	SwitchMode(1)

	Out("Exiting Outpost")
	MoveTo(-26472, 16217)
	WaitMapLoading($Map_ID_Bjora)

;~ Scans your bags for Cupcakes and uses one to make the run faster.
	pconsScanInventory()
	Sleep(GetPing()+500)
	UseCupcake()
	Sleep(GetPing()+500)
;~ Displays your Norn Title for the Health boost.
	;SetDisplayedTitle(0x29)
	;Sleep(GetPing()+500)
EndFunc

;~ Description: zones to longeye if we're not there, and travel to Jaga Moraine
Func RunThereLongeyes()
   $CurGold = GetGoldCharacter()
   GUICtrlSetData($Goldies, "Current Gold: " & $CurGold)
	Out("Running to farm spot")
	DIM $Array_Longeyes[31][3] = [ _
										[1, 15003.8, -16598.1], _
										[1, 15003.8, -16598.1], _
										[1, 12699.5, -14589.8], _
										[1, 11628,   -13867.9], _
										[1, 10891.5, -12989.5], _
										[1, 10517.5, -11229.5], _
										[1, 10209.1, -9973.1], _
										[1, 9296.5,  -8811.5], _
										[1, 7815.6,  -7967.1], _
										[1, 6266.7,  -6328.5], _
										[1, 4940,    -4655.4], _
										[1, 3867.8,  -2397.6], _
										[1, 2279.6,  -1331.9], _
										[1, 7.2,     -1072.6], _
										[1, 7.2,     -1072.6], _
										[1, -1752.7, -1209], _
										[1, -3596.9, -1671.8], _
										[1, -5386.6, -1526.4], _
										[1, -6904.2, -283.2], _
										[1, -7711.6, 364.9], _
										[1, -9537.8, 1265.4], _
										[1, -11141.2,857.4], _
										[1, -12730.7,371.5], _
										[1, -13379,  40.5], _
										[1, -14925.7,1099.6], _
										[1, -16183.3,2753], _
										[1, -17803.8,4439.4], _
										[1, -18852.2,5290.9], _
										[1, -19250,  5431], _
										[1, -19968, 5564], _
										[2, -20076,  5580]]
	Out("Running to Jaga")
	For $i = 0 To (UBound($Array_Longeyes) -1)
		If ($Array_Longeyes[$i][0]==1)Then
			If Not MoveRunning($Array_Longeyes[$i][1], $Array_Longeyes[$i][2])Then ExitLoop
		EndIf
		If ($Array_Longeyes[$i][0]==2)Then
			Move($Array_Longeyes[$i][1], $Array_Longeyes[$i][2], 30)
			WaitMapLoading($Map_ID_JAGA)
		EndIf
	Next
EndFunc


; Description: This is pretty much all, take bounty, do left, do right, kill, rezone
Func CombatLoop()

   $CurGold = GetGoldCharacter()

   Local $tGold = GetGoldCharacter() ;<== Required for totalising platinum

   GUICtrlSetData($Goldies, "Current Gold: " & $CurGold)
    Local $lTimer = TimerInit()
	If Not $RenderingEnabled Then ClearMemory()

    Local $norntitle = GetNornTitle()

	If $norntitle > 100 and $norntitle < 160000 Then
		Out("Taking Blessing")
		GoNearestNPCToCoords(13318, -20826)
		Dialog(132)
	EndIf
	SendChat("")
	DisplayCounts()

	Sleep(GetPing()+2000)

	Out("Moving to aggro left")
	MoveTo(13501, -20925)
	MoveTo(13172, -22137)
	TarGetNearestEnemy()
	MoveAggroing(12496, -22600, 150)
	MoveAggroing(11375, -22761, 150)
	MoveAggroing(10925, -23466, 150)
	MoveAggroing(10917, -24311, 150)
	MoveAggroing(9910, -24599, 150)
	MoveAggroing(8995, -23177, 150)
	MoveAggroing(8307, -23187, 150)
	MoveAggroing(8213, -22829, 150)
	MoveAggroing(8307, -23187, 150)
	MoveAggroing(8213, -22829, 150)
	MoveAggroing(8740, -22475, 150)
	MoveAggroing(8880, -21384, 150)
	MoveAggroing(8684, -20833, 150)
	MoveAggroing(8982, -20576, 150)

	Out("Waiting for left ball")
	WaitFor(12*1000)

	If GetDistance()<1000 Then
		UseSkillEx($Skill_Heart_of_Shadow, -1)
	Else
		UseSkillEx($Skill_Heart_of_Shadow, -2)
	EndIf

	WaitFor(6000)

	TarGetNearestEnemy()

	Out("Moving to aggro right")
	MoveAggroing(10196, -20124, 150)
	MoveAggroing(9976, -18338, 150)
	MoveAggroing(11316, -18056, 150)
	MoveAggroing(10392, -17512, 150)
	MoveAggroing(10114, -16948, 150)
	MoveAggroing(10729, -16273, 150)
	MoveAggroing(10810, -15058, 150)
	MoveAggroing(11120, -15105, 150)
	MoveAggroing(11670, -15457, 150)
	MoveAggroing(12604, -15320, 150)
	TarGetNearestEnemy()
	MoveAggroing(12476, -16157)

	;Out("Waiting for right ball")
	WaitFor(15*1000)

	If GetDistance()<1000 Then
		UseSkillEx($Skill_Heart_of_Shadow, -1)
	Else
		UseSkillEx($Skill_Heart_of_Shadow, -2)
	EndIf

	WaitFor(5000)

	;Out("Blocking enemies in spot")
	MoveAggroing(12920, -17032, 30)
	MoveAggroing(12847, -17136, 30)
	MoveAggroing(12720, -17222, 30)
	WaitFor(300)
	MoveAggroing(12617, -17273, 30)
	WaitFor(300)
	MoveAggroing(12518, -17305, 20)
	WaitFor(300)
	MoveAggroing(12445, -17327, 10)


   ;Avoids a rare-ish occurence where the bot starts the kill sequence just before SF runs out. Most noticeable on non Assassin primary Professions.
   Out("Waiting for Shadow Form")
   Local $lDeadlock_2 = TimerInit()
   $Skill_ShadowForm_Time = TimerDiff($timer)
   Out($Skill_ShadowForm_Time)
   Do
	  WaitFor(100)
	  If GetIsDead(-2) = 1 Then Return
   Until (TimerDiff($timer)) < $Skill_ShadowForm_Time Or (TimerDiff($lDeadlock_2) > 20000)

   UseSF(True)
   Out("Shadow Form casted")

   Kill()

	WaitFor(1200)

  IF NOT (GUICtrlRead($DisableLooting) == $GUI_Checked) Then
    Out("Looting")
    Loot()
  EndIf

  ;==> update rolling totals ==<
  updateStatistics($tGold)

  ;===> Test Start ===>
;  Out("Pausing")
  ;GUICtrlSetData($Button, "Paused")
;  Sleep(500)
;  Do
  ;  Sleep(100)
  ;Until GUICtrlRead($Button) <> "Paused"

  ;<=== Test End# <===

	If GetIsDead(-2) Then
		$FailCount += 1
		GUICtrlSetData($FailsLabel, "Fails: " & $FailCount)
		; StoreRun(GetCharname(), TimerDiff($lTimer), 0)
	Else
		$RunCount += 1
		GUICtrlSetData($RunsLabel, "Runs: " & $RunCount)
		; StoreRun(GetCharname(), TimerDiff($lTimer), 1)
	EndIf

	Out("Zoning")
	MoveAggroing(12289, -17700)
	MoveAggroing(15318, -20351)

    Local $tDeadLock = TimerInit()
	While GetIsDead(-2)
		Out("Waiting for res")
		Sleep(1000)
        If TimerDiff($tDeadLock) > 60000 Then
            $Deadlocked = True
            Return
        EndIf
	WEnd
   Out("Zoning to Bjora")
	Move(15865, -20531)
	WaitMapLoading($Map_ID_BJORA)
   Out("Zoning to Jaga Moraine")
	MoveTo(-19968, 5564)
	Move(-20076,  5580, 30)

	WaitMapLoading($Map_ID_JAGA)

	ClearMemory()
	; _PurgeHook()
EndFunc

Func updateStatistics($gold)

  $lExperience = GetExperience() - $statExperience
  $lTitlePoints = GetNornTitle() - $statTitlePoints
  ;==> update variables <==
  $statPlatinum += ((GetGoldCharacter()-$gold)/1000)
  $statExperience += $lExperience
  $statTitlePoints += $lTitlePoints
  ;==> update front end <==
  GuiCtrlSetData($lblPlatinum, "Platinum: " & $statPlatinum)
  GuiCtrlSetData($lblTitlePoints, "Points: " & $statTitlePoints)
  GuiCtrlSetData($lblExperience, "Experience: " & $statExperience)
EndFunc
; Func _PurgeHook()
; 	ToggleRendering()
; 	Sleep(Random(2000,2500))
; 	ToggleRendering()
; EndFunc   ;==>_PurgeHook

#CS
Description: use whatever skills you need to keep yourself alive.
Take agent array as param to more effectively react to the environment (mobs)
#CE
Func StayAlive(Const ByRef $lAgentArray)
	If IsRecharged($Skill_ShadowForm ) Then
		UseSkillEx($Skill_Paradox)
		UseSkillEx($Skill_ShadowForm )
		$timer = TimerInit()
	EndIf

	Local $lMe = GetAgentByID(-2)
	Local $lEnergy = GetEnergy($lMe)
	Local $lAdjCount, $lAreaCount, $lSpellcastCount, $lProximityCount
	Local $lDistance
	For $i=1 To $lAgentArray[0]
		If DllStructGetData($lAgentArray[$i], "Allegiance") <> 0x3 Then ContinueLoop
		If DllStructGetData($lAgentArray[$i], "HP") <= 0 Then ContinueLoop
		$lDistance = GetPseudoDistance($lMe, $lAgentArray[$i])
		If $lDistance < 1200*1200 Then
			$lProximityCount += 1
			If $lDistance < $Range_Spellcast_2 Then
				$lSpellcastCount += 1
				If $lDistance < $Range_Area_2 Then
					$lAreaCount += 1
					If $lDistance < $Range_Adjacent_2 Then
						$lAdjCount += 1
					EndIf
				EndIf
			EndIf
		EndIf
	Next

	UseSF($lProximityCount)

	If IsRecharged($Skill_Shroud) And TimerDiff($timer) < 15000 Then
		If $lSpellcastCount > 0 And DllStructGetData(GetEffect($Skill_ID_Shroud), "SkillID") == 0 Then
			UseSkillEx($Skill_Shroud)
		ElseIf DllStructGetData($lMe, "HP") < 0.6 Then
			UseSkillEx($Skill_Shroud)
		ElseIf $lAdjCount > 20 Then
			UseSkillEx($Skill_Shroud)
		 EndIf
	  Else
			;If IsRecharged($Skill_Shroud) Then Out("Delayed casting Shroud")
	EndIf

	UseSF($lProximityCount)

	If IsRecharged($Skill_WayOfPerfection) And TimerDiff($timer) < 15000 Then
		If DllStructGetData($lMe, "HP") < 0.5 Then
			UseSkillEx($Skill_WayOfPerfection)
		ElseIf $lAdjCount > 20 Then
			UseSkillEx($Skill_WayOfPerfection)
		 EndIf
	  Else
		;If IsRecharged($Skill_WayOfPerfection) Then Out("Delayed casting WoP")
	EndIf

	UseSF($lProximityCount)

	If IsRecharged($Skill_Channeling) And TimerDiff($timer) < 15000 Then
		If $lAreaCount > 5 And GetEffectTimeRemaining($Skill_ID_Channeling) < 2000 Then
			UseSkillEx($Skill_Channeling)
		 Else
			 ;If IsRecharged($Skill_Channeling) Then Out("Delayed casting Channeling")
		EndIf
	EndIf

	UseSF($lProximityCount)
EndFunc

;~ Description: Uses sf if there's anything close and if its recharged
Func UseSF($lProximityCount)
	If IsRecharged($Skill_ShadowForm ) And $lProximityCount > 0 Then
		UseSkillEx($Skill_Paradox)
		UseSkillEx($Skill_ShadowForm )
		$timer = TimerInit()
	EndIf
EndFunc

;~ Description: Move to destX, destY, while staying alive vs vaettirs
Func MoveAggroing($lDestX, $lDestY, $lRandom = 150)
	If GetIsDead(-2) Then Return

	Local $lMe, $lAgentArray
	Local $lBlocked
	Local $lHosCount
	Local $lAngle
	Local $stuckTimer = TimerInit()

	Move($lDestX, $lDestY, $lRandom)

	Do
		RndSleep(50)

		$lMe = GetAgentByID(-2)

		$lAgentArray = GetAgentArray(0xDB)

		If GetIsDead($lMe) Then Return False

		StayAlive($lAgentArray)

		If DllStructGetData($lMe, 'MoveX') == 0 And DllStructGetData($lMe, 'MoveY') == 0 Then
			If $lHosCount > 6 Then
				Do	; suicide
					Sleep(100)
				Until GetIsDead(-2)
				Return False
			EndIf

			$lBlocked += 1
			If $lBlocked < 5 Then
				Move($lDestX, $lDestY, $lRandom)
			ElseIf $lBlocked < 10 Then
				$lAngle += 40
				Move(DllStructGetData($lMe, 'X')+300*sin($lAngle), DllStructGetData($lMe, 'Y')+300*cos($lAngle))
			ElseIf IsRecharged($Skill_Heart_of_Shadow) Then
				If $lHosCount==0 And GetDistance() < 1000 Then
					UseSkillEx($Skill_Heart_of_Shadow, -1)
				Else
					UseSkillEx($Skill_Heart_of_Shadow, -2)
				EndIf
				$lBlocked = 0
				$lHosCount += 1
			EndIf
		Else
			If $lBlocked > 0 Then
				If TimerDiff($ChatStuckTimer) > 3000 Then	; use a timer to avoid spamming /stuck
					SendChat("stuck", "/")
					$ChatStuckTimer = TimerInit()
				EndIf
				$lBlocked = 0
				$lHosCount = 0
			EndIf

			If GetDistance() > 1100 Then ; tarGet is far, we probably got stuck.
				If TimerDiff($ChatStuckTimer) > 3000 Then ; dont spam
					SendChat("stuck", "/")
					$ChatStuckTimer = TimerInit()
					RndSleep(GetPing())
					If GetDistance() > 1100 Then ; we werent stuck, but tarGet broke aggro. select a new one.
						TarGetNearestEnemy()
					EndIf
				EndIf
			EndIf
		EndIf

	Until ComputeDistance(DllStructGetData($lMe, 'X'), DllStructGetData($lMe, 'Y'), $lDestX, $lDestY) < $lRandom*1.5
	Return True
EndFunc

;~ Description: Move to destX, destY. This is to be used in the run from across Bjora
Func MoveRunning($lDestX, $lDestY)
	If GetIsDead(-2) Then Return False

	Local $lMe, $lTgt
	Local $lBlocked

	Move($lDestX, $lDestY)

	Do
		RndSleep(500)

		TarGetNearestEnemy()
		$lMe = GetAgentByID(-2)
		$lTgt = GetAgentByID(-1)

		If GetIsDead($lMe) Then Return False

		If GetDistance($lMe, $lTgt) < 1300 And GetEnergy($lMe)>20 And IsRecharged($Skill_Paradox) And IsRecharged($Skill_ShadowForm ) Then
			UseSkillEx($Skill_Paradox)
			UseSkillEx($Skill_ShadowForm )
			$timer = TimerInit()
		EndIf

		;If DllStructGetData($lMe, "HP") < 0.9 And GetEnergy($lMe) > 10 And IsRecharged($Skill_Shroud) Then UseSkillEx($Skill_Shroud)
		If DllStructGetData($lMe, "HP") < 0.9 And GetEnergy($lMe) > 10 And IsRecharged($Skill_Shroud) And TimerDiff($timer) < 15000 Then UseSkillEx($Skill_Shroud)

		If DllStructGetData($lMe, "HP") < 0.5 And GetDistance($lMe, $lTgt) < 500 And GetEnergy($lMe) > 5 And IsRecharged($Skill_Heart_of_Shadow) Then UseSkillEx($Skill_Heart_of_Shadow, -1)

		If DllStructGetData($lMe, 'MoveX') == 0 And DllStructGetData($lMe, 'MoveY') == 0 Then
			$lBlocked += 1
			Move($lDestX, $lDestY)
		EndIf

	Until ComputeDistance(DllStructGetData($lMe, 'X'), DllStructGetData($lMe, 'Y'), $lDestX, $lDestY) < 250
	Return True
EndFunc

;~ Description: Waits until all foes are in Range (useless comment ftw)
Func WaitUntilAllFoesAreInRange($lRange)
	Local $lAgentArray
	Local $lAdjCount, $lSpellcastCount
	Local $lMe
	Local $lDistance
	Local $lShouldExit = False
	While Not $lShouldExit
		Sleep(100)
		$lMe = GetAgentByID(-2)
		If GetIsDead($lMe) Then Return
		$lAgentArray = GetAgentArray(0xDB)
		StayAlive($lAgentArray)
		$lShouldExit = False
		For $i=1 To $lAgentArray[0]
			$lDistance = GetPseudoDistance($lMe, $lAgentArray[$i])
			If $lDistance < $Range_Spellcast_2 And $lDistance > $lRange^2 Then
				$lShouldExit = True
				ExitLoop
			EndIf
		Next
	WEnd
EndFunc

;~ Description: Wait and stay alive at the same time (like Sleep(..), but without the letting yourself die part)
Func WaitFor($lMs)
	If GetIsDead(-2) Then Return
	Local $lAgentArray
	Local $lTimer = TimerInit()
	Do
		Sleep(100)
		If GetIsDead(-2) Then Return
		$lAgentArray = GetAgentArray(0xDB)
		StayAlive($lAgentArray)
	Until TimerDiff($lTimer) > $lMs
EndFunc

;~ Description: BOOOOOOOOOOOOOOOOOM
Func Kill()
	If GetIsDead(-2) Then Return

	Local $lAgentArray
	Local $lDeadlock = TimerInit()

	TarGetNearestEnemy()
	Sleep(100)
	Local $lTarGetID = GetCurrentTarGetID()

	While GetAgentExists($lTarGetID) And DllStructGetData(GetAgentByID($lTarGetID), "HP") > 0
		Sleep(50)
		If GetIsDead(-2) Then Return
		$lAgentArray = GetAgentArray(0xDB)
		StayAlive($lAgentArray)

		; Use echo if possible
		If GetSkillbarSkillRecharge($Skill_ShadowForm ) > 5000 And GetSkillbarSkillID($Skill_Arcane_Echo)==$Skill_ID_Arcane_Echo Then
			If IsRecharged($Skill_Wastrels_Demise) And IsRecharged($Skill_Arcane_Echo) Then
				UseSkillEx($Skill_Arcane_Echo)
				UseSkillEx($Skill_Wastrels_Demise, GetGoodTarGet($lAgentArray))
				$lAgentArray = GetAgentArray(0xDB)
			EndIf
		EndIf

		UseSF(True)

		; Use wastrel if possible
		If IsRecharged($Skill_Wastrels_Demise) Then
			UseSkillEx($Skill_Wastrels_Demise, GetGoodTarGet($lAgentArray))
			$lAgentArray = GetAgentArray(0xDB)
		EndIf

		UseSF(True)

		; Use echoed wastrel if possible
		If IsRecharged($Skill_Arcane_Echo) And GetSkillbarSkillID($Skill_Arcane_Echo)==$Skill_ID_Wastrels_Demise Then
			UseSkillEx($Skill_Arcane_Echo, GetGoodTarGet($lAgentArray))
		EndIf

		; Check if tarGet has ran away
		If GetDistance(-2, $lTarGetID) > $Range_Earshot Then
			TarGetNearestEnemy()
			Sleep(GetPing()+100)
			If GetAgentExists(-1) And DllStructGetData(GetAgentByID(-1), "HP") > 0 And GetDistance(-2, -1) < $Range_Area Then
				$lTarGetID = GetCurrentTarGetID()
			Else
				ExitLoop
			EndIf
		EndIf

		If TimerDiff($lDeadlock) > 60 * 1000 Then ExitLoop
	WEnd
EndFunc

; Returns a good tarGet for watrels
; Takes the agent array as returned by GetAgentArray(..)
Func GetGoodTarGet(Const ByRef $lAgentArray)
	Local $lMe = GetAgentByID(-2)
	For $i=1 To $lAgentArray[0]
		If DllStructGetData($lAgentArray[$i], "Allegiance") <> 0x3 Then ContinueLoop
		If DllStructGetData($lAgentArray[$i], "HP") <= 0 Then ContinueLoop
		If GetDistance($lMe, $lAgentArray[$i]) > $Range_Nearby Then ContinueLoop
		If GetHasHex($lAgentArray[$i]) Then ContinueLoop
		If Not GetIsEnchanted($lAgentArray[$i]) Then ContinueLoop
		Return DllStructGetData($lAgentArray[$i], "ID")
	Next
EndFunc

; Uses a skill
; It will not use if I am dead, if the skill is not recharged, or if I don't have enough energy for it
; It will sleep until the skill is cast, then it will wait for aftercast.


; Checks if skill given (by number in bar) is recharged. Returns True if recharged, otherwise False.
; Func IsRecharged($lSkill)
; 	Return GetSkillBarSkillRecharge($lSkill)==0
; EndFunc

Func GoNearestNPCToCoords($x, $y)
	Local $guy, $Me
	Do
		RndSleep(250)
		$guy = GetNearestNPCToCoords($x, $y)
	Until DllStructGetData($guy, 'Id') <> 0
	ChanGetarGet($guy)
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
EndFunc   ;==>GoNearestNPCToCoords


; Checks if should pick up the given Item. Returns True or False
; Func CanPickUp($aItem)
;    $CurGold = GetGoldCharacter()
;    GUICtrlSetData($Goldies, "Current Gold: " & $CurGold)
; 	Local $lModelID = DllStructGetData(($aItem), 'ModelID')
; 	Local $aExtraID = DllStructGetData($aItem, "ExtraID")
; 	Local $lRarity = GetRarity($aItem)
; 	Local $Requirement = GetItemReq($aItem)
; 	$CurGold = GetGoldCharacter()
; 	If (($lModelID == 2511) And (GetGoldCharacter() < 99000)) Then
; 		Return True	; Gold coins (only pick if Character has less than 99k in inventory)
; 	 ElseIf ($lModelID == 21797) Then ; Mesmer Tomes
; 		If GUICtrlRead($Tomes) = 1 Then
; 			Return True
; 	    Else
; 			Return False
; 	    EndIf
; 	ElseIf ($lModelID == $Item_ID_Dyes) Then	; if dye
; 		If (($aExtraID == $Item_ExtraID_BlackDye) Or ($aExtraID == $Item_ExtraID_WhiteDye))Then ; only pick white and black ones
; 			Return True
; 		EndIf
; 	  ElseIf($lModelID == $Item_ID_Lockpicks)Then
; 		Return True ; Lockpicks
; 	ElseIf($lModelID == $Item_ID_Glacial_Stones)Then
; 		Return True ; glacial stones
; 	ElseIf CheckArrayPscon($lModelID)Then ; ==== Pcons ==== or all event Items
; 		Return True
;     ElseIf (($lModelID == 24629) Or ($lModelID == 24630) Or ($lModelID == 24631) Or ($lModelID == 24632))Then ; Map pieces
; 		If GUICtrlRead($MapPieces) = 1 Then
; 			Return True
; 	    Else
; 			Return False
; 	    EndIf
;     ElseIf ($lRarity == $Rarity_Gold) Then ; Gold Items
; 		Return True
; 	ElseIf ($lRarity == $Rarity_Purple) Then ; purple Items
; 		Return True
; 	ElseIf ($lRarity == $Rarity_White) Then ; White Items
; 		If GUICtrlRead($White_Pickup) = 1 Then
; 			Return True
; 	    Else
; 			Return False
; 	    EndIf
;     ElseIf ($lRarity == $Rarity_Blue) Then ; Blue Items
; 		Return True
;     Else
; 		Return False
; 	EndIf
; EndFunc   ;==>CanPickUp

Func MatSwitcher()
	$RareMatsBuy = False
	Out("$RareMatsBuy" & $RareMatsBuy)
	For $i = 0 To UBound($Pic_Mats) - 1
		If (GUICtrlRead($SelectMat, "") == $Pic_Mats[$i][0]) Then
			$MatID = $Pic_Mats[$i][1]
			$RareMatsBuy = True
			Out("$RareMatsBuy" & $RareMatsBuy)
			Out("You Select - " & $Pic_Mats[$i][0])
			Out("Mat Model ID == " & "" & $MatID)
		EndIf
	Next
EndFunc   ;==>MATSWITCHER

Func CheckGold()
	Local $GCharacter = GetGoldCharacter()
	Local $GStorage = GetGoldStorage()
	Local $GDifference = ($GStorage - $GCharacter)
	If $GCharacter <= 1000 Then
		Switch $GStorage
			Case 100000 To 1000000
				WithdrawGold(100000 - $GCharacter)
				Sleep(500 + 3 * GetPing())
			Case 1 To 99999
				WithdrawGold($GDifference)
				Sleep(500 + 3 * GetPing())
			Case 0
				Out("Out of cash, beginning farm")
				Return False
		EndSwitch
	EndIf
	Return True
EndFunc   ;==>CHECKGold

#Region Inventory
#CS

#CE
Func Inventory()
	Out("Travel to Guild Hall")
	TravelGH()
	WaitMapLoading()

	Out("Checking Guild Hall")
	CheckGuildHall()

  ;bolt on from ChestBot
  StoreItemsEx()
  Sleep(GetPing()+500)
  
	If GetGoldCharacter() > 90000 Then
		Out("Depositing Gold")
		DepositGold()
	EndIf

	Sleep(GetPing()+1000)
	LeaveGH()
	WaitMapLoading()
EndFunc

Func Ident($BagIndex)
	Local $Bag
	Local $I
	Local $aItem
	$Bag = GetBAG($BagIndex)
	For $I = 1 To DllStructGetData($Bag, "slots")
		If FindIDKit() = 0 Then
			If GetGoldCharacter() < 500 And GetGoldStorage() > 499 Then
				WithdrawGold(500)
				Sleep(GetPing()+500)
			EndIf
			Local $J = 0
			Do
				BuyItem(6, 1, 500)
				Sleep(GetPing()+500)
				$J = $J + 1
			Until FindIDKit() <> 0 Or $J = 3
			If $J = 3 Then ExitLoop
			Sleep(GetPing()+500)
		EndIf
		$aItem = GetItemBySlot($BagIndex, $I)
		If DllStructGetData($aItem, "ID") = 0 Then ContinueLoop
		IdentifyItem($aItem)
		Sleep(GetPing()+500)
	Next
EndFunc

Func Sell($BagIndex)
	Local $aItem
	Local $Bag = GetBAG($BagIndex)
	Local $SlotCount = DllStructGetData($Bag, "slots")
	For $I = 1 To $SlotCount
		Out("Selling Item: " & $BagIndex & ", " & $I)
		$aItem = GetItemBySlot($BagIndex, $I)
		If DllStructGetData($aItem, "ID") = 0 Then ContinueLoop
		If CanSell($aItem) Then
			SellItem($aItem)
		EndIf
		Sleep(GetPing()+250)
	Next
EndFunc

Func CanSell($aItem)

	Local $LMODELID = DllStructGetData($aItem, "ModelID")

	Local $LRarity = GetRarity($aItem)
	; Local $Requirement = GetItemReq($aItem)

    Local $IsCaster = IsPerfectCaster($aItem)
    Local $IsStaff  = IsPerfectStaff($aItem)
    Local $IsShield = IsPerfectShield($aItem)
    Local $IsRune   = IsRareRune($aItem)
    Local $Type     = DllStructGetData($aItem, "Type")


    Local $NiceMod  = IsNiceMod($aItem)

    If $lModelID == $Item_ID_Glacial_Stones Then Return False

    Switch $IsRune
    Case True
        Return False
    EndSwitch


	If $LMODELID == $Item_ID_Dyes Then
		Switch DllStructGetData($aItem, "ExtraID")
			Case $Item_ExtraID_BlackDye, $Item_ExtraID_WhiteDye
				Return False
			Case Else
				Return True
		EndSwitch
	EndIf

  If CheckArrayAllDrops($lModelID) Then Return False ;Bolt on from chest bot
	If CheckArrayTomes($lModelID) Then Return False
	If CheckArrayMaterials($lModelID) Then Return False
	; All weapon mods
	If CheckArrayWeaponMods($lModelID) Then Return False
	; ==== General ====
	If CheckArrayGeneralItems($lModelID) Then Return False ; Lockpicks, Kits
	If $lModelID == $Item_ID_Glacial_Stones Then Return True
	If CheckArrayPscon($lModelID) Then Return False
	; ==== Stupid Drops =
	;If CheckArrayMapPieces($lModelID)				Then Return False
    If $LRarity == $Rarity_Gold Then
		Return True
	EndIf
	If $LRarity == $Rarity_Purple Then
		Return True
	EndIf
;~ Leaving Blues and Whites as false for now. Going to make it salvage them at some point in the future. It does not currently pick up whites or blues
	If $LRarity == $Rarity_Blue Then
		Return True
	EndIf
	If $LRarity == $Rarity_White Then
		Return True
	EndIf
	Return True
EndFunc   ;==>CanSell

#Region Arrays

Func CheckArrayAllDrops($m)
	For $p = 0 To (UBound($Array_Store_ModelIDs460) -1)
		If ($m == $Array_Store_ModelIDs460[$p]) Then Return True
	Next
	Return False
EndFunc

Func CheckArrayPscon($lModelID)
	For $p = 0 To (UBound($Array_pscon) -1)
		If ($lModelID == $Array_pscon[$p]) Then Return True
	Next
EndFunc

Func CheckArrayGeneralItems($lModelID)
	For $p = 0 To (UBound($General_Items_Array) -1)
		If ($lModelID == $General_Items_Array[$p]) Then Return True
	Next
EndFunc

Func CheckArrayWeaponMods($lModelID)
	For $p = 0 To (UBound($Weapon_Mod_Array) -1)
		If ($lModelID == $Weapon_Mod_Array[$p]) Then Return True
	Next
EndFunc

Func CheckArrayTomes($lModelID)
	For $p = 0 To (UBound($All_Tomes_Array) -1)
		If ($lModelID == $All_Tomes_Array[$p]) Then Return True
	Next
EndFunc

Func CheckArrayMaterials($lModelID)
	For $p = 0 To (UBound($All_Materials_Array) -1)
		If ($lModelID == $All_Materials_Array[$p]) Then Return True
	Next
EndFunc

#EndRegion Arrays

#Region Checking Guild Hall
;~ Checks to see which Guild Hall you are in and the spawn point
Func CheckGuildHall()
	If GetMapID() == $GH_ID_Warriors_Isle Then
		$WarriorsIsle = True
		Out("Warrior's Isle")
	EndIf
	If GetMapID() == $GH_ID_Hunters_Isle Then
		$HuntersIsle = True
		Out("Hunter's Isle")
	EndIf
	If GetMapID() == $GH_ID_Wizards_Isle Then
		$WizardsIsle = True
		Out("Wizard's Isle")
	EndIf
	If GetMapID() == $GH_ID_Burning_Isle Then
		$BurningIsle = True
		Out("Burning Isle")
	EndIf
	If GetMapID() == $GH_ID_Frozen_Isle Then
		$FrozenIsle = True
		Out("Frozen Isle")
	EndIf
	If GetMapID() == $GH_ID_Nomads_Isle Then
		$NomadsIsle = True
		Out("Nomad's Isle")
	EndIf
	If GetMapID() == $GH_ID_Druids_Isle Then
		$DruidsIsle = True
		Out("Druid's Isle")
	EndIf
	If GetMapID() == $GH_ID_Isle_Of_The_Dead Then
		$IsleOfTheDead = True
		Out("Isle of the Dead")
	EndIf
	If GetMapID() == $GH_ID_Isle_Of_Weeping_Stone Then
		$IsleOfWeepingStone = True
		Out("Isle of Weeping Stone")
	EndIf
	If GetMapID() == $GH_ID_Isle_Of_Jade Then
		$IsleOfJade = True
		Out("Isle of Jade")
	EndIf
	If GetMapID() == $GH_ID_Imperial_Isle Then
		$ImperialIsle = True
		Out("Imperial Isle")
	EndIf
	If GetMapID() == $GH_ID_Isle_Of_Meditation Then
		$IsleOfMeditation = True
		Out("Isle of Meditation")
	EndIf
	If GetMapID() == $GH_ID_Uncharted_Isle Then
		$UnchartedIsle = True
		Out("Uncharted Isle")
	EndIf
	If GetMapID() == $GH_ID_Isle_Of_Wurms Then
		$IsleOfWurms = True
		Out("Isle of Wurms")
		If $IsleOfWurms = True Then
			CheckIsleOfWurms()
		EndIf
	EndIf
	If GetMapID() == $GH_ID_Corrupted_Isle Then
		$CorruptedIsle = True
		Out("Corrupted Isle")
		If $CorruptedIsle = True Then
			CheckCorruptedIsle()
		EndIf
	EndIf
	If GetMapID() == $GH_ID_Isle_Of_Solitude Then
		$IsleOfSolitude = True
		Out("Isle of Solitude")
	EndIf
EndFunc ;~ Check Guild halls

;~ If there is a missing Guild Hall from the below listing, it is because there is only 1 spawn point in that Guild Hall
Func CheckIsleOfWurms()
	If CheckArea(8682, 2265) Then
		OUT("Start Point 1")
		If Waypoint1() Then
			Return True
		Else
			Return False
		EndIf
	ElseIf CheckArea(6697, 3631) Then
		OUT("Start Point 2")
		If Waypoint2() Then
			Return True
		Else
			Return False
		EndIf
	ElseIf CheckArea(6716, 2929) Then
		OUT("Start Point 3")
		If Waypoint3() Then
			Return True
		Else
			Return False
		EndIf
	Else
		OUT("Where the fuck am I?")
		Return False
	EndIf
EndFunc

Func CheckCorruptedIsle()
	If CheckArea(-4830, 5985) Then
		OUT("Start Point 1")
		If Waypoint4() Then
			Return True
		Else
			Return False
		EndIf
	ElseIf CheckArea(-3778, 6214) Then
		OUT("Start Point 2")
		If Waypoint5() Then
			Return True
		Else
			Return False
		EndIf
	ElseIf CheckArea(-5209, 4468) Then
		OUT("Start Point 3")
		If Waypoint6() Then
			Return True
		Else
			Return False
		EndIf
	Else
		OUT("Where the fuck am I?")
		Return False
	EndIf
EndFunc

Func Waypoint1()
	MoveTo(8263, 2971)
EndFunc

Func Waypoint2()
	MoveTo(7086, 2983)
	MoveTo(8263, 2971)
EndFunc

Func Waypoint3()
	MoveTo(8263, 2971)
EndFunc

Func Waypoint4()
	MoveTo(-4830, 5985)
EndFunc

Func Waypoint5()
	MoveTo(-3778, 6214)
EndFunc

Func Waypoint6()
	MoveTo(-4352, 5232)
EndFunc

Func Chest()
	Dim $Waypoints_by_XunlaiChest[16][3] = [ _
			[$BurningIsle, -5285, -2545], _
			[$DruidsIsle, -1792, 5444], _
			[$FrozenIsle, -115, 3775], _
			[$HuntersIsle, 4855, 7527], _
			[$IsleOfTheDead, -4562, -1525], _
			[$NomadsIsle, 4630, 4580], _
			[$WarriorsIsle, 4224, 7006], _
			[$WizardsIsle, 4858, 9446], _
			[$ImperialIsle, 2184, 13125], _
			[$IsleOfJade, 8614, 2660], _
			[$IsleOfMeditation, -726, 7630], _
			[$IsleOfWeepingStone, -1573, 7303], _
			[$CorruptedIsle, -4868, 5998], _
			[$IsleOfSolitude, 4478, 3055], _
			[$IsleOfWurms, 8586, 3603], _
			[$UnchartedIsle, 4522, -4451]]
	For $i = 0 To (UBound($Waypoints_by_XunlaiChest) - 1)
		If ($Waypoints_by_XunlaiChest[$i][0] == True) Then
			Do
				GenericRandomPath($Waypoints_by_XunlaiChest[$i][1], $Waypoints_by_XunlaiChest[$i][2], Random(60, 80, 2))
			Until CheckArea($Waypoints_by_XunlaiChest[$i][1], $Waypoints_by_XunlaiChest[$i][2])
		EndIf
	Next
	Local $aChestName = "Xunlai Chest"
	Local $lChest = GetAgentByName($aChestName)
	If IsDllStruct($lChest)Then
		Out("Going to " & $aChestName)
		GoToNPC($lChest)
		RndSleep(Random(3000, 4200))
	EndIf
EndFunc ;~ Xunlai Chest

Func Merchant()
	Dim $Waypoints_by_Merchant[29][3] = [ _
			[$BurningIsle, -4439, -2088], _
			[$BurningIsle, -4772, -362], _
			[$BurningIsle, -3637, 1088], _
			[$BurningIsle, -2506, 988], _
			[$DruidsIsle, -2037, 2964], _
			[$FrozenIsle, 99, 2660], _
			[$FrozenIsle, 71, 834], _
			[$FrozenIsle, -299, 79], _
			[$HuntersIsle, 5156, 7789], _
			[$HuntersIsle, 4416, 5656], _
			[$IsleOfTheDead, -4066, -1203], _
			[$NomadsIsle, 5129, 4748], _
			[$WarriorsIsle, 4159, 8540], _
			[$WarriorsIsle, 5575, 9054], _
			[$WizardsIsle, 4288, 8263], _
			[$WizardsIsle, 3583, 9040], _
			[$ImperialIsle, 1415, 12448], _
			[$ImperialIsle, 1746, 11516], _
			[$IsleOfJade, 8825, 3384], _
			[$IsleOfJade, 10142, 3116], _
			[$IsleOfMeditation, -331, 8084], _
			[$IsleOfMeditation, -1745, 8681], _
			[$IsleOfMeditation, -2197, 8076], _
			[$IsleOfWeepingStone, -3095, 8535], _
			[$IsleOfWeepingStone, -3988, 7588], _
			[$CorruptedIsle, -4670, 5630], _
			[$IsleOfSolitude, 2970, 1532], _
			[$IsleOfWurms, 8284, 3578], _
			[$UnchartedIsle, 1503, -2830]]
	For $i = 0 To (UBound($Waypoints_by_Merchant) - 1)
		If ($Waypoints_by_Merchant[$i][0] == True) Then
			Do
				GenericRandomPath($Waypoints_by_Merchant[$i][1], $Waypoints_by_Merchant[$i][2], Random(60, 80, 2))
			Until CheckArea($Waypoints_by_Merchant[$i][1], $Waypoints_by_Merchant[$i][2])
		EndIf
	Next

	Out("Going to Merchant")

	Do
        RndSleep(Random(250,500))
		Local $Me = GetAgentByID(-2)
        Local $guy = GetNearestNPCToCoords(DllStructGetData($Me, 'X'), DllStructGetData($Me, 'Y'))
    Until DllStructGetData($guy, 'Id') <> 0
    ChanGetarGet($guy)
    RndSleep(Random(250,500))
    GoNPC($guy)
    RndSleep(Random(250,500))
    Do
        MoveTo(DllStructGetData($guy, 'X'), DllStructGetData($guy, 'Y'), 40)
        RndSleep(Random(500,750))
        GoNPC($guy)
        RndSleep(Random(250,500))
        Local $Me = GetAgentByID(-2)
    Until ComputeDistance(DllStructGetData($Me, 'X'), DllStructGetData($Me, 'Y'), DllStructGetData($guy, 'X'), DllStructGetData($guy, 'Y')) < 250
    RndSleep(Random(1000,1500))

EndFunc ;~ Merchant

Func RareMaterialTrader()
	Dim $Waypoints_by_RareMatTrader[36][3] = [ _
			[$BurningIsle, -3793, 1069], _
			[$BurningIsle, -2798, -74], _
			[$DruidsIsle, -989, 4493], _
			[$FrozenIsle, 71, 834], _
			[$FrozenIsle, 99, 2660], _
			[$FrozenIsle, -385, 3254], _
			[$FrozenIsle, -983, 3195], _
			[$HuntersIsle, 3267, 6557], _
			[$IsleOfTheDead, -3415, -1658], _
			[$NomadsIsle, 1930, 4129], _
			[$NomadsIsle, 462, 4094], _
			[$WarriorsIsle, 4108, 8404], _
			[$WarriorsIsle, 3403, 6583], _
			[$WarriorsIsle, 3415, 5617], _
			[$WizardsIsle, 3610, 9619], _
			[$ImperialIsle, 759, 11465], _
			[$IsleOfJade, 8919, 3459], _
			[$IsleOfJade, 6789, 2781], _
			[$IsleOfJade, 6566, 2248], _
			[$IsleOfMeditation, -2197, 8076], _
			[$IsleOfMeditation, -1745, 8681], _
			[$IsleOfMeditation, -331, 8084], _
			[$IsleOfMeditation, 422, 8769], _
			[$IsleOfMeditation, 549, 9531], _
			[$IsleOfWeepingStone, -3988, 7588], _
			[$IsleOfWeepingStone, -3095, 8535], _
			[$IsleOfWeepingStone, -2431, 7946], _
			[$IsleOfWeepingStone, -1618, 8797], _
			[$CorruptedIsle, -4424, 5645], _
			[$CorruptedIsle, -4443, 4679], _
			[$IsleOfSolitude, 3172, 3728], _
			[$IsleOfSolitude, 3221, 4789], _
			[$IsleOfSolitude, 3745, 4542], _
			[$IsleOfWurms, 8353, 2995], _
			[$IsleOfWurms, 6708, 3093], _
			[$UnchartedIsle, 2530, -2403]]
	For $i = 0 To (UBound($Waypoints_by_RareMatTrader) - 1)
		If ($Waypoints_by_RareMatTrader[$i][0] == True) Then
			Do
				GenericRandomPath($Waypoints_by_RareMatTrader[$i][1], $Waypoints_by_RareMatTrader[$i][2], Random(60, 80, 2))
			Until CheckArea($Waypoints_by_RareMatTrader[$i][1], $Waypoints_by_RareMatTrader[$i][2])
		EndIf
	Next
	Local $lRareTrader = "Rare Material Trader"
	Local $lRare = GetAgentByName($lRareTrader)
	If IsDllStruct($lRare)Then
		Out("Going to " & $lRareTrader)
		GoToNPC($lRare)
		RndSleep(Random(3000, 4200))
	EndIf
	;~This section does the buying
	TraderRequest($MatID)
	Sleep(500 + 3 * GetPing())
	While GetGoldCharacter() > 20*1000
		TraderRequest($MatID)
		Sleep(500 + 3 * GetPing())
		TraderBuy()
	WEnd
EndFunc   ;~ Rare Material trader
#EndRegion Checking Guild Hall

#CS
	If GetHoneyCombCount() > 49 Then

#CE

#Region Display/Counting Things
#CS
Each section can be commented out entirely or each individual line. Basically put here for reference and use.

I put the Display > 0 so that it won't list everything. Better for each event I think.

CountSlots and CountSlotsChest are used by the Storage and the bot to know how much it can put in there
and when to start an inventory cycle.

GetxxxxxxCount() are to count what is in your Inventory at that time. Say if you want to track each of these Items
either by the Message display or a section of your GUI.

Does Not track how many you put in the Storage chest!!!
#CE
Func DisplayCounts()
;	Standard Vaettir Drops excluding Map Pieces
	Local $CurrentGold = GetGoldCharacter()
	Local $GlacialStones = GetGlacialStoneCount()
	Local $MesmerTomes = GetMesmerTomeCount()
	Local $Lockpicks = GetLockpickCount()
	Local $BlackDye = GetBlackDyeCount()
	Local $WhiteDye = GetWhiteDyeCount()
;	Event Items
	Local $AgedDwarvenAle = GetAgedDwarvenAleCount()
	Local $AgedHuntersAle = GetAgedHuntersAleCount()
	Local $BattleIslandIcedTea = GetIcedTeaCount()
	Local $BirthdayCupcake = GetBirthdayCupcakeCount()
	Local $CandyCaneSHards = GetCandyCaneSHards()
	Local $GoldenEgg = GetGoldenEggCount()
	Local $Grog = GetBottleOfGrogCount()
	Local $HoneyCombs = GetHoneyCombCount()
	Local $KrytanBrandy = GetKrytanBrandyCount()
	Local $PartyBeacon = GetPartyBeaconCount()
	Local $PumpkinPies = GetPumpkinPieCount()
	Local $SpikedEggnog = GetSpikedEggnogCount()
	Local $TrickOrTreats = GetTrickOrTreatCount()
	Local $VictoryToken = GetVictoryTokenCount()
	Local $WayfarerMark = GetWayfarerMarkCount()
;	RareMaterials
	Local $EctoCount = GetEctoCount()
	Local $ObSHardCount = GetObsidianSHardCount()
	Local $FurCount = GetFurCount()
	Local $LinenCount = GetLinenCount()
	Local $DamaskCount = GetDamaskCount()
	Local $SilkCount = GetSilkCount()
	Local $SteelCount = GetSteelCount()
	Local $DSteelCount = GetDeldSteelCount()
	Local $MonClawCount = GetMonClawCount()
	Local $MonEyeCount = GetMonEyeCount()
	Local $MonFangCount = GetMonFangCount()
	Local $RubyCount = GetRubyCount()
	Local $SapphireCount = GetSapphireCount()
	Local $DiamondCount = GetDiamondCount()
	Local $OnyxCount = GetOnyxCount()
	Local $CharcoalCount = GetCharcoalCount()
	Local $GlassVialCount = GetGlassVialCount()
	Local $LeatherCount = GetLeatherCount()
	Local $ElonLeatherCount = GetElonLeatherCount()
	Local $VialInkCount = GetVialInkCount()
	Local $ParchmentCount = GetParchmentCount()
	Local $VellumCount = GetVellumCount()
	Local $SpiritwoodCount = GetSpiritwoodCount()
	Local $AmberCount = GetAmberCount()
	Local $JadeCount = GetJadeCount()
;	Standard Vaettir Drops excluding Map Pieces
	If GetGoldCharacter() > 0 Then
		Out("Current Gold:" & $CurrentGold)
	ElseIf GetGlacialStoneCount() > 0 Then
		Out("Glacial stone count:" & $GlacialStones)
	ElseIf GetMesmerTomeCount() > 0 Then
		Out("Mesmer Tomes:" & $MesmerTomes)
	ElseIf GetLockpickCount() > 0 Then
		Out ("Lockpicks:" & $Lockpicks)
	ElseIf GetBlackDyeCount() > 0 Then
		Out ("Black Dyes:" & $BlackDye)
	ElseIf GetWhiteDyeCount() > 0 Then
		Out ("White Dyes:" & $WhiteDye)
	EndIf
;	Rare Materials
	If GetFurCount() > 0 Then
		Out ("Fur Squares:" & $FurCount)
	ElseIf GetLinenCount() > 0 Then
		Out ("Linen:" & $LinenCount)
	ElseIf GetDamaskCount() > 0 Then
		Out ("Damask:" & $DamaskCount)
	ElseIf GetSilkCount() > 0 Then
		Out ("Silk:" & $SilkCount)
	ElseIf GetEctoCount() > 0 Then
		Out("Ecto Count:" & $EctoCount)
	ElseIf GetSteelCount() > 0 Then
		Out ("Steel:" & $SteelCount)
	ElseIf GetDeldSteelCount() > 0 Then
		Out ("Deldrimor Steel:" & $DSteelCount)
	ElseIf GetMonClawCount() > 0 Then
		Out ("Monstrous Claw:" & $MonClawCount)
	ElseIf GetMonEyeCount() > 0 Then
		Out ("Monstrous Eye:" & $MonEyeCount)
	ElseIf GetMonFangCount() > 0 Then
		Out ("Monstrous Fang:" & $MonFangCount)
	ElseIf GetRubyCount() > 0 Then
		Out ("Ruby:" & $RubyCount)
	ElseIf GetSapphireCount() > 0 Then
		Out ("Sapphire:" & $SapphireCount)
	ElseIf GetDiamondCount() > 0 Then
		Out ("Diamond:" & $DiamondCount)
	ElseIf GetOnyxCount() > 0 Then
		Out ("Onyx:" & $OnyxCount)
	ElseIf GetCharcoalCount() > 0 Then
		Out ("Charcoal:" & $CharcoalCount)
	ElseIf GetObsidianSHardCount() > 0 Then
		Out("Obby Count:" & $ObSHardCount)
	ElseIf GetGlassVialCount() > 0 Then
		Out ("Glass Vial:" & $GlassVialCount)
	ElseIf GetLeatherCount() > 0 Then
		Out ("Leather Square:" & $LeatherCount)
	ElseIf GetElonLeatherCount() > 0 Then
		Out ("Elonian Leather:" & $ElonLeatherCount)
	ElseIf GetVialInkCount() > 0 Then
		Out ("Vials of Ink:" & $VialInkCount)
	ElseIf GetParchmentCount() > 0 Then
		Out ("Parchment:" & $ParchmentCount)
	ElseIf GetVellumCount() > 0 Then
		Out ("Vellum:" & $VellumCount)
	ElseIf GetSpiritwoodCount() > 0 Then
		Out ("Spiritwood Planks:" & $SpiritwoodCount)
	ElseIf GetAmberCount() > 0 Then
		Out ("Amber:" & $AmberCount)
	ElseIf GetSpiritwoodCount() > 0 Then
		Out ("Jade:" & $JadeCount)
	EndIf
;	Event Items
	If GetAgedDwarvenAleCount() > 0 Then
		Out("Aged Dwarven Ale:" & $AgedDwarvenAle)
	ElseIf GetAgedHuntersAleCount() > 0 Then
		Out("Aged Hunter's Ale:" & $AgedHuntersAle)
	ElseIf GetIcedTeaCount() > 0 Then
		Out("Iced Tea:" & $BattleIslandIcedTea)
	ElseIf GetBirthdayCupcakeCount() > 0 Then
		Out("Cupcakes:" & $BirthdayCupcake)
	ElseIf GetCandyCaneSHards() > 0 Then
		Out("CC SHards:" & $CandyCaneSHards)
	ElseIf GetGoldenEggCount() > 0 Then
		Out("Golden Eggs:" & $GoldenEgg)
	ElseIf GetBottleOfGrogCount() > 0 Then
		Out("Grog Arrr:" & $Grog)
	ElseIf GetHoneyCombCount() > 0 Then
		Out("Honeycombs:" & $HoneyCombs)
	ElseIf GetKrytanBrandyCount() > 0 Then
		Out("Krytan Brandy:" & $KrytanBrandy)
	ElseIf GetPartyBeaconCount() > 0 Then
		Out("Jesus Beams:" & $PartyBeacon)
	ElseIf GetPumpkinPieCount() > 0 Then
		Out("Pumpkin Pies:" & $PumpkinPies)
	ElseIf GetSpikedEggnogCount() > 0 Then
		Out("Spiked Eggnog:" & $SpikedEggnog)
	ElseIf GetTrickOrTreatCount() > 0 Then
		Out("ToTs:" & $TrickOrTreats)
	ElseIf GetVictoryTokenCount() > 0 Then
		Out("Victory Tokens:" & $VictoryToken)
	ElseIf GetWayfarerMarkCount() > 0 Then
		Out("Wayfarer Marks:" & $WayfarerMark)
	ElseIf GetYuletideTonicCount() > 0 Then
		Out("Yuletide Tonics:" & $YuletideTonic)
	EndIf
EndFunc

;	Standard Vaettir Drops excluding Map Pieces
Func GetGlacialStoneCount()
	Local $aAMountGlacialStone
	Local $aBag
	Local $aItem
	Local $i
	For $i = 1 To 4
		$aBag = GetBag($i)
		For $j = 1 To DllStructGetData($aBag, "Slots")
			$aItem = GetItemBySlot($aBag, $j)
			If DllStructGetData($aItem, "ModelID") == 27047 Then
				$aAMountGlacialStone += DllStructGetData($aItem, "Quantity")
			Else
				ContinueLoop
			EndIf
		Next
	Next
	Return $aAMountGlacialStone
EndFunc   ; Counts Glacial Stones in your Inventory

Func GetMesmerTomeCount()
	Local $aAMountMesmerTomes
	Local $aBag
	Local $aItem
	Local $i
	For $i = 1 To 4
		$aBag = GetBag($i)
		For $j = 1 To DllStructGetData($aBag, "Slots")
			$aItem = GetItemBySlot($aBag, $j)
			If DllStructGetData($aItem, "ModelID") == 21797 Then
				$aAMountMesmerTomes += DllStructGetData($aItem, "Quantity")
			Else
				ContinueLoop
			EndIf
		Next
	Next
	Return $aAMountMesmerTomes
EndFunc   ; Counts Mesmer Tomes in your Inventory

Func GetLockpickCount()
	Local $aAMountLockPick
	Local $aBag
	Local $aItem
	Local $i
	For $i = 1 To 4
		$aBag = GetBag($i)
		For $j = 1 To DllStructGetData($aBag, "Slots")
			$aItem = GetItemBySlot($aBag, $j)
			If DllStructGetData($aItem, "ModelID") == 22751 Then
				$aAMountLockPick += DllStructGetData($aItem, "Quantity")
			Else
				ContinueLoop
			EndIf
		Next
	Next
	Return $aAMountLockPick
EndFunc   ; Counts Lockpicks in your Inventory

Func GetBlackDyeCount()
	Local $aAMountBlackDyes
	Local $aBag
	Local $aItem
	Local $i
	For $i = 1 To 4
		$aBag = GetBag($i)
		For $j = 1 To DllStructGetData($aBag, "Slots")
			$aItem = GetItemBySlot($aBag, $j)
			If DllStructGetData($aItem, "ModelID") == 146 Then
				If DllStructGetData($aItem, "ExtraID") == 10 Then
					$aAMountBlackDyes += DllStructGetData($aItem, "Quantity")
				EndIf
			Else
				ContinueLoop
			EndIf
		Next
	Next
	Return $aAMountBlackDyes
EndFunc   ; Counts Black Dyes in your Inventory

Func GetWhiteDyeCount()
	Local $aAMountWhiteDyes
	Local $aBag
	Local $aItem
	Local $i
	For $i = 1 To 4
		$aBag = GetBag($i)
		For $j = 1 To DllStructGetData($aBag, "Slots")
			$aItem = GetItemBySlot($aBag, $j)
			If DllStructGetData($aItem, "ModelID") == 146 Then
				If DllStructGetData($aItem, "ExtraID") == 12 Then
					$aAMountWhiteDyes += DllStructGetData($aItem, "Quantity")
				EndIf
			Else
				ContinueLoop
			EndIf
		Next
	Next
	Return $aAMountWhiteDyes
EndFunc   ; Counts White Dyes in your Inventory

;	Rare Materials
Func GetFurCount()
	Local $aAMountFurSquares
	Local $aBag
	Local $aItem
	Local $i
	For $i = 1 To 4
		$aBag = GetBag($i)
		For $j = 1 To DllStructGetData($aBag, "Slots")
			$aItem = GetItemBySlot($aBag, $j)
			If DllStructGetData($aItem, "ModelID") == 941 Then
				$aAMountFurSquares += DllStructGetData($aItem, "Quantity")
			Else
				ContinueLoop
			EndIf
		Next
	Next
	Return $aAMountFurSquares
EndFunc   ; Counts Fur Squares in your Inventory

Func GetLinenCount()
	Local $aAMountLinen
	Local $aBag
	Local $aItem
	Local $i
	For $i = 1 To 4
		$aBag = GetBag($i)
		For $j = 1 To DllStructGetData($aBag, "Slots")
			$aItem = GetItemBySlot($aBag, $j)
			If DllStructGetData($aItem, "ModelID") == 926 Then
				$aAMountLinen += DllStructGetData($aItem, "Quantity")
			Else
				ContinueLoop
			EndIf
		Next
	Next
	Return $aAMountLinen
EndFunc   ; Counts Linen in your Inventory

Func GetDamaskCount()
	Local $aAMountDamask
	Local $aBag
	Local $aItem
	Local $i
	For $i = 1 To 4
		$aBag = GetBag($i)
		For $j = 1 To DllStructGetData($aBag, "Slots")
			$aItem = GetItemBySlot($aBag, $j)
			If DllStructGetData($aItem, "ModelID") == 927 Then
				$aAMountDamask += DllStructGetData($aItem, "Quantity")
			Else
				ContinueLoop
			EndIf
		Next
	Next
	Return $aAMountDamask
EndFunc   ; Counts Damask in your Inventory

Func GetSilkCount()
	Local $aAMountSilk
	Local $aBag
	Local $aItem
	Local $i
	For $i = 1 To 4
		$aBag = GetBag($i)
		For $j = 1 To DllStructGetData($aBag, "Slots")
			$aItem = GetItemBySlot($aBag, $j)
			If DllStructGetData($aItem, "ModelID") == 928 Then
				$aAMountSilk += DllStructGetData($aItem, "Quantity")
			Else
				ContinueLoop
			EndIf
		Next
	Next
	Return $aAMountSilk
EndFunc   ; Counts Silk in your Inventory

Func GetEctoCount()
	Local $aAMountEctos
	Local $aBag
	Local $aItem
	Local $i
	For $i = 1 To 4
		$aBag = GetBag($i)
		For $j = 1 To DllStructGetData($aBag, "Slots")
			$aItem = GetItemBySlot($aBag, $j)
			If DllStructGetData($aItem, "ModelID") == 930 Then
				$aAMountEctos += DllStructGetData($aItem, "Quantity")
			Else
				ContinueLoop
			EndIf
		Next
	Next
	Return $aAMountEctos
EndFunc   ; Counts Ectos in your Inventory

Func GetSteelCount()
	Local $aAMountSteel
	Local $aBag
	Local $aItem
	Local $i
	For $i = 1 To 4
		$aBag = GetBag($i)
		For $j = 1 To DllStructGetData($aBag, "Slots")
			$aItem = GetItemBySlot($aBag, $j)
			If DllStructGetData($aItem, "ModelID") == 949 Then
				$aAMountSteel += DllStructGetData($aItem, "Quantity")
			Else
				ContinueLoop
			EndIf
		Next
	Next
	Return $aAMountSteel
EndFunc   ; Counts Steel in your Inventory

Func GetDeldSteelCount()
	Local $aAMountDelSteel
	Local $aBag
	Local $aItem
	Local $i
	For $i = 1 To 4
		$aBag = GetBag($i)
		For $j = 1 To DllStructGetData($aBag, "Slots")
			$aItem = GetItemBySlot($aBag, $j)
			If DllStructGetData($aItem, "ModelID") == 950 Then
				$aAMountDelSteel += DllStructGetData($aItem, "Quantity")
			Else
				ContinueLoop
			EndIf
		Next
	Next
	Return $aAMountDelSteel
EndFunc   ; Counts Deldrimor Steel in your Inventory

Func GetMonClawCount()
	Local $aAMountMonClaw
	Local $aBag
	Local $aItem
	Local $i
	For $i = 1 To 4
		$aBag = GetBag($i)
		For $j = 1 To DllStructGetData($aBag, "Slots")
			$aItem = GetItemBySlot($aBag, $j)
			If DllStructGetData($aItem, "ModelID") == 923 Then
				$aAMountMonClaw += DllStructGetData($aItem, "Quantity")
			Else
				ContinueLoop
			EndIf
		Next
	Next
	Return $aAMountMonClaw
EndFunc   ; Counts Monstrous Claws in your Inventory

Func GetMonEyeCount()
	Local $aAMountMonEyes
	Local $aBag
	Local $aItem
	Local $i
	For $i = 1 To 4
		$aBag = GetBag($i)
		For $j = 1 To DllStructGetData($aBag, "Slots")
			$aItem = GetItemBySlot($aBag, $j)
			If DllStructGetData($aItem, "ModelID") == 931 Then
				$aAMountMonEyes += DllStructGetData($aItem, "Quantity")
			Else
				ContinueLoop
			EndIf
		Next
	Next
	Return $aAMountMonEyes
EndFunc   ; Counts Montrous Eyes in your Inventory

Func GetMonFangCount()
	Local $aAMountMonFangs
	Local $aBag
	Local $aItem
	Local $i
	For $i = 1 To 4
		$aBag = GetBag($i)
		For $j = 1 To DllStructGetData($aBag, "Slots")
			$aItem = GetItemBySlot($aBag, $j)
			If DllStructGetData($aItem, "ModelID") == 932 Then
				$aAMountMonFangs += DllStructGetData($aItem, "Quantity")
			Else
				ContinueLoop
			EndIf
		Next
	Next
	Return $aAMountMonFangs
EndFunc   ; Counts Montrous Fangs in your Inventory

Func GetRubyCount()
	Local $aAMountRubies
	Local $aBag
	Local $aItem
	Local $i
	For $i = 1 To 4
		$aBag = GetBag($i)
		For $j = 1 To DllStructGetData($aBag, "Slots")
			$aItem = GetItemBySlot($aBag, $j)
			If DllStructGetData($aItem, "ModelID") == 937 Then
				$aAMountRubies += DllStructGetData($aItem, "Quantity")
			Else
				ContinueLoop
			EndIf
		Next
	Next
	Return $aAMountRubies
EndFunc   ; Counts Rubies in your Inventory

Func GetSapphireCount()
	Local $aAMountSapphires
	Local $aBag
	Local $aItem
	Local $i
	For $i = 1 To 4
		$aBag = GetBag($i)
		For $j = 1 To DllStructGetData($aBag, "Slots")
			$aItem = GetItemBySlot($aBag, $j)
			If DllStructGetData($aItem, "ModelID") == 938 Then
				$aAMountSapphires += DllStructGetData($aItem, "Quantity")
			Else
				ContinueLoop
			EndIf
		Next
	Next
	Return $aAMountSapphires
EndFunc   ; Counts Sapphires in your Inventory

Func GetDiamondCount()
	Local $aAMountDiamonds
	Local $aBag
	Local $aItem
	Local $i
	For $i = 1 To 4
		$aBag = GetBag($i)
		For $j = 1 To DllStructGetData($aBag, "Slots")
			$aItem = GetItemBySlot($aBag, $j)
			If DllStructGetData($aItem, "ModelID") == 935 Then
				$aAMountDiamonds += DllStructGetData($aItem, "Quantity")
			Else
				ContinueLoop
			EndIf
		Next
	Next
	Return $aAMountDiamonds
EndFunc   ; Counts Diamonds in your Inventory

Func GetOnyxCount()
	Local $aAMountOnyx
	Local $aBag
	Local $aItem
	Local $i
	For $i = 1 To 4
		$aBag = GetBag($i)
		For $j = 1 To DllStructGetData($aBag, "Slots")
			$aItem = GetItemBySlot($aBag, $j)
			If DllStructGetData($aItem, "ModelID") == 936 Then
				$aAMountOnyx += DllStructGetData($aItem, "Quantity")
			Else
				ContinueLoop
			EndIf
		Next
	Next
	Return $aAMountOnyx
EndFunc   ; Counts Onyx in your Inventory

Func GetCharcoalCount()
	Local $aAMountCharcoal
	Local $aBag
	Local $aItem
	Local $i
	For $i = 1 To 4
		$aBag = GetBag($i)
		For $j = 1 To DllStructGetData($aBag, "Slots")
			$aItem = GetItemBySlot($aBag, $j)
			If DllStructGetData($aItem, "ModelID") == 922 Then
				$aAMountCharcoal += DllStructGetData($aItem, "Quantity")
			Else
				ContinueLoop
			EndIf
		Next
	Next
	Return $aAMountCharcoal
EndFunc   ; Counts Charcoal in your Inventory

Func GetObsidianSHardCount()
	Local $aAMountObbySHards
	Local $aBag
	Local $aItem
	Local $i
	For $i = 1 To 4
		$aBag = GetBag($i)
		For $j = 1 To DllStructGetData($aBag, "Slots")
			$aItem = GetItemBySlot($aBag, $j)
			If DllStructGetData($aItem, "ModelID") == 945 Then
				$aAMountObbySHards += DllStructGetData($aItem, "Quantity")
			Else
				ContinueLoop
			EndIf
		Next
	Next
	Return $aAMountObbySHards
EndFunc   ; Counts Obsidian SHards in your Inventory

Func GetGlassVialCount()
	Local $aAMountGlassVials
	Local $aBag
	Local $aItem
	Local $i
	For $i = 1 To 4
		$aBag = GetBag($i)
		For $j = 1 To DllStructGetData($aBag, "Slots")
			$aItem = GetItemBySlot($aBag, $j)
			If DllStructGetData($aItem, "ModelID") == 939 Then
				$aAMountGlassVials += DllStructGetData($aItem, "Quantity")
			Else
				ContinueLoop
			EndIf
		Next
	Next
	Return $aAMountGlassVials
EndFunc   ; Counts Glass Vials in your Inventory

Func GetLeatherCount()
	Local $aAMountLeather
	Local $aBag
	Local $aItem
	Local $i
	For $i = 1 To 4
		$aBag = GetBag($i)
		For $j = 1 To DllStructGetData($aBag, "Slots")
			$aItem = GetItemBySlot($aBag, $j)
			If DllStructGetData($aItem, "ModelID") == 942 Then
				$aAMountLeather += DllStructGetData($aItem, "Quantity")
			Else
				ContinueLoop
			EndIf
		Next
	Next
	Return $aAMountLeather
EndFunc   ; Counts Leather Squares in your Inventory

Func GetElonLeatherCount()
	Local $aAMountElonLeather
	Local $aBag
	Local $aItem
	Local $i
	For $i = 1 To 4
		$aBag = GetBag($i)
		For $j = 1 To DllStructGetData($aBag, "Slots")
			$aItem = GetItemBySlot($aBag, $j)
			If DllStructGetData($aItem, "ModelID") == 943 Then
				$aAMountElonLeather += DllStructGetData($aItem, "Quantity")
			Else
				ContinueLoop
			EndIf
		Next
	Next
	Return $aAMountElonLeather
EndFunc   ; Counts Elonian LEather in your Inventory

Func GetVialInkCount()
	Local $aAMountVialsInk
	Local $aBag
	Local $aItem
	Local $i
	For $i = 1 To 4
		$aBag = GetBag($i)
		For $j = 1 To DllStructGetData($aBag, "Slots")
			$aItem = GetItemBySlot($aBag, $j)
			If DllStructGetData($aItem, "ModelID") == 944 Then
				$aAMountVialsInk += DllStructGetData($aItem, "Quantity")
			Else
				ContinueLoop
			EndIf
		Next
	Next
	Return $aAMountVialsInk
EndFunc   ; Counts Vials of Ink in your Inventory

Func GetParchmentCount()
	Local $aAMountParchment
	Local $aBag
	Local $aItem
	Local $i
	For $i = 1 To 4
		$aBag = GetBag($i)
		For $j = 1 To DllStructGetData($aBag, "Slots")
			$aItem = GetItemBySlot($aBag, $j)
			If DllStructGetData($aItem, "ModelID") == 951 Then
				$aAMountParchment += DllStructGetData($aItem, "Quantity")
			Else
				ContinueLoop
			EndIf
		Next
	Next
	Return $aAMountParchment
EndFunc   ; Counts Parchment in your Inventory

Func GetVellumCount()
	Local $aAMountVellum
	Local $aBag
	Local $aItem
	Local $i
	For $i = 1 To 4
		$aBag = GetBag($i)
		For $j = 1 To DllStructGetData($aBag, "Slots")
			$aItem = GetItemBySlot($aBag, $j)
			If DllStructGetData($aItem, "ModelID") == 952 Then
				$aAMountVellum += DllStructGetData($aItem, "Quantity")
			Else
				ContinueLoop
			EndIf
		Next
	Next
	Return $aAMountVellum
EndFunc   ; Counts Vellum in your Inventory

Func GetSpiritwoodCount()
	Local $aAMountSpiritWood
	Local $aBag
	Local $aItem
	Local $i
	For $i = 1 To 4
		$aBag = GetBag($i)
		For $j = 1 To DllStructGetData($aBag, "Slots")
			$aItem = GetItemBySlot($aBag, $j)
			If DllStructGetData($aItem, "ModelID") == 956 Then
				$aAMountSpiritWood += DllStructGetData($aItem, "Quantity")
			Else
				ContinueLoop
			EndIf
		Next
	Next
	Return $aAMountSpiritWood
EndFunc   ; Counts Spiritwood Planks in your Inventory

Func GetAmberCount()
	Local $aAMountAmber
	Local $aBag
	Local $aItem
	Local $i
	For $i = 1 To 4
		$aBag = GetBag($i)
		For $j = 1 To DllStructGetData($aBag, "Slots")
			$aItem = GetItemBySlot($aBag, $j)
			If DllStructGetData($aItem, "ModelID") == 6532 Then
				$aAMountAmber += DllStructGetData($aItem, "Quantity")
			Else
				ContinueLoop
			EndIf
		Next
	Next
	Return $aAMountAmber
EndFunc   ; Counts Chunks of Amber in your Inventory

Func GetJadeCount()
	Local $aAMountJade
	Local $aBag
	Local $aItem
	Local $i
	For $i = 1 To 4
		$aBag = GetBag($i)
		For $j = 1 To DllStructGetData($aBag, "Slots")
			$aItem = GetItemBySlot($aBag, $j)
			If DllStructGetData($aItem, "ModelID") == 6533 Then
				$aAMountJade += DllStructGetData($aItem, "Quantity")
			Else
				ContinueLoop
			EndIf
		Next
	Next
	Return $aAMountJade
EndFunc   ; Counts Jadeite SHards in your Inventory

;	Event Items
Func GetAgedDwarvenAleCount()
	Local $aAMountAgedDwarven
	Local $aBag
	Local $aItem
	Local $i
	For $i = 1 To 4
		$aBag = GetBag($i)
		For $j = 1 To DllStructGetData($aBag, "Slots")
			$aItem = GetItemBySlot($aBag, $j)
			If DllStructGetData($aItem, "ModelID") == 24593 Then
				$aAMountAgedDwarven += DllStructGetData($aItem, "Quantity")
			Else
				ContinueLoop
			EndIf
		Next
	Next
	Return $aAMountAgedDwarven
EndFunc   ; Counts Aged Dwarven Ales in your Inventory

Func GetAgedHuntersAleCount()
	Local $aAMountAgedHunters
	Local $aBag
	Local $aItem
	Local $i
	For $i = 1 To 4
		$aBag = GetBag($i)
		For $j = 1 To DllStructGetData($aBag, "Slots")
			$aItem = GetItemBySlot($aBag, $j)
			If DllStructGetData($aItem, "ModelID") == 31145 Then
				$aAMountAgedHunters += DllStructGetData($aItem, "Quantity")
			Else
				ContinueLoop
			EndIf
		Next
	Next
	Return $aAMountAgedHunters
EndFunc   ; Counts Aged Dwarven Ales in your Inventory

Func GetIcedTeaCount()
	Local $aAMountIcedTea
	Local $aBag
	Local $aItem
	Local $i
	For $i = 1 To 4
		$aBag = GetBag($i)
		For $j = 1 To DllStructGetData($aBag, "Slots")
			$aItem = GetItemBySlot($aBag, $j)
			If DllStructGetData($aItem, "ModelID") == 36682 Then
				$aAMountIcedTea += DllStructGetData($aItem, "Quantity")
			Else
				ContinueLoop
			EndIf
		Next
	Next
	Return $aAMountIcedTea
EndFunc   ; Counts Battle Isle Iced teas in your Inventory

Func GetBirthdayCupcakeCount()
	Local $aAMountCupcakes
	Local $aBag
	Local $aItem
	Local $i
	For $i = 1 To 4
		$aBag = GetBag($i)
		For $j = 1 To DllStructGetData($aBag, "Slots")
			$aItem = GetItemBySlot($aBag, $j)
			If DllStructGetData($aItem, "ModelID") == 22269 Then
				$aAMountCupcakes += DllStructGetData($aItem, "Quantity")
			Else
				ContinueLoop
			EndIf
		Next
	Next
	Return $aAMountCupcakes
EndFunc   ; Counts Birthday Cupcakes in your Inventory

Func GetCandyCaneSHards()
	Local $aAMountCCSHards
	Local $aBag
	Local $aItem
	Local $i
	For $i = 1 To 4
		$aBag = GetBag($i)
		For $j = 1 To DllStructGetData($aBag, "Slots")
			$aItem = GetItemBySlot($aBag, $j)
			If DllStructGetData($aItem, "ModelID") == 556 Then
				$aAMountCCSHards += DllStructGetData($aItem, "Quantity")
			Else
				ContinueLoop
			EndIf
		Next
	Next
	Return $aAMountCCSHards
EndFunc   ; Counts Candy Cane SHards in your Inventory

Func GetGoldenEggCount()
	Local $aAMountEggs
	Local $aBag
	Local $aItem
	Local $i
	For $i = 1 To 4
		$aBag = GetBag($i)
		For $j = 1 To DllStructGetData($aBag, "Slots")
			$aItem = GetItemBySlot($aBag, $j)
			If DllStructGetData($aItem, "ModelID") == 22752 Then
				$aAMountEggs += DllStructGetData($aItem, "Quantity")
			Else
				ContinueLoop
			EndIf
		Next
	Next
	Return $aAMountEggs
EndFunc   ; Counts Golden Eggs in your Inventory

Func GetBottleOfGrogCount()
	Local $aAMountGrogs
	Local $aBag
	Local $aItem
	Local $i
	For $i = 1 To 4
		$aBag = GetBag($i)
		For $j = 1 To DllStructGetData($aBag, "Slots")
			$aItem = GetItemBySlot($aBag, $j)
			If DllStructGetData($aItem, "ModelID") == 30855 Then
				$aAMountGrogs += DllStructGetData($aItem, "Quantity")
			Else
				ContinueLoop
			EndIf
		Next
	Next
	Return $aAMountGrogs
EndFunc   ; Counts Bottles of Grog in your Inventory

Func GetHoneyCombCount()
	Local $aAMountHoneycombs
	Local $aBag
	Local $aItem
	Local $i
	For $i = 1 To 4
		$aBag = GetBag($i)
		For $j = 1 To DllStructGetData($aBag, "Slots")
			$aItem = GetItemBySlot($aBag, $j)
			If DllStructGetData($aItem, "ModelID") == 26784 Then
				$aAMountHoneycombs += DllStructGetData($aItem, "Quantity")
			Else
				ContinueLoop
			EndIf
		Next
	Next
	Return $aAMountHoneycombs
EndFunc   ; Counts Honeycombs in your Inventory

Func GetKrytanBrandyCount()
	Local $aAMountBrandy
	Local $aBag
	Local $aItem
	Local $i
	For $i = 1 To 4
		$aBag = GetBag($i)
		For $j = 1 To DllStructGetData($aBag, "Slots")
			$aItem = GetItemBySlot($aBag, $j)
			If DllStructGetData($aItem, "ModelID") == 35124 Then
				$aAMountBrandy += DllStructGetData($aItem, "Quantity")
			Else
				ContinueLoop
			EndIf
		Next
	Next
	Return $aAMountBrandy
EndFunc   ; Counts Krytan Brandies in your Inventory

Func GetPartyBeaconCount()
	Local $aAMountJesusBeams
	Local $aBag
	Local $aItem
	Local $i
	For $i = 1 To 4
		$aBag = GetBag($i)
		For $j = 1 To DllStructGetData($aBag, "Slots")
			$aItem = GetItemBySlot($aBag, $j)
			If DllStructGetData($aItem, "ModelID") == 36683 Then
				$aAMountJesusBeams += DllStructGetData($aItem, "Quantity")
			Else
				ContinueLoop
			EndIf
		Next
	Next
	Return $aAMountJesusBeams
EndFunc   ; Counts Party Beacons in your Inventory

Func GetPumpkinPieCount()
	Local $aAMountPies
	Local $aBag
	Local $aItem
	Local $i
	For $i = 1 To 4
		$aBag = GetBag($i)
		For $j = 1 To DllStructGetData($aBag, "Slots")
			$aItem = GetItemBySlot($aBag, $j)
			If DllStructGetData($aItem, "ModelID") == 28436 Then
				$aAMountPies += DllStructGetData($aItem, "Quantity")
			Else
				ContinueLoop
			EndIf
		Next
	Next
	Return $aAMountPies
EndFunc   ; Counts Slice of Pumpkin Pie in your Inventory

Func GetSpikedEggnogCount()
	Local $aAMountSpikedEggnog
	Local $aBag
	Local $aItem
	Local $i
	For $i = 1 To 4
		$aBag = GetBag($i)
		For $j = 1 To DllStructGetData($aBag, "Slots")
			$aItem = GetItemBySlot($aBag, $j)
			If DllStructGetData($aItem, "ModelID") == 6366 Then
				$aAMountSpikedEggnog += DllStructGetData($aItem, "Quantity")
			Else
				ContinueLoop
			EndIf
		Next
	Next
	Return $aAMountSpikedEggnog
EndFunc   ; Counts Spiked Eggnogs in your Inventory

Func GetTrickOrTreatCount()
	Local $aAMountToTs
	Local $aBag
	Local $aItem
	Local $i
	For $i = 1 To 4
		$aBag = GetBag($i)
		For $j = 1 To DllStructGetData($aBag, "Slots")
			$aItem = GetItemBySlot($aBag, $j)
			If DllStructGetData($aItem, "ModelID") == 28434 Then
				$aAMountToTs += DllStructGetData($aItem, "Quantity")
			Else
				ContinueLoop
			EndIf
		Next
	Next
	Return $aAMountToTs
EndFunc   ; Counts Trick-Or-Treat bags in your Inventory

Func GetVictoryTokenCount()
	Local $aAMountVicTokens
	Local $aBag
	Local $aItem
	Local $i
	For $i = 1 To 4
		$aBag = GetBag($i)
		For $j = 1 To DllStructGetData($aBag, "Slots")
			$aItem = GetItemBySlot($aBag, $j)
			If DllStructGetData($aItem, "ModelID") == 18345 Then
				$aAMountVicTokens += DllStructGetData($aItem, "Quantity")
			Else
				ContinueLoop
			EndIf
		Next
	Next
	Return $aAMountVicTokens
EndFunc   ; Counts Victory Tokens in your Inventory

Func GetWayfarerMarkCount();
	Local $aAMountWayfarerMark
	Local $aBag
	Local $aItem
	Local $i
	For $i = 1 To 4
		$aBag = GetBag($i)
		For $j = 1 To DllStructGetData($aBag, "Slots")
			$aItem = GetItemBySlot($aBag, $j)
			If DllStructGetData($aItem, "ModelID") == 37765 Then
				$aAMountWayfarerMark += DllStructGetData($aItem, "Quantity")
			Else
				ContinueLoop
			EndIf
		Next
	Next
	Return $aAMountWayfarerMark
EndFunc   ; Counts Wayfarer Marks in your Inventory

Func GetYuletideTonicCount();
	Local $aAMountYuletideTonics
	Local $aBag
	Local $aItem
	Local $i
	For $i = 1 To 4
		$aBag = GetBag($i)
		For $j = 1 To DllStructGetData($aBag, "Slots")
			$aItem = GetItemBySlot($aBag, $j)
			If DllStructGetData($aItem, "ModelID") == 21490 Then
				$aAMountYuletideTonics += DllStructGetData($aItem, "Quantity")
			Else
				ContinueLoop
			EndIf
		Next
	Next
	Return $aAMountYuletideTonics
EndFunc   ; Counts Yuletides in your Inventory

Func CountSlots()
	Local $Bag
	Local $temp = 0
	$Bag = GetBag(1)
	$temp += DllStructGetData($Bag, 'Slots') - DllStructGetData($Bag, 'ItemsCount')
	$Bag = GetBag(2)
	$temp += DllStructGetData($Bag, 'Slots') - DllStructGetData($Bag, 'ItemsCount')
	$Bag = GetBag(3)
	$temp += DllStructGetData($Bag, 'Slots') - DllStructGetData($Bag, 'ItemsCount')
	$Bag = GetBag(4)
	$temp += DllStructGetData($Bag, 'Slots') - DllStructGetData($Bag, 'ItemsCount')
	Return $temp
EndFunc ; Counts open slots in your Imventory

Func CountSlotsChest()
	Local $Bag
	Local $temp = 0
	$Bag = GetBag(8)
	$temp += DllStructGetData($Bag, 'Slots') - DllStructGetData($Bag, 'ItemsCount')
	$Bag = GetBag(9)
	$temp += DllStructGetData($Bag, 'Slots') - DllStructGetData($Bag, 'ItemsCount')
	$Bag = GetBag(10)
	$temp += DllStructGetData($Bag, 'Slots') - DllStructGetData($Bag, 'ItemsCount')
	$Bag = GetBag(11)
	$temp += DllStructGetData($Bag, 'Slots') - DllStructGetData($Bag, 'ItemsCount')
	$Bag = GetBag(12)
	$temp += DllStructGetData($Bag, 'Slots') - DllStructGetData($Bag, 'ItemsCount')
	$Bag = GetBag(13)
	$temp += DllStructGetData($Bag, 'Slots') - DllStructGetData($Bag, 'ItemsCount')
	$Bag = GetBag(14)
	$temp += DllStructGetData($Bag, 'Slots') - DllStructGetData($Bag, 'ItemsCount')
	$Bag = GetBag(15)
	$temp += DllStructGetData($Bag, 'Slots') - DllStructGetData($Bag, 'ItemsCount')
	$Bag = GetBag(16)
	$temp += DllStructGetData($Bag, 'Slots') - DllStructGetData($Bag, 'ItemsCount')
	Return $temp
EndFunc ; Counts open slots in the Storage chest
#EndRegion Counting Things

#Region Storing Stuff
; Big function that calls the smaller functions below
Func StoreItems()
	StackableDrops(1, 20)
	StackableDrops(2, 5)
	StackableDrops(3, 10)
	StackableDrops(4, 10)
	Alcohol(1, 20)
	Alcohol(2, 5)
	Alcohol(3, 10)
	Alcohol(4, 10)
	Party(1, 20)
	Party(2, 5)
	Party(3, 10)
	Party(4, 10)
	Sweets(1, 20)
	Sweets(2, 5)
	Sweets(3, 10)
	Sweets(4, 10)
	Scrolls(1, 20)
	Scrolls(2, 5)
	Scrolls(3, 10)
	Scrolls(4, 10)
	EliteTomes(1, 20)
	EliteTomes(2, 5)
	EliteTomes(3, 10)
	EliteTomes(4, 10)
	Tomes(1, 20)
	Tomes(2, 5)
	Tomes(3, 10)
	Tomes(4, 10)
	DPRemoval(1, 20)
	DPRemoval(2, 5)
	DPRemoval(3, 10)
	DPRemoval(4, 10)
	SpecialDrops(1, 20)
	SpecialDrops(2, 5)
	SpecialDrops(3, 10)
	SpecialDrops(4, 10)
EndFunc ;~ Includes event Items broken down by Type

Func StoreMaterials()
	Materials(1, 20)
	Materials(2, 5)
	Materials(3, 10)
	Materials(4, 10)
EndFunc ;~ Common and Rare Materials

Func StoreUNIDGolds()
	UNIDGolds(1, 20)
	UNIDGolds(2, 5)
	UNIDGolds(3, 10)
	UNIDGolds(4, 10)
EndFunc ;~ UNID Golds

Func StoreMods()
	Mods(1, 20)
	Mods(2, 5)
	Mods(3, 10)
	Mods(4, 10)
EndFunc ;~ Mods I want to keep

Func StoreWeapons()
	Weapons(1, 20)
	Weapons(2, 5)
	Weapons(3, 10)
	Weapons(4, 10)
EndFunc

Func Weapons($BagIndex, $SlotCount)
	Local $aItem
	Local $Bag
	Local $Slot
	Local $Full
	Local $NSlot
	For $I = 1 To $SlotCount
		Local $aItem = GetItemBySlot($BagIndex, $I)
		If DllStructGetData($aItem, "ID") = 0 Then ContinueLoop
		Local $ModStruct = GetModStruct($aItem)
		Local $Energy = StringInStr($ModStruct, "0500D822", 0, 1) ;~String for +5e mod
		Switch DllStructGetData($aItem, "Type")
			Case 2, 5, 15, 27, 32, 35, 36
				If $Energy > 0 Then
					Do
						For $Bag = 8 To 12
							$Slot = FindEmptySlot($Bag)
							$Slot = @extended
							If $Slot <> 0 Then
								$Full = False
								$NSlot = $Slot
								ExitLoop 2
							Else
								$Full = True
							EndIf
							Sleep(400)
						Next
					Until $Full = True
					If $Full = False Then
						MoveItem($aItem, $Bag, $NSlot)
						Sleep(Random(450, 550))
					EndIf
				EndIf
		EndSwitch
	Next
EndFunc

Func StackableDrops($BagIndex, $SlotCount)
	Local $aItem
	Local $M
	Local $Q
	Local $Bag
	Local $Slot
	Local $Full
	Local $NSlot
	For $I = 1 To $SlotCount
		$aItem = GetItemBySlot($BagIndex, $I)
		If DllStructGetData($aItem, "ID") = 0 Then ContinueLoop
		$M = DllStructGetData($aItem, "ModelID")
		$Q = DllStructGetData($aItem, "quantity")
		If ($M = 460 Or $M = 474 Or $M = 476 Or $M = 486 Or $M = 522 Or $M = 525 Or $M = 811 Or $M = 819 Or $M = 822 Or $M = 835 Or $M = 1610 Or $M = 2994 Or $M = 19185 Or $M = 22751 Or $M = 24629 Or $M = 24630 Or $M = 24631 Or $M = 24632 Or $M = 27033 Or $M = 27035 Or $M = 27044 Or $M = 27046 Or $M = 27047 Or $M = 27052 Or $M = 35123) And $Q = 250 Then
			Do
				For $Bag = 8 To 12
					$Slot = FindEmptySlot($Bag)
					$Slot = @extended
					If $Slot <> 0 Then
						$Full = False
						$NSlot = $Slot
						ExitLoop 2
					Else
						$Full = True
					EndIf
					Sleep(400)
				Next
			Until $Full = True
			If $Full = False Then
				MoveItem($aItem, $Bag, $NSlot)
				Sleep(GetPing()+500)
			EndIf
		EndIf
	Next
EndFunc ;~ like Suarian Bones, lockpicks, Glacial Stones, etc

Func EliteTomes($BagIndex, $SlotCount)
	Local $aItem
	Local $M
	Local $Q
	Local $Bag
	Local $Slot
	Local $Full
	Local $NSlot
	For $I = 1 To $SlotCount
		$aItem = GetItemBySlot($BagIndex, $I)
		If DllStructGetData($aItem, "ID") = 0 Then ContinueLoop
		$M = DllStructGetData($aItem, "ModelID")
		$Q = DllStructGetData($aItem, "quantity")
		If ($M = 21796 Or $M = 21797 Or $M = 21798 Or $M = 21799 Or $M = 21800 Or $M = 21801 Or $M = 21802 Or $M = 21803 Or $M = 21804 Or $M = 21805) And $Q = 250 Then
			Do
				For $Bag = 8 To 12
					$Slot = FindEmptySlot($Bag)
					$Slot = @extended
					If $Slot <> 0 Then
						$Full = False
						$NSlot = $Slot
						ExitLoop 2
					Else
						$Full = True
					EndIf
					Sleep(400)
				Next
			Until $Full = True
			If $Full = False Then
				MoveItem($aItem, $Bag, $NSlot)
				Sleep(GetPing()+500)
			EndIf
		EndIf
	Next
EndFunc ;~ non-Elite tomes only

Func Tomes($BagIndex, $SlotCount)
	Local $aItem
	Local $M
	Local $Q
	Local $Bag
	Local $Slot
	Local $Full
	Local $NSlot
	For $I = 1 To $SlotCount
		$aItem = GetItemBySlot($BagIndex, $I)
		If DllStructGetData($aItem, "ID") = 0 Then ContinueLoop
		$M = DllStructGetData($aItem, "ModelID")
		$Q = DllStructGetData($aItem, "quantity")
		If ($M = 21796 Or $M = 21797 Or $M = 21798 Or $M = 21799 Or $M = 21800 Or $M = 21801 Or $M = 21802 Or $M = 21803 Or $M = 21804 Or $M = 21805) And $Q = 250 Then
			Do
				For $Bag = 8 To 12
					$Slot = FindEmptySlot($Bag)
					$Slot = @extended
					If $Slot <> 0 Then
						$Full = False
						$NSlot = $Slot
						ExitLoop 2
					Else
						$Full = True
					EndIf
					Sleep(400)
				Next
			Until $Full = True
			If $Full = False Then
				MoveItem($aItem, $Bag, $NSlot)
				Sleep(GetPing()+500)
			EndIf
		EndIf
	Next
EndFunc ;~ non-Elite tomes only

Func Alcohol($BagIndex, $SlotCount)
	Local $aItem
	Local $M
	Local $Q
	Local $Bag
	Local $Slot
	Local $Full
	Local $NSlot
	For $I = 1 To $SlotCount
		$aItem = GetItemBySlot($BagIndex, $I)
		If DllStructGetData($aItem, "ID") = 0 Then ContinueLoop
		$M = DllStructGetData($aItem, "ModelID")
		$Q = DllStructGetData($aItem, "quantity")
		If ($M = 910 Or $M = 2513 Or $M = 5585 Or $M = 6049 Or $M = 6366 Or $M = 6367 Or $M = 6375 Or $M = 15477 Or $M = 19171 Or $M = 22190 Or $M = 24593 Or $M = 28435 Or $M = 30855 Or $M = 31145 Or $M = 31146 Or $M = 35124 Or $M = 36682) And $Q = 250 Then
			Do
				For $Bag = 8 To 12
					$Slot = FindEmptySlot($Bag)
					$Slot = @extended
					If $Slot <> 0 Then
						$Full = False
						$NSlot = $Slot
						ExitLoop 2
					Else
						$Full = True
					EndIf
					Sleep(400)
				Next
			Until $Full = True
			If $Full = False Then
				MoveItem($aItem, $Bag, $NSlot)
				Sleep(GetPing()+500)
			EndIf
		EndIf
	Next
EndFunc

Func Party($BagIndex, $SlotCount)
	Local $aItem
	Local $M
	Local $Q
	Local $Bag
	Local $Slot
	Local $Full
	Local $NSlot
	For $I = 1 To $SlotCount
		$aItem = GetItemBySlot($BagIndex, $I)
		If DllStructGetData($aItem, "ID") = 0 Then ContinueLoop
		$M = DllStructGetData($aItem, "ModelID")
		$Q = DllStructGetData($aItem, "quantity")
		If ($M = 6376 Or $M = 6368 Or $M = 6369 Or $M = 21809 Or $M = 21810 Or $M = 21813 Or $M = 29436 Or $M = 29543 Or $M = 36683 Or $M = 4730 Or $M = 15837 Or $M = 21490 Or $M = 22192 Or $M = 30626 Or $M = 30630 Or $M = 30638 Or $M = 30642 Or $M = 30646 Or $M = 30648 Or $M = 31020 Or $M = 31141 Or $M = 31142 Or $M = 31144 Or $M = 31172) And $Q = 250 Then
			Do
				For $Bag = 8 To 12
					$Slot = FindEmptySlot($Bag)
					$Slot = @extended
					If $Slot <> 0 Then
						$Full = False
						$NSlot = $Slot
						ExitLoop 2
					Else
						$Full = True
					EndIf
					Sleep(400)
				Next
			Until $Full = True
			If $Full = False Then
				MoveItem($aItem, $Bag, $NSlot)
				Sleep(GetPing()+500)
			EndIf
		EndIf
	Next
EndFunc

Func Sweets($BagIndex, $SlotCount)
	Local $aItem
	Local $M
	Local $Q
	Local $Bag
	Local $Slot
	Local $Full
	Local $NSlot
	For $I = 1 To $SlotCount
		$aItem = GetItemBySlot($BagIndex, $I)
		If DllStructGetData($aItem, "ID") = 0 Then ContinueLoop
		$M = DllStructGetData($aItem, "ModelID")
		$Q = DllStructGetData($aItem, "quantity")
		If ($M = 15528 Or $M = 15479 Or $M = 19170 Or $M = 21492 Or $M = 21812 Or $M = 22269 Or $M = 22644 Or $M = 22752 Or $M = 28431 Or $M = 28432 Or $M = 28436 Or $M = 31150 Or $M = 35125 Or $M = 36681) And $Q = 250 Then
			Do
				For $Bag = 8 To 12
					$Slot = FindEmptySlot($Bag)
					$Slot = @extended
					If $Slot <> 0 Then
						$Full = False
						$NSlot = $Slot
						ExitLoop 2
					Else
						$Full = True
					EndIf
					Sleep(400)
				Next
			Until $Full = True
			If $Full = False Then
				MoveItem($aItem, $Bag, $NSlot)
				Sleep(GetPing()+500)
			EndIf
		EndIf
	Next
EndFunc

Func Scrolls($BagIndex, $SlotCount)
	Local $aItem
	Local $M
	Local $Q
	Local $Bag
	Local $Slot
	Local $Full
	Local $NSlot
	For $I = 1 To $SlotCount
		$aItem = GetItemBySlot($BagIndex, $I)
		If DllStructGetData($aItem, "ID") = 0 Then ContinueLoop
		$M = DllStructGetData($aItem, "ModelID")
		$Q = DllStructGetData($aItem, "quantity")
		If ($M = 3256 Or $M = 3746 Or $M = 5594 Or $M = 5595 Or $M = 5611 Or $M = 5853 Or $M = 5975 Or $M = 5976 Or $M = 21233 Or $M = 22279 Or $M = 22280) And $Q = 250 Then
			Do
				For $Bag = 8 To 12
					$Slot = FindEmptySlot($Bag)
					$Slot = @extended
					If $Slot <> 0 Then
						$Full = False
						$NSlot = $Slot
						ExitLoop 2
					Else
						$Full = True
					EndIf
					Sleep(400)
				Next
			Until $Full = True
			If $Full = False Then
				MoveItem($aItem, $Bag, $NSlot)
				Sleep(GetPing()+500)
			EndIf
		EndIf
	Next
EndFunc

Func DPRemoval($BagIndex, $SlotCount)
	Local $aItem
	Local $M
	Local $Q
	Local $Bag
	Local $Slot
	Local $Full
	Local $NSlot
	For $I = 1 To $SlotCount
		$aItem = GetItemBySlot($BagIndex, $I)
		If DllStructGetData($aItem, "ID") = 0 Then ContinueLoop
		$M = DllStructGetData($aItem, "ModelID")
		$Q = DllStructGetData($aItem, "quantity")
		If ($M = 6370 Or $M = 21488 Or $M = 21489 Or $M = 22191 Or $M = 35127 Or $M = 26784 Or $M = 28433) And $Q = 250 Then
			Do
				For $Bag = 8 To 12
					$Slot = FindEmptySlot($Bag)
					$Slot = @extended
					If $Slot <> 0 Then
						$Full = False
						$NSlot = $Slot
						ExitLoop 2
					Else
						$Full = True
					EndIf
					Sleep(400)
				Next
			Until $Full = True
			If $Full = False Then
				MoveItem($aItem, $Bag, $NSlot)
				Sleep(GetPing()+500)
			EndIf
		EndIf
	Next
EndFunc

Func SpecialDrops($BagIndex, $SlotCount)
	Local $aItem
	Local $M
	Local $Q
	Local $Bag
	Local $Slot
	Local $Full
	Local $NSlot
	For $I = 1 To $SlotCount
		$aItem = GetItemBySlot($BagIndex, $I)
		If DllStructGetData($aItem, "ID") = 0 Then ContinueLoop
		$M = DllStructGetData($aItem, "ModelID")
		$Q = DllStructGetData($aItem, "quantity")
		If ($M = 18345 Or $M = 21491 Or $M = 21833 Or $M = 28434 Or $M = 35121) And $Q = 250 Then
			Do
				For $Bag = 8 To 12
					$Slot = FindEmptySlot($Bag)
					$Slot = @extended
					If $Slot <> 0 Then
						$Full = False
						$NSlot = $Slot
						ExitLoop 2
					Else
						$Full = True
					EndIf
					Sleep(400)
				Next
			Until $Full = True
			If $Full = False Then
				MoveItem($aItem, $Bag, $NSlot)
				Sleep(GetPing()+500)
			EndIf
		EndIf
	Next
EndFunc

Func Materials($BagIndex, $SlotCount)
	Local $aItem
	Local $M
	Local $Q
	Local $Bag
	Local $Slot
	Local $Full
	Local $NSlot
	For $I = 1 To $SlotCount
		$aItem = GetItemBySlot($BagIndex, $I)
		If DllStructGetData($aItem, "ID") = 0 Then ContinueLoop
		$M = DllStructGetData($aItem, "ModelID")
		$Q = DllStructGetData($aItem, "quantity")
		If ($M = 921 Or $M = 922 Or $M = 923 Or $M = 925 Or $M = 926 Or $M = 927 Or $M = 928 Or $M = 929 Or $M = 930 Or $M = 931 Or $M = 932 Or $M = 933 Or $M = 934 Or $M = 935 Or $M = 936 Or $M = 937 Or $M = 938 Or $M = 939 Or $M = 940 Or $M = 941 Or $M = 942 Or $M = 943 Or $M = 944 Or $M = 945 Or $M = 946 Or $M = 948 Or $M = 949 Or $M = 950 Or $M = 951 Or $M = 952 Or $M = 953 Or $M = 954 Or $M = 955 Or $M = 956 Or $M = 6532 Or $M = 6533) And $Q = 250 Then
			Do
				For $Bag = 8 To 12
					$Slot = FindEmptySlot($Bag)
					$Slot = @extended
					If $Slot <> 0 Then
						$Full = False
						$NSlot = $Slot
						ExitLoop 2
					Else
						$Full = True
					EndIf
					Sleep(400)
				Next
			Until $Full = True
			If $Full = False Then
				MoveItem($aItem, $Bag, $NSlot)
				Sleep(GetPing()+500)
			EndIf
		EndIf
	Next
EndFunc

; Keeps all Golds
Func UNIDGolds($BagIndex, $SlotCount)
	Local $aItem
	Local $M
	Local $R
	Local $Bag
	Local $Slot
	Local $Full
	Local $NSlot
	For $I = 1 To $SlotCount
		$aItem = GetItemBySlot($BagIndex, $I)
		If DllStructGetData($aItem, "ID") = 0 Then ContinueLoop
		$R = GetRarity($aItem)
		$M = DllStructGetData($aItem, "ModelID")
		If $R = 2624 Then
			Do
				For $Bag = 8 To 12
					$Slot = FindEmptySlot($Bag)
					$Slot = @extended
					If $Slot <> 0 Then
						$Full = False
						$NSlot = $Slot
						ExitLoop 2
					Else
						$Full = True
					EndIf
					Sleep(400)
				Next
			Until $Full = True
			If $Full = False Then
				MoveItem($aItem, $Bag, $NSlot)
				Sleep(GetPing()+500)
			EndIf
		EndIf
	Next
EndFunc ;~ UNID Golds

; Stores the mods that I am salvaging out to keep for Hero weapons
Func Mods($BagIndex, $SlotCount)
	Local $aItem
	Local $M
	Local $Q
	Local $Bag
	Local $Slot
	Local $Full
	Local $NSlot
	For $I = 1 To $SlotCount
		$aItem = GetItemBySlot($BagIndex, $I)
		If DllStructGetData($aItem, "ID") = 0 Then ContinueLoop
		$M = DllStructGetData($aItem, "ModelID")
		$Q = DllStructGetData($aItem, "quantity")
		If ($M = 896 Or $M = 908 Or $M = 15554 Or $M = 15551 Or $M = 15552 Or $M = 894 Or $M = 906 Or $M = 897 Or $M = 909 Or $M = 893 Or $M = 905 Or $M = 6323 Or $M = 6331 Or $M = 895 Or $M = 907 Or $M = 15543 Or $M = 15553 Or $M = 15544 Or $M = 15555 Or $M = 15540 Or $M = 15541 Or $M = 15542 Or $M = 17059 Or $M = 19122 Or $M = 19123) Then
			Do
				For $Bag = 8 To 12
					$Slot = FindEmptySlot($Bag)
					$Slot = @extended
					If $Slot <> 0 Then
						$Full = False
						$NSlot = $Slot
						ExitLoop 2
					Else
						$Full = True
					EndIf
					Sleep(400)
				Next
			Until $Full = True
			If $Full = False Then
				MoveItem($aItem, $Bag, $NSlot)
				Sleep(GetPing()+500)
			EndIf
		EndIf
	Next
EndFunc

; This searches for empty slots in your Storage
Func FindEmptySlot($BagIndex)
	Local $LItemINFO, $aSlot
	For $aSlot = 1 To DllStructGetData(GetBAG($BagIndex), "Slots")
		Sleep(40)
		$LItemINFO = GetItemBySlot($BagIndex, $aSlot)
		If DllStructGetData($LItemINFO, "ID") = 0 Then
			SetExtended($aSlot)
			ExitLoop
		EndIf
	Next
	Return 0
EndFunc
#EndRegion Storing Stuff
#EndRegion Inventory


Func UpdateLock()
    Local $cn = GetCharname()
    If $cn Then
        Local $sFileName   = @ScriptDir & "\lock\" & $cn & ".lock"
        Local $hFilehandle = FileOpen($sFileName, $FO_OVERWRITE)
        FileWrite($hFilehandle,  @HOUR & ":" & @MIN)
        FileClose($hFilehandle)
    EndIf
EndFunc


;~ Description: Print to console with timestamp
Func Out($TEXT)
	; Local $TEXTLEN = StringLen($TEXT)
	; Local $CONSOLELEN = _GUICtrlEdit_GetTextLen($GUI_Console)
	; If $TEXTLEN + $CONSOLELEN > 30000 Then GUICtrlSetData($GUI_Console, StringRight(_GUICtrlEdit_GetText($GUI_Console), 30000 - $TEXTLEN - 1000))
	; _GUICtrlEdit_AppendText($GUI_Console, @CRLF & "[" & @HOUR & ":" & @MIN & ":" & @SEC & "] " & $TEXT)
	; _GUICtrlEdit_Scroll($GUI_Console, 1)
    GUICtrlSetData($GUI_Console, GUICtrlRead($GUI_Console) & @HOUR & ":" & @MIN & " - " & $TEXT & @CRLF)
    _GUICtrlEdit_Scroll($GUI_Console, $SB_SCROLLCARET)
    _GUICtrlEdit_Scroll($GUI_Console, $SB_LINEUP)
    UpdateLock()
EndFunc   ;==>OUT

;~ Description: guess what?
Func _exit()
	Exit
EndFunc

#Region Pcons
Func UseCupcake()
	If $useCupcake Then
		pconsScanInventory()
		If (GetMapLoading() == 1) And (GetIsDead(-2) == False) Then
			If $pconsCupcake_slot[0] > 0 And $pconsCupcake_slot[1] > 0 Then
				If DllStructGetData(GetItemBySlot($pconsCupcake_slot[0], $pconsCupcake_slot[1]), "ModelID") == 22269 Then
					UseItemBySlot($pconsCupcake_slot[0], $pconsCupcake_slot[1])
				EndIf
			EndIf
		EndIf
	EndIf
EndFunc
;~ This searches the bags for the specific pcon you wish to use.
Func pconsScanInventory()
	Local $Bag
	Local $size
	Local $Slot
	Local $Item
	Local $ModelID
	$pconsCupcake_slot[0] = $pconsCupcake_slot[1] = 0
	For $Bag = 1 To 4 Step 1
		If $Bag == 1 Then $size = 20
		If $Bag == 2 Then $size = 5
		If $Bag == 3 Then $size = 10
		If $Bag == 4 Then $size = 10
		For $Slot = 1 To $size Step 1
			$Item = GetItemBySlot($Bag, $Slot)
			$ModelID = DllStructGetData($Item, "ModelID")
			Switch $ModelID
				Case 0
					ContinueLoop
				Case 22269
					$pconsCupcake_slot[0] = $Bag
					$pconsCupcake_slot[1] = $Slot
			EndSwitch
		Next
	Next
EndFunc   ;==>pconsScanInventory
;~ Uses the Item from UseCupcake()
Func UseItemBySlot($aBag, $aSlot)
	Local $Item = GetItemBySlot($aBag, $aSlot)
	SendPacket(8, $HEADER_Item_USE, DllStructGetData($Item, "ID"))
EndFunc   ;==>UseItemBySlot

Func arrayContains($Array, $Item)
	For $i = 1 To $Array[0]
		If $Array[$i] == $Item Then
			Return True
		EndIf
	Next
	Return False
EndFunc   ;==>arrayContains
#EndRegion Pcons

;=================================================================================================
; Function:			SetDisplayedTitle($aTitle = 0)
; Description:		Set the currently displayed title.
; Parameter(s):		Parameter = $aTitle
;								No Title		= 0x00
;								Spearmarshall 	= 0x11
;								Lightbringer 	= 0x14
;								Asuran 			= 0x26
;								Dwarven 		= 0x27
;								Ebon Vanguard 	= 0x28
;								Norn 			= 0x29
;; Requirement(s):	GW must be running and Memory must have been scanned for pointers (see Initialize())
; Return Value(s):	Returns displayed Title
; Author(s):		Skaldish
;=================================================================================================
; Func SetDisplayedTitle($aTitle = 0)
; 	If $aTitle Then
; 		Return SendPacket(0x8, $HEADER_TITLE_DISPLAY, $aTitle)
; 	Else
; 		Return SendPacket(0x4, $HEADER_TITLE_CLEAR)
; 	EndIf
; EndFunc   ;==>SetDisplayedTitle

Func RndTravel($aMapID)
	Local $UseDistricts = 7 ; 7=eu, 8=eu+int, 11=all(incl. asia)
	; Region/Language order: eu-en, eu-fr, eu-ge, eu-it, eu-sp, eu-po, eu-ru, int, asia-ko, asia-ch, asia-ja
	Local $Region[11]   = [2, 2, 2, 2, 2, 2, 2, -2, 1, 3, 4]
	Local $Language[11] = [0, 2, 3, 4, 5, 9, 10, 0, 0, 0, 0]
	Local $Random = Random(0, $UseDistricts - 1, 1)
	MoveMap($aMapID, $Region[$Random], 0, $Language[$Random])
	WaitMapLoading($aMapID, 30000)
	Sleep(GetPing()+3000)
EndFunc   ;==>RndTravel

Func GenericRandomPath($aPosX, $aPosY, $aRandom = 50, $STOPSMIN = 1, $STOPSMAX = 5, $NumberOfStops = -1)
	If $NumberOfStops = -1 Then $NumberOfStops = Random($STOPSMIN, $STOPSMAX, 1)
	Local $lAgent = GetAgentByID(-2)
	Local $MyPosX = DllStructGetData($lAgent, "X")
	Local $MyPosY = DllStructGetData($lAgent, "Y")
	Local $Distance = ComputeDistance($MyPosX, $MyPosY, $aPosX, $aPosY)
	If $NumberOfStops = 0 Or $Distance < 200 Then
		MoveTo($aPosX, $aPosY, $aRandom)
	Else
		Local $M = Random(0, 1)
		Local $N = $NumberOfStops - $M
		Local $StepX = (($M * $aPosX) + ($N * $MyPosX)) / ($M + $N)
		Local $StepY = (($M * $aPosY) + ($N * $MyPosY)) / ($M + $N)
		MoveTo($StepX, $StepY, $aRandom)
		GenericRandomPath($aPosX, $aPosY, $aRandom, $STOPSMIN, $STOPSMAX, $NumberOfStops - 1)
	EndIf
EndFunc   ;==>GENERICRANDOMPATH

Func LOGIN($char_name = "fail", $ProcessID = false)

    If $char_name = "" Then
    	MsgBox(0, "Error", "char_name" & $char_name)
        Exit
    EndIf

    If $ProcessID = False Then
    	MsgBox(0, "Error", "ProcessID" & $ProcessID)
        Exit
    EndIf

    Sleep(Random(1000,1500))

    Local $WindowList=WinList("Guild Wars")
    Local $WinHandle = False;


    For $i = 1 to $WindowList[0][0]
        If WinGetProcess($WindowList[$i][1])= $ProcessID Then
            $WinHandle=$WindowList[$i][1]
        EndIf
    Next

    If $WinHandle = False Then
    	MsgBox(0, "Error", "WinHandle" & $WinHandle)
        Exit
    EndIf

    ; ControlSend($WinHandle, "", "", "{enter}")
    ; Sleep(Random(2500,3500))
    ; ControlSend($WinHandle, "", "", "{enter}")
    ; Sleep(Random(100,150))
    ; ControlSend($WinHandle, "", "", "{enter}")
    ; Sleep(Random(2000,2500))
    ; ControlSend($WinHandle, "", "", "{enter}")
    ; Sleep(Random(1000,1500))
    ; WinSetTitle($WinHandle, "", $char_name & " - Guild Wars")
    ; Sleep(Random(5000,7500))
    Local $lCheck    = False
    Local $lDeadLock = Timerinit()

    ControlSend($WinHandle, "", "", "{enter}")
    Sleep(Random(500,1500))
    WinSetTitle($WinHandle, "", $char_name & " - Guild Wars")
    Do
        Sleep(50)
        ; $lCheck = GetMapLoading() <> 2 and GetAgentExists(-2)
        $lCheck = GetMapLoading() <> 2
    Until $lCheck Or TimerDiff($lDeadLock)>15000
    ; ControlSend($WinHandle, "", "", "{enter}")
    ; Sleep(Random(500,1500))
    If $lCheck = False Then
        ControlSend($WinHandle, "", "", "{enter}")
        $lDeadLock = Timerinit()
        Do
            Sleep(50)
            ; $lCheck = GetMapLoading() <> 2 and GetAgentExists(-2)
            $lCheck = GetMapLoading() <> 2
        Until $lCheck Or TimerDiff($lDeadLock)>15000
    EndIf
    ; ControlSend($WinHandle, "", "", "{enter}")
    ; Sleep(Random(500,1500))
    If $lCheck = False Then
        ControlSend($WinHandle, "", "", "{enter}")
        $lDeadLock = Timerinit()
        Do
            Sleep(50)
            ; $lCheck = GetMapLoading() <> 2 and GetAgentExists(-2)
            $lCheck = GetMapLoading() <> 2
        Until $lCheck Or TimerDiff($lDeadLock)>15000
    EndIf
    ; ControlSend($WinHandle, "", "", "{enter}")
    ; Sleep(Random(500,1500))
    If $lCheck = False Then
        ControlSend($WinHandle, "", "", "{enter}")
        $lDeadLock = Timerinit()
        Do
            Sleep(50)
            ; $lCheck = GetMapLoading() <> 2 and GetAgentExists(-2)
            $lCheck = GetMapLoading() <> 2
        Until $lCheck Or TimerDiff($lDeadLock)>15000
    EndIf

    ; $lCheck = False



    If $lCheck = False Then
        MsgBox(0, "Error", "lcheck")

        ProcessClose($ProcessID)
        Exit
    Else
        Sleep(Random(2500,3500))
    EndIf


EndFunc




;Bolt ons from Chest Bot script i.e. Storing Golds, unids, consumables etc.
#Region Storage
Func StoreItemsEx()
	Out("Storing Items")
	Local $aItem, $m, $Q, $lbag, $Slot, $Full, $NSlot
	For $i = 1 To 4
		$lbag = GetBag($i)
		For $j = 1 To DllStructGetData($lbag, 'Slots')
			$aItem = GetItemBySlot($lbag, $j)
			If DllStructGetData($aItem, "ID") = 0 Then ContinueLoop
			$m = DllStructGetData($aItem, "ModelID")
			$Q = DllStructGetData($aItem, "quantity")

			For $z = 0 To (UBound($Array_Store_ModelIDs460) - 1)
				If (($m == $Array_Store_ModelIDs460[$z]) And ($Q = 250)) Then
					Do
						For $Bag = 8 To 12
							$Slot = FindEmptySlot($Bag)
							$Slot = @extended
							If $Slot <> 0 Then
								$Full = False
								$NSlot = $Slot
								ExitLoop 2
							Else
								$Full = True
							EndIf
							Sleep(400)
						Next
					Until $Full = True
					If $Full = False Then
						MoveItem($aItem, $Bag, $NSlot)
						Sleep(GetPing() + 500)
					EndIf
				EndIf
			Next
		Next
	Next
EndFunc   ;==>StoreItems

Func StoreGoldsEx()
	Out("Storing Golds")
	Local $aItem, $lItem, $m, $Q, $r, $lbag, $Slot, $Full, $NSlot
	For $i = 1 To 4
		$lbag = GetBag($i)
		For $j = 1 To DllStructGetData($lbag, 'Slots')
			$aItem = GetItemBySlot($lbag, $j)
			If DllStructGetData($aItem, "ID") = 0 Then ContinueLoop
			$m = DllStructGetData($aItem, "ModelID")
			$r = GetRarity($lItem)
			If CanStoreGoldsEx($aItem) Then
				Do
					For $Bag = 8 To 12
						$Slot = FindEmptySlotEx($Bag)
						$Slot = @extended
						If $Slot <> 0 Then
							$Full = False
							$NSlot = $Slot
							ExitLoop 2
						Else
							$Full = True
						EndIf
						Sleep(400)
					Next
				Until $Full = True
				If $Full = False Then
					MoveItem($aItem, $Bag, $NSlot)
					Sleep(GetPing() + 500)
				EndIf
			EndIf
		Next
	Next
EndFunc   ;==>StoreGolds

Func CanStoreGoldsEx($aItem)
	Local $m = DllStructGetData($aItem, "ModelID")
	Local $r = GetRarity($aItem)
	Switch $r
		Case $Rarity_Gold
			If $m = 22280 Then
				Return False
			Else
				Return True
			EndIf
	EndSwitch
EndFunc   ;==>CanStoreGolds

Func FindEmptySlotEx($BagIndex)
	Local $LItemINFO, $aSlot
	For $aSlot = 1 To DllStructGetData(GetBag($BagIndex), "Slots")
		Sleep(40)
		$LItemINFO = GetItemBySlot($BagIndex, $aSlot)
		If DllStructGetData($LItemINFO, "ID") = 0 Then
			SetExtended($aSlot)
			ExitLoop
		EndIf
	Next
	Return 0
EndFunc   ;==>FindEmptySlot

Func CountSlotsEx()
	Local $Bag
	Local $temp = 0
	$Bag = GetBag(1)
	$temp += DllStructGetData($Bag, 'Slots') - DllStructGetData($Bag, 'ItemsCount')
	$Bag = GetBag(2)
	$temp += DllStructGetData($Bag, 'Slots') - DllStructGetData($Bag, 'ItemsCount')
	$Bag = GetBag(3)
	$temp += DllStructGetData($Bag, 'Slots') - DllStructGetData($Bag, 'ItemsCount')
	$Bag = GetBag(4)
	$temp += DllStructGetData($Bag, 'Slots') - DllStructGetData($Bag, 'ItemsCount')
	Return $temp
EndFunc   ;==>CountSlots
#EndRegion Storage
