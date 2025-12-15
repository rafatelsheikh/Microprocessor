module Hazard_Unit_tb ();

	reg execute_use_ra, execute_use_rb, memory_writes, wb_writes, is_memory_instruction;
	reg [1:0] execute_ra, execute_rb, mem_dest, wb_dest;

	wire fwd_A_memory_execute, fwd_B_memory_execute, fwd_A_wb_execute, fwd_B_wb_execute, stall_structural, stall_data;

	Hazard_Unit dut (execute_use_ra, execute_use_rb, memory_writes, wb_writes, is_memory_instruction, execute_ra, execute_rb, mem_dest, 
	                 wb_dest, fwd_A_memory_execute, fwd_B_memory_execute, fwd_A_wb_execute, fwd_B_wb_execute, stall_structural, stall_data);

	initial begin

		$display("Time | ex_use_ra ex_use_rb mem_wr wb_wr is_mem mem_dest wb_dest ex_ra ex_rb | fwdA_mem fwdB_mem fwdA_wb fwdB_wb | stall_structural stall_data");
        $display("-----+--------------------------------------------------------------------------------------+--------------------------------------------");

		// Case 1 : No hazards

		execute_use_ra = 0; execute_use_rb = 0; memory_writes = 0; wb_writes = 0;
        is_memory_instruction = 0;
        mem_dest = 2'b00; wb_dest = 2'b01; execute_ra = 2'b10; execute_rb = 2'b11;

        #5 $display("%t |    %b         %b       %b     %b     %b    %b      %b     %b  %b  |    %b       %b      %b      %b |       %b             %b",
            $time, execute_use_ra, execute_use_rb, memory_writes, wb_writes, is_memory_instruction, mem_dest, wb_dest, execute_ra, execute_rb,
            fwd_A_memory_execute, fwd_B_memory_execute, fwd_A_wb_execute, fwd_B_wb_execute, stall_structural, stall_data);

        // Case 2 : WB forwarding

        execute_use_ra = 1; execute_use_rb = 0; memory_writes = 0; wb_writes = 1;
        is_memory_instruction = 0;
        mem_dest = 2'b00; wb_dest = 2'b01; execute_ra = 2'b01; execute_rb = 2'b11;

        #5 $display("%t |    %b         %b       %b     %b     %b    %b      %b     %b  %b  |    %b       %b      %b      %b |       %b             %b",
            $time, execute_use_ra, execute_use_rb, memory_writes, wb_writes, is_memory_instruction, mem_dest, wb_dest, execute_ra, execute_rb,
            fwd_A_memory_execute, fwd_B_memory_execute, fwd_A_wb_execute, fwd_B_wb_execute, stall_structural, stall_data);

        execute_use_ra = 0; execute_use_rb = 1; memory_writes = 0; wb_writes = 1;
        is_memory_instruction = 0;
        mem_dest = 2'b00; wb_dest = 2'b01; execute_ra = 2'b10; execute_rb = 2'b01;

        #5 $display("%t |    %b         %b       %b     %b     %b    %b      %b     %b  %b  |    %b       %b      %b      %b |       %b             %b",
            $time, execute_use_ra, execute_use_rb, memory_writes, wb_writes, is_memory_instruction, mem_dest, wb_dest, execute_ra, execute_rb,
            fwd_A_memory_execute, fwd_B_memory_execute, fwd_A_wb_execute, fwd_B_wb_execute, stall_structural, stall_data);

        // Case 3 : Mem forwarding

        execute_use_ra = 1; execute_use_rb = 0; memory_writes = 1; wb_writes = 0;
        is_memory_instruction = 0;
        mem_dest = 2'b00; wb_dest = 2'b01; execute_ra = 2'b00; execute_rb = 2'b11;

        #5 $display("%t |    %b         %b       %b     %b     %b    %b      %b     %b  %b  |    %b       %b      %b      %b |       %b             %b",
            $time, execute_use_ra, execute_use_rb, memory_writes, wb_writes, is_memory_instruction, mem_dest, wb_dest, execute_ra, execute_rb,
            fwd_A_memory_execute, fwd_B_memory_execute, fwd_A_wb_execute, fwd_B_wb_execute, stall_structural, stall_data);

        execute_use_ra = 0; execute_use_rb = 1; memory_writes = 1; wb_writes = 0;
        is_memory_instruction = 0;
        mem_dest = 2'b00; wb_dest = 2'b01; execute_ra = 2'b10; execute_rb = 2'b00;

        #5 $display("%t |    %b         %b       %b     %b     %b    %b      %b     %b  %b  |    %b       %b      %b      %b |       %b             %b",
            $time, execute_use_ra, execute_use_rb, memory_writes, wb_writes, is_memory_instruction, mem_dest, wb_dest, execute_ra, execute_rb,
            fwd_A_memory_execute, fwd_B_memory_execute, fwd_A_wb_execute, fwd_B_wb_execute, stall_structural, stall_data);

        // Case 4 : Fetch Stall

        execute_use_ra = 0; execute_use_rb = 0; memory_writes = 0; wb_writes = 0;
        is_memory_instruction = 1;
        mem_dest = 2'b00; wb_dest = 2'b01; execute_ra = 2'b10; execute_rb = 2'b11;

        #5 $display("%t |    %b         %b       %b     %b     %b    %b      %b     %b  %b  |    %b       %b      %b      %b |       %b             %b",
            $time, execute_use_ra, execute_use_rb, memory_writes, wb_writes, is_memory_instruction, mem_dest, wb_dest, execute_ra, execute_rb,
            fwd_A_memory_execute, fwd_B_memory_execute, fwd_A_wb_execute, fwd_B_wb_execute, stall_structural, stall_data);

        // Case 5 : Execute Stall

        execute_use_ra = 1; execute_use_rb = 0; memory_writes = 0; wb_writes = 0;
        is_memory_instruction = 1;
        mem_dest = 2'b00; wb_dest = 2'b01; execute_ra = 2'b00; execute_rb = 2'b11;

        #5 $display("%t |    %b         %b       %b     %b     %b    %b      %b     %b  %b  |    %b       %b      %b      %b |       %b             %b",
            $time, execute_use_ra, execute_use_rb, memory_writes, wb_writes, is_memory_instruction, mem_dest, wb_dest, execute_ra, execute_rb,
            fwd_A_memory_execute, fwd_B_memory_execute, fwd_A_wb_execute, fwd_B_wb_execute, stall_structural, stall_data);

        execute_use_ra = 0; execute_use_rb = 1; memory_writes = 0; wb_writes = 0;
        is_memory_instruction = 1;
        mem_dest = 2'b00; wb_dest = 2'b01; execute_ra = 2'b10; execute_rb = 2'b00;

        #5 $display("%t |    %b         %b       %b     %b     %b    %b      %b     %b  %b  |    %b       %b      %b      %b |       %b             %b",
            $time, execute_use_ra, execute_use_rb, memory_writes, wb_writes, is_memory_instruction, mem_dest, wb_dest, execute_ra, execute_rb,
            fwd_A_memory_execute, fwd_B_memory_execute, fwd_A_wb_execute, fwd_B_wb_execute, stall_structural, stall_data);

        $display("Testbench finished.");
        $stop();
	end
endmodule : Hazard_Unit_tb