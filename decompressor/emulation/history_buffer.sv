//	LZRW1 Compression Core
//	History Buffer
// 
//	This module stores history for the LZRW1 decompressor module. It stores one byte of data per 
//	table entry. wr_en triggers a write, and one write can be performed per clock cycle.
//
//	Manas Karanjekar, Mark Chernishoff, and Parker Ridd
//	ECEn 571 Fall 2017

module history_buffer(
		clock,			// clock in
		reset, 			// reset in
		data_in,		// data in
		wr_addr,		// write address in
		wr_en,			// write enable
		rd_addr,		// read address in
		data_out		// data out
	);

	parameter HISTORY_SIZE = 4096;				// the number of entries in the history buffer
	parameter ENTRY_WIDTH = 8;					// entry width for the history buffer
	localparam HISTORY_ADDR_WIDTH = $clog2(HISTORY_SIZE);	// the address width is derived from the history size


	input logic clock, reset;
	input logic[ENTRY_WIDTH-1:0] data_in;
	input logic[HISTORY_ADDR_WIDTH-1:0] wr_addr, rd_addr;
	input logic wr_en;
	output logic[ENTRY_WIDTH-1:0] data_out;

	// history buffer array
	logic[ENTRY_WIDTH-1:0] history[HISTORY_SIZE-1:0], history_next[HISTORY_SIZE-1:0];

	always_ff @(posedge clock, posedge reset) begin
		if(reset) begin
			for(int i = 0; i < HISTORY_SIZE; i++)
				history[i] <= '0;
		end
		else
			history <= history_next;
	end

	always_comb begin
		history_next = history;
		if(wr_en)
			history_next[wr_addr] = data_in;
	end

	assign data_out = history[rd_addr];

endmodule