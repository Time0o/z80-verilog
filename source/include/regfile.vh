localparam REG_SELECT_8BIT_A = 7'h01;
localparam REG_SELECT_8BIT_B = 7'h02;
localparam REG_SELECT_8BIT_C = 7'h04;
localparam REG_SELECT_8BIT_D = 7'h08;
localparam REG_SELECT_8BIT_E = 7'h10;
localparam REG_SELECT_8BIT_H = 7'h20;
localparam REG_SELECT_8BIT_L = 7'h40;

localparam REG_SELECT_16BIT_BC = 7'h01;
localparam REG_SELECT_16BIT_DE = 7'h02;
localparam REG_SELECT_16BIT_HL = 7'h04;
localparam REG_SELECT_16BIT_AF = 7'h08;
localparam REG_SELECT_16BIT_IX = 7'h10;
localparam REG_SELECT_16BIT_IY = 7'h20;
localparam REG_SELECT_16BIT_SP = 7'h40;

localparam REG_SELECT_A  = 14'h0001;
localparam REG_SELECT_B  = 14'h0002;
localparam REG_SELECT_C  = 14'h0004;
localparam REG_SELECT_D  = 14'h0008;
localparam REG_SELECT_E  = 14'h0010;
localparam REG_SELECT_H  = 14'h0020;
localparam REG_SELECT_L  = 14'h0040;
localparam REG_SELECT_AF = 14'h0080;
localparam REG_SELECT_BC = 14'h0100;
localparam REG_SELECT_DE = 14'h0200;
localparam REG_SELECT_HL = 14'h0400;
localparam REG_SELECT_IX = 14'h0800;
localparam REG_SELECT_IY = 14'h1000;
localparam REG_SELECT_SP = 14'h2000;

localparam BC_DEC_NONE = 2'b00;
localparam BC_DEC_LD   = 2'b01;
localparam BC_DEC_CP   = 2'b10;

localparam EX_NONE  = 3'h0;
localparam EX_DE_HL = 3'h1;
localparam EX_AF    = 3'h2;
localparam EX_EXX   = 3'h4;
