#stdlib
from ctypes import Structure, c_uint32, c_wchar_p


class Title(Structure):
	_fields_ = [
		("props", c_uint32),
		("current_points", c_uint32),
		("current_title_tier_index", c_uint32),
		("points_needed_current_rank", c_uint32),
		("next_title_tier_index", c_uint32),
		("points_needed_next_rank", c_uint32),
		("max_title_rank", c_uint32),
		("max_title_tier_index", c_uint32),
		("h0020", c_wchar_p),
		("h0024", c_wchar_p),
	]

	def is_percentage_based(self) -> bool:
		return (self.props & 1) != 0
	
	def has_tiers(self) -> bool:
		return (self.props & 3) != 0
	

class TitleTier(Structure):
	_fields_ = [
		("props", c_uint32),
		("tier_number", c_uint32),
		("tier_name_enc", c_wchar_p),
	]

	def is_percentage_based(self) -> bool:
		return (self.props & 1) != 0


class TitleClientData(Structure):
	_fields_ = [
		("title_id", c_uint32),
		("name_id", c_uint32),
	]