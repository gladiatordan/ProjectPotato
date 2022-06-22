#include-once

#Region Ptr
;~ Description: Returns Agent ptr by AgentID.
Func GetAgentPtr($aAgentID)
   Local $lOffset[3] = [0, 4 * ConvertID($aAgentID),0]
   Local $lAgentStructAddress = MemoryReadPtr($mAgentBase, $lOffset, 'ptr')
   Return $lAgentStructAddress[0]
EndFunc   ;==>GetAgentPtr

;~ Description: Returns agentptr by playernumber.
Func GetPlayerPtrByPlayerNumber($aPlayerNumber)
   Local $lAgentArray = GetAgentPtrArrayEx(1)
   For $i = 1 to $lAgentArray[0]
	  If MemoryRead($lAgentArray[$i] + 244, 'word') = $aPlayerNumber Then Return $lAgentArray[$i]
   Next
EndFunc   ;==>GetPlayerPtrByPlayerNumber

#Region AgentPtrArray
;~ Description: Pulls only ptrs instead of whole struct from memory.
;~ Authors: 4D1, Testytest
Func GetAgentPtrArray($aType = Default, $aAllegiance = Default, $aDead = Default)
   Local $lCount
   Local $lBuffer = ''
   DllStructSetData($mMakeAgentArrayEx, 2, $aType)
   MemoryWrite($mAgentCopyCount, -1, 'long')
   Enqueue($mMakeAgentArrayExPtr, 8)
   Local $lDeadlock = TimerInit()
   Do
	  Sleep(1)
	  $lCount = MemoryRead($mAgentCopyCount, 'long')
   Until $lCount >= 0 Or TimerDiff($lDeadlock) > 5000
   If $lCount < 0 Then $lCount = 0
   For $i = 1 To $lCount
	  $lBuffer &= 'ptr;'
   Next
   $lBuffer = DllStructCreate($lBuffer)
   DllCall($mKernelHandle, 'int', 'ReadProcessMemory', 'int', $mGWProcHandle, 'int', $mAgentCopyBase, 'ptr', DllStructGetPtr($lBuffer), 'int', DllStructGetSize($lBuffer), 'int', '')
   Local $lReturnArray[$lCount + 1]
   Local $lArrCount = 0
   For $i = 1 To $lCount
	  Local $lTemp = DllStructGetData($lBuffer, $i)
	  If $aType <> Default And MemoryRead($lTemp + 156, 'long') <> $aType Then ContinueLoop
	  If $aAllegiance <> Default And MemoryRead($lTemp + 433, 'byte') <> $aAllegiance Then ContinueLoop
	  If $aDead <> Default And MemoryRead($lTemp + 304, 'float') <= 0 Then ContinueLoop
	  If $aDead <> Default And BitAND(MemoryRead($lTemp + 312, 'long'), 0x0010) > 0 Then ContinueLoop
	  $lArrCount += 1
	  $lReturnArray[$lArrCount] = $lTemp
	  $lReturnArray[$i] = DllStructGetData($lBuffer, $i)
   Next
   $lReturnArray[0] = $lArrCount
   ReDim $lReturnArray[$lArrCount+1]
   Return $lReturnArray
EndFunc   ;==>GetAgentPtrArray

;~ Description: Pulls only ptrs instead of whole struct from memory.
Func GetAgentPtrArrayEx($aMode = 0, $aType = 0xDB, $aAllegiance = 3, $aDead = True)
   Local $lCount
   Local $lBuffer = ''
   DllStructSetData($mMakeAgentArrayEx, 2, $aType)
   MemoryWrite($mAgentCopyCount, -1, 'long')
   Enqueue($mMakeAgentArrayExPtr, 8)
   Local $lDeadlock = TimerInit()
   Do
	  Sleep(1)
	  $lCount = MemoryRead($mAgentCopyCount, 'long')
   Until $lCount >= 0 Or TimerDiff($lDeadlock) > 5000
   If $lCount < 0 Then $lCount = 0
   For $i = 1 To $lCount
	  $lBuffer &= 'ptr;'
   Next
   $lBuffer = DllStructCreate($lBuffer)
   DllCall($mKernelHandle, 'int', 'ReadProcessMemory', 'int', $mGWProcHandle, 'int', $mAgentCopyBase, 'ptr', DllStructGetPtr($lBuffer), 'int', DllStructGetSize($lBuffer), 'int', '')
   Local $lReturnArray[$lCount + 1]
   Switch $aMode
	  Case 0
		 For $i = 1 To $lCount
			$lReturnArray[$i] = DllStructGetData($lBuffer, $i)
		 Next
		 $lReturnArray[0] = $lCount
	  Case 1
		 Local $lArrCount = 0
		 For $i = 1 To $lCount
			Local $lTemp = DllStructGetData($lBuffer, $i)
			If MemoryRead($lTemp + 156, 'long') <> $aType Then ContinueLoop
			$lArrCount += 1
			$lReturnArray[$lArrCount] = $lTemp
		 Next
		 $lReturnArray[0] = $lArrCount
		 ReDim $lReturnArray[$lArrCount+1]
	  Case 2
		 Local $lArrCount = 0
		 For $i = 1 To $lCount
			Local $lTemp = DllStructGetData($lBuffer, $i)
			If MemoryRead($lTemp + 156, 'long') <> $aType Then ContinueLoop
			If MemoryRead($lTemp + 433, 'byte') <> $aAllegiance Then ContinueLoop
			$lArrCount += 1
			$lReturnArray[$lArrCount] = $lTemp
		 Next
		 $lReturnArray[0] = $lArrCount
		 ReDim $lReturnArray[$lArrCount+1]
	  Case 3
		 Local $lArrCount = 0
		 For $i = 1 To $lCount
			Local $lTemp = DllStructGetData($lBuffer, $i)
			If MemoryRead($lTemp + 156, 'long') <> $aType Then ContinueLoop
			If MemoryRead($lTemp + 433, 'byte') <> $aAllegiance Then ContinueLoop
			If MemoryRead($lTemp + 304, 'float') <= 0 Then ContinueLoop
			If BitAND(MemoryRead($lTemp + 312, 'long'), 0x0010) > 0 Then ContinueLoop
			$lArrCount += 1
			$lReturnArray[$lArrCount] = $lTemp
		 Next
		 $lReturnArray[0] = $lArrCount
		 ReDim $lReturnArray[$lArrCount+1]
   EndSwitch
   Return $lReturnArray
EndFunc   ;==>GetAgentPtrArrayEx

;~ Description: Returns array with all AgentPtrs in range. (slow)
Func GetAgentPtrArray_()
   Local $lCount = GetMaxAgents()
   Local $RetArr[$lCount+2][2]
   Local $lPtrCount = 0
   Local $lBasePtr = MemoryRead($mAgentBase)
   For $i = 0 to $lCount
	  Local $lAgentPtr = MemoryRead($lBasePtr + $i * 0x4, 'ptr')
	  If $lAgentPtr = 0 Then ContinueLoop
	  $lPtrCount += 1
	  $RetArr[$lPtrCount][0] = $lAgentPtr
	  $RetArr[$lPtrCount][1] = $i
   Next
   $RetArr[0][0] = $lPtrCount
   ReDim $RetArr[$lPtrCount+1][2]
   Return $RetArr
EndFunc   ;==>GetAgentPtrArray_

;~ Description: Returns array of agents of same type (npc, player etc.). (unreliable, but very fast)
Func GetAgentPtrCylceNext($aStartID = -1, $aMode = 0, $aType = -1, $aAllegiance = -1, $aDead = False)
   Local $lStart = GetAgentPtr($aStartID)
   If $lStart = 0 Then
	  Local $RetArr[1] = [0]
	  Return $RetArr
   EndIf
   Local $lNext = $lStart
   Local $lPtrCount = 1
   Local $lCount = GetMaxAgents()
   Local $RetArr[$lCount+2]
   $RetArr[1] = $lStart
   If $aMode = 0 Then
	  For $i = 1 To $lCount
		 $lNext = MemoryRead($lNext + 32, 'ptr')
		 If $lNext = 0 Then ExitLoop
		 If $lNext = $lStart Then ContinueLoop
		 $lPtrCount += 1
		 $RetArr[$lPtrCount] = $lNext
	  Next
   ElseIf $aMode = 1 Then ; only type
	  For $i = 1 To $lCount
		 $lNext = MemoryRead($lNext + 32, 'ptr')
		 If $lNext = 0 Then ExitLoop
		 If $lNext = $lStart Then ContinueLoop
		 If MemoryRead($lNext + 156, 'long') <> $aType Then ContinueLoop
		 $lPtrCount += 1
		 $RetArr[$lPtrCount] = $lNext
	  Next
   ElseIf $aMode = 2 Then ; type and allegiance
	  For $i = 1 To $lCount
		 $lNext = MemoryRead($lNext + 32, 'ptr')
		 If $lNext = 0 Then ExitLoop
		 If $lNext = $lStart Then ContinueLoop
		 If MemoryRead($lNext + 156, 'long') <> $aType Then ContinueLoop
		 If MemoryRead($lNext + 433, 'byte') <> $aAllegiance Then ContinueLoop
		 $lPtrCount += 1
		 $RetArr[$lPtrCount] = $lNext
	  Next
   Else
	  For $i = 1 To $lCount ; type and allegiance and alive
		 $lNext = MemoryRead($lNext + 32, 'ptr')
		 If $lNext = 0 Then ExitLoop
		 If $lNext = $lStart Then ContinueLoop
		 If MemoryRead($lNext + 156, 'long') <> $aType Then ContinueLoop
		 If MemoryRead($lNext + 433, 'byte') <> $aAllegiance Then ContinueLoop
		 If MemoryRead($lNext + 304, 'float') <= 0 Then ContinueLoop
		 If BitAND(MemoryRead($lNext + 312, 'long'), 0x0010) > 0 Then ContinueLoop
		 $lPtrCount += 1
		 $RetArr[$lPtrCount] = $lNext
	  Next
   EndIf
   $RetArr[0] = $lPtrCount
   ReDim $RetArr[$lPtrCount+1]
   Return $RetArr
