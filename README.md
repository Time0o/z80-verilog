# Verilog Implementation of a Z80 Compatible Processor Architecture

## Introduction

This repository collects the Verilog source files of a Zilog Z80 compatible
integrated processor design created as part of the _VLSI Processor Design_
course at TU-Dresden. The resulting processor has been extensively verified and
implements -with the exception of a few intentional omissions- the official
design specification.

Because the design process was closely tied to proprietary and custom
toolchains, all simulation and build information has been removed. Also, some
source files contain instantiations of proprietary cells, which are also not
included.

The toplevel testcases found under `source/units/top_z80/simulation/` were
automatically generated using the `ictest` tool specifically developed for this
purpose and cover all valid Z80 instructions. Note that running `ictest` and
the generated testcases only possible in conjunction with a special IC design
tool suite used at TUD.

Some C test programs written especially to verify the final synthesis results.
These can be found under `testprogs/`.

More details about the design and implementation of this project can be found
(in German) in the report under `report/pdf/master.pdf`.

## Building

Since recreating the final ASIC design it is not possible without the missing
proprietary Verilog files, this project can be built in an Icarus Verilog
"compatibility mode" which replaces the former by a set of non-synthesizable
modules. Simply run `make test_processor` from this repositories root directory
(this might take a few minutes) which will create the file `run/z80_test`.

## Simulating Programs

Simulating abitrary Z80 programs for test purposes is simple, run `make
test_program PROG=some_program.c` which will compile `some_program.c` to Z80
byte code and place it under `run/progmem.txt`. Afterwards, change into the
`run` directory and run `vvp z80_test`, this will create a `run.vcd` waveform
dump that can be inspected using a waveform viewer such as GTKWave.
