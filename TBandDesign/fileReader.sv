class file_reader;

/* Declaring virtual input interface */
virtual input_interface.IP input_intf;

function new(virtual input_interface.IP input_intf_new);
this.input_intf = input_intf_new;
endfunction	:	new

string data_to_send = "";
string global_string = "";
int char_no,low_val,high_val;
bit done = 1'b0;
bit flag;


/* This function reads data from the file and puts in the 'global string' */
function read_data;
string next_char;
int file_handle,j;
file_handle = $fopen("test_input.txt","r");	// Open the file in read mode
while(!$feof(file_handle))
begin
	j = $fscanf(file_handle,"%c",next_char);	// Read one character at a time into next_char	
	global_string = {global_string,next_char};	// Keep concatenating the next read character to the global string
	//$display("-D Global string is %s",global_string);
end

if($feof(file_handle))
begin
	//done = 1'b1;
end
endfunction	: read_data



/* This function is called whenever we have the 16 bytes buffer full */
task drive_data();
	int data_len = global_string.len();
	for(int start_point=0;start_point<data_len;start_point=start_point+16)
	begin
	@(posedge input_intf.clock)
	begin
	data_to_send <= global_string.substr(start_point,start_point+7);
	
	/* Drive data into the DUT */
	//input_intf.cb.CurByte <= data_to_send.atoi();
	input_intf.cb.CurByte <= int'(data_to_send);
	input_intf.cb.valid   <= 1'b1;
	input_intf.cb.reset   <= 1'b0;
	$display($time,"-D input_intf.cb.valid=%d",input_intf.cb.valid);
	$display("-D\tData to be sent is %p",data_to_send);
	$display("-D\tDUT input data : %p",input_intf.cb.CurByte);
	end
	end
	input_intf.cb.valid   <= 1'b0;
	//input_intf.cb.done    <= 1'b1;
	$display($time,"-D Finished driving data into compressor");
	$display($time,"-D input_intf.cb.valid=%d",input_intf.cb.valid);
	//end
endtask		: drive_data
endclass : file_reader






































//module testIt();
//
///* Create object of type file_reader */
//file_reader fr;
//
//initial
//begin
//	fr = new();			// Create object and allocate memory
//		fr.read_data();		// Reading data from input text file
//		$display("-D Now driving data into DUT...");
//		fr.drive_data();	// This needs to be executed at every clock edge
//	#1000;
//end
//
//final
//begin
//	$display("-D FINAL :Done =%d",fr.done);
//end
//endmodule
