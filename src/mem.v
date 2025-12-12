module mem #(
    parameter Data_width = 8,
    parameter Addr_width = 8,
    parameter Depth      = 256
) (
    input wire clk, wr_en,
    input wire [Data_width-1:0] wr_data, 
    input wire [Addr_width-1:0] address,
    output wire [Data_width-1:0] rd_data
);

reg [Data_width-1:0] mem [0:Depth-1];

// sync write 
always @(posedge clk) begin
    if (wr_en) begin
        mem[address] <= wr_data;
    end
end

// async read 
assign rd_data = mem[address];
    
endmodule