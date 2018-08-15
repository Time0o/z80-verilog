`timescale 1ns/10ps

module ff #(parameter WIDTH = 8) (
	input clk,
	input n_reset,
	input we,
	input [WIDTH-1:0] d,

	output reg [WIDTH-1:0] q
);

always @(posedge clk, negedge n_reset) begin
	if (n_reset == 1'b0)
		q <= {WIDTH{1'b0}};
	else if (we)
		q <= d;
end

endmodule
