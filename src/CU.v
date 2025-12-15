/*
**************************************** DOCUMENTATION ****************************************
*@AUTHOR    :   Robir Tamer                                                                   *
*@FILE      :   CU.sv                                                                        *
***********************************************************************************************
*/

module CU #(
/***************************************** PARAMETERS ****************************************/
    parameter inst_w = 8,
    parameter inst_OP_w = 4,
    parameter ALU_OP_W = 4,
    parameter flag_address_w=2,
    parameter branch_flag_w = 2,
    parameter RF_Size = 4,
    parameter RF_address = $clog2(RF_Size)
)(
/******************************************* INPUTS ******************************************/
    input   wire                            clk,
    input   wire                            rst,
    input   wire                            interrupt,
    input   wire                            pc_saved,
    input   wire    [inst_w-1:0]            instruction,
/******************************************* OUTPUTS *****************************************/
    //Fetching Stage
    output  reg                             pc_load_en,
    output  reg                             pc_load_data_sel,       //0 >>>> db //1 >>>> ISR
    //Decoding Stage
    output  reg                             read_reg_a_sel,         //0 >>>> ra //1 >>>> R3
    output  reg                             read_reg_b_sel,         //0 >>>> rb //1 >>>> R3
    output  reg                             use_ra,                 //1 if the inst. uses ra
    output  reg                             use_rb,                 //1 if the inst. uses rb
    //Executing Stage
    output  reg     [ALU_OP_W-1:0]          alu_op,
    output  reg     [1:0]                   alu_B_sel,              //00 >>>> da //01 >>>> db //10 >>>> immediate //11 >>>> input
    output  reg                             flag_en,
    output  reg     [flag_address_w-1:0]    flag_address,
    //MEM Stage 
    output  reg                             push,                   //for push instruction
    output  reg                             pop,                    //for pop instruction
    output  reg                             push_pc,
    output  reg                             pop_pc,
    output  reg                             store_flags,
    output  reg                             load_flags,
    output  reg                             mem_wr_en,
    output  reg     [1:0]                   mem_interface_sel,      //0 >>>> SP //1 >>>> inst //2 >>>> interrupt //3 >>>> data
    output  reg                             use_memory,             //high if the inst uses memory
    //WB Stage
    output  reg                             write_reg_en,
    output  reg                             write_reg_address_sel,  //0 >>>> ra //1 >>>> rb
    output  reg                             write_reg_data_sel,     //0 >>>> from ALU //1 >>>> from memory
    output  reg                             write_to_reg,           //1 >>>> inst writes into reg
    output  reg     [RF_address-1:0]        destination_addr,       //writing address into RF
    //Interrupt Signals
    output  reg                             current_next_PC_sel,    //when 1 Current is interrupt (Save pc) and when 0 next is normal
    output  reg                             pc_saving,              //High as long as state is SAVE_PC
    //Flushes
    output  reg                             flush_1_instruction,    //LDM,LDD,STD
    output  reg                             flush_2_instructions,   //Loop,Call,Conditional branches
    output  reg                             flush_3_instructions,   //RET,RTI,interrupt
    //Branching
    output  reg     [branch_flag_w-1 : 0]   branch_flag,            //0 >>>> CCR //1 >>>> Direct zero flag from alu (loop) //10 >>>> 1(always jump)

    output  reg                             out_en
);
/************************************** LOCAL PARAMETERS *************************************/
//ALU Operations
localparam  add_op=0,
            sub_op=1,
            and_op=2,
            or_op=3,
            rlcb_op=4,
            rrcb_op=5,
            setc_op=6,
            clrc_op=7,
            notb_op=8,
            negb_op=9,
            incb_op=10,
            decb_op=11,
            bypassb_op=12;
//CU States 
localparam  NORMAL          = 2'b00,
            SAVE_PC         = 2'b01,
            LOAD_INERRUPT   = 2'b10,
            RUN_INTERRUPT   = 2'b11;
//Instructions
localparam  NOP             = 4'b0000,
            MOV             = 4'b0001,
            ADD             = 4'b0010,
            SUB             = 4'b0011,
            AND             = 4'b0100,
            OR              = 4'b0101,
            CARRIES         = 4'b0110,
            STACK_IO        = 4'b0111,
            COMP_STEPS      = 4'b1000,
            COND_JUMP       = 4'b1001,
            LOOP            = 4'b1010,
            UNCOND_JUMP     = 4'b1011,
            LOAD_STORE      = 4'b1100,  //2byte inst
            LDI             = 4'b1101,
            STI             = 4'b1110;
/******************************************* SIGNALS *****************************************/
reg		                CS, NS;
wire                    CI; 
wire        [1:0]           ra,rb;
/************************************** ASSIGN STATEMENTS ************************************/
assign ra = instruction [3:2];
assign rb = instruction [1:0];
assign CI = instruction [7:4];
/****************************************** SEQ ALWAYS ***************************************/
always @ (posedge clk or negedge rst)
    begin
        if (!rst)
            begin
                CS <= NORMAL;
            end
        else
            begin
                CS <= NS;
            end
    end
always @ (posedge clk or negedge rst)
    begin
        if (!rst)
            begin
                pc_load_en              <='b0;
                pc_load_data_sel        <='b0;
                read_reg_a_sel          <='b0;
                read_reg_b_sel          <='b0;
                use_ra                  <='b0;
                use_rb                  <='b0;
                alu_op                  <='b0;
                alu_B_sel               <='b0;    
                flag_en                 <='b0;
                flag_address            <='b0;
                push                    <='b0;             
                pop                     <='b0;              
                push_pc                 <='b0;
                pop_pc                  <='b0;
                store_flags             <='b0;
                load_flags              <='b0;
                mem_wr_en               <='b0;
                mem_interface_sel       <='b1;
                use_memory              <='b0;
                write_reg_en            <='b0;
                write_reg_address_sel   <='b0;
                write_reg_data_sel      <='b0;
                write_to_reg            <='b0;
                destination_addr        <='b0;
                current_next_PC_sel     <='b0;
                pc_saving               <='b0;
                flush_1_instruction     <='b0;
                flush_2_instructions    <='b0;
                flush_3_instructions    <='b0;
                branch_flag             <='b0;
                out_en                  <='b0;
            end
    end
