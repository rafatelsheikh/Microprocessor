module mem_Interpreter #(
    parameter Addr_width = 8,
    parameter interrupt_offset = 0, // 0 -> 19(20)
    parameter Instruction_offset = 20, // 20 -> 99(80)
    parameter data_offset = 100, // 100 -> 199(100)
    parameter SP_offset = 0 // 200 --> 255(56)
) (
    input wire [Addr_width-1:0] interrupt, Instruction, data, SP,
    input wire [1:0] sel,
    output reg [Addr_width-1:0] wr_address, rd_address
);
always @(*) begin
       case (sel)
        2'b00: begin
           wr_address = SP + SP_offset + 1;
           rd_address = SP + SP_offset; 
        end
        2'b01: begin
           wr_address = Instruction + Instruction_offset;
           rd_address = Instruction + Instruction_offset;
        end
        2'b10: begin
           wr_address = interrupt + interrupt_offset;
           rd_address = interrupt + interrupt_offset;
        end 
        2'b11: begin
            wr_address = data + data_offset;
            rd_address = data + data_offset;
        end
        default: begin 
            wr_address = 0;
            rd_address = 0;
        end   
    endcase 
end
endmodule
