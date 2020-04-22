create_project tmp_vivado ./tmp_vivado -part xc7z020clg400-1
set_property board_part tul.com.tw:pynq-z2:part0:1.0 [current_project]
set_property target_language VHDL [current_project]

ipx::infer_core -vendor user.org -library user -taxonomy /UserIP ./vhdl
