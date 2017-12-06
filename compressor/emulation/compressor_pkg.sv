package compressor_pkg;

localparam STRINGSIZE = 350; 

// Bus sequence item struct
typedef struct packed {
  // Request fields
bit Done;
logic [STRINGSIZE - 1:0] cWord;
logic [STRINGSIZE-1:0][7:0] cArray;
logic [STRINGSIZE -1:0][7:0] testString;
} properties;

endpackage: compressor_pkg