EndFunc   ;==>GetAgentPtrCylceNext
#EndRegion AgentPtrArray

;~ Description: Returns the nearest agent to an agent.
Func GetNearestAgentPtrToAgent($aAgent = -1)
   Local $lAgentX, $lAgentY, $lArrayX, $lArrayY
   If IsPtr($aAgent) <> 0 Then
	  Local $lAgentID = MemoryRead($aAgent + 44, 'long')
	  UpdateAgentPosByPtr($aAgent, $lAgentX, $lAgentY)
   ElseIf IsDllStruct($aAgent) <> 0 Then
	  Local $lAgentID = DllStructGetData($aAgent, 'ID')
	  $lAgentX = DllStructGetData($aAgent, 'X')
	  $lAgentY = DllStructGetData($aAgent, 'Y')
   Else
	  Local $lAgentID = ConvertID($aAgent)
	  UpdateAgentPosByPtr(GetAgentPtr($aAgent), $lAgentX, $lAgentY)
   EndIf
   Local $lNearestAgent, $lDistance, $lNearestDistance = 25000000
   Local $lAgentArray = GetAgentPtrArrayEx()
   For $i = 1 To $lAgentArray[0]
	  If MemoryRead($lAgentArray[$i] + 44, 'long') = $lAgentID Then ContinueLoop
	  UpdateAgentPosByPtr($lAgentArray[$i], $lArrayX, $lArrayY)
	  $lDistance = ($lAgentX - $lArrayX) ^ 2 + ($lAgentY - $lArrayY) ^ 2
	  If $lDistance < $lNearestDistance Then
		 $lNearestAgent = $lAgentArray[$i]
		 $lNearestDistance = $lDistance
	  EndIf
   Next
   SetExtended(Sqrt($lNearestDistance))
   Return $lNearestAgent
EndFunc   ;==>GetNearestAgentPtrToAgent

;~ Description: Returns the nearest enemy to an agent.
Func GetNearestEnemyPtrToAgent($aAgent = -2)
   Local $lAgentX, $lAgentY, $lArrayX, $lArrayY
   If IsPtr($aAgent) <> 0 Then
	  Local $lAgentID = MemoryRead($aAgent + 44, 'long')
	  UpdateAgentPosByPtr($aAgent, $lAgentX, $lAgentY)
   ElseIf IsDllStruct($aAgent) <> 0 Then
	  Local $lAgentID = DllStructGetData($aAgent, 'ID')
	  Local $lAgentX = DllStructGetData($aAgent, 'X')
	  Local $lAgentY = DllStructGetData($aAgent, 'Y')
   Else
	  Local $lAgentID = ConvertID($aAgent)
	  UpdateAgentPosByPtr(GetAgentPtr($aAgent), $lAgentX, $lAgentY)
   EndIf
   Local $lNearestAgent, $lDistance, $lNearestDistance = 25000000
   Local $lAgentArray = GetAgentPtrArrayEx(3)
   For $i = 1 To $lAgentArray[0]
	  If MemoryRead($lAgentArray[$i] + 44, 'long') = $lAgentID Then ContinueLoop
	  UpdateAgentPosByPtr($lAgentArray[$i], $lArrayX, $lArrayY)
	  $lDistance = ($lAgentX - $lArrayX) ^ 2 + ($lAgentY - $lArrayY) ^ 2
	  If $lDistance < $lNearestDistance Then
		 $lNearestAgent = $lAgentArray[$i]
		 $lNearestDistance = $lDistance
	  EndIf
   Next
   SetExtended(Sqrt($lNearestDistance))
   Return $lNearestAgent
EndFunc   ;==>GetNearestEnemyPtrToAgent

;~ Description: Returns the enemy farthest away from an agent within given max distance.
Func GetFarthestEnemyPtrToAgent($aMaxDistance = 1400, $aAgent = -2)
   Local $lAgentX, $lAgentY, $lArrayX, $lArrayY
   If IsPtr($aAgent) <> 0 Then
	  Local $lAgentID = MemoryRead($aAgent + 44, 'long')
	  UpdateAgentPosByPtr($aAgent, $lAgentX, $lAgentY)
   ElseIf IsDllStruct($aAgent) <> 0 Then
	  Local $lAgentID = DllStructGetData($aAgent, 'ID')
	  Local $lAgentX = DllStructGetData($aAgent, 'X')
	  Local $lAgentY = DllStructGetData($aAgent, 'Y')
   Else
	  Local $lAgentID = ConvertID($aAgent)
	  UpdateAgentPosByPtr(GetAgentPtr($lAgentID), $lAgentX, $lAgentY)
   EndIf
   Local $lFarthestAgent, $lDistance, $lFarthestDistance = 1
   Local $lMaxDistance = $aMaxDistance ^ 2
   Local $lAgentArray = GetAgentPtrArrayEx(3)
   For $i = 1 To $lAgentArray[0]
	  If MemoryRead($lAgentArray[$i] + 44, 'long') = $lAgentID Then ContinueLoop
	  UpdateAgentPosByPtr($lAgentArray[$i], $lArrayX, $lArrayY)
	  $lDistance = ($lAgentX - $lArrayX) ^ 2 + ($lAgentY - $lArrayY) ^ 2
	  If $lDistance > $lFarthestDistance And $lDistance < $lMaxDistance Then
		 $lFarthestAgent = $lAgentArray[$i]
		 $lFarthestDistance = $lDistance
	  EndIf
   Next
   SetExtended(Sqrt($lFarthestDistance))
   Return $lFarthestAgent
EndFunc   ;==>GetFarthestEnemyPtrToAgent

;~ Description: Returns the nearest agent to a set of coordinates.
Func GetNearestAgentPtrToCoords($aX, $aY)
   Local $lNearestAgent, $lNearestDistance = 100000000
   Local $lDistance, $lArrayX, $lArrayY
   Local $lAgentArray = GetAgentPtrArrayEx()
   For $i = 1 To $lAgentArray[0]
	  UpdateAgentPosByPtr($lAgentArray[$i], $lArrayX, $lArrayY)
	  $lDistance = ($aX - $lArrayX) ^ 2 + ($aY - $lArrayY) ^ 2
	  If $lDistance < $lNearestDistance Then
		 $lNearestAgent = $lAgentArray[$i]
		 $lNearestDistance = $lDistance
	  EndIf
   Next
   SetExtended(Sqrt($lNearestDistance))
   Return $lNearestAgent
EndFunc   ;==>GetNearestAgentPtrToCoords

;~ Description: Returns the nearest signpost to an agent.
Func GetNearestSignpostPtrToAgent($aAgent = -2)
   Local $lAgentX, $lAgentY, $lArrayX, $lArrayY
   If IsPtr($aAgent) <> 0 Then
	  Local $lAgentID = MemoryRead($aAgent + 44, 'long')
	  UpdateAgentPosByPtr($aAgent, $lAgentX, $lAgentY)
   ElseIf IsDllStruct($aAgent) <> 0 Then
	  Local $lAgentID = DllStructGetData($aAgent, 'ID')
	  Local $lAgentX = DllStructGetData($aAgent, 'X')
	  Local $lAgentY = DllStructGetData($aAgent, 'Y')
   Else
	  Local $lAgentID = ConvertID($aAgent)
	  UpdateAgentPosByPtr(GetAgentPtr($aAgent), $lAgentX, $lAgentY)
   EndIf
   Local $lNearestAgent, $lDistance, $lNearestDistance = 100000000
   Local $lAgentArray = GetAgentPtrArrayEx(1, 0x200)
   For $i = 1 To $lAgentArray[0]
	  If MemoryRead($lAgentArray[$i] + 44, 'long') = $lAgentID Then ContinueLoop
	  UpdateAgentPosByPtr($lAgentArray[$i], $lArrayX, $lArrayY)
	  $lDistance = ($lAgentX - $lArrayX) ^ 2 + ($lAgentY - $lArrayY) ^ 2
	  If $lDistance < $lNearestDistance Then
		 $lNearestAgent = $lAgentArray[$i]
		 $lNearestDistance = $lDistance
	  EndIf
   Next
   SetExtended(Sqrt($lNearestDistance))
   Return $lNearestAgent
EndFunc   ;==>GetNearestSignpostPtrToAgent

;~ Description: Returns the nearest signpost to a set of coordinates.
Func GetNearestSignpostPtrToCoords($aX, $aY)
   Local $lNearestAgent, $lNearestDistance = 100000000
   Local $lDistance, $lArrayX, $lArrayY
   Local $lAgentArray = GetAgentPtrArrayEx(1, 0x200)
   For $i = 1 To $lAgentArray[0]
	  UpdateAgentPosByPtr($lAgentArray[$i], $lArrayX, $lArrayY)
	  $lDistance = ($aX - $lArrayX) ^ 2 + ($aY - $lArrayY) ^ 2
	  If $lDistance < $lNearestDistance Then
		 $lNearestAgent = $lAgentArray[$i]
		 $lNearestDistance = $lDistance
	  EndIf
   Next
   SetExtended(Sqrt($lNearestDistance))
   Return $lNearestAgent
