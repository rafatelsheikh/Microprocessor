#!/usr/bin/env python3
"""
Simple 8-bit Processor Assembler
Converts assembly code to binary machine code
"""

import sys

class Assembler:
    def __init__(self):
        # Memory: 256 bytes, all initialized to zero (binary strings)
        self.memory = ['00000000'] * 256
        
        # Store label addresses (e.g., LOOP: -> address 25)
        self.labels = {}
        
        # Registers: R0, R1, R2, R3
        self.regs = {'R0': 0, 'R1': 1, 'R2': 2, 'R3': 3}
        
        # All 32 instructions with their opcodes
        self.opcodes = {
            'NOP': 0x0, 'MOV': 0x1, 'ADD': 0x2, 'SUB': 0x3,
            'AND': 0x4, 'OR': 0x5, 'RLC': 0x6, 'RRC': 0x6,
            'SETC': 0x6, 'CLRC': 0x6, 'PUSH': 0x7, 'POP': 0x7,
            'OUT': 0x7, 'IN': 0x7, 'NOT': 0x8, 'NEG': 0x8,
            'INC': 0x8, 'DEC': 0x8, 'JZ': 0x9, 'JN': 0x9,
            'JC': 0x9, 'JV': 0x9, 'LOOP': 0xA, 'JMP': 0xB,
            'CALL': 0xB, 'RET': 0xB, 'RTI': 0xB, 'LDM': 0xC,
            'LDD': 0xC, 'STD': 0xC, 'LDI': 0xD, 'STI': 0xE
        }
    
    def get_register(self, reg_name):
        """Convert register name (R0) to number (0)"""
        return self.regs[reg_name.upper().strip()]
    
    def get_value(self, text):
        """Convert number or label to integer value"""
        text = text.strip()
        
        # Is it a label?
        if text in self.labels:
            return self.labels[text]
        
        # Is it hex? (0xFF)
        if text.startswith('0x') or text.startswith('0X'):
            return int(text, 16) & 0xFF
        
        # It's decimal (123 or -5)
        num = int(text)
        if num < 0:
            num = 256 + num  # Convert negative to two's complement
        return num & 0xFF
    
    def to_binary_string(self, number):
        """Convert number to 8-bit binary string"""
        return format(number, '08b')
    
    def scan_labels(self, lines):
        """First pass: find all labels and their addresses"""
        address = 0
        
        for line in lines:
            # Remove comments
            line = line.split(';')[0].strip()
            if not line:
                continue
            
            # Check for section markers
            if line.lower() == 'interrupt_start:':
                address = 0  # Interrupt section: addresses 0-19
                continue
            elif line.lower() == 'main_start:':
                address = 20  # Main section: addresses 20-99
                continue
            
            # Is there a label? (LOOP:)
            if ':' in line:
                label_name = line.split(':')[0].strip()
                self.labels[label_name] = address
                line = line.split(':', 1)[1].strip()
            
            # Skip empty lines
            if not line:
                continue
            
            # Count instruction size
            instruction = line.split()[0].upper()
            if instruction in self.opcodes:
                # LDM, LDD, STD are 2 bytes, others are 1 byte
                if instruction in ['LDM', 'LDD', 'STD']:
                    address += 2
                else:
                    address += 1
    
    def assemble_instruction(self, line):
        """Convert one assembly instruction to machine code bytes"""
        # Split instruction into parts (remove commas)
        parts = line.replace(',', ' ').split()
        instruction = parts[0].upper()
        
        # Get opcode
        if instruction not in self.opcodes:
            return []
        
        opcode = self.opcodes[instruction]
        
        # --- Simple instructions (no operands) ---
        if instruction == 'NOP':
            return [opcode << 4]
        
        if instruction in ['SETC', 'CLRC']:
            ra = 2 if instruction == 'SETC' else 3
            return [(opcode << 4) | (ra << 2)]
        
        if instruction in ['RET', 'RTI']:
            brx = 2 if instruction == 'RET' else 3
            return [(opcode << 4) | (brx << 2)]
        
        # --- Two register instructions (ADD R0, R1) ---
        if instruction in ['MOV', 'ADD', 'SUB', 'AND', 'OR']:
            ra = self.get_register(parts[1])
            rb = self.get_register(parts[2])
            byte = (opcode << 4) | (ra << 2) | rb
            return [byte]
        
        # --- One register instructions with fixed ra ---
        if instruction in ['RLC', 'RRC']:
            ra = 0 if instruction == 'RLC' else 1
            rb = self.get_register(parts[1])
            return [(opcode << 4) | (ra << 2) | rb]
        
        if instruction in ['PUSH', 'POP', 'OUT', 'IN']:
            ra = {'PUSH': 0, 'POP': 1, 'OUT': 2, 'IN': 3}[instruction]
            rb = self.get_register(parts[1])
            return [(opcode << 4) | (ra << 2) | rb]
        
        if instruction in ['NOT', 'NEG', 'INC', 'DEC']:
            ra = {'NOT': 0, 'NEG': 1, 'INC': 2, 'DEC': 3}[instruction]
            rb = self.get_register(parts[1])
            return [(opcode << 4) | (ra << 2) | rb]
        
        # --- Branch instructions ---
        if instruction in ['JZ', 'JN', 'JC', 'JV']:
            brx = {'JZ': 0, 'JN': 1, 'JC': 2, 'JV': 3}[instruction]
            rb = self.get_register(parts[1])
            return [(opcode << 4) | (brx << 2) | rb]
        
        if instruction in ['JMP', 'CALL']:
            brx = 0 if instruction == 'JMP' else 1
            rb = self.get_register(parts[1])
            return [(opcode << 4) | (brx << 2) | rb]
        
        if instruction == 'LOOP':
            ra = self.get_register(parts[1])
            rb = self.get_register(parts[2])
            return [(opcode << 4) | (ra << 2) | rb]
        
        # --- Memory instructions ---
        if instruction == 'LDM':
            rb = self.get_register(parts[1])
            immediate = self.get_value(parts[2])
            byte1 = (opcode << 4) | rb  # ra=0 for LDM
            return [byte1, immediate]
        
        if instruction in ['LDD', 'STD']:
            ra = 1 if instruction == 'LDD' else 2
            rb = self.get_register(parts[1])
            address = self.get_value(parts[2])
            byte1 = (opcode << 4) | (ra << 2) | rb
            return [byte1, address]
        
        if instruction in ['LDI', 'STI']:
            rb = self.get_register(parts[1])
            ra = self.get_register(parts[2])
            return [(opcode << 4) | (ra << 2) | rb]
        
        return []
    
    def generate_machine_code(self, lines):
        """Second pass: convert all instructions to machine code"""
        pc = 0  # Program counter
        
        for line in lines:
            # Remove comments
            line = line.split(';')[0].strip()
            
            # Handle section markers
            if line.lower() == 'interrupt_start:':
                pc = 0
                continue
            elif line.lower() == 'main_start:':
                pc = 20
                continue
            
            # Remove label if present
            if ':' in line:
                line = line.split(':', 1)[1].strip()
            
            # Skip empty lines
            if not line:
                continue
            
            # Assemble the instruction
            machine_code = self.assemble_instruction(line)
            
            # Write bytes to memory
            for byte in machine_code:
                self.memory[pc] = self.to_binary_string(byte)
                pc += 1
    
    def assemble_file(self, input_file, output_file):
        """Main function: assemble the file"""
        # Read the assembly file
        with open(input_file, 'r') as f:
            lines = f.readlines()
        
        # Pass 1: Find all labels
        self.scan_labels(lines)
        
        # Pass 2: Generate machine code
        self.generate_machine_code(lines)
        
        # Write binary output
        with open(output_file, 'w') as f:
            for byte in self.memory:
                f.write(byte + '\n')
        
        print(f"✓ Assembly complete: {output_file}")


# Run the assembler
if __name__ == '__main__':
    if len(sys.argv) != 3:
        print("Usage: python assembler.py <input.asm> <output.dat>")
        sys.exit(1)
    
    assembler = Assembler()
    assembler.assemble_file(sys.argv[1], sys.argv[2])