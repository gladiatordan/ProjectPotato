#stdlib
from ctypes import Structure, c_uint32, c_uint8, c_void_p, c_wchar, c_wchar_p

#mylib
from . import GWArray


class GHKey(Structure):
	_fields_ = [
		("k", c_uint32 * 4)
	]


class GuildPlayer(Structure):
	_fields_ = [
		("vtable", c_void_p),
		("name_ptr", c_wchar_p),
		("invited_name", c_wchar * 20),
		("current_name", c_wchar * 20),
		("inviter_name", c_wchar * 20),
		("invite_time", c_uint32),
		("promoter_name", c_wchar * 20),
		("h00AC", c_uint32),
		("offline", c_uint32),
		("member_type", c_uint32),
		("status", c_uint32),
		("h00E8", c_uint32 * 35),
	]


class GuildHistoryEvent(Structure):
	_fields_ = [
		("time1", c_uint32),
		("time2", c_uint32),
		("name", c_wchar * 256),
	]


class CapeDesign(Structure):
	_fields_ = [
		("cape_bg_color", c_uint32),
		("cape_detail_color", c_uint32),
		("cape_emblem_color", c_uint32),
		("cape_shape", c_uint32),
		("cape_detail", c_uint32),
		("cape_emblem", c_uint32),
		("cape_trim", c_uint32),
	]


class Guild(Structure):
	_fields_ = [
		("key", GHKey),
		("h0010", c_uint32 * 5),
		("index", c_uint32),
		("rank", c_uint32),
		("features", c_uint32),
		("name", c_wchar * 32),
		("rating", c_uint32),
		("faction", c_uint32),
		("faction_point", c_uint32),
		("qualifier_point", c_uint32),
		("tag", c_wchar * 8),
		("cape", CapeDesign),
	]


class TownAlliance(Structure):
	_fields_ = [
		("rank", c_uint32),
		("allegiance", c_uint32),
		("faction", c_uint32),
		("name", c_wchar * 32),
		("tag", c_wchar * 5),
		("_padding", c_uint8 * 2),
		("cape", CapeDesign),
		("map_id", c_uint32),
	]


class GuildContext(Structure):
	_fields_ = [
		("h0000", c_uint32),
		("h0004", c_uint32),
		("h0008", c_uint32),
		("h000C", c_uint32),
		("h0010", c_uint32),
		("h0014", c_uint32),
		("h0018", c_uint32),
		("h001C", c_uint32),
		("h0020", GWArray),
		("h0030", c_uint32),
		("player_name", c_wchar * 20),
		("h005C", c_uint32),
		("player_guild_index", c_uint32),
		("player_gh_key", GHKey),
		("h0074", c_uint32),
		("announcement", c_wchar * 256),
		("announcement_author", c_wchar * 20),
		("player_guild_rank", c_uint32),
		("h02A4", c_uint32),
		("factions_outpost_guilds", GWArray),
		("kurzick_town_count", c_uint32),
		("luxon_town_count", c_uint32),
		("h02C0", c_uint32),
		("h02C4", c_uint32),
		("h02C8", c_uint32),
		("player_guild_history", GWArray),
		("h02DC", c_uint32 * 7),
		("guilds", GWArray),
		("h0308", c_uint32 * 4),
		("h0318", GWArray),
		("h0328", c_uint32),
		("h032C", GWArray),
		("h033C", c_uint32 * 7),
		("player_roster", GWArray),
	]