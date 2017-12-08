//Import alu_pkg definitions for struct data type and parameters
import compressor_pkg::*;
interface decomp_if(input bit clock); 
// pragma attribute comp_if partition_interface_xif
parameter STRINGSIZE = 350;
parameter TABLESIZE = 4096;
localparam delay = 5;
logic clock, reset;
data_in_t data_in;
logic control_word_in;
logic data_in_valid;
logic[7:0] decompressed_byte;
logic out_valid;
logic decompressor_busy;
properties vals;

integer k,m;

// task to input string into compinput
task stringinput(input properties vals, output properties out); // pragma tbx xtf
@(posedge clock);
m = 0;
valid = 1;
for (int i = 0; m < STRINGSIZE ; i++) begin
	
			CurByte = (vals.testString[m +:16]);			
			
		@(posedge clock)
		m = m + 16;
	end
	
	valid = 0;	
	
	
endtask
// after Done signal high, save compArray and Control Word
task whenDone(input properties vals, output properties out); // pragma tbx xtf
	@(posedge clock);
	while(!Done) @(posedge clock);
	
	out.cArray = compArray;
	out.cWord = controlWord;
	out.Done = Done;
	$display("WhenDoneAfter.");
endtask
// used in debug
task whenReset(); // pragma tbx xtf
	@(negedge reset);
endtask

// reset the compressor to get ready for new inputs
task callReset(); 		// pragma tbx xtf


	@(posedge clock)
	reset = 1;
	@(posedge clock);
	@(posedge clock)
	reset = 0;
	@(posedge clock);
endtask

endinterface: comp_if