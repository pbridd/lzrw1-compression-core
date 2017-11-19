module compinput_tb ();
parameter STRINGSIZE = 88;
parameter TABLESIZE = 4096;
localparam delay = 5ns;
bit clock, reset, valid;
logic [15:0] [7:0] CurByte; 
logic [11:0] offset; 
logic [15:0] [7:0] toCompare; 
logic [15:0] [7:0] NextBytes;
logic [23:0] toHash;
integer bytePtr;
bit Done;

logic ControlBit;
logic [3:0] Length;
logic [15:0] [7:0] CurBytes,BytesAtOffset;
logic [STRINGSIZE -1:0] controlWord;
logic [STRINGSIZE*8:0] CompArray;
byte InByte;
logic [11:0] fromHash,a,b,c;
logic [11:0] OldBytePosition,Offset;
integer BytePosition;
byte OutByte;

logic [3:0] length;
byte OneByte;

compinput #(STRINGSIZE) comp (clock, reset, valid, CurByte, offset, Length, toCompare, NextBytes, toHash, Done, bytePtr);

/*
input [15:0] [7:0] CurBytes,BytesAtOffset, // from input history
input ControlBit, reset, 		// ControlBit from table
output logic [3:0] Length); 	*/
Comparator cptr (CurBytes,BytesAtOffset,ControlBit, reset,Length);

/*
input clock, reset,
input [7:0] InByte,
input [11:0] fromHash, 		// address from Hash function
input [11:0] BytePosition,	// from comp input
output logic [7:0] OutByte
output logic [11:0] OldBytePosition,	// to compinput(offset)
output logic[11:0] Offset,				// to CompressedValues
output bit ControlBit);		*/
tableOfPtr #(TABLESIZE) tob (clock,reset,InByte,fromHash,BytePosition,OutByte,OldBytePosition,Offset,ControlBit);

/*
input clock, reset,
input [3:0] length,	// from comparator
input [11:0] Offset,	// from table
input [7:0] OneByte,	// from table
input controlBit,		// from table
intf compArray,
output logic [STRINGSIZE-1:0] controlWord);	*/
//intf #(STRINGSIZE) InterfaceArray ();

CompressedValues #(STRINGSIZE) CV (clock,reset,length,Offset,OneByte,ControlBit,CompArray,controlWord);

assign BytePosition = bytePtr;		// from compinput to table
assign OneByte = OutByte; // from table to CompressedValues
assign offset = OldBytePosition;	// from table to compinput
assign BytesAtOffset = toCompare;	// from compinput to comparator
assign CurBytes = NextBytes;
assign length = Length;		// from comparator to compressedValues
assign a = toHash[23:16];
assign b = toHash[15:8] * 8;
assign c = toHash[7:0] * 16;
assign fromHash = a ^ b ^ c;
assign InByte = NextBytes[0];
string s;
int k;
int m;
initial begin
		clock = 0;
		reset = 1; 
		#(2*delay) reset = 0;
		//offset = 0;
end
always begin
#delay
clock <= ~clock;
/*
case(comp.bytePointer)
			14: offset = 1;
			30: offset = 7;
			45: offset = 31;
			50: offset = 35;
			55: offset = 39;
		endcase
*/


end

initial begin
k = 0;
m = 0;

		$display("...Starting input");
wait (!reset && clock);
//#(2*delay);

	s = "daddy finger daddy finger where are you, here I am, here I am where are you.\n new line\0";
	
	valid <= 1;
	for (int i = 0; m < s.len() ; i++) begin
		k = 0;
		for (int j = i*16; j < i*16+16; j++) begin
			CurByte[k] <= (s.getc(j));
			k++;
			
		m++;
		end
		
		#(2*delay);
	end
	valid <= 0;
	wait (Done) $display("%s",CompArray);
	
end


endmodule
