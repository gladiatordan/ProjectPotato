#stdlib
from ctypes import Structure, c_uint32, c_wchar_p

#mylib
from . import GWArray


class Player(Structure):
	_fields_ = [
		("agent_id", c_uint32),
		("h0004", c_uint32 * 3),
		("appearance_bitmap", c_uint32),
		("flags", c_uint32),
		("primary", c_uint32),
		("secondary", c_uint32),
		("h0020", c_uint32),
		("name_enc", c_wchar_p),
		("name", c_wchar_p),
		("party_leader_player_number", c_uint32),
		("active_title_tier", c_uint32),
		("player_number", c_uint32),
		("party_size", c_uint32),
		("h003C", GWArray),
	]

	def is_pvp(self) -> bool:
		return (self.flags & 0x800) != 0