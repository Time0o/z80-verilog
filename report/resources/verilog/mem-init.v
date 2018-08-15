// initialize swap data memory
reg [7:0] ext_datamem_buf [EXT_DATAMEM_BYTES-1:0];
reg [7:0] datamem_swap [INT_DATAMEM_BYTES+EXT_DATAMEM_BYTES-1:0];
reg [7:0] iomem_swap [IOMEM_BYTES:0];

integer i;
initial begin
    // add internal data memory
    $readmemh("datamem_int2.txt", datamem_swap, 0, (INT_DATAMEM_BYTES / 2) - 1);

    for (i = 0; i < (INT_DATAMEM_BYTES / 2); i = i +1) begin
        datamem_swap[i + (INT_DATAMEM_BYTES / 2)] = datamem_swap[i];
    end

    $readmemh("datamem_int1.txt", datamem_swap, 0, (INT_DATAMEM_BYTES / 2) - 1);

    // add external data memory
    $readmemh("datamem_ext.txt", ext_datamem_buf, 0, EXT_DATAMEM_BYTES - 1);

    for (i = 0; i < EXT_DATAMEM_BYTES; i = i +1) begin
        datamem_swap[i + INT_DATAMEM_BYTES] =
            ext_datamem_buf[i + INT_DATAMEM_BYTES];
    end

    $readmemh("iomem.txt", iomem_swap, 0, IOMEM_BYTES - 1);
end
