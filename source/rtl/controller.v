`timescale 1ns/10ps

`include "buswidth.vh"

module controller (
	input clk,
	input n_reset,
	input ipram_loaded,
	input int_request_int,
	input int_request_nmi,
	input [7:0] reg_instr,
	input [`OP_PREFIX_WIDTH-1:0] reg_op_prefix,
	input regfile_b_zero,
	input regfile_bc_zero,
	input regfile_flag_s,
	input regfile_flag_z,
	input regfile_flag_pv,
	input regfile_flag_c,
	output [2:0] alu_bitselect,
	output alu_iff2,
	output [`ALU_MODE_WIDTH-1:0] alu_mode,
	output halt_n_halt,
	output halt_n_halt_we,
	output io_n_iorq,
	output mem_dout_en,
	output mem_n_pmem,
	output mem_n_m1,
	output mem_n_mreq,
	output mem_n_rd,
	output mem_n_wr,
	output [`MUX_ALU_OP_A_SEL_WIDTH-1:0] mux_alu_op_a_sel,
	output [`MUX_ALU_OP_B_SEL_WIDTH-1:0] mux_alu_op_b_sel,
	output [`MUX_INT_BUS_SEL_WIDTH-1:0] mux_int_bus_sel,
	output [`MUX_MEM_ADDR_SEL_WIDTH-1:0] mux_mem_addr_sel,
	output [`MUX_MEM_DOUT_SEL_WIDTH-1:0] mux_mem_dout_sel,
	output reg_alu_addr_we,
	output reg_int_ctrl_we,
	output reg_instr_we,
	output reg_mem_addr_we,
	output reg_mem_din_hi_we,
	output reg_mem_din_lo_we,
	output reg_mem_dout_we,
	output [`OP_PREFIX_WIDTH-1:0] reg_op_prefix_next,
	output reg_op_prefix_we,
	output [7:0] reg_pc_lo_direct,
	output reg_pc_we,
	output [1:0] regfile_bc_dec,
	output [2:0] regfile_ex,
	output regfile_flags_we,
	output [`REG_SELECT_8BIT_WIDTH-1:0] regfile_read_addr_8bit_a,
	output [`REG_SELECT_16BIT_WIDTH-1:0] regfile_read_addr_16bit_a,
	output [`REG_SELECT_8BIT_WIDTH-1:0] regfile_read_addr_8bit_b,
	output [`REG_SELECT_16BIT_WIDTH-1:0] regfile_read_addr_16bit_b,
	output regfile_we,
	output [`REG_SELECT_WIDTH-1:0] regfile_write_addr
);

wire int_active_int;
wire int_active_nmi;
wire int_iff2;
wire int_sampled_int;
wire int_sampled_nmi;
wire int_disable;
wire int_enable;
wire [`INT_MODE_WIDTH-1:0] int_mode;
wire int_mode_change;
wire [`INT_MODE_WIDTH-1:0] int_mode_next;
wire int_restore;
wire [`FSM_STATE_WIDTH-1:0] state;

fsm fsm_i (
	.clk(clk),
	.n_reset(n_reset),
	// Inputs
	.ipram_loaded(ipram_loaded),
	.int_disable(int_disable),
	.int_enable(int_enable),
	.int_mode_change(int_mode_change),
	.int_mode_next(int_mode_next),
	.int_request_int(int_request_int),
	.int_request_nmi(int_request_nmi),
	.int_restore(int_restore),
	.reg_instr(reg_instr),
	.reg_op_prefix(reg_op_prefix),
	.regfile_flag_s(regfile_flag_s),
	.regfile_flag_z(regfile_flag_z),
	.regfile_flag_pv(regfile_flag_pv),
	.regfile_flag_c(regfile_flag_c),
	// Outputs
	.halt_n_halt(halt_n_halt),
	.halt_n_halt_we(halt_n_halt_we),
	.int_active_int(int_active_int),
	.int_active_nmi(int_active_nmi),
	.int_iff2(int_iff2),
	.int_sampled_int(int_sampled_int),
	.int_sampled_nmi(int_sampled_nmi),
	.int_mode(int_mode),
	.state(state)
);

decoder decoder_i (
	// Inputs
	.int_active_int(int_active_int),
	.int_active_nmi(int_active_nmi),
	.int_iff2(int_iff2),
	.int_sampled_int(int_sampled_int),
	.int_sampled_nmi(int_sampled_nmi),
	.int_mode(int_mode),
	.reg_instr(reg_instr),
	.reg_op_prefix(reg_op_prefix),
	.regfile_b_zero(regfile_b_zero),
	.regfile_bc_zero(regfile_bc_zero),
	.regfile_flag_s(regfile_flag_s),
	.regfile_flag_z(regfile_flag_z),
	.regfile_flag_pv(regfile_flag_pv),
	.regfile_flag_c(regfile_flag_c),
	.state(state),
	// Outputs
	.alu_bitselect(alu_bitselect),
	.alu_iff2(alu_iff2),
	.alu_mode(alu_mode),
	.int_disable(int_disable),
	.int_enable(int_enable),
	.int_mode_change(int_mode_change),
	.int_mode_next(int_mode_next),
	.int_restore(int_restore),
	.io_n_iorq(io_n_iorq),
	.mem_dout_en(mem_dout_en),
	.mem_n_pmem(mem_n_pmem),
	.mem_n_m1(mem_n_m1),
	.mem_n_mreq(mem_n_mreq),
	.mem_n_rd(mem_n_rd),
	.mem_n_wr(mem_n_wr),
	.mux_alu_op_a_sel(mux_alu_op_a_sel),
	.mux_alu_op_b_sel(mux_alu_op_b_sel),
	.mux_int_bus_sel(mux_int_bus_sel),
	.mux_mem_addr_sel(mux_mem_addr_sel),
	.mux_mem_dout_sel(mux_mem_dout_sel),
	.reg_alu_addr_we(reg_alu_addr_we),
	.reg_int_ctrl_we(reg_int_ctrl_we),
	.reg_instr_we(reg_instr_we),
	.reg_mem_addr_we(reg_mem_addr_we),
	.reg_mem_din_hi_we(reg_mem_din_hi_we),
	.reg_mem_din_lo_we(reg_mem_din_lo_we),
	.reg_mem_dout_we(reg_mem_dout_we),
	.reg_op_prefix_next(reg_op_prefix_next),
	.reg_op_prefix_we(reg_op_prefix_we),
	.reg_pc_lo_direct(reg_pc_lo_direct),
	.reg_pc_we(reg_pc_we),
	.regfile_bc_dec(regfile_bc_dec),
	.regfile_ex(regfile_ex),
	.regfile_flags_we(regfile_flags_we),
	.regfile_read_addr_8bit_a(regfile_read_addr_8bit_a),
	.regfile_read_addr_16bit_a(regfile_read_addr_16bit_a),
	.regfile_read_addr_8bit_b(regfile_read_addr_8bit_b),
	.regfile_read_addr_16bit_b(regfile_read_addr_16bit_b),
	.regfile_we(regfile_we),
	.regfile_write_addr(regfile_write_addr)
);

endmodule
