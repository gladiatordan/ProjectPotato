#stdlib
from ctypes import *

#mylib
from . import GWArray, TList, TLink, Vec2f, Vec3f
from .game_entities import GamePos


class AgentContext(Structure):
	_fields_ = [
		("h0000", GWArray),
		("h0010", c_uint32 * 5),
		("h0024", c_uint32),
		("h0028", c_uint32 * 2),
		("h0030", c_uint32),
		("h0034", c_uint32 * 2),
		("h003C", c_uint32),
		("h0040", c_uint32 * 2),
		("h0048", c_uint32),
		("h004C", c_uint32 * 2),
		("h0054", c_uint32),
		("h0058", c_uint32 * 11),
		("h0084", GWArray),
		("h0094", c_uint32),
		("agent_summary_info", GWArray),
		("h00A8", GWArray),
		("h00B8", GWArray),
		("rand1", c_uint32),
		("rand2", c_uint32),
		("h00D0", c_uint32 * 24),
		("agent_movement", GWArray),
		("h00F8", GWArray),
		("h0108", c_uint32 * 17),
		("agent_array1", GWArray),
		("agent_async_movement", GWArray),
		("h016C", c_uint32 * 15),
		("instance_timer", c_uint32),
	]


class Agent(Structure):
	_fields_ = [
		("vtable", c_void_p),
		("h0004", c_uint32),
		("h0008", c_uint32),
		("h000C", c_uint32 * 2),
		("timer", c_uint32),
		("timer2", c_uint32),
		("link", TLink),
		("link2", TLink),
		("agent_id", c_uint32),
		("z", c_float),
		("width1", c_float),
		("height1", c_float),
		("width2", c_float),
		("height2", c_float),
		("width3", c_float),
		("height3", c_float),
		("rotation_angle", c_float),
		("rotation_cos", c_float),
		("rotation_sin", c_float),
		("name_properties", c_uint32),
		("ground", c_uint32),
		("h0060", c_uint32),
		("terrain_normal", Vec3f),
		("h0070", c_uint8 * 4),
		("pos", GamePos),
		("h0080", c_uint32 * 4),
		("name_tag_x", c_float),
		("name_tag_y", c_float),
		("name_tag_z", c_float),
		("visual_effects", c_uint16),
		("h0092", c_uint16),
		("h0094", c_uint32 * 2),
		("type", c_uint32),
		("move_x", c_float),
		("move_y", c_float),
		("velocity", Vec2f),
		("h00A8", c_uint32),
		("rotation_cos2", c_float),
		("rotation_sin2", c_float),
		("h00B4", c_uint32 * 4),
	]

	def get_is_item_type(self):
		return self.type & 0x400 != 0

	def get_is_gadget_type(self):
		return self.type & 0x200 != 0

	def get_is_living_type(self):
		return self.type & 0xDB != 0


class AgentInfo(Structure):
	_fields_ = [
		("h0000", c_uint32 * 13),
		("name_enc", c_wchar_p),
	]


class AgentItem(Structure):
	_fields_ = [
		("owner", c_uint32),
		("item_id", c_uint32),
		("h00CC", c_uint32),
		("extra_type", c_uint32),
	]


class AgentGadget(Structure):
	_fields_ = [
		("h00C4", c_uint32),
		("h00C8", c_uint32),
		("extra_type", c_uint32),
		("gadget_id", c_uint32),
		("h00D4", c_uint32 * 4),
	]


