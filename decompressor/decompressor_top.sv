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
		out_byte,			// the output byte. One byte at a time.
		out_valid			// whether the output is valid. Don't use data if 0.
	);

	input clock, reset;
	input[15:0] data_in;
	input control_word_in;
	input in_data_valid;
	output history_full;
	output[7:0] out_byte;
	output out_valid;

	




endmodule