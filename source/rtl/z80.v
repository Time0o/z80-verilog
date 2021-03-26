`timescale 1ns/10ps

module z80 (
    input clk,
    input n_reset,
    input n_int,
    input n_nmi,
    input [7:0] din,
    output reg n_iorq,
    output reg n_halt,
    output reg n_m1,
    output reg n_mreq,
    output reg n_rd,
    output reg n_wr,
    output reg [15:0] addr,
    output reg [7:0] dout,
    output reg dout_en
);

wire cpu_n_halt;
wire cpu_n_halt_we;
wire cpu_n_iorq;
wire cpu_n_pmem;
wire cpu_n_m1;
wire cpu_n_mreq;
wire cpu_n_rd;
wire cpu_n_wr;
wire [15:0] cpu_addr;
wire [7:0] cpu_din;
wire [7:0] cpu_dout;
wire cpu_dout_en;
wire ext_n_mreq;
wire ext_n_rd;
wire ext_n_wr;
wire ipram_loaded;

always @(posedge clk or negedge n_reset) begin
    if (!n_reset) begin
        n_halt  <= 1'b1;
        n_iorq  <= 1'b1;
        n_m1    <= 1'b1;
        n_mreq  <= 1'b1;
        n_rd    <= 1'b1;
        n_wr    <= 1'b1;
        addr    <= 16'h0000;
`ifdef IVERILOG
        dout    <= 8'hzz;
`else
        dout    <= 8'h00;
`endif
        dout_en <= 1'b0;
    end
    else begin
        if (cpu_n_halt_we)
            n_halt <= cpu_n_halt;

        n_iorq  <= cpu_n_iorq;
        n_m1    <= cpu_n_m1;
        n_mreq  <= ext_n_mreq;
        n_rd    <= ext_n_rd;
        n_wr    <= ext_n_wr;
        addr    <= cpu_addr;
`ifdef IVERILOG
        if (cpu_dout_en)
            dout <= cpu_dout;
        else
            dout <= 8'hzz;
`else
        dout <= cpu_dout;
        dout_en <= cpu_dout_en;
`endif
    end
end

cpu cpu_i (
    .clk(clk),
    .n_reset(n_reset),
    // Inputs
    .ipram_loaded(ipram_loaded),
    .int_n_int(n_int),
    .int_n_nmi(n_nmi),
    .mem_din(cpu_din),
    // Outputs
    .halt_n_halt(cpu_n_halt),
    .halt_n_halt_we(cpu_n_halt_we),
    .io_n_iorq(cpu_n_iorq),
    .mem_n_pmem(cpu_n_pmem),
    .mem_n_m1(cpu_n_m1),
    .mem_n_mreq(cpu_n_mreq),
    .mem_n_rd(cpu_n_rd),
    .mem_n_wr(cpu_n_wr),
    .mem_addr(cpu_addr),
    .mem_dout(cpu_dout),
    .mem_dout_en(cpu_dout_en)
);

memory_control memory_control_i (
    .clk(clk),
    .n_reset(n_reset),
    // Inputs
    .int_n_iorq(cpu_n_iorq),
    .int_n_pmem(cpu_n_pmem),
    .int_n_m1(cpu_n_m1),
    .int_n_mreq(cpu_n_mreq),
    .int_n_rd(cpu_n_rd),
    .int_n_wr(cpu_n_wr),
    .int_addr(cpu_addr),
    .int_din(cpu_dout),
    .ext_din(din),
    // Outputs
    .int_ipram_loaded(ipram_loaded),
    .int_dout(cpu_din),
    .ext_n_mreq(ext_n_mreq),
    .ext_n_rd(ext_n_rd),
    .ext_n_wr(ext_n_wr)
);

endmodule
