module Hazard_Unit (execute_use_ra, execute_use_rb, memory_writes, wb_writes, is_memory_instruction, execute_ra, execute_rb, mem_dest, 
	                wb_dest, fwd_A_memory_execute, fwd_B_memory_execute, fwd_A_wb_execute, fwd_B_wb_execute, stall_structural, stall_data);
	
	input execute_use_ra, execute_use_rb, memory_writes, wb_writes, is_memory_instruction;
	input [1:0] execute_ra, execute_rb, mem_dest, wb_dest;

	output fwd_A_memory_execute, fwd_B_memory_execute, fwd_A_wb_execute, fwd_B_wb_execute, stall_structural, stall_data;

	// Forward from mem stage to execute stage
	assign fwd_A_memory_execute = execute_use_ra && (execute_ra == mem_dest) && memory_writes;
	assign fwd_B_memory_execute = execute_use_rb && (execute_rb == mem_dest) && memory_writes;

	// Forward from wb stage to execute stage
	assign fwd_A_wb_execute = execute_use_ra && (execute_ra == wb_dest) && wb_writes;
	assign fwd_B_wb_execute = execute_use_rb && (execute_rb == wb_dest) && wb_writes;

	// Stall fetch when mem stage instruction uses memory
	assign stall_structural = is_memory_instruction;

	// Stall execute when the data it needs will come from an instruction uses memory
	assign stall_data = is_memory_instruction && ( (execute_use_ra && (execute_ra == mem_dest)) || (execute_use_rb && (execute_rb == mem_dest)));

endmodule : Hazard_Unit