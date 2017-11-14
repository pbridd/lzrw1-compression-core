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

	typedef struct packed {
		logic[3:0] length;
		logic[11:0] offset;
	} compressed_t;

	typedef union packed {
		logic[15:0] character;
		compressed_t compressed_objects;

	} data_in_t;
	
	input clock, reset;
	input data_in_t data_in;
	input control_word_in;
	input in_data_valid;
	output history_full;
	output[7:0] decompressed_byte;
	output out_valid;
	output decompressor_busy;

	

	typedef enum {
		IDLE,
		PASS_THROUGH,
		DECOMPRESS
	} decomp_state_type;

	decomp_state_type decomp_state, decomp_state_next;
	logic[HISTORY_ADDR_WIDTH-1:0] history_out_addr, history_out_addr_next, history_in_addr, history_in_addr_next;
	logic[HISTORY_ADDR_WIDTH-1:0] history_max_addr, history_max_addr_next;
	logic history_buffer_wr_en;
	logic[15:0] history_buffer_result;
	data_in_t data_in_fp, data_in_fp_next;
	logic control_word_in_fp, control_word_in_fp_next;

	assign data_in_int = data_in;

	// flip flops
	always_ff @ (posedge clock, posedge reset) begin
		if(reset) begin
			decomp_state <= IDLE;
			history_out_addr <= '0;
			history_in_addr <= '0;
			history_max_addr <= '0;
			data_in_fp <= '0;
			control_word_in_fp <= '0;
		end
		else if(clock) begin
			decomp_state <= decomp_state_next;
			history_out_addr <= history_out_addr_next;
			history_in_addr <= history_in_addr_next;
			history_max_addr <= history_max_addr_next;
			data_in_fp <= data_in_fp_next;
			control_word_in_fp <= control_word_in_fp_next;
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
		data_in_fp_next = data_in_fp;
		control_word_in_fp_next = control_word_in_fp;
		history_in_addr_next = history_in_addr;
		decompressed_byte = '0;
		out_valid = 1'b0;

		decompressor_busy = 1'b1;
		case(decomp_state)
			IDLE: begin
				decompressor_busy = 1'b0;
				if(in_data_valid) begin
					// 1. Flop the data
					data_in_fp_next = data_in;
					control_word_in_fp_next = control_word_in;

					// 2. write data to the history buffer and increment history pointer
					history_buffer_wr_en = 1'b1;
					history_in_addr_next = history_in_addr + 1;

					// 3. determine the next state
					if(control_word_in == 1'b0) 
						decom_state_next = PASS_THROUGH;
					else begin
						decomp_state_next = DECOMPRESS;
						history_out_addr_next = history_in_addr - data_in.compressed_objects.offset;
						history_max_addr = history_in_addr - data_in.compressed_objects.offset + length - 1;
					end
				end
			end
			PASS_THROUGH: begin
				
				//assign outputs
				decompressed_byte = data_in_fp.character[7:0];
				out_valid = 1'b1;

				decomp_state_next = IDLE;
			end
			DECOMPRESS: begin
				//assign outputs
				decompressed_byte = history_buffer_result[7:0];
				out_valid = 1'b1;

				if(history_out_addr <= history_max_addr) begin
					history_out_addr_next = history_out_addr + 1;
				end
				else
					decom_state_next = IDLE;

			end
		endcase
	end




endmodule