EndFunc   ;==>GetNearestSignpostPtrToCoords

;~ Description: Returns the nearest NPC to an agent.
Func GetNearestNPCPtrToAgent($aAgent = -2)
   Local $lAgentX, $lAgentY, $lArrayX, $lArrayY
   If IsPtr($aAgent) <> 0 Then
	  Local $lAgentID = MemoryRead($aAgent + 44, 'long')
	  UpdateAgentPosByPtr($aAgent, $lAgentX, $lAgentY)
   ElseIf IsDllStruct($aAgent) <> 0 Then
	  Local $lAgentID = DllStructGetData($aAgent, 'ID')
	  $lAgentX = DllStructGetData($aAgent, 'X')
	  $lAgentY = DllStructGetData($aAgent, 'Y')
   Else
	  Local $lAgentID = ConvertID($aAgent)
	  Local $lAgentPtr = GetAgentPtr($aAgent)
	  UpdateAgentPosByPtr(GetAgentPtr($aAgent), $lAgentX, $lAgentY)
   EndIf
   Local $lNearestAgent, $lDistance, $lNearestDistance = 100000000
   Local $lAgentArray = GetAgentPtrArrayEx(3, 0xDB, 6)
   For $i = 1 To $lAgentArray[0]
	  If MemoryRead($lAgentArray[$i] + 44, 'long') = $lAgentID Then ContinueLoop
	  UpdateAgentPosByPtr($lAgentArray[$i], $lArrayX, $lArrayY)
	  $lDistance = ($lAgentX - $lArrayX) ^ 2 + ($lAgentY - $lArrayY) ^ 2
	  If $lDistance < $lNearestDistance Then
		 $lNearestAgent = $lAgentArray[$i]
		 $lNearestDistance = $lDistance
	  EndIf
   Next
   SetExtended(Sqrt($lNearestDistance))
   Return $lNearestAgent
EndFunc   ;==>GetNearestNPCPtrToAgent

;~ Description: Returns the nearest NPC to a set of coordinates.
Func GetNearestNPCPtrToCoords($aX, $aY)
   Local $lNearestAgent, $lNearestDistance = 100000000
   Local $lDistance, $lArrayX, $lArrayY
   Local $lAgentArray = GetAgentPtrArrayEx(3, 0xDB, 6)
   For $i = 1 To $lAgentArray[0]
	  UpdateAgentPosByPtr($lAgentArray[$i], $lArrayX, $lArrayY)
	  $lDistance = ($aX - $lArrayX) ^ 2 + ($aY - $lArrayY) ^ 2
	  If $lDistance < $lNearestDistance Then
		 $lNearestAgent = $lAgentArray[$i]
		 $lNearestDistance = $lDistance
	  EndIf
   Next
   SetExtended(Sqrt($lNearestDistance))
   Return $lNearestAgent
EndFunc   ;==>GetNearestNPCPtrToCoords

;~ Description: Returns the nearest NPC to a set of coordinates.
Func GetNearestEnemyPtrToCoords($aX, $aY)
   Local $lNearestAgent, $lNearestDistance = 100000000
   Local $lDistance, $lArrayX, $lArrayY
   Local $lAgentArray = GetAgentPtrArrayEx(3, 0xDB, 3)
   For $i = 1 To $lAgentArray[0]
	  UpdateAgentPosByPtr($lAgentArray[$i], $lArrayX, $lArrayY)
	  $lDistance = ($aX - $lArrayX) ^ 2 + ($aY - $lArrayY) ^ 2
	  If $lDistance < $lNearestDistance Then
		 $lNearestAgent = $lAgentArray[$i]
		 $lNearestDistance = $lDistance
	  EndIf
   Next
   SetExtended(Sqrt($lNearestDistance))
   Return $lNearestAgent
EndFunc   ;==>GetNearestEnemyPtrToCoords

;~ Description: Returns a ptr to an enemy agent in range of coordinates. If there is no agent in range, returns 0.
Func GetEnemyPtrNearCoords($aX, $aY, $aRange = 1000)
   Local $lDistance, $lArrayX, $lArrayY
   Local $lAgentArray = GetAgentPtrArrayEx(3, 0xDB, 3)
   For $i = 1 To $lAgentArray[0]
	  UpdateAgentPosByPtr($lAgentArray[$i], $lArrayX, $lArrayY)
	  $lDistance = ($aX - $lArrayX) ^ 2 + ($aY - $lArrayY) ^ 2
	  If $lDistance < $aRange Then
		 Return SetExtended($lDistance, $lAgentArray[$i])
	  EndIf
   Next
EndFunc   ;==>GetEnemyPtrNearCoords

;~ Description: Returns the nearest item to an agent.
Func GetNearestItemPtrToAgent($aAgent = -2, $aCanPickUp = True)
   Local $lAgentX, $lAgentY, $lArrayX, $lArrayY
   If IsPtr($aAgent) <> 0 Then
	  Local $lAgentID = MemoryRead($aAgent + 44, 'long')
	  Local $lAgentID = MemoryRead($aAgent + 44, 'long')
   ElseIf IsDllStruct($aAgent) <> 0 Then
	  Local $lAgentID = DllStructGetData($aAgent, 'ID')
	  $lAgentX = DllStructGetData($aAgent, 'X')
	  $lAgentY = DllStructGetData($aAgent, 'Y')
   Else
	  Local $lAgentID = ConvertID($aAgent)
	  Local $lAgentID = MemoryRead(GetAgentPtr($aAgent) + 44, 'long')
   EndIf
   Local $lNearestAgent, $lDistance, $lNearestDistance = 100000000
   Local $lAgentArray = GetAgentPtrArrayEx(1, 0x400)
   For $i = 1 To $lAgentArray[0]
	  If $aCanPickUp And Not GetCanPickUp($lAgentArray[$i]) Then ContinueLoop
	  If MemoryRead($lAgentArray[$i] + 44, 'long') = $lAgentID Then ContinueLoop
	  UpdateAgentPosByPtr($lAgentArray[$i], $lArrayX, $lArrayY)
	  $lDistance = ($lAgentX - $lArrayX) ^ 2 + ($lAgentY - $lArrayY) ^ 2
	  If $lDistance < $lNearestDistance Then
		 $lNearestAgent = $lAgentArray[$i]
		 $lNearestDistance = $lDistance
	  EndIf
   Next
   SetExtended(Sqrt($lNearestDistance))
   Return $lNearestAgent
EndFunc   ;==>GetNearestItemPtrToAgent
#EndRegion Ptr

#Region Interaction
;~ Description: Attack an agent.
Func Attack($aAgent, $aCallTarget = False)
   If IsPtr($aAgent) <> 0 Then
	  Local $lAgentID = MemoryRead($aAgent + 44, 'long')
   ElseIf IsDllStruct($aAgent) <> 0 Then
	  Local $lAgentID = DllStructGetData($aAgent, 'ID')
   Else
	  Local $lAgentID = ConvertID($aAgent)
   EndIf
   Return SendPacket(0xC, 0x20, $lAgentID, $aCallTarget)
EndFunc   ;==>Attack

;~ Description: Use switch/boss lock/etc, waits till in range.
Func UseSignpost($aX, $aY)
   Local $lSignpost = GetNearestSignpostPtrToCoords($aX, $aY)
   GoToSignpost($lSignpost)
EndFunc   ;==>UseSignpost

;~ Description: Turn character to the left.
Func TurnLeft($aTurn)
   If $aTurn Then
	  Return PerformAction(0xA2, 0x18)
   Else
	  Return PerformAction(0xA2, 0x1A)
   EndIf
EndFunc   ;==>TurnLeft

;~ Description: Turn character to the right.
Func TurnRight($aTurn)
   If $aTurn Then
	  Return PerformAction(0xA3, 0x18)
   Else
	  Return PerformAction(0xA3, 0x1A)
   EndIf
EndFunc   ;==>TurnRight

;~ Description: Move backwards.
Func MoveBackward($aMove)
   If $aMove Then
	  Return PerformAction(0xAC, 0x18)
   Else
	  Return PerformAction(0xAC, 0x1A)
   EndIf
EndFunc   ;==>MoveBackward

;~ Description: Run forwards.
Func MoveForward($aMove)
   If $aMove Then
	  Return PerformAction(0xAD, 0x18)
   Else
	  Return PerformAction(0xAD, 0x1A)
   EndIf
EndFunc   ;==>MoveForward

;~ Description: Strafe to the left.
Func StrafeLeft($aStrafe)
   If $aStrafe Then
	  Return PerformAction(0x91, 0x18)
   Else
	  Return PerformAction(0x91, 0x1A)
   EndIf
EndFunc   ;==>StrafeLeft

;~ Description: Strafe to the right.
Func StrafeRight($aStrafe)
   If $aStrafe Then
	  Return PerformAction(0x92, 0x18)
   Else
	  Return PerformAction(0x92, 0x1A)
   EndIf
EndFunc   ;==>StrafeRight

;~ Description: Auto-run.
Func ToggleAutoRun()
   Return PerformAction(0xB7, 0x18)
