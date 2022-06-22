#include <gwAPI.au3>

Global $UseAlcohol = True
Global $UseSweets = False
Global $UseParty = False
; if this is true, materials will be stored in storage (8 to 16)
; and any materials stored there will be used to craft cons !!
$mStoreMaterials = True

#Region GUI
TraySetIcon('conset.ico')
; left side
Global $Form = GUICreate("Dervish Conset Farmer", 350, 300, @DesktopWidth-360, 5)
GUISetIcon('conset.ico')
GUISetBkColor(0xF0F0F0, $Form)
Global $cbName = GUICtrlCreateCombo("", 10, 10, 140, 25)
GUICtrlSetData($cbName, GetLoggedCharnames())
Global $cbBuyMat = GUICtrlCreateCombo("Lockpick", 10, 40, 140, 25)
GUICtrlSetData($cbBuyMat, "Glob of Ectoplasm|Rubies|Sapphires|Diamonds|Onyx Gemstones|Obsidian Shard|Amber Chunk|Jadeite Shard|Deldrimor Steel Ingot|Monstrous Claws|Monstrous Eye|Monstrous Fangs|Lockpick")
Global $boxAlcohol = GUICtrlCreateCheckbox("Use Alcohol", 10, 70, 120, 20)
If $UseAlcohol Then GUICtrlSetState($boxAlcohol, 1)
Global $boxSweets = GUICtrlCreateCheckbox("Use Sweets", 10, 95, 120, 20)
If $UseSweets Then GUICtrlSetState($boxSweets, 1)
Global $boxParty = GUICtrlCreateCheckbox("Use Party", 10, 120, 120, 20)
If $UseParty Then GUICtrlSetState($boxParty, 1)
Global $boxStorage = GUICtrlCreateCheckbox("Store Conset Materials", 10, 145, 130, 20)
If $mStoreMaterials Then GUICtrlSetState($boxStorage, 1)
Global $btStart = GUICtrlCreateButton("Start", 10, 170, 140, 25)
Global $btPause = GUICtrlCreateButton("Pause", 10, 200, 140, 25)
Global $labelUpdateTime = GUICtrlCreateLabel("[00:00:00]",10, 235, 50, 20)
Global $labelUpdateText = GUICtrlCreateLabel("Bot not running.",10, 255, 150, 40)
; right side
Global $picBanner = GUICtrlCreatePic("images\conset.jpg", 260, 10, 64, 64)
Global $picCurrent = GUICTrlCreatePic("", 260, 195, 64, 64)
Global $labelTitle = GUICtrlCreateLabel("Conset Farmer" & @CRLF & @CRLF & "Dervish", 175, 10, 110, 70, 0x01)
GUICtrlSetBkColor($labelTitle, -2) ; $GUI_BKCOLOR_TRANSPARENT
GUICtrlSetFont($labelTitle, 10, 300, 0, "Verdana")
Global $labelConset = GUICtrlCreateLabel("Consets: ",170, 90, 80, 20)
Global $labelConsetCounter = GUICtrlCreateLabel("0", 250, 90, 20, 20)
GUICtrlSetBkColor($labelConsetCounter, -2) ; $GUI_BKCOLOR_TRANSPARENT
Global $labelIron = GUICtrlCreateLabel("Iron: ",170, 115, 80, 20)
Global $labelIronCounter = GUICtrlCreateLabel("0", 250, 115, 90, 20)
Global $labelDust = GUICtrlCreateLabel("Dust: ",170, 140, 80, 20)
Global $labelDustCounter = GUICtrlCreateLabel("0", 250, 140, 90, 20)
Global $labelBones = GUICtrlCreateLabel("Bones: ",170, 165, 80, 20)
Global $labelBonesCounter = GUICtrlCreateLabel("0", 250, 165, 90, 20)
Global $labelFeather = GUICtrlCreateLabel("Feather: ",170, 190, 80, 20)
Global $labelFeatherCounter = GUICtrlCreateLabel("0", 250, 190, 90, 20)
GUICtrlSetBkColor($labelFeatherCounter, -2) ; $GUI_BKCOLOR_TRANSPARENT
Global $boxRendering = GUICtrlCreateCheckbox("Disable Rendering", 220, 270, 120, 20)

Opt("GUIOnEventMode", 1)
GUICtrlSetState($boxRendering, 128)
GUICtrlSetOnEvent($boxAlcohol, "TitleHandler")
GUICtrlSetOnEvent($boxSweets, "TitleHandler")
GUICtrlSetOnEvent($boxParty, "TitleHandler")
GUICtrlSetOnEvent($boxStorage, "ToggleStoreMats")
GUICtrlSetOnEvent($boxRendering, "_ToggleRendering")
GUICtrlSetOnEvent($cbBuyMat, "_selectmat")
GUICtrlSetOnEvent($btStart, "_start")
GUICtrlSetOnEvent($btPause, "_pause")
GUISetOnEvent(-3, "_exit")

Opt("TrayAutoPause",0)
Opt("TrayMenuMode",3)
Opt("TrayOnEventMode",1)

Global $trayCurrent = TrayCreateItem("Bot not started")
TrayItemSetState($trayCurrent, 128)
TrayCreateItem("")
Global $trayRender = TrayCreateItem("Disable Rendering")
TrayItemSetState($trayRender, 128)
Global $trayGUI = TrayCreateItem("Hide GUI")
TrayCreateItem("")
Global $trayCloseBot = TrayCreateItem("Close Bot")
Global $trayCloseBotGW = TrayCreateItem("Close Bot and GW")
TrayItemSetOnEvent($trayCurrent,"_pause")
TrayItemSetOnEvent($trayRender,"_ToggleRendering")
TrayItemSetOnEvent($trayGUI,"ToggleGUI")
TrayItemSetOnEvent($trayCloseBot,"_exit")
TrayItemSetOnEvent($trayCloseBotGW,"CloseBotAndGW")

GUISetState(@SW_SHOW)

#Region Variables
Global $BotRunning = False
Global $BotPause = False
Global $BotInjected = False
Global $CurrentFarm = ''
#EndRegion
#EndRegion

#Region Global Variables
Global $OutText = ''
Global $Me
Global $Skillbar
Global $Skillqueue
Global $Cinematic = False
;~ Conset Variables
Global $ConsetsPerLoop = 5
Global $ConsetCounter = 0
Global $StartCount = 0
Global $BoolRandomize = True ; randomize first round
Global $Feather = 50
Global $Iron = 100
Global $Bone = 50
Global $Dust = 100
Global $CurrentFeather = 0
Global $CurrentIron = 0
Global $CurrentBone = 0
Global $CurrentDust = 0
Global $NeededFeather = 0
Global $NeededIron = 0
Global $NeededBone = 0
Global $NeededDust = 0
;~ Counter Variables
Global $WaypointCounter
Global $TenguGroupCounter
Global $RunCounter
; Kilroy
Global Const $savsuds_Is_Cool = True
Global $pconsPumpkinPie_slot[2]
Global $usePumpkin = True ; set it on true and he use it
Global $boolOpenLocked = False
Global $DeldrimorRank5 = False
Global $giveup = False
Global $HardMode = False
Global $ChestOpened = False
Global $tLastTarget
Global $tSwitchtarget
Global $tRun
Global $enemy = 0
Global $kilroy
#EndRegion

$NeededFeather = $Feather * $ConsetsPerLoop
$NeededIron = $Iron * $ConsetsPerLoop
$NeededBone = $Bone * $ConsetsPerLoop
$NeededDust = $Dust * $ConsetsPerLoop
$NeededSkillpoints = $ConsetsPerLoop * 3
UpdateRareMat()
While 1
   Main()
WEnd

Func Main()
   While $BotRunning
	  If Not $BotInjected Then
		 $BotInjected = True
		 $lCharname = GUICtrlRead($cbName)
		 If $lCharname = '' Then
			If Not Initialize(ProcessExists("gw.exe")) Then
			   ConsoleWrite("Initialize failed. Exiting." & @CRLF)
			   _exit()
			EndIf
		 Else
			If Not Initialize($lCharname) Then
			   ConsoleWrite("Initialize failed. Exiting." & @CRLF)
			   _exit()
			EndIf
		 EndIf
		 GUICtrlSetState($btStart, 64)
		 GUICtrlSetState($boxRendering, 64)
		 TrayItemSetState($trayRender, 64)
		 TrayItemSetState($trayCurrent, 64)
		 $StartCount = CountConsets()
		 $mRendering = Not MemoryRead($mDisableRendering)
		 If Not $mRendering Then GUICtrlSetState($boxRendering, 1)
	  EndIf
	  BotLoop()
   WEnd
EndFunc

Func BotLoop()
   If Not CheckClient() Then _exit()
   If CountSlots() <= 0 Then _exit()
   UpdateStatsMats()
   Sleep(1000)
   While GetSkillpoints() < $NeededSkillpoints
	  ConsoleWrite("[" & @HOUR & ":" & @MIN & ":" & @SEC & "] Need skillpoints!" & @CRLF)
	  KilroyFarm()
   WEnd
   ConsoleWrite("[" & @HOUR & ":" & @MIN & ":" & @SEC & "] Enough skillpoints." & @CRLF)
   If CheckMats($ConsetsPerLoop) Then
	  Inventory()
	  Sleep(1000)
	  $ConsetCounterOld = $ConsetCounter
	  $ConsetCounter = GoCrafter($ConsetsPerLoop)
	  If $ConsetCounter <> $ConsetCounterOld Then UpdateStatsMats()
   EndIf
   GUICtrlSetData($labelConsetCounter, CountConsets() - $StartCount)
   If $BoolRandomize Then
	  Switch Random(1, 4, 1)
		 Case 1
			If $NeededFeather > $CurrentFeather Then JayaFarm()
			If $NeededBone > $CurrentBone Then GoKFarm()
			If $NeededIron > $CurrentIron Then KilroyFarm()
			If $NeededDust > $CurrentDust Then Curtain()
		 Case 2
			If $NeededBone > $CurrentBone Then GoKFarm()
			If $NeededIron > $CurrentIron Then KilroyFarm()
			If $NeededDust > $CurrentDust Then Curtain()
			If $NeededFeather > $CurrentFeather Then JayaFarm()
		 Case 3
			If $NeededIron > $CurrentIron Then KilroyFarm()
			If $NeededFeather > $CurrentFeather Then JayaFarm()
			If $NeededDust > $CurrentDust Then Curtain()
			If $NeededBone > $CurrentBone Then GoKFarm()
		 Case 4
			If $NeededDust > $CurrentDust Then Curtain()
			If $NeededIron > $CurrentIron Then KilroyFarm()
			If $NeededBone > $CurrentBone Then GoKFarm()
			If $NeededFeather > $CurrentFeather Then JayaFarm()
	  EndSwitch
   Else
	  If $NeededFeather > $CurrentFeather Then JayaFarm()
	  If $NeededBone > $CurrentBone Then GoKFarm()
	  If $NeededIron > $CurrentIron Then KilroyFarm()
	  If $NeededDust > $CurrentDust Then Curtain()
   EndIf
