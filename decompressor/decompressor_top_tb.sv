module decompressor_top_tb;
	// parameter declarations
	parameter CLOCK_TOGGLE_RATE = 5;
	parameter MAX_FILE_SIZE = 4096;

	// signal declarations
	logic clock, reset;

	logic[15:0] tv_compressed_array[MAX_FILE_SIZE-1:0];
	byte tv_decompressed_array[MAX_FILE_SIZE:0];
	logic[0:7] tv_control_word_array[MAX_FILE_SIZE-1:0];

	logic[7:0] test_output_byte_array[MAX_FILE_SIZE-1:0];

	//inputs and outputs to decompressor module
	logic[15:0] dut_data_in;
	logic dut_control_word_in, dut_data_in_valid, dut_out_valid, dut_decompressor_busy;
	logic[7:0] dut_decompressed_byte;

	string tv_compressed_filename, tv_control_word_filename, tv_decompressed_filename;

	// TASKS
	task getTestVectors(input string compressed_filename, decompressed_filename, control_word_filename,
		output logic[15:0] compressed_array[MAX_FILE_SIZE-1:0], output byte decompressed_array[MAX_FILE_SIZE:0],
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

	//	populate test vectors	
	initial begin
		// 1. assign the first set of testvector files
		tv_compressed_filename = "test_vectors/basic_compression_c.bin";
		tv_decompressed_filename = "test_vectors/basic_compression_d.bin";
		tv_control_word_filename = "test_vectors/basic_compression_cw.bin";

		for(int k = 0; k < MAX_FILE_SIZE; k++) begin
			tv_compressed_array[k] = '0;
			tv_control_word_array[k] = '0;
			tv_decompressed_array[k] = '0;
		end

		// get first testvectors
		getTestVectors(tv_compressed_filename, tv_decompressed_filename, tv_control_word_filename,
			tv_compressed_array, tv_decompressed_array, tv_control_word_array);


	end	

	// feed stimulus in
	initial begin
		// initialize the decompressor
		dut_data_in = '0;
		dut_control_word_in = '0;
		dut_data_in_valid = '0;

		reset_decompressor;


		// feed in stimulus
		for(int i = 0; i < MAX_FILE_SIZE; i++) begin

			// make sure we're passing valid data in
			if(tv_compressed_array[i] === 0 || ^tv_compressed_array[i] === 1'bX) begin
				$display("Data input terminated at iteration %d", i);
				break;
			end
			
			dut_data_in = tv_compressed_array[i];
			dut_control_word_in = tv_control_word_array[i/8][i%8];
			dut_data_in_valid = 1'b1;

			// wait for busy to go low
			@(negedge dut_decompressor_busy);
		end
	end

	// capture data out
	initial begin
		automatic int errors = 0;

		wait_for_decompressor_reset;	// wait for reset sequence to end
		
		for(int j = 0; j < MAX_FILE_SIZE; j++) begin
			@(dut_out_valid); 			// wait until the output byte is valid
				test_output_byte_array[j] = dut_decompressed_byte;
			@(posedge clock);			// wait at least until the next clock for the next byte
		end


		// check the output data against the test vector
		for(int j = 0; j < MAX_FILE_SIZE; j++) begin
			assert(test_output_byte_array[j] === tv_decompressed_array[j])
			else begin
				$error("-E- Actual output %c did not match expected output %c at index %d", test_output_byte_array[j], tv_decompressed_array[j], j);
				errors++;
			end
		end
		
		// whether or not there were errors, display the strings 
		//TODO pbridd: see above

		//display number of errors
		$display("Total number of errors found was %d", errors);

	end

	// clock generator
	initial begin
		clock = 1'b0;
		forever 
			#CLOCK_TOGGLE_RATE clock = ~clock;
	end

	task wait_until_rising_edge; begin 
		@(posedge clock);
	end
	endtask

	task wait_until_falling_edge; begin 
		@(negedge clock);
	end
	endtask

	// instantiation of decompressor
 	decompressor_top decompressor_dut(
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