module adder (
    input   logic   [7:0]   IA,      // 8 bit value input
    input   logic   [7:0]   IB,      // 8 bit value input
    input   logic           cin,     // 1 bit carry in input
    output  logic   [7:0]   IS,      // 8 bit result output
    output  logic 		    cout,    // 1 bit carry out flag
	output  logic 		    vout     // 1 bit Overflow flag
);
    /*
    * Add operation -> IA + IB + carry in
    */
    assign {cout, IS} = IA + IB + cin; 

    // Overflow flag
	always_comb vout = ((~IA[7] & ~IB[7] & IS[7]) | (IA[7] & IB[7] & ~IS[7])) ? 1 : 0;
    
endmodule 