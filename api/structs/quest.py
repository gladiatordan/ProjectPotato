#stdlib
from ctypes import Structure, c_uint32, c_wchar_p

#mylib
from .game_entities import GamePos


class Quest(Structure):
	_fields_ = [
		("quest_id", c_uint32),
		("log_state", c_uint32),
		("location", c_wchar_p),
		("name", c_wchar_p),
		("npc", c_wchar_p),
		("map_from", c_uint32),
		("marker", GamePos),
		("h0024", c_uint32),
		("map_to", c_uint32),
		("description", c_wchar_p),
		("objectives", c_wchar_p),
	]

	def is_completed(self) -> bool:
		return (self.log_state & 0x2) != 0
	
	def is_current_mission_quest(self) -> bool:
		return (self.log_state & 0x10) != 0
	
	def is_area_primary(self) -> bool:
		return (self.log_state & 0x40) != 0
	
	def is_primary(self) -> bool:
		return (self.log_state & 0x20) != 0


class MissionObjective(Structure):
	_fields_ = [
		("objective_id", c_uint32),
		("enc_str", c_wchar_p),
		("type", c_uint32),
	]