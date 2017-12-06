import compressor_pkg::*;

module top_hdl; //pragma attribute top_hdl parition_module_xrtl 
parameter STRINGSIZE = 350;
parameter TABLESIZE = 4096;
localparam delay = 5;
bit clock, reset, valid;
logic [15:0] [7:0] CurByte; 
 bit Done;
 logic [STRINGSIZE-1:0][7:0] compArray;
 logic [STRINGSIZE-1:0] controlWord;
properties vals;
comp_if comp_port(clock, reset);
compressor_top #(STRINGSIZE,TABLESIZE) ctop (comp_port);

integer k,m;
// tbx clkgen
initial begin
	clock = 0;
		forever #5 clock = ~clock;

end

// tbx clkgen
initial begin
		reset = 1; 
		#10 reset = 0;
end

endmodule