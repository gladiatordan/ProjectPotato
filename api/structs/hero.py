#stdlib
from ctypes import Structure, c_uint32, c_uint8, c_wchar

#mylib
from . import GWArray, Vec2f


class HeroFlag(Structure):
	_fields_ = [
		("hero_id", c_uint32),
		("agent_id", c_uint32),
		("level", c_uint32),
		("hero_behavior", c_uint32),
		("flag", Vec2f),
		("h0018", c_uint32),
		("locked_target_id", c_uint32),
		("h0028", c_uint32),
	]


class HeroInfo(Structure):
	_fields_ = [
		("hero_id", c_uint32),
		("agent_id", c_uint32),
		("level", c_uint32),
		("primary", c_uint32),
		("secondary", c_uint32),
		("hero_file_id", c_uint32),
		("model_file_id", c_uint32),
		("h001C", c_uint32 * 52),
		("name", c_wchar * 20),
	]
