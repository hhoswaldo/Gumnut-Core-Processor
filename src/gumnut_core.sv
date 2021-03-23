module gumnut_core (
    input   logic           clk_i,
    input   logic           int_req, // 1 bit interrupt request signal input
    input   logic           rst_i,
    input   logic   [7:0]   port_dat_i,
    // Imem inputs
    input   logic   [17:0]  inst_data_i, // 18 bit instruction data
    input   logic           inst_ack_i,  // 1 bit IR write enable input 

    // Datamem inputs
    input   logic           data_ack_i,
    input   logic   [7:0]   data_dat_i,

    // Outputs to dataMem
    output  logic   [7:0]   data_adr_o,
    output  logic           data_cyc_o,
    output  logic   [7:0]   data_dat_o,
    output  logic           data_stb_o,
    output  logic           data_we_o,

    // Outputs to instruction memory
    output  logic   [11:0]  inst_adr_o,
    output  logic           inst_cyc_o,
    output  logic           inst_stb_o,    

    // Interrupt flag output
    output  logic           int_ack,
    
    // Port outputs
    output  logic   [7:0]   port_adr_o,
    output  logic   [7:0]   port_data_o,  
    output  logic           port_we_o
);

    //  Clock divider
    logic clkEn;
    parameter frecuency_rate = 2'b10; // 50 mhz to 25 mhz clock divider
    logic [1:0] frecuency_register;

    always_ff @( negedge clk_i ) begin : clock_divider
        if (rst_i) begin
            frecuency_register <= 2'b1;
        end
        else if ( frecuency_rate == frecuency_register ) begin
            clkEn = 1'b1;
            frecuency_register <= 2'b1;
        end
        else begin
            frecuency_register <= frecuency_register + 1'b1;
        end
    end

    // PROCESOR UNIT TO CONTROL UNIT WIRES
    logic [7:0] op_e;
    logic [3:0] func_e;
    
    // CONTROL UNIT TO PROCESOR UNIT WIRES
    logic op2_c;
    logic ALUOp_c;
    logic ALUFR_c;
    logic ALUEn_c;
    logic RegWrt_c;
    logic [1:0] RegMux_c;
    logic DPMux_c;
    logic reti_c;
    logic Port_we_c;

    // CONTROL UNIT TO PC UNIT WIRES
    logic PCEn_c;
    logic [3:0] PCoper_c;
    logic int_c;

    // PROCESS UNIT TO PC UNIT WIRES
    logic cCarry_e;
    logic cZero_e;
    logic addr_e;
    logic disp_e;

    // PC UNIT to PROCESS UNIT WIRES
    logic intc_e;
    logic intz_e;

    // Unic wires
    logic PC_e;

    //  op_res_e
    logic [7:0] op_res_e;
    logic [7:0] op_res2_e;

    // Port inputs
    logic [7:0] data_dat_e;
    logic [7:0] port_dat_e;

    always_comb data_adr_o = op_res_e;
    always_comb data_dat_o = op_res2_e;
    always_comb inst_adr_o = PC_e;


    // Port outputs registers outputs
    always_ff @( posedge clk_i ) begin : port_register_output
        if (Port_we_c) begin
            port_adr_o <= op_res_e;
            port_data_o <= op_res2_e;
        end
        else begin
            port_we_o <= Port_we_c;
        end
    end

    always_ff @( posedge clk_i ) begin : port_register_input
        data_dat_e = data_dat_i;
        port_dat_e = port_dat_i;
    end

    control_unit control_unit1(
        .clk_i(clk_i),      
        .clkEn_i(clkEn),    
        .op_i(op_e),       
        .func_i(func_e),     
        .inst_ack_i(inst_ack_i), 
        .data_ack_i(data_ack_i), 
        .int_req(int_req),    
        .op2_o(op2_c),      
        .ALUOp_o(ALUOp_c),     
        .ALUFR_o(ALUFR_c),    
        .ALUEn_o(ALUEn_c),    
        .RegWrt_o(RegWrt_c),   
        .RegMux_o(RegMux_c),   
        .PCEn_o(PCEn_c),     
        .PCoper_o(PCoper_c),   
       // .ret_o(),      
       // .jsb_o(),      
        .reti_o(reti_c),
        .DPMux_o(DPMux_c),         
        .stb_o(inst_stb_o),      
        .cyc_o(inst_cyc_o),
        .port_we_o(Port_we_c),      
        .data_we_o(data_we_o),  
        .data_stb_o(data_stb_o), 
        .data_cyc_o(data_cyc_o),
        .int_ack(int_ack) 
    );

    processor_unit processor_unit1(
        .clk_i(clk_i),      // 1 bit clock input
        .clkEn_i(clkEn),    // 1 bit clock enable
        .rst_i(rst_i),      // 1 bit reset
        .data_dat_i(data_dat_e), // 8 bit MUX4to1 input
        .port_dat_i(port_dat_e), // 8 bit MUX4to1 input
        .RegMux_i(RegMux_c),   // 2 bit Mux4to1 selector
        .inst_ack_i(inst_ack_i), // 1 bit IR input 
        .inst_dat_i(inst_data_i), // 18 bit IR input 
        .RegWrt_i(RegWrt_c),   // 1 bit Registers write enable
        .op2_i(op2_c),      // 1 bit Mux2to1 selector
        .DPMux_i(DPMux_c),
        .ALUOp_i(ALUOp_c),    // 4 bit ALU operation selector
        .intz_i(intz_e),     //
        .intc_i(intc_e),     // 
        .we(ALUFR_c),         // ALU write enable input
        .we_i(reti_c),       // Interrupt write enable
        .ALUEn_c(ALUEn_c),
        .op_o(op_e),       // 7 bit operation output
        .func_o(func_e),     // 4 bit function output
        .addr_o(addr_e),     // 12 bit address output
        .disp_o(disp_e),     // 8 bit disp/offset output
        .c_o(cCarry_e),        // 1 bit ALU carry out flag 
        .z_o(cZero_e),        // 1 bit ALU zero out flag
        .rsr2_o(op_res2_e),     // 8 bit rs2
        .res_o(op_res_e)       // 8 bit ALU operation result
    );

    pc_unit pc_unit1(
        .clk_i(clk_i), //1 bit clk input
        .clkEn_i(clkEn), //1 bit clock enable input
        .rst(rst_i),  //1 bit reset input
        .PCoper_i(PCoper_c), //Ctr unit output
        .PCEn_c(PCEn_c), // CtrlUnit output
        .int_c(int_c), // ctrlUnit output
        .carry_i(cCarry_e), // Flag register
        .zero_i(cZero_e), // Flag register
        .disp_o(disp_e), // 8 bit IR output
        .addr_o(addr_e), // 12 bit IR output
        .ccC_e(intc_e),
        .ccZ_e(intz_e),
        .PC_o(PC_e) //12 bits pc ouput
    );


endmodule