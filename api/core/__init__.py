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

	

	Usage

	

	
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


	def get_scanned_address(self, label: str) -> int:
		"""Retrieve a previously-saved memory address by label."""
		if label not in self.saved_values:
			raise KeyError(f"Missing scanned address for label: '{label}'")
		return self.saved_values[label]


	def set_value(self, label: str, value: int) -> None:
		"""Saves a memory address or value by label."""
		self.saved_values[label] = value


	def get_value(self, label: str) -> int:
		"""Returns a memory address or value by label"""
		return self.saved_values[label]
	

	def _read_scan_values(self):
		"""Reads known offsets from the scan base and updates self.saved_values with the labels"""
		pmem = self.proc_memory
		base = self.scan_base

		for i, label in enumerate(self.scan_buffer.labels):
			scan_offset = scan_offsets[label]
			offset = i * 8
			label_addr = pmem.memory_read(base + offset)
			mem_offset = label_addr + scan_offset
			label_final = label.replace("Scan", "")
			
			if label_addr == 0:
				raise RuntimeError(f"No address found for Label: {label}")
			
			print(f"Address for '{label_final}' found at {label_addr:X}")
			
			if label == "ScanAgentArray":
				self.set_value("AgentBase", pmem.memory_read(mem_offset))
				print(f"AgentBase set to {mem_offset}")
				self.set_value("MaxAgents", mem_offset + 0x8)
				print(f"MaxAgents set to {mem_offset + 0x8:X}")
			
			elif label == "ScanMyID":
				self.set_value("MyID", pmem.memory_read(mem_offset))
				print(f"MyID set to {mem_offset:X}")

			elif label == "ScanBaseOffset":
				self.set_value("PacketLocation", pmem.memory_read(mem_offset))
				print(f"PacketLocation set to {mem_offset:X}")
			
			elif label == "ScanEngine":
				self.set_value("MainStart", pmem.memory_read(mem_offset))
				self.set_value("MainReturn", pmem.memory_read(mem_offset + 0x5))
				print(f"MainStart set to {mem_offset:X}")
				print(f"MainReturn set to {mem_offset + 0x5:X}")

			elif label == "ScanRenderFunc":
				self.set_value("RenderingMod", pmem.memory_read(mem_offset))
				self.set_value("RenderingModReturn", pmem.memory_read(mem_offset + 0xA))
				print(f"MainStart set to {mem_offset:X}")
				print(f"MainReturn set to {mem_offset + 0xA:X}")

			elif label == "ScanTargetLog":
				self.set_value("TargetLogStart", pmem.memory_read(mem_offset))
				self.set_value("TargetLogReturn", pmem.memory_read(mem_offset + 0x5))
				print(f"TargetLogStart set to {mem_offset:X}")
				print(f"TargetLogReturn set to {mem_offset + 0x5:X}")
			
			elif label == "ScanSkillLog":
				self.set_value("SkillLogStart", pmem.memory_read(mem_offset))
				self.set_value("SkillLogReturn", pmem.memory_read(mem_offset + 0x5))
				print(f"SkillLogStart set to {mem_offset:X}")
				print(f"SkillLogReturn set to {mem_offset + 0x5:X}")
			
			elif label == "ScanSkillCancelLog":
				self.set_value("SkillCancelLogStart", pmem.memory_read(mem_offset))
				self.set_value("SkillCancelLogReturn", pmem.memory_read(mem_offset + 0x6))
				print(f"SkillCancelLogStart set to {mem_offset:X}")
				print(f"SkillCancelLogReturn set to {mem_offset + 0x6:X}")
			
			elif label == "ScanChatLog":
				self.set_value("ChatLogStart", pmem.memory_read(mem_offset))
				self.set_value("ChatLogReturn", pmem.memory_read(mem_offset + 0x6))
				print(f"ChatLogStart set to {mem_offset:X}")
				print(f"ChatLogReturn set to {mem_offset + 0x6:X}")
			
			elif label == "ScanTraderHook":
				self.set_value("TraderHookStart", pmem.memory_read(mem_offset))
				self.set_value("TraderHookReturn", pmem.memory_read(mem_offset + 0x5))
				print(f"TraderHookStart set to {mem_offset:X}")
				print(f"TraderHookReturn set to {mem_offset + 0x5:X}")
			
			elif label == "ScanDialogLog":
				self.set_value("DialogLogStart", pmem.memory_read(mem_offset))
				self.set_value("DialogLogReturn", pmem.memory_read(mem_offset + 0x5))
				print(f"DialogLogStart set to {mem_offset:X}")
				print(f"DialogLogReturn set to {mem_offset + 0x5:X}")
			
			elif label == "ScanStringFilter1":
				self.set_value("StringFilter1Start", pmem.memory_read(mem_offset))
				self.set_value("StringFilter1Return", pmem.memory_read(mem_offset + 0x5))
				print(f"StringFilter1Start set to {mem_offset:X}")
				print(f"StringFilter1Return set to {mem_offset + 0x5:X}")
			
			elif label == "ScanStringFilter2":
				self.set_value("StringFilter2Start", pmem.memory_read(mem_offset))
				self.set_value("StringFilter2Return", pmem.memory_read(mem_offset + 0x5))
				print(f"StringFilter2Start set to {mem_offset:X}")
				print(f"StringFilter2Return set to {mem_offset + 0x5:X}")
			
			elif label == "ScanStringLog":
				self.set_value("StringLogStart", pmem.memory_read(mem_offset))
				print(f"StringLogStart set to {mem_offset:X}")

			else:
				self.set_value(label_final, pmem.memory_read(mem_offset))
				print(f"{label_final} set to {mem_offset:X}")

	
	def _read_modify_values(self):
		"""Reads known offsets from the modify base address and updates self.saved_values with the labels"""
		pmem = self.proc_memory
		base = self.modify_base

		for label in self.scan_buffer.labels:
			offset = self.modify_buffer[label]
			resolved_addr = self.modify_base + offset
			self.saved_values[label] = resolved_addr
			print(f"Saved {label} with address -> {resolved_addr:X}")


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
		asm.add_label("ScanBasePointer:")
		asm.add_pattern(function_signatures["ScanBasePointer"])
		asm.add_label("ScanAgentBase:")
		asm.add_pattern(function_signatures["ScanAgentBase"])
		asm.add_label("ScanAgentBasePointer:")
		asm.add_pattern(function_signatures["ScanAgentBasePointer"])
		# asm.add_label("ScanAgentArray:")
		# asm.add_pattern(function_signatures["ScanAgentArray"])
		asm.add_label("ScanCurrentTarget:")
		asm.add_pattern(function_signatures["ScanCurrentTarget"])
		asm.add_label("ScanMyID:")
		asm.add_pattern(function_signatures["ScanMyId"])
		asm.add_label("ScanEngine:")
		asm.add_pattern(function_signatures["ScanEngine"])
		asm.add_label("ScanRenderFunc:")
		asm.add_pattern(function_signatures["ScanRenderFunc"])
		asm.add_label("ScanLoadFinished:")
		asm.add_pattern(function_signatures["ScanLoadFinished"])
		asm.add_label("ScanPostMessage:")
		asm.add_pattern(function_signatures["ScanPostMessage"])
		asm.add_label("ScanTargetLog:")
		asm.add_pattern(function_signatures["ScanTargetLog"])
		asm.add_label("ScanChangeTargetFunction:")
		asm.add_pattern(function_signatures["ScanChangeTargetFunction"])
		asm.add_label("ScanMoveFunction:")
		asm.add_pattern(function_signatures["ScanMoveFunction"])
		asm.add_label("ScanPing:")
		asm.add_pattern(function_signatures["ScanPing"])
		asm.add_label("ScanMapID:")
		asm.add_pattern(function_signatures["ScanMapID"])
		asm.add_label("ScanMapLoading:")
		asm.add_pattern(function_signatures["ScanMapLoading"])
		asm.add_label("ScanLoggedIn:")
		asm.add_pattern(function_signatures["ScanLoggedIn"])
		asm.add_label("ScanRegion:")
		asm.add_pattern(function_signatures["ScanRegion"])
		asm.add_label("ScanMapInfo:")
		asm.add_pattern(function_signatures["ScanMapInfo"])
		asm.add_label("ScanLanguage:")
		asm.add_pattern(function_signatures["ScanLanguage"])
		asm.add_label("ScanUseSkillFunction:")
		asm.add_pattern(function_signatures["ScanUseSkillFunction"])
		asm.add_label("ScanPacketSendFunction:")
		asm.add_pattern(function_signatures["ScanPacketSendFunction"])
		asm.add_label("ScanBaseOffset:")
		asm.add_pattern(function_signatures["ScanBaseOffset"])
		asm.add_label("ScanWriteChatFunction:")
		asm.add_pattern(function_signatures["ScanWriteChatFunction"])
		asm.add_label("ScanSkillLog:")
		asm.add_pattern(function_signatures["ScanSkillLog"])
		asm.add_label("ScanSkillCompleteLog:")
		asm.add_pattern(function_signatures["ScanSkillCompleteLog"])
		asm.add_label("ScanSkillCancelLog:")
		asm.add_pattern(function_signatures["ScanSkillCancelLog"])
		asm.add_label("ScanChatLog:")
		asm.add_pattern(function_signatures["ScanChatLog"])
		asm.add_label("ScanSellItemFunction:")
		asm.add_pattern(function_signatures["ScanSellItemFunction"])
		asm.add_label("ScanStringLog:")
		asm.add_pattern(function_signatures["ScanStringLog"])
		asm.add_label("ScanStringFilter1:")
		asm.add_pattern(function_signatures["ScanStringFilter1"])
		asm.add_label("ScanStringFilter2:")
		asm.add_pattern(function_signatures["ScanStringFilter2"])
		asm.add_label("ScanActionFunction:")
		asm.add_pattern(function_signatures["ScanActionFunction"])
		asm.add_label("ScanActionBase:")
		asm.add_pattern(function_signatures["ScanActionBase"])
		asm.add_label("ScanSkillBase:")
		asm.add_pattern(function_signatures["ScanSkillBase"])
		asm.add_label("ScanUseHeroSkillFunction:")
		asm.add_pattern(function_signatures["ScanUseHeroSkillFunction"])
		asm.add_label("ScanTransactionFunction:")
		asm.add_pattern(function_signatures["ScanTransactionFunction"])
		asm.add_label("ScanBuyItemFunction:")
		asm.add_pattern(function_signatures["ScanBuyItemFunction"])
		asm.add_label("ScanBuyItemBase:")
		asm.add_pattern(function_signatures["ScanBuyItemBase"])
		asm.add_label("ScanRequestQuoteFunction:")
		asm.add_pattern(function_signatures["ScanRequestQuoteFunction"])
		asm.add_label("ScanTraderFunction:")
		asm.add_pattern(function_signatures["ScanTraderFunction"])
		asm.add_label("ScanTraderHook:")
		asm.add_pattern(function_signatures["ScanTraderHook"])
		asm.add_label("ScanSleep:")
		asm.add_pattern(function_signatures["ScanSleep"])
		asm.add_label("ScanSalvageFunction:")
		asm.add_pattern(function_signatures["ScanSalvageFunction"])
		asm.add_label("ScanSalvageGlobal:")
		asm.add_pattern(function_signatures["ScanSalvageGlobal"])
		asm.add_label("ScanIncreaseAttributeFunction:")
		asm.add_pattern(function_signatures["ScanIncreaseAttributeFunction"])
		asm.add_label("ScanDecreaseAttributeFunction:")
		asm.add_pattern(function_signatures["ScanDecreaseAttributeFunction"])
		asm.add_label("ScanSkillTimer:")
		asm.add_pattern(function_signatures["ScanSkillTimer"])
		asm.add_label("ScanClickToMoveFix:")
		asm.add_pattern(function_signatures["ScanClickToMoveFix"])
		asm.add_label("ScanZoomStill:")
		asm.add_pattern(function_signatures["ScanZoomStill"])
		asm.add_label("ScanZoomMoving:")
		asm.add_pattern(function_signatures["ScanZoomMoving"])
		asm.add_label("ScanBuildNumber:")
		asm.add_pattern(function_signatures["ScanBuildNumber"])
		asm.add_label("ScanChangeStatusFunction:")
		asm.add_pattern(function_signatures["ScanChangeStatusFunction"])
		asm.add_label("ScanCharslots:")
		asm.add_pattern(function_signatures["ScanCharSlots"])
		asm.add_label("ScanReadChatFunction:")
		asm.add_pattern(function_signatures["ScanReadChatFunction"])
		asm.add_label("ScanDialogLog:")
		asm.add_pattern(function_signatures["ScanDialogLog"])
		asm.add_label("ScanTradeHack:")
		asm.add_pattern(function_signatures["ScanTradeHack"])
		asm.add_label("ScanClickCoords:")
		asm.add_pattern(function_signatures["ScanClickCoords"])

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
		asm.add_label("CallBackHandle/4")
		asm.add_label("QueueCounter/4")
		asm.add_label("SkillLogCounter/4")
		asm.add_label("ChatLogCounter/4")
		asm.add_label("ChatLogLastMsg/4")
		asm.add_label("MapIsLoaded/4")
		asm.add_label("NextStringType/4")
		asm.add_label("EnsureEnglish/4")
		asm.add_label("TraderQuoteID/4")
		asm.add_label("TraderCostID/4")
		asm.add_label("TraderCostValue/4")
		asm.add_label("DisableRendering/4")
		asm.add_label(f"QueueBase/{256 * self.get_value("QueueSize")}")
		asm.add_label(f"TargetLogBase/{4 * self.get_value("TargetLogSize")}")
		asm.add_label(f"SkillLogBase/{16 * self.get_value("SkillLogSize")}")
		asm.add_label(f"StringLogBase/{256 * self.get_value("StringLogSize")}")
		asm.add_label(f"ChatLogBase/{512 * self.get_value("ChatLogSize")}")
		asm.add_label("LastDialogID/4")
		asm.add_label("AgentCopyCount/4")
		asm.add_label(f"AgentCopyBase/{0x1C0 * 256}")

		# CreateMain
		asm.add_label("MainProc:")
		# asm.add_instruction("nop x")
		asm.add_instruction("pushad")
		asm.add_instruction("mov {eax},dword[<EnsureEnglish>]")
		asm.add_instruction("test {eax},{eax}")
		asm.add_instruction("jz [<MainMain>]")
		asm.add_instruction("mov {ecx},dword[<BasePointer>]")
		asm.add_instruction("mov {ecx},dword[{ecx}+18]")
		asm.add_instruction("mov {ecx},dword[{ecx}+18]")
		asm.add_instruction("mov {ecx},dword[{ecx}+194]")
		asm.add_instruction("mov {al},byte[{ecx}+4f]")
		asm.add_instruction("cmp {al},f")
		asm.add_instruction("ja [<MainMain>]")
		asm.add_instruction("mov {ecx},dword[{ecx}+4c]")
		asm.add_instruction("mov {al},byte[{ecx}+3f]")
		asm.add_instruction("cmp {al},f")
		asm.add_instruction("ja [<MainMain>]")
		asm.add_instruction("mov {eax},dword[{ecx}+40]")
		asm.add_instruction("test {eax},{eax}")
		asm.add_instruction("jz [<MainMain>]")

		asm.add_label("MainMain:")
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

		# TraderHook
		asm.add_label("TraderHookProc:")
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
		asm.add_instruction("ljmp [<TraderHookReturn>]")

		# StringLog
		asm.add_label("StringLogProc:")
		asm.add_instruction("pushad")
		asm.add_instruction("mov {eax},dword[<NextStringType>]")
		asm.add_instruction("test {eax},{eax}")
		asm.add_instruction("jz [<StringLogExit>]")
		asm.add_instruction("cmp {eax},1")
		asm.add_instruction("jnz [<StringLogFilter2>]")
		asm.add_instruction("mov {eax},dword[{ebp}+37c]")
		asm.add_instruction("jmp [<StringLogRangeCheck>]")

		asm.add_label("StringLogFilter2:")
		asm.add_instruction("cmp {eax},2")
		asm.add_instruction("jnz [<StringLogExit>]")
		asm.add_instruction("mov {eax},dword[{ebp}+338]")

		asm.add_label("StringLogRangeCheck:")
		asm.add_instruction("mov dword[<NextStringType>],0")
		asm.add_instruction("cmp {eax},0")
		asm.add_instruction("jbe [<StringLogExit>]")
		asm.add_instruction("cmp {eax},[<StringLogSize>]")
		asm.add_instruction("jae [<StringLogExit>]")
		asm.add_instruction("shl {eax},8")
		asm.add_instruction("add {eax},[<StringLogBase>]")
		asm.add_instruction("xor {ebx},{ebx}")

		asm.add_label("StringLogCopyLoop:")
		asm.add_instruction("mov {dx},word[{ecx}]")
		asm.add_instruction("mov word[{eax}],{dx}")
		asm.add_instruction("add {ecx},2")
		asm.add_instruction("add {eax},2")
		asm.add_instruction("inc {ebx}")
		asm.add_instruction("cmp {ebx},80")
		asm.add_instruction("jz [<StringLogExit>]")
		asm.add_instruction("test {dx},{dx}")
		asm.add_instruction("jnz [<StringLogCopyLoop>]")

		asm.add_label("StringLogExit:")
		asm.add_instruction("popad")
		asm.add_instruction("mov {esp},{ebp}")
		asm.add_instruction("pop {ebp}")
		asm.add_instruction("retn 10")

		# CreateRenderingMod
		asm.add_label("RenderingModProc:")
		asm.add_instruction("add {esp},4")
		asm.add_instruction("cmp dword[<DisableRendering>],1")
		asm.add_instruction("ljmp [<RenderingModReturn>]")

		# CreateCommands
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
		asm.add_instruction("call [<UseSkillFunction>]")
		asm.add_instruction("pop {eax}")
		asm.add_instruction("pop {edx}")
		asm.add_instruction("pop {ebx}")
		asm.add_instruction("pop {ecx}")
		asm.add_instruction("ljmp [<CommandReturn>]")

		asm.add_label("CommandMove:")
		asm.add_instruction("lea {eax},dword[{eax}+4]")
		asm.add_instruction("push {eax}")
		asm.add_instruction("call [<MoveFunction>]")
		asm.add_instruction("pop {eax}")
		asm.add_instruction("ljmp [<CommandReturn>]")

		asm.add_label("CommandChangeTarget:")
		asm.add_instruction("xor {edx},{edx}")
		asm.add_instruction("push {edx}")
		asm.add_instruction("mov {eax},dword[{eax}+4]")
		asm.add_instruction("push {eax}")
		asm.add_instruction("call [<ChangeTargetFunction>]")
		asm.add_instruction("pop {eax}")
		asm.add_instruction("pop {edx}")
		asm.add_instruction("ljmp [<CommandReturn>]")

		asm.add_label("CommandPacketSend:")
		asm.add_instruction("lea {edx},dword[{eax}+8]")
		asm.add_instruction("push {edx}")
		asm.add_instruction("mov {ebx},dword[{eax}+4]")
		asm.add_instruction("push {ebx}")
		asm.add_instruction("mov {eax},dword[<PacketLocation>]")
		asm.add_instruction("push {eax}")
		asm.add_instruction("call [<PacketSendFunction>]")
		asm.add_instruction("pop {eax}")
		asm.add_instruction("pop {ebx}")
		asm.add_instruction("pop {edx}")
		asm.add_instruction("ljmp [<CommandReturn>]")

		asm.add_label("CommandChangeStatus:")
		asm.add_instruction("mov {eax},dword[{eax}+4]")
		asm.add_instruction("push {eax}")
		asm.add_instruction("call [<ChangeStatusFunction>]")
		asm.add_instruction("pop {eax}")
		asm.add_instruction("ljmp [<CommandReturn>]")

		asm.add_label("CommandWriteChat:")
		asm.add_instruction("push 0")
		asm.add_instruction("add {eax},4")
		asm.add_instruction("push {eax}")
		asm.add_instruction("call [<WriteChatFunction>]")
		asm.add_instruction("add {esp},8")
		asm.add_instruction("ljmp [<CommandReturn>]")

		asm.add_label("CommandSellItem:")
		asm.add_instruction("mov {esi},{eax}")
		asm.add_instruction("add {esi},C")
		asm.add_instruction("push 0")
		asm.add_instruction("push 0")
		asm.add_instruction("push 0")
		asm.add_instruction("push dword[{eax}+4]")
		asm.add_instruction("push 0")
		asm.add_instruction("add {eax},8")
		asm.add_instruction("push {eax}")
		asm.add_instruction("push 1")
		asm.add_instruction("push 0")
		asm.add_instruction("push B")
		asm.add_instruction("call [<TransactionFunction>]")
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
		asm.add_instruction("call [<TransactionFunction>]")
		asm.add_instruction("add {esp},24")
		asm.add_instruction("ljmp [<CommandReturn>]")

		asm.add_label("CommandCraftItemEx:")
		asm.add_instruction("add {eax},4")
		asm.add_instruction("push {eax}")
		asm.add_instruction("add {eax},4")
		asm.add_instruction("push {eax}")
		asm.add_instruction("push 1")
		asm.add_instruction("push 0")
		asm.add_instruction("push 0")
		asm.add_instruction("mov {ecx},dword[<TradeID>]")
		asm.add_instruction("mov {ecx},dword[{ecx}]")
		asm.add_instruction("mov {edx},dword[{eax}+4]")
		asm.add_instruction("lea {ecx},dword[{ebx}+{ecx}*4]")
		asm.add_instruction("push {ecx}")
		asm.add_instruction("push 1")
		asm.add_instruction("push dword[{eax}+8]")
		asm.add_instruction("push dword[{eax}+C]")
		asm.add_instruction("call [<TraderFunction>]")
		asm.add_instruction("add {esp},24")
		asm.add_instruction("mov dword[<TraderCostID>],0")
		asm.add_instruction("ljmp [<CommandReturn>]")

		asm.add_label("CommandAction:")
		asm.add_instruction("mov {ecx},dword[<ActionBase>]")
		asm.add_instruction("mov {ecx},dword[{ecx}+c]")
		asm.add_instruction("add {ecx},A0")
		asm.add_instruction("push 0")
		asm.add_instruction("add {eax},4")
		asm.add_instruction("push {eax}")
		asm.add_instruction("push dword[{eax}+4]")
		asm.add_instruction("mov {edx},0")
		asm.add_instruction("call [<ActionFunction>]")
		asm.add_instruction("ljmp [<CommandReturn>]")

		asm.add_label("CommandUseHeroSkill:")
		asm.add_instruction("mov {ecx},dword[{eax}+8]")
		asm.add_instruction("push {ecx}")
		asm.add_instruction("mov {ecx},dword[{eax}+c]")
		asm.add_instruction("push {ecx}")
		asm.add_instruction("mov {ecx},dword[{eax}+4]")
		asm.add_instruction("push {ecx}")
		asm.add_instruction("call [<UseHeroSkillFunction>]")
		asm.add_instruction("add {esp},C")
		asm.add_instruction("ljmp [<CommandReturn>]")

		asm.add_label("CommandSendChat:")
		asm.add_instruction("lea {edx},dword[{eax}+4]")
		asm.add_instruction("push {edx}")
		asm.add_instruction("mov {ebx},11c")
		asm.add_instruction("push {ebx}")
		asm.add_instruction("mov {eax},dword[<PacketLocation>]")
		asm.add_instruction("push {eax}")
		asm.add_instruction("call [<PacketSendFunction>]")
		asm.add_instruction("pop {eax}")
		asm.add_instruction("pop {ebx}")
		asm.add_instruction("pop {edx}")
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
		asm.add_instruction("call [<RequestQuoteFunction>]")
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
		asm.add_instruction("call [<RequestQuoteFunction>]")
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
		asm.add_instruction("call [<TraderFunction>]")
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
		asm.add_instruction("call [<TransactionFunction>]")
		asm.add_instruction("add {esp},24")
		asm.add_instruction("mov dword[<TraderCostID>],0")
		asm.add_instruction("mov dword[<TraderCostValue>],0")
		asm.add_instruction("ljmp [<CommandReturn>]")

		asm.add_label("CommandSalvage:")
		asm.add_instruction("push {eax}")
		asm.add_instruction("push {ecx}")
		asm.add_instruction("push {ebx}")
		asm.add_instruction("mov {ebx},[<SalvageGlobal>]")
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
		asm.add_instruction("call [<SalvageFunction>]")
		asm.add_instruction("add {esp},C")
		asm.add_instruction("pop {ebx}")
		asm.add_instruction("pop {ecx}")
		asm.add_instruction("pop {eax}")
		asm.add_instruction("ljmp [<CommandReturn>]")

		asm.add_label("CommandCraftItemEx2:")
		asm.add_instruction("add {eax},4")
		asm.add_instruction("push {eax}")
		asm.add_instruction("add {eax},4")
		asm.add_instruction("push {eax}")
		asm.add_instruction("push 1")
		asm.add_instruction("push 0")
		asm.add_instruction("push 0")
		asm.add_instruction("mov {ecx},dword[<TradeID>]")
		asm.add_instruction("mov {ecx},dword[{ecx}]")
		asm.add_instruction("mov {edx},dword[{eax}+8]")
		asm.add_instruction("lea {ecx},dword[{ebx}+{ecx}*4]")
		asm.add_instruction("mov {ecx},dword[{ecx}]")
		asm.add_instruction("mov [{eax}+8],{ecx}")
		asm.add_instruction("mov {ecx},dword[<TradeID>]")
		asm.add_instruction("mov {ecx},dword[{ecx}]")
		asm.add_instruction("mov {ecx},dword[{ecx}+0xF4]")
		asm.add_instruction("lea {ecx},dword[{ecx}+{ecx}*2]")
		asm.add_instruction("lea {ecx},dword[{ebx}+{ecx}*4]")
		asm.add_instruction("mov {ecx},dword[{ecx}]")
		asm.add_instruction("mov [{eax}+C],{ecx}")
		asm.add_instruction("mov {ecx},{eax}")
		asm.add_instruction("add {ecx},8")
		asm.add_instruction("push {ecx}")
		asm.add_instruction("push 2")
		asm.add_instruction("push dword[{eax}+4]")
		asm.add_instruction("push 3")
		asm.add_instruction("call [<TransactionFunction>]")
		asm.add_instruction("add {esp},24")
		asm.add_instruction("mov dword[<TraderCostID>],0")
		asm.add_instruction("ljmp [<CommandReturn>]")

		asm.add_label("CommandIncreaseAttribute:")
		asm.add_instruction("mov {edx},dword[{eax}+4]")
		asm.add_instruction("push {edx}")
		asm.add_instruction("mov {ecx},dword[{eax}+8]")
		asm.add_instruction("push {ecx}")
		asm.add_instruction("call [<IncreaseAttributeFunction>]")
		asm.add_instruction("pop {ecx}")
		asm.add_instruction("pop {edx}")
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

		asm.add_label("CommandMakeAgentArray:")
		asm.add_instruction("mov {eax},dword[{eax}+4]")
		asm.add_instruction("xor {ebx},{ebx}")
		asm.add_instruction("xor {edx},{edx}")
		asm.add_instruction("mov {edi},[<AgentCopyBase>]")

		asm.add_label("AgentCopyLoopStart:")
		asm.add_instruction("inc {ebx}")
		asm.add_instruction("cmp {ebx},dword[<MaxAgents>]")
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
		asm.add_instruction("mov dword[<AgentCopyCount>],{edx}")
		asm.add_instruction("ljmp [<CommandReturn>]")

		asm.add_label("CommandSendChatPartySearch:")
		asm.add_instruction("lea {edx},dword[{eax}+4]")
		asm.add_instruction("push {edx}")
		asm.add_instruction("mov {ebx},4C")
		asm.add_instruction("push {ebx}")
		asm.add_instruction("mov {eax},dword[<PacketLocation>]")
		asm.add_instruction("push {eax}")
		asm.add_instruction("call [<PacketSendFunction>]")
		asm.add_instruction("pop {eax}")
		asm.add_instruction("pop {ebx}")
		asm.add_instruction("pop {edx}")
		asm.add_instruction("ljmp [<CommandReturn>]")

		# CreateDialogHook
		asm.add_label("DialogLogProc:")
		asm.add_instruction("push {ecx}")
		asm.add_instruction("mov {ecx},{esp}")
		asm.add_instruction("add {ecx},C")
		asm.add_instruction("mov {ecx},dword[{ecx}]")
		asm.add_instruction("mov dword[<LastDialogID>],{ecx}")
		asm.add_instruction("pop {ecx}")
		asm.add_instruction("mov {ebp},{esp}")
		asm.add_instruction("sub {esp},8")
		asm.add_instruction("ljmp [<DialogLogReturn>]")


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
		# Get original label address
		from_addr = self.saved_values[from_label]

		# Get Offset to apply to modify_base to find where the to_label r{esi}des in the modify payload
		to_offset = self.modify_buffer.labels[to_label]

		# Find to_addr by applying the offset to modify_base
		to_addr = self.modify_base + to_offset

		# Account for relative JMP instruction
		rel_offset = to_addr - from_addr - 5
		jmp_bytes = b'\E9' + struct.pack('<i', rel_offset)

		# Override the function Start address with our detour and pray that it's aligned :)
		self.proc_memory.write(from_addr, jmp_bytes)
		print(f"Detour for {from_label} at {from_addr:X} placed for {to_label} at {to_addr:X}")


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
			remote_addr = self.proc_memory.allocate_memory(self.scan_buffer.asm_offset + self.scan_buffer.storage_label_offset)
			self.scan_base = remote_addr + self.scan_buffer.storage_label_offset
			print(f"ScanBase -> 0x{self.scan_base:08X}")
			self._assemble_payload(self.scan_base)
			print("Payload:")
			print(self.scan_buffer.buffer.hex())
			self.proc_memory.write_buffer(self.scan_base, self.scan_buffer)
			self.proc_memory.memory_write(self.mem_base, self.scan_base)
			print(f"Injected Scan Payload at 0x{self.scan_base:08X}")
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
		self.proc_memory.free_allocated_memory(self.scan_base)
		print("Memory freed.")
		# self.scanner_injected = False

		# # read in scanned values from scanner payload
		# self._read_scan_values()

		# # add these for modify buffer to reference
		# self.set_value("QueueSize", SIZE_QUEUE)
		# self.set_value("SkillLogSize", SIZE_SKILL_LOG)
		# self.set_value("ChatLogSize", SIZE_CHAT_LOG)
		# self.set_value("TargetLogSize", SIZE_TARGET_LOG)
		# self.set_value("StringLogSize", SIZE_STRING_LOG)
		# self.set_value("CallbackEvent", SIZE_CALLBACK_EVENT)

		# # create asm payload to add function detours with our custom logic
		
		
		# check if modify payload has already been injected, do not inject again if already present
		# modify_ptr_addr = ADDRESS_BASE_MODIFY_MEMORY
		# modify_ptr_existing = self.proc_memory.memory_read(modify_ptr_addr)
		
		# if modify_ptr_existing == 0:
		# 	self.modify_buffer = MemoryBuffer()
		# 	self._build_modify_payload()
		# 	modify_remote_addr = self.proc_memory.allocate_memory(len(self.modify_buffer.buffer))
		# 	self.modify_base = modify_remote_addr
		# 	print(f"ModifyBase -> {self.modify_base}")
		# 	self._assemble_payload(self.modify_base)
		# 	print("Payload at MainProc:")
		# 	print(self.modify_buffer.buffer[self.modify_buffer.labels["MainProc"]:].hex())
		# 	self.proc_memory.write_buffer(modify_remote_addr, self.modify_buffer)
		# 	self.proc_memory.memory_write(modify_ptr_addr, modify_remote_addr)
		# 	print(f"Injected Modify Payload at 0x{self.modify_base:08X}")
		# 	self._read_modify_values()
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

