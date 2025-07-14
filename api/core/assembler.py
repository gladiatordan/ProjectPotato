#stdlib
import re

#mylib
from .memory import MemoryBuffer



class Assembler:
	"""
	
	General Assembler class, encodes x86 asm instructions and adds them to a given MemoryBuffer instance
	
	"""
	def __init__(self, buffer: MemoryBuffer):
		self.buffer = buffer
		self.unresolved_labels = {}


	def _is_immediate(self, operand: str) -> bool:
		try:
			int(operand, 0)  # Auto-detects base: 0x... or decimal
			return True
		except ValueError:
			try:
				int(operand, 16)
				return True
			except ValueError:
				return False


	def _parse_immediate(self, value: str) -> int:
		if value.startswith("0x") or value.startswith("-0x"):
			return int(value, 16)
		return int(value, 10 if value.isdigit() or value.startswith("-") else 16)


	def _add_unresolved_label(self, label: str, add_to_payload: bool = True) -> None:
		if label not in self.unresolved_labels:
			self.unresolved_labels[label] = []
			print(f"Added new label type to unresolved labels: '{label}'")
		self.unresolved_labels[label].append(self.buffer.asm_offset)
		print(f"Added offset entry for label {label} at {self.buffer.asm_offset}")
		
		if add_to_payload:
			self.buffer.write_int(self.buffer.asm_offset, 0xDEADBEEF)
			# finally, increment asm_offset for newly inserted label
			self.buffer.asm_offset += 4


	def add_pattern(self, pattern: str) -> None:
		"""
		Adds a pattern to the buffer

		Formatted with 12-byte header and padded to 80 bytes total

		 :param pattern: Hexadecimal string pattern (wildcards not supported yet)
		
		"""
		byte_length = len(pattern) // 2

		length_hex_le = bytearray.fromhex(f"{byte_length:08X}")[::-1].hex()
		header = "00000000" + length_hex_le + "00000000"

		final_pattern = header + pattern
		final_pattern_b = bytes.fromhex(final_pattern)

		padding_len = 80 - len(final_pattern_b)
		final_pattern_b += b'\x00' * padding_len

		self.buffer.write(self.buffer.asm_offset, final_pattern_b)
		self.buffer.asm_offset += len(final_pattern_b)
		self.buffer.asm_size = max(self.buffer.asm_size, self.buffer.asm_offset)

		print(f"Added scan pattern ({byte_length} bytes), padded to {len(final_pattern_b)} bytes")
		

	def add_label(self, name: str) -> None:
		"""
		Sets a label in the buffer for reference.
		
		:param name: The name of the label.

		If a size expression is included (e.g. "Label/1024"), it reserves that many bytes.
		If no size expression is included, reserves 4 bytes for x86 address resolution.

		"""
		# register label at current offset for later resolution
		name = name.replace(":", "")
		pos = self.buffer.asm_offset
		self.buffer.labels[name] = pos
		
		# add the placeholder for label first
		# DO NOT ADD THE ACTUAL FUCKING LABEL TO THE BUFFER IF IT'S CALLED VIA THIS, YOU DOOFUS
		# self._add_unresolved_label(name, add_to_payload=False)
		print(f"Label {name} set at position {pos}")
		
		# check if size is explicitly included and add size - 4 bytes of padding if so
		size = 4
		padding_size = 0
		if "/" in name:
			size = int(name.split("/")[-1])
			print(f"{name} size: {size}")
			padding_size = 4 if size == 4 else size - 4
		
			# add size - 4 of byte padding to payload
			to_add = bytearray()
			to_add += b'\x00' * padding_size
			print(to_add)
			self.buffer.write(self.buffer.asm_offset, to_add)
		
			# if / is explicitly included then we need to adjust the asm_offset since we adding padded bytes
		print(f"ASM offset before: {self.buffer.asm_offset}")
		self.buffer.asm_offset += padding_size
		print(f"Added {padding_size} bytes of padding for Label '{name} for total size of {size}")
		print(f"ASM offset after: {self.buffer.asm_offset}")


	def _encode_jump(self, instruction: str) -> None:
		raise NotImplementedError(f"Jump not implemented yet: {instruction}")

	
	def _encode_arithmetic(self, instruction: str) -> None:
		raise NotImplementedError(f"Arithmetic not implemented yet: {instruction}")


	def _encode_mov(self, instruction: str) -> None:
		reg_code = {
			# 32-bit
			"eax": 0x0, "ecx": 0x1, "edx": 0x2, "ebx": 0x3,
			"esp": 0x4, "ebp": 0x5, "esi": 0x6, "edi": 0x7,

			# 16-bit
			"ax":  0x0, "cx":  0x1, "dx":  0x2, "bx":  0x3,
			"sp":  0x4, "bp":  0x5, "si":  0x6, "di":  0x7,

			# 8-bit
			"al":  0x0, "cl":  0x1, "dl":  0x2, "bl":  0x3,
			"ah":  0x4, "ch":  0x5, "dh":  0x6, "bh":  0x7,
		}

		patterns = [
			("reg_to_imm",				re.compile(r"mov\s+\{(\w+)}\s*,\s*(-?(?:0x[\da-fA-F]+|\d+))\s*$")),
			("reg_from_sib_label",		re.compile(r"mov\s+\{(\w+)}\s*,\s*dword\[\{(\w+)}\*(\d+)\+<([a-zA-Z_][\w]*)>\]\s*$")),
			("reg_from_mem_reg_reg",	re.compile(r"mov\s+\{(\w+)}\s*,\s*dword\[\{(\w+)}\+\{(\w+)}\]\s*$")),
			("reg_from_mem_disp", 		re.compile(r"mov\s+\{(\w+)}\s*,\s*(?:byte|word|dword)?\[\{(\w+)}\+(-?(?:0x[\da-fA-F]+|\d+|[a-fA-F\d]+))\]\s*$")),
			("reg_from_label_dword",	re.compile(r"mov\s+\{(\w+)}\s*,\s*dword\[<([a-zA-Z_][\w]*)>\]\s*$")),
			("reg_from_label_plain",	re.compile(r"mov\s+\{(\w+)}\s*,\s*\[<([a-zA-Z_][\w]*)>\]\s*$")),
			("reg_from_mem_reg",		re.compile(r"mov\s+\{(\w+)}\s*,\s*(?:dword|word|byte)?\[\{(\w+)}\]\s*$")),
			("reg_to_reg",				re.compile(r"mov\s+\{(\w+)}\s*,\s*\{(\w+)}\s*$")),
			("reg_to_label",			re.compile(r"mov\s+\{(\w+)}\s*,\s*<([a-zA-Z_][\w]*)>\s*$")),
			("mem_reg_to_imm",			re.compile(r"mov\s+dword\[\{(\w+)}\]\s*,\s*(-?(?:0x[\da-fA-F]+|\d+))\s*$")),
			("mem_disp_to_reg", 		re.compile(r"mov\s+dword\[\{(\w+)}\+(-?(?:0x[\da-fA-F]+|\d+|[a-fA-F]+))\]\s*,\s*\{(\w+)}\s*$")),
			("mem_reg_to_reg",			re.compile(r"mov\s+(?:dword|word|byte)?\[\{(\w+)}\]\s*,\s*\{(\w+)}\s*$")),
			("label_to_reg",			re.compile(r"mov\s+dword\[<([a-zA-Z_][\w]*)>\]\s*,\s*\{(\w+)}\s*$")),
		]

		# Determine mov_type
		mov_type = None
		match = None

		for name, regex in patterns:
			m = regex.match(instruction)
			if not m:
				continue

			if name == "reg_to_reg":
				dst, src = m.groups()
				if dst not in reg_code or src not in reg_code:
					continue
			elif name == "reg_to_label":
				dst, label = m.groups()
				if label in reg_code:
					continue
			elif name == "mem_reg_to_reg":
				mem, reg = m.groups()
				if mem not in reg_code:
					continue
			elif name == "mem_reg_to_imm":
				mem = m.group(1)
				if mem not in reg_code:
					continue

			mov_type = name
			match = m
			break

		print(f"Instruction '{instruction}' matched '{mov_type}'")
		# do the thing based on mov_type encountered
		match mov_type:
			case "reg_to_imm":
				dst, imm = match.groups()
				reg = reg_code[dst]
				value = int(imm, 0)
				self.buffer.write_int(self.buffer.asm_offset, 0xB8 + reg, size=1)
				self.buffer.write_int(self.buffer.asm_offset, value)

			case "reg_from_sib_label":
				dst, index, scale, label = match.groups()
				mod = 0b00
				rm = 0b100  # SIB follows
				reg = reg_code[dst]
				index_code = reg_code[index]
				scale_val = int(scale)
				if scale_val not in (1, 2, 4, 8):
					raise ValueError("Invalid SIB scale")
				scale_bits = {1: 0b00, 2: 0b01, 4: 0b10, 8: 0b11}[scale_val]
				self.buffer.write_int(self.buffer.asm_offset, 0x8B, size=1)
				self.buffer.write_int(self.buffer.asm_offset, (mod << 6) | (reg << 3) | rm, size=1)
				self.buffer.write_int(self.buffer.asm_offset, (scale_bits << 6) | (index_code << 3) | 0b101, size=1)
				self._add_unresolved_label(label)

			case "reg_from_mem_reg_reg":
				dst, base, index = match.groups()
				mod = 0b00
				rm = 0b100
				reg = reg_code[dst]
				base_code = reg_code[base]
				index_code = reg_code[index]
				scale_bits = 0b00  # assume scale of 1
				self.buffer.write_int(self.buffer.asm_offset, 0x8B, size=1)
				self.buffer.write_int(self.buffer.asm_offset, (mod << 6) | (reg << 3) | rm, size=1)
				self.buffer.write_int(self.buffer.asm_offset, (scale_bits << 6) | (index_code << 3) | base_code, size=1)

			case "reg_from_mem_disp":
				dst, base, offset = match.groups()
				mod = 0b10
				reg = reg_code[dst]
				rm = reg_code[base]
				try:
					offset_val = int(offset, 0)
				except ValueError:
					offset_val = int(offset, 16)
				self.buffer.write_int(self.buffer.asm_offset, 0x8B, size=1)
				self.buffer.write_int(self.buffer.asm_offset, (mod << 6) | (reg << 3) | rm, size=1)
				self.buffer.write_int(self.buffer.asm_offset, offset_val)

			case "reg_from_label_dword" | "reg_from_label_plain":
				dst, label = match.groups()
				reg = reg_code[dst]
				self.buffer.write_int(self.buffer.asm_offset, 0x8B, size=1)
				self.buffer.write_int(self.buffer.asm_offset, (0 << 6) | (reg << 3) | 0b101, size=1)
				self._add_unresolved_label(label)

			case "reg_from_mem_reg":
				dst, src = m.groups()
				reg = reg_code[dst]
				rm = reg_code[src]
				mod = 0b00
				size = 4
				if dst in ("ax", "bx", "cx", "dx", "sp", "bp", "si", "di"):
					size = 2
				elif dst in ("al", "ah", "bl", "bh", "cl", "ch", "dl", "dh"):
					size = 1
				self.buffer.write_int(self.buffer.asm_offset, 0x8B, size=1)
				self.buffer.write_int(self.buffer.asm_offset, (mod << 6) | (reg << 3) | rm, size=1)
				# prefix if needed
				if size == 2:
					self.buffer.write_int(self.buffer.asm_offset, 0x66, size=1)

			case "reg_to_reg":
				dst, src = match.groups()
				reg_dst = reg_code[dst]
				reg_src = reg_code[src]
				mod = 0b11
				self.buffer.write_int(self.buffer.asm_offset, 0x8B, size=1)
				self.buffer.write_int(self.buffer.asm_offset, (mod << 6) | (reg_dst << 3) | reg_src, size=1)

			case "reg_to_label":
				dst, label = match.groups()
				reg = reg_code[dst]
				self.buffer.write_int(self.buffer.asm_offset, 0xB8 + reg, size=1)
				self._add_unresolved_label(label)

			case "mem_reg_to_reg":
				mem, src = match.groups()
				reg = reg_code[src]
				rm = reg_code[mem]
				mod = 0b00
				self.buffer.write_int(self.buffer.asm_offset, 0x89, size=1)
				self.buffer.write_int(self.buffer.asm_offset, (mod << 6) | (reg << 3) | rm, size=1)

			case "mem_reg_to_imm":
				mem, imm = match.groups()
				rm = reg_code[mem]
				imm_val = int(imm, 0)
				self.buffer.write_int(self.buffer.asm_offset, 0xC7, size=1)
				self.buffer.write_int(self.buffer.asm_offset, (0b00 << 6) | (0b000 << 3) | rm, size=1)
				self.buffer.write_int(self.buffer.asm_offset, imm_val)

			case "mem_disp_to_reg":
				base, offset, src = match.groups()
				reg = reg_code[src]
				rm = reg_code[base]
				try:
					offset_val = int(offset, 0)
				except ValueError:
					offset_val = int(offset, 16)
				self.buffer.write_int(self.buffer.asm_offset, 0x89, size=1)
				self.buffer.write_int(self.buffer.asm_offset, (0b10 << 6) | (reg << 3) | rm, size=1)
				self.buffer.write_int(self.buffer.asm_offset, offset_val)

			case "label_to_reg":
				label, src = match.groups()
				reg = reg_code[src]
				self.buffer.write_int(self.buffer.asm_offset, 0x89, size=1)
				self.buffer.write_int(self.buffer.asm_offset, (0 << 6) | (reg << 3) | 0b101, size=1)
				self._add_unresolved_label(label)

			case _:
				raise NotImplementedError(f"mov not implemented yet: {instruction}")


	def _encode_lea(self, instruction: str) -> None:
		raise NotImplementedError(f"lea not implemented yet: {instruction}")


	def _encode_push(self, instruction: str) -> None:
		raise NotImplementedError(f"Push not implemented yet: {instruction}")


	def _encode_pop(self, instruction: str) -> None:
		raise NotImplementedError(f"Pop not implemented yet: {instruction}")


	def _encode_call(self, instruction: str) -> None:
		raise NotImplementedError(f"Call not implemented yet: {instruction}")


	def _encode_retn(self, instruction: str) -> None:
		raise NotImplementedError(f"Retn not implemented yet: {instruction}")


	def _encode_fld(self, instruction: str) -> None:
		raise NotImplementedError(f"FloatLoad not implemented yet: {instruction}")
		

	def _encode_test(self, instruction: str) -> None:
		raise NotImplementedError(f"Test not implemented yet: {instruction}")
		

	def _encode_shl(self, instruction: str) -> None:
		raise NotImplementedError(f"ShiftLeft not implemented yet: {instruction}")


	def add_instruction(self, instruction: str):
		"""
		Parses an assembly-like instruction and writes it to the buffer as machine code.

		:param instruction: Assembly-like instruction as a string.

		TODO - clean this fucking mess up
		"""
		instruction = instruction.strip()
		if "->" in instruction:
			left, hex_string = instruction.split(" -> ", 1)
			hex_string = hex_string.strip().replace(" ", "")
			bytes_to_write = bytes.fromhex(hex_string)
			self.buffer.write(self.buffer.asm_offset, bytes_to_write)
			self.buffer.asm_offset += len(bytes_to_write)
			return
		
		if instruction == "pushad":
			self.buffer.write(self.buffer.asm_offset, bytes([0x60]))
			self.buffer.asm_offset += 1
			return
		elif instruction == "popad":
			self.buffer.write(self.buffer.asm_offset, bytes([0x61]))
			self.buffer.asm_offset += 1
			return
		elif re.match(r"^\s*(add|sub|cmp|xor|and|or|inc|dec)\b", instruction, re.IGNORECASE):
			return self._encode_arithmetic(instruction)
		elif re.match(r"^\s*(jmp|jz|jnz|je|jne|ja|jb|jl|jg|jo|jno|js|jns|jp|jnp|jc|jnc)\b", instruction, re.IGNORECASE):
			return self._encode_jump(instruction)
		elif re.match(r"^\s*mov\b", instruction, re.IGNORECASE):
			return self._encode_mov(instruction)
		elif re.match(r"^\s*lea\b", instruction, re.IGNORECASE):
			return self._encode_lea(instruction)
		elif re.match(r"^\s*push\b", instruction, re.IGNORECASE):
			return self._encode_push(instruction)
		elif re.match(r"^\s*pop\b", instruction, re.IGNORECASE):
			return self._encode_pop(instruction)
		elif re.match(r"^\s*call\b", instruction, re.IGNORECASE):
			return self._encode_call(instruction)
		elif re.match(r"^\s*(ret|retn)\b", instruction, re.IGNORECASE):
			return self._encode_retn(instruction)
		elif re.match(r"^\s*fld\b", instruction, re.IGNORECASE):
			return self._encode_fld(instruction)
		elif re.match(r"^\s*test\b", instruction, re.IGNORECASE):
			return self._encode_test(instruction)
		elif re.match(r"^\s*shl\b", instruction, re.IGNORECASE):
			return self._encode_shl(instruction)
		

		raise NotImplementedError(f"Instruction fell through all handlers: {instruction}")


	def assemble(self, base_address: int) -> None:
		"""
		Resolves all tracked symbolic labels and replaces them with base_address + offset.
		
			:param base_address: Address given by VirtualAllocEx as the entry point for buffer to be written
		"""
		for label, positions in self.unresolved_labels.items():
			if label not in self.buffer.labels:
				raise ValueError(f"Unresolved label: {label}")
			
			final_addr = base_address + self.buffer.labels[label]
			for pos in positions:
				# print(f"Resolved label '{label}' to address 0x{final_addr:X} at offsets {pos}")
				# print(f"Original Bytes: {self.buffer.buffer[pos:pos+4]}")
				self.buffer.resolve_label(pos, final_addr)
				# print(f"New Bytes: {self.buffer.buffer[pos:pos+4]}")
			# print(f"Resolved label '{label}' to address 0x{final_addr:X} at offsets {positions}")
		# print(f"[ASSEMBLE] All control flow placeholders patched.")
		# print(f"Generated ASM String: {self.buffer.buffer.hex()}")
		# print(f"Total ASM Size: {self.buffer.asm_size}")
