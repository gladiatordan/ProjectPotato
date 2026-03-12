"""

Project Potato LogService module

"""
#stdlib

#mylib
from core.service import Service
import queue


class LogService(Service):
    def run(self):
        print("[LogService] Started.")
        while True:
            try:
                msg = self.inbound.get()
                # Here you would route to a FileHandler. For now, print to console.
                print(f"[LOG] {msg.get('source', 'UNKNOWN')}: {msg.get('message')}")
            except Exception as e:
                print(f"LogService Error: {e}")