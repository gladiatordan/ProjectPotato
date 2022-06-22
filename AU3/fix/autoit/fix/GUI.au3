#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.8.1
 Author:         myName

 Script Function:
	Template AutoIt script.

#ce ----------------------------------------------------------------------------

; Script Start - Add your code below here
#include-once
#include <String.au3>
#include <GuiComboBox.au3>
#include <ComboConstants.au3>
#include <ButtonConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <File.au3>
#include <GuiEdit.au3>
#include <inet.au3>


#region GUIGlobals
Global $GUITitle = "Fiber"
Global $NewGUITitle
Global $boolrun = False
Global $WeakCounter = 0
Global $Sec = 0
Global $Min = 0
Global $Hour = 0
Global $Runs = 0
Global $GoodRuns = 0
Global $BadRuns = 0
Global $Option1 = True
Global $Option2 = False
Global $Option3 = False
#endregion GUIGlobals

#region GUI
Opt("GUIOnEventMode", 1)
$cGUI = GUICreate($GUITitle&"", 466, 301, 191, 196)
WinSetTrans($cGUI,"",200)
_GuiRoundCorners($cGUI,35)
$gMain = GUICtrlCreateGroup("Main", 0, 24, 201, 81)
$bStart = GUICtrlCreateButton("Start", 8, 64, 89, 33)
$bStahp = GUICtrlCreateButton("Stop", 104, 64, 89, 33)
GUICtrlSetState(-1,$GUI_DISABLE)
GUICtrlCreateGroup("", -99, -99, 1, 1)
$gOpt = GUICtrlCreateGroup("Options", 8, 112, 89, 113)
$Opt3 = GUICtrlCreateCheckbox("Rendering", 16, 184, 75, 17)
GUICtrlCreateGroup("", -99, -99, 1, 1)
$lTime = GUICtrlCreateLabel("00:00:00", 16, 232, 175, 57, BitOR($SS_CENTER,$SS_CENTERIMAGE), $WS_EX_STATICEDGE)
GUICtrlSetFont(-1, 24, 800, 0, "MS Sans Serif")
$gStats = GUICtrlCreateGroup("Stats", 120, 112, 81, 113)
$cRuns = GUICtrlCreateLabel("Runs:", 128, 136, 32, 17)
$lRuns = GUICtrlCreateLabel("0", 168, 136, 18, 17)
$cWins = GUICtrlCreateLabel("Wins:", 128, 168, 31, 17)
$lWins = GUICtrlCreateLabel("0", 168, 168, 26, 17)
$cFails = GUICtrlCreateLabel("Fails", 128, 200, 25, 17)
$lFails = GUICtrlCreateLabel("0", 168, 200, 10, 17)
GUICtrlCreateGroup("", -99, -99, 1, 1)
$lAction = GUICtrlCreateEdit("", 209, 24, 255, 275, BitOR($GUI_SS_DEFAULT_EDIT,$ES_READONLY,$WS_BORDER))
GUICtrlSetData(-1, "")
GUICtrlSetFont(-1, 9, 400, 0, "Arial")
GUICtrlSetBkColor(-1,0x000000)
GUICtrlSetColor(-1, 0x00FF00)
GUICtrlSetCursor (-1, 5)
$Label1 = GUICtrlCreateLabel("", 8, 0, 352, 19, -1)
GUICtrlSetFont(-1, 11, 800, 0, "Comic Sans MS")
GUISetState(@SW_SHOW)

GUICtrlSetOnEvent($bStart, "GUIHandler")
GUICtrlSetOnEvent($bStahp, "GUIHandler")
GUICtrlSetOnEvent($Opt3, "GUIHandler")
GUISetOnEvent($GUI_EVENT_CLOSE, "GUIHandler")



GUISetState(@SW_SHOW)
#endregion GUI

