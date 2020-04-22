# Config
set prj_name     "tmp_vivado"
set ip_prj_name  "tmp_vivado_ip"
set src_dir      "./hdl"

set clk_pin      "clk_100"
set axis_in_bus  "AXIS_hphone"
set axis_out_bus "AXIS_line_in"

set ip_version   2

# Create dummy project
create_project ${prj_name} ./${prj_name} -part xc7z020clg400-1
set_property board_part tul.com.tw:pynq-z2:part0:1.0 [current_project]
set_property target_language VHDL [current_project]

# Infer IP core
ipx::infer_core -vendor user.org -library user -taxonomy /UserIP ${src_dir}

# Pair clks to interfaces
ipx::edit_ip_in_project -upgrade true -name ${ip_prj_name} -directory ./${ip_prj_name} ${src_dir}/component.xml
update_compile_order -fileset sources_1
ipx::infer_bus_interface ${clk_pin} xilinx.com:signal:clock_rtl:1.0 [ipx::current_core]
ipx::associate_bus_interfaces -busif ${axis_in_bus} -clock ${clk_pin} [ipx::current_core]
ipx::associate_bus_interfaces -busif ${axis_out_bus} -clock ${clk_pin} [ipx::current_core]

# Re-package
set_property core_revision ${ip_version} [ipx::current_core]
ipx::update_source_project_archive -component [ipx::current_core]
ipx::create_xgui_files [ipx::current_core]
ipx::update_checksums [ipx::current_core]
ipx::save_core [ipx::current_core]
ipx::move_temp_component_back -component [ipx::current_core]
close_project -delete