EndFunc

#Region GUI Functions
Func _start()
   If Not $BotRunning Then
	  GUICtrlSetData($btStart, 'Stop after run')
	  GUICtrlSetState($btStart, 128)
	  $BotRunning = True
   Else
	  GUICtrlSetData($btStart, 'ReStart')
	  GUICtrlSetState($btStart, 128)
	  $BotRunning = False
   EndIf
EndFunc

Func _pause()
   If Not $BotPause Then
	  GUICtrlSetData($btPause, 'Pause after run')
	  GUICtrlSetState($btPause, 128)
	  TrayItemSetText($trayCurrent, 'Pause: ' & $CurrentFarm)
	  TrayItemSetState($trayCurrent, 128)
	  $BotPause = True
   Else
	  GUICtrlSetData($btPause, 'Resume')
	  GUICtrlSetState($btPause, 128)
	  TrayItemSetText($trayCurrent, 'Resume: ' & $CurrentFarm)
	  TrayItemSetState($trayCurrent, 128)
	  $BotPause = False
   EndIf
EndFunc

Func UpdateRareMat()
   Switch GUICtrlRead($cbBuyMat)
	  Case 'Glob of Ectoplasm'
		 $mMatExchangeGold = 930
	  Case 'Rubies'
		 $mMatExchangeGold = 936
	  Case 'Sapphires'
		 $mMatExchangeGold = 938
	  Case 'Diamonds'
		 $mMatExchangeGold = 935
	  Case 'Onyx Gemstones'
		 $mMatExchangeGold = 936
	  Case 'Obsidian Shard'
		 $mMatExchangeGold = 945
	  Case 'Amber Chunk'
		 $mMatExchangeGold = 6532
	  Case 'Jadeite Shard'
		 $mMatExchangeGold = 6533
	  Case 'Deldrimor Steel Ingot'
		 $mMatExchangeGold = 950
	  Case 'Monstrous Claws'
		 $mMatExchangeGold = 923
	  Case 'Monstrous Eye'
		 $mMatExchangeGold = 931
	  Case 'Monstrous Fangs'
		 $mMatExchangeGold = 932
	  Case 'Lockpick'
		 $mMatExchangeGold = 0
   EndSwitch
EndFunc

Func _selectmat()
   Switch _GUICtrlComboBox_GetCurSel($cbBuyMat)
	  Case 1 ; Glob of Ectoplasm
		 $mMatExchangeGold = 930
	  Case 2 ; Rubies
		 $mMatExchangeGold = 936
	  Case 3 ; Sapphires
		 $mMatExchangeGold = 938
	  Case 4 ; Diamonds
		 $mMatExchangeGold = 935
	  Case 5 ; Onyx Gemstones
		 $mMatExchangeGold = 936
	  Case 6 ; Obsidian Shard
		 $mMatExchangeGold = 945
	  Case 7 ; Amber Chunk
		 $mMatExchangeGold = 6532
	  Case 8 ; Jadeite Shard
		 $mMatExchangeGold = 6533
	  Case 9 ; Deldrimor Steel Ingot
		 $mMatExchangeGold = 950
	  Case 10 ; Monstrous Claws
		 $mMatExchangeGold = 923
	  Case 11 ; Monstrous Eye
		 $mMatExchangeGold = 931
	  Case 12 ; Monstrous Fangs
		 $mMatExchangeGold = 932
	  Case 13 ; Lockpick
		 $mMatExchangeGold = 0
   EndSwitch
   Out("Selected: " & $mMatExchangeGold)
EndFunc

Func _exit()
   If $BotInjected Then RestoreDetour()
   If Not $mRendering Then EnableRendering()
   Exit
EndFunc

Func UpdateStatsMats()
   UpdateMats()
   GUICtrlSetData($labelIronCounter, $CurrentIron & " of " & $NeededIron)
   GUICtrlSetData($labelDustCounter, $CurrentDust & " of " & $NeededDust)
   GUICtrlSetData($labelBonesCounter, $CurrentBone & " of " & $NeededBone)
   GUICtrlSetData($labelFeatherCounter, $CurrentFeather & " of " & $NeededFeather)
EndFunc

Func CheckClient()
   If Not GetAgentExists(-2) And Not $mRendering Then
	  EnableRendering()
	  If WinExists($mGWHwnd) Then
		 $lSleep = 1000
		 For $i = 1 To 10
			Sleep(8000 + $i*1000)
			ControlSend($mGWHwnd, "", "", "{Enter}")
			If GetAgentExists(-2) Then Return True
		 Next
	  EndIf
	  Return False
   ElseIf Not GetAgentExists(-2) And WinExists($mGWHwnd) Then
	  $lSleep = 1000
	  For $i = 1 To 10
		 Sleep(7000 + $i*1000)
		 ControlSend($mGWHwnd, "", "", "{Enter}")
		 If GetAgentExists(-2) Then Return True
	  Next
	  Return False
   Else
	  Return True
   EndIf
EndFunc

Func CountConsets()
   Local $lGrail = 0
   Local $lBU = 0
   Local $lArmor = 0
   For $bag = 1 To 4 ; inventory only
	  $lBagPtr = GetBagPtr($bag)
	  If $lBagPtr = 0 Then ContinueLoop ; empty bag slot
	  $lItemArrayPtr = MemoryRead($lBagPtr + 24, 'ptr')
	  For $slot = 0 To MemoryRead($lBagPtr + 32, 'long') - 1
		 $lItemPtr = MemoryRead($lItemArrayPtr + 4 * ($slot), 'ptr')
		 If $lItemPtr = 0 Then ContinueLoop ; empty slot
		 $lItemMID = MemoryRead($lItemPtr + 44, 'long')
		 Switch $lItemMID
			Case 24859
			   $lBU += MemoryRead($lItemPtr + 75, 'byte')
			Case 24860
			   $lArmor += MemoryRead($lItemPtr + 75, 'byte')
			Case 24861
			   $lGrail += MemoryRead($lItemPtr + 75, 'byte')
		 EndSwitch
	  Next
   Next
   If $lBU >= $lArmor And $lBU >= $lGrail Then
	  Return $lBU
   ElseIf $lArmor >= $lGrail Then
	  Return $lArmor
   Else
	  Return $lGrail
   EndIf
EndFunc

Func UpdateMats()
   $CurrentBone = 0
   $CurrentDust = 0
   $CurrentFeather = 0
   $CurrentIron = 0
   For $bag = 1 To 4
	  Local $lBagPtr = GetBagPtr($bag)
	  If $lBagPtr = 0 Then ContinueLoop
	  Local $lItemArrayPtr = MemoryRead($lBagPtr + 24, 'ptr')
	  For $slot = 0 To MemoryRead($lBagPtr + 32, 'long') - 1
		 Local $lItemPtr = MemoryRead($lItemArrayPtr + 4 * ($slot), 'ptr')
		 If $lItemPtr = 0 Then ContinueLoop
		 $lItemMID = MemoryRead($lItemPtr + 44, 'long')
		 Switch $lItemMID
			Case 921
			   $CurrentBone += MemoryRead($lItemPtr + 75, 'byte')
			Case 929
			   $CurrentDust += MemoryRead($lItemPtr + 75, 'byte')
			Case 933
			   $CurrentFeather += MemoryRead($lItemPtr + 75, 'byte')
			Case 948
			   $CurrentIron += MemoryRead($lItemPtr + 75, 'byte')
		 EndSwitch
	  Next
   Next
   If $mStoreMaterials Then
	  For $bag = 8 To 16
		 Local $lBagPtr = GetBagPtr($bag)
		 If $lBagPtr = 0 Then ContinueLoop
		 Local $lItemArrayPtr = MemoryRead($lBagPtr + 24, 'ptr')
		 For $slot = 0 To 19
			Local $lItemPtr = MemoryRead($lItemArrayPtr + 4 * ($slot), 'ptr')
			If $lItemPtr = 0 Then ContinueLoop
			$lItemMID = MemoryRead($lItemPtr + 44, 'long')
			Switch $lItemMID
			   Case 921
				  $CurrentBone += MemoryRead($lItemPtr + 75, 'byte')
			   Case 929
				  $CurrentDust += MemoryRead($lItemPtr + 75, 'byte')
			   Case 933
				  $CurrentFeather += MemoryRead($lItemPtr + 75, 'byte')
			   Case 948
				  $CurrentIron += MemoryRead($lItemPtr + 75, 'byte')
			EndSwitch
		 Next
	  Next
   EndIf
EndFunc

Func _ToggleRendering()
   If $mRendering Then
	  DisableRendering()
	  DllCall($mKernelHandle, 'int', 'SetProcessWorkingSetSize', 'int', $mGWProcHandle, 'int', -1, 'int', -1) ; clearmemory()
	  $mRendering = False
	  TrayItemSetText($trayRender, 'Enable Rendering')
   Else
	  EnableRendering()
	  TrayItemSetText($trayRender, 'Disable Rendering')
   EndIf
EndFunc

Func RefreshGW()
   If Not $mRendering Then
	  EnableRendering(False)
	  Sleep(5000)
	  DisableRendering(False)
	  Local $lTemp = DllStructCreate('dword;dword;int;int;int;int;int;int;int;int')
	  DllCall('psapi.dll', 'bool', 'GetProcessMemoryInfo', 'handle', $mGWProcHandle, 'ptr', DllStructGetPtr($lTemp), 'dword', DllStructGetSize($lTemp))
	  If DllStructGetData($lTemp, 4) > 262144000 Then
		 DllCall($mKernelHandle, 'int', 'SetProcessWorkingSetSize', 'int', $mGWProcHandle, 'int', -1, 'int', -1)
	  EndIf
   EndIf
EndFunc

Func TitleHandler()
   Switch @GUI_CtrlId
	  Case $boxAlcohol
		 If GUICtrlRead($boxAlcohol) = 1 Then ; checked
			$UseAlcohol = True
		 Else ; unchecked
			$UseAlcohol = False
		 EndIf
	  Case $boxSweets
		 If GUICtrlRead($boxSweets) = 1 Then ; checked
			$UseSweets = True
		 Else ; unchecked
			$UseSweets = False
		 EndIf
	  Case $boxParty
		 If GUICtrlRead($boxParty) = 1 Then ; checked
			$UseParty = True
		 Else ; unchecked
			$UseParty = False
		 EndIf
   EndSwitch
