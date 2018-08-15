`timescale 1ns/10ps

module ipram (
	input clk,
	input n_reset,
	input ce,
	input [11:0] addr,
	input [7:0] din,
	output reg [7:0] dout,
	output loaded
);

wire [31:0] dout_int;

reg [9:0] addr_word;
reg [3:0] bwe;
reg csb;
reg [12:0] counter;
reg [7:0] din_int;

SY180_1024X8X4CM4 SY180_1024X8X4CM4_i (
	.A0(addr_word[0]),
	.A1(addr_word[1]),
	.A2(addr_word[2]),
	.A3(addr_word[3]),
	.A4(addr_word[4]),
	.A5(addr_word[5]),
	.A6(addr_word[6]),
	.A7(addr_word[7]),
	.A8(addr_word[8]),
	.A9(addr_word[9]),
	.DO0(dout_int[0]),
	.DO1(dout_int[1]),
	.DO2(dout_int[2]),
	.DO3(dout_int[3]),
	.DO4(dout_int[4]),
	.DO5(dout_int[5]),
	.DO6(dout_int[6]),
	.DO7(dout_int[7]),
	.DO8(dout_int[8]),
	.DO9(dout_int[9]),
	.DO10(dout_int[10]),
	.DO11(dout_int[11]),
	.DO12(dout_int[12]),
	.DO13(dout_int[13]),
	.DO14(dout_int[14]),
	.DO15(dout_int[15]),
	.DO16(dout_int[16]),
	.DO17(dout_int[17]),
	.DO18(dout_int[18]),
	.DO19(dout_int[19]),
	.DO20(dout_int[20]),
	.DO21(dout_int[21]),
	.DO22(dout_int[22]),
	.DO23(dout_int[23]),
	.DO24(dout_int[24]),
	.DO25(dout_int[25]),
	.DO26(dout_int[26]),
	.DO27(dout_int[27]),
	.DO28(dout_int[28]),
	.DO29(dout_int[29]),
	.DO30(dout_int[30]),
	.DO31(dout_int[31]),
	.DI0(din_int[0]),
	.DI1(din_int[1]),
	.DI2(din_int[2]),
	.DI3(din_int[3]),
	.DI4(din_int[4]),
	.DI5(din_int[5]),
	.DI6(din_int[6]),
	.DI7(din_int[7]),
	.DI8(din_int[0]),
	.DI9(din_int[1]),
	.DI10(din_int[2]),
	.DI11(din_int[3]),
	.DI12(din_int[4]),
	.DI13(din_int[5]),
	.DI14(din_int[6]),
	.DI15(din_int[7]),
	.DI16(din_int[0]),
	.DI17(din_int[1]),
	.DI18(din_int[2]),
	.DI19(din_int[3]),
	.DI20(din_int[4]),
	.DI21(din_int[5]),
	.DI22(din_int[6]),
	.DI23(din_int[7]),
	.DI24(din_int[0]),
	.DI25(din_int[1]),
	.DI26(din_int[2]),
	.DI27(din_int[3]),
	.DI28(din_int[4]),
	.DI29(din_int[5]),
	.DI30(din_int[6]),
	.DI31(din_int[7]),
	.WEB0(bwe[0]),
	.WEB1(bwe[1]),
	.WEB2(bwe[2]),
	.WEB3(bwe[3]),
	.CK(clk),
	.CSB(csb)
);

assign loaded = (counter == 13'b1000000000000);

always @(posedge clk, negedge n_reset) begin
	if (n_reset == 1'b0) begin
		counter <= 13'b0000000000000;
	end
	else if (!loaded) begin
		counter <= counter + 13'b0000000000001;
	end
end

always @* begin
	#10

	din_int = din;
	dout    = 8'h00;
	bwe     = 4'b1111;

	if (!loaded) begin
		csb = 1'b0;

		addr_word = counter[11:2];

		case (counter[1:0])
			2'b00: bwe[3] = 1'b0;
			2'b01: bwe[2] = 1'b0;
			2'b10: bwe[1] = 1'b0;
			2'b11: bwe[0] = 1'b0;
		endcase
	end
	else begin
		csb = ~ce;

		addr_word = addr[11:2];

		case (addr[1:0])
			2'b00: dout = dout_int[31:24];
			2'b01: dout = dout_int[23:16];
			2'b10: dout = dout_int[15:8];
			2'b11: dout = dout_int[7:0];
		endcase
	end
end

endmodule
