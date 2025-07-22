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
	

	def scan(self) -> None:
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
						print(f"Adding {title} to matches")
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
			self.scan()

		result = {}
		print(self.matches)
		for match in self.matches:
			result[match.title] = match
		return result


	def get_process_by_title(self, name: str) -> Process | None:
		"""
		
		returns Process struct associated with a given process or None if it couldn't find one in the scanned list
		
		"""
		if not self.matches:
			self.scan()
		
		for proc in self.matches:
			print(f"Proc: {proc}")
			if proc.title == name:
				print(f"Found proc: {proc}")
				return proc
		return None



class ProcessFileScanner:
	"""
	Class instance which handles PE header parsing and static disk scanning of .rdata/.text sections.
	Used to resolve assertion strings and generate opcode patterns.
	
	"""
	def __init__(self, pe_path: str):
		self.pe_path = pe_path
		self.image_base = 0
		self.sections = {}
		self._map_file()
		self._parse_headers()

	
	def _map_file(self):
		self.fd = os.open(self.pe_path, os.O_RDONLY)
		self.size = os.path.getsize(self.pe_path)
		self.mapped = mmap.mmap(self.fd, self.size, access=mmap.ACCESS_READ)


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

		section_offset = opt_header_offset + size_opt_header
		for i in range(num_sections):
			entry = self.mapped[section_offset + i * 40:section_offset + (i + 1) * 40]
			name = entry[0:8].rstrip(b'\x00').decode(errors="ignore")
			vaddr, vsize, raw_ptr = struct.unpack_from("<III", entry, 12)
			self.sections[name] = (raw_ptr, vsize)
		
	
	def read_section(self, section_name: str) -> bytes:
		if section_name not in self.sections:
			raise ValueError(f"Section {section_name} not found")
		start, size = self.sections[section_name]
		return self.mapped[start:start+size]
	

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


	def close(self):
		self.mapped.close()
		os.close(self.fd)
