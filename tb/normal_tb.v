module not_pipelined_tb ();
    reg clk, rst, interrupt_tb;
    reg [7:0] in_tb;
    wire [7:0] out_dut;

    // inist.
    top_module dut (clk, rst, interrupt_tb, in_tb, out_dut);

    initial begin
        $readmemb("test7.dat", dut.mem_wrapper_inst.M0.mem);

        clk = 0;
        forever begin
            #1 clk = ~clk;
        end
    end

    initial begin
        rst = 1;
        interrupt_tb = 0;
        in_tb = 8'hab;

        @(negedge clk);

        rst = 0;

        repeat(60) begin
            @(negedge clk);
        end

        $stop;
    end
endmodule