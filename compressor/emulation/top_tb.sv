import compressor_pkg::*;
module top_tb;
localparam STRINGSIZE = 350; 
properties vals, out; // needed for package variables
string s;
int k;

initial
  begin
  top_hdl.comp_port.callReset(); // call reset
	
	 s = "When Munch died in January 1944, it transpired that he had unconditionally bequeathed all his remaining works to the City of Oslo. Edvard Munch's art is the most significant Norwegian contribution to the history of art, and he is the only Norwegian artist who has exercised a decisive influence on European art trends, above all as a pioneer of";

	 k = 0;
for(int i = 0; i < STRINGSIZE; i++) begin	// convert string to a synthesizable array 
	vals.testString[k] = s.getc(k);
	k++;
end 	
top_hdl.comp_port.stringinput(vals, out);	// inputs the string to compinput
	$display("...After stringinput");
top_hdl.comp_port.whenDone(vals,out);		// When Done signal high move on to show the outputs
	$display("Input string= %s", s);
	//$display("Compressed string= %s",);
$display("Compressed string= %s", out.cArray);	// out.cArray contains the compressed output

	top_hdl.comp_port.callReset();				// reset to input new string
	
	 s = "daddy finger daddy finger where are you, here I am, here I am where are you.\n new line";

	 k = 0;
for(int i = 0; i < STRINGSIZE; i++) begin 	// convert string to a synthesizable array 
	vals.testString[k] = s.getc(k);
	k++;
end 	
top_hdl.comp_port.stringinput(vals, out);	// inputs the string to compinput
	$display("...After stringinput");
top_hdl.comp_port.whenDone(vals,out);		// When Done signal high move on to show the outputs
	$display("Input string= %s", s);
$display("Compressed string= %s", out.cArray);	// out.cArray contains the compressed output

$stop;
	
  end
endmodule