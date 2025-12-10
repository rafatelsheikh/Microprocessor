`timescale 1ns/1ps

module tb_memory_system;

// Parameters
parameter Data_width = 8;
parameter Addr_width = 8;
parameter Depth = 256;
parameter interrupt_offset = 0;
parameter Instruction_offset = 20;
parameter data_offset = 100;
parameter SP_offset = 200;

// Testbench signals
reg clk;
reg wr_en;
reg [1:0] sel;
reg [Addr_width-1:0] interrupt, Instruction, data, SP;
reg [Data_width-1:0] wr_data;
wire [Data_width-1:0] rd_data;

// Instantiate DUT
moduleName #(
    .Data_width(Data_width),
    .Addr_width(Addr_width),
    .Depth(Depth),
    .interrupt_offset(interrupt_offset),
    .Instruction_offset(Instruction_offset),
    .data_offset(data_offset),
    .SP_offset(SP_offset)
) dut (
    .clk(clk),
    .wr_en(wr_en),
    .sel(sel),
    .interrupt(interrupt),
    .Instruction(Instruction),
    .data(data),
    .SP(SP),
    .wr_data(wr_data),
    .rd_data(rd_data)
);

// Clock generation (10ns period = 100MHz)
initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

// Test procedure
initial begin
    // Initialize signals
    wr_en = 0;
    sel = 2'b00;
    interrupt = 0;
    Instruction = 0;
    data = 0;
    SP = 0;
    wr_data = 0;
    
    $display("========================================");
    $display("Starting Memory System Test");
    $display("========================================\n");
    
    // Wait for initial setup
    #10;
    
    //===========================================
    // TEST 1: Stack Operations (sel = 2'b00)
    //===========================================
    $display("TEST 1: Stack Operations (sel = 2'b00)");
    $display("----------------------------------------");
    
    sel = 2'b00;
    SP = 8'd10;  // Stack pointer at 10
    wr_data = 8'hAA;
    wr_en = 1;
    
    @(posedge clk);
    #1; // Small delay for async read
    $display("Write 0xAA to stack location SP+1 (addr=%0d)", SP + SP_offset + 1);
    
    @(posedge clk);
    wr_en = 0;
    #1;
    $display("Read from stack location SP (addr=%0d): Data = 0x%h", SP + SP_offset, rd_data);
    
    // Verify write by changing SP to read what we just wrote
    SP = 8'd11;
    #1;
    $display("Verify: Read from SP=11 (addr=%0d): Data = 0x%h\n", SP + SP_offset, rd_data);
    
    //===========================================
    // TEST 2: Instruction Memory (sel = 2'b01)
    //===========================================
    $display("TEST 2: Instruction Memory (sel = 2'b01)");
    $display("----------------------------------------");
    
    sel = 2'b01;
    Instruction = 8'd5;  // Instruction address offset 5
    wr_data = 8'hBB;
    wr_en = 1;
    
    @(posedge clk);
    #1;
    $display("Write 0xBB to instruction location (addr=%0d)", Instruction + Instruction_offset);
    
    @(posedge clk);
    wr_en = 0;
    #1;
    $display("Read from instruction location (addr=%0d): Data = 0x%h\n", Instruction + Instruction_offset, rd_data);
    
    //===========================================
    // TEST 3: Interrupt Vector (sel = 2'b10)
    //===========================================
    $display("TEST 3: Interrupt Vector (sel = 2'b10)");
    $display("----------------------------------------");
    
    sel = 2'b10;
    interrupt = 8'd15;  // Interrupt vector 15
    wr_data = 8'hCC;
    wr_en = 1;
    
    @(posedge clk);
    #1;
    $display("Write 0xCC to interrupt location (addr=%0d)", interrupt + interrupt_offset);
    
    @(posedge clk);
    wr_en = 0;
    #1;
    $display("Read from interrupt location (addr=%0d): Data = 0x%h\n", interrupt + interrupt_offset, rd_data);
    
    //===========================================
    // TEST 4: Data Memory (sel = 2'b11)
    //===========================================
    $display("TEST 4: Data Memory (sel = 2'b11)");
    $display("----------------------------------------");
    
    sel = 2'b11;
    data = 8'd50;  // Data address offset 50
    wr_data = 8'hDD;
    wr_en = 1;
    
    @(posedge clk);
    #1;
    $display("Write 0xDD to data location (addr=%0d)", data + data_offset);
    
    @(posedge clk);
    wr_en = 0;
    #1;
    $display("Read from data location (addr=%0d): Data = 0x%h\n", data + data_offset, rd_data);
    
    //===========================================
    // TEST 5: Multiple Writes to Same Region
    //===========================================
    $display("TEST 5: Multiple Sequential Writes");
    $display("----------------------------------------");
    
    sel = 2'b11;  // Data memory
    wr_en = 1;
    
    data = 8'd0;  wr_data = 8'h11;
    @(posedge clk); #1;
    $display("Write 0x11 to data[0] (addr=%0d)", data + data_offset);
    
    data = 8'd1;  wr_data = 8'h22;
    @(posedge clk); #1;
    $display("Write 0x22 to data[1] (addr=%0d)", data + data_offset);
    
    data = 8'd2;  wr_data = 8'h33;
    @(posedge clk); #1;
    $display("Write 0x33 to data[2] (addr=%0d)", data + data_offset);
    
    wr_en = 0;
    
    // Read back
    data = 8'd0; #1;
    $display("Read data[0] (addr=%0d): 0x%h", data + data_offset, rd_data);
    
    data = 8'd1; #1;
    $display("Read data[1] (addr=%0d): 0x%h", data + data_offset, rd_data);
    
    data = 8'd2; #1;
    $display("Read data[2] (addr=%0d): 0x%h\n", data + data_offset, rd_data);
    
    //===========================================
    // TEST 6: Write Enable Control
    //===========================================
    $display("TEST 6: Write Enable Control");
    $display("----------------------------------------");
    
    sel = 2'b11;
    data = 8'd10;
    wr_data = 8'hEE;
    wr_en = 1;
    
    @(posedge clk);
    #1;
    $display("Write 0xEE to data[10] with wr_en=1");
    
    wr_en = 0;
    #1;
    $display("Read data[10]: 0x%h", rd_data);
    
    // Try to write with wr_en = 0 (should not write)
    wr_data = 8'hFF;
    @(posedge clk);
    #1;
    $display("Attempt write 0xFF with wr_en=0 (should not write)");
    $display("Read data[10]: 0x%h (should still be 0xEE)\n", rd_data);
    
    //===========================================
    // TEST 7: Switching Between Memory Regions
    //===========================================
    $display("TEST 7: Switching Between Regions");
    $display("----------------------------------------");
    
    // Write to all regions
    sel = 2'b00; SP = 8'd20; wr_data = 8'h01; wr_en = 1;
    @(posedge clk); #1;
    $display("Wrote 0x01 to Stack[20] (addr=%0d)", SP + SP_offset + 1);
    
    sel = 2'b01; Instruction = 8'd30; wr_data = 8'h02;
    @(posedge clk); #1;
    $display("Wrote 0x02 to Instruction[30] (addr=%0d)", Instruction + Instruction_offset);
    
    sel = 2'b10; interrupt = 8'd5; wr_data = 8'h03;
    @(posedge clk); #1;
    $display("Wrote 0x03 to Interrupt[5] (addr=%0d)", interrupt + interrupt_offset);
    
    sel = 2'b11; data = 8'd40; wr_data = 8'h04;
    @(posedge clk); #1;
    $display("Wrote 0x04 to Data[40] (addr=%0d)", data + data_offset);
    
    wr_en = 0;
    
    // Read back from all regions
    sel = 2'b00; SP = 8'd21; #1;
    $display("Read Stack[21] (addr=%0d): 0x%h", SP + SP_offset, rd_data);
    
    sel = 2'b01; Instruction = 8'd30; #1;
    $display("Read Instruction[30] (addr=%0d): 0x%h", Instruction + Instruction_offset, rd_data);
    
    sel = 2'b10; interrupt = 8'd5; #1;
    $display("Read Interrupt[5] (addr=%0d): 0x%h", interrupt + interrupt_offset, rd_data);
    
    sel = 2'b11; data = 8'd40; #1;
    $display("Read Data[40] (addr=%0d): 0x%h\n", data + data_offset, rd_data);
    
    //===========================================
    // End of test
    //===========================================
    #50;
    $display("========================================");
    $display("All Tests Completed!");
    $display("========================================");
    
    $finish;
end
endmodule