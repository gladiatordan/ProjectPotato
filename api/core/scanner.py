"""

Process Scanning module for ProjectPotato


"""
#stdlib
import os
import mmap
import struct
import ctypes
import ctypes.wintypes as wintypes
import win32gui
import win32process
from dataclasses import dataclass
from typing import List

#3rdpartylib
import psutil




@dataclass
class Process:
	pid: int
	name: str
	exe: str
	hwnd: int
	title: str
	base_address: int
	base_address_hex: str



class ProcessScanner:
	"""
	
	Class that scans for processes of a given executable type
	
	"""
	def __init__(self, target_exe: str, class_filter: str = None, title_filter: str = None):
		self.target_exe = target_exe.lower()
		self.matches: List[Process] = []
		self.class_filter = class_filter
		self.title_filter = title_filter

	def scan_for_process(self) -> None:
		"""Scans for all running processes matching the executable name"""
		self.matches.clear()

		pid_to_hwnd: dict[int, int] = {}

		def enum_windows_callback(hwnd, _):
			if not win32gui.IsWindowVisible(hwnd):
				return True
			
			_, pid = win32process.GetWindowThreadProcessId(hwnd)
			class_name = win32gui.GetClassName(hwnd)
			title = win32gui.GetWindowText(hwnd)

			# filters if necessary
			if self.class_filter and class_name != self.class_filter:
				return True
			
			if self.title_filter and self.title_filter.lower() not in title.lower():
				return True
			
			# store first matching visible window for a PID
			if pid not in pid_to_hwnd:
				pid_to_hwnd[pid] = hwnd
			
			return True

		win32gui.EnumWindows(enum_windows_callback, None)
		
		for proc in psutil.process_iter(['pid', 'name', 'exe']):
			try:
				name = proc.info["name"]
				if name and name.lower() == self.target_exe:
					pid = proc.info["pid"]
					if pid in pid_to_hwnd:
						hwnd = pid_to_hwnd[pid]
						title = win32gui.GetWindowText(hwnd).strip()
						base_addr = 0
						base_addr_hex = ""
						h_proc = ctypes.windll.kernel32.OpenProcess(0x0410, False, pid)
						if h_proc:
							h_mod = wintypes.HMODULE()
							count = wintypes.DWORD()
							ctypes.windll.psapi.EnumProcessModules(h_proc, ctypes.byref(h_mod), ctypes.sizeof(h_mod), ctypes.byref(count))
							ctypes.windll.kernel32.CloseHandle(h_proc)

							base_addr = ctypes.cast(h_mod, ctypes.c_void_p).value + 0x1000
							base_addr_hex = f"{base_addr:08X}"
						
						if not base_addr and base_addr_hex:
							raise OSError(f"Could not read base address from ProcessID: {pid}")
						# print(f"Adding {title} to matches")
						self.matches.append(
							Process(
								pid=proc.info["pid"], 
								name=name, 
								exe=proc.info.get("exe", ""),
								hwnd=hwnd,
								title=title,
								base_address=base_addr,
								base_address_hex=base_addr_hex,
							)
						)
			
			except (psutil.NoSuchProcess, psutil.AccessDenied):
				continue

	def get_scanned_processes(self) -> dict[str, Process]:
		"""

		returns dictionary of key = logged character name with value = relevant Process struct

		"""
		if not self.matches:
			self.scan_for_process()

		result = {}
		# print(self.matches)
		for match in self.matches:
			result[match.title] = match
		return result

	def get_process_by_title(self, name: str) -> Process | None:
		"""
		
		returns Process struct associated with a given process or None if it couldn't find one in the scanned list
		
		"""
		if not self.matches:
			self.scan_for_process()
		
		for proc in self.matches:
			# print(f"Proc: {proc}")
			if proc.title == name:
				# print(f"Found proc: {proc}")
				return proc
		return None


