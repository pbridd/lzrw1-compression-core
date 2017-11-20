module decompressor_top_tb;
	// parameter declarations
	parameter CLOCK_TOGGLE_RATE = 5;

	// signal declarations
	logic clock, reset;

	logic[7:0] charvector_1[20:0];

	string compressed_file, control_word_file, decompressed_file;

	//	populate test vectors	
	initial begin
		// 1. assign the first set of testvector files
		compressed_file = "basic_compression_c.bin";
		decompressed_file = "basic_compression_d.bin";
		control_word_file = "basic_compression_cw.bin";


	end	



	// clock generator
	initial begin
		clock = 1'b0;
		forever 
			#CLOCK_TOGGLE_RATE clock = ~clock;
	end

endmodule