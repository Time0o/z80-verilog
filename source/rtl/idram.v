`timescale 1ns/10ps

module idram (
    input clk,
    input ce,
    input we,
    input [8:0] addr,
    input [7:0] din,
    output [7:0] dout
);

`ifdef IVERILOG

wire cs1, cs2, we_int;
wire [7:0] din_int;

datamem_mock #(
    .SZ_LOG2(8),
    .INITFILE("datamem_int1.txt")
) datamem_mock_i1 (
    .clk(clk),
    .ce(cs1),
    .we(we_int),
    .addr(addr[7:0]),
    .din(din_int),
    .dout(dout)
);

datamem_mock #(
    .SZ_LOG2(8),
    .INITFILE("datamem_int2.txt")
) datamem_mock_i2 (
    .clk(clk),
    .ce(cs2),
    .we(we_int),
    .addr(addr[7:0]),
    .din(din_int),
    .dout(dout)
);

assign #10 cs1     = ~addr[8] && ce;
assign #10 cs2     = addr[8] && ce;
assign #10 we_int  = we;
assign #10 din_int = din;

`else // IVERILOG

wire csb1, csb2, web_int;
wire [7:0] din_int, dout1, dout2;

SY180_256X8X1CM8 #(.INITFILE("datamem_int1.txt")) SY180_256X8X1CM8_i1 (
    .CK(clk),
    .CSB(csb1),
    .A0(addr[0]),
    .A1(addr[1]),
    .A2(addr[2]),
    .A3(addr[3]),
    .A4(addr[4]),
    .A5(addr[5]),
    .A6(addr[6]),
    .A7(addr[7]),
    .DO0(dout1[0]),
    .DO1(dout1[1]),
    .DO2(dout1[2]),
    .DO3(dout1[3]),
    .DO4(dout1[4]),
    .DO5(dout1[5]),
    .DO6(dout1[6]),
    .DO7(dout1[7]),
    .DI0(din_int[0]),
    .DI1(din_int[1]),
    .DI2(din_int[2]),
    .DI3(din_int[3]),
    .DI4(din_int[4]),
    .DI5(din_int[5]),
    .DI6(din_int[6]),
    .DI7(din_int[7]),
    .WEB(web_int)
);

SY180_256X8X1CM8 #(.INITFILE("datamem_int2.txt")) SY180_256X8X1CM8_i2 (
    .CK(clk),
    .CSB(csb2),
    .A0(addr[0]),
    .A1(addr[1]),
    .A2(addr[2]),
    .A3(addr[3]),
    .A4(addr[4]),
    .A5(addr[5]),
    .A6(addr[6]),
    .A7(addr[7]),
    .DO0(dout2[0]),
    .DO1(dout2[1]),
    .DO2(dout2[2]),
    .DO3(dout2[3]),
    .DO4(dout2[4]),
    .DO5(dout2[5]),
    .DO6(dout2[6]),
    .DO7(dout2[7]),
    .DI0(din_int[0]),
    .DI1(din_int[1]),
    .DI2(din_int[2]),
    .DI3(din_int[3]),
    .DI4(din_int[4]),
    .DI5(din_int[5]),
    .DI6(din_int[6]),
    .DI7(din_int[7]),
    .WEB(web_int)
);

assign #10 csb1    = ~(~addr[8] && ce);
assign #10 csb2    = ~(addr[8] && ce);
assign #10 web_int = ~we;
assign #10 din_int = din;

assign dout = addr[8] ? dout2 : dout1;

`endif // IVERILOG

endmodule
