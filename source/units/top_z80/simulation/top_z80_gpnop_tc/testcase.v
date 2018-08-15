unit.start("nop ('NOP')");

// BEGIN TESTCASE #0
#(3 * CLKPERIOD);

unit.assert(top_z80_i.z80_i.cpu_i.controller_i.fsm_i.state == FSM_STATE_INSTR_FETCH1_1,
"STATE");
unit.assert(top_z80_i.z80_i.cpu_i.datapath_i.reg_pc_i.q == 8'h01,
"PC");

unit.finish("nop ('NOP')");
