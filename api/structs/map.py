#stdlib
from ctypes import Structure, c_float, c_uint32, c_void_p, c_uint8

#mylib
from . import GWArray


class MapContext(Structure):
	_fields_ = [
		("map_boundaries", c_float * 5),
		("h0014", c_uint32),
		("spawns1", GWArray),
		("spawns2", GWArray),
		("spawns3", GWArray),
		("h005C", c_float * 6),
		("sub1", c_void_p),
		("pad1", c_uint8 * 4),
		("props", c_void_p),
		("h0080", c_uint32),
		("terrain", c_void_p),
		("h0088", c_uint32 * 42),
		("zones", c_void_p),
	]


class PropsContext(Structure):
	_fields_ = [
		("pad1", c_uint32 * 27),
		("props_by_type", GWArray),
		("h007C", c_uint32 * 10),
		("prop_models", GWArray),
		("h00B4", c_uint32 * 56),
		("prop_array", GWArray),
	]


class MissionMapIcon(Structure):
	_fields_ = [
		("index", c_uint32),
		("X", c_float),
		("Y", c_float),
		("h000C", c_uint32),
		("h0010", c_uint32),
		("option", c_uint32),
		("h0018", c_uint32),
		("model_id", c_uint32),
		("h0020", c_uint32),
		("h0024", c_uint32),
	]


class AreaInfo(Structure):
	_fields_ = [
		("campaign", c_uint32),
		("continent", c_uint32),
		("region", c_uint32),
		("type", c_uint32),
		("flags", c_uint32),
		("thumbnail_id", c_uint32),
		("min_party_size", c_uint32),
		("max_party_size", c_uint32),
		("min_player_size", c_uint32),
		("max_player_size", c_uint32),
		("controlled_outpost_id", c_uint32),
		("fraction_mission", c_uint32),
		("min_level", c_uint32),
		("max_level", c_uint32),
		("needed_pq", c_uint32),
		("mission_maps_to", c_uint32),
		("x", c_uint32),
		("y", c_uint32),
		("icon_start_x", c_uint32),
		("icon_start_y", c_uint32),
		("icon_end_x", c_uint32),
		("icon_end_y", c_uint32),
		("icon_start_x_dupe", c_uint32),
		("icon_start_y_dupe", c_uint32),
		("icon_end_x_dupe", c_uint32),
		("icon_end_y_dupe", c_uint32),
		("file_id", c_uint32),
		("mission_chronology", c_uint32),
		("ha_map_chronology", c_uint32),
		("name_id", c_uint32),
		("description_id", c_uint32),
	]

	def has_enter_button(self) -> bool:
		return (self.flags & 0x100) != 0
	
	def is_on_world_map(self) -> bool:
		return (self.flags & 0x20) == 0
	
	def is_pvp(self) -> bool:
		return (self.flags & 0x40001) != 0
	
	def is_guild_hall(self) -> bool:
		return (self.flags & 0x800000) != 0
	
	def is_vanquishable_area(self) -> bool:
		return (self.flags & 0x100000000) != 0
	
	def is_unlockable(self) -> bool:
		return (self.flags & 0x10000) != 0
	
	def has_mission_maps_to(self) -> bool:
		return (self.flags & 0x8000000) != 0
