#stdlib
from ctypes import *


class GWArray(Structure):
	_fields_ = [
		("m_buffer", c_void_p),
		("m_capacity", c_uint32),
		("m_size", c_uint32),
		("m_param", c_uint32),
	]


class TLink(Structure):
	_fields_ = [
		("prev_link", c_void_p),
		("next_node", c_void_p),
	]


class TList(Structure):
	_fields_ = [
		("offset", c_uint32),
		("link", TLink),
	]


class Vec2f(Structure):
	_fields_ = [
		("x", c_float),
		("y", c_float),
	]


class Vec3f(Structure):
	_fields_ = [
		("x", c_float),
		("y", c_float),
		("z", c_float),
	]


class Sub1(Structure):
	_fields_ = [
		("sub2", c_void_p),
		("pathing_map_block", GWArray),
		("total_trapezoid_count", c_uint32),
		("h0014", c_uint32 * 18),
		("something_else_for_props", GWArray)
	]


class Sub2(Structure):
	_fields_ = [
		("pad1", c_uint32 * 6),
		("pmaps", GWArray),
	]


#mylib
from .account import *
from .agent import *
from .attribute import *
from .char import *
from .gadget import *
from .game_entities import *
from .game import *
from .gameplay import *
from .guild import *
from .hero import *
from .item import *
from .map import *
from .npc import *
from .party import *
from .player import *
from .pregame import *
from .quest import *
from .skill import *
from .title import *
from .trade import *
from .world import *