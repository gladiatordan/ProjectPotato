#cs

	TODO :
		- Interaction functions Bot.ini
		- CustomBuildIni_Internal
#ce

#Region .ini handeling Functions
	#Region .ini Init Functions
Func IniFilesPresent() ;Check if all .ini files are in place
	If Not FileExists("Ini_Files/Bot_Main.ini") Then
		MsgBox(16, "PreFarmer_Bot", "Cannot find Bot_Main.ini file in Ini_Files folder.")
		_exit()
	EndIf
	If Not FileExists("Ini_Files/Bot_Second.ini") Then
		MsgBox(16, "PreFarmer_Bot", "Cannot find Bot_Second.ini file in Ini_Files folder.")
		_exit()
	EndIf
	If Not FileExists("Ini_Files/Config_Main.ini") Then
		MsgBox(16, "PreFarmer_Bot", "Cannot find Config_Main.ini file in Ini_Files folder.")
		_exit()
	EndIf
	If Not FileExists("Ini_Files/Config_Second.ini") Then
		MsgBox(16, "PreFarmer_Bot", "Cannot find Config_Second.ini file in Ini_Files folder.")
		_exit()
	EndIf
	If Not FileExists("Ini_Files/CustomBuild_Main.ini") Then
		MsgBox(16, "PreFarmer_Bot", "Cannot find CustomBuild_Main.ini file in Ini_Files folder.")
		_exit()
	EndIf
	If Not FileExists("Ini_Files/CustomBuild_Second.ini") Then
		MsgBox(16, "PreFarmer_Bot", "Cannot find CustomBuild_Second.ini file in Ini_Files folder.")
		_exit()
	EndIf
EndFunc

Func ClearIni($State = 0) ;Calls ClearIni_Internal (default:all=0, main=1, second=2)
	Switch $State
		Case 0
			ClearIni_Internal("Ini_Files/Bot_Main.ini")
			ClearIni_Internal("Ini_Files/Bot_Second.ini")
		Case 1
			ClearIni_Internal("Ini_Files/Bot_Main.ini")
		Case 2
			ClearIni_Internal("Ini_Files/Bot_Second.ini")
		Case Else
			logFile("ClearIni : Invalid parameter.")
			logFile("Bot.ini files not cleaned.")
	EndSwitch
EndFunc

Func ClearIni_Internal($StateString) ;Clear the .ini files based on bot's number
	Local $ActionsData[3]
	Local $CharacterData[3]
	Local $CharStateData[2]
	Local $Pos_Data[2]
	Local $InteractionData[2]
	
	If ($StateString == "Ini_Files/Bot_Main.ini") Then
		$ActionsData[0] = "isRunning="&False
		$ActionsData[1] = "RunID="&0
		$ActionsData[2] = "FarmID="&0
		IniWriteSection($StateString,"Actions",$ActionsData[0]&@LF&$ActionsData[1]&@LF&$ActionsData[2])
	EndIf
	If (($StateString == "Ini_Files/Bot_Main.ini") OR ($StateString == "Ini_Files/Bot_Second.ini")) Then
		$CharacterData[0] = "Name="&0
		$CharacterData[1] = "ProfessionMain="&0
		$CharacterData[2] = "ProfessionSecondary="&0
		IniWriteSection($StateString,"Character",$CharacterData[0]&@LF&$CharacterData[1]&@LF&$CharacterData[2])

		$CharStateData[0] = "Health="&0
		$CharStateData[1] = "Dead="&False
		IniWriteSection($StateString,"CharState",$CharStateData[0]&@LF&$CharStateData[1])
		
		$Pos_Data[0] = "Pos_X="&0
		$Pos_Data[1] = "Pos_Y="&0
		IniWriteSection($StateString,"Position",$Pos_Data[0]&@LF&$Pos_Data[1])

		$InteractionData[0] = "LastSpellType="&0
		$InteractionData[1] = "Resigned="&False
		IniWriteSection($StateString,"Interaction",$InteractionData[0]&@LF&$InteractionData[1])
	EndIf
EndFunc
	#EndRegion .ini Init Functions
	
	#Region .ini GUI Functions
		#Region .ini Save Functions
Func SaveConfigIni_Main() ;Calls SaveConfigIni_Internal for main
	SaveConfigIni_Internal("Ini_Files/Config_Main.ini")
EndFunc

