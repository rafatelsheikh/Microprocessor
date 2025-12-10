module moduleName #(
    parameter Data_width = 8,
    parameter Addr_width = 8,
    parameter Depth      = 256,
    parameter interrupt_offset = 0, // 0 -> 19(20)
    parameter Instruction_offset = 20, // 20 -> 99(80)
    parameter data_offset = 100, // 100 -> 199(100)
    parameter SP_offset = 200 // 200 --> 255(56
) (
    input wire clk, wr_en, 
    input wire [1:0] sel,
    input wire [Addr_width-1:0] interrupt, Instruction, data, SP,
    input wire [Data_width-1:0] wr_data,
    output wire [Data_width-1:0] rd_data
);

wire [Addr_width-1:0] wr_address_wire, rd_address_wire;

mem #(
    .Data_width (Data_width),     
    .Addr_width (Addr_width),     
    .Depth      (Depth)    
) M0 (
    .clk        (clk),      
    .wr_en      (wr_en),      
    .wr_data    (wr_data),      
    .wr_address (wr_address_wire),      
    .rd_address (rd_address_wire),      
    .rd_data    (rd_data)       
);

mem_Interpreter #(
    .Addr_width         (Addr_width),     
    .interrupt_offset   (interrupt_offset),     
    .Instruction_offset (Instruction_offset),    
    .data_offset        (data_offset),   
    .SP_offset          (SP_offset)    
) mem_int_M0 (
    .interrupt    (interrupt),   
    .Instruction  (Instruction),   
    .data         (data),   
    .SP           (SP),   
    .sel          (sel),  
    .wr_address   (wr_address_wire),   
    .rd_address   (rd_address_wire)    
);

endmodule