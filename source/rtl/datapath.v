`timescale 1ns/10ps

`include "buswidth.vh"

module datapath (
    input clk,
    input n_reset,
    input [2:0] alu_bitselect,
    input alu_iff2,
    input [`ALU_MODE_WIDTH-1:0] alu_mode,
    input [7:0] mem_din,
    input [`MUX_ALU_OP_A_SEL_WIDTH-1:0] mux_alu_op_a_sel,
    input [`MUX_ALU_OP_B_SEL_WIDTH-1:0] mux_alu_op_b_sel,
    input [`MUX_INT_BUS_SEL_WIDTH-1:0] mux_int_bus_sel,
    input [`MUX_MEM_ADDR_SEL_WIDTH-1:0] mux_mem_addr_sel,
    input [`MUX_MEM_DOUT_SEL_WIDTH-1:0] mux_mem_dout_sel,
    input reg_alu_addr_we,
    input reg_int_ctrl_we,
    input reg_instr_we,
    input reg_mem_addr_we,
    input reg_mem_din_hi_we,
    input reg_mem_din_lo_we,
    input reg_mem_dout_we,
    input [`OP_PREFIX_WIDTH-1:0] reg_op_prefix_next,
    input reg_op_prefix_we,
    input [7:0] reg_pc_lo_direct,
    input reg_pc_we,
    input [1:0] regfile_bc_dec,
    input [2:0] regfile_ex,
    input regfile_flags_we,
    input [`REG_SELECT_8BIT_WIDTH-1:0] regfile_read_addr_8bit_a,
    input [`REG_SELECT_16BIT_WIDTH-1:0] regfile_read_addr_16bit_a,
    input [`REG_SELECT_8BIT_WIDTH-1:0] regfile_read_addr_8bit_b,
    input [`REG_SELECT_16BIT_WIDTH-1:0] regfile_read_addr_16bit_b,
    input regfile_we,
    input [`REG_SELECT_WIDTH-1:0] regfile_write_addr,
    output regfile_b_zero,
    output regfile_bc_zero,
    output regfile_flag_s,
    output regfile_flag_z,
    output regfile_flag_pv,
    output regfile_flag_c,
    output [15:0] mem_addr,
    output [7:0] mem_dout,
    output [7:0] reg_instr,
    output [`OP_PREFIX_WIDTH-1:0] reg_op_prefix
);

`include "flags.vh"

wire [5:0] alu_flags;
wire [15:0] alu_op_a;
wire [15:0] alu_op_b;
wire [15:0] alu_out;
wire [15:0] int_bus;
wire [7:0] reg_int_ctrl;
wire [15:0] reg_mem_addr;
wire [15:0] reg_alu_addr;
wire [7:0] reg_mem_din_hi;
wire [7:0] reg_mem_din_lo;
wire [15:0] reg_mem_dout;
wire [15:0] reg_pc;
wire [5:0] regfile_flags;
wire [7:0] regfile_out_8bit_a;
wire [7:0] regfile_out_8bit_b;
wire [15:0] regfile_out_16bit_a;
wire [15:0] regfile_out_16bit_b;

assign regfile_flag_s  = regfile_flags[FLAG_IDX_S];
assign regfile_flag_z  = regfile_flags[FLAG_IDX_Z];
assign regfile_flag_pv = regfile_flags[FLAG_IDX_PV];
assign regfile_flag_c  = regfile_flags[FLAG_IDX_C];

/*****************************************************************************
 Internal bux
 *****************************************************************************/
mux_int_bus mux_int_bus_i (
    .data_select(mux_int_bus_sel),
    .alu_out(alu_out),
    .reg_int_ctrl(reg_int_ctrl),
    .reg_mem_din_hi(reg_mem_din_hi),
    .reg_mem_din_lo(reg_mem_din_lo),
    .reg_pc(reg_pc),
    .reg_pc_lo_direct(reg_pc_lo_direct),
    .regfile_out_8bit_a(regfile_out_8bit_a),
    .regfile_out_16bit_a(regfile_out_16bit_a),
    .regfile_out_16bit_b(regfile_out_16bit_b),
    .data_out(int_bus)
);


/*****************************************************************************
 Memory Interface
 *****************************************************************************/
ff #(.WIDTH(16)) reg_mem_addr_i (
    .clk(clk),
    .n_reset(n_reset),
    .we(reg_mem_addr_we),
    .d(mem_addr),
    .q(reg_mem_addr)
);

ff #(.WIDTH(8)) reg_mem_din_hi_i (
    .clk(clk),
    .n_reset(n_reset),
    .we(reg_mem_din_hi_we),
    .d(mem_din),
    .q(reg_mem_din_hi)
);

ff #(.WIDTH(8)) reg_mem_din_lo_i (
    .clk(clk),
    .n_reset(n_reset),
    .we(reg_mem_din_lo_we),
    .d(mem_din),
    .q(reg_mem_din_lo)
);

ff #(.WIDTH(16)) reg_mem_dout_i (
    .clk(clk),
    .n_reset(n_reset),
    .we(reg_mem_dout_we),
    .d(int_bus),
    .q(reg_mem_dout)
);

