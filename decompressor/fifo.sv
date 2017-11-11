module fifo(
	clk,
	reset,
	data_in,
	wr_en_in,
	rd_en_in,
	fifo_empty_out,
	fifo_full_out,
	data_out
	);

	parameter FIFO_SIZE = 128;
	localparam ADDR_WIDTH = $clog2(FIFO_SIZE);

	input clk, reset;
	input[7:0] data_in;
	input wr_en_in, rd_en_in;
	output fifo_empty_out, fifo_full_out;
	output data_out;

	// internal signals
	logic[ADDR_WIDTH-1 : 0] front_ptr, back_ptr;
	logic[ADDR_WIDTH-1 : 0] front_ptr_next, back_ptr_next;
	logic[7 : 0] fifo_buffer[FIFO_SIZE-1 : 0], fifo_buffer_next[FIFO_SIZE-1 : 0];

	assign fifo_full_out = (front_ptr == (back_ptr + 1)) ? 1 : 0;
	assign fifo_empty_out = (front_ptr == back_ptr) ? 1 : 0;
	assign data_out = fifo_buffer[front_ptr];

	// registers
	always_ff @(posedge clk, posedge reset) begin
		if(reset) begin
			front_ptr <= '0;
			back_ptr <= '0;
			for(int i = 0; i < FIFO_SIZE-1; i++)
				fifo_buffer[i] <= '0;
		end
		else begin
			front_ptr <= front_ptr_next;
			back_ptr <= back_ptr_next;
			fifo_buffer <= fifo_buffer_next;
		end

		// check that we never underflow
		assert((front_ptr != back_ptr + 1) & ((front_ptr != 0) & (back_ptr != FIFO_SIZE-1)))
		else $error("Underflow detected in FIFO %m");
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
			if(back_ptr == (FIFO_SIZE-1))
				front_ptr_next = '0;
			else
				back_ptr_next = back_ptr + 1;
			fifo_buffer_next[back_ptr] = data_in;
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
			if((front_ptr != (back_ptr+1)) && ((front_ptr != 0) && (back_ptr != FIFO_SIZE-1))) begin
				if(back_ptr == (FIFO_SIZE-1))
					back_ptr_next = '0;
				else
					back_ptr_next = back_ptr + 1;
				fifo_buffer_next[back_ptr] = data_in;
			end
		end

	end

endmodule
