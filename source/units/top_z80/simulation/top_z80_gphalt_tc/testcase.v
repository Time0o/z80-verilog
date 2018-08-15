unit.start("halt ('HALT')");

// BEGIN TESTCASE #0
top_z80_i.z80_i.cpu_i.controller_i.fsm_i.int_iff1 = 1'b1;

unit.assert_eq(1'b1, o_n_halt,
"N_HALT");

#(3 * CLKPERIOD);

unit.assert(top_z80_i.z80_i.cpu_i.controller_i.fsm_i.state == FSM_STATE_INSTR_FETCH1_1,
"STATE");
unit.assert(top_z80_i.z80_i.cpu_i.datapath_i.reg_pc_i.q == 8'h00,
"PC");
unit.assert_eq(1'b0, o_n_halt,
"N_HALT");

#(2 * CLKPERIOD);
unit.assert_eq(1'b0, o_n_halt,
"N_HALT");
#(CLKPERIOD);

unit.assert(top_z80_i.z80_i.cpu_i.controller_i.fsm_i.state == FSM_STATE_INSTR_FETCH1_1,
"STATE");
unit.assert(top_z80_i.z80_i.cpu_i.datapath_i.reg_pc_i.q == 8'h00,
"PC");
unit.assert_eq(1'b0, o_n_halt,
"N_HALT");

#(CLKPERIOD);
i_n_int = 1'b0;
#(CLKPERIOD);
i_n_int = 1'b1;
#(CLKPERIOD);

unit.assert(top_z80_i.z80_i.cpu_i.controller_i.fsm_i.state == FSM_STATE_ACK_INT_1,
"STATE");
unit.assert(top_z80_i.z80_i.cpu_i.datapath_i.reg_pc_i.q == 8'h00,
"PC");
unit.assert_eq(1'b1, o_n_halt,
"N_HALT");

unit.finish("halt ('HALT')");
