module hashFunction(
input reset,
input [23:0] toHash, /* from compinput */
output logic [11:0] fromHash); /* to tableofPtr*/


logic [3:0]index_part_1 ;
logic [3:0]index_part_2 ;
logic [3:0]index_part_3 ;
int seed_val = 40543;

/* Combinational logic to model hash function */
always_comb
begin
if (reset) begin
	index_part_1 = 0;
	index_part_2 = 0;
	index_part_3 = 0;
	fromHash = 0;
end 
else begin

	if(toHash[7:0] == 0 ) index_part_1 = 122;
	else if(toHash[15:8] == 0 ) index_part_2 = 122;
	else if(toHash[23:16] == 0 ) index_part_3 = 122;
	else begin
	index_part_1 = toHash[3:0] ^ toHash[7:4];
	index_part_2 = toHash[15:12] ^toHash[11:8];
	index_part_3 = toHash[23:20] ^toHash[19:16];
	end
	fromHash  = {index_part_2, index_part_3, index_part_1};
end
end

endmodule