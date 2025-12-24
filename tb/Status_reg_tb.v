module Status_REG_tb();
// I/O    
reg [3:0] flags_in;
reg clk,rst,load_en;
wire [3:0] status_flags;

//test to keep
reg [3:0] last_flags;

Status_REG DUT (flags_in,clk,rst,load_en,status_flags);

//clock
initial begin
    clk = 0;
    forever begin
        #10;
        clk = ~clk;
    end 
end

initial begin
    rst = 1;
    @(negedge clk);

    if(status_flags != 0) begin
        $display("Error in the reset operation");
    end

    rst = 0;
    load_en = 1;

    repeat(5) begin
        flags_in = $random;
        @(negedge clk);

        if(status_flags != flags_in) begin
            $display("Error in loading operation");
        end
    end

    load_en = 0;
    last_flags = status_flags;

    repeat(5) begin
        flags_in = $random;
        @(negedge clk);

        if(status_flags != last_flags) begin
            $display("Error, can't keep the values");
        end
    end

    $stop;
end

endmodule