Func SaveConfigIni_Second() ;Calls SaveConfigIni_Internal for second
	SaveConfigIni_Internal("Ini_Files/Config_Second.ini")
EndFunc

Func SaveBuildIni_Main() ;Calls SaveBuildIni_Internal for main
	SaveBuildIni_Internal("Ini_Files/CustomBuild_Main.ini")
EndFunc

Func SaveBuildIni_Second() ;Calls SaveBuildIni_Internal for second
	SaveBuildIni_Internal("Ini_Files/CustomBuild_Second.ini")
EndFunc

Func SaveConfigIni_Internal($StateString) ;Saves checkboxes settings in the corresponding Config.ini file
	Local $SettingsData[6]
	Local $PconsData[2]
	Local $PickDyeData[9]
	Local $SellBagsData[4]
	Local $PickItemsData[5]
    
    ;All is false
    $SettingsData[0] = "Offline="&False
	$SettingsData[1] = "UseStone="&False
	$SettingsData[2] = "TradeNicholas="&False
	$SettingsData[3] = "DontSellPurple="&False
	$SettingsData[4] = "LDoAlvl19="&False
	$SettingsData[5] = "SurvivorTitle="&False
    
    $PconsData[0] = "Sweets="&False
    $PconsData[1] = "Morale="&False
    
    $PickDyeData[0] = "Blue="&False
	$PickDyeData[1] = "Red="&False
	$PickDyeData[2] = "Orange="&False
	$PickDyeData[3] = "Green="&False
	$PickDyeData[4] = "Yellow="&False
	$PickDyeData[5] = "Silver="&False
	$PickDyeData[6] = "Purple="&False
	$PickDyeData[7] = "Brown="&False
	$PickDyeData[8] = "Pink="&False
    
    $SellBagsData[0] = "Bag1="&False
	$SellBagsData[1] = "Bag2="&False
	$SellBagsData[2] = "Bag3="&False
	$SellBagsData[3] = "Bag4="&False
    
    $PickItemsData[0] = "PickWhite="&False
	$PickItemsData[1] = "PickBlue="&False
	$PickItemsData[2] = "PickPurple="&False
	$PickItemsData[3] = "PickGold="&False
	$PickItemsData[4] = "PickGreen="&False
    
    ;Reading what is true			
	If GUICtrlRead($Status) == $GUI_CHECKED Then $SettingsData[0] = "Offline="&True
	If GUICtrlRead($Stone) == $GUI_CHECKED Then $SettingsData[1] = "UseStone="&True
	If GUICtrlRead($GoNicholas) == $GUI_CHECKED Then $SettingsData[2] = "TradeNicholas="&True
	If GUICtrlRead($DontSellPurple) == $GUI_CHECKED Then $SettingsData[3] = "DontSellPurple="&True
	If GUICtrlRead($Lvl19) == $GUI_CHECKED Then $SettingsData[4] = "LDoAlvl19="&True
	If GUICtrlRead($Survivor) == $GUI_CHECKED Then $SettingsData[5] = "SurvivorTitle="&True
	IniWriteSection($StateString,"Settings",$SettingsData[0]&@LF&$SettingsData[1]&@LF&$SettingsData[2]&@LF&$SettingsData[3]&@LF&$SettingsData[4]&@LF&$SettingsData[5])	
	
	If GUICtrlRead($UsePcons_Sweets) == $GUI_CHECKED Then $PconsData[0] = "Sweets="&True
	If GUICtrlRead($UsePcons_Moral) == $GUI_CHECKED Then $PconsData[1] = "Morale="&True
	IniWriteSection($StateString,"Pcons",$PconsData[0]&@LF&$PconsData[1])
	
	If GUICtrlRead($PickDye_Blue) == $GUI_CHECKED Then $PickDyeData[0] = "Blue="&True
	If GUICtrlRead($PickDye_Red) == $GUI_CHECKED Then $PickDyeData[1] = "Red="&True
	If GUICtrlRead($PickDye_Orange) == $GUI_CHECKED Then $PickDyeData[2] = "Orange="&True
	If GUICtrlRead($PickDye_Green) == $GUI_CHECKED Then $PickDyeData[3] = "Green="&True
	If GUICtrlRead($PickDye_Yellow) == $GUI_CHECKED Then $PickDyeData[4] = "Yellow="&True
	If GUICtrlRead($PickDye_Silver) == $GUI_CHECKED Then $PickDyeData[5] = "Silver="&True
	If GUICtrlRead($PickDye_Purple) == $GUI_CHECKED Then $PickDyeData[6] = "Purple="&True
	If GUICtrlRead($PickDye_Brown) == $GUI_CHECKED Then $PickDyeData[7] = "Brown="&True
	If GUICtrlRead($PickDye_Pink) == $GUI_CHECKED Then $PickDyeData[8] = "Pink="&True
	IniWriteSection($StateString,"PickDye",$PickDyeData[0]&@LF&$PickDyeData[1]&@LF&$PickDyeData[2]&@LF&$PickDyeData[3]&@LF&$PickDyeData[4]&@LF&$PickDyeData[5]&@LF&$PickDyeData[6]&@LF&$PickDyeData[7]&@LF&$PickDyeData[8])

	If GUICtrlRead($SellBag1) == $GUI_CHECKED Then $SellBagsData[0] = "Bag1="&True
	If GUICtrlRead($SellBag2) == $GUI_CHECKED Then $SellBagsData[1] = "Bag2="&True
	If GUICtrlRead($SellBag3) == $GUI_CHECKED Then $SellBagsData[2] = "Bag3="&True
	If GUICtrlRead($SellBag4) == $GUI_CHECKED Then $SellBagsData[3] = "Bag4="&True
	IniWriteSection($StateString,"SellBags",$SellBagsData[0]&@LF&$SellBagsData[1]&@LF&$SellBagsData[2]&@LF&$SellBagsData[3])

	If GUICtrlRead($PickWhite) == $GUI_CHECKED Then $PickItemsData[0] = "PickWhite="&True
	If GUICtrlRead($PickBlue) == $GUI_CHECKED Then $PickItemsData[1] = "PickBlue="&True
	If GUICtrlRead($PickPurple) == $GUI_CHECKED Then $PickItemsData[2] = "PickPurple="&True
	If GUICtrlRead($PickGold) == $GUI_CHECKED Then $PickItemsData[3] = "PickGold="&True
	If GUICtrlRead($PickGreen) == $GUI_CHECKED Then $PickItemsData[4] = "PickGreen="&True
	IniWriteSection($StateString,"PickItems",$PickItemsData[0]&@LF&$PickItemsData[1]&@LF&$PickItemsData[2]&@LF&$PickItemsData[3]&@LF&$PickItemsData[4])

    If GUICtrlRead($OverwriteSecond_Checkbox) == $GUI_CHECKED Then OverwriteSecond_Config()
