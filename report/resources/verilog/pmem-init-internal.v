// ...

assign loaded = (counter == 13'b1000000000000);

always @(posedge clk, negedge n_reset) begin
    if (n_reset == 1'b0) begin
        counter <= 13'b0000000000000;
    end
    else if (!loaded) begin
        counter <= counter + 13'b0000000000001;
    end
end

always @* begin
    #10

    din_int = din;
    dout    = 8'h00;
    bwe     = 4'b1111;

    if (!loaded) begin
        csb = 1'b0;

        addr_word = counter[11:2];

        case (counter[1:0])
            2'b00: bwe[3] = 1'b0;
            2'b01: bwe[2] = 1'b0;
            2'b10: bwe[1] = 1'b0;
            2'b11: bwe[0] = 1'b0;
        endcase
    end
    else begin
        csb = ~ce;

        addr_word = addr[11:2];

        case (addr[1:0])
            2'b00: dout = dout_int[31:24];
            2'b01: dout = dout_int[23:16];
            2'b10: dout = dout_int[15:8];
            2'b11: dout = dout_int[7:0];
        endcase
    end
end
