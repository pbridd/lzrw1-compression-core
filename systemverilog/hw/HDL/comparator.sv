//placeholder text

module comparator(
	input logic[16*8-1 : 0]	LookAheadxDI,
	input integer LookAheadLenxDI,				// how many bytes of LookAheadxDI are valid
	input logic[16*8-1 : 0] CandidatexDI,		
	input integer CandidateLenxDI,				// how many bytes of CandidatexDI are valid
	output integer MatchLenxDO);				// length of the match in bytes

	
	// logic declarations
	logic[15 : 0] MatchVectorxS;				// match signals for the individual bytes
	integer RawMatchLenxD;						// number of matching bytes (before further processing)
	integer MaxLengthxD;						// smaller of the two input signal length

	// implement 16 byte wide comparators
	always_comb begin : matchvectassign 
		for(int i = 0; i < 16; i++) begin
			MatchVectorxS(i) = (CandidatexDI[(i+1)*8 -: 8] == LookAheadxDI[(i+1)*8 -: 8]) ? 1'b1 : 1'b0;
		end
	end


endmodule