EndFunc

Func SaveBuildIni_Internal($StateString) ;Saves custom build settings in the corresponding CustomBuild.ini file
	Local $TemplateData[1]
	Local $SkillTypeData[8]
    
    ;All is false
    $TemplateData[0] = "BuildTemplate="&0
    
    $SkillTypeData[0] = "Skill_1="&"Void"
    $SkillTypeData[1] = "Skill_2="&"Void"
    $SkillTypeData[2] = "Skill_3="&"Void"
    $SkillTypeData[3] = "Skill_4="&"Void"
    $SkillTypeData[4] = "Skill_5="&"Void"
    $SkillTypeData[5] = "Skill_6="&"Void"
    $SkillTypeData[6] = "Skill_7="&"Void"
    $SkillTypeData[7] = "Skill_8="&"Void"
    
    ;Reading what have been choosen			
	If (GUICtrlRead($CustomBuild_Template, "") <> "") Then $TemplateData[0] = "BuildTemplate="&GUICtrlRead($CustomBuild_Template, "")
	IniWriteSection($StateString,"CustomBuild",$TemplateData[0])	
	
	If (GUICtrlRead($Custom_Skill_1_Type, "") <> "Void") Then $SkillTypeData[0] = "Skill_1="&GUICtrlRead($Custom_Skill_1_Type, "")
	If (GUICtrlRead($Custom_Skill_2_Type, "") <> "Void") Then $SkillTypeData[1] = "Skill_2="&GUICtrlRead($Custom_Skill_2_Type, "")
	If (GUICtrlRead($Custom_Skill_3_Type, "") <> "Void") Then $SkillTypeData[2] = "Skill_3="&GUICtrlRead($Custom_Skill_3_Type, "")
	If (GUICtrlRead($Custom_Skill_4_Type, "") <> "Void") Then $SkillTypeData[3] = "Skill_4="&GUICtrlRead($Custom_Skill_4_Type, "")
	If (GUICtrlRead($Custom_Skill_5_Type, "") <> "Void") Then $SkillTypeData[4] = "Skill_5="&GUICtrlRead($Custom_Skill_5_Type, "")
	If (GUICtrlRead($Custom_Skill_6_Type, "") <> "Void") Then $SkillTypeData[5] = "Skill_6="&GUICtrlRead($Custom_Skill_6_Type, "")
	If (GUICtrlRead($Custom_Skill_7_Type, "") <> "Void") Then $SkillTypeData[6] = "Skill_7="&GUICtrlRead($Custom_Skill_7_Type, "")
	If (GUICtrlRead($Custom_Skill_8_Type, "") <> "Void") Then $SkillTypeData[7] = "Skill_8="&GUICtrlRead($Custom_Skill_8_Type, "")

	IniWriteSection($StateString,"SkillTypes",$SkillTypeData[0]&@LF&$SkillTypeData[1]&@LF&$SkillTypeData[2]&@LF&$SkillTypeData[3]&@LF&$SkillTypeData[4]&@LF&$SkillTypeData[5]&@LF&$SkillTypeData[6]&@LF&$SkillTypeData[7])
	
    If GUICtrlRead($OverwriteSecond_Build_Checkbox) == $GUI_CHECKED Then OverwriteSecond_Build()
