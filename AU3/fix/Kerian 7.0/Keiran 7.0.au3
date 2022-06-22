#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <ButtonConstants.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include "GWA2.au3"
#include <Date.au3> ;Most likely not needed
#include <Array.au3>

;ADD ON
;#include <Misc.au3>
;#include <GuiEdit.au3>
;#Include <WinAPIEx.au3>
;#include <GUIConstantsEx.au3>
;#include <ScrollBarsConstants.au3>
;#include <ComboConstants.au3>
;#include <FileConstants.au3>

Opt("GUIOnEventMode", True)
Opt("GUICloseOnESC", False)

#cs ----------------------------------------------------------------------------
 Keiran Bot
 AutoIt Version:   3.3.8.1
 Last Modified:	   1.24.19
 Script Version:   7.0
 Original Author:  Danylia
 Modified Author:  RiflemanX
 Modified Author:  Zaishen Silver

 Script Notes:
 (Weapon Slot-1) Shortbow +15/-5 vamp +5 armor is the best weapon
 (Weapon Slot-2) Kieran Bow
 Ideal character is max armor (War/Para) with Knights Insignias and the Absorption -3 rune superior
 Any char can go into mission if you send the right dialog ID (already in script)
 You just need the Keiran's Bow that Gwen gives for the right dialog ID

 Keiran Bot v6.4-v6.7
 AutoIt Version:   3.3.8.1
 Last Modified:	   1.9.19
 Script Version:   6.4 - 6.6
 Original Author:  Danylia
 Modified Author:  RiflemanX
 Modified Author:  Zaishen Silver
 Script Function:  -

Version Notes:
Run Time added
General Script Clean-Up
Start Button visual upgraded
Removed unesseccary constants
Formatting changes made to GUI
Changed some minor sleep times
Vanguard Rank adjusted to display points and rank
LoadFinished as wells as some patterns uptdated
Upgraded and changed Purge Engine Hook Checkbox, function, and call timing.
Changed WeaponSlot organization and call outs.  Keiran Bow in slot-1 and best bow in slot-2.  No others needed.

v6.7 Also changed waitmaploading for waitmaploadigex.  See GWA2 for details.
  ~Updated Gold Pointers
  ~Patched using Rheeks patcher from GitHub (2.28.19)
  ~Adjusted Buy Ectos function.  If more than 800k in chest and Buy Ectos is checked it will buy till it gets down to 500k in chest

v6.8 ChangeLog 3.19.19
Script Clean-Up
Adjusted more sleep times
Swapped GWA2 for proven one
Changed waitmaploading
Removed unescesary call for DepositGOld (already called in checkinventory)
Created map stuck timer.  If you are in the mission for more than 10 minutes then the script will restart

v6.9 ChangeLog 3.21.19
Added "Use War Supplies" option
Found errors in GWA2, corrected
Replaced GetGoldCharacter with new
Replaced GetGoldstorage with new
Updated $lItemStruct

v7.0 ChangeLog 4.4.19
Deposit Gold in EoTN.  No sense in traveling to GH if not storing golds needed
Bunny Boost/Speed Boost option now available for Guild Hall whens storing golds
Modified the gold functions and patterns to ensure no hang-ups when buying ecto
Will move full stacks of War Supplies to Chest when full (during merch/inv session)
If the option for "Buy Ecto" is selected and you have 900k in your inventory it will buy ectos until you are below 800k then being to farm again

Sill needed:
Count Gold Coins accurately
Import Rare Items (Q8 shields, swords, etc)
Pickup Armor pieces and salvage runes for resale
Improve strategy for ChangeWeaponSet during msision
Check for bug that causes crash after closing script and then playing manually
Create map/mission timer.  If in the mission for more than 10 minutes than bot is stuck.  Restart.
#ce ----------------------------------------------------------------------------


#region Variables
	GLOBAL $QUESTMAPID = 849
	GLOBAL $HOMMAPID = 646
	GLOBAL $EOTNMAPID = 642
	GLOBAL $EOTNEVMAPID = 821
	GLOBAL $BRUNNING = FALSE
	GLOBAL $BINITIALIZED = FALSE
	GLOBAL $RESIGN = FALSE
	GLOBAL $RENDERING = TRUE
	GLOBAL $GWPID = -1
	GLOBAL $TOTALCASH = 0
	GLOBAL $FAILRUNS = 0
	GLOBAL $SUCCESSRUNS = 0
	GLOBAL $VANGUARDDONE = 0
	GLOBAL $CASHMADE = 0
	GLOBAL $RUNWAYPOINTS[21][4] = [[11125, -5226, "Main Path 1", 1250], [10338, -5966, "Main Path 2", 1250], [9871, -6464, "Main Path 3", 1250], [8933, -8213, "Main Path 4", 1250], [7498, -8517, "Main Path 6", 1250], [5193, -8514, "Trying to skip this group", 2000], [3082, -11112, "Trying to Skip Forest", 1600], [1743, -12859, "Killing Forest Mob", 1300], [-181, -12791, "Leaving Forest", 1250], [-2728, -11695, "Main Path 16", 1250], [-2858, -11942, "Detour 17", 1250], [-4212, -12641, "Detour 18", 1250], [-4276, -12771, "Detour 19", 1250], [-6884, -11357, "Detour 20", 1250], [-9085, -8631, "Detour 22", 1250], [-13156, -7883, "Detour 23", 1250], [-13768, -8158, "Final Area 30", 1250], [-14205, -8373, "Final Area 31", 1250], [-15876, -8903, "Final Area 32", 1250], [-17109, -8978, "Final Area 33", 1250], ["WaitForEnemies", 1500, 25000, FALSE]]
	Global $RARITY_White = 2621, $RARITY_Blue = 2623, $RARITY_Purple = 2626, $RARITY_Gold = 2624, $RARITY_Green = 2627
	GLOBAL $MTEAM
	GLOBAL $MTEAMOTHERS
	GLOBAL $MTEAMDEAD
	GLOBAL $MENEMIES
	GLOBAL $MENEMIESRANGE
	GLOBAL $MENEMIESSPELLRANGE
	GLOBAL $MSPIRITS
	GLOBAL $MPETS
	GLOBAL $MMINIONS
	GLOBAL $MSELF
	GLOBAL $MSELFID
	GLOBAL $MLOWESTALLY
	GLOBAL $MLOWESTALLYHP
	GLOBAL $MLOWESTOTHERALLY
	GLOBAL $MLOWESTOTHERALLYHP
	GLOBAL $MLOWESTENEMY
	GLOBAL $MLOWESTENEMYHP
	GLOBAL $MCLOSESTENEMY
	GLOBAL $MCLOSESTENEMYDIST
	GLOBAL $MEFFECTS
	GLOBAL $MSKILLBAR
	GLOBAL $MENERGY
	GLOBAL $MDAZED = FALSE
	GLOBAL $MBLIND = FALSE
	GLOBAL $MSKILLHARDCOUNTER = FALSE
	GLOBAL $MSKILLSOFTCOUNTER = 0
	GLOBAL $MATTACKHARDCOUNTER = FALSE
	GLOBAL $MATTACKSOFTCOUNTER = 0
	GLOBAL $MALLYSPELLHARDCOUNTER = FALSE
	GLOBAL $MENEMYSPELLHARDCOUNTER = FALSE
	GLOBAL $MSPELLSOFTCOUNTER = 0
	GLOBAL $MBLOCKING = FALSE
	GLOBAL $MSKILLTIMER = TIMERINIT()
	GLOBAL $MCASTTIME = -1
	GLOBAL $WPTCOUNT
	GLOBAL $MOVE = FALSE
	GLOBAL $NDEADLOCK = TIMERINIT()
	Global $RenderingEnabled = True
	Global $VanTitle = "Vanguard Title"
	Global $VanGuarRank = "R-0"
	Global $GoldsCount = 0
	Global $GoldsCoins = 0

	;TIME
	Global $MAP_TIMER = TimerInit()
    Global $Timeout = 10000 ; 10 seconds used for testing)
	;Global $Timeout = 10000 * 300; 300 seconds (5 Min)
	Global $TotalSeconds = 0
	Global $Seconds = 0
	Global $Minutes = 0
	Global $Hours = 0

