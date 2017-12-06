//Import alu_pkg definitions for struct data type and parameters
import compressor_pkg::*;

interface comp_if(input bit clock, reset); 
// pragma attribute comp_if partition_interface_xif
parameter STRINGSIZE = 350;
parameter TABLESIZE = 4096;
localparam delay = 5;
bit valid;
logic [15:0] [7:0] CurByte; 
 bit Done;
 logic [STRINGSIZE-1:0][7:0] compArray;
 logic [STRINGSIZE-1:0] controlWord;
properties vals;

integer k,m;

task stringinput(input properties vals, output properties out); // pragma tbx xtf

m = 0;
@(posedge clock);
valid = 1;
for (int i = 0; m < STRINGSIZE ; i++) begin
		k = 0;
		for (int j = i*16; j < i*16+16; j++) begin
			CurByte[k] <= (vals.testString[j]);
			k++;
			
		m++;
		end		
		@(posedge clock)
		m = m;
		
	end
	
	valid = 0;	
	
	
endtask

task whenDone(input properties vals, output properties out); // pragma tbx xtf

	while(!Done) @(posedge clock);
	
	out.cArray = compArray;
	out.cWord = controlWord;
	out.Done = Done;
	$display("WhenDoneAfter.");
endtask

task whenReset(); // pragma tbx xtf
	@(negedge reset);
endtask

endinterface: comp_if