EndFunc

Func ToggleStoreMats()
   If GUICtrlRead($boxStorage) = 1 Then ; checked
	  $mStoreMaterials = True
   Else ; unchecked
	  $mStoreMaterials = False
   EndIf
EndFunc

#Region Tray
Func ToggleGUI()
   If BitAND(WinGetState($Form),2) Then
	  GUISetState(@SW_HIDE)
	  TrayItemSetText($trayGUI, 'Show GUI')
   Else
	  GUISetState(@SW_SHOW)
	  TrayItemSetText($trayGUI, 'Hide GUI')
   EndIf
EndFunc

Func CloseBotAndGW()
   ProcessClose(WinGetProcess($mGWHwnd))
   _exit()
EndFunc

Func TrayAddImage($aBMPHandle, $aMenuControlID, $aIndex)
   Return DllCall("user32.dll", "int", "SetMenuItemBitmaps", "hwnd", TrayItemGetHandle($aMenuControlID), "int",  $aIndex, "int",  0x00000400, "hwnd", $aBMPHandle, "hwnd", $aBMPHandle)
EndFunc

#EndRegion
#EndRegion

#Region Craft Conset
Func GoCrafter($aConsetAmount)
   $CurrentFarm = 'Crafting Cons'
   TrayItemSetText($trayCurrent, $CurrentFarm)
   GUICTrlSetImage($picCurrent, "images\conset.jpg")
   TravelTo(857)
   MoveTo(3031, 441)
   If $mStoreMaterials And CheckStorageForMaterials() Then
	  ; Get materials as needed so as to not run out of inventory space
	  OpenStorageWindow()
	  ; BU
	  GetMaterialFromStorage(929) ; Dust
	  Sleep(125)
	  GetMaterialFromStorage(933) ; Feather
	  Sleep(125)
	  GoToNPCNearestCoords(3666, 90)  ; (6748)
	  CraftBU($aConsetAmount)
	  Sleep(1000)
	  ; Grail
	  GetMaterialFromStorage(948) ; Iron
	  Sleep(125)
	  GoToNPCNearestCoords(3414, 644)  ; (6374)
	  CraftGrail($aConsetAmount)
	  ; Armor
	  GetMaterialFromStorage(921) ; Bone
	  Sleep(125)
	  GoToNPCNearestCoords(3743, -106)  ; (6224)
	  CraftArmor($aConsetAmount)
	  Sleep(1000)
   Else
	  ; BU
	  GoToNPCNearestCoords(3666, 90)  ; (6748)
	  CraftBU($aConsetAmount)
	  Sleep(1000)
	  ; Armor
	  GoToNPCNearestCoords(3743, -106)  ; (6224)
	  CraftArmor($aConsetAmount)
	  Sleep(1000)
	  ; Grail
	  GoToNPCNearestCoords(3414, 644)  ; (6374)
	  CraftGrail($aConsetAmount)
   EndIf
   Sleep(1000)
   Return CountConsets()
EndFunc

Func CheckStorageForMaterials()
   For $bag = 8 To 16
	  Local $lBagPtr = GetBagPtr($bag)
	  If $lBagPtr = 0 Then ContinueLoop
	  Local $lItemArrayPtr = MemoryRead($lBagPtr + 24, 'ptr')
	  For $slot = 0 To 19
		 Local $lItemPtr = MemoryRead($lItemArrayPtr + 4 * ($slot), 'ptr')
		 If $lItemPtr = 0 Then ContinueLoop
		 $lItemMID = MemoryRead($lItemPtr + 44, 'long')
		 If $lItemMID = 921 Or $lItemMID = 929 Or $lItemMID = 933 Or $lItemMID = 948 Then Return True
	  Next
   Next
EndFunc

Func GetMaterialFromStorage($aModelID)
   Local $lEmptyBag, $lEmptySlot
   For $bag = 8 To 16
	  Local $lBagPtr = GetBagPtr($bag)
	  If $lBagPtr = 0 Then ContinueLoop
	  Local $lItemArrayPtr = MemoryRead($lBagPtr + 24, 'ptr')
	  For $slot = 0 To 19
		 Local $lItemPtr = MemoryRead($lItemArrayPtr + 4 * ($slot), 'ptr')
		 If $lItemPtr = 0 Then ContinueLoop
		 If $aModelID = MemoryRead($lItemPtr + 44, 'long') Then
			UpdateEmptySlot($lEmptyBag, $lEmptySlot)
			If $lEmptyBag = 0 Then MsgBox(0,"Error","No inventory space, cannot proceed.")
			Sleep(125)
			MoveItem($lItemPtr, $lEmptyBag, $lEmptySlot)
			Do
			   Sleep(250)
			Until GetItemPtrBySlot($lEmptyBag, $lEmptySlot) <> 0
		 EndIf
	  Next
   Next
EndFunc

Func CraftBU($aAmount)
   Local $lMatArray[2][2] = [[933, 50],[929, 50]]
   Return CraftItemEx(24859, $aAmount, 250, $lMatArray)
EndFunc

Func CraftArmor($aAmount)
   Local $lMatArray[2][2] = [[921, 50],[948, 50]]
   Return CraftItemEx(24860, $aAmount, 250, $lMatArray)
EndFunc

Func CraftGrail($aAmount)
   Local $lMatArray[2][2] = [[948, 50],[929, 50]]
   Return CraftItemEx(24861, $aAmount, 250, $lMatArray)
EndFunc

Func CheckMats($aAmount)
   $lFeather = False
   $lIron = False
   $lBone = False
   $lDust = False
   If $CurrentFeather >= $NeededFeather Then $lFeather = True
   If $CurrentIron >= $NeededIron Then $lIron = True
   If $CurrentBone >= $NeededBone Then $lBone = True
   If $CurrentDust >= $NeededDust Then $lDust = True
   Return $lFeather And $lIron And $lBone And $lDust
EndFunc
#EndRegion

#Region Jaya Bluffs
Func JayaFarm()
   $CurrentFarm = 'Jaya Bluffs'
   TrayItemSetText($trayCurrent, $CurrentFarm)
   GUICTrlSetImage($picCurrent, "images\feather.jpg")
   EquipScythe()
   Sleep(1000)
   Inventory()
   Sleep(1000)
   Do
	  If GetMapID() <> 250 Then TravelTo(250)
	  While GetNumberOfPlayersInOutpost() > 2
		 DistrictChange(250)
	  WEnd
	  PrepResignFeather()
	  Feather()
	  If GetMapLoading() = 1 Then
		 Update("Resigning")
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
	  RefreshGW()
	  Inventory()
	  Sleep(1000)
	  While $BotPause
		 Sleep(1000)
	  WEnd
	  GUICtrlSetState($btPause, 64)
	  UpdateStatsMats()
   Until $CurrentFeather >= $NeededFeather Or Not $BotRunning
   GUICtrlSetState($btStart, 64)
EndFunc

Func PrepResignFeather()
   Update("Loading build.")
   LoadSkillTemplate("OgOjkmrMLSfbmXXXffsX7XqiyDA")
   Update("Going outside")
   MoveTo(19389, 10143)
   MoveTo(19180, 13273)
   MoveTo(18806, 16395)
   Move(16875, 17491)
   WaitMapLoading(196)
   Update("Prepping resign")
   Move(011152.008789, -13439.760742)
   WaitMapLoading(250)
EndFunc   ;==>PrepResign

Func Feather()
   Move(16875, 17491)
   WaitMapLoading(196)
   ; cast balth spirit on yourself
   Update("Precasting")
   UseSkillBySkillID(242)
   Sleep(3000)
   ; set global variables for run
   $Me = GetAgentPtr(-2)
   $Skillbar = GetSkillbarPtr()
   $WaypointCounter = 0
   $TenguGroupCounter = 0
   Update("Moving on to Tengu #" & $TenguGroupCounter + 1)
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
   Update("Running to: " & $aX & ", " & $aY & " (Waypoint #" & $WaypointCounter & ")")
   Do
	  Move_($aX, $aY)
	  Sleep(500)
	  If $aCheckTengu And Not TenguDead(GetAgentPtrArrayEx(3)) Then
		 If Not KillTengu($aX, $aY) Then Return
		 Move_($aX, $aY)
	  ElseIf Not GetIsMoving($Me, 100) Then
		 Update("Blocked.")
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
   Update("Waiting for Tengu to ball")
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
		 Update("Why am I even here?")
		 $lAngle += 40
		 Move_($aX + 500 * Sin($lAngle), $aY + 500 * Cos($lAngle))
		 Sleep(500)
	  EndIf
   Until AreTenguBalledUp($lAgentArray) = 0
   Update("Killing Tengu #" & $TenguGroupCounter)
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
		 Sleep(100)
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
   Update("Picking up loot")
   PickUpLoot()
   Update("Moving on to Tengu #" & $TenguGroupCounter + 1)
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

Func EquipScythe()
   Local $lMainhand = GetItemPtrBySlot(17,1)
   Sleep(50)
   If MemoryRead($lMainhand + 32, 'byte') = 35 Then Return True ; already scythe equipped
   ; search equipment bag for scythe
   Local $lBagPtr = GetBagPtr(5)
   If $lBagPtr = 0 Then Return ; no equipment bag
   Local $lItemArrayPtr = MemoryRead($lBagPtr + 24, 'ptr')
   For $i = 1 To 5
	  $lItemPtr = MemoryRead($lItemArrayPtr + 4 * ($i - 1), 'ptr')
	  If $lItemPtr = 0 Then ContinueLoop
	  If MemoryRead($lItemPtr + 32, 'byte') = 35 Then
		 $lEquipped = MemoryRead($lItemPtr + 76, 'byte')
		 If $lEquipped <> 0 Then
			Return ChangeWeaponSetToEquipped($lEquipped)
		 ElseIf GetIsIDed($lItemPtr) Then ; identified scythe in equipment bag... has to be the right one, right?
			If $lMainhand <> 0 Then ; mainhand weapon equipped, have to store it safely
			   $lMainhandID = MemoryRead($lMainhand, 'long')
			   EquipItem($lItemPtr)
			   Do
				  Sleep(1000)
			   Until GetItemPtrBySlot(5, $i) = 0
			   Return MoveItem($lMainhandID, $lBagPtr, $i)
			Else ; no mainhand weapon
			   Return EquipItem($lItemPtr)
			EndIf
		 EndIf
	  EndIf
   Next
   MsgBox(0, "Danger", "Cant safely store mainhand weapon. Exiting.")
   _exit()
