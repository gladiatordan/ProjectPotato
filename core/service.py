"""

ProjectPotato Service Module

"""
#stdlib
import multiprocessing

#mylib
from .core import Core


class Service(Core):
	"""
	
	Base Service Class to be inherited by any spawnable Service
	
	"""
	def __init__(self, inbound: multiprocessing.Queue=None, outbound: multiprocessing.Queue=None):
		self.inbound = inbound
		self.outbound = outbound
		super().__init__(inbound, outbound)
		self.running = False

	def _register(self):
		# TODO: implement this
		pass

	def _deregister(self):
		# TODO: implement this
		pass

	def stop(self):
		# TODO: implement this
		pass
	
	def run(self):
		# TODO: implement this
		pass