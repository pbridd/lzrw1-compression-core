# lzrw1-compression-core
This is the repository for a verilog version of the lzrw1 compression core. It is loosely based on the VHDL compressor found at http://opencores.org/project,lzrw1-compressor-core and is extended to include a decompressor module. 


##Authors
The authors of this core are Manas Karanjekar (ManasK7), Mark Chernishoff (markcherni), and Parker Ridd (pbridd). The core was made for ECEn 571, Introduction to SystemVerilog, at Portland State University.

##Design
###Overview
This design includes a compressor core (under the compressor folder), a decompressor core (under the decompressor folder), and a high-level testbench.

####Compressor
Under construction

#### Decompressor
This module decompresses data that has been compressed using a LZRW1 algorithm. It accepts one piece of
compressed data every time data_in_valid is driven high, and outputs one byte of data every clock cycle
out_valid is 1'b1. 

When the control word is high, data_in_valid is high, and the compressor isn't busy, the decompressor
will go into the DECOMPRESS state. In this state, the decompressor will use the high four bits of the
data_in input to find the length of the compressed data (up to 15 bytes) and the low twelve bits to 
get the offset. It has an offset range of 4095 bytes. It outputs a distinct byte of data on deompressed_byte
for every cycle out_valid is 1'b1, and then goes back to the IDLE state after it is done, at which point
it can accept new data.

If the conditions above are met with the exception of control_word_in being 1'b0, the decompressor will simply
pass the byte through while writing the applicable space in its history memory. out_valid will go high for one
cycle to allow the byte to be passed through. After that one clock cycle, it will go back to the IDLE state.

#### High level testbench
Under construction

## How to run tests
Under construction