EndFunc
#EndRegion

#Region Gates of Kryta
Func GoKFarm()
   $CurrentFarm = 'Gates of Kryta'
   TrayItemSetText($trayCurrent, $CurrentFarm)
   GUICTrlSetImage($picCurrent, "images\bone.jpg")
   EquipScythe()
   Sleep(1000)
   Inventory()
   Sleep(1000)
   Do
	  GoK()
	  Sleep(1000)
	  RefreshGW()
	  Inventory()
	  Sleep(1000)
	  While $BotPause
		 Sleep(1000)
	  WEnd
	  GUICtrlSetState($btPause, 64)
	  UpdateStatsMats()
   Until $CurrentBone >= $NeededBone Or Not $BotRunning
   GUICtrlSetState($btStart, 64)
EndFunc

Func GoK()
   ;  New Map Gates of Kryta outpost, ID 14
   TravelTo(14) ;  New Map Gates of Kryta outpost
   LoadSkilltemplate("OgOjkmrMLOfbzLB+7zdZv7X5BA")
   EnterChallengeForeign()
   Do
	  Sleep(1000)
   Until GetMapLoading() = 1
   Sleep(3000)
   UseSkillBySkillID(242) ; cast balth spirit on yourself
   Sleep(3000)
   $Me = GetAgentPtr(-2)
   $Skillbar = GetSkillbarPtr()
   $WaypointCounter = 0
   MoveToCount(4097.40, 17606.35)
   MoveToCount(3594.10, 16493.45)
   MoveToCount(5760.82, 17880.57)
   MoveToCount(5812.00, 18702.47)
   MoveToCount(7101.03, 18425.27)
   MoveToCount(7372.46, 16062.31)
   MoveToCount(8076.67, 14390.21)
   MoveToCount(8574.87, 14204.79)
   MoveToCount(8653.73, 13504.28)
   If Not RunGoK(8597.50, 14336.75) Then Return
   If Not CombatGoK() Then Return
   PickUpLoot()
   If Not RunGoK(7772.42, 13428.04) Then Return
   If Not CombatGoK() Then Return
   PickUpLoot()
   MoveToCount(9379.13, 14448.80, 0)
   Sleep(1000)
   MoveToCount(10853.49, 15399.41, 0)
   AdlibRegister("DetectCinematic")
   Local $lWaypoints[8][2] = [[11354.33, 9594.18], _
							  [12556.49, 10455.31], _
							  [13656.10, 7002.75], _
							  [0, 0], _
							  [13073.71, 10445.01], _
							  [12895.94, 11441.50], _
							  [13355.15, 11870.67], _
							  [14636.79, 13483.25]]
   For $i = 0 To 7
	  If $lWaypoints[$i][0] = 0 Then
		 If Not CombatGoK(True) Then Return
		 If CountSlots() < 5 Then SalvageBagsExplorable()
		 PickUpLoot()
	  Else
		 If Not RunGoK($lWaypoints[$i][0], $lWaypoints[$i][1]) Then Return
	  EndIf
	  If $Cinematic Then ExitLoop
   Next
   If Not CombatGoK() Then Return
   If Not $Cinematic Then
	  PickUpLoot()
	  For $i = 1 To 10
		 $lNext = CheckForMore()
		 If $lNext <> 0 Then
			Local $lNextX, $lNextY
			UpdateAgentPosByPtr($lNext, $lNextX, $lNextY)
			MoveTo($lNextX, $lNextY)
			If Not CombatGoK() Then Return
		 EndIf
		 If $lNext = 0 Or $Cinematic Then ExitLoop
	  Next
	  AdlibUnRegister("DetectCinematic")
	  TravelTo(14)
   Else
	  AdlibUnRegister("DetectCinematic")
	  Do
		 Sleep(1000)
	  Until GetMapLoading() = 0
	  AcceptAllItems()
	  TravelTo(14)
   EndIf
   Return True
EndFunc

Func CombatGoK($aPick = False)
   ; OgOjkmrMLOfbzLB+7zdZv7X5BA
   If $Cinematic Then Return True
   TargetNearestEnemy()
   Sleep(50)
   $lPtr = GetCurrentTargetPtr()
   If $lPtr = 0 Then Return True
   While GetDistance($Me, $lPtr) < 1300
	  If $Cinematic Then Return True
	  $lTargetID = ConvertID(-1)
	  Update("Attacking: " & $lTargetID)
	  $lBlocked = 0
	  Do
		 $lBlocked += 1
		 Attack(-1)
		 While GetEnergy($Me) < 10
			Sleep(250)
			If $Cinematic Then Return True
		 WEnd
		 If GetSkillbarSkillRecharge(6, 0, $Skillbar) = 0 And Not HasEffect(1516) Then ; Mystic Regeneration
			UseSkill(6, -2)
			$lDuration = 250
		 ElseIf GetSkillbarSkillRecharge(7, 0, $Skillbar) = 0 And Not HasEffect(1531) Then ; Intimidating Aura
			UseSkill(7, -2)
			$lDuration = 750
		 ElseIf GetSkillbarSkillRecharge(2, 0, $Skillbar) = 0 And Not HasEffect(1510) Then ; Sand Shards
			UseSkill(2, -2)
			$lDuration = 50
		 ElseIf GetSkillbarSkillRecharge(1, 0, $Skillbar) = 0 Then ; Vow of Strength
			UseSkill(1, -2)
			$lDuration = 250
		 ElseIf GetSkillbarSkillRecharge(5, 0, $Skillbar) = 0 Then ; Mirage Cloak
			UseSkill(5, -2)
			$lDuration = 50
		 ElseIf GetSkillbarSkillRecharge(3, 0, $Skillbar) = 0 Then ; Conviction
			UseSkill(3, -2)
			$lDuration = 50
		 ElseIf GetSkillbarSkillRecharge(4, 0, $Skillbar) = 0 And Not HasEffect(479) Then ; Farmer's Scythe
			UseSkill(4, -1)
			$lDuration = 500
		 Else
			$lDuration = 250
		 EndIf
		 While MemoryRead($Skillbar + 176) <> 0
			Sleep(125)
			If $Cinematic Then Return True
		 WEnd
		 Sleep($lDuration)
		 If $lBlocked > 20 And GetDistance($Me, $lPtr) > 300 Then
			TargetNearestEnemy()
			Sleep(50)
			$lPtr = GetCurrentTargetPtr()
			$lNewID = ConvertID(-1)
			If $lNewID = $lTargetID Then
			   TargetNextEnemy()
			   Sleep(50)
			   $lPtr = GetCurrentTargetPtr()
			   $lTargetID = ConvertID(-1)
			Else
			   $lTargetID = $lNewID
			EndIf
			Update("Switching to: " & $lNewID)
		 EndIf
		 If GetIsDead($Me) Or GetMorale() < 0 Or GetMapLoading() <> 1 Then Return False
		 If $lBlocked > 100 And GetHealth($lPtr) > 0.5 Then
			Update("Takes just way too long, outta here.")
			PickUpLoot()
			Return False
		 EndIf
		 If $Cinematic Then Return True
		 If GetMapLoading() <> 1 Then Return
	  Until GetIsDead($lPtr)
	  If $aPick Then PickUpLoot()
	  TargetNearestEnemy()
	  Sleep(50)
	  $lPtr = GetCurrentTargetPtr()
	  If $lPtr = 0 Then Return True
   WEnd
   While GetEnergy() < 20
	  If $Cinematic Then Return True
	  Sleep(1000)
   WEnd
   Return True
EndFunc

Func RunGoK($aX, $aY)
   Local $lX, $lY
   Local $lAngle = 0
   Local $lBlocked = 0
   $WaypointCounter += 1
   Update("Running to: " & $aX & ", " & $aY & " (Waypoint #" & $WaypointCounter & ")")
   Do
	  Move_($aX, $aY)
	  If Not GetIsMoving($Me) Then
		 $lBlocked += 1
		 UpdateAgentPosByPtr($Me, $lX, $lY)
		 $lAngle += 40
		 Move_($lX + 300 * Sin($lAngle), $lY + 300 * Cos($lAngle))
		 Sleep(500)
		 Move_($aX, $aY)
		 If $lBlocked > 20 Then
			If Not CombatGoK() Then Return
		 EndIf
	  ElseIf MemoryRead($Me + 304, 'float') < 0.9 Then
		 If GetSkillbarSkillRecharge(7, 0, $Skillbar) = 0 And Not HasEffect(1531) Then ; Intimidating Aura
			UseSkillBySkillID(1531)
		 EndIf
		 If GetSkillbarSkillRecharge(6, 0, $Skillbar) = 0 And Not HasEffect(1516) Then ; Mystic Regeneration
			UseSkillBySkillID(1516)
		 EndIf
	  EndIf
	  Sleep(500)
	  If $Cinematic Then Return True
	  If GetIsDead($Me) Or GetMorale() < 0 Or GetMapLoading() <> 1 Then Return False
	  UpdateAgentPosByPtr($Me, $lX, $lY)
   Until (($aX - $lX) ^ 2 + ($aY - $lY) ^ 2) < 10000
   Return True
EndFunc

Func MoveToCount($aX, $aY, $aRandom = 50)
   $WaypointCounter += 1
   Update("Moving to: " & $aX & ", " & $aY & " (Waypoint #" & $WaypointCounter & ")")
   MoveTo($aX, $aY, $aRandom)
EndFunc
#EndRegion

