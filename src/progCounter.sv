module progCounter (
    input logic [11:0] PC_i,
    input logic we,
    input logic clk,
    input logic cen,
    input logic rst,
    output logic [11:0] PC_o
);

    logic clkg;

    always_comb clkg = clk & cen;

    always_ff @( posedge clkg or posedge rst ) begin
        if (rst) begin
            PC_o = 12'b0;
        end
        else if (we) begin
            PC_o = PC_i;
        end
    end
    
endmodule