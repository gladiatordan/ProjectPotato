from enum import IntEnum, auto



class Allegiance(IntEnum):
	ALLY_NOATTACK = 0x1
	NEUTRAL       = 0x2
	ENEMY         = 0x3
	SPIRIT_PET    = 0x4
	MINION        = 0x5
	NPC_MINIPET   = 0x6


class AgentType(IntEnum):
	LIVING = 0xDB
	GADGET = 0x200
	ITEM   = 0x400



class AgentModelIDs(IntEnum):
	# Value comes from Agent.player_number

	# Ranger Spirits
	SPIRIT_EOE = 2876
	SPIRIT_QZ = 2886
	SPIRIT_WINNOWING = 2875
	SPIRIT_INFURIATINGHEAT = 5715
	SPIRIT_EQUINOX = 4236
	SPIRIT_FAMINE = 4238
	SPIRIT_FROZENSOIL = 2882
	SPIRIT_QUICKSAND = 5718
	SPIRIT_LACERATE = 4232


