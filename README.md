# lzrw1-compression-core
This is the repository for a verilog version of the lzrw1 compression core. The goal of this project was to make both a compressor and decompressor core that uses the LZRW1 compression algorithm. The long-term goal is to integrate both the cores into a single module and test them in a feedthrough fashion.

The project is loosely based on the VHDL compressor found at http://opencores.org/project,lzrw1-compressor-core. However, it was designed from scratch.


## Authors

The authors of this core are Manas Karanjekar (ManasK7), Mark Chernishoff (markcherni), and Parker Ridd (pbridd). The core was made for ECEn 571, Introduction to SystemVerilog, at Portland State University.

Contact for compressor: Mark Chernishoff

Contact for decompressor: Parker Ridd

Contact for combined testbench: Manas Karanjekar


## Progress

### Compressor

#### Validation

The compressor has been successfully validated using its standalone testbench. The testbench consists of feeding in an input string and outputting compressed data. Many assertions are checked in the testbench and the number is printed out when the string has finished being compressed.

#### Emulation
The compressor has been successfully emulated on the Veloce platform using the TBX mode of emulation.

### Decompressor

#### Validation

The decompressor has been successfully validated using manual test vectors that examine corner cases (including 256 repeating characters) as well as real text from websites and books. In addition, the testbench drives random generated strings into the decompressor and checks it against the original data. Errors are recorded and reported. A python3 program is included that can generate new random testvectors as well as manual testvectors given in test_vectors/manual_tvs.txt and line delimited.

#### Emulation

The basic framework has been laid down for decompressor to run in tbx mode and the decompressor modules were synthesized, but no attempt was made to run the testbench in this mode due to time constraints. 

### Top testbench

A testbench has been created that instantiates both the compressor and decompressor. This testbench successfully generates random values and drives them into the compressor, and then the top-level dut drives values into the decompressor. The decompressed characters are then collected by the testbench and compared to the original stimulus, and the testbench indicates whether they match.

## Design

### Overview

This design includes a compressor core (under the compressor folder), a decompressor core (under the decompressor folder), and a high-level testbench.

#### Compressor

This design takes a string and compresses it using the LZRW1 algorithm. When the valid signal goes high,
data in 16 byte chunks is expected to be at the input of CurBytes. The outputs afte compression completes
is an array of compressed values name compArray and an array of control bits named ControlWord.

While inputs are received, the compressor starts going to work on the CurBytes being fed into the input. 
The first 3 bytes starting at the char byte pointer are fed into the hash function to convert to a 12 bit 
address that access a table of pointers. If the entry is null, the current byte pointer is placed inside the
entry. If it is not null the old entry is the old byte position that had the same address and more likely that
it has the same 3 bytes as the current 3 bytes. If that is the case, a comparison up to 16 bytes is made starting
at the old byte position to 16 bytes past the new byte position. A length is returned from this comparison and an 
offset is calculated from old byte position to current byte position. 

If the table entry is null a control bit is set low and the output compArray gets the current byte at the current
byte position. If the entry is not null and the bytes match between 3 to 16 bytes, then the length is concatenated 
with the offset to form a 16 bit word. This 16 word is placed in the compArray. When the byte pointer reaches the end 
of the string a Done signal goes high, saying its complete. A reset is then needed to input new strings.

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

#### Top level testbench

The top-level testbench is an object-oriented testbench that generates a 'test_input.txt' file, which contains randomly generated strings, with the degree of randomization and repetition of alphabets being decided by a randcase statement.  The driver module takes this txt file and drives 16-bytes at a time(i.e. at posedge of clock) into the DUT. After the DUT is reset and initialized, we drive these 16-byte chunks, and ideally, we should see the output stream of bytes to match the input string. SystemVerilog concepts such as interfaces, polymorphism, constrained randomization with weighted distributions, string operations and general Object Oriented Programming were learnt and deployed in this top-level testbench.

## Running the design

### Prerequisites:

1. You must be on a machine that has QuestaSim installed and has access to the commmandline

2. You must be on a linux machine

3. To run the python testbench make stage (optional because randomly generated vectors have been provided), you must have python 3 installed on your computer

### Running the standalone compressor testbench

To run the compressor testbench, use the folliwing steps:

1. Run `make run_compressor_testbench`

2. Once questasim is launched via commandline, enter `run -all`.

3. If the test was successful, you should see output that contains the number of assertions checked, the input string, and the compressed output.

### Emulating the compressor

1. Log onto the veloce machine

2. cd into compressor/emulation

3. run `make -f Makefile_comp`

### Running the standalone decompressor testbench

To run the decompressor testbench, use the following steps

1. (optional & requires python 3 to be installed)
 : Run `make create_test_vectors` while cd'd into the root of this repository.

2. Run `make run_decompressor_testbench`

3. Once questasim is launched via commandline, enter `run -all` 

4. If the test was successful, you should see this output:

	```# Total tests failed was 0 out of 10 manual tests + 100 automatically generated tests```

### Running the integrated testbench

1. Run `make run_top_testbench`

2. Once questasim is launched via commandline, enter `run -all`

3. The test will show inputs being driven into the compressor, and then will show the input/output strings that were compared. Finally, it will indicate whether the strings match. If they do, the test passed.