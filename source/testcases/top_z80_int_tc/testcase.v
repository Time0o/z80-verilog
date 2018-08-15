unit.start("int ('(DI|EI|IM (0|1|2)), int, nmi')");

// BEGIN TESTCASE #0 (DI)
top_z80_i.z80_i.cpu_i.controller_i.fsm_i.int_iff1 = 1'b1;
top_z80_i.z80_i.cpu_i.controller_i.fsm_i.int_iff2 = 1'b1;

#(3 * CLKPERIOD);

unit.assert(top_z80_i.z80_i.cpu_i.controller_i.fsm_i.state == FSM_STATE_INSTR_FETCH1_1,
"STATE (Testcase #0)");

unit.assert_eq(1'b0, top_z80_i.z80_i.cpu_i.controller_i.fsm_i.int_iff1,
"IFF1 (Testcase #0)");
unit.assert_eq(1'b0, top_z80_i.z80_i.cpu_i.controller_i.fsm_i.int_iff2,
"IFF2 (Testcase #0)");

// BEGIN TESTCASE #1 (EI)
top_z80_i.z80_i.cpu_i.controller_i.fsm_i.int_iff1 = 1'b0;
top_z80_i.z80_i.cpu_i.controller_i.fsm_i.int_iff2 = 1'b0;

#(3 * CLKPERIOD);

unit.assert(top_z80_i.z80_i.cpu_i.controller_i.fsm_i.state == FSM_STATE_INSTR_FETCH1_1,
"STATE (Testcase #1)");

unit.assert_eq(1'b1, top_z80_i.z80_i.cpu_i.controller_i.fsm_i.int_iff1,
"IFF1 (Testcase #1)");
unit.assert_eq(1'b1, top_z80_i.z80_i.cpu_i.controller_i.fsm_i.int_iff2,
"IFF2 (Testcase #1)");

// BEGIN TESTCASE #2 (IM 0)
top_z80_i.z80_i.cpu_i.controller_i.fsm_i.int_mode = INT_MODE_1;

#(6 * CLKPERIOD);

unit.assert(top_z80_i.z80_i.cpu_i.controller_i.fsm_i.state == FSM_STATE_INSTR_FETCH1_1,
"STATE (Testcase #2)");

unit.assert(top_z80_i.z80_i.cpu_i.controller_i.fsm_i.int_mode == INT_MODE_0,
"INT MODE (Testcase #2)");

// BEGIN TESTCASE #3 (IM 1)
top_z80_i.z80_i.cpu_i.controller_i.fsm_i.int_mode = INT_MODE_0;

#(6 * CLKPERIOD);

unit.assert(top_z80_i.z80_i.cpu_i.controller_i.fsm_i.state == FSM_STATE_INSTR_FETCH1_1,
"STATE (Testcase #3)");

unit.assert(top_z80_i.z80_i.cpu_i.controller_i.fsm_i.int_mode == INT_MODE_1,
"INT MODE (Testcase #3)");

// BEGIN TESTCASE #4 (IM 1)
top_z80_i.z80_i.cpu_i.controller_i.fsm_i.int_mode = INT_MODE_0;

#(6 * CLKPERIOD);

unit.assert(top_z80_i.z80_i.cpu_i.controller_i.fsm_i.state == FSM_STATE_INSTR_FETCH1_1,
"STATE (Testcase #4)");

unit.assert(top_z80_i.z80_i.cpu_i.controller_i.fsm_i.int_mode == INT_MODE_2,
"INT MODE (Testcase #4)");

// BEGIN TESTCASE #5 (INT MODE 0)
top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.a = 16'h0000;
top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.b = 8'h42;
top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.c = 8'h00;

top_z80_i.z80_i.cpu_i.controller_i.fsm_i.int_iff1 = 1'b1;
top_z80_i.z80_i.cpu_i.controller_i.fsm_i.int_iff2 = 1'b1;
top_z80_i.z80_i.cpu_i.controller_i.fsm_i.int_mode = INT_MODE_0;

