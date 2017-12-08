class myChecker;
string str_out = "";
string str_in  = "";

/* Declaring virtual interfaces */
//virtual input_interface.IP input_intf;
virtual output_interface.OP output_intf;


function new(virtual output_interface.OP output_intf_new);
//this.input_intf = input_intf_new;
this.output_intf = output_intf_new;
endfunction;


function read_data;
string next_char;
int file_handle,j;
file_handle = $fopen("test_input.txt","r");	// Open the file in read mode
while(!$feof(file_handle))
begin
	j = $fscanf(file_handle,"%c",next_char);	// Read one character at a time into next_char	
	str_in = {str_in,next_char};	// Keep concatenating the next read character to the global string
	//$display("-D Global string is %s",str_in);
end

if($feof(file_handle))
begin
	//done = 1'b1;
end
endfunction : read_data




task wait_for_end();
$display("-D Inside wait_for_end function");
while(output_intf.cb.finished_cycle==0)
 begin
 @(negedge output_intf.clock)
 if(output_intf.cb.out_valid==1)
	begin 
	str_out = {str_out,string'(output_intf.cb.decompressed_byte)};
 	end
//$display("-D Output string is :");
//$display("%s",str_out);
 end	

endtask


function start_comparison();
//int errors;
//errors=0;
int flag=1'b0;
	/* Check if string lengths are equal */
	if(str_out.len()!=str_in.len())
	begin
	 str_in = str_in.substr(0,str_out.len());
	 $display("-D Input string is :");	
	 $display("-D ///////////////////////////////");
	 $display("INPUT STRING :");
	 $display("%p",str_in);
	 $display("OUTPUT STRING :");
	 $display("%p",str_out);
	 
	 $display("-D ///////////////////////////////");
	 
	 //$display("%s",str_in);
	end

	/* Check the input and the output strings */
	flag = str_in.compare(str_out)	;
	$display("-D Value of flag=%d",flag);
	if(flag!=1)
	$display("-D Decompressed string not same as compressed string");
	else
	$display("-D The compressed and the decompressed strings are the same");

endfunction

endclass
