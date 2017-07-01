# FRANK6000
Multi single cicle 8 bits processor.

### Info
- Two/three cycle per instruction
- Data width: 8 bits
- Instruction width: 16 bits
- File register memory: 256 x 8
- Instruction memory: 256 x 16
- Instruction stack: 16 x 8
- Working register: 1 x 8
- Program counter: 1 x 8
- Address register: 1 x 8
- Status register: 1 x 3

### This repository includes
- FRANK6000.circ: the processor implementation for Logisim-evolution software (https://github.com/reds-heig/logisim-evolution).
- FRANK6000.ods: Spreadsheet with the instruction set, and their description.
- FRANK6000.png: Cool image of processor schematic.
- compiler.py: python compiler for the language.
- tests/: various tests for the processor.
- verilog/: a Verilog implementation of the processor (in progress).

### The processor
![alt tag](https://github.com/francocurotto/FRANK5000/blob/master/FRANK6000.png)

### Status
The Logisim version of the processor is complete. The Verilog version is complete. The last step is to encapsulate the processor in a module so you can easily load programs from the PC.
