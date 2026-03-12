"""

ProjectPotato Entry Point

"""
#stdlib
import multiprocessing
import sys

#mylib
from services.manager import ServiceManager


def main():
    # Required for Windows multiprocessing to freeze support and not recursively spawn
    multiprocessing.freeze_support()
    
    manager = ServiceManager()
    try:
        manager.start_all()
    except KeyboardInterrupt:
        print("Shutting down ProjectPotato...")
        manager.stop_all()
        sys.exit(0)

if __name__ == "__main__":
    main()