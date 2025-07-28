#stdlib
from ctypes import Structure, c_uint32, c_float


class GameplayContext(Structure):
	_fields_ = [
		("h0000", c_uint32 * 19),
		("misison_map_zoom", c_float),
		("unk", c_uint32 * 10)
	]