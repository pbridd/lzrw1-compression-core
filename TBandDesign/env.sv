//`include "driver.sv"
class Environment;

driver drv;

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
$display($time,"Inside reset function");
end
endtask	: reset

task cfg_dut();
$display("Inside cfg_dut function");
endtask	: cfg_dut

task run();
$display(": Start of run() method ",$time);
reset();
cfg_dut();
$display(": End of run() method ",$time);
drv = new(input_intf);
drv.start();
endtask	: run

endclass	: Environment
