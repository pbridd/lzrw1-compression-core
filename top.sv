`include "fileReader.sv"
`include "string_writer.sv"
`include "driver.sv"
`include "env.sv"
`include "testcase.sv"
//`include "package.sv"
//import topPkg::*;
module top();

bit clk;

initial
	forever	#10 clk = ~clk;

/*	Input interface		*/

/*	Output interface	*/

/*	Program block Testcase instance		*/
testcase TC ();


endmodule	: top
