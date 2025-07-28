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
scanner_assertions = {
	"PreGameContext": 	["UiPregame.cpp", "!s_scene", 0,0x34],
	"GameplayContext": 	["\\Code\\Gw\\Ui\\Game\\GmContext.cpp", "!s_context", 0, -0x9],
	"ItemFormulas":		["\\Code\\Gw\\Const\\ConstItem.cpp", "formula < ITEM_FORMULAS",0,0],
	"AgentArray":		["AvSelect.cpp", "!(autoAgentId && !ManagerFindAgent(autoAgentId))",0,0]
}

scanner_patterns ={
	"BasePointer"      : ["506A0F6A00FF35", 0x8],
	"CurrentTarget"    : ["83C4085F8BE55DC3CCCCCCCCCCCCCCCCCCCCCC55", -0xE],
	"MyID"             : ["83EC08568BF13B15", -0x3],
	"Engine"           : ["568B3085F67478EB038D4900D9460C", -0x22],
	"Render"           : ["F6C401741C68B1010000BA", -0x67],
	"ChangeTarget"     : ["3BDF0F95", -0x86],
	"Move"             : ["558BEC83EC208D45F0", 0x1],


	"PacketSend"       : ["C747540000000081E6", -0x50],
	"PacketLocation"   : ["83C40433C08BE55DC3A1", 0xB],
	"Action"           : ["8B7508578BF983FE09750C6876", -0x3],
	"ActionBase"       : ["8D1C87899DF4", -0x3],
	"Environment"      : ["6BC67C5E05", 0x6],
	"SkillBase"        : ["8D04B6C1E00505", 0x8],
	"SkillTimer"       : ["FFD68B4DF08BD88B4708", -0x3],
	"UseSkill"         : ["85F6745B83FE1174", -0x125],
	"UseHeroSkill"     : ["BA02000000B954080000", -0x59],
	"PlayerStatus"     : ["83FE037740FF24B50000000033C0", -0x25],
	"AddFriend"        : ["8B751083FE037465", -0x47],
	"RemoveFriend"     : ["83F803741D83F8047418", 0x0],
	"AttributeInfo"    : ["BA3300000089088d4004", -0x3],
	"IncreaseAttribute": ["8B7D088B702C8B1F3B9E00050000", -0x5A],
	"DecreaseAttribute": ["8B8AA800000089480C5DC3CC", 0x19],
	"Transaction"      : ["85FF741D8B4D14EB08", -0x7E],
	"BuyItemBase"      : ["D9EED9580CC74004", 0xF],
	"RequestQuote"     : ["8B752083FE107614", -0x34],
	"Salvage"          : ["33C58945FC8B45088945F08B450C8945F48B45108945F88D45EC506A10C745EC76", -0xA],
	"SalvageGlobal"    : ["8B4A04538945F48B4208", 0x1],
	
	
	
	"ClickCoords"      : ["8B451C85C0741CD945F8", 0xD],
	"InstanceInfo"     : ["6A2C50E80000000083C408C7", 0xE],
	"SendUIMessage"    : ["B900000000E8000000005DC3894508", 0x0],
	"EnterMission"     : ["A900001000743A", 0x52],
	"SetDifficulty"    : ["8B75086828010010", 0x71],
	
	
	"TraderHook"       : ["50516A476A06", -0x2F],
}