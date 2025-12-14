module EX_stage(
    input signed [7:0]A,B,
    input [3:0]opcode,
    input EN_CCR,rst,clk,load_status,store_status,
    input [1:0]sel,
    output signed [7:0]out,
    output flag,
    output  Z  
);

wire Cin_CCR_2,z_update,v_update,n_update,c_update,negative_CCR1,Carry_CCR2,overflow_CCR3;
wire [3:0]flags_status_to_ccr,flags_ccr_to_status;


ALU alu_block (
    .A(A), 
    .B(B),
    .opcode(opcode),
    .Cin(flags_ccr_to_status[2]),
    .out(out),
    .Z(Z),
    .C(Carry_CCR2),
    .V(overflow_CCR3),
    .N(negative_CCR1),
    .Z_update(z_update),
    .C_update(c_update),
    .V_update(v_update),
    .N_update(n_update)  
);


CCR flags_register_block(
    .Z(Z),
    .V(overflow_CCR3),
    .C(Carry_CCR2),
    .N(negative_CCR1),
    .rst(rst),
    .clk(clk),
    .en(EN_CCR),
    .status_restore(load_status),
    .sel(sel),
    .status_reg(flags_status_to_ccr),
    .Z_update(z_update),
    .C_update(c_update),
    .V_update(v_update),
    .N_update(n_update), 
    .flag(flag),
    .CCR(flags_ccr_to_status)
);

Status_REG status_reg_block(
    .flags_in(flags_ccr_to_status),
    .rst(rst),
    .clk(clk),
    .load_en(store_status),
    .status_flags(flags_status_to_ccr)
);


endmodule
