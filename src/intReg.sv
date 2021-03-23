module intReg (
    input logic clk_i,
    input logic cen_i,
    input logic rst,
    input logic we,
    //Inputs
    input logic [11:0] pc_i,
    input logic c_i,
    input logic z_i,
    //Outputs
    output logic intc_o,
    output logic intz_o,
    output logic [11:0] pc_o
);

    logic clkg;

    always_comb clkg = clk_i & cen_i;

    always_ff @( posedge clkg or posedge rst ) begin
        if (rst) begin
            intc_o <= 1'b0;
            intz_o <= 1'b0;
            pc_o <= 12'b0;
        end
        else if (we) begin
            intc_o <= c_i;
            intz_o <= z_i;
            pc_o <= pc_i;
        end
    end
    
endmodule