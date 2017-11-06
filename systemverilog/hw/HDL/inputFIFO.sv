//**************************************************************************************************************
//
//    L Z R W 1   E N C O D E R   C O R E
//
//  A high throughput loss less data compression core.
// 
// Copyright 2012-2017  Lukas Schrittwieser (LS) (VHDL Author)
//						Manas Karanjekar	(MK) (SystemVerilog translator)
//						Mark Chernishoff 	(MC) (SystemVerilog translator)
//						Parker Ridd			(PR) (SystemVerilog translator)
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
// Version 1.0 - 2012/6/30 - LS
//
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
// Implements a 4 byte input, 1 byte output FIFO buffer. Note: so far only writes where all 4 bytes contain
// data are supported.
//
//**************************************************************************************************************
module InputFIFO(
	input logic ClkxCI,
	input logic RstxRI,
	input logic[31 : 0] DInxDI,
	input logic WexSI,
	input logic StopOutputxSI,
	output logic BusyxSO,
	output logic[7 : 0] DOutxDO,
	output logic OutStrobexSO,
	output logic[2048 : 0] signed LengthxDO 
	);

	const integer ADR_BIT_LEN = 11;
	const integer DEPTH = 2048;

	logic[DEPTH : 0]   signed  LengthxDN, LengthxDP;
	logic[DEPTH-1 : 0] signed  WrPtrxDN, WrPtrxDP;
	logic[DEPTH-1 : 0] signed  RdPtrxDN, RdPtrxDP;
	logic DoWritexS, DoReadxS;
	logic OutStrobexSN, OutStrobexSP;
	logic BusyxSN, BusyxSP;

	logic[31 : 0] BRamDOutxD;
	logic[31 : 0] BRamDInxD;
	logic[13 : 0] BRamWrAdrxD;
	logic[13 : 0] BRamRdAdrxD;

	// write port logic
	always_comb begin : write_port_logic
		WrPtrxDN = WrPtrxDP;
		BusyxSN = 1'b0;
		BRamWrAdrxD = {WrPtrxDP, 3'b000};
		DoWritexS = 1'b0;

		if(WExSI = 1'b1 && LengthxDP <= (DEPTH-4)) begin
			DoWritexS = 1'b1;`
			if(WrPtrxDP < (DEPTH-4))
				WrPtrxDN = WrPtrxDP + 4;
			else
				WrPtrxDN = 0;
		end

		// use busy as an almost full indicator
		if(LengthxDP >= (DEPTH-8))
			BusyxSN = 1'b1;
	end

	// implement data output port logic
	// TODO pbridd: fix the error / assertion logic
	always_comb begin : lenCntAlways
		LengthxDN = LenthxDP;
		if(DoWritexS && (DoReadxS == 1'b0))
			LengthxDN <= LengthxDP + 4;
		else
			$error("-E- Input FIFO overrun");
		if(DoWritexS == 1'b0 && DoReadxS == 1'b1) begin
			assert(LengthxDP > 0);	
			else
				$error("-E- Input FIFO underrun");
			LengthxDN = LengthxDP - 1;
		end
		if(DoWritexS = 1'b1 && DoReadxS == 1'b1) begin
			assert(LengthxDP < DEPTH-3);
			else
				$error("-E- Input FIFO underrun at simultaneous read and write");
			LengthxDN = LengthxDP + 4 - 1;
		end
	end

	assign DOutxDO = BRamDOutxD[7:0];
	assign LengthxDO = LengthxDP;
	assign OutStrobexSO = OutStrobexSP;
	assign BusyxSO = BusyxSP;

	always_ff(posedge ClkxCI | posedge RstxRI) begin
		if(RstxRI = 1'b1) begin
			LengthxDP <= '0;
			WrPtrxDP <= '0;
			RdPtrxDP <= '0;
			OutStrobexSP <= '0;
			LengthxDP <= '0;
		end
		else
			LengthxDP <= LengthxDN;
			WrPtrxDP <= WrPtrxDN;
			RdPtrxDP <= RdPtrxDN;
			OutStrobexSP <= OutStrobexSN;
			BusyxSP <= BusyxSN;
		end
	end

endmodule