EndFunc   ;==>ToggleAutoRun

;~ Description: Turn around.
Func ReverseDirection()
   Return PerformAction(0xB1, 0x18)
EndFunc   ;==>ReverseDirection

;~ Description: Cancel current action.
Func CancelAction()
   Return SendPacket(0x4, 0x22)
EndFunc   ;==>CancelAction

;~ Description: Same as hitting spacebar.
Func ActionInteract()
   Return PerformAction(0x80, 0x18)
EndFunc   ;==>ActionInteract

;~ Description: Follow a player.
Func ActionFollow()
   Return PerformAction(0xCC, 0x18)
EndFunc   ;==>ActionFollow

;~ Description: Drop environment object.
Func DropBundle()
   Return PerformAction(0xCD, 0x18)
EndFunc   ;==>DropBundle

;~ Description: Suppress action.
Func SuppressAction($aSuppress)
   If $aSuppress Then
	  Return PerformAction(0xD0, 0x18)
   Else
	  Return PerformAction(0xD0, 0x1A)
   EndIf
EndFunc   ;==>SuppressAction

;~ Description: Open a chest.
Func OpenChest()
   Return SendPacket(0x8, 0x4D, 2)
EndFunc   ;==>OpenChest

;~ Description: Change weapon sets.
Func ChangeWeaponSet($aSet)
   Return PerformAction(0x80 + $aSet, 0x18)
EndFunc   ;==>ChangeWeaponSet

;~ Description: Open a dialog.
Func Dialog($aDialogID)
   Return SendPacket(0x8, 0x35, $aDialogID)
EndFunc   ;==>Dialog

;~ Description: Returns last DialogID in ascii.
Func GetLastDialogId()
   Return MemoryRead($mLastDialogId)
EndFunc   ;==>GetLastDialogId

;~ Description: Last DialogID as hex.
Func GetLastDialogIdHex()
   $DialogHex = MemoryRead($mLastDialogId)
   Return "0x" & StringReplace(Hex($DialogHex, 8), StringRegExpReplace(Hex($DialogHex, 8), "[^0].*", ""), "")
EndFunc   ;==>GetLastDialogIdHex
#EndRegion

#Region Targeting
;~ Description: Returns current target ptr.
Func GetCurrentTargetPtr()
   Local $lOffset[2] = [0, 4 * MemoryRead($mCurrentTarget)]
   Local $lAgentStructAddress = MemoryReadPtr($mAgentBase, $lOffset, 'ptr')
   Return $lAgentStructAddress[1]
EndFunc   ;==>GetCurrentTarget

;~ Description: Returns current target ID.
Func GetCurrentTargetID()
   Return MemoryRead($mCurrentTarget)
EndFunc   ;==>GetCurrentTargetID

;~ Description: Target an agent.
Func ChangeTarget($aAgent)
   If IsPtr($aAgent) <> 0 Then
	  Local $lAgentID = MemoryRead($aAgent + 44, 'long')
   ElseIf IsDllStruct($aAgent) <> 0 Then
	  Local $lAgentID = DllStructGetData($aAgent, 'ID')
   Else
	  Local $lAgentID = ConvertID($aAgent)
   EndIf
   DllStructSetData($mChangeTarget, 2, $lAgentID)
   Enqueue($mChangeTargetPtr, 8)
EndFunc   ;==>ChangeTarget

;~ Description: Call target.
Func CallTarget($aTarget)
   If IsPtr($aTarget) <> 0 Then
	  Local $lTargetID = MemoryRead($aTarget + 44, 'long')
   ElseIf IsDllStruct($aTarget) <> 0 Then
	  Local $lTargetID = DllStructGetData($aTarget, 'ID')
   Else
	  Local $lTargetID = ConvertID($aTarget)
   EndIf
   Return SendPacket(0xC, 0x1C, 0xA, $lTargetID)
EndFunc   ;==>CallTarget

;~ Description: Clear current target.
Func ClearTarget()
   Return PerformAction(0xE3, 0x18)
EndFunc   ;==>ClearTarget

;~ Description: Target the nearest enemy.
Func TargetNearestEnemy()
   Return PerformAction(0x93, 0x18)
EndFunc   ;==>TargetNearestEnemy

;~ Description: Target the next enemy.
Func TargetNextEnemy()
   Return PerformAction(0x95, 0x18)
EndFunc   ;==>TargetNextEnemy

;~ Description: Target the next party member.
Func TargetPartyMember($aNumber)
   If $aNumber > 0 And $aNumber < 13 Then Return PerformAction(0x95 + $aNumber, 0x18)
EndFunc   ;==>TargetPartyMember

;~ Description: Target the previous enemy.
Func TargetPreviousEnemy()
   Return PerformAction(0x9E, 0x18)
EndFunc   ;==>TargetPreviousEnemy

;~ Description: Target the called target.
Func TargetCalledTarget()
   Return PerformAction(0x9F, 0x18)
EndFunc   ;==>TargetCalledTarget

;~ Description: Target yourself.
Func TargetSelf()
   Return PerformAction(0xA0, 0x18)
EndFunc   ;==>TargetSelf

;~ Description: Target the nearest ally.
Func TargetNearestAlly()
   Return PerformAction(0xBC, 0x18)
EndFunc   ;==>TargetNearestAlly

;~ Description: Target the nearest item.
Func TargetNearestItem()
   Return PerformAction(0xC3, 0x18)
EndFunc   ;==>TargetNearestItem

;~ Description: Target the next item.
Func TargetNextItem()
   Return PerformAction(0xC4, 0x18)
EndFunc   ;==>TargetNextItem

;~ Description: Target the previous item.
Func TargetPreviousItem()
   Return PerformAction(0xC5, 0x18)
EndFunc   ;==>TargetPreviousItem

;~ Description: Target the next party member.
Func TargetNextPartyMember()
   Return PerformAction(0xCA, 0x18)
EndFunc   ;==>TargetNextPartyMember

;~ Description: Target the previous party member.
Func TargetPreviousPartyMember()
   Return PerformAction(0xCB, 0x18)
EndFunc   ;==>TargetPreviousPartyMember
#EndRegion Targeting

#Region Information
;~ Description: Internal use for handing -1 and -2 agent IDs.
Func ConvertID($aID)
   If $aID = -2 Then
	  Return GetMyID()
   ElseIf $aID = -1 Then
	  Return GetCurrentTargetID()
   Else
	  Return $aID
   EndIf
EndFunc   ;==>ConvertID

;~ Description: Returns the ID of an agent.
Func GetAgentID($aAgent)
   If IsPtr($aAgent) <> 0 Then
	  Local $lAgentID =  MemoryRead($aAgent + 44, 'long')
   ElseIf IsDllStruct($aAgent) <> 0 Then
	  Local $lAgentID =  DllStructGetData($aAgent, 'ID')
   Else
	  Local $lAgentID = ConvertID($aAgent)
   EndIf
   If $lAgentID = 0 Then Return ''
   Return $lAgentID
EndFunc   ;==>GetAgentID

;~ Description: Returns your agent ID.
Func GetMyID()
   Return MemoryRead($mMyID)
EndFunc   ;==>GetMyID

;~ Description: Updates X and Y variables with current x and y coordinate values.
;~ Author: 4D1.
Func UpdateAgentPosByPtr($aAgentPtr, ByRef $aX, ByRef $aY)
   Local $lStruct = MemoryReadStruct($aAgentPtr + 116,'float X;float Y')
   $aX = DllStructGetData($lStruct,'X')
   $aY = DllStructGetData($lStruct,'Y')
EndFunc   ;==>UpdateAgentPosByPtr

;~ Description: Updates MoveX and MoveY variables with current values.
Func UpdateAgentMoveByPtr($aAgentPtr, ByRef $aMoveX, ByRef $aMoveY)
   Local $lStruct = MemoryReadStruct($aAgentPtr + 160,'float MoveX;float MoveY')
   $aMoveX = DllStructGetData($lStruct,'MoveX')
   $aMoveY = DllStructGetData($lStruct,'MoveY')
EndFunc   ;==>UpdateAgentPosByPtr

;~ Description: Returns number of agents currently loaded.
Func GetMaxAgents()
   Return MemoryRead($mMaxAgents)
EndFunc   ;==>GetMaxAgents

;~ Description: Test if an agent exists.
Func GetAgentExists($aAgentID)
   If IsPtr($aAgentID) <> 0 Then
	  Return $aAgentID <> 0 And MemoryRead($aAgentID + 44, 'long') <= GetMaxAgents()
   Else
	  Return (GetAgentPtr($aAgentID) > 0 And $aAgentID <= GetMaxAgents())
   EndIf
EndFunc   ;==>GetAgentExists

;~ Description: Returns the target of an agent.
Func GetTarget($aAgent)
   If IsPtr($aAgent) <> 0 Then
	  Local $lAgentID = MemoryRead($aAgent + 44, 'long')
   ElseIf IsDllStruct($aAgent) <> 0 Then
	  Local $lAgentID = DllStructGetData($aAgent, 'ID')
   Else
	  Local $lAgentID = ConvertID($aAgent)
   EndIf
   Return MemoryRead(GetValue('TargetLogBase') + 4 * $lAgentID)
EndFunc   ;==>GetTarget

