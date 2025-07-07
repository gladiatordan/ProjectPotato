import re
import logging



class Assembler:
	"""

	Basic assembler class 

	"""
	def __init__(self, buffer):
		self.buffer = buffer
		self.opcode_map = {
			"add": {
				"eax": "05",
				"ebx": "81C3",
				"ecx": "81C1",
				"edx": "81C2",
				"esi": "81C6",
				"edi": "81C7",
				"esp": "81C4",
				"ebp": "81C5",
			},
			"cmp": {
				"eax": "3D",
				"ebx": "81FB",
				"ecx": "81F9",
				"edx": "81FA",
			},
			"mov": {
				"eax": "A1", 
				"ebx": "8B1D", 
				"ecx": "8B0D", 
				"edx": "8B15",
				"DWORD": {
					"eax": "A1",
					"ebx": "8B1D",
					"ecx": "8B0D",
					"edx": "8B15",
					"esi": "8B35",
					"edi": "8B3D",
				},
			},
			"sub": {
				"eax": "81E8",
				"ebx": "81EB",
				"ecx": "81E9",
				"edx": "81EA",
			},
			"xor": {
				"eax": "31C0",
				"ecx": "31C9",
				"edx": "31D2",
				"ebx": "31DB",
			},
			"or": {
				"eax": "09C0",
			},
			"and": {
				"eax": "21C0",
			},
			"test": {
				"eax": "85C0",
				"ecx": "85C9",
				"edx": "85D2",
				"ebx": "85DB",
			},
		}
		
		self.add_opcodes = {
			"eax": "05",
			"ebx": "83C3",
			"ecx": "83C1",
			"edx": "83C2",
			"edi": "83C7",
			"esi": "83C6",
		} # why are these different?
		self.fixed_opcodes = {
			"nop": "90",
			"pushad": "60",
			"popad": "61",
			"mov ebx,dword[eax]": "8B18",
			"test eax,eax": "85C0",
			"test ebx,ebx": "85DB",
			"test ecx,ecx": "85C9",
			"mov dword[eax],0": "C70000000000",
			"push eax": "50",
			"push ebx": "53",
			"push ecx": "51",
			"push edx": "52",
			"push ebp": "55",
			"push esi": "56",
			"push edi": "57",
			"jmp ebx": "FFE3",
			"pop eax": "58",
			"pop ebx": "5B",
			"pop edx": "5A",
			"pop ecx": "59",
			"pop esi": "5E",
			"inc eax": "40",
			"inc ecx": "41",
			"inc ebx": "43",
			"dec edx": "4A",
			"mov edi,edx": "8BFA",
			"mov ecx,esi": "8BCE",
			"mov ecx,edi": "8BCF",
			"mov ecx,esp": "8BCC",
			"xor eax,eax": "33C0",
			"xor ecx,ecx": "33C9",
			"xor edx,edx": "33D2",
			"xor ebx,ebx": "33DB",
			"mov edx,eax": "8BD0",
			"mov edx,ecx": "8BD1",
			"mov ebp,esp": "8BEC",
			"sub esp,8": "83EC08",
			"cmp eax,0": "83F800",
		}


	def create_pattern(self, pattern):
		"""
		Creates a bytes representation of a hexidecimal pattern string
		to be added to the buffer.
		
		 :param pattern: The hexadecimal pattern as a string.
		"""
		cleaned_pattern = re.sub(r"[^0-9A-Fa-f]", "", pattern) # remove invalid characters
		return bytes.fromhex(cleaned_pattern)


	def set_label(self, name):
		"""
		Sets a label in the buffer for reference.
		
		 :param name: The name of the label.
		
		"""
		pos = self.buffer.asm_offset
		self.buffer.labels[name] = pos
		print(f"Label {name} set at position {pos}")


	def add_pattern(self, pattern):
		"""
		Adds a hexadecimal pattern to the buffer.

		 :param pattern: The hexadecimal pattern as a string.

		"""
		cleaned_pattern = re.sub(r"[^0-9A-Fa-f]", "", pattern)      # remove invalid characters
		pattern_bytes = bytes.fromhex(cleaned_pattern)
		self.buffer.write(self.buffer.asm_offset, pattern_bytes)
		self.buffer.asm_offset += len(pattern_bytes)
		print(f"Added pattern: {cleaned_pattern} (Size: {len(pattern_bytes)} bytes)")


	def _encode_arithmetic(self, instruction):
		"""
		Encodes arithmetic instructions like ADD and CMP.

		 :param instruction: add or cmp instruction to write to buffer
		
		"""
		match = re.match(r"(add|cmp) ([a-z]+),(.+)", instruction)
		if match:
			operation, dest, src = match.groups()
			if dest in self.opcode_map[operation]:
				opcode = self.opcode_map[operation][dest]
				if src.isdigit() or re.match(r"0x[0-9A-Fa-f]+", src): # src is an immediate value
					imm = int(src, 0) # parse as integer
					imm_size = 1 if imm <= 0xFF else 4 # determine immediate size
					imm_bytes = imm.to_bytes(imm_size, byteorder="little", signed=False)
					# don't call add_instruction here as the offset will be non-standard
					self.buffer.write(self.buffer.asm_offset, bytes.fromhex(opcode) + imm_bytes)
					self.buffer.asm_offset += len(opcode) // 2 + len(imm_bytes)
					print(f"Added {operation.upper()} {dest}, {src} (Immediate)")
				else:
					print(f"Unhandled {operation.upper()} with source: {src}")
			else:
				print(f"Unsupported destination register for {operation.upper()}: {dest}")
		else:
			print(f"Invalid arithmetic instruction: {instruction}")


	def _encode_logic(self, instruction):
		match = re.match(r"(sub|xor|or|and|test) ([a-z]+),([a-z0-9x]+)", instruction)
		if match:
			mnemonic, dest, src = match.groups()
			if dest in self.opcode_map.get(mnemonic, {}):
				opcode = self.opcode_map[mnemonic][dest]
				if src == dest:
					self._add_instruction(bytes.fromhex(opcode))
					print(f"Added {mnemonic.upper()} {dest},{src}")


	def _encode_mov(self, instruction):
		"""
		Encodes MOV instructions to be written to the buffer

		 :param instruction: MOV instruction to be encoded
		
		"""
		# register to register
		match = re.match(r"mov ([a-z]+),([a-z]+)", instruction)
		if match:
			dest, src = match.groups()
			reg_map = {
				"eax": 0b000, "ecx": 0b001, "edx": 0b010, "ebx": 0b011,
				"esp": 0b100, "ebp": 0b101, "esi": 0b110, "edi": 0b111,
			}

			if dest in reg_map and src in reg_map:
				modrm = 0b11000000 | (reg_map[dest] << 3) | reg_map[src]
				mov_bytes = b'\x89' + bytes([modrm])  # Opcode `89` for `MOV reg_dest, reg_src`
				self._add_instruction(mov_bytes)
				print(f"Added MOV {dest},{src} (Register-to-Register)")
				return
			
		# immediate to register
		match = re.match(r"mov ([a-z]+),([-0-9A-Fa-fx]+)", instruction)
		if match:
			dest, imm = match.groups()
			reg_map = {
				"eax": 0xB8, "ecx": 0xB9, "edx": 0xBA, "ebx": 0xBB,
				"esp": 0xBC, "ebp": 0xBD, "esi": 0xBE, "edi": 0xBF,
			}

			if dest in reg_map:
				imm_value = int(imm, 0)  # Parse as an integer
				imm_bytes = imm_value.to_bytes(4, byteorder="little", signed=False)
				mov_bytes = bytes([reg_map[dest]]) + imm_bytes
				self._add_instruction(mov_bytes)
				print(f"Added MOV {dest},{imm} (Immediate to Register)")
				return
		
		# memory to register and vise versa
		match = re.match(r"mov ([a-z]+),dword\[([a-z]+)\]", instruction)
		if match:
			dest, src = match.groups()
			opcode_map = {
				"eax": 0b000, "ecx": 0b001, "edx": 0b010, "ebx": 0b011,
				"esp": 0b100, "ebp": 0b101, "esi": 0b110, "edi": 0b111,
			}

			if dest in opcode_map:
				# Example case: mov eax, dword[esp]
				modrm = 0b00000100 | (reg_map[dest] << 3) | reg_map[src]
				mov_bytes = b'\x8B' + bytes([modrm])  # Opcode `8B` for `MOV reg_dest, [reg_src]`
				self._add_instruction(mov_bytes)
				print(f"Added MOV {dest},dword[{src}] (Memory to Register)")
				return

		match = re.match(r"mov dword\[([a-z]+)\],([a-z]+)", instruction)
		if match:
			dest, src = match.groups()
			reg_map = {
				"eax": 0b000, "ecx": 0b001, "edx": 0b010, "ebx": 0b011,
				"esp": 0b100, "ebp": 0b101, "esi": 0b110, "edi": 0b111,
			}

			if dest in reg_map and src in reg_map:
				modrm = 0b00000100 | (reg_map[src] << 3) | reg_map[dest]
				mov_bytes = b'\x89' + bytes([modrm])  # Opcode `89` for `MOV [reg_dest], reg_src`
				self._add_instruction(mov_bytes)
				print(f"Added MOV dword[{dest}],{src} (Register to Memory)")
				return
			
	
	def _encode_lea(self, instruction):
		"""
		Handles: lea reg, [Label]
		"""
		match = re.match(r"lea ([a-z]+),\[(\w+)([+-]0x[0-9A-Fa-f]+)?\]", instruction)
		if match:
			reg, label, offset = match.groups()
			if label not in self.buffer.labels:
				print(f"[WARN] Unknown label '{label}' in LEA")
				return

			address = self.buffer.labels[label]
			if offset:
				address += int(offset, 16)

			reg_map = {
				"eax": 0, "ecx": 1, "edx": 2, "ebx": 3,
				"esp": 4, "ebp": 5, "esi": 6, "edi": 7,
			}

			if reg not in reg_map:
				print(f"[ERROR] Unsupported register in LEA: {reg}")
				return

			modrm = 0x05 | (reg_map[reg] << 3)  # Mod = 00, R/M = 101 (disp32)
			lea_bytes = bytes([0x8D, modrm]) + address.to_bytes(4, 'little')
			self._add_instruction(lea_bytes)
			print(f"Added LEA {reg},[{label}{offset or ''}]")
	

	def _encode_call_indirect(self, instruction):
		"""
		Handles: call [Label]
		"""
		match = re.match(r"call \[(\w+)([+-]0x[0-9A-Fa-f]+)?\]", instruction)
		if match:
			label, offset = match.groups()
			if label not in self.buffer.labels:
				print(f"[WARN] Unknown label '{label}' in CALL")
				return

			address = self.buffer.labels[label]
			if offset:
				address += int(offset, 16)

			# Opcode FF /2 with modrm 0x15 (disp32)
			call_bytes = bytes([0xFF, 0x15]) + address.to_bytes(4, 'little')
			self._add_instruction(call_bytes)
			print(f"Added CALL [dword {label}{offset or ''}]")


	def _encode_symbolic_mov(self, instruction):
		"""
		Handles symbolic MOV expressions like:
		- mov eax,[Label]
		- mov [Label],eax
		- mov eax,[Label+0x4]
		- mov [Label+0x4],eax
		"""
		 # match: mov reg,[Label] or mov [Label],reg
		match = re.match(r"mov ([a-z]+),\[(\w+)([+-]0x[0-9A-Fa-f]+)?\]", instruction)
		if match:
			dest, label, offset = match.groups()
			if label not in self.buffer.labels:
				print(f"[WARN] Unknown label '{label}' in instruction: {instruction}")
				return

			address = self.buffer.labels[label]
			if offset:
				address += int(offset, 16)

			reg_map = {
				"eax": 0b000, "ecx": 0b001, "edx": 0b010, "ebx": 0b011,
				"esp": 0b100, "ebp": 0b101, "esi": 0b110, "edi": 0b111,
			}

			if dest in reg_map:
				# mov reg, [absolute_address]
				modrm = bytes([0x8B, 0x05 | (reg_map[dest] << 3)])  # 0x05 = mod 00, r/m 101 (disp32)
				disp = address.to_bytes(4, 'little')
				self._add_instruction(modrm + disp)
				print(f"Added MOV {dest},[{label}{offset or ''}] (Absolute)")
				return

		match = re.match(r"mov \[(\w+)([+-]0x[0-9A-Fa-f]+)?\],([a-z]+)", instruction)
		if match:
			label, offset, src = match.groups()
			if label not in self.buffer.labels:
				print(f"[WARN] Unknown label '{label}' in instruction: {instruction}")
				return

			address = self.buffer.labels[label]
			if offset:
				address += int(offset, 16)

			reg_map = {
				"eax": 0b000, "ecx": 0b001, "edx": 0b010, "ebx": 0b011,
				"esp": 0b100, "ebp": 0b101, "esi": 0b110, "edi": 0b111,
			}

			if src in reg_map:
				# mov [absolute_address], reg
				modrm = bytes([0x89, 0x05 | (reg_map[src] << 3)])  # 0x05 = mod 00, r/m 101
				disp = address.to_bytes(4, 'little')
				self._add_instruction(modrm + disp)
				print(f"Added MOV [{label}{offset or ''}],{src} (Absolute)")
				return


	def _add_jump(self, opcode, target, length):
		"""
		Adds a jump instruction (e.g., ljmp, ljne).

		 :param opcode: opcode signifying type of jump
		 :param target: destination for jump
		 :param length: length of instruction
		
		"""
		if target in self.buffer.labels:
			offset = self.buffer.labels[target] - (self.buffer.asm_offset + length)
			jump_bytes = bytes.fromhex(opcode) + offset.to_bytes(length - 1, byteorder="little", signed=True)
			self._add_instruction(jump_bytes)
			print(f"Added {opcode.upper()} to {target} (Offset: {offset})")
		else:
			self.buffer.unresolved_labels.append((self.buffer.asm_offset, f"{opcode} {target}"))
			placeholder = bytes.fromhex(opcode) + b'\x00' * (length - 1)
			self._add_instruction(placeholder)
			print(f"Unresolved jump to {target} (Placeholder added)")


	def _add_instruction(self, instruction):
		"""
		Internal method for writing instructions to the buffer

		 :param instruction: Instruction in bytes form
		"""
		self.buffer.write(self.buffer.asm_offset, instruction)
		self.buffer.asm_offset += len(instruction)


	def add_instruction(self, instruction):
		"""
		Parses an assembly-like instruction and writes it to the buffer as machine code.

		 :param instruction: Assembly-like instruction as a string.

		"""
		instruction = instruction.strip()

		# handle labels
		if instruction.endswith(":"):
			label_name = instruction[:-1]
			self.set_label(label_name)

		# handle labels with offsets
		elif "/" in instruction:
			# add offset after adding label
			label_name, offset = instruction.split("/")
			self.set_label(label_name)
			self.buffer.asm_offset += int(offset, 16)
			print(f"Added offset to Label {label_name} of size {offset}")
		
		# handle specific instruction types
		elif instruction.startswith("nop x"):
			count = int(instruction[5:])
			nop_bytes = b'\x90' * count
			self._add_instruction(nop_bytes)
		
		elif instruction.startswith("ljmp "):
			# long jump
			target = instruction[5:]
			self._add_jump("E9", target, 5)

		elif instruction.startswith("ljne "):
			# long jump if not equal
			target = instruction[5:]
			self._add_jump("0F85", target, 6)
		
		elif instruction.startswith("jmp "):
			# short jump
			target = instruction[4:]
			if target in self.buffer.labels:
				offset = self.buffer.labels[target] - (self.buffer.asm_offset + 2)
				# non standard encode, do manually
				self.buffer.write(self.buffer.asm_offset, b'\xEB' + offset.to_bytes(1, byteorder='little', signed=True))
				self.buffer.asm_offset += 2
				print(f"Added JMP to {target} (Offset: {offset})")
			else:
				self.buffer.unresolved_labels.append((self.buffer.asm_offset, instruction))
				# non standard encode, do manually
				self.buffer.write(self.buffer.asm_offset, b'\xEB\x00')
				self.buffer.asm_offset += 2
				print(f"Unresolved JMP to {target} (Placeholder added)")
		
		elif instruction.startswith("j"):
			# conditional jumps
			condition_map = {
				"jae": "73", "jz": "74", "jnz": "75",
				"jbe": "76", "ja": "77", "jl": "7C",
				"jge": "7D", "jle": "7E",
			}
			mnemonic, _, target = instruction.partition(" ")
			opcode = condition_map.get(mnemonic)
			if opcode:
				if target in self.labels:
					offset = self.labels[target] - (self.memory_buffer.asm_code_offset + 2)
					self.memory_buffer.write(self.memory_buffer.asm_code_offset, bytes.fromhex(opcode) + offset.to_bytes(1, byteorder='little', signed=True))
					self.memory_buffer.asm_code_offset += 2
					print(f"Added {mnemonic.upper()} to {target} (Offset: {offset})")
				else:
					self.unresolved.append((self.memory_buffer.asm_code_offset, instruction))
					self.memory_buffer.write(self.memory_buffer.asm_code_offset, bytes.fromhex(opcode) + b'\x00')  # Placeholder
					self.memory_buffer.asm_code_offset += 2
					print(f"Unresolved {mnemonic.upper()} to {target} (Placeholder added)")
		
		elif instruction.startswith("mov "):
			# mov instructions
			self._encode_mov(instruction)

		elif instruction.startswith("add ") or instruction.startswith("cmp "):
			# add|cmp instructions
			self._encode_arithmetic(instruction)

		elif instruction.startswith("sub", "xor", "or ", "and ", "test "):
			self._encode_logic(instruction)

		elif re.match(r"mov [a-z]+,\[", instruction) or re.match(r"mov \[", instruction):
			self._encode_symbolic_mov(instruction)
		
		elif instruction.startswith("lea "):
			self._encode_lea(instruction)

		elif instruction.startswith("call ["):
			self._encode_call_indirect(instruction)

		elif instruction in self.fixed_opcodes:
			# specific opcodes
			opcode = self.fixed_opcodes[instruction]
			opcode_bytes = bytes.fromhex(opcode)
			self._add_instruction(opcode_bytes)
			print(f"Added fixed opcode: {instruction} -> {opcode}")

		else:
			print(f"Unhandled instruction: {instruction}")


	def assemble(self):
		"""
		Resolves all unresolved symbolic control flow instructions by patching correct offsets.
		Should be called after all instructions are added.
		
		"""
		# TODO - implement this as Func CompleteASM()
		for pos, instr in self.buffer.unresolved_labels:
			instr = instr.strip()

			if instr.startswith("ljmp "):
				target = instr[5:]
				if target in self.buffer.labels:
					offset = self.buffer.labels[target] - (pos + 5)
					patch = b'\xE9' + offset.to_bytes(4, byteorder='little', signed=True)
					self.buffer.write(pos, patch)
					print(f"[PATCH] LJMP to {target}: Patched offset {offset} at {pos}")
			
			elif instr.startswith("ljne "):
				target = instr[5:]
				if target in self.buffer.labels:
					offset = self.buffer.labels[target] - (pos + 6)
					patch = b'\x0F\x85' + offset.to_bytes(4, byteorder='little', signed=True)
					self.buffer.write(pos, patch)
					print(f"[PATCH] LJNE to {target}: Patched offset {offset} at {pos}")

			elif instr.startswith("jmp "):
				target = instr[4:]
				if target in self.buffer.labels:
					offset = self.buffer.labels[target] - (pos + 2)
					patch = b'\xEB' + offset.to_bytes(1, byteorder='little', signed=True)
					self.buffer.write(pos, patch)
					print(f"[PATCH] JMP to {target}: Patched offset {offset} at {pos}")

			elif instr.startswith("call {") and instr.endswith("}"):
				target = instr[6:-1]
				if target in self.buffer.labels:
					offset = self.buffer.labels[target] - (pos + 5)
					patch = b'\xE8' + offset.to_bytes(4, byteorder='little', signed=True)
					self.buffer.write(pos, patch)
					print(f"[PATCH] CALL to {target}: Patched offset {offset} at {pos}")

			elif re.match(r"j[a-z]{1,2} ", instr):
				mnemonic, _, target = instr.partition(" ")
				condition_map = {
					"jae": "73", "jz": "74", "jnz": "75",
					"jbe": "76", "ja": "77", "jl": "7C",
					"jge": "7D", "jle": "7E",
				}
				opcode = condition_map.get(mnemonic)
				if opcode and target in self.buffer.labels:
					offset = self.buffer.labels[target] - (pos + 2)
					patch = bytes.fromhex(opcode) + offset.to_bytes(1, byteorder="little", signed=True)
					self.buffer.write(pos, patch)
					print(f"[PATCH] {mnemonic.upper()} to {target}: Patched offset {offset} at {pos}")
		
		print(f"[ASSEMBLE] All control flow placeholders patched.")
		print(f"Generated ASM String: {self.buffer.buffer}")
		print(f"Total ASM Size: {self.buffer.asm_size}")
