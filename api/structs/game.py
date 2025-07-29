#stdlib
from ctypes import Structure, c_uint32


class GameContext(Structure):
	_fields_ = [
		("h0000", c_uint32),
		("h0004", c_uint32),
		("agent", c_uint32), 			# AgentContext
		("h000C", c_uint32),
		("h0010", c_uint32),
		("map", c_uint32),				# MapContext
		("text_parser", c_uint32),		# not sure we give a shit about this
		("h001C", c_uint32),
		("some_number", c_uint32),
		("h0024", c_uint32),
		("account", c_uint32),			# AccountContext
		("world", c_uint32),			# WorldContext
		("cinematic", c_uint32),		# There's a struct to read here but idk if we care
		("h0034", c_uint32),
		("gadget", c_uint32),			# GadgetContext
		("guild", c_uint32),			# GuildContext
		("items", c_uint32),			# ItemContext
		("character", c_uint32),		# CharContext
		("h0048", c_uint32),
		("party", c_uint32),			# PartyContext
		("h0050", c_uint32),
		("h0054", c_uint32),
		("trade", c_uint32),			# TradeContext
	]

	def __repr__(self):
		return f"{self.__class__.__name__}:\n" + ", ".join(f"{name}={hex(getattr(self, name))}\n" for name, _ in self._fields_)
