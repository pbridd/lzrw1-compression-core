//
//
// 
//
//
//

module decompressor_top(
		clock,				// clock input
		reset,				// reset input
		data_in,			// The 2 byte data-in field
		control_word_in,	// The control word that corresponds to data-in
		in_data_valid,		// when this is 1'b1, the decompressor will use the inputs
		history_full,		// FYI: the history buffer is full. Output might not be valid.
		decompressed_byte, // the decompressed output
		out_valid,			// whether the output is valid. Don't use data if 0.
		decompressor_busy	// whether the decompressor is busy. When this is 1'b1, the decompressor will ignore all data inputs.
	);
	
	input clock, reset;
	input[15:0] data_in;
	input control_word_in;
	input in_data_valid;
	output history_full;
	output[7:0] decompressed_byte;
	output out_valid;

	// decompression fsm
	// states:
	//	D_IDLE: no input, not busy
	//	D_PASS_THROUGH: regular mode -- no decompression needed on current byte
	//	D_DECOMPRESS: Currently decompressing something




endmodule