module fifo(
	clk,
	reset,
	data_in,
	wr_en_in,
	rd_en_in,
	num_bytes_in,
	fifo_empty_out,
	fifo_full_out,
	data_out,
	occupancy
	);

	parameter FIFO_SIZE = 128;
	parameter MAX_BYTES_IN = 16;
	localparam ADDR_WIDTH = $clog2(FIFO_SIZE);

	input clk, reset;
	input[7 : 0] data_in[MAX_BYTES_IN-1 : 0];
	input wr_en_in, rd_en_in;
	output fifo_empty_out, fifo_full_out;
	output data_out;

	// internal signals
	logic[ADDR_WIDTH-1 : 0] front_ptr, back_ptr;
	logic[ADDR_WIDTH-1 : 0] front_ptr_next, back_ptr_next;
	logic[7 : 0] fifo_buffer[FIFO_SIZE-1 : 0], fifo_buffer_next[FIFO_SIZE-1 : 0];
	integer occupancy, occupancy_next;

	assign fifo_full_out = (occupancy == FIFO_SIZE) ? 1 : 0;
	assign fifo_empty_out = (occupancy == 0) ? 1 : 0;
	assign data_out = fifo_buffer[front_ptr];

	// registers
	always_ff @(posedge clk, posedge reset) begin
		if(reset) begin
			front_ptr <= '0;
			back_ptr <= '0;
			for(int i = 0; i < FIFO_SIZE-1; i++)
				fifo_buffer[i] <= '0;
			occupancy <= 0;
		end
		else begin
			front_ptr <= front_ptr_next;
			back_ptr <= back_ptr_next;
			fifo_buffer <= fifo_buffer_next;
			occupancy <= occupancy_next;
		end

		// check that we never underflow or overflow
		assert(occupancy >= 0)
		else $error("Underflow detected in FIFO %m");
		assert(occupancy <= FIFO_SIZE)
		else $error("Overflow detected in FIFO %m");
	end

	// next state logic
	always_comb begin
		//default logic
		front_ptr_next = front_ptr;
		back_ptr = back_ptr_next;
		fifo_buffer_next = fifo_buffer;

		//advance both pointers
		if(rd_en_in & wr_en_in) begin
			if(front_ptr == (FIFO_SIZE-1))
				front_ptr_next = '0;
			else
				front_ptr_next = front_ptr + 1;
			if(back_ptr + num_bytes_in >= FIFO_SIZE) begin
				back_ptr_next = num_bytes_in-(FIFO_SIZE-back_ptr);
				fifo_buffer_next[FIFO_SIZE-1 : back_ptr] = data_in[FIFO_SIZE-back_ptr-1 : 0];
				fifo_buffer_next[num_bytes_in-(FIFO_SIZE-back_ptr)-1 : 0] = data_in[num_bytes_in-1:FIFO_SIZE-back_ptr];
			else begin
				back_ptr_next = back_ptr + num_bytes_in;
				fifo_buffer_next[back_ptr +: num_bytes_in] = data_in[num_bytes_in : 0];
			end
				

			end
			
		end
		else if(rd_en_in) begin
			// make sure we aren't empty -- don't allow advance
			// if FIFO is empty
			if(front_ptr != back_ptr) begin
				if(front_ptr == (FIFO_SIZE-1))
					front_ptr_next = '0;
				else
					front_ptr_next = front_ptr + 1;
			end
		end
		else if(wr_en_in) begin
			// make sure we aren't full -- don't allow advance
			// if FIFO is full
			if(back_ptr + num_bytes_in >= FIFO_SIZE) begin
				back_ptr_next = num_bytes_in-(FIFO_SIZE-back_ptr);
				fifo_buffer_next[FIFO_SIZE-1 : back_ptr] = data_in[FIFO_SIZE-back_ptr-1 : 0];
				fifo_buffer_next[num_bytes_in-(FIFO_SIZE-back_ptr)-1 : 0] = data_in[num_bytes_in-1:FIFO_SIZE-back_ptr];
			else begin
				back_ptr_next = back_ptr + num_bytes_in;
				fifo_buffer_next[back_ptr +: num_bytes_in] = data_in[num_bytes_in : 0];
			end
		end

	end

endmodule
