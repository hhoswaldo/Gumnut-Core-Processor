module control_unit (
    // Sequential inputs
    input logic         clk_i,      // 1 bit clock input
    input logic         clkEn_i,    // 1 bit clock enable input
    input logic         rst_i,      // 1 bit reset input
    // Instruction register inputs
    input logic [6:0]   op_i,       // 7 bits input operation input
    input logic [2:0]   func_i,     // 3 bits input function input
    input logic         inst_ack_i, // 1 bit instruction acknowledge input
    input logic         data_ack_i, // 1 bit data acknowledge input
    // Interrupt inputs
    input logic         int_req,    // 1 bit interrupt request input
    // Processing unit outputs
    output logic        op2_o,      // 1 bit immed rs2 selector output -> op_i[3]
    output logic [3:0]  ALUOp_o,    // 4 bits ALU operation selector output 
    output logic        ALUFR_o,    // 1 bit Flagregister write enable output
    output logic        ALUEn_o,    // 1 bit ALU enable output
    output logic        RegWrt_o,   // 1 bit register bank write enable output
    output logic [1:0]  RegMux_o,   // 2 bits Mux4to1 write selector output
    output logic        reti_o,     // 1 bit flag register write enable output
    output logic        DPMux_o,    // 1 bit Rs2 or Rd selector
    // PC unit outputs
    output logic        PCEn_o,     // 1 bit progcounter write enable
    output logic [3:0]  PCoper_o,   // 4 bits newPC operation output
    output logic        ret_o,      // 1 bit stack pop output
        //output logic        jsb_o,      // 1 bit stack push output 
        //output logic        int_o,      // 1 bit IntReg write enable output
    // IDK these outputs
    output logic        stb_o,      // 1 bit standby output
    output logic        cyc_o,      // 1 bit cycle output
    // Data memory outputs
    output logic        port_we_o,  // 1 bit port data enable
    output logic        data_we_o,  // 1 bit data memory write enable output
    output logic        data_stb_o, // 1 bit data memory standby output
    output logic        data_cyc_o,  // 1 bit data memory cycle output
    output logic        int_ack
);
    // State codification
    parameter fetch_state = 3'h0;
    parameter decode_state = 3'h1;
    parameter execute_state = 3'h2;
    parameter mem_state = 3'h3;
    parameter write_back_state = 3'h4;
    parameter int_state = 3'h5;

    // Types of instructions
    parameter arithmetic_logic  = 4'b1110;
    parameter shift = 3'b110;
    parameter branch = 6'b111110;
    parameter jump = 5'b11110;
    parameter mem  = 2'b10;
    parameter misc = 7'b1111110;

    // Memory and Input Output instructions
    parameter ldm = 2'b00; 
    parameter stm = 2'b01;
    parameter inp = 2'b10; 
    parameter out = 2'b11;
    
    // Branch and Input Output instructions
    parameter bz  = 2'b00; 
    parameter bnz = 2'b01;
    parameter bc  = 2'b10; 
    parameter bnc = 2'b11;

    // Jump and Input Output instructions
    parameter jmp = 1'b0; 
    parameter jsb = 1'b1;

    // Miscellaneous and Input Output instructions
    parameter ret  = 3'b000;
    parameter reti = 3'b001;
    parameter enai = 3'b010;
    parameter disi = 3'b011;
    parameter wt   = 3'b100;
    parameter stby = 3'b101;


    logic [2:0] state;
    logic [2:0] nxt_state;
    logic clkg;

    always_comb clkg = clk_i & clkEn_i; //Clock gate

    // State combinational logic
    always_comb begin
        case (state)
            fetch_state : begin
                nxt_state = (inst_ack_i) ? decode_state : fetch_state;
            end

            decode_state : begin 
                if (op_i[6:1] == branch || op_i[6:2] == jump || op_i == misc) 
                    if (!int_req)   
                        if (op_i == misc && func_i == wt || func_i == stby) 
                            nxt_state = decode_state;
                        else
                            nxt_state = fetch_state; 
                    else            
                        nxt_state = int_state;
                else
                    nxt_state = execute_state;
            end

            execute_state : begin
                if (op_i[6:5] == mem && data_ack_i && ~int_req)
                    if (op_i[4:3] == stm || op_i[4:3] == out)
                        nxt_state = fetch_state;
                    else
                        nxt_state = write_back_state;
                else if (op_i[6:5] == mem && ~data_ack_i)
                    nxt_state = mem_state;
                else if (op_i[6:5] != mem)
                    nxt_state = write_back_state;
                else
                    nxt_state = int_state;
            end

            mem_state: begin
                if (op_i[6:5] == mem && ~data_ack_i)
                    nxt_state = mem_state;
                else if (op_i[4:3] == ldm || op_i[4:3] == inp && data_ack_i)
                    nxt_state = write_back_state;
                else
                    if (~int_req)
                        nxt_state = fetch_state;
                    else
                        nxt_state = int_state;
            end

            write_back_state: begin
                if (~int_req)
                    nxt_state = fetch_state;
                else
                    nxt_state = int_state;
            end

            int_state: begin
                nxt_state = fetch_state;
            end

            default: nxt_state = fetch_state;
        endcase
    end

    // Outputs combinational logic
    always_comb op2_o = ( state == execute_state && op_i[6:5] == mem ) ? 1'b0 : op_i[6];

    // ALU operation && Flag register ALU write enable
    always_comb begin
        if ((op_i[6:4] == arithmetic_logic || op_i[6] == 1'b0) && state == execute_state) begin
            ALUFR_o = 1'b1;
            ALUEn_o = 1'b1;
            RegWrt_o = 1'b1;
            RegMux_o = 2'bx;
            if (op_i[6] == 1'b1)
                ALUOp_o = { 1'b0, func_i};    // WXYZ rs2
            else 
                ALUOp_o = { 1'b0,  op_i[5:3]}; // Immed
        end
        else if (state == execute_state && op_i[6:4] == shift) begin
            ALUOp_o = {1'b1, func_i};       // Shift ALU operation 
            ALUFR_o = 1'b1;                 // Carry & Zero affected
            ALUEn_o = 1'b1;
            RegWrt_o = 1'b1;
            RegMux_o = 2'bx;
        end
        else if ((state == execute_state || state == mem_state) && op_i[6:5] == mem) begin
            ALUOp_o = {2'b00, op_i[4:3]};   // Memory IO instruction ALU operation
            ALUFR_o = 1'b0;                 // Carry & Zero not affected 
            ALUEn_o = 1'b1; 
            RegWrt_o = 1'b1;
            RegMux_o = op_i[4:3];      
        end 
        else begin
            ALUOp_o = 4'bx;
            ALUFR_o = 1'b0;
            ALUEn_o = 1'b0;
            RegWrt_o = 1'b0;
            RegMux_o = 2'bx;
        end
    end

    always_comb begin
        if ( state == decode_state ) begin
            if ( op_i[6:1] == branch ) begin
                if (func_i[2:0] == bz)
                    PCoper_o = 4'b0100;
                else if (func_i[2:0] == bnz)
                    PCoper_o = 4'b0101;
                else if (func_i[2:0] == bc)
                    PCoper_o = 4'b0110;
                else
                    PCoper_o = 4'b0111;
            end
            else if (op_i[6:2] == jump) 
                PCoper_o = 4'b1000;
            else if (op_i == misc) begin
                if (func_i == ret)
                    PCoper_o = 4'b1010;
                else if (func_i == reti)
                    PCoper_o = 4'b1100;
                else
                    PCoper_o = 4'b0000; 
            end
            else
                PCoper_o = 4'b0000;
        end
        else if ( state == fetch_state )
            PCoper_o = 4'b0000; // PC = PC + 1
        else
            PCoper_o = 4'bx;
    end

    always_comb begin
        if (state == decode_state) begin
            if (op_i == misc && func_i == stby || func_i == wt)
                PCEn_o = 1'b0;
            else
                PCEn_o = 1'b1;
        end
        else
            PCEn_o = 1'b0;
    end
    
    
    // Interruption
    //always_comb jsb_o = (state == int_state) ? 1'b1 : 1'b0; // Don´t care
    //always_comb int_o = (state == int_state) ? 1'b1 : 1'b0; // Dont´t care


    // After interruption
    always_comb ret_o = (state == fetch_state) ? 1'b1 : 1'b0;
    always_comb reti_o = (state == fetch_state) ? 1'b1 : 1'b0;
    
    always_comb begin
        if (state == write_back_state || state == mem_state) begin
            data_we_o = 1'b1;
            data_stb_o = 1'b1;
            data_cyc_o = 1'b1;
        end
        else begin
            data_we_o = 1'b0;
            data_stb_o = 1'b0;
            data_cyc_o = 1'b0;
        end
    end

    always_comb begin
        if (state == write_back_state || state == mem_state && data_ack_i) begin
            stb_o = 1'b1;
            cyc_o = 1'b1;
        end
        else begin
            stb_o = 1'b0;
            cyc_o = 1'b0;
        end        
    end

    always_comb DPMux_o = (state == execute_state || state == mem_state && func_i[1:0] == inp || func_i[1:0] == out) ? 1'b1 : 1'b0;

    always_comb port_we_o = (data_ack_i) ? 1'b1 : 1'b0;

    always_comb int_ack = int_req;

    // Sequential logic
    always_ff @( posedge clkg or posedge rst_i ) begin
        if ( rst_i ) begin
            state <= fetch_state;
        end
        else begin
            state <= nxt_state;
        end    
    end
endmodule