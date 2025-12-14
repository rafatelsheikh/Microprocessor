module ALU(
    input signed [7:0]A,B,
    input [3:0]opcode,
    input Cin,
    output reg signed [7:0]out,
    output reg Z,C,V,N,
    output reg Z_update,C_update,V_update,N_update  
);

localparam ADD      = 4'd0,
           SUB      = 4'd1,
           AND      = 4'd2,
           OR       = 4'd3,
           RLC      = 4'd4,
           RRC      = 4'd5,
           SET_C    = 4'd6,
           CLR_C    = 4'd7,
           NOT_B    = 4'd8,
           NEG_B    = 4'd9,
           INC_B    = 4'd10,
           DEC_B    = 4'd11,
           BYPASS_B = 4'd12,
           BYPASS_A = 4'd13;

//ALU block
always @(*) begin

        case (opcode)
        
            ADD: begin
                {C,out} = A + B;
                Z_update = 1;
                N_update = 1;
                C_update = 1;
                V_update = 1;
            end

            SUB: begin
                {C,out} = A - B;
                Z_update = 1;
                N_update = 1;
                C_update = 1;
                V_update = 1;
            end

            AND: begin
                {C,out}  = A & B;
                Z_update = 1;
                N_update = 1;
                C_update = 0;
                V_update = 0;
            end

            OR: begin
                {C,out}  = A | B;
                Z_update = 1;
                N_update = 1;
                C_update = 0;
                V_update = 0;
            end

            RLC: begin
                {C,out} = {B,Cin};
                Z_update = 0;
                N_update = 0;
                C_update = 1;
                V_update = 0;
            end

            RRC: begin
                {out,C} = {Cin,B};
                Z_update = 0;
                N_update = 0;
                C_update = 1;
                V_update = 0;
            end

            SET_C: begin
                {C,out} = {1'b1,8'b0};
                Z_update = 0;
                N_update = 0;
                C_update = 1;
                V_update = 0;
            end

            CLR_C: begin
                {C,out} = 0;
                Z_update = 0;
                N_update = 0;
                C_update = 1;
                V_update = 0;
            end

            NOT_B: begin
                {C,out} = ~B;
                Z_update = 1;
                N_update = 1;
                C_update = 0;
                V_update = 0;
            end

            NEG_B: begin
                {C,out} = (~B) + 1;
                Z_update = 1;
                N_update = 1;
                C_update = 0;
                V_update = 0;
            end

            INC_B: begin
                {C,out} = B + 1;
                Z_update = 1;
                N_update = 1;
                C_update = 1;
                V_update = 1;
            end

            DEC_B: begin
                {C,out} = B -1 ;
                Z_update = 1;
                N_update = 1;
                C_update = 1;
                V_update = 1;
            end

            BYPASS_B: begin
                {C,out} = {1'b0,B};
                Z_update = 0;
                N_update = 0;
                C_update = 0;
                V_update = 0;
            end

            BYPASS_A: begin
                {C,out} = {1'b0,A};
                Z_update = 0;
                N_update = 0;
                C_update = 0;
                V_update = 0;
            end

            default: begin
                {C,out} = 0; 
                Z_update = 0;
                N_update = 0;
                C_update = 0;
                V_update = 0;
            end 

            
        endcase
end

always @(out,C) begin
    
    //Zero flag
    Z = (out == 0);

    //Negative flag
    N = out[7];

    //Carry flag calculated with the out

    //overflow flag
    V = C ^ out[7];

end


endmodule
