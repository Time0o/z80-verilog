// ...

sub = ((mode == ALU_MODE_SUB)       || (mode == ALU_MODE_SBC) ||
       (mode == ALU_MODE_SBC_16BIT) || (mode == ALU_MODE_CP)  ||
       (mode == ALU_MODE_NEG)       || (mode == ALU_MODE_CPB));

carry = ((mode == ALU_MODE_ADC) || (mode == ALU_MODE_ADC_16BIT) ||
         (mode == ALU_MODE_SBC) || (mode == ALU_MODE_SBC_16BIT));

cin  = flags_in[FLAG_IDX_C];
cin0 = sub ^ (carry && cin);

// ...

// perform calculations
case (mode)

    // arithmetic operations
    default: begin
        { cout3, data_out[3:0] } = { 1'b0, a[3:0] } + { 1'b0, b[3:0] } + { 4'b0000, cin0 };

        { cin7, data_out[6:4] } = { 1'b0, a[6:4] } + { 1'b0, b[6:4] } + { 3'b000, cout3 };

        data_out[7] = (a[7] ^ b[7]) ^ cin7;
        cout7 = (cin7 & (a[7] ^ b[7])) | (a[7] & b[7]);

        { cout11, data_out[11:8] } = { 1'b0, a[11:8] } + { 1'b0, b[11:8] } + { 4'b0000, cout7 };

        { cin15, data_out[14:12] } = { 1'b0, a[14:12] } + { 1'b0, b[14:12] } + { 3'b000, cout11 };

        data_out[15] = (a[15] ^ b[15]) ^ cin15;
        cout15 = (cin15 & (a[15] ^ b[15])) | (a[15] & b[15]);
    end

    // ...
