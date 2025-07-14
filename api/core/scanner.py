"""

Process Scanning module for ProjectPotato


"""
#stdlib
import win32gui
import win32process
from dataclasses import dataclass
from typing import List
import ctypes
import ctypes.wintypes as wintypes

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

							base_addr = ctypes.cast(h_mod, ctypes.c_void_p).value - 0x1000
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



class MemoryScanner:
	"""
	
	Singleton class which scans given process memory for specific inputted patterns
	
	"""
	def __init__(self):
		self.proc_mem = None
		