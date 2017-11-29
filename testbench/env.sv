//`include "driver.sv"
class Environment;

driver drv;

function new();
$display(" : Environment .... Created new env object",$time);
endfunction	: new

task reset();
$display("Inside reset function");
endtask	: reset

task cfg_dut();
$display("Inside cfg_dut function");
endtask	: cfg_dut

task run();
$display(": Start of run() method ",$time);
reset();
cfg_dut();
$display(": End of run() method ",$time);
drv = new;
drv.start();
endtask	: run

endclass	: Environment
