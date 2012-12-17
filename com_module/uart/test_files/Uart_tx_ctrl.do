restart -f -nowave
add wave clk bitDone txState txBit bitIndex DATA SEND READY UART_TX
force clk 0 0ns, 1 5ns -repeat 10ns 
force DATA "10100101"
force SEND 0 0ms, 1 0.3ms
run 3ms