class FileScanner:
	"""

	Class instance which handles PE header parsing and static disk scanning of PE sections.
	Used to resolve assertion strings and generate opcode patterns.
	
	"""
	def __init__(self, pe_path: str):
		self.pe_path = pe_path
		self.image_base = 0
		self.sections = {}
		self._cached_sections = {}
		self.scanned_values = {}
		self._map_file()
		self._parse_headers()
		self._cache_sections()
		self.close()

	def _map_file(self):
		self.fd = os.open(self.pe_path, os.O_RDONLY)
		self.size = os.path.getsize(self.pe_path)
		self.mapped = mmap.mmap(self.fd, self.size, access=mmap.ACCESS_READ)

	def get_scanned_values(self):
		return self.scanned_values

	def _parse_headers(self):
		# DOS Header is 64 bytes
		dos_magic = self.mapped[:2]
		if dos_magic != b'MZ':
			raise ValueError("Invalid DOS header magic")
		
		e_lfanew = struct.unpack_from("<I", self.mapped, 0x3C)[0]
		nt_signature = self.mapped[e_lfanew:e_lfanew + 4]
		if nt_signature != b'PE\x00\x00':
			raise ValueError("Invalid PE signature")
		
		file_header_offset = e_lfanew + 4
		machine, num_sections, _, _, _, size_opt_header = struct.unpack_from("<HHIIIH", self.mapped, file_header_offset)
		if machine != 0x14C:
			raise ValueError(f"Only 32-bit PE files supported!")
		
		opt_header_offset = file_header_offset + 20
		magic = struct.unpack_from("<H", self.mapped, opt_header_offset)[0]
		if magic != 0x10b:
			raise ValueError(f"Not a PE32 optional header!")
		
		self.image_base = struct.unpack_from("<I", self.mapped, opt_header_offset + 28)[0]
		print(f"IMAGE BASE -> 0x{self.image_base:08X}")
		section_offset = opt_header_offset + size_opt_header
		for i in range(num_sections):
			entry = self.mapped[section_offset + i * 40:section_offset + (i + 1) * 40]
			name = entry[0:8].rstrip(b'\x00').decode(errors="ignore")
			vaddr, vsize, raw_ptr = struct.unpack_from("<III", entry, 12)
			self.sections[name] = (vaddr, vsize, raw_ptr)

	def _cache_sections(self):
		for name, (_, size, raw_ptr) in self.sections.items():
			self._cached_sections[name] = self.mapped[raw_ptr:raw_ptr + size]
	
	def _clear_cache(self):
		self._cached_sections = {}
		
	def read_section(self, section_name: str) -> bytes:
		if section_name not in self._cached_sections:
			if section_name not in self.sections:
				raise ValueError(f"Section {section_name} not found")
			_, size, raw_ptr = self.sections[section_name]
			self._cached_sections[section_name] = self.mapped[raw_ptr:raw_ptr + size]
		return self._cached_sections[section_name]
	
	def find_in_section(self, section_name: str, pattern: bytes, mask: str, offset: int = 0) -> int:
		section = self.read_section(section_name)
		start, _ = self.sections[section_name]
		pat_len = len(mask)
		first = pattern[0:1]
		for i in range(len(section) - pat_len):
			if section[i:i+1] != first:
				continue

			match = True
			for j in range(pat_len):
				if mask[j] == "x" and section[i + j] != pattern[j]:
					match = False
					break
			
			if match:
				return self.image_base + start + i + offset
		return 0
	
	def find_assertions(self, patterns: dict[str, list[str]]) -> dict[str, int]:
		"""
		Scans memory starting from self.base_address for strings matching provided patterns and captures pointers.

		:param base: Starting address of the scan range.
		:param patterns: Dictionary mapping keys to [file_hint, substring, return_type], where:
			- file_hint (str): Currently unused, may point to a section name or source file.
			- substring (str): Substring to match within dereferenced strings.
			- return_type (str): "ptr" to return the dereferenced address, otherwise base address.
		:param size: Size of the memory region to scan.
		:return: Dictionary mapping each pattern key to the matching address (int).
		"""
		for key, (file_hint, message, line_number, offset) in patterns.items():
			res = self.find_assertion(file_hint, message, line_number, offset)
			if res != 0:
				self.scanned_values[key] = res
				print(f"Found scan value {key} at addr 0x{res:08X} (offset = {hex(offset)})")
			else:
				print(f"Could not find scan value for {key}")
		

	def find_assertion(self, file_hint: str, message: str, line_number: int, offset: int = 0) -> int:
		"""
		Build function signature based on data retrieved from .rdata then looks for that pattern in .text
		
		"""
		msg_bytes = message.encode()
		file_bytes = file_hint.encode()
		msg_offset = self.read_section(".rdata").find(msg_bytes)
		file_offset = self.read_section(".rdata").find(file_bytes)
		if msg_offset == -1 or file_offset == -1:
			return 0
		
		msg_va = self.image_base + self.sections[".rdata"][0] + msg_offset
		file_va = self.image_base + self.sections[".rdata"][0] + file_offset

		# encode push (optional line number), mov edx, mov ecx
		pattern = bytearray()
		mask = ""
		adjust = 0
		if line_number:
			if line_number <= 0xFF:
				pattern += b"\x6A" + struct.pack("B", line_number)
				mask += "xx"
				adjust = 3
			else:
				pattern += b"\x68" + struct.pack("<I", line_number)
				mask += "xxxx"
				adjust = 0
		
		offset += adjust
		pattern += b"\xBA" + struct.pack("<I", file_va)
		mask += "x" + "x" * 4
		pattern += b"\xB9" + struct.pack("<I", msg_va)
		mask += "x" + "x" * 4

		# Scan .text for encoded pattern
		return self.find(pattern, offset)
	
	def find_in_range(self, pattern: bytes, offset: int, start: int, end: int) -> int:
		"""
		Scans the mapped PE file's section contents for a byte pattern with mask within a virtual address range.

		 :param pattern: 	Byte pattern to search for
		 :param mask: 		String mask, e.g. "xx?x" ("x" means match byte, "?" means wildcard)
		 :param offset:		Integer offset to apply to match result
		 :param start:		Virtual memory start address.
		 :param end:		Virtual memory end address.
		:return:			Virtual memory address of match plus offset, or 0 if not found.
		
		NOTE: This scanner always assumes exact match and does not use a match/wildcard mask!
		"""
		section_name = None
		for name, (vaddr, size, _) in self.sections.items():
			va_start = self.image_base + vaddr
			va_end = va_start + size
			if va_start <= start <= va_end:
				section_name = name
				break

		if not section_name:
			return 0
		section = self.read_section(section_name)
		section_start = self.image_base + self.sections[section_name][0]
		search_offset = start - section_start
		search_end = min(len(section), end - section_start)
		index = section.find(pattern, search_offset, search_end)
		if index != -1:
			return section_start + index + offset
		return 0
	
	def find(self, pattern: bytes, offset: int = 0, section: str = ".text") -> int:
		"""
		Wrapper to scan within a named section using a pattern and mask.

		 :param pattern:	Byte pattern to search for.
		 :param offset:		Offset to apply to final match address.
		 :param section:	Section name (e.g. ".text" | ".rdata", etc)
		:return:			Virtual address of match plus offset, or 0 if not found
		
		NOTE: This scanner always assumes exact match and does not use a match/wildcard mask!
		"""
		if section not in self.sections:
			print("we hit this for some reason")
			return 0

		start = self.image_base + self.sections[section][0]
		end = start + self.sections[section][1]
		# print(f"PATTERN -> {pattern.hex()}, OFFSET -> {offset}, START -> {start}, END -> {end}")
		return self.find_in_range(pattern, offset, start, end)
	
	def scan_for_values(self, scan_values: dict):
		for k in scan_values:
			pattern, offset = scan_values[k]
			res = self.find(bytes.fromhex(pattern), offset)
			if res != 0:
				print(f"Found scan value {k} at addr 0x{res:08X} (offset = {hex(offset)})")
				self.scanned_values[k] = res
			else:
				print(f"Could not find scan value for {k}")

	def close(self):
		self.mapped.close()
		os.close(self.fd)
	