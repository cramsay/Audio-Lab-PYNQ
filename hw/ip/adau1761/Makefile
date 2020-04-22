ip := ./hdl/component.xml

all: $(ip)

$(ip):
	vivado -mode batch -notrace -nojournal -nolog -source create_ip.tcl

clean:
	rm -rf tmp_vivado *.jou *.log NA hdl/xgui hdl/component.xml

