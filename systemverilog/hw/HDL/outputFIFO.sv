//**************************************************************************************************************
//
//    L Z R W 1   E N C O D E R   C O R E
//
//  A high throughput loss less data compression core.
// 
// Copyright 2012-2017  Lukas Schrittwieser (LS) (VHDL Author)
//                      Manas Karanjekar    (MK) (SystemVerilog translator)
//                      Mark Chernishoff    (MC) (SystemVerilog translator)
//                      Parker Ridd         (PR) (SystemVerilog translator)
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
//***************************************************************************************************************
//*
//* Descrambles encoded data output into proper data stream and buffers data in an FIFO.
//* Note: This unit can accept simulatinous input of body and header data.
//* However there must not be too much data input. The minimum is 16 cycles between
//* two assertions of HeaderStrobexSI. This is due to internal bandwidth
//* limitations. The only exception to this rule is the very last frame. However
//* no additional data is permitted after it until the reset signal was applied
//*
//***************************************************************************************************************
module outputFIFO(
        ClkxCI,
        RstxRI,
        BodyDataxDI,
        BodyStrobexSI,
        HeaderDataxDI,
        HeaderStrobexSI,
        BuffersEmptyxSO,
        BufOutxDO,
        OutputValidxSO,
        RdStrobexSI,
        LengthxDO
    );

parameter FRAME_SIZE = 8;

    input  logic            ClkxCI;
    input  logic            RstxRI;
    input  logic[7:0]       BodyDataxDI;
    input  logic            BodyStrobexSI;
    input  logic[FRAME_SIZE-1:0]    HeaderDataxDI;
    input  logic            HeaderStrobexSI;
    output logic            BuffersEmptyxSO;
    output logic[7:0]       BufOutxDO;
    output logic            OutputValidxSO;
    input  logic            RdStrobexSI;
    output logic signed[0:1024]    LengthxDO;

endmodule;