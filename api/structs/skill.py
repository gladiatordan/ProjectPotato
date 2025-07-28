#stdlib
from ctypes import Structure, c_uint32, c_uint16, c_uint8, c_float, c_ulong

#mylib
from . import GWArray


class Skill(Structure):
	_fields_ = [
		("skill_id", c_uint32),
		("h0004", c_uint32),
		("campaign", c_uint32),
		("type", c_uint32),
		("special", c_uint32),
		("combo_req", c_uint32),
		("effect1", c_uint32),
		("condition", c_uint32),
		("effect2", c_uint32),
		("weapon_req", c_uint32),
		("profession", c_uint8),
		("attribute", c_uint8),
		("title", c_uint16),
		("skill_id_pvp", c_uint32),
		("combo", c_uint8),
		("target", c_uint8),
		("h0032", c_uint8),
		("skill_equip_type", c_uint8),
		("overcast", c_uint8),
		("energy_cost", c_uint8),
		("health_cost", c_uint8),
		("h0037", c_uint8),
		("adrenaline", c_uint8),
		("activation", c_float),
		("aftercast", c_float),
		("duration0", c_uint32),
		("duration15", c_uint32),
		("recharge", c_uint32),
		("h0050", c_uint16 * 4),
		("skill_arguments", c_uint32),
		("scale0", c_uint32),
		("scale15", c_uint32),
		("bonus_scale0", c_uint32),
		("bonus_scale15", c_uint32),
		("aoe_range", c_float),
		("const_effect", c_float),
		("caster_overhead_animation_id", c_uint32),
		("caster_body_animation_id", c_uint32),
		("target_overhead_animation_id", c_uint32),
		("target_body_animation_id", c_uint32),
		("projectile_animation_1_id", c_uint32),
		("projectile_animation_2_id", c_uint32),
		("icon_file_id", c_uint32),
		("icon_file_id_2", c_uint32),
		("name", c_uint32),
		("concise", c_uint32),
		("description", c_uint32),
	]

	def get_energy_cost(self) -> int:
		match self.energy_cost:
			case 11:
				return 15
			case 12:
				return 25
			case _:
				return self.energy_cost
			
	def is_touch_range(self) -> bool:
		return (self.special & 0x2) != 0
	
	def is_elite(self) -> bool:
		return (self.special & 0x4) != 0
	
	def is_half_range(self) -> bool:
		return (self.special & 0x8) != 0
	
	def is_pvp(self) -> bool:
		return (self.special & 0x400000) != 0
	
	def is_pve(self) -> bool:
		return (self.special & 0x80000) != 0
	
	def is_playable(self) -> bool:
		return (self.special & 0x2000000) == 0
	
	def is_stacking(self) -> bool:
		return (self.special & 0x10000) != 0
	
	def is_non_stacking(self) -> bool:
		return (self.special & 0x20000) != 0


class SkillbarSkill(Structure):
	_fields_ = [
		("adrenaline_a", c_uint32),
		("adrenaline_b", c_uint32),
		("recharge", c_uint32),
		("skill_id", c_uint32),
		("event", c_uint32),
	]


class Skillbar(Structure):
	_fields_ = [
		("agent_id", c_uint32),
		("skills", SkillbarSkill * 8),
		("disabled", c_uint32),
		("h00A8", c_uint32 * 2),
		("casting", c_uint32),
		("h00B4", c_uint32 * 2),
	]


class Effect(Structure):
	_fields_ = [
		("skill_id", c_uint32),
		("attribute_level", c_uint32),
		("effect_id", c_uint32),
		("agent_id", c_uint32),
		("duration", c_float),
		("timestamp", c_ulong),
	]


class Buff(Structure):
	_fields_ = [
		("skill_id", c_uint32),
		("h0004", c_uint32),
		("buff_id", c_uint32),
		("target_agent_id", c_uint32),
	]


class AgentEffects(Structure):
	_fields_ = [
		("agent_id", c_uint32),
		("buffs", GWArray),
		("effects", GWArray),
	]
