"""

ProjectPotato memory module


"""
#stdlib
import ctypes
import ctypes.wintypes as wintypes
from ctypes import ARRAY
import struct

#mylib
from .scanner import FileScanner


PROCESS_ALL_ACCESS 			= 0x1F0FFF              # process open access rights
MEM_COMMIT					= 0x1000				# commit memory
MEM_RESERVE					= 0x2000				# reserve memory
PAGE_EXECUTE_READWRITE  	= 0x40
HIGH_PRIORITY_CLASS			= 0x80
NORMAL_PRIORITY_CLASS		= 0x20
BELOW_NORMAL_PRIORITY_CLASS = 0x4000
IDLE_PRIORITY_CLASS			= 0x40


class MemoryBuffer:
	"""
	
	Buffer class to be written to processes
	
	"""
	def __init__(self, data=None):
		"""
		
		Initializes the memory buffer with optional initial data.

		:param data: Initial memory data as bytes.
		
		"""
		self.buffer = bytearray(data) if data else bytearray()
		self.asm_size = 0
		self.asm_offset = 0
		self.storage_labels = {}
		self.labels = {}
		self.jumps = {}
		self.storage_label_offset = 0

	def reset_asm_state(self) -> None:
		"""Resets the assembler-specific state"""
		self.asm_size = 0
		self.asm_offset = 0

	def read(self, address: int, size: int) -> bytes:
		"""
		Reads a sequence of bytes from the buffer.

		 :param address: Starting address (offset) in the buffer.
		 :param size: Number of bytes to read.
		
		:return: Bytes read from the buffer.
		"""
		return bytes(self.buffer[address:address + size])

	def write(self, address: int, data: bytes) -> None:
		"""
		Writes a sequence of bytes to the buffer's specified address

		 :param address: Starting address (offset) in the buffer.
		 :param data: Data to write as bytes.
		
		"""
		try:
			end_address = address + len(data)
		except Exception as e:
			raise TypeError(f"{address} -> {data}")
		if end_address > len(self.buffer):
			# make buffer bigger if it's too small
			self.buffer.extend([0] * (end_address - len(self.buffer)))
		# write to buffer
		self.buffer[address:end_address] = data
		# adjust asm_size so it's inline when assembling
		self.asm_size = max(self.asm_size, len(self.buffer))

	def delete_bytes(self, address: int, size: int) -> None:
		del self.buffer[address:address + size]

	def read_int(self, address: int, size: int = 4, signed: bool = False, big_endian=False) -> int:
		"""
		Reads an integer value from the buffer.

         :param address: Starting address (offset) in the buffer.
         :param size: Size of the integer in bytes (default is 4 for 32-bit integers).
         :param signed: Whether to interpret the integer as signed.

        :return: Integer value read from the buffer.
		"""
		data = self.read(address, size)
		# print(data)
		fmt = {
			1: "b" if signed else "B",
			2: "h" if signed else "H",
			4: "i" if signed else "I"
		}[size]
		prefix = ">" if big_endian else "<"
		fmt = prefix + fmt
		return struct.unpack(fmt, data)[0]

	def write_int(self, address, value, size=4, byteorder="little"):
		"""
		Writes an integer value to the buffer. DOES NOT INCREMENT asm_offset!

		 :param address: Starting address (offset) in the buffer.
		 :param value: Integer value to write.
		 :param size: Size of the integer in bytes (default is 4 for 32-bit integers).

		"""
		is_signed = False
		if value < 0:
			is_signed = True
		self.write(address, value.to_bytes(size, byteorder=byteorder, signed=is_signed))

	def resolve_label(self, pos: int, address: int, size=4):
		"""
		Overrides a symbolic label in the buffer with its resolved address (used only at runtime)

		 :param address: Starting address (offset) in the buffer.
		 :param value: Address to replace 0xDEADBEEF with
		 :param size: Size of the integer in bytes (default is 4 for 32-bit addresses).

		"""
		self.buffer[pos:pos+4] = address.to_bytes(4, byteorder="little")

	def resolve_ptr(self, base_address, offsets):
		"""
		Resolves a multi-level pointer.

		 :param base_address: The base address of the pointer.
		 :param offsets: A list of offsets to dereference.

		:return: The final resolved address.
		"""
		address = base_address

		for offset in offsets:
			address = self.read_int(address) + offset

		return address


