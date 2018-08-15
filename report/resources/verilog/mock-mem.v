datamem_mock #(
    .SZ_LOG2(EXT_DATAMEM_BYTES_LOG2),
    .INITFILE("datamem_ext.txt")
) datamem_ext_i (
    .clk(i_clk),
    // Inputs
    .addr(o_addr[EXT_DATAMEM_BYTES_LOG2-1:0]),
    .din(io_data),
    .ce(~o_n_mreq),
    .we(~o_n_wr),
    // Outputs
    .dout(io_data)
);

datamem_mock #(
    .SZ_LOG2(IOMEM_BYTES_LOG2),
    .INITFILE("iomem.txt")
) iodev_mock_i (
    .clk(i_clk),
    // Inputs
    .addr(o_addr[IOMEM_BYTES_LOG2-1:0]),
    .din(io_data),
    .ce(~o_n_iorq),
    .we(~o_n_wr),
    // Outputs
    .dout(io_data)
);
