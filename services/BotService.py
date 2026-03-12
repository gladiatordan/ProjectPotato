"""

Project Potato BotService module

"""
#stdlib
import time

#mylib
from core.database import DatabaseContext
from core.service import Service


class BotService(Service):
    def __init__(self, inbound, outbound, account_name):
        super().__init__(inbound, outbound)
        self.account_name = account_name
        self.api = GWAPY()

    def run(self):
        self.info(f"BotService starting for {self.account_name}")
        self.api.initialize(self.account_name)
        
        while True:
            try:
                # 1. Check inbound queue for stop commands
                if not self.inbound.empty():
                    msg = self.inbound.get()
                    if msg.get("action") == "STOP":
                        break
                
                # 2. Main Bot Loop Logic (Read memory, decide action, sleep)
                # context = self.api.game_cxt.get_game_cxt()
                time.sleep(0.05) # Prevent CPU starvation
                
            except Exception as e:
                self.error(f"BotService crash: {e}")
                break