/***************************************** COMB ALWAYS ***************************************/
//Next State Logic
always @(*)
    begin
        case (CS)
            NORMAL:         begin
                                if (interrupt)
                                    NS = SAVE_PC;
                                else
                                    NS = NORMAL;
                            end
            SAVE_PC :       begin
                                if (pc_saved)
                                    NS = LOAD_INERRUPT;
                                else
                                    NS = SAVE_PC;
                            end
            LOAD_INERRUPT : begin
                                NS = RUN_INTERRUPT;
                            end
            RUN_INTERRUPT : begin
                                if (instruction [7:2] =={UNCOND_JUMP ,2'b11} )
                                    NS = NORMAL;
                                else    
                                    NS = RUN_INTERRUPT;
                            end
            default :       begin
                                NS = NORMAL;
                            end
        endcase
    end
//Interrupt Signals
always @ (*)
    begin
        case (CS)
            NORMAL  :       begin
                                push_pc             = 'b0;
                                pop_pc              = 'b0;
                                store_flags         = 'b0;
                                load_flags          = 'b0;
                                pc_saving           = 'b0;
                                pc_load_data_sel    = 'b0;
                                pc_load_en          = 'b0;
                                current_next_PC_sel = 'b0;
                                case (CI)
                                    COND_JUMP : begin
                                                    pc_load_en          ='b1;
                                                end
                                    LOOP :      begin
                                                    pc_load_en          ='b1;
                                                end
                                    UNCOND_JUMP:begin
                                                    if (ra == 'b00)
                                                        pc_load_en ='b1;
                                                    else if (ra == 'b01)
                                                        begin
                                                            pc_load_en ='b1;
                                                            push_pc = 'b1;
                                                        end
                                                    else if (ra == 'b10)
                                                        pop_pc  ='b1;
                                                    else if (ra == 'b11)
                                                        begin
                                                            pop_pc ='b1;
                                                            store_flags ='b1;       
                                                        end
                                                end
                                    default :   begin
                                                    push_pc             = 'b0;
                                                    pop_pc              = 'b0;
                                                    store_flags         = 'b0;
                                                    load_flags          = 'b0;
                                                    pc_saving           = 'b0;
                                                    pc_load_data_sel    = 'b0;
                                                    pc_load_en          = 'b0;
                                                    current_next_PC_sel = 'b0;
                                                end
                                endcase
                            end
            SAVE_PC :       begin
                                push_pc             = 'b1;
                                pop_pc              = 'b0;
                                store_flags         = 'b1;
                                load_flags          = 'b0;
                                pc_saving           = 'b1;
                                pc_load_data_sel    = 'b0;
                                pc_load_en          = 'b0;    
                                current_next_PC_sel = 'b1;  
                            end
            LOAD_INERRUPT : begin
                                push_pc             = 'b0;
                                pop_pc              = 'b0;
                                store_flags         = 'b0;
                                load_flags          = 'b0;
                                pc_saving           = 'b0;
                                pc_load_data_sel    = 'b1;
                                pc_load_en          = 'b1;
                                current_next_PC_sel = 'b0;
                            end
            RUN_INTERRUPT : begin
                                if (instruction [7:2] !={UNCOND_JUMP ,2'b11})
                                    begin
                                        push_pc             = 'b0;
                                        pop_pc              = 'b0;
                                        store_flags         = 'b0;
                                        load_flags          = 'b0;
                                        pc_saving           = 'b0;
                                        pc_load_data_sel    = 'b0;
                                        pc_load_en          = 'b0;
                                        current_next_PC_sel = 'b0;
                                    end
                                else
                                    begin
                                        push_pc             = 'b0;
                                        pop_pc              = 'b1;
                                        store_flags         = 'b0;
                                        load_flags          = 'b1;
                                        pc_saving           = 'b0;
                                        pc_load_data_sel    = 'b0;
                                        pc_load_en          = 'b1;
                                        current_next_PC_sel = 'b0;
                                    end
                            end
            default :       begin
                                push_pc             = 'b0;
                                pop_pc              = 'b0;
                                store_flags         = 'b0;
                                load_flags          = 'b0;
                                pc_saving           = 'b0;
                                pc_load_data_sel    = 'b0;
                                pc_load_en          = 'b0;
                                current_next_PC_sel = 'b0;
                            end
        endcase
    end
always @ (*)
    begin
        if (CS == NORMAL || CS == RUN_INTERRUPT)
            begin
                case(CI)
                    NOP :       begin
                                    read_reg_a_sel          ='b0;
                                    read_reg_b_sel          ='b0;
                                    use_ra                  ='b0;
                                    use_rb                  ='b0;
                                    alu_op                  ='b0;
                                    alu_B_sel               ='b0;    
                                    flag_en                 ='b0;
                                    flag_address            ='b0;
                                    push                    ='b0;             
                                    pop                     ='b0;              
                                    mem_wr_en               ='b0;
                                    if (CS == NORMAL)
                                        mem_interface_sel   ='b1;
                                    else
                                        mem_interface_sel   ='b10;
                                    use_memory              ='b0;
                                    write_reg_en            ='b0;
                                    write_reg_address_sel   ='b0;
                                    write_reg_data_sel      ='b0;
                                    write_to_reg            ='b0;
                                    destination_addr        ='b0;
                                    flush_1_instruction     ='b0;
                                    flush_2_instructions    ='b0;
                                    flush_3_instructions    ='b0;
                                    branch_flag             ='b0;
                                    out_en                  ='b0;
                                end 
                    MOV :       begin
                                    read_reg_a_sel          ='b0;
                                    read_reg_b_sel          ='b0;
                                    use_ra                  ='b1;
                                    use_rb                  ='b1;
                                    alu_op                  =bypassb_op;
                                    alu_B_sel               ='b1;    
                                    flag_en                 ='b0;
                                    flag_address            ='b0;
                                    push                    ='b0;             
                                    pop                     ='b0;              
                                    mem_wr_en               ='b0;
                                    if (CS == NORMAL)
                                        mem_interface_sel   ='b1;
                                    else
                                        mem_interface_sel   ='b10;
                                    use_memory              ='b0;
                                    write_reg_en            ='b1;
                                    write_reg_address_sel   ='b0;
                                    write_reg_data_sel      ='b0;
                                    write_to_reg            ='b1;
                                    destination_addr        = ra;
                                    flush_1_instruction     ='b0;
                                    flush_2_instructions    ='b0;
                                    flush_3_instructions    ='b0;
                                    branch_flag             ='b0;
                                    out_en                  ='b0;
                                end
                    ADD :       begin
                                    read_reg_a_sel          ='b0;
                                    read_reg_b_sel          ='b0;
                                    use_ra                  ='b1;
                                    use_rb                  ='b1;
                                    alu_op                  =add_op;
                                    alu_B_sel               ='b1;    
                                    flag_en                 ='b1;
                                    flag_address            ='b0;
                                    push                    ='b0;             
                                    pop                     ='b0;              
                                    mem_wr_en               ='b0;
                                    if (CS == NORMAL)
                                        mem_interface_sel   ='b1;
                                    else
                                        mem_interface_sel   ='b10;
                                    use_memory              ='b0;
                                    write_reg_en            ='b1;
                                    write_reg_address_sel   ='b0;
                                    write_reg_data_sel      ='b0;
                                    write_to_reg            ='b1;
                                    destination_addr        = ra;
                                    flush_1_instruction     ='b0;
                                    flush_2_instructions    ='b0;
                                    flush_3_instructions    ='b0;
                                    branch_flag             ='b0;   
                                    out_en                  ='b0;
                                end
                    SUB :       begin
                                    read_reg_a_sel          ='b0;
                                    read_reg_b_sel          ='b0;
                                    use_ra                  ='b1;
                                    use_rb                  ='b1;
                                    alu_op                  =sub_op;
                                    alu_B_sel               ='b1;    
                                    flag_en                 ='b1;
                                    flag_address            ='b0;
                                    push                    ='b0;             
                                    pop                     ='b0;              
                                    mem_wr_en               ='b0;
                                    if (CS == NORMAL)
                                        mem_interface_sel   ='b1;
                                    else
                                        mem_interface_sel   ='b10;
                                    use_memory              ='b0;
                                    write_reg_en            ='b1;
                                    write_reg_address_sel   ='b0;
                                    write_reg_data_sel      ='b0;
                                    write_to_reg            ='b1;
                                    destination_addr        = ra;
                                    flush_1_instruction     ='b0;
                                    flush_2_instructions    ='b0;
                                    flush_3_instructions    ='b0;
                                    branch_flag             ='b0;   
                                    out_en                  ='b0;
                                end  
                    AND :       begin
                                    read_reg_a_sel          ='b0;
                                    read_reg_b_sel          ='b0;
                                    use_ra                  ='b1;
                                    use_rb                  ='b1;
                                    alu_op                  =and_op;
                                    alu_B_sel               ='b1;    
                                    flag_en                 ='b1;
                                    flag_address            ='b0;
                                    push                    ='b0;             
                                    pop                     ='b0;              
                                    mem_wr_en               ='b0;
                                    if (CS == NORMAL)
                                        mem_interface_sel   ='b1;
                                    else
                                        mem_interface_sel   ='b10;
                                    use_memory              ='b0;
                                    write_reg_en            ='b1;
                                    write_reg_address_sel   ='b0;
                                    write_reg_data_sel      ='b0;
                                    write_to_reg            ='b1;
                                    destination_addr        = ra;
                                    flush_1_instruction     ='b0;
                                    flush_2_instructions    ='b0;
                                    flush_3_instructions    ='b0;
                                    branch_flag             ='b0;   
                                    out_en                  ='b0;
                                end
                    OR :        begin
                                    read_reg_a_sel          ='b0;
                                    read_reg_b_sel          ='b0;
                                    use_ra                  ='b1;
                                    use_rb                  ='b1;
                                    alu_op                  =or_op;
                                    alu_B_sel               ='b1;    
                                    flag_en                 ='b1;
                                    flag_address            ='b0;
                                    push                    ='b0;             
                                    pop                     ='b0;              
                                    mem_wr_en               ='b0;
                                    if (CS == NORMAL)
                                        mem_interface_sel   ='b1;
                                    else
                                        mem_interface_sel   ='b10;
                                    use_memory              ='b0;
                                    write_reg_en            ='b1;
                                    write_reg_address_sel   ='b0;
                                    write_reg_data_sel      ='b0;
                                    write_to_reg            ='b1;
                                    destination_addr        = ra;
                                    flush_1_instruction     ='b0;
                                    flush_2_instructions    ='b0;
                                    flush_3_instructions    ='b0;
                                    branch_flag             ='b0;   
                                    out_en                  ='b0;
                                end
                    CARRIES:    begin
                                    case(ra)
                                        'b00 :  begin       //RLC
                                                    read_reg_a_sel          ='b0;
                                                    read_reg_b_sel          ='b0;
                                                    use_ra                  ='b0;
                                                    use_rb                  ='b1;
                                                    alu_op                  =rlcb_op;
                                                    alu_B_sel               ='b1;    
                                                    flag_en                 ='b1;
                                                    flag_address            ='b0;
                                                    push                    ='b0;             
                                                    pop                     ='b0;              
                                                    mem_wr_en               ='b0;
                                                    if (CS == NORMAL)
                                                        mem_interface_sel   ='b1;
                                                    else
                                                        mem_interface_sel   ='b10;
                                                    use_memory              ='b0;
                                                    write_reg_en            ='b1;
                                                    write_reg_address_sel   ='b1;
                                                    write_reg_data_sel      ='b0;
                                                    write_to_reg            ='b1;
                                                    destination_addr        = rb;
                                                    flush_1_instruction     ='b0;
                                                    flush_2_instructions    ='b0;
                                                    flush_3_instructions    ='b0;
                                                    branch_flag             ='b0;   
                                                    out_en                  ='b0;
                                                end
                                        'b01 :  begin       //RRC
                                                    read_reg_a_sel          ='b0;
                                                    read_reg_b_sel          ='b0;
                                                    use_ra                  ='b0;
                                                    use_rb                  ='b1;
                                                    alu_op                  =rrcb_op;
                                                    alu_B_sel               ='b1;    
                                                    flag_en                 ='b1;
                                                    flag_address            ='b0;
                                                    push                    ='b0;             
                                                    pop                     ='b0;              
                                                    mem_wr_en               ='b0;
                                                    if (CS == NORMAL)
                                                        mem_interface_sel   ='b1;
                                                    else
                                                        mem_interface_sel   ='b10;
                                                    use_memory              ='b0;
                                                    write_reg_en            ='b1;
                                                    write_reg_address_sel   ='b1;
                                                    write_reg_data_sel      ='b0;
                                                    write_to_reg            ='b1;
                                                    destination_addr        = rb;
                                                    flush_1_instruction     ='b0;
                                                    flush_2_instructions    ='b0;
                                                    flush_3_instructions    ='b0;
                                                    branch_flag             ='b0;   
                                                    out_en                  ='b0;
                                                end
                                        'b10 :  begin       //SETC
                                                    read_reg_a_sel          ='b0;
                                                    read_reg_b_sel          ='b0;
                                                    use_ra                  ='b0;
                                                    use_rb                  ='b0;
                                                    alu_op                  =setc_op;
                                                    alu_B_sel               ='b0;    
                                                    flag_en                 ='b1;
                                                    flag_address            ='b0;
                                                    push                    ='b0;             
                                                    pop                     ='b0;              
                                                    mem_wr_en               ='b0;
                                                    if (CS == NORMAL)
                                                        mem_interface_sel   ='b1;
                                                    else
                                                        mem_interface_sel   ='b10;
                                                    use_memory              ='b0;
                                                    write_reg_en            ='b0;
                                                    write_reg_address_sel   ='b0;
                                                    write_reg_data_sel      ='b0;
                                                    write_to_reg            ='b0;       
                                                    destination_addr        ='b0;
                                                    flush_1_instruction     ='b0;
                                                    flush_2_instructions    ='b0;
                                                    flush_3_instructions    ='b0;
                                                    branch_flag             ='b0;   
                                                    out_en                  ='b0;
                                                end
                                        'b11 :  begin       //CLRC
                                                    read_reg_a_sel          ='b0;
                                                    read_reg_b_sel          ='b0;
                                                    use_ra                  ='b0;
                                                    use_rb                  ='b0;
                                                    alu_op                  =clrc_op;
                                                    alu_B_sel               ='b0;    
                                                    flag_en                 ='b1;
                                                    flag_address            ='b0;
                                                    push                    ='b0;             
                                                    pop                     ='b0;              
                                                    mem_wr_en               ='b0;
                                                    if (CS == NORMAL)
                                                        mem_interface_sel   ='b1;
                                                    else
                                                        mem_interface_sel   ='b10;
                                                    use_memory              ='b0;
                                                    write_reg_en            ='b0;
                                                    write_reg_address_sel   ='b0;
                                                    write_reg_data_sel      ='b0;
                                                    write_to_reg            ='b0;       
                                                    destination_addr        ='b0;
                                                    flush_1_instruction     ='b0;
                                                    flush_2_instructions    ='b0;
                                                    flush_3_instructions    ='b0;
                                                    branch_flag             ='b0;   
                                                    out_en                  ='b0;
                                                end
                                    endcase
                                end
                    STACK_IO:   begin
                                    case(ra)
                                        'b00 :  begin       //PUSH
                                                    read_reg_a_sel          ='b1;
                                                    read_reg_b_sel          ='b0;
                                                    use_ra                  ='b0;
                                                    use_rb                  ='b1;
                                                    alu_op                  =bypassb_op;
                                                    alu_B_sel               ='b0;    
                                                    flag_en                 ='b0;
                                                    flag_address            ='b0;
                                                    push                    ='b1;             
                                                    pop                     ='b0;              
                                                    mem_wr_en               ='b1;
                                                    mem_interface_sel       ='b0;
                                                    use_memory              ='b1;
                                                    write_reg_en            ='b0;
                                                    write_reg_address_sel   ='b0;
                                                    write_reg_data_sel      ='b0;
                                                    write_to_reg            ='b0;
                                                    destination_addr        ='b0;
                                                    flush_1_instruction     ='b0;
                                                    flush_2_instructions    ='b0;
                                                    flush_3_instructions    ='b0;
                                                    branch_flag             ='b0;   
                                                    out_en                  ='b0;
                                                end
                                        'b01 :  begin       //pop
                                                    read_reg_a_sel          ='b1;
                                                    read_reg_b_sel          ='b0;
                                                    use_ra                  ='b0;
                                                    use_rb                  ='b1;
                                                    alu_op                  =bypassb_op;
                                                    alu_B_sel               ='b0;    
                                                    flag_en                 ='b0;
                                                    flag_address            ='b0;
                                                    push                    ='b0;             
                                                    pop                     ='b1;              
                                                    mem_wr_en               ='b0;
                                                    mem_interface_sel       ='b0;
                                                    use_memory              ='b1;
                                                    write_reg_en            ='b1;
                                                    write_reg_address_sel   ='b1;
                                                    write_reg_data_sel      ='b1;
                                                    write_to_reg            ='b1;
                                                    destination_addr        = rb;
                                                    flush_1_instruction     ='b0;
                                                    flush_2_instructions    ='b0;
                                                    flush_3_instructions    ='b0;
                                                    branch_flag             ='b0;   
                                                    out_en                  ='b0;
                                                end
                                        'b10 :  begin       //OUT
                                                    read_reg_a_sel          ='b0;
                                                    read_reg_b_sel          ='b0;
                                                    use_ra                  ='b0;
                                                    use_rb                  ='b1;
                                                    alu_op                  =bypassb_op;
                                                    alu_B_sel               ='b1;    
                                                    flag_en                 ='b0;
                                                    flag_address            ='b0;
                                                    push                    ='b0;             
                                                    pop                     ='b0;              
                                                    mem_wr_en               ='b0;
                                                    if (CS == NORMAL)
                                                        mem_interface_sel   ='b1;
                                                    else
                                                        mem_interface_sel   ='b10;
                                                    use_memory              ='b0;
                                                    write_reg_en            ='b0;
                                                    write_reg_address_sel   ='b0;
                                                    write_reg_data_sel      ='b0;
                                                    write_to_reg            ='b0;       
                                                    destination_addr        ='b0;
                                                    flush_1_instruction     ='b0;
                                                    flush_2_instructions    ='b0;
                                                    flush_3_instructions    ='b0;
                                                    branch_flag             ='b0;   
                                                    out_en                  ='b1;
                                                end
                                        'b11 :  begin       //IN
                                                    read_reg_a_sel          ='b0;
                                                    read_reg_b_sel          ='b0;
                                                    use_ra                  ='b0;
                                                    use_rb                  ='b1;
                                                    alu_op                  =bypassb_op;
                                                    alu_B_sel               ='b11;    
                                                    flag_en                 ='b0;
                                                    flag_address            ='b0;
                                                    push                    ='b0;             
                                                    pop                     ='b0;              
                                                    mem_wr_en               ='b0;
                                                    if (CS == NORMAL)
                                                        mem_interface_sel   ='b1;
                                                    else
                                                        mem_interface_sel   ='b10;
                                                    use_memory              ='b0;
                                                    write_reg_en            ='b1;
                                                    write_reg_address_sel   ='b1;
                                                    write_reg_data_sel      ='b0;
                                                    write_to_reg            ='b1;       
                                                    destination_addr        = rb;
                                                    flush_1_instruction     ='b0;
                                                    flush_2_instructions    ='b0;
                                                    flush_3_instructions    ='b0;
                                                    branch_flag             ='b0;   
                                                    out_en                  ='b0;
                                                end
                                    endcase
                                end
                    COMP_STEPS: begin
                                    case(ra)
                                        'b00 :  begin       //NOT
                                                    read_reg_a_sel          ='b0;
                                                    read_reg_b_sel          ='b0;
                                                    use_ra                  ='b0;
                                                    use_rb                  ='b1;
                                                    alu_op                  =notb_op;
                                                    alu_B_sel               ='b1;    
                                                    flag_en                 ='b1;
                                                    flag_address            ='b0;
                                                    push                    ='b0;             
                                                    pop                     ='b0;              
                                                    mem_wr_en               ='b0;
                                                    if (CS == NORMAL)
                                                        mem_interface_sel   ='b1;
                                                    else
                                                        mem_interface_sel   ='b10;
                                                    use_memory              ='b0;
                                                    write_reg_en            ='b1;
                                                    write_reg_address_sel   ='b1;
                                                    write_reg_data_sel      ='b0;
                                                    write_to_reg            ='b1;
                                                    destination_addr        = rb;
                                                    flush_1_instruction     ='b0;
                                                    flush_2_instructions    ='b0;
                                                    flush_3_instructions    ='b0;
                                                    branch_flag             ='b0;   
                                                    out_en                  ='b0;
                                                end
                                        'b01 :  begin       //NEG
                                                    read_reg_a_sel          ='b0;
                                                    read_reg_b_sel          ='b0;
                                                    use_ra                  ='b0;
                                                    use_rb                  ='b1;
                                                    alu_op                  =negb_op;
                                                    alu_B_sel               ='b1;    
                                                    flag_en                 ='b1;
                                                    flag_address            ='b0;
                                                    push                    ='b0;             
                                                    pop                     ='b0;              
                                                    mem_wr_en               ='b0;
                                                    if (CS == NORMAL)
                                                        mem_interface_sel   ='b1;
                                                    else
                                                        mem_interface_sel   ='b10;
                                                    use_memory              ='b0;
                                                    write_reg_en            ='b1;
                                                    write_reg_address_sel   ='b1;
                                                    write_reg_data_sel      ='b0;
                                                    write_to_reg            ='b1;
                                                    destination_addr        = rb;
                                                    flush_1_instruction     ='b0;
                                                    flush_2_instructions    ='b0;
                                                    flush_3_instructions    ='b0;
                                                    branch_flag             ='b0;   
                                                    out_en                  ='b0;
                                                end
                                        'b10 :  begin       //INC
                                                    read_reg_a_sel          ='b0;
                                                    read_reg_b_sel          ='b0;
                                                    use_ra                  ='b0;
                                                    use_rb                  ='b1;
                                                    alu_op                  =incb_op;
                                                    alu_B_sel               ='b1;    
                                                    flag_en                 ='b1;
                                                    flag_address            ='b0;
                                                    push                    ='b0;             
                                                    pop                     ='b0;              
                                                    mem_wr_en               ='b0;
                                                    if (CS == NORMAL)
                                                        mem_interface_sel   ='b1;
                                                    else
                                                        mem_interface_sel   ='b10;
                                                    use_memory              ='b0;
                                                    write_reg_en            ='b1;
                                                    write_reg_address_sel   ='b1;
                                                    write_reg_data_sel      ='b0;
                                                    write_to_reg            ='b1;
                                                    destination_addr        = rb;
                                                    flush_1_instruction     ='b0;
                                                    flush_2_instructions    ='b0;
                                                    flush_3_instructions    ='b0;
                                                    branch_flag             ='b0;   
                                                    out_en                  ='b0;
                                                end
                                        'b11 :  begin       //DEC
                                                    read_reg_a_sel          ='b0;
                                                    read_reg_b_sel          ='b0;
                                                    use_ra                  ='b0;
                                                    use_rb                  ='b1;
                                                    alu_op                  =decb_op;
                                                    alu_B_sel               ='b1;    
                                                    flag_en                 ='b1;
                                                    flag_address            ='b0;
                                                    push                    ='b0;             
                                                    pop                     ='b0;              
                                                    mem_wr_en               ='b0;
                                                    if (CS == NORMAL)
                                                        mem_interface_sel   ='b1;
                                                    else
                                                        mem_interface_sel   ='b10;
                                                    use_memory              ='b0;
                                                    write_reg_en            ='b1;
                                                    write_reg_address_sel   ='b1;
                                                    write_reg_data_sel      ='b0;
                                                    write_to_reg            ='b1;
                                                    destination_addr        = rb;
                                                    flush_1_instruction     ='b0;
                                                    flush_2_instructions    ='b0;
                                                    flush_3_instructions    ='b0;
                                                    branch_flag             ='b0;   
                                                    out_en                  ='b0;
                                                end
                                    endcase
                                end
                    COND_JUMP:  begin
                                    case(ra)
                                        'b00 :  begin       //JZ
                                                    read_reg_a_sel          ='b0;
                                                    read_reg_b_sel          ='b0;
                                                    use_ra                  ='b0;
                                                    use_rb                  ='b1;
                                                    alu_op                  ='b0;
                                                    alu_B_sel               ='b0;    
                                                    flag_en                 ='b0;
                                                    flag_address            ='b0;
                                                    push                    ='b0;             
                                                    pop                     ='b0;              
                                                    mem_wr_en               ='b0;
                                                    if (CS == NORMAL)
                                                        mem_interface_sel   ='b1;
                                                    else
                                                        mem_interface_sel   ='b10;
                                                    use_memory              ='b0;
                                                    write_reg_en            ='b0;
                                                    write_reg_address_sel   ='b0;
                                                    write_reg_data_sel      ='b0;
                                                    write_to_reg            ='b0;
                                                    destination_addr        ='b0;
                                                    flush_1_instruction     ='b0;
                                                    flush_2_instructions    ='b1;
                                                    flush_3_instructions    ='b0;
                                                    branch_flag             ='b0;   
                                                    out_en                  ='b0;
                                                end
                                        'b01 :  begin       //JN
                                                    read_reg_a_sel          ='b0;
                                                    read_reg_b_sel          ='b0;
                                                    use_ra                  ='b0;
                                                    use_rb                  ='b1;
                                                    alu_op                  ='b0;
                                                    alu_B_sel               ='b0;    
                                                    flag_en                 ='b0;
                                                    flag_address            ='b1;
                                                    push                    ='b0;             
                                                    pop                     ='b0;              
                                                    mem_wr_en               ='b0;
                                                    if (CS == NORMAL)
                                                        mem_interface_sel   ='b1;
                                                    else
                                                        mem_interface_sel   ='b10;
                                                    use_memory              ='b0;
                                                    write_reg_en            ='b0;
                                                    write_reg_address_sel   ='b0;
                                                    write_reg_data_sel      ='b0;
                                                    write_to_reg            ='b0;
                                                    destination_addr        ='b0;
                                                    flush_1_instruction     ='b0;
                                                    flush_2_instructions    ='b1;
                                                    flush_3_instructions    ='b0;
                                                    branch_flag             ='b0;   
                                                    out_en                  ='b0;
                                                end
                                        'b10 :  begin       //JC
                                                    read_reg_a_sel          ='b0;
                                                    read_reg_b_sel          ='b0;
                                                    use_ra                  ='b0;
                                                    use_rb                  ='b1;
                                                    alu_op                  ='b0;
                                                    alu_B_sel               ='b0;    
                                                    flag_en                 ='b0;
                                                    flag_address            ='b10;
                                                    push                    ='b0;             
                                                    pop                     ='b0;              
                                                    mem_wr_en               ='b0;
                                                    if (CS == NORMAL)
                                                        mem_interface_sel   ='b1;
                                                    else
                                                        mem_interface_sel   ='b10;
                                                    use_memory              ='b0;
                                                    write_reg_en            ='b0;
                                                    write_reg_address_sel   ='b0;
                                                    write_reg_data_sel      ='b0;
                                                    write_to_reg            ='b0;
                                                    destination_addr        ='b0;
                                                    flush_1_instruction     ='b0;
                                                    flush_2_instructions    ='b1;
                                                    flush_3_instructions    ='b0;
                                                    branch_flag             ='b0;   
                                                    out_en                  ='b0;
                                                end
                                        'b11 :  begin       //JV
                                                    read_reg_a_sel          ='b0;
                                                    read_reg_b_sel          ='b0;
                                                    use_ra                  ='b0;
                                                    use_rb                  ='b1;
                                                    alu_op                  ='b0;
                                                    alu_B_sel               ='b0;    
                                                    flag_en                 ='b0;
                                                    flag_address            ='b11;
                                                    push                    ='b0;             
                                                    pop                     ='b0;              
                                                    mem_wr_en               ='b0;
                                                    if (CS == NORMAL)
                                                        mem_interface_sel   ='b1;
                                                    else
                                                        mem_interface_sel   ='b10;
                                                    use_memory              ='b0;
                                                    write_reg_en            ='b0;
                                                    write_reg_address_sel   ='b0;
                                                    write_reg_data_sel      ='b0;
                                                    write_to_reg            ='b0;
                                                    destination_addr        ='b0;
                                                    flush_1_instruction     ='b0;
                                                    flush_2_instructions    ='b1;
                                                    flush_3_instructions    ='b0;
                                                    branch_flag             ='b0;   
                                                    out_en                  ='b0;
                                                end
                                    endcase
                                end
                    LOOP :      begin
                                    read_reg_a_sel          ='b0;
                                    read_reg_b_sel          ='b0;
                                    use_ra                  ='b1;
                                    use_rb                  ='b1;
                                    alu_op                  =decb_op;
                                    alu_B_sel               ='b0;    
                                    flag_en                 ='b0;
                                    flag_address            ='b0;
                                    push                    ='b0;             
                                    pop                     ='b0;              
                                    mem_wr_en               ='b0;
                                    if (CS == NORMAL)
                                        mem_interface_sel   ='b1;
                                    else
                                        mem_interface_sel   ='b10;
                                    use_memory              ='b0;
                                    write_reg_en            ='b1;
                                    write_reg_address_sel   ='b0;
                                    write_reg_data_sel      ='b0;
                                    write_to_reg            ='b1;
                                    destination_addr        = ra;
                                    flush_1_instruction     ='b0;
                                    flush_2_instructions    ='b1;
                                    flush_3_instructions    ='b0;
                                    branch_flag             ='b1;   
                                    out_en                  ='b0;
                                end
                    UNCOND_JUMP:begin
                                    case(ra)
                                        'b00 :  begin       //JMP
                                                    read_reg_a_sel          ='b0;
                                                    read_reg_b_sel          ='b0;
                                                    use_ra                  ='b0;
                                                    use_rb                  ='b1;
                                                    alu_op                  ='b0;
                                                    alu_B_sel               ='b0;    
                                                    flag_en                 ='b0;
                                                    flag_address            ='b0;
                                                    push                    ='b0;             
                                                    pop                     ='b0;              
                                                    mem_wr_en               ='b0;
                                                    if (CS == NORMAL)
                                                        mem_interface_sel   ='b1;
                                                    else
                                                        mem_interface_sel   ='b10;
                                                    use_memory              ='b0;
                                                    write_reg_en            ='b0;
                                                    write_reg_address_sel   ='b0;
                                                    write_reg_data_sel      ='b0;
                                                    write_to_reg            ='b0;
                                                    destination_addr        ='b0;
                                                    flush_1_instruction     ='b0;
                                                    flush_2_instructions    ='b1;
                                                    flush_3_instructions    ='b0;
                                                    branch_flag             ='b10;   
                                                    out_en                  ='b0;
                                                end
                                        'b01 :  begin       //CALL
                                                    read_reg_a_sel          ='b1;
                                                    read_reg_b_sel          ='b0;
                                                    use_ra                  ='b0;
                                                    use_rb                  ='b1;
                                                    alu_op                  = bypassb_op;
                                                    alu_B_sel               ='b0;    
                                                    flag_en                 ='b0;
                                                    flag_address            ='b0;
                                                    push                    ='b1;             
                                                    pop                     ='b0;              
                                                    mem_wr_en               ='b1;
                                                    mem_interface_sel       ='b0;
                                                    use_memory              ='b1;
                                                    write_reg_en            ='b0;
                                                    write_reg_address_sel   ='b0;
                                                    write_reg_data_sel      ='b0;
                                                    write_to_reg            ='b0;
                                                    destination_addr        ='b0;
                                                    flush_1_instruction     ='b0;
                                                    flush_2_instructions    ='b1;
                                                    flush_3_instructions    ='b0;
                                                    branch_flag             ='b10;   
                                                    out_en                  ='b0;
                                                end
                                        'b10 :  begin       //RET
                                                    read_reg_a_sel          ='b1;
                                                    read_reg_b_sel          ='b0;
                                                    use_ra                  ='b0;
                                                    use_rb                  ='b0;
                                                    alu_op                  = bypassb_op;
                                                    alu_B_sel               ='b0;    
                                                    flag_en                 ='b0;
                                                    flag_address            ='b0;
                                                    push                    ='b0;             
                                                    pop                     ='b1;              
                                                    mem_wr_en               ='b0;
                                                    mem_interface_sel       ='b0;
                                                    use_memory              ='b1;
                                                    write_reg_en            ='b0;
                                                    write_reg_address_sel   ='b0;
                                                    write_reg_data_sel      ='b0;
                                                    write_to_reg            ='b0;
                                                    destination_addr        ='b0;
                                                    flush_1_instruction     ='b0;
                                                    flush_2_instructions    ='b0;
                                                    flush_3_instructions    ='b1;
                                                    branch_flag             ='b0;   
                                                    out_en                  ='b0;
                                                end
                                        'b11 :  begin       //RTI
                                                    read_reg_a_sel          ='b1;
                                                    read_reg_b_sel          ='b0;
                                                    use_ra                  ='b0;
                                                    use_rb                  ='b0;
                                                    alu_op                  = bypassb_op;
                                                    alu_B_sel               ='b0;    
                                                    flag_en                 ='b0;
                                                    flag_address            ='b0;
                                                    push                    ='b0;             
                                                    pop                     ='b1;              
                                                    mem_wr_en               ='b0;
                                                    mem_interface_sel       ='b0;
                                                    use_memory              ='b1;
                                                    write_reg_en            ='b0;
                                                    write_reg_address_sel   ='b0;
                                                    write_reg_data_sel      ='b0;
                                                    write_to_reg            ='b0;
                                                    destination_addr        ='b0;
                                                    flush_1_instruction     ='b0;
                                                    flush_2_instructions    ='b0;
                                                    flush_3_instructions    ='b1;
                                                    branch_flag             ='b0;   
                                                    out_en                  ='b0;
                                                end
                                    endcase
                                end
                    LOAD_STORE: begin
                                    case(ra)
                                        'b00 :  begin       //LDM
                                                    read_reg_a_sel          ='b0;
                                                    read_reg_b_sel          ='b0;
                                                    use_ra                  ='b0;
                                                    use_rb                  ='b1;
                                                    alu_op                  = bypassb_op;
                                                    alu_B_sel               ='b10;    
                                                    flag_en                 ='b0;
                                                    flag_address            ='b0;
                                                    push                    ='b0;             
                                                    pop                     ='b0;              
                                                    mem_wr_en               ='b0;
                                                    if (CS == NORMAL)
                                                        mem_interface_sel   ='b1;
                                                    else
                                                        mem_interface_sel   ='b10;
                                                    use_memory              ='b0;
                                                    write_reg_en            ='b1;
                                                    write_reg_address_sel   ='b1;
                                                    write_reg_data_sel      ='b0;
                                                    write_to_reg            ='b1;
                                                    destination_addr        = rb;
                                                    flush_1_instruction     ='b1;
                                                    flush_2_instructions    ='b0;
                                                    flush_3_instructions    ='b0;
                                                    branch_flag             ='b10;   
                                                    out_en                  ='b0;
                                                end
                                        'b01 :  begin       //LDD
                                                    read_reg_a_sel          ='b0;
                                                    read_reg_b_sel          ='b0;
                                                    use_ra                  ='b0;
                                                    use_rb                  ='b1;
                                                    alu_op                  = bypassb_op;
                                                    alu_B_sel               ='b10;    
                                                    flag_en                 ='b0;
                                                    flag_address            ='b0;
                                                    push                    ='b0;             
                                                    pop                     ='b0;              
                                                    mem_wr_en               ='b0;
                                                    mem_interface_sel       ='b11;
                                                    use_memory              ='b1;
                                                    write_reg_en            ='b1;
                                                    write_reg_address_sel   ='b1;
                                                    write_reg_data_sel      ='b1;
                                                    write_to_reg            ='b1;
                                                    destination_addr        = rb;
                                                    flush_1_instruction     ='b1;
                                                    flush_2_instructions    ='b0;
                                                    flush_3_instructions    ='b0;
                                                    branch_flag             ='b10;   
                                                    out_en                  ='b0;
                                                end
                                        'b10 :  begin       //STD
                                                    read_reg_a_sel          ='b0;
                                                    read_reg_b_sel          ='b0;
                                                    use_ra                  ='b0;
                                                    use_rb                  ='b1;
                                                    alu_op                  = bypassb_op;
                                                    alu_B_sel               ='b10;    
                                                    flag_en                 ='b0;
                                                    flag_address            ='b0;
                                                    push                    ='b0;             
                                                    pop                     ='b0;              
                                                    mem_wr_en               ='b1;
                                                    mem_interface_sel       ='b11;
                                                    use_memory              ='b1;
                                                    write_reg_en            ='b0;
                                                    write_reg_address_sel   ='b0;
                                                    write_reg_data_sel      ='b0;
                                                    write_to_reg            ='b0;
                                                    destination_addr        ='b0;
                                                    flush_1_instruction     ='b1;
                                                    flush_2_instructions    ='b0;
                                                    flush_3_instructions    ='b0;
                                                    branch_flag             ='b0;   
                                                    out_en                  ='b0;
                                                end
                                        default:begin       
                                                    read_reg_a_sel          ='b0;
                                                    read_reg_b_sel          ='b0;
                                                    use_ra                  ='b0;
                                                    use_rb                  ='b0;
                                                    alu_op                  ='b0;
                                                    alu_B_sel               ='b0;    
                                                    flag_en                 ='b0;
                                                    flag_address            ='b0;
                                                    push                    ='b0;             
                                                    pop                     ='b0;              
                                                    mem_wr_en               ='b0;
                                                    if (CS == NORMAL)
                                                        mem_interface_sel   ='b1;
                                                    else
                                                        mem_interface_sel   ='b10;
                                                    use_memory              ='b0;
                                                    write_reg_en            ='b0;
                                                    write_reg_address_sel   ='b0;
                                                    write_reg_data_sel      ='b0;
                                                    write_to_reg            ='b0;
                                                    destination_addr        ='b0;
                                                    flush_1_instruction     ='b0;
                                                    flush_2_instructions    ='b0;
                                                    flush_3_instructions    ='b0;
                                                    branch_flag             ='b0;   
                                                    out_en                  ='b0;
                                                end
                                    endcase
                                end  
                    LDI :       begin       
                                    read_reg_a_sel          ='b0;
                                    read_reg_b_sel          ='b0;
                                    use_ra                  ='b1;
                                    use_rb                  ='b1;
                                    alu_op                  = bypassb_op;
                                    alu_B_sel               ='b10;    
                                    flag_en                 ='b0;
                                    flag_address            ='b0;
                                    push                    ='b0;             
                                    pop                     ='b0;              
                                    mem_wr_en               ='b0;
                                    mem_interface_sel       ='b11;
                                    use_memory              ='b1;
                                    write_reg_en            ='b1;
                                    write_reg_address_sel   ='b1;
                                    write_reg_data_sel      ='b1;
                                    write_to_reg            ='b1;
                                    destination_addr        = rb;
                                    flush_1_instruction     ='b0;
                                    flush_2_instructions    ='b0;
                                    flush_3_instructions    ='b0;
                                    branch_flag             ='b0;   
                                    out_en                  ='b0;
                                end  
                STI :           begin
                                    read_reg_a_sel          ='b0;
                                    read_reg_b_sel          ='b0;
                                    use_ra                  ='b1;
                                    use_rb                  ='b1;
                                    alu_op                  = bypassb_op;
                                    alu_B_sel               ='b0;    
                                    flag_en                 ='b0;
                                    flag_address            ='b0;
                                    push                    ='b0;             
                                    pop                     ='b0;              
                                    mem_wr_en               ='b1;
                                    mem_interface_sel       ='b11;
                                    use_memory              ='b1;
                                    write_reg_en            ='b0;
                                    write_reg_address_sel   ='b0;
                                    write_reg_data_sel      ='b0;
                                    write_to_reg            ='b0;
                                    destination_addr        ='b0;
                                    flush_1_instruction     ='b0;
                                    flush_2_instructions    ='b0;
                                    flush_3_instructions    ='b0;
                                    branch_flag             ='b0;   
                                    out_en                  ='b0;
                                end        
                endcase
            end
        else if (CS == SAVE_PC)
            begin
                read_reg_a_sel          ='b1;
                read_reg_b_sel          ='b0;
                use_ra                  ='b0;
                use_rb                  ='b0;
                alu_op                  = bypassb_op;
                alu_B_sel               ='b0;    
                flag_en                 ='b0;
                flag_address            ='b0;
                push                    ='b1;             
                pop                     ='b0;              
                mem_wr_en               ='b1;
                mem_interface_sel       ='b0;
                use_memory              ='b1;
                write_reg_en            ='b0;
                write_reg_address_sel   ='b0;
                write_reg_data_sel      ='b0;
                write_to_reg            ='b0;
                destination_addr        ='b0;
                flush_1_instruction     ='b0;
                flush_2_instructions    ='b0;
                flush_3_instructions    ='b1;
                branch_flag             ='b0;   
                out_en                  ='b0;
            end
        else if (CS == LOAD_INERRUPT)
            begin
                read_reg_a_sel          ='b0;
                read_reg_b_sel          ='b0;
                use_ra                  ='b0;
                use_rb                  ='b0;
                alu_op                  ='b0;
                alu_B_sel               ='b0;    
                flag_en                 ='b0;
                flag_address            ='b0;
                push                    ='b0;             
                pop                     ='b0;              
                mem_wr_en               ='b0;
                mem_interface_sel       ='b10;
                use_memory              ='b0;
                write_reg_en            ='b0;
                write_reg_address_sel   ='b0;
                write_reg_data_sel      ='b0;
                write_to_reg            ='b0;
                destination_addr        ='b0;
                flush_1_instruction     ='b0;
                flush_2_instructions    ='b1;
                flush_3_instructions    ='b0;
                branch_flag             ='b10;   
                out_en                  ='b0;
            end
        else
            begin
                read_reg_a_sel          ='b0;
                read_reg_b_sel          ='b0;
                use_ra                  ='b0;
                use_rb                  ='b0;
                alu_op                  ='b0;
                alu_B_sel               ='b0;    
                flag_en                 ='b0;
                flag_address            ='b0;
                push                    ='b0;             
                pop                     ='b0;              
                mem_wr_en               ='b0;
                mem_interface_sel       ='b0;
                use_memory              ='b0;
                write_reg_en            ='b0;
                write_reg_address_sel   ='b0;
                write_reg_data_sel      ='b0;
                write_to_reg            ='b0;
                destination_addr        ='b0;
                flush_1_instruction     ='b0;
                flush_2_instructions    ='b0;
                flush_3_instructions    ='b0;
                branch_flag             ='b0;   
                out_en                  ='b0;
            end
    end

endmodule
