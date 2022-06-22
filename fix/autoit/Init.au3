Global $charName = ""
Global $ProcessID = ""
Global $cmdmode = false
Global $timer = TimerInit()

Global Const $doLoadLoggedChars = True

Global $RenderingEnabled = True
Global $RunCount = 0
Global $FailCount = 0
Global $BotRunning = False
Global $BotInitialized = False
Global $ChatStuckTimer = Timer()
Global $Deadlocked = False
Global $CurGold = 0


If $CmdLine[0] = 0 Then
Else
    $cmdmode = true

    If 1 > UBound($CmdLine)-1 Then exit; element is out of the array bounds
    If 2 > UBound($CmdLine)-1 Then exit;

    $charName  = $CmdLine[1]
    $ProcessID = $CmdLine[2]
    LOGIN($charName, $ProcessID)
EndIf