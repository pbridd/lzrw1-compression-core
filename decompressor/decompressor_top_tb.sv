module decompressor_top_tb;
	// parameter declarations
	parameter CLOCK_TOGGLE_RATE = 5;
	parameter MAX_FILE_SIZE = 4096;

	localparam MAX_ADDRESS_WIDTH = $clog2(MAX_FILE_SIZE);

	// signal declarations
	logic clock, reset;


	logic[7:0] test_output_byte_array[MAX_FILE_SIZE-1:0];

	//inputs and outputs to decompressor module
	logic[15:0] dut_data_in;
	logic dut_control_word_in, dut_data_in_valid, dut_out_valid, dut_decompressor_busy;
	logic[7:0] dut_decompressed_byte;

	//internal flags
	bit unsigned input_done_flag;
	integer unsigned last_address_captured;  


	////////////////////////////////////////////////////////////////////////////////////////////////////
	// Essential tasks
	////////////////////////////////////////////////////////////////////////////////////////////////////	
	task getTestVectors(input string compressed_filename, decompressed_filename, control_word_filename,
		output logic[7:0] compressed_array[MAX_FILE_SIZE-1:0], output logic[7:0] decompressed_array[MAX_FILE_SIZE-1:0],
		output logic[0:7] control_word_array[MAX_FILE_SIZE-1:0]);
		int compressed_file, decompressed_file, control_word_file;
		int temp_int;

		// process the compressed file
		compressed_file = $fopen(compressed_filename, "r");
		if(!compressed_file) begin
			$display("Could not open %s", compressed_filename);
			$finish;
		end
		else
			temp_int = $fread(compressed_array, compressed_file);
		

		//process the decompressed file
		decompressed_file = $fopen(decompressed_filename, "r");
		if(!decompressed_file) begin
			$display("Could not open %s", decompressed_filename);
			$finish;
		end
		else
			temp_int = $fread(decompressed_array, decompressed_file);

		// process the control word file
		control_word_file = $fopen(control_word_filename, "r");
		if(!control_word_file) begin
			$display("Could not open %s", control_word_file);
			$finish;
		end
		else
			temp_int = $fread(control_word_array, control_word_file);
	endtask

	task reset_decompressor;
		reset <= 1'b1;
		repeat(3)	// wait for three cycles of the clock
			wait_until_rising_edge;
		reset <= 1'b0;
	endtask;

	task wait_for_decompressor_reset;
		@(negedge reset);
	endtask

	task initialize_global_values;
		input_done_flag = 1'b0;
		last_address_captured = 0;  
	endtask : initialize_global_values

	task run_testvector(input string tv_compressed_filename, tv_decompressed_filename, tv_control_word_filename, output int return_value);
		logic[7:0] local_tv_compressed_array[MAX_FILE_SIZE-1:0];
		logic[7:0] local_tv_decompressed_array[MAX_FILE_SIZE-1:0];
		logic[0:7] local_tv_control_word_array[MAX_FILE_SIZE-1:0];

		// clear all global state
		initialize_global_values;

		// initialize the arrays
		for(int k = 0; k < MAX_FILE_SIZE; k++) begin
			local_tv_compressed_array[k] = '0;
			local_tv_control_word_array[k] = '0;
			local_tv_decompressed_array[k] = '0;
			test_output_byte_array[k] = '0;
		end

		// get test vectors from file
		getTestVectors(tv_compressed_filename, tv_decompressed_filename, tv_control_word_filename,
			local_tv_compressed_array, local_tv_decompressed_array, local_tv_control_word_array);

		fork
			feed_in_testvectors(local_tv_compressed_array, local_tv_decompressed_array, local_tv_control_word_array);
			capture_data_out;
		join
		
		check_data_out(local_tv_decompressed_array, return_value);

	endtask : run_testvector

	task feed_in_testvectors(input logic[7:0] local_tv_compressed_array[MAX_FILE_SIZE-1:0], 
		logic[7:0] local_tv_decompressed_array[MAX_FILE_SIZE-1:0],
		logic[0:7] local_tv_control_word_array[MAX_FILE_SIZE-1:0]);
		integer current_compressed_byte;

		current_compressed_byte = 0;
		
		//initialize flags
		input_done_flag = 1'b0;

		// initialize the decompressor
		dut_data_in = '0;
		dut_control_word_in = '0;
		dut_data_in_valid = '0;

		reset_decompressor;


		// feed in stimulus
		for(int i = 0; i < MAX_FILE_SIZE; i++) begin

			// make sure we're passing valid data in
			if(local_tv_compressed_array[current_compressed_byte] === 0 || ^local_tv_compressed_array[current_compressed_byte] === 1'bX || local_tv_control_word_array[i] === 1'bX || (local_tv_control_word_array[i/8][i%8] == 1'b1 && local_tv_compressed_array[current_compressed_byte+1] === 0 || ^local_tv_compressed_array[current_compressed_byte+1] === 1'bX)) begin
				$display("Data input terminated at iteration %d", i);
				dut_data_in = '0;
				dut_control_word_in = '0;
				dut_data_in_valid = '0;
				input_done_flag = 1'b1;
				break;
			end
			if(local_tv_control_word_array[i/8][i%8] == 1'b1) begin
				dut_data_in = {local_tv_compressed_array[current_compressed_byte], local_tv_compressed_array[current_compressed_byte+1]}; 
				current_compressed_byte += 2;
			end
			else begin
				dut_data_in = {8'b0 , local_tv_compressed_array[current_compressed_byte]};
				current_compressed_byte += 1;
			end
			dut_control_word_in = local_tv_control_word_array[i/8][i%8];
			dut_data_in_valid = 1'b1;

			// wait for busy to go low
			@(negedge dut_decompressor_busy);
		end
	endtask : feed_in_testvectors


	task capture_data_out;
		automatic int j;
		j = 0;

		last_address_captured = 0;

		wait_for_decompressor_reset;	// wait for reset sequence to end
		
		forever begin
			@(negedge clock); 			// wait until the output byte is valid
			if(input_done_flag)
				break;
			if(dut_out_valid) begin
				test_output_byte_array[j] = dut_decompressed_byte;
				last_address_captured = j;
				j++;
			end
		end
	endtask

	task check_data_out(input logic[7:0] local_tv_decompressed_array[MAX_FILE_SIZE-1:0], output int errors_out);
		automatic int errors;
		errors = 0;

		// check the output data against the test vector
		for(int j = 0; j <= last_address_captured; j++) begin
			assert(test_output_byte_array[j] === local_tv_decompressed_array[j])
			else begin
				$error("-E- Actual output %c did not match expected output %c at index %d", test_output_byte_array[j], local_tv_decompressed_array[j], j);
				errors++;
			end
		end
		

		// whether or not there were errors, display the strings 
		$write("Expected string: ");
		for (int k = 0; k <= last_address_captured; k++) begin
			$write("%c", local_tv_decompressed_array[k]);
		end
		$write("\n");

		$write("Actual string: ");
		for (int k = 0; k <= last_address_captured; k++) begin
			$write("%c", test_output_byte_array[k]);
		end
		$write("\n");

		//display number of errors
		$display("Total number of errors found was %d", errors);

		errors_out = errors;

	endtask : check_data_out


	////////////////////////////////////////////////////////////////////////////////////////////////////
	// Run tests
	////////////////////////////////////////////////////////////////////////////////////////////////////	
	initial begin
		string tv_compressed_filename, tv_control_word_filename, tv_decompressed_filename;
		int return_value;
		int num_tests_failed;
		num_tests_failed = 0;

		$display("Starting manually generated test 1...");
		// 1. assign the first set of testvector files
		tv_compressed_filename = "test_vectors/basic_compression_c.bin";
		tv_decompressed_filename = "test_vectors/basic_compression_d.bin";
		tv_control_word_filename = "test_vectors/basic_compression_cw.bin";
		return_value = 0;

		// get first testvectors
		run_testvector( tv_compressed_filename, tv_decompressed_filename, tv_control_word_filename, return_value);
		if(return_value > 0)
			num_tests_failed ++;

		$display("Starting automatically generated testvectors...");
		for (int testnum = 0; testnum < 10; testnum ++) begin
			$display("Starting automatically generated test %d...", testnum);
			// 1. assign the first set of testvector files
			$sformat(tv_compressed_filename, "test_vectors/generated_tv_%0d_c.bin", testnum);
			$sformat(tv_decompressed_filename, "test_vectors/generated_tv_%0d_d.bin", testnum);
			$sformat(tv_control_word_filename, "test_vectors/generated_tv_%0d_cw.bin", testnum);
			return_value = 0;

			// get first testvectors
			run_testvector( tv_compressed_filename, tv_decompressed_filename, tv_control_word_filename, return_value);
			if(return_value > 0)
				num_tests_failed ++;
		end

		$display("Total tests failed was %0d out of 1 + %0d", num_tests_failed, testnum);
	end	


	// clock generator
	initial begin
		clock = 1'b0;
		forever 
			#CLOCK_TOGGLE_RATE clock = ~clock;
	end

	task wait_until_rising_edge; 
		@(posedge clock);
	endtask

	task wait_until_falling_edge;
		@(negedge clock);
	endtask

	// instantiation of decompressor
 	decompressor_top #(.HISTORY_SIZE(256))
 		decompressor_dut(
 		.clock(clock),								// clock input
		.reset(reset),								// reset input
		.data_in(dut_data_in),						// The 2 byte data-in field
		.control_word_in(dut_control_word_in),		// The control word that corresponds to data-in
		.data_in_valid(dut_data_in_valid),			// when this is 1'b1, the decompressor will use the inputs
		.decompressed_byte(dut_decompressed_byte), // the decompressed output
		.out_valid(dut_out_valid),					// whether the output is valid. Don't use data if 0.
		.decompressor_busy(dut_decompressor_busy)	// whether the decompressor is busy. When this is 1'b1, the decompressor will ignore all data inputs.
	);

endmodule