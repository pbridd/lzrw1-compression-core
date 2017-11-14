module history_buffer(
		clock,
		reset, 
		data_in,
		wr_addr,
		wr_en,
		rd_addr,
		data_out
	);

	parameter HISTORY_SIZE = 4096;
	parameter ENTRY_WIDTH = 16;
	localparam HISTORY_ADDR_WIDTH = $clog2(HISTORY_SIZE);


	input logic clock, reset;
	input logic[ENTRY_WIDTH-1:0] data_in;
	input logic[HISTORY_ADDR_WIDTH-1:0] wr_addr, rd_addr;
	input logic wr_en;
	output logic[ENTRY_WIDTH-1:0] data_out;

	// history buffer
	logic[ENTRY_WIDTH-1:0] history[HISTORY_SIZE-1:0], history_next[HISTORY_SIZE-1:0];

	always_ff @(clock, reset) begin
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