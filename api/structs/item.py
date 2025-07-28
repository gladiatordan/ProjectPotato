#stdlib
from ctypes import Structure, c_uint32, c_uint16, c_uint8, c_void_p, c_wchar_p, c_char


#mylib
from . import GWArray
from ..constants.item import *


# FOR ALL STRUCTS, NEED TO USE EXPLICIT PADDING, UNLIKE C++ PYTHON DOES NOT IMPLICITLY ALIGN STRUCT SIZES
class DyeInfo(Structure):
	_fields_ = [
		("dye_tint", c_uint8),
		("dye1", c_uint8, 4),
		("dye2", c_uint8, 4),
		("dye3", c_uint8, 4),
		("dye4", c_uint8, 4),
	]


class Item(Structure):
	_fields_ = [
		("item_id", 				c_uint32),
		("agent_id", 				c_uint32),
		("bag_equpped", 			c_void_p),
		("bag", 					c_void_p),
		("mod_struct", 				c_void_p),
		("mod_struct_size", 		c_uint32),
		("customized", 				c_wchar_p),
		("model_file_id", 			c_uint32),
		("item_type",				c_uint8),
		("dye", 					DyeInfo),
		("value",					c_uint16),
		("h0026", 					c_uint16),
		("interaction", 			c_uint32),
		("model_id", 				c_uint32),
		("info_string", 			c_wchar_p),
		("name_enc", 				c_wchar_p),
		("complete_name_enc", 		c_wchar_p),
		("single_item_name", 		c_wchar_p),
		("h0040", 					c_uint32),
		("item_formula", 			c_uint16),
		("is_material_salvageable", c_uint8),
		("h004B", 					c_uint8),
		("quantity", 				c_uint16),
		("equipped", 				c_uint8),
		("profession", 				c_uint8),
		("slot", 					c_uint8),
		("_pad", 					c_uint8 * 3),
	]

	def is_stackable(self) -> bool:
		return bool(self.interaction & 0x800000)

	def is_inscribable(self) -> bool:
		return bool(self.interaction & 0x08000000)
	
	def is_material(self) -> bool:
		return self.item_type == ItemType.MATERIALS_ZCOINS and not self.is_zcoin()
	
	def is_zcoin(self) -> bool:
		return self.model_file_id in [ItemModelID.ZCOIN_COPPER, ItemModelID.ZCOIN_SILVER, ItemModelID.ZCOIN_GOLD]


class ItemData(Structure):
	_fields_ = [
		("model_file_id", c_uint32),
		("type", c_uint8),
		("dye", DyeInfo),
		("value", c_uint32),
		("interaction", c_uint32),
	]


class ItemFormula(Structure):
	_fields_ = [
		("h0000", c_uint32),
		("gold_cost", c_uint32),
		("skill_point_cost", c_uint32),
		("material_cost_count", c_uint32),
		("material_cost_buffer", c_void_p),
	]


class MaterialCost(Structure):
	_fields_ = [
		("material", c_uint32),
		("amount", c_uint32),
		("h0008", c_uint32),
		("h000C", c_uint32),
	]


class ItemContext(Structure):
	_fields_ = [
		("h0000", GWArray),
		("h0010", GWArray),
		("h0020", c_uint32),
		("bags_array", GWArray),
		("h0034", c_char * 12),
		("h0040", GWArray),
		("h0050", GWArray),
		("h0060", c_char * 88),
		("item_array", GWArray),
		("h00C8", c_char * 48),
		("inventory", c_void_p),
		("h00FC", GWArray),
	]


class Bag(Structure):
	_fields_ = [
		("bag_type", c_uint32),
		("index", c_uint32),
		("_unknown0", c_uint32),
		("container_item", c_uint32),
		("items_count", c_uint32),
		("bag_array", c_void_p),
		("items", GWArray),
	]

	def is_inventory_bag(self) -> bool:
		return self.bag_type == 1
	
	def is_storage_bag(self) -> bool:
		return self.bag_type == 4
	
	def is_material_storage(self) -> bool:
		return self.bag_type == 5


class ItemModifier(Structure):
	_fields_ = [
		("mod", c_uint32),
	]

	def identifier(self) -> int:
		return self.mod >> 16
	
	def arg1(self):
		return (self.mod & 0x0000FF00) >> 8
	
	def arg2(self):
		return (self.mod & 0x000000FF)
	
	def arg(self):
		return (self.mod & 0x0000FFFF)


class WeaponSet(Structure):
	_fields_ = [
		("weapon", c_void_p),
		("offhand", c_void_p),
	]


class Inventory(Structure):
	_fields_ = [
		("unused_bag", c_void_p),
		("backpack", c_void_p),
		("belt_pouch", c_void_p),
		("bag1", c_void_p),
		("bag2", c_void_p),
		("equipment_pack", c_void_p),
		("material_storage", c_void_p),
		("unclaimed_items", c_void_p),
		("storage1", c_void_p),
		("storage2", c_void_p),
		("storage3", c_void_p),
		("storage4", c_void_p),
		("storage5", c_void_p),
		("storage6", c_void_p),
		("storage7", c_void_p),
		("storage8", c_void_p),
		("storage9", c_void_p),
		("storage10", c_void_p),
		("storage11", c_void_p),
		("storage12", c_void_p),
		("storage13", c_void_p),
		("storage14", c_void_p),
		("equipped_items", c_void_p),
		("bundle", c_void_p),
		("h0060", c_uint32),
		("weapon_sets", WeaponSet * 4),
		("active_weapon_set", c_uint32),
		("h0088", c_uint32 * 2),
		("gold_character", c_uint32),
		("gold_storage", c_uint32),
	]


class SalvageSessionInfo(Structure):
	_fields_ = [
		("vtable", c_void_p),
		("frame_id", c_uint32),
		("item_id", c_uint32),
		("salvageable_1", c_uint32),
		("salvageable_2", c_uint32),
		("salvageable_3", c_uint32),
		("chosen_salvageable", c_uint32),
		("h001C", c_uint32),
		("kit_id", c_uint32),
	]
