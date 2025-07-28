#stdlib
from ctypes import Structure, c_void_p


class GameContext(Structure):
	_fields_ = [
		("h0000", c_void_p),
		("h0004", c_void_p),
		("agent", c_void_p), 			# AgentContext
		("h000C", c_void_p),
		("h0010", c_void_p),
		("map", c_void_p),				# MapContext
		("text_parser", c_void_p),		# not sure we give a shit about this
		("h001C", c_void_p),
		("some_number", c_void_p),
		("h0024", c_void_p),
		("account", c_void_p),			# AccountContext
		("world", c_void_p),			# WorldContext
		("cinematic", c_void_p),		# There's a struct to read here but idk if we care
		("h0034", c_void_p),
		("gadget", c_void_p),			# GadgetContext
		("guild", c_void_p),			# GuildContext
		("items", c_void_p),			# ItemContext
		("h0048", c_void_p),
		("party", c_void_p),			# PartyContext
		("h0050", c_void_p),
		("h0054", c_void_p),
		("trade", c_void_p),			# TradeContext
	]

