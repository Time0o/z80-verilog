`timescale 1ns/10ps

`include "buswidth.vh"

module mux_int_bus (
    input [`MUX_INT_BUS_SEL_WIDTH-1:0] data_select,
    input [15:0] alu_out,
    input [7:0] reg_int_ctrl,
    input [7:0] reg_mem_din_lo,
    input [7:0] reg_mem_din_hi,
    input [15:0] reg_pc,
    input [7:0] reg_pc_lo_direct,
    input [7:0] regfile_out_8bit_a,
    input [15:0] regfile_out_16bit_a,
    input [15:0] regfile_out_16bit_b,
    output reg [15:0] data_out
);

localparam MUX_INT_BUS_IDX_REG_INT_CTRL        = 0;
localparam MUX_INT_BUS_IDX_REG_MEM_DIN         = 1;
localparam MUX_INT_BUS_IDX_REG_PC              = 2;
localparam MUX_INT_BUS_IDX_REG_PC_DIRECT       = 3;
localparam MUX_INT_BUS_IDX_REGFILE_OUT_8BIT_A  = 4;
localparam MUX_INT_BUS_IDX_REGFILE_OUT_16BIT_A = 5;
localparam MUX_INT_BUS_IDX_REGFILE_OUT_16BIT_B = 6;

always @* begin
    data_out = alu_out;

    if (data_select[MUX_INT_BUS_IDX_REG_INT_CTRL])
        data_out = { 8'h00, reg_int_ctrl };
    if (data_select[MUX_INT_BUS_IDX_REG_MEM_DIN])
        data_out = { reg_mem_din_hi, reg_mem_din_lo };
    if (data_select[MUX_INT_BUS_IDX_REG_PC])
        data_out = reg_pc;
    if (data_select[MUX_INT_BUS_IDX_REG_PC_DIRECT])
        data_out = { 8'h00, reg_pc_lo_direct };
    if (data_select[MUX_INT_BUS_IDX_REGFILE_OUT_8BIT_A])
        data_out = regfile_out_8bit_a;
    if (data_select[MUX_INT_BUS_IDX_REGFILE_OUT_16BIT_A])
        data_out = regfile_out_16bit_a;
    if (data_select[MUX_INT_BUS_IDX_REGFILE_OUT_16BIT_B])
        data_out = regfile_out_16bit_b;
end

endmodule
