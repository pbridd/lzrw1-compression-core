module compinput_tb ();
parameter STRINGSIZE = 88;
parameter TABLESIZE = 4096;
localparam delay = 5ns;
bit clock, reset, valid;
logic [15:0] [7:0] CurByte; 
bit Done;

logic [STRINGSIZE - 1:0] controlWord;
logic [STRINGSIZE-1:0][7:0] compArray;


compressor_top #(STRINGSIZE,TABLESIZE) ctop (clock,reset,valid,CurByte,Done,compArray,controlWord);


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
	wait (Done) $display("%s",compArray);
	
end


endmodule
