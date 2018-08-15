`timescale 1ns/10ps

module datamem_mock #(
	parameter SZ_LOG2 = 16,
	parameter INITFILE = "datamem.txt"
) (
	input clk,
	input [SZ_LOG2-1:0] addr,
	input [7:0] din,
	input ce,
	input we,
	output reg [7:0] dout
);

localparam SIZE = 1 << SZ_LOG2;

wire [SZ_LOG2-1:0] addr_int;
wire [7:0] din_int;

reg [7:0] datamem [SIZE-1:0];
reg [SZ_LOG2-1:0] addr_sampled;
reg [7:0] din_sampled;

assign #1 addr_int = addr;
assign #1 din_int  = din;

always @(posedge ce) begin
	addr_sampled <= addr_int;
	din_sampled  <= din_int;
end

always @(posedge clk) begin
	if (we) begin
		if (addr !== addr_sampled || din !== din_sampled)
			datamem[addr] <= 8'hxx;
		else
			datamem[addr] <= din;
	end
end

always @* begin
	if (!ce || we)
		dout = 8'hzz;
	else if (addr !== addr_sampled)
		dout = 8'hxx;
	else
		dout = datamem[addr];
end

initial begin
	$readmemh(INITFILE, datamem);
end

endmodule
