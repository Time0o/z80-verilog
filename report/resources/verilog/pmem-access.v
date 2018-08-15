// ...

if (!int_n_pmem) begin
    if (!int_n_rd && int_n_wr) begin
        if (int_addr < INTERNAL_PROGMEM_SIZE) begin
            ipram_ce = 1'b1;

            int_dout = ipram_dout;
        end
    end
    else begin
        ext_n_mreq = 1'b0;
        ext_n_rd   = 1'b0;

        int_dout = ext_din;
    end
end

// ...
