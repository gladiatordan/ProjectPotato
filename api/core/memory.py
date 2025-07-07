"""

ProjectPotato memory module


"""
#stdlib
import ctypes
import ctypes.wintypes as wintypes



PROCESS_ALL_ACCESS = 0x1F0FFF              # process open access rights



class ProcessMemory:
	"""
	
	Singleton used when dealing with any memory-related functionality in the API
	
	
	"""
	_instance = None

	def __new__(cls, *args, **kwargs):
		if cls._instance is None:
			cls._instance = super().__new__(cls)
		return cls._instance


	def __init__(self, pid):
		self._kernel32 = ctypes.WinDLL("kernel32.dll")
		self.pid = pid   	# ProcessID
		self._proc = None	# Process Handle
	

	def memory_open(self) -> None:
		"""opens handle to the instance's given process"""
		self._proc = self._kernel32.OpenProcess(PROCESS_ALL_ACCESS, False, pid)

	
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
		
		buf = ctype_type(data)
		self._kernel32.WriteProcessMemory(self._proc, address, ctypes.byref(buffer), ctypes.sizeof(buf), None)
		
	
	def memory_read(self, address: int, ctype_type=ctypes.c_uint32) -> int:
		"""reads from the given address of current process handle"""
		if not self._proc:
			self.memory_open()
		
		buffer = ctype_type()
		self._kernel32.ReadProcessMemory(self._proc, address, ctypes.byref(buffer), ctypes.sizeof(buffer), None)
		return buffer.value
	

	def memory_read_ptr(self, address: int, offsets: list[int], ctype_type=ctypes.c_uint32) -> tuple[int, int] | tuple[int, None]:
		"""attempts to dereference and read a given pointer with any given offsets of current process handle"""
		if not self._proc:
			self.memory_open()

		# apply all offsets except last
		for offset in offsets[:-1]:
			address += offset
			buffer = ctype_type()
			self._kernel32.ReadProcessMemory(self._proc, address, ctypes.byref(buffer), ctypes.sizeof(buffer), None)
			address = buffer.value
			if address == 0:
				# return nothing because we're clearly off
				return (0, None)
		
		# add final offset
		address += offsets[-1]
		buffer = ctype_type()
		self._kernel32.ReadProcessMemory(self._proc, address, ctypes.byref(buffer), ctypes.sizeof(buffer), None)
		return (address, buffer.value)


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
	

	def memory_read_array_ptr(self, address: int, offsets: list[int], size_offset: int) -> list[int]:
		"""attempts to dereference an array pointer at a given address + offset chain of the current process handle"""
		base_address, _ = self.memory_read_ptr(address, offsets, ctypes.c_void_p)
		return self.memory_read_array(base_address, size_offset)
	

	def swap_endian(self, hex_str: str) -> str:
		"""swaps endianness of given hex string"""
		assert len(hex_str) == 8, "Hex String must be length 8"
		return hex_str[6:8] + hex_str[4:6] + hex_str[2:4] + hex_str[0:2]
	

	def clear_memory(self) -> None:
		"""clears working memory of current process handle"""
		if not self._proc:
			self.memory_open()
		self._kernel32.SetProcessWorkingSetSize(self._proc, -1, -1)


	def set_max_memory(self, mem_size: int = 157_286_400) -> None:
		"""sets working memory set size of current process handle"""
		if not self._proc:
			self.memory_open()
		self._kernel32.SetProcessWorkingSetSizeEx(self._proc, 1, mem_size, 6)