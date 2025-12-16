module top_module (clk, rst, interrupt, in, out);
    // processor inputs and outputs
    input clk, rst, interrupt;
    input [7:0] in;
    output [7:0] out;

    // pc inputs and outputs
    wire pc_counter_en, pc_load_en;
    reg [7:0] pc_load;
    wire [7:0] pc_out;

    // pc inst.
    PC PC_inst(.clk(clk), .rst(rst), .counter_en(pc_counter_en), .load_en(pc_load_en),
                .load(pc_load), .inst(pc_out));

    // memory inputs and outputs
    wire mem_wr_en, mem_pop;
    wire [1:0] mem_sel;
    wire [7:0] mem_sp, mem_instruction, mem_interrupt, mem_data;
    wire [7:0] mem_wr_data;
    wire [7:0] mem_rd_data;

    // mem inst.
    mem_wrapper mem_wrapper_inst(.clk(clk), .wr_en(mem_wr_en), .pop(mem_pop),
                                    .sel(mem_sel), .SP(mem_sp), .Instruction(mem_instruction),
                                    .interrupt(mem_interrupt), .data(mem_data),
                                    .wr_data(mem_wr_data), .rd_data(mem_rd_data));

    // reg file inputs and outputs
    wire reg_wr_en, reg_push, reg_pop;
    wire [1:0] reg_read_ra_address, reg_read_rb_address, reg_wr_address;
    wire [7:0] reg_ra_data, reg_rb_data, reg_wr_data;

    // reg file inst.
    reg_file reg_file_inst(.clk(clk), .rst(rst), .wr_en(reg_wr_en), .push(reg_push), .pop(reg_pop), .wr_data(reg_wr_data),
                            .read_ra_address(reg_read_ra_address), .read_rb_address(reg_read_rb_address),
                            .wr_address(reg_wr_address), .ra_data(reg_ra_data), .rb_data(reg_rb_data));

    // hazards unit inputs and outputs
    wire hazard_execute_use_ra, hazard_execute_use_rb, hazard_decode_use_ra, hazard_decode_use_rb;
    wire hazard_memory_writes, hazard_wb_writes, hazard_is_memory_instruction;
    wire [1:0] hazard_execute_ra, hazard_execute_rb, hazard_decode_ra, hazard_decode_rb;
    wire [1:0] hazard_mem_dest, hazard_wb_dest;
    wire hazard_fwd_A_memory_execute, hazard_fwd_B_memory_execute;
    wire hazard_fwd_A_wb_decoe, hazard_fwd_B_wb_decode, hazard_fwd_A_wb_execute, hazard_fwd_B_wb_execute;
    wire hazard_stall_structural, hazard_stall_data;

    // hazards unit inst.
    Hazard_Unit Hazard_Unit_inst(.execute_use_ra(hazard_execute_use_ra), .execute_use_rb(hazard_execute_use_rb),
                                    .decode_use_ra(hazard_decode_use_ra), .decode_use_rb(hazard_decode_use_rb),
                                    .memory_writes(hazard_memory_writes), .wb_writes(hazard_wb_writes),
                                    .is_memory_instruction(hazard_is_memory_instruction),
                                    .decode_ra(hazard_decode_ra), .decode_rb(hazard_decode_rb),
                                    .execute_ra(hazard_execute_ra), .execute_rb(hazard_execute_rb),
                                    .mem_dest(hazard_mem_dest), .wb_dest(hazard_wb_dest),
                                    .fwd_A_memory_execute(hazard_fwd_A_memory_execute),
                                    .fwd_B_memory_execute(hazard_fwd_B_memory_execute),
                                    .fwd_A_wb_execute(hazard_fwd_A_wb_execute),
                                    .fwd_B_wb_execute(hazard_fwd_B_wb_execute),
                                    .fwd_A_wb_decode(hazard_fwd_A_wb_decode),
                                    .fwd_B_wb_decode(hazard_fwd_B_wb_decode),
                                    .stall_structural(hazard_stall_structural), .stall_data(hazard_stall_data));

    // execution stage inputs and outputs
    wire ex_en_ccr, ex_load_status, ex_store_status;
    wire [1:0] ex_sel;
    wire [3:0] ex_opcode;
    wire signed [7:0] ex_A; 
    reg signed [7:0] ex_B;
    wire ex_flag, z;
    wire signed [7:0] ex_out;

    // execution stage inst.
    EX_stage EX_stage_inst(.clk(clk), .rst(rst), .EN_CCR(ex_en_ccr),
                            .load_status(ex_load_status), .store_status(ex_store_status),
                            .sel(ex_sel), .opcode(ex_opcode), .A(ex_A), .B(ex_B),
                            .flag(ex_flag), .Z(ex_z), .out(ex_out));

    // CU inputs and outputs
    wire cu_pc_saved;
    wire [7:0] cu_instruction;
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
    wire cu_use_ra;
    wire cu_use_rb;

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
                .flush_1_instruction(cu_flush_1_instrucion),
                .flush_2_instructions(cu_flush_2_instrucions),
                .flush_3_instructions(cu_flush_3_instrucions),
                .push_pc(cu_push_pc),
                .pop_pc(cu_pop_pc),
                .current_next_PC_sel(cu_current_next_pc_sel),
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
                .out_en(cu_out_en),
                .use_ra(cu_use_ra),
                .use_rb(cu_use_rb));

    // F/D register
    reg [7:0] r1_instruction;
    reg [7:0] r1_pc_out;
    reg r2_flush_2_instructions; // D/Ex forwarded
    reg r3_flush_3_instructions; // Ex/M forwarded

    always @(posedge clk or posedge rst) begin
        if (rst || cu_flush_1_instrucion ||
            (r2_flush_2_instructions && pc_load_en) ||
            r3_flush_3_instructions || hazard_stall_structural) begin
            r1_instruction <= 0;
            r1_pc_out <= 0;
        end else if (!hazard_stall_data) begin
            r1_instruction <= mem_rd_data;
            r1_pc_out <= pc_out;
        end
    end

    // D/Ex register
    reg r2_reg_wr_en;
    reg r2_reg_wr_addr_sel;
    reg r2_reg_wr_data_sel;
    reg r2_pop;
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
    reg [7:0] r2_pc_out;
    reg [7:0] r2_next_pc;
    reg signed [7:0] r2_in;
    reg signed [7:0] r2_immediate;
    reg signed [7:0] r2_da;
    reg signed [7:0] r2_db;
    reg [1:0] r2_ra;
    reg [1:0] r2_rb;
    reg r2_use_ra;
    reg r2_use_rb;
    reg r2_interrupt_mode;
    reg signed [7:0] daf; // decode fwd
    reg signed [7:0] dbf; // decode fwd

    always @(posedge clk or posedge rst) begin
        if (rst || cu_load_flags) begin
            r2_interrupt_mode <= 0;
        end else if (cu_pc_saving) begin
            r2_interrupt_mode <= 1;
        end

        if (rst || (r2_flush_2_instructions && pc_load_en) ||
            r3_flush_3_instructions) begin
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
            r2_use_ra <= 0;
            r2_use_rb <= 0;

            if (r2_interrupt_mode) begin
                r2_mem_interface_sel <= 2;
            end else begin
                r2_mem_interface_sel <= 1;
            end
        end else if (!hazard_stall_data) begin
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
            r2_da <= daf;
            r2_db <= dbf;
            r2_ra <= reg_read_ra_address;
            r2_rb <= reg_read_rb_address;
            r2_use_ra <= cu_use_ra;
            r2_use_rb <= cu_use_rb;
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
    reg r3_curr_pc_sel;
    reg r3_pc_saving;
    reg r3_reg_wr_en;
    reg r3_reg_wr_addr_sel;
    reg r3_reg_wr_data_sel;
    reg [1:0] r3_ra;
    reg [1:0] r3_rb;
    reg r3_interrupt_mode;
    reg signed [7:0] dbb; // from the forwarding dbb

    always @(posedge clk or posedge rst) begin
        if (rst || r2_load_flags) begin
            r3_interrupt_mode <= 0;
        end else if (r2_pc_saving) begin
            r3_interrupt_mode <= 1;
        end

        if (rst || r3_flush_3_instructions || hazard_stall_data) begin
            r3_alu_out <= 0;
            r3_db <= 0;
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

            if (r3_interrupt_mode) begin
                r3_mem_interface_sel <= 2;
            end else begin
                r3_mem_interface_sel <= 1;
            end
        end else begin
            r3_alu_out <= ex_out;
            r3_db <= dbb;
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
            r3_ra <= r2_ra;
            r3_rb <= r2_rb;
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

    // flag selector mux
    reg selected_flag;

    always @(*) begin
        case (r2_branch_flag)
            2'b00: selected_flag = ex_flag;
            2'b01: selected_flag = ex_z;
            2'b10: selected_flag = 1;
            2'b11: selected_flag = 1;
        endcase
    end

    // pc counter enable
    assign pc_counter_en = ~(hazard_stall_data | hazard_stall_structural);

    // pc counter load enable
    assign pc_load_en = (r2_pc_load_en | r3_pop_pc) &
                        (selected_flag | r3_pop_pc | r2_pc_load_data_sel);

    // pc load data
    always @(*) begin
        case ({r3_pop_pc, r2_pc_load_data_sel})
            2'b00: pc_load = dbb;
            2'b01: pc_load = 0;
            2'b10: pc_load = mem_rd_data;
            2'b11: pc_load = mem_rd_data;
        endcase
    end

    // reg file ra
    assign reg_read_ra_address = (cu_read_reg_a_sel)? 2'b11 : r1_instruction[3:2];

    // reg file rb
    assign reg_read_rb_address = (cu_read_reg_b_sel)? 2'b11 : r1_instruction[1:0];

    // reg file write enable
    assign reg_wr_en = r4_reg_wr_en;

    // reg file write address
    assign reg_wr_address = (r4_reg_wr_addr_sel)? r4_rb : r4_ra;

    // reg file write data
    assign reg_wr_data = (r4_reg_wr_data_sel)? r4_mem_out : r4_alu_out;

    // reg file push
    assign reg_push = cu_push;

    // reg file pop
    assign reg_pop = cu_pop;

    // forwarding da
    reg signed [7:0] daa;

    always @(*) begin
        case ({hazard_fwd_A_memory_execute, hazard_fwd_A_wb_execute})
            2'b00: daa = r2_da;
            2'b01: daa = reg_wr_data;
            2'b10: daa = r3_alu_out;
            2'b11: daa = r3_alu_out;
        endcase
    end

    // forwarding db
    always @(*) begin
        case ({hazard_fwd_B_memory_execute, hazard_fwd_B_wb_execute})
            2'b00: dbb = r2_db;
            2'b01: dbb = reg_wr_data;
            2'b10: dbb = r3_alu_out;
            2'b11: dbb = r3_alu_out;
        endcase
    end

    // forwarding da before r2
    always @(*) begin
        if (hazard_fwd_A_wb_decode) begin
            daf = reg_wr_data;
        end else begin
            daf = reg_ra_data;
        end
    end

    // forwarding db before r2
    always @(*) begin
        if (hazard_fwd_B_wb_decode) begin
            dbf = reg_wr_data;
        end else begin
            dbf = reg_rb_data;
        end
    end

    // Ex_stage A
    assign ex_A = daa;

    // Ex_stage B
    always @(*) begin
        case (r2_alu_B_sel)
            2'b00: ex_B = daa;
            2'b01: ex_B = dbb;
            2'b10: ex_B = r2_immediate;
            2'b11: ex_B = r2_in;
        endcase
    end

    // Ex_stage CCR selector
    assign ex_sel = r2_flag_addr;

    // Ex_stage CCR enable
    assign ex_en_ccr = r2_flag_en;

    // Ex_stage load status
    assign ex_load_status = r2_load_flags;

    // Ex_stage store status
    assign ex_store_status = r2_store_flags;

    // Ex_stage alu opcode
    assign ex_opcode = r2_alu_op;

    // memory write enable
    assign mem_wr_en = r3_mem_wr_en;

    // memory selector
    assign mem_sel = r3_mem_interface_sel;

    // memory instruction
    assign mem_instruction = pc_out;

    // memory interrupt
    assign mem_interrupt = pc_out;

    // memory sp
    assign mem_sp = r3_alu_out;

    // memory data
    assign mem_data = r3_alu_out;

    // memory pop
    assign mem_pop = r3_pop;

    // memory write data
    assign mem_wr_data = (r3_push_pc)? ((r3_curr_pc_sel)? r3_pc_out : r3_next_pc) : r3_db;

    // out
    assign out = (r4_out_en)? r4_alu_out : 0;

    // CU instruction
    assign cu_instruction = r1_instruction;

    // CU pc_saved
    assign cu_pc_saved = r3_pc_saving;

    // hazards unit inputs
    assign hazard_decode_use_ra = cu_use_ra;
    assign hazard_decode_use_rb = cu_use_rb;
    assign hazard_execute_use_ra = r2_use_ra;
    assign hazard_execute_use_rb = r2_use_rb;
    assign hazard_memory_writes = r3_wr_to_reg;
    assign hazard_wb_writes = r4_wr_to_reg;
    assign hazard_is_memory_instruction = r3_use_mem;
    assign hazard_decode_ra = reg_read_ra_address;
    assign hazard_decode_rb = reg_read_rb_address;
    assign hazard_execute_ra = r2_ra;
    assign hazard_execute_rb = r2_rb;
    assign hazard_mem_dest = r3_dest_addr;
    assign hazard_wb_dest = r4_dest_addr;
endmodule