;~ Description: Returns agent by name.
Func GetAgentIDByName($aName)
   If $mUseStringLog = False Then Return
   Local $lName, $lAddress
   For $i = 1 To GetMaxAgents()
	  $lAddress = $mStringLogBase + 256 * $i
	  $lName = MemoryRead($lAddress, 'wchar [128]')
	  If $lName = '' Then ContinueLoop
	  $lName = StringRegExpReplace($lName, '[<]{1}([^>]+)[>]{1}', '')
	  If StringInStr($lName, $aName) <> 0 Then Return $i
   Next
   DisplayAll(True)
   Sleep(100)
   DisplayAll(False)
   DisplayAll(True)
   Sleep(100)
   DisplayAll(False)
   For $i = 1 To GetMaxAgents()
	  $lAddress = $mStringLogBase + 256 * $i
	  $lName = MemoryRead($lAddress, 'wchar [128]')
	  If $lName = '' Then ContinueLoop
	  $lName = StringRegExpReplace($lName, '[<]{1}([^>]+)[>]{1}', '')
	  If StringInStr($lName, $aName) <> 0 Then Return $i
   Next
EndFunc   ;==>GetAgentIDByName

;~ Description: Checks number of enemies in range, can check specific Enemies with ModelID.
Func GetNumberOfFoesInRangeOfAgent($aAgent = -2, $aMaxDistance = 4000, $ModelID = 0)
   If IsPtr($aAgent) <> 0 Then
	  Local $lAgentPtr = $aAgent
   ElseIf IsDllStruct($aAgent) <> 0 Then
	  Local $lAgentID = DllStructGetData($aAgent, 'ID')
	  Local $lAgentPtr = GetAgentPtr($lAgentID)
   Else
	  Local $lAgentID = $aAgent
	  Local $lAgentPtr = GetAgentPtr($lAgentID)
   EndIf
   Local $lDistance, $lCount = 0
   Local $lTargetTypeArray = GetAgentPtrArrayEx(3)
   For $i = 1 To $lTargetTypeArray[0]
	  If $ModelID <> 0 And MemoryRead($lTargetTypeArray[$i] + 244, 'word') <> $ModelID Then ContinueLoop
	  $lDistance = GetDistance($lTargetTypeArray[$i], $lAgentPtr)
	  If $lDistance < $aMaxDistance Then
		 $lCount += 1
	  EndIf
   Next
   Return $lCount
EndFunc   ;==>GetNumberOfFoesInRangeOfAgent

;~ Description: Checks number of allies in range, can check specific allies with ModelID.
Func GetNumberOfAlliesInRangeOfAgent($aAgent = -2, $aMaxDistance = 4000, $ModelID = 0)
   If IsPtr($aAgent) <> 0 Then
	  Local $lAgentPtr = $aAgent
   ElseIf IsDllStruct($aAgent) <> 0 Then
	  Local $lAgentID = DllStructGetData($aAgent, 'ID')
	  Local $lAgentPtr = GetAgentPtr($lAgentID)
   Else
	  Local $lAgentID = $aAgent
	  Local $lAgentPtr = GetAgentPtr($lAgentID)
   EndIf
   Local $lDistance, $lCount = 0
   Local $lTargetTypeArray = GetAgentPtrArrayEx(3, 0xDB, 1)
   For $i = 1 To $lTargetTypeArray[0]
	  If $ModelID <> 0 And MemoryRead($lTargetTypeArray[$i] + 244, 'word') <> $ModelID Then ContinueLoop
	  $lDistance = GetDistance($lTargetTypeArray[$i], $lAgentPtr)
	  If $lDistance < $aMaxDistance Then
		 $lCount += 1
	  EndIf
   Next
   Return $lCount
EndFunc   ;==>GetNumberOfAlliesInRangeOfAgent

;~ Description: Returns player with most enemies around them within range $aMaxDistance.
Func GetVIP($aMaxDistance = 1350)
   Local $lDistance, $lVIPPtr, $lCount = 0
   Local $lTargetTypeArray = GetAgentPtrArrayEx(3, 0xDB, 1) ; all living allies
   Local $lTargetArray = GetAgentPtrArrayEx(3) ; all living enemies
   For $i = 1 To $lTargetTypeArray[0]
	  Local $lEnemies = 0
	  For $j = 1 To $lTargetArray[0]
		 If $lTargetArray[$j] = 0 Then ContinueLoop
		 $lDistance = GetDistance($lTargetArray[$j], $lTargetTypeArray[$i])
		 If $lDistance < $aMaxDistance Then
			$lEnemies += 1
		 EndIf
	  Next
	  If $lEnemies > $lCount Then
		 $lVIPPtr = $lTargetTypeArray[$i]
		 $lCount = $lEnemies
	  EndIf
   Next
   Return $lVIPPtr
EndFunc   ;==>GetVIP

;~ Description: Returns amount of players in outpost.
;~ Includes oneself.
Func GetNumberOfPlayersInOutpost()
   Local $lCount = 0
   $lAgentArray = GetAgentPtrArrayEx(2, 0xDB, 1)
   For $i = 0 To $lAgentArray[0]
	  If MemoryRead($lAgentArray[$i] + 384, 'long') <> 0 Then $lCount += 1
   Next
   Return $lCount
EndFunc   ;==>GetNumberOfPlayersInOutpost

;~ Description: Returns true if agent and party is dead.
Func Death($aAgentID = -2, $aResign = True)
   Local $lAgentPtr = GetAgentPtr($aAgentID)
   Local $lPartyDead = False
   If BitAND(MemoryRead($lAgentPtr + 312, 'long'), 0x0010) Then
	  Local $lPartyArray = GetAgentPtrArrayEx(3, 0xDB, 1, True)
	  If $lPartyArray[0] <> 0 Then
		 For $i = 1 to 5
			If GetMapLoading() <> 1 Then
			   $lPartyDead = True
			   ExitLoop
			EndIf
			For $j = 1 To $lPartyArray[0]
			   If BitAND(MemoryRead($lPartyArray[$j] + 312, 'long'), 0x0010) Then
				  $lPartyDead = True
			   Else
				  $lPartyDead = False
			   EndIf
			Next
			RndSleep(100)
		 Next
	  Else
		 $lPartyDead = True
	  EndIf
	  If $lPartyDead And $aResign Then ResignAndReturn()
	  Return $lPartyDead
   EndIf
EndFunc   ;==>Death

#Region Type
;~ Description: Tests if an agent is living.
Func GetIsLiving($aAgent)
   If IsPtr($aAgent) <> 0 Then
	  Return MemoryRead($aAgent + 156, 'long') = 0xDB
   ElseIf IsDllStruct($aAgent) <> 0 Then
	  Return DllStructGetData($aAgent, 'Type') = 0xDB
   Else
	  Return MemoryRead(GetAgentPtr($aAgent) + 156, 'long') = 0xDB
   EndIf
EndFunc   ;==>GetIsLiving

;~ Description: Tests if an agent is a signpost/chest/etc.
Func GetIsStatic($aAgent)
   If IsPtr($aAgent) <> 0 Then
	  Return MemoryRead($aAgent + 156, 'long') = 0x200
   ElseIf IsDllStruct($aAgent) <> 0 Then
	  Return DllStructGetData($aAgent, 'Type') = 0x200
   Else
	  Return MemoryRead(GetAgentPtr($aAgent) + 156, 'long') = 0x200
   EndIf
EndFunc   ;==>GetIsStatic

;~ Description: Tests if an agent is an item.
Func GetIsMovable($aAgent)
   If IsPtr($aAgent) <> 0 Then
	  Return MemoryRead($aAgent + 156, 'long') = 0x400
   ElseIf IsDllStruct($aAgent) <> 0 Then
	  Return DllStructGetData($aAgent, 'Type') = 0x400
   Else
	  Return MemoryRead(GetAgentPtr($aAgent) + 156, 'long') = 0x400
   EndIf
EndFunc   ;==>GetIsMovable

;~ Description: Checks if agentID is summoned.
Func IsSummonedCreature($aAgentID)
   If IsPtr($aAgentID) <> 0 Then
	  Local $lAgentMID = MemoryRead($aAgentID + 244, 'word')
   Else
	  Local $lAgentMID = MemoryRead(GetAgentPtr($aAgentID) + 244, 'word')
   EndIf
   Switch $lAgentMID
	  Case 1377 ; Pet-Elder Wolf
		 Return True
	  Case 2220 to 2222 ; bone horror, fiend, minion
		 Return True
	  Case 2864 to 2872 ; ranger spirits part 1
		 Return True
	  Case 2875 to 2878 ; ranger spirits part 2
		 Return True
	  Case 3956 to 3957 ; corrupted scales and spores
		 Return True
	  Case 4199 to 4200 ; flesh golem, vampiric horror
		 Return True
	  Case 4203 to 4222 ; ritualist spirits part 1 and one ranger spirit
		 Return True
	  Case 4224 to 4229 ; ranger spirits part 3
		 Return True
	  Case 5703 to 5713 ; necro, ranger and ritualist spirits
		 Return True
	  Case 5842 to 5844 ; EVA, ritualist spirits
		 Return True
	  Case Else
		 Return False
   EndSwitch
EndFunc

;~ Description: Returns true if agent is a minion.
Func IsMinion($aAgentID)
   If IsPtr($aAgentID) <> 0 Then
	  Local $lAgentMID = MemoryRead($aAgentID + 244, 'word')
   Else
	  Local $lAgentMID = MemoryRead(GetAgentPtr($aAgentID) + 244, 'word')
   EndIf
   Switch $lAgentMID
	  Case 2220, 2221, 2222 ; bone horror, fiend, minion
		 Return True
	  Case 4199, 4200 ; flesh golem, vampiric horror
		 Return True
	  Case 5703, 5704 ; shambling horror, jagged horror
		 Return True
	  Case Else
		 Return False
   EndSwitch
