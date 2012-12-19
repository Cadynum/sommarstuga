restart -f -nowave
add wave clk rst debugIn debugOut debugData rx tx
force clk 0 0ns, 1 5ns -repeat 10ns 
force rst 1 0ns, 0 30ns
force rx '1'
force txSend 0 0ms, 1 0.3ms
run 200ns


