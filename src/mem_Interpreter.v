module mem_Interpreter #(
    parameter Addr_width = 8,
    parameter interrupt_offset = 0, // 0 -> 19(20)
    parameter Instruction_offset = 20, // 20 -> 99(80)
    parameter data_offset = 100, // 100 -> 199(100)
    parameter SP_offset = 0 // 200 --> 255(56)
) (
    input wire pop,
    input wire [Addr_width-1:0] interrupt, Instruction, data, SP,
    input wire [1:0] sel,
    output reg [Addr_width-1:0] address
);
always @(*) begin
       case (sel)
        2'b00: begin
            address = SP + SP_offset + pop;
        end
        2'b01: begin
           address = Instruction + Instruction_offset;

        end
        2'b10: begin
           address = interrupt + interrupt_offset;

        end 
        2'b11: begin
            address = data + data_offset;

        end
        default: begin 
            address = 0;
        end   
    endcase 
end
endmodule