EndFunc
		#EndRegion .ini Save Functions
	
Func ConfigIni_Checkbox($State = 0) ;Calls ConfigIni_Checkbox_Internal (default:all=0, main=1, second=2)
	Switch $State
		Case 0
			ConfigIni_Checkbox_Internal("Ini_Files/Config_Main.ini")
			ConfigIni_Checkbox_Internal("Ini_Files/Config_Second.ini")
		Case 1
			ConfigIni_Checkbox_Internal("Ini_Files/Config_Main.ini")
		Case 2
			ConfigIni_Checkbox_Internal("Ini_Files/Config_Second.ini")
		Case Else
			logFile("Ini_Files/ConfigIni_Checkbox : Invalid parameter.")
			logFile("Checkboxes unchanged.")
	EndSwitch
EndFunc

Func CustomBuildIni($State = 0) ;Calls CustomBuildIni_Internal (Default:all=0, main=1, second=2)
	Switch $State
		Case 0
			CustomBuildIni_Internal("Ini_Files/CustomBuild_Main.ini")
			CustomBuildIni_Internal("Ini_Files/CustomBuild_Second.ini")
		Case 1
			CustomBuildIni_Internal("Ini_Files/CustomBuild_Main.ini")
		Case 2
			CustomBuildIni_Internal("Ini_Files/CustomBuild_Second.ini")
		Case Else
			logFile("Ini_Files/CustomBuild.ini : Invalid parameter.")
			logFile("Build params unchanged.")
	EndSwitch
EndFunc
	
