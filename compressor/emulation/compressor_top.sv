

module compressor_top (comp_if comp_port);
/*clock, reset, valid, CurByte, Done, compArray, controlWord);
parameter STRINGSIZE = 4096;
parameter TABLESIZE = 4096;
input clock, reset, valid;
input [15:0] [7:0] CurByte;
output Done;
output logic [STRINGSIZE-1:0][7:0] compArray;
output logic [STRINGSIZE-1:0] controlWord;
//input logic [RANDTABLE:0][11:0] uniqnums;
*/
parameter STRINGSIZE = 4096;
parameter TABLESIZE = 4096;
logic [11:0] offset; 
logic [15:0] [7:0] toCompare; 
logic [15:0] [7:0] NextBytes;
logic [23:0] toHash;
integer bytePtr;

logic ControlBit;
logic [3:0] Length;
logic [15:0] [7:0] CurBytes,BytesAtOffset;
byte InByte;
logic [11:0] fromHash;
logic [11:0] OldBytePosition,Offset;
integer BytePosition;
byte OutByte;

logic [3:0] length;
byte OneByte;

compinput #(STRINGSIZE) comp (comp_port.clock, comp_port.reset, comp_port.valid, comp_port.CurByte, offset, Length, toCompare, NextBytes, toHash, comp_port.Done, bytePtr);

/*
input [15:0] [7:0] CurBytes,BytesAtOffset, // from input history
input ControlBit, reset, 		// ControlBit from table
output logic [3:0] Length); 	*/
Comparator cptr (CurBytes,BytesAtOffset,ControlBit, comp_port.reset,Length);

/*
input clock, reset,
input [7:0] InByte,
input [11:0] fromHash, 		// address from Hash function
input [11:0] BytePosition,	// from comp input
output logic [7:0] OutByte
output logic [11:0] OldBytePosition,	// to compinput(offset)
output logic[11:0] Offset,				// to CompressedValues
output bit ControlBit);		*/
tableOfPtr #(TABLESIZE) tob (comp_port.clock,comp_port.reset,InByte,fromHash,BytePosition,length,OutByte,OldBytePosition,Offset,ControlBit);

/*
input clock, reset,
input [3:0] length,	// from comparator
input [11:0] Offset,	// from table
input [7:0] OneByte,	// from table
input controlBit,		// from table
intf compArray,
output logic [STRINGSIZE-1:0] controlWord);	*/
//intf #(STRINGSIZE) InterfaceArray ();

CompressedValues #(STRINGSIZE) CV (comp_port.clock,comp_port.reset, comp_port.Done,length,Offset,OneByte,ControlBit,comp_port.compArray,comp_port.controlWord);

hashFunction hF (comp_port.reset,toHash,fromHash);

assign BytePosition = bytePtr;		// from compinput to table
assign OneByte = OutByte; // from table to CompressedValues
assign offset = OldBytePosition;	// from table to compinput
assign BytesAtOffset = toCompare;	// from compinput to comparator
assign CurBytes = NextBytes;
assign length = Length;		// from comparator to compressedValues and table
assign InByte = NextBytes[0];

endmodule
