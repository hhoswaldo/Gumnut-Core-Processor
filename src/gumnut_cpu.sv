module gumnut_cpu (
    input logic clk_i,
    input logic rst_i,
    input logic [7:0] port_dat_i,
    output logic int_ack,
    output logic [7:0] port_adr_o,
    output logic [7:0] port_data_o,
    output logic port_we_o
);
    // Core to data mem
    logic data_cyc_e;
    logic data_stb_e;
    logic data_we_e;
    logic [7:0] data_adr_e;
    logic [7:0] data_e;

    // Data mem to core
    logic data_ack_e;
    logic data_dat_e;

    // Core to inst_mem
    logic inst_cyc_e;
    logic inst_stb_e;
    logic [7:0] inst_adr_e;

    // Inst_mem to core
    logic inst_ack_e;
    logic [7:0] inst_dat_e;

    data_mem cpu_data_mem (
        .clk_i(clk_i),
        .cyc_i(data_cyc_e),
        .stb_i(data_stb_e),
        .we_i(data_we_e),
        .ack_o(data_ack_e),
        .adr_i(data_adr_e),
        .dat_i(dat_e),
        .dat_o(dat_dat_e) 
    );

    inst_mem cpu_inst_mem (
        .clk_i(clk_i),
        .cyc_i(inst_cyc_e),
        .stb_i(inst_stb_e),
        .adr_i(inst_addr_e),
        .ack_o(inst_ack_e),
        .dat_o(inst_dat_e)
    );

    gumnut_core cpu_core (
        .clk_i(clk_i),
        .int_req(int_req), 
        .rst_i(rst_i),
        .port_dat_i(port_dat_i),
        .inst_data_i(inst_dat_e),
        .inst_ack_i(inst_ack_e), 
        .data_ack_i(data_ack_e),
        .data_dat_i(data_dat_e),
        .data_adr_o(data_adr_e),
        .data_cyc_o(data_cyc_e),
        .data_dat_o(data_e),
        .data_stb_o(data_stb_e),
        .data_we_o(data_we_e),
        .inst_adr_o(inst_adr_e),
        .inst_cyc_o(inst_cyc_e),
        .inst_stb_o(inst_stb_e),    
        .int_ack(int_ack),
        .port_adr_o(port_adr_o),
        .port_data_o(port_data_o),  
        .port_we_o(port_we_o)
    );
    
endmodule