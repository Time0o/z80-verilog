unit.start("ebsblock ('(LDIR|LDDR|CPIR|CPDR)')");

// BEGIN TESTCASE #0
top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.f = 8'hD7;
{ top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.b, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.c } = 16'h0003;
{ top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.d,  top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.e } = 16'h0456;
{ top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.h, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.l } = 16'h0234;

for (i = 0; i < 3; i = i + 1) begin
	#(CLKPERIOD);

	loop_condition = 1'b1;
	loop_counter = 5'b0;
	while (loop_condition) begin
	    #(3 * CLKPERIOD / 4);
	    if (top_z80_i.z80_i.cpu_i.controller_i.fsm_i.state ==
	        FSM_STATE_INSTR_FETCH1_1) begin
	        loop_condition = 1'b0;
	    end else begin
	        #(CLKPERIOD / 4);
	        loop_counter = loop_counter + 1;
	        if (loop_counter == 5'b11111)
	            unit.fail("Instruction not terminating (Testcase #0)");
	    end
	end
end

unit.assert_eq16(16'h0000, { top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.b, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.c },
"BC (Testcase #0)");
unit.assert_eq16(16'h0459, { top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.d,  top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.e },
"DE (Testcase #0)");
unit.assert_eq16(16'h0237, { top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.h, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.l },
"HL (Testcase #0)");
unit.assert_eq(1'b1, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.f[7],
"S (Testcase #0)");
unit.assert_eq(1'b1, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.f[6],
"Z (Testcase #0)");
unit.assert_eq(1'b0, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.f[4],
"H (Testcase #0)");
unit.assert_eq(1'b0, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.f[2],
"PV (Testcase #0)");
unit.assert_eq(1'b0, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.f[1],
"N (Testcase #0)");
unit.assert_eq(1'b1, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.f[0],
"C (Testcase #0)");

unit.assert_eq8(8'h21, datamem_ext_i.datamem[13'h456],
"EXT DMEM (Testcase #0)");
unit.assert_eq8(8'h92, datamem_ext_i.datamem[13'h457],
"EXT DMEM (Testcase #0)");
unit.assert_eq8(8'h12, datamem_ext_i.datamem[13'h458],
"EXT DMEM (Testcase #0)");
unit.assert_eq8(8'h00, datamem_ext_i.datamem[13'h459],
"EXT DMEM (Testcase #0)");

datamem_ext_i.datamem[13'h456] = datamem_swap[16'h456];
datamem_ext_i.datamem[13'h457] = datamem_swap[16'h457];
datamem_ext_i.datamem[13'h458] = datamem_swap[16'h458];

// BEGIN TESTCASE #1
top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.f = 8'hD7;
{ top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.b, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.c } = 16'h0003;
{ top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.d,  top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.e } = 16'h0459;
{ top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.h, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.l } = 16'h0236;

for (i = 0; i < 3; i = i + 1) begin
	#(CLKPERIOD);

	loop_condition = 1'b1;
	loop_counter = 5'b0;
	while (loop_condition) begin
	    #(3 * CLKPERIOD / 4);
	    if (top_z80_i.z80_i.cpu_i.controller_i.fsm_i.state ==
	        FSM_STATE_INSTR_FETCH1_1) begin
	        loop_condition = 1'b0;
	    end else begin
	        #(CLKPERIOD / 4);
	        loop_counter = loop_counter + 1;
	        if (loop_counter == 5'b11111)
	            unit.fail("Instruction not terminating (Testcase #1)");
	    end
	end
end

unit.assert_eq16(16'h0000, { top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.b, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.c },
"BC (Testcase #1)");
unit.assert_eq16(16'h0456, { top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.d,  top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.e },
"DE (Testcase #1)");
unit.assert_eq16(16'h0233, { top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.h, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.l },
"HL (Testcase #1)");
unit.assert_eq(1'b1, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.f[7],
"S (Testcase #1)");
unit.assert_eq(1'b1, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.f[6],
"Z (Testcase #1)");
unit.assert_eq(1'b0, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.f[4],
"H (Testcase #1)");
unit.assert_eq(1'b0, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.f[2],
"PV (Testcase #1)");
unit.assert_eq(1'b0, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.f[1],
"N (Testcase #1)");
unit.assert_eq(1'b1, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.f[0],
"C (Testcase #1)");

unit.assert_eq8(8'h12, datamem_ext_i.datamem[13'h459],
"EXT DMEM (Testcase #1)");
unit.assert_eq8(8'h92, datamem_ext_i.datamem[13'h458],
"EXT DMEM (Testcase #1)");
unit.assert_eq8(8'h21, datamem_ext_i.datamem[13'h457],
"EXT DMEM (Testcase #1)");
unit.assert_eq8(8'h00, datamem_ext_i.datamem[13'h456],
"EXT DMEM (Testcase #1)");

datamem_ext_i.datamem[13'h459] = datamem_swap[16'h459];
datamem_ext_i.datamem[13'h458] = datamem_swap[16'h458];
datamem_ext_i.datamem[13'h457] = datamem_swap[16'h457];

// BEGIN TESTCASE #2 (CPIR no match)
top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.f = 8'hD3;
top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.a = 8'h13;
{ top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.b, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.c } = 16'h0003;
{ top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.h, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.l } = 16'h0234;

