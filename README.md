# Malak Advanced Calculator - x86 Assembly

A comprehensive calculator program written in x86 assembly language for DOS that provides arithmetic calculations and base conversions with a clean menu-driven interface.

## 🚀 Features

### 1. **Arithmetic Calculator**
- Supports all basic operations: `+`, `-`, `*`, `/`
- Advanced operations:
  - Modulus (`%`) - remainder calculation
  - Power (`^`) - exponentiation
  - Square root (`#`) - prefix operator (e.g., `#16`)
- Expression evaluation with operator precedence (left-to-right)
- Error handling for division by zero and overflow

### 2. **Number System Conversions**
- **Binary to Decimal/Hex**: Convert 16-bit binary numbers
- **Hex to Decimal/Binary**: Convert 4-digit hexadecimal numbers
- Real-time display in all three formats

### 3. **User-Friendly Interface**
- Clean menu system with clear options
- Interactive input with backspace support
- Clear screen functionality between operations
- Detailed error messages for invalid inputs

## 🛠️ Technical Implementation

### **Memory Segments**
- **Code Segment**: Starts at `100h` (COM file format)
- **Data Segment**: Inline data storage for messages and buffers
- **Stack**: Used for expression evaluation and temporary storage

### **Key Algorithms**
1. **Expression Parser**:
   - Recursive descent parsing for arithmetic expressions
   - Support for unary minus and square root prefix
   - Space-tolerant input handling

2. **Square Root Calculation**:
   - Integer-based iterative approximation
   - Error checking for negative inputs

3. **Power Function**:
   - Iterative multiplication with overflow detection
   - Support for positive exponents

4. **Base Conversion**:
   - Binary parsing with bit-shifting
   - Hexadecimal parsing with case-insensitive support
   - Efficient output formatting for all bases

### **System Integration**
- **DOS INT 21h** services for:
  - Console I/O (functions 01h, 02h, 09h)
  - Program termination (function 4Ch)
- **BIOS INT 10h** for screen clearing

## 📁 Project Structure

```
MALAK_CALCULATOR.ASM
├── Main Program Loop
│   ├── Clear Screen Routine
│   ├── Menu Display & Selection
│   └── Option Routing
├── Arithmetic Calculator Module
│   ├── Expression Evaluator
│   ├── Operator Functions (+, -, *, /, %, ^)
│   ├── Square Root Handler
│   └── Error Handlers
├── Conversion Modules
│   ├── Binary Parser & Formatter
│   └── Hexadecimal Parser & Formatter
├── Utility Functions
│   ├── Input Buffer Management
│   ├── Number Parsing
│   ├── Output Formatting
│   └── Screen Utilities
└── Data Section
    ├── String Messages
    ├── Input Buffers
    └── Temporary Variables
```

## 🔧 Assembly & Execution

### Requirements
- NASM or compatible x86 assembler
- DOSBox or real DOS environment
- 16-bit x86 compatible processor

### Assembly Command
```bash
nasm MALAK_CALCULATOR.ASM -f bin -o CALC.COM
```

### Execution
```bash
CALC.COM
```

## 💡 Technical Highlights

1. **Efficient Memory Usage**: Compact code with shared buffers
2. **Robust Error Handling**: Division by zero, overflow, and invalid input detection
3. **User Experience**: Backspace support, clear prompts, and consistent formatting
4. **Mathematical Accuracy**: Proper handling of signed 16-bit integers
5. **Modular Design**: Separated functionality for easy maintenance

## 🎯 Use Cases

- Educational tool for learning x86 assembly
- Practical demonstration of expression parsing
- Base conversion utility
- Reference implementation for DOS programming
- Foundation for more complex calculator applications

## 📝 Notes

- All calculations use 16-bit signed integers (-32,768 to 32,767)
- Square root returns integer results only (floor value)
- Power function supports positive exponents only
- Expression evaluation follows left-to-right precedence (no operator hierarchy)

---

*This project demonstrates practical x86 assembly programming with real-world application development, showcasing low-level system interaction, algorithmic implementation, and user interface design in a constrained environment.*
