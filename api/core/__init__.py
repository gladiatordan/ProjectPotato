"""

Entry point to access the core functionality


usage: from core import Core


"""
#stdlib
import ctypes
import struct
from ctypes import wintypes

#corelib
from .constants import *
from .scanner import ProcessScanner, MemoryScanner
from .memory import MemoryBuffer, ProcessMemory
from .assembler import Assembler



class Core:
	"""
	Core API instance which directly interfaces with an executable.
	Do not expose this beyond the API scope!

	"""
	def __init__(self, target_exe):
		self.proc_scanner = ProcessScanner(target_exe)
		self.mem_scanner = MemoryScanner()
		self.scan_buffer = None
		self.scan_assembler = None
		self.modify_buffer = None
		self.modify_assembler = None
		self.proc_memory = None
		self.proc = None
		self.scanner_injected = False
		self.initialized = False
		self.references = {}
		self.saved_values = {}

	
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


	def _get_scanned_label_address(self, label: str, offset: int):
		base = self.scan_base
		pmem = self.proc_memory
		# print(f"LABEL ADDR '{label}': {self.scan_buffer.labels[label] + offset}")
		return (pmem.memory_read(self.scan_buffer.labels[label] + 8 + self.scan_inject_base) - pmem.memory_read(self.scan_buffer.labels[label] + 4 + self.scan_inject_base) + offset)


	def _read_scan_values(self):
		"""Reads known offsets from the scan base and updates self.saved_values with the labels"""
		pmem = self.proc_memory

		self.saved_vales["PreGame"] = pmem.find_assertion("P:\Code\Gw\Ui\UiPregame.cpp", "!s_scene", 0, 0x34)
		
		self.saved_values["BasePointer"] = pmem.memory_read(self._get_scanned_label_address("ScanBasePointer", 8))
		print(f"BasePointer -> 0x{self.saved_values["BasePointer"]:08X}")

		self.saved_values["AgentBase"] = pmem.memory_read(self._get_scanned_label_address("ScanAgentBasePointer", 8) + 5)
		print(f"AgentBase -> 0x{self.saved_values["AgentBase"]:08X}")

		self.saved_values["MaxAgents"] = self.saved_values["AgentBase"] + 8
		print(f"MaxAgents -> 0x{self.saved_values["MaxAgents"]:08X}")

		self.saved_values["MyID"] = pmem.memory_read(self._get_scanned_label_address("ScanMyID", -3))
		print(f"MyID -> 0x{self.saved_values["MyID"]:08X}")
		
		self.saved_values["CurrentTarget"] = pmem.memory_read(self._get_scanned_label_address("ScanCurrentTarget", -14))
		print(f"CurrentTarget -> 0x{self.saved_values["CurrentTarget"]:08X}")
		
		self.saved_values["PacketLocation"] = pmem.memory_read(self._get_scanned_label_address("ScanBaseOffset", 11))
		print(f"PacketLocation -> 0x{self.saved_values["PacketLocation"]:08X}")
		
		self.saved_values["Ping"] = pmem.memory_read(self._get_scanned_label_address("ScanPing", -0x14))
		print(f"Ping -> 0x{self.saved_values["Ping"]:08X}")
		
		self.saved_values["MapID"] = pmem.memory_read(self._get_scanned_label_address("ScanMapID", 28))
		print(f"MapID -> 0x{self.saved_values["MapID"]:08X}")
		
		self.saved_values["MapLoading"] = pmem.memory_read(self._get_scanned_label_address("ScanMapLoading", 0xB))
		print(f"MapLoading -> 0x{self.saved_values["MapLoading"]:08X}")
		
		self.saved_values["LoggedIn"] = pmem.memory_read(self._get_scanned_label_address("ScanLoggedIn", 3))
		print(f"LoggedIn -> 0x{self.saved_values["LoggedIn"]:08X}")
		
		self.saved_values["Language"] = pmem.memory_read(self._get_scanned_label_address("ScanMapInfo", 11) + 0xC)
		print(f"Language -> 0x{self.saved_values["Language"]:08X}")
		self.saved_values["Region"] = self.saved_values["Language"] + 4
		print(f"Region -> 0x{self.saved_values["Language"]:08X}")
		
		self.saved_values["SkillBase"] = pmem.memory_read(self._get_scanned_label_address("ScanSkillBase", 8))
		print(f"SkillBase -> 0x{self.saved_values["SkillBase"]:08X}")
		
		self.saved_values["SkillTimer"] = pmem.memory_read(self._get_scanned_label_address("ScanSkillTimer", -3))
		print(f"SkillTimer -> 0x{self.saved_values["SkillTimer"]:08X}")
		
		self.saved_values["ZoomStill"] = self._get_scanned_label_address("ScanZoomStill", 0x33)
		print(f"ZoomStill -> 0x{self.saved_values["ZoomStill"]:08X}")
		
		self.saved_values["ZoomMoving"] = self._get_scanned_label_address("ScanZoomMoving", 0x21)
		print(f"ZoomMoving -> 0x{self.saved_values["ZoomMoving"]:08X}")
		
		self.saved_values["ChangeStatusFunction"] = pmem.memory_read(self._get_scanned_label_address("ScanChangeStatusFunction", 0x23))
		print(f"ChangeStatusFunction -> 0x{self.saved_values["ChangeStatusFunction"]:08X}")
		
		self.saved_values["CharSlots"] = pmem.memory_read(self._get_scanned_label_address("ScanCharSlots", 0x16))
		print(f"CharSlots -> 0x{self.saved_values["CharSlots"]:08X}")
		
		self.saved_values["MainStart"] = self._get_scanned_label_address("ScanEngine", -0x22)
		print(f"MainStart -> 0x{self.saved_values["MainStart"]:08X}")
		self.saved_values["MainReturn"] = self.saved_values["MainStart"] + 5
		print(f"MainReturn -> {self.saved_values["MainReturn"]}")
		
		self.saved_values["TargetLogStart"] = self._get_scanned_label_address("ScanTargetLog", 1)
		print(f"TargetLogStart -> 0x{self.saved_values["TargetLogStart"]:08X}")
		self.saved_values["TargetLogReturn"] = self.saved_values["TargetLogStart"] + 5
		print(f"TargetLogReturn -> 0x{self.saved_values["TargetLogReturn"]:08X}")
		
		self.saved_values["SkillLogStart"] = self._get_scanned_label_address("ScanSkillLog", 1)
		print(f"SkillLogStart -> 0x{self.saved_values["SkillLogStart"]:08X}")
		self.saved_values["SkillLogReturn"] = self.saved_values["SkillLogStart"] + 5
		print(f"SkillLogReturn -> 0x{self.saved_values["SkillLogReturn"]:08X}")
		
		self.saved_values["SkillCompleteLogStart"] = self._get_scanned_label_address("ScanSkillCompleteLog", -0x4)
		print(f"SkillCompleteLogStart -> 0x{self.saved_values["SkillCompleteLogStart"]:08X}")
		self.saved_values["SkillCompleteLogReturn"] = self.saved_values["SkillCompleteLogStart"] + 5
		print(f"SkillCompleteLogReturn -> 0x{self.saved_values["SkillCompleteLogReturn"]:08X}")
		
		self.saved_values["SkillCancelLogStart"] = self._get_scanned_label_address("ScanSkillCancelLog", 0x5)
		print(f"SkillCancelLogStart -> 0x{self.saved_values["SkillCancelLogStart"]:08X}")
		self.saved_values["SkillCancelLogReturn"] = self.saved_values["SkillCancelLogStart"] + 6
		print(f"SkillCancelLogReturn -> 0x{self.saved_values["SkillCancelLogReturn"]:08X}")
		
		self.saved_values["ChatLogStart"] = self._get_scanned_label_address("ScanChatLog", 0x12)
		print(f"ChatLogStart -> 0x{self.saved_values["ChatLogStart"]:08X}")
		self.saved_values["ChatLogReturn"] = self.saved_values["ChatLogStart"]
		print(f"ChatLogReturn -> 0x{self.saved_values["ChatLogReturn"]:08X}")
		
		self.saved_values["TraderHookStart"] = self._get_scanned_label_address("ScanTraderHook", -0x2F)
		print(f"TraderHookStart -> 0x{self.saved_values["TraderHookStart"]:08X}")
		self.saved_values["TraderHookReturn"] = self.saved_values["TraderHookStart"] + 5
		print(f"TraderHookReturn -> 0x{self.saved_values["TraderHookReturn"]:08X}")
		
		self.saved_values["DialogLogStart"] = self._get_scanned_label_address("ScanDialogLog", -0x4)
		print(f"DialogLogStart -> 0x{self.saved_values["DialogLogStart"]:08X}")
		self.saved_values["DialogLogReturn"] = self.saved_values["DialogLogStart"] + 5
		print(f"DialogLogReturn -> 0x{self.saved_values["DialogLogReturn"]:08X}")
		
		self.saved_values["StringFilter1Start"] = self._get_scanned_label_address("ScanStringFilter1", -0x5)
		print(f"StringFilter1Start -> 0x{self.saved_values["StringFilter1Start"]:08X}")
		self.saved_values["StringFilter1Return"] = self.saved_values["StringFilter1Start"] + 5
		print(f"StringFilter1Return -> 0x{self.saved_values["StringFilter1Return"]:08X}")
		
		self.saved_values["StringFilter2Start"] = self._get_scanned_label_address("ScanStringFilter2", -0x5)
		print(f"StringFilter2Start -> 0x{self.saved_values["StringFilter2Start"]:08X}")
		self.saved_values["StringFilter2Return"] = self.saved_values["StringFilter2Start"] + 5
		print(f"StringFilter2Return -> 0x{self.saved_values["StringFilter2Return"]:08X}")
		
		self.saved_values["StringLogStart"] = self._get_scanned_label_address("ScanStringLog", 0x16)
		print(f"StringLogStart -> 0x{self.saved_values["StringLogStart"]:08X}")
		
		self.saved_values["LoadFinishedStart"] = self._get_scanned_label_address("ScanLoadFinished", 0x1)
		print(f"LoadFinishedStart -> 0x{self.saved_values["LoadFinishedStart"]:08X}")
		self.saved_values["LoadFinishedReturn"] = self._get_scanned_label_address("ScanLoadFinished", 0x6)
		print(f"LoadFinishedReturn -> 0x{self.saved_values["LoadFinishedReturn"]:08X}")
		
		self.saved_values["PostMessage"] = pmem.memory_read(self._get_scanned_label_address("ScanPostMessage", 0xB))
		print(f"PostMessage -> 0x{self.saved_values["PostMessage"]:08X}")
		
		self.saved_values["Sleep"] = pmem.memory_read(pmem.memory_read(self.scan_buffer.labels["ScanSleep"] + self.scan_base + 8) + 3)
		print(f"Sleep -> 0x{self.saved_values["Sleep"]:08X}")
		
		self.saved_values["SalvageFunction"] = self._get_scanned_label_address("ScanSalvageFunction", -0xA)
		print(f"SalvageFunction -> 0x{self.saved_values["SalvageFunction"]:08X}")
		
		self.saved_values["SalvageGlobal"] = pmem.memory_read(self._get_scanned_label_address("ScanSalvageGlobal", 1) - 0x4)
		print(f"SalvageGlobal -> 0x{self.saved_values["SalvageGlobal"]:08X}")
		
		self.saved_values["IncreaseAttributeFunction"] = self._get_scanned_label_address("ScanIncreaseAttributeFunction", -0x5A)
		print(f"IncreaseAttributeFunction -> 0x{self.saved_values["IncreaseAttributeFunction"]:08X}")
		
		self.saved_values["DecreaseAttributeFunction"] = self._get_scanned_label_address("ScanDecreaseAttributeFunction", 0x19)
		print(f"DecreaseAttributeFunction -> 0x{self.saved_values["DecreaseAttributeFunction"]:08X}")
		
		self.saved_values["MoveFunction"] = self._get_scanned_label_address("ScanMoveFunction", 0x1)
		print(f"MoveFunction -> 0x{self.saved_values["MoveFunction"]:08X}")
		
		self.saved_values["UseSkillFunction"] = self._get_scanned_label_address("ScanUseSkillFunction", -0x125)
		print(f"UseSkillFunction -> 0x{self.saved_values["UseSkillFunction"]:08X}")
		
		self.saved_values["ChangeTargetFunction"] = self._get_scanned_label_address("ScanChangeTargetFunction", -0x86) + 1
		print(f"ChangeTargetFunction -> 0x{self.saved_values["ChangeTargetFunction"]:08X}")
		
		self.saved_values["WriteChatFunction"] = self._get_scanned_label_address("ScanWriteChatFunction", -0x3D)
		print(f"WriteChatFunction -> 0x{self.saved_values["WriteChatFunction"]:08X}")
		
		self.saved_values["SellItemFunction"] = self._get_scanned_label_address("ScanSellItemFunction", -0x55)
		print(f"SellItemFunction -> 0x{self.saved_values["SellItemFunction"]:08X}")
		
		self.saved_values["PacketSendFunction"] = self._get_scanned_label_address("ScanPacketSendFunction", -0x50)
		print(f"PacketSendFunction -> 0x{self.saved_values["PacketSendFunction"]:08X}")
		
		self.saved_values["ActionBase"] = self._get_scanned_label_address("ScanActionBase", -0x3)
		print(f"ActionBase -> 0x{self.saved_values["ActionBase"]:08X}")
		
		self.saved_values["ActionFunction"] = self._get_scanned_label_address("ScanActionFunction", -0x3)
		print(f"ActionFunction -> 0x{self.saved_values["ActionFunction"]:08X}")
		
		self.saved_values["UseHeroSkillFunction"] = self._get_scanned_label_address("ScanUseHeroSkillFunction", -0x59)
		print(f"UseHeroSkillFunction -> 0x{self.saved_values["UseHeroSkillFunction"]:08X}")
		
		self.saved_values["BuyItemBase"] = pmem.memory_read(self._get_scanned_label_address("ScanBuyItemBase", 0xF))
		print(f"BuyItemBase -> 0x{self.saved_values["BuyItemBase"]:08X}")
		
		self.saved_values["TransactionFunction"] = self._get_scanned_label_address("ScanTransactionFunction", -0x7E)
		print(f"TransactionFunction -> 0x{self.saved_values["TransactionFunction"]:08X}")
		
		self.saved_values["RequestQuoteFunction"] = self._get_scanned_label_address("ScanRequestQuoteFunction", -0x34)
		print(f"RequestQuoteFunction -> 0x{self.saved_values["RequestQuoteFunction"]:08X}")
		
		self.saved_values["TraderFunction"] = self._get_scanned_label_address("ScanTraderFunction", -0x1E)
		print(f"TraderFunction -> 0x{self.saved_values["TraderFunction"]:08X}")
		
		self.saved_values["ClickToMoveFix"] = self._get_scanned_label_address("ScanClickToMoveFix", 0x1)
		print(f"ClickToMoveFix -> 0x{self.saved_values["ClickToMoveFix"]:08X}")
		
		self.saved_values["ChangeStatusFunction"] = self._get_scanned_label_address("ScanChangeStatusFunction", 0x1)
		print(f"ChangeStatusFunction -> 0x{self.saved_values["ChangeStatusFunction"]:08X}")


	def _read_modify_values(self):
		"""Reads known offsets from the modify base address and updates self.saved_values with the labels"""
		pass


	def read_value_ptr(self, label: str, offsets: list[int]) -> int:
		"""
		Read a value from memory starting at the address saved under 'label'.
		
		Dereferences with the given offsets.
		"""
		base_address = self.get_scanned_address(label)
		_, value = self.proc_memory.memory_read_ptr(base_address, offsets)
		return value

	
	def _execute_remote_thread(self, wait: bool = True, timeout_ms: int = 2500) -> None:
		"""
		
		Creates a remote thread at the given address in the target process and waits for it to complete execution.
		
		"""
		if not self.scanner_injected:
			raise RuntimeError(f"Scanner has not been injected yet!")
		
		kernel32 = ctypes.WinDLL("kernel32", use_last_error=True)

		CreateRemoteThread = kernel32.CreateRemoteThread
		CreateRemoteThread.restype = wintypes.HANDLE
		CreateRemoteThread.argtypes = [
			wintypes.HANDLE, wintypes.LPVOID, ctypes.c_size_t,
			wintypes.LPVOID, wintypes.LPVOID, wintypes.DWORD, 
			ctypes.POINTER(wintypes.DWORD)
		]
		scan_proc_addr = self.scan_base + self.scan_buffer.labels["ScanProc"]
		print(f"ScanProc addr: {scan_proc_addr:08X}")
		thread_id = wintypes.DWORD(0)
		thread_handle = CreateRemoteThread(
			self.proc_memory._proc,															# Process handle
			None,																			# lpThreadAttributes
			0,																				# dwStackSize
			ctypes.c_void_p(scan_proc_addr),			# lpStartAddress
			None,																			# lpParameter
			0,																				# dwCreationFlags
			ctypes.byref(thread_id)															# lpThreadID
		)
		print(f"Remote Thread Handle -> {thread_handle}")
		print(f"ThreadID -> {thread_id.value}")

		if not thread_handle:
			raise OSError(f"CreateRemoteThread failed for address 0x{self.scan_base:08X}")
		
		if wait:
			result = kernel32.WaitForSingleObject(thread_handle, timeout_ms)
			if result != 0:
				kernel32.CloseHandle(thread_handle)
				raise TimeoutError (f"Remote thread at 0x{self.scan_base:08X} timed out")
		
		kernel32.CloseHandle(thread_handle)

	
	def _build_scan_payload(self):
		# calculate scan_base_addr_cmp
		if not self.scan_buffer:
			raise RuntimeError(f"Memory buffer for Scanner not created before building scan payload!")
		
		asm = Assembler(self.scan_buffer)
		self.scan_assembler = asm
		# self.swapped_base_addr = f"{self.proc.base_address_hex:08X}"
		# self.swapped_base_addr = self.proc.base_address_hex[6:8] + self.proc.base_address_hex[4:6] + self.proc.base_address_hex[2:4] + self.proc.base_address_hex[0:2]
		# print(f"SWAPPED_BASE_ADDR -> {self.swapped_base_addr}")
		scan_base_addr_cmp = f"{self.proc.base_address + ADDRESS_BASE_SCAN_CMP_OFFSET:08X}"
		# scan_base_addr_cmp = scan_base_addr_cmp[6:8] + scan_base_addr_cmp[4:6] + scan_base_addr_cmp[2:4] + scan_base_addr_cmp[0:2]
		print(f"SCAN_BASE_ADDR_CMP -> {scan_base_addr_cmp}")

		asm.add_label("MainModPtr/4")
		for label in scanner_patterns:
			pattern = scanner_patterns[label][0]
			asm.add_label(f"Scan{label}")
			asm.add_pattern(pattern)

		# Scan Process function - scans GW for function patterns and adds resulting addresses to addresses for later retrieval
		asm.add_label("ScanProc:")
		asm.add_instruction("pushad")
		asm.add_instruction(f"mov {{ecx}},0x{self.proc.base_address:08X}")
		# print(f"mov {{ecx}},0x{self.proc.base_address_hex}")
		asm.add_instruction("mov {esi},[<ScanProc>]")

		# Scan Loop function
		asm.add_label("ScanLoop:")
		asm.add_instruction("inc {ecx}")
		asm.add_instruction("mov {al},byte[{ecx}]")
		asm.add_instruction("mov {edx},[<ScanBasePointer>]")

		# Scan Inner Loop function
		asm.add_label("ScanInnerLoop:")
		asm.add_instruction("mov {ebx},dword[{edx}]")
		asm.add_instruction("cmp {ebx},-1")
		asm.add_instruction("jnz [<ScanContinue>]")
		asm.add_instruction("add {edx},50")
		asm.add_instruction("cmp {edx},{esi}")
		asm.add_instruction("jnz [<ScanInnerLoop>]")
		asm.add_instruction(f"cmp {{ecx}},{scan_base_addr_cmp}")
		asm.add_instruction("jnz [<ScanLoop>]")
		asm.add_instruction("jmp [<ScanExit>]")

		# Scan Continue function
		asm.add_label("ScanContinue:")
		asm.add_instruction("lea {edi},dword[{edx}+{ebx}]")
		asm.add_instruction("add {edi},C")
		asm.add_instruction("mov {ah},byte[{edi}]")
		asm.add_instruction("cmp {al},{ah}")
		asm.add_instruction("jz [<ScanMatched>]")
		asm.add_instruction("mov dword[{edx}],0")
		asm.add_instruction("add {edx},50")
		asm.add_instruction("cmp {edx},{esi}")
		asm.add_instruction("jnz [<ScanInnerLoop>]")
		asm.add_instruction(f"cmp {{ecx}},{scan_base_addr_cmp}")
		asm.add_instruction("jnz [<ScanLoop>]")
		asm.add_instruction("jmp [<ScanExit>]")

		asm.add_label("ScanMatched:")
		asm.add_instruction("inc {ebx}")
		asm.add_instruction("mov {edi},dword[{edx}+4]")
		asm.add_instruction("cmp {ebx},{edi}")
		asm.add_instruction("jz [<ScanFound>]")
		asm.add_instruction("mov dword[{edx}],{ebx}")
		asm.add_instruction("add {edx},50")
		asm.add_instruction("cmp {edx},{esi}")
		asm.add_instruction("jnz [<ScanInnerLoop>]")
		asm.add_instruction(f"cmp {{ecx}},{scan_base_addr_cmp}")
		asm.add_instruction("jnz [<ScanLoop>]")
		asm.add_instruction("jmp [<ScanExit>]")

		# ScanFound function
		asm.add_label("ScanFound")
		asm.add_instruction("lea {edi},dword[{edx}+8]")
		asm.add_instruction("mov dword[{edi}],{ecx}")
		asm.add_instruction("mov dword[{edx}],-1")
		asm.add_instruction("add {edx},50")
		asm.add_instruction("cmp {edx},{esi}")
		asm.add_instruction("jnz [<ScanInnerLoop>]")
		asm.add_instruction(f"cmp {{ecx}},{scan_base_addr_cmp}")
		asm.add_instruction("jnz [<ScanLoop>]")

		# ScanExit function
		asm.add_label("ScanExit")
		asm.add_instruction("popad")
		asm.add_instruction("retn")


	def _build_modify_payload(self):
		asm = Assembler(self.modify_buffer)
		self.modify_assembler = asm
		# CreateData()
		asm.add_label("QueueCounter/4")
		asm.add_label("TraderQuoteID/4")
		asm.add_label("TraderCostID/4")
		asm.add_label("TraderCostValue/4")
		asm.add_label("DisableRendering/4")
		asm.add_label(f"QueueBase/{256 * SIZE_QUEUE}")
		asm.add_label(f"AgentCopyBase/{0x1C0 * 256}")


		# CreateMain
		asm.add_label("MainProc:")
		# asm.add_instruction("nop x")
		asm.add_instruction("pushad")
		asm.add_instruction("push {eax}")
		asm.add_instruction("push ebx")

		asm.add_instruction(f"mov {{eax}},dword[{self.get_value('BasePointer')}]")
		asm.add_instruction("test {eax},{eax}")
		asm.add_instruction("jz [<RegularFlow>]")
		asm.add_instruction("mov {eax},dword[{eax}]")
		asm.add_instruction("test {eax},{eax}")
		asm.add_instruction("jz [<RegularFlow>]")
		asm.add_instruction("mov {eax},dword[{eax}+18]")
		asm.add_instruction("test {eax},{eax}")
		asm.add_instruction("jz [<RegularFlow>]")
		asm.add_instruction("mov {eax},dword[{eax}+44]")
		asm.add_instruction("test {eax},{eax}")
		asm.add_instruction("jz [<RegularFlow>]")
		asm.add_instruction("mov {ebx},dword[{eax}+19C]")
		asm.add_instruction("test {ebx},{ebx}")
		asm.add_instruction("jz [<RegularFlow>]")
		asm.add_instruction("mov {eax},dword[{eax}+198]")
		asm.add_instruction("cmp {eax},0")
		asm.add_instruction("je [<HandleCase>]")
		asm.add_instruction("mov {ebx},{eax}")
		asm.add_instruction("imul {ebx},{ebx},7C")
		asm.add_instruction(f"add {{ebx}},dword[{self.get_value('Environment')}]")
		asm.add_instruction("test {ebx},{ebx}")
		asm.add_instruction("jz [<RegularFlow>]")
		asm.add_instruction("mov {ebx},dword[{ebx}+10]")
		asm.add_instruction("test {ebx},40001")
		asm.add_instruction("jz [<RegularFlow>]")

		asm.add_label("HandleCase:")
		asm.add_instruction("pop {ebx}")
		asm.add_instruction("pop {eax}")
		asm.add_instruction("mov {eax},dword[<QueueCounter>]")
		asm.add_instruction("mov ecx,{eax}")
		asm.add_instruction("shl {eax},8")
		asm.add_instruction("add {eax},[<QueueBase>]")
		asm.add_instruction("mov {ebx},dword[{eax}]")
		asm.add_instruction("test {ebx},{ebx}")
		asm.add_instruction("jz [<MainExit>]")
		asm.add_instruction("mov dword[{eax}],0")
		asm.add_instruction("mov {eax},ecx")
		asm.add_instruction("inc {eax}")
		asm.add_instruction("cmp {eax},[<QueueSize>]")
		asm.add_instruction("jnz [<SubSkipReset>]")
		asm.add_instruction("xor {eax},{eax}")

		asm.add_label("SubSkipReset:")
		asm.add_instruction("mov dword[<QueueCounter>],{eax}")
		asm.add_instruction("jmp [<MainExit>]")

		asm.add_label("RegularFlow:")
		asm.add_instruction("pop {ebx}")
		asm.add_instruction("pop {eax}")
		asm.add_instruction("mov {eax},dword[<QueueCounter>]")
		asm.add_instruction("mov {ecx},{eax}")
		asm.add_instruction("shl {eax},8")
		asm.add_instruction("add {eax},[<QueueBase>]")
		asm.add_instruction("mov {ebx},dword[{eax}]")
		asm.add_instruction("test {ebx},{ebx}")
		asm.add_instruction("jz [<MainExit>]")
		asm.add_instruction("push {ecx}")
		asm.add_instruction("mov dword[{eax}],0")
		asm.add_instruction("jmp {ebx}")

		asm.add_label("CommandReturn:")
		asm.add_instruction("pop {eax}")
		asm.add_instruction("inc {eax}")
		asm.add_instruction("cmp {eax},[<QueueSize>]")
		asm.add_instruction("jnz [<MainSkipReset>]")
		asm.add_instruction("xor {eax},{eax}")

		asm.add_label("MainSkipReset:")
		asm.add_instruction("mov dword[<QueueCounter>],{eax}")

		asm.add_label("MainExit:")
		asm.add_instruction("popad")
		asm.add_instruction("mov {ebp},{esp}")
		asm.add_instruction("fld st(0),dword[{ebp}+8]")
		asm.add_instruction("ljmp [<MainReturn>]")

		# TraderProc
		asm.add_label("TraderProc:")
		asm.add_instruction("push {eax}")
		asm.add_instruction("mov {eax},dword[{ebx}+28] -> 8b 43 28")
		asm.add_instruction("mov {eax},[{eax}] -> 8b 00")
		asm.add_instruction("mov dword[<TraderCostID>],{eax}")
		asm.add_instruction("mov {eax},dword[{ebx}+28] -> 8b 43 28")
		asm.add_instruction("mov {eax},[{eax}+4] -> 8b 40 04")
		asm.add_instruction("mov dword[<TraderCostValue>],{eax}")
		asm.add_instruction("pop {eax}")
		asm.add_instruction("mov {ebx},dword[{ebp}+C] -> 8B 5D 0C")
		asm.add_instruction("mov {esi},{eax}")
		asm.add_instruction("push {eax}")
		asm.add_instruction("mov {eax},dword[<TraderQuoteID>]")
		asm.add_instruction("inc {eax}")
		asm.add_instruction("cmp {eax},200")
		asm.add_instruction("jnz [<TraderSkipReset>]")
		asm.add_instruction("xor {eax},{eax}")

		asm.add_label("TraderSkipReset:")
		asm.add_instruction("mov dword[<TraderQuoteID>],{eax}")
		asm.add_instruction("pop {eax}")
		asm.add_instruction("ljmp [<TraderReturn>]")

		# CreateRenderingMod
		asm.add_label("RenderingModProc:")
		asm.add_instruction("add {esp},4")
		asm.add_instruction("cmp dword[<DisableRendering>],1")
		asm.add_instruction("ljmp [<RenderingModReturn>]")

		# CreateCommands
		asm.add_label("CommandPacketSend:")
		asm.add_instruction("lea {edx},dword[{eax}+4]")
		asm.add_instruction("push {edx}")
		asm.add_instruction("mov {ebx},11C")
		asm.add_instruction("push {ebx}")
		asm.add_instruction("mov {eax},dword[<PacketLocation>]")
		asm.add_instruction("push {eax}")
		asm.add_instruction("call [<PacketSend>]")
		asm.add_instruction("pop {eax}")
		asm.add_instruction("pop {ebx}")
		asm.add_instruction("pop {edx}")
		asm.add_instruction("ljmp [<CommandReturn>]")

		asm.add_label("CommandAction:")
		asm.add_instruction(f"mov {{ecx}},dword[{self.get_value('ActionBase')}]")
		asm.add_instruction("mov {ecx},dword[{ecx}+c]")
		asm.add_instruction("add {ecx},A0")
		asm.add_instruction("push 0")
		asm.add_instruction("add {eax},4")
		asm.add_instruction("push {eax}")
		asm.add_instruction("push dword[{eax}+4]")
		asm.add_instruction("mov {edx},0")
		asm.add_instruction(f"call {self.get_value('Action')}")
		asm.add_instruction("ljmp [<CommandReturn>]")

		asm.add_label("CommandSendChat:")
		asm.add_instruction("lea {edx},dword[{eax}+4]")
		asm.add_instruction("push {edx}")
		asm.add_instruction("mov {ebx},11c")
		asm.add_instruction("push {ebx}")
		asm.add_instruction(f"mov {{eax}},dword[{self.get_value('PacketLocation')}]")
		asm.add_instruction("push {eax}")
		asm.add_instruction(f"call {self.get_value('PacketSend')}")
		asm.add_instruction("pop {eax}")
		asm.add_instruction("pop {ebx}")
		asm.add_instruction("pop {edx}")
		asm.add_instruction("ljmp [<CommandReturn>]")

		# Skills
		asm.add_label("CommandUseSkill:")
		asm.add_instruction("mov {ecx},dword[{eax}+C]")
		asm.add_instruction("push {ecx}")
		asm.add_instruction("mov {ebx},dword[{eax}+8]")
		asm.add_instruction("push {ebx}")
		asm.add_instruction("mov {edx},dword[{eax}+4]")
		asm.add_instruction("dec {edx}")
		asm.add_instruction("push {edx}")
		asm.add_instruction("mov {eax},dword[<MyID>]")
		asm.add_instruction("push {eax}")
		asm.add_instruction(f"call {self.get_value('UseSkill')}")
		asm.add_instruction("pop {eax}")
		asm.add_instruction("pop {edx}")
		asm.add_instruction("pop {ebx}")
		asm.add_instruction("pop {ecx}")
		asm.add_instruction("ljmp [<CommandReturn>]")

		asm.add_label("CommandUseHeroSkill:")
		asm.add_instruction("mov {ecx},dword[{eax}+8]")
		asm.add_instruction("push {ecx}")
		asm.add_instruction("mov {ecx},dword[{eax}+c]")
		asm.add_instruction("push {ecx}")
		asm.add_instruction("mov {ecx},dword[{eax}+4]")
		asm.add_instruction("push {ecx}")
		asm.add_instruction(f"call {self.get_value('UseHeroSkill')}")
		asm.add_instruction("add {esp},C")
		asm.add_instruction("ljmp [<CommandReturn>]")

		asm.add_label("CommandPlayerStatus:")
		asm.add_instruction("mov {eax},dword[{eax}+4]")
		asm.add_instruction("push {eax}")
		asm.add_instruction(f"call {self.get_value('PlayerStatus')}")
		asm.add_instruction("pop {eax}")
		asm.add_instruction("ljmp [<CommandReturn>]")

		asm.add_label("CommandAddFriend:")
		asm.add_instruction("mov {ecx},dword[{eax}+C]")
		asm.add_instruction("push {ecx}")
		asm.add_instruction("mov {edx},dword[{eax}+8]")
		asm.add_instruction("push {edx}")
		asm.add_instruction("mov {ecx},dword[{eax}+4]")
		asm.add_instruction("push {ecx}")
		asm.add_instruction(f"call {self.get_value('AddFriend')}")
		asm.add_instruction("add {esp},C")
		asm.add_instruction("ljmp [<CommandReturn>]")

		asm.add_label("CommandRemoveFriend:")
		asm.add_instruction("mov {ecx},dword[{eax}+18]")
		asm.add_instruction("push {ecx}")
		asm.add_instruction("mov {edx},dword[{eax}+14]")
		asm.add_instruction("push {edx}")
		asm.add_instruction("lea {ecx},dword[{eax}+4]")
		asm.add_instruction("push {ecx}")
		asm.add_instruction(f"call {self.get_value('RemoveFriend')}")
		asm.add_instruction("add {esp},C")
		asm.add_instruction("ljmp [<CommandReturn>]")

		asm.add_label("CommandIncreaseAttribute:")
		asm.add_instruction("mov {edx},dword[{eax}+4]")
		asm.add_instruction("push {edx}")
		asm.add_instruction("mov {ecx},dword[{eax}+8]")
		asm.add_instruction("push {ecx}")
		asm.add_instruction(f"call {self.get_value('IncreaseAttribute')}")
		asm.add_instruction("add {esp},8")
		asm.add_instruction("ljmp [<CommandReturn>]")

		asm.add_label("CommandDecreaseAttribute:")
		asm.add_instruction("mov {edx},dword[{eax}+4]")
		asm.add_instruction("push {edx}")
		asm.add_instruction("mov {ecx},dword[{eax}+8]")
		asm.add_instruction("push {ecx}")
		asm.add_instruction("call [<DecreaseAttributeFunction>]")
		asm.add_instruction("pop {ecx}")
		asm.add_instruction("pop {edx}")
		asm.add_instruction("ljmp [<CommandReturn>]")

		asm.add_label("CommandChangeStatus:")
		asm.add_instruction("mov {eax},dword[{eax}+4]")
		asm.add_instruction("push {eax}")
		asm.add_instruction(f"call {self.get_value('ChangeStatus')}")
		asm.add_instruction("pop {eax}")
		asm.add_instruction("ljmp [<CommandReturn>]")

		asm.add_label("CommandSellItem:")
		asm.add_instruction("push 0")
		asm.add_instruction("push 0")
		asm.add_instruction("push 0")
		asm.add_instruction("push dword[{eax}+C]")
		asm.add_instruction("add {eax},4")
		asm.add_instruction("mov {ecx},[{eax}]")
		asm.add_instruction("test {ecx},{ecx}")
		asm.add_instruction("jz [<SellItemAll>]")
		asm.add_instruction("push {eax}")
		asm.add_instruction("jmp [<SellItemContinue>]")

		asm.add_label("SellItemAll:")
		asm.add_instruction("push 0")

		asm.add_label("SellItemContinue:")
		asm.add_instruction("add {eax},4")
		asm.add_instruction("push {eax}")
		asm.add_instruction("push 1")
		asm.add_instruction("push 0")
		asm.add_instruction("push B")
		asm.add_instruction(f"call {self.get_value("Transaction")}")
		asm.add_instruction("add {esp},24")
		asm.add_instruction("ljmp [<CommandReturn>]")

		asm.add_label("CommandBuyItem:")
		asm.add_instruction("mov {esi},{eax}")
		asm.add_instruction("add {esi},10")
		asm.add_instruction("mov {ecx},{eax}")
		asm.add_instruction("add {ecx},4")
		asm.add_instruction("push {ecx}")
		asm.add_instruction("mov {edx},{eax}")
		asm.add_instruction("add {edx},8")
		asm.add_instruction("push {edx}")
		asm.add_instruction("push 1")
		asm.add_instruction("push 0")
		asm.add_instruction("push 0")
		asm.add_instruction("push 0")
		asm.add_instruction("push 0")
		asm.add_instruction("mov {eax},dword[{eax}+C]")
		asm.add_instruction("push {eax}")
		asm.add_instruction("push 1")
		asm.add_instruction(f"call {self.get_value('Transaction')}")
		asm.add_instruction("add {esp},24")
		asm.add_instruction("ljmp [<CommandReturn>]")

		asm.add_label("CommandCraftItem:")
		asm.add_instruction("add {eax},4")
		asm.add_instruction("push {eax}")
		asm.add_instruction("add {eax},4")
		asm.add_instruction("push {eax}")
		asm.add_instruction("push 1")
		asm.add_instruction("push 0")
		asm.add_instruction("push 0")
		asm.add_instruction("lea {edi},[{eax}+C]")
		asm.add_instruction("push {edi}")
		asm.add_instruction("push dword[{eax}+8]")
		asm.add_instruction("push dword[{eax}+4]")
		asm.add_instruction("push 3")
		asm.add_instruction(f"call {self.get_value('Transaction')}")
		asm.add_instruction("add {esp},24")
		asm.add_instruction("mov dword[<TraderCostID>],0")
		asm.add_instruction("ljmp [<CommandReturn>]")

		asm.add_label("CommandCollectorExchange:")
		asm.add_instruction("mov {edx},{eax}")
		asm.add_instruction("push 0")
		asm.add_instruction("lea {ecx},[{edx}+4]")
		asm.add_instruction("push {ecx}")
		asm.add_instruction("push 1")
		asm.add_instruction("push 0")
		asm.add_instruction("lea {eax},[{edx}+C]")
		asm.add_instruction("push {eax}")
		asm.add_instruction("mov {ebx},[{edx}+8]")
		asm.add_instruction("lea {ecx},[{edx}+{ebx}*4+C]")
		asm.add_instruction("push {ecx}")
		asm.add_instruction("push {ebx}")
		asm.add_instruction("push 0")
		asm.add_instruction("push 2")
		asm.add_instruction(f"call {self.get_value('Transaction')}")
		asm.add_instruction("add {esp},24")
		asm.add_instruction("ljmp [<CommandReturn>]")

		asm.add_label("CommandRequestQuote:")
		asm.add_instruction("mov dword[<TraderCostID>],0")
		asm.add_instruction("mov dword[<TraderCostValue>],0")
		asm.add_instruction("mov {esi},{eax}")
		asm.add_instruction("add {esi},4")
		asm.add_instruction("push {esi}")
		asm.add_instruction("push 1")
		asm.add_instruction("push 0")
		asm.add_instruction("push 0")
		asm.add_instruction("push 0")
		asm.add_instruction("push 0")
		asm.add_instruction("push 0")
		asm.add_instruction("push C")
		asm.add_instruction("mov {ecx},0")
		asm.add_instruction("mov {edx},2")
		asm.add_instruction(f"call {self.get_value('RequestQuote')}")
		asm.add_instruction("add {esp},20")
		asm.add_instruction("ljmp [<CommandReturn>]")

		asm.add_label("CommandRequestQuoteSell:")
		asm.add_instruction("mov dword[<TraderCostID>],0")
		asm.add_instruction("mov dword[<TraderCostValue>],0")
		asm.add_instruction("push 0")
		asm.add_instruction("push 0")
		asm.add_instruction("push 0")
		asm.add_instruction("add {eax},4")
		asm.add_instruction("push {eax}")
		asm.add_instruction("push 1")
		asm.add_instruction("push 0")
		asm.add_instruction("push 0")
		asm.add_instruction("push D")
		asm.add_instruction("xor {edx},{edx}")
		asm.add_instruction(f"call {self.get_value('RequestQuote')}")
		asm.add_instruction("add {esp},20")
		asm.add_instruction("ljmp [<CommandReturn>]")

		asm.add_label("CommandTraderBuy:")
		asm.add_instruction("push 0")
		asm.add_instruction("push [<TraderCostID>]")
		asm.add_instruction("push 1")
		asm.add_instruction("push 0")
		asm.add_instruction("push 0")
		asm.add_instruction("push 0")
		asm.add_instruction("push 0")
		asm.add_instruction("mov {edx},dword[<TraderCostValue>]")
		asm.add_instruction("push {edx}")
		asm.add_instruction("push C")
		asm.add_instruction("mov {ecx},C")
		asm.add_instruction(f"call {self.get_value('Transaction')}")
		asm.add_instruction("add {esp},24")
		asm.add_instruction("mov dword[<TraderCostID>],0")
		asm.add_instruction("mov dword[<TraderCostValue>],0")
		asm.add_instruction("ljmp [<CommandReturn>]")

		asm.add_label("CommandTraderSell:")
		asm.add_instruction("push 0")
		asm.add_instruction("push 0")
		asm.add_instruction("push 0")
		asm.add_instruction("push dword[<TraderCostValue>]")
		asm.add_instruction("push 0")
		asm.add_instruction("push [<TraderCostID>]")
		asm.add_instruction("push 1")
		asm.add_instruction("push 0")
		asm.add_instruction("push D")
		asm.add_instruction("mov {ecx},d")
		asm.add_instruction("xor {edx},{edx}")
		asm.add_instruction(f"call {self.get_value('Transaction')}")
		asm.add_instruction("add {esp},24")
		asm.add_instruction("mov dword[<TraderCostID>],0")
		asm.add_instruction("mov dword[<TraderCostValue>],0")
		asm.add_instruction("ljmp [<CommandReturn>]")

		asm.add_label("CommandSalvage:")
		asm.add_instruction("push {eax}")
		asm.add_instruction("push {ecx}")
		asm.add_instruction("push {ebx}")
		asm.add_instruction(f"mov {{ebx}},{self.get_value('SalvageGlobal')}")
		asm.add_instruction("mov {ecx},dword[{eax}+4]")
		asm.add_instruction("mov dword[{ebx}],{ecx}")
		asm.add_instruction("add {ebx},4")
		asm.add_instruction("mov {ecx},dword[{eax}+8]")
		asm.add_instruction("mov dword[{ebx}],{ecx}")
		asm.add_instruction("mov {ebx},dword[{eax}+4]")
		asm.add_instruction("push {ebx}")
		asm.add_instruction("mov {ebx},dword[{eax}+8]")
		asm.add_instruction("push {ebx}")
		asm.add_instruction("mov {ebx},dword[{eax}+c]")
		asm.add_instruction("push {ebx}")
		asm.add_instruction(f"call {self.get_value('Salvage')}")
		asm.add_instruction("add {esp},C")
		asm.add_instruction("pop {ebx}")
		asm.add_instruction("pop {ecx}")
		asm.add_instruction("pop {eax}")
		asm.add_instruction("ljmp [<CommandReturn>]")

		asm.add_label("CommandChangeTarget:")
		asm.add_instruction("xor {edx},{edx}")
		asm.add_instruction("push {edx}")
		asm.add_instruction("mov {eax},dword[{eax}+4]")
		asm.add_instruction("push {eax}")
		asm.add_instruction(f"call {self.get_value('ChangeTarget')}")
		asm.add_instruction("add {esp},8")
		asm.add_instruction("ljmp [<CommandReturn>]")

		asm.add_label("CommandMakeAgentArray:")
		asm.add_instruction("mov {eax},dword[{eax}+4]")
		asm.add_instruction("xor {ebx},{ebx}")
		asm.add_instruction("xor {edx},{edx}")
		asm.add_instruction("mov {edi},[<AgentCopyBase>]")

		asm.add_label("AgentCopyLoopStart:")
		asm.add_instruction("inc {ebx}")
		asm.add_instruction(f"cmp {{ebx}},dword[{self.get_value('MaxAgents')}]")
		asm.add_instruction("jge [<AgentCopyLoopExit>]")
		asm.add_instruction("mov {esi},dword[<AgentBase>]")
		asm.add_instruction("lea {esi},dword[{esi}+{ebx}*4]")
		asm.add_instruction("mov {esi},dword[{esi}]")
		asm.add_instruction("test {esi},{esi}")
		asm.add_instruction("jz [<AgentCopyLoopStart>]")
		asm.add_instruction("cmp {eax},0")
		asm.add_instruction("jz [<CopyAgent>]")
		asm.add_instruction("cmp {eax},dword[{esi}+9C]")
		asm.add_instruction("jnz [<AgentCopyLoopStart>]")

		asm.add_label("CopyAgent:")
		asm.add_instruction("mov {ecx},1C0")
		asm.add_instruction("clc")
		asm.add_instruction("repe movsb")
		asm.add_instruction("inc {edx}")
		asm.add_instruction("jmp [<AgentCopyLoopStart>]")

		asm.add_label("AgentCopyLoopExit:")
		asm.add_instruction(f"mov dword[{self.get_value('AgentCopyCount')}],{{edx}}")
		asm.add_instruction("ljmp [<CommandReturn>]")

		asm.add_label("CommandMove:")
		asm.add_instruction("lea {eax},dword[{eax}+4]")
		asm.add_instruction("push {eax}")
		asm.add_instruction(f"call {self.get_value('Move')}")
		asm.add_instruction("pop {eax}")
		asm.add_instruction("ljmp [<CommandReturn>]")

		asm.add_label("CommandEnterMission:")
		asm.add_instruction("push dword[{eax}+4]")
		asm.add_instruction(f"call {self.get_value('EnterMission')}")
		asm.add_instruction("add {esp},4")
		asm.add_instruction("ljmp [<CommandReturn>]")

		asm.add_label("CommandSetDifficulty:")
		asm.add_instruction("push dword[{eax}+4]")
		asm.add_instruction(f"call {self.get_value('SetDifficulty')}")
		asm.add_instruction("add {esp},4")
		asm.add_instruction("ljmp [<CommandReturn>]")


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
		self.proc_memory = ProcessMemory(proc.pid)
		self.proc_memory.memory_open()

		# check if scanner has already been injected, do not inject again if already present
		self.mem_base = proc.base_address + ADDRESS_SCAN_PTR_OFFSET
		scan_ptr_existing = self.proc_memory.memory_read(self.mem_base)
		
		if scan_ptr_existing == 0:
			self.scan_buffer = MemoryBuffer()
			self._build_scan_payload()
			scan_remote_addr = self.proc_memory.allocate_memory(self.scan_buffer.asm_offset + self.scan_buffer.storage_label_offset)
			self.scan_base = scan_remote_addr
			self.scan_inject_base = self.scan_base + self.scan_buffer.storage_label_offset
			print(f"ScanBase -> 0x{self.scan_base:08X}")
			print(f"ScanInjectBase -> 0x{self.scan_inject_base:08X}")
			self._assemble_payload(self.scan_base)
			print("Payload:")
			print(self.scan_buffer.buffer.hex())
			self.proc_memory.write_buffer(self.scan_inject_base, self.scan_buffer)
			self.proc_memory.memory_write(self.mem_base, self.scan_inject_base)
			print(f"Injected Scan Payload at 0x{self.scan_inject_base:08X}")
			self.scanner_injected = True

		else:
			print(f"Scanner already injected at 0x{scan_ptr_existing:08X}")

		scan_ptr_exists_after_inject = self.proc_memory.memory_read(self.mem_base)
		if scan_ptr_exists_after_inject and not self.scanner_injected:
			self.scan_base = scan_ptr_exists_after_inject
		print(f"Found ScanPointerBase at 0x{scan_ptr_exists_after_inject:08X}")
		
		# execute remote thread for Scanner
		# print(f"PROC BASE ADDRESS: {self.proc.base_address:08X}")
		self._execute_remote_thread()

		# after remote thread ends free up memory
		# self.proc_memory.free_allocated_memory(self.scan_base)
		# print("Memory freed.")
		# self.scanner_injected = False

		# # read in scanned values from scanner payload
		self._read_scan_values()
		print("SAVED VALUES")
		print(self.saved_values)
		self.proc_memory.free_allocated_memory(self.scan_base)
		print("Memory freed!")

		# check if modify payload has already been injected, do not inject again if already present
		# modify_ptr_addr = ADDRESS_BASE_MODIFY_MEMORY
		# modify_ptr_existing = self.proc_memory.memory_read(modify_ptr_addr)
		
		# if modify_ptr_existing == 0:
		# 	self.modify_buffer = MemoryBuffer()
		# 	self._build_modify_payload()
		# 	modify_remote_addr = self.proc_memory.allocate_memory(len(self.modify_buffer.buffer))
		# 	self.modify_base = modify_remote_addr
		# 	print(f"ModifyBase -> {self.modify_base}")
		# 	self._assemble_payload(self.modify_base, payload_type="modify")
		# 	print("Payload at MainProc:")
		# 	print(self.modify_buffer.buffer[self.modify_buffer.labels["MainProc"]:].hex())
		# 	# self.proc_memory.write_buffer(modify_remote_addr, self.modify_buffer)
		# 	# self.proc_memory.memory_write(modify_ptr_addr, modify_remote_addr)
		# 	# print(f"Injected Modify Payload at 0x{self.modify_base:08X}")
		# 	# self._read_modify_values()
		# 	self.proc_memory.free_allocated_memory(self.modify_base)
		# 	print("Modify Memory freed.")
		# else:
		# 	raise OSError("Modify Buffer already injected? Not sure how...")
		
		# # save references at a higher level to prevent bloat from constantly retrieving from dictionaries
		# self._save_references()

		# # insert function detours into process memory
		# self._write_detour("MainStart", "MainProc")
		# self._write_detour("TraderHookStart", "TraderHookProc")
		# self._write_detour("RenderingMod", "RenderingModProc")
		# self._write_detour("DialogLogStart", "DialogLogProc")

		# # Set MaxMemory for the process
		# self.proc_memory.set_max_memory()
		# print(f"Initialized with process: {self.proc.title} (PID: {self.proc.pid})")
		# self.initialized = True