class ProcessMemory:
	"""
	
	Instance used when dealing with memory of a target process
	
	
	"""
	def __init__(self, pid):
		self._kernel32 = ctypes.WinDLL("kernel32.dll", use_last_error=True)
		self._psapi = ctypes.WinDLL("psapi.dll", use_last_error=True)
		self.pid = pid																		# ProcessID
		self.base_address = 0																# Base Address of Process
		self._proc = self._kernel32.OpenProcess(PROCESS_ALL_ACCESS, False, self.pid)		# ProcessHandle
		self._pe_path = self._get_module_filename()
		print(f"BASE ADDR -> {hex(self.base_address)}")
		

	def _get_module_filename(self):
		GetModuleFileNameExW = self._psapi.GetModuleFileNameExW
		GetModuleFileNameExW.argtypes = [
			wintypes.HANDLE, 
			wintypes.HMODULE,
			wintypes.LPWSTR,
			wintypes.DWORD
		]
		GetModuleFileNameExW.restype = wintypes.DWORD

		h_module = wintypes.HMODULE()
		cb_needed = wintypes.DWORD()
		enum_modules = self._psapi.EnumProcessModules
		enum_modules.argtypes = [
			wintypes.HANDLE,
			ctypes.POINTER(wintypes.HMODULE),
			wintypes.DWORD,
			ctypes.POINTER(wintypes.DWORD)
		]
		enum_modules.restype = wintypes.BOOL

		if not enum_modules(self._proc, ctypes.byref(h_module), ctypes.sizeof(h_module), ctypes.byref(cb_needed)):
			raise OSError(f"EnumProcessModules failed with error -> {ctypes.get_last_error()}")
		self.base_address = h_module.value		
		fname_buffer_len = 260
		fname_buffer = ctypes.create_unicode_buffer(fname_buffer_len)
		if not GetModuleFileNameExW(self._proc, h_module, fname_buffer, fname_buffer_len):
			raise OSError(f"GetModuleFileNameExW failed with error -> {ctypes.get_last_error()}")

		return fname_buffer.value


	def memory_open(self) -> None:
		"""opens handle to the instance's given process"""
		self._proc = self._kernel32.OpenProcess(PROCESS_ALL_ACCESS, False, self.pid)


	def memory_close(self) -> None:
		"""closes handle to the instance's given process"""
		if self._proc:
			# close handle
			self._kernel32.CloseHandle(self._proc)
			# set self._proc back to None so that we aren't trying anything against a closed handle
			self._proc = None
	

	def write_binary(self, address: int, hex_string: str) -> None:
		"""writes binary string to given address of current process handle"""
		if not self._proc:
			self.memory_open()
		
		data = bytes.fromhex(hex_string)
		size = len(data)
		self._kernel32.WriteProcessMemory(self._proc, address, data, size, None)


	def memory_write(self, address: int, data: int, ctype_type=ctypes.c_uint32) -> None:
		"""writes uint32 block to the given address of current process handle"""
		if not self._proc:
			self.memory_open()
		
		buffer = ctype_type(data)
		self._kernel32.WriteProcessMemory(self._proc, address, ctypes.byref(buffer), ctypes.sizeof(buffer), None)
		
	
	def memory_read(self, address: int, ctype_type=ctypes.c_uint32) -> int:
		"""reads from the given address of current process handle"""
		if not self._proc:
			self.memory_open()
		buffer = ctype_type()
		self._kernel32.ReadProcessMemory(self._proc, address, ctypes.byref(buffer), ctypes.sizeof(buffer), None)
		return buffer.value
	
	def memory_read_struct(self, address: int, ctype_type=ctypes.c_uint32) -> ctypes.Structure:
		if not self._proc:
			self.memory_open()
		buffer = ctype_type()
		self._kernel32.ReadProcessMemory(self._proc, address, ctypes.byref(buffer), ctypes.sizeof(buffer), None)
		return buffer

	def memory_read_gw_array(self, hdr: ctypes.Structure, arr_type: ctypes.Structure):
		"""
		Reads a known address in memory for a specific type of GWArray and transcribes based on type

		 :param address:		Address of memory to read
		 :param hdr:			GWArray structure header instance
		 :param arr_type:		custom Structure instance type to use
		
		"""
		arr = ARRAY(arr_type, hdr.m_size)
		return self._kernel32.ReadProcessMemory(self._proc, hdr.m_buffer, ctypes.byref(arr), ctypes.sizeof(arr), None)


	def memory_read_array(self, address: int, size_offset: int = 0) -> list[int]:
		"""attempts to read array at given address + offset of the current process handle"""
		array_size = self.memory_read(address + size_offset, ctypes.c_uint32)
		base_ptr = self.memory_read(address, ctypes.c_void_p)

		if array_size <= 0 or base_ptr == 0:
			# we didn't find anything, return empty array/list
			return []
		
		buffer_type = ctypes.c_void_p * array_size
		buffer = buffer_type()

		self._kernel32.ReadProcessMemory(self._proc, base_ptr, ctypes.byref(buffer), ctypes.sizeof(buffer), None)
		return [ptr for ptr in buffer if ptr]
	
	def swap_endian(self, hex_str: str) -> str:
		"""swaps endianness of given hex string"""
		assert len(hex_str) == 8, "Hex String must be length 8"
		return hex_str[6:8] + hex_str[4:6] + hex_str[2:4] + hex_str[0:2]
	

	def clear_memory(self) -> None:
		"""clears working memory of current process handle"""
		if not self._proc:
			self.memory_open()
		self._kernel32.SetProcessWorkingSetSize(self._proc, -1, -1)


	def set_max_memory(self, mem_size: int = 157286400) -> None:
		"""sets working memory set size of current process handle"""
		if not self._proc:
			self.memory_open()
		self._kernel32.SetProcessWorkingSetSizeEx(self._proc, 1, mem_size, 6)

	def set_process_priority(self, priority=NORMAL_PRIORITY_CLASS):
		get_priority = self._kernel32.GetPriorityClass
		get_priority.argtypes = [wintypes.HANDLE]
		get_priority.restype = wintypes.DWORD

		current_priority = get_priority(self._proc)
		# only reset process priority to NORMAL if process has been marked as IDLE or BELOW_NORMAL
		if current_priority in (IDLE_PRIORITY_CLASS, BELOW_NORMAL_PRIORITY_CLASS):
			result = self._kernel32.SetPriorityClass(self._proc, priority)
			if not result:
				raise ctypes.WinError(f"Received an error when attempting to set process priority: {ctypes.get_last_error()}")

	def allocate_memory(self, size: int, protect: int = PAGE_EXECUTE_READWRITE) -> int:
		"""
		
		Allocates memory in the target process using VirtualAllocEx.

		 :param size: The size of the memory block to allocate.
		 :param protect: Memory protection desired (default: PAGE_EXECUTE_READWRITE)

		:return: Address of the allocated memory in the remote process.
		"""
		if not self._proc:
			self.memory_open()
		
		VirtualAllocEx = self._kernel32.VirtualAllocEx
		VirtualAllocEx.restype = wintypes.LPVOID
		VirtualAllocEx.argtypes = [
			wintypes.HANDLE,		# Process Handle
			wintypes.LPVOID,		# VOID Pointer
			ctypes.c_size_t,		# dwSize
			wintypes.DWORD,			# flAllocationType
			wintypes.DWORD			# flProtect
		]

		address = VirtualAllocEx(self._proc, None, size, MEM_COMMIT, protect)
		print(f"address for VirtualAllocEx given at -> 0x{address:X}")
		if not address:
			raise OSError("VirtualAllocEx failed.")
		
		entry_point = ctypes.cast(address, ctypes.c_void_p).value
		print(f"entry point saved as -> 0x{entry_point:X}")
		return entry_point

	def free_allocated_memory(self, address: int, size: int = 0, free_type: int = 0x8000) -> bool:
		"""
		Frees memory in the target process using VirtualFreeEx that was previously allocated via VirtualAllocEx

		 :param address: The base address of the memory block to free.
		 :param size: The size of the memory block. Use 0 if freezing the entire region
		 :param free_type: The type of free operation. Default is MEM_RELEASE (0x8000)
		
		"""
		if not self._proc:
			self.memory_open()

		VirtualFreeEx = self._kernel32.VirtualFreeEx
		VirtualFreeEx.restype = wintypes.BOOL
		VirtualFreeEx.argtypes = [
			wintypes.HANDLE,		# Process Handle
			wintypes.LPVOID,		# lpStartAddress
			ctypes.c_size_t,		# dwSize
			wintypes.DWORD,			# dwFreeType
		]

		success = VirtualFreeEx(self._proc, ctypes.c_void_p(address), size, free_type)

		if not success:
			err = ctypes.get_last_error()
			raise OSError(f"VirtualFreeEx failed at 0x{address:08X}, error code {err}")

	def write_buffer(self, address: int, mem_buffer: MemoryBuffer) -> None:
		"""
		Writes the contents of a MemoryBuffer instance into the remote process at the given address.

		 :param address: Address in remote provess memory where data should be written.
		 :param mem_buffer: A MemoryBuffer instance containing assembled code/data
		
		"""
		if not self._proc:
			self.memory_open()

		buffer_len = len(mem_buffer.buffer)
		buffer_data = bytes(mem_buffer.buffer)

		result = self._kernel32.WriteProcessMemory(self._proc, ctypes.c_void_p(address), ctypes.c_char_p(buffer_data), buffer_len, None)

		if not result:
			err = ctypes.get_last_error()
			print(f"Error received from WriteProcessMemory -> {err}")
			raise OSError(f"WriteProcessMemory failed at 0x{address:X}")
