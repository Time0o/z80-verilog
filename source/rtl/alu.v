`timescale 1ns/10ps

`include "buswidth.vh"

module alu (
    input [`ALU_MODE_WIDTH-1:0] mode,
    input [15:0] op_a,
    input [15:0] op_b,
    input [5:0] flags_in,
    input iff2,
    input [2:0] bitselect,
    output reg [15:0] data_out,
    output reg [5:0] flags_out
);

`include "alu.vh"
`include "flags.vh"

reg [15:0] a, b;
reg sub, carry;
reg cin, cin0, cout3, cin7, cout7, cout11, cin15, cout15;

reg [15:0] daa_tmp;

always @* begin
    a = op_a;
    b = op_b;

    case (mode)
        ALU_MODE_SUB,
        ALU_MODE_SBC,
        ALU_MODE_SBC_16BIT,
        ALU_MODE_CP,
        ALU_MODE_CPB: begin
            b = ~op_b;
        end
        ALU_MODE_INC: begin
            b = 16'h0001;
        end
        ALU_MODE_DEC,
        ALU_MODE_INI: begin
            b = 16'hFFFF;
        end
        ALU_MODE_NEG: begin
            a = 16'h00;
            b = ~op_b;
        end
        default: begin
            a = op_a;
            b = op_b;
        end
    endcase

    daa_tmp = op_a;
    data_out = op_a;

    flags_out[FLAG_IDX_S]  = flags_in[FLAG_IDX_S];
    flags_out[FLAG_IDX_Z]  = flags_in[FLAG_IDX_Z];
    flags_out[FLAG_IDX_H]  = flags_in[FLAG_IDX_H];
    flags_out[FLAG_IDX_PV] = flags_in[FLAG_IDX_PV];
    flags_out[FLAG_IDX_N]  = flags_in[FLAG_IDX_N];
    flags_out[FLAG_IDX_C]  = flags_in[FLAG_IDX_C];

    sub = ((mode == ALU_MODE_SUB)       || (mode == ALU_MODE_SBC) ||
           (mode == ALU_MODE_SBC_16BIT) || (mode == ALU_MODE_CP)  ||
           (mode == ALU_MODE_NEG)       || (mode == ALU_MODE_CPB));

    carry = ((mode == ALU_MODE_ADC) || (mode == ALU_MODE_ADC_16BIT) ||
             (mode == ALU_MODE_SBC) || (mode == ALU_MODE_SBC_16BIT));

    cin    = flags_in[FLAG_IDX_C];
    cin0   = sub ^ (carry && cin);
    cout3  = 1'b0;
    cin7   = 1'b0;
    cout7  = 1'b0;
    cout11 = 1'b0;
    cin15  = 1'b0;
    cout15 = 1'b0;

    // perform calculations
    case (mode)
        // arithmetic operations
        default: begin
            { cout3, data_out[3:0] } =
                { 1'b0, a[3:0] } + { 1'b0, b[3:0] } + { 4'b0000, cin0 };

            { cin7, data_out[6:4] } =
                { 1'b0, a[6:4] } + { 1'b0, b[6:4] } + { 3'b000, cout3 };

            data_out[7] = (a[7] ^ b[7]) ^ cin7;
            cout7 = (cin7 & (a[7] ^ b[7])) | (a[7] & b[7]);

            { cout11, data_out[11:8] } =
                { 1'b0, a[11:8] } + { 1'b0, b[11:8] } + { 4'b0000, cout7 };

            { cin15, data_out[14:12] } =
                { 1'b0, a[14:12] } + { 1'b0, b[14:12] } + { 3'b000, cout11 };

            data_out[15] = (a[15] ^ b[15]) ^ cin15;
            cout15 = (cin15 & (a[15] ^ b[15])) | (a[15] & b[15]);
        end

        // logical operations
        ALU_MODE_AND:
            data_out = a & b;
        ALU_MODE_OR:
            data_out = a | b;
        ALU_MODE_XOR:
            data_out = a ^ b;

        // rotate and shift
        ALU_MODE_RLCA,
        ALU_MODE_RLC:
            data_out = { a[6:0], a[7] };
        ALU_MODE_RLA,
        ALU_MODE_RL:
            data_out = { a[6:0], cin };
        ALU_MODE_RRCA,
        ALU_MODE_RRC:
            data_out = { a[0], a[7:1] };
        ALU_MODE_RRA,
        ALU_MODE_RR:
            data_out = { cin, a[7:1] };
        ALU_MODE_SLA:
            data_out = { a[6:0], 1'b0 };
        ALU_MODE_SRA:
            data_out = { a[7], a[7:1] };
        ALU_MODE_SRL:
            data_out = { 1'b0, a[7:1] };

        // bit set, reset and test
        ALU_MODE_SET: begin
            case (bitselect)
                3'b000: data_out = a | 16'h0001;
                3'b001: data_out = a | 16'h0002;
                3'b010: data_out = a | 16'h0004;
                3'b011: data_out = a | 16'h0008;
                3'b100: data_out = a | 16'h0010;
                3'b101: data_out = a | 16'h0020;
                3'b110: data_out = a | 16'h0040;
                3'b111: data_out = a | 16'h0080;
            endcase
        end
        ALU_MODE_RES: begin
            case (bitselect)
                3'b000: data_out = a & ~16'h0001;
                3'b001: data_out = a & ~16'h0002;
                3'b010: data_out = a & ~16'h0004;
                3'b011: data_out = a & ~16'h0008;
                3'b100: data_out = a & ~16'h0010;
                3'b101: data_out = a & ~16'h0020;
                3'b110: data_out = a & ~16'h0040;
                3'b111: data_out = a & ~16'h0080;
            endcase
        end

        // special cases
        ALU_MODE_CPL:
            data_out = a ^ 16'hFFFF;
        ALU_MODE_RLD:
            data_out = { b[3:0], a[3:0], a[7:4], b[7:4] };
        ALU_MODE_RRD:
            data_out = { a[3:0], b[7:4], a[7:4], b[3:0] };
        ALU_MODE_DAA: begin
            if (flags_in[FLAG_IDX_N]) begin
                if (a[3:0] > 4'h9 || flags_in[FLAG_IDX_H]) begin
                    flags_out[FLAG_IDX_H] = (a[3:0] < 4'h6);
                    daa_tmp = a + 16'hfffa;
                end
                else begin
                    daa_tmp = a;
                end

                if (daa_tmp[7:4] > 4'h9 || flags_in[FLAG_IDX_C]) begin
                    data_out = daa_tmp + 16'hffa0;

                    if (daa_tmp[15] || daa_tmp[7:0] < 8'h60)
                        flags_out[FLAG_IDX_C] = 1'b1;
                end
                else begin
                    data_out = daa_tmp;
                end
            end
            else begin
                if (a[3:0] > 4'h9 || flags_in[FLAG_IDX_H]) begin
                    flags_out[FLAG_IDX_H] = (a[3:0] > 4'h9);
                    daa_tmp = a + 16'h0006;
                end
                else begin
                    daa_tmp = a;
                end

                if (daa_tmp[7:4] > 4'h9 || flags_in[FLAG_IDX_C]) begin
                    data_out = daa_tmp + 16'h0060;

                    if (daa_tmp[8] || daa_tmp[7:4] > 4'h9)
                        flags_out[FLAG_IDX_C] = 1'b1;
                end
                else begin
                    data_out = daa_tmp;
                end
            end
        end
    endcase

    // update flags
    case (mode)
        // arithmetic operations
        default: begin
            flags_out[FLAG_IDX_S]  = data_out[7];
            flags_out[FLAG_IDX_Z]  = ~|data_out[7:0];
            flags_out[FLAG_IDX_H]  = cout3;
            flags_out[FLAG_IDX_PV] = cin7 ^ cout7;
            flags_out[FLAG_IDX_N]  = 1'b0;
            flags_out[FLAG_IDX_C]  = cout7;
        end
        ALU_MODE_INC: begin
            flags_out[FLAG_IDX_S]  = data_out[7];
            flags_out[FLAG_IDX_Z]  = ~|data_out[7:0];
            flags_out[FLAG_IDX_H]  = cout3;
            flags_out[FLAG_IDX_PV] = cin7 ^ cout7;
            flags_out[FLAG_IDX_N]  = 1'b0;
        end
        ALU_MODE_SUB,
        ALU_MODE_CP,
        ALU_MODE_NEG,
        ALU_MODE_SBC: begin
            flags_out[FLAG_IDX_S]  = data_out[7];
            flags_out[FLAG_IDX_Z]  = ~|data_out[7:0];
            flags_out[FLAG_IDX_H]  = ~cout3;
            flags_out[FLAG_IDX_PV] = cin7 ^ cout7;
            flags_out[FLAG_IDX_N]  = 1'b1;
            flags_out[FLAG_IDX_C]  = ~cout7;
        end
        ALU_MODE_DEC: begin
            flags_out[FLAG_IDX_S]  = data_out[7];
            flags_out[FLAG_IDX_Z]  = ~|data_out[7:0];
            flags_out[FLAG_IDX_H]  = (a[3:0] == 4'h0);
            flags_out[FLAG_IDX_PV] = cin7 ^ cout7;
            flags_out[FLAG_IDX_N]  = 1'b1;
        end

        // 16-bit arithmetic operations
        ALU_MODE_ADD_16BIT: begin
            flags_out[FLAG_IDX_H] = cout11;
            flags_out[FLAG_IDX_N] = 1'b0;
            flags_out[FLAG_IDX_C] = cout15;
        end
        ALU_MODE_ADC_16BIT: begin
            flags_out[FLAG_IDX_S]  = data_out[15];
            flags_out[FLAG_IDX_Z]  = ~|data_out;
            flags_out[FLAG_IDX_H]  = cout11;
            flags_out[FLAG_IDX_PV] = cin15 ^ cout15;
            flags_out[FLAG_IDX_N]  = 1'b0;
            flags_out[FLAG_IDX_C]  = cout15;
        end
        ALU_MODE_SBC_16BIT: begin
            flags_out[FLAG_IDX_S]  = data_out[15];
            flags_out[FLAG_IDX_Z]  = ~|data_out;
            flags_out[FLAG_IDX_H]  = ~cout11;
            flags_out[FLAG_IDX_PV] = cin15 ^ cout15;
            flags_out[FLAG_IDX_N]  = 1'b1;
            flags_out[FLAG_IDX_C]  = ~cout15;
        end

        // logical operations
        ALU_MODE_AND: begin
            flags_out[FLAG_IDX_S]  = data_out[7];
            flags_out[FLAG_IDX_Z]  = ~|data_out[7:0];
            flags_out[FLAG_IDX_H]  = 1'b1;
            flags_out[FLAG_IDX_PV] = ~^data_out[7:0];
            flags_out[FLAG_IDX_N]  = 1'b0;
            flags_out[FLAG_IDX_C]  = 1'b0;
        end
        ALU_MODE_OR,
        ALU_MODE_XOR: begin
            flags_out[FLAG_IDX_S]  = data_out[7];
            flags_out[FLAG_IDX_Z]  = ~|data_out[7:0];
            flags_out[FLAG_IDX_H]  = 1'b0;
            flags_out[FLAG_IDX_PV] = ~^data_out[7:0];
            flags_out[FLAG_IDX_N]  = 1'b0;
            flags_out[FLAG_IDX_C]  = 1'b0;
        end

        // rotate and shift
        ALU_MODE_RLCA,
        ALU_MODE_RLA: begin
            flags_out[FLAG_IDX_H] = 1'b0;
            flags_out[FLAG_IDX_N] = 1'b0;
            flags_out[FLAG_IDX_C] = a[7];
        end
        ALU_MODE_RRCA,
        ALU_MODE_RRA: begin
            flags_out[FLAG_IDX_H] = 1'b0;
            flags_out[FLAG_IDX_N] = 1'b0;
            flags_out[FLAG_IDX_C] = a[0];
        end
        ALU_MODE_RLC,
        ALU_MODE_RL,
        ALU_MODE_SLA: begin
            flags_out[FLAG_IDX_S]  = data_out[7];
            flags_out[FLAG_IDX_Z]  = ~|data_out[7:0];
            flags_out[FLAG_IDX_H]  = 1'b0;
            flags_out[FLAG_IDX_PV] = ~^data_out[7:0];
            flags_out[FLAG_IDX_N]  = 1'b0;
            flags_out[FLAG_IDX_C]  = a[7];
        end
        ALU_MODE_RRC,
        ALU_MODE_RR,
        ALU_MODE_SRA,
        ALU_MODE_SRL: begin
            flags_out[FLAG_IDX_S]  = data_out[7];
            flags_out[FLAG_IDX_Z]  = ~|data_out[7:0];
            flags_out[FLAG_IDX_H]  = 1'b0;
            flags_out[FLAG_IDX_PV] = ~^data_out[7:0];
            flags_out[FLAG_IDX_N]  = 1'b0;
            flags_out[FLAG_IDX_C]  = a[0];
        end

        // bit set, reset and test
        ALU_MODE_BIT: begin
            flags_out[FLAG_IDX_Z] = (a[{ 1'b0, bitselect }] == 1'b0);
            flags_out[FLAG_IDX_H] = 1'b1;
            flags_out[FLAG_IDX_N] = 1'b0;
        end

        // special cases
        ALU_MODE_DAA: begin
            flags_out[FLAG_IDX_S] = data_out[7];
            flags_out[FLAG_IDX_Z] = ~|data_out[7:0];
            flags_out[FLAG_IDX_PV] = ~^data_out[7:0];
        end
        ALU_MODE_LDAI: begin
            flags_out[FLAG_IDX_S]  = a[7];
            flags_out[FLAG_IDX_Z]  = ~|a[7:0];
            flags_out[FLAG_IDX_H]  = 1'b0;
            flags_out[FLAG_IDX_PV] = iff2;
            flags_out[FLAG_IDX_N]  = 1'b0;
        end
        ALU_MODE_CPB: begin
            flags_out[FLAG_IDX_S] = data_out[7];
            flags_out[FLAG_IDX_Z] = ~|data_out[7:0];
            flags_out[FLAG_IDX_H] = ~cout3;
            flags_out[FLAG_IDX_N] = 1'b1;
        end
        ALU_MODE_CPL: begin
            flags_out[FLAG_IDX_H] = 1'b1;
            flags_out[FLAG_IDX_N] = 1'b1;
        end
        ALU_MODE_CCF: begin
            flags_out[FLAG_IDX_H] = flags_in[FLAG_IDX_C];
            flags_out[FLAG_IDX_N] = 1'b0;
            flags_out[FLAG_IDX_C] = ~flags_in[FLAG_IDX_C];
        end
        ALU_MODE_SCF: begin
            flags_out[FLAG_IDX_H] = 1'b0;
            flags_out[FLAG_IDX_N] = 1'b0;
            flags_out[FLAG_IDX_C] = 1'b1;
        end
        ALU_MODE_RLD,
        ALU_MODE_RRD: begin
            flags_out[FLAG_IDX_S]  = data_out[7];
            flags_out[FLAG_IDX_Z]  = ~|data_out[7:0];
            flags_out[FLAG_IDX_H]  = 1'b0;
            flags_out[FLAG_IDX_PV] = ~^data_out[7:0];
            flags_out[FLAG_IDX_N]  = 1'b0;
        end
        ALU_MODE_IN: begin
            flags_out[FLAG_IDX_S]  = a[7];
            flags_out[FLAG_IDX_Z]  = ~|a[7:0];
            flags_out[FLAG_IDX_H]  = 1'b0;
            flags_out[FLAG_IDX_PV] = ~^a[7:0];
            flags_out[FLAG_IDX_N]  = 1'b0;
        end
        ALU_MODE_INI: begin
            flags_out[FLAG_IDX_Z] = ~|data_out;
            flags_out[FLAG_IDX_N] = 1'b1;
        end
    endcase
end

endmodule