#endregion Variables


#region GUI
	OPT("GUIOnEventMode", 1)
	$MAINGUI = GUICREATE("Kieran v7.0", 230, 295)

	$INPUTCHARNAME = GUICTRLCREATECOMBO  ("", 08, 10, 105, 20)
	GUICTRLSETDATA(-1, GETLOGGEDCHARNAMES())

	;Vanguard Data Box
	$VANGUARD     = GUICTRLCREATEGROUP("Vanguard",    120, 003, 102, 064, BITOR($GUI_SS_DEFAULT_GROUP, $BS_CENTER))
	$LBLVAN_RANK  = GUICTRLCREATELABEL ($VanGuarRank, 121, 018, 099, 017, BITOR($SS_CENTER, $SS_CENTERIMAGE))
	$STVANGUARD   = GUICTRLCREATELABEL("-",           121, 033, 099, 017, BITOR($SS_CENTER, $SS_CENTERIMAGE))

   $Label_Vanguard_Title  = GUICTRLCREATELABEL($VanTitle, 121, 046, 099, 17, BITOR($SS_CENTER, $SS_CENTERIMAGE))

	;War Supplies Data Box
	$LBLWARSUPPLIES   = GUICTRLCREATEGROUP("War Supply Total",   120, 70, 102, 035, BITOR($GUI_SS_DEFAULT_GROUP, $BS_CENTER))
	$WARSUPPLIES     = GUICTRLCREATELABEL("-", 127, 083, 093, 17, BITOR($SS_CENTER, $SS_CENTERIMAGE))
	GUICTRLSETFONT(-1, 9, 700, 0)

	;Stats/Info
	$GSTATS        = GUICTRLCREATEGROUP("",        008, 028, 105, 050, BITOR($GUI_SS_DEFAULT_GROUP, $BS_CENTER))
	$LBLRUNS       = GUICTRLCREATELABEL("Wins: ",  015, 042, 050, 17)
	$STRUNS        = GUICTRLCREATELABEL("0",       080, 042, 030, 17)
	$LBLFAILRUNS   = GUICTRLCREATELABEL("Fails:",  015, 058, 050, 17)
	$STFAILRUNS    = GUICTRLCREATELABEL("0",       080, 058, 030, 17)
	$LBLGOLD_ITEMS = GUICTRLCREATELABEL("Gold Items:",       008, 085, 070, 17)
	$GOLD_ITEMS_CNT= GUICTRLCREATELABEL("0",                 080, 085, 030, 17)
	$LBLEARNEDCASH = GUICTRLCREATELABEL("Gold Earned:",      008, 100, 070, 17)
	$STEARNEDCASH  = GUICTRLCREATELABEL("0",                 080, 100, 030, 17)
	$LBLCHESTGOLD  = GUICTRLCREATELABEL("Gold in Chest:",    008, 115, 068, 17)
	$STCHESTGOLD   = GUICTRLCREATELABEL("0",                 080, 115, 044, 17)
	$LBLWARSUP     = GUICTRLCREATELABEL("War Supplies:",     008, 130, 068, 17)
	$STWARSUP      = GUICTRLCREATELABEL("0",                 080, 130, 030, 17)
	$LBLEquip_1     = GUICTRLCREATELABEL("Slot-1 Best Bow",  135, 115, 080, 17)
	$LBLEquip_2     = GUICTRLCREATELABEL("Slot-2 Keiran Bow",135, 130, 085, 17)

    ;OPTIONS
	$CBDISABLEGRAPH = GUICTRLCREATECHECKBOX("Render",           015, 150, 090, 20)
	$CBECTOS        = GUICTRLCREATECHECKBOX("Buy Ectos",        015, 167, 090, 20)
	$PURGE          = GUICTRLCREATECHECKBOX("Purge Engine",     015, 184, 090, 20)
	$CBSWEETBOOST   = GUICTRLCREATECHECKBOX("Bunny Boost",      015, 201, 090, 20)
	$PICKUPARMOR	= GUICTRLCREATECHECKBOX("Pick-Up Armor",    130, 150, 090, 20) ;Need Function Updated
	$CBPICKGOLDS    = GUICTRLCREATECHECKBOX("Pick-Up Golds",    130, 167, 090, 20)
	$CBSTOREGOLDS   = GUICTRLCREATECHECKBOX("Store Golds",      130, 184, 090, 20)
    $CBUSEWARSUP    = GUICTRLCREATECHECKBOX("Use War Sup.",     130, 201, 090, 20)


	GUICTRLSETSTATE($CBSTOREGOLDS, $GUI_CHECKED)
	GUICTRLSETSTATE($CBPICKGOLDS, $GUI_CHECKED)

	$Run_Time      = GUICTRLCREATELABEL("0:00:00",        020, 220, 190, 20, $SS_CENTER)
	$LBLSTATUS     = GUICTRLCREATELABEL("Ready to Start", 020, 235, 190, 20, $SS_CENTER)
	$BTNSTART      = GUICTRLCREATEBUTTON("Start",         020, 253, 190, 35, $WS_GROUP, $SS_CENTER)
	GUICTRLSETONEVENT($CBDISABLEGRAPH, "EventHandler")
	GUICTRLSETONEVENT($BTNSTART, "EventHandler")
	GUISETONEVENT($GUI_EVENT_CLOSE, "EventHandler")
	GUISETSTATE(@SW_SHOW)
#endregion GUI

#region EventHandler
	DO
		SLEEP(100)
	UNTIL $BINITIALIZED
	INITGUI()
	AdlibRegister("TimeUpdater", 1000)
   ; AdlibRegister("MapTimer", 1000)  =======NEED TO CREATE MAP TIMER.  IF ON MAP FOR 10 MINUTES THEN RESTART========
	GUISetState(@SW_SHOW)

	CHECKINVENTORY()
	WHILE 1
	   ;Testing Map Timer (5 min, then ExitLoop)

	    ;$nMsg = GUIGetMsg()
		; If TimerDiff($MAP_TIMER) > $Timeout Then
		;	MsgBox(0,"","Out of time")
		;	ExitLoop
		; EndIf

		IF $BRUNNING THEN
			UPDATEGUI()
			SWITCH GETMAPID()
				CASE $QUESTMAPID
					IF RUNNINGQUEST() THEN
						OUT("Success")
						$SUCCESSRUNS += 1
					ELSE
						OUT("Fail")
						$FAILRUNS += 1
						SLEEP(3000)
						RETURNTOOUTPOST()
						WaitMapLoading($EOTNMAPID)
					 ENDIF
					CHECKINVENTORY()

				CASE $EOTNMAPID, $EOTNEVMAPID

					 If GetChecked ($CBSWEETBOOST) Then
					   UseBunnies()
					 EndIf

					If Getchecked($CBECTOS) Then
						BUYECTOS()
					EndIf

					ENTERHOM()
				CASE $HOMMAPID
					ENTERQUEST()
				CASE ELSE
					OUT("Travelling: EoTN")
					TRAVELTO($EOTNMAPID)
			ENDSWITCH
		ENDIF
		SLEEP(100)
	WEND

	FUNC EVENTHANDLER()
		SWITCH @GUI_CTRLID
			CASE $GUI_EVENT_CLOSE
				EXIT
			CASE $BTNSTART
				IF $BRUNNING THEN
					GUICTRLSETDATA($BTNSTART, "Resume")
					$BRUNNING = FALSE
				ELSEIF $BINITIALIZED THEN
					GUICTRLSETDATA($BTNSTART, "Pause")
					$BRUNNING = TRUE
				ELSE
					$BRUNNING = TRUE
					GUICTRLSETDATA($BTNSTART, "Initializing...")
					GUICTRLSETSTATE($BTNSTART, $GUI_DISABLE)
					GUICTRLSETSTATE($INPUTCHARNAME, $GUI_DISABLE)
					WINSETTITLE($MAINGUI, "v7.0", GUICTRLREAD($INPUTCHARNAME))
					IF GUICTRLREAD($INPUTCHARNAME) = "" THEN
						IF INITIALIZE(PROCESSEXISTS("gw.exe"), TRUE) = FALSE THEN
							MSGBOX(0, "Error", "Guild Wars it not running.")
							EXIT
						ENDIF
					ELSE
						IF INITIALIZE(GUICTRLREAD($INPUTCHARNAME), TRUE) = FALSE THEN
							MSGBOX(0, "Error", "Can't find a Guild Wars client with that character name.")
							EXIT
						ENDIF
					ENDIF
					GUICTRLSETDATA($BTNSTART, "Pause")
					GUICTRLSETSTATE($BTNSTART, $GUI_ENABLE)
					SETMAXMEMORY()
					$BINITIALIZED = TRUE
				ENDIF
			CASE $CBDISABLEGRAPH
				TOGGLERENDERING_2()
		ENDSWITCH
	ENDFUNC
