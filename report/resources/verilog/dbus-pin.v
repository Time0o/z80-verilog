ZMA2GSC data_pad_i [7:0] (
    .IO(IO_DATA),
    .I(data_out),
    .O(data_in),
    .E(data_out_en),
    .E2(1'b1),
    .E4(1'b1),
    .E8(1'b0),
    .SR(1'b1),
    .SMT(1'b0),
    .PU(1'b1),
    .PD(1'b1)
);
