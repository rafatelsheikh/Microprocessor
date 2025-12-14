module reg_file_tb ();
    reg clk;
    reg rst;
    reg wr_en_tb;
    reg [1:0] wr_address_tb;
    reg [7:0] wr_data_tb;
    reg [1:0] read_ra_address_tb;
    reg [1:0] read_rb_address_tb; 
    reg push_tb;
    reg pop_tb;
    wire [7:0] ra_data_dut; 
    wire [7:0] rb_data_dut;
    reg [7:0] ra_data_exp; 
    reg [7:0] rb_data_exp;

    reg_file dut (clk, rst, wr_en_tb, wr_address_tb, wr_data_tb, read_ra_address_tb,
                    read_rb_address_tb, push_tb, pop_tb, ra_data_dut, rb_data_dut);

    initial begin
        clk = 0;
        forever begin
            #1 clk = ~clk;
        end
    end

    initial begin
        // reset r0 and r1
        rst = 1;

        wr_en_tb = 0;
        wr_address_tb = 0;
        wr_data_tb = 0;
        read_ra_address_tb = 0;
        read_rb_address_tb = 1;
        push_tb = 0;
        pop_tb = 0;

        ra_data_exp = 0;
        rb_data_exp = 0;
        
        @(negedge clk)

        if ((ra_data_dut != ra_data_exp) || (rb_data_dut != rb_data_exp)) begin
            $display("Error, rst: %b, wr_en: %b, wr_address: %h, wr_data: %h, read_ra_address: %h, read_rb_address: %h, push: %b, pop: %b, ra_data_dut: %h, rb_data_dut: %h, ra_data_exp: %h, rb_data_exp: %h",
                        rst, wr_en_tb, wr_address_tb, wr_data_tb, read_ra_address_tb, read_rb_address_tb, push_tb, pop_tb, ra_data_dut, rb_data_dut, ra_data_exp, rb_data_exp);
        end

        // reset r2 and r3
        wr_en_tb = 0;
        wr_address_tb = 0;
        wr_data_tb = 0;
        read_ra_address_tb = 2;
        read_rb_address_tb = 3;
        push_tb = 0;
        pop_tb = 0;

        ra_data_exp = 0;
        rb_data_exp = 255;
        
        @(negedge clk)

        if ((ra_data_dut != ra_data_exp) || (rb_data_dut != rb_data_exp)) begin
            $display("Error, rst: %b, wr_en: %b, wr_address: %h, wr_data: %h, read_ra_address: %h, read_rb_address: %h, push: %b, pop: %b, ra_data_dut: %h, rb_data_dut: %h, ra_data_exp: %h, rb_data_exp: %h",
                        rst, wr_en_tb, wr_address_tb, wr_data_tb, read_ra_address_tb, read_rb_address_tb, push_tb, pop_tb, ra_data_dut, rb_data_dut, ra_data_exp, rb_data_exp);
        end

        // write r0 read r0 and r1
        rst = 0;

        wr_en_tb = 1;
        wr_address_tb = 0;
        wr_data_tb = 8'h52;
        read_ra_address_tb = 0;
        read_rb_address_tb = 1;
        push_tb = 0;
        pop_tb = 0;

        ra_data_exp = 8'h52;
        rb_data_exp = 0;
        
        @(negedge clk)

        if ((ra_data_dut != ra_data_exp) || (rb_data_dut != rb_data_exp)) begin
            $display("Error, rst: %b, wr_en: %b, wr_address: %h, wr_data: %h, read_ra_address: %h, read_rb_address: %h, push: %b, pop: %b, ra_data_dut: %h, rb_data_dut: %h, ra_data_exp: %h, rb_data_exp: %h",
                        rst, wr_en_tb, wr_address_tb, wr_data_tb, read_ra_address_tb, read_rb_address_tb, push_tb, pop_tb, ra_data_dut, rb_data_dut, ra_data_exp, rb_data_exp);
        end

        // write r1 push read r1 and r3
        wr_en_tb = 1;
        wr_address_tb = 1;
        wr_data_tb = 8'h24;
        read_ra_address_tb = 1;
        read_rb_address_tb = 3;
        push_tb = 1;
        pop_tb = 0;

        ra_data_exp = 8'h24;
        rb_data_exp = 254;
        
        @(negedge clk)

        if ((ra_data_dut != ra_data_exp) || (rb_data_dut != rb_data_exp)) begin
            $display("Error, rst: %b, wr_en: %b, wr_address: %h, wr_data: %h, read_ra_address: %h, read_rb_address: %h, push: %b, pop: %b, ra_data_dut: %h, rb_data_dut: %h, ra_data_exp: %h, rb_data_exp: %h",
                        rst, wr_en_tb, wr_address_tb, wr_data_tb, read_ra_address_tb, read_rb_address_tb, push_tb, pop_tb, ra_data_dut, rb_data_dut, ra_data_exp, rb_data_exp);
        end

        // write r2 pop read r3 and r2
        wr_en_tb = 1;
        wr_address_tb = 2;
        wr_data_tb = 8'h1a;
        read_ra_address_tb = 3;
        read_rb_address_tb = 2;
        push_tb = 0;
        pop_tb = 1;

        ra_data_exp = 255;
        rb_data_exp = 8'h1a;
        
        @(negedge clk)

        if ((ra_data_dut != ra_data_exp) || (rb_data_dut != rb_data_exp)) begin
            $display("Error, rst: %b, wr_en: %b, wr_address: %h, wr_data: %h, read_ra_address: %h, read_rb_address: %h, push: %b, pop: %b, ra_data_dut: %h, rb_data_dut: %h, ra_data_exp: %h, rb_data_exp: %h",
                        rst, wr_en_tb, wr_address_tb, wr_data_tb, read_ra_address_tb, read_rb_address_tb, push_tb, pop_tb, ra_data_dut, rb_data_dut, ra_data_exp, rb_data_exp);
        end

        // reset after write r0 r1
        rst = 1;

        wr_en_tb = 1;
        wr_address_tb = 2;
        wr_data_tb = 8'h1a;
        read_ra_address_tb = 0;
        read_rb_address_tb = 1;
        push_tb = 1;
        pop_tb = 0;

        ra_data_exp = 0;
        rb_data_exp = 0;
        
        @(negedge clk)

        if ((ra_data_dut != ra_data_exp) || (rb_data_dut != rb_data_exp)) begin
            $display("Error, rst: %b, wr_en: %b, wr_address: %h, wr_data: %h, read_ra_address: %h, read_rb_address: %h, push: %b, pop: %b, ra_data_dut: %h, rb_data_dut: %h, ra_data_exp: %h, rb_data_exp: %h",
                        rst, wr_en_tb, wr_address_tb, wr_data_tb, read_ra_address_tb, read_rb_address_tb, push_tb, pop_tb, ra_data_dut, rb_data_dut, ra_data_exp, rb_data_exp);
        end

        // reset after write r2 r3
        wr_en_tb = 1;
        wr_address_tb = 2;
        wr_data_tb = 8'h1a;
        read_ra_address_tb = 2;
        read_rb_address_tb = 3;
        push_tb = 1;
        pop_tb = 0;

        ra_data_exp = 0;
        rb_data_exp = 255;
        
        @(negedge clk)

        if ((ra_data_dut != ra_data_exp) || (rb_data_dut != rb_data_exp)) begin
            $display("Error, rst: %b, wr_en: %b, wr_address: %h, wr_data: %h, read_ra_address: %h, read_rb_address: %h, push: %b, pop: %b, ra_data_dut: %h, rb_data_dut: %h, ra_data_exp: %h, rb_data_exp: %h",
                        rst, wr_en_tb, wr_address_tb, wr_data_tb, read_ra_address_tb, read_rb_address_tb, push_tb, pop_tb, ra_data_dut, rb_data_dut, ra_data_exp, rb_data_exp);
        end

        $stop;
    end
endmodule