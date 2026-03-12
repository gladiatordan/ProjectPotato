#stdlib
from ctypes import Structure, c_uint32, c_float, c_wchar

#mylib
from . import GWPointer, GWArray
from .agent import AgentContext
from .world import MapContext, WorldContext
from .account import AccountContext
from .guild import GuildContext
from .item import ItemContext
from .player import CharContext
from .party import PartyContext
from .trade import TradeContext


class GameContext(Structure):
	_fields_ = [
		("h0000", c_uint32),
		("h0004", c_uint32),
		("agent", GWPointer(AgentContext)), 			# AgentContext
		("h000C", c_uint32),
		("h0010", c_uint32),
		("map", GWPointer(MapContext)),				# MapContext
		("text_parser", c_uint32),		# not sure we give a shit about this
		("h001C", c_uint32),
		("some_number", c_uint32),
		("h0024", c_uint32),
		("account", GWPointer(AccountContext)),			# AccountContext
		("world", GWPointer(WorldContext)),			# WorldContext
		("cinematic", c_uint32),		# There's a struct to read here but idk if we care
		("h0034", c_uint32),
		("gadget", c_uint32),			# GadgetContext
		("guild", GWPointer(GuildContext)),			# GuildContext
		("items", GWPointer(ItemContext)),			# ItemContext
		("character", GWPointer(CharContext)),		# CharContext
		("h0048", c_uint32),
		("party", GWPointer(PartyContext)),			# PartyContext
		("h0050", c_uint32),
		("h0054", c_uint32),
		("trade", GWPointer(TradeContext)),			# TradeContext
	]

	def __repr__(self):
		return f"{self.__class__.__name__}:\n" + ", ".join(f"{name}={getattr(self, name)}\n" for name, _ in self._fields_)


class GameplayContext(Structure):
	_fields_ = [
		("h0000", c_uint32 * 19),
		("misison_map_zoom", c_float),
		("unk", c_uint32 * 10)
	]


class LoginCharacter(Structure):
	_fields_ = [
		("unk0", c_uint32),
		("character_name", c_wchar * 20)
	]


class PreGameContext(Structure):
	_fields_ = [
		("frame_id", c_uint32),
		("h0004", c_uint32 * 72),
		("chosen_character_index", c_uint32),
		("h0128", c_uint32 * 6),
		("index_1", c_uint32),
		("index_2", c_uint32),
		("chars", GWArray),
	]
