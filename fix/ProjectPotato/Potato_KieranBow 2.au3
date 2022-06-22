#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=..\..\..\..\..\..\Black Shield Armory\AR Lower Art\Toy Boy Panda.ico
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#Region
#EndRegion

#include <Memory.au3>
#include <ButtonConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <misc.au3>
#include "GWA2.au3"

$DLL=DLLOPEN("user32.dll")
HotKeySet("{ESC}", "exitit")
Local $Character = InputBox("Keiran Bow", "Character Name","","",100,130)

GUICreate("Keiran Bow quick script- B_farmer", 170, 60)

;Initialize(ProcessExists("gw.exe"))
Initialize($Character, True)
$btn1 = GUICtrlCreateButton("Bow", 5, 5, 160, 20, $WS_GROUP)
$btn2 = GUICtrlCreateButton("Quest", 5, 35, 160, 20, $WS_GROUP)

GUISetState(@SW_SHOW)

  While 1
        $msg = GUIGetMsg()
        Select
            Case $msg = $GUI_EVENT_CLOSE
                ExitLoop
            Case $msg = $btn1
                                Dialog(0x0000008A)
			Case $msg = $btn2
						        Dialog(0x00000631)

        EndSelect
    WEnd

func exitit()
    Exit
endfunc