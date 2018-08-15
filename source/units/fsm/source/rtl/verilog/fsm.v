`timescale 1ns/10ps

`include "buswidth.vh"

module fsm (
	input clk,
	input n_reset,
	input ipram_loaded,
	input int_disable,
	input int_enable,
	input int_mode_change,
	input [`INT_MODE_WIDTH-1:0] int_mode_next,
	input int_request_int,
	input int_request_nmi,
	input int_restore,
	input [7:0] reg_instr,
	input [`OP_PREFIX_WIDTH-1:0] reg_op_prefix,
	input regfile_flag_s,
	input regfile_flag_z,
	input regfile_flag_pv,
	input regfile_flag_c,
	output reg halt_n_halt,
	output reg halt_n_halt_we,
	output reg int_active_int,
	output reg int_active_nmi,
	output reg int_iff2,
	output reg int_sampled_int,
	output reg int_sampled_nmi,
	output reg [`INT_MODE_WIDTH-1:0] int_mode,
	output reg [`FSM_STATE_WIDTH-1:0] state
);

`include "fsm.vh"
`include "interrupt.vh"
`include "opcode.vh"

reg int_done;
reg int_enable_buf;
reg int_iff1;
reg int_sample;
reg int_suppress;

reg cond;
reg [`FSM_STATE_WIDTH-1:0] state_next;

// Sequential Logic ==========================================================

