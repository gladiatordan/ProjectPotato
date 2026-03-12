"""

Project Potato GUIService module

"""
#stdlib
import sys
import os
import queue
from Qt import QtWidgets, QtCore

#mylib
from core.service import Service
from gui.main_window import MainWindow


class GUIService(Service):
	def handle_ui_action(self, payload: dict):
		self.info(f"UI Action requested: {payload['action']}")
		self._send_message({
			"dest": "MAIN", 
			"source": "GUI",
			"payload": payload
		})

	def process_inbound_queue(self):
		if not self.inbound: return
		try:
			while True:
				msg = self.inbound.get_nowait()
				# Process messages from other services (e.g., updating UI state)
		except queue.Empty:
			pass
	
	def load_stylesheet(self):
		"""Loads the custom QSS theme file."""
		qss_path = os.path.join(os.path.dirname(__file__), "..", "gui", "style.qss")
		try:
			with open(qss_path, "r") as f:
				self.app.setStyleSheet(f.read())
			self.debug("Custom stylesheet loaded successfully.")
		except FileNotFoundError:
			self.warning(f"Stylesheet not found at {qss_path}. Falling back to default theme.")

	def run(self):
		self.app = QtWidgets.QApplication(sys.argv)
		
		# Load and apply the QSS theme before rendering the window
		self.load_stylesheet()
		
		self.window = MainWindow()
		
		# (Optional) Tag the settings button so our CSS can apply alternative styling to it
		# self.window.launcher_tab.btn_settings.setObjectName("btn_settings")
		
		self.window.launcher_tab.action_requested.connect(self.handle_ui_action)
		self.window.show()

		self.queue_timer = QtCore.QTimer()
		self.queue_timer.timeout.connect(self.process_inbound_queue)
		self.queue_timer.start(100)

		sys.exit(self.app.exec())