"""

Process Scanning module for ProjectPotato


"""
#stdlib
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
						self.matches.append(
							Process(
								pid=proc.info["pid"], 
								name=name, 
								exe=proc.info.get("exe", ""),
								hwnd=hwnd,
								title=title
							)
						)
			
			except (psutil.NoSuchProcess, psutil.AccessDenied):
				continue
		

	def get_matches(self) -> List[Process]:
		"""returns list of matching processes"""
		return self.matches


	def get_character_names(self) -> dict[str, Process]:
		"""

		returns dictionary of key = logged character name with value = relevant Process struct
		
		"""
		results = {}
		for proc in self.matches:
			results[proc.name] = proc
		return results


	def get_process_by_name(self, name: str) -> Process | None:
		"""
		
		returns Process struct associated with a given character name
		
		"""
		for proc in self.matches:
			if proc.title == name:
				return proc
		return None
