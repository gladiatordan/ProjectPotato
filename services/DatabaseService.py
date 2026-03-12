"""

Project Potato DatabaseService module

"""
#stdlib

#mylib
from core.service import Service
from core.database import DatabaseContext

class DatabaseService(Service):
    def run(self):
        print("[DatabaseService] Started.")
        # Ensure DB is initialized for this process
        DatabaseContext.initialize()
        
        while True:
            try:
                msg = self.inbound.get()
                # Example: {"action": "UPDATE", "query": "...", "params": (...)}
                # Use DatabaseContext.cursor(commit=True) to write
            except Exception as e:
                self.error(f"DatabaseService Error: {e}")