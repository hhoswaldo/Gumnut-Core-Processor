module registers (
    //Sequential inputs
    input  logic        clk,   // Clock
    input  logic        cen,   // Clock enable
    input  logic        rst,   // Reset
    input  logic        we,    // Write enable
    //IR inputs
    input  logic [2:0]  rs_i,  // Read address A 3 bit
    input  logic [2:0]  rs2_i, // Read address B 3 bit
    input  logic [2:0]  rd_i,  // Write address 3 bit
    //Mux4to1 input
    input  logic [7:0]  dat_i, // Write data 8 bit
    //ALU output
    output logic [7:0]  rs_o,  // Read data A 8 bit
    //Mux2to1 output
    output logic [7:0]  rs2_o  // Read data B 8 bit
);

    integer i;              //Size of elements
    logic [7:0] mem [7:0];  //8 bit * 8 registers bus
    logic clkg;             // Gated clock

    always_comb clkg = clk & cen; // Clock gating logic

    always_ff @( posedge clkg or posedge rst ) begin : write_data
        if (rst)
            for (i = 0; i < 8 ; i = i + 1 )
                mem[i] <= 0; // Resets all registers to 0
        else if (we)
            mem[rd_i] <= dat_i; // Writes write data to write address
    end

    always_ff @( negedge clkg  or posedge rst ) begin : reading_data
        if (rst) begin
            rs_o = 8'bx;   // Reads data at read address A
            rs2_o = 8'bx; // Reads data at read address B
        end
        else begin
            rs_o = mem[rs_i];   // Reads data at read address A
            rs2_o = mem[rs2_i]; // Reads data at read address B
        end
    end

endmodule