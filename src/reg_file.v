module reg_file(clk, rst, wr_en, wr_address, wr_data, read_ra_address, read_rb_address, push, pop
, ra_data, rb_data);

    input rst;
    input clk;
    input wr_en;
    input [1:0] wr_address; // which register to write to
    input [7:0] wr_data;
    input [1:0] read_ra_address;
    input [1:0] read_rb_address; 
    input push;
    input pop;
    output [7:0] ra_data; 
    output [7:0] rb_data;
    reg [7:0] R0;
    reg [7:0] R1;
    reg [7:0] R2;
    reg [7:0] R3;


    always @(posedge clk or posedge rst) begin
        if (rst) begin
            R0 <= 8'b0;
            R1 <= 8'b0;
            R2 <= 8'b0;
            R3 <= 8'b11111111;
        end
        else begin
            if (push) begin
                R3 <= R3 - 1;
            end
            else if (pop) begin     
                R3 <= R3 + 1;
            end
            // Write operation
            else if (wr_en) begin
                case (wr_address)
                    2'b00: R0 <= wr_data;
                    2'b01: R1 <= wr_data;
                    2'b10: R2 <= wr_data;
                    2'b11: R3 <= wr_data;
                endcase
            end
        end
    end
     // Read operations
    assign ra_data = (read_ra_address == 2'b00) ? R0 :
                     (read_ra_address == 2'b01) ? R1 :
                     (read_ra_address == 2'b10) ? R2 :
                     (read_ra_address == 2'b11) ? R3 : 8'b0;


    assign rb_data = (read_rb_address == 2'b00) ? R0 :
                     (read_rb_address == 2'b01) ? R1 :
                     (read_rb_address == 2'b10) ? R2 :
                     (read_rb_address == 2'b11) ? R3 : 8'b0;
endmodule