#endregion EventHandler

#region Fonctions
	FUNC ENTERHOM()
		OUT("Entering HoM ")
		MOVETO(-4340, 4887)
		MOVE(-5000, 5400)
		WaitMapLoading($HOMMAPID)
		If GetMapLoading() == 2 Then Disconnected()
	ENDFUNC

	FUNC ENTERQUEST()
		GUICTRLSETDATA($STWARSUP,    GETNUMBERWARSUPINV()) ;Count in pack
		GUICTRLSETDATA($WARSUPPLIES, GET_TOTAL_NUMBER_WAR_SUP_INV());Total count including chest
		Out("Changing Weapons: Slot-2 Keiran Bow")
		CHANGEWEAPONSET(2)
		Sleep(2000)
		MOVETO(-6381, 6381)
		OUT("Entering Quest")
		$NPC = GETNEARESTNPCTOCOORDS(-6662, 6584)
		GOTONPC($NPC)
		Sleep(1500)
		DIALOG(1586)
		WaitMapLoading($QUESTMAPID)
	ENDFUNC

	FUNC RUNNINGQUEST()
		If GetMapLoading() == 2 Then Disconnected()
		LOCAL $LTIME, $LME
		$LTIME = TIMERINIT()
		IF GETMAPID() <> $QUESTMAPID THEN
			RETURN FALSE
		 ENDIF
	    Sleep(GetPing()) ;<====Added some extra lag time (2 seconds, approx)
		OUT("Running Quest")
		MOVETO(11815, -4827)
		Out("Changing weapons to best bow")
		CHANGEWEAPONSET(1)
		Sleep(GetPing())

		If Getchecked ($Purge) Then
		Out("Purging Engine Hook")
		PurgeHook()
		EndIf


		WAITFORENEMIES(1550, 56000)

		If GetChecked ($CBUSEWARSUP) Then
		   UseWarSupply()
	    EndIf

		IF NOT RUNWAYPOINTS() THEN RETURN FALSE
		WAITFORENEMIES(2000, 30000)
		IF NOT FIGHT(2500) THEN RETURN FALSE
		OUT("Finished a cycle in " & ROUND(TIMERDIFF($LTIME) / 60000) & " minutes.")
		DO
			SLEEP(GetPing())
			$LME = GETAGENTBYID(-2)
		UNTIL GETMAPID() = $HOMMAPID AND DLLSTRUCTGETDATA($LME, "X") <> 0 OR GETISDEAD(-2) OR TIMERDIFF($LTIME) > 900000

		Sleep(GetPing()*20)
		RETURN TRUE
	ENDFUNC
#endregion Fonctions

#region Cast Engine
	FUNC CAST()
		IF GETISKNOCKED($MSELF) THEN RETURN FALSE
		LOCAL $LMIKU = GETAGENTBYNAME("Miku")
		IF DLLSTRUCTGETDATA($MSELF, "HP") < 0.7 OR DLLSTRUCTGETDATA($LMIKU, "HP") < 0.5 THEN
			IF CANUSESKILL(6, 2) THEN
				USESKILL(6, $MSELFID)
				RETURN TRUE
			ENDIF
		ENDIF
		IF CANUSESKILL(1, 2) THEN
			FOR $I = 1 TO $MENEMIESRANGE[0]
				IF GETHASHEX($MENEMIESRANGE[$I]) THEN
					USESKILL(1, $MENEMIESRANGE[$I])
					RETURN TRUE
				ENDIF
			NEXT
		ENDIF
		IF GETHASCONDITION($MSELF) THEN
			IF CANUSESKILL(5, 3) THEN
				USESKILL(5, $MLOWESTENEMY)
				RETURN TRUE
			ENDIF
		ENDIF
		IF CANUSESKILL(3, 1) THEN
			FOR $I = 1 TO $MENEMIESRANGE[0]
				IF GETISBLEEDING($MENEMIESRANGE[$I]) OR DLLSTRUCTGETDATA($MENEMIESRANGE[$I], "Skill") <> 0 OR GETTARGET($MENEMIESRANGE[$I]) == $MSELFID THEN
					USESKILL(3, $MENEMIESRANGE[$I])
					RETURN TRUE
				ENDIF
			NEXT
		ENDIF
		IF CANUSESKILL(4, 1) THEN
			USESKILL(4, $MLOWESTENEMY)
			RETURN TRUE
		ENDIF
		IF CANUSESKILL(2, 2) THEN
			FOR $I = 1 TO $MENEMIESRANGE[0]
				IF GETHASCONDITION($MENEMIESRANGE[$I]) OR GETTARGET($MENEMIESRANGE[$I]) == $MSELFID THEN
					USESKILL(2, $MENEMIESRANGE[$I])
					RETURN TRUE
				ENDIF
			NEXT
		ENDIF
		RETURN FALSE
	ENDFUNC

	FUNC BUILDMAINTENANCE()
		LOCAL $LMIKU = GETAGENTBYNAME("Miku")
		IF DLLSTRUCTGETDATA($MSELF, "HP") < 0.7 OR DLLSTRUCTGETDATA($LMIKU, "HP") < 0.5 THEN
			IF CANUSESKILL(6, 2) THEN
				USESKILL(6, $MSELFID)
				RETURN TRUE
			ENDIF
		ENDIF
		RETURN FALSE
	ENDFUNC

	FUNC CANUSESKILL($ASKILLSLOT, $AENERGY = 0, $ASOFTCOUNTER = 10)
		IF $MSKILLHARDCOUNTER THEN RETURN FALSE
		IF $MSKILLSOFTCOUNTER > $ASOFTCOUNTER THEN RETURN FALSE
		IF $MENERGY < $AENERGY THEN RETURN FALSE
		IF DLLSTRUCTGETDATA($MSKILLBAR, "Recharge" & $ASKILLSLOT) == 0 THEN
			LOCAL $LSKILL = GETSKILLBYID(DLLSTRUCTGETDATA($MSKILLBAR, "Id" & $ASKILLSLOT))
			IF DLLSTRUCTGETDATA($MSKILLBAR, "AdrenalineA" & $ASKILLSLOT) < DLLSTRUCTGETDATA($LSKILL, "Adrenaline") THEN RETURN FALSE
			SWITCH DLLSTRUCTGETDATA($LSKILL, "Type")
				CASE 7, 10, 3, 12, 15, 16, 19, 20, 21, 22, 26, 27, 28
				CASE 14
					IF $MATTACKHARDCOUNTER THEN RETURN FALSE
					IF $MATTACKSOFTCOUNTER > $ASOFTCOUNTER THEN RETURN FALSE
				CASE 4, 5, 6, 9, 11, 24, 25
					IF $MSPELLSOFTCOUNTER > $ASOFTCOUNTER THEN RETURN FALSE
					IF $MDAZED THEN
						IF DLLSTRUCTGETDATA($LSKILL, "Activation") > 0.25 THEN RETURN FALSE
					ENDIF
					SWITCH DLLSTRUCTGETDATA($LSKILL, "Target")
						CASE 3, 4
							IF $MALLYSPELLHARDCOUNTER THEN RETURN FALSE
						CASE 5, 16
							IF $MENEMYSPELLHARDCOUNTER THEN RETURN FALSE
						CASE ELSE
					ENDSWITCH
			ENDSWITCH
			RETURN TRUE
		ENDIF
		RETURN FALSE
	ENDFUNC

	FUNC CASTENGINE($ASKILL = FALSE, $ATARGET = 0)
		IF NOT $ASKILL THEN
			IF TIMERDIFF($MSKILLTIMER) < $MCASTTIME THEN RETURN FALSE
			$MCASTTIME = -1
			LOCAL $LDEADLOCK = TIMERINIT()
			IF CAST() THEN
				DO
					SLEEP(3)
				UNTIL $MCASTTIME > -1 OR TIMERDIFF($LDEADLOCK) > GETPING() + 175
				RETURN TRUE
			ENDIF
		ELSE
			IF TIMERDIFF($MSKILLTIMER) < $MCASTTIME THEN SLEEP($MCASTTIME - TIMERDIFF($MSKILLTIMER))
			$MCASTTIME = -1
			LOCAL $LDEADLOCK = TIMERINIT()
			USESKILL($ASKILL, $ATARGET)
			DO
				SLEEP(3)
			UNTIL $MCASTTIME > -1 OR TIMERDIFF($LDEADLOCK) > GETPING() + 750
			IF $MCASTTIME > -1 THEN SLEEP($MCASTTIME)
		ENDIF
		RETURN FALSE
	ENDFUNC