#Region Kilroy
Func KilroyFarm()
   $CurrentFarm = 'Kilroy'
   TrayItemSetText($trayCurrent, $CurrentFarm)
   GUICTrlSetImage($picCurrent, "images\iron.jpg")
   Inventory()
   Sleep(1000)
   Do
	  Sleep(100)
	  ; This is so a non-level 20 character does not get stuck at initialize. Be sure to have the 30 att quests done before this
   ;~ If GetExperience() >= 140600 Then LoadMySkillbar()
	  If GetMapID() <> 644 Then TravelTo(644)
	  Do
		 DistrictChange(644)
	  Until GetNumberOfPlayersInOutpost() <= 2
	  GoOutside()
	  $tRun = TimerInit()
	  AdlibRegister("DeathCheck", 1000)
	  $Me = GetAgentPtr(-2)
	  $skillbar = GetSkillbarPtr()
	  $skillqueue = MemoryRead($skillbar + 168, 'ptr')
	  Do
		 Sleep(200)
		 $kilroy = GetNearestNPCPtrToAgent($Me)
	  Until $kilroy <> 0
	  If GetSkillbarSkillID(7) <> 0 Then $HardMode = True
	  $giveup = False
	  $tLastTarget = TimerInit()
	  Fight()
	  AdlibUnRegister("DeathCheck")
	  Update("Returning to town")
	  Sleep(GetPing() + 1000)
	  If GetMapID() <> 644 Then TravelTo(644)
	  $ChestOpened = False
	  ; These are here to get you the spam titles until they are maxed.
	  If $UseAlcohol And GetDrunkardTitle() < 10000 Then
		 Sleep(200)
		 UseItems(True, False, False)
	  EndIf
	  If $UseSweets And GetSweetTitle() < 10000 Then
		 Sleep(200)
		 UseItems(False, True, False)
	  EndIf
	  If $UseParty And GetPartyTitle() < 10000 Then
		 Sleep(200)
		 UseItems(False, False, True)
	  EndIf
	  ; In case you selected Stop at Rank 5, this will make sure it enables the GW screen on exit
	  If $DeldrimorRank5 And GetDeldrimorTitle() >= 26000 Then
		 EnableRendering()
		 WinSetState(GetWindowHandle(), "", @SW_SHOW)
		 _exit()
	  EndIf
	  $lSlots = CountSlots()
	  If $lSlots < 2 Then
		 Inventory()
	  Else
		 IDAndSell()
	  EndIf
	  UpdateQuest(856)
	  Sleep(2000)
	  If MemoryRead(GetQuestPtrByID(856) + 4, 'long') = 3 Then
		 Update("Turning in quest")
		 MoveToEx(17263.34, -4844.00)
		 $lOldExp = GetExperience()
		 Do
			GoToMerchant(6164)
			Sleep(GetPing()+500)
			QuestReward(856)
			Sleep(GetPing()+500)
			$lNewExp = GetExperience()
		 Until $lOldExp <> $lNewExp
		 ConsoleWrite("Exp: " & $lOldExp & " | " & $lNewExp & @CRLF)
	  Else
		 ConsoleWrite("[" & @HOUR & ":" & @MIN & ":" & @SEC & "] LogState: " & MemoryRead(GetQuestPtrByID(856) + 4, 'long') & @CRLF)
	  EndIf
	  AbandonQuest(856)
	  While $BotPause
		 Sleep(1000)
	  WEnd
	  GUICtrlSetState($btPause, 64)
	  UpdateStatsMats()
	  RefreshGW()
   Until $CurrentIron >= $NeededIron Or Not $BotRunning
   GUICtrlSetState($btStart, 64)
EndFunc

Func GoOutside()
   Update("Leaving town")
   MoveToEx(17263.34, -4844.00)
   Do
	  GoToMerchant(6164)
	  Sleep(GetPing()+500)
	  AcceptQuest(856)
	  Sleep(GetPing()+500)
	  EquipBrassKnuckles()
	  Dialog(0x85)
	  Sleep(GetPing()+500)
	  Sleep(3000)
   Until GetMapLoading() <> 0
   Do
	  Sleep(1000)
   Until GetMapLoading() = 1
   pconsScanInventory()
   Sleep(GetPing()+500)
   UsePumpkinPie()
   Sleep(GetPing()+500)
   SetDisplayedTitle(0x27) ; Displays your Deldrimor title
   Sleep(GetPing()+500)
EndFunc   ;==>GoOutside

Func LoadMySkillbar()
   Sleep(GetPing()+500)
   Switch MemoryRead(GetAgentPtr(-2) + 266, 'byte')
	  Case 1
		 LoadSkillTemplate("OQcSE5ODAAAAAAAAAAA")
	  Case 2
		 LoadSkillTemplate("OgcSc5ODAAAAAAAAAAA")
	  Case 3
		 LoadSkillTemplate("OwcSA5ODAAAAAAAAAAA")
	  Case 4
		 LoadSkillTemplate("OAdSY4ODAAAAAAAAAAA")
	  Case 5
		 LoadSkillTemplate("OQdSA4ODAAAAAAAAAAA")
	  Case 6
		 LoadSkillTemplate("OgdSw4ODAAAAAAAAAAA")
	  Case 7
		 LoadSkillTemplate("OwBiMydMAAAAAAAAAAA")
	  Case 8
		 LoadSkillTemplate("OAeiQydMAAAAAAAAAAA")
	  Case 9
		 LoadSkillTemplate("OQeigydMAAAAAAAAAAA")
	  Case 10
		 LoadSkillTemplate("OgeiwydMAAAAAAAAAAA")
	  Case Else
		 Update("You have no Profession retard!") ; this will never announced, but I like it in here.
		 $boolRun = False
   EndSwitch
EndFunc

Func DeathCheck()
   If $giveup Then Return
   If MemoryRead($Me + 288, 'long') >= 60 Then
	  ConsoleWrite("Got deadlocked, giving up" & @CRLF)
	  GiveUp()
	  Return
   EndIf
   If TimerDiff($tLastTarget) > 60000 Or TimerDiff($tRun) > 600000 Then
	  ConsoleWrite("Got deadlocked, giving up" & @CRLF)
	  GiveUp()
	  Return
   EndIf
   If GetmapID() <> 704 Then
	  ConsoleWrite("Got kicked out of area, giving up" & @CRLF)
	  GiveUp()
	  Return
   EndIf
   While MemoryRead($Me + 284, 'float') < 1.0
	  ConsoleWrite("Stand UP!" & @CRLF)
	  UseSkill(8, $enemy)
	  RndSleep(100)
   WEnd
EndFunc   ;==>DeathCheck

Func GiveUp()
   If Not $giveup Then
	  $giveup = True
	  AdlibUnRegister("DeathCheck")
   EndIf
EndFunc

Func SelectTarget()
   $target = GetCurrentTargetPtr()
   If $target <> 0 And MemoryRead($target + 156, 'long') = 219 And MemoryRead($target + 433, 'byte') = 3 And Not GetIsDead($target) Then
	  If TimerDiff($tSwitchtarget) < 1000 Or GetDistance($Me, $target) < 100 Then
		 Return $target
	  Else
		 ConsoleWrite("Switching target, out of range!" & @CRLF)
	  EndIf
   EndIf
   $tSwitchtarget = TimerInit()
   Update("Looking for items")
   PickUpLoot()
   If GetIsDead($kilroy) Then
	  TargetNearestEnemy()
	  Sleep(100)
	  $target = GetCurrentTargetPtr()
	  ConsoleWrite("Kilroy is dead -> new target: " & $target & @CRLF)
   Else
	  $target = GetAgentPtr(GetTarget($kilroy))
	  Update("Selecting new target")
	  If $target = 0 Or GetIsDead($target) Or MemoryRead($target + 433, 'byte') <> 3 Then
		 TargetNearestEnemy()
		 Sleep(100)
		 $possibletarget = GetCurrentTargetPtr()
		 If GetDistance($possibletarget, $kilroy) < 1250 Then
			ConsoleWrite("Roaming!" & @CRLF)
			$target = $possibletarget
		 EndIf
	  Else
		 ConsoleWrite("Trying to copy target!" & @CRLF)
		 ChangeTarget($target)
	  EndIf
   EndIf
   If GetIsBoss($target) Then
	  ;It's a boss, lets search for minions first!
	  TargetNextEnemy()
	  Sleep(100)
	  $possibletarget = GetCurrentTargetPtr()
	  If $possibletarget <> 0 And GetDistance($possibletarget, $kilroy) < 1250 Then
		 ConsoleWrite("Retargeting to minion!" & @CRLF)
		 $target = $possibletarget
	  EndIf
   EndIf
   If $target <> 0 And Not GetIsDead($target) Then
	  Update("Attacking " & MemoryRead($target + 44, 'long'))
	  Attack($target)
	  Return $target
   EndIf
   SalvageBagsExplorable()
EndFunc   ;==>SelectTarget

Func Fight()
   Local $lX, $lY
   Update("Fighting!")
   $tSwitchtarget = TimerInit()
   Do
	  $enemy = SelectTarget()
	  While Not GetIsDead($enemy) And Not $giveup And $enemy <> 0
		 $tLastTarget = TimerInit()
		 $shouldblock = GetIsCasting($enemy) And GetDistance($enemy, $Me) < 200
		 $useSkill = -1
		 If $HardMode And IsRecharged_(7, $skillbar) Then
			UseSkill(7, $enemy)
		 ElseIf GetSkillEffectPtr(485) = 0 And IsRecharged_(1, $skillbar) Then
			UseSkill(1, $enemy)
		 ElseIf $shouldblock And IsRecharged_(3, $skillbar) Then
			UseSkill(3, $enemy)
		 ElseIf MemoryRead($skillbar + 84, 'long') >= 250 And IsRecharged_(5, $skillbar) Then
			UseSkill(5, $enemy)
		 ElseIf MemoryRead($skillbar + 104, 'long') >= 175 And IsRecharged_(6, $skillbar) Then
			UseSkill(6, $enemy)
		 ElseIf MemoryRead($skillbar + 64, 'long') >= 100 And IsRecharged_(4, $skillbar) Then
			UseSkill(4, $enemy)
		 Else
			UseSkill(2, $enemy)
		 EndIf
		 While MemoryRead($skillqueue + 4, 'byte') <> 0
			Sleep(250)
		 WEnd
		 Sleep(250)
		 If GetDistance($Me, $enemy) > 500 Then ExitLoop
	  WEnd
	  Update("Following Kilroy " & MemoryRead($kilroy + 44, 'long'))
	  RndSleep(GetPing())
	  UpdateAgentPosByPtr($kilroy, $lX, $lY)
	  Move($lX, $lY, 400)
	  RndSleep(500)
   Until $giveup Or DoChest() Or GetMapID() <> 704
EndFunc   ;==>Fight

Func IsRecharged_($aSkillSlot, $aPtr)
   Return GetSkillbarSkillRecharge($aSkillSlot, 0, $aPtr) = 0
EndFunc

Func DoChest() ;~ End Chest after quest is done
   Sleep(GetPing())
   $chest = GetNearestSignpostPtrToCoords(13275, -16039)
   If $chest <> 0 And GetDistance2(13275, -16039, $chest) < 100 Then
