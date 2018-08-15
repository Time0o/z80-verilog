`timescale 1ns/10ps

module pads (
	input I_CLK,
	input I_N_RESET,
	input I_N_NMI,
	input I_N_INT,
	input n_iorq,
	input n_halt,
	input n_m1,
	input n_mreq,
	input n_rd,
	input n_wr,
	input [15:0] addr,
	input [7:0] data_out,
	input data_out_en,
	output [15:0] O_ADDR,
	output O_N_IORQ,
	output O_N_HALT,
	output O_N_M1,
	output O_N_MREQ,
	output O_N_RD,
	output O_N_WR,
	output clk,
	output n_reset,
	output n_nmi,
	output n_int,
	output [7:0] data_in,
	inout [7:0] IO_DATA,
	inout VCC,
	inout GND,
	inout VCC3IO,
	inout GNDIO
);

// Inputs ====================================================================

XMC clk_pad_i (
	.I(I_CLK),
	.O(clk),
	.SMT(1'b0),
	.PU(1'b0),
	.PD(1'b0)
);

XMC n_reset_pad_i (
	.I(I_N_RESET),
	.O(n_reset),
	.SMT(1'b0),
	.PU(1'b0),
	.PD(1'b0)
);

XMC n_nmi_pad_i (
	.I(I_N_NMI),
	.O(n_nmi),
	.SMT(1'b0),
	.PU(1'b0),
	.PD(1'b0)
);

XMC n_int_pad_i (
	.I(I_N_INT),
	.O(n_int),
	.SMT(1'b0),
	.PU(1'b0),
	.PD(1'b0)
);

// Outputs ===================================================================

YA2GSC addr_pad_i [15:0] (
	.O(O_ADDR),
	.I(addr),
	.E(1'b1),
	.E2(1'b1),
	.E4(1'b1),
	.E8(1'b0),
	.SR(1'b1)
);

YA2GSC n_iorq_pad_i (
	.O(O_N_IORQ),
	.I(n_iorq),
	.E(1'b1),
	.E2(1'b1),
	.E4(1'b1),
	.E8(1'b0),
	.SR(1'b1)
);

YA2GSC n_halt_pad_i (
	.O(O_N_HALT),
	.I(n_halt),
	.E(1'b1),
	.E2(1'b1),
	.E4(1'b1),
	.E8(1'b0),
	.SR(1'b1)
);

YA2GSC n_m1_pad_i (
	.O(O_N_M1),
	.I(n_m1),
	.E(1'b1),
	.E2(1'b1),
	.E4(1'b1),
	.E8(1'b0),
	.SR(1'b1)
);

YA2GSC n_mreq_pad_i (
	.O(O_N_MREQ),
	.I(n_mreq),
	.E(1'b1),
	.E2(1'b1),
	.E4(1'b1),
	.E8(1'b0),
	.SR(1'b1)
);

YA2GSC n_rd_pad_i (
	.O(O_N_RD),
	.I(n_rd),
	.E(1'b1),
	.E2(1'b1),
	.E4(1'b1),
	.E8(1'b0),
	.SR(1'b1)
);

YA2GSC n_wr_pad_i (
	.O(O_N_WR),
	.I(n_wr),
	.E(1'b1),
	.E2(1'b1),
	.E4(1'b1),
	.E8(1'b0),
	.SR(1'b1)
);

// Inout =====================================================================

ZMA2GSC data_pad_i [7:0] (
	.IO(IO_DATA),
	.I(data_out),
	.O(data_in),
	.E(data_out_en),
	.E2(1'b1),
	.E4(1'b1),
	.E8(1'b0),
	.SR(1'b1),
	.SMT(1'b0),
	.PU(1'b1),
	.PD(1'b1)
);

VCCKC VCC_pad_i(
	.VCC(VCC)
);

GNDKC GND_pad_i(
	.GND(GND)
);

VCC3IOC VCC3IO_pad_i(
	.VCC3IO(VCC3IO)
);

GNDIOC GNDIO_pad_i(
	.GNDIO(GNDIO)
);

CORNERC NWCORNER_pad_i ();
CORNERC NECORNER_pad_i ();
CORNERC SECORNER_pad_i ();
CORNERC SWCORNER_pad_i ();

endmodule
