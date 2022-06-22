#include <ButtonConstants.au3>
#include <GWA2_18052018.au3>
#include <ComboConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <ScrollBarsConstants.au3>
#include <Misc.au3>
#include <EditConstants.au3>
#include <GuiEdit.au3>
#include "GUI.au3"
#NoTrayIcon

$Character = "" ; Put the Character Name between the ""

Initialize($Character)

Func Out()
	GUICtrlSetData($lAction, "[" & @HOUR & ":" & @MIN & "]" & " " & $Character)
EndFunc

Func UseSkillEx($aSkillSlot, $aTarget)
	$tDeadlock = TimerInit()
	USESKILL($aSkillSlot, $aTarget)
	Do
		Sleep(50)
	Until GetSkillBarSkillRecharge($aSkillSlot) <> 0 Or TimerDiff($tDeadlock) > 2000
EndFunc   ;==>UseSkillEx

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
		If CanPickUp($lItem) Then
			Do
				If GetMapLoading() == 2 Then Disconnected()
				If GetDistance($lAgent) > 143 Then Move(DllStructGetData($lAgent, 'X'), DllStructGetData($lAgent, 'Y'), 100)
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

Func CanPickUp($aitem)
	$m = DllStructGetData($aitem, 'ModelID')
	$r = GetRarity($aitem)
	$t = DllStructGetData($aitem, 'Type')
	$e = DllStructGetData($aitem, 'ExtraID')
	$req = GetItemReq($aitem)
	
	Switch $m
		Case 146 ; Dyes
			If $e = 10 Then Return True ; Black
		Case 22751 ; Lockpicks
			Return True
		Case 819, 934, 937 ; Dragon roots, Fibers, Ruby
			Return True
		Case 22752, 22269, 28436, 31152, 31151, 31153, 35121, 28433, 26784, 6370, 21488, 21489, 22191, 24862, 21492, 22644, 30855, 5585, 24593, 6375, 22190, 6049, 910, 6369, 21809, 21810, 21813, 6376, 6368, 29436, 21491, 28434, 21812, 35124
			Return True ; Pcons, even stuff
		Case 944, 945 ; Echovalds
			If $r = 2624 and $req = 9 Then Return True
		Case 950, 951 ; Gothics
			If $r = 2624 and $req = 9 Then Return True
		Case 940, 941 ; Ambers
			If $r = 2624 and $req = 9 Then Return True
		Case 954, 955 ; Ornates
			If $r = 2624 and $req = 9 Then Return True
	EndSwitch

	If $t = 20 Then Return True ; Gold Coins
EndFunc

Func Freeway()
	$ee_target = GetNearestNPCToAgent(-2)
	UseHeroSkill(1, 2, -2)
	UseHeroSkill(1, 3, -2)
	CommandHero(1, -8017, 18090)
	MoveTo(-9336, 18893)
	UseSkillEx(6, $ee_target)
	MoveTo(-6633, 17375)
	UseHeroSkill(1, 1)
	UseSkillEx(1, -2)
	UseSkillEx(2, -2)
	UseSkillEx(3, -2)
EndFunc

Func MossBall()
	MoveTo(-5263, 15803)
	UseSkillEx(4, -2)
	CommandHero(1, -11546, 19525)
	MoveTo(-5833, 15963)
	MoveTo(-6253, 17432, 1)
	Sleep(200)
	UseSkillEx(7, -2)
	Sleep(200)
	MoveTo(-6131, 17952)
	Sleep(200)
	MoveTo(-6777, 18816, 1)
	
	Do
		Sleep(200)
	Until GetSkillbarSkillRecharge(2) == 0 Or GetIsDead(-2)
	
	UseSkillEx(2, -2)
EndFunc

Func Spike()
	UseSkillEx(8, -2)
	UseSkillEx(5, -2)

	Do
		Sleep(200)
	Until GetDistance(GetNearestEnemyToAgent(-2), -2) > 168 Or GetIsDead(-2) Or GetInstanceUpTime() > 75000
EndFunc

Func GoingOut()
	SwitchMode(1)
	Do
		Move(-11172, -23105)
		Sleep(200)
	Until WaitMapLoading(195)
	Sleep(GetPing() + 50)
EndFunc

Func GoingIn()
	Do
		Move(-11232, 20001)
		Sleep(200)
	Until WaitMapLoading(349)
	Sleep(GetPing() + 50)
EndFunc

Func FastResign()
	GoingOut()
	GoingIn()
EndFunc


Func Main()
	Out()

	If $Runs == 0 Then 
		$PlayerTemplate = "OgcTcZ88ZC5Qn5A64wtkuM0R4AA"
		$HeroTemplate = "OQKigxm88cuxAAAAAAAAAAAA"
		KickAllHeroes()
		If GetMapID() <> 349 Then TravelTo(349)
		LoadSkillTemplate($PlayerTemplate)
		AddHero(11)
		Sleep(400)
		LoadSkillTemplate($HeroTemplate, 1)
		DisableHeroSkillSlot(1, 1)
		DisableHeroSkillSlot(1, 2)
		FastResign()
	EndIf

	GoingOut()
	Freeway()
	MossBall()
	Spike()

	If GetIsDead(-2) Then
		Resign()
		GUIUpdateFAIL()
		Sleep(5000)
	Else
		Sleep(200)
		PickUpLoot()
		Sleep(200)
		Resign()
		GUIUpdateWIN()
		Sleep(5000)
	EndIf

	ReturnToOutpost()
	WaitMapLoading(349)
	Sleep(GetPing() + 50)
EndFunc

While 1
	If $boolrun Then
		If $Option3 = True Then Purge()
		Main()
	EndIf
WEnd