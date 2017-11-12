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

	parameter HISTORY_SIZE = 4096;
	localparam HISTORY_ADDR_WIDTH = $clog2(HISTORY_SIZE);
	
	input clock, reset;
	input[15:0] data_in;
	input control_word_in;
	input in_data_valid;
	output history_full;
	output[7:0] decompressed_byte;
	output out_valid;

	typedef enum {
		IDLE,
		PASS_THROUGH,
		DECOMPRESS
	} decomp_state_type;

	decomp_state_type decomp_state, decomp_state_next;
	logic[HISTORY_ADDR_WIDTH-1:0] history_out_addr, history_out_addr_next;

	// flip flops
	always_ff @ (posedge clock, posedge reset) begin
		if(reset) begin
			decomp_state <= IDLE;
			history_out_addr <= '0;
		end
		else if(clock) begin
			decomp_state <= decomp_state_next;
			history_out_addr <= history_out_addr_next;
		end
	end

	// decompression fsm
	// states:
	//	D_IDLE: no input, not busy
	//	D_PASS_THROUGH: regular mode -- no decompression needed on current byte
	//	D_DECOMPRESS: Currently decompressing something
	always_comb begin : decompressor_fsm
		decomp_state_next = decomp_state;
		history_out_addr_next = history_out_addr;
		case(decomp_state)
			IDLE: begin
				if(in_data_valid) begin
					if(control_word_in == 1'b0) 
						decom_state_next = PASS_THROUGH;
					else
						decomp_state_next = DECOMPRESS;
			end
			PASS_THROUGH: begin
				if(in_data_valid) begin
					if(control_word_in == 1'b0) 
						decom_state_next = PASS_THROUGH;
					else
						decomp_state_next = DECOMPRESS;
			end
			DECOMPRESS: begin

			end
	end




endmodule