import compressor_pkg::*;
module top_tb;
localparam STRINGSIZE = 256; 
localparam CW_SIZE = 128;
localparam COMPRESSED_SIZE = 131;
properties vals, out; // needed for package variables
string s;
logic[0:CW_SIZE-1] control_word_vector;
logic[COMPRESSED_SIZE-1:0][7:0] compressed_byte_vector;
string expected_output;
int k;

initial
  begin
  top_hdl.decomp_port.callReset(); // call reset
	
	control_word_vector = SW_SIZE'h00000011881801040C00408308040000;
	compresed_byte_vector =COMPRESSED_SIZE'h497420776173207468652062657374206F662074696D65732C2069A01A776F72F01B90356167654034776973646F6DD035701A666F6F6C6973686E6573E05465706F6368403B62656C696566D03B901C696E63726564756C697479D021736561736F6E403E4C69676874F01C801C4461726BF0786520737072696E67403B686F70652C;
	expected_output = "It was the best of times, it was the worst of times, it was the age of wisdom, it was the age of foolishness, it was the epoch of belief, it was the epoch of incredulity, it was the season of Light, it was the season of Darkness, it was the spring of hope,";

	 k = 0;
for(int i = 0; i < STRINGSIZE; i++) begin	// convert string to a synthesizable array 
	vals.testString[k] = s.getc(k);
	k++;
end 	
top_hdl.decomp_port.stringinput(vals, out);	// inputs the string to compinput
	$display("...After stringinput");
top_hdl.decomp_port.whenDone(vals,out);		// When Done signal high move on to show the outputs
	$display("Input string= %s", s);
	//$display("Compressed string= %s",);
$display("Compressed string= %s", out.cArray);	// out.cArray contains the compressed output

	top_hdl.decomp_port.callReset();				// reset to input new string
	
	 s = "daddy finger daddy finger where are you, here I am, here I am where are you.\n new line";

	 k = 0;
for(int i = 0; i < STRINGSIZE; i++) begin 	// convert string to a synthesizable array 
	vals.testString[k] = s.getc(k);
	k++;
end 	
top_hdl.decomp_port.stringinput(vals, out);	// inputs the string to compinput
	$display("...After stringinput");
top_hdl.decomp_port.whenDone(vals,out);		// When Done signal high move on to show the outputs
	$display("Input string= %s", s);
$display("Compressed string= %s", out.cArray);	// out.cArray contains the compressed output

$stop;
	
  end
endmodule