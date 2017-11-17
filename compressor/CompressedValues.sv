interface intf #(parameter  STRINGSIZE);

//https://verificationacademy.com/forums/systemverilog/parameterized-struct-systemverilog-design
  
 
typedef union packed {
	logic [STRINGSIZE-1:0] [15:0] copy;
	logic [(STRINGSIZE*2)-1:0] [7:0] literal;
} compressed_t
endinterface


module CompressedValues(
input clock, reset,
input [3:0] length,	// from comparator
input [11:0] Offset,	// from table
input [7:0] CurByte,	// from table
input controlBit,		// from table
intf compArray,
controlWord);	
parameter STRINGSIZE = 4096;

output logic [STRINGSIZE-1:0] controlWord;

int controlPtr;
int compressPtr;

always_ff @(posedge clock) begin
	if (reset) begin
		compressedString <= '0;
		controlWord <= '0;
		controlPtr = 0;
		compressPtr = 0;
	end
	else if (controlBit) begin
		compArray.copy[compressPtr] <= {length,Offset};
		compressPtr <= compressPtr+2;
		controlWord[controlPtr] <= controlBit;
		controlPtr <= controlPtr + 1;
	end
	else begin
		compArray.literal[compressPtr] <= CurByte;
		controlPtr <= controlPtr + 1;
		controlWord[controlPtr] <= controlBit;
		controlPtr <= controlPtr + 1;
	end
end



endmodule