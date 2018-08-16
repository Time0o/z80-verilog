`timescale 1ns/10ps

module top_z80 (
    input I_CLK,
    input I_N_RESET,
    input I_N_NMI,
    input I_N_INT,
    output [15:0] O_ADDR,
    output O_N_IORQ,
    output O_N_HALT,
    output O_N_M1,
    output O_N_MREQ,
    output O_N_RD,
    output O_N_WR,
    inout [7:0] IO_DATA,
    inout VCC,
    inout GND,
    inout VCC3IO,
    inout GNDIO
);

wire clk;
wire n_reset;
wire n_nmi;
wire n_int;
wire [15:0] addr;
wire n_iorq;
wire n_halt;
wire n_m1;
wire n_mreq;
wire n_rd;
wire n_wr;
wire [7:0] data_in;
wire [7:0] data_out;
wire data_out_en;

pads pads_i (
    // Inputs
    .I_CLK(I_CLK),
    .I_N_RESET(I_N_RESET),
    .I_N_NMI(I_N_NMI),
    .I_N_INT(I_N_INT),
    .n_iorq(n_iorq),
    .n_halt(n_halt),
    .n_m1(n_m1),
    .n_mreq(n_mreq),
    .n_rd(n_rd),
    .n_wr(n_wr),
    .addr(addr),
    .data_out(data_out),
    .data_out_en(data_out_en),
    // Outputs
    .O_ADDR(O_ADDR),
    .O_N_IORQ(O_N_IORQ),
    .O_N_HALT(O_N_HALT),
    .O_N_M1(O_N_M1),
    .O_N_MREQ(O_N_MREQ),
    .O_N_RD(O_N_RD),
    .O_N_WR(O_N_WR),
    .clk(clk),
    .n_reset(n_reset),
    .n_nmi(n_nmi),
    .n_int(n_int),
    .data_in(data_in),
    .IO_DATA(IO_DATA),
    .VCC(VCC),
    .GND(GND),
    .VCC3IO(VCC3IO),
    .GNDIO(GNDIO)
);

z80 z80_i (
    // Inputs
    .clk(clk),
    .n_reset(n_reset),
    .n_int(n_int),
    .n_nmi(n_nmi),
    .din(data_in),
    // Outputs
    .n_iorq(n_iorq),
    .n_halt(n_halt),
    .n_m1(n_m1),
    .n_mreq(n_mreq),
    .n_rd(n_rd),
    .n_wr(n_wr),
    .addr(addr),
    .dout(data_out),
    .dout_en(data_out_en)
);

endmodule
