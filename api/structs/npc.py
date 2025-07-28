#stdlib
from ctypes import Structure, c_uint32, c_uint8, c_wchar_p, c_void_p


class NPC(Structure):
	_fields_ = [
		("model_file_id", c_uint32),
		("h0004", c_uint32),
		("scale", c_uint32),
		("sex", c_uint32),
		("npc_flags", c_uint32),
		("primary", c_uint32),
		("h0018", c_uint32),
		("default_level", c_uint8),
		("name_enc", c_wchar_p),
		("model_files", c_void_p),
		("files_count", c_uint32),
		("files_capacity", c_uint32),
	]

	def is_henchman(self) -> bool:
		return (self.npc_flags & 0x10) != 0
	
	def is_hero(self) -> bool:
		return (self.npc_flags & 0x20) != 0
	
	def is_spirit(self) -> bool:
		return (self.npc_flags & 0x4000) != 0
	
	def is_minion(self) -> bool:
		return (self.npc_flags & 0x100) != 0
	
	def is_pet(self) -> bool:
		return (self.npc_flags & 0xD) != 0
