#stdlib
from ctypes import Structure, c_uint32

#mylib
from . import GWArray


class TradeItem(Structure):
	_fields_ = [
		("item_id", c_uint32),
		("quantity", c_uint32),
	]


class TradePlayer(Structure):
	_fields_ = [
		("gold", c_uint32),
		("items", GWArray),
	]


class TradeContext(Structure):
	_fields_ = [
		("flags", c_uint32),
		("h0004", c_uint32 * 3),
		("player", TradePlayer),
		("partner", TradePlayer),
	]
	
	def is_trade_initiated(self) -> bool:
		return (self.flags & 0x1) != 0

	def is_trade_offered(self) -> bool:
		return (self.flags & 0x2) != 0

	def is_trade_accepted(self) -> bool:
		return (self.flags & 0x4) != 0
