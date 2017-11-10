module fifo(
	clk,
	reset,
	data_in,
	wr_en_in,
	fifo_empty_out,
	fifo_full_out,
	data_out
	);

	parameter FIFO_SIZE = 4096;
	localparam ADDR_WIDTH = $clog2(FIFO_SIZE);

	input clk, reset;
	input[7:0] data_in;
	input wr_en_in;
	output fifo_empty_out, fifo_full_out;
	output data_out;

	// internal signals
	logic[ADDR_WIDTH-1 : 0] front_ptr, back_ptr;
	logic[7 : 0] fifo_buffer[FIFO_SIZE-1 : 0];


endmodule
