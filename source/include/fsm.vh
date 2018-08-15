localparam FSM_STATE_IDLE              = 46'h000000000000;
localparam FSM_STATE_INSTR_FETCH1_1    = 46'h000000000003;
localparam FSM_STATE_INSTR_FETCH1_2    = 46'h000000000005;
localparam FSM_STATE_INSTR_FETCH1_3    = 46'h000000000009;
localparam FSM_STATE_INSTR_FETCH2_1    = 46'h000000000011;
localparam FSM_STATE_INSTR_FETCH2_2    = 46'h000000000021;
localparam FSM_STATE_INSTR_FETCH2_3    = 46'h000000000041;
localparam FSM_STATE_INSTR_FETCH3_1    = 46'h000000000081;
localparam FSM_STATE_INSTR_FETCH3_2    = 46'h000000000101;
localparam FSM_STATE_INSTR_FETCH3_3    = 46'h000000000201;
localparam FSM_STATE_OP_FETCH1_1       = 46'h000000000401;
localparam FSM_STATE_OP_FETCH1_2       = 46'h000000000801;
localparam FSM_STATE_OP_FETCH1_3       = 46'h000000001001;
localparam FSM_STATE_OP_FETCH2_1       = 46'h000000002001;
localparam FSM_STATE_OP_FETCH2_2       = 46'h000000004001;
localparam FSM_STATE_OP_FETCH2_3       = 46'h000000008001;
localparam FSM_STATE_MEM_READ1_1       = 46'h000000010001;
localparam FSM_STATE_MEM_READ1_2       = 46'h000000020001;
localparam FSM_STATE_MEM_READ1_3       = 46'h000000040001;
localparam FSM_STATE_MEM_READ2_1       = 46'h000000080001;
localparam FSM_STATE_MEM_READ2_2       = 46'h000000100001;
localparam FSM_STATE_MEM_READ2_3       = 46'h000000200001;
localparam FSM_STATE_MEM_WRITE1_1      = 46'h000000400001;
localparam FSM_STATE_MEM_WRITE1_2      = 46'h000000800001;
localparam FSM_STATE_MEM_WRITE1_3      = 46'h000001000001;
localparam FSM_STATE_MEM_WRITE2_1      = 46'h000002000001;
localparam FSM_STATE_MEM_WRITE2_2      = 46'h000004000001;
localparam FSM_STATE_MEM_WRITE2_3      = 46'h000008000001;
localparam FSM_STATE_IO_READ_1         = 46'h000010000001;
localparam FSM_STATE_IO_READ_2         = 46'h000020000001;
localparam FSM_STATE_IO_READ_3         = 46'h000040000001;
localparam FSM_STATE_IO_WRITE_1        = 46'h000080000001;
localparam FSM_STATE_IO_WRITE_2        = 46'h000100000001;
localparam FSM_STATE_IO_WRITE_3        = 46'h000200000001;
localparam FSM_STATE_ACK_INT_1         = 46'h000400000001;
localparam FSM_STATE_ACK_INT_2         = 46'h000800000001;
localparam FSM_STATE_ACK_INT_3         = 46'h001000000001;
localparam FSM_STATE_ACK_INT_4         = 46'h002000000001;
localparam FSM_STATE_ACK_NMI_1         = 46'h004000000001;
localparam FSM_STATE_ACK_NMI_2         = 46'h008000000001;
localparam FSM_STATE_PRE_INSTR_FETCH_1 = 46'h010000000001;
localparam FSM_STATE_PRE_MEM_READ_1    = 46'h020000000001;
localparam FSM_STATE_PRE_MEM_READ_2    = 46'h040000000001;
localparam FSM_STATE_PRE_MEM_WRITE_1   = 46'h080000000001;
localparam FSM_STATE_PRE_MEM_WRITE_2   = 46'h100000000001;
localparam FSM_STATE_BLOCK_TRANSFER    = 46'h200000000001;
