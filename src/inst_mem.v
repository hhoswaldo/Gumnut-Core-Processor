module inst_mem ( 
    input  clk_i,
    input  cyc_i,
    input  stb_i,
    input  [11:0] adr_i,
    output ack_o,
    output [17:0] dat_o 
);

  reg [17:0] IMem [0:4095];

  initial $readmemh("gasm_text.dat", IMem);

  assign dat_o = IMem[adr_i];

  assign ack_o = cyc_i & stb_i;

endmodule
