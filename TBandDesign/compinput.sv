module compinput(
input clock, reset, valid, 
input [15:0] [7:0] CurByte, 
input [11:0] offset ,
input [3:0] Length, 
output logic [15:0] [7:0] toCompare,
output logic [15:0] [7:0] NextBytes,
output logic [23:0] toHash,
output bit Done,
output integer bytePtr);

parameter HISTORY = 4096;

logic [HISTORY-1:0] [7:0] myHistory = '0;
int bytePointer = 0;
int count = 0;
integer s_offset;

byte valueHistory;

assign s_offset = (!reset) ? integer' (offset) : '0 ;

always_ff @(posedge clock) begin
	
	if (reset) begin
		bytePointer <= 0;
		count <= 0;
		myHistory <= '0;
		Done <= 1;
	end
	else if(!valid && 0 ==  myHistory[bytePointer+1]) Done <= 1;
	else begin
		
		// increment byte pointer if not at end of string
		// add current byte to history
		if(valid && (bytePointer < HISTORY)) begin
			Done <= 0;
			myHistory[count+1 +: 17] <= CurByte ;
			count <= count + 16;
		end
		else count <= count;
		// if first 3 bytes recieved, send to hash function
		if(Length >= 3) bytePointer <= bytePointer + Length;
		else  bytePointer <= bytePointer + 1;

	end
end

always_comb begin
		if(reset) begin
			toHash <= '0;
		toCompare <= '0;
		NextBytes <= '0;
		end
		else if (bytePointer >= 1) begin
			toHash <= {myHistory[bytePointer],myHistory[bytePointer+1],myHistory[bytePointer+2]};		
		end
		else toHash <= toHash;
		if ((myHistory[bytePointer] != 0) && (bytePointer - s_offset) > 15 && s_offset > 0 ) begin
			toCompare <= myHistory[(s_offset) +: 16];
			NextBytes <= myHistory[bytePointer +: 16];
		end
		else if ((myHistory[bytePointer] != 0)  && (bytePointer - s_offset) <= 15 && s_offset > 0 ) begin
			for(int i = 0; i < bytePointer - offset; i++) begin
				toCompare[i] <= myHistory[offset+i];
			end
			NextBytes <= myHistory[bytePointer +: 16];
		end
		else toCompare <= '0;
		NextBytes <= myHistory[bytePointer +: 16];
end
assign bytePtr = bytePointer;
assign valueHistory = myHistory[bytePointer];

endmodule
