module compinput(input clock, reset, valid, input [7:0] CurByte, input [11:0] offset, output logic [8*16:0] toCompare, output logic [23:0] toHash, output [11:0] OldByteOffset);
parameter HISTORY = 4096;

logic [HISTORY-1:0] [7:0] myHistory = '0;
int count = 0;
int bytePointer = 0;


always_ff @(posedge clock, negedge reset) begin
	
	if (!reset) begin
		count<= 0;
		bytePointer <= 0;

	end
	else begin

		if(valid && count < HISTORY) begin
			myHistory[count] <= CurByte;
			count <= count + 1;
		end
		else count <= count;
	
		if (count - bytePointer == 3) begin
			toHash <= {myHistory[bytePointer],myHistory[bytePointer+1],myHistory[bytePointer+2]};
			bytePointer <= bytePointer + 1;
		end
		else toHash <= toHash;

		if (bytePointer - offset > 16)
			toCompare <= myHistory[offset*16-1 : offset];
		else 	toCompare <= {'0,myHistory[offset : bytePointer]};
	end
end
endmodule
