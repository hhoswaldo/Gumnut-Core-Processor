module aluext (
    input   logic   [7:0]   A,      // 8 bit value input
    input   logic   [7:0]   B,      // 8 bit value input
    input   logic   [1:0]   S,      // 2 bit selector input
	input   logic           cin,    // 1 bit carry in input
    output  logic   [7:0]   OPA,    // 8 bit A result output 
    output  logic   [7:0]   OPB,    // 8 bit B result output 
    output  logic 			cout    // 1 bit carry out output 
);
    always_comb begin : mux4to1b
        case (S)
            2'b00 : OPB = B;    // Bitwise B
            2'b01 : OPB = B;    // Bitwise B
            2'b10 : OPB = ~B;   // Bitwise ~B
            2'b11 : OPB = ~B;   // Bitwise ~B
            default : OPB = B;  // Bitwise B
        endcase
    end

    always_comb begin : mux4to1cout
            case (S)
            2'b00 : cout = 1'b0;    // 0    
            2'b01 : cout = cin;     // Carry in
            2'b10 : cout = 1'b1;    // 1
            2'b11 : cout = ~cin;    // Not carry in
            default : cout = cin;  // Carry in
        endcase
    end

    always_comb OPA = A; // A is unchanged

endmodule 