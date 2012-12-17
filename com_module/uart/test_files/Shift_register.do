restart -f -nowave
add wave clk serialIn shift byteOut
force clk 0 0ns, 1 10ns -repeat 20ns 
force serialIn 0 0ns, 1 40ns -repeat 80ns
force shift 0 0ns, 1 40ns
run 250ns