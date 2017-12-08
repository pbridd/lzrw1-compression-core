TESTVECTORSFLAGS =  --num_chars 256 --num_vectors 100 --manual_tv manual_tvs.txt --io_path test_vectors/

run_top_testbench: compile_testbench_sv
	vsim -c top

run_decompressor_testbench: compile_decompressor_sv 
	# put info here
	vsim -c -GNUM_AUTO_TESTS=100 decompressor_top_tb

run_compressor_testbench: compile_compressor_sv
	vsim -c compinput_tb

compile_testbench_sv: compile_compressor_sv compile_decompressor_sv
	vlog -sv TBandDesign/top.sv

compile_compressor_sv: make_vlib
	vlog -sv compressor/Comparator.sv compressor/compinput.sv compressor/hashFunction.sv compressor/tableofPtr.sv compressor/CompressedValues.sv compressor/compressor_top.sv compressor/compinput_tb.sv

compile_decompressor_sv: make_vlib
	vlog -sv decompressor/history_buffer.sv decompressor/decompressor_top.sv decompressor/decompressor_top_tb.sv

create_test_vectors:
	python3 test_vectors/GenerateVectors.py $(TESTVECTORSFLAGS)

make_vlib:
	vlib work

clean_test_vectors:
	rm test_vectors/*bin


clean:
	rm -rf work

