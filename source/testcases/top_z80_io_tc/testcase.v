unit.start("io ('(IN|OUT)')");

// BEGIN TESTCASE #0 (IN A,(n))
top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.a = 8'h12;
top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.f = 8'hD7;
top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.b = 8'h00;
top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.c = 8'h00;
top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.d = 8'h00;
top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.e = 8'h00;

#(CLKPERIOD);

loop_counter = 5'b0;
while (top_z80_i.z80_i.cpu_i.controller_i.fsm_i.state != FSM_STATE_INSTR_FETCH1_1)
begin
    #(CLKPERIOD);
    loop_counter = loop_counter + 1;
    if (loop_counter == 5'b11111)
        unit.fail("Instruction not terminating");
end

unit.assert_eq8(8'h42, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.a,
"A (Testcase #0)");
unit.assert_eq(1'b1, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.f[7],
"S (Testcase #0)");
unit.assert_eq(1'b1, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.f[6],
"Z (Testcase #0)");
unit.assert_eq(1'b1, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.f[4],
"H (Testcase #0)");
unit.assert_eq(1'b1, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.f[2],
"PV (Testcase #0)");
unit.assert_eq(1'b1, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.f[1],
"N (Testcase #0)");
unit.assert_eq(1'b1, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.f[0],
"C (Testcase #0)");
unit.assert_eq16(16'h0000, { top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.b, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.c },
"BC (Testcase #0)");
unit.assert_eq16(16'h0000, { top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.d, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.e },
"DE (Testcase #0)");
unit.assert_eq16(16'h0000, { top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.h, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.l },
"HL (Testcase #0)");

unit.assert_eq8(8'h42, iodev_mock_i.datamem[13'h1234],
"IOMEM (Testcase #0)");

// BEGIN TESTCASE #1 (IN r,(C))
top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.a = 8'h00;
top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.f = 8'h13;
top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.b = 8'h12;
top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.c = 8'h35;
top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.d = 8'h00;
top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.e = 8'h00;
top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.h = 8'h00;
top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.l = 8'h00;

#(CLKPERIOD);

loop_counter = 5'b0;
while (top_z80_i.z80_i.cpu_i.controller_i.fsm_i.state != FSM_STATE_INSTR_FETCH1_1)
begin
    #(CLKPERIOD);
    loop_counter = loop_counter + 1;
    if (loop_counter == 5'b11111)
        unit.fail("Instruction not terminating");
end

unit.assert_eq8(8'h00, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.a,
"A (Testcase #1)");
unit.assert_eq(1'b1, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.f[7],
"S (Testcase #1)");
unit.assert_eq(1'b0, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.f[6],
"Z (Testcase #1)");
unit.assert_eq(1'b0, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.f[4],
"H (Testcase #1)");
unit.assert_eq(1'b1, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.f[2],
"PV (Testcase #1)");
unit.assert_eq(1'b0, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.f[1],
"N (Testcase #1)");
unit.assert_eq(1'b1, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.f[0],
"C (Testcase #1)");
unit.assert_eq16(16'h1235, { top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.b, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.c },
"BC (Testcase #1)");
unit.assert_eq16(16'h8700, { top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.d, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.e },
"DE (Testcase #1)");
unit.assert_eq16(16'h0000, { top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.h, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.l },
"HL (Testcase #1)");

unit.assert_eq8(8'h87, iodev_mock_i.datamem[13'h1235],
"IOMEM (Testcase #1)");

// BEGIN TESTCASE #2 (INI)
top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.a = 8'h00;
top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.f = 8'h00;
top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.b = 8'h01;
top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.c = 8'h23;
top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.d = 8'h00;
top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.e = 8'h00;
top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.h = 8'h01;
top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.l = 8'h01;

#(CLKPERIOD);

