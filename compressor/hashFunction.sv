module hashFunction(
input reset,
input [4095:0][11:0] uniqnums, /* table of all unique numbers from testbench*/
input [23:0] toHash, /* from compinput */
output logic [11:0] fromHash); /* to tableofPtr*/


logic [11:0]index_part_1 ;
logic [11:0]index_part_2 ;
//logic [3:0]index_part_3 ;
//int seed_val = 40543;

/* Combinational logic to model hash function */
always_comb
begin
if (reset) begin
	index_part_1 = 0;
	index_part_2 = 0;
	//index_part_3 = 0;
	fromHash = 0;
end 
else begin
if (toHash[23:16] > 0 && toHash[15:8] == 0 )begin
index_part_1 = uniqnums[toHash[23:16]];
	index_part_2 =  uniqnums[toHash[15:8] ^ index_part_1];
	fromHash =  uniqnums[0 ^ index_part_2];
end
else begin
	index_part_1 = uniqnums[toHash[23:16]];
	index_part_2 =  uniqnums[toHash[15:8] ^ index_part_1];
	fromHash =  uniqnums[toHash[7:0] ^ index_part_2];
end	


end
end

endmodule