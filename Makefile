all: PynqZ2 wheel

wheel:
	python3 setup.py bdist_wheel

PynqZ2:
	cd hw/PynqZ2 && $(MAKE)
	
clean_PynqZ2:
	cd hw/PynqZ2 && $(MAKE) clean