;~ 	  ConsoleWrite("Found Chest" & @CRLF)
	  GoToSignpost($chest)
	  OpenChest()
	  Sleep(Random(700, 900))
	  PickUpLoot()
	  Sleep(Random(700, 900))
	  Return True
   ElseIf $boolOpenLocked And Not $ChestOpened Then ; open locked chest
	  $chest = GetNearestSignpostPtrToAgent($Me)
	  If $chest <> 0 And MemoryRead($chest + 208, 'long') = 8141 And GetDistance($Me, $chest) < 2000 Then
		 ConsoleWrite("Found Chest" & @CRLF)
		 GoToSignpost($chest)
		 OpenChest()
		 Sleep(Random(700, 900))
		 PickUpLoot()
		 Sleep(Random(700, 900))
		 $ChestOpened = True
	  EndIf
   EndIf
   ChangeTarget(0)
   Sleep(GetPing())
   Return False
EndFunc   ;==>DoChest

Func CheckMainHand()
   Local $lMainHandPtr = GetItemPtrBySlot(17, 1)
   If $lMainHandPtr = 0 Then Return SetExtended($lMainHandPtr, 0)
   Local $lMainHandMID = MemoryRead($lMainHandPtr + 44, 'long')
   If $lMainHandMID = 24897 Or $lMainHandMID = 24659 Then
	  Return SetExtended($lMainHandPtr, 1)
   Else
	  Return SetExtended($lMainHandPtr, 0)
   EndIf
EndFunc

Func EquipBrassKnuckles()
   If CheckMainHand() <> 0 Then Return True
   Local $lMainHand = @extended
   Local $lNormalKnuckles = 0
   Local $lThunderfistsKnuckles = 0
   Local $lEquipped = 0
   Local $lEquippedTF = 0
   Local $lResetAttributes = False
   ; normal brass knuckles -> 24897
   ; gold brass knuckles -> 24659
   For $bag = 1 To 5
	  Local $lBagPtr = GetBagPtr($bag)
	  Local $lItemArrayPtr = MemoryRead($lBagPtr + 24, 'ptr')
	  For $slot = 0 To MemoryRead($lBagPtr + 32, 'long') - 1
		 Local $lItemPtr = MemoryRead($lItemArrayPtr + 4 * ($slot), 'ptr')
		 If $lItemPtr = 0 Then ContinueLoop
		 Local $lItemMID = MemoryRead($lItemPtr + 44, 'long')
		 If $lItemMID = 24897 Then
			If $lNormalKnuckles <> 0 Then ; Brass Knuckles (white)
			   $lTemp = MemoryRead($lItemPtr + 76, 'byte')
			   If $lTemp <> 0 Then
				  $lNormalKnuckles = $lItemPtr
				  $lEquipped = $lTemp
			   EndIf
			Else
			   $lNormalKnuckles = $lItemPtr
			   $lEquipped = MemoryRead($lItemPtr + 76, 'byte')
			EndIf
		 ElseIf $lItemMID = 24659 Then ; Thunderfists Brass Knuckles (gold)
			$lResetAttributes = True
			$lThunderfistsKnuckles = $lItemPtr
			$lEquippedTF = MemoryRead($lItemPtr + 76, 'byte')
		 EndIf
	  Next
   Next
   If $lThunderfistsKnuckles <> 0 And $lEquippedTF <> 0 Then
	  Return ChangeWeaponSetToEquipped($lEquippedTF)
   ElseIf $lNormalKnuckles <> 0 And $lEquipped <> 0 Then
	  Return ChangeWeaponSetToEquipped($lEquipped)
   ElseIf $lThunderfistsKnuckles <> 0 Or $lNormalKnuckles <> 0 Then
	  $lEquipBag = GetBagPtr(5)
	  If $lMainHand = 0 Then
		 If $lThunderfistsKnuckles <> 0 Then
			Return EquipItem($lThunderfistsKnuckles)
		 Else
			Return EquipItem($lNormalKnuckles)
		 EndIf
	  ElseIf MemoryRead($lEquipBag + 16, 'long') < 5 Then
		 For $i = 1 To 5
			$lEmpty = GetItemPtrBySlot(5, $i)
			If $lEmpty = 0 Then
			   If $lMainHand <> 0 Then UnequipItem(1, $lEquipBag, $i)
			   Sleep(250)
			   If $lThunderfistsKnuckles <> 0 Then
				  Return EquipItem($lThunderfistsKnuckles)
			   Else
				  Return EquipItem($lNormalKnuckles)
			   EndIf
			EndIf
		 Next
	  Else
		 For $i = 8 To 16
			$lStoragePtr = GetBagPtr($i)
			If $lStoragePtr = 0 Then ContinueLoop
			Local $lItemArrayPtr = MemoryRead($lStoragePtr + 24, 'ptr')
			For $j = 0 To MemoryRead($lStoragePtr + 32, 'long') - 1
			   Local $lEmpty = MemoryRead($lItemArrayPtr + 4 * $j, 'ptr')
			   If $lEmpty = 0 Then
				  If $lMainHand <> 0 Then UnequipItem(1, $lStoragePtr, $j + 1)
				  Sleep(250)
				  If $lThunderfistsKnuckles <> 0 Then
					 Return EquipItem($lThunderfistsKnuckles)
				  Else
					 Return EquipItem($lNormalKnuckles)
				  EndIf
			   EndIf
			Next
		 Next
	  EndIf
	  If Not $mRendering Then EnableRendering()
	  MsgBox(0, "Danger", "Cant safely store mainhand weapon. Exiting.")
	  _exit()
   Else
	  If Not $mRendering Then EnableRendering()
	  MsgBox(0, "Error", "No Brass Knuckles Found. Exiting.")
	  _exit()
   EndIf
EndFunc

#Region Inventory
Func IDAndSell()
   Local $lRenderChanged = False
   MinMaxGold()
   Update("Storing items")
   StoreItems()
   Update("Cleaning inventory")
   RndSleep(1000)
   MoveToEx(17822, -7520, 0)
   GoToNPCNearestCoords(17664, -7724)
   Sleep(1000)
   BuyKits()
   Sleep(GetPing()+500)
   Ident()
   Sleep(GetPing()+500)
   While SalvageBags() = -1
	  BuyKits()
   WEnd
   Sleep(1000)
   UpdateStatsMats()
   StoreRunes()
   Sell()
   Update("Selling materials")
   MoveToEx(18693, -7445, 0)
   MoveToEx(18694, -7804, 0)
   GoToNPCNearestCoords(18695, -7902)
   Sleep(1000)
   SellMaterials()
   SellExcessMaterials()
   MoveToEx(18644, -5773)
   GoToNPCNearestCoords(18924, -5828)
   Sleep(1000)
   SellUpgrades()
   If FindDye() <> 0 Then
	  Update("Selling dye")
	  MoveToEx(19315, -7087, 0)
	  MoveToEx(19460, -7247, 0)
	  GoToNPCNearestCoords(19530, -7327)
	  SellDyes()
   EndIf
   MinMaxGold()
   If FindScroll() <> 0 Then
	  Update("Selling Scrolls")
	  MoveToEx(17867, -6371, 0)
	  MoveToEx(17830, -6185, 0)
	  GoToNPCNearestCoords(17811, -6071)
	  SellScrolls()
   EndIf
   If GetGoldCharacter() > 90000 Then
	  If $mMatExchangeGold = 0 Then
		 Update("Buying Lockpicks")
		 MoveToEx(17822, -7520, 0)
		 GoToNPCNearestCoords(17664, -7724)
		 $lAmount = Floor((GetGoldCharacter() - 10000) / 1500)
		 BuyItemByModelID(22751, $lAmount, 1500)
	  Else
		 Update("Buying Rare Materials")
		 MoveToEx(18978, -7765, 0)
		 MoveToEx(19000, -8270, 0)
		 GoToNPCNearestCoords(18764, -8031)
		 Do
			TraderRequest($mMatExchangeGold)
			TraderBuy()
			Sleep(250)
		 Until GetGoldCharacter() <= 15000
	  EndIf
   EndIf
EndFunc   ;==>IDAndSell

Func FindDye()
   For $bag = 1 To 4 ; inventory only
	  $lBagPtr = GetBagPtr($bag)
	  If $lBagPtr = 0 Then ContinueLoop ; empty bag slot
	  $lItemArrayPtr = MemoryRead($lBagPtr + 24, 'ptr')
	  For $slot = 0 To MemoryRead($lBagPtr + 32, 'long') - 1
		 $lItemPtr = MemoryRead($lItemArrayPtr + 4 * ($slot), 'ptr')
		 If MemoryRead($lItemPtr + 44, 'long') = 146 Then Return $lItemPtr
	  Next
   Next
EndFunc   ;==>Find Dyes

Func FindScroll()
   For $bag = 1 To 4 ; inventory only
	  $lBagPtr = GetBagPtr($bag)
	  If $lBagPtr = 0 Then ContinueLoop ; empty bag slot
	  $lItemArrayPtr = MemoryRead($lBagPtr + 24, 'ptr')
	  For $slot = 0 To MemoryRead($lBagPtr + 32, 'long') - 1
		 $lItemPtr = MemoryRead($lItemArrayPtr + 4 * ($slot), 'ptr')
		 If MemoryRead($lItemPtr + 44, 'long') = 5594 Then Return $lItemPtr
		 If MemoryRead($lItemPtr + 44, 'long') = 5595 Then Return $lItemPtr
		 If MemoryRead($lItemPtr + 44, 'long') = 5611 Then Return $lItemPtr
	  Next
   Next
EndFunc   ;==>Find Scrolls

Func InventoryCheck()
   Return CountSlots() < 3
EndFunc   ;==>InventoryCheck

Func StoreRunes()
   UpdateEmptyStorageSlot($mEmptyBag, $mEmptySlot)
   Update("Empty Spot: " & $mEmptyBag & ", " & $mEmptySlot)
   If $mEmptySlot = 0 Then Return ; no more empty slots found
   OpenStorageWindow()
   For $bag = 1 To 4 ; inventory only
	  $lBagPtr = GetBagPtr($bag)
	  If $lBagPtr = 0 Then ContinueLoop ; empty bag slot
	  $lItemArrayPtr = MemoryRead($lBagPtr + 24, 'ptr')
	  For $slot = 0 To MemoryRead($lBagPtr + 32, 'long') - 1
		 $lItemPtr = MemoryRead($lItemArrayPtr + 4 * ($slot), 'ptr')
		 If $lItemPtr = 0 Then ContinueLoop ; empty slot
		 If CanStoreRunes($lItemPtr) Then
			Update("Store Rune: " & $bag & ", " & $slot & " -> " & $mEmptyBag & ", " & $mEmptySlot)
			MoveItem(MemoryRead($lItemPtr, 'long'), $mEmptyBag, $mEmptySlot)
			Do
			   Sleep(250)
			Until MemoryRead($lItemArrayPtr + 4 * ($slot), 'ptr') = 0
			UpdateEmptyStorageSlot($mEmptyBag, $mEmptySlot)
			If $mEmptySlot = 0 Then Return ; no more empty slots
		 EndIf
	  Next
   Next