class AgentLiving(Structure):
	_fields_ = [
		("owner", c_uint32),
		("h00C8", c_uint32),
		("h00CC", c_uint32),
		("h00D0", c_uint32),
		("h00D4", c_uint32 * 3),
		("animation_type", c_float),
		("h00E4", c_uint32 * 2),
		("weapon_attack_speed", c_float),
		("attack_speed_modifier", c_float),
		("player_number", c_uint16),
		("agent_model_type", c_uint16),
		("transmog_npc_id", c_uint32),
		("equip", c_void_p),
		("h0100", c_uint32),
		("tags", c_void_p),
		("h0108", c_uint16),
		("primary", c_uint8),
		("secondary", c_uint8),
		("level", c_uint8),
		("team_id", c_uint8),
		("h010E", c_uint8 * 2),
		("h0110", c_uint32),
		("energy_regen", c_float),
		("h0118", c_uint32),
		("energy", c_float),
		("max_energy", c_uint32),
		("h0124", c_uint32),
		("hp_pips", c_float),
		("h012C", c_uint32),
		("hp", c_float),
		("max_hp", c_uint32),
		("effects", c_uint32),
		("h013C", c_uint32),
		("hex", c_uint8),
		("h0141", c_uint8 * 19),
		("model_state", c_uint32),
		("type_map", c_uint32),
		("h015C", c_uint32 * 4),
		("in_spirit_range", c_uint32),
		("visible_effects", TList),
		("h017C", c_uint32),
		("login_number", c_uint32),
		("animation_speed", c_float),
		("animation_code", c_uint32),
		("animation_id", c_uint32),
		("h0190", c_uint8 * 32),
		("dagger_status", c_uint8),
		("allegiance", c_uint8),
		("weapon_type", c_uint16),
		("skill", c_uint16),
		("h01B6", c_uint16),
		("weapon_item_type", c_uint8),
		("offhand_item_type", c_uint8),
		("weapon_item_id", c_uint16),
		("offhand_item_id", c_uint16),
	]

	def is_bleeding(self) -> bool:
		return self.effects & 0x0001 != 0
	
	def is_conditioned(self) -> bool:
		return self.effects & 0x0002 != 0
	
	def is_crippled(self) -> bool:
		return self.effects & 0x000A != 0
	
	def is_dead(self) -> bool:
		return self.effects & 0x0010 != 0
	
	def is_deepwounded(self) -> bool:
		return self.effects & 0x0020 != 0
	
	def is_poisoned(self) -> bool:
		return self.effects & 0x0040 != 0
	
	def is_enchanted(self) -> bool:
		return self.effects & 0x0080 != 0
	
	def is_degen_hexed(self) -> bool:
		return self.effects & 0x0400 != 0
	
	def is_hexed(self) -> bool:
		return self.effects & 0x0800 != 0
	
	def is_weapon_spelled(self) -> bool:
		return self.effects & 0x8000 != 0
	
	def in_combat_stance(self):
		return self.type_map & 0x000001 != 0
	
	def has_quest(self):
		return self.type_map & 0x000002 != 0
	
	def is_dead_by_type_map(self):
		return self.type_map & 0x000008 != 0
	
	def is_female(self):
		return self.type_map & 0x000200 != 0
	
	def has_boss_glow(self):
		return self.type_map & 0x000400 != 0
	
	def is_hiding_cape(self):
		return self.type_map & 0x001000 != 0
	
	def can_be_viewed_in_party_window(self):
		return self.type_map & 0x20000 != 0
	
	def is_spawned(self):
		return self.type_map & 0x040000 != 0
	
	def is_being_observed(self):
		return self.type_map & 0x4000000 != 0
	
	def is_knocked_down(self):
		return self.model_state == 1104
	
	def is_moving(self):
		return self.model_state == 12
	
	def is_attacking(self):
		return self.model_state == 96
	
	def is_casting(self):
		return self.model_state == 65
	
	def is_idle(self):
		return self.model_state == 68
	
	def is_alive(self):
		return not self.is_dead() and self.hp > 0
	
	def is_player(self):
		return self.login_number != 0
	
	def is_npc(self):
		return self.login_number == 0
	

class MapAgent(Structure):
	_fields_ = [
		("cur_energy", c_float),
		("max_energy", c_float),
		("energy_regen", c_float),
		("skill_timestamp", c_uint32),
		("h0010", c_float),
		("max_energy2", c_float),
		("h0018", c_float),
		("h001C", c_uint32),
		("cur_health", c_float),
		("max_health", c_float),
		("health_regen", c_float),
		("h002C", c_uint32),
		("effects", c_uint32),
	]
	
	def is_bleeding(self):
		return self.effects & 0x0001 != 0
	
	def is_conditioned(self):
		return self.effects & 0x0002 != 0
	
	def is_crippled(self):
		return self.effects & 0x000A != 0
	
	def is_dead(self):
		return self.effects & 0x0010 != 0
	
	def is_deep_wounded(self):
		return self.effects & 0x0020 != 0
	
	def is_poisoned(self):
		return self.effects & 0x0040 != 0
	
	def is_enchanted(self):
		return self.effects & 0x0080 != 0
	
	def is_degen_hexed(self):
		return self.effects & 0x0400 != 0
	
	def is_hexed(self):
		return self.effects & 0x0800 != 0
	
	def is_weapon_spelled(self):
		return self.effects & 0x8000 != 0


class AgentSummaryInfo(Structure):
	_fields_ = [
		("h0000", c_uint32),
		("h0004", c_uint32),
		("gadget_id", c_uint32),
		("h000C", c_uint32),
		("gadget_name_enc", c_wchar_p),
		("h0014", c_uint32),
		("composite_agent_id", c_uint32),
	]


class AgentMovement(Structure):
	_fields_ = [
		("h0000", c_uint32 * 3),
		("agent_id", c_uint32),
		("h0010", c_uint32 * 3),
		("agent_def", c_uint32),
		("h0020", c_uint32 * 6),
		("moving1", c_uint32),
		("h003C", c_uint32 * 2),
		("moving2", c_uint32),
		("h0048", c_uint32 * 7),
		("h0064", Vec3f),
		("h0070", c_uint32),
		("h0074", Vec3f),
	]

