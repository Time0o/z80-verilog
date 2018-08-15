`timescale 1ns/10ps

`include "buswidth.vh"

module mux_mem_addr (
	input [`MUX_MEM_ADDR_SEL_WIDTH-1:0] data_select,
	input [15:0] alu_out,
	input [7:0] reg_int_ctrl,
	input [15:0] reg_mem_addr,
	input [7:0] reg_mem_din_hi,
	input [7:0] reg_mem_din_lo,
	input [15:0] reg_pc,
	input [7:0] regfile_out_8bit_b,
	input [15:0] regfile_out_16bit_b,
	output reg [15:0] data_out
);

localparam MUX_MEM_ADDR_IDX_INT_ADDR            = 0;
localparam MUX_MEM_ADDR_IDX_REG_IMM             = 1;
localparam MUX_MEM_ADDR_IDX_REG_MEM_DIN         = 2;
localparam MUX_MEM_ADDR_IDX_REG_MEM_ADDR        = 3;
localparam MUX_MEM_ADDR_IDX_REG_PC              = 4;
localparam MUX_MEM_ADDR_IDX_REGFILE_OUT_16BIT_B = 5;

always @* begin
	data_out = alu_out;

	if (data_select[MUX_MEM_ADDR_IDX_INT_ADDR])
		data_out = { reg_int_ctrl, reg_mem_din_lo[7:1], 1'b0 };
	if (data_select[MUX_MEM_ADDR_IDX_REG_IMM])
		data_out = { regfile_out_8bit_b, reg_mem_din_lo };
	if (data_select[MUX_MEM_ADDR_IDX_REG_MEM_ADDR])
		data_out = reg_mem_addr;
	if (data_select[MUX_MEM_ADDR_IDX_REG_MEM_DIN])
		data_out = { reg_mem_din_hi, reg_mem_din_lo };
	if (data_select[MUX_MEM_ADDR_IDX_REG_PC])
		data_out = reg_pc;
	if (data_select[MUX_MEM_ADDR_IDX_REGFILE_OUT_16BIT_B])
		data_out = regfile_out_16bit_b;
end

endmodule
