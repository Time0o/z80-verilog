`timescale 1ns/10ps

module memory_control (
	input clk,
	input n_reset,
	input int_n_iorq,
	input int_n_pmem,
	input int_n_m1,
	input int_n_mreq,
	input int_n_rd,
	input int_n_wr,
	input [15:0] int_addr,
	input [7:0] int_din,
	input [7:0] ext_din,
	output int_ipram_loaded,
	output reg [7:0] int_dout,
	output reg ext_n_mreq,
	output reg ext_n_rd,
	output reg ext_n_wr
);

localparam INTERNAL_PROGMEM_SIZE = 16'h1000;
localparam INTERNAL_DATAMEM_SIZE = 16'h0200;

wire [7:0] ipram_dout;
wire [7:0] idram_dout;

reg ipram_ce;
reg idram_ce;
reg idram_we;

ipram ipram_i (
	.clk(clk),
	.n_reset(n_reset),
	// Inputs
	.ce(ipram_ce),
	.din(ext_din),
	.addr(int_addr[11:0]),
	// Outputs
	.loaded(int_ipram_loaded),
	.dout(ipram_dout)
);

idram idram_i (
	.clk(clk),
	// Inputs
	.ce(idram_ce),
	.we(idram_we),
	.addr(int_addr[8:0]),
	.din(int_din),
	// Outputs
	.dout(idram_dout)
);

always @* begin
	ext_n_mreq = 1'b1;
	ext_n_rd   = 1'b1;
	ext_n_wr   = 1'b1;
	ipram_ce   = 1'b0;
	idram_ce   = 1'b0;
	idram_we   = 1'b0;
	int_dout   = ext_din;

	if (!int_n_iorq) begin
		if (int_n_m1 && !int_n_rd && int_n_wr) begin
			ext_n_rd = 1'b0;
			int_dout = ext_din;
		end
		if (!int_n_wr && int_n_rd) begin
			ext_n_wr = 1'b0;
		end
	end
	else if (!int_n_mreq) begin
		if (!int_n_pmem) begin
			if (!int_n_rd && int_n_wr) begin
				if (int_addr < INTERNAL_PROGMEM_SIZE) begin
					ipram_ce = 1'b1;

					int_dout = ipram_dout;
				end
				else begin
					ext_n_mreq = 1'b0;
					ext_n_rd   = 1'b0;

					int_dout = ext_din;
				end
			end
		end
		else if (!int_n_m1) begin // NMI
			ext_n_mreq = int_n_mreq;
			ext_n_rd   = int_n_rd;
		end
		else begin
			if (int_addr < INTERNAL_DATAMEM_SIZE) begin
				if (!int_n_rd && int_n_wr) begin
					idram_ce = 1'b1;

					int_dout = idram_dout;
				end
				if (!int_n_wr && int_n_rd) begin
					idram_ce = 1'b1;
					idram_we = 1'b1;
				end
			end
			else begin
				ext_n_mreq = 1'b0;

				if (!int_n_rd && int_n_wr) begin
					ext_n_rd   = 1'b0;

					int_dout = ext_din;
				end
				if (!int_n_wr && int_n_rd) begin
					ext_n_wr    = 1'b0;
				end
			end
		end
	end
end

endmodule
