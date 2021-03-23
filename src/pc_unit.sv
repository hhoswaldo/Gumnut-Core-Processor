module pc_unit (
    input logic clk_i, //1 bit clk input
    input logic clkEn_i, //1 bit clock enable input
    input logic rst,  //1 bit reset input
    input logic [3:0] PCoper_i, //Ctr unit output
    input logic PCEn_c, // CtrlUnit output
    input logic int_c, // ctrlUnit output
        //input logic pop_i, //1 bit pop CtrlUnit output
        //input logic push_i, //1 bit push CtrlUnit output
    input logic carry_i, // Flag register
    input logic zero_i, // Flag register
    input logic [7:0] disp_o, // 8 bit IR output
    input logic [11:0] addr_o, // 12 bit IR output
    output logic ccC_e,      // 1 bit Intreg output
    output logic ccZ_e,      // 1 bit Intreg output
    output logic [11:0] PC_o //12 bits pc ouput
);

    logic [11:0] PC_e, ccPC_o, PCnew_e;

    intReg intreg1(
        .clk_i(clk_i), //1 bit clock input
        .cen_i(clkEn_i),//1 bit clock enable input
        .rst(rst),  //1 bit reset input
        .we(int_c), //1 bit we input
        //ProgCounter to intReg
        .pc_i(PC_o), //12 bits pc input
        //ALU to intReg inputs
        .c_i(carry_i), //1 bit carry input
        .z_i(zero_i),  //1 bit zero input
        .intc_o(ccC_e), //1 bit intc output
        .intz_o(ccZ_e), //1 bit intz output
         //intReg to NewPC
        .pc_o(ccPC_o) //12 bits pc output
    );

    newPC_unit newPC_unit1 (
        .PCoper_i(PCoper_i), //4 bits PC operation input
        //FlagReg to NewPC
        .zero_i(zero_i), //1 bit zero input
        .carry_i(carry_i), //1 bit carry input
        //IntReg to NewPC
        .ISRaddr_i(ccPC_o), //12 bits ISRaddress input
        //IR to NewPC
        .offset_i(disp_o), //9 bits offset input
        .addr_i(addr_o), //12 bits address input
        .PC_i(PC_o), //12 bits pc input
        .PC_o(PCnew_e) //12 bits pc output
    );

    progCounter progcounter1(
        .clk(clk_i), //1 bit clock input
        .cen(clkEn_i), //1 bit clock enable input
        .rst(rst), //1 bit reset input
        // NewPC to progCounter
        .PC_i(PCnew_e), //12 bits pc input
        .we(PCEn_c), //1 bit we input
        //progCounter to newpc, stack & intReg
        .PC_o(PC_e) //12 bits pc output
    );

    always_comb PC_o = PC_e;

endmodule