Func ConfigIni_Checkbox_Internal($StateString) ;Checks Option checkbox based on Config.ini
	If (IniRead($StateString,"Settings","Offline","") == True) Then
		GUICtrlSetState($Status, $GUI_CHECKED)
	EndIf
	If (IniRead($StateString,"Settings","UseStone","") == True) Then
		GUICtrlSetState($Stone, $GUI_CHECKED)
	EndIf
	If (IniRead($StateString,"Settings","TradeNicholas","") == True) Then
		GUICtrlSetState($GoNicholas, $GUI_CHECKED)
	EndIf
	If (IniRead($StateString,"Settings","DontSellPurple","") == True) Then
		GUICtrlSetState($DontSellPurple, $GUI_CHECKED)
	EndIf
	If (IniRead($StateString,"Settings","LDoAlvl19","") == True) Then
		GUICtrlSetState($Lvl19, $GUI_CHECKED)
	EndIf
	If (IniRead($StateString,"Settings","SurvivorTitle","") == True) Then
		GUICtrlSetState($Survivor, $GUI_CHECKED)
	EndIf
	If (IniRead($StateString,"Pcons","Sweets","") == True) Then
		GUICtrlSetState($UsePcons_Sweets, $GUI_CHECKED)
	EndIf
	If (IniRead($StateString,"Pcons","Morale","") == True) Then
		GUICtrlSetState($UsePcons_Moral, $GUI_CHECKED)
	EndIf
	If (IniRead($StateString,"PickDye","Blue","") == True) Then
		GUICtrlSetState($PickDye_Blue, $GUI_CHECKED)
	EndIf
	If (IniRead($StateString,"PickDye","Red","") == True) Then
		GUICtrlSetState($PickDye_Red, $GUI_CHECKED)
	EndIf
	If (IniRead($StateString,"PickDye","Orange","") == True) Then
		GUICtrlSetState($PickDye_Orange, $GUI_CHECKED)
	EndIf
	If (IniRead($StateString,"PickDye","Green","") == True) Then
		GUICtrlSetState($PickDye_Green, $GUI_CHECKED)
	EndIf
	If (IniRead($StateString,"PickDye","Yellow","") == True) Then
		GUICtrlSetState($PickDye_Yellow, $GUI_CHECKED)
	EndIf
	If (IniRead($StateString,"PickDye","Silver","") == True) Then
		GUICtrlSetState($PickDye_Silver, $GUI_CHECKED)
	EndIf
	If (IniRead($StateString,"PickDye","Purple","") == True) Then
		GUICtrlSetState($PickDye_Purple, $GUI_CHECKED)
	EndIf
	If (IniRead($StateString,"PickDye","Brown","") == True) Then
		GUICtrlSetState($PickDye_Brown, $GUI_CHECKED)
	EndIf
	If (IniRead($StateString,"PickDye","Pink","") == True) Then
		GUICtrlSetState($PickDye_Pink, $GUI_CHECKED)
	EndIf
	If (IniRead($StateString,"SellBags","Bag1","") == True) Then
		GUICtrlSetState($SellBag1, $GUI_CHECKED)
	EndIf
	If (IniRead($StateString,"SellBags","Bag2","") == True) Then
		GUICtrlSetState($SellBag2, $GUI_CHECKED)
	EndIf
	If (IniRead($StateString,"SellBags","Bag3","") == True) Then
		GUICtrlSetState($SellBag3, $GUI_CHECKED)
	EndIf
	If (IniRead($StateString,"SellBags","Bag4","") == True) Then
		GUICtrlSetState($SellBag4, $GUI_CHECKED)
	EndIf
	If (IniRead($StateString,"PickItems","PickWhite","") == True) Then
		GUICtrlSetState($PickWhite, $GUI_CHECKED)
	EndIf
	If (IniRead($StateString,"PickItems","PickBlue","") == True) Then
		GUICtrlSetState($PickBlue, $GUI_CHECKED)
	EndIf
	If (IniRead($StateString,"PickItems","PickPurple","") == True) Then
		GUICtrlSetState($PickPurple, $GUI_CHECKED)
	EndIf
	If (IniRead($StateString,"PickItems","PickGold","") == True) Then
		GUICtrlSetState($PickGold, $GUI_CHECKED)
	EndIf
	If (IniRead($StateString,"PickItems","PickGreen","") == True) Then
		GUICtrlSetState($PickGreen, $GUI_CHECKED)
	EndIf
EndFunc
	
Func CustomBuildIni_Internal($StateString) ;Fills Custom build tab based on CustomBuild.ini
	If (IniRead($StateString,"CustomBuild","BuildTemplate","") <> "") Then
		GUICtrlSetData($CustomBuild_Template, IniRead($StateString,"CustomBuild","BuildTemplate",""))
	EndIf
	If (IniRead($StateString,"SkillTypes","Skill_1","") <> "") Then
		GUICtrlSetData($Custom_Skill_1_Type, IniRead($StateString,"SkillTypes","Skill_1",""))
	EndIf
	If (IniRead($StateString,"SkillTypes","Skill_2","") <> "") Then
		GUICtrlSetData($Custom_Skill_2_Type, IniRead($StateString,"SkillTypes","Skill_2",""))
	EndIf
	If (IniRead($StateString,"SkillTypes","Skill_3","") <> "") Then
		GUICtrlSetData($Custom_Skill_3_Type, IniRead($StateString,"SkillTypes","Skill_3",""))
	EndIf
	If (IniRead($StateString,"SkillTypes","Skill_4","") <> "") Then
		GUICtrlSetData($Custom_Skill_4_Type, IniRead($StateString,"SkillTypes","Skill_4",""))
	EndIf
	If (IniRead($StateString,"SkillTypes","Skill_5","") <> "") Then
		GUICtrlSetData($Custom_Skill_5_Type, IniRead($StateString,"SkillTypes","Skill_5",""))
	EndIf
	If (IniRead($StateString,"SkillTypes","Skill_6","") <> "") Then
		GUICtrlSetData($Custom_Skill_6_Type, IniRead($StateString,"SkillTypes","Skill_6",""))
	EndIf
	If (IniRead($StateString,"SkillTypes","Skill_7","") <> "") Then
		GUICtrlSetData($Custom_Skill_7_Type, IniRead($StateString,"SkillTypes","Skill_7",""))
	EndIf
	If (IniRead($StateString,"SkillTypes","Skill_8","") <> "") Then
		GUICtrlSetData($Custom_Skill_8_Type, IniRead($StateString,"SkillTypes","Skill_8",""))
	EndIf
