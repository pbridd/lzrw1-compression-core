/*
This module adds a byte position entry into the table and sends old
byte position back to compinput.

input InByte; byte to send on to CompressedValues if controlBit high
input fromHash; 12 bits to index the TableOfPointers
input BytePosition; the current byte position to input into the tableOfPtr
input length; amount of bits that are the same if >2 then set controlBit hi, else low
output OutByte; send on to CompressedValues, 0 or literal depends on ControlBit
output OldBytePosition; if table entry !null send to value to compinput
output Offset; send to CompressedValues
output ControlBit; send to CompressedValues

Portland State University
ECE571 Final Project
by Mark Chernishoff, Parker Ridd, Manas Karanjekar

*/

module tableOfPtr(

input clock, reset,
input [7:0] InByte,
input [11:0] fromHash, 		// address from Hash function
input [31:0] BytePosition,	// from comp input
input [3:0] length,
output logic [7:0] OutByte,
output logic [11:0] OldBytePosition,	// to compinput(offset)
output logic[11:0] Offset,				// to CompressedValues
output bit ControlBit);					// to comparator and CompressedValues

parameter TABLESIZE = 4096;

logic [TABLESIZE-1:0] [31:0] TableOfPointers;
logic [31:0] tableValue;

always_ff @(posedge clock) begin
	if(reset) begin
		TableOfPointers <= '0;
		//OldBytePosition <= '0;
	end
	else if (TableOfPointers[fromHash]== 0) begin
		TableOfPointers[fromHash] <= BytePosition; 
	end
	else if(TableOfPointers[fromHash] > 0 && length > 2)begin
		//OldBytePosition <= TableOfPointers[fromHash];
		TableOfPointers[fromHash] <= BytePosition;
	end
	else TableOfPointers[fromHash] <= TableOfPointers[fromHash];
	
	/*
	if(TableOfPointers[fromHash] == 0) Offset <= BytePosition - TableOfPointers[fromHash];
	else Offset <= '0;
	
	if ((TableOfPointers[fromHash] == 0) || (BytePosition - TableOfPointers[fromHash] ) >= TABLESIZE) OutByte <= InByte;
	else OutByte <= '0;
	*/
end
always_comb begin
if(reset) ControlBit = 0;
	else if (TableOfPointers[fromHash]== 0) begin 
		ControlBit = 0;
	end
	else if (TableOfPointers[fromHash] > 0 && length > 2) begin 
		ControlBit = 1;
		end
	else if (length <= 2)begin
		ControlBit = 0;
	end
	else ControlBit = ControlBit;
end
assign Offset = TableOfPointers[fromHash] == 0 ? '0 : (BytePosition - TableOfPointers[fromHash] );
assign OutByte = !ControlBit ? InByte : '0;
assign OldBytePosition = TableOfPointers[fromHash];
assign tableValue = TableOfPointers[fromHash] ;
endmodule