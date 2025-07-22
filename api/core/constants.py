"""

Constants library



"""
# Misc
TARGET_EXE = "gw.exe"


# Addresses
ADDRESS_BASE_SCAN_CMP_OFFSET = 0x4FF000
ADDRESS_SCAN_PTR_OFFSET      = 0x9DF000
ADDRESS_BASE_MODIFY_MEMORY	 = 0x00C50000

# Sizes
SIZE_QUEUE          	= 0x10 * 256
SIZE_SKILL_LOG      	= 0x10 * 16
SIZE_CHAT_LOG       	= 0x10 * 512
SIZE_TARGET_LOG     	= 0x200 * 4
SIZE_STRING_LOG     	= 0x200 * 256
SIZE_AGENT_COPY_BASE	= 0x1C0 * 256
SIZE_CALLBACK_EVENT 	= 0x501


# Scanner Function Signatures
function_signatures = {
	"ScanBasePointer"              : "506A0F6A00FF35",
	"ScanAgentBase"                : "FF501083C6043BF775E2",
	"ScanAgentBasePointer"		   : "FF501083C6043BF775E28B35",
	"ScanAgentArray"               : "8B0C9085C97419",
	"ScanBuildNumber"			   : "558BEC83EC4053568BD9",
	"ScanCurrentTarget"            : "83C4085F8BE55DC3CCCCCCCCCCCCCCCCCCCCCC55",
	"ScanMapID"					   : "558BEC8B450885C074078B",
	"ScanMyId"                     : "83EC08568BF13B15",
	"ScanEngine"                   : "568B3085F67478EB038D4900D9460C",
	"ScanRenderFunc"               : "F6C401741C68B1010000BA",
	"ScanLoadFinished"             : "8B561C8BCF52E8",
	"ScanPostMessage"              : "6A00680080000051FF15",
	"ScanTargetLog"                : "5356578BFA894DF4E8",
	"ScanChangeTargetFunction"     : "3BDF0F95",
	"ScanMoveFunction"             : "558BEC83EC208D45F0",
	# "ScanPing"                     : "E874651600",
	"ScanPing"                     : "E874651300",
	"ScanMapId"                    : "558BEC8B450885C074078B",
	# "ScanMapLoading"               : "2480ED0000000000",
	"ScanMapLoading"               : "E880ED0000",
	"ScanLoggedIn"                 : "C705ACDE740000000000C3CCCCCCCC",
	"ScanLoggedIn"                 : "C705C029EE0000000000C3CCCCCCCC",
	"ScanRegion"                   : "6A548D46248908",
	"ScanMapInfo"                  : "8BF0EB038B750C3B",
	"ScanLanguage"                 : "C38B75FC8B04B5",
	"ScanUseSkillFunction"         : "85F6745B83FE1174",
	"ScanPacketSendFunction"       : "C747540000000081E6",
	"ScanBaseOffset"               : "83C40433C08BE55DC3A1",
	"ScanWriteChatFunction"        : "8D85E0FEFFFF50681C01",
	"ScanSkillLog"                 : "408946105E5B5D",
	"ScanSkillCompleteLog"         : "741D6A006A40",
	"ScanSkillCancelLog"           : "741D6A006A48",
	"ScanChatLog"                  : "8B45F48B138B4DEC50",
	"ScanSellItemFunction"         : "8B4D2085C90F858E",
	"ScanStringLog"                : "893E8B7D10895E04397E08",
	"ScanStringFilter1"            : "8B368B4F2C6A006A008B06",
	"ScanStringFilter2"            : "515356578BF933D28B4F2C",
	"ScanActionFunction"           : "8B7508578BF983FE09750C6876",
	"ScanActionBase"               : "8D1C87899DF4",
	"ScanSkillBase"                : "8D04B6C1E00505",
	"ScanUseHeroSkillFunction"     : "BA02000000B954080000",
	"ScanTransactionFunction"      : "85FF741D8B4D14EB08",
	"ScanBuyItemFunction"          : "D9EED9580CC74004",
	"ScanBuyItemBase"              : "D9EED9580CC74004",
	"ScanRequestQuoteFunction"     : "8B752083FE107614",
	"ScanTraderFunction"           : "83FF10761468D2210000",
	"ScanTraderHook"               : "50516A466A06",
	"ScanSleep"                    : "6A0057FF15D8408A006860EA0000",
	"ScanSalvageFunction"          : "33C58945FC8B45088945F08B450C8945F48B45108945F88D45EC506A10C745EC76",
	"ScanSalvageGlobal"            : "8B4A04538945F48B4208",
	"ScanIncreaseAttributeFunction": "8B7D088B702C8B1F3B9E00050000",
	"ScanDecreaseAttributeFunction": "8B8AA800000089480C5DC3CC",
	"ScanSkillTimer"               : "FFD68B4DF08BD88B4708",
	"ScanClickToMoveFix"           : "3DD301000074",
	"ScanZoomStill"                : "558BEC8B41085685C0",
	"ScanZoomMoving"               : "EB358B4304",
	"ScanChangeStatusFunction"     : "558BEC568B750883FE047C14",
	"ScanCharSlots"                : "8B551041897E38897E3C897E34897E48897E4C890D",
	"ScanReadChatFunction"         : "A128B6EB00",
	"ScanDialogLog"                : "8B45088945FC8D45F8506A08C745F841",
	"ScanTradeHack"                : "8BEC8B450883F846",
	"ScanClickCoords"              : "8B451C85C0741CD945F8",
	"ScanInstanceInfo"             : "6A2C50E80000000083C408C7",
	"ScanAreaInfo"                 : "6BC67C5E05",
	"ScanAttributeInfo"            : "BA3300000089088D4004",
	"ScanWorldConst"               : "8D0476C1E00405",
}