#endregion Cast Engine

#region Stock
	FUNC CHECKINVENTORY()
		OUT("Check inventory")
		IF GETGOLDCHARACTER() > 90000 THEN
			DEPOSITGOLD(91000)
			IF GUICTRLREAD($CBSTOREGOLDS) = 1 THEN
			    TRAVELGH()
				CHANGEWEAPONSET(1)

				 If GetChecked ($CBSWEETBOOST) Then
					   UseBunnies()
				  EndIf

				STOREGOLD()
			ENDIF
			GUICTRLSETDATA($STCHESTGOLD, GETGOLDSTORAGE())
		ENDIF
	ENDFUNC

	FUNC BUYECTOS()
		IF GETGOLDSTORAGE() > 900000 THEN ;900k
			LOCAL $RAREMATTRADER = GETNEARESTNPCTOCOORDS(-2079, 1046)
			OUT("Going to Rare Material Trader")
			GOTONPC($RAREMATTRADER)
			RNDSLEEP(1000)
			LOCAL $MAXINVGOLDS
			LOCAL $TRADERPRICE
			Out("Buying Ectos")
			WHILE GETGOLDSTORAGE() > 900000 ;900k
				DO
				   	WITHDRAWGOLD()
				    GUICTRLSETDATA($STCHESTGOLD, GETGOLDSTORAGE())
					TRADERREQUEST(930)
					SLEEP(GETPING()+500)
					$TRADERPRICE = GETTRADERCOSTVALUE()
					TRADERBUY()
					SLEEP(GETPING()+500)
					GUICTRLSETDATA($STCHESTGOLD, GETGOLDSTORAGE())
					SLEEP(GETPING()+500)
				 Until GETGOLDSTORAGE() < 800000 ;800k

			 WEND
			 	Out("Buy Ectos Complete")
				Sleep(500)
				Out("Depositing Platinum")
			DEPOSITGOLD()
		ENDIF
	ENDFUNC

	FUNC STOREGOLD()
		 STOREBAG(1)
		 STOREBAG(2)
		 STOREBAG(3)
		 STOREBAG(4)
	ENDFUNC

	FUNC STOREBAG($ABAG)
		OUT("Storing bag " & $ABAG)
		IF NOT ISDLLSTRUCT($ABAG) THEN $ABAG = GETBAG($ABAG)
		LOCAL $LITEM
		LOCAL $LSLOT
		IF ISCHESTFULL() THEN RETURN
		FOR $I = 1 TO DLLSTRUCTGETDATA($ABAG, "Slots")
			$STOCKABLE = FALSE
			$LITEM = GETITEMBYSLOT($ABAG, $I)
			IF DLLSTRUCTGETDATA($LITEM, "id") == 0 THEN CONTINUELOOP
			$M = DLLSTRUCTGETDATA($LITEM, "ModelID")
			$R = GETRARITY($LITEM)
			IF $R = 2624 THEN
				$STOCKABLE = TRUE
			ENDIF
			IF $STOCKABLE == TRUE THEN
				$LSLOT = OPENSTORAGESLOT()
				IF ISARRAY($LSLOT) THEN
					MOVEITEM($LITEM, $LSLOT[0], $LSLOT[1])
					SLEEP(GETPING() + RANDOM(500, 750, 1))
				ENDIF
			ENDIF
		NEXT
	ENDFUNC

	FUNC OPENSTORAGESLOT()
		LOCAL $LBAG
		LOCAL $LRETURNARRAY[2]
		FOR $I = 8 TO 16
			$LBAG = GETBAG($I)
			FOR $J = 1 TO DLLSTRUCTGETDATA($LBAG, "Slots")
				IF DLLSTRUCTGETDATA(GETITEMBYSLOT($LBAG, $J), "ID") == 0 THEN
					$LRETURNARRAY[0] = $I
					$LRETURNARRAY[1] = $J
					RETURN $LRETURNARRAY
				ENDIF
			NEXT
		NEXT
	ENDFUNC
	FUNC ISCHESTFULL()
		IF COUNTCHESTSLOTS() = 0 THEN
			OUT("Chest Full")
			RETURN TRUE
		ENDIF
		RETURN FALSE
	ENDFUNC
	FUNC COUNTCHESTSLOTS()
		LOCAL $BAG
		LOCAL $TEMP = 0
		FOR $I = 8 TO 16
			$BAG = GETBAG($I)
			$TEMP += DLLSTRUCTGETDATA($BAG, "slots") - DLLSTRUCTGETDATA($BAG, "ItemsCount")
		NEXT
		RETURN $TEMP
	ENDFUNC

	FUNC GETNUMBERWARSUPINV()
		LOCAL $LNBWARSUP
		FOR $J = 1 TO 4
			$ABAG = GETBAG($J)
			IF NOT ISDLLSTRUCT($ABAG) THEN $ABAG = GETBAG($ABAG)
			FOR $I = 1 TO DLLSTRUCTGETDATA($ABAG, "Slots")
				$LITEM = GETITEMBYSLOT($ABAG, $I)
				IF DLLSTRUCTGETDATA($LITEM, "id") == 0 THEN CONTINUELOOP
				$M = DLLSTRUCTGETDATA($LITEM, "ModelID")
				$Q = DLLSTRUCTGETDATA($LITEM, "Quantity")
				IF $M == 35121 THEN
					$LNBWARSUP += $Q
				ENDIF
			NEXT
		NEXT
		RETURN $LNBWARSUP
	ENDFUNC

	FUNC GET_TOTAL_NUMBER_WAR_SUP_INV()
		LOCAL $LNBWARSUP
		FOR $J = 1 TO 16
			$ABAG = GETBAG($J)
			IF NOT ISDLLSTRUCT($ABAG) THEN $ABAG = GETBAG($ABAG)
			FOR $I = 1 TO DLLSTRUCTGETDATA($ABAG, "Slots")
				$LITEM = GETITEMBYSLOT($ABAG, $I)
				IF DLLSTRUCTGETDATA($LITEM, "id") == 0 THEN CONTINUELOOP
				$M = DLLSTRUCTGETDATA($LITEM, "ModelID")
				$Q = DLLSTRUCTGETDATA($LITEM, "Quantity")
				IF $M == 35121 THEN
					$LNBWARSUP += $Q
				ENDIF
			NEXT
		NEXT
		RETURN $LNBWARSUP
	ENDFUNC

