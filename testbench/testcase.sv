//`include "env.sv"
program testcase;

Environment env1;
initial
begin
$display("******************** Start of testcase*************************");
env1 = new();
env1.run();
#1000;
end

final
$display("*************** End of testcase **********************");

endprogram