#region GUIFuncs
Func GUIHandler()
	Switch (@GUI_CtrlId)
		Case $bStart
			$boolrun = True
			GUICtrlSetState($bStahp, $GUI_ENABLE)
			GUICtrlSetState($bStart, $GUI_DISABLE)
			GUICtrlSetState($Opt3, $GUI_ENABLE)
			AdlibRegister("TimeUpdater", 1000)
			;AdLibRegister("DeathCheck",1000)
		Case $bStahp
			$boolrun = False
			$Firstrun = True
			GUICtrlSetState($bStahp, $GUI_DISABLE)
			GUICtrlSetState($bStart, $GUI_ENABLE)
			AdlibUnRegister("TimeUpdater")
			;AdLibUnRegister("DeathCheck")
			;Reset()
		Case $Opt3
			If GUICtrlRead($Opt3) = $GUI_CHECKED Then
				RenderOff()
				$Option3 = True
			ElseIf GUICtrlRead($Opt3) = $GUI_UNCHECKED Then
				RenderOn()
				$Option3 = False
			EndIf
		Case $GUI_EVENT_CLOSE
			Exit
	EndSwitch
EndFunc   ;==>GUIHandler

Func Purge()
;~ 	upd("Purging engine hook")
	RenderOn()
	Sleep(Random(2000, 2500))
	RenderOff()
EndFunc   ;==>Purge

Func RenderOff()
;~ 	upd("Rendering Off")
	DisableRendering()
	WinSetState(GetWindowHandle(), "", @SW_HIDE)
EndFunc   ;==>RenderOff

Func RenderOn()
;~ 	upd("Rendering On")
	EnableRendering()
	WinSetState(GetWindowHandle(), "", @SW_SHOW)
EndFunc   ;==>RenderOn

Func Reset()
	$WeakCounter = 0
	$Sec = 0
	$Min = 0
	$Hour = 0
	$Runs = 0
	$GoodRuns = 0
	$BadRuns = 0
	GUICtrlSetData($lTime, "00:00:00")
	GUICtrlSetData($lRuns, "0")
	GUICtrlSetData($lWins, "0")
	GUICtrlSetData($lFails, "0")
EndFunc   ;==>Reset

Func GUIUpdateWIN()
	$Runs += 1
	$GoodRuns += 1
	GUICtrlSetData($lRuns, $Runs)
	GUICtrlSetData($lWins, $GoodRuns)
EndFunc   ;==>GUIUpdate

Func GUIUpdateFAIL()
	$Runs += 1
	$BadRuns += 1
	GUICtrlSetData($lRuns, $Runs)
	GUICtrlSetData($lFails, $BadRuns)
EndFunc   ;==>GUIUpdate

Func TimeUpdater()
	$WeakCounter += 1

	$Sec += 1
	If $Sec = 60 Then
		$Min += 1
		$Sec = $Sec - 60
	EndIf

	If $Min = 60 Then
		$Hour += 1
		$Min = $Min - 60
	EndIf

	If $Sec < 10 Then
		$L_Sec = "0" & $Sec
	Else
		$L_Sec = $Sec
	EndIf

	If $Min < 10 Then
		$L_Min = "0" & $Min
	Else
		$L_Min = $Min
	EndIf

	If $Hour < 10 Then
		$L_Hour = "0" & $Hour
	Else
		$L_Hour = $Hour
	EndIf

	GUICtrlSetData($lTime, $L_Hour & ":" & $L_Min & ":" & $L_Sec)
EndFunc   ;==>TimeUpdater

Func Upd($AMSG)
	Local $LTEXTLEN = StringLen($AMSG)
	Local $LCONSOLELEN = _GUICtrlEdit_GetTextLen($lAction)
	If $LTEXTLEN + $LCONSOLELEN > 30000 Then GUICtrlSetData($lAction, StringRight(_GUICtrlEdit_GetText($lAction), 30000 - $LTEXTLEN - 1000))
	_GUICtrlEdit_AppendText($lAction, @CRLF & $AMSG)
	_GUICtrlEdit_Scroll($lAction, 1)
EndFunc   ;==>Upd


Func _GuiRoundCorners($h_win, $iSize)
	Local $XS_pos, $XS_ret
	$XS_pos = WinGetPos($h_win)
	$XS_ret = DllCall("gdi32.dll", "long", "CreateRoundRectRgn", "long", 0, "long", 0, "long", $XS_pos[2] + 1, "long", $XS_pos[3] + 1, "long", $iSize, "long", $iSize)
	If $XS_ret[0] Then
		DllCall("user32.dll", "long", "SetWindowRgn", "hwnd", $h_win, "long", $XS_ret[0], "int", 1)
	EndIf
EndFunc   ;==>_GuiRoundCorners

#endregion GUIFuncs3