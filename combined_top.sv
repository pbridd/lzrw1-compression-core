module combined_top(
		clock,
		reset,
		valid,
		CurByte,
		decompressed_byte,
		out_valid,
		decompressor_busy
	);

	parameter STRINGSIZE = 4096;
	parameter TABLESIZE = 4096;
	parameter RANDTABLE = 16523;
	localparam TABLE_ADDRESS_WIDTH = $clog2(TABLESIZE);

	//typedefs
	typedef enum {
		COMPRESS,
		DECOMPRESS,
		DONE
	} combined_state_type;


	//I/O declarations
	input clock, reset, valid;
	input [15:0] [7:0] CurByte;
	output [7:0] decompressed_byte;
	output out_valid, decompressor_busy;

	// intermediate signals
	logic c_Done;
	logic[STRINGSIZE-1:0][7:0] compArray;
	logic[STRINGSIZE-1:0] c_controlWord;
	logic[15:0] d_data_in;
	logic d_control_word_in;
	logic d_data_in_valid;
	logic unsigned integer c_controlPtr;
	logic unsigned integer internal_controlPtr, internal_controlPtr_next;	
	logic unsigned integer internal_dataPtr, internal_dataPtr_next;	
	logic d_out_valid;

	// state storage
	combined_state_type comb_state, comb_state_next;

	// pointer locations
	logic [TABLE_ADDRESS_WIDTH-1:0][7:0] control_word_pointer, control_word_pointer_next,
											compressed_pointer, compressed_pointer_next;

	always_ff @(posedge clock or posedge reset) begin : proc_load_data
		if(reset) begin
			comb_state <= COMPRESS;
			control_word_pointer <= '0;
			compressed_pointer <= '0;
			internal_controlPtr <= '0;
			internal_dataPtr <= '0;
		end else begin
			comb_state <= comb_state_next;
			control_word_pointer <= control_word_pointer_next;
			compressed_pointer <= compressed_pointer_next;
			internal_controlPtr <= internal_controlPtr_next;
			internal_dataPtr <= internal_dataPtr_next;
		end
	end

	always_comb begin
		case(comb_state):
			comb_state_next = comb_state;
			COMPRESS:
				if(valid == 1'b0 && c_Done)
					comb_state_next = DECOMPRESS;
			DECOMPRESS:
				d_data_in_valid = 1'b1;
				d_data_in = compArray[internal_dataPtr];
				d_control_word_in = c_controlWord[internal_controlPtr];
				if((c_controlPtr == internal_controlPtr) && d_out_valid)
					comb_state_next = DONE;
			DONE:
	end






		// module instantiations
	compressor_top compressor(
			.clock(clock),
			.reset(reset),
			.valid(valid),
			.CurByte(CurByte),
			.compArray(compArray),
			.controlWord(c_controlWord),
			.Done(c_Done),
			.uniqnums(),
			.controlPtr(c_controlPtr)
		);
	decompressor_top decompressor(
			.clock(clock),
			.reset(reset),
			.data_in(d_data_in),
			.control_word_in(d_control_word_in),
			.data_in_valid(d_data_in_valid),
			.decompressed_byte(decompressed_byte),
			.out_valid(d_out_valid),
			.decompressor_busy(decompressor_busy)
		);


endmodule // combined_top