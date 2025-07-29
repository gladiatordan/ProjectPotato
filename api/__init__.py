"""

Main entry point for the entire GWAPY API.


usage: from api import GWAPY as gwapy


"""
from .core import *
from .context import GameContext



class GWAPY(Core):
	def __init__(self):
		super().__init__(target_exe="Gw.exe", target_root="C:\\Users\\Daniel\\Desktop\\GW")
		# targets = self.get_processes()
		self.initialized = False
		# print("Found targets for gw.exe")
		# print(targets)

	def _resolve_scanned_values(self):
		rebase_delta = self.proc.base_address - self.scanner.image_base
		print(f"REBASE DELTA -> {hex(rebase_delta)}")
		for k, v in self.scanner.scanned_values.items():
			# print(f"OLD ADDR FOR {k} -> {hex(v)}")
			self.saved_values[k] = v + rebase_delta - 0x1000
			# print(f"NEW ADDR FOR {k} -> {hex(v + rebase_delta)}")
	
	def initialize(self, target_title):
		self._initialize(target_title)
		self._resolve_scanned_values()
		self.initialized = True
		self.game_cxt = GameContext(self)

	def get_game_cxt(self):
		gx_struct = self.game_cxt.get_game_cxt()
		print(type(gx_struct))
		print(gx_struct)
