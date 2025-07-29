#stdlib
from ctypes import Structure, c_uint32, c_uint8, sizeof

#mylib
from . import GWArray


class AccountUnlockedCount(Structure):
	_fields_ = [
		("id", c_uint32),
		("unk1", c_uint32),
		("unk2", c_uint32),
	]


class AccountUnlockedItemInfo(Structure):
	_fields_ = [
		("name_id", c_uint32),
		("mod_struct_index", c_uint32),
		("mod_struct_size", c_uint32),
	]


class AccountContext(Structure):
	_fields_ = [
		("account_unlocked_counts", GWArray),
		("h0010", c_uint8 * 164),
		("unlocked_pvp_heroes", GWArray),
		("h00C4", GWArray),
		("unlocked_pvp_item_info", GWArray),
		("unlcoked_pvp_items", GWArray),
		("h0104", c_uint8 * 48),
		("unlocked_account_skills", GWArray),
		("account_flags", c_uint32),
	]


assert(sizeof(AccountUnlockedCount) == 12)
assert(sizeof(AccountUnlockedItemInfo) == 12)
assert(sizeof(AccountContext) == 0x138)