EndFunc
	
Func OverwriteSecond_Config() ;Overwrite Config_Second.ini with Config_Main.ini params
    IniWrite("Ini_Files/Config_Second.ini","Settings","Offline",IniRead("Ini_Files/Config_Main.ini","Settings","Offline",""))
	IniWrite("Ini_Files/Config_Second.ini","Settings","UseStone",IniRead("Ini_Files/Config_Main.ini","Settings","UseStone",""))
	IniWrite("Ini_Files/Config_Second.ini","Settings","TradeNicholas",IniRead("Ini_Files/Config_Main.ini","Settings","TradeNicholas",""))
	IniWrite("Ini_Files/Config_Second.ini","Settings","DontSellPurple",IniRead("Ini_Files/Config_Main.ini","Settings","DontSellPurple",""))
	IniWrite("Ini_Files/Config_Second.ini","Settings","LDoAlvl19",IniRead("Ini_Files/Config_Main.ini","Settings","LDoAlvl19",""))
	IniWrite("Ini_Files/Config_Second.ini","Settings","SurvivorTitle",IniRead("Ini_Files/Config_Main.ini","Settings","SurvivorTitle",""))
	
	IniWrite("Ini_Files/Config_Second.ini","Pcons","Sweets",IniRead("Ini_Files/Config_Main.ini","Pcons","Sweets",""))
	IniWrite("Ini_Files/Config_Second.ini","Pcons","Morale",IniRead("Ini_Files/Config_Main.ini","Pcons","Morale",""))
	
	IniWrite("Ini_Files/Config_Second.ini","PickDye","Blue",IniRead("Ini_Files/Config_Main.ini","PickDye","Blue",""))
	IniWrite("Ini_Files/Config_Second.ini","PickDye","Red",IniRead("Ini_Files/Config_Main.ini","PickDye","Red",""))
	IniWrite("Ini_Files/Config_Second.ini","PickDye","Orange",IniRead("Ini_Files/Config_Main.ini","PickDye","Orange",""))
	IniWrite("Ini_Files/Config_Second.ini","PickDye","Green",IniRead("Ini_Files/Config_Main.ini","PickDye","Green",""))
	IniWrite("Ini_Files/Config_Second.ini","PickDye","Yellow",IniRead("Ini_Files/Config_Main.ini","PickDye","Yellow",""))
	IniWrite("Ini_Files/Config_Second.ini","PickDye","Silver",IniRead("Ini_Files/Config_Main.ini","PickDye","Silver",""))
	IniWrite("Ini_Files/Config_Second.ini","PickDye","Purple",IniRead("Ini_Files/Config_Main.ini","PickDye","Purple",""))
	IniWrite("Ini_Files/Config_Second.ini","PickDye","Brown",IniRead("Ini_Files/Config_Main.ini","PickDye","Brown",""))
	IniWrite("Ini_Files/Config_Second.ini","PickDye","Pink",IniRead("Ini_Files/Config_Main.ini","PickDye","Pink",""))
	
   	IniWrite("Ini_Files/Config_Second.ini","SellBags","Bag1",IniRead("Ini_Files/Config_Main.ini","SellBags","Bag1",""))
	IniWrite("Ini_Files/Config_Second.ini","SellBags","Bag2",IniRead("Ini_Files/Config_Main.ini","SellBags","Bag2",""))
	IniWrite("Ini_Files/Config_Second.ini","SellBags","Bag3",IniRead("Ini_Files/Config_Main.ini","SellBags","Bag3",""))
	IniWrite("Ini_Files/Config_Second.ini","SellBags","Bag4",IniRead("Ini_Files/Config_Main.ini","SellBags","Bag4",""))
	
	IniWrite("Ini_Files/Config_Second.ini","PickItems","PickWhite",IniRead("Ini_Files/Config_Main.ini","PickItems","PickWhite",""))
	IniWrite("Ini_Files/Config_Second.ini","PickItems","PickBlue",IniRead("Ini_Files/Config_Main.ini","PickItems","PickBlue",""))
	IniWrite("Ini_Files/Config_Second.ini","PickItems","PickPurple",IniRead("Ini_Files/Config_Main.ini","PickItems","PickPurple",""))
	IniWrite("Ini_Files/Config_Second.ini","PickItems","PickGold",IniRead("Ini_Files/Config_Main.ini","PickItems","PickGold",""))
	IniWrite("Ini_Files/Config_Second.ini","PickItems","PickGreen",IniRead("Ini_Files/Config_Main.ini","PickItems","PickGreen",""))
