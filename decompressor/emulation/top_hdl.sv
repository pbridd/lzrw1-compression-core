import deompressor_pkg::*;
module top_hdl; //pragma attribute top_hdl parition_module_xrtl 
parameter HISTORY_SIZE = 4096;
localparam HISTORY_ADDR_WIDTH = $clog2(HISTORY_SIZE);

localparam delay = 5; 
logic clock, reset;
data_in_t data_in;
logic control_word_in;
logic data_in_valid;
logic[7:0] decompressed_byte;
logic out_valid;
logic decompressor_busy;
properties vals;
decomp_if decomp_port(clock);
deompressor_top #(.HISTORY_SIZE(HISTORY_SIZE) dctop (decomp_port);

integer k,m;
// tbx clkgen
initial begin
	clock = 0;
		forever #5 clock = ~clock;
end

endmodule