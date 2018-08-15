This repository collects the Verilog source files of a Zilog Z80 compatible
integrated processor design created as part of the _VLSI Processor Design_
course at TU-Dresden. The resulting processor has been extensively verified and
implements -with the exception of a few intentional omissions- the official
design specification. The `report` directory contains a very detailed report
(in German) describing the development process.

Because the design process was closely tied to proprietary and custom
toolchains, all simulation and build information has been removed. Also, some
source files contain instantiations of proprietary cells, which are also not
included.

The toplevel testcases found under `source/units/top_z80/simulation` were
automatically generated using the `ictest` tool specifically developed for this
purpose which can be obtained from [here](https://github.com/Time0o/TUD_ictest).

Some Z80 test programs written especially to verify the final synthesis results
can be found [here](https://github.com/Time0o/TUD_z80_testprogs).

In the future I will attempt to transform this project into a ready-to-use FPGA
soft core implementation.
