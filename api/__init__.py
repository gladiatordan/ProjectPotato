"""

Main entry point for the entire GWAPY API.


usage: from api import GWAPY as gwapy


"""
from core import *
from elevate import elevate



class GWAPY(Core):
	def __init__(self):
		super().__init__(target_exe="Gw.exe", target_root="C:\\Users\\Daniel\\Desktop\\GW")
		# targets = self.get_processes()

		# print("Found targets for gw.exe")
		# print(targets)

	
	def initialize(self, target_title):
		self._initialize(target_title)



def main():
	# elevate()
	gw = GWAPY()
	gw.initialize("Potato Sin One")
	


if __name__ == "__main__":
	main()