`timescale 1ns / 1ps

module mem_wrapper_tb;

// Parameters
parameter Data_width = 8;
parameter Addr_width = 8;
parameter Depth      = 256;
parameter interrupt_offset = 0;      // 0 -> 19 (20 locations)
parameter Instruction_offset = 20;   // 20 -> 99 (80 locations)
parameter data_offset = 100;         // 100 -> 199 (100 locations)
parameter SP_offset = 0;           //(56 locations)

// Clock period
parameter CLK_PERIOD = 10;

// Testbench signals
reg clk;
reg wr_en;
reg pop;
reg [1:0] sel;
reg [Addr_width-1:0] interrupt;
reg [Addr_width-1:0] Instruction;
reg [Addr_width-1:0] data;
reg [Addr_width-1:0] SP;
reg [Data_width-1:0] wr_data;
wire [Data_width-1:0] rd_data;

// Instantiate the Unit Under Test (UUT)
mem_wrapper #(
    .Data_width         (Data_width),
    .Addr_width         (Addr_width),
    .Depth              (Depth),
    .interrupt_offset   (interrupt_offset),
    .Instruction_offset (Instruction_offset),
    .data_offset        (data_offset),
    .SP_offset          (SP_offset)
) uut (
    .clk        (clk),
    .wr_en      (wr_en),
    .pop        (pop),
    .sel        (sel),
    .interrupt  (interrupt),
    .Instruction(Instruction),
    .data       (data),
    .SP         (SP),
    .wr_data    (wr_data),
    .rd_data    (rd_data)
);

// Clock generation
initial begin
    clk = 0;
    forever #(CLK_PERIOD/2) clk = ~clk;
end

// Test stimulus
initial begin
    // Initialize signals
    wr_en = 0;
    pop = 0;
    sel = 2'b00;
    interrupt = 0;
    Instruction = 0;
    data = 0;
    SP = 255;
    wr_data = 0;

    // Wait for initial setup
    #(CLK_PERIOD*2);
    
    // STACK OPERATIONS (sel = 2'b00)
    $display("\n STACK OPERATIONS (PUSH/POP) ");
    
    // TEST CASE 1: PUSH to stack (SP = 255, address = 255)
    $display("\n--- Push Test Case 1 ---");
    sel = 2'b00;
    SP = 255;        
    pop = 0;        // Push operation
    wr_en = 1;
    wr_data = 8'hAA;
    #(CLK_PERIOD);
    
    wr_en = 0;
    #(CLK_PERIOD);
    $display("%0t\tًWrite\t\t%d\t\t\t0x%h", $time, SP_offset + SP, rd_data);
    
    // TEST CASE 2: PUSH to stack (SP = 254, address = 254)
    $display("\n--- Push Test Case 2 ---");
    SP = 254;
    pop = 0;
    wr_en = 1;
    wr_data = 8'hBB;
    #(CLK_PERIOD);
    
    wr_en = 0;
    #(CLK_PERIOD);
    $display("%0t\tWrite\t\t%d\t\t\t0x%h", $time, SP_offset + SP, rd_data);
 
    // INSTRUCTION MEMORY (sel = 2'b01)
    $display("\n\n=== INSTRUCTION MEMORY OPERATIONS ===");
    
    // TEST CASE 3: Write instruction at offset 0 (address = 20)
    $display("\n--- Instruction Test Case 1 ---");
    sel = 2'b01;
    Instruction = 0;
    pop = 0;
    wr_en = 1;
    wr_data = 8'h12;
    #(CLK_PERIOD);
    $display("%0t\tWRITE_INST\t%d\t0x%h\t\t0x%h", $time, Instruction_offset + Instruction, wr_data, rd_data);
    wr_en = 0;
    #(CLK_PERIOD);
    $display("%0t\tREAD_INST\t%d\t\t\t0x%h", $time, Instruction_offset + Instruction, rd_data);
    
    // TEST CASE 4: Write instruction at offset 10 (address = 30)
    $display("\n--- Instruction Test Case 2 ---");
    Instruction = 10;   // Instruction_offset + 10 = 30
    wr_en = 1;
    wr_data = 8'h34;
    #(CLK_PERIOD);
    $display("%0t\tWRITE_INST\t%d\t0x%h\t\t0x%h", $time, Instruction_offset + Instruction, wr_data, rd_data);
    
    wr_en = 0;
    #(CLK_PERIOD);
    $display("%0t\tREAD_INST\t%d\t\t\t0x%h", $time, Instruction_offset + Instruction, rd_data);
    
    // DATA MEMORY (sel = 2'b11)
    $display("\n\n=== DATA MEMORY OPERATIONS ===");
    
    // TEST CASE 5: Write data at offset 0 (address = 100)
    $display("\n--- Data Test Case 1 ---");
    sel = 2'b11;
    data = 0;           // data_offset + 0 = 100
    wr_en = 1;
    wr_data = 8'hCC;
    #(CLK_PERIOD);
    $display("%0t\tWRITE_DATA\t%d\t0x%h\t\t0x%h", $time, data_offset + data, wr_data, rd_data);
    
    wr_en = 0;
    #(CLK_PERIOD);
    $display("%0t\tREAD_DATA\t%d\t\t\t0x%h", $time, data_offset + data, rd_data);
    
    // TEST CASE 6: Write data at offset 25 (address = 125)
    $display("\n--- Data Test Case 2 ---");
    data = 25;          // data_offset + 25 = 125
    wr_en = 1;
    wr_data = 8'hDD;
    #(CLK_PERIOD);
    $display("%0t\tWRITE_DATA\t%d\t0x%h\t\t0x%h", $time, data_offset + data, wr_data, rd_data);
    
    wr_en = 0;
    #(CLK_PERIOD);
    $display("%0t\tREAD_DATA\t%d\t\t\t0x%h", $time, data_offset + data, rd_data);
    

    // (sel = 2'b10)
    $display("\n\n=== INTERRUPT VECTOR TABLE OPERATIONS ===");
    
    // TEST CASE 7: Write interrupt vector at offset 0 (address = 0)
    $display("\n--- Interrupt Test Case 1 ---");
    sel = 2'b10;
    interrupt = 0;      // interrupt_offset + 0 = 0
    wr_en = 1;
    wr_data = 8'hEE;
    #(CLK_PERIOD);
    $display("%0t\tWRITE_INT\t%d\t0x%h\t\t0x%h", $time, interrupt_offset + interrupt, wr_data, rd_data);
    
    wr_en = 0;
    #(CLK_PERIOD);
    $display("%0t\tREAD_INT\t%d\t\t\t0x%h", $time, interrupt_offset + interrupt, rd_data);
    
    // TEST CASE 8: Write interrupt vector at offset 5 (address = 5)
    $display("\n--- Interrupt Test Case 2 ---");
    interrupt = 5;      // interrupt_offset + 5 = 5
    wr_en = 1;
    wr_data = 8'hFF;
    #(CLK_PERIOD);
    $display("%0t\tWRITE_INT\t%d\t0x%h\t\t0x%h", $time, interrupt_offset + interrupt, wr_data, rd_data);
    
    wr_en = 0;
    #(CLK_PERIOD);
    $display("%0t\tREAD_INT\t%d\t\t\t0x%h", $time, interrupt_offset + interrupt, rd_data);
    

    // VERIFICATION: Read back all written values
    $display("\n\n=== VERIFICATION - Reading Back All Values ===");
    wr_en = 0;
    
    // Verify Stack
    sel = 2'b00;
    SP = 253; pop = 1;
    #(CLK_PERIOD);
    $display("Stack[254] = 0x%h (Expected: 0xBB)", rd_data);
    
    SP = 254; pop = 1;
    #(CLK_PERIOD);
    $display("Stack[255] = 0x%h (Expected: 0xAA)", rd_data);
    
    // Verify Instructions
    sel = 2'b01;
    Instruction = 0;
    #(CLK_PERIOD);
    $display("Instruction[20] = 0x%h (Expected: 0x12)", rd_data);
    
    Instruction = 10;
    #(CLK_PERIOD);
    $display("Instruction[30] = 0x%h (Expected: 0x34)", rd_data);
    
    // Verify Data
    sel = 2'b11;
    data = 0;
    #(CLK_PERIOD);
    $display("Data[100] = 0x%h (Expected: 0xCC)", rd_data);
    
    data = 25;
    #(CLK_PERIOD);
    $display("Data[125] = 0x%h (Expected: 0xDD)", rd_data);
    
    // Verify Interrupts
    sel = 2'b10;
    interrupt = 0;
    #(CLK_PERIOD);
    $display("Interrupt[0] = 0x%h (Expected: 0xEE)", rd_data);
    
    interrupt = 5;
    #(CLK_PERIOD);
    $display("Interrupt[5] = 0x%h (Expected: 0xFF)", rd_data);
    
    $display("Test Complete!");
    $finish;
end
endmodule