scanner_patterns ={
	"BasePointer"      : ["506A0F6A00FF35", 0x8, "ptr"],
	"Ping"             : ["568B750889165E", -0x3, "ptr"],
	"PacketSend"       : ["C747540000000081E6", -0x50, "func"],
	"PacketLocation"   : ["83C40433C08BE55DC3A1", 0xB, "ptr"],
	"Action"           : ["8B7508578BF983FE09750C6876", -0x3, "func"],
	"ActionBase"       : ["8D1C87899DF4", -0x3, "ptr"],
	"Environment"      : ["6BC67C5E05", 0x6, "ptr"],
	"SkillBase"        : ["8D04B6C1E00505", 0x8, "ptr"],
	"SkillTimer"       : ["FFD68B4DF08BD88B4708", -0x3, "ptr"],
	"UseSkill"         : ["85F6745B83FE1174", -0x125, "func"],
	"UseHeroSkill"     : ["BA02000000B954080000", -0x59, "func"],
	"PlayerStatus"     : ["83FE037740FF24B50000000033C0", -0x25, "func"],
	"AddFriend"        : ["8B751083FE037465", -0x47, "func"],
	"RemoveFriend"     : ["83F803741D83F8047418", 0x0, "func"],
	"AttributeInfo"    : ["BA3300000089088d4004", -0x3, "ptr"],
	"IncreaseAttribute": ["8B7D088B702C8B1F3B9E00050000", -0x5A, "func"],
	"DecreaseAttribute": ["8B8AA800000089480C5DC3CC", 0x19, "func"],
	"Transaction"      : ["85FF741D8B4D14EB08", -0x7E, "func"],
	"BuyItemBase"      : ["D9EED9580CC74004", 0xF, "ptr"],
	"RequestQuote"     : ["8B752083FE107614", -0x34, "func"],
	"Salvage"          : ["33C58945FC8B45088945F08B450C8945F48B45108945F88D45EC506A10C745EC76", -0xA, "func"],
	"SalvageGlobal"    : ["8B4A04538945F48B4208", 0x1, "ptr"],
	"AgentBase"        : ["8B0C9085C97419", -0x3, "ptr"],
	"ChangeTarget"     : ["3BDF0F95", -0x86, "func"],
	"CurrentTarget"    : ["83C4085F8BE55DC3CCCCCCCCCCCCCCCCCCCCCC55", -0xE, "ptr"],
	"MyID"             : ["83EC08568BF13B15", -0x3, "ptr"],
	"Move"             : ["558BEC83EC208D45F0", 0x1, "func"],
	"ClickCoords"      : ["8B451C85C0741CD945F8", 0xD, "ptr"],
	"InstanceInfo"     : ["6A2C50E80000000083C408C7", 0xE, "ptr"],
	"WorldConst"       : ["8D0476C1E00405", 0x8, "ptr"],
	"Region"           : ["6A548D46248908", -0x3, "ptr"],
	"SendUIMessage"    : ["B900000000E8000000005DC3894508", 0x0, "func"],
	"EnterMission"     : ["A900001000743A", 0x52, "func"],
	"SetDifficulty"    : ["8B75086828010010", 0x71, "func"],
	"Engine"           : ["568B3085F67478EB038D4900D9460C", -0x22, "hook"],
	"Render"           : ["F6C401741C68B1010000BA", -0x67, "hook"],
	"TraderHook"       : ["50516A476A06", -0x2F, "hook"],
}