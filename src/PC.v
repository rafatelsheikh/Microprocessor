module PC(clk, rst, counter_en, load_en, load, inst);

    input rst;
    input clk;
    input counter_en;
    input load_en;
    input [7:0] load;
    output reg [7:0] inst;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            inst <= 0;
        end
        else if (load_en) begin
            inst <= load;
        end
        else if (counter_en) begin
            inst <= inst + 1;
        end
    end

endmodule