ff #(.WIDTH(16)) reg_alu_addr_i (
    .clk(clk),
    .n_reset(n_reset),
    .we(reg_alu_addr_we),
    .d(alu_out),
    .q(reg_alu_addr)
);

mux_mem_addr mux_mem_addr_i (
    .data_select(mux_mem_addr_sel),
    .alu_out(reg_alu_addr),
    .reg_int_ctrl(reg_int_ctrl),
    .reg_mem_addr(reg_mem_addr),
    .reg_mem_din_hi(reg_mem_din_hi),
    .reg_mem_din_lo(reg_mem_din_lo),
    .reg_pc(reg_pc),
    .regfile_out_8bit_b(regfile_out_8bit_b),
    .regfile_out_16bit_b(regfile_out_16bit_b),
    .data_out(mem_addr)
);

mux_mem_dout mux_mem_dout_i (
    .data_select(mux_mem_dout_sel),
    .reg_mem_dout(reg_mem_dout),
    .reg_mem_din_lo(reg_mem_din_lo),
    .reg_pc(reg_pc),
    .regfile_out_8bit_a(regfile_out_8bit_a),
    .regfile_out_16bit_a(regfile_out_16bit_a),
    .data_out(mem_dout)
);


/*****************************************************************************
 Program Counter
 *****************************************************************************/
ff #(.WIDTH(16)) reg_pc_i (
    .clk(clk),
    .n_reset(n_reset),
    .we(reg_pc_we),
    .d(int_bus),
    .q(reg_pc)
);


/*****************************************************************************
 Op prefix and instruction register
 *****************************************************************************/
ff #(.WIDTH(`OP_PREFIX_WIDTH)) reg_op_prefix_i (
    .clk(clk),
    .n_reset(n_reset),
    .we(reg_op_prefix_we),
    .d(reg_op_prefix_next),
    .q(reg_op_prefix)
);

ff #(.WIDTH(8)) reg_instr_i (
    .clk(clk),
    .n_reset(n_reset),
    .we(reg_instr_we),
    .d(mem_din),
    .q(reg_instr)
);


/*****************************************************************************
 Interrupt Control Vector Register
 *****************************************************************************/
ff #(.WIDTH(8)) reg_int_ctrl_i (
    .clk(clk),
    .n_reset(n_reset),
    .we(reg_int_ctrl_we),
    .d(int_bus[7:0]),
    .q(reg_int_ctrl)
);


/*****************************************************************************
 Register File
 *****************************************************************************/
regfile regfile_i (
    .clk(clk),
    .n_reset(n_reset),
    // Inputs
    .bc_dec(regfile_bc_dec),
    .ex(regfile_ex),
    .flags_in(alu_flags),
    .flags_we(regfile_flags_we),
    .reg_in(int_bus),
    .reg_read_addr_8bit_a(regfile_read_addr_8bit_a),
    .reg_read_addr_16bit_a(regfile_read_addr_16bit_a),
    .reg_read_addr_8bit_b(regfile_read_addr_8bit_b),
    .reg_read_addr_16bit_b(regfile_read_addr_16bit_b),
    .reg_we(regfile_we),
    .reg_write_addr(regfile_write_addr),
    // Outputs
    .b_zero(regfile_b_zero),
    .bc_zero(regfile_bc_zero),
    .flags_out(regfile_flags),
    .reg_out_8bit_a(regfile_out_8bit_a),
    .reg_out_8bit_b(regfile_out_8bit_b),
    .reg_out_16bit_a(regfile_out_16bit_a),
    .reg_out_16bit_b(regfile_out_16bit_b)
);


/*****************************************************************************
 ALU and flag generation
 *****************************************************************************/
mux_alu_op_a mux_alu_op_a_i (
    .data_select(mux_alu_op_a_sel),
    .regfile_out_8bit_a(regfile_out_8bit_a),
    .regfile_out_16bit_a(regfile_out_16bit_a),
    .reg_mem_addr(reg_mem_addr),
    .reg_mem_din_hi(reg_mem_din_hi),
    .reg_mem_din_lo(reg_mem_din_lo),
    .reg_pc(reg_pc),
    .reg_int_ctrl(reg_int_ctrl),
    .data_out(alu_op_a)
);

mux_alu_op_b mux_alu_op_b_i (
    .data_select(mux_alu_op_b_sel),
    .regfile_out_8bit_b(regfile_out_8bit_b),
    .regfile_out_16bit_b(regfile_out_16bit_b),
    .reg_mem_din_hi(reg_mem_din_hi),
    .reg_mem_din_lo(reg_mem_din_lo),
    .data_out(alu_op_b)
);

alu alu_i (
    // Inputs
    .mode(alu_mode),
    .op_a(alu_op_a),
    .op_b(alu_op_b),
    .flags_in(regfile_flags),
    .iff2(alu_iff2),
    .bitselect(alu_bitselect),
    // Outputs
    .data_out(alu_out),
    .flags_out(alu_flags)
);

endmodule
