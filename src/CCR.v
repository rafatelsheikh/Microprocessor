module CCR(
    input Z,V,C,N,
    input rst,clk,en,status_restore,
    input [1:0]sel,
    input [3:0]status_reg,
    input Z_update,C_update,V_update,N_update,
    output reg flag,
    output reg [3:0]CCR
);


always @(posedge clk or posedge rst) begin

    if (rst) begin
        CCR <= 0;
    end

    else begin

        if (status_restore) begin
            CCR <= status_reg;
        end
        else if (en) begin
            
            if (Z_update) begin
                CCR[0] <= Z;
            end

            if (N_update) begin
                CCR[1] <= N;
            end

            if (C_update) begin
                CCR[2] <= C;
            end

            if (V_update) begin
                CCR[3] <= V;
            end
        end

    end
end

always @(*) begin
    flag = CCR[sel];
end

endmodule