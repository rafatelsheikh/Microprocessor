module ALU_tb();

// I/O    
reg [7:0]A,B;
reg [3:0]opcode;
reg Cin;
wire [7:0]out;
wire Z,C,V,N;
wire Z_update,C_update,V_update,N_update; 

//instantiate
ALU DUT (A,B,opcode,Cin,out,Z,C,V,N,Z_update,C_update,V_update,N_update);

integer i;

//test operations on same values

initial begin
    repeat (5) begin
        A = $random;
        B = $random;
        Cin = $random;

        for (i=0 ; i < 14 ; i=i+1) begin
            opcode = i;
            #2;
        end 
    end

    $stop;
end



endmodule