always @(posedge clk or negedge n_reset) begin
	if (n_reset == 1'b0) begin
		state <= FSM_STATE_IDLE;

		int_active_int  <= 1'b0;
		int_active_nmi  <= 1'b0;
		int_enable_buf  <= 1'b0;
		int_iff1        <= 1'b0;
		int_iff2        <= 1'b0;
		int_mode        <= INT_MODE_0;
		int_sampled_int <= 1'b0;
		int_sampled_nmi <= 1'b0;
	end
	else begin
		if (int_sample) begin
			state <= state_next;

			// Sample interrupt lines.
			if (int_request_nmi) begin
				int_sampled_nmi <= 1'b1;
			end
			else if (int_iff1 && !int_enable_buf && int_request_int) begin
				int_sampled_int <= 1'b1;
			end

			// Re-allow interrupts two instructions after an interrupt enable.
			if (int_enable_buf)
				int_enable_buf <= 1'b0;
		end
		else begin
			// Determine next state.
			if (!int_suppress && int_sampled_nmi) begin
				state <= FSM_STATE_ACK_NMI_1;

				int_active_nmi <= 1'b1;
			end
			else if (!int_suppress && !int_disable && !int_enable &&
			         int_sampled_int) begin

				state <= FSM_STATE_ACK_INT_1;

				int_active_int <= 1'b1;
			end
			else begin
				state <= state_next;

				if (int_done) begin
					int_active_int <= 1'b0;
					int_active_nmi <= 1'b0;
				end
			end

			// Update interrupt control flip-flops.
			if (int_disable) begin
				int_iff1 <= 1'b0;
				int_iff2 <= 1'b0;
			end
			else if (int_enable) begin
				int_iff1 <= 1'b1;
				int_iff2 <= 1'b1;
			end
			else if (int_restore) begin
				if (!int_suppress && int_sampled_nmi)
					int_iff1 <= 1'b0;
				else
					int_iff1 <= int_iff2;
			end
			else if (!int_suppress && int_sampled_nmi) begin
				int_iff2 <= int_iff1;
				int_iff1 <= 1'b0;
			end

			// Remember interrupt enable during the following instruction.
			if (int_enable)
				int_enable_buf <= 1'b1;

			// Update interrupt mode.
			if (int_mode_change) begin
				int_mode <= int_mode_next;
			end

			// Reset interrupt sample flip-flops.
			int_sampled_int <= 1'b0;
			int_sampled_nmi <= 1'b0;
		end
	end
end

// Combinational Logic =======================================================

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
end

always @* begin
	halt_n_halt    = 1'b1;
	halt_n_halt_we = 1'b0;
	int_done       = 1'b0;
	int_sample     = 1'b0;
	int_suppress   = 1'b0;
	state_next     = FSM_STATE_IDLE;

	case (state)
		FSM_STATE_IDLE: begin
		    if (ipram_loaded == 1'b1) begin
				state_next = FSM_STATE_INSTR_FETCH1_1;
			end else begin
				state_next = FSM_STATE_IDLE;
			end
		end
		FSM_STATE_INSTR_FETCH1_1: begin
			state_next = FSM_STATE_INSTR_FETCH1_2;
		end
		FSM_STATE_INSTR_FETCH1_2: begin
			state_next = FSM_STATE_INSTR_FETCH1_3;
			int_sample = 1'b1;
		end
		FSM_STATE_INSTR_FETCH1_3: begin
			casez (reg_instr)
				8'hDD, 8'hFD, 8'hED, 8'hCB: // Prefixes
				begin
					state_next   = FSM_STATE_INSTR_FETCH2_1;
					int_suppress = 1'b1;
				end
				8'b01110110: // HALT
				begin
					state_next     = FSM_STATE_INSTR_FETCH1_1;
					halt_n_halt    = int_sampled_int;
					halt_n_halt_we = 1'b1;
				end
				8'b00101010, // LD HL,(nn)
				8'b00100010, // LD (nn),HL
				8'b00110010, // LD (nn),A
				8'b00110110, // LD (HL),n
				8'b00111010, // LD A,(nn)
				8'b00???110, // LD r,n
				8'b00??0001, // LD dd,nn
				8'b11???110, // ALUOP [A,]n
				8'b11000011, // JP nn
				8'b11???010, // JP cc,nn
				8'b00011000, // JR e
				8'b00111000, // JR C,e
				8'b00110000, // JR NC,e
				8'b00101000, // JR Z,e
				8'b00100000, // JR NZ,e
				8'b00010000, // DJNZ e
				8'b11001101, // CALL nn
				8'b11011011, // IN A,(n)
				8'b11010011: // OUT (n),A
				begin
					state_next   = FSM_STATE_OP_FETCH1_1;
					int_suppress = 1'b1;
				end
				8'b11??0001, // POP qq
				8'b000?1010, // LD A,((BC)|(DE))
				8'b11100011, // EX (SP),HL
				8'b0011010?, // (INC|DEC) (HL)
				8'b01???110, // LD r,(HL)
				8'b10???110, // ALUOP [A,](HL)
				8'b11001001: // RET
				begin
					state_next   = FSM_STATE_MEM_READ1_1;
					int_suppress = 1'b1;
				end
				8'b11??0101, // PUSH qq
				8'b11???111: // RST p
				begin
					state_next   = FSM_STATE_PRE_MEM_WRITE_1;
					int_suppress = 1'b1;
				end
				8'b000?0010, // LD ((BC)|(DE)),A
				8'b01110???: // LD (HL),r
				begin
					state_next   = FSM_STATE_MEM_WRITE1_1;
					int_suppress = 1'b1;
				end
				8'b11???100: // CALL cc,nn
				begin
					if (cond) begin
						state_next   = FSM_STATE_OP_FETCH1_1;
						int_suppress = 1'b1;
					end
					else begin
						state_next = FSM_STATE_PRE_INSTR_FETCH_1;
					end
				end
				8'b11???000: // RET cc
				begin
					if (cond) begin
						state_next   = FSM_STATE_MEM_READ1_1;
						int_suppress = 1'b1;
					end
					else begin
						state_next = FSM_STATE_INSTR_FETCH1_1;
					end
				end
				default: begin
					state_next = FSM_STATE_INSTR_FETCH1_1;
				end
			endcase
		end
		FSM_STATE_INSTR_FETCH2_1: begin
			state_next = FSM_STATE_INSTR_FETCH2_2;
		end
		FSM_STATE_INSTR_FETCH2_2: begin
			state_next = FSM_STATE_INSTR_FETCH2_3;
			int_sample = 1'b1;
		end
		FSM_STATE_INSTR_FETCH2_3: begin
			casez ({ reg_op_prefix, reg_instr })
				{ OP_PREFIX_DD, 8'b00100001 }, // LD IX,nn
				{ OP_PREFIX_DD, 8'b00100010 }, // LD (nn),IX
				{ OP_PREFIX_DD, 8'b00101010 }, // LD IX,(nn)
				{ OP_PREFIX_DD, 8'b0011010? }, // (INC|DEC) (IX + d)
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
				{ OP_PREFIX_FD, 8'b0011010? }, // (INC|DEC) (IY + d)
				{ OP_PREFIX_FD, 8'b00110110 }, // LD (IY + d),n
				{ OP_PREFIX_FD, 8'b01110??? }, // LD (IY + d),r
				{ OP_PREFIX_FD, 8'b01???110 }, // LD r,(IY + d)
				{ OP_PREFIX_FD, 8'b10???110 }, // ALUOP [A,](IY + d)
				{ OP_PREFIX_FD, 8'b11001011 }: // (ROT|SHIFT|BIT) (IY + d)
				begin
					state_next   = FSM_STATE_OP_FETCH1_1;
					int_suppress = 1'b1;
				end
				{ OP_PREFIX_CB,   8'b?????110 }, // (ROT|SHIFT|BIT) (HL)
				{ OP_PREFIX_DD,   8'b11100011 }, // EX (SP),IX
				{ OP_PREFIX_DD,   8'b11100001 }, // POP IX
				{ OP_PREFIX_ED,   8'b101??000 }, // (LDI|LDIR|LDD|LDDR)
				{ OP_PREFIX_ED,   8'b101??001 }, // (CPI|CPIR|CPD|CPDR)
				{ OP_PREFIX_ED,   8'b0110?111 }, // (RLD|RRD)
				{ OP_PREFIX_ED,   8'b0100?101 }, // (RETI|RETN)
				{ OP_PREFIX_FD,   8'b11100011 }, // EX (SP),IY
				{ OP_PREFIX_ED,   8'b101??011 }, // (OUTI|OUTR|OUTD|OUTDR)
				{ OP_PREFIX_FD,   8'b11100001 }: // POP IY
				begin
					state_next   = FSM_STATE_MEM_READ1_1;
					int_suppress = 1'b1;
				end
				{ OP_PREFIX_DD, 8'b11100101 }, // PUSH IX
				{ OP_PREFIX_FD, 8'b11100101 }: // PUSH IY
				begin
					state_next   = FSM_STATE_PRE_MEM_WRITE_1;
					int_suppress = 1'b1;
				end
				{ OP_PREFIX_ED, 8'b01???000 }, // IN r,(C)
				{ OP_PREFIX_ED, 8'b101??010 }: // (INI|INIR|IND|INDR)
				begin
					state_next   = FSM_STATE_IO_READ_1;
					int_suppress = 1'b1;
				end
				{ OP_PREFIX_ED, 8'b01???001 }: // OUT (C),r
				begin
					state_next   = FSM_STATE_IO_WRITE_1;
					int_suppress = 1'b1;
				end
				default: begin
					state_next = FSM_STATE_INSTR_FETCH1_1;
				end
			endcase
		end
		FSM_STATE_INSTR_FETCH3_1: begin
			state_next = FSM_STATE_INSTR_FETCH3_2;
		end
		FSM_STATE_INSTR_FETCH3_2: begin
			state_next = FSM_STATE_INSTR_FETCH3_3;
			int_sample = 1'b1;
		end
		FSM_STATE_INSTR_FETCH3_3: begin
			state_next   = FSM_STATE_PRE_MEM_READ_1;
			int_suppress = 1'b1;
		end
		FSM_STATE_OP_FETCH1_1: begin
			state_next = FSM_STATE_OP_FETCH1_2;
		end
		FSM_STATE_OP_FETCH1_2: begin
			state_next = FSM_STATE_OP_FETCH1_3;

			casez ({ reg_op_prefix, reg_instr })
				{ OP_PREFIX_NONE,  8'b00100010 }, // LD (nn),HL
				{ OP_PREFIX_NONE,  8'b00101010 }, // LD HL,(nn)
				{ OP_PREFIX_NONE,  8'b00110010 }, // LD (nn),A
				{ OP_PREFIX_NONE,  8'b00110110 }, // LD (HL),n
				{ OP_PREFIX_NONE,  8'b00111010 }, // LD A,(nn)
				{ OP_PREFIX_NONE,  8'b11000011 }, // JP nn
				{ OP_PREFIX_NONE,  8'b11001101 }, // CALL nn
				{ OP_PREFIX_NONE,  8'b11010011 }, // OUT (n),A
				{ OP_PREFIX_NONE,  8'b11011011 }, // IN A,(n)
				{ OP_PREFIX_NONE,  8'b11???010 }, // JP cc,nn
				{ OP_PREFIX_NONE,  8'b11???100 }, // CALL cc,nn
				{ OP_PREFIX_CB,    8'b00???110 }, // (ROT|SHIFT|BIT) (HL)
				{ OP_PREFIX_DD,    8'b00100010 }, // LD (nn),IX
				{ OP_PREFIX_DD,    8'b00100001 }, // LD IX,nn
				{ OP_PREFIX_DD,    8'b00101010 }, // LD IX,(nn)
				{ OP_PREFIX_DD,    8'b0011010? }, // (INC|DEC) (IX + d)
				{ OP_PREFIX_DD,    8'b00110110 }, // LD (IX + d),n
				{ OP_PREFIX_DD,    8'b01110??? }, // LD (IX + d),r
				{ OP_PREFIX_DD,    8'b01???110 }, // LD r,(IX + d)
				{ OP_PREFIX_DD,    8'b10???110 }, // ALUOP [A,](IX + d)
				{ OP_PREFIX_ED,    8'b01??0011 }, // LD (nn),dd
				{ OP_PREFIX_ED,    8'b01??1011 }, // LD dd,(nn)
				{ OP_PREFIX_FD,    8'b00100001 }, // LD IY,nn
				{ OP_PREFIX_FD,    8'b00100010 }, // LD (nn),IY
				{ OP_PREFIX_FD,    8'b00101010 }, // LD IY,(nn)
				{ OP_PREFIX_FD,    8'b0011010? }, // (INC|DEC) (IY + d)
				{ OP_PREFIX_FD,    8'b00110110 }, // LD (IY + d),n
				{ OP_PREFIX_FD,    8'b01110??? }, // LD (IY + d),r
				{ OP_PREFIX_FD,    8'b01???110 }, // LD r,(IY + d)
				{ OP_PREFIX_FD,    8'b10???110 }, // ALUOP [A,](IY + d)
				{ OP_PREFIX_DD_CB, 8'b?????110 }, // (ROT|SHIFT|BIT) (IX + d)
				{ OP_PREFIX_FD_CB, 8'b?????110 }: // (ROT|SHIFT|BIT) (IY + d)
				begin
					int_sample = 1'b0;
				end
				default: begin
					int_sample = 1'b1;
				end
			endcase
		end
		FSM_STATE_OP_FETCH1_3: begin
			casez ({ reg_op_prefix, reg_instr })
				{ OP_PREFIX_DD_CB, 8'b???????? }, // (ROT|SHIFT|BIT) (IX + d)
				{ OP_PREFIX_FD_CB, 8'b???????? }: // (ROT|SHIFT|BIT) (IX + d)
				begin
					state_next = FSM_STATE_INSTR_FETCH3_1;
				end
				{ OP_PREFIX_NONE, 8'b00100010 }, // LD (nn),HL
				{ OP_PREFIX_NONE, 8'b00101010 }, // LD HL,(nn)
				{ OP_PREFIX_NONE, 8'b00110010 }, // LD (nn),A
				{ OP_PREFIX_NONE, 8'b00111010 }, // LD A,(nn)
				{ OP_PREFIX_NONE, 8'b00??0001 }, // LD dd,nn
				{ OP_PREFIX_NONE, 8'b11000011 }, // JP nn
				{ OP_PREFIX_NONE, 8'b11001101 }, // CALL nn
				{ OP_PREFIX_NONE, 8'b11???010 }, // JP cc,nn
				{ OP_PREFIX_NONE, 8'b11???100 }, // CALL cc,nn
				{ OP_PREFIX_DD,   8'b00100001 }, // LD IX,nn
				{ OP_PREFIX_DD,   8'b00100010 }, // LD (nn),IX
				{ OP_PREFIX_DD,   8'b00101010 }, // LD IX,(nn)
				{ OP_PREFIX_DD,   8'b00110110 }, // LD (IX + d),n
				{ OP_PREFIX_ED,   8'b01??0011 }, // LD (nn),dd
				{ OP_PREFIX_ED,   8'b01??1011 }, // LD dd,(nn)
				{ OP_PREFIX_FD,   8'b00100001 }, // LD IY,nn
				{ OP_PREFIX_FD,   8'b00100010 }, // LD (nn),IY
				{ OP_PREFIX_FD,   8'b00101010 }, // LD IY,(nn)
				{ OP_PREFIX_FD,   8'b00110110 }: // LD (IY + d),n
				begin
					state_next = FSM_STATE_OP_FETCH2_1;
				end
				{ OP_PREFIX_DD, 8'b01???110 }, // LD r,(IX + d)
				{ OP_PREFIX_DD, 8'b10???110 }, // ALUOP [A,](IX + d)
				{ OP_PREFIX_DD, 8'b0011010? }, // (INC|DEC) (IX + d)
				{ OP_PREFIX_FD, 8'b01???110 }, // LD r,(IY + d)
				{ OP_PREFIX_FD, 8'b10???110 }, // ALUOP [A,](IY + d)
				{ OP_PREFIX_FD, 8'b0011010? }: // (INC|DEC) (IY + d)
				begin
					state_next = FSM_STATE_PRE_MEM_READ_1;
				end
				{ OP_PREFIX_DD, 8'b01110??? }, // LD (IX + d),r
				{ OP_PREFIX_FD, 8'b01110??? }: // LD (IY + d),r
				begin
					state_next = FSM_STATE_PRE_MEM_WRITE_1;
				end
				{ OP_PREFIX_NONE, 8'b00110110 }: // LD (HL),n
				begin
					state_next = FSM_STATE_MEM_WRITE1_1;
				end
				{ OP_PREFIX_NONE, 8'b11011011 }: // IN A,(n)
				begin
					state_next = FSM_STATE_IO_READ_1;
				end
				{ OP_PREFIX_NONE, 8'b11010011 }: // OUT (n),A
				begin
					state_next = FSM_STATE_IO_WRITE_1;
				end
				default: begin
					state_next = FSM_STATE_INSTR_FETCH1_1;
				end
			endcase
		end
		FSM_STATE_OP_FETCH2_1: begin
			state_next = FSM_STATE_OP_FETCH2_2;
		end
		FSM_STATE_OP_FETCH2_2: begin
			state_next = FSM_STATE_OP_FETCH2_3;

			casez ({ reg_op_prefix, reg_instr })
				{ OP_PREFIX_NONE, 8'b00100010 }, // LD (nn),HL
				{ OP_PREFIX_NONE, 8'b00101010 }, // LD HL,(nn)
				{ OP_PREFIX_NONE, 8'b00110010 }, // LD (nn),A
				{ OP_PREFIX_NONE, 8'b00111010 }, // LD A,(nn)
				{ OP_PREFIX_NONE, 8'b11001101 }, // CALL nn
				{ OP_PREFIX_NONE, 8'b11???100 }, // CALL cc,nn
				{ OP_PREFIX_DD,   8'b00100010 }, // LD (nn),IX
				{ OP_PREFIX_DD,   8'b00101010 }, // LD IX,(nn)
				{ OP_PREFIX_DD,   8'b00110110 }, // LD (IX + d),n
				{ OP_PREFIX_ED,   8'b01??0011 }, // LD (nn),dd
				{ OP_PREFIX_ED,   8'b01??1011 }, // LD dd,(nn)
				{ OP_PREFIX_FD,   8'b00100010 }, // LD (nn),IY
				{ OP_PREFIX_FD,   8'b00101010 }, // LD IY,(nn)
				{ OP_PREFIX_FD,   8'b00110110 }: // LD (IY + d),n
				begin
					int_sample = 1'b0;
				end
				default: begin
					int_sample = 1'b1;
				end
			endcase
		end
		FSM_STATE_OP_FETCH2_3: begin
			casez ({ reg_op_prefix, reg_instr })
				{ OP_PREFIX_NONE, 8'b00101010 }, // LD HL,(nn)
				{ OP_PREFIX_NONE, 8'b00111010 }, // LD A,(nn)
				{ OP_PREFIX_DD,   8'b00101010 }, // LD IX,(nn)
				{ OP_PREFIX_ED,   8'b01??1011 }, // LD dd,(nn)
				{ OP_PREFIX_FD,   8'b00101010 }: // LD IY,(nn)
				begin
					state_next = FSM_STATE_MEM_READ1_1;
				end
				{ OP_PREFIX_DD, 8'b00110110 }, // LD (IX + d),n
				{ OP_PREFIX_FD, 8'b00110110 }: // LD (IY + d),n
				begin
					state_next = FSM_STATE_PRE_MEM_WRITE_1;
				end
				{ OP_PREFIX_NONE, 8'b00100010 }, // LD (nn),HL
				{ OP_PREFIX_NONE, 8'b00110010 }, // LD (nn),A
				{ OP_PREFIX_NONE, 8'b11001101 }, // CALL nn
				{ OP_PREFIX_NONE, 8'b11???100 }, // CALL cc,nn
				{ OP_PREFIX_DD,   8'b00100010 }, // LD (nn),IX
				{ OP_PREFIX_ED,   8'b01??0011 }, // LD (nn),dd
				{ OP_PREFIX_FD,   8'b00100010 }: // LD (nn),IY
				begin
					state_next = FSM_STATE_MEM_WRITE1_1;
				end
				default: begin
					state_next = FSM_STATE_INSTR_FETCH1_1;
				end
			endcase
		end
		FSM_STATE_MEM_READ1_1: begin
			state_next = FSM_STATE_MEM_READ1_2;
		end
		FSM_STATE_MEM_READ1_2: begin
			state_next = FSM_STATE_MEM_READ1_3;

			if (int_active_int && int_mode == INT_MODE_2) begin
				int_sample = 1'b0;
			end
			else begin
				casez ({ reg_op_prefix, reg_instr })
					{ OP_PREFIX_NONE,  8'b11??0001 }, // POP qq
					{ OP_PREFIX_NONE,  8'b00101010 }, // LD HL,(nn)
					{ OP_PREFIX_NONE,  8'b0011010? }, // (INC|DEC) (HL)
					{ OP_PREFIX_NONE,  8'b11001001 }, // RET
					{ OP_PREFIX_NONE,  8'b11100011 }, // EX (SP),HL
					{ OP_PREFIX_NONE,  8'b11???000 }, // RET cc
					{ OP_PREFIX_CB,    8'b00???110 }, // (ROT|SHIFT) (HL)
					{ OP_PREFIX_CB,    8'b1????110 }, // (SET|RES) b,(HL)
					{ OP_PREFIX_DD,    8'b00101010 }, // LD IX,(nn)
					{ OP_PREFIX_DD,    8'b11100001 }, // POP IX
					{ OP_PREFIX_DD,    8'b0011010? }, // (INC|DEC) (IX + d)
					{ OP_PREFIX_DD,    8'b11100011 }, // EX (SP),IX
					{ OP_PREFIX_ED,    8'b0100?101 }, // (RETN|RETI)
					{ OP_PREFIX_ED,    8'b0110?111 }, // (RLD|RRD)
					{ OP_PREFIX_ED,    8'b01??1011 }, // LD dd,(nn)
					{ OP_PREFIX_ED,    8'b101??000 }, // (LDI|LDD|LDIR|LDDR)
					{ OP_PREFIX_ED,    8'b1011?001 }, // (CPIR|CPDR)
					{ OP_PREFIX_FD,    8'b00101010 }, // LD IY,(nn)
					{ OP_PREFIX_FD,    8'b11100001 }, // POP IY
					{ OP_PREFIX_FD,    8'b0011010? }, // (INC|DEC) (IY + d)
					{ OP_PREFIX_FD,    8'b11100011 }, // EX (SP),IY
					{ OP_PREFIX_DD_CB, 8'b00???110 }, // (ROT|SHIFT) (IX + d)
					{ OP_PREFIX_DD_CB, 8'b1????110 }, // (SET|RES) (IX + d)
					{ OP_PREFIX_FD_CB, 8'b00???110 }, // (ROT|SHIFT) (IY + d)
					{ OP_PREFIX_FD_CB, 8'b1????110 }: // (SET|RES) (IY + d)
					begin
						int_sample = 1'b0;
					end
					default: begin
						int_sample = 1'b1;
					end
				endcase
			end
		end
		FSM_STATE_MEM_READ1_3: begin
			if (int_active_int && int_mode == INT_MODE_2) begin
				state_next = FSM_STATE_PRE_MEM_READ_2;
			end
			else begin
				casez ({ reg_op_prefix, reg_instr })
					{ OP_PREFIX_NONE, 8'b00101010 }, // LD HL,(nn)
					{ OP_PREFIX_NONE, 8'b11??0001 }, // POP qq
					{ OP_PREFIX_DD,   8'b00101010 }, // LD IX,(nn)
					{ OP_PREFIX_DD,   8'b11100001 }, // POP IX
					{ OP_PREFIX_ED,   8'b01??1011 }, // LD dd,(nn)
					{ OP_PREFIX_FD,   8'b00101010 }, // LD IY,(nn)
					{ OP_PREFIX_FD,   8'b11100001 }: // POP IY
					begin
						state_next = FSM_STATE_PRE_MEM_READ_2;
					end
					{ OP_PREFIX_NONE, 8'b11001001 }, // RET
					{ OP_PREFIX_NONE, 8'b11???000 }, // RET cc
					{ OP_PREFIX_ED,   8'b0100?101 }: // (RETN|RETI)
					begin
						state_next = FSM_STATE_MEM_READ2_1;
					end
					{ OP_PREFIX_NONE,  8'b0011010? }, // (INC|DEC) (HL)
					{ OP_PREFIX_CB,    8'b00???110 }, // (ROT|SHIFT) (HL)
					{ OP_PREFIX_CB,    8'b1????110 }, // (SET|RES) b,(HL)
					{ OP_PREFIX_DD,    8'b0011010? }, // (INC|DEC) (IX + d)
					{ OP_PREFIX_ED,    8'b0110?111 }, // (RLD|RRD)
					{ OP_PREFIX_FD,    8'b0011010? }, // (INC|DEC) (IY + d)
					{ OP_PREFIX_DD_CB, 8'b00???110 }, // (ROT|SHIFT) (IX + d)
					{ OP_PREFIX_DD_CB, 8'b1????110 }, // (SET|RES) (IX + d)
					{ OP_PREFIX_FD_CB, 8'b00???110 }, // (ROT|SHIFT) (IY + d)
					{ OP_PREFIX_FD_CB, 8'b1????110 }: // (SET|RES) (IY + d)
					begin
						state_next = FSM_STATE_PRE_MEM_WRITE_1;
					end
					{ OP_PREFIX_NONE, 8'b11100011 }, // EX (SP),HL
					{ OP_PREFIX_DD,   8'b11100011 }, // EX (SP),IX
					{ OP_PREFIX_ED,   8'b101??000 }, // (LDI|LDD|LDIR|LDDR)
					{ OP_PREFIX_FD,   8'b11100011 }: // EX (SP),IY
					begin
						state_next = FSM_STATE_MEM_WRITE1_1;
					end
					{ OP_PREFIX_ED, 8'b101??011 }: // (OUTI|OUTR|OUTD|OUTDR)
					begin
						state_next = FSM_STATE_IO_WRITE_1;
					end
					{ OP_PREFIX_ED, 8'b1011?001 }: // (CPIR|CPDR)
					begin
						state_next = FSM_STATE_BLOCK_TRANSFER;

						int_sample = 1'b1;
					end
					default: begin
						state_next = FSM_STATE_INSTR_FETCH1_1;
					end
				endcase
			end
		end
		FSM_STATE_MEM_READ2_1: begin
			state_next = FSM_STATE_MEM_READ2_2;
		end
		FSM_STATE_MEM_READ2_2: begin
			state_next = FSM_STATE_MEM_READ2_3;

			if (int_active_int && int_mode == INT_MODE_2) begin
				int_sample = 1'b1;
			end
			else begin
				case ({ reg_op_prefix, reg_instr })
					{ OP_PREFIX_NONE, 8'b11100011 }, // EX (SP),HL
					{ OP_PREFIX_DD,   8'b11100011 }, // EX (SP),IX
					{ OP_PREFIX_FD,   8'b11100011 }: // EX (SP),IY
					begin
						int_sample = 1'b0;
					end
					default: begin
						int_sample = 1'b1;
					end
				endcase
			end
		end
		FSM_STATE_MEM_READ2_3: begin
			if (int_active_int && int_mode == INT_MODE_2) begin
				state_next = FSM_STATE_INSTR_FETCH1_1;

				int_done = 1'b1;
			end
			else begin
				case ({ reg_op_prefix, reg_instr })
					{ OP_PREFIX_NONE, 8'b11100011 }, // EX (SP),HL
					{ OP_PREFIX_DD,   8'b11100011 }, // EX (SP),IX
					{ OP_PREFIX_FD,   8'b11100011 }: // EX (SP),IY
					begin
						state_next = FSM_STATE_MEM_WRITE2_1;
					end
					default: begin
						state_next = FSM_STATE_INSTR_FETCH1_1;
					end
				endcase
			end

			if (int_active_int && int_mode == INT_MODE_2)
				int_done = 1'b1;
		end
		FSM_STATE_MEM_WRITE1_1: begin
			state_next = FSM_STATE_MEM_WRITE1_2;
		end
		FSM_STATE_MEM_WRITE1_2: begin
			state_next = FSM_STATE_MEM_WRITE1_3;

			if (int_active_int || int_active_nmi) begin
				int_sample = 1'b0;
			end
			else begin
				casez ({ reg_op_prefix, reg_instr })
					{ OP_PREFIX_NONE, 8'b00100010 }, // LD (nn),HL
					{ OP_PREFIX_NONE, 8'b11??0101 }, // PUSH qq
					{ OP_PREFIX_NONE, 8'b11100011 }, // EX (SP),HL
					{ OP_PREFIX_NONE, 8'b11???100 }, // CALL cc,nn
					{ OP_PREFIX_NONE, 8'b11???111 }, // RST p
					{ OP_PREFIX_DD,   8'b00100010 }, // LD (nn),IX
					{ OP_PREFIX_DD,   8'b11100101 }, // PUSH IX
					{ OP_PREFIX_DD,   8'b11100011 }, // EX (SP),IX
					{ OP_PREFIX_ED,   8'b01??0011 }, // LD (nn),dd
					{ OP_PREFIX_FD,   8'b00100010 }, // LD (nn),IY
					{ OP_PREFIX_FD,   8'b11100101 }, // PUSH IY
					{ OP_PREFIX_FD,   8'b11100011 }: // EX (SP),IY
					begin
						int_sample = 1'b0;
					end
					default: begin
						int_sample = 1'b1;
					end
				endcase
			end
		end
		FSM_STATE_MEM_WRITE1_3: begin
			if (int_active_nmi || (int_active_int && int_mode != INT_MODE_0)) begin
				state_next = FSM_STATE_PRE_MEM_WRITE_2;
			end
			else begin
				casez ({ reg_op_prefix, reg_instr })
					{ OP_PREFIX_NONE, 8'b11100011 }, // EX (SP),HL
					{ OP_PREFIX_DD,   8'b11100011 }, // EX (SP),IX
					{ OP_PREFIX_FD,   8'b11100011 }: // EX (SP),IY
					begin
						state_next = FSM_STATE_PRE_MEM_READ_2;
					end
					{ OP_PREFIX_ED, 8'b1011?010 }: // (INIR|INDR)
					begin
						if (!regfile_flag_z)
							state_next = FSM_STATE_PRE_MEM_READ_1;
					end
					{ OP_PREFIX_NONE, 8'b00100010 }, // LD (nn),HL
					{ OP_PREFIX_NONE, 8'b11??0101 }, // PUSH qq
					{ OP_PREFIX_NONE, 8'b11???100 }, // CALL cc,nn
					{ OP_PREFIX_NONE, 8'b11001101 }, // CALL nn
					{ OP_PREFIX_NONE, 8'b11???111 }, // RST p
					{ OP_PREFIX_DD,   8'b00100010 }, // LD (nn),IX
					{ OP_PREFIX_DD,   8'b11100101 }, // PUSH IX
					{ OP_PREFIX_ED,   8'b01??0011 }, // LD (nn),dd
					{ OP_PREFIX_FD,   8'b00100010 }, // LD (nn),IY
					{ OP_PREFIX_FD,   8'b11100101 }: // PUSH IY
					begin
						state_next = FSM_STATE_PRE_MEM_WRITE_2;
					end
					default: begin
						int_sample = 1'b1;
						state_next = FSM_STATE_INSTR_FETCH1_1;
					end
				endcase
			end
		end
		FSM_STATE_MEM_WRITE2_1: begin
			state_next = FSM_STATE_MEM_WRITE2_2;
		end
		FSM_STATE_MEM_WRITE2_2: begin
			state_next = FSM_STATE_MEM_WRITE2_3;

			if ((int_active_int && (int_mode != INT_MODE_2)) || int_active_nmi)
				int_sample = 1'b0;
			else
				int_sample = 1'b1;
		end
		FSM_STATE_MEM_WRITE2_3: begin
			if (int_active_int && int_mode == INT_MODE_2)
				state_next = FSM_STATE_MEM_READ1_1;
			else
				state_next = FSM_STATE_INSTR_FETCH1_1;

			if ((int_active_int && int_mode != INT_MODE_2) || int_active_nmi)
				int_done = 1'b1;
		end
		FSM_STATE_IO_READ_1: begin
			state_next = FSM_STATE_IO_READ_2;
		end
		FSM_STATE_IO_READ_2: begin
			state_next = FSM_STATE_IO_READ_3;

			casez ({ reg_op_prefix, reg_instr })
				{ OP_PREFIX_ED, 8'b101??010 }: // (INI|INIR|IND|INDR)
				begin
					int_sample = 1'b0;
				end
				default: begin
					int_sample = 1'b1;
				end
			endcase
		end
		FSM_STATE_IO_READ_3: begin
			casez ({ reg_op_prefix, reg_instr })
				{ OP_PREFIX_ED, 8'b101??010 }: // (INI|INIR|IND|INDR)
				begin
					state_next = FSM_STATE_MEM_WRITE1_1;
				end
				default: begin
					state_next = FSM_STATE_INSTR_FETCH1_1;
				end
			endcase
		end
		FSM_STATE_IO_WRITE_1: begin
			state_next = FSM_STATE_IO_WRITE_2;
		end
		FSM_STATE_IO_WRITE_2: begin
			state_next = FSM_STATE_IO_WRITE_3;
			int_sample = 1'b1;
		end
		FSM_STATE_IO_WRITE_3: begin
			casez ({ reg_op_prefix, reg_instr })
				{ OP_PREFIX_ED, 8'b1010?011 }: // (OUTI|OUTD)
				begin
					state_next = FSM_STATE_INSTR_FETCH1_1;
				end
				{ OP_PREFIX_ED, 8'b1011?011 }: // (OUTR|OUTDR)
				begin
					if (!regfile_flag_z)
						state_next = FSM_STATE_PRE_INSTR_FETCH_1;
					else
						state_next = FSM_STATE_INSTR_FETCH1_1;
				end
			endcase
		end
		FSM_STATE_ACK_INT_1: begin
			state_next = FSM_STATE_ACK_INT_2;
		end
		FSM_STATE_ACK_INT_2: begin
			state_next = FSM_STATE_ACK_INT_3;
		end
		FSM_STATE_ACK_INT_3: begin
			state_next = FSM_STATE_ACK_INT_4;
		end
		FSM_STATE_ACK_INT_4: begin
			case (int_mode)
				INT_MODE_0: begin
					state_next = FSM_STATE_INSTR_FETCH1_3;
					int_done = 1'b1;
				end
				INT_MODE_1,
				INT_MODE_2: begin
					state_next = FSM_STATE_PRE_MEM_WRITE_1;
				end
			endcase
		end
		FSM_STATE_ACK_NMI_1: begin
			state_next = FSM_STATE_ACK_NMI_2;
		end
		FSM_STATE_ACK_NMI_2: begin
			state_next = FSM_STATE_PRE_MEM_WRITE_1;
		end
		FSM_STATE_PRE_INSTR_FETCH_1: begin
			state_next = FSM_STATE_INSTR_FETCH1_1;
		end
		FSM_STATE_PRE_MEM_READ_1: begin
			state_next = FSM_STATE_MEM_READ1_1;
		end
		FSM_STATE_PRE_MEM_READ_2: begin
			state_next = FSM_STATE_MEM_READ2_1;
		end
		FSM_STATE_PRE_MEM_WRITE_1: begin
			state_next = FSM_STATE_MEM_WRITE1_1;
		end
		FSM_STATE_PRE_MEM_WRITE_2: begin
			state_next = FSM_STATE_MEM_WRITE2_1;
		end
		FSM_STATE_BLOCK_TRANSFER: begin
			state_next = FSM_STATE_INSTR_FETCH1_1;
		end
	endcase
end

endmodule