for (i = 0; i < 3; i = i + 1) begin
	#(CLKPERIOD);

	loop_condition = 1'b1;
	loop_counter = 5'b0;
	while (loop_condition) begin
	    #(3 * CLKPERIOD / 4);
	    if (top_z80_i.z80_i.cpu_i.controller_i.fsm_i.state ==
	        FSM_STATE_INSTR_FETCH1_1) begin
	        loop_condition = 1'b0;
	    end else begin
	        #(CLKPERIOD / 4);
	        loop_counter = loop_counter + 1;
	        if (loop_counter == 5'b11111)
	            unit.fail("Instruction not terminating (Testcase #2)");
	    end
	end
end

unit.assert_eq16(16'h0000, { top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.b, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.c },
"BC (Testcase #2)");
unit.assert_eq16(16'h0237, { top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.h, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.l },
"HL (Testcase #2)");
unit.assert_eq(1'b0, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.f[7],
"S (Testcase #2)");
unit.assert_eq(1'b0, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.f[6],
"Z (Testcase #2)");
unit.assert_eq(1'b0, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.f[4],
"H (Testcase #2)");
unit.assert_eq(1'b0, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.f[2],
"PV (Testcase #2)");
unit.assert_eq(1'b1, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.f[1],
"N (Testcase #2)");
unit.assert_eq(1'b1, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.f[0],
"C (Testcase #2)");

// BEGIN TESTCASE #3 (CPIR match)
top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.f = 8'hD3;
top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.a = 8'h92;
{ top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.b, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.c } = 16'h0003;
{ top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.h, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.l } = 16'h0234;

for (i = 0; i < 2; i = i + 1) begin
	#(CLKPERIOD);

	loop_condition = 1'b1;
	loop_counter = 5'b0;
	while (loop_condition) begin
	    #(3 * CLKPERIOD / 4);
	    if (top_z80_i.z80_i.cpu_i.controller_i.fsm_i.state ==
	        FSM_STATE_INSTR_FETCH1_1) begin
	        loop_condition = 1'b0;
	    end else begin
	        #(CLKPERIOD / 4);
	        loop_counter = loop_counter + 1;
	        if (loop_counter == 5'b11111)
	            unit.fail("Instruction not terminating (Testcase #3)");
	    end
	end
end

unit.assert_eq16(16'h0001, { top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.b, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.c },
"BC (Testcase #3)");
unit.assert_eq16(16'h0236, { top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.h, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.l },
"HL (Testcase #3)");
unit.assert_eq(1'b0, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.f[7],
"S (Testcase #3)");
unit.assert_eq(1'b1, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.f[6],
"Z (Testcase #3)");
unit.assert_eq(1'b0, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.f[4],
"H (Testcase #3)");
unit.assert_eq(1'b1, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.f[2],
"PV (Testcase #3)");
unit.assert_eq(1'b1, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.f[1],
"N (Testcase #3)");
unit.assert_eq(1'b1, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.f[0],
"C (Testcase #3)");

// BEGIN TESTCASE #4 (CPID no match)
top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.f = 8'hD3;
top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.a = 8'h13;
{ top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.b, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.c } = 16'h0003;
{ top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.h, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.l } = 16'h0236;

for (i = 0; i < 3; i = i + 1) begin
	#(CLKPERIOD);

	loop_condition = 1'b1;
	loop_counter = 5'b0;
	while (loop_condition) begin
	    #(3 * CLKPERIOD / 4);
	    if (top_z80_i.z80_i.cpu_i.controller_i.fsm_i.state ==
	        FSM_STATE_INSTR_FETCH1_1) begin
	        loop_condition = 1'b0;
	    end else begin
	        #(CLKPERIOD / 4);
	        loop_counter = loop_counter + 1;
	        if (loop_counter == 5'b11111)
	            unit.fail("Instruction not terminating (Testcase #4)");
	    end
	end
end

unit.assert_eq16(16'h0000, { top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.b, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.c },
"BC (Testcase #4)");
unit.assert_eq16(16'h0233, { top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.h, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.l },
"HL (Testcase #4)");
unit.assert_eq(1'b1, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.f[7],
"S (Testcase #4)");
unit.assert_eq(1'b0, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.f[6],
"Z (Testcase #4)");
unit.assert_eq(1'b0, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.f[4],
"H (Testcase #4)");
unit.assert_eq(1'b0, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.f[2],
"PV (Testcase #4)");
unit.assert_eq(1'b1, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.f[1],
"N (Testcase #4)");
unit.assert_eq(1'b1, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.f[0],
"C (Testcase #4)");

// BEGIN TESTCASE #5 (CPID match)
top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.f = 8'hD3;
top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.a = 8'h92;
{ top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.b, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.c } = 16'h0003;
{ top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.h, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.l } = 16'h0236;

for (i = 0; i < 2; i = i + 1) begin
	#(CLKPERIOD);

	loop_condition = 1'b1;
	loop_counter = 5'b0;
	while (loop_condition) begin
	    #(3 * CLKPERIOD / 4);
	    if (top_z80_i.z80_i.cpu_i.controller_i.fsm_i.state ==
	        FSM_STATE_INSTR_FETCH1_1) begin
	        loop_condition = 1'b0;
	    end else begin
	        #(CLKPERIOD / 4);
	        loop_counter = loop_counter + 1;
	        if (loop_counter == 5'b11111)
	            unit.fail("Instruction not terminating (Testcase #5)");
	    end
	end
end

unit.assert_eq16(16'h0001, { top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.b, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.c },
"BC (Testcase #5)");
unit.assert_eq16(16'h0234, { top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.h, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.l },
"HL (Testcase #5)");
unit.assert_eq(1'b0, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.f[7],
"S (Testcase #5)");
unit.assert_eq(1'b1, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.f[6],
"Z (Testcase #5)");
unit.assert_eq(1'b0, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.f[4],
"H (Testcase #5)");
unit.assert_eq(1'b1, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.f[2],
"PV (Testcase #5)");
unit.assert_eq(1'b1, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.f[1],
"N (Testcase #5)");
unit.assert_eq(1'b1, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.f[0],
"C (Testcase #5)");

unit.finish("ebsblock ('(LDIR|LDDR|CPIR|CPDR)')");
