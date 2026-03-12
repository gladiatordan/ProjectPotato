"""

Project Potato GUIService module

"""
#stdlib
import sys
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

    def run(self):
        self.app = QtWidgets.QApplication(sys.argv)
        self.window = MainWindow()
        self.window.launcher_tab.action_requested.connect(self.handle_ui_action)
        self.window.show()

        self.queue_timer = QtCore.QTimer()
        self.queue_timer.timeout.connect(self.process_inbound_queue)
        self.queue_timer.start(100)

        sys.exit(self.app.exec())