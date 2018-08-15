case(state)

    // ...

    FSM_STATE_INSTR_FETCH2_3: begin
        casez ({ reg_op_prefix, reg_instr })
            { OP_PREFIX_DD, 8'b00100001 }, // LD IX,nn
            { OP_PREFIX_DD, 8'b00100010 }, // LD (nn),IX
            { OP_PREFIX_DD, 8'b00101010 }, // LD IX,(nn)
            { OP_PREFIX_DD, 8'b00110100 }, // INC (IX + d)
            { OP_PREFIX_DD, 8'b00110101 }, // DEC (IX + d)
            { OP_PREFIX_DD, 8'b00110110 }, // LD (IX + d),n
            { OP_PREFIX_DD, 8'b01110??? }, // LD (IX + d),r
            { OP_PREFIX_DD, 8'b01???110 }, // LD r,(IX + d)
            { OP_PREFIX_DD, 8'b10???110 }, // ALUOP [A,](IX + d)
            { OP_PREFIX_DD, 8'b11001011 }, // (ROT|SHIFT|BIT) (IX + d)
            { OP_PREFIX_ED, 8'b01??0011 }, // LD (nn),dd
            { OP_PREFIX_ED, 8'b01??1011 }, // LD dd,(nn)
            { OP_PREFIX_FD, 8'b00100001 }, // LD IY,nn
            { OP_PREFIX_FD, 8'b00100010 }, // LD (nn),IY
            { OP_PREFIX_FD, 8'b00101010 }, // LD IY,(nn)
            { OP_PREFIX_FD, 8'b00110100 }, // INC (IY + d)
            { OP_PREFIX_FD, 8'b00110101 }, // DEC (IY + d)
            { OP_PREFIX_FD, 8'b00110110 }, // LD (IY + d),n
            { OP_PREFIX_FD, 8'b01110??? }, // LD (IY + d),r
            { OP_PREFIX_FD, 8'b01???110 }, // LD r,(IY + d)
            { OP_PREFIX_FD, 8'b10???110 }, // ALUOP [A,](IY + d)
            { OP_PREFIX_FD, 8'b11001011 }: // (ROT|SHIFT|BIT) (IY + d)
            begin
                state_next   = FSM_STATE_OP_FETCH1_1;
                int_suppress = 1'b1;
            end

            // ...

            default: begin
                state_next = FSM_STATE_INSTR_FETCH1_1;
            end

    // ...
