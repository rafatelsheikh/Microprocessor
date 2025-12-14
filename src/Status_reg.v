module Status_REG(
    input[3:0] flags_in,
    input clk,rst,load_en,
    output reg [3:0] status_flags
);

always @(posedge clk or posedge rst) begin
    
    if (rst) begin
        status_flags <= 0;
    end 
    
    else begin
        if (load_en) begin
            status_flags <= flags_in;
        end
    end

end
    
endmodule