EndFunc
#EndRegion

#Region hp, energy, coordinates
;~ Description: Agents X Location
Func XLocation($aAgent = -2)
   If IsPtr($aAgent) <> 0 Then
	  Return MemoryRead($aAgent + 116, 'float')
   ElseIf IsDllStruct($aAgent) <> 0 Then
	  Return DllStructGetData($aAgent, 'X')
   Else
	  Return MemoryRead(GetAgentPtr($aAgent) + 116, 'float')
   EndIf
EndFunc   ;==>XLocation

;~ Description: Agents Y Location
Func YLocation($aAgent = -2)
   If IsPtr($aAgent) <> 0 Then
	  Return MemoryRead($aAgent + 120, 'float')
   ElseIf IsDllStruct($aAgent) <> 0 Then
	  Return DllStructGetData($aAgent, 'Y')
   Else
	  Return MemoryRead(GetAgentPtr($aAgent) + 120, 'float')
   EndIf
EndFunc   ;==>YLocation

;~ Description: Agents X and Y Location
Func XandYLocation($aAgent = -2)
   Local $Location[2]
   If IsPtr($aAgent) <> 0 Then
	  UpdateAgentPosByPtr($aAgent, $Location[0], $Location[1])
   ElseIf IsDllStruct($aAgent) <> 0 Then
	  $Location[0] = DllStructGetData($aAgent, 'X')
	  $Location[1] = DllStructGetData($aAgent, 'Y')
   Else
	  UpdateAgentPosByPtr(GetAgentPtr($aAgent), $Location[0], $Location[1])
   EndIf
   Return $Location
EndFunc   ;==>XandYLocation

;~ Description: Returns energy of an agent. (Only self/heroes)
Func GetEnergy($aAgent = -2)
   If IsPtr($aAgent) <> 0 Then
	  Return MemoryRead($aAgent + 284, 'float') * MemoryRead($aAgent + 288, 'long')
   ElseIf IsDllStruct($aAgent) <> 0 Then
	  Return DllStructGetData($aAgent, 'EnergyPercent') * DllStructGetData($aAgent, 'MaxEnergy')
   Else
	  Return MemoryRead(GetAgentPtr($aAgent) + 284, 'float') * MemoryRead(GetAgentPtr($aAgent) + 288, 'long')
   EndIf
EndFunc   ;==>GetEnergy

;~ Description: Returns health of an agent. (Must have caused numerical change in health)
Func GetHealth($aAgent = -2)
   If IsPtr($aAgent) <> 0 Then
	  Return MemoryRead($aAgent + 304, 'float') * MemoryRead($aAgent + 308, 'long')
   ElseIf IsDllStruct($aAgent) <> 0 Then
	  Return DllStructGetData($aAgent, 'HP') * DllStructGetData($aAgent, 'MaxHP')
   Else
	  Return MemoryRead(GetAgentPtr($aAgent) + 304, 'float') * MemoryRead(GetAgentPtr($aAgent) + 308, 'long')
   EndIf
EndFunc   ;==>GetHealth

;~ Description: Returns moving from agent movement struct.
Func GetMoving($aAgentID)
   Local $lPtr = MemoryRead($mAgentMovement + 4 * ConvertID($aAgentID))
   Return MemoryRead($lPtr + 60, 'long')
EndFunc

;~ Description: Checks if GetMoving stays 0 for a period of time.
Func GetIsRubberbanding($aAgentID, $aTime)
   Local $lPtr = MemoryRead($mAgentMovement + 4 * ConvertID($aAgentID))
   $lTimer = TimerInit()
   Do
	  If MemoryRead($lPtr + 60, 'long') <> 0 Then Return False
	  ConsoleWrite("Rubberbanding: " & MemoryRead($lPtr + 60, 'long') & @CRLF)
	  Sleep(50)
   Until TimerDiff($lTimer) > $aTime
   Return True
EndFunc

;~ Description: Tests if an agent is moving. Uses agent struct data.
Func GetIsMoving($aAgent = -2, $aTimer = 0)
   If IsPtr($aAgent) <> 0 Then
	  Local $lPtr = $aAgent
   ElseIf IsDllStruct($aAgent) <> 0 Then
	  If DllStructGetData($aAgent, 'MoveX') <> 0 Or DllStructGetData($aAgent, 'MoveY') <> 0 Then Return True
   Else
	  Local $lPtr = GetAgentPtr($aAgent)
   EndIf
   Local $lMoveX, $lMoveY
   UpdateAgentMoveByPtr($lPtr, $lMoveX, $lMoveY)
   If $lMoveX <> 0 Or $lMoveY <> 0 Then Return True
   If $aTimer <> 0 Then
	  Sleep($aTimer)
	  UpdateAgentMoveByPtr($lPtr, $lMoveX, $lMoveY)
	  If $lMoveX <> 0 Or $lMoveY <> 0 Then Return True
   EndIf
   Return False
EndFunc   ;==>GetIsMoving
#EndRegion

#Region State
;~ Description: Tests if an agent is knocked down.
Func GetIsKnocked($aAgent = -2)
   If IsPtr($aAgent) <> 0 Then
	  Return MemoryRead($aAgent + 340, 'long') = 0x450
   ElseIf IsDllStruct($aAgent) <> 0 Then
	  Return DllStructGetData($aAgent, 'ModelState') = 0x450
   Else
	  Return MemoryRead(GetAgentPtr($aAgent) + 340, 'long') = 0x450
   EndIf
   Return False
EndFunc   ;==>GetIsKnocked

;~ Description: Tests if an agent is attacking.
Func GetIsAttacking($aAgent = -2)
   Local $lModelState
   If IsPtr($aAgent) <> 0 Then
	  $lModelState = MemoryRead($aAgent + 340, 'long')
   ElseIf IsDllStruct($aAgent) <> 0 Then
	  $lModelState = DllStructGetData($aAgent, 'ModelState')
   Else
	  $lModelState = MemoryRead(GetAgentPtr($aAgent) + 340, 'long')
   EndIf
   Switch $lModelState
	  Case 0x60 ; Is Attacking
		 Return True
	  Case 0x440 ; Is Attacking
		 Return True
	  Case 0x460 ; Is Attacking
		 Return True
	  Case Else
		 Return False
   EndSwitch
EndFunc   ;==>GetIsAttacking

;~ Description: Tests if an agent is casting.
Func GetIsCasting($aAgent = -2)
   If IsPtr($aAgent) <> 0 Then
	  Return MemoryRead($aAgent + 436, 'word') <> 0
   ElseIf IsDllStruct($aAgent) <> 0 Then
	  Return DllStructGetData($aAgent, 'Skill') <> 0
   Else
	  Return MemoryRead(GetAgentPtr($aAgent) + 436, 'word') <> 0
   EndIf
EndFunc   ;==>GetIsCasting
#EndRegion

#Region Effects
;~ Description: Tests if an agent is bleeding.
Func GetIsBleeding($aAgent)
   If IsPtr($aAgent) <> 0 Then
	  Return BitAND(MemoryRead($aAgent + 312, 'long'), 0x0001) > 0
   ElseIf IsDllStruct($aAgent) <> 0 Then
	  Return BitAND(DllStructGetData($aAgent, 'Effects'), 0x0001) > 0
   Else
	  Return BitAND(MemoryRead(GetAgentPtr($aAgent) + 312, 'long'), 0x0001) > 0
   EndIf
EndFunc   ;==>GetIsBleeding

;~ Description: Tests if an agent has a condition.
Func GetHasCondition($aAgent)
   If IsPtr($aAgent) <> 0 Then
	  Return BitAND(MemoryRead($aAgent + 312, 'long'), 0x0002) > 0
   ElseIf IsDllStruct($aAgent) <> 0 Then
	  Return BitAND(DllStructGetData($aAgent, 'Effects'), 0x0002) > 0
   Else
	  Return BitAND(MemoryRead(GetAgentPtr($aAgent) + 312, 'long'), 0x0002) > 0
   EndIf
EndFunc   ;==>GetHasCondition

;~ Description: Tests if an agent is dead.
Func GetIsDead($aAgent = -2)
   If IsPtr($aAgent) <> 0 Then
	  Return BitAND(MemoryRead($aAgent + 312, 'long'), 0x0010) > 0
   ElseIf IsDllStruct($aAgent) <> 0 Then
	  Return BitAND(DllStructGetData($aAgent, 'Effects'), 0x0010) > 0
   Else
	  Return BitAND(MemoryRead(GetAgentPtr($aAgent) + 312, 'long'), 0x0010) > 0
   EndIf
EndFunc   ;==>GetIsDead

;~ Description: Tests if an agent has a deep wound.
Func GetHasDeepWound($aAgent)
   If IsPtr($aAgent) <> 0 Then
	  Return BitAND(MemoryRead($aAgent + 312, 'long'), 0x0020) > 0
   ElseIf IsDllStruct($aAgent) <> 0 Then
	  Return BitAND(DllStructGetData($aAgent, 'Effects'), 0x0020) > 0
   Else
	  Return BitAND(MemoryRead(GetAgentPtr($aAgent) + 312, 'long'), 0x0020) > 0
   EndIf
EndFunc   ;==>GetHasDeepWound