loop_counter = 5'b0;
while (top_z80_i.z80_i.cpu_i.controller_i.fsm_i.state != FSM_STATE_INSTR_FETCH1_1)
begin
    #(CLKPERIOD);
    loop_counter = loop_counter + 1;
    if (loop_counter == 5'b11111)
        unit.fail("Instruction not terminating");
end

unit.assert_eq8(8'h00, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.a,
"A (Testcase #2)");
unit.assert_eq(1'b1, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.f[6],
"Z (Testcase #2)");
unit.assert_eq(1'b1, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.f[1],
"N (Testcase #2)");
unit.assert_eq16(16'h0023, { top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.b, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.c },
"BC (Testcase #2)");
unit.assert_eq16(16'h0000, { top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.d, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.e },
"DE (Testcase #2)");
unit.assert_eq16(16'h0102, { top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.h, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.l },
"HL (Testcase #2)");

unit.assert_eq8(8'h32, top_z80_i.z80_i.memory_control_i.idram_i.SY180_256X8X1CM8_i2.Memory[8'h01],
"DMEM (Testcase #2)");
top_z80_i.z80_i.memory_control_i.idram_i.SY180_256X8X1CM8_i2.Memory[8'h01] =
datamem_swap[16'h0101];

// BEGIN TESTCASE #3 (INIR)
top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.a = 8'h00;
top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.f = 8'h00;
top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.b = 8'h03;
top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.c = 8'h45;
top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.d = 8'h00;
top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.e = 8'h00;
top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.h = 8'h01;
top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.l = 8'h02;

#(CLKPERIOD);

loop_counter = 5'b0;
while (top_z80_i.z80_i.cpu_i.controller_i.fsm_i.state != FSM_STATE_INSTR_FETCH1_1)
begin
    #(CLKPERIOD);
    loop_counter = loop_counter + 1;
    if (loop_counter == 5'b11111)
        unit.fail("Instruction not terminating");
end

#(CLKPERIOD);

loop_counter = 5'b0;
while (top_z80_i.z80_i.cpu_i.controller_i.fsm_i.state != FSM_STATE_INSTR_FETCH1_1)
begin
    #(CLKPERIOD);
    loop_counter = loop_counter + 1;
    if (loop_counter == 5'b11111)
        unit.fail("Instruction not terminating");
end

#(CLKPERIOD);

loop_counter = 5'b0;
while (top_z80_i.z80_i.cpu_i.controller_i.fsm_i.state != FSM_STATE_INSTR_FETCH1_1)
begin
    #(CLKPERIOD);
    loop_counter = loop_counter + 1;
    if (loop_counter == 5'b11111)
        unit.fail("Instruction not terminating");
end

unit.assert_eq8(8'h00, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.a,
"A (Testcase #3)");
unit.assert_eq(1'b1, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.f[6],
"Z (Testcase #3)");
unit.assert_eq(1'b1, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.f[1],
"N (Testcase #3)");
unit.assert_eq16(16'h0045, { top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.b, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.c },
"BC (Testcase #3)");
unit.assert_eq16(16'h0000, { top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.d, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.e },
"DE (Testcase #3)");
unit.assert_eq16(16'h0105, { top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.h, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.l },
"HL (Testcase #3)");

unit.assert_eq8(8'h03, top_z80_i.z80_i.memory_control_i.idram_i.SY180_256X8X1CM8_i2.Memory[8'h02],
"DMEM (Testcase #3)");
unit.assert_eq8(8'h02, top_z80_i.z80_i.memory_control_i.idram_i.SY180_256X8X1CM8_i2.Memory[8'h03],
"DMEM (Testcase #3)");
unit.assert_eq8(8'h01, top_z80_i.z80_i.memory_control_i.idram_i.SY180_256X8X1CM8_i2.Memory[8'h04],
"DMEM (Testcase #3)");
top_z80_i.z80_i.memory_control_i.idram_i.SY180_256X8X1CM8_i2.Memory[8'h02] =
datamem_swap[16'h0102];
top_z80_i.z80_i.memory_control_i.idram_i.SY180_256X8X1CM8_i2.Memory[8'h03] =
datamem_swap[16'h0103];
top_z80_i.z80_i.memory_control_i.idram_i.SY180_256X8X1CM8_i2.Memory[8'h04] =
datamem_swap[16'h0104];

// BEGIN TESTCASE #4 (IND)
top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.a = 8'h00;
top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.f = 8'h40;
top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.b = 8'h02;
top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.c = 8'h67;
top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.d = 8'h00;
top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.e = 8'h00;
top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.h = 8'h00;
top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.l = 8'h99;

#(CLKPERIOD);

loop_counter = 5'b0;
while (top_z80_i.z80_i.cpu_i.controller_i.fsm_i.state != FSM_STATE_INSTR_FETCH1_1)
begin
    #(CLKPERIOD);
    loop_counter = loop_counter + 1;
    if (loop_counter == 5'b11111)
        unit.fail("Instruction not terminating");
end

unit.assert_eq8(8'h00, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.a,
"A (Testcase #4)");
unit.assert_eq(1'b0, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.f[6],
"Z (Testcase #4)");
unit.assert_eq(1'b1, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.f[1],
"N (Testcase #4)");
unit.assert_eq16(16'h0167, { top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.b, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.c },
"BC (Testcase #4)");
unit.assert_eq16(16'h0000, { top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.d, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.e },
"DE (Testcase #4)");
unit.assert_eq16(16'h0098, { top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.h, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.l },
"HL (Testcase #4)");

unit.assert_eq8(8'h75, top_z80_i.z80_i.memory_control_i.idram_i.SY180_256X8X1CM8_i1.Memory[8'h99],
"DMEM (Testcase #4)");
top_z80_i.z80_i.memory_control_i.idram_i.SY180_256X8X1CM8_i1.Memory[8'h99] =
datamem_swap[16'h0099];

// BEGIN TESTCASE #5 (INDR)
top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.a = 8'h00;
top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.f = 8'h00;
top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.b = 8'h03;
top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.c = 8'h89;
top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.d = 8'h00;
top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.e = 8'h00;
top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.h = 8'h00;
top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.l = 8'h99;

#(CLKPERIOD);

loop_counter = 5'b0;
while (top_z80_i.z80_i.cpu_i.controller_i.fsm_i.state != FSM_STATE_INSTR_FETCH1_1)
begin
    #(CLKPERIOD);
    loop_counter = loop_counter + 1;
    if (loop_counter == 5'b11111)
        unit.fail("Instruction not terminating");
end

#(CLKPERIOD);

loop_counter = 5'b0;
while (top_z80_i.z80_i.cpu_i.controller_i.fsm_i.state != FSM_STATE_INSTR_FETCH1_1)
begin
    #(CLKPERIOD);
    loop_counter = loop_counter + 1;
    if (loop_counter == 5'b11111)
        unit.fail("Instruction not terminating");
end

#(CLKPERIOD);

loop_counter = 5'b0;
while (top_z80_i.z80_i.cpu_i.controller_i.fsm_i.state != FSM_STATE_INSTR_FETCH1_1)
begin
    #(CLKPERIOD);
    loop_counter = loop_counter + 1;
    if (loop_counter == 5'b11111)
        unit.fail("Instruction not terminating");
end

unit.assert_eq8(8'h00, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.a,
"A (Testcase #5)");
unit.assert_eq(1'b1, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.f[6],
"Z (Testcase #5)");
unit.assert_eq(1'b1, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.f[1],
"N (Testcase #5)");
unit.assert_eq16(16'h0089, { top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.b, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.c },
"BC (Testcase #5)");
unit.assert_eq16(16'h0000, { top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.d, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.e },
"DE (Testcase #5)");
unit.assert_eq16(16'h0096, { top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.h, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.l },
"HL (Testcase #5)");

unit.assert_eq8(8'h03, top_z80_i.z80_i.memory_control_i.idram_i.SY180_256X8X1CM8_i1.Memory[8'h99],
"DMEM (Testcase #5)");
unit.assert_eq8(8'h02, top_z80_i.z80_i.memory_control_i.idram_i.SY180_256X8X1CM8_i1.Memory[8'h98],
"DMEM (Testcase #5)");
unit.assert_eq8(8'h01, top_z80_i.z80_i.memory_control_i.idram_i.SY180_256X8X1CM8_i1.Memory[8'h97],
"DMEM (Testcase #5)");
top_z80_i.z80_i.memory_control_i.idram_i.SY180_256X8X1CM8_i1.Memory[8'h99] =
datamem_swap[16'h0099];
top_z80_i.z80_i.memory_control_i.idram_i.SY180_256X8X1CM8_i1.Memory[8'h98] =
datamem_swap[16'h0098];
top_z80_i.z80_i.memory_control_i.idram_i.SY180_256X8X1CM8_i1.Memory[8'h97] =
datamem_swap[16'h0097];

// BEGIN TESTCASE #6 (OUT (n),A)
top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.a = 8'h12;

#(CLKPERIOD);

loop_counter = 5'b0;
while (top_z80_i.z80_i.cpu_i.controller_i.fsm_i.state != FSM_STATE_INSTR_FETCH1_1)
begin
    #(CLKPERIOD);
    loop_counter = loop_counter + 1;
    if (loop_counter == 5'b11111)
        unit.fail("Instruction not terminating");
end

unit.assert_eq8(8'h12, iodev_mock_i.datamem[13'h1240],
"IOMEM (Testcase #6)");
iodev_mock_i.datamem[13'h1240] = iomem_swap[13'h1240];

// BEGIN TESTCASE #7 (OUT (C),r)
top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.a = 8'h00;
top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.f = 8'hD7;
top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.b = 8'h12;
top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.c = 8'h41;
top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.d = 8'h37;
top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.e = 8'h00;
top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.h = 8'h00;
top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.l = 8'h00;

#(CLKPERIOD);

loop_counter = 5'b0;
while (top_z80_i.z80_i.cpu_i.controller_i.fsm_i.state != FSM_STATE_INSTR_FETCH1_1)
begin
    #(CLKPERIOD);
    loop_counter = loop_counter + 1;
    if (loop_counter == 5'b11111)
        unit.fail("Instruction not terminating");
end

unit.assert_eq8(8'h00, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.a,
"A (Testcase #7)");
unit.assert_eq(1'b1, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.f[7],
"S (Testcase #7)");
unit.assert_eq(1'b1, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.f[6],
"Z (Testcase #7)");
unit.assert_eq(1'b1, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.f[4],
"H (Testcase #7)");
unit.assert_eq(1'b1, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.f[2],
"PV (Testcase #7)");
unit.assert_eq(1'b1, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.f[1],
"N (Testcase #7)");
unit.assert_eq(1'b1, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.f[0],
"C (Testcase #7)");
unit.assert_eq16(16'h1241, { top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.b, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.c },
"BC (Testcase #7)");
unit.assert_eq16(16'h3700, { top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.d, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.e },
"DE (Testcase #7)");
unit.assert_eq16(16'h0000, { top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.h, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.l },
"HL (Testcase #7)");

unit.assert_eq8(8'h37, iodev_mock_i.datamem[13'h1241],
"IOMEM (Testcase #7)");
iodev_mock_i.datamem[13'h1241] = iomem_swap[13'h1241];

// BEGIN TESTCASE #8 (OUTI)
top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.a = 8'h00;
top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.f = 8'h00;
top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.b = 8'h01;
top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.c = 8'hAB;
top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.d = 8'h00;
top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.e = 8'h00;
top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.h = 8'h01;
top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.l = 8'h32;

#(CLKPERIOD);

loop_counter = 5'b0;
while (top_z80_i.z80_i.cpu_i.controller_i.fsm_i.state != FSM_STATE_INSTR_FETCH1_1)
begin
    #(CLKPERIOD);
    loop_counter = loop_counter + 1;
    if (loop_counter == 5'b11111)
        unit.fail("Instruction not terminating");
end

unit.assert_eq8(8'h00, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.a,
"A (Testcase #8)");
unit.assert_eq(1'b1, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.f[6],
"Z (Testcase #8)");
unit.assert_eq(1'b1, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.f[1],
"N (Testcase #8)");
unit.assert_eq16(16'h00AB, { top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.b, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.c },
"BC (Testcase #8)");
unit.assert_eq16(16'h0000, { top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.d, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.e },
"DE (Testcase #8)");
unit.assert_eq16(16'h0133, { top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.h, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.l },
"HL (Testcase #8)");

unit.assert_eq8(8'h56, iodev_mock_i.datamem[13'h00AB],
"IOMEM (Testcase #8)");
iodev_mock_i.datamem[13'h00AB] = iomem_swap[13'h00AB];

// BEGIN TESTCASE #9 (OUTIR)
top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.a = 8'h00;
top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.f = 8'h00;
top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.b = 8'h03;
top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.c = 8'hCD;
top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.d = 8'h00;
top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.e = 8'h00;
top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.h = 8'h01;
top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.l = 8'h43;

#(CLKPERIOD);

loop_counter = 5'b0;
while (top_z80_i.z80_i.cpu_i.controller_i.fsm_i.state != FSM_STATE_INSTR_FETCH1_1)
begin
    #(CLKPERIOD);
    loop_counter = loop_counter + 1;
    if (loop_counter == 5'b11111)
        unit.fail("Instruction not terminating");
end

#(CLKPERIOD);

loop_counter = 5'b0;
while (top_z80_i.z80_i.cpu_i.controller_i.fsm_i.state != FSM_STATE_INSTR_FETCH1_1)
begin
    #(CLKPERIOD);
    loop_counter = loop_counter + 1;
    if (loop_counter == 5'b11111)
        unit.fail("Instruction not terminating");
end

#(CLKPERIOD);

loop_counter = 5'b0;
while (top_z80_i.z80_i.cpu_i.controller_i.fsm_i.state != FSM_STATE_INSTR_FETCH1_1)
begin
    #(CLKPERIOD);
    loop_counter = loop_counter + 1;
    if (loop_counter == 5'b11111)
        unit.fail("Instruction not terminating");
end

unit.assert_eq8(8'h00, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.a,
"A (Testcase #9)");
unit.assert_eq(1'b1, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.f[6],
"Z (Testcase #9)");
unit.assert_eq(1'b1, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.f[1],
"N (Testcase #9)");
unit.assert_eq16(16'h00CD, { top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.b, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.c },
"BC (Testcase #9)");
unit.assert_eq16(16'h0000, { top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.d, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.e },
"DE (Testcase #9)");
unit.assert_eq16(16'h0146, { top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.h, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.l },
"HL (Testcase #9)");

unit.assert_eq8(8'h03, iodev_mock_i.datamem[13'h00CD],
"IOMEM (Testcase #9)");
unit.assert_eq8(8'h02, iodev_mock_i.datamem[13'h01CD],
"IOMEM (Testcase #9)");
unit.assert_eq8(8'h01, iodev_mock_i.datamem[13'h02CD],
"IOMEM (Testcase #9)");
iodev_mock_i.datamem[13'h00CD] = iomem_swap[13'h00CD];
iodev_mock_i.datamem[13'h01CD] = iomem_swap[13'h01CD];
iodev_mock_i.datamem[13'h02CD] = iomem_swap[13'h02CD];

// BEGIN TESTCASE #10 (OUTD)
top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.a = 8'h00;
top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.f = 8'h00;
top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.b = 8'h02;
top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.c = 8'hEF;
top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.d = 8'h00;
top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.e = 8'h00;
top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.h = 8'h00;
top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.l = 8'h46;

#(CLKPERIOD);

loop_counter = 5'b0;
while (top_z80_i.z80_i.cpu_i.controller_i.fsm_i.state != FSM_STATE_INSTR_FETCH1_1)
begin
    #(CLKPERIOD);
    loop_counter = loop_counter + 1;
    if (loop_counter == 5'b11111)
        unit.fail("Instruction not terminating");
end

unit.assert_eq8(8'h00, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.a,
"A (Testcase #10)");
unit.assert_eq(1'b0, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.f[6],
"Z (Testcase #10)");
unit.assert_eq(1'b1, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.f[1],
"N (Testcase #10)");
unit.assert_eq16(16'h01EF, { top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.b, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.c },
"BC (Testcase #10)");
unit.assert_eq16(16'h0000, { top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.d, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.e },
"DE (Testcase #10)");
unit.assert_eq16(16'h0045, { top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.h, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.l },
"HL (Testcase #10)");

unit.assert_eq8(8'h15, iodev_mock_i.datamem[13'h01EF],
"IOMEM (Testcase #10)");
iodev_mock_i.datamem[13'h01EF] = iomem_swap[13'h01EF];

// BEGIN TESTCASE #11 (OUTIR)
top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.a = 8'h00;
top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.f = 8'h00;
top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.b = 8'h03;
top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.c = 8'h00;
top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.d = 8'h00;
top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.e = 8'h00;
top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.h = 8'h00;
top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.l = 8'h49;

#(CLKPERIOD);

loop_counter = 5'b0;
while (top_z80_i.z80_i.cpu_i.controller_i.fsm_i.state != FSM_STATE_INSTR_FETCH1_1)
begin
    #(CLKPERIOD);
    loop_counter = loop_counter + 1;
    if (loop_counter == 5'b11111)
        unit.fail("Instruction not terminating");
end

#(CLKPERIOD);

loop_counter = 5'b0;
while (top_z80_i.z80_i.cpu_i.controller_i.fsm_i.state != FSM_STATE_INSTR_FETCH1_1)
begin
    #(CLKPERIOD);
    loop_counter = loop_counter + 1;
    if (loop_counter == 5'b11111)
        unit.fail("Instruction not terminating");
end

#(CLKPERIOD);

loop_counter = 5'b0;
while (top_z80_i.z80_i.cpu_i.controller_i.fsm_i.state != FSM_STATE_INSTR_FETCH1_1)
begin
    #(CLKPERIOD);
    loop_counter = loop_counter + 1;
    if (loop_counter == 5'b11111)
        unit.fail("Instruction not terminating");
end

unit.assert_eq8(8'h00, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.a,
"A (Testcase #11)");
unit.assert_eq(1'b1, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.f[6],
"Z (Testcase #11)");
unit.assert_eq(1'b1, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.f[1],
"N (Testcase #11)");
unit.assert_eq16(16'h0000, { top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.b, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.c },
"BC (Testcase #11)");
unit.assert_eq16(16'h0000, { top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.d, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.e },
"DE (Testcase #11)");
unit.assert_eq16(16'h0046, { top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.h, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.l },
"HL (Testcase #11)");

unit.assert_eq8(8'h01, iodev_mock_i.datamem[13'h0000],
"IOMEM (Testcase #11)");
unit.assert_eq8(8'h02, iodev_mock_i.datamem[13'h0100],
"IOMEM (Testcase #11)");
unit.assert_eq8(8'h03, iodev_mock_i.datamem[13'h0200],
"IOMEM (Testcase #11)");
iodev_mock_i.datamem[13'h0000] = iomem_swap[13'h0000];
iodev_mock_i.datamem[13'h0100] = iomem_swap[13'h0100];
iodev_mock_i.datamem[13'h0200] = iomem_swap[13'h0200];

unit.finish("io ('(IN|OUT)')");
