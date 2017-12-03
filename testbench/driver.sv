//`include "fileReader.sv"
//`include "string_writer.sv"
class driver;
/* Create objects of class file_reader and string_writer */
file_reader fr;
text_writer tw;
int no_of_words;
task start();
$display("-D\t Inside start method of the driver");
/* We first generate a test file */
tw = new;	// Create object and allocate memory
fr = new;	// Create object and allocate memory

	randcase
	0 : 	begin
		completely_random cr;
		cr = new();
		tw = cr;
		cr.randomize();
		no_of_words = cr.no_of_characters;
		for(int i=0;i<no_of_words;i++)
			begin
			cr.randomize();
			tw.str_gen();
			end	
		tw.open_file();
		tw.write_to_file();
		tw.close_file();
		end

	0 : 	begin
		moderately_random mr;
		mr = new();
		tw = mr;
		mr.randomize();
		no_of_words = mr.no_of_characters;
		for(int i=0;i<no_of_words;i++)
			begin
			mr.randomize();
			tw.str_gen();
			end	
		tw.open_file();
		tw.write_to_file();
		tw.close_file();
		end

	10 : 	begin
		all_strings_same ar;
		ar = new();
		tw = ar;
		ar.randomize();
		no_of_words = ar.no_of_characters;
		for(int i=0;i<no_of_words;i++)
			begin
			ar.randomize();
			tw.str_gen();
			end	
		tw.open_file();
		tw.write_to_file();
		tw.close_file();
		end
	endcase

/* At this stage we have the randomly generated test file ready */
$display("****************New test file generated**************");

fr.read_data();
fr.drive_data();

endtask	: start



endclass	:	driver
