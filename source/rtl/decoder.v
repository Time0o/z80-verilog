`timescale 1ns/10ps

`include "buswidth.vh"

module decoder (
    input int_active_int,
    input int_active_nmi,
    input int_iff2,
    input int_sampled_int,
    input int_sampled_nmi,
    input [`INT_MODE_WIDTH-1:0] int_mode,
    input [7:0] reg_instr,
    input [`OP_PREFIX_WIDTH-1:0] reg_op_prefix,
    input regfile_b_zero,
    input regfile_bc_zero,
    input regfile_flag_s,
    input regfile_flag_z,
    input regfile_flag_pv,
    input regfile_flag_c,
    input [`FSM_STATE_WIDTH-1:0] state,
    output reg [2:0] alu_bitselect,
    output reg alu_iff2,
    output reg [`ALU_MODE_WIDTH-1:0] alu_mode,
    output reg int_disable,
    output reg int_enable,
    output reg int_mode_change,
    output reg [`INT_MODE_WIDTH-1:0] int_mode_next,
    output reg int_restore,
    output reg io_n_iorq,
    output reg mem_dout_en,
    output reg mem_n_pmem,
    output reg mem_n_m1,
    output reg mem_n_mreq,
    output reg mem_n_rd,
    output reg mem_n_wr,
    output reg [`MUX_ALU_OP_A_SEL_WIDTH-1:0] mux_alu_op_a_sel,
    output reg [`MUX_ALU_OP_B_SEL_WIDTH-1:0] mux_alu_op_b_sel,
    output reg [`MUX_INT_BUS_SEL_WIDTH-1:0] mux_int_bus_sel,
    output reg [`MUX_MEM_ADDR_SEL_WIDTH-1:0] mux_mem_addr_sel,
    output reg [`MUX_MEM_DOUT_SEL_WIDTH-1:0] mux_mem_dout_sel,
    output reg reg_alu_addr_we,
    output reg reg_int_ctrl_we,
    output reg reg_instr_we,
    output reg reg_mem_addr_we,
    output reg reg_mem_din_hi_we,
    output reg reg_mem_din_lo_we,
    output reg reg_mem_dout_we,
    output reg [`OP_PREFIX_WIDTH-1:0] reg_op_prefix_next,
    output reg reg_op_prefix_we,
    output reg [7:0] reg_pc_lo_direct,
    output reg reg_pc_we,
    output reg [1:0] regfile_bc_dec,
    output reg [2:0] regfile_ex,
    output reg regfile_flags_we,
    output reg [`REG_SELECT_8BIT_WIDTH-1:0] regfile_read_addr_8bit_a,
    output reg [`REG_SELECT_16BIT_WIDTH-1:0] regfile_read_addr_16bit_a,
    output reg [`REG_SELECT_8BIT_WIDTH-1:0] regfile_read_addr_8bit_b,
    output reg [`REG_SELECT_16BIT_WIDTH-1:0] regfile_read_addr_16bit_b,
    output reg regfile_we,
    output reg [`REG_SELECT_WIDTH-1:0] regfile_write_addr
);

`include "alu.vh"
`include "fsm.vh"
`include "interrupt.vh"
`include "mux.vh"
`include "opcode.vh"
`include "regfile.vh"

