#stdlib
from ctypes import Structure, c_uint32, c_wchar_p

#mylib
from . import GWArray


class GadgetInfo(Structure):
	_fields_ = [
		("h0000", c_uint32),
		("h0004", c_uint32),
		("h0008", c_uint32),
		("name_enc", c_wchar_p),
	]


class GadgetContext(Structure):
	_fields_ = [
		("gadget_info", GadgetInfo),
	]