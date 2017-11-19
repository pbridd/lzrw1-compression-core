module tableOfPtr(

input clock, reset,
input [7:0] InByte,
input [11:0] fromHash, 		// address from Hash function
input [31:0] BytePosition,	// from comp input
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
		ControlBit <= 0;
		//OldBytePosition <= '0;
	end
	else if (TableOfPointers[fromHash]== 0) begin
		TableOfPointers[fromHash] <= BytePosition; 
		ControlBit <= 0;
	end
	else begin
		//OldBytePosition <= TableOfPointers[fromHash];
		TableOfPointers[fromHash] <= BytePosition;
		ControlBit <= 1;
	end
	
	/*
	if(TableOfPointers[fromHash] == 0) Offset <= BytePosition - TableOfPointers[fromHash];
	else Offset <= '0;
	
	if ((TableOfPointers[fromHash] == 0) || (BytePosition - TableOfPointers[fromHash] ) >= TABLESIZE) OutByte <= InByte;
	else OutByte <= '0;
	*/
end

assign Offset = TableOfPointers[fromHash] == 0 ? '0 : (BytePosition - TableOfPointers[fromHash] );
assign OutByte = !ControlBit ? InByte : '0;
assign OldBytePosition = TableOfPointers[fromHash];
assign tableValue = TableOfPointers[fromHash] ;
endmodule