EndFunc

Func CanStoreRunes($aitem)
   Local $ModStruct = GetModStruct($aitem)
   If StringInStr($ModStruct, "C202E827", 0, 1) Then Return True ; minor vigor
   If StringInStr($ModStruct, "C202E927", 0, 1) Then Return True ; major vigor
   If StringInStr($ModStruct, "C202EA27", 0, 1) Then Return True ; sup. vigor
   If StringInStr($ModStruct, "000A4823", 0, 1) Then Return True ; vitae
   If StringInStr($ModStruct, "0200D822", 0, 1) Then Return True ; attunement
   If StringInStr($ModStruct, "0005D826", 0, 1) Then Return True ; survivor
   If StringInStr($ModStruct, "E9010824", 0, 1) Then Return True ; blessed
   If StringInStr($ModStruct, "FB010824", 0, 1) Then Return True ; sentinel
   If StringInStr($ModStruct, "0129E821", 0, 1) Then Return True ; minor scythe
   If StringInStr($ModStruct, "0110E821", 0, 1) Then Return True ; minor divine
   If StringInStr($ModStruct, "0105E821", 0, 1) Then Return True ; minor death
   If StringInStr($ModStruct, "0305E8217901", 0, 1) Then Return True ; sup death
   If StringInStr($ModStruct, "0106E821", 0, 1) Then Return True ; minor soul reapong
   If StringInStr($ModStruct, "0100E821", 0, 1) Then Return True ; minor fast casting
   If StringInStr($ModStruct, "0103E821", 0, 1) Then Return True ; minor inspiration
   If StringInStr($ModStruct, "010CE821", 0, 1) Then Return True ; minor energy storage
   If StringInStr($ModStruct, "0124E821", 0, 1) Then Return True ; minor spawning
   If StringInStr($ModStruct, "02020824", 0, 1) Then Return True ; windwalker
   If StringInStr($ModStruct, "04020824", 0, 1) Then Return True ; shaman
   If StringInStr($ModStruct, "07020824", 0, 1) Then Return True ; centurion
EndFunc
#EndRegion

#Region Pcons
Func UsePumpkinPie()
   If Not $usePumpkin Then Return
   If Not pconsScanInventory() Then Return
   Sleep(GetPing()+200)
   If GetMapLoading() = 1 And Not GetIsDead($Me) Then
	  $lPumpkinPie = GetItemPtrBySlot($pconsPumpkinPie_slot[0], $pconsPumpkinPie_slot[1])
	  If MemoryRead($lPumpkinPie + 44, 'long') <> 28436 Then Return
	  UseItem($lPumpkinPie)
   EndIf
EndFunc

Func pconsScanInventory()
   For $bag = 1 To 4 ; inventory only
	  $lBagPtr = GetBagPtr($bag)
	  If $lBagPtr = 0 Then ContinueLoop ; empty bag slot
	  $lItemArrayPtr = MemoryRead($lBagPtr + 24, 'ptr')
	  For $slot = 0 To MemoryRead($lBagPtr + 32, 'long') - 1
		 $lItemPtr = MemoryRead($lItemArrayPtr + 4 * ($slot), 'ptr')
		 If MemoryRead($lItemPtr + 44, 'long') = 28436 Then
			$pconsPumpkinPie_slot[0] = $bag
			$pconsPumpkinPie_slot[1] = $slot + 1
			Return True
		 EndIf
	  Next
   Next
EndFunc   ;==>pconsScanInventory
#EndRegion

#Region Title functions
Func UseItems($aAlc = True, $aSweet = True, $aParty = True)
   Sleep(GetPing()+300)
   For $bag = 1 To 4 ; inventory only
	  $lBagPtr = GetBagPtr($bag)
	  If $lBagPtr = 0 Then ContinueLoop ; empty bag slot
	  $lItemArrayPtr = MemoryRead($lBagPtr + 24, 'ptr')
	  For $slot = 0 To MemoryRead($lBagPtr + 32, 'long') - 1
		 $lItemPtr = MemoryRead($lItemArrayPtr + 4 * ($slot), 'ptr')
		 If $lItemPtr = 0 Then ContinueLoop
		 $lItemMID = MemoryRead($lItemPtr + 44, 'long')
		 $lQuantity = MemoryRead($lItemPtr + 75, 'byte')
		 If $aAlc And IsAlcohol($lItemMID) Then
			For $i = 1 To $lQuantity
			   UseItem($lItemPtr)
			   Sleep(125)
			Next
		 EndIf
		 If $aSweet And IsSweetOutpost($lItemMID) Then
			For $i = 1 To $lQuantity
			   UseItem($lItemPtr)
			   Sleep(125)
			Next
		 EndIf
		 If $aParty And IsParty($lItemMID) Then
			For $i = 1 To $lQuantity
			   UseItem($lItemPtr)
			   Sleep(125)
			Next
		 EndIf
	  Next
   Next
EndFunc

Func IsParty($aModelID)
   Switch $aModelID
	  Case 6368, 6369, 6376, 21809, 21810, 21813, 29543, 36683
		 Return True
	  Case Else
		 Return False
   EndSwitch
EndFunc

Func IsAlcohol($aModelID)
   Switch $aModelID
	  Case 910, 5585, 6049, 6375, 22190, 24593, 28435, 30855, 35124, 36682
		 Return True
	  Case Else
		 Return False
   EndSwitch
EndFunc

Func IsSweetOutpost($aModelID)
   Switch $aModelID
	  Case 36681, 21812, 21492, 22644
		 Return True
	  Case Else
		 Return False
   EndSwitch
EndFunc

Func SurvivorRank($Survivor = 1)
   Switch $Survivor
	  Case 1
		 Return 140600
	  Case 2
		 Return 587500
	  Case 3
		 Return 1337500
	  Case Else
		 Return 0
   EndSwitch
EndFunc   ;==>Rank
#EndRegion
#EndRegion

#Region Curtain
Func Curtain()
   $CurrentFarm = 'Black Curtain'
   TrayItemSetText($trayCurrent, $CurrentFarm)
   GUICTrlSetImage($picCurrent, "images\dust.jpg")
   Inventory()
   Sleep(1000)
   Do
	  LeaveToA()
	  Do
		 Sleep(250)
	  Until GetMapID() = 18
	  $Me = GetAgentPtr(-2)
	  $Skillbar = GetSkillbarPtr()
	  FarmDust()
	  Sleep(1000)
	  RefreshGW()
	  Inventory()
	  Sleep(1000)
	  While $BotPause
		 Sleep(1000)
	  WEnd
	  GUICtrlSetState($btPause, 64)
	  UpdateStatsMats()
   Until $CurrentDust >= $NeededDust Or Not $BotRunning
   GUICtrlSetState($btStart, 64)
EndFunc

Func LeaveToA()
   If GetMapID() <> 138 Then TravelTo(138)
   LoadSkillTemplate("OgCjkmrMbOfbzLBu5y9Zv73DMA")
   EquipScythe()
   While GetNumberOfPlayersInOutpost() > 3
	  DistrictChange(138)
   WEnd
   MoveTo(-5096, 16560)
   Move(-5200, 16000)
   Return WaitMapLoading(18)
EndFunc

Func FarmDust()
   Local $lWaypoints[22][2] = [[-6854, 14613], _
						     [-7761, 12286], _
							 [-6228, 7567], _
							 [-4783, 6108], _
							 [-2103, 3318], _
							 [2872, 273], _
							 [6008, -1207], _
							 [7653, -2127], _
							 [0, 0], _
							 [7348, -3619], _
							 [0, 0], _
							 [10026, -6060], _
							 [0, 0], _
							 [12097, -7507], _
							 [0, 0], _
							 [12769, -4257], _
							 [12857, 364], _
							 [0, 0], _
							 [12519, 1257], _
							 [0, 0], _
							 [10434, 1086], _
							 [0, 0]]
   For $i = 0 To 21
	  If $lWaypoints[$i][0] <> 0 Then
		 If Not RunDerv($lWaypoints[$i][0], $lWaypoints[$i][1]) Or GetMorale() < 0 Then Return False
	  Else
		 If Not CombatDerv() Or GetMorale() < 0 Then Return False
	  EndIf
   Next
EndFunc

Func RunDerv($aX, $aY)
   Local $lX, $lY
   Local $lAngle = 0
   Do
	  Move_($aX, $aY)
	  If Not GetIsMoving($Me) Then
		 UpdateAgentPosByPtr($Me, $lX, $lY)
		 $lAngle += 40
		 Move_($lX + 300 * Sin($lAngle), $lY + 300 * Cos($lAngle))
		 Sleep(500)
		 Move_($aX, $aY)
	  ElseIf GetSkillbarSkillRecharge(8, 0, $Skillbar) = 0 Then ; Pious Haste
		 UseSkillBySkillID(1540) ; Conviction for cover
		 Sleep(250)
		 UseSkillBySkillID(1543) ; Pious Haste
	  ElseIf MemoryRead($Me + 304, 'float') < 0.7 Then
		 If GetSkillbarSkillRecharge(7, 0, $Skillbar) = 0 And Not HasEffect(1531) Then ; Intimidating Aura
			UseSkillBySkillID(1531)
		 EndIf
		 If GetSkillbarSkillRecharge(6, 0, $Skillbar) = 0 And Not HasEffect(1516) Then ; Mystic Regeneration
			UseSkillBySkillID(1516)
		 EndIf
	  EndIf
	  Sleep(500)
	  If GetIsDead($Me) Then Return False
	  UpdateAgentPosByPtr($Me, $lX, $lY)
   Until (($aX - $lX) ^ 2 + ($aY - $lY) ^ 2) < 10000
   Return True
EndFunc

