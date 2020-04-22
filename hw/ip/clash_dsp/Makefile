ip := ./vhdl/component.xml

all: $(ip)

vhdl:
	  nix-shell --run "clash --vhdl src/Filters"; sed -i 's/clash_dsp_types.clk_audiodomain/std_logic/g' vhdl/Filters/clash_dsp/clash_dsp.vhdl; sed -i 's/clash_dsp_types.rst_audiodomain/std_logic/g' vhdl/Filters/clash_dsp/clash_dsp.vhdl

$(ip): vhdl
	vivado -mode batch -notrace -nojournal -nolog -source create_ip.tcl

clean:
	rm -rf vhdl tmp_vivado *.jou *.log NA src/*.hi src/*.o
