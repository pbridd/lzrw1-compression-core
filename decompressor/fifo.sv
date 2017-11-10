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
	logic[7 : 0] fifo_buffer[FIFO_SIZE-1 : 0];

	assign fifo_full_out = (front_ptr == (back_ptr + 1)) ? 1 : 0;
	assign fifo_empty_out = (front_ptr == back_ptr) ? 1 : 0;

	always_ff @(posedge clk, posedge reset) begin
		if(reset) begin
			front_ptr <= '0;
			back_ptr <= '0;
		end
	end


endmodule