Func CombatDerv()
   TargetNearestEnemy()
   Sleep(50)
   $lPtr = GetCurrentTargetPtr()
   If $lPtr = 0 Then Return True
   While GetDistance($Me, $lPtr) < 1300
	  Do
		 Attack(-1)
		 While GetEnergy($Me) < 10
			Sleep(250)
		 WEnd
		 If GetSkillbarSkillRecharge(2, 0, $Skillbar) = 0 And Not HasEffect(1510) Then ; Sand Shards
			UseSkill(2, -2)
			$lDuration = 50
		 ElseIf GetSkillbarSkillRecharge(1, 0, $Skillbar) = 0 Then ; Vow of Strength
			UseSkill(1, -2)
			$lDuration = 250
		 ElseIf GetSkillbarSkillRecharge(6, 0, $Skillbar) = 0 And Not HasEffect(1516) Then ; Mystic Regeneration
			UseSkill(6, -2)
			$lDuration = 250
		 ElseIf GetSkillbarSkillRecharge(7, 0, $Skillbar) = 0 Then ; Armor of Sanctity
			UseSkill(7, -2)
			$lDuration = 250
		 ElseIf GetSkillbarSkillRecharge(3, 0, $Skillbar) = 0 Then ; Conviction
			UseSkill(3, -2)
			Sleep(50)
			UseSkill(4, -1)
			$lDuration = 1200
		 ElseIf MemoryRead($Skillbar + 84, 'long') >= 150 Then ; Whirlwind Attack
			UseSkill(5, -1)
			$lDuration = 1200
		 Else
			$lDuration = 250
		 EndIf
		 While MemoryRead($Skillbar + 176) <> 0
			Sleep(125)
		 WEnd
		 Sleep($lDuration)
		 If GetIsDead($Me) Or GetMorale() < 0 Then Return False
		 Until GetIsDead($lPtr)
		 PickUpLoot()
	  TargetNearestEnemy()
	  Sleep(50)
	  $lPtr = GetCurrentTargetPtr()
	  If $lPtr = 0 Then Return True
   WEnd
   While GetEnergy() < 30
	  Sleep(1000)
   WEnd
   Return True
EndFunc
#EndRegion

#Region Extra Functions
Func Out($aMsg)
   If $aMsg <> $OutText Then
	  $TimeStamp = "[" & @HOUR & ":" & @MIN & ":" & @SEC & "] "
	  $OutText = $aMsg
;~ 	  ConsoleWrite($TimeStamp & $aMsg & @CRLF)
	  WriteChat($TimeStamp & $aMsg, 0)
	  GUICtrlSetData($labelUpdateTime, $TimeStamp)
	  GUICtrlSetData($labelUpdateText, $aMsg)
   EndIf
EndFunc

Func ChangeWeaponSetToEquipped($aEquipped)
   Switch $aEquipped
	  Case 1
		 Return ChangeWeaponSet(1)
	  Case 2
		 Return ChangeWeaponSet(2)
	  Case 4
		 Return ChangeWeaponSet(3)
	  Case 8
		 Return ChangeWeaponSet(4)
   EndSwitch
EndFunc

Func CheckForMore()
   TargetNearestEnemy()
   Sleep(50)
   $lPtr = GetCurrentTargetPtr()
   If $lPtr = 0 Then Return
   Update("More: " & $lPtr)
   If GetDistance($Me, $lPtr) < 4000 Then Return $lPtr
EndFunc

Func DetectCinematic()
   $lTypeMap = MemoryRead(GetAgentPtr(-2) + 344, 'long')
   If BitAND($lTypeMap, 4194304) Or $lTypeMap = 0 Then
	  $Cinematic = False
	  Return False
   Else
	  $Cinematic = True
	  Update("Cinematic detected, skipping!")
	  SkipCinematic()
	  Return True
   EndIf
EndFunc

Func MoveToEx($x, $y, $random = 150)
   MoveTo($x, $y, $random)
EndFunc   ;==>MoveToEx

;~ Description: Returns the distance between two agents.
Func GetDistance2($aX1, $aY1, $aAgentPtr)
   Local $lX, $lY
   UpdateAgentPosByPtr($aAgentPtr, $lX, $lY)
   Return Sqrt(($aX1 - $lX) ^ 2 + ($aY1 - $lY) ^ 2)
EndFunc   ;==>GetDistance2

Func Inventory()
   While GetMapLoading() = 2
	  Sleep(1000)
   WEnd
   If CountSlots() > 10 Then Return True ; enough room
   Update("Travel to Guild Hall")
   If Not TravelGuildHall() Then TravelTo(642) ; no guild hall... travel to EotN
   Sleep(1000)
   $lGold = MinMaxGold()
   If $lGold < 1000 Then Return ; not enough gold
   Update("Storing Stuff")
   StoreItems()
   $lMapID = GetMapID()
   $lSlots = CountSlots()
   If $lSlots < 2 Then  ; no more free slots
	  If Not ClearInventorySpace($lMapID) Then
		 MsgBox(0,"Error","Inventory full. Please make room and try again.")
		 EnableRendering()
		 _exit()
	  EndIf
   ElseIf $lSlots > 10 Then
	  Return True ; enough room
   EndIf
   If GoToMerchant(GetDyeTrader($lMapID)) <> 0 Then SellDyes()
   Update("Buying Kits")
   GoToMerchant(GetMerchant($lMapID))
   BuyKits()
   Update("Identifying")
   Ident()
   Update("Salvaging")
   SalvageBags()
   StoreItems()
   UpdateStatsMats()
   Update("Selling")
   Sell()
   If GoToMerchant(GetRuneTrader($lMapID)) <> 0 Then SellUpgrades()
   If GoToMerchant(GetMaterialTrader($lMapID)) <> 0 Then
	  SellMaterials()
	  SellExcessMaterials()
   EndIf
   If GoToMerchant(GetScrollTrader($lMapID)) <> 0 Then SellScrolls()
   If GoToMerchant(GetRareMaterialTrader($lMapID)) <> 0 Then SellMaterials(True)
   If MinMaxGold() > 50000 Then
	  If $mMatExchangeGold = 0 Then
		 Update("Buying Lockpicks")
		 GoToMerchant(GetMerchant($lMapID))
		 $lAmount = Floor((GetGoldCharacter() - 10000) / 1500)
		 BuyItemByModelID(22751, $lAmount, 1500)
	  Else
		 Update("Buying Rare Materials")
		 Do
			TraderRequest($mMatExchangeGold)
			TraderBuy()
			Sleep(250)
		 Until GetGoldCharacter() <= 15000
	  EndIf
   EndIf
   Update("Buying Kits")
   GoToMerchant(GetMerchant($lMapID))
   BuyKits(40, False) ; stock up on normal salv kits for salvaging in between
   Sleep(1000)
   If GetMapID() <> 642 Then
	  LeaveGH()
	  WaitMapLoading()
   EndIf
EndFunc   ;==>Inventory

;~ Description: Sell materials.
Func SellExcessMaterials()
   UpdateStatsMats()
   $lSellIron = Floor(($CurrentIron - $NeededIron) / 10)
   $lSellDust = Floor(($CurrentDust - $NeededDust) / 10)
   $lSellBone = Floor(($CurrentBone - $NeededBone) / 10)
   $lSellFeather = Floor(($CurrentFeather - $NeededFeather) / 10)
   For $bag = 1 to 4 ; inventory only
	  $lBagPtr = GetBagPtr($bag)
	  If $lBagPtr = 0 Then ContinueLoop
	  For $slot = 1 to MemoryRead($lBagPtr + 32, 'long')
		 $lItemPtr = GetItemPtrBySlot($lBagPtr, $slot)
		 If $lItemPtr = 0 Then ContinueLoop
		 If MemoryRead($lItemPtr + 32, 'byte') <> 11 Then ContinueLoop ; not materials
		 Switch MemoryRead($lItemPtr + 44, 'long')
			Case 948 ; Iron
			   While $lSellIron > 0 And MemoryRead($lItemPtr + 75, 'byte') >= 10
				  Update("Sell Iron: " & $bag & ", " & $slot)
				  TraderRequestSell($lItemPtr)
				  Sleep(250)
				  TraderSell()
				  Sleep(250)
				  $lSellIron -= 1
				  If MemoryRead($lItemPtr + 12, 'ptr') = 0 Then ExitLoop
			   WEnd
			Case 921 ; Bone
			   While $lSellBone > 0 And MemoryRead($lItemPtr + 75, 'byte') >= 10
				  Update("Sell Bone: " & $bag & ", " & $slot)
				  TraderRequestSell($lItemPtr)
				  Sleep(250)
				  TraderSell()
				  Sleep(250)
				  $lSellBone -= 1
				  If MemoryRead($lItemPtr + 12, 'ptr') = 0 Then ExitLoop
			   WEnd
			Case 933 ; Feather
			   While $lSellFeather > 0 And MemoryRead($lItemPtr + 75, 'byte') >= 10
				  Update("Sell Feather: " & $bag & ", " & $slot)
				  TraderRequestSell($lItemPtr)
				  Sleep(250)
				  TraderSell()
				  Sleep(250)
				  $lSellFeather -= 1
				  If MemoryRead($lItemPtr + 12, 'ptr') = 0 Then ExitLoop
			   WEnd
			Case 929 ; Dust
			   While $lSellDust > 0 And MemoryRead($lItemPtr + 75, 'byte') >= 10
				  Update("Sell Dust: " & $bag & ", " & $slot)
				  TraderRequestSell($lItemPtr)
				  Sleep(250)
				  TraderSell()
				  Sleep(250)
				  $lSellDust -= 1
				  If MemoryRead($lItemPtr + 12, 'ptr') = 0 Then ExitLoop
			   WEnd
		 EndSwitch
	  Next
   Next
   UpdateStatsMats()
EndFunc   ;==>SellExcessMaterials
#EndRegion

#Region Autoit UDF
; #FUNCTION# ====================================================================================================================
; Author ........: Gary Frost (gafrost)
; Modified.......:
; ===============================================================================================================================
Func _GUICtrlComboBox_GetCurSel($hWnd)
   If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)
   Return _SendMessage($hWnd, 0x147)
EndFunc   ;==>_GUICtrlComboBox_GetCurSel

; #FUNCTION# ====================================================================================================================
; Author ........: Valik
; Modified.......: Gary Frost (GaryFrost) aka gafrost
; ===============================================================================================================================
Func _SendMessage($hWnd, $iMsg, $wParam = 0, $lParam = 0, $iReturn = 0, $wParamType = "wparam", $lParamType = "lparam", $sReturnType = "lresult")
   Local $aResult = DllCall("user32.dll", $sReturnType, "SendMessageW", "hwnd", $hWnd, "uint", $iMsg, $wParamType, $wParam, $lParamType, $lParam)
   If @error Then Return SetError(@error, @extended, "")
   If $iReturn >= 0 And $iReturn <= 4 Then Return $aResult[$iReturn]
   Return $aResult
EndFunc   ;==>_SendMessage
#EndRegion