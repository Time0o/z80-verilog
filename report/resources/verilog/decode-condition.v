reg cond

// ...

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
