/*
This is the is the module that handles adding literal (OneByte) or {length,offset}
to the compArray.
 
input OneByte; byte to add to compArray
input Offset; offset from tableofPtr's
input Length; amount of total chars that are the same between CurBytes and the toCompare(bytes at offset)
input ControlBit; added to controlWord array
output compArray; an array of compressed characters
output countrolWord; an array of 0's and 1's 
output controlPtr; used for assertions
output compressPtr; used for assertions
input Done; end of string reached

Portland State University
ECE571 Final Project
by Mark Chernishoff, Parker Ridd, Manas Karanjekar

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
		compArray[compressPtr+1] <= Offset[7:0];
		compressPtr = compressPtr+2;
		controlWord[controlPtr] <= controlBit;
		controlPtr = controlPtr + 1;
	end
	else if (!Done && !controlBit) begin
		compArray[compressPtr] <= OneByte;
		compressPtr = compressPtr + 1;
		controlWord[controlPtr] <= controlBit;
		controlPtr = controlPtr + 1;
	end
	else begin
		compressPtr = compressPtr;
		controlPtr = controlPtr;
	end
end
	

endmodule