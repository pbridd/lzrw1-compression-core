class text_writer;
	rand byte unsigned temp_arr[];
	constraint str_len {temp_arr.size == 5;}		// Length of the string
	int my_seed;
	/* Constraining every letter to be ASCII */
	constraint ascii_char {foreach(temp_arr[i]) temp_arr[i] inside{[65:90],[97:122]};}

	/* Generate a random seed and depending upon the seed select text generator  */
	function int seed_gen();
	my_seed = $random;
	$display("-D\t my_seed=%d",my_seed);
	return my_seed;
	endfunction	: seed_gen

	/* Virtual function to generate randomized strings */
	virtual function string str_gen();
	//$display("-D Inside base class str_gen function");
	endfunction;

	/* Virtual function to write the randomly generated string to a file */
	virtual function write_to_file();
	//$display("-D Inside base class write_to_file function");
	endfunction;
	
	virtual function open_file();
	endfunction;
	virtual function close_file();
	endfunction;
endclass

class completely_random extends text_writer;

/* Constraint length of strings generated to be of either 2,3 or 4 characters with a 5 character string to be unlikely */
//constraint str_len {temp_arr.size dist {2:=60, [3:4]:=80,5:=40};}
constraint str_len {temp_arr.size dist {[3:4]:=80};}
//$display("-D 	Inside completely_random function");
rand byte unsigned temp_arr[];
rand int no_of_characters;
string blank_str = " ";
string str;
integer file_handle;
/* Constraint number of characters to be between 500 and 4500 */ 
constraint no_of_char {no_of_characters>50;no_of_characters <450;}
//no_of_characters = $random;
/* Constraining every letter to be ASCII */
constraint ascii_char {foreach(temp_arr[i]) temp_arr[i] inside{[65:90],[97:122]};};

	///* Constructor function */
	//function new();
	//endfunction

	
	function string str_gen();
	//$display("-D\t no_of_characters=%d",no_of_characters);
	//$display("-D\t Inside str_gen function of derived class");
	begin
		/* Randomly generate a word */
		foreach(temp_arr[i])
			begin
			//$display("-D\t Inside temp_arr foreach loop\t ");
			str = {str,string'(temp_arr[i])};
			end
		/* Append a space after randomly generated word */
		str = {str,blank_str};		
	end
	endfunction

	function open_file();
	file_handle = $fopen("test_input.txt"); 
	endfunction;

	function write_to_file();
	//$display("-D	Inside write_to_file function of derived class:");
	$fwrite(file_handle,"",str);
	endfunction;

	function close_file();
	$fclose(file_handle);
	endfunction;
endclass

class moderately_random extends text_writer;

/* Constraint length of strings generated to be of either 2,3 or 4 characters with a 5 character string to be unlikely */
//constraint str_len {temp_arr.size dist {2:=60, [3:4]:=80,5:=40};}
constraint str_len {temp_arr.size dist {[3:4]:=80};}
//$display("-D 	Inside completely_random function");
rand byte unsigned temp_arr[];
rand int no_of_characters;
string blank_str = " ";
string str;
int words_for_text[],j,k;	// Dynamic array to store a set of words that will be repeated
int strings_for_text[][];
/* Constraint number of characters to be between 500 and 4500 */ 
constraint no_of_char {no_of_characters>50;no_of_characters <450;}
//no_of_characters = $random;
/* Constraining every letter to be ASCII */
constraint ascii_char {foreach(temp_arr[i]) temp_arr[i] inside{[65:90],[97:122]};};

	integer file_handle;
	function string str_gen();
	//$display("-D\t no_of_characters=%d",no_of_characters);
	//$display("-D\t Inside str_gen function of derived class : moderately_random");
	begin
		/* Randomly generate a word */
		foreach(temp_arr[i])
			begin
			//$display("-D\t Inside temp_arr foreach loop\t ");
			//temp_arr[i].randomize();
			str = {str,string'(temp_arr[i])};
			end
		/* Append a space after randomly generated word */
		str = {str,blank_str};		
	end
	endfunction

	function open_file();
	file_handle = $fopen("test_input.txt"); 
	endfunction;

	function write_to_file();
	integer i;
	//$display("-D	Inside write_to_file function of derived class : moderately_random");
	//i = $fopen("test_input.txt");
	$fwrite(file_handle,"",str);
	//$fclose(i);
	//return i;
	endfunction;
	
	function close_file();
	$fclose(file_handle);
	endfunction;

endclass	: moderately_random


class all_strings_same extends text_writer;

/* Constraint length of strings generated to be of either 2,3 or 4 characters with a 5 character string to be unlikely */
//constraint str_len {temp_arr.size dist {2:=60, [3:4]:=80,5:=40};}
//constraint str_len {temp_arr.size dist {[3:4]:=80};}
//$display("-D 	Inside completely_random function");
rand byte unsigned temp_arr;
rand int no_of_characters;
string blank_str = " ";
string str;
int words_for_text[],j,k;	// Dynamic array to store a set of words that will be repeated
int strings_for_text[][];
/* Constraint number of characters to be between 50 and 450 */ 
constraint no_of_char {no_of_characters>50;no_of_characters <450;}
//no_of_characters = $random;
/* Constraining every letter to be ASCII */
constraint ascii_char {temp_arr inside{[65:90],[97:122]};};

	integer file_handle;
	function string str_gen();
	//$display("-D\t no_of_characters=%d",no_of_characters);
	//$display("-D\t Inside str_gen function of derived class : all_strings_same");
	begin
	int rand_no = $random;
		/* Randomly generate a word */
		for(int i=0;i<rand_no%50;i++)
			begin
			//$display("-D\t Inside temp_arr foreach loop\t :all_strings_same ");
			str = {str,string'(temp_arr)};
			end
		/* Append a space after randomly generated word */
		str = {str,blank_str};		
	end
	endfunction

	function open_file();
	file_handle = $fopen("test_input.txt"); 
	endfunction;

	function write_to_file();
	$fwrite(file_handle,"",str);
	endfunction;
	
	function close_file();
	$fclose(file_handle);
	endfunction;

endclass	: all_strings_same


//module string_writer();
///* Declare handle for object of the class text_writer */
//text_writer tw;
//completely_random cr;
//moderately_random mr;
//all_strings_same ar;
//integer i1;
//int no_of_words;
//int random_no,j;
//string str1;
//initial 
//begin
//	tw = new();	// Create the object and allocate memory
//
//	randcase
//	0 : 	begin
//		cr = new();
//		tw = cr;
//		cr.randomize();
//		no_of_words = cr.no_of_characters;
//		for(int i=0;i<no_of_words;i++)
//			begin
//			cr.randomize();
//			tw.str_gen();
//			end	
//		tw.open_file();
//		tw.write_to_file();
//		tw.close_file();
//		end
//
//	10 : 	begin
//		mr = new();
//		tw = mr;
//		mr.randomize();
//		no_of_words = mr.no_of_characters;
//		for(int i=0;i<no_of_words;i++)
//			begin
//			mr.randomize();
//			tw.str_gen();
//			end	
//		tw.open_file();
//		tw.write_to_file();
//		tw.close_file();
//		end
//
//	0 : 	begin
//		ar = new();
//		tw = ar;
//		ar.randomize();
//		no_of_words = ar.no_of_characters;
//		for(int i=0;i<no_of_words;i++)
//			begin
//			ar.randomize();
//			tw.str_gen();
//			end	
//		tw.open_file();
//		tw.write_to_file();
//		tw.close_file();
//		end
//	endcase
//
//
//
//
//
//
//
//	////cr = new();	
//	////mr = new();
//	//ar = new();
//	//ar.randomize();
//	////mr.randomize();
//	////cr.randomize();
//	//
//	//no_of_words = ar.no_of_characters;
//	//$display("-D\t no_of_words=%0d",no_of_words);
//	////tw = cr;
//	//tw = ar;
//	////for(int i=0;i<10;i++)
//	//begin
//	////j = $urandom;
//	//random_no=tw.seed_gen();
//	//$display("Random number is %d  and j is %d",random_no,j);
//	//for(int i=0;i<no_of_words%10;i++)
//	//begin
//	//$display("-D\t no_of_words=%0d",no_of_words);
//	//ar.randomize();
//	////cr.randomize();
//	//tw.str_gen();
//	//end
//	//tw.open_file();
//	//for(int i=0;i<no_of_words%10;i++)
//	//begin
//	//tw.write_to_file();
//	//end
//	//tw.close_file();
//	////tw.randomize();	// Randomizes the properties/variiables of the object 
//	////i1 = tw.file_open();
//	////str1 = tw.make_str();
//	////$display("str 1 is %p",str1);
//	////$fdisplay(i1," String is ",str1);
//	////$fwrite(i1," String is ",str1);
//	//end
//	////$fclose(i1);
//end
//endmodule : string_writer
