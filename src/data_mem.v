module data_mem ( 
    input  clk_i,
    input  cyc_i,
    input  stb_i,
    input  we_i,
    output ack_o,
    input      [7:0] adr_i,
    input      [7:0] dat_i,
    output reg [7:0] dat_o 
  );

  reg [7:0] DMem [0:255];

  reg read_ack;

  initial $readmemh("gasm_data.dat", DMem);

  always @(posedge clk_i)
    if (cyc_i && stb_i)
      if (we_i) begin
        DMem[adr_i] <= dat_i;
        dat_o <= dat_i;
        read_ack <= 1'b0;
      end
      else begin
        dat_o <= DMem[adr_i];
        read_ack <= 1'b1;
      end
    else
      read_ack <= 1'b0;

  assign ack_o = cyc_i & stb_i & (we_i | read_ack);

endmodule
