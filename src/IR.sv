module IR (
    //Inputs
    input logic clk,                // 1 bit clock
    input logic cen,                // 1 bit clock enable
    input logic rst,                // 1 bit reset
    input logic we,                 // 1 bit write enable
    input logic [17:0]  inst_i,     // 18 bit instruction data
    //Outputs
    output logic [6:0]  op_o,       // 7 bit operation output
    output logic [2:0]  func_o,     // 3 bit function output
    output logic [11:0] addr_o,     // 12 bit address output
    output logic [7:0]  disp_o,     // 8 bit disp/offset output
    output logic [2:0]  rs_o,       // 3 bit rs output 
    output logic [2:0]  rs2_o,      // 3 bit rs_2 output
    output logic [2:0]  rd_o,       // 3 bit rd output
    output logic [7:0]  immed_o,    // 8 bit immed output
    output logic [2:0]  count_o     // 3 bit count output 
);
    // Types of instructions
    parameter arithmetic_logic  = 4'b1110;
    parameter shift = 3'b110;
    parameter branch = 6'b111110;
    parameter jump = 5'b11110;
    parameter mem  = 2'b10;
    parameter misc = 7'b1111110;

    logic clkg;
    logic [2:0] func_e; // Function instruction type

    always_comb clkg = clk & cen; // Clock gate
    

    always_comb begin
        if (inst_i[17] == 0 || inst_i[17:16] == shift)
            func_e = inst_i[16:14];
        else if (inst_i[17:12] == branch || inst_i[17:13] == jump)
            func_e = inst_i[12:10];
        else if (inst_i[17:11] == misc)
            func_e = inst_i[10:8];
        else
            func_e = inst_i[2:0]; //Arithmetic
    end

    always_ff @( posedge clkg or posedge rst ) begin
        if (rst) begin
            op_o = 7'b0;
            func_o = 3'b0;
            addr_o = 12'b0; 
            disp_o = 8'b0; 
            rs_o = 3'b0;
            rs2_o = 3'b0;
            rd_o = 3'b0;
            immed_o = 8'b0;
            count_o = 3'b0; 
        end
        else if (we) begin
            op_o = inst_i[17:11];
            func_o = func_e;
            addr_o = inst_i[11:0]; 
            disp_o = inst_i[7:0]; 
            rs_o = inst_i[10:8];
            rs2_o = inst_i[7:5];
            rd_o = inst_i[13:11];
            immed_o = inst_i[7:0];
            count_o = inst_i[7:5]; 
        end 
    end
endmodule