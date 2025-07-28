#stdlib
from ctypes import Structure, c_uint32, c_uint16, c_float, c_void_p

#mylib
from . import Vec2f, Vec3f


class GamePos(Structure):
	_fields_ = [
		("x", c_float),
		("y", c_float),
		("plane", c_uint32),
	]


class PathingTrapezoid(Structure):
	_fields_ = [
		("id", c_uint32),
		("adjacent", c_void_p * 4),
		("portal_left", c_uint16),
		("portal_right", c_uint16),
		("XTL", c_float),
		("XTR", c_float),
		("YT", c_float),
		("XBL", c_float),
		("XBR", c_float),
		("YB", c_float),
	]


class Node(Structure):
	_fields_ = [
		("type", c_uint32),
		("id", c_uint32),
	]


class XNode(Node):
	_fields_ = Node._fields_ + [
		("pos", Vec2f),
		("dir", Vec2f),
		("left", c_void_p),
		("right", c_void_p),
	]


class YNode(Node):
	_fields = Node._fields_ + [
		("pos", Vec2f),
		("left", c_void_p),
		("right", c_void_p),
	]


class SinkNode(Node):
	_fields_ = Node._fields_ + [
		("trapezoid", c_void_p),
	]


class Portal(Structure):
	_fields_ = [
		("left_layer_id", c_uint16),
		("right_layer_id", c_uint16),
		("h0004", c_uint32),
		("pair", c_void_p),
		("count", c_uint32),
		("trapezoids", c_void_p),
	]


class PathingMap(Structure):
	_fields_ = [
		("z_plane", c_uint32),
		("h0004", c_uint32),
		("h0008", c_uint32),
		("h000C", c_uint32),
		("h0010", c_uint32),
		("trapezoid_count", c_uint32),
		("trapezoids", c_void_p),
		("sink_node_count", c_uint32),
		("sink_nodes", c_void_p),
		("x_node_count", c_uint32),
		("x_nodes", c_void_p),
		("y_node_count", c_uint32),
		("y_nodes", c_void_p),
		("h0034", c_uint32),
		("h0038", c_uint32),
		("portal_count", c_uint32),
		("portals", c_void_p),
		("root_node", c_void_p),
		("h0048", c_void_p),
		("h004C", c_void_p),
		("h0050", c_void_p),
	]


class PropByType(Structure):
	_fields_ = [
		("object_id", c_uint32),
		("prop_index", c_uint32)
	]


class PropModelInfo(Structure):
	_fields_ = [
		("h0000", c_uint32),
		("h0004", c_uint32),
		("h0008", c_uint32),
		("h000C", c_uint32),
		("h0010", c_uint32),
		("h0014", c_uint32),
	]


class RecObject(Structure):
	_fields_ = [
		("h0000", c_uint32),
		("h0004", c_uint32),
		("access_key", c_uint32),

	]


class MapProp(Structure):
	_fields_ = [
		("h0000", c_uint32 * 5),
		("uptime_seconds", c_uint32),
		("h0018", c_uint32),
		("prop_index", c_uint32),
		("position", Vec3f),
		("model_file_id", c_uint32),
		("h0030", c_uint32 * 2),
		("rotation_angle", c_float),
		("rotation_cos", c_float),
		("rotation_sin", c_float),
		("h0034", c_uint32 * 5),
		("interactive_model", c_void_p),
		("h005C", c_uint32 * 4),
		("appearance_bitmap", c_uint32),
		("animation_bits", c_uint32),
		("h0064", c_uint32 * 5),
		("prop_object_info", c_void_p),
		("h008C", c_uint32),
	]