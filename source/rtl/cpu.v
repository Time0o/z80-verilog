`timescale 1ns/10ps

`include "buswidth.vh"

module cpu (
    input clk,
    input n_reset,
    input ipram_loaded,
    input int_n_int,
    input int_n_nmi,
    input [7:0] mem_din,
    output halt_n_halt,
    output halt_n_halt_we,
    output io_n_iorq,
    output mem_n_pmem,
    output mem_n_m1,
    output mem_n_mreq,
    output mem_n_rd,
    output mem_n_wr,
    output [15:0] mem_addr,
    output [7:0] mem_dout,
    output mem_dout_en
);

wire [2:0] alu_bitselect;
wire alu_iff2;
wire [`ALU_MODE_WIDTH-1:0] alu_mode;
wire [`MUX_ALU_OP_A_SEL_WIDTH-1:0] mux_alu_op_a_sel;
wire [`MUX_ALU_OP_B_SEL_WIDTH-1:0] mux_alu_op_b_sel;
wire [`MUX_INT_BUS_SEL_WIDTH-1:0] mux_int_bus_sel;
wire [`MUX_MEM_ADDR_SEL_WIDTH-1:0] mux_mem_addr_sel;
wire [`MUX_MEM_DOUT_SEL_WIDTH-1:0] mux_mem_dout_sel;
wire [7:0] reg_instr;
wire reg_alu_addr_we;
wire reg_int_ctrl_we;
wire reg_instr_we;
wire reg_mem_addr_we;
wire reg_mem_din_hi_we;
wire reg_mem_din_lo_we;
wire reg_mem_dout_we;
wire [`OP_PREFIX_WIDTH-1:0] reg_op_prefix;
wire [`OP_PREFIX_WIDTH-1:0] reg_op_prefix_next;
wire reg_op_prefix_we;
wire [7:0] reg_pc_lo_direct;
wire reg_pc_we;
wire [1:0] regfile_bc_dec;
wire regfile_b_zero;
wire regfile_bc_zero;
wire [2:0] regfile_ex;
wire regfile_flag_s;
wire regfile_flag_z;
wire regfile_flag_pv;
wire regfile_flag_c;
wire regfile_flags_we;
wire [`REG_SELECT_8BIT_WIDTH-1:0] regfile_read_addr_8bit_a;
wire [`REG_SELECT_16BIT_WIDTH-1:0] regfile_read_addr_16bit_a;
wire [`REG_SELECT_8BIT_WIDTH-1:0] regfile_read_addr_8bit_b;
wire [`REG_SELECT_16BIT_WIDTH-1:0] regfile_read_addr_16bit_b;
wire regfile_we;
wire [`REG_SELECT_WIDTH-1:0] regfile_write_addr;

// controller
controller controller_i (
    .clk(clk),
    .n_reset(n_reset),
    // Inputs
    .ipram_loaded(ipram_loaded),
    .int_request_int(~int_n_int),
    .int_request_nmi(~int_n_nmi),
    .reg_instr(reg_instr),
    .reg_op_prefix(reg_op_prefix),
    .regfile_b_zero(regfile_b_zero),
    .regfile_bc_zero(regfile_bc_zero),
    .regfile_flag_s(regfile_flag_s),
    .regfile_flag_z(regfile_flag_z),
    .regfile_flag_pv(regfile_flag_pv),
    .regfile_flag_c(regfile_flag_c),
    // Outputs
    .alu_bitselect(alu_bitselect),
    .alu_iff2(alu_iff2),
    .alu_mode(alu_mode),
    .halt_n_halt(halt_n_halt),
    .halt_n_halt_we(halt_n_halt_we),
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

// datapath
datapath datapath_i (
    .clk(clk),
    .n_reset(n_reset),
    // Inputs
    .alu_bitselect(alu_bitselect),
    .alu_iff2(alu_iff2),
    .alu_mode(alu_mode),
    .mem_din(mem_din),
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
    .regfile_write_addr(regfile_write_addr),
    // Outputs
    .mem_addr(mem_addr),
    .mem_dout(mem_dout),
    .regfile_b_zero(regfile_b_zero),
    .regfile_bc_zero(regfile_bc_zero),
    .regfile_flag_s(regfile_flag_s),
    .regfile_flag_z(regfile_flag_z),
    .regfile_flag_pv(regfile_flag_pv),
    .regfile_flag_c(regfile_flag_c),
    .reg_instr(reg_instr),
    .reg_op_prefix(reg_op_prefix)
);

endmodule
