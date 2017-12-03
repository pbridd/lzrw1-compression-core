//**************************************************************************************************************
//
//    L Z R W 1   E N C O D E R   C O R E
//
//  A high throughput loss less data compression core.
// 
// Copyright 2012-2017  Lukas Schrittwieser (LS) (VHDL Author)
//						Manas Karanjekar	(SystemVerilog translator)
//						Mark Chernishoff 	(SystemVerilog translator)
//						Parker Ridd			(SystemVerilog translator)
// 						 
// 
//
//    This program is free software: you can redistribute it and/or modify
//    it under the terms of the GNU General Public License as published by
//    the Free Software Foundation, either version 2 of the License, or
//    (at your option) any later version.
//
//    This program is distributed in the hope that it will be useful,
//    but WITHOUT ANY WARRANTY; without even the implied warranty of
//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//    GNU General Public License for more details.
//
//    You should have received a copy of the GNU General Public License
//    along with this program; if not, write to the Free Software
//    Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
//    Or see <http://www.gnu.org/licenses/>
//
//**************************************************************************************************************
//
// Change Log:
//
// Version 1.0 - 2012/6/30 - LS
//   started file
//
// Version 1.0 - 2013/04/05 - LS
//   release
//
//**************************************************************************************************************
//
// Naming convention:  http://dz.ee.ethz.ch/en/information/hdl-help/vhdl-naming-conventions.html
//
//**************************************************************************************************************
//
// Compares a the look ahead buffer to a candidate and returns the number of bytes before the first
// non-matching pair. The counting starts at the least significant end of the look ahead and the candidate
//
//**************************************************************************************************************


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

	// count how many bits match
	always_comb begin : matchcounter_block
		integer count = 0;
		for(int j = 0; j < 16; j++) begin
			if(MatchVectorxS(i) == 1'b1) 
				count += 1;
			else
				break;
		end
		assign RawMatchLenxD = count;
	end


	// the match length cannot be longer than the shorter of the two data inputs
	assign MaxLengthxD = (CandidateLenxDI < LookAheadLenxDI) ? CandidateLenxDI : LookAheadLenxDI;

	//make sure the match length is not bigger than the max length
	assign MatchLenxDO = (RawMatchLenxD <= MaxLengthxD) ? RawMatchLenxD : MaxLengthxD;

endmodule