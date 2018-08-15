`timescale 1ns/10ps

`include "buswidth.vh"

module mux_alu_op_a (
	input [`MUX_ALU_OP_A_SEL_WIDTH-1:0] data_select,
	input [7:0] regfile_out_8bit_a,
	input [15:0] regfile_out_16bit_a,
	input [15:0] reg_mem_addr,
	input [7:0] reg_mem_din_hi,
	input [7:0] reg_mem_din_lo,
	input [15:0] reg_pc,
	input [7:0] reg_int_ctrl,
	output reg [15:0] data_out
);

localparam MUX_ALU_OP_A_IDX_REGFILE_OUT_16BIT_A  = 0;
localparam MUX_ALU_OP_A_IDX_REG_MEM_ADDR         = 1;
localparam MUX_ALU_OP_A_IDX_REG_MEM_DIN          = 2;
localparam MUX_ALU_OP_A_IDX_REG_PC               = 3;
localparam MUX_ALU_OP_A_IDX_REG_INT_CTRL         = 4;

always @* begin
	data_out = { 8'h00, regfile_out_8bit_a };

	if (data_select[MUX_ALU_OP_A_IDX_REGFILE_OUT_16BIT_A])
		data_out = regfile_out_16bit_a;
	if (data_select[MUX_ALU_OP_A_IDX_REG_MEM_ADDR])
		data_out = reg_mem_addr;
	if (data_select[MUX_ALU_OP_A_IDX_REG_MEM_DIN])
		data_out = { reg_mem_din_hi, reg_mem_din_lo };
	if (data_select[MUX_ALU_OP_A_IDX_REG_PC])
		data_out = reg_pc;
	if (data_select[MUX_ALU_OP_A_IDX_REG_INT_CTRL])
		data_out = { 8'h00, reg_int_ctrl };
end

endmodule
