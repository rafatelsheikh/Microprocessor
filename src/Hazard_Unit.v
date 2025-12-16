module Hazard_Unit (decode_use_ra, decode_use_rb, execute_use_ra, execute_use_rb, memory_writes, wb_writes, is_memory_instruction, decode_ra, decode_rb, execute_ra, execute_rb, mem_dest, 
	                wb_dest, fwd_A_memory_execute, fwd_B_memory_execute, fwd_A_wb_execute, fwd_B_wb_execute, fwd_A_wb_decode, fwd_B_wb_decode, stall_structural, stall_data);
	
	input decode_use_ra, decode_use_rb, execute_use_ra, execute_use_rb, memory_writes, wb_writes, is_memory_instruction;
	input [1:0] decode_ra, decode_rb, execute_ra, execute_rb, mem_dest, wb_dest;

	output fwd_A_memory_execute, fwd_B_memory_execute, fwd_A_wb_execute, fwd_B_wb_execute, fwd_A_wb_decode, fwd_B_wb_decode, stall_structural, stall_data;

	// Forward from mem stage to execute stage
	assign fwd_A_memory_execute = execute_use_ra && (execute_ra == mem_dest) && memory_writes;
	assign fwd_B_memory_execute = execute_use_rb && (execute_rb == mem_dest) && memory_writes;

	// Forward from wb stage to execute stage
	assign fwd_A_wb_execute = execute_use_ra && (execute_ra == wb_dest) && wb_writes;
	assign fwd_B_wb_execute = execute_use_rb && (execute_rb == wb_dest) && wb_writes;

	// Forward from wb stage to decode stage
	assign fwd_A_wb_decode = decode_use_ra && (decode_ra == wb_dest) && wb_writes;
	assign fwd_B_wb_decode = decode_use_rb && (decode_rb == wb_dest) && wb_writes;

	// Stall fetch when mem stage instruction uses memory
	assign stall_structural = is_memory_instruction;

	// Stall execute when the data it needs will come from an instruction uses memory
	assign stall_data = is_memory_instruction && memory_writes && ( (execute_use_ra && (execute_ra == mem_dest)) || (execute_use_rb && (execute_rb == mem_dest)));


endmodule : Hazard_Unit
