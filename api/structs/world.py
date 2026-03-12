#stdlib
from ctypes import *

#mylib
from . import GWArray, Vec3f


class WorldContext(Structure):
	_fields_ = [
		("account_info", c_uint32),
		("message_buff", GWArray),
		("dialog_buff", GWArray),
		("merch_items", GWArray),					# Item Array of currently-interacted merchant
		("merch_items2", GWArray),					# no fucking clue
		("accum_map_init_unk0", c_uint32),
		("accum_map_init_unk1", c_uint32),
		("accum_map_init_offset", c_uint32),
		("accum_map_init_length", c_uint32),
		("h0054", c_uint32),
		("accum_map_init_unk2", c_uint32),
		("h005C", c_uint32 * 8),
		("map_agents", GWArray),
		("party_allies", GWArray),
		("all_flag", Vec3f),
		("h00A8", c_uint32),
		("attributes", GWArray),
		("h00BC", c_uint32 * 255),
		("h04B8", GWArray),
		("h04C8", GWArray),
		("h04D8", c_uint32),
		("h04DC", GWArray),
		("h04EC", c_uint32 * 7),
		("party_effects", GWArray),
		("h0518", GWArray),
		("active_quest_id", c_uint32),
		("quest_log", GWArray),
		("h053C", c_uint32 * 10),
		("mission_objectives", GWArray),
		("henchmen_agent_ids", GWArray),
		("hero_flags", GWArray),
		("hero_info", GWArray),
		("cartographed_areas", GWArray),
		("h05B4", c_uint32 * 2),
		("controlled_minion_count", GWArray),
		("missions_completed", GWArray),
		("missions_bonus", GWArray),
		("missions_completed_hm", GWArray),
		("missions_bonus_hm", GWArray),
		("unlocked_map", GWArray),
		("h061C", c_uint32 * 2),
		("player_morale_info", c_void_p),
		("h028C", c_uint32),
		("party_morale_related", GWArray),
		("h063C", c_uint32 * 16),
		("player_number", c_uint32),
		("player_controlled_character", c_void_p),
		("is_hard_mode_unlocked", c_uint32),
		("h0688", c_uint32 * 2),
		("salvage_session_id", c_uint32),
		("h0694", c_uint32 * 5),
		("player_team_token", c_uint32),
		("pets", GWArray),
		("party_profession_states", GWArray),
		("h06CC", GWArray),
		("h06DC", c_uint32),
		("h06E0", GWArray),
		("skillbar", GWArray),
		("learnable_character_skills", GWArray),
		("unlocked_character_skills", GWArray),
		("duplicated_character_skills", GWArray),
		("h0730", GWArray),
		("experience", c_uint32),
		("experience_dupe", c_uint32),
		("current_kurzick", c_uint32),
		("current_kurzick_dupe", c_uint32),
		("total_earned_kurzick", c_uint32),
		("total_earned_kurzick_dupe", c_uint32),
		("current_luxon", c_uint32),
		("current_luxon_dupe", c_uint32),
		("total_earned_luxon", c_uint32),
		("total_earned_luxon_dupe", c_uint32),
		("current_imperial", c_uint32),
		("current_imperial_dupe", c_uint32),
		("total_earned_imperial", c_uint32),
		("total_earned_imperial_dupe", c_uint32),
		("unk_faction4", c_uint32),
		("unk_faction4_dupe", c_uint32),
		("unk_faction5", c_uint32),
		("unk_faction5_dupe", c_uint32),
		("level", c_uint32),
		("level_dupe", c_uint32),
		("morale", c_uint32),
		("morale_dupe", c_uint32),
		("current_balth", c_uint32),
		("current_balth_dupe", c_uint32),
		("total_earned_balth", c_uint32),
		("total_earned_balth_dupe", c_uint32),
		("current_skill_points", c_uint32),
		("current_skill_points_dupe", c_uint32),
		("total_earned_skill_points", c_uint32),
		("total_earned_skill_points_dupe", c_uint32),
		("max_kurzick", c_uint32),
		("max_luxon", c_uint32),
		("max_balth", c_uint32),
		("max_imperial", c_uint32),
		("equipment_status", c_uint32),
		("agent_infos", GWArray),
		("h07DC", GWArray),
		("mission_map_icons", GWArray),
		("npcs", GWArray),
		("players", GWArray),
		("titles", GWArray),
		("title_tiers", GWArray),
		("vanquished_areas", GWArray),
		("foes_killed", c_uint32),
		("foes_to_kill", c_uint32),
	]

	def __repr__(self):
		return f"{self.__class__.__name__}:\n" + ", ".join(f"{name}={getattr(self, name)}\n" for name, _ in self._fields_)


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
