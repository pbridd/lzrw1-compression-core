configure -emul CSDSOLO1
reg setvalue testbench.reset 1
run 50
reg setvalue testbench.reset 0
run 5000
upload -tracedir ./veloce.wave/wave1
memory upload -instance decompressed_byte -file result.txt
exit
