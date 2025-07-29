"""

Entry point to access the core functionality


usage: from core import Core


"""
#stdlib
import os
import glob

#mylib
from .core_const import *
from .scanner import ProcessScanner, FileScanner
from .memory import MemoryBuffer, ProcessMemory
from .assembler import Assembler


class Core:
	"""
	Core API instance which directly interfaces with an executable.
	Do not expose this beyond the API scope!

	"""
	def __init__(self, target_exe, target_root):
		self.proc_scanner = ProcessScanner(target_exe)
		self.modify_buffer = None
		self.modify_assembler = None
		self.proc_memory = None
		self.proc = None
		self.initialized = False
		self.references = {}
		self.saved_values = {}

		for f in glob.glob(f"{os.path.join(target_root, "*")}"):
			if os.path.isdir(f) and "GuildWars" in f:
				pe_path = os.path.join(target_root, f, target_exe)
				break
		self.scanner = FileScanner(pe_path)

	def get_processes(self):
		return self.proc_scanner.get_scanned_processes()

	def set_value(self, label: str, value: int) -> None:
		"""Saves a memory address or value by label."""
		self.saved_values[label] = value

	def get_value(self, label: str) -> int:
		"""Returns a memory address or value by label"""
		if label in self.saved_values:
			return self.saved_values[label]
		raise KeyError(f"Trying to fetch {label} but it is not a saved value!")

	def _read_scan_values(self):
		"""Reads known offsets from the scan base and updates self.saved_values with the labels"""
		# TODO - redo this

	def _read_modify_values(self):
		"""Reads known offsets from the modify base address and updates self.saved_values with the labels"""
		pass

	def _build_modify_payload(self):
		asm = Assembler(self.modify_buffer)
		self.modify_assembler = asm
		# TODO - redo this routine!

	def _assemble_payload(self, base_addr, payload_type="scan"):
		# if payload_type is not scan then assemble modify payload
		assemblers = {
			"scan":	self.scan_assembler,
			"modify": self.modify_assembler,
		}
		assemblers[payload_type].assemble(base_addr)

	def _write_detour(self, from_label: str, to_label: str) -> None:
		"""
		Writes a JMP detour in the modify buffer from one label to another

		This modifies the buffer at the location of 'from_label' to jump to 'to_label'

		
		"""
		pass

	def _save_references(self):
		self.queue_counter = self.proc_memory.memory_read(self.saved_values["QueueCounter"])
		self.queue_size = self.saved_values["QueueSize"]
		self.queue_base = self.saved_values["QueueBase"]
		self.target_log_base = self.saved_values["TargetLogBase"]
		self.string_log_base = self.saved_values["StringLogBase"]
		self.ensure_english = self.saved_values["EnsureEnglish"]
		self.trader_quote_id = self.saved_values["TraderQuoteID"]
		self.trader_cost_id = self.saved_values["TraderCostID"]
		self.trader_cost_value = self.saved_values["TraderCostValue"]
		self.disable_rendering = self.saved_values["DisableRendering"]
		self.agent_copy_count = self.saved_values["AgentCopyCount"]
		self.agent_copy_base = self.saved_values["AgentCopyBase"]
		self.last_dialog_id = self.saved_values["last_dialog_id"]

	def _initialize(self, target_title: str):
		if self.initialized:
			print("Already initialized, why are we calling this again?")
			return

		proc = self.proc_scanner.get_process_by_title(target_title)

		if not proc:
			raise RuntimeError(f"Could not find process with title: '{target_title}'")
		self.proc = proc
		self.proc_memory = ProcessMemory(self.proc.pid)
		self.proc_memory.memory_open()
		pmem = self.proc_memory
		
		self.scanner.find_assertions(scanner_assertions)
		self.scanner.scan_for_values(scanner_patterns)

		print(self.scanner.get_scanned_values())