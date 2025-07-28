#stdlib
from ctypes import Structure, c_uint32, c_uint8, c_void_p, c_int, c_float, c_wchar

#mylib
from . import GWArray


class ProgressBar(Structure):
	_fields_ = [
		("pips", c_int),
		("color", c_uint8 * 4),
		("background", c_uint8 * 4),
		("unk", c_int * 7),
		("progress", c_float),
	]


class CharContext(Structure):
	_fields_ = [
		("h0000", GWArray),
		("h0010", c_uint32),
		("h0014", GWArray),
		("h0024", c_uint32 * 4),
		("h0034", GWArray),
		("h0044", GWArray),
		("h0054", c_uint32 * 4),
		("player_uuid", c_uint32 * 4),
		("player_name", c_wchar * 20),
		("h009C", c_uint32 * 20),
		("h00EC", GWArray),
		("h00FC", c_uint32 * 37),
		("world_flags", c_uint32),
		("token1", c_uint32),
		("map_id", c_uint32),
		("is_explorable", c_uint32),
		("host", c_uint32 * 24),
		("token2", c_uint32),
		("h01BC", c_uint32 * 25),
		("district_number", c_uint32),
		("language", c_uint8),
		("observe_map_id", c_uint32),
		("current_map_id", c_uint32),
		("observe_map_type", c_uint32),
		("current_map_type", c_uint32),
		("observer_matches", GWArray),
		("h0248", c_uint32 * 22),
		("player_flags", c_uint32),
		("player_number", c_uint32),
		("h02A8", c_uint32 * 40),
		("progress_bar", c_void_p),
		("h034C", c_uint32 * 27),
		("player_email", c_wchar * 64),
	]