;~ Description: Tests if an agent is poisoned.
Func GetIsPoisoned($aAgent)
   If IsPtr($aAgent) <> 0 Then
	  Return BitAND(MemoryRead($aAgent + 312, 'long'), 0x0040) > 0
   ElseIf IsDllStruct($aAgent) <> 0 Then
	  Return BitAND(DllStructGetData($aAgent, 'Effects'), 0x0040) > 0
   Else
	  Return BitAND(MemoryRead(GetAgentPtr($aAgent) + 312, 'long'), 0x0040) > 0
   EndIf
EndFunc   ;==>GetIsPoisoned

;~ Description: Tests if an agent is enchanted.
Func GetIsEnchanted($aAgent)
   If IsPtr($aAgent) <> 0 Then
	  Return BitAND(MemoryRead($aAgent + 312, 'long'), 0x0080) > 0
   ElseIf IsDllStruct($aAgent) <> 0 Then
	  Return BitAND(DllStructGetData($aAgent, 'Effects'), 0x0080) > 0
   Else
	  Return BitAND(MemoryRead(GetAgentPtr($aAgent) + 312, 'long'), 0x0080) > 0
   EndIf
EndFunc   ;==>GetIsEnchanted

;~ Description: Tests if an agent has a degen hex.
Func GetHasDegenHex($aAgent)
   If IsPtr($aAgent) <> 0 Then
	  Return BitAND(MemoryRead($aAgent + 312, 'long'), 0x0400) > 0
   ElseIf IsDllStruct($aAgent) <> 0 Then
	  Return BitAND(DllStructGetData($aAgent, 'Effects'), 0x0400) > 0
   Else
	  Return BitAND(MemoryRead(GetAgentPtr($aAgent) + 312, 'long'), 0x0400) > 0
   EndIf
EndFunc   ;==>GetHasDegenHex

;~ Description: Tests if an agent is hexed.
Func GetHasHex($aAgent)
   If IsPtr($aAgent) <> 0 Then
	  Return BitAND(MemoryRead($aAgent + 312, 'long'), 0x0800) > 0
   ElseIf IsDllStruct($aAgent) <> 0 Then
	  Return BitAND(DllStructGetData($aAgent, 'Effects'), 0x0800) > 0
   Else
	  Return BitAND(MemoryRead(GetAgentPtr($aAgent) + 312, 'long'), 0x0800) > 0
   EndIf
EndFunc   ;==>GetHasHex

;~ Description: Tests if an agent has a weapon spell.
Func GetHasWeaponSpell($aAgent)
   If IsPtr($aAgent) <> 0 Then
	  Return BitAND(MemoryRead($aAgent + 312, 'long'), 0x8000) > 0
   ElseIf IsDllStruct($aAgent) <> 0 Then
	  Return BitAND(DllStructGetData($aAgent, 'Effects'), 0x8000) > 0
   Else
	  Return BitAND(MemoryRead(GetAgentPtr($aAgent) + 312, 'long'), 0x8000) > 0
   EndIf
EndFunc   ;==>GetHasWeaponSpell
#EndRegion

#Region TypeMap
;~ Description: Tests if an agent is a boss.
Func GetIsBoss($aAgent)
   If IsPtr($aAgent) <> 0 Then
	  Return BitAND(MemoryRead($aAgent + 344, 'long'), 1024) > 0
   ElseIf IsDllStruct($aAgent) <> 0 Then
	  Return BitAND(DllStructGetData($aAgent, 'TypeMap'), 1024) > 0
   Else
	  Return BitAND(MemoryRead( GetAgentPtr($aAgent) + 344, 'long'), 1024) > 0
   EndIf
EndFunc   ;==>GetIsBoss
#EndRegion

#Region X and Y Calcs
;~ Description: Returns the distance between two agents.
Func GetDistanceToE($aAgent1 = -1)
   Local $lAgent1X, $lAgent1Y, $lAgent2X, $lAgent2Y
   If IsPtr($aAgent1) <> 0 Then
	  UpdateAgentPosByPtr($aAgent1, $lAgent1X, $lAgent1Y)
   ElseIf IsDllStruct($aAgent1) <> 0 Then
	  $lAgent1X = DllStructGetData($aAgent1, 'X')
	  $lAgent1Y = DllStructGetData($aAgent1, 'Y')
   Else
	  UpdateAgentPosByPtr(GetAgentPtr($aAgent1), $lAgent1X, $lAgent1Y)
   EndIf
   UpdateAgentPosByPtr(GetAgentPtr(-2), $lAgent2X, $lAgent2Y)
   Return Sqrt(($lAgent1X - $lAgent2X) ^ 2 + ($lAgent1Y - $lAgent2Y) ^ 2)
EndFunc   ;==>GetDistanceToE

;~ Description: Returns the distance between two agents.
Func GetDistance($aAgent1 = -1, $aAgent2 = -2)
   Local $lAgent1X, $lAgent1Y, $lAgent2X, $lAgent2Y
   If IsPtr($aAgent1) <> 0 Then
	  UpdateAgentPosByPtr($aAgent1, $lAgent1X, $lAgent1Y)
   ElseIf IsDllStruct($aAgent1) <> 0 Then
	  $lAgent1X = DllStructGetData($aAgent1, 'X')
	  $lAgent1Y = DllStructGetData($aAgent1, 'Y')
   Else
	  Local $lAgentID = $aAgent1
	  UpdateAgentPosByPtr(GetAgentPtr($aAgent1), $lAgent1X, $lAgent1Y)
   EndIf
   If IsPtr($aAgent2) <> 0 Then
	  UpdateAgentPosByPtr($aAgent2, $lAgent2X, $lAgent2Y)
   ElseIf IsDllStruct($aAgent2) <> 0 Then
	  $lAgent2X = DllStructGetData($aAgent2, 'X')
	  $lAgent2Y = DllStructGetData($aAgent2, 'Y')
   Else
	  UpdateAgentPosByPtr(GetAgentPtr($aAgent2), $lAgent2X, $lAgent2Y)
   EndIf
   Return Sqrt(($lAgent1X - $lAgent2X) ^ 2 + ($lAgent1Y - $lAgent2Y) ^ 2)
EndFunc   ;==>GetDistance

;~ Description: Checks if a point is within a polygon defined by an array.
Func GetIsPointInPolygon($aAreaCoords, $aPosX = 0, $aPosY = 0)
   Local $lPosition, $lPosX, $lPosY
   Local $lEdges = UBound($aAreaCoords)
   Local $lOddNodes = False
   If $lEdges < 3 Then Return False
   If $aPosX = 0 Then
	  Local $lAgent = GetAgentPtr(-2)
	  UpdateAgentPosByPtr($lAgent, $lPosX, $lPosY)
   Else
	  $lPosX = $aPosX
	  $lPosY = $aPosY
   EndIf
   $j = $lEdges - 1
   For $i = 0 To $lEdges - 1
	  If (($aAreaCoords[$i][1] < $aPosY And $aAreaCoords[$j][1] >= $aPosY) _
	  Or ($aAreaCoords[$j][1] < $aPosY And $aAreaCoords[$i][1] >= $aPosY)) _
	  And ($aAreaCoords[$i][0] <= $aPosX Or $aAreaCoords[$j][0] <= $aPosX) Then
		 If ($aAreaCoords[$i][0] + ($aPosY - $aAreaCoords[$i][1]) / ($aAreaCoords[$j][1] - $aAreaCoords[$i][1]) * ($aAreaCoords[$j][0] - $aAreaCoords[$i][0]) < $aPosX) Then
			$lOddNodes = Not $lOddNodes
		 EndIf
	  EndIf
	  $j = $i
   Next
   Return $lOddNodes
EndFunc   ;==>GetIsPointInPolygon
#EndRegion

#Region Agentname
;~ Description: Returns the name of an agent.
Func GetAgentName($aAgent)
   If $mUseStringLog = False Then Return
   If IsPtr($aAgent) <> 0 Then
	  Local $lAgentPtr = $aAgent
	  Local $lAgentID = MemoryRead($aAgent + 44, 'long')
   ElseIf IsDllStruct($aAgent) <> 0 Then
	  Local $lAgentID = DllStructGetData($aAgent, 'ID')
   Else
	  Local $lAgentID = ConvertID($aAgent)
   EndIf
   If $lAgentID = ConvertID(-2) Then Return GetCharname()
   Local $lAddress = $mStringLogBase + 256 * $lAgentID
   Local $lName = MemoryRead($lAddress, 'wchar [128]')

   If $lName = '' Then
	  DisplayAll(True)
	  Sleep(100)
	  DisplayAll(False)
   EndIf
   Local $lName = MemoryRead($lAddress, 'wchar [128]')
   $lName = StringRegExpReplace($lName, '[<]{1}([^>]+)[>]{1}', '')
   Return $lName
EndFunc   ;==>GetAgentName
#EndRegion

#Region Profession
;~ Description: Agents Primary Profession
Func GetProfessionPrimary($aAgent = -2)
   Return GetAgentPrimaryProfession($aAgent)
EndFunc   ;==>GetProfessionPrimary

;~ Description: Agents Secondary Profession
Func GetProfessionSecondary($aAgent = -2)
   Return GetAgentSecondaryProfession($aAgent)
EndFunc   ;==>GetProfessionSecondary

