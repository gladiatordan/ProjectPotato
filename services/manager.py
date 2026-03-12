#stdlib
import multiprocessing
import time

#mylib
from .LogService import LogService
from .DatabaseService import DatabaseService
from .GUIService import GUIService
from .GameService import GameService
from .DiscordService import DiscordService
from .BotService import BotService


class ServiceManager:
    def __init__(self):
        self.manager_queue = multiprocessing.Queue() # All services send outbound messages here
        
        # Service Inbound Queues
        self.queues = {
            "LOG": multiprocessing.Queue(),
            "DB": multiprocessing.Queue(),
            "GUI": multiprocessing.Queue(),
            "GAME": multiprocessing.Queue(),
            # "DISCORD": multiprocessing.Queue()
        }

        # Initialize core services
        self.services = {
            "LOG": LogService(self.queues["LOG"], self.manager_queue),
            "DB": DatabaseService(self.queues["DB"], self.manager_queue),
            "GUI": GUIService(self.queues["GUI"], self.manager_queue),
            "GAME": GameService(self.queues["GAME"], self.manager_queue),
            # "DISCORD": DiscordService(self.queues["DISCORD"], self.manager_queue)
        }
        
        self.processes = {}
        self.running = False

    def start_all(self):
        self.running = True
        
        # Spawn all core processes
        for name, service in self.services.items():
            p = multiprocessing.Process(target=service.run, name=f"{name}_Process")
            p.daemon = True # Ensure child processes die if the main process dies
            p.start()
            self.processes[name] = p
            
        print("[Main] All core services started. Beginning routing loop...")
        self._routing_loop()

    def stop_all(self):
        self.running = False
        for name, p in self.processes.items():
            p.terminate()
            p.join()

    def _routing_loop(self):
        """Monolithic message router."""
        while self.running:
            try:
                msg = self.manager_queue.get()
                dest = msg.get("dest")
                
                if dest in self.queues:
                    self.queues[dest].put(msg)
                elif dest == "MAIN":
                    # Handle actions meant specifically for the ServiceManager (e.g., spawning BotServices)
                    self._handle_main_action(msg)
                else:
                    print(f"[Main Router] Unknown destination '{dest}' for message: {msg}")
            except Exception as e:
                print(f"[Main Router] Error: {e}")

    def _handle_main_action(self, msg):
        payload = msg.get("payload", {})
        action = payload.get("action")
        
        if action == "SPAWN_BOT":
            # Logic to spawn a new BotService up to the 25 limit would go here
            pass