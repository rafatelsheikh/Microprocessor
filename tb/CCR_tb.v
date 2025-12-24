module CCR_tb();
// I/O
reg Z,V,C,N;
reg rst,clk,en,status_restore;
reg [1:0]sel;
reg [3:0]status_reg;
reg Z_update,C_update,V_update,N_update;
wire flag;
wire [3:0]CCR;

CCR DUT (Z,V,C,N,rst,clk,en,status_restore,sel,status_reg,Z_update,C_update,V_update,N_update,flag,CCR);


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
    rst = 0;
    repeat(30) begin
        Z = $random;
        V = $random;
        C = $random;
        N = $random;
        en = $random;
        status_restore = $random;
        sel = $random;
        status_reg = $random;
        Z_update = $random;
        C_update = $random;
        V_update = $random;
        N_update = $random;
        @(negedge clk);
    end

    $stop;
end
endmodule