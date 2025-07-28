#stdlib
from ctypes import Structure, c_uint32, c_uint8, c_wchar

#mylib
from . import GWArray, TLink, TList


class PartyContext(Structure):
	_fields_ = [
		("h0000", c_uint32),
		("h0004", GWArray),
		("flag", c_uint32),
		("h0018", c_uint32),
		("requests", TList),
		("requests_count", c_uint32),
		("sending", TList),
		("h003C", c_uint32),
		("parties", GWArray),
		("h0050", c_uint32),
		("player_party", GWArray),
		("h0058", c_uint8 * 104),
		("party_search", GWArray),
	]

	def in_hard_mode(self) -> bool:
		return (self.flag & 0x10) > 0
	
	def is_defeated(self) -> bool:
		return (self.flag & 0x20) > 0
	
	def is_party_leader(self) -> bool:
		return (self.flag >> 0x7) & 1
	

class PartyInfo(Structure):
	_fields_ = [
		("party_id", c_uint32),
		("players", GWArray),
		("henchmen", GWArray),
		("heroes", GWArray),
		("others", GWArray),
		("h0044", c_uint32 * 14),
		("invite_link", TLink),
	]


class PartySearch(Structure):
	_fields_ = [
		("party_search_id", c_uint32),
		("party_search_type", c_uint32),
		("hardmode", c_uint32),
		("district", c_uint32),
		("language", c_uint32),
		("party_size", c_uint32),
		("hero_count", c_uint32),
		("message", c_wchar * 32),
		("party_leader", c_wchar * 20),
		("primary", c_uint32),
		("secondary", c_uint32),
		("level", c_uint32),
		("timestmap", c_uint32),
	]


class PlayerPartyMember(Structure):
	_fields_ = [
		("login_number", c_uint32),
		("called_target_id", c_uint32),
		("state", c_uint32),
	]

	def is_connected(self) -> bool:
		return (self.state & 1) > 0
	
	def is_ticked(self) -> bool:
		return (self.state & 2) > 0


class HeroPartyMember(Structure):
	_fields_ = [
		("agent_id", c_uint32),
		("owner_player_id", c_uint32),
		("hero_id", c_uint32),
		("h000C", c_uint32),
		("h0010", c_uint32),
		("level", c_uint32),
	]


class HenchmanPartyMember(Structure):
	_fields_ = [
		("agent_id", c_uint32),
		("h0004", c_uint32 * 10),
		("profession", c_uint32),
		("level", c_uint32),
	]
