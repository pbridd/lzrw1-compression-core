TESTVECTORSFLAGS =  --num_chars 256 --num_vectors 100 --manual_tv test_vectors/manual_tvs.txt --io_path test_vectors/

run_decompressor_testbench: compile_decompressor_sv 
	# put info here
	vsim -c -GNUM_AUTO_TESTS=100 deompressor_top_tv

compile_decompressor_sv:
	vlog -sv decompressor/history_buffer.sv decompressor/decompressor_tob.sv decompressor/decompressor_top_tv.sv

create_test_vectors:
	python test_vectors/GenerateVectors.py $(TESTVECTORSFLAGS)

clean_test_vectors:
	rm test_vectors/*bin

clean:
	rm -rf work