module EX_stage(
    input signed [7:0]A,B,
    input [3:0]opcode,
    input EN_CCR,rst,clk,load_status,store_status,
    input [1:0]sel,
    output reg signed [7:0]out,
    output flag,
    output reg Z  
);

reg [3:0] CCR,status_reg;
reg carry_flag,N;
wire Cin;

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

assign Cin = CCR[2];

//ALU block
always @(*) begin

        case (opcode)
        
            ADD: begin
                {carry_flag,out} = A + B;
            end

            SUB: begin
                {carry_flag,out} = A - B;
            end

            AND: begin
                {carry_flag,out}  = A & B;
            end

            OR: begin
                {carry_flag,out}  = A | B;
            end

            RLC: begin
                {carry_flag,out} = {B,Cin};
            end

            RRC: begin
                {out,carry_flag} = {Cin,B};
            end

            SET_C: begin
                {carry_flag,out} = {1'b1,8'b0};
            end

            CLR_C: begin
                {carry_flag,out} = 0;
            end

            NOT_B: begin
                {carry_flag,out} = ~B;
            end

            NEG_B: begin
                {carry_flag,out} = (~B) + 1;
            end

            INC_B: begin
                {carry_flag,out} = B + 1;
            end

            DEC_B: begin
                {carry_flag,out} = B -1 ;
            end

            BYPASS_B: begin
                {carry_flag,out} = {1'b0,B};
            end

            BYPASS_A: begin
                {carry_flag,out} = {1'b0,A};
            end

            default: {carry_flag,out} = 0; 
            
        endcase

        //show the zero flag as an output not from the CCR
        if (out == 0) begin
            Z = 1;
        end 
        else begin
            Z = 0;
        end

        // negative flag internal signal
        if (out < 0) begin
            N = 1;
        end 
        else begin
            N = 0;
        end

end



//CCR block

//write with clk
 always @(posedge clk or posedge rst) begin
    
    if (rst) begin
        CCR <=0 ;
    end 
    
    else begin    
        
        if(load_status) begin
            CCR <= status_reg;
        end

        else if(EN_CCR) begin

            //update the zero flag CCR[0]
            if (opcode == ADD || opcode == SUB || opcode == AND || opcode == OR || opcode == NOT_B || opcode == NEG_B || opcode == INC_B || opcode == DEC_B) begin
                CCR[0] <= Z;
            end 

            //update the negative flag CCR[1]
            if (opcode == ADD || opcode == SUB || opcode == AND || opcode == OR || opcode == NOT_B || opcode == NEG_B || opcode == INC_B || opcode == DEC_B) begin
                CCR[1] <= N;
            end 
    
            //update the carry flag CCR[2]
            if (opcode == ADD || opcode == SUB || opcode == RLC || opcode == RRC || opcode == SET_C || opcode == CLR_C || opcode == INC_B || opcode == DEC_B) begin
                CCR[2] <= carry_flag;
            end 

            //update the overflow flag CCR[3]
            if (opcode == ADD || opcode == SUB || opcode == INC_B || opcode == DEC_B) begin
                CCR[3] <= carry_flag ^ out[7];
            end 
        
        end

    end 

 end

//read async from CCR
assign flag = CCR[sel];

//status register 
always @(posedge clk or posedge rst) begin
    if (rst) begin
        status_reg <= 0;
    end 
    else begin
        if (store_status) begin
            status_reg <= CCR ;
        end
    end
end

endmodule
