module alua (
    input   logic   [7:0]   A,      // 8 bit value A input
    input   logic   [7:0]   B,      // 8 bit value B input
    input   logic   [1:0]   SEL,    // 2 bit input selector
	input   logic		    cin,    // 1 bit carry in input
    output  logic   [7:0]   out,    // 8 bit result output
    output  logic           vout,   // 1 bit overflow output
    output  logic           cout    // 1 bit carry out output
);

    logic [7:0] a_e;    // 8 bit aluext A output
    logic [7:0] b_e;    // 8 bit aluext B output
	logic       cout_e; // 1 bit carry in

    //aluext instance
    aluext aluext1(
        .A(A), 
        .B(B), 
        .S(SEL),
		.cin(cin),
        .OPA(a_e), 
        .OPB(b_e), 
        .cout(cout_e)
    );

    // adder instance
    adder adder1(
        .IA(a_e), 
        .IB(b_e), 
        .cin(cout_e), 
        .IS(out), 
        .cout(cout), 
        .vout(vout) 
    );
	
endmodule 