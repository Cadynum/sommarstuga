restart -f -nowave
add wave rst rx byteOut byteReady timing shift nextState state sync toggle i bitIndex
force clk 0 0ns, 1 5ns -repeat 10ns 
force rst 1 0ns, 0 0.052ms
force rx 1 0ms, 0 0.104166667ms -repeat 0.208333334ms 
run 3ms