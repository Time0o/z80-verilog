`timescale 1ns/10ps

module tb_top_z80 (
);

`include "z80.vh"

`ifndef IVERILOG
vunit unit();
`endif

wire o_n_iorq;
wire o_n_halt;
wire o_n_m1;
wire o_n_mreq;
wire o_n_rd;
wire o_n_wr;
wire [15:0] o_addr;
wire [7:0] io_data;

reg i_clk;
reg i_n_reset;
reg i_n_nmi;
reg i_n_int;
reg [7:0] din_init;
reg [4:0] loop_counter;
reg loop_condition;

localparam PROGMEM_BYTES = 4096;
localparam INT_DATAMEM_BYTES = 512;
localparam EXT_DATAMEM_BYTES = 65536;
localparam IOMEM_BYTES = 65536;

localparam PROGMEM_BYTES_LOG2 = 12;
localparam INT_DATAMEM_BYTES_LOG2 = 9;
localparam EXT_DATAMEM_BYTES_LOG2 = 16;
localparam IOMEM_BYTES_LOG2 = 16;

datamem_mock #(
    .SZ_LOG2(EXT_DATAMEM_BYTES_LOG2),
    .INITFILE("datamem_ext.txt")
) datamem_ext_i (
    .clk(i_clk),
    // Inputs
    .addr(o_addr[EXT_DATAMEM_BYTES_LOG2-1:0]),
    .din(io_data),
    .ce(~o_n_mreq),
    .we(~o_n_wr),
    // Outputs
    .dout(io_data)
);

datamem_mock #(
    .SZ_LOG2(IOMEM_BYTES_LOG2),
    .INITFILE("iomem.txt")
) iodev_mock_i (
    .clk(i_clk),
    // Inputs
    .addr(o_addr[IOMEM_BYTES_LOG2-1:0]),
    .din(io_data),
    .ce(~o_n_iorq),
    .we(~o_n_wr),
    // Outputs
    .dout(io_data)
);

`ifdef IVERILOG

z80 z80_i (
    // Inputs
    .clk(i_clk),
    .n_reset(i_n_reset),
    .n_int(i_n_int),
    .n_nmi(i_n_nmi),
    .din(io_data),
    // Outputs
    .n_iorq(o_n_iorq),
    .n_halt(o_n_halt),
    .n_m1(o_n_m1),
    .n_mreq(o_n_mreq),
    .n_rd(o_n_rd),
    .n_wr(o_n_wr),
    .addr(o_addr),
    .dout(io_data)
);

`else

top_z80 top_z80_i (
    .I_CLK(i_clk),
    .I_N_RESET(i_n_reset),
    .I_N_NMI(i_n_nmi),
    .I_N_INT(i_n_int),
    .O_ADDR(o_addr),
    .O_N_IORQ(o_n_iorq),
    .O_N_HALT(o_n_halt),
    .O_N_M1(o_n_m1),
    .O_N_MREQ(o_n_mreq),
    .O_N_RD(o_n_rd),
    .O_N_WR(o_n_wr),
    .IO_DATA(io_data),
    .VCC(),
    .GND(),
    .VCC3IO(),
    .GNDIO()
);

// externally initialize program memory
reg [7:0] progmem [PROGMEM_BYTES-1:0];
reg [PROGMEM_BYTES_LOG2:0] progmem_counter;

initial begin
    $readmemh("progmem.txt", progmem);
    progmem_counter = 0;
end

always @(posedge i_clk) begin
    # 10

    if (progmem_counter <= PROGMEM_BYTES) begin
        if (progmem_counter != 0)
            din_init <= progmem[progmem_counter - 1];
        progmem_counter <= progmem_counter + 1;
    end
    else begin
        din_init <= 8'hzz;
    end
end

assign io_data = din_init;

// initialize swap data memory
reg [7:0] ext_datamem_buf [EXT_DATAMEM_BYTES-1:0];
reg [7:0] datamem_swap [INT_DATAMEM_BYTES+EXT_DATAMEM_BYTES-1:0];
reg [7:0] iomem_swap [IOMEM_BYTES:0];

integer i;
initial begin
    // add internal data memory
    $readmemh("datamem_int2.txt", datamem_swap, 0, (INT_DATAMEM_BYTES / 2) - 1);

    for (i = 0; i < (INT_DATAMEM_BYTES / 2); i = i + 1) begin
        datamem_swap[i + (INT_DATAMEM_BYTES / 2)] = datamem_swap[i];
    end

    $readmemh("datamem_int1.txt", datamem_swap, 0, (INT_DATAMEM_BYTES / 2) - 1);

    // add external data memory
    $readmemh("datamem_ext.txt", ext_datamem_buf, 0, EXT_DATAMEM_BYTES - 1);

    for (i = 0; i < EXT_DATAMEM_BYTES; i = i +1) begin
        datamem_swap[i + INT_DATAMEM_BYTES] =
            ext_datamem_buf[i + INT_DATAMEM_BYTES];
    end

    $readmemh("iomem.txt", iomem_swap, 0, IOMEM_BYTES - 1);
end

`endif // IVERILOG

// clock
parameter CLKPERIOD = 100;

initial begin
    i_clk = 1'b1;
end

always #(CLKPERIOD / 2) i_clk = ~i_clk;

// run testcase
initial begin
    i_n_reset = 1'b1;
    i_n_int   = 1'b1;
    i_n_nmi   = 1'b1;

    #(3 * CLKPERIOD / 4);

    i_n_reset = 1'b0;

    #(CLKPERIOD);

    i_n_reset = 1'b1;

`ifdef IVERILOG
    $dumpfile("run.vcd");
    $dumpvars(0,tb_top_z80);
    #(10000 * CLKPERIOD);
    $finish;
`else
    #((PROGMEM_BYTES + 1) * CLKPERIOD);

    `include "testcase.v"
`endif

end

endmodule
