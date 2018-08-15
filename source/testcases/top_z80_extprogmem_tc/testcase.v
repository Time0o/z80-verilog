unit.start("external memory instruction read");

#(7 * CLKPERIOD / 4);

// BEGIN TESTCASE #0
top_z80_i.z80_i.cpu_i.datapath_i.reg_pc_i.q = 16'h1000;

#(3 * CLKPERIOD);

unit.assert_eq8(8'h42, top_z80_i.z80_i.cpu_i.datapath_i.reg_instr_i.q,
"REG INSTR (Testcase #0)");

unit.finish("external memory instruction read");
