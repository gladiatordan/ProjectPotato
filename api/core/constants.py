"""

Constants library



"""
# Misc
TARGET_EXE = "gw.exe"


# Addresses
ADDRESS_BASE_SCAN_CMP_OFFSET = 0x4FF000
ADDRESS_SCAN_PTR_OFFSET      = 0x9DF000
ADDRESS_BASE_MODIFY_MEMORY	 = 0x00C50000


# Offsets
scan_offsets = {
	"ScanBasePointer":                0x8,
	"ScanAgentArray":                 -0x3,
	"ScanCurrentTarget":              -0xE,
	"ScanMyID":                       -3,
	"ScanEngine":                     -0x22,
	"ScanRenderFunc":                 -0x67,
	"ScanLoadFinished":               0x1,
	"ScanPostMessage":                0xB,
	"ScanTargetLog":                  0x1,
	"ScanChangeTargetFunction":       -0x0086,
	"ScanMoveFunction":               0x1,
	"ScanPing":                       -0x14,
	"ScanLoggedIn":                   0x3,
	"ScanRegion":                     -0x3,
	"ScanUseSkillFunction":           -0x125,
	"ScanPacketSendFunction":         -0x50,
	"ScanBaseOffset":                 0xB,
	"ScanWriteChatFunction":          -0x3D,
	"ScanSkillLog":                   0x1,
	"ScanSkillCompleteLog":           -0x4,
	"ScanSkillCancelLog":             0x5,
	"ScanChatLog":                    0x12,
	"ScanSellItemFunction":           -0x55,
	"ScanStringLog":                  0x16,
	"ScanStringFilter1":              -0x5,
	"ScanStringFilter2":              0x16,
	"ScanActionFunction":             -0x3,
	"ScanActionBase":                 -0x3,
	"ScanSkillBase":                  0x8,
	"ScanUseHeroSkillFunction":       -0x59,
	"ScanTransactionFunction":        -0x7E,
	"ScanBuyItemBase":                0xF,
	"ScanRequestQuoteFunction":       -0x34,
	"ScanTraderFunction":             -0x1E,
	"ScanTraderHook":                 -0x2F,
	"ScanSalvageFunction":            -0xA,
	"ScanSalvageGlobal":              1,
	"ScanIncreaseAttributeFunction":  -0x5A,
	"ScanDecreaseAttributeFunction":  0x19,
	"ScanSkillTimer":                 -0x3,
	"ScanClickToMoveFix":             0x1,
	"ScanZoomStill":                  0x33,
	"ScanZoomMoving":                 0x21,
	"ScanChangeStatusFunction":       0x1,
	"ScanCharslots":                  0x16,
	"ScanDialogLog":                  -0x4,
	"ScanTradeHack":                  0,
	"ScanInstanceInfo":               0xE,
	"ScanAreaInfo":                   0x6,
	"ScanAttributeInfo":              -0x3,
	"ScanWorldConst":                 0x8,
}

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
	"ScanAgentArray"               : "8B0C9085C97419",
	"ScanCurrentTarget"            : "83C4085F8BE55DC3CCCCCCCCCCCCCCCCCCCCCC55",
	"ScanMyId"                     : "83EC08568BF13B15",
	"ScanEngine"                   : "568B3085F67478EB038D4900D9460C",
	"ScanRenderFunc"               : "F6C401741C68B1010000BA",
	"ScanLoadFinished"             : "8B561C8BCF52E8",
	"ScanPostMessage"              : "6A00680080000051FF15",
	"ScanTargetLog"                : "5356578BFA894DF4E8",
	"ScanChangeTargetFunction"     : "3BDF0F95",
	"ScanMoveFunction"             : "558BEC83EC208D45F0",
	"ScanPing"                     : "E874651600",
	"ScanMapId"                    : "558BEC8B450885C074078B",
	"ScanMapLoading"               : "2480ED0000000000",
	"ScanLoggedIn"                 : "C705ACDE740000000000C3CCCCCCCC",
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