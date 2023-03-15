This folder contains source code for the alu.

The alu is designed to operate in a riscv pipeline.
  Alu operations are done on two 32 bit inputs, and the result is output on the 32 bit result signal.
  Operations include, add, subtract, logical right and left shift, arithmetic right shift, signed and unsigned set if less than, xor, or, and and.

Alu control signals are enumerated in the control_signals.sv file.
