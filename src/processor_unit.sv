module processor_unit (
    //Processor unit inputs
    input logic         clk_i,      // 1 bit clock input
    input logic         clkEn_i,    // 1 bit clock enable
    input logic         rst_i,      // 1 bit reset
    //Mux4to1 inputs
    input logic [7:0]   data_dat_i, // 8 bit MUX4to1 input
    input logic [7:0]   port_dat_i, // 8 bit MUX4to1 input
    input logic [1:0]   RegMux_i,   // 2 bit Mux4to1 selector
    //Instruction register inputs
    input logic         inst_ack_i, // 1 bit IR input 
    input logic [17:0]  inst_dat_i, // 18 bit IR input 
    //Register Bank inputs
    input logic         RegWrt_i,   // 1 bit Registers write enable
    //Mux2to1 inputs
    input logic         op2_i,      // 1 bit Mux2to1 selector
    input logic         DPMux_i,
    //ALU inputs
    input logic [3:0]   ALUOp_i,    // 4 bit ALU operation selector
    //Flag register inputs
    input logic         intz_i,     //
    input logic         intc_i,     // 
    input logic         we,         // ALU write enable input
    input logic         we_i,       // Interrupt write enable
    //ALU result enable register
    input logic         ALUEn_c,
    //Instruction register outputs
    output logic [6:0]  op_o,       // 7 bit operation output
    output logic [3:0]  func_o,     // 4 bit function output
    output logic [11:0] addr_o,     // 12 bit address output
    output logic [7:0]  disp_o,     // 8 bit disp/offset output
    //Flag register outputs
    output logic        c_o,        // 1 bit ALU carry out flag 
    output logic        z_o,        // 1 bit ALU zero out flag
    //Register bank outputs
    output logic [7:0]  rsr2_o,     // 8 bit rs2
    //ALU outputs
    output logic [7:0]  res_o       // 8 bit ALU operation result 
);
    // IR to Register bank
    logic [2:0] rs_e;  // IR rs_o output -> registers input rs_i
    logic [2:0] rs2_e; // IR rs2_o output -> registers input rs2_i 
    logic [2:0] rd_e;  // IR rd_o output -> registers input rd_i 

    // IR to Mux2to1
    logic [2:0] immed_offset_e;

    // IR to ALU
    logic [2:0] count_e;

    // Register bank to ALU
    logic [7:0] rsr_e;

    // Register bank to Mux2to1
    logic [7:0] rsr2_e;

    // Mux4to1 to ALU
    logic [7:0] dat_e;

    // Mux2to1 to ALU
    logic [7:0] op2_e;

    // ALU to Mux2to1
    logic [7:0] ALU_e_1;
    logic [7:0] ALU_e_2;

    // IR to Mux2to1
    logic [2:0] rs2_e1; //IR output
    logic [2:0] rs2_e2; //Register bank input
    
    // Flag register to ALU
    logic ccC_e;
    logic ccZ_e;
    logic carry_e;
    logic zero_e;

    // data_dat_i && port_dat_i wires
    logic [7:0] data_dat_e;
    logic [7:0] port_dat_e;

    //data_dat_i && port_dat_i register
    always_ff @( posedge clk_i or posedge rst_i ) begin : port_data_registers
        if (rst_i) begin
            data_dat_e = 8'bx;
            port_dat_e = 8'bx;
        end
        else begin
            data_dat_e = data_dat_i;
            port_dat_e = port_dat_i; 
        end
    end
    
    // Flag register
    always_ff @( posedge clk_i or posedge rst_i ) begin : flag_register
        if (rst_i) begin
            ccC_e = 1'bx;
            ccZ_e = 1'bx;
        end
        else if ( we_i && clkEn_i ) begin
            ccC_e = intc_i;
            ccZ_e = intz_i;
        end
        else if ( we && clkEn_i ) begin
            ccC_e = carry_e;
            ccZ_e = zero_e;
        end
    end

    //ALU result register
    always_ff @( posedge clk_i or posedge rst_i ) begin : alu_result_register
        if (rst_i) begin
            ALU_e_2 = 8'b0;
        end
        else if ( ALUEn_c ) begin
            ALU_e_2 = ALU_e_1;
        end
    end

    // Mux4to1
    always_comb begin : mux4to1_write_data
        if (RegMux_i == 2'b00) begin 
            dat_e = ALU_e_2;
        end
        else if (RegMux_i == 2'b01) begin
            dat_e = data_dat_e;
        end
        else if (RegMux_i == 2'b10) begin
            dat_e = port_dat_e;
        end
        else begin
            dat_e = 8'hx;
        end        
    end

    // Mux2to1 IR ALU Register Bank
    always_comb op2_e = op2_i ? rsr2_e : immed_offset_e;

    // Mux4to1 IR Register Bank
    always_comb rs2_e2 = (DPMux_i) ? rd_e : rs2_e1;

    // Outputs
    always_comb res_o = ALU_e_1;
    always_comb c_o = ccC_e;
    always_comb z_o = ccZ_e;
    always_comb rsr2_o = rsr2_e;


    // IR instance
    IR IR1(
        .clk(clk_i),
        .cen(clkEn_i),
        .rst(rst_i),
        .we(inst_ack_i),
        .inst_i(inst_dat_i),
        .op_o(op_o),
        .func_o(func_o),
        .addr_o(addr_o),
        .disp_o(disp_o),
        .rs_o(rs_e),
        .rs2_o(rs2_e1),
        .rd_o(rd_e),
        .immed_o(immed_offset_e),
        .count_o(count_e)
    );

    // registers instance
    registers registers1(
        .clk(clk_i),   
        .cen(clkEn_i),   
        .rst(rst_i),  
        .we(RegWrt_i),
        .rs_i(rs_e),  
        .rs2_i(rs2_e2), 
        .rd_i(rd_e),  
        .dat_i(dat_e), 
        .rs_o(rsr_e),
        .rs2_o(rsr2_e)
    );
    
    // ALU instance
	ALU ALU1(
        .rs_i(rs_e),
        .op2_i(op2_e),
        .count_i(count_e),
        .carry_i(ccC_e),
        .ALUOp_i(ALUOp_i),
        .zero_o(zero_e),
        .carry_o(carry_e),
        .res_o(ALU_e_1)
    );

endmodule
