# Config
set ip_prj_name  "tmp_vivado_ip"
set ip_version   1
#set src_dirs     ["./vhdl/Filters" "./vhdl/ADAU1761"]
set prj_name     "tmp_vivado"

set src_dir [lindex $argv 0]

# Create dummy project
create_project -f ${prj_name} ./${prj_name} -part xc7z020clg400-1
set_property board_part tul.com.tw:pynq-z2:part0:1.0 [current_project]
set_property target_language VHDL [current_project]

# Infer IP core
ipx::infer_core -vendor cramsay.co.uk -library cramsay -taxonomy /UserIP ${src_dir}
ipx::edit_ip_in_project -upgrade true -name ${ip_prj_name} -directory ./${ip_prj_name} ${src_dir}/component.xml
update_compile_order -fileset sources_1
ipx::current_core ${src_dir}/component.xml
set_property core_revision ${ip_version} [ipx::current_core]
ipx::create_xgui_files [ipx::current_core]
ipx::update_checksums [ipx::current_core]
ipx::save_core [ipx::current_core]
ipx::move_temp_component_back -component [ipx::current_core]
close_project -delete