reg cond;
reg [`REG_SELECT_8BIT_WIDTH-1:0] reg_select_8bit_1;
reg [`REG_SELECT_WIDTH-1:0] reg_select_8bit_write_1;
reg [`REG_SELECT_8BIT_WIDTH-1:0] reg_select_8bit_2;
reg [`REG_SELECT_WIDTH-1:0] reg_select_8bit_write_2;
reg [`REG_SELECT_16BIT_WIDTH-1:0] reg_select_16bit;
reg [`REG_SELECT_WIDTH-1:0] reg_select_16bit_write;
reg [`ALU_MODE_WIDTH-1:0] alu_mode_select;

always @* begin
    case (reg_instr[5:3])
        3'b000: cond = !regfile_flag_z;
        3'b001: cond =  regfile_flag_z;
        3'b010: cond = !regfile_flag_c;
        3'b011: cond =  regfile_flag_c;
        3'b100: cond = !regfile_flag_pv;
        3'b101: cond =  regfile_flag_pv;
        3'b110: cond = !regfile_flag_s;
        3'b111: cond =  regfile_flag_s;
    endcase

    case (reg_instr[5:3])
        3'b000: begin
            reg_select_8bit_1 = REG_SELECT_8BIT_B;
            reg_select_8bit_write_1 = REG_SELECT_B;
        end
        3'b001: begin
            reg_select_8bit_1 = REG_SELECT_8BIT_C;
            reg_select_8bit_write_1 = REG_SELECT_C;
        end
        3'b010: begin
            reg_select_8bit_1 = REG_SELECT_8BIT_D;
            reg_select_8bit_write_1 = REG_SELECT_D;
        end
        3'b011: begin
            reg_select_8bit_1 = REG_SELECT_8BIT_E;
            reg_select_8bit_write_1 = REG_SELECT_E;
        end
        3'b100: begin
            reg_select_8bit_1 = REG_SELECT_8BIT_H;
            reg_select_8bit_write_1 = REG_SELECT_H;
        end
        3'b101: begin
            reg_select_8bit_1 = REG_SELECT_8BIT_L;
            reg_select_8bit_write_1 = REG_SELECT_L;
        end
        default: begin
            reg_select_8bit_1 = REG_SELECT_8BIT_A;
            reg_select_8bit_write_1 = REG_SELECT_A;
        end
    endcase

    case (reg_instr[2:0])
        3'b000: begin
            reg_select_8bit_2 = REG_SELECT_8BIT_B;
            reg_select_8bit_write_2 = REG_SELECT_B;
        end
        3'b001: begin
            reg_select_8bit_2 = REG_SELECT_8BIT_C;
            reg_select_8bit_write_2 = REG_SELECT_C;
        end
        3'b010: begin
            reg_select_8bit_2 = REG_SELECT_8BIT_D;
            reg_select_8bit_write_2 = REG_SELECT_D;
        end
        3'b011: begin
            reg_select_8bit_2 = REG_SELECT_8BIT_E;
            reg_select_8bit_write_2 = REG_SELECT_E;
        end
        3'b100: begin
            reg_select_8bit_2 = REG_SELECT_8BIT_H;
            reg_select_8bit_write_2 = REG_SELECT_H;
        end
        3'b101: begin
            reg_select_8bit_2 = REG_SELECT_8BIT_L;
            reg_select_8bit_write_2 = REG_SELECT_L;
        end
        default: begin
            reg_select_8bit_2 = REG_SELECT_8BIT_A;
            reg_select_8bit_write_2 = REG_SELECT_A;
        end
    endcase

    case (reg_instr[5:4])
        2'b00: begin
            reg_select_16bit = REG_SELECT_16BIT_BC;
            reg_select_16bit_write = REG_SELECT_BC;
        end
        2'b01: begin
            reg_select_16bit = REG_SELECT_16BIT_DE;
            reg_select_16bit_write = REG_SELECT_DE;
        end
        2'b10: begin
            reg_select_16bit = REG_SELECT_16BIT_HL;
            reg_select_16bit_write = REG_SELECT_HL;
        end
        2'b11: begin
            reg_select_16bit = REG_SELECT_16BIT_SP;
            reg_select_16bit_write = REG_SELECT_SP;
        end
    endcase

    case (reg_instr[5:3])
        3'b000: alu_mode_select = ALU_MODE_ADD;
        3'b001: alu_mode_select = ALU_MODE_ADC;
        3'b010: alu_mode_select = ALU_MODE_SUB;
        3'b011: alu_mode_select = ALU_MODE_SBC;
        3'b100: alu_mode_select = ALU_MODE_AND;
        3'b101: alu_mode_select = ALU_MODE_XOR;
        3'b110: alu_mode_select = ALU_MODE_OR;
        3'b111: alu_mode_select = ALU_MODE_CP;
    endcase
end

always @* begin
    alu_bitselect             = 3'b000;
    alu_iff2                  = 1'b0;
    alu_mode                  = ALU_MODE_ADD;
    int_disable               = 1'b0;
    int_enable                = 1'b0;
    int_mode_change           = 1'b0;
    int_mode_next             = INT_MODE_0;
    int_restore               = 1'b0;
    io_n_iorq                 = 1'b1;
    mem_dout_en               = 1'b0;
    mem_n_pmem                = 1'b1;
    mem_n_m1                  = 1'b1;
    mem_n_mreq                = 1'b1;
    mem_n_rd                  = 1'b1;
    mem_n_wr                  = 1'b1;
    mux_alu_op_a_sel          = MUX_ALU_OP_A_SEL_REGFILE_OUT_8BIT_A;
    mux_alu_op_b_sel          = MUX_ALU_OP_B_SEL_REGFILE_OUT_8BIT_B;
    mux_int_bus_sel           = MUX_INT_BUS_SEL_ALU_OUT;
    mux_mem_addr_sel          = MUX_MEM_ADDR_SEL_REG_PC;
    mux_mem_dout_sel          = MUX_MEM_DOUT_SEL_REG_MEM_DOUT_LO;
    reg_alu_addr_we           = 1'b0;
    reg_int_ctrl_we           = 1'b0;
    reg_instr_we              = 1'b0;
    reg_mem_addr_we           = 1'b0;
    reg_mem_din_hi_we         = 1'b0;
    reg_mem_din_lo_we         = 1'b0;
    reg_mem_dout_we           = 1'b0;
    reg_op_prefix_next        = OP_PREFIX_NONE;
    reg_op_prefix_we          = 1'b0;
    reg_pc_lo_direct          = 8'h00;
    reg_pc_we                 = 1'b0;
    regfile_bc_dec            = BC_DEC_NONE;
    regfile_ex                = EX_NONE;
    regfile_flags_we          = 1'b0;
    regfile_read_addr_8bit_a  = REG_SELECT_8BIT_A;
    regfile_read_addr_8bit_b  = REG_SELECT_8BIT_A;
    regfile_read_addr_16bit_a = REG_SELECT_16BIT_BC;
    regfile_read_addr_16bit_b = REG_SELECT_16BIT_BC;
    regfile_we                = 1'b0;
    regfile_write_addr        = REG_SELECT_A;

    case (state)
        FSM_STATE_INSTR_FETCH1_1,
        FSM_STATE_INSTR_FETCH2_1,
        FSM_STATE_INSTR_FETCH3_1: begin
            mem_n_m1         = 1'b0;
            mem_n_pmem       = 1'b0;
            mem_n_mreq       = 1'b0;
            mem_n_rd         = 1'b0;
            mux_mem_addr_sel = MUX_MEM_ADDR_SEL_REG_PC;
        end
        FSM_STATE_INSTR_FETCH1_2,
        FSM_STATE_INSTR_FETCH2_2,
        FSM_STATE_INSTR_FETCH3_2: begin
            mem_n_m1         = 1'b0;
            mem_n_pmem       = 1'b0;
            mem_n_mreq       = 1'b0;
            mem_n_rd         = 1'b0;
            mux_mem_addr_sel = MUX_MEM_ADDR_SEL_REG_PC;

            alu_mode         = ALU_MODE_INC;
            mux_alu_op_a_sel = MUX_ALU_OP_A_SEL_REG_PC;
            mux_int_bus_sel  = MUX_INT_BUS_SEL_ALU_OUT;
            reg_pc_we        = 1'b1;

            reg_instr_we = 1'b1;
        end
        FSM_STATE_INSTR_FETCH1_3: begin
            reg_op_prefix_next = OP_PREFIX_NONE;
            reg_op_prefix_we   = 1'b1;

            casez (reg_instr)
                // HALT ==============================================================

                8'b01110110: // HALT
                begin
                    alu_mode         = ALU_MODE_DEC;
                    mux_alu_op_a_sel = MUX_ALU_OP_A_SEL_REG_PC;
                    mux_int_bus_sel  = MUX_INT_BUS_SEL_ALU_OUT;
                    reg_pc_we        = 1'b1;
                end

                // Prefixes ==========================================================

                8'hDD: reg_op_prefix_next = OP_PREFIX_DD;
                8'hFD: reg_op_prefix_next = OP_PREFIX_FD;
                8'hED: reg_op_prefix_next = OP_PREFIX_ED;
                8'hCB: reg_op_prefix_next = OP_PREFIX_CB;

                // 8-Bit Load Group ==================================================

                8'b01???110: // LD r,(HL)
                begin
                    mux_mem_addr_sel          = MUX_MEM_ADDR_SEL_REGFILE_OUT_16BIT_B;
                    reg_mem_addr_we           = 1'b1;
                    regfile_read_addr_16bit_b = REG_SELECT_16BIT_HL;
                end
                8'b000?0010: // LD ((BC)|(DE)),A
                begin
                    mem_dout_en              = 1'b1;
                    mux_int_bus_sel          = MUX_INT_BUS_SEL_REGFILE_OUT_8BIT_A;
                    mux_mem_addr_sel         = MUX_MEM_ADDR_SEL_REGFILE_OUT_16BIT_B;
                    mux_mem_dout_sel         = MUX_MEM_DOUT_SEL_REGFILE_OUT_8BIT_A;
                    reg_mem_addr_we          = 1'b1;
                    reg_mem_dout_we          = 1'b1;
                    regfile_read_addr_8bit_a = REG_SELECT_8BIT_A;

                    case (reg_instr[4])
                        1'b0: regfile_read_addr_16bit_b = REG_SELECT_16BIT_BC;
                        1'b1: regfile_read_addr_16bit_b = REG_SELECT_16BIT_DE;
                    endcase
                end
                8'b01110???: // LD (HL),r
                begin
                    mem_dout_en               = 1'b1;
                    mux_int_bus_sel           = MUX_INT_BUS_SEL_REGFILE_OUT_8BIT_A;
                    mux_mem_addr_sel          = MUX_MEM_ADDR_SEL_REGFILE_OUT_16BIT_B;
                    mux_mem_dout_sel          = MUX_MEM_DOUT_SEL_REGFILE_OUT_8BIT_A;
                    reg_mem_addr_we           = 1'b1;
                    reg_mem_dout_we           = 1'b1;
                    regfile_read_addr_16bit_b = REG_SELECT_16BIT_HL;
                    regfile_read_addr_8bit_a  = reg_select_8bit_2;
                end
                8'b01??????: // LD r,r'
                begin
                    mux_int_bus_sel          = MUX_INT_BUS_SEL_REGFILE_OUT_8BIT_A;
                    regfile_read_addr_8bit_a = reg_select_8bit_2;
                    regfile_we               = 1'b1;
                    regfile_write_addr       = reg_select_8bit_write_1;
                end
                8'b00001010: // LD A,(BC)
                begin
                    mux_mem_addr_sel          = MUX_MEM_ADDR_SEL_REGFILE_OUT_16BIT_B;
                    reg_mem_addr_we           = 1'b1;
                    regfile_read_addr_16bit_b = REG_SELECT_16BIT_BC;
                end
                8'b00011010: // LD A,(DE)
                begin
                    mux_mem_addr_sel          = MUX_MEM_ADDR_SEL_REGFILE_OUT_16BIT_B;
                    reg_mem_addr_we           = 1'b1;
                    regfile_read_addr_16bit_b = REG_SELECT_16BIT_DE;
                end

                // 16-Bit Load Group =================================================

                8'b11111001: // LD SP,HL
                begin
                    mux_int_bus_sel           = MUX_INT_BUS_SEL_REGFILE_OUT_16BIT_A;
                    regfile_read_addr_16bit_a = REG_SELECT_16BIT_HL;
                    regfile_we                = 1'b1;
                    regfile_write_addr        = REG_SELECT_SP;
                end

                8'b11??0101: // PUSH qq
                begin
                    alu_mode                  = ALU_MODE_DEC;
                    mux_alu_op_a_sel          = MUX_ALU_OP_A_SEL_REGFILE_OUT_16BIT_A;
                    mux_int_bus_sel           = MUX_INT_BUS_SEL_REGFILE_OUT_16BIT_B;
                    reg_alu_addr_we           = 1'b1;
                    reg_mem_dout_we           = 1'b1;
                    regfile_read_addr_16bit_a = REG_SELECT_16BIT_SP;

                    case (reg_instr[5:4])
                        2'b00: regfile_read_addr_16bit_b = REG_SELECT_16BIT_BC;
                        2'b01: regfile_read_addr_16bit_b = REG_SELECT_16BIT_DE;
                        2'b10: regfile_read_addr_16bit_b = REG_SELECT_16BIT_HL;
                        2'b11: regfile_read_addr_16bit_b = REG_SELECT_16BIT_AF;
                    endcase
                end
                8'b11??0001: // POP qq
                begin
                    mux_mem_addr_sel          = MUX_MEM_ADDR_SEL_REGFILE_OUT_16BIT_B;
                    regfile_read_addr_16bit_b = REG_SELECT_16BIT_SP;
                    reg_mem_addr_we           = 1'b1;
                end

                // Exchange, Block Transfer, and Search Group ========================

                8'b11101011: // EX DE,HL
                begin
                    regfile_ex = EX_DE_HL;
                end
                8'b00001000: // EX AF,AF'
                begin
                    regfile_ex = EX_AF;
                end
                8'b11011001: // EXX
                begin
                    regfile_ex = EX_EXX;
                end
                8'b11100011: // EX (SP),HL
                begin
                    mux_int_bus_sel           = MUX_INT_BUS_SEL_REGFILE_OUT_16BIT_A;
                    mux_mem_addr_sel          = MUX_MEM_ADDR_SEL_REGFILE_OUT_16BIT_B;
                    reg_mem_addr_we           = 1'b1;
                    reg_mem_dout_we           = 1'b1;
                    regfile_read_addr_16bit_a = REG_SELECT_16BIT_HL;
                    regfile_read_addr_16bit_b = REG_SELECT_16BIT_SP;
                end

                // 8-Bit Arithmetic Group ============================================

                8'b10???110: // ALUOP [A,](HL)
                begin
                    mux_mem_addr_sel          = MUX_MEM_ADDR_SEL_REGFILE_OUT_16BIT_B;
                    regfile_read_addr_16bit_b = REG_SELECT_16BIT_HL;
                    reg_mem_addr_we           = 1'b1;
                end
                8'b10??????: begin // ALUOP [A,]r
                    alu_mode                 = alu_mode_select;
                    mux_alu_op_a_sel         = MUX_ALU_OP_A_SEL_REGFILE_OUT_8BIT_A;
                    mux_alu_op_b_sel         = MUX_ALU_OP_B_SEL_REGFILE_OUT_8BIT_B;
                    mux_int_bus_sel          = MUX_INT_BUS_SEL_ALU_OUT;
                    regfile_flags_we         = 1'b1;
                    regfile_read_addr_8bit_a = REG_SELECT_8BIT_A;
                    regfile_read_addr_8bit_b = reg_select_8bit_2;

                    if (alu_mode_select != ALU_MODE_CP) begin
                        regfile_we         = 1'b1;
                        regfile_write_addr = REG_SELECT_A;
                    end
                end
                8'b0011010?: // (INC|DEC) (HL)
                begin
                    mux_mem_addr_sel          = MUX_MEM_ADDR_SEL_REGFILE_OUT_16BIT_B;
                    reg_mem_addr_we           = 1'b1;
                     regfile_read_addr_16bit_b = REG_SELECT_16BIT_HL;
                end
                8'b00???10?: // (INC|DEC) r
                begin
                    case (reg_instr[0])
                        1'b0: alu_mode = ALU_MODE_INC;
                        1'b1: alu_mode = ALU_MODE_DEC;
                    endcase

                    mux_alu_op_a_sel         = MUX_ALU_OP_A_SEL_REGFILE_OUT_8BIT_A;
                    mux_int_bus_sel          = MUX_INT_BUS_SEL_ALU_OUT;
                    regfile_flags_we         = 1'b1;
                    regfile_read_addr_8bit_a = reg_select_8bit_1;
                    regfile_we               = 1'b1;
                    regfile_write_addr       = reg_select_8bit_write_1;
                end

                // General Purpose Arithmetic and CPU Control Group ==================

                8'b00100111: // DAA
                begin
                    alu_mode                 = ALU_MODE_DAA;
                    mux_alu_op_a_sel         = MUX_ALU_OP_A_SEL_REGFILE_OUT_8BIT_A;
                    mux_int_bus_sel          = MUX_INT_BUS_SEL_ALU_OUT;
                    regfile_flags_we         = 1'b1;
                    regfile_read_addr_8bit_a = REG_SELECT_8BIT_A;
                    regfile_we               = 1'b1;
                    regfile_write_addr       = REG_SELECT_A;
                end
                8'b00101111: // CPL
                begin
                    alu_mode                 = ALU_MODE_CPL;
                    mux_alu_op_b_sel         = MUX_ALU_OP_B_SEL_REGFILE_OUT_8BIT_B;
                    mux_int_bus_sel          = MUX_INT_BUS_SEL_ALU_OUT;
                    regfile_flags_we         = 1'b1;
                    regfile_read_addr_8bit_b = REG_SELECT_8BIT_A;
                    regfile_we               = 1'b1;
                    regfile_write_addr       = REG_SELECT_A;
                end
                8'b00111111: // CCF
                begin
                    alu_mode         = ALU_MODE_CCF;
                    regfile_flags_we = 1'b1;
                end
                8'b00110111: // SCF
                begin
                    alu_mode         = ALU_MODE_SCF;
                    regfile_flags_we = 1'b1;
                end
                8'b11110011: // DI
                begin
                    int_disable = 1'b1;
                end
                8'b11111011: // EI
                begin
                    int_enable = 1'b1;
                end

                // 16-Bit Arithmetic Group ===========================================

                8'b00??1001: // ADD HL,ss
                begin
                    alu_mode                  = ALU_MODE_ADD_16BIT;
                    mux_alu_op_a_sel          = MUX_ALU_OP_A_SEL_REGFILE_OUT_16BIT_A;
                    mux_alu_op_b_sel          = MUX_ALU_OP_B_SEL_REGFILE_OUT_16BIT_B;
                    mux_int_bus_sel           = MUX_INT_BUS_SEL_ALU_OUT;
                    regfile_flags_we          = 1'b1;
                    regfile_read_addr_16bit_a = REG_SELECT_16BIT_HL;
                    regfile_read_addr_16bit_b = reg_select_16bit;
                    regfile_we                = 1'b1;
                    regfile_write_addr        = REG_SELECT_HL;
                end
                 8'b00??0011, // INC ss
                 8'b00??1011: // DEC ss
                begin
                    case (reg_instr[3])
                        1'b0: alu_mode = ALU_MODE_INC;
                        1'b1: alu_mode = ALU_MODE_DEC;
                    endcase

                    mux_alu_op_a_sel          = MUX_ALU_OP_A_SEL_REGFILE_OUT_16BIT_A;
                    mux_int_bus_sel           = MUX_INT_BUS_SEL_ALU_OUT;
                    regfile_read_addr_16bit_a = reg_select_16bit;
                    regfile_we                = 1'b1;
                    regfile_write_addr        = reg_select_16bit_write;
                end

                // Rotate and Shift Group ============================================

                8'b000??111: // (RLCA|RLA|RRCA|RRA)
                begin
                    case (reg_instr[4:3])
                        2'b00: alu_mode = ALU_MODE_RLCA;
                        2'b10: alu_mode = ALU_MODE_RLA;
                        2'b01: alu_mode = ALU_MODE_RRCA;
                        2'b11: alu_mode = ALU_MODE_RRA;
                    endcase

                    mux_alu_op_a_sel         = MUX_ALU_OP_A_SEL_REGFILE_OUT_8BIT_A;
                    mux_int_bus_sel          = MUX_INT_BUS_SEL_ALU_OUT;
                    regfile_flags_we         = 1'b1;
                    regfile_read_addr_8bit_a = REG_SELECT_8BIT_A;
                    regfile_we               = 1'b1;
                    regfile_write_addr       = REG_SELECT_A;
                end

                // Jump Group ========================================================

                8'b11101001: // JP (HL)
                begin
                    mux_int_bus_sel           = MUX_INT_BUS_SEL_REGFILE_OUT_16BIT_A;
                    regfile_read_addr_16bit_a = REG_SELECT_16BIT_HL;
                    reg_pc_we                 = 1'b1;
                end
                8'b00010000: // DJNZ, e
                begin
                    alu_mode                 = ALU_MODE_DEC;
                    mux_alu_op_a_sel         = MUX_ALU_OP_A_SEL_REGFILE_OUT_8BIT_A;
                    mux_int_bus_sel          = MUX_INT_BUS_SEL_ALU_OUT;
                    regfile_read_addr_8bit_a = REG_SELECT_8BIT_B;
                    regfile_we               = 1'b1;
                    regfile_write_addr       = REG_SELECT_B;
                end

                // Call and Return Group =============================================

                8'b11???100: // CALL cc,nn
                begin
                    if (!cond) begin
                        alu_mode         = ALU_MODE_ADD_16BIT;
                        mux_alu_op_a_sel = MUX_ALU_OP_A_SEL_REG_PC;
                        mux_alu_op_b_sel = MUX_ALU_OP_B_SEL_CONST2;
                        mux_int_bus_sel  = MUX_INT_BUS_SEL_ALU_OUT;
                        reg_alu_addr_we  = 1'b1;
                        reg_pc_we        = 1'b1;
                    end
                end
                8'b11001001: // RET
                begin
                    alu_mode                  = ALU_MODE_INC;
                    mux_alu_op_a_sel          = MUX_ALU_OP_A_SEL_REGFILE_OUT_16BIT_A;
                    mux_alu_op_b_sel          = MUX_ALU_OP_B_SEL_REGFILE_OUT_16BIT_B;
                    mux_int_bus_sel           = MUX_INT_BUS_SEL_ALU_OUT;
                    mux_mem_addr_sel          = MUX_MEM_ADDR_SEL_REGFILE_OUT_16BIT_B;
                    reg_mem_addr_we           = 1'b1;
                    regfile_read_addr_16bit_a = REG_SELECT_16BIT_SP;
                    regfile_read_addr_16bit_b = REG_SELECT_16BIT_SP;
                    regfile_we                = 1'b1;
                    regfile_write_addr        = REG_SELECT_SP;
                end
                8'b11???000: // RET cc
                begin
                    if (cond) begin
                        alu_mode                  = ALU_MODE_INC;
                        mux_alu_op_a_sel          = MUX_ALU_OP_A_SEL_REGFILE_OUT_16BIT_A;
                        mux_alu_op_b_sel          = MUX_ALU_OP_B_SEL_REGFILE_OUT_16BIT_B;
                        mux_int_bus_sel           = MUX_INT_BUS_SEL_ALU_OUT;
                        mux_mem_addr_sel          = MUX_MEM_ADDR_SEL_REGFILE_OUT_16BIT_B;
                        reg_mem_addr_we           = 1'b1;
                        regfile_read_addr_16bit_a = REG_SELECT_16BIT_SP;
                        regfile_read_addr_16bit_b = REG_SELECT_16BIT_SP;
                        regfile_we                = 1'b1;
                        regfile_write_addr        = REG_SELECT_SP;
                    end
                end
                8'b11???111: // RST p
                begin
                    alu_mode                  = ALU_MODE_DEC;
                    mux_alu_op_a_sel          = MUX_ALU_OP_A_SEL_REGFILE_OUT_16BIT_A;
                    mux_int_bus_sel           = MUX_INT_BUS_SEL_ALU_OUT;
                    reg_alu_addr_we           = 1'b1;
                    regfile_read_addr_16bit_a = REG_SELECT_16BIT_SP;
                    regfile_we                = 1'b1;
                    regfile_write_addr        = REG_SELECT_SP;
                end

                // Input and Output Group ============================================

                8'b11010011: // OUT (n),A
                begin
                    mux_int_bus_sel          = MUX_INT_BUS_SEL_REGFILE_OUT_8BIT_A;
                    mux_mem_dout_sel         = MUX_MEM_DOUT_SEL_REGFILE_OUT_8BIT_A;
                    reg_mem_dout_we          = 1'b1;
                    regfile_read_addr_8bit_a = REG_SELECT_8BIT_A;
                end
            endcase
        end
        FSM_STATE_INSTR_FETCH2_3: begin
            casez ({ reg_op_prefix, reg_instr })
                // Prefixes ==========================================================

                { OP_PREFIX_DD, 8'hCB }: begin
                    reg_op_prefix_next = OP_PREFIX_DD_CB;
                    reg_op_prefix_we   = 1'b1;
                end
                { OP_PREFIX_FD, 8'hCB }: begin
                    reg_op_prefix_next = OP_PREFIX_FD_CB;
                    reg_op_prefix_we   = 1'b1;
                end

                // 8-Bit Load Group ==================================================

                { OP_PREFIX_ED, 8'b01010111 }: // LD A,I
                begin
                    alu_iff2 = int_iff2 & (~int_sampled_nmi || ~int_sampled_int);

                    alu_mode           = ALU_MODE_LDAI;
                    mux_alu_op_a_sel   = MUX_ALU_OP_A_SEL_REG_INT_CTRL;
                    mux_int_bus_sel    = MUX_INT_BUS_SEL_REG_INT_CTRL;
                    regfile_flags_we   = 1'b1;
                    regfile_we         = 1'b1;
                    regfile_write_addr = REG_SELECT_A;
                end

                { OP_PREFIX_ED, 8'b01000111 }: // LD I,A
                begin
                    mux_int_bus_sel          = MUX_INT_BUS_SEL_REGFILE_OUT_8BIT_A;
                    regfile_read_addr_8bit_a = REG_SELECT_8BIT_A;
                    regfile_we               = 1'b1;
                    reg_int_ctrl_we          = 1'b1;
                end

                { OP_PREFIX_DD, 8'b01110??? }, // LD (IX + d),r
                { OP_PREFIX_FD, 8'b01110??? }: // LD (IY + d),r
                begin
                    mux_int_bus_sel          = MUX_INT_BUS_SEL_REGFILE_OUT_8BIT_A;
                    reg_mem_dout_we          = 1'b1;
                    regfile_read_addr_8bit_a = reg_select_8bit_2;
                end

                // 16-Bit Load Group =================================================

                { OP_PREFIX_DD, 8'b11111001 }, // LD SP,IX
                { OP_PREFIX_FD, 8'b11111001 }: // LD SP,IY
                begin
                    mux_int_bus_sel = MUX_INT_BUS_SEL_REGFILE_OUT_16BIT_A;

                    case (reg_op_prefix)
                        OP_PREFIX_DD: regfile_read_addr_16bit_a = REG_SELECT_16BIT_IX;
                        OP_PREFIX_FD: regfile_read_addr_16bit_a = REG_SELECT_16BIT_IY;
                    endcase

                    regfile_we         = 1'b1;
                    regfile_write_addr = REG_SELECT_SP;
                end
                { OP_PREFIX_DD, 8'b11100101 }, // PUSH IX
                { OP_PREFIX_FD, 8'b11100101 }: // PUSH IY
                begin
                    alu_mode                  = ALU_MODE_DEC;
                    mux_alu_op_a_sel          = MUX_ALU_OP_A_SEL_REGFILE_OUT_16BIT_A;
                    mux_int_bus_sel           = MUX_INT_BUS_SEL_REGFILE_OUT_16BIT_B;
                    reg_alu_addr_we           = 1'b1;
                    reg_mem_dout_we           = 1'b1;
                    regfile_read_addr_16bit_a = REG_SELECT_16BIT_SP;

                    case (reg_op_prefix)
                        OP_PREFIX_DD: regfile_read_addr_16bit_b = REG_SELECT_16BIT_IX;
                        OP_PREFIX_FD: regfile_read_addr_16bit_b = REG_SELECT_16BIT_IY;
                    endcase
                end
                { OP_PREFIX_DD, 8'b11100001 }, // POP IX
                { OP_PREFIX_FD, 8'b11100001 }: // POP IY
                begin
                    mux_mem_addr_sel    = MUX_MEM_ADDR_SEL_REGFILE_OUT_16BIT_B;
                    regfile_read_addr_16bit_b = REG_SELECT_16BIT_SP;
                    reg_mem_addr_we     = 1'b1;
                end

                // Exchange, Block Transfer, and Search Group ========================

                { OP_PREFIX_DD, 8'b11100011 }, // EX (SP),IX
                { OP_PREFIX_FD, 8'b11100011 }: // EX (SP),IY
                begin
                    mux_int_bus_sel  = MUX_INT_BUS_SEL_REGFILE_OUT_16BIT_A;
                    mux_mem_addr_sel = MUX_MEM_ADDR_SEL_REGFILE_OUT_16BIT_B;
                    reg_mem_addr_we  = 1'b1;
                    reg_mem_dout_we  = 1'b1;

                    case (reg_op_prefix)
                        OP_PREFIX_DD: regfile_read_addr_16bit_a = REG_SELECT_16BIT_IX;
                        OP_PREFIX_FD: regfile_read_addr_16bit_a = REG_SELECT_16BIT_IY;
                    endcase

                    regfile_read_addr_16bit_b = REG_SELECT_16BIT_SP;
                end
                { OP_PREFIX_ED, 8'b10100000 }, // LDI
                { OP_PREFIX_ED, 8'b10110000 }, // LDIR
                { OP_PREFIX_ED, 8'b10101000 }, // LDD
                { OP_PREFIX_ED, 8'b10111000 }: // LDDR
                begin
                    case (reg_instr[3])
                        1'b0: alu_mode = ALU_MODE_INC;
                        1'b1: alu_mode = ALU_MODE_DEC;
                    endcase

                    mux_alu_op_a_sel          = MUX_ALU_OP_A_SEL_REGFILE_OUT_16BIT_A;
                    mux_int_bus_sel           = MUX_INT_BUS_SEL_ALU_OUT;
                    mux_mem_addr_sel          = MUX_MEM_ADDR_SEL_REGFILE_OUT_16BIT_B;
                    reg_mem_addr_we           = 1'b1;
                    regfile_read_addr_16bit_a = REG_SELECT_16BIT_HL;
                    regfile_read_addr_16bit_b = REG_SELECT_16BIT_HL;
                    regfile_we                = 1'b1;
                    regfile_write_addr        = REG_SELECT_HL;
                end
                { OP_PREFIX_ED, 8'b10100001 }, // CPI
                { OP_PREFIX_ED, 8'b10110001 }, // CPIR
                { OP_PREFIX_ED, 8'b10101001 }, // CPD
                { OP_PREFIX_ED, 8'b10111001 }: // CPDR
                begin
                    case (reg_instr[3])
                        1'b0: alu_mode = ALU_MODE_INC;
                        1'b1: alu_mode = ALU_MODE_DEC;
                    endcase

                    mux_alu_op_a_sel          = MUX_ALU_OP_A_SEL_REGFILE_OUT_16BIT_A;
                    mux_int_bus_sel           = MUX_INT_BUS_SEL_ALU_OUT;
                    mux_mem_addr_sel          = MUX_MEM_ADDR_SEL_REGFILE_OUT_16BIT_B;
                    reg_mem_addr_we           = 1'b1;
                    regfile_bc_dec            = BC_DEC_CP;
                    regfile_read_addr_16bit_a = REG_SELECT_16BIT_HL;
                    regfile_read_addr_16bit_b = REG_SELECT_16BIT_HL;
                    regfile_we                = 1'b1;
                    regfile_write_addr        = REG_SELECT_HL;
                end

                // General Purpose Arithmetic and CPU Control Group ==================

                { OP_PREFIX_ED, 8'b01000100 }: // NEG
                begin
                    alu_mode                 = ALU_MODE_NEG;
                    mux_alu_op_b_sel         = MUX_ALU_OP_B_SEL_REGFILE_OUT_8BIT_B;
                    mux_int_bus_sel          = MUX_INT_BUS_SEL_ALU_OUT;
                    regfile_flags_we         = 1'b1;
                    regfile_read_addr_8bit_b = REG_SELECT_8BIT_A;
                    regfile_we               = 1'b1;
                    regfile_write_addr       = REG_SELECT_A;
                end
                { OP_PREFIX_ED, 8'b01000110 }: // IM 0
                begin
                    int_mode_change = 1'b1;
                    int_mode_next   = INT_MODE_0;
                end
                { OP_PREFIX_ED, 8'b01010110 }: // IM 1
                begin
                    int_mode_change = 1'b1;
                    int_mode_next   = INT_MODE_1;
                end
                { OP_PREFIX_ED, 8'b01011110 }: // IM 2
                begin
                    int_mode_change = 1'b1;
                    int_mode_next   = INT_MODE_2;
                end

                // 16-Bit Arithmetic Group ===========================================

                { OP_PREFIX_ED, 8'b01??1010 }, // ADC HL,ss
                { OP_PREFIX_ED, 8'b01??0010 }: // SBC HL,ss
                begin
                    case (reg_instr[3:0])
                        4'b1010: alu_mode = ALU_MODE_ADC_16BIT;
                        4'b0010: alu_mode = ALU_MODE_SBC_16BIT;
                    endcase

                    mux_alu_op_a_sel          = MUX_ALU_OP_A_SEL_REGFILE_OUT_16BIT_A;
                    mux_alu_op_b_sel          = MUX_ALU_OP_B_SEL_REGFILE_OUT_16BIT_B;
                    mux_int_bus_sel           = MUX_INT_BUS_SEL_ALU_OUT;
                    regfile_flags_we          = 1'b1;
                    regfile_read_addr_16bit_a = REG_SELECT_16BIT_HL;
                    regfile_read_addr_16bit_b = reg_select_16bit;
                    regfile_we                = 1'b1;
                    regfile_write_addr        = REG_SELECT_HL;
                end
                { OP_PREFIX_DD, 8'b00??1001 }, // ADD IX,pp
                { OP_PREFIX_FD, 8'b00??1001 }: // ADD IY,rr
                begin
                    alu_mode         = ALU_MODE_ADD_16BIT;
                    mux_alu_op_a_sel = MUX_ALU_OP_A_SEL_REGFILE_OUT_16BIT_A;
                    mux_alu_op_b_sel = MUX_ALU_OP_B_SEL_REGFILE_OUT_16BIT_B;
                    mux_int_bus_sel  = MUX_INT_BUS_SEL_ALU_OUT;
                    regfile_flags_we = 1'b1;
                    regfile_we       = 1'b1;

                    case (reg_op_prefix)
                        OP_PREFIX_DD: begin
                            regfile_read_addr_16bit_a = REG_SELECT_16BIT_IX;
                            regfile_write_addr        = REG_SELECT_IX;
                        end
                        OP_PREFIX_FD: begin
                            regfile_read_addr_16bit_a = REG_SELECT_16BIT_IY;
                            regfile_write_addr        = REG_SELECT_IY;
                        end
                    endcase

                    case (reg_instr[5:4])
                        2'b00: regfile_read_addr_16bit_b = REG_SELECT_16BIT_BC;
                        2'b01: regfile_read_addr_16bit_b = REG_SELECT_16BIT_DE;
                        2'b10: regfile_read_addr_16bit_b = regfile_read_addr_16bit_a;
                        2'b11: regfile_read_addr_16bit_b = REG_SELECT_16BIT_SP;
                    endcase
                end
                 { OP_PREFIX_DD, 8'b0010?011 }, // (INC|DEC) IX
                 { OP_PREFIX_FD, 8'b0010?011 }: // (INC|DEC) IY
                begin
                    case (reg_instr[3])
                        1'b0: alu_mode = ALU_MODE_INC;
                        1'b1: alu_mode = ALU_MODE_DEC;
                    endcase

                    mux_alu_op_a_sel = MUX_ALU_OP_A_SEL_REGFILE_OUT_16BIT_A;
                    mux_int_bus_sel  = MUX_INT_BUS_SEL_ALU_OUT;
                    regfile_we       = 1'b1;

                    case (reg_op_prefix)
                        OP_PREFIX_DD: begin
                            regfile_read_addr_16bit_a = REG_SELECT_16BIT_IX;
                            regfile_write_addr        = REG_SELECT_IX;
                        end
                        OP_PREFIX_FD: begin
                            regfile_read_addr_16bit_a = REG_SELECT_16BIT_IY;
                            regfile_write_addr        = REG_SELECT_IY;
                        end
                    endcase
                end

                // Rotate and Shift Group ============================================

                { OP_PREFIX_CB, 8'b00???110 }: // (ROT|SHIFT) (HL)
                begin
                    mux_mem_addr_sel          = MUX_MEM_ADDR_SEL_REGFILE_OUT_16BIT_B;
                    regfile_read_addr_16bit_b = REG_SELECT_16BIT_HL;
                    reg_mem_addr_we           = 1'b1;
                end
                { OP_PREFIX_CB, 8'b00?????? }: // (ROT|SHIFT) r
                begin
                    case (reg_instr[5:3])
                        3'b000: alu_mode = ALU_MODE_RLC;
                        3'b010: alu_mode = ALU_MODE_RL;
                        3'b001: alu_mode = ALU_MODE_RRC;
                        3'b011: alu_mode = ALU_MODE_RR;
                        3'b100: alu_mode = ALU_MODE_SLA;
                        3'b101: alu_mode = ALU_MODE_SRA;
                        3'b111: alu_mode = ALU_MODE_SRL;
                    endcase

                    mux_alu_op_a_sel         = MUX_ALU_OP_A_SEL_REGFILE_OUT_8BIT_A;
                    mux_int_bus_sel          = MUX_INT_BUS_SEL_ALU_OUT;
                    regfile_flags_we         = 1'b1;
                    regfile_read_addr_8bit_a = reg_select_8bit_2;
                    regfile_we               = 1'b1;
                    regfile_write_addr       = reg_select_8bit_write_2;
                end
                { OP_PREFIX_ED, 8'b0110?111 }: // (RLD|RRD)
                begin
                    mux_mem_addr_sel          = MUX_MEM_ADDR_SEL_REGFILE_OUT_16BIT_B;
                    reg_mem_addr_we           = 1'b1;
                    regfile_read_addr_16bit_b = REG_SELECT_16BIT_HL;
                end

                // Bit Set, Reset, and Test Group ====================================

                { OP_PREFIX_CB, 8'b01???110 }, // BIT b,(HL)
                { OP_PREFIX_CB, 8'b11???110 }, // SET b,(HL)
                { OP_PREFIX_CB, 8'b10???110 }: // RES b,(HL)
                begin
                    mux_mem_addr_sel          = MUX_MEM_ADDR_SEL_REGFILE_OUT_16BIT_B;
                    reg_mem_addr_we           = 1'b1;
                    regfile_read_addr_16bit_b = REG_SELECT_16BIT_HL;
                end
                { OP_PREFIX_CB, 8'b01?????? }: // BIT b,r
                begin
                    alu_bitselect            = reg_instr[5:3];
                    alu_mode                 = ALU_MODE_BIT;
                    mux_alu_op_a_sel         = MUX_ALU_OP_A_SEL_REGFILE_OUT_8BIT_A;
                    regfile_flags_we         = 1'b1;
                    regfile_read_addr_8bit_a = reg_select_8bit_2;
                end
                { OP_PREFIX_CB, 8'b11?????? }, // SET b,r
                { OP_PREFIX_CB, 8'b10?????? }: // RES b,r
                begin
                    alu_bitselect = reg_instr[5:3];

                    case (reg_instr[7:6])
                        2'b11: alu_mode = ALU_MODE_SET;
                        2'b10: alu_mode = ALU_MODE_RES;
                    endcase

                    mux_alu_op_a_sel         = MUX_ALU_OP_A_SEL_REGFILE_OUT_8BIT_A;
                    mux_int_bus_sel          = MUX_INT_BUS_SEL_ALU_OUT;
                    regfile_read_addr_8bit_a = reg_select_8bit_2;
                    regfile_we               = 1'b1;
                    regfile_write_addr       = reg_select_8bit_write_2;
                end

                // Jump Group ========================================================

                { OP_PREFIX_DD, 8'b11101001 }, // JP (IX)
                { OP_PREFIX_FD, 8'b11101001 }: // JP (IY)
                begin
                    mux_int_bus_sel = MUX_INT_BUS_SEL_REGFILE_OUT_16BIT_A;
                    reg_pc_we       = 1'b1;

                    case (reg_op_prefix)
                        OP_PREFIX_DD: regfile_read_addr_16bit_a = REG_SELECT_16BIT_IX;
                        OP_PREFIX_FD: regfile_read_addr_16bit_a = REG_SELECT_16BIT_IY;
                    endcase
                end

                // Call and Return Group =============================================

                { OP_PREFIX_ED, 8'b01001101 }, // RETI
                { OP_PREFIX_ED, 8'b01000101 }: // RETN
                begin
                    alu_mode                  = ALU_MODE_INC;
                    mux_alu_op_a_sel          = MUX_ALU_OP_A_SEL_REGFILE_OUT_16BIT_A;
                    mux_alu_op_b_sel          = MUX_ALU_OP_B_SEL_REGFILE_OUT_16BIT_B;
                    mux_int_bus_sel           = MUX_INT_BUS_SEL_ALU_OUT;
                    mux_mem_addr_sel          = MUX_MEM_ADDR_SEL_REGFILE_OUT_16BIT_B;
                    reg_mem_addr_we           = 1'b1;
                    regfile_read_addr_16bit_a = REG_SELECT_16BIT_SP;
                    regfile_read_addr_16bit_b = REG_SELECT_16BIT_SP;
                    regfile_we                = 1'b1;
                    regfile_write_addr        = REG_SELECT_SP;
                end

                // Input and Output Group ============================================

                { OP_PREFIX_ED, 8'b01???000 }: // IN r,(C)
                begin
                    mux_mem_addr_sel          = MUX_MEM_ADDR_SEL_REGFILE_OUT_16BIT_B;
                    reg_mem_addr_we           = 1'b1;
                    regfile_read_addr_16bit_b = REG_SELECT_16BIT_BC;
                end
                { OP_PREFIX_ED, 8'b01???001 }: // OUT (C),r
                begin
                    mem_dout_en               = 1'b1;
                    mux_mem_addr_sel          = MUX_MEM_ADDR_SEL_REGFILE_OUT_16BIT_B;
                    mux_mem_dout_sel          = MUX_MEM_DOUT_SEL_REGFILE_OUT_8BIT_A;
                    reg_mem_addr_we           = 1'b1;
                    reg_mem_dout_we           = 1'b1;
                    regfile_read_addr_8bit_a  = reg_select_8bit_1;
                    regfile_read_addr_16bit_b = REG_SELECT_16BIT_BC;
                end
                { OP_PREFIX_ED, 8'b101??010 }, // (INI|INITR|IND|INDR)
                { OP_PREFIX_ED, 8'b101??011 }: // (OUTI|OUTIR|OUTD|OUTDR)
                begin
                    alu_mode                 = ALU_MODE_INI;
                    mux_alu_op_a_sel         = MUX_ALU_OP_A_SEL_REGFILE_OUT_8BIT_A;
                    mux_int_bus_sel          = MUX_INT_BUS_SEL_ALU_OUT;
                    mux_mem_addr_sel         = MUX_MEM_ADDR_SEL_REGFILE_OUT_16BIT_B;
                    reg_mem_addr_we          = 1'b1;
                    regfile_flags_we         = 1'b1;
                    regfile_read_addr_8bit_a = REG_SELECT_8BIT_B;

                    case (reg_instr[0])
                        1'b0: regfile_read_addr_16bit_b = REG_SELECT_16BIT_BC; // IN
                        1'b1: regfile_read_addr_16bit_b = REG_SELECT_16BIT_HL; // OUT
                    endcase

                    regfile_we         = 1'b1;
                    regfile_write_addr = REG_SELECT_B;
                end
            endcase
        end
        FSM_STATE_INSTR_FETCH3_3: begin
            casez ({ reg_op_prefix, reg_instr })
                // Rotate and Shift Group ============================================

                { OP_PREFIX_DD_CB, 8'b???????? }, // (ROT|SHIFT|BIT) (IX + d)
                { OP_PREFIX_FD_CB, 8'b???????? }: // (ROT|SHIFT|BIT) (IY + d)
                begin
                    alu_mode         = ALU_MODE_ADD_16BIT;
                    mux_alu_op_a_sel = MUX_ALU_OP_A_SEL_REGFILE_OUT_16BIT_A;
                    mux_alu_op_b_sel = MUX_ALU_OP_B_SEL_REG_MEM_DIN_LO_SGN_EXT;
                    reg_alu_addr_we  = 1'b1;

                    case (reg_op_prefix)
                        OP_PREFIX_DD_CB: regfile_read_addr_16bit_a = REG_SELECT_16BIT_IX;
                        OP_PREFIX_FD_CB: regfile_read_addr_16bit_a = REG_SELECT_16BIT_IY;
                    endcase
                end
            endcase
        end
        FSM_STATE_OP_FETCH1_1,
        FSM_STATE_OP_FETCH2_1: begin
            mem_n_pmem       = 1'b0;
            mem_n_mreq       = 1'b0;
            mem_n_rd         = 1'b0;
            mux_mem_addr_sel = MUX_MEM_ADDR_SEL_REG_PC;
        end
        FSM_STATE_OP_FETCH1_2,
        FSM_STATE_OP_FETCH2_2: begin
            mem_n_pmem       = 1'b0;
            mem_n_mreq       = 1'b0;
            mem_n_rd         = 1'b0;
            mux_mem_addr_sel = MUX_MEM_ADDR_SEL_REG_PC;

            alu_mode         = ALU_MODE_INC;
            mux_alu_op_a_sel = MUX_ALU_OP_A_SEL_REG_PC;
            mux_int_bus_sel  = MUX_INT_BUS_SEL_ALU_OUT;
            reg_pc_we        = 1'b1;

            case (state)
                FSM_STATE_OP_FETCH1_2: reg_mem_din_lo_we = 1'b1;
                FSM_STATE_OP_FETCH2_2: reg_mem_din_hi_we = 1'b1;
            endcase
        end
        FSM_STATE_OP_FETCH1_3: begin
            casez ({ reg_op_prefix, reg_instr })
                // 8-Bit Load Group ==================================================

                { OP_PREFIX_NONE, 8'b00110110 }: // LD (HL),n
                begin
                    mem_dout_en               = 1'b1;
                    mux_mem_dout_sel          = MUX_MEM_DOUT_SEL_REG_MEM_DIN_LO;
                    mux_int_bus_sel           = MUX_INT_BUS_SEL_REG_MEM_DIN;
                    mux_mem_addr_sel          = MUX_MEM_ADDR_SEL_REGFILE_OUT_16BIT_B;
                    reg_mem_addr_we           = 1'b1;
                    reg_mem_dout_we           = 1'b1;
                    regfile_read_addr_16bit_b = REG_SELECT_16BIT_HL;
                end
                { OP_PREFIX_NONE, 8'b00???110 }: // LD r,n
                begin
                    mux_int_bus_sel    = MUX_INT_BUS_SEL_REG_MEM_DIN;
                    regfile_write_addr = reg_select_8bit_write_1;
                    regfile_we         = 1'b1;
                end
                { OP_PREFIX_DD, 8'b01110??? }, // LD (IX + d),r
                { OP_PREFIX_FD, 8'b01110??? }: // LD (IY + d),r
                begin
                    alu_mode         = ALU_MODE_ADD_16BIT;
                    mux_alu_op_a_sel = MUX_ALU_OP_A_SEL_REGFILE_OUT_16BIT_A;
                    mux_alu_op_b_sel = MUX_ALU_OP_B_SEL_REG_MEM_DIN_LO_SGN_EXT;
                    mux_int_bus_sel  = MUX_INT_BUS_SEL_REGFILE_OUT_16BIT_A;
                    reg_alu_addr_we  = 1'b1;

                    case (reg_op_prefix)
                        OP_PREFIX_DD: regfile_read_addr_16bit_a = REG_SELECT_16BIT_IX;
                        OP_PREFIX_FD: regfile_read_addr_16bit_a = REG_SELECT_16BIT_IY;
                    endcase
                end
                { OP_PREFIX_DD, 8'b01???110 }, // LD r,(IX + d)
                { OP_PREFIX_FD, 8'b01???110 }: // LD r,(IY + d)
                begin
                    alu_mode         = ALU_MODE_ADD_16BIT;
                    mux_alu_op_a_sel = MUX_ALU_OP_A_SEL_REGFILE_OUT_16BIT_A;
                    mux_alu_op_b_sel = MUX_ALU_OP_B_SEL_REG_MEM_DIN_LO_SGN_EXT;
                    reg_alu_addr_we  = 1'b1;

                    case (reg_op_prefix)
                        OP_PREFIX_DD: regfile_read_addr_16bit_a = REG_SELECT_16BIT_IX;
                        OP_PREFIX_FD: regfile_read_addr_16bit_a = REG_SELECT_16BIT_IY;
                    endcase
                end

                // 8-Bit Arithmetic Group ============================================

                { OP_PREFIX_NONE, 8'b11???110 }: // ALUOP [A,]n
                begin
                    alu_mode                 = alu_mode_select;
                    mux_alu_op_a_sel         = MUX_ALU_OP_A_SEL_REGFILE_OUT_8BIT_A;
                    mux_alu_op_b_sel         = MUX_ALU_OP_B_SEL_REG_MEM_DIN;
                    mux_int_bus_sel          = MUX_INT_BUS_SEL_ALU_OUT;
                    regfile_flags_we         = 1'b1;
                    regfile_read_addr_8bit_a = REG_SELECT_8BIT_A;

                    if (alu_mode_select != ALU_MODE_CP) begin
                        regfile_we         = 1'b1;
                        regfile_write_addr = REG_SELECT_A;
                    end
                end
                { OP_PREFIX_DD, 8'b10???110 }, // ALUOP [A,](IX + d)
                { OP_PREFIX_DD, 8'b0011010? }, // (INC|DEC) (IX + d)
                { OP_PREFIX_FD, 8'b10???110 }, // ALUOP [A,](IY + d)
                { OP_PREFIX_FD, 8'b0011010? }: // (INC|DEC) (IY + d)
                begin
                    alu_mode         = ALU_MODE_ADD_16BIT;
                    mux_alu_op_a_sel = MUX_ALU_OP_A_SEL_REGFILE_OUT_16BIT_A;
                    mux_alu_op_b_sel = MUX_ALU_OP_B_SEL_REG_MEM_DIN_LO_SGN_EXT;
                    reg_alu_addr_we  = 1'b1;

                    case (reg_op_prefix)
                        OP_PREFIX_DD: regfile_read_addr_16bit_a = REG_SELECT_16BIT_IX;
                        OP_PREFIX_FD: regfile_read_addr_16bit_a = REG_SELECT_16BIT_IY;
                    endcase
                end

                // Jump Group ========================================================

                { OP_PREFIX_NONE, 8'b00011000 }, // JR e
                { OP_PREFIX_NONE, 8'b00111000 }, // JR C,e
                { OP_PREFIX_NONE, 8'b00110000 }, // JR NC,e
                { OP_PREFIX_NONE, 8'b00101000 }, // JR Z,e
                { OP_PREFIX_NONE, 8'b00100000 }: // JR NZ,e
                begin
                    alu_mode         = ALU_MODE_ADD_16BIT;
                    mux_alu_op_a_sel = MUX_ALU_OP_A_SEL_REG_PC;
                    mux_alu_op_b_sel = MUX_ALU_OP_B_SEL_REG_MEM_DIN_LO_SGN_EXT;
                    mux_int_bus_sel  = MUX_INT_BUS_SEL_ALU_OUT;

                    case (reg_instr[5:3])
                        3'b011: reg_pc_we = 1'b1;
                        3'b111: reg_pc_we =  regfile_flag_c;
                        3'b110: reg_pc_we = ~regfile_flag_c;
                        3'b101: reg_pc_we =  regfile_flag_z;
                        3'b100: reg_pc_we = ~regfile_flag_z;
                    endcase
                end
                { OP_PREFIX_NONE, 8'b00010000 }: // DJNZ, e
                begin
                    if (!regfile_b_zero) begin
                        alu_mode         = ALU_MODE_ADD_16BIT;
                        mux_alu_op_a_sel = MUX_ALU_OP_A_SEL_REG_PC;
                        mux_alu_op_b_sel = MUX_ALU_OP_B_SEL_REG_MEM_DIN_LO_SGN_EXT;
                        mux_int_bus_sel  = MUX_INT_BUS_SEL_ALU_OUT;
                        reg_pc_we        = 1'b1;
                    end
                end

                // Call Group ========================================================

                { OP_PREFIX_NONE, 8'b11001101 }, // CALL nn
                { OP_PREFIX_NONE, 8'b11???100 }: // CALL cc,nn
                begin
                    alu_mode                  = ALU_MODE_DEC;
                    mux_alu_op_a_sel          = MUX_ALU_OP_A_SEL_REGFILE_OUT_16BIT_A;
                    mux_int_bus_sel           = MUX_INT_BUS_SEL_ALU_OUT;
                    regfile_read_addr_16bit_a = REG_SELECT_16BIT_SP;
                    regfile_we                = 1'b1;
                    regfile_write_addr        = REG_SELECT_SP;
                end

                // Input and Output Group ============================================

                { OP_PREFIX_NONE, 8'b11011011 }, // IN A,(n)
                { OP_PREFIX_NONE, 8'b11010011 }: // OUT (n),A
                begin
                    mem_dout_en              = 1'b1;
                    mux_mem_addr_sel         = MUX_MEM_ADDR_SEL_REG_IMM;
                    mux_mem_dout_sel         = MUX_MEM_DOUT_SEL_REG_MEM_DOUT_LO;
                    reg_mem_addr_we          = 1'b1;
                    regfile_read_addr_8bit_b = REG_SELECT_8BIT_A;
                end
            endcase
        end
        FSM_STATE_OP_FETCH2_3: begin
            casez ({ reg_op_prefix, reg_instr })
                // 8-Bit Load Group ==================================================

                { OP_PREFIX_NONE, 8'b00110010 }: // LD (nn),A
                begin
                    mem_dout_en              = 1'b1;
                    mux_int_bus_sel          = MUX_INT_BUS_SEL_REGFILE_OUT_8BIT_A;
                    mux_mem_addr_sel         = MUX_MEM_ADDR_SEL_REG_MEM_DIN;
                    mux_mem_dout_sel         = MUX_MEM_DOUT_SEL_REGFILE_OUT_8BIT_A;
                    reg_mem_addr_we          = 1'b1;
                    reg_mem_dout_we          = 1'b1;
                    regfile_read_addr_8bit_a = REG_SELECT_8BIT_A;
                end
                { OP_PREFIX_DD, 8'b00110110 }, // LD (IX + d),n
                { OP_PREFIX_FD, 8'b00110110 }: // LD (IY + d),n
                begin
                    alu_mode         = ALU_MODE_ADD_16BIT;
                    mux_alu_op_a_sel = MUX_ALU_OP_A_SEL_REGFILE_OUT_16BIT_A;
                    mux_alu_op_b_sel = MUX_ALU_OP_B_SEL_REG_MEM_DIN_LO_SGN_EXT;
                    mux_int_bus_sel  = MUX_INT_BUS_SEL_REG_MEM_DIN;
                    reg_alu_addr_we  = 1'b1;
                    reg_mem_dout_we  = 1'b1;

                    case (reg_op_prefix)
                        OP_PREFIX_DD: regfile_read_addr_16bit_a = REG_SELECT_16BIT_IX;
                        OP_PREFIX_FD: regfile_read_addr_16bit_a = REG_SELECT_16BIT_IY;
                    endcase
                end
                { OP_PREFIX_NONE, 8'b00111010 }: // LD A,(nn)
                begin
                    mux_mem_addr_sel = MUX_MEM_ADDR_SEL_REG_MEM_DIN;
                    reg_mem_addr_we  = 1'b1;
                end

                // 16-Bit Load Group =================================================

                { OP_PREFIX_NONE, 8'b00??0001 }, // LD dd,nn
                { OP_PREFIX_DD,   8'b00100001 }, // LD IX,nn
                { OP_PREFIX_FD,   8'b00100001 }: // LD IY,nn
                begin
                    mux_int_bus_sel = MUX_INT_BUS_SEL_REG_MEM_DIN;
                    regfile_we      = 1'b1;

                    case (reg_op_prefix)
                        OP_PREFIX_DD:
                            regfile_write_addr = REG_SELECT_IX;
                        OP_PREFIX_FD:
                            regfile_write_addr = REG_SELECT_IY;
                        OP_PREFIX_NONE:
                            regfile_write_addr = reg_select_16bit_write;
                    endcase
                end
                { OP_PREFIX_NONE, 8'b00101010 }, // LD HL,(nn)
                { OP_PREFIX_ED,   8'b01??1011 }, // LD dd,(nn)
                { OP_PREFIX_DD,   8'b00101010 }, // LD IX,(nn)
                { OP_PREFIX_FD,   8'b00101010 }: // LD IY,(nn)
                begin
                    mux_int_bus_sel  = MUX_INT_BUS_SEL_REG_MEM_DIN;
                    mux_mem_addr_sel = MUX_MEM_ADDR_SEL_REG_MEM_DIN;
                    reg_mem_addr_we  = 1'b1;
                end
                { OP_PREFIX_NONE, 8'b00100010 }, // LD (nn),HL
                { OP_PREFIX_ED,   8'b01??0011 }, // LD (nn),dd
                { OP_PREFIX_DD,   8'b00100010 }, // LD (nn),IX
                { OP_PREFIX_FD,   8'b00100010 }: // LD (nn),IY
                begin
                    mem_dout_en      = 1'b1;
                    mux_int_bus_sel  = MUX_INT_BUS_SEL_REGFILE_OUT_16BIT_A;
                    mux_mem_addr_sel = MUX_MEM_ADDR_SEL_REG_MEM_DIN;
                    mux_mem_dout_sel = MUX_MEM_DOUT_SEL_REGFILE_OUT_16BIT_A_LO;
                    reg_mem_addr_we  = 1'b1;
                    reg_mem_dout_we  = 1'b1;

                    case (reg_op_prefix)
                        OP_PREFIX_DD:
                            regfile_read_addr_16bit_a = REG_SELECT_16BIT_IX;
                        OP_PREFIX_FD:
                            regfile_read_addr_16bit_a = REG_SELECT_16BIT_IY;
                        OP_PREFIX_NONE,
                        OP_PREFIX_ED:
                            regfile_read_addr_16bit_a = reg_select_16bit;
                    endcase
                end

                // Jump Group ========================================================

                { OP_PREFIX_NONE, 8'b11000011 }: // JP nn
                begin
                    mux_int_bus_sel = MUX_INT_BUS_SEL_REG_MEM_DIN;
                    reg_pc_we       = 1'b1;
                end
                { OP_PREFIX_NONE, 8'b11???010 }: // JP cc,nn
                begin
                    mux_int_bus_sel = MUX_INT_BUS_SEL_REG_MEM_DIN;

                    case (reg_instr[5:3])
                        3'b000: reg_pc_we = ~regfile_flag_z;
                        3'b001: reg_pc_we =  regfile_flag_z;
                        3'b010: reg_pc_we = ~regfile_flag_c;
                        3'b011: reg_pc_we =  regfile_flag_c;
                        3'b100: reg_pc_we = ~regfile_flag_pv;
                        3'b101: reg_pc_we =  regfile_flag_pv;
                        3'b110: reg_pc_we = ~regfile_flag_s;
                        3'b111: reg_pc_we =  regfile_flag_s;
                    endcase
                end

                // Call Group ========================================================

                { OP_PREFIX_NONE, 8'b11001101 }, // CALL nn
                { OP_PREFIX_NONE, 8'b11???100 }: // CALL cc,nn
                begin
                    mem_dout_en               = 1'b1;
                    mux_mem_addr_sel          = MUX_MEM_ADDR_SEL_REGFILE_OUT_16BIT_B;
                    mux_mem_dout_sel          = MUX_MEM_DOUT_SEL_REG_PC_HI;
                    reg_mem_addr_we           = 1'b1;
                    reg_mem_dout_we           = 1'b1;
                    regfile_read_addr_16bit_b = REG_SELECT_16BIT_SP;
                end
            endcase
        end
        FSM_STATE_MEM_READ1_1,
        FSM_STATE_MEM_READ2_1: begin
            mem_n_mreq       = 1'b0;
            mem_n_rd         = 1'b0;
            mux_mem_addr_sel = MUX_MEM_ADDR_SEL_REG_MEM_ADDR;
        end
        FSM_STATE_MEM_READ1_2,
        FSM_STATE_MEM_READ2_2: begin
            mem_n_mreq       = 1'b0;
            mem_n_rd         = 1'b0;
            mux_mem_addr_sel = MUX_MEM_ADDR_SEL_REG_MEM_ADDR;

            case (state)
                FSM_STATE_MEM_READ1_2: reg_mem_din_lo_we = 1'b1;
                FSM_STATE_MEM_READ2_2: reg_mem_din_hi_we = 1'b1;
            endcase

            casez ({ reg_op_prefix, reg_instr })
                // 16-Bit Load Group =================================================

                { OP_PREFIX_NONE, 8'b11??0001 }, // POP qq
                { OP_PREFIX_DD,   8'b11100001 }, // POP IX
                { OP_PREFIX_FD,   8'b11100001 }: // POP IY
                begin
                    alu_mode           = ALU_MODE_INC;
                    mux_alu_op_a_sel   = MUX_ALU_OP_A_SEL_REG_MEM_ADDR;
                    regfile_we         = 1'b1;
                    regfile_write_addr = REG_SELECT_SP;
                end
            endcase
        end
        FSM_STATE_MEM_READ1_3: begin
            if (int_active_int && int_mode == INT_MODE_2) begin
                alu_mode         = ALU_MODE_INC;
                mux_alu_op_a_sel = MUX_ALU_OP_A_SEL_REG_MEM_ADDR;
                reg_alu_addr_we  = 1'b1;
            end
            else begin
                casez ({ reg_op_prefix, reg_instr })
                    // 8-Bit Load Group ================================================

                    { OP_PREFIX_NONE, 8'b01???110 }, // LD r,(HL)
                    { OP_PREFIX_DD,   8'b01???110 }, // LD r,(IX + d)
                    { OP_PREFIX_FD,   8'b01???110 }: // LD r,(IY + d)
                    begin
                        mux_int_bus_sel    = MUX_INT_BUS_SEL_REG_MEM_DIN;
                        regfile_we         = 1'b1;
                        regfile_write_addr = reg_select_8bit_write_1;
                    end
                    { OP_PREFIX_NONE, 8'b00001010 }, // LD A,(BC)
                    { OP_PREFIX_NONE, 8'b00011010 }: // LD A,C)|(DE)
                    begin
                        mux_int_bus_sel    = MUX_INT_BUS_SEL_REG_MEM_DIN;
                        regfile_we         = 1'b1;
                        regfile_write_addr = REG_SELECT_A;
                    end
                    { OP_PREFIX_NONE, 8'b00111010 }: begin // LD A,(nn)
                        mux_int_bus_sel    = MUX_INT_BUS_SEL_REG_MEM_DIN;
                        regfile_we         = 1'b1;
                        regfile_write_addr = REG_SELECT_A;
                    end

                    // 16-Bit Load Group ===============================================

                    { OP_PREFIX_NONE, 8'b00101010 }, // LD HL,(nn)
                    { OP_PREFIX_DD,   8'b00101010 }, // LD IX,(nn)
                    { OP_PREFIX_ED,   8'b01??1011 }, // LD dd,(nn)
                    { OP_PREFIX_FD,   8'b00101010 }: // LD IY,(nn)
                    begin
                        alu_mode         = ALU_MODE_INC;
                        mux_alu_op_a_sel = MUX_ALU_OP_A_SEL_REG_MEM_ADDR;
                        mux_int_bus_sel  = MUX_INT_BUS_SEL_ALU_OUT;
                        reg_alu_addr_we  = 1'b1;
                    end
                    { OP_PREFIX_NONE, 8'b11??0001 }, // POP qq
                    { OP_PREFIX_DD,   8'b11100001 }, // POP IX
                    { OP_PREFIX_FD,   8'b11100001 }: // POP IY
                    begin
                        alu_mode         = ALU_MODE_INC;
                        mux_alu_op_a_sel = MUX_ALU_OP_A_SEL_REG_MEM_ADDR;
                        reg_alu_addr_we  = 1'b1;
                    end

                    // Exchange, Block Transfer, and Search Group ======================

                    { OP_PREFIX_NONE, 8'b11100011 }, // EX (SP),HL
                    { OP_PREFIX_DD,   8'b11100011 }, // EX (SP),IX
                    { OP_PREFIX_FD,   8'b11100011 }: // EX (SP),IY
                    begin
                        mem_dout_en      = 1'b1;
                        mux_mem_addr_sel = MUX_MEM_ADDR_SEL_REG_MEM_ADDR;
                        mux_mem_dout_sel = MUX_MEM_DOUT_SEL_REG_MEM_DOUT_LO;
                    end
                    { OP_PREFIX_ED, 8'b101??000 }: // (LDI|LDIR|LDD|LDDR)
                    begin
                        case (reg_instr[3])
                            1'b0: alu_mode = ALU_MODE_INC;
                            1'b1: alu_mode = ALU_MODE_DEC;
                        endcase

                        mem_dout_en               = 1'b1;
                        mux_alu_op_a_sel          = MUX_ALU_OP_A_SEL_REGFILE_OUT_16BIT_A;
                        mux_int_bus_sel           = MUX_INT_BUS_SEL_ALU_OUT;
                        mux_mem_addr_sel          = MUX_MEM_ADDR_SEL_REGFILE_OUT_16BIT_B;
                        mux_mem_dout_sel          = MUX_MEM_DOUT_SEL_REG_MEM_DIN_LO;
                        reg_mem_addr_we           = 1'b1;
                        reg_mem_dout_we           = 1'b1;
                        regfile_bc_dec            = BC_DEC_LD;
                        regfile_read_addr_16bit_a = REG_SELECT_16BIT_DE;
                        regfile_read_addr_16bit_b = REG_SELECT_16BIT_DE;
                        regfile_we                = 1'b1;
                        regfile_write_addr        = REG_SELECT_DE;
                    end
                    { OP_PREFIX_ED, 8'b101??001 }: // (CPI|CPIR|CPD|CPDR)
                    begin
                        alu_mode                 = ALU_MODE_CPB;
                        mux_alu_op_a_sel         = MUX_ALU_OP_A_SEL_REGFILE_OUT_8BIT_A;
                        mux_alu_op_b_sel         = MUX_ALU_OP_B_SEL_REG_MEM_DIN;
                        regfile_flags_we         = 1'b1;
                        regfile_read_addr_8bit_a = REG_SELECT_8BIT_A;
                    end

                    // 8-Bit Arithmetic Group ==========================================

                    { OP_PREFIX_NONE, 8'b10???110 }, // ALUOP [A,](HL)
                    { OP_PREFIX_DD,   8'b10???110 }, // ALUOP [A,](IX + d)
                    { OP_PREFIX_FD,   8'b10???110 }: // ALUOP [A,](IY + d)
                    begin
                        alu_mode                 = alu_mode_select;
                        mem_dout_en              = 1'b1;
                        mux_alu_op_a_sel         = MUX_ALU_OP_A_SEL_REGFILE_OUT_8BIT_A;
                        mux_alu_op_b_sel         = MUX_ALU_OP_B_SEL_REG_MEM_DIN;
                        mux_int_bus_sel          = MUX_INT_BUS_SEL_ALU_OUT;
                        regfile_flags_we         = 1'b1;
                        regfile_read_addr_8bit_a = REG_SELECT_8BIT_A;

                        if (alu_mode_select != ALU_MODE_CP) begin
                            regfile_we         = 1'b1;
                            regfile_write_addr = REG_SELECT_A;
                        end
                    end
                    { OP_PREFIX_NONE, 8'b0011010? }, // (INC|DEC) (HL)
                    { OP_PREFIX_DD,   8'b0011010? }, // (INC|DEC) (IX + d)
                    { OP_PREFIX_FD,   8'b0011010? }: // (INC|DEC) (IY + d)
                    begin
                        case (reg_instr[0])
                            1'b0: alu_mode = ALU_MODE_INC;
                            1'b1: alu_mode = ALU_MODE_DEC;
                        endcase

                        mux_alu_op_a_sel = MUX_ALU_OP_A_SEL_REG_MEM_DIN;
                        mux_int_bus_sel  = MUX_INT_BUS_SEL_ALU_OUT;
                        reg_mem_dout_we  = 1'b1;
                        regfile_flags_we = 1'b1;
                    end

                    // Rotate and Shift Group ==========================================

                    { OP_PREFIX_CB,    8'b00???110 }, // (ROT|SHIFT) (HL)
                    { OP_PREFIX_DD_CB, 8'b00???110 }, // (ROT|SHIFT) (IX + d)
                    { OP_PREFIX_FD_CB, 8'b00???110 }: // (ROT|SHIFT) (IY + d)
                    begin
                        case (reg_instr[5:3])
                            3'b000: alu_mode = ALU_MODE_RLC;
                            3'b010: alu_mode = ALU_MODE_RL;
                            3'b001: alu_mode = ALU_MODE_RRC;
                            3'b011: alu_mode = ALU_MODE_RR;
                            3'b100: alu_mode = ALU_MODE_SLA;
                            3'b101: alu_mode = ALU_MODE_SRA;
                            3'b111: alu_mode = ALU_MODE_SRL;
                        endcase

                        mux_alu_op_a_sel = MUX_ALU_OP_A_SEL_REG_MEM_DIN;
                        mux_int_bus_sel  = MUX_INT_BUS_SEL_ALU_OUT;
                        reg_mem_dout_we  = 1'b1;
                        regfile_flags_we = 1'b1;
                    end
                    { OP_PREFIX_ED, 8'b0110?111 }: // (RLD|RRD)
                    begin
                        case (reg_instr[3])
                            1'b1: alu_mode = ALU_MODE_RLD;
                            1'b0: alu_mode = ALU_MODE_RRD;
                        endcase

                        mux_alu_op_a_sel          = MUX_ALU_OP_A_SEL_REGFILE_OUT_8BIT_A;
                        mux_alu_op_b_sel          = MUX_ALU_OP_B_SEL_REG_MEM_DIN;
                        mux_int_bus_sel           = MUX_INT_BUS_SEL_ALU_OUT;
                        reg_mem_dout_we           = 1'b1;
                        regfile_flags_we          = 1'b1;
                        regfile_read_addr_8bit_a  = REG_SELECT_8BIT_A;
                        regfile_read_addr_16bit_b = REG_SELECT_16BIT_HL;
                        regfile_we                = 1'b1;
                        regfile_write_addr        = REG_SELECT_A;
                    end

                    // Bit Set, Reset, and Test Group ==================================

                    { OP_PREFIX_CB,    8'b01???110 }, // BIT b,(HL)
                    { OP_PREFIX_DD_CB, 8'b01???110 }, // BIT b,(IX + d)
                    { OP_PREFIX_FD_CB, 8'b01???110 }: // BIT b,(IY + d)
                    begin
                        alu_bitselect             = reg_instr[5:3];
                        alu_mode                  = ALU_MODE_BIT;
                        mux_alu_op_a_sel          = MUX_ALU_OP_A_SEL_REG_MEM_DIN;
                        regfile_flags_we          = 1'b1;
                        regfile_read_addr_16bit_a = REG_SELECT_16BIT_HL;
                    end
                    { OP_PREFIX_CB,    8'b1????110 }, // (SET|RES) b,(HL)
                    { OP_PREFIX_DD_CB, 8'b1????110 }, // (SET|RES) b,(IX + d)
                    { OP_PREFIX_FD_CB, 8'b1????110 }: // (SET|RES) b,(IY + d)
                    begin
                        alu_bitselect = reg_instr[5:3];

                        case (reg_instr[7:6])
                            2'b11: alu_mode = ALU_MODE_SET;
                            2'b10: alu_mode = ALU_MODE_RES;
                        endcase

                        mux_alu_op_a_sel = MUX_ALU_OP_A_SEL_REG_MEM_DIN;
                        mux_int_bus_sel  = MUX_INT_BUS_SEL_ALU_OUT;
                        reg_mem_dout_we  = 1'b1;
                    end

                    // Call and Return Group ===========================================

                    { OP_PREFIX_NONE, 8'b11001001 }, // RET
                    { OP_PREFIX_NONE, 8'b11???000 }, // RET cc
                    { OP_PREFIX_ED,   8'b0100?101 }: // (RETI|RETN)
                    begin
                        alu_mode                  = ALU_MODE_INC;
                        mux_alu_op_a_sel          = MUX_ALU_OP_A_SEL_REGFILE_OUT_16BIT_A;
                        mux_int_bus_sel           = MUX_INT_BUS_SEL_ALU_OUT;
                        mux_mem_addr_sel          = MUX_MEM_ADDR_SEL_REGFILE_OUT_16BIT_B;
                        reg_mem_addr_we           = 1'b1;
                        regfile_read_addr_16bit_a = REG_SELECT_16BIT_SP;
                        regfile_read_addr_16bit_b = REG_SELECT_16BIT_SP;
                        regfile_we                = 1'b1;
                        regfile_write_addr        = REG_SELECT_SP;
                    end

                    // Input and Output Group ==========================================

                    { OP_PREFIX_ED, 8'b101??011 }: // (OUTI|OUTIR|OUTD|OUTDR)
                    begin
                        case (reg_instr[3])
                            1'b0: alu_mode = ALU_MODE_INC;
                            1'b1: alu_mode = ALU_MODE_DEC;
                        endcase

                        mem_dout_en               = 1'b1;
                        mux_alu_op_a_sel          = MUX_ALU_OP_A_SEL_REGFILE_OUT_16BIT_A;
                        mux_int_bus_sel           = MUX_INT_BUS_SEL_ALU_OUT;
                        mux_mem_addr_sel          = MUX_MEM_ADDR_SEL_REGFILE_OUT_16BIT_B;
                        mux_mem_dout_sel          = MUX_MEM_DOUT_SEL_REG_MEM_DIN_LO;
                        reg_mem_addr_we           = 1'b1;
                        regfile_read_addr_16bit_a = REG_SELECT_16BIT_HL;
                        regfile_read_addr_16bit_b = REG_SELECT_16BIT_BC;
                        regfile_we                = 1'b1;
                        regfile_write_addr        = REG_SELECT_HL;
                    end
                endcase
            end
        end
        FSM_STATE_MEM_READ2_3: begin
            if (int_active_int && int_mode == INT_MODE_2) begin
                mux_int_bus_sel  = MUX_INT_BUS_SEL_REG_MEM_DIN;
                mux_mem_addr_sel = MUX_MEM_ADDR_SEL_REG_MEM_DIN;
                reg_pc_we        = 1'b1;
            end
            else begin
                casez ({ reg_op_prefix, reg_instr })
                    // 16-Bit Load Group ===============================================

                    { OP_PREFIX_NONE, 8'b00101010 }, // LD HL,(nn)
                    { OP_PREFIX_DD,   8'b00101010 }, // LD IX,(nn)
                    { OP_PREFIX_FD,   8'b00101010 }, // LD IY,(nn)
                    { OP_PREFIX_ED,   8'b01??1011 }: // LD dd,(nn)
                    begin
                        mux_int_bus_sel = MUX_INT_BUS_SEL_REG_MEM_DIN;
                        regfile_we      = 1'b1;

                        case (reg_op_prefix)
                            OP_PREFIX_DD:
                                regfile_write_addr = REG_SELECT_IX;
                            OP_PREFIX_FD:
                                regfile_write_addr = REG_SELECT_IY;
                             OP_PREFIX_NONE,
                            OP_PREFIX_ED:
                                regfile_write_addr = reg_select_16bit_write;
                        endcase
                    end
                    { OP_PREFIX_NONE, 8'b11??0001 }, // POP qq
                    { OP_PREFIX_DD,   8'b11100001 }, // POP IX
                    { OP_PREFIX_FD,   8'b11100001 }: // POP IY
                    begin
                        mux_int_bus_sel = MUX_INT_BUS_SEL_REG_MEM_DIN;
                        regfile_we      = 1'b1;

                        case (reg_op_prefix)
                            OP_PREFIX_DD:
                                regfile_write_addr = REG_SELECT_IX;
                            OP_PREFIX_FD:
                                regfile_write_addr = REG_SELECT_IY;
                            OP_PREFIX_NONE: begin
                                case (reg_instr[5:4])
                                    2'b00: regfile_write_addr = REG_SELECT_BC;
                                    2'b01: regfile_write_addr = REG_SELECT_DE;
                                    2'b10: regfile_write_addr = REG_SELECT_HL;
                                    2'b11: regfile_write_addr = REG_SELECT_AF;
                                endcase
                            end
                        endcase
                    end

                    // Exchange, Block Transfer, and Search Group ======================

                    { OP_PREFIX_NONE, 8'b11100011 }, // EX (SP),HL
                    { OP_PREFIX_DD,   8'b11100011 }, // EX (SP),IX
                    { OP_PREFIX_FD,   8'b11100011 }: // EX (SP),IY
                    begin
                        mem_dout_en      = 1'b1;
                        mux_int_bus_sel  = MUX_INT_BUS_SEL_REG_MEM_DIN;
                        mux_mem_addr_sel = MUX_MEM_ADDR_SEL_REG_MEM_ADDR;
                        mux_mem_dout_sel = MUX_MEM_DOUT_SEL_REG_MEM_DOUT_HI;
                        regfile_we       = 1'b1;

                        case (reg_op_prefix)
                            OP_PREFIX_NONE: regfile_write_addr = REG_SELECT_HL;
                            OP_PREFIX_DD:   regfile_write_addr = REG_SELECT_IX;
                            OP_PREFIX_FD:   regfile_write_addr = REG_SELECT_IY;
                        endcase
                    end

                    // Call and Return Group ===========================================

                    { OP_PREFIX_NONE, 8'b11001001 }, // RET
                    { OP_PREFIX_NONE, 8'b11???000 }, // RET cc
                    { OP_PREFIX_ED,   8'b01001101 }: // RETI
                    begin
                        mux_int_bus_sel  = MUX_INT_BUS_SEL_REG_MEM_DIN;
                        mux_mem_addr_sel = MUX_MEM_ADDR_SEL_REG_MEM_DIN;
                        reg_pc_we        = 1'b1;
                    end
                    { OP_PREFIX_ED, 8'b01000101 }: // RETN
                    begin
                        int_restore      = 1'b1;
                        mux_int_bus_sel  = MUX_INT_BUS_SEL_REG_MEM_DIN;
                        mux_mem_addr_sel = MUX_MEM_ADDR_SEL_REG_MEM_DIN;
                        reg_pc_we        = 1'b1;
                    end
                endcase
            end
        end
        FSM_STATE_MEM_WRITE1_1,
        FSM_STATE_MEM_WRITE1_2: begin
            mem_n_mreq       = 1'b0;
            mem_dout_en      = 1'b1;
            mux_mem_addr_sel = MUX_MEM_ADDR_SEL_REG_MEM_ADDR;

            if (state == FSM_STATE_MEM_WRITE1_1)
                mem_n_wr = 1'b0;

            if (int_active_nmi || (int_active_int && int_mode != INT_MODE_0)) begin
                mux_mem_dout_sel = MUX_MEM_DOUT_SEL_REG_PC_HI;
            end
            else begin
                casez ({ reg_op_prefix, reg_instr })
                    { OP_PREFIX_NONE, 8'b11??0101 }, // PUSH qq
                    { OP_PREFIX_DD,   8'b11100101 }, // PUSH IX
                    { OP_PREFIX_DD,   8'b00110110 }, // LD (IX + d),n
                    { OP_PREFIX_FD,   8'b00110110 }, // LD (IY + d),n
                    { OP_PREFIX_FD,   8'b11100101 }, // PUSH IY
                    { OP_PREFIX_ED,   8'b0110?111 }: // (RLD|RRD)
                    begin
                        mux_mem_dout_sel = MUX_MEM_DOUT_SEL_REG_MEM_DOUT_HI;
                    end
                    { OP_PREFIX_ED, 8'b101??000 }, // (LDI|LDIR|LDD|LDDR)
                    { OP_PREFIX_ED, 8'b101??010 }: // (INI|INIR|IND|INDR)
                    begin
                        mux_mem_dout_sel = MUX_MEM_DOUT_SEL_REG_MEM_DIN_LO;
                    end
                    { OP_PREFIX_NONE, 8'b11001101 }, // CALL nn
                    { OP_PREFIX_NONE, 8'b11???100 }, // CALL cc,nn
                    { OP_PREFIX_NONE, 8'b11???111 }: // RST p
                    begin
                        mux_mem_dout_sel = MUX_MEM_DOUT_SEL_REG_PC_HI;
                    end
                    default: begin
                        mux_mem_dout_sel = MUX_MEM_DOUT_SEL_REG_MEM_DOUT_LO;
                    end
                endcase
            end
        end
        FSM_STATE_MEM_WRITE2_1,
        FSM_STATE_MEM_WRITE2_2: begin
            mem_n_mreq       = 1'b0;
            mem_dout_en      = 1'b1;
            mux_mem_addr_sel = MUX_MEM_ADDR_SEL_REG_MEM_ADDR;

            if (state == FSM_STATE_MEM_WRITE2_1)
                mem_n_wr = 1'b0;

            if (int_active_nmi || (int_active_int && int_mode != INT_MODE_0)) begin
                mux_mem_dout_sel = MUX_MEM_DOUT_SEL_REG_PC_LO;
            end
            else begin
                casez ({ reg_op_prefix, reg_instr })
                    { OP_PREFIX_NONE, 8'b00100010 }, // LD (nn),HL
                    { OP_PREFIX_NONE, 8'b11100011 }, // EX (SP),HL
                    { OP_PREFIX_DD,   8'b00100010 }, // LD (nn),IX
                    { OP_PREFIX_DD,   8'b11100011 }, // EX (SP),IX
                    { OP_PREFIX_ED,   8'b01??0011 }, // LD (nn),dd
                    { OP_PREFIX_FD,   8'b00100010 }, // LD (nn),IY
                    { OP_PREFIX_FD,   8'b11100011 }: // EX (SP),IY
                    begin
                        mux_mem_dout_sel = MUX_MEM_DOUT_SEL_REG_MEM_DOUT_HI;
                    end
                    { OP_PREFIX_NONE, 8'b11???100 }, // CALL cc,nn
                    { OP_PREFIX_NONE, 8'b11001101 }, // CALL nn
                    { OP_PREFIX_NONE, 8'b11???111 }: // RST p
                    begin
                        mux_mem_dout_sel = MUX_MEM_DOUT_SEL_REG_PC_LO;
                    end
                    default: begin
                        mux_mem_dout_sel = MUX_MEM_DOUT_SEL_REG_MEM_DOUT_LO;
                    end
                endcase
            end
        end
        FSM_STATE_MEM_WRITE1_3: begin
            if (int_active_nmi || (int_active_int && int_mode != INT_MODE_0)) begin
                alu_mode                  = ALU_MODE_DEC;
                mux_alu_op_a_sel          = MUX_ALU_OP_A_SEL_REGFILE_OUT_16BIT_A;
                mux_int_bus_sel           = MUX_INT_BUS_SEL_ALU_OUT;
                reg_alu_addr_we           = 1'b1;
                regfile_read_addr_16bit_a = REG_SELECT_16BIT_SP;
                regfile_we                = 1'b1;
                regfile_write_addr        = REG_SELECT_SP;
            end
            else begin
                casez ({ reg_op_prefix, reg_instr })
                    // 16-Bit Load Group ===============================================

                    { OP_PREFIX_NONE, 8'b00100010 }, // LD (nn),HL
                    { OP_PREFIX_DD,   8'b00100010 }, // LD (nn),IX
                    { OP_PREFIX_ED,   8'b01??0011 }, // LD (nn),dd
                    { OP_PREFIX_FD,   8'b00100010 }: // LD (nn),IY
                    begin
                        alu_mode         = ALU_MODE_INC;
                        mux_alu_op_a_sel = MUX_ALU_OP_A_SEL_REG_MEM_ADDR;
                        reg_alu_addr_we  = 1'b1;
                    end
                    { OP_PREFIX_NONE, 8'b11??0101 }, // PUSH qq
                    { OP_PREFIX_DD,   8'b11100101 }, // PUSH IX
                    { OP_PREFIX_FD,   8'b11100101 }: // PUSH IY
                    begin
                        alu_mode           = ALU_MODE_DEC;
                        mux_alu_op_a_sel   = MUX_ALU_OP_A_SEL_REG_MEM_ADDR;
                        mux_int_bus_sel    = MUX_INT_BUS_SEL_ALU_OUT;
                        reg_alu_addr_we    = 1'b1;
                        regfile_we         = 1'b1;
                        regfile_write_addr = REG_SELECT_SP;
                    end

                    // Exchange, Block Transfer, and Search Group ======================

                    { OP_PREFIX_NONE, 8'b11100011 }, // EX (SP),HL
                    { OP_PREFIX_DD,   8'b11100011 }, // EX (SP),IX
                    { OP_PREFIX_FD,   8'b11100011 }: // EX (SP),IY
                    begin
                        alu_mode                  = ALU_MODE_INC;
                        mux_alu_op_a_sel          = MUX_ALU_OP_A_SEL_REGFILE_OUT_16BIT_A;
                        mux_int_bus_sel           = MUX_INT_BUS_SEL_ALU_OUT;
                        reg_alu_addr_we           = 1'b1;
                        regfile_read_addr_16bit_a = REG_SELECT_16BIT_SP;
                    end
                    { OP_PREFIX_ED, 8'b1011?000 }: // (LDIR|LDDR)
                    begin
                        if (!regfile_bc_zero) begin
                            alu_mode         = ALU_MODE_SUB;
                            mux_alu_op_a_sel = MUX_ALU_OP_A_SEL_REG_PC;
                            mux_alu_op_b_sel = MUX_ALU_OP_B_SEL_CONST2;
                            mux_int_bus_sel  = MUX_INT_BUS_SEL_ALU_OUT;
                            reg_pc_we        = 1'b1;
                        end
                    end

                    // Call Group ======================================================

                    { OP_PREFIX_NONE, 8'b11001101 }, // CALL nn
                    { OP_PREFIX_NONE, 8'b11???100 }, // CALL cc,nn
                    { OP_PREFIX_NONE, 8'b11???111 }: // RST p
                    begin
                        alu_mode                  = ALU_MODE_DEC;
                        mem_dout_en               = 1'b1;
                        mux_alu_op_a_sel          = MUX_ALU_OP_A_SEL_REGFILE_OUT_16BIT_A;
                        mux_int_bus_sel           = MUX_INT_BUS_SEL_ALU_OUT;
                        mux_mem_dout_sel          = MUX_MEM_DOUT_SEL_REG_PC_LO;
                        reg_alu_addr_we           = 1'b1;
                        regfile_read_addr_16bit_a = REG_SELECT_16BIT_SP;
                        regfile_we                = 1'b1;
                        regfile_write_addr        = REG_SELECT_SP;
                    end

                    // Input and Ouput Group ===========================================

                    { OP_PREFIX_ED, 8'b1011?010 }: // (INIR|INDR)
                    begin
                        if (!regfile_flag_z) begin
                            alu_mode         = ALU_MODE_SUB;
                            mux_alu_op_a_sel = MUX_ALU_OP_A_SEL_REG_PC;
                            mux_alu_op_b_sel = MUX_ALU_OP_B_SEL_CONST2;
                            mux_int_bus_sel  = MUX_INT_BUS_SEL_ALU_OUT;
                            reg_alu_addr_we  = 1'b1;
                            reg_pc_we        = 1'b1;
                        end
                    end
                endcase
            end
        end
        FSM_STATE_MEM_WRITE2_3: begin
            if (int_active_nmi) begin
                mux_int_bus_sel  = MUX_INT_BUS_SEL_REG_PC_DIRECT;
                reg_pc_lo_direct = 8'h66;
                reg_pc_we        = 1'b1;
            end
            else if (int_active_int && int_mode == INT_MODE_1) begin
                mux_int_bus_sel  = MUX_INT_BUS_SEL_REG_PC_DIRECT;
                reg_pc_lo_direct = 8'h38;
                reg_pc_we        = 1'b1;
            end
            else if (int_active_int && int_mode == INT_MODE_2) begin
                mux_mem_addr_sel = MUX_MEM_ADDR_SEL_INT_ADDR;
                reg_mem_addr_we  = 1'b1;
            end
            else begin
                casez ({ reg_op_prefix, reg_instr })
                    // Call Group ======================================================

                    { OP_PREFIX_NONE, 8'b11001101 }, // CALL nn
                    { OP_PREFIX_NONE, 8'b11???100 }: // CALL cc,nn
                    begin
                        mux_int_bus_sel = MUX_INT_BUS_SEL_REG_MEM_DIN;
                        reg_pc_we       = 1'b1;
                    end
                    { OP_PREFIX_NONE, 8'b11???111 }: // RST p
                    begin
                        mux_int_bus_sel  = MUX_INT_BUS_SEL_REG_PC_DIRECT;
                        reg_pc_lo_direct = { 2'b00, reg_instr[5:3] } << 3;
                        reg_pc_we        = 1'b1;
                    end
                endcase
            end
        end
        FSM_STATE_IO_READ_1: begin
            io_n_iorq        = 1'b0;
            mem_n_rd         = 1'b0;
            mux_mem_addr_sel = MUX_MEM_ADDR_SEL_REG_MEM_ADDR;
        end
        FSM_STATE_IO_READ_2: begin
            io_n_iorq         = 1'b0;
            mem_n_rd          = 1'b0;
            mux_mem_addr_sel  = MUX_MEM_ADDR_SEL_REG_MEM_ADDR;

            reg_mem_din_lo_we = 1'b1;
        end
        FSM_STATE_IO_READ_3: begin
            casez ({ reg_op_prefix, reg_instr })
                // Input and Output Group ============================================

                { OP_PREFIX_NONE, 8'b11011011 }: // IN A,(n)
                begin
                    mux_int_bus_sel    = MUX_INT_BUS_SEL_REG_MEM_DIN;
                    regfile_we         = 1'b1;
                    regfile_write_addr = REG_SELECT_A;
                end
                { OP_PREFIX_ED, 8'b01???000 }: // IN r,(C)
                begin
                    alu_mode         = ALU_MODE_IN;
                    mux_alu_op_a_sel = MUX_ALU_OP_A_SEL_REG_MEM_DIN;
                    regfile_flags_we = 1'b1;

                    if (reg_instr[5:3] != 3'b110) begin
                        mux_int_bus_sel    = MUX_INT_BUS_SEL_REG_MEM_DIN;
                        regfile_we         = 1'b1;
                        regfile_write_addr = reg_select_8bit_write_1;
                    end
                end
                { OP_PREFIX_ED, 8'b101??010 }: // (INI|INIR|IND|INDR)
                begin
                    case (reg_instr[3])
                        1'b0: alu_mode = ALU_MODE_INC;
                        1'b1: alu_mode = ALU_MODE_DEC;
                    endcase

                    mux_alu_op_a_sel          = MUX_ALU_OP_A_SEL_REGFILE_OUT_16BIT_A;
                    mux_int_bus_sel           = MUX_INT_BUS_SEL_ALU_OUT;
                    mux_mem_addr_sel          = MUX_MEM_ADDR_SEL_REGFILE_OUT_16BIT_B;
                    mux_mem_dout_sel          = MUX_MEM_DOUT_SEL_REG_MEM_DIN_LO;
                    reg_mem_addr_we           = 1'b1;
                    reg_mem_dout_we           = 1'b1;
                     regfile_read_addr_16bit_a = REG_SELECT_16BIT_HL;
                     regfile_read_addr_16bit_b = REG_SELECT_16BIT_HL;
                     regfile_we                = 1'b1;
                     regfile_write_addr        = REG_SELECT_HL;
                end
            endcase
        end
        FSM_STATE_IO_WRITE_1,
        FSM_STATE_IO_WRITE_2: begin
            io_n_iorq        = 1'b0;
            mem_dout_en      = 1'b1;
            mux_mem_addr_sel = MUX_MEM_ADDR_SEL_REG_MEM_ADDR;

            if (state == FSM_STATE_IO_WRITE_1)
                mem_n_wr = 1'b0;

            casez ({ reg_op_prefix, reg_instr })
                { OP_PREFIX_ED, 8'b101??011 }: // (OUTI|OUTIR|OUTD|OUTDR)
                begin
                    mux_mem_dout_sel = MUX_MEM_DOUT_SEL_REG_MEM_DIN_LO;
                end
                default: begin
                    mux_mem_dout_sel = MUX_MEM_DOUT_SEL_REG_MEM_DOUT_LO;
                end
            endcase
        end
        FSM_STATE_IO_WRITE_3: begin
            casez ({ reg_op_prefix, reg_instr })
                { OP_PREFIX_ED, 8'b101??011 }: // (OUTI|OUTIR|OUTD|OUTDR)
                begin
                    if (!regfile_flag_z) begin
                        alu_mode         = ALU_MODE_SUB;
                        mux_alu_op_a_sel = MUX_ALU_OP_A_SEL_REG_PC;
                        mux_alu_op_b_sel = MUX_ALU_OP_B_SEL_CONST2;
                        mux_int_bus_sel  = MUX_INT_BUS_SEL_ALU_OUT;
                        reg_alu_addr_we  = 1'b1;
                        reg_pc_we        = 1'b1;
                    end
                end
            endcase
        end
        FSM_STATE_ACK_INT_1: begin
            mem_n_m1         = 1'b0;
            mux_mem_addr_sel = MUX_MEM_ADDR_SEL_REG_PC;
        end
        FSM_STATE_ACK_INT_2: begin
            io_n_iorq        = 1'b0;
            mem_n_m1         = 1'b0;
            mux_mem_addr_sel = MUX_MEM_ADDR_SEL_REG_PC;
        end
        FSM_STATE_ACK_INT_3: begin
            io_n_iorq        = 1'b0;
            mem_n_m1         = 1'b0;
            mux_mem_addr_sel = MUX_MEM_ADDR_SEL_REG_PC;

            if (int_mode == INT_MODE_0)
                reg_instr_we = 1'b1;
            if (int_mode == INT_MODE_2)
                reg_mem_din_lo_we = 1'b1;
        end
        FSM_STATE_ACK_INT_4: begin
            if (int_mode == INT_MODE_1 || int_mode == INT_MODE_2) begin
                alu_mode                  = ALU_MODE_DEC;
                mux_alu_op_a_sel          = MUX_ALU_OP_A_SEL_REGFILE_OUT_16BIT_A;
                mux_int_bus_sel           = MUX_INT_BUS_SEL_ALU_OUT;
                reg_alu_addr_we           = 1'b1;
                regfile_read_addr_16bit_a = REG_SELECT_16BIT_SP;
                regfile_we                = 1'b1;
                regfile_write_addr        = REG_SELECT_SP;
            end
        end
        FSM_STATE_ACK_NMI_1: begin
            mem_n_m1         = 1'b0;
            mem_n_mreq       = 1'b0;
            mem_n_rd         = 1'b0;
            mux_mem_addr_sel = MUX_MEM_ADDR_SEL_REG_PC;
        end
        FSM_STATE_ACK_NMI_2: begin
            alu_mode                  = ALU_MODE_DEC;
            mux_alu_op_a_sel          = MUX_ALU_OP_A_SEL_REGFILE_OUT_16BIT_A;
            mux_int_bus_sel           = MUX_INT_BUS_SEL_ALU_OUT;
            reg_alu_addr_we           = 1'b1;
            regfile_read_addr_16bit_a = REG_SELECT_16BIT_SP;
            regfile_we                = 1'b1;
            regfile_write_addr        = REG_SELECT_SP;
        end
        FSM_STATE_PRE_INSTR_FETCH_1,
        FSM_STATE_PRE_MEM_READ_1,
        FSM_STATE_PRE_MEM_READ_2: begin
            mux_mem_addr_sel = MUX_MEM_ADDR_SEL_ALU_ADDR;

            reg_mem_addr_we = 1'b1;
        end
        FSM_STATE_PRE_MEM_WRITE_1: begin
            mem_dout_en = 1'b1;

            casez ({ reg_op_prefix, reg_instr })
                { OP_PREFIX_NONE, 8'b0011010? }, // (INC|DEC) (HL)
                { OP_PREFIX_ED,   8'b0110?111 }, // (RLD|RRD)
                { OP_PREFIX_CB,   8'b???????? }: // (ROT|SHIFT|BIT) (HL)
                begin
                    mux_mem_addr_sel = MUX_MEM_ADDR_SEL_REG_MEM_ADDR;
                end
                default: begin
                    mux_mem_addr_sel = MUX_MEM_ADDR_SEL_ALU_ADDR;
                end
            endcase

            if (int_active_nmi || (int_active_int && int_mode != INT_MODE_0)) begin
                mux_mem_dout_sel = MUX_MEM_DOUT_SEL_REG_PC_LO;
            end
            else begin
                casez ({ reg_op_prefix, reg_instr })
                    { OP_PREFIX_NONE, 8'b11??0101 }, // PUSH qq
                    { OP_PREFIX_DD,   8'b00110110 }, // LD (IX + d),n
                    { OP_PREFIX_DD,   8'b11100101 }, // PUSH IX
                    { OP_PREFIX_ED,   8'b0110?111 }, // (RLD|RRD)
                    { OP_PREFIX_FD,   8'b00110110 }, // LD (IY + d),n
                    { OP_PREFIX_FD,   8'b11100101 }: // PUSH IY
                    begin
                        mux_mem_dout_sel = MUX_MEM_DOUT_SEL_REG_MEM_DOUT_HI;
                    end
                    { OP_PREFIX_NONE, 8'b11???111 }: // RST p
                    begin
                        mux_mem_dout_sel = MUX_MEM_DOUT_SEL_REG_PC_HI;
                    end
                    default: begin
                        mux_mem_dout_sel = MUX_MEM_DOUT_SEL_REG_MEM_DOUT_LO;
                    end
                endcase
            end

            reg_mem_addr_we = 1'b1;
        end
        FSM_STATE_PRE_MEM_WRITE_2: begin
            mem_dout_en = 1'b1;

            mux_mem_addr_sel = MUX_MEM_ADDR_SEL_ALU_ADDR;

            if (int_active_nmi || (int_active_int && int_mode != INT_MODE_0)) begin
                mux_mem_dout_sel = MUX_MEM_DOUT_SEL_REG_PC_LO;
            end
            else begin
                casez ({ reg_op_prefix, reg_instr })
                    { OP_PREFIX_NONE, 8'b11??0101 }, // PUSH qq
                    { OP_PREFIX_DD,   8'b11100101 }, // PUSH IX
                    { OP_PREFIX_FD,   8'b11100101 }: // PUSH IY
                    begin
                        mux_mem_dout_sel = MUX_MEM_DOUT_SEL_REG_MEM_DOUT_LO;
                    end
                    { OP_PREFIX_NONE, 8'b11???100 }, // CALL cc,nn
                    { OP_PREFIX_NONE, 8'b11001101 }, // CALL nn
                    { OP_PREFIX_NONE, 8'b11???111 }: // RST p
                    begin
                        mux_mem_dout_sel = MUX_MEM_DOUT_SEL_REG_PC_LO;
                    end
                    default: begin
                        mux_mem_dout_sel = MUX_MEM_DOUT_SEL_REG_MEM_DOUT_HI;
                    end
                endcase
            end

            reg_mem_addr_we  = 1'b1;
        end
        FSM_STATE_BLOCK_TRANSFER: begin
            // (CPIR|CPDR)
            if (!regfile_bc_zero && !regfile_flag_z) begin
                alu_mode         = ALU_MODE_SUB;
                mux_alu_op_a_sel = MUX_ALU_OP_A_SEL_REG_PC;
                mux_alu_op_b_sel = MUX_ALU_OP_B_SEL_CONST2;
                mux_int_bus_sel  = MUX_INT_BUS_SEL_ALU_OUT;
                reg_pc_we        = 1'b1;
            end
        end
    endcase
end

endmodule
