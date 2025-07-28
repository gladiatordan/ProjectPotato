#stdlib
from ctypes import Structure, c_uint32, c_wchar

#mylib
from . import GWArray



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