module compinput_tb ();
parameter STRINGSIZE = 350;
parameter TABLESIZE = 4096;
parameter RANDTABLE = 4095;
localparam delay = 5ns;
bit clock, reset, valid;
logic [15:0] [7:0] CurByte; 
bit Done;
logic[RANDTABLE:0][11:0] uniqnums;
logic [STRINGSIZE - 1:0] controlWord;
logic [STRINGSIZE-1:0][7:0] compArray;
integer nums;
int newPtr;
logic [7:0] newByte;
// compressor_top #(STRINGSIZE,TABLESIZE,RANDTABLE) ctop (clock,reset,valid,CurByte,Done,compArray,controlWord,uniqnums);
compressor_top #(STRINGSIZE,TABLESIZE) ctop (clock,reset,valid,CurByte,Done,compArray,controlWord);
int assertions_cnt;

string s;
int k;
int m;
initial begin
	clock = 0;
		reset = 1; 
		#(2*delay) reset = 0;

end

always begin
#delay
clock <= ~clock;
end

initial begin
k = 0;
m = 0;

		$display("...Starting input");
wait (!reset && clock);
//#(2*delay);

	//s = "daddy finger daddy finger where are you, here I am, here I am where are you.\n new line\0";
	 s = "When Munch died in January 1944, it transpired that he had unconditionally bequeathed all his remaining works to the City of Oslo. Edvard Munch's art is the most significant Norwegian contribution to the history of art, and he is the only Norwegian artist who has exercised a decisive influence on European art trends, above all as a pioneer of";
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
	
	
	wait (Done)
	$display("Input string= %s", s);
	$display("Compressed string= %s",{<< byte {compArray}});
	$display("amount of assertions checked = %d", assertions_cnt);
	
end


// used for assertion properties
always begin

@(posedge clock) newPtr = (ctop.length+ctop.bytePtr);
 newByte = ctop.CV.OneByte; 		

end

////////////////////////////
// assertion properties

property p_bytePtr;
@(negedge clock)
	disable iff(reset || Done)	
	(ctop.length >= 3) |=>  newPtr == ctop.bytePtr;
	
endproperty
a_bytePtr: assert property (p_bytePtr) assertions_cnt++;

property p_tableEntry;
@(negedge clock)
	disable iff(reset)	
	(ctop.ControlBit) |-> (ctop.comp.offset > 0);
	
endproperty
a_tableEntry: assert property (p_tableEntry) assertions_cnt++;

property p_offsetnotzero;
@(negedge clock)
	disable iff(reset || Done)	
	(ctop.ControlBit) |->  ((ctop.tob.BytePosition - ctop.comp.offset) == ctop.Offset);
endproperty
a_offsetnotzero: assert property (p_offsetnotzero) assertions_cnt++;

property p_lengthnotzero;
@(negedge clock)
	disable iff(reset  || Done || ctop.length < 3)	
	(ctop.ControlBit) |-> (ctop.length >= 3);
endproperty
a_lengthnotzero: assert property (p_lengthnotzero) assertions_cnt++;

property p_outputwhenlow;
@(negedge clock)
	disable iff(reset  || Done || ctop.CV.compressPtr == 0 || newByte === 0)	
	(!ctop.ControlBit) |-> (compArray[ctop.CV.compressPtr-1] === newByte);
endproperty
a_outputwhenlow: assert property (p_outputwhenlow) assertions_cnt++;
				else $display("a_outputwhenlow:time %t, Ptr = %d; compArray = %d; newByte = %s", $time, ctop.CV.compressPtr, compArray[ctop.CV.compressPtr], newByte );

/*
property p_outputwhenhi;
@(negedge clock)
	disable iff(reset  || Done || ctop.CV.compressPtr == 0 )	
	(ctop.ControlBit) |=> ({compArray[ctop.CV.compressPtr],compArray[ctop.CV.compressPtr+1]} === {ctop.length,ctop.Offset});
endproperty
a_outputwhenhi: assert property (p_outputwhenhi) assertions_cnt++;
				else $display("a_outputwhenhi: time %t, Ptr = %d; compArray-1 = %d; compArray = %d; Length =%d; Offset=%d ", $time, ctop.CV.compressPtr, compArray[ctop.CV.compressPtr], compArray[ctop.CV.compressPtr+1], ctop.length, ctop.Offset );
*/
property p_ctrlbitwhenlow;
@(negedge clock)
	disable iff(reset  || Done )	
	(!ctop.ControlBit) |=> (controlWord[ctop.CV.controlPtr] === 0);
endproperty
a_ctrlbitwhenlow: assert property (p_ctrlbitwhenlow) assertions_cnt++;

property p_ctrlbitwhenhi;
@(negedge clock)
	disable iff(reset  || Done)
	(ctop.ControlBit) |=> (controlWord[ctop.CV.controlPtr -1] === 1);
endproperty
a_ctrlbitwhenhi: assert property (p_ctrlbitwhenhi) assertions_cnt++;
				else $display("time %t, Ptr = %d;", $time, ctop.CV.controlPtr);

property p_lengthwhenctrlbithi;
@(negedge clock)
	disable iff(reset  || Done)
	(ctop.ControlBit) |-> (ctop.length >= 3);
endproperty
a_lengthwhenctrlbithi: assert property (p_lengthwhenctrlbithi) assertions_cnt++;
						else $display("time %t, fromHash = %d;", $time, ctop.hF.fromHash);				
				
endmodule
