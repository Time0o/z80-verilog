`timescale 1ns/10ps

`include "buswidth.vh"

module regfile (
    input clk,
    input n_reset,
    input [1:0] bc_dec,
    input [2:0] ex,
    input [5:0] flags_in,
    input flags_we,
    input [15:0] reg_in,
    input [`REG_SELECT_8BIT_WIDTH-1:0] reg_read_addr_8bit_a,
    input [`REG_SELECT_16BIT_WIDTH-1:0] reg_read_addr_16bit_a,
    input [`REG_SELECT_8BIT_WIDTH-1:0] reg_read_addr_8bit_b,
    input [`REG_SELECT_16BIT_WIDTH-1:0] reg_read_addr_16bit_b,
    input reg_we,
    input [`REG_SELECT_WIDTH-1:0] reg_write_addr,
    output b_zero,
    output bc_zero,
    output [5:0] flags_out,
    output reg [7:0] reg_out_8bit_a,
    output reg [7:0] reg_out_8bit_b,
    output reg [15:0] reg_out_16bit_a,
    output reg [15:0] reg_out_16bit_b
);

localparam REG_SELECT_8BIT_IDX_A  = 0;
localparam REG_SELECT_8BIT_IDX_B  = 1;
localparam REG_SELECT_8BIT_IDX_C  = 2;
localparam REG_SELECT_8BIT_IDX_D  = 3;
localparam REG_SELECT_8BIT_IDX_E  = 4;
localparam REG_SELECT_8BIT_IDX_H  = 5;
localparam REG_SELECT_8BIT_IDX_L  = 6;

localparam REG_SELECT_16BIT_IDX_BC = 0;
localparam REG_SELECT_16BIT_IDX_DE = 1;
localparam REG_SELECT_16BIT_IDX_HL = 2;
localparam REG_SELECT_16BIT_IDX_AF = 3;
localparam REG_SELECT_16BIT_IDX_IX = 4;
localparam REG_SELECT_16BIT_IDX_IY = 5;
localparam REG_SELECT_16BIT_IDX_SP = 6;

localparam REG_SELECT_IDX_A  = 0;
localparam REG_SELECT_IDX_B  = 1;
localparam REG_SELECT_IDX_C  = 2;
localparam REG_SELECT_IDX_D  = 3;
localparam REG_SELECT_IDX_E  = 4;
localparam REG_SELECT_IDX_H  = 5;
localparam REG_SELECT_IDX_L  = 6;
localparam REG_SELECT_IDX_AF = 7;
localparam REG_SELECT_IDX_BC = 8;
localparam REG_SELECT_IDX_DE = 9;
localparam REG_SELECT_IDX_HL = 10;
localparam REG_SELECT_IDX_IX = 11;
localparam REG_SELECT_IDX_IY = 12;
localparam REG_SELECT_IDX_SP = 13;

localparam BC_DEC_IDX_LD = 0;
localparam BC_DEC_IDX_CP = 1;

localparam EX_IDX_DE_HL = 0;
localparam EX_IDX_AF    = 1;
localparam EX_IDX_EXX   = 2;

reg [7:0] a, ap;
reg [7:0] f, fp;
reg [7:0] b, c, bp, cp;
reg [7:0] d, e, dp, ep;
reg [7:0] h, l, hp, lp;
reg [15:0] ix;
reg [15:0] iy;
reg [15:0] sp;

reg [7:0] reg_out_8bit_a_1, reg_out_8bit_b_1;
reg [7:0] reg_out_8bit_a_2, reg_out_8bit_b_2;
reg [7:0] reg_out_8bit_a_3, reg_out_8bit_b_3;
reg [7:0] reg_out_8bit_a_4, reg_out_8bit_b_4;
reg [7:0] reg_out_8bit_a_5, reg_out_8bit_b_5;
reg [7:0] reg_out_8bit_a_6, reg_out_8bit_b_6;
reg [7:0] reg_out_8bit_a_7, reg_out_8bit_b_7;

reg [15:0] reg_out_16bit_a_1, reg_out_16bit_b_1;
reg [15:0] reg_out_16bit_a_2, reg_out_16bit_b_2;
reg [15:0] reg_out_16bit_a_3, reg_out_16bit_b_3;
reg [15:0] reg_out_16bit_a_4, reg_out_16bit_b_4;
reg [15:0] reg_out_16bit_a_5, reg_out_16bit_b_5;
reg [15:0] reg_out_16bit_a_6, reg_out_16bit_b_6;
reg [15:0] reg_out_16bit_a_7, reg_out_16bit_b_7;

assign b_zero = ~|b;
assign bc_zero = ~|{ b, c };

assign flags_out = { f[7:6], f[4], f[2:0] };

always @* begin
    reg_out_8bit_a = reg_out_8bit_a_1 | reg_out_8bit_a_2 |
                     reg_out_8bit_a_3 | reg_out_8bit_a_4 |
                     reg_out_8bit_a_5 | reg_out_8bit_a_6 |
                     reg_out_8bit_a_7;
end

always @* begin
    reg_out_8bit_b = reg_out_8bit_b_1 | reg_out_8bit_b_2 |
                     reg_out_8bit_b_3 | reg_out_8bit_b_4 |
                     reg_out_8bit_b_5 | reg_out_8bit_b_6 |
                     reg_out_8bit_b_7;
end

always @* begin
    reg_out_16bit_a = reg_out_16bit_a_1 | reg_out_16bit_a_2 |
                      reg_out_16bit_a_3 | reg_out_16bit_a_4 |
                      reg_out_16bit_a_5 | reg_out_16bit_a_6 |
                      reg_out_16bit_a_7;
end

always @* begin
    reg_out_16bit_b = reg_out_16bit_b_1 | reg_out_16bit_b_2 |
                      reg_out_16bit_b_3 | reg_out_16bit_b_4 |
                      reg_out_16bit_b_5 | reg_out_16bit_b_6 |
                      reg_out_16bit_b_7;
end

always @* begin
    reg_out_8bit_a_1 = 8'h00;
    reg_out_8bit_a_2 = 8'h00;
    reg_out_8bit_a_3 = 8'h00;
    reg_out_8bit_a_4 = 8'h00;
    reg_out_8bit_a_5 = 8'h00;
    reg_out_8bit_a_6 = 8'h00;
    reg_out_8bit_a_7 = 8'h00;

    if (reg_read_addr_8bit_a[REG_SELECT_8BIT_IDX_A])
        reg_out_8bit_a_1 = a;
    if (reg_read_addr_8bit_a[REG_SELECT_8BIT_IDX_B])
        reg_out_8bit_a_2 = b;
    if (reg_read_addr_8bit_a[REG_SELECT_8BIT_IDX_C])
        reg_out_8bit_a_3 = c;
    if (reg_read_addr_8bit_a[REG_SELECT_8BIT_IDX_D])
        reg_out_8bit_a_4 = d;
    if (reg_read_addr_8bit_a[REG_SELECT_8BIT_IDX_E])
        reg_out_8bit_a_5 = e;
    if (reg_read_addr_8bit_a[REG_SELECT_8BIT_IDX_H])
        reg_out_8bit_a_6 = h;
    if (reg_read_addr_8bit_a[REG_SELECT_8BIT_IDX_L])
        reg_out_8bit_a_7 = l;
end

always @* begin
    reg_out_16bit_a_1 = 16'h0000;
    reg_out_16bit_a_2 = 16'h0000;
    reg_out_16bit_a_3 = 16'h0000;
    reg_out_16bit_a_4 = 16'h0000;
    reg_out_16bit_a_5 = 16'h0000;
    reg_out_16bit_a_6 = 16'h0000;
    reg_out_16bit_a_7 = 16'h0000;

    if (reg_read_addr_16bit_a[REG_SELECT_16BIT_IDX_BC])
        reg_out_16bit_a_1 = { b, c };
    if (reg_read_addr_16bit_a[REG_SELECT_16BIT_IDX_DE])
        reg_out_16bit_a_2 = { d, e };
    if (reg_read_addr_16bit_a[REG_SELECT_16BIT_IDX_HL])
        reg_out_16bit_a_3 = { h, l };
    if (reg_read_addr_16bit_a[REG_SELECT_16BIT_IDX_IX])
        reg_out_16bit_a_5 = ix;
    if (reg_read_addr_16bit_a[REG_SELECT_16BIT_IDX_IY])
        reg_out_16bit_a_6 = iy;
    if (reg_read_addr_16bit_a[REG_SELECT_16BIT_IDX_SP])
        reg_out_16bit_a_7 = sp;
end

always @* begin
    reg_out_8bit_b_1 = 8'h00;
    reg_out_8bit_b_2 = 8'h00;
    reg_out_8bit_b_3 = 8'h00;
    reg_out_8bit_b_4 = 8'h00;
    reg_out_8bit_b_5 = 8'h00;
    reg_out_8bit_b_6 = 8'h00;
    reg_out_8bit_b_7 = 8'h00;

    if (reg_read_addr_8bit_b[REG_SELECT_8BIT_IDX_A])
        reg_out_8bit_b_1 = a;
    if (reg_read_addr_8bit_b[REG_SELECT_8BIT_IDX_B])
        reg_out_8bit_b_2 = b;
    if (reg_read_addr_8bit_b[REG_SELECT_8BIT_IDX_C])
        reg_out_8bit_b_3 = c;
    if (reg_read_addr_8bit_b[REG_SELECT_8BIT_IDX_D])
        reg_out_8bit_b_4 = d;
    if (reg_read_addr_8bit_b[REG_SELECT_8BIT_IDX_E])
        reg_out_8bit_b_5 = e;
    if (reg_read_addr_8bit_b[REG_SELECT_8BIT_IDX_H])
        reg_out_8bit_b_6 = h;
    if (reg_read_addr_8bit_b[REG_SELECT_8BIT_IDX_L])
        reg_out_8bit_b_7 = l;
end

always @* begin
    reg_out_16bit_b_1 = 16'h0000;
    reg_out_16bit_b_2 = 16'h0000;
    reg_out_16bit_b_3 = 16'h0000;
    reg_out_16bit_b_4 = 16'h0000;
    reg_out_16bit_b_5 = 16'h0000;
    reg_out_16bit_b_6 = 16'h0000;
    reg_out_16bit_b_7 = 16'h0000;

    if (reg_read_addr_16bit_b[REG_SELECT_16BIT_IDX_AF])
        reg_out_16bit_b_4 = { a, f };
    if (reg_read_addr_16bit_b[REG_SELECT_16BIT_IDX_BC])
         reg_out_16bit_b_1 = { b, c };
    if (reg_read_addr_16bit_b[REG_SELECT_16BIT_IDX_DE])
        reg_out_16bit_b_2 = { d, e };
    if (reg_read_addr_16bit_b[REG_SELECT_16BIT_IDX_HL])
        reg_out_16bit_b_3 = { h, l };
    if (reg_read_addr_16bit_b[REG_SELECT_16BIT_IDX_IX])
        reg_out_16bit_b_5 = ix;
    if (reg_read_addr_16bit_b[REG_SELECT_16BIT_IDX_IY])
        reg_out_16bit_b_6 = iy;
    if (reg_read_addr_16bit_b[REG_SELECT_16BIT_IDX_SP])
        reg_out_16bit_b_7 = sp;
end

always @(posedge clk or negedge n_reset) begin
    if (n_reset == 1'b0) begin
        a  <= 8'h00;
        ap <= 8'h00;
        f  <= 8'h00;
        fp <= 8'h00;
        b  <= 8'h00;
        bp <= 8'h00;
        c  <= 8'h00;
        cp <= 8'h00;
        d  <= 8'h00;
        dp <= 8'h00;
        e  <= 8'h00;
        ep <= 8'h00;
        h  <= 8'h00;
        hp <= 8'h00;
        l  <= 8'h00;
        lp <= 8'h00;
        ix <= 16'h0000;
        iy <= 16'h0000;
        sp <= 16'h0000;
    end
    else begin
        if (flags_we) begin
            f <= { flags_in[5:4], 1'b0, flags_in[3], 1'b0, flags_in[2:0] };
        end

        if (reg_we && reg_write_addr[REG_SELECT_IDX_A])
            a <= reg_in[7:0];
        if (reg_we && reg_write_addr[REG_SELECT_IDX_B])
            b <= reg_in[7:0];
        if (reg_we && reg_write_addr[REG_SELECT_IDX_C])
            c <= reg_in[7:0];
        if (reg_we && reg_write_addr[REG_SELECT_IDX_D])
            d <= reg_in[7:0];
        if (reg_we && reg_write_addr[REG_SELECT_IDX_E])
            e <= reg_in[7:0];
        if (reg_we && reg_write_addr[REG_SELECT_IDX_H])
            h <= reg_in[7:0];
        if (reg_we && reg_write_addr[REG_SELECT_IDX_L])
            l <= reg_in[7:0];
        if (reg_we && reg_write_addr[REG_SELECT_IDX_AF])
            { a, f } <= reg_in;
        if (reg_we && reg_write_addr[REG_SELECT_IDX_BC])
            { b, c } <= reg_in;
        if (reg_we && reg_write_addr[REG_SELECT_IDX_DE])
            { d, e } <= reg_in;
        if (reg_we && reg_write_addr[REG_SELECT_IDX_HL])
            { h, l } <= reg_in;
        if (reg_we && reg_write_addr[REG_SELECT_IDX_IX])
            ix <= reg_in;
        if (reg_we && reg_write_addr[REG_SELECT_IDX_IY])
            iy <= reg_in;
        if (reg_we && reg_write_addr[REG_SELECT_IDX_SP])
            sp <= reg_in;

        if (bc_dec[BC_DEC_IDX_LD]) begin
            f[4] <= 1'b0;
            f[2] <= ~({ b, c } == 16'h0001);
            f[1] <= 1'b0;

            { b, c } <= { b, c } - 16'h0001;
        end
        if (bc_dec[BC_DEC_IDX_CP]) begin
            f[2] <= ~({ b, c } == 16'h0001);

            { b, c } <= { b, c } - 16'h0001;
        end

        if (ex[EX_IDX_DE_HL]) begin
            { d, e } <= { h, l };
            { h, l } <= { d, e };
        end
        if (ex[EX_IDX_AF]) begin
            a  <= ap;
            f  <= fp;
            ap <= a;
            fp <= f;
        end
        if (ex[EX_IDX_EXX]) begin
            b  <= bp;
            c  <= cp;
            bp <= b;
            cp <= c;
            d  <= dp;
            e  <= ep;
            dp <= d;
            ep <= e;
            h  <= hp;
            l  <= lp;
            hp <= h;
            lp <= l;
        end
    end
end

endmodule
