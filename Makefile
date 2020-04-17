all: Pynq-Z2 wheel

wheel:
	python3 setup.py bdist_wheel

Pynq-Z2:
	cd hw/Pynq-Z2 && $(MAKE)
	
clean_Pynq-Z2:
	cd hw/Pynq-Z2 && $(MAKE) clean
