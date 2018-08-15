`timescale 1ns/10ps

`include "buswidth.vh"

module mux_alu_op_b (
    input [`MUX_ALU_OP_B_SEL_WIDTH-1:0] data_select,
    input [7:0] regfile_out_8bit_b,
    input [15:0] regfile_out_16bit_b,
    input [7:0] reg_mem_din_hi,
    input [7:0] reg_mem_din_lo,
    output reg [15:0] data_out
);

localparam MUX_ALU_OP_B_IDX_REGFILE_OUT_16BIT_B    = 0;
localparam MUX_ALU_OP_B_IDX_REG_MEM_DIN            = 1;
localparam MUX_ALU_OP_B_IDX_REG_MEM_DIN_LO_SGN_EXT = 2;
localparam MUX_ALU_OP_B_IDX_CONST2                 = 3;

always @* begin
    data_out = { 8'h00, regfile_out_8bit_b };

    if (data_select[MUX_ALU_OP_B_IDX_REGFILE_OUT_16BIT_B])
        data_out = regfile_out_16bit_b;
    if (data_select[MUX_ALU_OP_B_IDX_REG_MEM_DIN])
        data_out = { reg_mem_din_hi, reg_mem_din_lo };
    if (data_select[MUX_ALU_OP_B_IDX_REG_MEM_DIN_LO_SGN_EXT])
        data_out = { {8{reg_mem_din_lo[7]}}, reg_mem_din_lo };
    if (data_select[MUX_ALU_OP_B_IDX_CONST2])
        data_out = 16'h0002;
end

endmodule
