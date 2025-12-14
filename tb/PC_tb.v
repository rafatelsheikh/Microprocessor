module PC_tb ();
    reg clk;
    reg rst;
    reg counter_en_tb;
    reg load_en_tb;
    reg [7:0] load_tb;
    wire [7:0] inst_dut;
    reg [7:0] inst_exp;

    PC dut (clk, rst, counter_en_tb, load_en_tb, load_tb, inst_dut);

    initial begin
        clk = 0;
        forever begin
            #1 clk = ~clk;
        end
    end

    initial begin
        // reset
        rst = 1;

        counter_en_tb = 0;
        load_en_tb = 0;
        load_tb = 0;

        inst_exp = 0;
        
        @(negedge clk)

        if (inst_dut != inst_exp) begin
            $display("Error, rst: %b, counter_en: %b, load_en: %b, load: %h, inst_dut: %h, inst_exp: %h",
                        rst, counter_en_tb, load_en_tb, load_tb, inst_dut, inst_exp);
        end

        // load
        rst = 0;

        counter_en_tb = 0;
        load_en_tb = 1;
        load_tb = 8'h34;

        inst_exp = load_tb;
        
        @(negedge clk)

        if (inst_dut != inst_exp) begin
            $display("Error, rst: %b, counter_en: %b, load_en: %b, load: %h, inst_dut: %h, inst_exp: %h",
                        rst, counter_en_tb, load_en_tb, load_tb, inst_dut, inst_exp);
        end

        // counter
        counter_en_tb = 1;
        load_en_tb = 0;
        load_tb = 0;

        inst_exp = inst_exp + 1;
        
        @(negedge clk)

        if (inst_dut != inst_exp) begin
            $display("Error, rst: %b, counter_en: %b, load_en: %b, load: %h, inst_dut: %h, inst_exp: %h",
                        rst, counter_en_tb, load_en_tb, load_tb, inst_dut, inst_exp);
        end

        // stall
        counter_en_tb = 0;
        load_en_tb = 0;
        load_tb = 0;

        inst_exp = inst_exp;
        
        @(negedge clk)

        if (inst_dut != inst_exp) begin
            $display("Error, rst: %b, counter_en: %b, load_en: %b, load: %h, inst_dut: %h, inst_exp: %h",
                        rst, counter_en_tb, load_en_tb, load_tb, inst_dut, inst_exp);
        end

        // load over counter
        counter_en_tb = 1;
        load_en_tb = 1;
        load_tb = 8'hab;

        inst_exp = load_tb;
        
        @(negedge clk)

        if (inst_dut != inst_exp) begin
            $display("Error, rst: %b, counter_en: %b, load_en: %b, load: %h, inst_dut: %h, inst_exp: %h",
                        rst, counter_en_tb, load_en_tb, load_tb, inst_dut, inst_exp);
        end

        // reset after load
        rst = 1;

        counter_en_tb = 1;
        load_en_tb = 1;
        load_tb = 8'hab;

        inst_exp = 0;
        
        @(negedge clk)

        if (inst_dut != inst_exp) begin
            $display("Error, rst: %b, counter_en: %b, load_en: %b, load: %h, inst_dut: %h, inst_exp: %h",
                        rst, counter_en_tb, load_en_tb, load_tb, inst_dut, inst_exp);
        end

        $stop;
    end
endmodule