EndFunc

Func OverwriteSecond_Build() ;Overwrite CustomBuild_Second.ini with CustomBuild_Main.ini params
	IniWrite("Ini_Files/CustomBuild_Second.ini","CustomBuild","BuildTemplate",IniRead("Ini_Files/CustomBuild_Main.ini","CustomBuild","BuildTemplate",""))
	
	IniWrite("Ini_Files/CustomBuild_Second.ini","SkillTypes","Skill_1",IniRead("Ini_Files/CustomBuild_Main.ini","SkillTypes","Skill_1",""))
	IniWrite("Ini_Files/CustomBuild_Second.ini","SkillTypes","Skill_2",IniRead("Ini_Files/CustomBuild_Main.ini","SkillTypes","Skill_2",""))
	IniWrite("Ini_Files/CustomBuild_Second.ini","SkillTypes","Skill_3",IniRead("Ini_Files/CustomBuild_Main.ini","SkillTypes","Skill_3",""))
	IniWrite("Ini_Files/CustomBuild_Second.ini","SkillTypes","Skill_4",IniRead("Ini_Files/CustomBuild_Main.ini","SkillTypes","Skill_4",""))
	IniWrite("Ini_Files/CustomBuild_Second.ini","SkillTypes","Skill_5",IniRead("Ini_Files/CustomBuild_Main.ini","SkillTypes","Skill_5",""))
	IniWrite("Ini_Files/CustomBuild_Second.ini","SkillTypes","Skill_6",IniRead("Ini_Files/CustomBuild_Main.ini","SkillTypes","Skill_6",""))
	IniWrite("Ini_Files/CustomBuild_Second.ini","SkillTypes","Skill_7",IniRead("Ini_Files/CustomBuild_Main.ini","SkillTypes","Skill_7",""))
	IniWrite("Ini_Files/CustomBuild_Second.ini","SkillTypes","Skill_8",IniRead("Ini_Files/CustomBuild_Main.ini","SkillTypes","Skill_8",""))
EndFunc	

Func ActionsRunning_Ini($BoolRunning) ;Writes if bot is running in Bot_Main.ini. Used by Main bot.
	Local $ActionsData[3]
	
	$ActionsData[0] = "isRunning="&$BoolRunning
	$ActionsData[1] = "RunID="&IniRead("Ini_Files/Bot_Main.ini","Actions","RunID","")
	$ActionsData[2] = "FarmID="&IniRead("Ini_Files/Bot_Main.ini","Actions","FarmID","")
	
	IniWriteSection("Ini_Files/Bot_Main.ini","Actions",$ActionsData[0]&@LF&$ActionsData[1]&@LF&$ActionsData[2])
EndFunc

Func ActionsIDs_Ini() ;Writes Actions in Bot_Main.ini. Used by Main bot.
	Local $ActionsData[3]
	
	$ActionsData[0] = "isRunning="&IniRead("Ini_Files/Bot_Main.ini","Actions","isRunning","")
	$ActionsData[1] = "RunID="&GetRunTownID()
	$ActionsData[2] = "FarmID="&GetJobId()
	
	IniWriteSection("Ini_Files/Bot_Main.ini","Actions",$ActionsData[0]&@LF&$ActionsData[1]&@LF&$ActionsData[2])
EndFunc
	#EndRegion .ini GUI Functions

	#Region InJob Bot.ini discussion
		#Region Job's prep .ini
