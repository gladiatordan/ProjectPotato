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
			# print(f"Added new label type to unresolved labels: '{label}'")
		self.unresolved_labels[label].append(self.buffer.asm_offset)
		# print(f"Added offset entry for label {label} at {self.buffer.asm_offset}")
		
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

		# print(f"Added scan pattern ({byte_length} bytes), padded to {len(final_pattern_b)} bytes")
		

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
		# print(f"Label {name} set at position {pos}")
		
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
		# print(f"ASM offset before: {self.buffer.asm_offset}")
		self.buffer.asm_offset += padding_size
		# print(f"Added {padding_size} bytes of padding for Label '{name} for total size of {size}")
		# print(f"ASM offset after: {self.buffer.asm_offset}")

	
	def _encode_arithmetic(self, instruction: str) -> None:
		reg_code = {
			"eax": 0x0, "ecx": 0x1, "edx": 0x2, "ebx": 0x3,
			"esp": 0x4, "ebp": 0x5, "esi": 0x6, "edi": 0x7,
			"ax":  0x0, "cx":  0x1, "dx":  0x2, "bx":  0x3,
			"sp":  0x4, "bp":  0x5, "si":  0x6, "di":  0x7,
			"al":  0x0, "cl":  0x1, "dl":  0x2, "bl":  0x3,
			"ah":  0x4, "ch":  0x5, "dh":  0x6, "bh":  0x7,
		}

		patterns = [
			("reg_to_imm", 					re.compile(r"(add|sub|cmp|xor|shl)\s+\{(\w+)}\s*,\s*(-?(?:0x[\da-fA-F]+|\d+|[a-fA-F\d]+))$")),
			("reg_to_reg", 					re.compile(r"(?i)(add|sub|cmp|xor)\s+\{(\w+)}\s*,\s*\{(\w+)}$")),
			("reg_unary", 					re.compile(r"(inc|dec)\s+\{(\w+)}$")),
			("reg_to_label", 				re.compile(r"(cmp)\s+\{(\w+)}\s*,\s*<(\w+)>$")),
			("reg_to_mem_label", 			re.compile(r"(cmp)\s+(byte|word|dword)\[<(\w+)>]\s*,\s*(-?(?:0x[\da-fA-F]+|\d+))$")),
			("reg_to_mem_reg_disp", 		re.compile(r"(cmp)\s+\{(\w+)}\s*,\s+(byte|word|dword)?\[\{(\w+)}\}\+([0-9A-Fa-fx]+)]$")),
			("reg_from_mem_label", 			re.compile(r"(cmp)\\s+\\{(\w+)}\\s*,\\s*\\[<(\w+)>]$")),
			("reg_from_mem_label_dword", 	re.compile(r"(cmp)\\s+\\{(\w+)}\\s*,\\s*dword\\[<(\w+)>]$")),
			("reg_from_mem_label_plain", 	re.compile(r"(add|sub|cmp)\s+\{(\w+)}\s*,\s*\[<(\w+)>]$")),
			("mem_label_to_imm", 			re.compile(r"(cmp)\s+(byte|word|dword)?\[<(\w+)>]\s*,\s*(-?(?:0x[\da-fA-F]+|\d+))$")),
			("reg_to_mem_label_dword", 		re.compile(r"(cmp)\s+\{(\w+)}\s*,\s*dword\[<(\w+)>]$")),
			("reg_from_mem_reg_disp_dword", re.compile(r"(cmp)\s+\{(\w+)}\s*,\s*dword\[\{(\w+)}\+([0-9A-Fa-fx]+)]$")),
		]

		arith_type = None
		match = None

		for name, regex in patterns:
			m = regex.fullmatch(instruction.strip())
			if m:
				arith_type = name
				match = m
				break

		# print(f"Instruction '{instruction}' matched '{arith_type}'")

		match arith_type:
			case "reg_to_imm":
				op, dst, imm = match.groups()
				reg = reg_code[dst]
				value = int(imm, 16)
				fits_in_imm8 = -128 <= (value if value < 0x80000000 else value - 0x100000000) <= 127

				# Special case: cmp al, imm8 → opcode 0x3C
				if dst == "al" and op == "cmp":
					self.buffer.write_int(self.buffer.asm_offset, 0x3C, size=1)
					self.buffer.asm_offset += 1
					self.buffer.write_int(self.buffer.asm_offset, value & 0xFF, size=1)
					self.buffer.asm_offset += 1
					return

				is_8bit = dst in {"al", "cl", "dl", "bl", "ah", "ch", "dh", "bh"}
				is_16bit = dst in {"ax", "cx", "dx", "bx", "sp", "bp", "si", "di"}

				subcode = {
					"add": 0b000,
					"or":  0b001,
					"adc": 0b010,
					"sbb": 0b011,
					"and": 0b100,
					"shl": 0b100,  # sal = shl
					"sub": 0b101,
					"xor": 0b110,
					"cmp": 0b111,
				}[op]

				# Special handling for SHL — different base opcode (C0/C1)
				if op == "shl":
					if is_8bit:
						opcode = 0xC0
					elif is_16bit:
						self.buffer.write_int(self.buffer.asm_offset, 0x66, size=1)
						self.buffer.asm_offset += 1
						opcode = 0xC1
					else:
						opcode = 0xC1
				else:
					if is_8bit:
						opcode = 0x80
					elif is_16bit:
						self.buffer.write_int(self.buffer.asm_offset, 0x66, size=1)
						self.buffer.asm_offset += 1
						opcode = 0x81
					elif fits_in_imm8 and op in {"add", "sub", "cmp", "xor"}:
						opcode = 0x83
					else:
						opcode = 0x81

				# Emit opcode and modrm
				self.buffer.write_int(self.buffer.asm_offset, opcode, size=1)
				self.buffer.asm_offset += 1
				modrm = (0b11 << 6) | (subcode << 3) | reg
				self.buffer.write_int(self.buffer.asm_offset, modrm, size=1)
				self.buffer.asm_offset += 1

				# Emit immediate value
				if is_8bit or op == "shl":
					self.buffer.write_int(self.buffer.asm_offset, value & 0xFF, size=1)
					self.buffer.asm_offset += 1
				elif is_16bit:
					self.buffer.write_int(self.buffer.asm_offset, value & 0xFFFF, size=2)
					self.buffer.asm_offset += 2
				else:
					if fits_in_imm8:
						self.buffer.write_int(self.buffer.asm_offset, value, size=1)
						self.buffer.asm_offset += 1
					else:
						self.buffer.write_int(self.buffer.asm_offset, value)
						self.buffer.asm_offset += 4

			case "reg_to_reg":
				op, dst, src = match.groups()
				dst_code = reg_code[dst]
				src_code = reg_code[src]

				is_8bit = dst in {"al", "cl", "dl", "bl", "ah", "ch", "dh", "bh"}
				is_16bit = dst in {"ax", "cx", "dx", "bx", "sp", "bp", "si", "di"}

				if is_8bit:
					opcode = {
						"add": 0x00, "or":  0x08, "adc": 0x10, "sbb": 0x18,
						"and": 0x20, "sub": 0x28, "xor": 0x30, "cmp": 0x38,
					}[op]
				elif is_16bit:
					self.buffer.write_int(self.buffer.asm_offset, 0x66, size=1)
					self.buffer.asm_offset += 1
					opcode = {
						"add": 0x03, "or":  0x0B, "adc": 0x13, "sbb": 0x1B,
						"and": 0x23, "sub": 0x2B, "xor": 0x33, "cmp": 0x3B,
					}[op]
				else:
					opcode = {
						"add": 0x03, "or":  0x0B, "adc": 0x13, "sbb": 0x1B,
						"and": 0x23, "sub": 0x2B, "xor": 0x33, "cmp": 0x3B,
					}[op]

				self.buffer.write_int(self.buffer.asm_offset, opcode, size=1)
				self.buffer.asm_offset += 1
				modrm = (0b11 << 6) | (dst_code << 3) | src_code
				self.buffer.write_int(self.buffer.asm_offset, modrm, size=1)
				self.buffer.asm_offset += 1

			case "reg_unary":
				op, reg = match.groups()
				reg_code_val = reg_code[reg]
				opcode = {"inc": 0x40, "dec": 0x48}[op]
				self.buffer.write_int(self.buffer.asm_offset, opcode + reg_code_val, size=1)
				self.buffer.asm_offset += 1

			case "reg_to_label":
				op, dst, label = match.groups()
				if dst not in reg_code:
					raise NotImplementedError(f"Unsupported register in: {instruction}")
				opcode = 0x3B  # cmp reg, r/m32
				self.buffer.write_int(self.buffer.asm_offset, opcode, size=1)
				self.buffer.asm_offset += 1
				modrm = 0x05 | (reg_code[dst] << 3)
				self.buffer.write_int(self.buffer.asm_offset, modrm, size=1)
				self.buffer.asm_offset += 1
				self._add_unresolved_label(label)

			case "reg_to_mem_label":
				op, size, label, imm = match.groups()
				opcode = 0x80 if size == "byte" else 0x81
				subcode = 0x07  # cmp r/mX, immX
				self.buffer.write_int(self.buffer.asm_offset, opcode, size=1)
				self.buffer.asm_offset += 1
				modrm = 0x05 | (subcode << 3)
				self.buffer.write_int(self.buffer.asm_offset, modrm, size=1)
				self.buffer.asm_offset += 1
				self._add_unresolved_label(label)
				if size == "byte":
					self.buffer.write_int(self.buffer.asm_offset, int(imm, 0) & 0xFF, size=1)
					self.buffer.asm_offset += 1
				else:
					self.buffer.write_int(self.buffer.asm_offset, int(imm, 0) & 0xFFFFFFFF)
					self.buffer.asm_offset += 4

			case "reg_to_mem_reg_disp":
				op, dst, size, base, disp = match.groups()
				dst_code = reg_code[dst]
				base_code = reg_code[base]
				opcode = 0x38 if dst in {"al", "cl", "dl", "bl", "ah", "ch", "dh", "bh"} else 0x3B
				self.buffer.write_int(self.buffer.asm_offset, opcode, size=1)
				self.buffer.asm_offset += 1
				modrm = 0x80 | (dst_code << 3) | base_code
				self.buffer.write_int(self.buffer.asm_offset, modrm, size=1)
				self.buffer.asm_offset += 1
				self.buffer.write_int(self.buffer.asm_offset, int(disp, 16))
				self.buffer.asm_offset += 4

			case "reg_from_mem_label":
				op, dst, label = match.groups()
				opcode = 0x3B  # cmp reg, r/m32
				self.buffer.write_int(self.buffer.asm_offset, opcode, size=1)
				self.buffer.asm_offset += 1
				modrm = 0x05 | (reg_code[dst] << 3)
				self.buffer.write_int(self.buffer.asm_offset, modrm, size=1)
				self.buffer.asm_offset += 1
				self._add_unresolved_label(label)

			case "reg_from_mem_label_dword":
				op, dst, label = match.groups()
				opcode = 0x3B
				self.buffer.write_int(self.buffer.asm_offset, opcode, size=1)
				self.buffer.asm_offset += 1
				modrm = 0x05 | (reg_code[dst] << 3)
				self.buffer.write_int(self.buffer.asm_offset, modrm, size=1)
				self.buffer.asm_offset += 1
				self._add_unresolved_label(label)

			case "reg_from_mem_label_plain":
				op, dst, label = match.groups()
				if dst not in reg_code:
					raise NotImplementedError(f"Unsupported register in: {instruction}")
				opcode = {"add": 0x03, "sub": 0x2B, "cmp": 0x3B}[op]
				self.buffer.write_int(self.buffer.asm_offset, opcode, size=1)
				self.buffer.asm_offset += 1
				modrm = 0x05 | (reg_code[dst] << 3)
				self.buffer.write_int(self.buffer.asm_offset, modrm, size=1)
				self.buffer.asm_offset += 1
				self._add_unresolved_label(label)

			case "mem_label_to_imm":
				op, size, label, imm = match.groups()
				opcode = 0xC6 if size == "byte" else 0xC7
				subcode = 0x00  # opcode extension for mov/cmp imm to r/m
				self.buffer.write_int(self.buffer.asm_offset, opcode, size=1)
				self.buffer.asm_offset += 1
				modrm = 0x05 | (subcode << 3)
				self.buffer.write_int(self.buffer.asm_offset, modrm, size=1)
				self.buffer.asm_offset += 1
				self._add_unresolved_label(label)
				if size == "byte":
					self.buffer.write_int(self.buffer.asm_offset, int(imm, 0) & 0xFF, size=1)
					self.buffer.asm_offset += 1
				else:
					self.buffer.write_int(self.buffer.asm_offset, int(imm, 0) & 0xFFFFFFFF)
					self.buffer.asm_offset += 4
			
			case "reg_to_mem_label_dword":
				op, dst, label = match.groups()
				opcode = 0x3B
				dst_code = reg_code[dst]
				self.buffer.write_int(self.buffer.asm_offset, opcode, size=1)
				self.buffer.asm_offset += 1
				modrm = 0x05 | (dst_code << 3)
				self.buffer.write_int(self.buffer.asm_offset, modrm, size=1)
				self.buffer.asm_offset += 1
				self._add_unresolved_label(label)
			
			case "reg_from_mem_reg_disp_dword":
				op, dst, base, disp = match.groups()
				dst_code = reg_code[dst]
				base_code = reg_code[base]
				opcode = 0x3B  # CMP r32, r/m32
				self.buffer.write_int(self.buffer.asm_offset, opcode, size=1)
				self.buffer.asm_offset += 1
				modrm = 0x80 | (dst_code << 3) | base_code
				self.buffer.write_int(self.buffer.asm_offset, modrm, size=1)
				self.buffer.asm_offset += 1
				self.buffer.write_int(self.buffer.asm_offset, int(disp, 16))
				self.buffer.asm_offset += 4

			case _:
				raise NotImplementedError(f"arithmetic not implemented yet: {instruction}")


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
			("reg_to_imm", 				re.compile(r"mov\s+\{(\w+)}\s*,\s*(-?(?:0x)?[\da-fA-F]+)\s*$")),
			("reg_from_sib_label",		re.compile(r"mov\s+\{(\w+)}\s*,\s*dword\[\{(\w+)}\*(\d+)\+<([a-zA-Z_][\w]*)>\]\s*$")),
			("reg_from_mem_reg_reg",	re.compile(r"mov\s+\{(\w+)}\s*,\s*dword\[\{(\w+)}\+\{(\w+)}\]\s*$")),
			("reg_from_mem_disp", 		re.compile(r"mov\s+\{(\w+)}\s*,\s*(?:byte|word|dword)?\[\{(\w+)}\+(-?(?:0x[\da-fA-F]+|\d+|[a-fA-F\d]+))\]\s*$")),
			("reg_from_label_dword",	re.compile(r"mov\s+\{(\w+)}\s*,\s*dword\[<([a-zA-Z_][\w]*)>\]\s*$")),
			("reg_from_label_plain",	re.compile(r"mov\s+\{(\w+)\},\s*\[\<([a-zA-Z_][a-zA-Z0-9_]*)\>\]")),
			("reg_from_mem_reg_32", 	re.compile(r"mov\s+\{(\w+)}\s*,\s*dword\[\{(\w+)}\]\s*$")),
			("reg_from_mem_reg_16", 	re.compile(r"mov\s+\{(\w+)}\s*,\s*word\[\{(\w+)}\]\s*$")),
			("reg_from_mem_reg_8",  	re.compile(r"mov\s+\{(\w+)}\s*,\s*byte\[\{(\w+)}\]\s*$")),
			("reg_to_reg",				re.compile(r"mov\s+\{(\w+)}\s*,\s*\{(\w+)}\s*$")),
			("reg_to_label",			re.compile(r"mov\s+\{(\w+)}\s*,\s*<([a-zA-Z_][\w]*)>\s*$")),
			("mem_reg_to_imm",			re.compile(r"mov\s+dword\[\{(\w+)}\]\s*,\s*(-?(?:0x[\da-fA-F]+|\d+))\s*$")),
			("mem_disp_to_reg", 		re.compile(r"mov\s+dword\[\{(\w+)}\+(-?(?:0x[\da-fA-F]+|\d+|[a-fA-F]+))\]\s*,\s*\{(\w+)}\s*$")),
			("mem_reg_to_reg",			re.compile(r"mov\s+(?:dword|word|byte)?\[\{(\w+)}\]\s*,\s*\{(\w+)}\s*$")),
			("label_to_reg",			re.compile(r"mov\s+dword\[<([a-zA-Z_][\w]*)>\]\s*,\s*\{(\w+)}\s*$")),
			("label_to_imm", 			re.compile(r"mov\s+dword\[<([a-zA-Z_][\w]*)>\]\s*,\s*(-?(?:0x[\da-fA-F]+|\d+))\s*$")),
		]

		# Determine mov_type
		mov_type = None
		match = None

		for name, regex in patterns:
			m = regex.fullmatch(instruction)
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

		# print(f"Instruction '{instruction}' matched '{mov_type}'")
		# do the thing based on mov_type encountered
		match mov_type:
			case "reg_to_imm":
				dst, imm = match.groups()
				reg = reg_code[dst]
				try:
					value = int(imm, 0)
				except ValueError:
					value = int(imm, 16)
				self.buffer.write_int(self.buffer.asm_offset, 0xB8 + reg, size=1)
				self.buffer.asm_offset += 1
				self.buffer.write_int(self.buffer.asm_offset, value)
				self.buffer.asm_offset += 4

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
				self.buffer.asm_offset += 1
				self.buffer.write_int(self.buffer.asm_offset, (mod << 6) | (reg << 3) | rm, size=1)
				self.buffer.asm_offset += 1
				self.buffer.write_int(self.buffer.asm_offset, (scale_bits << 6) | (index_code << 3) | 0b101, size=1)
				self.buffer.asm_offset += 1
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
				self.buffer.asm_offset += 1
				self.buffer.write_int(self.buffer.asm_offset, (mod << 6) | (reg << 3) | rm, size=1)
				self.buffer.asm_offset += 1
				self.buffer.write_int(self.buffer.asm_offset, (scale_bits << 6) | (index_code << 3) | base_code, size=1)
				self.buffer.asm_offset += 1

			case "reg_from_mem_disp":
				dst, base, offset = match.groups()
				mod = 0b10
				reg = reg_code[dst]
				rm = reg_code[base]
				offset_val = int(offset, 16)
				self.buffer.write_int(self.buffer.asm_offset, 0x8B, size=1)
				self.buffer.asm_offset += 1
				if rm == 0b100:  # esp
					# Use SIB with no index (index = 100), base = esp (100)
					self.buffer.write_int(self.buffer.asm_offset, (mod << 6) | (reg << 3) | 0b100, size=1)
					self.buffer.asm_offset += 1
					self.buffer.write_int(self.buffer.asm_offset, (0b00 << 6) | (0b100 << 3) | 0b100, size=1)
					self.buffer.asm_offset += 1
				else:
					self.buffer.write_int(self.buffer.asm_offset, (mod << 6) | (reg << 3) | rm, size=1)
					self.buffer.asm_offset += 1
				self.buffer.write_int(self.buffer.asm_offset, offset_val)
				self.buffer.asm_offset += 4

			case "reg_from_label_plain":
				dest = match.group(1)
				label = match.group(2)
				r = reg_code[dest]
				opcode = 0xB8 + r
				self.buffer.write_int(self.buffer.asm_offset, opcode, size=1)
				self.buffer.asm_offset += 1
				self._add_unresolved_label(label)
				return

			case "reg_from_label_dword":
				dst, label = match.groups()
				reg = reg_code[dst]
				self.buffer.write_int(self.buffer.asm_offset, 0x8B, size=1)
				self.buffer.asm_offset += 1
				self.buffer.write_int(self.buffer.asm_offset, (0 << 6) | (reg << 3) | 0b101, size=1)
				self.buffer.asm_offset += 1
				self._add_unresolved_label(label)

			case "reg_from_mem_reg_32":
				dst, src = match.groups()
				reg = reg_code[dst]
				rm = reg_code[src]
				mod = 0b00
				self.buffer.write_int(self.buffer.asm_offset, 0x8B, size=1)
				self.buffer.asm_offset += 1
				self.buffer.write_int(self.buffer.asm_offset, (mod << 6) | (reg << 3) | rm, size=1)
				self.buffer.asm_offset += 1

			case "reg_from_mem_reg_16":
				dst, src = match.groups()
				reg = reg_code[dst]
				rm = reg_code[src]
				mod = 0b00
				self.buffer.write_int(self.buffer.asm_offset, 0x66, size=1)  # 16-bit override
				self.buffer.asm_offset += 1
				self.buffer.write_int(self.buffer.asm_offset, 0x8B, size=1)
				self.buffer.asm_offset += 1
				self.buffer.write_int(self.buffer.asm_offset, (mod << 6) | (reg << 3) | rm, size=1)
				self.buffer.asm_offset += 1

			case "reg_from_mem_reg_8":
				dst, src = match.groups()
				reg = reg_code[dst]
				rm = reg_code[src]
				mod = 0b00
				self.buffer.write_int(self.buffer.asm_offset, 0x8A, size=1)  # opcode for r8 <- m8
				self.buffer.asm_offset += 1
				self.buffer.write_int(self.buffer.asm_offset, (mod << 6) | (reg << 3) | rm, size=1)
				self.buffer.asm_offset += 1

			case "reg_to_reg":
				dst, src = match.groups()
				reg_dst = reg_code[dst]
				reg_src = reg_code[src]
				mod = 0b11
				self.buffer.write_int(self.buffer.asm_offset, 0x8B, size=1)
				self.buffer.asm_offset += 1
				self.buffer.write_int(self.buffer.asm_offset, (mod << 6) | (reg_dst << 3) | reg_src, size=1)
				self.buffer.asm_offset += 1

			case "reg_to_label":
				dst, label = match.groups()
				reg = reg_code[dst]
				self.buffer.write_int(self.buffer.asm_offset, 0xB8 + reg, size=1)
				self.buffer.asm_offset += 1
				self._add_unresolved_label(label)

			case "mem_reg_to_reg":
				mem, src = match.groups()
				reg = reg_code[src]
				rm = reg_code[mem]
				mod = 0b00
				# override for non 32-bit registers
				if src in ("ax", "bx", "cx", "dx", "sp", "bp", "si", "di"):
					self.buffer.write_int(self.buffer.asm_offset, 0x66, size=1)
					self.buffer.asm_offset += 1
				self.buffer.write_int(self.buffer.asm_offset, 0x89, size=1)
				self.buffer.asm_offset += 1
				self.buffer.write_int(self.buffer.asm_offset, (mod << 6) | (reg << 3) | rm, size=1)
				self.buffer.asm_offset += 1

			case "mem_reg_to_imm":
				mem, imm = match.groups()
				rm = reg_code[mem]
				imm_val = int(imm, 0)
				self.buffer.write_int(self.buffer.asm_offset, 0xC7, size=1)
				self.buffer.asm_offset += 1
				self.buffer.write_int(self.buffer.asm_offset, (0b00 << 6) | (0b000 << 3) | rm, size=1)
				self.buffer.asm_offset += 1
				self.buffer.write_int(self.buffer.asm_offset, imm_val)
				self.buffer.asm_offset += 4

			case "mem_disp_to_reg":
				base, offset, src = match.groups()
				reg = reg_code[src]
				rm = reg_code[base]
				offset_val = int(offset, 16)
				self.buffer.write_int(self.buffer.asm_offset, 0x89, size=1)
				self.buffer.asm_offset += 1
				self.buffer.write_int(self.buffer.asm_offset, (0b10 << 6) | (reg << 3) | rm, size=1)
				self.buffer.asm_offset += 1
				self.buffer.write_int(self.buffer.asm_offset, offset_val)
				self.buffer.asm_offset += 4

			case "label_to_reg":
				label, src = match.groups()
				reg = reg_code[src]
				self.buffer.write_int(self.buffer.asm_offset, 0x89, size=1)
				self.buffer.asm_offset += 1
				self.buffer.write_int(self.buffer.asm_offset, (0 << 6) | (reg << 3) | 0b101, size=1)
				self.buffer.asm_offset += 1
				self._add_unresolved_label(label)

			case "label_to_imm":
				label, imm = match.groups()
				imm_val = int(imm, 0)
				self.buffer.write_int(self.buffer.asm_offset, 0xC7, size=1)
				self.buffer.asm_offset += 1
				self.buffer.write_int(self.buffer.asm_offset, (0b00 << 6) | (0b000 << 3) | 0b101, size=1)
				self.buffer.asm_offset += 1
				self._add_unresolved_label(label)
				self.buffer.write_int(self.buffer.asm_offset, imm_val)
				self.buffer.asm_offset += 4
			case _:
				raise NotImplementedError(f"mov not implemented yet: {instruction}")


	def _encode_pop(self, instruction: str) -> None:
		reg_code = {
			"popad": 0x61,
			"reg":   0x58,  # + register code
		}

		registers = {
			# 8-bit
			"al": (0, 8), "cl": (1, 8), "dl": (2, 8), "bl": (3, 8),
			"ah": (4, 8), "ch": (5, 8), "dh": (6, 8), "bh": (7, 8),
			# 16-bit
			"ax": (0, 16), "cx": (1, 16), "dx": (2, 16), "bx": (3, 16),
			"sp": (4, 16), "bp": (5, 16), "si": (6, 16), "di": (7, 16),
			# 32-bit
			"eax": (0, 32), "ecx": (1, 32), "edx": (2, 32), "ebx": (3, 32),
			"esp": (4, 32), "ebp": (5, 32), "esi": (6, 32), "edi": (7, 32),
		}

		patterns = [
			("popa", re.compile(r"^popa$")),
			("popad", re.compile(r"^popad$")),
			("reg",   re.compile(r"^pop\s+\{(\w+)}$")),
		]

		pop_type = None
		operand = None
		for type_name, pattern in patterns:
			match = pattern.match(instruction)
			if match:
				pop_type = type_name
				operand = match.group(1) if match.groups() else None
				break

		# print(f"Instruction '{instruction}' matched '{pop_type}'")
		match pop_type:
			case "popad":
				self.buffer.write_int(self.buffer.asm_offset, reg_code["popad"], size=1)
				self.buffer.asm_offset += 1
			
			case "popa":
				self.buffer.write_int(self.buffer.asm_offset, 0x66, size=1)
				self.buffer.asm_offset += 1
				self.buffer.write_int(self.buffer.asm_offset, reg_code["popad"], size=1)
				self.buffer.asm_offset += 1

			case "reg":
				if operand not in registers:
					raise NotImplementedError(f"Unsupported register for pop: {operand}")

				reg_id, width = registers[operand]
				if width == 8:
					raise NotImplementedError(f"Cannot pop into 8-bit register: {operand}")

				elif width == 16:
					self.buffer.write_int(self.buffer.asm_offset, 0x66, size=1)
					self.buffer.asm_offset += 1

				self.buffer.write_int(self.buffer.asm_offset, reg_code["reg"] + reg_id, size=1)
				self.buffer.asm_offset += 1

			case _:
				raise NotImplementedError(f"Unrecognized pop instruction: {instruction}")


	def _encode_push(self, instruction: str) -> None:
		reg_code = {
			"imm8":  0x6A, "imm32": 0x68, "reg":   0x50,  # + register code
			"mem":   0xFF,  # /6 in ModRM
			"label": 0x68, "pushad": 0x60,
		}

		registers = {
			# 8-bit
			"al": (0, 8), "cl": (1, 8), "dl": (2, 8), "bl": (3, 8),
			"ah": (4, 8), "ch": (5, 8), "dh": (6, 8), "bh": (7, 8),
			# 16-bit
			"ax": (0, 16), "cx": (1, 16), "dx": (2, 16), "bx": (3, 16),
			"sp": (4, 16), "bp": (5, 16), "si": (6, 16), "di": (7, 16),
			# 32-bit
			"eax": (0, 32), "ecx": (1, 32), "edx": (2, 32), "ebx": (3, 32),
			"esp": (4, 32), "ebp": (5, 32), "esi": (6, 32), "edi": (7, 32),
		}

		patterns = [
			("pushad",      	re.compile(r"^pushad$")),
			("reg",         	re.compile(r"^push\s+\{(\w+)}$")),
			("imm", 			re.compile(r"^push\s+((?:0x)?[0-9A-Fa-f]+)$")),
			("mem",         	re.compile(r"push\s+dword\[(\w+)]$")),
			("mem_label",   	re.compile(r"^push\s+(?:(byte|word|dword)?\s*)?\[<([\w]+)>]$")),
			("mem_reg_disp",	re.compile(r"^push\s+dword\s*\[\{(\w+)}\+(-?(?:0x)?[\da-fA-F]+)\]$")),
			("label", 		 	re.compile(r"^push\s+<([A-Za-z_][\w]*)>$")),
		]

		# Determine push_type
		push_type = None
		operand = None
		operand_parts = None
		for type_name, pattern in patterns:
			match = pattern.match(instruction)
			if match:
				push_type = type_name
				if type_name == "mem_label" or type_name == "mem_reg_disp":
					operand_parts = match.groups()  # (size, label)
				else:
					operand = match.group(1) if match.groups() else None
				break

		# print(f"Instruction '{instruction}' matched '{push_type}'")
		match push_type:
			case "pushad":
				self.buffer.write_int(self.buffer.asm_offset, reg_code["pushad"], size=1)
				self.buffer.asm_offset += 1

			case "reg":
				if operand not in registers:
					raise NotImplementedError(f"Unsupported register for push: {operand}")
				
				reg_id, width = registers[operand]
				if width == 8:
					raise NotImplementedError(f"Cannot push 8-bit register: {operand}")
				
				elif width == 16:
					self.buffer.write_int(self.buffer.asm_offset, 0x66, size=1)
					self.buffer.asm_offset += 1

				self.buffer.write_int(self.buffer.asm_offset, reg_code["reg"] + reg_id, size=1)
				self.buffer.asm_offset += 1

			case "imm":
				value = int(operand, 16)
				if -128 <= value <= 127:
					self.buffer.write_int(self.buffer.asm_offset, reg_code["imm8"], size=1)
					self.buffer.asm_offset += 1
					self.buffer.write_int(self.buffer.asm_offset, value & 0xFF, size=1)
					self.buffer.asm_offset += 1
				else:
					self.buffer.write_int(self.buffer.asm_offset, reg_code["imm32"], size=1)
					self.buffer.asm_offset += 1
					self.buffer.write_int(self.buffer.asm_offset, value, size=4)
					self.buffer.asm_offset += 4

			case "label":
				self.buffer.write_int(self.buffer.asm_offset, reg_code["label"], size=1)
				self.buffer.asm_offset += 1
				self._add_unresolved_label(operand)

			case "mem":
				# existing mem handling remains unchanged
				pass

			case "mem_label":
				size_hint, label = operand_parts
				if size_hint is None:
					# treat as raw 4-byte address push
					self.buffer.write_int(self.buffer.asm_offset, reg_code["label"], size=1)
					self.buffer.asm_offset += 1
					self._add_unresolved_label(label)
				else:
					# treat as memory dereference (e.g. push dword[<label>])
					self.buffer.write_int(self.buffer.asm_offset, reg_code["mem"], size=1)
					self.buffer.asm_offset += 1
					self.buffer.write_int(self.buffer.asm_offset, 0x35, size=1)  # ModRM: PUSH [disp32]
					self.buffer.asm_offset += 1
					self._add_unresolved_label(label)

			case "mem_reg_disp":
				base, disp = operand_parts
				if base not in registers:
					raise NotImplementedError(f"Unsupported base register in: {instruction}")

				base_id, _ = registers[base]
				disp_val = int(disp, 16)

				self.buffer.write_int(self.buffer.asm_offset, reg_code["mem"], size=1)
				self.buffer.asm_offset += 1

				reg_ext = 0b110  # /6 for push

				# Mod selection based on displacement
				if -128 <= disp_val <= 127:
					mod = 0b01
					disp_bytes = [disp_val & 0xFF]
				else:
					mod = 0b10
					disp_bytes = list(disp_val.to_bytes(4, "little", signed=True))

				rm = base_id
				modrm = (mod << 6) | (reg_ext << 3) | rm
				self.buffer.write_int(self.buffer.asm_offset, modrm, size=1)
				self.buffer.asm_offset += 1

				if base_id == 4:
					sib = (0 << 6) | (4 << 3) | 4
					self.buffer.write_int(self.buffer.asm_offset, sib, size=1)
					self.buffer.asm_offset += 1

				for b in disp_bytes:
					self.buffer.write_int(self.buffer.asm_offset, b, size=1)
					self.buffer.asm_offset += 1

			case _:
				raise NotImplementedError(f"Unrecognized push instruction: {instruction}")


	def _encode_jump(self, instruction: str) -> None:
		jump_codes = {
			"jmp_rel8":  0xEB,
			"jmp_rel32": 0xE9,
			"jmp_rm32":  0xFF,  # /4 with ModRM
			"ljmp":      0xEA,

			# Full conditional jumps (rel32 only)
			"jae":  0x0F83,
			"jz":   0x0F84, "je":   0x0F84,  # equal / zero
			"jnz":  0x0F85, "jne":  0x0F85,  # not equal / not zero
			"jb":   0x0F82, "jc":   0x0F82,  # below / carry
			"jnb":  0x0F83, "jnc":  0x0F83,  # not below / not carry
			"ja":   0x0F87,                 # above (unsigned)
			"jbe":  0x0F86,                 # below or equal (unsigned)
			"jl":   0x0F8C,                 # less (signed)
			"jge":  0x0F8D,                 # greater or equal (signed)
			"jg":   0x0F8F,                 # greater (signed)
			"jle":  0x0F8E,                 # less or equal (signed)
			"jo":   0x0F80, "jno":  0x0F81, # overflow / no overflow
			"js":   0x0F88, "jns":  0x0F89, # sign / not sign
			"jp":   0x0F8A, "jnp":  0x0F8B, # parity / no parity
		}

		patterns = [
			("cond", 			re.compile(r"^(jz|jnz|je|jne|ja|jb|jl|jg|jo|jno|js|jns|jp|jnp|jc|jnc|jae|jbe|jge)\s+(?:\{([\w]+)\}|\[<([\w]+)>\]|<([\w]+)>)$")),
			("jmp", 			re.compile(r"^jmp\s+(?:<([\w]+)>|\[<([\w]+)>\])$")),
			("jmp_reg",			re.compile(r"^jmp\s+\{(\w+)}$")),
			("jmp_mem", 		re.compile(r"^jmp\s+\[\<([\w]+)\>\]$")),
			("jmp_mem_dword", 	re.compile(r"^jmp\s+dword\[\<([\w]+)\>\]$")),
			("ljmp",   			re.compile(r"^ljmp\s+([\w]+)$")),
			("ljmp_mem",   		re.compile(r"^ljmp\s+\[<([\w]+)>\]$")),
			("ljmp_mem_dword",  re.compile(r"^ljmp\s+dword\[<([\w]+)>\]$")),
		]

		jump_type = None
		operand = None
		operand_parts = None

		for type_name, pattern in patterns:
			match = pattern.match(instruction)
			if match:
				jump_type = type_name
				operand_parts = match.groups()
				operand = operand_parts[0] if len(operand_parts) == 1 else operand_parts
				break

		# print(f"Instruction '{instruction}' matched '{jump_type}'")
		match jump_type:
			case "cond":
				mnem = operand_parts[0]
				label = next(part for part in operand_parts[1:] if part)

				# Normalize symbolic label syntax
				if label.startswith("[<") and label.endswith(">]"):
					label = label[2:-2]
				elif label.startswith("<") and label.endswith(">"):
					label = label[1:-1]
				elif label.startswith("{") and label.endswith("}"):
					label = label[1:-1]

				opcode = jump_codes[mnem]
				self.buffer.write_int(self.buffer.asm_offset, opcode >> 8, size=1)
				self.buffer.asm_offset += 1
				self.buffer.write_int(self.buffer.asm_offset, opcode & 0xFF, size=1)
				self.buffer.asm_offset += 1
				self._add_unresolved_label(label)

			case "jmp":
				operand = next(filter(None, operand_parts)) if operand_parts else None
				self.buffer.write_int(self.buffer.asm_offset, jump_codes["jmp_rel32"], size=1)
				self.buffer.asm_offset += 1
				self._add_unresolved_label(operand)

			case "jmp_reg":
				reg_map = {
					"eax": 0x00, "ecx": 0x01, "edx": 0x02, "ebx": 0x03,
					"esp": 0x04, "ebp": 0x05, "esi": 0x06, "edi": 0x07
				}
				if operand not in reg_map:
					raise NotImplementedError(f"Unsupported jmp register: {operand}")
				self.buffer.write_int(self.buffer.asm_offset, jump_codes["jmp_rm32"], size=1)
				self.buffer.asm_offset += 1
				modrm = (0b11 << 6) | (0b100 << 3) | reg_map[operand]  # /4
				self.buffer.write_int(self.buffer.asm_offset, modrm, size=1)
				self.buffer.asm_offset += 1

			case "jmp_mem":
				self.buffer.write_int(self.buffer.asm_offset, jump_codes["jmp_rm32"], size=1)
				self.buffer.asm_offset += 1
				self.buffer.write_int(self.buffer.asm_offset, 0x25, size=1)
				self.buffer.asm_offset += 1
				self._add_unresolved_label(operand)

			case "jmp_mem_dword":
				self.buffer.write_int(self.buffer.asm_offset, jump_codes["jmp_rm32"], size=1)
				self.buffer.asm_offset += 1
				self.buffer.write_int(self.buffer.asm_offset, 0x25, size=1)
				self.buffer.asm_offset += 1
				self._add_unresolved_label(operand)

			case "ljmp":
				self.buffer.write_int(self.buffer.asm_offset, jump_codes["ljmp"], size=1)
				self.buffer.asm_offset += 1
				self._add_unresolved_label(operand)
				self.buffer.write_int(self.buffer.asm_offset, 0x00, size=2)  # dummy segment selector
				self.buffer.asm_offset += 2

			case "ljmp_mem":
				self.buffer.write_int(self.buffer.asm_offset, jump_codes["ljmp"], size=1)
				self.buffer.asm_offset += 1
				self._add_unresolved_label(operand)
				self.buffer.write_int(self.buffer.asm_offset, 0x00, size=2)  # segment
				self.buffer.asm_offset += 2

			case "ljmp_mem_dword":
				self.buffer.write_int(self.buffer.asm_offset, jump_codes["ljmp"], size=1)
				self.buffer.asm_offset += 1
				self.buffer.write_int(self.buffer.asm_offset, 0x25, size=1)
				self.buffer.asm_offset += 1
				self._add_unresolved_label(operand)
				self.buffer.write_int(self.buffer.asm_offset, 0x00, size=2)
				self.buffer.asm_offset += 2

			case _:
				raise NotImplementedError(f"Unrecognized jump not implemented: {instruction}")


	def _encode_lea(self, instruction: str) -> None:
		reg_code = {
			"eax": 0x00, "ecx": 0x01, "edx": 0x02, "ebx": 0x03,
			"esp": 0x04, "ebp": 0x05, "esi": 0x06, "edi": 0x07
		}

		patterns = [
			("lea_mem", 		re.compile(r"^lea\s+\{(\w+)}\s*,\s*dword\[\{(\w+)}(?:\+\{(\w+)}(?:\*(\d))?)?(?:\+(\d+)|\+<(\w+)>)?\]$")),
			("lea_index_disp", 	re.compile(r"^lea\s+\{(\w+)}\s*,\s*dword\[\{(\w+)}\*(\d)(?:\+(\d+)|\+<(\w+)>)?\]$")),
		]

		lea_type = None
		groups = None

		for type_name, pattern in patterns:
			match = pattern.match(instruction)
			if match:
				lea_type = type_name
				groups = match.groups()
				break

		# print(f"Instruction '{instruction}' matched '{lea_type}'")
		match lea_type:
			case "lea_mem":
				dst_reg, base, index, scale, disp_int, disp_label = groups

				if dst_reg not in reg_code or base not in reg_code:
					raise NotImplementedError(f"Unsupported register in lea: {instruction}")

				dst_code = reg_code[dst_reg]
				base_code = reg_code[base]
				index_code = reg_code.get(index, 0x00)
				scale_val = int(scale) if scale else 1
				scale_bits = {1: 0b00, 2: 0b01, 4: 0b10, 8: 0b11}.get(scale_val)
				if scale_bits is None:
					raise NotImplementedError(f"Unsupported scale factor {scale_val} in: {instruction}")

				self.buffer.write_int(self.buffer.asm_offset, 0x8D, size=1)  # lea opcode
				self.buffer.asm_offset += 1

				use_sib = index is not None or base_code == 0x04

				# Decide ModRM mode based on displacement
				if disp_int or disp_label:
					mod = 0b10  # 32-bit disp
				elif base_code == 0x05:  # EBP with no displacement always requires disp
					mod = 0b01  # 8-bit disp
					disp_int = "0"
				else:
					mod = 0b00

				modrm = (mod << 6) | (dst_code << 3) | (0x04 if use_sib else base_code)
				self.buffer.write_int(self.buffer.asm_offset, modrm, size=1)
				self.buffer.asm_offset += 1

				if use_sib:
					sib = (scale_bits << 6) | (index_code << 3) | base_code
					self.buffer.write_int(self.buffer.asm_offset, sib, size=1)
					self.buffer.asm_offset += 1

				if disp_int:
					self.buffer.write_int(self.buffer.asm_offset, int(disp_int), size=4)
					self.buffer.asm_offset += 4
				elif disp_label:
					self._add_unresolved_label(disp_label)

			case "lea_index_disp":
				dst_reg, index, scale, disp_int, disp_label = groups

				if dst_reg not in reg_code or index not in reg_code:
					raise NotImplementedError(f"Unsupported register in lea: {instruction}")

				dst_code = reg_code[dst_reg]
				index_code = reg_code[index]
				scale_val = int(scale)
				scale_bits = {1: 0b00, 2: 0b01, 4: 0b10, 8: 0b11}.get(scale_val)
				if scale_bits is None:
					raise NotImplementedError(f"Unsupported scale factor {scale_val} in: {instruction}")

				self.buffer.write_int(self.buffer.asm_offset, 0x8D, size=1)
				self.buffer.asm_offset += 1

				mod = 0b00 if (disp_int or disp_label) else 0b01
				modrm = (mod << 6) | (dst_code << 3) | 0x04  # SIB always
				self.buffer.write_int(self.buffer.asm_offset, modrm, size=1)
				self.buffer.asm_offset += 1

				sib = (scale_bits << 6) | (index_code << 3) | 0x05  # base = none
				self.buffer.write_int(self.buffer.asm_offset, sib, size=1)
				self.buffer.asm_offset += 1

				if disp_int:
					self.buffer.write_int(self.buffer.asm_offset, int(disp_int), size=4)
					self.buffer.asm_offset += 4
				elif disp_label:
					self._add_unresolved_label(disp_label)

			case _:
				raise NotImplementedError(f"LEA format not implemented: {instruction}")


	def _encode_call(self, instruction: str) -> None:
		patterns = [
			("call_deref", re.compile(r"^call\s+dword\s*\[\s*<(\w+)>\s*\]$")),
			("call_raw", re.compile(r"^call\s+\[<(\w+)>\]$")),
		]

		call_type = None
		groups = None

		for type_name, pattern in patterns:
			match = pattern.match(instruction)
			if match:
				call_type = type_name
				groups = match.groups()
				break

		# print(f"Instruction '{instruction}' matched '{call_type}'")

		match call_type:
			case "call_deref":
				label = groups[0]
				self.buffer.write_int(self.buffer.asm_offset, 0xFF, size=1)  # opcode for indirect call
				self.buffer.asm_offset += 1
				self.buffer.write_int(self.buffer.asm_offset, 0x15, size=1)  # modrm for absolute [addr]
				self.buffer.asm_offset += 1
				self._add_unresolved_label(label)

			case "call_raw":
				label = groups[0]
				self.buffer.write_int(self.buffer.asm_offset, 0xE8, size=1)  # opcode for relative call
				self.buffer.asm_offset += 1
				self._add_unresolved_label(label)

			case _:
				raise NotImplementedError(f"Unsupported call format: {instruction}")


	def _encode_retn(self, instruction: str) -> None:
		match = re.fullmatch(r"ret(?:n)?(?:\s+(\d+))?", instruction.strip(), re.IGNORECASE)
		if not match:
			raise NotImplementedError(f"ret not implemented yet: {instruction}")

		imm = match.group(1)
		if imm is None:
			# ret / retn → opcode 0xC3
			self.buffer.write_int(self.buffer.asm_offset, 0xC3, size=1)
			self.buffer.asm_offset += 1
		else:
			# ret/retn imm16 → opcode 0xC2 + imm16
			self.buffer.write_int(self.buffer.asm_offset, 0xC2, size=1)
			self.buffer.asm_offset += 1
			self.buffer.write_int(self.buffer.asm_offset, int(imm, 16) & 0xFFFF, size=2)
			self.buffer.asm_offset += 2


	def _encode_nop(self, instruction: str) -> None:
		match = re.fullmatch(r"nop(?:\s+(\d+))?", instruction.strip(), re.IGNORECASE)
		if not match:
			raise NotImplementedError(f"nop not implemented yet: {instruction}")

		count = int(match.group(1)) if match.group(1) else 1
		for _ in range(count):
			self.buffer.write_int(self.buffer.asm_offset, 0x90, size=1)
			self.buffer.asm_offset += 1


	def _encode_test(self, instruction: str) -> None:
		match = re.fullmatch(r"test\s+\{([a-z0-9]{2,3})\},\{([a-z0-9]{2,3})\}", instruction.strip(), re.IGNORECASE)
		if not match:
			raise NotImplementedError(f"test not implemented yet: {instruction}")

		reg1, reg2 = match.group(1).lower(), match.group(2).lower()

		reg_code = {
			"al": 0, "cl": 1, "dl": 2, "bl": 3,
			"ah": 4, "ch": 5, "dh": 6, "bh": 7,
			"ax": 0, "cx": 1, "dx": 2, "bx": 3, "sp": 4, "bp": 5, "si": 6, "di": 7,
			"eax": 0, "ecx": 1, "edx": 2, "ebx": 3, "esp": 4, "ebp": 5, "esi": 6, "edi": 7
		}

		size = 0
		if reg1 in ("al", "cl", "dl", "bl", "ah", "ch", "dh", "bh"):
			opcode = 0x84
			size = 1
		elif reg1 in ("ax", "cx", "dx", "bx", "sp", "bp", "si", "di"):
			opcode = 0x66
			prefix = True
			size = 2
		elif reg1 in ("eax", "ecx", "edx", "ebx", "esp", "ebp", "esi", "edi"):
			opcode = 0x85
			size = 4
		else:
			raise NotImplementedError(f"Unknown register in test: {reg1}")

		if reg1 != reg2:
			raise NotImplementedError("test currently only supports same-register form")

		if size == 2:
			self.buffer.write_int(self.buffer.asm_offset, 0x66, size=1)
			self.buffer.asm_offset += 1
			self.buffer.write_int(self.buffer.asm_offset, 0x85, size=1)
			self.buffer.asm_offset += 1
		else:
			self.buffer.write_int(self.buffer.asm_offset, opcode, size=1)
			self.buffer.asm_offset += 1

		modrm = 0b11000000 | (reg_code[reg1] << 3) | reg_code[reg2]
		self.buffer.write_int(self.buffer.asm_offset, modrm, size=1)
		self.buffer.asm_offset += 1

	
	def _encode_fld(self, instruction: str) -> None:
		registers = {
			'eax': 0, 'ecx': 1, 'edx': 2, 'ebx': 3,
			'esp': 4, 'ebp': 5, 'esi': 6, 'edi': 7,
		}
		patterns = {
			"fld_mem": re.compile(r"fld\s+st\(0\),\s*dword\[\s*\{(?P<base>\w+)\}\s*\+\s*(?P<disp>\d+)\s*\]$", re.IGNORECASE),
		}

		for fld_type, pattern in patterns.items():
			match = pattern.match(instruction)
			if match:
				break

		# print(f"Instruction '{instruction}' matched {fld_type}")

		match fld_type:
			case "fld_mem":
				base = match.group("base").lower()
				disp = int(match.group("disp"), 0)

				if base not in registers:
					raise NotImplementedError(f"Unsupported base register in '{instruction}'")

				mod = 0b10  # mod=10: disp32
				reg = 0b000  # /0 for fld
				rm = registers[base]

				modrm = (mod << 6) | (reg << 3) | rm
				self.buffer.write_int(self.buffer.asm_offset, 0xD9, size=1)
				self.buffer.write_int(self.buffer.asm_offset, modrm, size=1)
				self.buffer.write_int(self.buffer.asm_offset, disp, size=4)
				return

		raise NotImplementedError(f"Unhandled fld variant in '{instruction}'")


	def add_instruction(self, instruction: str) -> None:
		"""
		Parses an assembly-like instruction and writes it to the buffer as machine code.

		:param instruction: Assembly-like instruction as a string.

		TODO - clean this fucking mess up
		"""
		instruction = instruction.strip()
		
		if "->" in instruction:
			hex_string = instruction.split(" -> ")[-1]
			hex_string = hex_string.strip().replace(" ", "")
			bytes_to_write = bytes.fromhex(hex_string)
			self.buffer.write(self.buffer.asm_offset, bytes_to_write)
			self.buffer.asm_offset += len(bytes_to_write)
			return
		elif instruction == "clc":
			self.buffer.write_int(self.buffer.asm_offset, 0xF8, size=1)
			self.buffer.asm_offset += 1
			return
		elif instruction == "repe movsb":
			self.buffer.write_int(self.buffer.asm_offset, 0xF3, size=1)
			self.buffer.asm_offset += 1
			self.buffer.write_int(self.buffer.asm_offset, 0xA4, size=1)
			self.buffer.asm_offset += 1
			return
		
		if "push" in instruction:
			return self._encode_push(instruction)
		elif "pop" in instruction:
			return self._encode_pop(instruction)
		elif re.match(r"^\s*(add|sub|cmp|xor|and|or|inc|dec|shl)\b", instruction, re.IGNORECASE):
			return self._encode_arithmetic(instruction)
		elif re.match(r"^\s*(jge|jae|jbe|ljmp|jmp|jz|jnz|je|jne|ja|jb|jl|jg|jo|jno|js|jns|jp|jnp|jc|jnc)\b", instruction, re.IGNORECASE):
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
		elif re.match(r"^\s*nop\b", instruction, re.IGNORECASE):
			return self._encode_nop(instruction)

		raise NotImplementedError(f"Instruction fell through all handlers: {instruction}")


	def assemble(self, base_address: int) -> None:
		"""
		Resolves all tracked symbolic labels and replaces them with base_address + offset.
		
			:param base_address: Address given by VirtualAllocEx as the entry point for buffer to be written
		"""
		for label, positions in self.unresolved_labels.items():
			if label not in self.buffer.labels:
				raise ValueError(f"Unresolved label: {label}")
			
			# final_addr = base_address + self.buffer.labels[label]
			final_addr = self.buffer.labels[label]
			for pos in positions:
				# print(f"Resolved label '{label}' to address 0x{final_addr:X} at offsets {pos}")
				# print(f"Original Bytes: {self.buffer.buffer[pos:pos+4]}")
				self.buffer.resolve_label(pos, final_addr)
				# print(f"New Bytes: {self.buffer.buffer[pos:pos+4]}")
			# print(f"Resolved label '{label}' to address 0x{final_addr:X} at offsets {positions}")
		# print(f"[ASSEMBLE] All control flow placeholders patched.")
		# print(f"Generated ASM String: {self.buffer.buffer.hex()}")
		# print(f"Total ASM Size: {self.buffer.asm_size}")



"""
TODO 
- rewrite the whole fucking _encode_jump
	- Always use 5byte placeholder for unconditional jumps
	- Always use 6byte placeholder for conditional jumps
	- Track relative jumps to resolve w/label resolution during assemble()

- x86 is fucking stupid
- retest Scanner buffer once done
- verify code cave buffer once relative jumps are fixed


"""