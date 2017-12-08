//`include "driver.sv"
class Environment;

string out_str="";
driver drv;
myChecker chk;
/* Declaring virtual interfaces */
virtual input_interface.IP input_intf;
virtual output_interface.OP output_intf;


function new(virtual input_interface.IP input_intf_new,
	     virtual output_interface.OP output_intf_new);

this.input_intf = input_intf_new;
this.output_intf= output_intf_new;

$display(" : Environment .... Created new env object",$time);
endfunction	: new

task reset();
@(posedge input_intf.clock)
begin
input_intf.cb.reset <= 1'b1;
input_intf.cb.valid <= 1'b0;
$display($time,"-D Inside reset function");
end
endtask	: reset

task cfg_dut();
$display("-D Inside cfg_dut function");
endtask	: cfg_dut

task wait_for_end();
$display("-D Inside wait_for_end function");
while(output_intf.cb.finished_cycle==0)
 begin
 @(negedge input_intf.clock)
 if(output_intf.cb.out_valid==1)
	begin 
	out_str = {out_str,string'(output_intf.cb.decompressed_byte)};
 	end
$display("-D Output string is :");
$display("%s",out_str);
 end	

endtask : wait_for_end


task run();
$display(": Start of run() method ",$time);
reset();
cfg_dut();
$display(": End of run() method ",$time);
drv = new(input_intf);
drv.start();
//wait_for_end();
chk = new(output_intf);
chk.wait_for_end();
chk.read_data();
chk.start_comparison();
endtask	: run


endclass	: Environment
