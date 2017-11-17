module table(

input clock, reset,
input [11:0] fromHash, 		// address from Hash function
input [11:0] BytePosition,	// from comp input
output logic [11:0] OldBytePosition,	// to compinput(offset)
output logic[11:0] Offset,				// to CompressedValues
output bit ControlBit);					// to comparator and CompressedValues

parameter TABLESIZE = 4096;

logic [TABLESIZE-1:0] [31:0] TableOfPointers;

always_ff @(posedge clock) begin
	if(reset) begin
		TableOfPointers <= '0;
	end
	else if (TableOfPointers[fromHash]== 0) begin
		TableOfPointers[fromHash] <= BytePosition; 
		ControlBit <= 0;
	end
	else begin
		OldBytePosition <= TableOfPointers[fromHash];
		TableOfPointers[fromHash] <= BytePosition;
		ControlBit <= 1;
	end

end

assign Offset = TableOfPointers[fromHash] == 0 ? '0 : (TableOfPointers[fromHash] - BytePosition);


endmodule