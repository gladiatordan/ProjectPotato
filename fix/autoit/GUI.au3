#Region GUI

Global $LONGEYE = True

Global Const $mainGui = GuiCreate($PotatoName, 234, 497, 373, 366)
GUISetIcon(@ScriptDir & "\Mesmer_Tango.ico")
TraySetIcon(@ScriptDir & "\Mesmer_Tango.ico")
GUISetOnEvent($GUI_Event_Close, "_exit")

Global $Input

If $doLoadLoggedChars Then
	$Input = GUICtrlCreateCombo($charName, 8, 8, 217, 25)
	GUICtrlSetData(-1, GetLoggedCharNames())
Else
	$Input = GUICtrlCreateInput("Character Name", 8, 8, 217, 25)
EndIf

Global Const $RunsLabel = GUICtrlCreateLabel("Runs: " & $RunCount, 8, 444, 59, 17)
Global Const $FailsLabel = GUICtrlCreateLabel("Fails: " & $FailCount, 100, 444, 59, 17)
Global Const $Button = GUICtrlCreateButton("Start", 8, 409, 219, 31)
GUICtrlSetOnEvent($Button, "GuiButtonHandler")

Global $GUI_Console = GUICtrlCreateEdit("", 16, 257, 201, 142, BitOR($ES_AUTOVSCROLL, $ES_AUTOHSCROLL, $ES_WANTRETURN, $WS_VSCROLL))

Global Const $Tomes = GUICtrlCreateCheckbox("Regular Tomes", 8, 40, 100, 20)
Global Const $EliteTomes = GUICtrlCreateCheckbox("Elite Tomes", 8, 60, 100, 20)
Global Const $Dyes = GUICtrlCreateCheckbox("Dyes", 110, 40, 100, 20)
Global Const $Gold = GUICtrlCreateCheckbox("Money", 110, 60, 100, 20)
Global Const $GlacialStones = GUICtrlCreateCheckbox("Glacial Stones", 8, 80, 100, 20)

GUISetState(@SW_SHOW)
GUISetOnEvent($GUI_Event_Close, "GuiButtonHandler")
#EndRegion GUI

Func GuiButtonHandler()
	Switch @GUI_CtrlID
		Case $Button
			If $BotRunning Then
				If