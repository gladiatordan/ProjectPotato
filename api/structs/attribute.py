#stdlib
from ctypes import Structure, c_uint32


class Attribute(Structure):
	_fields_ = [
		("id", c_uint32),
		("level_base", c_uint32),
		("level", c_uint32),
		("decrement_points", c_uint32),
		("increment_points", c_uint32),
	]


class AttributeInfo(Structure):
	_fields_ = [
		("profession_id", c_uint32),
		("attribute_id", c_uint32),
		("name_id", c_uint32),
		("desc_id", c_uint32),
		("is_pve", c_uint32),
	]


class PartyAttribute(Structure):
	_fields_ = [
		("agent_id", c_uint32),
		("attribute", Attribute * 54),
	]