#endregion Stock
#region Rendering

	Func ToggleRendering_2()
	$RenderingEnabled = Not $RenderingEnabled
	If $RenderingEnabled Then
		EnableRendering()
		WinSetState(GetWindowHandle(), "", @SW_SHOW)
	Else
		DisableRendering()
		WinSetState(GetWindowHandle(), "", @SW_HIDE)
		ClearMemory()
	EndIf
 EndFunc

	FUNC _REDUCEMEMORY()
		IF $GWPID <> -1 THEN
			LOCAL $AI_HANDLE = DLLCALL("kernel32.dll", "int", "OpenProcess", "int", 2035711, "int", FALSE, "int", $GWPID)
			LOCAL $AI_RETURN = DLLCALL("psapi.dll", "int", "EmptyWorkingSet", "long", $AI_HANDLE[0])
			DLLCALL("kernel32.dll", "int", "CloseHandle", "int", $AI_HANDLE[0])
		ELSE
			LOCAL $AI_RETURN = DLLCALL("psapi.dll", "int", "EmptyWorkingSet", "long", -1)
		ENDIF
		RETURN $AI_RETURN[0]
	ENDFUNC
#endregion Rendering

#region Fonctions
	FUNC RUNWAYPOINTS()
		LOCAL $LX, $LY, $LMSG, $LRANGE
		$WPTCOUNT = 0
		FOR $I = 0 TO 20
			$LX = $RUNWAYPOINTS[$I][0]
			$LY = $RUNWAYPOINTS[$I][1]
			$LMSG = $RUNWAYPOINTS[$I][2]
			$LRANGE = $RUNWAYPOINTS[$I][3]
			IF ISSTRING($LX) THEN
				CALL($LX, $LY, $LMSG, $LRANGE)
			ELSE
				IF NOT AGGROMOVETOEX($LX, $LY, $LMSG, $LRANGE) THEN RETURN FALSE
			ENDIF
			$WPTCOUNT = $WPTCOUNT + 1
		NEXT
		RETURN TRUE
	ENDFUNC
	FUNC COUNTSPIRITS()
		LOCAL $LSHADOWSONG
		LOCAL $LSPIRITSINRANGE
		IF $MSPIRITS[0] = 0 THEN RETURN FALSE
		FOR $I = 1 TO $MSPIRITS[0]
			IF GETDISTANCE($MSPIRITS[$I]) > 1500 THEN CONTINUELOOP
			$LSPIRITSINRANGE = $LSPIRITSINRANGE + 1
			IF DLLSTRUCTGETDATA($MSPIRITS[$I], "PlayerNumber") = 4181 THEN
				$LSHADOWSONG = TRUE
			ENDIF
		NEXT
		IF $LSPIRITSINRANGE > 2 OR $LSHADOWSONG THEN RETURN TRUE
	ENDFUNC
	FUNC CHECKFORSPIRITS($MOVEBACKX, $MOVEBACKY)
		LOCAL $LENEMY
		LOCAL $J
		IF NOT COUNTSPIRITS() THEN RETURN TRUE
		$J = 1
		DO
			IF GETISDEAD(-2) THEN RETURN FALSE
			IF $WPTCOUNT < 4 OR $WPTCOUNT = (UBOUND($RUNWAYPOINTS) - 1) THEN RETURN TRUE
			IF $WPTCOUNT - $J < 0 THEN RETURN TRUE
			IF ISSTRING($RUNWAYPOINTS[$WPTCOUNT - $J][0]) THEN RETURN TRUE
			OUT("Spirit found, running to waypoint " & $WPTCOUNT - $J)
			MOVETO($RUNWAYPOINTS[$WPTCOUNT - $J][0], $RUNWAYPOINTS[$WPTCOUNT - $J][1])
			$J = $J + 1
			$NDEADLOCK = TIMERINIT()
			SLEEP(2000)
		UNTIL NOT COUNTSPIRITS()
		OUT("Back to normal route")
		IF NOT AGGROMOVETOEX($MOVEBACKX, $MOVEBACKY) THEN RETURN FALSE
		RETURN TRUE
	 ENDFUNC

	FUNC WAITFORENEMIES($ADIST, $ADEADLOCK, $PARAM = FALSE)
		LOCAL $LTARGET, $LDISTANCE
		LOCAL $LDEADLOCK = TIMERINIT()
		OUT("Waiting For Enemies")
		DO
			$LTARGET = GETNEARESTENEMYTOAGENT(-2)
			IF NOT ISDLLSTRUCT($LTARGET) THEN CONTINUELOOP
			$LDISTANCE = GETDISTANCE($LTARGET, -2)
			IF $LDISTANCE < $ADIST THEN FIGHT(1500)
		UNTIL TIMERDIFF($LDEADLOCK) > $ADEADLOCK
		RETURN FALSE
	 ENDFUNC

	FUNC FIGHT($ARANGE)
		LOCAL $NX, $NY, $RND, $RNDRANGE
		UPDATE($ARANGE)
		IF $MOVE THEN MOVE(DLLSTRUCTGETDATA(-2, "X"), DLLSTRUCTGETDATA(-2, "Y"), 250)
		$NDEADLOCK = TIMERINIT()
		DO
			IF GETISDEAD($MSELF) THEN EXITLOOP
			IF TIMERDIFF($NDEADLOCK) > 30000 THEN
				OUT("Obstructed")
				IF GETNUMBEROFFOESINRANGEOFAGENT(-2, 1600) = 1 THEN
					$MAGENT = GETNEARESTENEMYTOAGENT(-2)
				ELSE
					$MAGENT = GETAGENTBYNAME("Miku")
				ENDIF
				MOVETO(DLLSTRUCTGETDATA($MAGENT, "X"), DLLSTRUCTGETDATA($MAGENT, "Y"), 200)
				$NDEADLOCK = TIMERINIT() + 20000
			ENDIF

			UPDATE($ARANGE)

			IF $MOVE THEN
				OUT("Meteor Shower/Roj detected moving")
				$RND = RANDOM(1, 4, 1)
				SWITCH $RND
					CASE 1
						MOVE(DLLSTRUCTGETDATA(-2, "X") + 250, DLLSTRUCTGETDATA(-2, "Y"))
					CASE 2
						MOVE(DLLSTRUCTGETDATA(-2, "X") - 250, DLLSTRUCTGETDATA(-2, "Y"))
					CASE 3
						MOVE(DLLSTRUCTGETDATA(-2, "X"), DLLSTRUCTGETDATA(-2, "Y") + 250)
					CASE 4
						MOVE(DLLSTRUCTGETDATA(-2, "X"), DLLSTRUCTGETDATA(-2, "Y") - 250)
				ENDSWITCH
			ENDIF
			$NX = DLLSTRUCTGETDATA($MSELF, "X")
			$NY = DLLSTRUCTGETDATA($MSELF, "Y")
			IF NOT CHECKFORSPIRITS($NX, $NY) THEN RETURN FALSE
			CASTENGINE()

		UNTIL $MENEMIESRANGE[0] = 0
		IF TIMERDIFF($MSKILLTIMER) < $MCASTTIME THEN SLEEP($MCASTTIME - TIMERDIFF($MSKILLTIMER))
		SLEEP(RANDOM(500, 1000, 1))
		IF GETISDEAD($MSELF) THEN
			OUT("I'm dead")
			RETURN FALSE
		ENDIF
		PICKUPLOOT()
		RETURN TRUE
	ENDFUNC

	FUNC UPDATE($ARANGE)
		$MSELFID = GETMYID()
		$MSELF = GETAGENTBYID($MSELFID)
		$MENERGY = GETENERGY($MSELF)
		$MSKILLBAR = GETSKILLBAR()
		$MEFFECTS = GETEFFECT()
		IF NOT ISARRAY($MEFFECTS) THEN DIM $MEFFECTS[1] = [0]
		$MDAZED = FALSE
		$MBLIND = FALSE
		$MSKILLHARDCOUNTER = FALSE
		$MSKILLSOFTCOUNTER = 0
		$MATTACKHARDCOUNTER = FALSE
		$MATTACKSOFTCOUNTER = 0
		$MALLYSPELLHARDCOUNTER = FALSE
		$MENEMYSPELLHARDCOUNTER = FALSE
		$MSPELLSOFTCOUNTER = 0
		$MBLOCKING = FALSE
		$MOVE = FALSE

		FOR $I = 1 TO $MEFFECTS[0]
			SWITCH DLLSTRUCTGETDATA($MEFFECTS[$I], "SkillID")
				CASE 485
					$MDAZED = TRUE
				CASE 479
					$MBLIND = TRUE
				CASE 30, 764
					$MSKILLHARDCOUNTER = TRUE
				CASE 51, 127
					$MALLYSPELLHARDCOUNTER = TRUE
				CASE 46, 979, 3191
					$MENEMYSPELLHARDCOUNTER = TRUE
				CASE 878, 3234
					$MSKILLSOFTCOUNTER += 1
					$MSPELLSOFTCOUNTER += 1
					$MATTACKSOFTCOUNTER += 1
				CASE 28, 128
					$MSPELLSOFTCOUNTER += 1
				CASE 47, 43, 2056, 3195
					$MATTACKHARDCOUNTER = TRUE
				CASE 123, 26, 3151, 121, 103, 66
					$MATTACKSOFTCOUNTER += 1
				CASE 380, 810
					$MBLOCKING = TRUE
			ENDSWITCH
		NEXT
		LOCAL $LAGENT
		LOCAL $LTEAM = DLLSTRUCTGETDATA($MSELF, "Team")
		LOCAL $LHP
		LOCAL $LDISTANCE
		LOCAL $LMODEL
		DIM $MTEAM[1] = [0]
		DIM $MTEAMOTHERS[1] = [0]
		DIM $MTEAMDEAD[1] = [0]
		DIM $MENEMIES[1] = [0]
		DIM $MENEMIESRANGE[1] = [0]
		DIM $MENEMIESSPELLRANGE[1] = [0]
		DIM $MSPIRITS[1] = [0]
		DIM $MPETS[1] = [0]
		DIM $MMINIONS[1] = [0]
		$MLOWESTALLY = $MSELF
		$MLOWESTALLYHP = 1
		$MLOWESTOTHERALLY = 0
		$MLOWESTOTHERALLYHP = 2
		$MLOWESTENEMY = 0
		$MLOWESTENEMYHP = 2
		$MCLOSESTENEMY = 0
		$MCLOSESTENEMYDIST = 5000
		FOR $I = 1 TO GETMAXAGENTS()
			$LAGENT = GETAGENTBYID($I)
			IF DLLSTRUCTGETDATA($LAGENT, "Type") <> 219 THEN CONTINUELOOP
			$LHP = DLLSTRUCTGETDATA($LAGENT, "HP")
			$LDISTANCE = GETDISTANCE($LAGENT, $MSELF)
			SWITCH DLLSTRUCTGETDATA($LAGENT, "Allegiance")
				CASE 1
					IF NOT BITAND(DLLSTRUCTGETDATA($LAGENT, "Typemap"), 131072) THEN CONTINUELOOP
					IF NOT GETISDEAD($LAGENT) AND $LHP > 0 THEN
						$MTEAM[0] += 1
						REDIM $MTEAM[$MTEAM[0] + 1]
						$MTEAM[$MTEAM[0]] = $LAGENT
						IF $LHP < $MLOWESTALLYHP THEN
							$MLOWESTALLY = $LAGENT
							$MLOWESTALLYHP = $LHP
						ELSEIF $LHP = $MLOWESTALLYHP THEN
							IF $LDISTANCE < GETDISTANCE($MLOWESTALLY, $MSELF) THEN
								$MLOWESTALLY = $LAGENT
								$MLOWESTALLYHP = $LHP
							ENDIF
						ENDIF
						IF $I <> $MSELFID THEN
							$MTEAMOTHERS[0] += 1
							REDIM $MTEAMOTHERS[$MTEAMOTHERS[0] + 1]
							$MTEAMOTHERS[$MTEAMOTHERS[0]] = $LAGENT
							IF $LHP < $MLOWESTOTHERALLYHP THEN
								$MLOWESTOTHERALLY = $LAGENT
								$MLOWESTOTHERALLYHP = $LHP
							ELSEIF $LHP = $MLOWESTOTHERALLYHP THEN
								IF $LDISTANCE < GETDISTANCE($MLOWESTOTHERALLY, $MSELF) THEN
									$MLOWESTOTHERALLY = $LAGENT
									$MLOWESTOTHERALLYHP = $LHP
								ENDIF
							ENDIF
						ENDIF
					ELSE
						$MTEAMDEAD[0] += 1
						REDIM $MTEAMDEAD[$MTEAMDEAD[0] + 1]
						$MTEAMDEAD[$MTEAMDEAD[0]] = $LAGENT
					ENDIF
				CASE 3
					IF GETISDEAD($LAGENT) OR $LHP <= 0 THEN CONTINUELOOP
					IF BITAND(DLLSTRUCTGETDATA($LAGENT, "Typemap"), 262144) THEN
						$MSPIRITS[0] += 1
						REDIM $MSPIRITS[$MSPIRITS[0] + 1]
						$MSPIRITS[$MSPIRITS[0]] = $LAGENT
					ENDIF
					$LMODEL = DLLSTRUCTGETDATA($LAGENT, "PlayerNumber")
					$MENEMIES[0] += 1
					REDIM $MENEMIES[$MENEMIES[0] + 1]
					$MENEMIES[$MENEMIES[0]] = $LAGENT
					IF $LDISTANCE <= $ARANGE THEN
						$MENEMIESRANGE[0] += 1
						REDIM $MENEMIESRANGE[$MENEMIESRANGE[0] + 1]
						$MENEMIESRANGE[$MENEMIESRANGE[0]] = $LAGENT
						IF $LHP < $MLOWESTENEMYHP THEN
							$MLOWESTENEMY = $LAGENT
							$MLOWESTENEMYHP = $LHP
						ELSEIF $LHP = $MLOWESTENEMYHP THEN
							IF $LDISTANCE < GETDISTANCE($MLOWESTENEMY, $MSELF) THEN
								$MLOWESTENEMY = $LAGENT
								$MLOWESTENEMYHP = $LHP
							ENDIF
						ENDIF
						IF $LDISTANCE < $MCLOSESTENEMYDIST THEN
							$MCLOSESTENEMYDIST = $LDISTANCE
							$MCLOSESTENEMY = $LAGENT
						ENDIF
					ENDIF
					IF $LDISTANCE <= 1240 THEN
						$MENEMIESSPELLRANGE[0] += 1
						REDIM $MENEMIESSPELLRANGE[$MENEMIESSPELLRANGE[0] + 1]
						$MENEMIESSPELLRANGE[$MENEMIESSPELLRANGE[0]] = $LAGENT
						IF GETISCASTING($LAGENT) THEN
							SWITCH DLLSTRUCTGETDATA($LAGENT, "Skill")
								CASE 830, 192, 1083, 1372, 1380
									$MOVE = TRUE
							ENDSWITCH
						ENDIF
					ENDIF
				CASE 4
					IF GETISDEAD($LAGENT) OR $LHP <= 0 THEN CONTINUELOOP
					IF BITAND(DLLSTRUCTGETDATA($LAGENT, "Typemap"), 262144) THEN
						$MSPIRITS[0] += 1
						REDIM $MSPIRITS[$MSPIRITS[0] + 1]
						$MSPIRITS[$MSPIRITS[0]] = $LAGENT
						OUT("spirits: " & $MSPIRITS[0])
					ELSE
						$MPETS[0] += 1
						REDIM $MPETS[$MPETS[0] + 1]
						$MPETS[$MPETS[0]] = $LAGENT
					ENDIF
				CASE 5
					IF NOT BITAND(DLLSTRUCTGETDATA($LAGENT, "Typemap"), 131072) THEN CONTINUELOOP
					IF GETISDEAD($LAGENT) OR $LHP <= 0 THEN CONTINUELOOP
					$MMINIONS[0] += 1
					REDIM $MMINIONS[$MMINIONS[0] + 1]
					$MMINIONS[$MMINIONS[0]] = $LAGENT
				CASE ELSE
			ENDSWITCH
		NEXT
	ENDFUNC

	FUNC AGGROMOVETOEX($X, $Y, $S = "", $Z = 1250)
		LOCAL $LBLOCKED = 0
		LOCAL $LME, $LXME, $LYME, $LOLDXME, $LOLDYME
		LOCAL $LNEARESTENEMY, $LDISTANCE
		IF $S <> "" THEN OUT($S)
		BUILDMAINTENANCE()
		MOVE($X, $Y)
		$LME = GETAGENTBYID(-2)
		$LXME = DLLSTRUCTGETDATA($LME, "X")
		$LYME = DLLSTRUCTGETDATA($LME, "Y")
		DO
			RNDSLEEP(250)
			$LOLDXME = $LXME
			$LOLDYME = $LYME
			$LNEARESTENEMY = GETNEARESTENEMYTOAGENT(-2)
			$LDISTANCE = GETDISTANCE($LNEARESTENEMY, -2)
			IF $LDISTANCE < $Z AND DLLSTRUCTGETDATA($LNEARESTENEMY, "ID") <> 0 THEN
				;CHANGEWEAPONSET(1)    ;This should already be weapon set-1 , no need to call.
				IF FIGHT($Z) = FALSE THEN
					OUT("What ! I'm a noob sorry")
					RETURN FALSE
				ENDIF
				;CHANGEWEAPONSET(4)   ; I dont understand why a 4th Weapon Set?
			ENDIF
			RNDSLEEP(250)
			$LME = GETAGENTBYID(-2)
			$LXME = DLLSTRUCTGETDATA($LME, "X")
			$LYME = DLLSTRUCTGETDATA($LME, "Y")
			IF $LOLDXME = $LXME AND $LOLDYME = $LYME THEN
				$LBLOCKED += 1
				MOVE($LXME, $LYME, 500)
				RNDSLEEP(350)
				MOVE($X, $Y)
				IF GETMAPLOADING() == 2 THEN DISCONNECTED()
			ENDIF
			IF GETISDEAD(-2) THEN
				RETURN FALSE
			ENDIF
		UNTIL COMPUTEDISTANCE($LXME, $LYME, $X, $Y) < 250 OR $LBLOCKED > 20
		IF GETISDEAD(-2) THEN
			RETURN FALSE
		ENDIF
		RETURN TRUE
	ENDFUNC

	FUNC PICKUPLOOT()
		LOCAL $LME
		LOCAL $LBLOCKEDTIMER
		LOCAL $LBLOCKEDCOUNT = 0
		LOCAL $LITEMEXISTS = TRUE
		FOR $I = 1 TO GETMAXAGENTS()
			$LME = GETAGENTBYID(-2)
			IF DLLSTRUCTGETDATA($LME, "HP") <= 0 THEN RETURN -1
			$LAGENT = GETAGENTBYID($I)
			IF NOT GETISMOVABLE($LAGENT) THEN CONTINUELOOP
			IF NOT GETCANPICKUP($LAGENT) THEN CONTINUELOOP
			$LITEM = GETITEMBYAGENTID($I)
			IF CANPICKUP($LITEM) THEN
				DO
					PICKUPITEM($LITEM)
					SLEEP(GETPING())
					DO
						SLEEP(100)
						$LME = GETAGENTBYID(-2)
					UNTIL DLLSTRUCTGETDATA($LME, "MoveX") == 0 AND DLLSTRUCTGETDATA($LME, "MoveY") == 0
					$LBLOCKEDTIMER = TIMERINIT()
					DO
						SLEEP(3)
						$LITEMEXISTS = ISDLLSTRUCT(GETAGENTBYID($I))
					UNTIL NOT $LITEMEXISTS OR TIMERDIFF($LBLOCKEDTIMER) > RANDOM(5000, 7500, 1)
					IF $LITEMEXISTS THEN $LBLOCKEDCOUNT += 1
				UNTIL NOT $LITEMEXISTS OR $LBLOCKEDCOUNT > 5
			ENDIF
		NEXT
	ENDFUNC

	FUNC CANPICKUP($AITEM)
		LOCAL $M = DLLSTRUCTGETDATA($AITEM, "ModelId")
		Local $Q = DllStructGetData($aItem, 'Quantity')
		LOCAL $R = GETRARITY($AITEM)
		LOCAL $REQUIREMENT = GETITEMREQ($AITEM)

		SWITCH $M
			CASE 910, 2513, 5585, 6366, 6375, 22190, 24593, 28435, 30855, 31145, 36682, 21492, 21812, 22269, 22644, 22752, 28436, 36681, 6376, 21809, 21810, 21813, 36683, 6370, 21488, 21489, 22191, 26784, 28433, 15837, 21490, 30648, 31020, 556, 18345, 21491, 37765, 21833, 28433, 28434, 921, 922, 923, 925, 926, 927, 928, 931, 932, 933, 934, 935, 936, 937, 938, 939, 940, 941, 942, 943, 944, 945, 946, 948, 949, 950, 951, 952, 953, 954, 955, 956, 6532, 6533
				RETURN TRUE

			Case 2511 ; Gold Coins
			Out("Picking up gold coins")
			$GoldsCoins += $Q
			GUICtrlSetData($STEARNEDCASH,$GoldsCoins)
			Return True

			CASE 146
				SWITCH DLLSTRUCTGETDATA($AITEM, "ExtraId")
					CASE 10, 12 ;Black & White Dye
						RETURN TRUE
				ENDSWITCH
			CASE 474, 476, 5882
				RETURN TRUE
			CASE 460, 461, 35123
				RETURN TRUE
		ENDSWITCH

		SWITCH $R
			CASE 2624 ;Gold Items
			Out("Gold Item Dropped!")
			$GoldsCount = $GoldsCount + 1
			GUICtrlSetData($GOLD_ITEMS_CNT,$GoldsCount)
			IF GUICTRLREAD($CBPICKGOLDS) THEN RETURN TRUE
		ENDSWITCH


		RETURN FALSE
	ENDFUNC


	FUNC INITGUI()
		Vanguard_Rank()
		GUICTRLSETDATA($STRUNS, $SUCCESSRUNS)
		GUICTRLSETDATA($STFAILRUNS, $FAILRUNS)
		GUICTRLSETDATA($STEARNEDCASH, $CASHMADE)
		GUICTRLSETDATA($STCHESTGOLD, GETGOLDSTORAGE())
		GUICTRLSETDATA($STVANGUARD, GetVanguardTitle())
		GUICTRLSETDATA($STWARSUP,    GETNUMBERWARSUPINV()) ;Count in pack
		GUICTRLSETDATA($WARSUPPLIES, GET_TOTAL_NUMBER_WAR_SUP_INV());Total count including chest
	ENDFUNC

	FUNC UPDATEGUI()
		GUICTRLSETDATA($STWARSUP,    GETNUMBERWARSUPINV()) ;Count in pack
		GUICTRLSETDATA($WARSUPPLIES, GET_TOTAL_NUMBER_WAR_SUP_INV());Total count including chest
		GUICTRLSETDATA($STVANGUARD, GetVanguardTitle())
		GUICTRLSETDATA($STRUNS, $SUCCESSRUNS)
		GUICTRLSETDATA($STFAILRUNS, $FAILRUNS)
		Vanguard_Rank()
	ENDFUNC

	FUNC OUT($ASTRING) ;no timestamp
		LOCAL $TIMESTAMP = ""
		GUICTRLSETDATA($LBLSTATUS, $TIMESTAMP & $ASTRING)
		LOGFILE($TIMESTAMP & $ASTRING)
	ENDFUNC

	FUNC OUT_2($ASTRING) ;Original with timestamp
		LOCAL $TIMESTAMP = "[" & @HOUR & ":" & @MIN & "] "
		GUICTRLSETDATA($LBLSTATUS, $TIMESTAMP & $ASTRING)
		LOGFILE($TIMESTAMP & $ASTRING)
	ENDFUNC

	FUNC LOGFILE($STRING)
		$FILE = FILEOPEN("log - " & GUICTRLREAD($INPUTCHARNAME) & ".txt", 1)
		FILEWRITE($FILE, $STRING & @CRLF)
		FILECLOSE($FILE)
	ENDFUNC

	FUNC Vanguard_Rank()
	Local $VanguardTitle = GetVanguardTitle()
	If $VanguardTitle  > 1000 AND $VanguardTitle  < 4000 Then
		GUICTRLSETDATA($Label_Vanguard_Title, "Agent")
		GUICTRLSETDATA($LBLVAN_RANK, "R-1")
	EndIf
	If $VanguardTitle  > 4000 AND $VanguardTitle  < 8000 Then
		GUICTRLSETDATA($Label_Vanguard_Title, "Covert Agent")
		GUICTRLSETDATA($LBLVAN_RANK, "R-2")
	EndIf
	IF $VanguardTitle  > 8000 AND $VanguardTitle  < 16000 Then
		GUICTRLSETDATA($Label_Vanguard_Title, "Stealth Agent")
		GUICTRLSETDATA($LBLVAN_RANK, "R-3")
	EndIf
	If $VanguardTitle  > 16000 AND $VanguardTitle  < 26000 Then
		GUICTRLSETDATA($Label_Vanguard_Title, "Mysterious Agent")
		GUICTRLSETDATA($LBLVAN_RANK, "R-4")
	EndIf
	If $VanguardTitle  > 26000 AND $VanguardTitle  < 40000 Then
		GUICTRLSETDATA($Label_Vanguard_Title, "Shadow Agent")
		GUICTRLSETDATA($LBLVAN_RANK, "R-5")
	EndIf
	If $VanguardTitle  > 40000 AND $VanguardTitle  < 56000 THen
		GUICTRLSETDATA($Label_Vanguard_Title, "Underground Agent")
		GUICTRLSETDATA($LBLVAN_RANK, "R-6")
	EndIf
	If $VanguardTitle  > 56000 AND $VanguardTitle  < 80000 Then
		GUICTRLSETDATA($Label_Vanguard_Title, "Special Agent")
		GUICTRLSETDATA($LBLVAN_RANK, "R-7")
	EndIf
	If $VanguardTitle  > 80000 AND $VanguardTitle  < 110000 Then
		GUICTRLSETDATA($Label_Vanguard_Title, "Valued Agent")
		GUICTRLSETDATA($LBLVAN_RANK, "R-8")
	EndIf
	If $VanguardTitle  > 110000 AND $VanguardTitle  < 160000 Then
		GUICTRLSETDATA($Label_Vanguard_Title, "Superior Agent")
		GUICTRLSETDATA($LBLVAN_RANK, "R-9")
	EndIf
	If $VanguardTitle  > 160000 Then
		GUICTRLSETDATA($Label_Vanguard_Title, "Secret Agent")
		GUICTRLSETDATA($LBLVAN_RANK, "R-10")
	EndIf
