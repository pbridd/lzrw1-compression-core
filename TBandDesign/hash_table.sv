/* Module implementing hash table functionality of the LRZW1 algorithm */
module hash_table #(parameter entry_BitWidth = 12)
		(
		input logic [23:0] bytes_in,	// Stream of 3 bytes of input from the compinput module
		input logic	    clk,
		input logic	  rst_b,
		output logic [11:0] offset,	// Acts as input to the History Buffer
		output logic [7:0] CurByte,	// Current byte
		output logic [7:0] bytePos,	// /* CONFIRM THIS FROM TEAM */  Position of current byte
		output logic control_Bit	// To indicate if it is a copy item or a literal 
		);
/* Creating a packed memory with 4096 locations and initializing to all zeros
 NOTE : Initialization is not actually required as per the research paper and is done for design convenience only
 */
logic [23:0] hash_table [2**entry_BitWidth-1:0];
int seed_val = 40543;

/* Declaring intermediate signals */
logic [entry_BitWidth-1:0]hash_index  ;
logic [7:0]index_part_1 ;
logic [7:0]index_part_2 ;
logic [7:0]index_part_3 ;
logic [7:0]	  byte1 ;
logic [7:0]	  byte2 ;
logic [7:0]	  byte3 ;

assign byte1 = bytes_in [23:16];	// Hold first input byte
assign byte2 = bytes_in [15:8];		// Hold second input byte
assign byte3 = bytes_in [7:0];		// Hold third input byte


/* Combinational logic to model hash function */
always_comb
begin
index_part_1 = byte1 << 4;
index_part_2 = (index_part_1 ^ byte2) << 4;
index_part_3 = (index_part_2 ^ byte3) >> 4;
hash_index   = (12'(seed_val) * (index_part_3)) & 12'hFFF;
end

/* Sequential logic to check for value pointed and updation */
always_ff @(posedge clk)
begin
offset <=  hash_table[hash_index];

/* If the offset value from the hash_table is less than 4096, then
   the new entry in the hash_table is the current byte position minus the offset, and the word is a copy item, so we set the control bit to 1 */
if(offset<4096)
begin
hash_table[hash_index] <= bytePos - offset;
control_Bit	       <= 1'b1;			// Copy item
end

/* If the offset value from the hash_table is greater than 4096, then it is a literal, so set control bit to 0, and offset is the present byte position
*/

else
begin
hash_table[hash_index] <= bytePos;
control_Bit	       <= 1'b0;			// Literal item
CurByte		       <= byte1;		// We need to transmit the current byte if it is a literal?	
end
end
endmodule :	hash_table 

