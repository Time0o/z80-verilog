/*****************************************************************************
 Alu Operand A Mux
 *****************************************************************************/
localparam MUX_ALU_OP_A_SEL_REGFILE_OUT_8BIT_A  = 5'h00;
localparam MUX_ALU_OP_A_SEL_REGFILE_OUT_16BIT_A = 5'h01;
localparam MUX_ALU_OP_A_SEL_REG_MEM_ADDR        = 5'h02;
localparam MUX_ALU_OP_A_SEL_REG_MEM_DIN         = 5'h04;
localparam MUX_ALU_OP_A_SEL_REG_PC              = 5'h08;
localparam MUX_ALU_OP_A_SEL_REG_INT_CTRL        = 5'h10;

/*****************************************************************************
 Alu Operand B Mux
 *****************************************************************************/
localparam MUX_ALU_OP_B_SEL_REGFILE_OUT_8BIT_B     = 4'h0;
localparam MUX_ALU_OP_B_SEL_REGFILE_OUT_16BIT_B    = 4'h1;
localparam MUX_ALU_OP_B_SEL_REG_MEM_DIN            = 4'h2;
localparam MUX_ALU_OP_B_SEL_REG_MEM_DIN_LO_SGN_EXT = 4'h4;
localparam MUX_ALU_OP_B_SEL_CONST2                 = 4'h8;

/*****************************************************************************
 Internal Databus Mux
 *****************************************************************************/
localparam MUX_INT_BUS_SEL_ALU_OUT             = 7'h00;
localparam MUX_INT_BUS_SEL_REG_INT_CTRL        = 7'h01;
localparam MUX_INT_BUS_SEL_REG_MEM_DIN         = 7'h02;
localparam MUX_INT_BUS_SEL_REG_PC              = 7'h04;
localparam MUX_INT_BUS_SEL_REG_PC_DIRECT       = 7'h08;
localparam MUX_INT_BUS_SEL_REGFILE_OUT_8BIT_A  = 7'h10;
localparam MUX_INT_BUS_SEL_REGFILE_OUT_16BIT_A = 7'h20;
localparam MUX_INT_BUS_SEL_REGFILE_OUT_16BIT_B = 7'h40;

/*****************************************************************************
 Memory Address Mux
 *****************************************************************************/
localparam MUX_MEM_ADDR_SEL_ALU_ADDR            = 6'h00;
localparam MUX_MEM_ADDR_SEL_INT_ADDR            = 6'h01;
localparam MUX_MEM_ADDR_SEL_REG_IMM             = 6'h02;
localparam MUX_MEM_ADDR_SEL_REG_MEM_DIN         = 6'h04;
localparam MUX_MEM_ADDR_SEL_REG_MEM_ADDR        = 6'h08;
localparam MUX_MEM_ADDR_SEL_REG_PC              = 6'h10;
localparam MUX_MEM_ADDR_SEL_REGFILE_OUT_16BIT_B = 6'h20;

/*****************************************************************************
 Memory Data Out Mux
 *****************************************************************************/
localparam MUX_MEM_DOUT_SEL_REG_MEM_DOUT_LO        = 6'h00;
localparam MUX_MEM_DOUT_SEL_REG_MEM_DOUT_HI        = 6'h01;
localparam MUX_MEM_DOUT_SEL_REG_MEM_DIN_LO         = 6'h02;
localparam MUX_MEM_DOUT_SEL_REG_PC_LO              = 6'h04;
localparam MUX_MEM_DOUT_SEL_REG_PC_HI              = 6'h08;
localparam MUX_MEM_DOUT_SEL_REGFILE_OUT_8BIT_A     = 6'h10;
localparam MUX_MEM_DOUT_SEL_REGFILE_OUT_16BIT_A_LO = 6'h20;