#(CLKPERIOD);
i_n_int = 1'b0;
#(CLKPERIOD);
i_n_int = 1'b1;
#(4 * CLKPERIOD);
unit.assert_eq(1'b1, top_z80_i.z80_i.cpu_i.controller_i.fsm_i.int_active_int,
"INT ACTIVE (Testcase #5)");
unit.assert_eq(1'b0, top_z80_i.z80_i.cpu_i.controller_i.fsm_i.int_active_nmi,
"NMI ACTIVE (Testcase #5)");
#(2 * CLKPERIOD);

unit.assert(top_z80_i.z80_i.cpu_i.controller_i.fsm_i.state == FSM_STATE_INSTR_FETCH1_1,
"STATE (Testcase #5)");
unit.assert_eq16(16'h0009, top_z80_i.z80_i.cpu_i.datapath_i.reg_pc_i.q,
"PC (Testcase #5)");
unit.assert_eq16(8'h42, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.a,
"A (Testcase #5)");

unit.assert_eq(1'b1, top_z80_i.z80_i.cpu_i.controller_i.fsm_i.int_iff1,
"IFF1 (Testcase #5)");
unit.assert_eq(1'b1, top_z80_i.z80_i.cpu_i.controller_i.fsm_i.int_iff2,
"IFF2 (Testcase #5)");
unit.assert_eq(1'b0, top_z80_i.z80_i.cpu_i.controller_i.fsm_i.int_active_int,
"INT ACTIVE (Testcase #5)");
unit.assert_eq(1'b0, top_z80_i.z80_i.cpu_i.controller_i.fsm_i.int_active_nmi,
"NMI ACTIVE (Testcase #5)");

// BEGIN TESTCASE #6 (INT MODE 1)
top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.sp = 16'h0042;

top_z80_i.z80_i.cpu_i.controller_i.fsm_i.int_iff1 = 1'b1;
top_z80_i.z80_i.cpu_i.controller_i.fsm_i.int_iff2 = 1'b1;
top_z80_i.z80_i.cpu_i.controller_i.fsm_i.int_mode = INT_MODE_1;

#(CLKPERIOD);
i_n_int = 1'b0;
#(CLKPERIOD);
i_n_int = 1'b1;
#(10 * CLKPERIOD);
unit.assert_eq(1'b1, top_z80_i.z80_i.cpu_i.controller_i.fsm_i.int_active_int,
"INT ACTIVE (Testcase #6)");
unit.assert_eq(1'b0, top_z80_i.z80_i.cpu_i.controller_i.fsm_i.int_active_nmi,
"NMI ACTIVE (Testcase #6)");
#(3 * CLKPERIOD / 4);

unit.assert(top_z80_i.z80_i.cpu_i.controller_i.fsm_i.state == FSM_STATE_INSTR_FETCH1_1,
"STATE (Testcase #6)");
unit.assert_eq16(16'h0038, top_z80_i.z80_i.cpu_i.datapath_i.reg_pc_i.q,
"PC (Testcase #6)");
top_z80_i.z80_i.cpu_i.datapath_i.reg_pc_i.q = 16'h000A;
unit.assert_eq16(16'h0040, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.sp,
"SP (Testcase #6)");

