vlib work
vlog *v
vsim -voptargs=+acc work.normal_tb
add wave -position insertpoint  \
sim:/not_pipelined_tb/clk \
sim:/not_pipelined_tb/rst \
sim:/not_pipelined_tb/interrupt_tb \
sim:/not_pipelined_tb/in_tb \
sim:/not_pipelined_tb/out_dut
add wave -position insertpoint  \
sim:/not_pipelined_tb/dut/reg_file_inst/R0 \
sim:/not_pipelined_tb/dut/reg_file_inst/R1 \
sim:/not_pipelined_tb/dut/reg_file_inst/R2 \
sim:/not_pipelined_tb/dut/reg_file_inst/R3 \
sim:/not_pipelined_tb/dut/CU_inst/read_reg_a_sel \
sim:/not_pipelined_tb/dut/CU_inst/read_reg_b_sel \
sim:/not_pipelined_tb/dut/CU_inst/write_reg_en \
sim:/not_pipelined_tb/dut/CU_inst/write_reg_address_sel \
sim:/not_pipelined_tb/dut/CU_inst/write_reg_data_sel \
sim:/not_pipelined_tb/dut/CU_inst/write_to_reg \
sim:/not_pipelined_tb/dut/CU_inst/destination_addr \
sim:/not_pipelined_tb/dut/mem_wrapper_inst/sel \
sim:/not_pipelined_tb/dut/mem_wrapper_inst/M0/mem \
sim:/not_pipelined_tb/dut/r4_alu_out \
sim:/not_pipelined_tb/dut/r4_mem_out \
sim:/not_pipelined_tb/dut/r4_reg_wr_data_sel \
sim:/not_pipelined_tb/dut/reg_file_inst/wr_data \
sim:/not_pipelined_tb/dut/mem_wrapper_inst/data \
sim:/not_pipelined_tb/dut/mem_wrapper_inst/rd_data \
sim:/not_pipelined_tb/dut/mem_wrapper_inst/address_wire \
sim:/not_pipelined_tb/dut/Hazard_Unit_inst/execute_use_ra \
sim:/not_pipelined_tb/dut/Hazard_Unit_inst/execute_use_rb \
sim:/not_pipelined_tb/dut/Hazard_Unit_inst/memory_writes \
sim:/not_pipelined_tb/dut/Hazard_Unit_inst/wb_writes \
sim:/not_pipelined_tb/dut/Hazard_Unit_inst/is_memory_instruction \
sim:/not_pipelined_tb/dut/Hazard_Unit_inst/execute_ra \
sim:/not_pipelined_tb/dut/Hazard_Unit_inst/execute_rb \
sim:/not_pipelined_tb/dut/Hazard_Unit_inst/mem_dest \
sim:/not_pipelined_tb/dut/Hazard_Unit_inst/wb_dest \
sim:/not_pipelined_tb/dut/Hazard_Unit_inst/fwd_A_memory_execute \
sim:/not_pipelined_tb/dut/Hazard_Unit_inst/fwd_B_memory_execute \
sim:/not_pipelined_tb/dut/Hazard_Unit_inst/fwd_A_wb_execute \
sim:/not_pipelined_tb/dut/Hazard_Unit_inst/fwd_B_wb_execute \
sim:/not_pipelined_tb/dut/selected_flag \
sim:/not_pipelined_tb/dut/r2_branch_flag \
sim:/not_pipelined_tb/dut/r2_pc_load_en \
sim:/not_pipelined_tb/dut/r2_pc_load_data_sel

run -all