set proj_name "audio_lab"
set origin_dir "."
set iprepo_dir $origin_dir/../ip

# Create project
create_project ${proj_name} ./${proj_name} -part xc7z020clg400-1
set_property board_part tul.com.tw:pynq-z2:part0:1.0 [current_project]
set_property  ip_repo_paths $iprepo_dir [current_project]
set_property target_language VHDL [current_project]
update_ip_catalog

# Generate block design
source ./block_design.tcl
make_wrapper -files [get_files ./${proj_name}/${proj_name}.srcs/sources_1/bd/block_design/block_design.bd] -top
add_files -norecurse ./${proj_name}/${proj_name}.srcs/sources_1/bd/block_design/hdl/block_design_wrapper.vhd
update_compile_order -fileset sources_1

# Compile
launch_runs impl_1 -to_step write_bitstream -jobs 16
wait_on_run impl_1

# Collect bitstream and hwh files
if {![file exists ./bitstreams/]} {
	file mkdir ./bitstreams/
}
file copy -force ./${proj_name}/${proj_name}.runs/impl_1/block_design_wrapper.bit ./bitstreams/${proj_name}.bit
file copy -force ./${proj_name}/${proj_name}.srcs/sources_1/bd/block_design/hw_handoff/block_design.hwh ./bitstreams/${proj_name}.hwh
