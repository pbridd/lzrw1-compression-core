/*
This is the comparator input for the compressor portion of the design.
This compares amount of bytes that are the same. 

input ControlBit; used for debug
input BytesAtOffset;  bytes at offset to compare
input NextBytes; Current 16 bytes to compare
output Length; amount of total chars that are the same between CurBytes and the toCompare(bytes at offset)


Portland State University
ECE571 Final Project
by Mark Chernishoff, Parker Ridd, Manas Karanjekar

*/


module Comparator(
input [15:0] [7:0] CurBytes,BytesAtOffset, // from input history
input ControlBit, reset, 		// ControlBit from table
output logic [3:0] Length);

int count;

always_comb begin

	if (reset) begin
		Length = '0;
		count = 0;
	end
	else //if (ControlBit) begin
	begin
		count = 0;
		for (int i = 0; i < 16; i++) begin
			if(CurBytes[i] == BytesAtOffset[i]) count++;
			else begin 
				Length = count;
				break;
			end
		end
	end
	//else Length <= '0;
end
endmodule