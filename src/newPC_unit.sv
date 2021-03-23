module newPC_unit (
    input logic     [3:0]   PCoper_i,       //Selector 
    input logic             zero_i,         //Zero flag
    input logic             carry_i,        //Carry flag
    //input logic     [11:0]  stack_addr_i,   //Stack addr
    input logic     [11:0]  ISRaddr_i,      //ISR addr
    input logic     [8:0]   offset_i,       //Branch offset
    input logic     [11:0]  addr_i,         //jump addr
    input logic     [11:0]  PC_i,           //Current
    output logic    [11:0]  PC_o            //PC output
);
    
always_comb begin
    case (PCoper_i)
        4'b0000 : PC_o = (PC_i+1);
        4'b0100 : PC_o = zero_i ? (PC_i + offset_i) : (PC_i + 1);
        4'b0101 : PC_o = !zero_i ? (PC_i + offset_i) : (PC_i + 1);
        4'b0110 : PC_o = carry_i ? (PC_i + offset_i) : (PC_i + 1);
        4'b0111 : PC_o = !carry_i ? (PC_i + offset_i) : (PC_i + 1);
        4'b1000 : PC_o = addr_i;
        4'b1100 : PC_o = ISRaddr_i;
        4'b1010 : PC_o = 12'b0; //Don't care
        default : PC_o = 12'bxx;
    endcase
end

endmodule