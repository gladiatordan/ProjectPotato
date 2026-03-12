"""

Project Potato GameService module

"""
#stdlib

#mylib
from core.service import Service
import time

class GameService(Service):
    def run(self):
        print("[GameService] Started.")
        while True:
            try:
                if not self.inbound.empty():
                    msg = self.inbound.get()
                    # Handle process launching, window title changes, etc.
                
                # Poll psutil for game process states here non-blockingly
                time.sleep(1)
            except Exception as e:
                self.error(f"GameService Error: {e}")