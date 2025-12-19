vlib work
vlog *v
vsim -voptargs=+acc work.normal_tb
add wave -position insertpoint  \
sim:/normal_tb/clk \
sim:/normal_tb/rst \
sim:/normal_tb/interrupt_tb \
sim:/normal_tb/in_tb \
sim:/normal_tb/out_dut \
sim:/normal_tb/dut/reg_file_inst/R0 \
sim:/normal_tb/dut/reg_file_inst/R1 \
sim:/normal_tb/dut/reg_file_inst/R2 \
sim:/normal_tb/dut/reg_file_inst/R3 \
sim:/normal_tb/dut/CU_inst/read_reg_a_sel \
sim:/normal_tb/dut/CU_inst/read_reg_b_sel \
sim:/normal_tb/dut/CU_inst/write_reg_en \
sim:/normal_tb/dut/CU_inst/write_reg_address_sel \
sim:/normal_tb/dut/CU_inst/write_reg_data_sel \
sim:/normal_tb/dut/CU_inst/write_to_reg \
sim:/normal_tb/dut/CU_inst/destination_addr \
sim:/normal_tb/dut/mem_wrapper_inst/sel \
sim:/normal_tb/dut/mem_wrapper_inst/M0/mem \
sim:/normal_tb/dut/r4_alu_out \
sim:/normal_tb/dut/r4_mem_out \
sim:/normal_tb/dut/r4_reg_wr_data_sel \
sim:/normal_tb/dut/reg_file_inst/wr_data \
sim:/normal_tb/dut/mem_wrapper_inst/data \
sim:/normal_tb/dut/mem_wrapper_inst/rd_data \
sim:/normal_tb/dut/mem_wrapper_inst/address_wire \
sim:/normal_tb/dut/Hazard_Unit_inst/execute_use_ra \
sim:/normal_tb/dut/Hazard_Unit_inst/execute_use_rb \
sim:/normal_tb/dut/Hazard_Unit_inst/memory_writes \
sim:/normal_tb/dut/Hazard_Unit_inst/wb_writes \
sim:/normal_tb/dut/Hazard_Unit_inst/is_memory_instruction \
sim:/normal_tb/dut/Hazard_Unit_inst/execute_ra \
sim:/normal_tb/dut/Hazard_Unit_inst/execute_rb \
sim:/normal_tb/dut/Hazard_Unit_inst/mem_dest \
sim:/normal_tb/dut/Hazard_Unit_inst/wb_dest \
sim:/normal_tb/dut/Hazard_Unit_inst/fwd_A_memory_execute \
sim:/normal_tb/dut/Hazard_Unit_inst/fwd_B_memory_execute \
sim:/normal_tb/dut/Hazard_Unit_inst/fwd_A_wb_execute \
sim:/normal_tb/dut/Hazard_Unit_inst/fwd_B_wb_execute \
sim:/normal_tb/dut/selected_flag \
sim:/normal_tb/dut/r2_branch_flag \
sim:/normal_tb/dut/r2_pc_load_en \
sim:/normal_tb/dut/r2_pc_load_data_sel

run -all