module ALU (
    // Register bank & mux2to1 inputs
    input   logic   [7:0]   rs_i,       // 8 bit A value input
    input   logic   [7:0]   op2_i,      // 8 bit B value input
    // Instruction register input
	input   logic   [2:0]   count_i,    // 3 bit ALUS count input
    // Control Unit inputs
    input   logic   [3:0]   ALUOp_i,    // 4 bit operation selector input
    // Flag register inputs
	input   logic           carry_i,	// 1 bit carry in input
    //Mux4to1 & Processing unit output
    output  logic   [7:0]   res_o,      // 8 bit ALU result output
    //Register flag output
    output  logic           neg_o,     // 1 bit negative flag output
    output  logic           zero_o,    // 1 bit zero flag output
    output  logic           v_o,       // 1 bit overflow flag output
    output  logic           carry_o    // 1 bit carry flag output
);
	
	logic   [7:0]   alua_res_e;     // 8 bit ALUA result 
	logic   [7:0]   alul_res_e;     // 8 bit ALUL result
    logic   [7:0]   alus_res_e;     // 8 bit ALUS result
    logic           alua_cout_e;    // 1 bit ALUA carry out
    logic           alus_cout_e;    // 1 bit ALUS carry out
    logic           alua_vout_e;    // 1 bit ALUA overflow
    
	// Mux4to1 operation selector
    always_comb begin : mux4to1function
        case (ALUOp_i[3:2])
            2'b00: begin                // Arithmetic operation
                res_o = alua_res_e;
                v_o = alua_vout_e;
                carry_o = alua_cout_e;
            end 
            2'b01: begin                // Logic Operation
                res_o = alul_res_e;
                v_o = 1'b0;
                carry_o = 1'b0;
            end 
            2'b10: begin                // Shift Operation
                res_o = alus_res_e;
                v_o = 1'b0;
                carry_o = alus_cout_e;
            end
            2'b11: begin                // Shift Operation
                res_o = alus_res_e;
                v_o = 1'b0;
                carry_o = alus_cout_e; 
            end
            default: begin
                res_o = 8'bx;
                v_o = 1'b0;
                carry_o = 1'b0;
            end 
        endcase
    end

    always_comb zero_o = res_o == 0;    // Zero flag
    always_comb neg_o = res_o < 0;      // Negative flag
	
    //alua instance 
    alua alua1(
        .A(rs_i), 
        .B(op2_i), 
        .sel(ALUOp_i[1:0]), 
		.cin(carry_i),
        .out(alua_res_e), 
        .vout(alua_vout_e), 
        .cout(alua_cout_e) 
    );

    always_comb begin : alul
        case (ALUOp_i[1:0])
            2'b00 : alul_res_e = rs_i & op2_i;  // AND bitwise
            2'b01 : alul_res_e = rs_i | op2_i;  // OR bitwise
            2'b10 : alul_res_e = rs_i ^ op2_i;  // XOR bitwise
            2'b11 : alul_res_e = ~ rs_i;        // Negate A bitwise
            default : alul_res_e = 8'bx;        // Default : x
        endcase
    end

    always_comb begin : alus
        case (ALUOp_i[1:0])
			2'b00: {alus_cout_e, alus_res_e} = {1'b0,rs_i} << count_i;
			2'b01: {alus_res_e, alus_cout_e} = {rs_i,1'b0} >> count_i;
			2'b10: begin
						alus_res_e = (rs_i << count_i) | (rs_i >> (8 - count_i));
						alus_cout_e = alus_res_e[0];
					end
			2'b11: begin
						alus_res_e = (rs_i >> count_i) | (rs_i << (8 - count_i));
						alus_cout_e = alus_res_e[7];
					end
			default :  {alus_cout_e, alus_res_e} = {1'b0,rs_i} << count_i;
		endcase 
    end
endmodule 
