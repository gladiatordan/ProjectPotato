"""

ProjectPotato Core Module

Base classes for standardizing logging, configuration, and secret redaction.
Designed for Monolithic Multiprocessing.

"""
import json
import inspect
import multiprocessing


class Serializable:
	"""
	
	Base class that provides string representation with secret redaction.
	
	"""
	def __init__(self):
		pass

	def __str__(self):
		data = {}
		for k, v in self.__dict__.items():
			if k in self._redact_ or any(x in k.lower() for x in self._redact_):
				data[k] = "[REDACTED]"
			else:
				try:
					json.dumps(v)
					data[k] = v
				except TypeError, OverflowError:
					data[k] = str(v)
		
		return f"{self.__class__.__name__} Instance\n{json.dumps(data, indent=4, default=str)}"


class Core(Serializable):
	"""
	Base class for most objects in the framework.
	Builtin log message routing
	
	"""
	def __init__(self, inbound: multiprocessing.Queue=None, outbound: multiprocessing.Queue=None):
		self.mod = self._get_caller_module()
		self.id = self._get_id()
		self.inbound = inbound
		self.outbound = outbound
		super().__init__()

	def _generate_id(self):
		# TODO: IMPLEMENT THIS
		pass

	def _get_caller_module(self):
		"""
		Walks the stack to find the name of the subclass.
		"""
		try:
			frame = inspect.currentframe().f_back
			while frame:
				module = inspect.getmodule(frame)
				# skip Core module itself to find the caller
				if module and module.__name__ != __name__:
					return module.__name__.split('.')[-1]
				frame = frame.f_back
		except:
			pass
		return None
	
	def _send_message(self, message):
		if self.outbound:
			self.outbound.put(message)
	
	def _send_log(self, level, message):
		"""
		Internal helper to route logs via router message
		
		"""
		#TODO: ADD UUID AND MESSAGING LOGIC HERE
		msg = {
			"dest": "LOGS",
			"source": self.mod,
			"level": level,
			"message": message,
		} # NOTE: THIS IS A STUB, DO NOT USE!
		self._send_message(msg)

	def debug(self, message):
		self._send_log("DEBUG", message)

	def info(self, message):
		self._send_log("INFO", message)

	def warning(self, message):
		self._send_log("WARNING", message)
		
	def error(self, message):
		self._send_log("ERROR", message)

	def critical(self, message):
		self._send_log("CRITICAL", message)