EndFunc
#endregion Functions


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
	GUICtrlSetData($Run_Time, $L_Hour & ":" & $L_Min & ":" & $L_Sec)
EndFunc

Func PurgeHook()
	ToggleRendering()
	Sleep(GetPing()+3500)
	;ToggleRendering()
	Sleep(GetPing()+1000)
	ClearMemory()
 EndFunc   ;==>_PurgeHook

Func GetChecked($GUICtrl)
	Return (GUICtrlRead($GUICtrl)==$GUI_Checked)
EndFunc

Func CanStoreRunes($aitem) ;Can also be changed to sell these runes.
	Local $m = DllStructGetData($aitem, "ModelID")
	Local $t = DllStructGetData($aitem, "Type")
	Local $q = DllStructGetData($aitem, "Quantity")
	Local $r = GetRarity($aitem)
	Local $ModStruct = GetModStruct($aitem)
	Local $MinorVigor = StringInStr($ModStruct, "C202E827", 0, 1)
	Local $MajorVigor = StringInStr($ModStruct, "C202E927", 0, 1)
	Local $SupVigor = StringInStr($ModStruct, "C202EA27", 0, 1)
	Local $Vitae = StringInStr($ModStruct, "000A4823", 0, 1)
;	Local $Attunement = StringInStr($ModStruct, "0200D822", 0, 1)
	Local $Survivor = StringInStr($ModStruct, "0005D826", 0, 1)
	Local $Blessed = StringInStr($ModStruct, "E9010824", 0, 1)
	Local $Sentinel = StringInStr($ModStruct, "FB010824", 0, 1)
	Local $MinorScythe = StringInStr($ModStruct, "0129E821", 0, 1)
	Local $MinorDivine = StringInStr($ModStruct, "0110E821", 0, 1)
	Local $MinorDeath = StringInStr($ModStruct, "0105E821", 0, 1)
	Local $SupDeath = StringInStr($ModStruct, "0305E8217901", 0, 1)
	Local $MinorSoulReaping = StringInStr($ModStruct, "0106E821", 0, 1)
	Local $MinorFastCasting = StringInStr($ModStruct, "0100E821", 0, 1)
	Local $MinorInspiration = StringInStr($ModStruct, "0103E821", 0, 1)
	Local $MinorEnergyStorage = StringInStr($ModStruct, "010CE821", 0, 1)
	Local $MinorSpawning = StringInStr($ModStruct, "0124E821", 0, 1)
	Local $WindWalker = StringInStr($ModStruct, "02020824", 0, 1)
	Local $Shaman = StringInStr($ModStruct, "04020824", 0, 1)
	Local $Centurion = StringInStr($ModStruct, "07020824", 0, 1)
	Switch $r
		Case $Rarity_Gold, $Rarity_Purple, $Rarity_Blue
			If ($SupVigor > 0) Or ($MajorVigor > 0) Or ($MinorVigor > 0) Then ; Health Runes
				Return True