;~ Description: Returns agent primary profession.
Func GetAgentPrimaryProfession($aAgent = -2)
   If IsPtr($aAgent) <> 0 Then
	  Return MemoryRead($aAgent + 266, 'byte')
   ElseIf IsDllStruct($aAgent) <> 0 Then
	  Return DllStructGetData($aAgent, 'Primary')
   Else
	  Return MemoryRead(GetAgentPtr($aAgent) + 266, 'byte')
   EndIf
EndFunc   ;==>GetAgentPrimaryProfession

;~ Description: Returns agent secondary profession.
Func GetAgentSecondaryProfession($aAgent = -2)
   If IsPtr($aAgent) <> 0 Then
	  Return MemoryRead($aAgent + 267, 'byte')
   ElseIf IsDllStruct($aAgent) <> 0 Then
	  Return DllStructGetData($aAgent, 'Secondary')
   Else
	  Return MemoryRead(GetAgentPtr($aAgent) + 267, 'byte')
   EndIf
EndFunc   ;==>GetAgentSecondaryProfession

;~ Description: Returns primary/secondary as string.
Func GetAgentProfessionsName($aAgent = -2)
   Return GetProfessionName(GetAgentPrimaryProfession($aAgent)) & "/" & GetProfessionName(GetAgentSecondaryProfession($aAgent))
EndFunc   ;==>GetAgentProfessionsName

;~ Description: Returns profession's abbreviation.
Func GetProfessionName($aProf)
   Switch $aProf
	  Case 0 ; $PROFESSION_None
		 Return "x"
	  Case 1 ; $PROFESSION_Warrior
		 Return "W"
	  Case 2 ; $PROFESSION_Ranger
		 Return "R"
	  Case 3 ; $PROFESSION_Monk
		 Return "Mo"
	  Case 4 ; $PROFESSION_Necromancer
		 Return "N"
	  Case 5 ; $PROFESSION_Mesmer
		 Return "Me"
	  Case 6 ; $PROFESSION_Elementalist
		 Return "E"
	  Case 7 ; $PROFESSION_Assassin
		 Return "A"
	  Case 8 ; $PROFESSION_Ritualist
		 Return "Rt"
	  Case 9 ; $PROFESSION_Paragon
		 Return "P"
	  Case 10 ; $PROFESSION_Dervish
		 Return "D"
   EndSwitch
EndFunc   ;==>GetProfessionName

;~ Description: Returns profession's fullname.
Func GetProfessionFullName($aProf)
   Switch $aProf
	  Case 0 ; $PROFESSION_None
		 Return "x"
	  Case 1 ; $PROFESSION_Warrior
		 Return "Warrior"
	  Case 2 ; $PROFESSION_Ranger
		 Return "Ranger"
	  Case 3 ; $PROFESSION_Monk
		 Return "Monk"
	  Case 4 ; $PROFESSION_Necromancer
		 Return "Necromancer"
	  Case 5 ; $PROFESSION_Mesmer
		 Return "Mesmer"
	  Case 6 ; $PROFESSION_Elementalist
		 Return "Elementalist"
	  Case 7 ; $PROFESSION_Assassin
		 Return "Assassin"
	  Case 8 ; $PROFESSION_Ritualist
		 Return "Ritualist"
	  Case 9 ; $PROFESSION_Paragon
		 Return "Paragon"
	  Case 10 ; $PROFESSION_Dervish
		 Return "Dervish"
   EndSwitch
EndFunc   ;==>GetProfessionFullName

;~ Description: Returns true if agent is main healing profession.
Func GetIsHealer($aAgent)
   $lPrimaryProfession = GetAgentPrimaryProfession($aAgent)
   Switch $lPrimaryProfession
	  Case 3,8; $PROFESSION_Monk, $PROFESSION_Ritualist
		 Return True
   EndSwitch
   $lSecondaryProfession = GetAgentSecondaryProfession($aAgent)
   Switch $lSecondaryProfession
	  Case 3,8; $PROFESSION_Monk, $PROFESSION_Ritualist
		 Return True
   EndSwitch
EndFunc   ;==>GetIsHealer

;~ Description: Returns true if agent is monk.
Func IsMonk($aAgent)
   If GetAgentPrimaryProfession($aAgent) = 3 Then Return True ; $PROFESSION_Monk
   If GetAgentSecondaryProfession($aAgent) = 3 Then Return True ; $PROFESSION_Monk
   Return False
EndFunc   ;==>IsMonk

;~ Description: Returns true if agent is E/Mo.
Func IsEMo($aAgent)
   If GetAgentPrimaryProfession($aAgent) = 6 And GetAgentSecondaryProfession($aAgent) = 3 Then Return True ; $PROFESSION_Elementalist, $PROFESSION_Monk
EndFunc   ;==>IsEMo

;~ Description: Returns true if agent uses a martial weapon
Func GetIsMartial($aAgent)
   Local $lAgentWeaponType
   If IsPtr($aAgent) <> 0 Then
	  $lAgentWeaponType = MemoryRead($aAgent + 434, 'word')
   ElseIf IsDllStruct($aAgent) <> 0 Then
	  $lAgentWeaponType = DllStructGetData($aAgent, 'WeaponType')
   Else
	  $lAgentWeaponType = MemoryRead(GetAgentPtr($aAgent) + 434, 'word')
   EndIf
   Switch $lAgentWeaponType
	  Case 1 To 7
		 Return True
	  Case Else
		 Return False
   EndSwitch
EndFunc   ;==>GetIsMartial
#EndRegion
#EndRegion Information

#Region CheckRupt
;~ Description: Checks if rupted.
Func CheckRupt($aCaster, $aTarget, $aSkill, $aActivationTime)
   If IsPtr($aCaster) <> 0 Then
	  Local $lCasterPtr = $aCaster
	  Local $lCasterAllegiance = MemoryRead($aCaster + 433, 'byte')
	  Local $lCasterTypeMap = MemoryRead($aCaster + 344, 'long')
   ElseIf IsDllStruct($aCaster) <> 0 Then
	  Local $lCasterPtr = GetAgentPtr(DllStructGetData($aCaster, 'ID'))
	  Local $lCasterAllegiance = DllStructGetData($aCaster, 'Allegiance')
	  Local $lCasterTypeMap = DllStructGetData($aCaster, 'TypeMap')
   Else
	  Local $lCasterPtr = GetAgentPtr($aCaster)
	  Local $lCasterAllegiance = MemoryRead($aCaster + 433, 'byte')
	  Local $lCasterTypeMap = MemoryRead($aCaster + 344, 'long')
   EndIf
   If IsPtr($aSkill) <> 0 Then
	  Local $lSkillType = MemoryRead($aSkill + 12, 'long')
	  Local $lSkillDuration = MemoryRead($aSkill + 72, 'long')
	  Local $lSkillActivation = MemoryRead($aSkill + 60, 'float')
   ElseIf IsDllStruct($aSkill) <> 0 Then
	  Local $lSkillType = DllStructGetData($aSkill, 'Type')
	  Local $lSkillDuration = DllStructGetData($aSkill, 'Duration15')
	  Local $lSkillActivation = DllStructGetData($aSkill, 'Activation')
   Else
	  Local $lSkillPtr = GetSkillPtr($aSkill)
	  Local $lSkillType = MemoryRead($lSkillPtr + 12, 'long')
	  Local $lSkillDuration = MemoryRead($lSkillPtr + 72, 'long')
	  Local $lSkillActivation = MemoryRead($lSkillPtr + 60, 'float')
   EndIf
   Local $ICast = False
   If $lCasterAllegiance = 3 And Not BitAND($lCasterTypeMap, 262144) Then
	  If $lSkillType = 5 Then ; $SKILLTYPE_Spell
		 ;;;;;;;;;;;;;;;;;;;  Interrupt  ;;;;;;;;;;;;;;;;;;;;;;;
		 If GetDistanceToE($lCasterPtr) < 1249 And GetEnergy(-2) > 10 Then
			For $i = 1 To 8
			   If Not $IsInterrupt[$i] Then ContinueLoop
			   If GetSkillbarSkillRecharge($i) <> 0 Then ContinueLoop
			   UseSkill($i, $lCasterPtr, True)
			   $ICast = True
			   Update("INTERRUPT!")
			   ExitLoop
			Next
		 EndIf
	  EndIf
	  ;;;;;;;;;;;;;;;;;;;;;;;  AOE Evasion  ;;;;;;;;;;;;;;;;;;;;;
	  If $lSkillType = 5 And SkillAOERange($aSkill) > 0 And $lSkillDuration > 0 Then ; $SKILLTYPE_Spell
		 If GetDistance($lCasterPtr) < 1249 And $lSkillActivation > 0.15 Then
			$EnemyCaster = $lCasterPtr
			$EnemyCasterTimer = TimerInit()
			$EnemyCasterActivationTime = $lSkillActivation
		 EndIf
		 If GetDistance($aTarget) < 500 Then
			$AOEDanger = True
			$AOEDangerTimer = TimerInit()
			$AOEDangerRange = SkillAOERange($aSkill)
			$AOEDangerDuration = $lSkillDuration
			$AOEDangerXLocation = XLocation($aTarget) ; Caster is Enemy so Target must be Friendly
			$AOEDangerYLocation = YLocation($aTarget)
		 EndIf
	  EndIf
	  If $lSkillType = 14 Then
		 If GetDistance($lCasterPtr) < 1249 Then $EnemyAttacker = $lCasterPtr
	  EndIf
   EndIf
EndFunc   ;==>CheckRupt
#EndRegion