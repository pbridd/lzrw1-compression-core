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

/* Constraint number of characters to be between 500 and 4500 */ 
constraint no_of_char {no_of_characters>500;no_of_characters <4500;}
//no_of_characters = $random;
/* Constraining every letter to be ASCII */
constraint ascii_char {foreach(temp_arr[i]) temp_arr[i] inside{[65:90],[97:122]};};

	/* Constructor function */
	function new();
	endfunction

	
	function string str_gen();
	$display("-D\t no_of_characters=%d",no_of_characters);
	$display("-D\t Inside str_gen function of derived class");
	//foreach(temp_arr[i])
	//begin
	//for(int count=0;count<no_of_characters;count++)
	begin
		//$display("-D\t Inside for loop\t count=%d",count);
		/* Randomly generate a word */
		foreach(temp_arr[i])
			begin
			$display("-D\t Inside temp_arr foreach loop\t ");
			str = {str,string'(temp_arr[i])};
			end
		/* Append a space after randomly generated word */
		str = {str,blank_str};		
	end
	//end
	//for(int count=0;count<no_of_characters;count++)
	//begin
	//	//$display("-D\t Inside for loop\t count=%d",count);
	//	/* Randomly generate a word */
	//	foreach(temp_arr[i])
	//		begin
	//		$display("-D\t Inside temp_arr foreach loop\t count=%d",count);
	//		str = {str,string'(temp_arr[i])};
	//		end
	//	/* Append a space after randomly generated word */
	//	str = {str,blank_str};		
	//end
	endfunction

	function write_to_file();
	integer i;
	$display("-D	Inside write_to_file function of derived class");
	i = $fopen("test_input.txt");
	$fwrite(i,"",str);
	$fclose(i);
	return i;
	endfunction;

endclass


//class moderately_random extends text_writer;
//
//
//	function write_to_file();
//	integer i;
//	string str1;
//	i = $fopen("test_input_new.txt","a");
//	str1 = "asasas";
//	$fwrite(i," String is ",str1);
//	return i;
//	endfunction;
//
//endclass
//
//
//class all_strings_same extends text_writer;
//
//
//	function write_to_file();
//	integer i;
//	string str1;
//	i = $fopen("test_input_new.txt");
//	str1 = "asasas";
//	$fwrite(i," String is ",str1);
//	$fclose(i);
//	return i;
//	endfunction;
//
//endclass

module string_writer();
/* Declare handle for object of the class text_writer */
text_writer tw;
completely_random cr;
integer i1;
int no_of_words;
int random_no,j;
string str1;
initial 
begin
	tw = new();	// Create the object and allocate memory
	cr = new();	
	cr.randomize();
	no_of_words = cr.no_of_characters;
	tw = cr;
	//for(int i=0;i<10;i++)
	begin
	//j = $urandom;
	random_no=tw.seed_gen();
	$display("Random number is %d  and j is %d",random_no,j);
	for(int i=0;i<no_of_words;i++)
	begin
	cr.randomize();
	tw.str_gen();
	tw.write_to_file();
	end
	//tw.randomize();	// Randomizes the properties/variiables of the object 
	//i1 = tw.file_open();
	//str1 = tw.make_str();
	//$display("str 1 is %p",str1);
	//$fdisplay(i1," String is ",str1);
	//$fwrite(i1," String is ",str1);
	end
	//$fclose(i1);
end
endmodule : string_writer
