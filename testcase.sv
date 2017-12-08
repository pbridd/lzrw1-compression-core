//`include "env.sv"
program testcase(input_interface.IP input_intf,output_interface.OP output_intf);

Environment env1;
initial
begin
$display("******************** Start of testcase*************************");
env1 = new(input_intf,output_intf);
//env1=new();
env1.run();
#1000;
end

final
$display("*************** End of testcase **********************");

endprogram