Func GetCharInfo_Ini($State = 0) ;Calls GetCharInfo_Ini_Internal (Default:all=0, main=1, second=2)
	Switch $State
		Case 0
			GetCharInfo_Ini_Internal("Ini_Files/Bot_Main.ini")
			GetCharInfo_Ini_Internal("Ini_Files/Bot_Second.ini")
		Case 1
			GetCharInfo_Ini_Internal("Ini_Files/Bot_Main.ini")
		Case 2
			GetCharInfo_Ini_Internal("Ini_Files/Bot_Second.ini")
		Case Else
			logFile("GetCharInfo_Ini : Invalid parameter.")
			logFile("Unable to get character's infos.")
	EndSwitch
EndFunc

Func GetCharInfo_Ini_Internal($StateString) ;Gets bot's character's infos and writes it into Bot.ini
	Local $CharacterData[3] 
	
	$CharacterData[0] = "Name="&GetCharname()
	$CharacterData[1] = "ProfessionMain="&GetAgentPrimaryProfession(-2)
	$CharacterData[2] = "ProfessionSecondary="&GetAgentSecondaryProfession(-2)
	IniWriteSection($StateString,"Character",$CharacterData[0]&@LF&$CharacterData[1]&@LF&$CharacterData[2])
EndFunc
		#EndRegion Job's prep .ini
		
		#Region Char state .ini
Func GetCharHealth_Ini($State = 0) ;Calls GetCharHealth_Ini_Internal (Default:all=0, main=1, second=2)
	Switch $State
		Case 0
			GetCharHealth_Ini_Internal("Ini_Files/Bot_Main.ini")
			GetCharHealth_Ini_Internal("Ini_Files/Bot_Second.ini")
		Case 1
			GetCharHealth_Ini_Internal("Ini_Files/Bot_Main.ini")
		Case 2
			GetCharHealth_Ini_Internal("Ini_Files/Bot_Second.ini")
		Case Else
			logFile("GetCharHealth_Ini : Invalid parameter.")
			logFile("Unable to get character's health infos.")
	EndSwitch
EndFunc

Func GetCharHealth_Ini_Internal($StateString) ;Gets character's health and death state and writes it into Bot.ini
	Local $CharStateData[2]
	
	Local $HealthHP
    $HealthHP = ((GetHealth(-2)) * 100/(DllStructGetData(GetAgentByID(-2), 'MaxHP')))
	
	$CharStateData[0] = "Health="&$HealthHP
	If GetIsDead(-2) Then 
		$CharStateData[1] = "Dead="&True
	ElseIf Not GetIsDead(-2) Then
		$CharStateData[1] = "Dead="&False
	Else
		$CharStateData[1] = "Dead="&IniRead($StateString,"CharState","Dead","")
	EndIf
	IniWriteSection($StateString,"CharState",$CharStateData[0]&@LF&$CharStateData[1])
EndFunc
		#EndRegion Char state .ini
		
		#Region Positions .ini
Func GetPos_Ini($State = 0) ;Calls GetPos_Ini_Internal (Default:all=0, Main=1, Second=2)
	Switch $State
		Case 0
			GetPos_Ini_Internal("Ini_Files/Bot_Main.ini")
			GetPos_Ini_Internal("Ini_Files/Bot_Second.ini")
		Case 1
			GetPos_Ini_Internal("Ini_Files/Bot_Main.ini")
		Case 2
			GetPos_Ini_Internal("Ini_Files/Bot_Second.ini")
		Case Else
			logFile("GetPos_Ini : Invalid parameter.")
			logFile("Unable to get bot's position.")
	EndSwitch
EndFunc

Func GetPos_Ini_Internal($StateString) ;Get bot's position and writes into Bot.ini
	Local $lAgent = GetAgentByID(-2)
	Local $BotPosX = DllStructGetData($lAgent, 'X')
	Local $BotPosY = DllStructGetData($lAgent, 'Y')
	
	Local $Pos_Data[2]
	
	$Pos_Data[0] = "Pos_X="&$BotPosX
	$Pos_Data[1] = "Pos_Y="&$BotPosY
	
	IniWriteSection($StateString,"Position",$Pos_Data[0]&@LF&$Pos_Data[1])
EndFunc
		#EndRegion Positions .ini
		
		#Region Interaction .ini
		
		
		
		#EndRegion Interaction .ini
	#EndRegion InJob Bot.ini discussion
#EndRegion .ini handeling Functions