;			ElseIf ($SupDeath > 0) Or ($MinorSoulReaping > 0) Then ; Necro Runes
;				Return True
			ElseIf ($SupDeath > 0) Then ; Necro Runes
				Return True
;			ElseIf ($Survivor > 0) Or ($Sentinel > 0) Or ($WindWalker > 0) Or ($Shaman > 0) Or ($Centurion > 0) Then ; Insignias
;				Return True
			ElseIf ($WindWalker > 0) Or ($Shaman > 0) Then ; Insignias
				Return True
;			ElseIf ($MinorScythe > 0) Or ($MinorDivine > 0) Or ($MinorFastCasting > 0) Or ($MinorInspiration > 0) Or ($MinorEnergyStorage > 0) Or ($MinorSpawning > 0) Then
;				Return True
			ElseIf ($MinorScythe > 0) Or ($MinorFastCasting > 0) Or ($MinorSpawning > 0) Or ($MinorSoulReaping > 0) Then
				Return True
			Else
				Return False
			EndIf
		Case Else ; $Rarity_White
			Return False
	Endswitch
 EndFunc
#EndRegion Store

 Func UseBunnies()
	Local $aBag
	Local $aItem
	Out("Using Bunnies")
	Sleep(200)
	For $i = 1 To 4
	$aBag = GetBag($i)
	For $j = 1 To DllStructGetData($aBag, "Slots")
	$aItem = GetItemBySlot($aBag, $j)
	If DllStructGetData($aItem, "ModelID") == 22644 Then ;CHOCOLATE BUNNY
		UseItem($aItem)
		Return
		Else
		ContinueLoop
	EndIf
Next
Next
EndFunc

Func UseBlueSugar()
	Local $aBag
	Local $aItem
	Out("Using B. Sugary Drink")
	Sleep(200)
	For $i = 1 To 4
	$aBag = GetBag($i)
	For $j = 1 To DllStructGetData($aBag, "Slots")
	$aItem = GetItemBySlot($aBag, $j)
	If DllStructGetData($aItem, "ModelID") == 21812 Then ;BLUE SUGARY DRINK
		UseItem($aItem)
		Return
		Else
		ContinueLoop
	EndIf
Next
Next
EndFunc

Func UseWarSupply()
	Local $aBag
	Local $aItem
	Local $WarSupplies = TimerInit()
	Out("Using War Supplies")
	;Sendchat("Using War Supplies")
	Sleep(200)
	For $i = 1 To 4
	$aBag = GetBag($i)
	For $j = 1 To DllStructGetData($aBag, "Slots")
	$aItem = GetItemBySlot($aBag, $j)
	If DllStructGetData($aItem, "ModelID") == 35121 Then
		UseItem($aItem)
		Return
		Else
		ContinueLoop
	EndIf
Next
Next
EndFunc
