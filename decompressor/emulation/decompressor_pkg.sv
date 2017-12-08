
package decompressor_pkg;

localparam STRINGSIZE = 350; 

// Bus sequence item struct

typedef struct packed {
	logic[3:0] length;
	logic[11:0] offset;
} compressed_t;

typedef union packed {
	logic[15:0] character;
	compressed_t compressed_objects;

} data_in_t;


typedef struct packed {
  // Request fields
bit Done;
logic [STRINGSIZE - 1:0] cWord;
logic [STRINGSIZE-1:0][7:0] cArray;
logic [STRINGSIZE -1:0][7:0] testString;
} properties;

endpackage: decompressor_pkg