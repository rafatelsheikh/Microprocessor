module top_module (clk, rst, interrupt, in, out);
    // processor inputs and outputs
    input clk, rst, interrupt;
    input [7:0] in;
    output [7:0] out;

    // pc inputs and outputs
    reg pc_counter_en, pc_load_en;
    reg [7:0] pc_load;
    wire [7:0] pc_out;

    // pc inst.
    pc pc_inst(.clk(clk), .rst(rst), .counter_en(pc_counter_en), .load_en(pc_load_en),
                .load(pc_load), .instruction(pc_out));

    // memory inputs and outputs
    reg mem_wr_en, mem_pop;
    reg [1:0] mem_sel;
    reg [7:0] mem_sp, mem_instruction, mem_interrupt, mem_data;
    reg [7:0] mem_wr_data;
    wire [7:0] mem_rd_data;

    // mem inst.
    mem_wrapper mem_wrapper_inst(.clk(clk), .rst(rst), .wr_en(mem_wr_en), .pop(mem_pop),
                                    .sel(mem_sel), .SP(mem_sp), .instruction(mem_instruction),
                                    .interrupt(mem_interrupt), .data(mem_data),
                                    .wr_data(mem_wr_data), .rd_data(mem_rd_data));

    // reg file inputs and outputs
    reg reg_wr_en, reg_push, reg_pop;
    reg [1:0] reg_read_ra_address, reg_read_rb_address, reg_wr_address;
    wire [7:0] reg_ra_data, reg_rb_data;

    // reg file inst.
    reg_file reg_file_inst(.clk(clk), .rst(rst), .wr_en(reg_wr_en), .push(reg_push), .pop(reg_pop),
                            .read_ra_address(reg_read_ra_address), .read_rb_address(reg_read_rb_address),
                            .wr_address(reg_wr_address), .ra_data(reg_ra_data), .rb_data(reg_rb_data));

    // hazards unit inputs and outputs
    reg hazard_execute_use_ra, hazard_execute_use_rb;
    reg hazard_memory_writes, hazard_wb_writes, hazard_is_memory_instruction;
    reg [1:0] hazard_execute_ra, hazard_execute_rb;
    reg [1:0] hazard_mem_dist, hazard_wb_dist;
    wire hazard_fwd_A_memory_execute, hazard_fwd_B_memory_execute;
    wire hazard_fwd_A_wb_execute, hazard_fwd_B_wb_execute;
    wire hazard_stall_structural, hazard_stall_data;

    // hazards unit inst.
    hazards_unit hazards_unit_inst(.execute_use_ra(hazard_execute_use_ra), .execute_use_rb(hazard_execute_use_rb),
                                    .memory_writes(hazard_memory_writes), .wb_writes(hazard_wb_writes),
                                    .is_memory_instruction(hazard_is_memory_instruction),
                                    .execute_ra(hazard_execute_ra), .execute_rb(hazard_execute_rb),
                                    .mem_dist(hazard_mem_dist), .wb_dist(hazard_wb_dist),
                                    .fwd_A_memory_execute(hazard_fwd_A_memory_execute),
                                    .fwd_B_memory_execute(hazard_fwd_B_memory_execute),
                                    .fwd_A_wb_execute(hazard_fwd_A_wb_execute),
                                    .fwd_B_wb_execute(hazard_fwd_B_wb_execute),
                                    .stall_strucural(hazard_stall_structural), .stall_data(hazard_stall_data));

    // execution stage inputs and outputs
    reg ex_en_ccr, ex_load_status, ex_store_status;
    reg [1:0] ex_sel;
    reg [3:0] ex_opcode;
    rg signed [7:0] ex_A, ex_B;
    wire ex_flag, z;
    wire signed [7:0] ex_out;

    // execution stage inst.
    EX_stage EX_stage_inst(.clk(clk), .rst(rst), .EN_CCR(ex_en_ccr),
                            .load_status(ex_load_status), .store_status(ex_store_status),
                            .sel(ex_sel), .opcode(ex_opcode), .A(ex_A), .B(ex_B),
                            .flag(ex_flag), .z(ex_z), .out(ex_out));

    // CU inputs and outputs
    reg cu_pc_saved;
    reg [7:0] cu_instruction;
    wire cu_write_reg_en;
    wire cu_write_reg_address_sel;
    wire cu_write_reg_data_sel;
    wire cu_read_reg_a_sel;
    wire cu_read_reg_b_sel;
    wire cu_push;
    wire cu_pop;
    wire cu_flush_1_instrucion;
    wire cu_flush_2_instrucions;
    wire cu_flush_3_instrucions;
    wire cu_push_pc;
    wire cu_pop_pc;
    wire cu_current_next_pc_sel;
    wire cu_pc_saving;
    wire [3:0] cu_alu_op;
    wire [1:0] cu_alu_B_sel;
    wire cu_flag_en;
    wire [1:0] cu_flag_address;
    wire [1:0] cu_branch_flag;
    wire cu_store_flags;
    wire cu_load_flags;
    wire cu_pc_load_en;
    wire cu_pc_load_data_sel;
    wire cu_mem_wr_en;
    wire [1:0] cu_mem_interface_sel;
    wire cu_write_to_reg;
    wire [1:0] cu_destination_addr;
    wire cu_use_memory;
    wire cu_out_en;

    // CU inst.
    CU CU_inst(.clk(clk),
                .rst(rst),
                .interrupt(interrupt),
                .pc_saved(cu_pc_saved),
                .instruction(cu_instruction),
                .write_reg_en(cu_write_reg_en),
                .write_reg_address_sel(cu_write_reg_address_sel),
                .write_reg_data_sel(cu_write_reg_data_sel),
                .read_reg_a_sel(cu_read_reg_a_sel),
                .read_reg_b_sel(cu_read_reg_b_sel),
                .push(cu_push),
                .pop(cu_pop),
                .flush_1_instrucion(cu_flush_1_instrucion),
                .flush_2_instrucions(cu_flush_2_instrucions),
                .flush_3_instrucions(cu_flush_3_instrucions),
                .push_pc(cu_push_pc),
                .pop_pc(cu_pop_pc),
                .current_next_pc_sel(cu_current_next_pc_sel),
                .pc_saving(cu_pc_saving),
                .alu_op(cu_alu_op),
                .alu_B_sel(cu_alu_B_sel),
                .flag_en(cu_flag_en),
                .flag_address(cu_flag_address),
                .branch_flag(cu_branch_flag),
                .store_flags(cu_store_flags),
                .load_flags(cu_load_flags),
                .pc_load_en(cu_pc_load_en),
                .pc_load_data_sel(cu_pc_load_data_sel),
                .mem_wr_en(cu_mem_wr_en),
                .mem_interface_sel(cu_mem_interface_sel),
                .write_to_reg(cu_write_to_reg),
                .destination_addr(cu_destination_addr),
                .use_memory(cu_use_memory),
                .out_en(cu_out_en));

    // F/D register
    reg [7:0] r1_instruction;
    reg [7:0] r1_pc_out;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            r1_instruction <= 0;
            r1_pc_out <= 0;
        end else begin
            r1_instruction <= mem_rd_data;
            r1_pc_out <= pc_out;
        end
    end

    // D/Ex register
    reg r2_reg_wr_en;
    reg r2_reg_wr_addr_sel;
    reg r2_reg_wr_data_sel;
    reg r2_pop;
    reg r2_flush_2_instructions;
    reg r2_flush_3_instructions;
    reg r2_push_pc;
    reg r2_pop_pc;
    reg r2_curr_pc_sel;
    reg r2_pc_saving;
    reg [3:0] r2_alu_op;
    reg [1:0] r2_alu_B_sel;
    reg r2_flag_en;
    reg [1:0] r2_flag_addr;
    reg [1:0] r2_branch_flag;
    reg r2_store_flags;
    reg r2_load_flags;
    reg r2_pc_load_en;
    reg r2_pc_load_data_sel;
    reg r2_mem_wr_en;
    reg [1:0] r2_mem_interface_sel;
    reg r2_wr_to_reg;
    reg [1:0] r2_dest_addr;
    reg r2_use_mem;
    reg r2_out_en;
    reg [7:0] r2_pc_out
    reg [7:0] r2_next_pc;
    reg signed [7:0] r2_in;
    reg signed [7:0] r2_immediate;
    reg signed [7:0] r2_da;
    reg signed [7:0] r2_db;
    reg [1:0] r2_ra;
    reg [1:0] r2_rb;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            r2_reg_wr_en <= 0;
            r2_reg_wr_addr_sel <= 0;
            r2_reg_wr_data_sel <= 0;
            r2_pop <= 0;
            r2_flush_2_instructions <= 0;
            r2_flush_3_instructions <= 0;
            r2_push_pc <= 0;
            r2_pop_pc <= 0;
            r2_curr_pc_sel <= 0;
            r2_pc_saving <= 0;
            r2_alu_op <= 0;
            r2_alu_B_sel <= 0;
            r2_flag_en <= 0;
            r2_flag_addr <= 0;
            r2_branch_flag <= 0;
            r2_store_flags <= 0;
            r2_load_flags <= 0;
            r2_pc_load_en <= 0;
            r2_pc_load_data_sel <= 0;
            r2_mem_wr_en <= 0;
            r2_mem_interface_sel <= 1;
            r2_wr_to_reg <= 0;
            r2_dest_addr <= 0;
            r2_use_mem <= 0;
            r2_out_en <= 0;
            r2_pc_out <= 0;
            r2_next_pc <= 0;
            r2_in <= 0;
            r2_immediate <= 0;
            r2_da <= 0;
            r2_db <= 0;
            r2_ra <= 0;
            r2_rb <= 0;
        end else begin
            r2_reg_wr_en <= cu_write_reg_en;
            r2_reg_wr_addr_sel <= cu_write_reg_address_sel;
            r2_reg_wr_data_sel <= cu_write_reg_data_sel;
            r2_pop <= cu_pop;
            r2_flush_2_instructions <= cu_flush_2_instrucions;
            r2_flush_3_instructions <= cu_flush_3_instrucions;
            r2_push_pc <= cu_push_pc;
            r2_pop_pc <= cu_pop_pc;
            r2_curr_pc_sel <= cu_current_next_pc_sel;
            r2_pc_saving <= cu_pc_saving;
            r2_alu_op <= cu_alu_op;
            r2_alu_B_sel <= cu_alu_B_sel;
            r2_flag_en <= cu_flag_en;
            r2_flag_addr <= cu_flag_address;
            r2_branch_flag <= cu_branch_flag;
            r2_store_flags <= cu_store_flags;
            r2_load_flags <= cu_load_flags;
            r2_pc_load_en <= cu_pc_load_en;
            r2_pc_load_data_sel <= cu_pc_load_data_sel;
            r2_mem_wr_en <= cu_mem_wr_en;
            r2_mem_interface_sel <= cu_mem_interface_sel;
            r2_wr_to_reg <= cu_write_to_reg;
            r2_dest_addr <= cu_destination_addr;
            r2_use_mem <= cu_use_memory;
            r2_out_en <= cu_out_en;
            r2_pc_out <= r1_pc_out;
            r2_next_pc <= pc_out;
            r2_in <= in;
            r2_immediate <= mem_rd_data;
            r2_da <= reg_ra_data;
            r2_db <= reg_rb_data;
            r2_ra <= reg_read_ra_address
            r2_rb <= reg_read_rb_address
        end
    end

    // Ex/M register
    reg signed [7:0] r3_alu_out;
    reg signed [7:0] r3_db;
    reg [1:0] r3_mem_interface_sel;
    reg r3_pop;
    reg r3_push_pc;
    reg r3_pop_pc;
    reg [1:0] r3_dest_addr;
    reg [7:0] r3_pc_out;
    reg [7:0] r3_next_pc;
    reg r3_wr_to_reg;
    reg r3_use_mem;
    reg r3_out_en;
    reg r3_mem_wr_en;
    reg r3_flush_3_instructions;
    reg r3_curr_pc_sel;
    reg r3_pc_saving;
    reg r3_reg_wr_en;
    reg r3_reg_wr_addr_sel;
    reg r3_reg_wr_data_sel;
    reg [1:0] r3_ra;
    reg [1:0] r3_rb;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            r3_alu_out <= 0;
            r3_db <= 0;
            r3_mem_interface_sel <= 1;
            r3_pop <= 0;
            r3_push_pc <= 0;
            r3_pop_pc <= 0;
            r3_dest_addr <= 0;
            r3_pc_out <= 0;
            r3_next_pc <= 0;
            r3_wr_to_reg <= 0;
            r3_use_mem <= 0;
            r3_out_en <= 0;
            r3_mem_wr_en <= 0;
            r3_flush_3_instructions <= 0;
            r3_curr_pc_sel <= 0;
            r3_pc_saving <= 0;
            r3_reg_wr_en <= 0;
            r3_reg_wr_addr_sel <= 0;
            r3_reg_wr_data_sel <= 0;
            r3_ra <= 0;
            r3_rb <= 0;
        end else begin
            r3_alu_out <= ex_out;
            r3_db <= r2_db;
            r3_mem_interface_sel <= r2_mem_interface_sel;
            r3_pop <= r2_pop;
            r3_push_pc <= r2_push_pc;
            r3_pop_pc <= r2_pop_pc;
            r3_dest_addr <= r2_dest_addr;
            r3_pc_out <= r2_pc_out;
            r3_next_pc <= r2_next_pc;
            r3_wr_to_reg <= r2_wr_to_reg;
            r3_use_mem <= r2_use_mem;
            r3_out_en <= r2_out_en;
            r3_mem_wr_en <= r2_mem_wr_en;
            r3_flush_3_instructions <= r2_flush_3_instructions;
            r3_curr_pc_sel <= r2_curr_pc_sel;
            r3_pc_saving <= r2_pc_saving;
            r3_reg_wr_en <= r2_reg_wr_en;
            r3_reg_wr_addr_sel <= r2_reg_wr_addr_sel;
            r3_reg_wr_data_sel <= r2_reg_wr_data_sel;
            r3_ra <= r2_rb;
            r3_rb <= r2_ra;
        end
    end

    // M/WB register
    reg r4_reg_wr_en;
    reg r4_reg_wr_addr_sel;
    reg r4_reg_wr_data_sel;
    reg [1:0] r4_ra;
    reg [1:0] r4_rb;
    reg r4_wr_to_reg;
    reg r4_out_en;
    reg [1:0] r4_dest_addr;
    reg [7:0] r4_alu_out;
    reg [7:0] r4_mem_out;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            r4_reg_wr_en <= 0;
            r4_reg_wr_addr_sel <= 0;
            r4_reg_wr_data_sel <= 0;
            r4_ra <= 0;
            r4_rb <= 0;
            r4_wr_to_reg <= 0;
            r4_out_en <= 0;
            r4_dest_addr <= 0;
            r4_alu_out <= 0;
            r4_mem_out <= 0;
        end else begin
            r4_reg_wr_en <= r3_reg_wr_en;
            r4_reg_wr_addr_sel <= r3_reg_wr_addr_sel;
            r4_reg_wr_data_sel <= r3_reg_wr_data_sel;
            r4_ra <= r3_ra;
            r4_rb <= r3_rb;
            r4_wr_to_reg <= r3_wr_to_reg;
            r4_out_en <= r3_out_en;
            r4_dest_addr <= r3_dest_addr;
            r4_alu_out <= r3_alu_out;
            r4_mem_out <= mem_rd_data;
        end
    end
endmodule