unit.assert_eq8(8'h00, top_z80_i.z80_i.memory_control_i.idram_i.SY180_256X8X1CM8_i1.Memory[13'h0041],
"DMEM (Testcase #6)");
unit.assert_eq8(8'h0A, top_z80_i.z80_i.memory_control_i.idram_i.SY180_256X8X1CM8_i1.Memory[13'h0040],
"DMEM (Testcase #6)");
top_z80_i.z80_i.memory_control_i.idram_i.SY180_256X8X1CM8_i1.Memory[13'h0041]
= datamem_swap[13'h0041];
top_z80_i.z80_i.memory_control_i.idram_i.SY180_256X8X1CM8_i1.Memory[13'h0040]
= datamem_swap[13'h0040];

unit.assert_eq(1'b1, top_z80_i.z80_i.cpu_i.controller_i.fsm_i.int_iff1,
"IFF1 (Testcase #6)");
unit.assert_eq(1'b1, top_z80_i.z80_i.cpu_i.controller_i.fsm_i.int_iff2,
"IFF2 (Testcase #6)");
unit.assert_eq(1'b0, top_z80_i.z80_i.cpu_i.controller_i.fsm_i.int_active_int,
"INT ACTIVE (Testcase #6)");
unit.assert_eq(1'b0, top_z80_i.z80_i.cpu_i.controller_i.fsm_i.int_active_nmi,
"NMI ACTIVE (Testcase #6)");

#(CLKPERIOD / 4);

// BEGIN TESTCASE #7 (INT MODE 2)
top_z80_i.z80_i.cpu_i.datapath_i.reg_int_ctrl_i.q = 8'h01;
top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.sp = 16'h0042;

top_z80_i.z80_i.cpu_i.controller_i.fsm_i.int_iff1 = 1'b1;
top_z80_i.z80_i.cpu_i.controller_i.fsm_i.int_iff2 = 1'b1;
top_z80_i.z80_i.cpu_i.controller_i.fsm_i.int_mode = INT_MODE_2;

#(CLKPERIOD);
i_n_int = 1'b0;
#(CLKPERIOD);
i_n_int = 1'b1;
#(16 * CLKPERIOD);
unit.assert_eq(1'b1, top_z80_i.z80_i.cpu_i.controller_i.fsm_i.int_active_int,
"INT ACTIVE (Testcase #7)");
unit.assert_eq(1'b0, top_z80_i.z80_i.cpu_i.controller_i.fsm_i.int_active_nmi,
"NMI ACTIVE (Testcase #7)");
#(3 * CLKPERIOD / 4);

unit.assert(top_z80_i.z80_i.cpu_i.controller_i.fsm_i.state == FSM_STATE_INSTR_FETCH1_1,
"STATE (Testcase #7)");
unit.assert_eq16(16'h01FF, top_z80_i.z80_i.cpu_i.datapath_i.reg_pc_i.q,
"PC (Testcase #7)");
top_z80_i.z80_i.cpu_i.datapath_i.reg_pc_i.q = 16'h000B;
unit.assert_eq16(16'h0040, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.sp,
"SP (Testcase #7)");

unit.assert_eq8(8'h00, top_z80_i.z80_i.memory_control_i.idram_i.SY180_256X8X1CM8_i1.Memory[13'h0041],
"DMEM (Testcase #7)");
unit.assert_eq8(8'h0B, top_z80_i.z80_i.memory_control_i.idram_i.SY180_256X8X1CM8_i1.Memory[13'h0040],
"DMEM (Testcase #7)");
top_z80_i.z80_i.memory_control_i.idram_i.SY180_256X8X1CM8_i1.Memory[13'h0041]
= datamem_swap[13'h0041];
top_z80_i.z80_i.memory_control_i.idram_i.SY180_256X8X1CM8_i1.Memory[13'h0040]
= datamem_swap[13'h0040];

unit.assert_eq(1'b1, top_z80_i.z80_i.cpu_i.controller_i.fsm_i.int_iff1,
"IFF1 (Testcase #7)");
unit.assert_eq(1'b1, top_z80_i.z80_i.cpu_i.controller_i.fsm_i.int_iff2,
"IFF2 (Testcase #7)");
unit.assert_eq(1'b0, top_z80_i.z80_i.cpu_i.controller_i.fsm_i.int_active_int,
"INT ACTIVE (Testcase #7)");
unit.assert_eq(1'b0, top_z80_i.z80_i.cpu_i.controller_i.fsm_i.int_active_nmi,
"NMI ACTIVE (Testcase #7)");

#(CLKPERIOD / 4);

// BEGIN TESTCASE #8 (NMI)
top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.sp = 16'h0042;

top_z80_i.z80_i.cpu_i.controller_i.fsm_i.int_iff1 = 1'b1;
top_z80_i.z80_i.cpu_i.controller_i.fsm_i.int_iff2 = 1'b0;

#(CLKPERIOD);
i_n_nmi = 1'b0;
#(CLKPERIOD);
i_n_nmi = 1'b1;
#(8 * CLKPERIOD);
unit.assert_eq(1'b0, top_z80_i.z80_i.cpu_i.controller_i.fsm_i.int_active_int,
"INT ACTIVE (Testcase #8)");
unit.assert_eq(1'b1, top_z80_i.z80_i.cpu_i.controller_i.fsm_i.int_active_nmi,
"NMI ACTIVE (Testcase #8)");
#(3 * CLKPERIOD / 4);

unit.assert(top_z80_i.z80_i.cpu_i.controller_i.fsm_i.state == FSM_STATE_INSTR_FETCH1_1,
"STATE (Testcase #8)");
unit.assert_eq16(16'h0066, top_z80_i.z80_i.cpu_i.datapath_i.reg_pc_i.q,
"PC (Testcase #8)");
top_z80_i.z80_i.cpu_i.datapath_i.reg_pc_i.q = 16'h000C;
unit.assert_eq16(16'h0040, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.sp,
"SP (Testcase #8)");

unit.assert_eq8(8'h00, top_z80_i.z80_i.memory_control_i.idram_i.SY180_256X8X1CM8_i1.Memory[13'h0041],
"DMEM (Testcase #8)");
unit.assert_eq8(8'h0C, top_z80_i.z80_i.memory_control_i.idram_i.SY180_256X8X1CM8_i1.Memory[13'h0040],
"DMEM (Testcase #8)");
top_z80_i.z80_i.memory_control_i.idram_i.SY180_256X8X1CM8_i1.Memory[13'h0041]
= datamem_swap[13'h0041];
top_z80_i.z80_i.memory_control_i.idram_i.SY180_256X8X1CM8_i1.Memory[13'h0040]
= datamem_swap[13'h0040];

unit.assert_eq(1'b0, top_z80_i.z80_i.cpu_i.controller_i.fsm_i.int_iff1,
"IFF1 (Testcase #8)");
unit.assert_eq(1'b1, top_z80_i.z80_i.cpu_i.controller_i.fsm_i.int_iff2,
"IFF2 (Testcase #8)");
unit.assert_eq(1'b0, top_z80_i.z80_i.cpu_i.controller_i.fsm_i.int_active_int,
"INT ACTIVE (Testcase #8)");
unit.assert_eq(1'b0, top_z80_i.z80_i.cpu_i.controller_i.fsm_i.int_active_nmi,
"NMI ACTIVE (Testcase #8)");

#(CLKPERIOD / 4);

// BEGIN TESTCASE #9 (Only NMIs recognized during DI)
top_z80_i.z80_i.cpu_i.controller_i.fsm_i.int_iff1 = 1'b1;
top_z80_i.z80_i.cpu_i.controller_i.fsm_i.int_iff2 = 1'b1;
top_z80_i.z80_i.cpu_i.controller_i.fsm_i.int_mode = INT_MODE_0;

#(CLKPERIOD);
i_n_int = 1'b0;
#(CLKPERIOD);
i_n_int = 1'b1;
#(CLKPERIOD);

unit.assert(top_z80_i.z80_i.cpu_i.controller_i.fsm_i.state == FSM_STATE_INSTR_FETCH1_1,
"STATE (Testcase #9)");
unit.assert_eq16(16'h000D, top_z80_i.z80_i.cpu_i.datapath_i.reg_pc_i.q,
"PC (Testcase #9)");

unit.assert_eq(1'b0, top_z80_i.z80_i.cpu_i.controller_i.fsm_i.int_iff1,
"IFF1 (Testcase #9)");
top_z80_i.z80_i.cpu_i.controller_i.fsm_i.int_iff1 = 1'b1;
unit.assert_eq(1'b0, top_z80_i.z80_i.cpu_i.controller_i.fsm_i.int_iff2,
"IFF2 (Testcase #9)");
top_z80_i.z80_i.cpu_i.controller_i.fsm_i.int_iff2 = 1'b1;
unit.assert_eq(1'b0, top_z80_i.z80_i.cpu_i.controller_i.fsm_i.int_active_int,
"INT ACTIVE (Testcase #9)");

#(CLKPERIOD);
i_n_int = 1'b0;
#(CLKPERIOD);
i_n_int = 1'b1;
#(CLKPERIOD);

unit.assert(top_z80_i.z80_i.cpu_i.controller_i.fsm_i.state == FSM_STATE_ACK_INT_1,
"STATE (Testcase #9)");

unit.assert_eq(1'b1, top_z80_i.z80_i.cpu_i.controller_i.fsm_i.int_iff1,
"IFF1 (Testcase #9)");
unit.assert_eq(1'b1, top_z80_i.z80_i.cpu_i.controller_i.fsm_i.int_iff2,
"IFF2 (Testcase #9)");
unit.assert_eq(1'b1, top_z80_i.z80_i.cpu_i.controller_i.fsm_i.int_active_int,
"INT ACTIVE (Testcase #9)");

#(5 * CLKPERIOD);

unit.assert(top_z80_i.z80_i.cpu_i.controller_i.fsm_i.state == FSM_STATE_INSTR_FETCH1_1,
"STATE (Testcase #9)");
unit.assert_eq16(16'h000E, top_z80_i.z80_i.cpu_i.datapath_i.reg_pc_i.q,
"PC (Testcase #9)");

unit.assert_eq(1'b1, top_z80_i.z80_i.cpu_i.controller_i.fsm_i.int_iff1,
"IFF1 (Testcase #9)");
unit.assert_eq(1'b1, top_z80_i.z80_i.cpu_i.controller_i.fsm_i.int_iff2,
"IFF2 (Testcase #9)");
unit.assert_eq(1'b0, top_z80_i.z80_i.cpu_i.controller_i.fsm_i.int_active_int,
"INT ACTIVE (Testcase #9)");

#(CLKPERIOD);
i_n_nmi = 1'b0;
#(CLKPERIOD);
i_n_nmi = 1'b1;
#(CLKPERIOD);

unit.assert(top_z80_i.z80_i.cpu_i.controller_i.fsm_i.state == FSM_STATE_ACK_NMI_1,
"STATE (Testcase #9)");

unit.assert_eq(1'b0, top_z80_i.z80_i.cpu_i.controller_i.fsm_i.int_iff1,
"IFF1 (Testcase #9)");
top_z80_i.z80_i.cpu_i.controller_i.fsm_i.int_iff1 = 1'b1;
unit.assert_eq(1'b0, top_z80_i.z80_i.cpu_i.controller_i.fsm_i.int_iff2,
"IFF2 (Testcase #9)");
top_z80_i.z80_i.cpu_i.controller_i.fsm_i.int_iff2 = 1'b1;
unit.assert_eq(1'b1, top_z80_i.z80_i.cpu_i.controller_i.fsm_i.int_active_nmi,
"NMI ACTIVE (Testcase #9)");

#(7 * CLKPERIOD + 3 * CLKPERIOD / 4);

unit.assert(top_z80_i.z80_i.cpu_i.controller_i.fsm_i.state == FSM_STATE_INSTR_FETCH1_1,
"STATE (Testcase #9)");
unit.assert_eq16(16'h0066, top_z80_i.z80_i.cpu_i.datapath_i.reg_pc_i.q,
"PC (Testcase #9)");
top_z80_i.z80_i.cpu_i.datapath_i.reg_pc_i.q = 16'h000F;

unit.assert_eq(1'b1, top_z80_i.z80_i.cpu_i.controller_i.fsm_i.int_iff1,
"IFF1 (Testcase #9)");
unit.assert_eq(1'b1, top_z80_i.z80_i.cpu_i.controller_i.fsm_i.int_iff2,
"IFF2 (Testcase #9)");
unit.assert_eq(1'b0, top_z80_i.z80_i.cpu_i.controller_i.fsm_i.int_active_nmi,
"NMI ACTIVE (Testcase #9)");

#(CLKPERIOD / 4);

// BEGIN TESTCASE #10 (Only NMIs recognized during EI)
top_z80_i.z80_i.cpu_i.controller_i.fsm_i.int_iff1 = 1'b0;
top_z80_i.z80_i.cpu_i.controller_i.fsm_i.int_iff2 = 1'b0;
top_z80_i.z80_i.cpu_i.controller_i.fsm_i.int_mode = INT_MODE_0;

#(CLKPERIOD);
i_n_int = 1'b0;
#(CLKPERIOD);
i_n_int = 1'b1;
#(CLKPERIOD);

unit.assert(top_z80_i.z80_i.cpu_i.controller_i.fsm_i.state == FSM_STATE_INSTR_FETCH1_1,
"STATE (Testcase #10)");
unit.assert_eq16(16'h0010, top_z80_i.z80_i.cpu_i.datapath_i.reg_pc_i.q,
"PC (Testcase #10)");

unit.assert_eq(1'b1, top_z80_i.z80_i.cpu_i.controller_i.fsm_i.int_iff1,
"IFF1 (Testcase #10)");
unit.assert_eq(1'b1, top_z80_i.z80_i.cpu_i.controller_i.fsm_i.int_iff2,
"IFF2 (Testcase #10)");
unit.assert_eq(1'b0, top_z80_i.z80_i.cpu_i.controller_i.fsm_i.int_active_int,
"INT ACTIVE (Testcase #10)");

#(CLKPERIOD);
i_n_int = 1'b0;
#(CLKPERIOD);
i_n_int = 1'b1;
#(CLKPERIOD);

unit.assert(top_z80_i.z80_i.cpu_i.controller_i.fsm_i.state == FSM_STATE_INSTR_FETCH1_1,
"STATE (Testcase #10)");
unit.assert_eq16(16'h0011, top_z80_i.z80_i.cpu_i.datapath_i.reg_pc_i.q,
"PC (Testcase #10)");

unit.assert_eq(1'b1, top_z80_i.z80_i.cpu_i.controller_i.fsm_i.int_iff1,
"IFF1 (Testcase #10)");
unit.assert_eq(1'b1, top_z80_i.z80_i.cpu_i.controller_i.fsm_i.int_iff2,
"IFF2 (Testcase #10)");
unit.assert_eq(1'b0, top_z80_i.z80_i.cpu_i.controller_i.fsm_i.int_active_int,
"INT ACTIVE (Testcase #10)");

#(CLKPERIOD);
i_n_int = 1'b0;
#(CLKPERIOD);
i_n_int = 1'b1;
#(CLKPERIOD);

unit.assert(top_z80_i.z80_i.cpu_i.controller_i.fsm_i.state == FSM_STATE_ACK_INT_1,
"STATE (Testcase #10)");

unit.assert_eq(1'b1, top_z80_i.z80_i.cpu_i.controller_i.fsm_i.int_iff1,
"IFF1 (Testcase #10)");
unit.assert_eq(1'b1, top_z80_i.z80_i.cpu_i.controller_i.fsm_i.int_iff2,
"IFF2 (Testcase #10)");
unit.assert_eq(1'b1, top_z80_i.z80_i.cpu_i.controller_i.fsm_i.int_active_int,
"INT ACTIVE (Testcase #10)");

#(5 * CLKPERIOD);

unit.assert(top_z80_i.z80_i.cpu_i.controller_i.fsm_i.state == FSM_STATE_INSTR_FETCH1_1,
"STATE (Testcase #10)");
unit.assert_eq16(16'h0012, top_z80_i.z80_i.cpu_i.datapath_i.reg_pc_i.q,
"PC (Testcase #10)");

unit.assert_eq(1'b1, top_z80_i.z80_i.cpu_i.controller_i.fsm_i.int_iff1,
"IFF1 (Testcase #10)");
unit.assert_eq(1'b1, top_z80_i.z80_i.cpu_i.controller_i.fsm_i.int_iff2,
"IFF2 (Testcase #10)");
unit.assert_eq(1'b0, top_z80_i.z80_i.cpu_i.controller_i.fsm_i.int_active_int,
"INT ACTIVE (Testcase #10)");

#(CLKPERIOD);
i_n_nmi = 1'b0;
#(CLKPERIOD);
i_n_nmi = 1'b1;
#(CLKPERIOD);

unit.assert(top_z80_i.z80_i.cpu_i.controller_i.fsm_i.state == FSM_STATE_ACK_NMI_1,
"STATE (Testcase #10)");

unit.assert_eq(1'b1, top_z80_i.z80_i.cpu_i.controller_i.fsm_i.int_iff1,
"IFF1 (Testcase #10)");
unit.assert_eq(1'b1, top_z80_i.z80_i.cpu_i.controller_i.fsm_i.int_iff2,
"IFF2 (Testcase #10)");
unit.assert_eq(1'b1, top_z80_i.z80_i.cpu_i.controller_i.fsm_i.int_active_nmi,
"NMI ACTIVE (Testcase #10)");

#(7 * CLKPERIOD + 3 * CLKPERIOD / 4);

unit.assert(top_z80_i.z80_i.cpu_i.controller_i.fsm_i.state == FSM_STATE_INSTR_FETCH1_1,
"STATE (Testcase #10)");
unit.assert_eq16(16'h0066, top_z80_i.z80_i.cpu_i.datapath_i.reg_pc_i.q,
"PC (Testcase #10)");
top_z80_i.z80_i.cpu_i.datapath_i.reg_pc_i.q = 16'h0013;

unit.assert_eq(1'b1, top_z80_i.z80_i.cpu_i.controller_i.fsm_i.int_iff1,
"IFF1 (Testcase #10)");
unit.assert_eq(1'b1, top_z80_i.z80_i.cpu_i.controller_i.fsm_i.int_iff2,
"IFF2 (Testcase #10)");
unit.assert_eq(1'b0, top_z80_i.z80_i.cpu_i.controller_i.fsm_i.int_active_nmi,
"NMI ACTIVE (Testcase #10)");

#(CLKPERIOD / 4);

// BEGIN TESTCASE #11 (IFF1 can disable INTs but not NMIs)
top_z80_i.z80_i.cpu_i.controller_i.fsm_i.int_iff1 = 1'b0;
top_z80_i.z80_i.cpu_i.controller_i.fsm_i.int_iff2 = 1'b1;

#(CLKPERIOD);
i_n_int = 1'b0;
#(CLKPERIOD);
i_n_int = 1'b1;
#(CLKPERIOD);

unit.assert(top_z80_i.z80_i.cpu_i.controller_i.fsm_i.state == FSM_STATE_INSTR_FETCH1_1,
"STATE (Testcase #11)");
unit.assert_eq16(16'h0014, top_z80_i.z80_i.cpu_i.datapath_i.reg_pc_i.q,
"PC (Testcase #11)");

unit.assert_eq(1'b0, top_z80_i.z80_i.cpu_i.controller_i.fsm_i.int_iff1,
"IFF1 (Testcase #11)");
unit.assert_eq(1'b1, top_z80_i.z80_i.cpu_i.controller_i.fsm_i.int_iff2,
"IFF2 (Testcase #11)");
unit.assert_eq(1'b0, top_z80_i.z80_i.cpu_i.controller_i.fsm_i.int_active_int,
"INT ACTIVE (Testcase #11)");

top_z80_i.z80_i.cpu_i.controller_i.fsm_i.int_iff1 = 1'b1;
top_z80_i.z80_i.cpu_i.controller_i.fsm_i.int_iff2 = 1'b0;

#(CLKPERIOD);
i_n_int = 1'b0;
#(CLKPERIOD);
i_n_int = 1'b1;
#(CLKPERIOD);

unit.assert(top_z80_i.z80_i.cpu_i.controller_i.fsm_i.state == FSM_STATE_ACK_INT_1,
"STATE (Testcase #11)");

unit.assert_eq(1'b1, top_z80_i.z80_i.cpu_i.controller_i.fsm_i.int_iff1,
"IFF1 (Testcase #11)");
unit.assert_eq(1'b0, top_z80_i.z80_i.cpu_i.controller_i.fsm_i.int_iff2,
"IFF2 (Testcase #11)");
unit.assert_eq(1'b1, top_z80_i.z80_i.cpu_i.controller_i.fsm_i.int_active_int,
"INT ACTIVE (Testcase #11)");

#(5 * CLKPERIOD);

unit.assert(top_z80_i.z80_i.cpu_i.controller_i.fsm_i.state == FSM_STATE_INSTR_FETCH1_1,
"STATE (Testcase #11)");
unit.assert_eq16(16'h0015, top_z80_i.z80_i.cpu_i.datapath_i.reg_pc_i.q,
"PC (Testcase #11)");

unit.assert_eq(1'b1, top_z80_i.z80_i.cpu_i.controller_i.fsm_i.int_iff1,
"IFF1 (Testcase #11)");
unit.assert_eq(1'b0, top_z80_i.z80_i.cpu_i.controller_i.fsm_i.int_iff2,
"IFF2 (Testcase #11)");
unit.assert_eq(1'b0, top_z80_i.z80_i.cpu_i.controller_i.fsm_i.int_active_int,
"INT ACTIVE (Testcase #11)");

top_z80_i.z80_i.cpu_i.controller_i.fsm_i.int_iff1 = 1'b0;
top_z80_i.z80_i.cpu_i.controller_i.fsm_i.int_iff2 = 1'b1;

#(CLKPERIOD);
i_n_nmi = 1'b0;
#(CLKPERIOD);
i_n_nmi = 1'b1;
#(CLKPERIOD);

unit.assert(top_z80_i.z80_i.cpu_i.controller_i.fsm_i.state == FSM_STATE_ACK_NMI_1,
"STATE (Testcase #11)");

unit.assert_eq(1'b0, top_z80_i.z80_i.cpu_i.controller_i.fsm_i.int_iff1,
"IFF1 (Testcase #11)");
unit.assert_eq(1'b0, top_z80_i.z80_i.cpu_i.controller_i.fsm_i.int_iff2,
"IFF2 (Testcase #11)");
unit.assert_eq(1'b1, top_z80_i.z80_i.cpu_i.controller_i.fsm_i.int_active_nmi,
"NMI ACTIVE (Testcase #11)");

#(8 * CLKPERIOD);

unit.assert(top_z80_i.z80_i.cpu_i.controller_i.fsm_i.state == FSM_STATE_INSTR_FETCH1_1,
"STATE (Testcase #11)");
unit.assert_eq16(16'h0066, top_z80_i.z80_i.cpu_i.datapath_i.reg_pc_i.q,
"PC (Testcase #11)");

unit.assert_eq(1'b0, top_z80_i.z80_i.cpu_i.controller_i.fsm_i.int_iff1,
"IFF1 (Testcase #11)");
unit.assert_eq(1'b0, top_z80_i.z80_i.cpu_i.controller_i.fsm_i.int_iff2,
"IFF2 (Testcase #11)");
unit.assert_eq(1'b0, top_z80_i.z80_i.cpu_i.controller_i.fsm_i.int_active_nmi,
"NMI ACTIVE (Testcase #11)");

unit.finish("int ('(DI|EI|IM (0|1|2)), int, nmi')");
