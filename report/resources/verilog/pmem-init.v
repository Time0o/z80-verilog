// externally initialize program memory
reg [7:0] progmem [PROGMEM_BYTES-1:0];
reg [PROGMEM_BYTES_LOG2:0] progmem_counter;

initial begin
    $readmemh("progmem.txt", progmem);
    progmem_counter = 0;
end

always @(posedge i_clk) begin
    # 10

    if (progmem_counter < PROGMEM_BYTES) begin
        din_init <= progmem[progmem_counter];
        progmem_counter <= progmem_counter + 1;
    end
    else begin
        din_init <= 8'hzz;
    end
end

assign io_data = din_init;
