// BEGIN TESTCASE #0
top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.a = 8'hF1;
top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.f = 8'h42;
{ top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.b, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.c } = 16'h7299;
{ top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.d,  top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.e } = 16'hF25E;
{ top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.h, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.l } = 16'h07AB;

#(CLKPERIOD);

loop_condition = 1;
loop_counter = 0;
while (loop_condition) begin
    #(3 * CLKPERIOD / 4);
    if (top_z80_i.z80_i.cpu_i.controller_i.fsm_i.state == FSM_STATE_INSTR_FETCH1_1) begin
        loop_condition = 0;
    end else begin
        #(CLKPERIOD / 4);
        loop_counter = loop_counter + 1;
        if (loop_counter == 32)
            unit.fail("Instruction not terminating (Testcase #0)");
    end
end

unit.assert_eq8(8'hF1, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.a,
"A (Testcase #0 291bbb07-bcc9-47d9-b4b7-09d062abd07a)");
unit.assert_eq16(16'hE499, { top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.b,
                             top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.c },
"BC (Testcase #0 9b91f096-523c-4f9e-9810-5ee1b656838c)");
unit.assert_eq16(16'hF25E, { top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.d,
                             top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.e },

// ...

"S (Testcase #0 7981d155-ee97-4b19-bdf9-241d4ee32d73)");
unit.assert_eq(1'b0, top_z80_i.z80_i.cpu_i.datapath_i.regfile_i.f[6],
"Z (Testcase #0 e169f6f1-93a7-4e25-919c-940a357e7c01)");

// ...

unit.assert_eq8(8'h15, datamem_ext_i.datamem[13'h7AB],
"EXT DMEM (Testcase #0 7d481749-8d95-4f41-a6bb-6d8cbf38497b)");
datamem_ext_i.datamem[13'h7AB] = datamem_swap[16'h7AB];

// ...

