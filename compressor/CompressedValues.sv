/*
interface intf #(parameter  STRINGSIZE);

//https://verificationacademy.com/forums/systemverilog/parameterized-struct-systemverilog-design
  
 
typedef union packed {
	logic [STRINGSIZE-1:0] [15:0] copy;
	logic [(STRINGSIZE*2)-1:0] [7:0] literal;
} compressed_t;

compressed_t c_t;
endinterface
*/

module CompressedValues (clock, reset, Done, length, Offset, OneByte, controlBit, compArray, controlWord);
parameter  STRINGSIZE = 4096;

input clock, reset, Done;
input [3:0] length;	// from comparator
input [11:0] Offset;	// from table
input [7:0] OneByte;	// from table
input controlBit;		// from table
/*intf compArray,*/
output logic [STRINGSIZE-1:0] [7:0] compArray;
output logic [STRINGSIZE-1:0] controlWord;	

int controlPtr;
int compressPtr;


always_ff @(posedge clock) begin
	if (reset) begin
		compArray <= '0;
		controlWord <= '0;
		controlPtr = 0;
		compressPtr = 0;
	end
	
	else if (controlBit && Done == 0) begin
		compArray[compressPtr] <= {length,Offset[11:8]};
		compArray[compressPtr] <= Offset[7:0];
		compressPtr <= compressPtr+2;
		controlWord[controlPtr] <= controlBit;
		controlPtr <= controlPtr + 1;
	end
	else if (!Done) begin
		compArray[compressPtr] <= OneByte;
		compressPtr <= compressPtr + 1;
		controlWord[controlPtr] <= controlBit;
		controlPtr <= controlPtr + 1;
	end
	else begin
		compressPtr <= compressPtr;
		controlPtr <= controlPtr;
	end
end
	

endmodule