# systemverilog-alu-and-testbench

This repository contains an alu, designed to operate in a riscv pipeline.

It also contains a testbench which performs a directed test on the alu.

Both the alu and testbench are written in systemverilog.

Alu design code can be found in the rtl_src folder.

Testbench code can be found in the tb folder.

vsim_comp and vsim_sim are shell scripts used to compile and simulate the sv files using modelsim.

Testbench output can be read in the transcript.txt file.

![diagram](https://user-images.githubusercontent.com/39601174/225287814-9f01c449-18e3-4dbf-9ad5-b4673b27e8d8.png)

Waveform of testbench simulation:
![waveform](https://user-images.githubusercontent.com/39601174/225491935-8221ab63-8a1a-402a-a669-9e769d97f2b7.png)
