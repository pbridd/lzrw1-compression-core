interface input_interface(input bit clock);
	logic reset;
	logic valid;
	logic [15:0] [7:0] CurByte;
	//logic done;
	
clocking cb@(posedge clock);
	output reset;
	output valid;
	//output done;
	output CurByte;
endclocking

modport IP(clocking cb,input clock);

endinterface

interface output_interface(input bit clock);
	logic [7:0] decompressed_byte;
	logic out_valid;
	logic finished_cycle;

clocking cb@(posedge clock);
	input decompressed_byte;
	input out_valid;
	input finished_cycle;
endclocking

modport OP(clocking cb,input clock);

endinterface

