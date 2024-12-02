"""

ProjectPotato memory module


"""
#stdlib
import struct



class MemoryBuffer:
    """
    
    class containing the memory buffer to be injected into the GW client
    
    """
    def __init__(self, data=None):
        """
        Initializes the memory buffer with optional initial data.
        
         :param data: Initial memory data as bytes.

        """
        self.buffer = bytearray(data) if data else bytearray()
        self.asm_size = 0
        self.asm_offset = 0
        self.labels = {}


    def reset_asm_state(self):
        """
        Resets the assembler-specific state.

        """
        self.asm_size = 0
        self.asm_offset = 0


    def read(self, address, size):
        """
        Reads a sequence of bytes from the buffer.
        
         :param address: Starting address (offset) in the buffer.
         :param size: Number of bytes to read.
        
        :return: Bytes read from the buffer.
        """
        return bytes(self.buffer[address:address + size])


    def write(self, address, data):
        """
        Writes data to the buffer at the specified address.

         :param address: Starting address (offset) in the buffer.
         :param data: Data to write as bytes.

        """
        end_address = address + len(data)
        if end_address > len(self.buffer):
            self.buffer.extend([0] * (end_address - len(self.buffer)))
        self.buffer[address:end_address] = data
        self.asm_size = max(self.asm_size, len(self.buffer))


    def read_int(self, address, size=4, signed=False):
        """
        Reads an integer value from the buffer.

         :param address: Starting address (offset) in the buffer.
         :param size: Size of the integer in bytes (default is 4 for 32-bit integers).
         :param signed: Whether to interpret the integer as signed.
        
        :return: Integer value read from the buffer.
        """
        data = self.read(address, size)
        fmt = {1: "b" if signed else "B", 2: "h" if signed else "H", 4: "i" if signed else "I"}[size]
        return struct.unpack(fmt, data)[0]


    def write_int(self, address, value, size=4):
        """
        Writes an integer value to the buffer.

         :param address: Starting address (offset) in the buffer.
         :param value: Integer value to write.
         :param size: Size of the integer in bytes (default is 4 for 32-bit integers).

        """
        fmt = {1: "b", 2: "h", 4: "i"}[size]
        data = struct.pack(fmt, value)
        self.write(address, data)


    def resolve_ptr(self, base_address, offsets):
        """
        Resolves a multi-level pointer.

         :param base_address: The base address of the pointer.
         :param offsets: A list of offsets to dereference.

        :return: The final resolved address.
        """
        address = base_address
        for offset in offsets:
            address = self.read_int(address) + offset
        return address