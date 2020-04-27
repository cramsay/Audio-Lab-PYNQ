ip := ./vhdl/component.xml

LIBS := LowPassFir ADAU1761

SRCS := $(foreach LIB, $(LIBS), ./src/$(LIB).hs)
VHDLS := $(foreach LIB, $(LIBS), ./vhdl/$(LIB))
IPS := $(foreach VHDL, $(VHDLS), $(VHDL)/component.xml)

all: $(IPS)

vhdl/%/component.xml : vhdl/%
	vivado -mode batch -notrace -nojournal -nolog -source create_ip.tcl -tclargs "$<"

vhdl/%: src/%.hs
	  nix-shell --run "clash -isrc --vhdl $<";
		find $@ -name *.vhdl -type f -print0 | xargs -0 sed -i 's/in [^[:space:]]*\.\(clk\|rst\).*;/in std_logic;/'

clean:
	rm -rf vhdl *.jou *.log NA src/*.hi src/*.o
