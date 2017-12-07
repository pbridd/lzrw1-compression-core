module combined_top(
		clock,
		reset,
		valid,
		CurByte,
		//done,
		decompressed_byte,
		out_valid,
		finished_cycle
	);

	parameter STRINGSIZE = 4096;
	parameter TABLESIZE = 4096;
	parameter RANDTABLE = 16523;
	localparam TABLE_ADDRESS_WIDTH = $clog2(TABLESIZE);

	//typedefs
	typedef enum {
		RESET,
		COMPRESS,
		DECOMPRESS,
		DONE
	} combined_state_type;


	//I/O declarations
	input clock, reset, valid;	//,done;
	input [15:0] [7:0] CurByte;
	output [7:0] decompressed_byte;
	output logic out_valid,finished_cycle;

	// intermediate signals
	logic c_Done;
	logic[STRINGSIZE-1:0][7:0] compArray;
	logic[STRINGSIZE-1:0] c_controlWord;
	logic[15:0] d_data_in;
	logic d_control_word_in;
	logic d_data_in_valid;
	integer unsigned c_controlPtr;
	integer unsigned internal_controlPtr, internal_controlPtr_next;	
	integer unsigned internal_dataPtr, internal_dataPtr_next;	
	logic d_out_valid;
	logic decompressor_busy;

	// state storage
	combined_state_type comb_state, comb_state_next;
	/* MK -> c_Done was only connected to the compressor's input done signal, but the main module itself was not having the done as an input signal */
	//assign c_Done=done;

	always_ff @(posedge clock or posedge reset) begin : proc_load_data
		if(reset) begin
			comb_state <= RESET;	//COMPRESS;
			internal_controlPtr <= '0;
			internal_dataPtr <= '0;
		end else begin
			comb_state <= comb_state_next;
			internal_controlPtr <= internal_controlPtr_next;
			internal_dataPtr <= internal_dataPtr_next;
		end
	end

	always_comb begin
		comb_state_next = comb_state;
		internal_controlPtr_next = internal_controlPtr;
		//internal_dataPtr = internal_dataPtr_next;
		d_data_in = '0;
		d_control_word_in = '0;
		d_data_in_valid = 1'b0;
		finished_cycle = 1'b0;

		case(comb_state)
			RESET :
				begin
				if(reset == 1'b1)
				comb_state_next = RESET;
				else
				comb_state_next = COMPRESS;	 
				end

			COMPRESS:
				begin
				/* MK-> internal_controlPtr was not incrementing in  the compArray */
				internal_controlPtr_next = internal_controlPtr + 1;
				if(valid == 1'b0 && c_Done)
					comb_state_next = DECOMPRESS;
				end
			DECOMPRESS: begin
				d_data_in_valid = 1'b1;
				d_control_word_in = c_controlWord[internal_controlPtr];
				if(!decompressor_busy) begin
					internal_controlPtr_next = internal_controlPtr + 1;
					//figure out whether to pull one or two bytes from the table
					if(compArray[internal_controlPtr] == 1'b0) begin
						d_data_in = {8'b00000000, compArray[internal_dataPtr]};
						internal_dataPtr_next = internal_dataPtr + 1;
					end
					else begin
						d_data_in = {compArray[internal_dataPtr], compArray[internal_dataPtr+1]};
						internal_dataPtr_next = internal_dataPtr + 2;
					end
				end
				
				if((c_controlPtr == internal_controlPtr) && d_out_valid)
					comb_state_next = DONE;
			end
			DONE:
				finished_cycle = 1'b1;
		endcase
	end



	assign out_valid = d_out_valid;


		// module instantiations
	compressor_top #(
			.STRINGSIZE(STRINGSIZE),
			.TABLESIZE(TABLESIZE)
		) 
		compressor(
			.clock(clock),
			.reset(reset),
			.valid(valid),
			.CurByte(CurByte),
			.compArray(compArray),
			.controlWord(c_controlWord),
			.Done(c_Done),	// MK-> Avoiding multiply driven signals
			.controlPtr(c_controlPtr)
		);
	decompressor_top #( 
		.HISTORY_SIZE(STRINGSIZE)
		)
		decompressor(
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
