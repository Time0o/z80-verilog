`timescale 1ns/10ps

`include "buswidth.vh"

module mux_mem_dout (
	input [`MUX_MEM_DOUT_SEL_WIDTH-1:0] data_select,
	input [15:0] reg_mem_dout,
	input [7:0] reg_mem_din_lo,
	input [15:0] reg_pc,
	input [7:0] regfile_out_8bit_a,
	input [15:0] regfile_out_16bit_a,
	output reg [7:0] data_out
);

localparam MUX_MEM_DOUT_IDX_REG_MEM_DOUT_HI        = 0;
localparam MUX_MEM_DOUT_IDX_REG_MEM_DIN_LO         = 1;
localparam MUX_MEM_DOUT_IDX_REG_PC_LO              = 2;
localparam MUX_MEM_DOUT_IDX_REG_PC_HI              = 3;
localparam MUX_MEM_DOUT_IDX_REGFILE_OUT_8BIT_A     = 4;
localparam MUX_MEM_DOUT_IDX_REGFILE_OUT_16BIT_A_LO = 5;

always @* begin
	data_out = reg_mem_dout[7:0];

	if (data_select[MUX_MEM_DOUT_IDX_REG_MEM_DOUT_HI])
		data_out = reg_mem_dout[15:8];
	if (data_select[MUX_MEM_DOUT_IDX_REG_MEM_DIN_LO])
		data_out = reg_mem_din_lo;
	if (data_select[MUX_MEM_DOUT_IDX_REG_PC_LO])
		data_out = reg_pc[7:0];
	if (data_select[MUX_MEM_DOUT_IDX_REG_PC_HI])
		data_out = reg_pc[15:8];
	if (data_select[MUX_MEM_DOUT_IDX_REGFILE_OUT_8BIT_A])
		data_out = regfile_out_8bit_a;
	if (data_select[MUX_MEM_DOUT_IDX_REGFILE_OUT_16BIT_A_LO])
		data_out = regfile_out_16bit_a[7:0];
end

endmodule
